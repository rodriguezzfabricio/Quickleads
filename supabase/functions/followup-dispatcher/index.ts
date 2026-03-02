import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js@2.49.8";

import { HttpError, isHttpError } from "../_shared/auth.ts";
import {
  applyRetryDelay,
  isWithinSendWindow,
  nextSendWindowStart,
  normalizeTimezone,
} from "../_shared/followup_schedule.ts";
import {
  renderTemplate,
  sendEmail,
  sendSms,
  type TemplateTokens,
} from "../_shared/messaging.ts";

type ErrorCode =
  | "method_not_allowed"
  | "unauthorized"
  | "invalid_request"
  | "internal_error";

interface ApiError {
  ok: false;
  error: {
    code: ErrorCode;
    message: string;
  };
}

interface DispatcherStats {
  due_count: number;
  processed_count: number;
  sent_count: number;
  retried_count: number;
  failed_count: number;
  deferred_count: number;
  skipped_count: number;
}

interface ApiSuccess {
  ok: true;
  data: DispatcherStats;
}

interface FollowupMessageRow {
  id: string;
  sequence_id: string;
  step_number: number;
  channel: "sms" | "email";
  template_key: string;
  scheduled_at: string;
  retry_count: number;
  status: string;
}

interface FollowupSequenceRow {
  id: string;
  organization_id: string;
  lead_id: string;
  state: string;
  timezone: string | null;
}

interface LeadRow {
  id: string;
  organization_id: string;
  client_name: string;
  job_type: string;
  phone_e164: string | null;
  email: string | null;
  created_by_profile_id: string | null;
  followup_state: string;
  status: string;
}

interface MessageTemplateRow {
  organization_id: string;
  template_key: string;
  sms_body: string | null;
  email_subject: string | null;
  email_body: string | null;
}

interface ProfileRow {
  id: string;
  organization_id: string;
  full_name: string;
  role: string;
}

interface OrganizationRow {
  id: string;
  name: string;
  timezone: string | null;
}

const MAX_RETRIES = 3;
const BATCH_LIMIT = 200;

function jsonResponse(payload: ApiSuccess | ApiError, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "content-type": "application/json; charset=utf-8",
    },
  });
}

function requireEnv(name: string): string {
  const value = Deno.env.get(name)?.trim();
  if (!value) {
    throw new HttpError(500, "internal_error", `Missing required environment variable: ${name}`);
  }
  return value;
}

function createServiceRoleClient(): SupabaseClient {
  const supabaseUrl = requireEnv("SUPABASE_URL");
  const serviceRoleKey = requireEnv("SUPABASE_SERVICE_ROLE_KEY");

  return createClient(supabaseUrl, serviceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
    global: {
      headers: {
        Authorization: `Bearer ${serviceRoleKey}`,
      },
    },
  });
}

function assertDispatcherAuthorization(request: Request): void {
  const configuredSecret = Deno.env.get("FOLLOWUP_DISPATCHER_SECRET")?.trim();
  if (!configuredSecret) {
    return;
  }

  const incoming = request.headers.get("x-dispatcher-secret")?.trim();
  if (!incoming || incoming !== configuredSecret) {
    throw new HttpError(401, "unauthorized", "Dispatcher secret is invalid.");
  }
}

function toInteger(value: unknown, field: string): number {
  if (typeof value === "number" && Number.isInteger(value)) {
    return value;
  }

  if (typeof value === "string") {
    const parsed = Number.parseInt(value, 10);
    if (Number.isInteger(parsed)) {
      return parsed;
    }
  }

  throw new HttpError(500, "internal_error", `Expected integer value for ${field}.`);
}

function parseDueMessages(rows: unknown[]): FollowupMessageRow[] {
  const parsed: FollowupMessageRow[] = [];

  for (const row of rows) {
    const record = row as Record<string, unknown>;
    if (
      typeof record.id !== "string" ||
      typeof record.sequence_id !== "string" ||
      typeof record.channel !== "string" ||
      typeof record.template_key !== "string" ||
      typeof record.scheduled_at !== "string" ||
      typeof record.status !== "string"
    ) {
      continue;
    }

    if (record.channel !== "sms" && record.channel !== "email") {
      continue;
    }

    let stepNumber: number;
    let retryCount: number;
    try {
      stepNumber = toInteger(record.step_number, "step_number");
      retryCount = toInteger(record.retry_count ?? 0, "retry_count");
    } catch {
      continue;
    }

    parsed.push({
      id: record.id,
      sequence_id: record.sequence_id,
      step_number: stepNumber,
      channel: record.channel,
      template_key: record.template_key,
      scheduled_at: record.scheduled_at,
      retry_count: retryCount,
      status: record.status,
    });
  }

  return parsed;
}

function getUnique(values: Array<string | null | undefined>): string[] {
  return [...new Set(values.filter((value): value is string => typeof value === "string" && value.length > 0))];
}

function templateMapKey(organizationId: string, templateKey: string): string {
  return `${organizationId}::${templateKey}`;
}

async function updateMessageAsSent(
  client: SupabaseClient,
  message: FollowupMessageRow,
  providerMessageId: string | undefined,
): Promise<void> {
  const { error } = await client
    .from("followup_messages")
    .update({
      status: "sent",
      sent_at: new Date().toISOString(),
      provider_message_id: providerMessageId ?? null,
      error_message: null,
    })
    .eq("id", message.id)
    .eq("status", "queued");

  if (error) {
    throw new HttpError(500, "internal_error", `Failed to mark follow-up message ${message.id} as sent.`);
  }
}

async function updateMessageForRetryOrFailure(
  client: SupabaseClient,
  message: FollowupMessageRow,
  timezone: string,
  failureReason: string,
  options?: { permanent?: boolean },
): Promise<"retried" | "failed"> {
  const permanent = options?.permanent === true;
  const nextRetryCount = permanent ? MAX_RETRIES : message.retry_count + 1;

  if (nextRetryCount >= MAX_RETRIES) {
    const { error } = await client
      .from("followup_messages")
      .update({
        status: "failed",
        retry_count: nextRetryCount,
        error_message: failureReason,
      })
      .eq("id", message.id)
      .eq("status", "queued");

    if (error) {
      throw new HttpError(500, "internal_error", `Failed to mark follow-up message ${message.id} as failed.`);
    }

    return "failed";
  }

  const retryAt = applyRetryDelay(new Date().toISOString(), timezone, nextRetryCount);

  const { error } = await client
    .from("followup_messages")
    .update({
      status: "queued",
      retry_count: nextRetryCount,
      scheduled_at: retryAt,
      error_message: failureReason,
    })
    .eq("id", message.id)
    .eq("status", "queued");

  if (error) {
    throw new HttpError(500, "internal_error", `Failed to reschedule follow-up message ${message.id} for retry.`);
  }

  return "retried";
}

async function deferMessageToWindow(
  client: SupabaseClient,
  message: FollowupMessageRow,
  timezone: string,
): Promise<void> {
  const deferredAt = nextSendWindowStart(new Date().toISOString(), timezone);

  const { error } = await client
    .from("followup_messages")
    .update({
      scheduled_at: deferredAt,
      error_message: null,
    })
    .eq("id", message.id)
    .eq("status", "queued");

  if (error) {
    throw new HttpError(500, "internal_error", `Failed to defer follow-up message ${message.id}.`);
  }
}

async function refreshSequenceNextSendAt(
  client: SupabaseClient,
  sequenceIds: string[],
  stateBySequenceId: Map<string, string>,
): Promise<void> {
  if (sequenceIds.length === 0) {
    return;
  }

  const { data: queuedRows, error: queuedError } = await client
    .from("followup_messages")
    .select("sequence_id,scheduled_at")
    .in("sequence_id", sequenceIds)
    .eq("status", "queued")
    .order("scheduled_at", { ascending: true });

  if (queuedError) {
    throw new HttpError(500, "internal_error", "Failed to compute follow-up sequence next_send_at values.");
  }

  const nextBySequence = new Map<string, string>();
  for (const row of (queuedRows ?? []) as Array<Record<string, unknown>>) {
    const sequenceId = typeof row.sequence_id === "string" ? row.sequence_id : null;
    const scheduledAt = typeof row.scheduled_at === "string" ? row.scheduled_at : null;
    if (!sequenceId || !scheduledAt) {
      continue;
    }

    if (!nextBySequence.has(sequenceId)) {
      nextBySequence.set(sequenceId, scheduledAt);
    }
  }

  for (const sequenceId of sequenceIds) {
    const state = stateBySequenceId.get(sequenceId) ?? "active";
    const nextSendAt = state === "active" ? nextBySequence.get(sequenceId) ?? null : null;

    const { error: updateError } = await client
      .from("followup_sequences")
      .update({ next_send_at: nextSendAt })
      .eq("id", sequenceId);

    if (updateError) {
      throw new HttpError(500, "internal_error", `Failed to update next_send_at for sequence ${sequenceId}.`);
    }
  }
}

function mapError(error: unknown): { status: number; body: ApiError } {
  if (isHttpError(error)) {
    const code: ErrorCode =
      error.status === 401
        ? "unauthorized"
        : error.status === 400
          ? "invalid_request"
          : "internal_error";

    return {
      status: error.status,
      body: {
        ok: false,
        error: {
          code,
          message: error.message,
        },
      },
    };
  }

  return {
    status: 500,
    body: {
      ok: false,
      error: {
        code: "internal_error",
        message: "Unexpected server error.",
      },
    },
  };
}

Deno.serve(async (request: Request) => {
  if (request.method !== "POST") {
    return jsonResponse(
      {
        ok: false,
        error: {
          code: "method_not_allowed",
          message: "Only POST is supported for this endpoint.",
        },
      },
      405,
    );
  }

  try {
    assertDispatcherAuthorization(request);

    const client = createServiceRoleClient();
    const nowIso = new Date().toISOString();

    const { data: dueRaw, error: dueError } = await client
      .from("followup_messages")
      .select("id,sequence_id,step_number,channel,template_key,scheduled_at,retry_count,status")
      .eq("status", "queued")
      .lte("scheduled_at", nowIso)
      .order("scheduled_at", { ascending: true })
      .limit(BATCH_LIMIT);

    if (dueError) {
      throw new HttpError(500, "internal_error", "Failed to query due follow-up messages.");
    }

    const dueMessages = parseDueMessages(Array.isArray(dueRaw) ? dueRaw : []);

    if (dueMessages.length === 0) {
      return jsonResponse({
        ok: true,
        data: {
          due_count: 0,
          processed_count: 0,
          sent_count: 0,
          retried_count: 0,
          failed_count: 0,
          deferred_count: 0,
          skipped_count: 0,
        },
      });
    }

    const sequenceIds = getUnique(dueMessages.map((message) => message.sequence_id));

    const { data: sequenceRaw, error: sequenceError } = await client
      .from("followup_sequences")
      .select("id,organization_id,lead_id,state,timezone")
      .in("id", sequenceIds);

    if (sequenceError) {
      throw new HttpError(500, "internal_error", "Failed to resolve follow-up sequences.");
    }

    const sequencesById = new Map<string, FollowupSequenceRow>();
    for (const row of (sequenceRaw ?? []) as Array<Record<string, unknown>>) {
      if (
        typeof row.id !== "string" ||
        typeof row.organization_id !== "string" ||
        typeof row.lead_id !== "string" ||
        typeof row.state !== "string"
      ) {
        continue;
      }

      sequencesById.set(row.id, {
        id: row.id,
        organization_id: row.organization_id,
        lead_id: row.lead_id,
        state: row.state,
        timezone: typeof row.timezone === "string" ? row.timezone : null,
      });
    }

    const leadIds = getUnique([...sequencesById.values()].map((sequence) => sequence.lead_id));
    const organizationIds = getUnique([...sequencesById.values()].map((sequence) => sequence.organization_id));

    const [{ data: leadRaw, error: leadError }, { data: orgRaw, error: orgError }] = await Promise.all([
      client
        .from("leads")
        .select("id,organization_id,client_name,job_type,phone_e164,email,created_by_profile_id,followup_state,status")
        .in("id", leadIds),
      client
        .from("organizations")
        .select("id,name,timezone")
        .in("id", organizationIds),
    ]);

    if (leadError) {
      throw new HttpError(500, "internal_error", "Failed to resolve leads for follow-up dispatch.");
    }

    if (orgError) {
      throw new HttpError(500, "internal_error", "Failed to resolve organizations for follow-up dispatch.");
    }

    const leadsById = new Map<string, LeadRow>();
    for (const row of (leadRaw ?? []) as Array<Record<string, unknown>>) {
      if (
        typeof row.id !== "string" ||
        typeof row.organization_id !== "string" ||
        typeof row.client_name !== "string" ||
        typeof row.job_type !== "string" ||
        typeof row.followup_state !== "string" ||
        typeof row.status !== "string"
      ) {
        continue;
      }

      leadsById.set(row.id, {
        id: row.id,
        organization_id: row.organization_id,
        client_name: row.client_name,
        job_type: row.job_type,
        phone_e164: typeof row.phone_e164 === "string" ? row.phone_e164 : null,
        email: typeof row.email === "string" ? row.email : null,
        created_by_profile_id:
          typeof row.created_by_profile_id === "string"
            ? row.created_by_profile_id
            : null,
        followup_state: row.followup_state,
        status: row.status,
      });
    }

    const organizationsById = new Map<string, OrganizationRow>();
    for (const row of (orgRaw ?? []) as Array<Record<string, unknown>>) {
      if (
        typeof row.id !== "string" ||
        typeof row.name !== "string"
      ) {
        continue;
      }

      organizationsById.set(row.id, {
        id: row.id,
        name: row.name,
        timezone: typeof row.timezone === "string" ? row.timezone : null,
      });
    }

    const templateKeys = getUnique(dueMessages.map((message) => message.template_key));
    const { data: templateRaw, error: templateError } = await client
      .from("message_templates")
      .select("organization_id,template_key,sms_body,email_subject,email_body")
      .in("organization_id", organizationIds)
      .in("template_key", templateKeys)
      .eq("active", true);

    if (templateError) {
      throw new HttpError(500, "internal_error", "Failed to resolve follow-up message templates.");
    }

    const templatesByKey = new Map<string, MessageTemplateRow>();
    for (const row of (templateRaw ?? []) as Array<Record<string, unknown>>) {
      if (typeof row.organization_id !== "string" || typeof row.template_key !== "string") {
        continue;
      }

      templatesByKey.set(templateMapKey(row.organization_id, row.template_key), {
        organization_id: row.organization_id,
        template_key: row.template_key,
        sms_body: typeof row.sms_body === "string" ? row.sms_body : null,
        email_subject: typeof row.email_subject === "string" ? row.email_subject : null,
        email_body: typeof row.email_body === "string" ? row.email_body : null,
      });
    }

    const profileIds = getUnique(
      [...leadsById.values()].map((lead) => lead.created_by_profile_id),
    );

    const [{ data: profileRaw, error: profileError }, { data: ownerRaw, error: ownerError }] = await Promise.all([
      profileIds.length > 0
        ? client
            .from("profiles")
            .select("id,organization_id,full_name,role")
            .in("id", profileIds)
        : Promise.resolve({ data: [], error: null }),
      organizationIds.length > 0
        ? client
            .from("profiles")
            .select("id,organization_id,full_name,role")
            .in("organization_id", organizationIds)
            .eq("role", "owner")
        : Promise.resolve({ data: [], error: null }),
    ]);

    if (profileError) {
      throw new HttpError(500, "internal_error", "Failed to resolve contractor profiles.");
    }

    if (ownerError) {
      throw new HttpError(500, "internal_error", "Failed to resolve owner fallback profiles.");
    }

    const profilesById = new Map<string, ProfileRow>();
    for (const row of (profileRaw ?? []) as Array<Record<string, unknown>>) {
      if (
        typeof row.id !== "string" ||
        typeof row.organization_id !== "string" ||
        typeof row.full_name !== "string" ||
        typeof row.role !== "string"
      ) {
        continue;
      }

      profilesById.set(row.id, {
        id: row.id,
        organization_id: row.organization_id,
        full_name: row.full_name,
        role: row.role,
      });
    }

    const ownerByOrganizationId = new Map<string, ProfileRow>();
    for (const row of (ownerRaw ?? []) as Array<Record<string, unknown>>) {
      if (
        typeof row.id !== "string" ||
        typeof row.organization_id !== "string" ||
        typeof row.full_name !== "string" ||
        typeof row.role !== "string"
      ) {
        continue;
      }

      if (!ownerByOrganizationId.has(row.organization_id)) {
        ownerByOrganizationId.set(row.organization_id, {
          id: row.id,
          organization_id: row.organization_id,
          full_name: row.full_name,
          role: row.role,
        });
      }
    }

    const touchedSequenceIds = new Set<string>();

    const stats: DispatcherStats = {
      due_count: dueMessages.length,
      processed_count: 0,
      sent_count: 0,
      retried_count: 0,
      failed_count: 0,
      deferred_count: 0,
      skipped_count: 0,
    };

    for (const message of dueMessages) {
      const sequence = sequencesById.get(message.sequence_id);
      if (!sequence) {
        stats.skipped_count += 1;
        continue;
      }

      if (sequence.state !== "active") {
        stats.skipped_count += 1;
        touchedSequenceIds.add(sequence.id);
        continue;
      }

      const lead = leadsById.get(sequence.lead_id);
      if (!lead) {
        stats.skipped_count += 1;
        touchedSequenceIds.add(sequence.id);
        continue;
      }

      if (lead.status !== "estimate_sent" || lead.followup_state !== "active") {
        stats.skipped_count += 1;
        touchedSequenceIds.add(sequence.id);
        continue;
      }

      const organization = organizationsById.get(sequence.organization_id);
      const timezone = normalizeTimezone(sequence.timezone ?? organization?.timezone ?? "America/New_York");

      if (!isWithinSendWindow(new Date().toISOString(), timezone)) {
        await deferMessageToWindow(client, message, timezone);
        stats.deferred_count += 1;
        touchedSequenceIds.add(sequence.id);
        continue;
      }

      const template = templatesByKey.get(templateMapKey(sequence.organization_id, message.template_key));
      if (!template) {
        const result = await updateMessageForRetryOrFailure(
          client,
          message,
          timezone,
          `No active template found for key '${message.template_key}'.`,
          { permanent: true },
        );
        if (result === "failed") {
          stats.failed_count += 1;
        } else {
          stats.retried_count += 1;
        }
        touchedSequenceIds.add(sequence.id);
        stats.processed_count += 1;
        continue;
      }

      const profile =
        (lead.created_by_profile_id ? profilesById.get(lead.created_by_profile_id) : null) ??
        ownerByOrganizationId.get(sequence.organization_id);
      const contractorName = profile?.full_name ?? organization?.name ?? "CrewCommand";

      const tokens: TemplateTokens = {
        client_name: lead.client_name,
        job_type: lead.job_type,
        contractor_name: contractorName,
      };

      if (message.channel === "sms") {
        const smsBody = template.sms_body;
        if (!smsBody || smsBody.trim().length === 0) {
          const result = await updateMessageForRetryOrFailure(
            client,
            message,
            timezone,
            `Template '${message.template_key}' does not have sms_body.`,
            { permanent: true },
          );
          if (result === "failed") {
            stats.failed_count += 1;
          } else {
            stats.retried_count += 1;
          }
          touchedSequenceIds.add(sequence.id);
          stats.processed_count += 1;
          continue;
        }

        if (!lead.phone_e164 || lead.phone_e164.trim().length === 0) {
          const result = await updateMessageForRetryOrFailure(
            client,
            message,
            timezone,
            "Lead is missing phone_e164 for SMS delivery.",
            { permanent: true },
          );
          if (result === "failed") {
            stats.failed_count += 1;
          } else {
            stats.retried_count += 1;
          }
          touchedSequenceIds.add(sequence.id);
          stats.processed_count += 1;
          continue;
        }

        const renderedBody = renderTemplate(smsBody, tokens);
        const sendResult = await sendSms({
          to: lead.phone_e164,
          body: renderedBody,
        });

        if (sendResult.success) {
          await updateMessageAsSent(client, message, sendResult.provider_message_id);
          stats.sent_count += 1;
        } else {
          const result = await updateMessageForRetryOrFailure(
            client,
            message,
            timezone,
            sendResult.error ?? "SMS provider request failed.",
          );

          if (result === "failed") {
            stats.failed_count += 1;
          } else {
            stats.retried_count += 1;
          }
        }

        touchedSequenceIds.add(sequence.id);
        stats.processed_count += 1;
        continue;
      }

      const emailSubject = template.email_subject;
      const emailBody = template.email_body;

      if (!emailSubject || emailSubject.trim().length === 0 || !emailBody || emailBody.trim().length === 0) {
        const result = await updateMessageForRetryOrFailure(
          client,
          message,
          timezone,
          `Template '${message.template_key}' does not have email subject/body.`,
          { permanent: true },
        );
        if (result === "failed") {
          stats.failed_count += 1;
        } else {
          stats.retried_count += 1;
        }
        touchedSequenceIds.add(sequence.id);
        stats.processed_count += 1;
        continue;
      }

      if (!lead.email || lead.email.trim().length === 0) {
        const result = await updateMessageForRetryOrFailure(
          client,
          message,
          timezone,
          "Lead is missing email for email delivery.",
          { permanent: true },
        );
        if (result === "failed") {
          stats.failed_count += 1;
        } else {
          stats.retried_count += 1;
        }
        touchedSequenceIds.add(sequence.id);
        stats.processed_count += 1;
        continue;
      }

      const renderedSubject = renderTemplate(emailSubject, tokens);
      const renderedBody = renderTemplate(emailBody, tokens);

      const sendResult = await sendEmail({
        to: lead.email,
        subject: renderedSubject,
        body: renderedBody,
      });

      if (sendResult.success) {
        await updateMessageAsSent(client, message, sendResult.provider_message_id);
        stats.sent_count += 1;
      } else {
        const result = await updateMessageForRetryOrFailure(
          client,
          message,
          timezone,
          sendResult.error ?? "Email provider request failed.",
        );

        if (result === "failed") {
          stats.failed_count += 1;
        } else {
          stats.retried_count += 1;
        }
      }

      touchedSequenceIds.add(sequence.id);
      stats.processed_count += 1;
    }

    const touched = [...touchedSequenceIds];
    const stateBySequenceId = new Map<string, string>();
    for (const sequenceId of touched) {
      const sequence = sequencesById.get(sequenceId);
      if (sequence) {
        stateBySequenceId.set(sequence.id, sequence.state);
      }
    }

    await refreshSequenceNextSendAt(client, touched, stateBySequenceId);

    return jsonResponse({
      ok: true,
      data: stats,
    });
  } catch (error) {
    const mappedError = mapError(error);
    return jsonResponse(mappedError.body, mappedError.status);
  }
});
