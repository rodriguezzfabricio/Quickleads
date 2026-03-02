import { HttpError, isHttpError, requireAuthContext } from "../_shared/auth.ts";
import {
  ValidationError,
  parseJsonObject,
  readOptionalIsoDateTime,
  readOptionalString,
  readRequiredUuid,
} from "../_shared/validation.ts";
import {
  buildFollowupSchedule,
  localDateIso,
  normalizeTimezone,
} from "../_shared/followup_schedule.ts";

type ErrorCode =
  | "method_not_allowed"
  | "invalid_request"
  | "unauthorized"
  | "forbidden"
  | "not_found"
  | "conflict"
  | "internal_error";

interface ApiError {
  ok: false;
  error: {
    code: ErrorCode;
    message: string;
  };
}

interface EstimateSentData {
  lead_id: string;
  organization_id: string;
  estimate_sent_at: string;
  accepted: boolean;
}

interface ApiSuccess {
  ok: true;
  data: EstimateSentData;
}

interface EstimateSentRequest {
  lead_id: string;
  estimate_sent_at?: string;
  trigger_source?: "manual" | "sent_from_another_tool";
}

interface LeadRow {
  id: string;
  organization_id: string;
  status: string;
  version: number;
}

const TRIGGER_SOURCES = new Set(["manual", "sent_from_another_tool"] as const);
const TERMINAL_LEAD_STATUSES = new Set(["won", "cold"]);
const MAX_VERSION_RETRIES = 3;

function jsonResponse(payload: ApiSuccess | ApiError, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "content-type": "application/json; charset=utf-8",
    },
  });
}

function parseEstimateSentRequest(input: Record<string, unknown>): EstimateSentRequest {
  const leadId = readRequiredUuid(input, "lead_id");
  const estimateSentAt = readOptionalIsoDateTime(input, "estimate_sent_at");
  const triggerSource = readOptionalString(input, "trigger_source", 64);

  if (triggerSource && !TRIGGER_SOURCES.has(triggerSource as EstimateSentRequest["trigger_source"])) {
    throw new ValidationError("trigger_source", "trigger_source must be either 'manual' or 'sent_from_another_tool'.");
  }

  return {
    lead_id: leadId,
    estimate_sent_at: estimateSentAt,
    trigger_source: triggerSource as EstimateSentRequest["trigger_source"] | undefined,
  };
}

function toInteger(value: unknown): number {
  if (typeof value === "number" && Number.isInteger(value)) {
    return value;
  }

  if (typeof value === "string") {
    const parsed = Number.parseInt(value, 10);
    if (Number.isInteger(parsed)) {
      return parsed;
    }
  }

  throw new HttpError(500, "internal_error", "Lead version is invalid.");
}

async function resolveLead(
  auth: Awaited<ReturnType<typeof requireAuthContext>>,
  leadId: string,
): Promise<LeadRow> {
  const { data, error } = await auth.client
    .from("leads")
    .select("id, organization_id, status, version")
    .eq("id", leadId)
    .eq("organization_id", auth.organizationId)
    .is("deleted_at", null)
    .maybeSingle();

  if (error) {
    throw new HttpError(500, "internal_error", "Failed to resolve lead for estimate_sent update.");
  }

  if (!data || typeof data.id !== "string") {
    throw new HttpError(404, "not_found", "Lead was not found in the authenticated organization.");
  }

  const status = typeof data.status === "string" ? data.status : "";
  if (TERMINAL_LEAD_STATUSES.has(status)) {
    throw new HttpError(409, "conflict", `Cannot mark estimate sent for a terminal lead status ('${status}').`);
  }

  return {
    id: data.id,
    organization_id: auth.organizationId,
    status,
    version: toInteger(data.version),
  };
}

async function markLeadEstimateSent(
  auth: Awaited<ReturnType<typeof requireAuthContext>>,
  leadId: string,
  estimateSentAtIso: string,
): Promise<void> {
  for (let attempt = 0; attempt < MAX_VERSION_RETRIES; attempt += 1) {
    const current = await resolveLead(auth, leadId);
    const nextVersion = current.version + 1;

    const { data: updated, error: updateError } = await auth.client
      .from("leads")
      .update({
        status: "estimate_sent",
        followup_state: "active",
        estimate_sent_at: estimateSentAtIso,
        version: nextVersion,
      })
      .eq("id", current.id)
      .eq("organization_id", current.organization_id)
      .eq("version", current.version)
      .select("id")
      .maybeSingle();

    if (updateError) {
      throw new HttpError(500, "internal_error", "Failed to persist lead estimate_sent update.");
    }

    if (updated?.id) {
      return;
    }
  }

  throw new HttpError(409, "conflict", "Lead was modified by another update. Retry the request.");
}

async function resolveTimezone(
  auth: Awaited<ReturnType<typeof requireAuthContext>>,
): Promise<string> {
  const { data, error } = await auth.client
    .from("organizations")
    .select("timezone")
    .eq("id", auth.organizationId)
    .maybeSingle();

  if (error) {
    throw new HttpError(500, "internal_error", "Failed to resolve organization timezone.");
  }

  if (!data || typeof data.timezone !== "string") {
    return "America/New_York";
  }

  return normalizeTimezone(data.timezone);
}

async function ensureFollowupSequence(
  auth: Awaited<ReturnType<typeof requireAuthContext>>,
  leadId: string,
  estimateSentAtIso: string,
  timezone: string,
): Promise<string> {
  const schedule = buildFollowupSchedule(estimateSentAtIso, timezone);
  const earliestScheduledAt = schedule
    .map((entry) => entry.scheduledAt)
    .sort()[0] ?? null;

  const { data: sequence, error: sequenceError } = await auth.client
    .from("followup_sequences")
    .upsert(
      {
        organization_id: auth.organizationId,
        lead_id: leadId,
        state: "active",
        start_date_local: localDateIso(estimateSentAtIso, timezone),
        timezone,
        next_send_at: earliestScheduledAt,
        paused_at: null,
        stopped_at: null,
        completed_at: null,
      },
      { onConflict: "lead_id" },
    )
    .select("id")
    .maybeSingle();

  if (sequenceError) {
    throw new HttpError(500, "internal_error", "Failed to create follow-up sequence.");
  }

  if (!sequence || typeof sequence.id !== "string") {
    throw new HttpError(500, "internal_error", "Follow-up sequence upsert did not return an id.");
  }

  const messageRows = schedule.map((entry) => ({
    sequence_id: sequence.id,
    step_number: entry.stepNumber,
    channel: entry.channel,
    template_key: entry.templateKey,
    scheduled_at: entry.scheduledAt,
    status: "queued",
    sent_at: null,
    retry_count: 0,
    provider_message_id: null,
    error_message: null,
  }));

  const { error: messageError } = await auth.client
    .from("followup_messages")
    .upsert(messageRows, { onConflict: "sequence_id,step_number,channel" });

  if (messageError) {
    throw new HttpError(500, "internal_error", "Failed to enqueue follow-up messages.");
  }

  return sequence.id;
}

async function refreshSequenceNextSendAt(
  auth: Awaited<ReturnType<typeof requireAuthContext>>,
  sequenceId: string,
): Promise<void> {
  const { data: nextMessage, error: nextMessageError } = await auth.client
    .from("followup_messages")
    .select("scheduled_at")
    .eq("sequence_id", sequenceId)
    .eq("status", "queued")
    .order("scheduled_at", { ascending: true })
    .limit(1)
    .maybeSingle();

  if (nextMessageError) {
    throw new HttpError(500, "internal_error", "Failed to resolve sequence next_send_at.");
  }

  const nextSendAt =
    nextMessage && typeof nextMessage.scheduled_at === "string"
      ? nextMessage.scheduled_at
      : null;

  const { error: updateError } = await auth.client
    .from("followup_sequences")
    .update({ next_send_at: nextSendAt })
    .eq("id", sequenceId)
    .eq("organization_id", auth.organizationId);

  if (updateError) {
    throw new HttpError(500, "internal_error", "Failed to update sequence next_send_at.");
  }
}

function mapError(error: unknown): { status: number; body: ApiError } {
  if (error instanceof ValidationError) {
    return {
      status: 400,
      body: {
        ok: false,
        error: {
          code: "invalid_request",
          message: `${error.field}: ${error.message}`,
        },
      },
    };
  }

  if (isHttpError(error)) {
    const code: ErrorCode =
      error.status === 401
        ? "unauthorized"
        : error.status === 403
          ? "forbidden"
          : error.status === 404
            ? "not_found"
            : error.status === 409
              ? "conflict"
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
    const auth = await requireAuthContext(request);
    const body = await parseJsonObject(request);
    const payload = parseEstimateSentRequest(body);

    const estimateSentAtIso = payload.estimate_sent_at ?? new Date().toISOString();

    await markLeadEstimateSent(auth, payload.lead_id, estimateSentAtIso);

    const timezone = await resolveTimezone(auth);
    const sequenceId = await ensureFollowupSequence(
      auth,
      payload.lead_id,
      estimateSentAtIso,
      timezone,
    );

    await refreshSequenceNextSendAt(auth, sequenceId);

    return jsonResponse({
      ok: true,
      data: {
        lead_id: payload.lead_id,
        organization_id: auth.organizationId,
        estimate_sent_at: estimateSentAtIso,
        accepted: true,
      },
    });
  } catch (error) {
    const mappedError = mapError(error);
    return jsonResponse(mappedError.body, mappedError.status);
  }
});
