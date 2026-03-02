import { HttpError, isHttpError, requireAuthContext, type AuthContext } from "../_shared/auth.ts";
import {
  ValidationError,
  isRecord,
  parseJsonObject,
  readOptionalInteger,
  readOptionalIsoDateTime,
  readOptionalUuid,
  readRequiredArray,
  readRequiredString,
  readRequiredUuid,
} from "../_shared/validation.ts";

type ErrorCode =
  | "method_not_allowed"
  | "invalid_request"
  | "unauthorized"
  | "forbidden"
  | "not_implemented"
  | "internal_error";

interface ApiError {
  ok: false;
  error: {
    code: ErrorCode;
    message: string;
  };
}

interface SyncMutationRequest {
  client_mutation_id: string;
  entity:
    | "lead"
    | "job"
    | "client"
    | "followup_sequence"
    | "call_log"
    | "import"
    | "notification"
    | "device"
    | "message_template";
  entity_id?: string;
  type: "insert" | "update" | "delete" | "status_transition";
  base_version?: number;
  payload: Record<string, unknown>;
}

interface SyncPushRequest {
  device_id: string;
  cursor?: string;
  mutations: SyncMutationRequest[];
}

interface SyncConflict {
  client_mutation_id: string;
  reason: string;
}

interface SyncPushData {
  organization_id: string;
  received_mutations: number;
  applied: string[];
  conflicts: SyncConflict[];
  server_cursor: string;
}

interface ApiSuccess {
  ok: true;
  data: SyncPushData;
}

const ENTITY_TYPES = new Set([
  "lead",
  "job",
  "client",
  "followup_sequence",
  "call_log",
  "import",
  "notification",
  "device",
  "message_template",
] as const);

const MUTATION_TYPES = new Set(["insert", "update", "delete", "status_transition"] as const);
const LEAD_TERMINAL_STATUSES = new Set(["won", "cold"]);
const LEAD_EARLY_STATUSES = new Set(["new_callback", "estimate_sent"]);
const FOLLOWUP_SEQUENCE_STATES = new Set(["active", "paused", "stopped", "completed"]);
const JOB_PHASES = ["demo", "rough", "electrical_plumbing", "finishing", "walkthrough", "complete"] as const;
const JOB_PHASE_SET = new Set(JOB_PHASES);
const JOB_HEALTH_SET = new Set(["green", "yellow", "red"] as const);
const FOLLOWUP_STATE_PRIORITY: Record<string, number> = {
  none: 0,
  active: 1,
  paused: 2,
  stopped: 3,
  completed: 4,
};

interface EntityConfig {
  tableName: string;
  isVersioned: boolean;
  supportsSoftDelete: boolean;
}

const ENTITY_CONFIG: Record<SyncMutationRequest["entity"], EntityConfig> = {
  lead: {
    tableName: "leads",
    isVersioned: true,
    supportsSoftDelete: true,
  },
  job: {
    tableName: "jobs",
    isVersioned: true,
    supportsSoftDelete: true,
  },
  client: {
    tableName: "clients",
    isVersioned: true,
    supportsSoftDelete: true,
  },
  followup_sequence: {
    tableName: "followup_sequences",
    isVersioned: false,
    supportsSoftDelete: false,
  },
  call_log: {
    tableName: "call_logs",
    isVersioned: false,
    supportsSoftDelete: false,
  },
  import: {
    tableName: "imports",
    isVersioned: false,
    supportsSoftDelete: false,
  },
  notification: {
    tableName: "notifications",
    isVersioned: false,
    supportsSoftDelete: false,
  },
  device: {
    tableName: "devices",
    isVersioned: false,
    supportsSoftDelete: false,
  },
  message_template: {
    tableName: "message_templates",
    isVersioned: false,
    supportsSoftDelete: false,
  },
};

function isUniqueViolation(error: unknown): boolean {
  return isRecord(error) && error.code === "23505";
}

function toSafeInteger(value: unknown): number | null {
  if (typeof value === "number" && Number.isInteger(value)) {
    return value;
  }

  if (typeof value === "string") {
    const parsed = Number.parseInt(value, 10);
    if (Number.isInteger(parsed)) {
      return parsed;
    }
  }

  return null;
}

function isTerminalStatusRevert(currentStatus: string, nextStatus: string): boolean {
  return LEAD_TERMINAL_STATUSES.has(currentStatus) && LEAD_EARLY_STATUSES.has(nextStatus) && currentStatus !== nextStatus;
}

function isFollowupStateDowngrade(currentState: string, nextState: string): boolean {
  const currentPriority = FOLLOWUP_STATE_PRIORITY[currentState];
  const nextPriority = FOLLOWUP_STATE_PRIORITY[nextState];
  if (currentPriority == null || nextPriority == null) {
    return false;
  }
  return nextPriority < currentPriority;
}

function isValidJobPhaseTransition(currentPhase: string, nextPhase: string): boolean {
  const currentIndex = JOB_PHASES.indexOf(currentPhase as (typeof JOB_PHASES)[number]);
  const nextIndex = JOB_PHASES.indexOf(nextPhase as (typeof JOB_PHASES)[number]);
  if (currentIndex < 0 || nextIndex < 0) {
    return false;
  }
  return Math.abs(nextIndex - currentIndex) <= 1;
}

function validateJobPayload(payload: Record<string, unknown>): string | null {
  if (payload.phase != null) {
    if (typeof payload.phase !== "string" || !JOB_PHASE_SET.has(payload.phase as (typeof JOB_PHASES)[number])) {
      return "Job phase must be one of demo, rough, electrical_plumbing, finishing, walkthrough, complete.";
    }
  }

  if (payload.health_status != null) {
    if (typeof payload.health_status !== "string" || !JOB_HEALTH_SET.has(payload.health_status as "green" | "yellow" | "red")) {
      return "Job health_status must be one of green, yellow, red.";
    }
  }

  return null;
}

function sanitizeUpdatePayload(payload: Record<string, unknown>): Record<string, unknown> {
  const nextPayload = { ...payload };
  delete nextPayload.id;
  delete nextPayload.organization_id;
  delete nextPayload.version;
  delete nextPayload.created_at;
  delete nextPayload.updated_at;
  return nextPayload;
}

async function recordSyncMutation(
  auth: AuthContext,
  mutation: SyncMutationRequest,
  entityId: string | null,
  hadConflict: boolean,
  resolution?: string,
): Promise<"recorded" | "duplicate"> {
  const { error } = await auth.client.from("sync_mutations").insert({
    organization_id: auth.organizationId,
    entity_id: entityId,
    entity_type: mutation.entity,
    mutation_type: mutation.type,
    client_mutation_id: mutation.client_mutation_id,
    base_version: mutation.base_version ?? null,
    payload: mutation.payload,
    had_conflict: hadConflict,
    resolution: resolution ?? null,
    processed_at: new Date().toISOString(),
  });

  if (!error) {
    return "recorded";
  }

  if (isUniqueViolation(error)) {
    return "duplicate";
  }

  throw new HttpError(500, "internal_error", "Failed to persist sync mutation audit log.");
}

async function resolveCurrentRow(
  auth: AuthContext,
  mutation: SyncMutationRequest,
  config: EntityConfig,
  entityId: string,
): Promise<Record<string, unknown> | null> {
  const selectColumns = ["id"];
  if (config.isVersioned) {
    selectColumns.push("version");
  }

  if (mutation.entity === "lead") {
    selectColumns.push("status", "followup_state");
  }

  if (mutation.entity === "job") {
    selectColumns.push("phase", "health_status");
  }

  const { data, error } = await auth.client
    .from(config.tableName)
    .select(selectColumns.join(", "))
    .eq("id", entityId)
    .eq("organization_id", auth.organizationId)
    .maybeSingle();

  if (error) {
    throw new HttpError(500, "internal_error", `Failed to resolve ${mutation.entity} before applying mutation.`);
  }

  if (data == null) {
    return null;
  }

  return data as Record<string, unknown>;
}

async function resolveNextQueuedFollowupSendAt(
  auth: AuthContext,
  sequenceId: string,
): Promise<string | null> {
  const { data, error } = await auth.client
    .from("followup_messages")
    .select("scheduled_at")
    .eq("sequence_id", sequenceId)
    .eq("status", "queued")
    .order("scheduled_at", { ascending: true })
    .limit(1)
    .maybeSingle();

  if (error) {
    throw new HttpError(500, "internal_error", "Failed to resolve next queued follow-up message.");
  }

  return data && typeof data.scheduled_at === "string" ? data.scheduled_at : null;
}

async function updateFollowupSequenceNextSendAt(
  auth: AuthContext,
  sequenceId: string,
  nextSendAt: string | null,
): Promise<void> {
  const { error } = await auth.client
    .from("followup_sequences")
    .update({ next_send_at: nextSendAt })
    .eq("id", sequenceId)
    .eq("organization_id", auth.organizationId);

  if (error) {
    throw new HttpError(500, "internal_error", "Failed to update follow-up sequence next_send_at.");
  }
}

async function cancelQueuedFollowupMessages(
  auth: AuthContext,
  sequenceId: string,
  reason: string,
): Promise<void> {
  const { error } = await auth.client
    .from("followup_messages")
    .update({
      status: "canceled",
      error_message: reason,
    })
    .eq("sequence_id", sequenceId)
    .eq("status", "queued");

  if (error) {
    throw new HttpError(500, "internal_error", "Failed to cancel queued follow-up messages.");
  }
}

function jsonResponse(payload: ApiSuccess | ApiError, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "content-type": "application/json; charset=utf-8",
    },
  });
}

function parseMutation(input: unknown, index: number): SyncMutationRequest {
  if (!isRecord(input)) {
    throw new ValidationError(`mutations[${index}]`, "Each mutation entry must be an object.");
  }

  const clientMutationId = readRequiredUuid(input, "client_mutation_id");
  const entity = readRequiredString(input, "entity", 64);
  const mutationType = readRequiredString(input, "type", 64);
  const entityId = readOptionalUuid(input, "entity_id");
  const baseVersion = readOptionalInteger(input, "base_version", { min: 1 });

  if (!ENTITY_TYPES.has(entity as SyncMutationRequest["entity"])) {
    throw new ValidationError(`mutations[${index}].entity`, "Unsupported entity type.");
  }

  if (!MUTATION_TYPES.has(mutationType as SyncMutationRequest["type"])) {
    throw new ValidationError(`mutations[${index}].type`, "Unsupported mutation type.");
  }

  const payload = input.payload;
  if (!isRecord(payload)) {
    throw new ValidationError(`mutations[${index}].payload`, "Mutation payload must be a JSON object.");
  }

  return {
    client_mutation_id: clientMutationId,
    entity: entity as SyncMutationRequest["entity"],
    entity_id: entityId,
    type: mutationType as SyncMutationRequest["type"],
    base_version: baseVersion,
    payload,
  };
}

function parseRequest(input: Record<string, unknown>): SyncPushRequest {
  const deviceId = readRequiredUuid(input, "device_id");
  const cursor = readOptionalIsoDateTime(input, "cursor");
  const mutationsInput = readRequiredArray(input, "mutations");

  const mutations = mutationsInput.map((mutation, index) => parseMutation(mutation, index));

  return {
    device_id: deviceId,
    cursor,
    mutations,
  };
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
    const payload = parseRequest(body);

    const { data: device, error: deviceLookupError } = await auth.client
      .from("devices")
      .select("id")
      .eq("id", payload.device_id)
      .eq("organization_id", auth.organizationId)
      .maybeSingle();

    if (deviceLookupError) {
      throw new HttpError(500, "internal_error", "Failed to verify device ownership for this organization.");
    }

    if (!device) {
      throw new HttpError(403, "forbidden", "Device is not registered to the authenticated organization.");
    }

    const appliedIds: string[] = [];
    const conflictList: SyncConflict[] = [];

    for (const mutation of payload.mutations) {
      const config = ENTITY_CONFIG[mutation.entity];
      const entityId =
        mutation.entity_id ??
        (typeof mutation.payload.id === "string" ? mutation.payload.id : null);

      const { data: existingMutation, error: existingMutationError } = await auth.client
        .from("sync_mutations")
        .select("id")
        .eq("organization_id", auth.organizationId)
        .eq("client_mutation_id", mutation.client_mutation_id)
        .maybeSingle();

      if (existingMutationError) {
        throw new HttpError(500, "internal_error", "Failed to verify sync mutation idempotency.");
      }

      if (existingMutation) {
        appliedIds.push(mutation.client_mutation_id);
        continue;
      }

      if (mutation.type === "insert") {
        if (mutation.entity === "job") {
          const validationError = validateJobPayload(mutation.payload);
          if (validationError != null) {
            await recordSyncMutation(auth, mutation, entityId, true, validationError);
            conflictList.push({
              client_mutation_id: mutation.client_mutation_id,
              reason: validationError,
            });
            continue;
          }
        }

        const insertPayload: Record<string, unknown> = {
          ...mutation.payload,
          organization_id: auth.organizationId,
        };

        if (mutation.entity === "lead" && insertPayload.created_by_profile_id == null) {
          insertPayload.created_by_profile_id = auth.profileId;
        }

        const { data: insertedRow, error: insertError } = await auth.client
          .from(config.tableName)
          .insert(insertPayload)
          .select("id")
          .maybeSingle();

        if (insertError) {
          throw new HttpError(500, "internal_error", `Failed to insert ${mutation.entity} mutation.`);
        }

        const persistedEntityId =
          entityId ??
          (isRecord(insertedRow) && typeof insertedRow.id === "string" ? insertedRow.id : null);

        const recordStatus = await recordSyncMutation(auth, mutation, persistedEntityId, false, "applied");
        if (recordStatus === "duplicate") {
          appliedIds.push(mutation.client_mutation_id);
          continue;
        }

        appliedIds.push(mutation.client_mutation_id);
        continue;
      }

      if (!entityId) {
        const reason = "entity_id is required for update/delete/status_transition mutations.";
        await recordSyncMutation(auth, mutation, null, true, reason);
        conflictList.push({
          client_mutation_id: mutation.client_mutation_id,
          reason,
        });
        continue;
      }

      const currentRow = await resolveCurrentRow(auth, mutation, config, entityId);
      if (!currentRow) {
        const reason = `The target ${mutation.entity} was not found for this organization.`;
        await recordSyncMutation(auth, mutation, entityId, true, reason);
        conflictList.push({
          client_mutation_id: mutation.client_mutation_id,
          reason,
        });
        continue;
      }

      let currentVersion: number | null = null;
      if (config.isVersioned) {
        currentVersion = toSafeInteger(currentRow.version);
        if (currentVersion == null) {
          throw new HttpError(500, "internal_error", `Stored ${mutation.entity} version is invalid.`);
        }
      }

      if (
        config.isVersioned &&
        mutation.base_version != null &&
        currentVersion != null &&
        currentVersion > mutation.base_version
      ) {
        const reason = `Version conflict: server=${currentVersion}, client_base=${mutation.base_version}.`;
        await recordSyncMutation(auth, mutation, entityId, true, reason);
        conflictList.push({
          client_mutation_id: mutation.client_mutation_id,
          reason,
        });
        continue;
      }

      if (mutation.entity === "job") {
        const validationError = validateJobPayload(mutation.payload);
        if (validationError != null) {
          await recordSyncMutation(auth, mutation, entityId, true, validationError);
          conflictList.push({
            client_mutation_id: mutation.client_mutation_id,
            reason: validationError,
          });
          continue;
        }

        if (typeof mutation.payload.phase === "string") {
          const currentPhase = typeof currentRow.phase === "string" ? currentRow.phase : "";
          if (!isValidJobPhaseTransition(currentPhase, mutation.payload.phase)) {
            const reason = `Job phase transition is invalid: '${currentPhase}' -> '${mutation.payload.phase}'.`;
            await recordSyncMutation(auth, mutation, entityId, true, reason);
            conflictList.push({
              client_mutation_id: mutation.client_mutation_id,
              reason,
            });
            continue;
          }
        }
      }

      const nextStatusRaw = mutation.payload.status;
      if (mutation.entity === "lead" && typeof nextStatusRaw === "string") {
        const currentStatus = typeof currentRow.status === "string" ? currentRow.status : "";
        if (isTerminalStatusRevert(currentStatus, nextStatusRaw)) {
          const reason = `Lead status conflict: cannot revert terminal status '${currentStatus}' to '${nextStatusRaw}'.`;
          await recordSyncMutation(auth, mutation, entityId, true, reason);
          conflictList.push({
            client_mutation_id: mutation.client_mutation_id,
            reason,
          });
          continue;
        }
      }

      const nextFollowupStateRaw = mutation.payload.followup_state;
      if (mutation.entity === "lead" && typeof nextFollowupStateRaw === "string") {
        const currentFollowupState = typeof currentRow.followup_state === "string" ? currentRow.followup_state : "";
        if (isFollowupStateDowngrade(currentFollowupState, nextFollowupStateRaw)) {
          const reason =
            `Lead follow-up conflict: cannot downgrade followup_state from '${currentFollowupState}' to ` +
            `'${nextFollowupStateRaw}'.`;
          await recordSyncMutation(auth, mutation, entityId, true, reason);
          conflictList.push({
            client_mutation_id: mutation.client_mutation_id,
            reason,
          });
          continue;
        }
      }

      if (mutation.type === "delete") {
        if (!config.supportsSoftDelete) {
          const reason = `Delete conflict: ${mutation.entity} does not support soft delete.`;
          await recordSyncMutation(auth, mutation, entityId, true, reason);
          conflictList.push({
            client_mutation_id: mutation.client_mutation_id,
            reason,
          });
          continue;
        }

        const deletePatch: Record<string, unknown> = {
          deleted_at: new Date().toISOString(),
        };
        if (config.isVersioned && currentVersion != null) {
          deletePatch.version = currentVersion + 1;
        }

        const { error: deleteError } = await auth.client
          .from(config.tableName)
          .update(deletePatch)
          .eq("id", entityId)
          .eq("organization_id", auth.organizationId);

        if (deleteError) {
          throw new HttpError(500, "internal_error", `Failed to soft-delete ${mutation.entity}.`);
        }

        await recordSyncMutation(auth, mutation, entityId, false, "applied");
        appliedIds.push(mutation.client_mutation_id);
        continue;
      }

      const updatePatch = sanitizeUpdatePayload(mutation.payload);
      if (mutation.type === "status_transition") {
        if (typeof mutation.payload.status !== "string") {
          const reason = "status_transition mutation requires a string payload.status.";
          await recordSyncMutation(auth, mutation, entityId, true, reason);
          conflictList.push({
            client_mutation_id: mutation.client_mutation_id,
            reason,
          });
          continue;
        }
      }

      if (mutation.type === "status_transition") {
        Object.keys(updatePatch).forEach((key) => {
          if (key !== "status") {
            delete updatePatch[key];
          }
        });
      }

      let followupSequenceState: string | null = null;
      if (mutation.entity === "followup_sequence" && typeof updatePatch.state === "string") {
        if (!FOLLOWUP_SEQUENCE_STATES.has(updatePatch.state)) {
          const reason = `Unsupported follow-up sequence state '${updatePatch.state}'.`;
          await recordSyncMutation(auth, mutation, entityId, true, reason);
          conflictList.push({
            client_mutation_id: mutation.client_mutation_id,
            reason,
          });
          continue;
        }

        followupSequenceState = updatePatch.state;
        const nowIso = new Date().toISOString();

        if (followupSequenceState === "active") {
          updatePatch.paused_at = null;
          updatePatch.stopped_at = null;
          updatePatch.completed_at = null;
        } else if (followupSequenceState === "paused") {
          updatePatch.paused_at = nowIso;
          updatePatch.stopped_at = null;
          updatePatch.completed_at = null;
          updatePatch.next_send_at = null;
        } else if (followupSequenceState === "stopped") {
          updatePatch.stopped_at = nowIso;
          updatePatch.completed_at = null;
          updatePatch.next_send_at = null;
        } else if (followupSequenceState === "completed") {
          updatePatch.completed_at = nowIso;
          updatePatch.next_send_at = null;
        }
      }

      if (config.isVersioned && currentVersion != null) {
        updatePatch.version = currentVersion + 1;
      }

      if (Object.keys(updatePatch).length > 0) {
        const { error: updateError } = await auth.client
          .from(config.tableName)
          .update(updatePatch)
          .eq("id", entityId)
          .eq("organization_id", auth.organizationId);

        if (updateError) {
          throw new HttpError(500, "internal_error", `Failed to update ${mutation.entity}.`);
        }
      }

      if (mutation.entity === "followup_sequence" && followupSequenceState != null) {
        if (followupSequenceState === "stopped" || followupSequenceState === "completed") {
          await cancelQueuedFollowupMessages(
            auth,
            entityId,
            `Sequence ${followupSequenceState} by user action.`,
          );
        }

        if (followupSequenceState === "active") {
          const nextSendAt = await resolveNextQueuedFollowupSendAt(auth, entityId);
          await updateFollowupSequenceNextSendAt(auth, entityId, nextSendAt);
        } else {
          await updateFollowupSequenceNextSendAt(auth, entityId, null);
        }
      }

      const recordStatus = await recordSyncMutation(auth, mutation, entityId, false, "applied");
      if (recordStatus === "duplicate") {
        appliedIds.push(mutation.client_mutation_id);
        continue;
      }

      appliedIds.push(mutation.client_mutation_id);
    }

    return jsonResponse({
      ok: true,
      data: {
        organization_id: auth.organizationId,
        received_mutations: payload.mutations.length,
        applied: appliedIds,
        conflicts: conflictList,
        server_cursor: new Date().toISOString(),
      },
    });
  } catch (error) {
    const mappedError = mapError(error);
    return jsonResponse(mappedError.body, mappedError.status);
  }
});
