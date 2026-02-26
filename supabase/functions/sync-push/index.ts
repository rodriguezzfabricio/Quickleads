import { HttpError, isHttpError, requireAuthContext } from "../_shared/auth.ts";
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
  entity: "lead" | "job" | "followup_sequence" | "call_log" | "import" | "notification" | "device";
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
  "followup_sequence",
  "call_log",
  "import",
  "notification",
  "device",
] as const);

const MUTATION_TYPES = new Set(["insert", "update", "delete", "status_transition"] as const);

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

    // TODO(PHASE-2-sync-write): Apply validated mutations and persist idempotency records in sync_mutations.
    // TODO(PHASE-2-conflict-policy): Enforce server-authoritative conflict resolution for terminal lead states.

    return jsonResponse({
      ok: true,
      data: {
        organization_id: auth.organizationId,
        received_mutations: payload.mutations.length,
        applied: [],
        conflicts: [],
        server_cursor: new Date().toISOString(),
      },
    });
  } catch (error) {
    const mappedError = mapError(error);
    return jsonResponse(mappedError.body, mappedError.status);
  }
});
