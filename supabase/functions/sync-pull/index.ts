import { HttpError, isHttpError, requireAuthContext } from "../_shared/auth.ts";
import { ValidationError, isUuid } from "../_shared/validation.ts";

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

interface SyncPullRequest {
  cursor?: string;
  limit: number;
  device_id?: string;
}

interface SyncPullData {
  organization_id: string;
  requested_cursor: string | null;
  next_cursor: string;
  limit: number;
  changes: Array<Record<string, unknown>>;
  has_more: boolean;
}

interface ApiSuccess {
  ok: true;
  data: SyncPullData;
}

interface PullEntitySpec {
  entityType:
    | "lead"
    | "job"
    | "followup_sequence"
    | "followup_message"
    | "call_log"
    | "message_template"
    | "organization"
    | "profile";
  tableName:
    | "leads"
    | "jobs"
    | "followup_sequences"
    | "followup_messages"
    | "call_logs"
    | "message_templates"
    | "organizations"
    | "profiles";
  cursorColumn: "updated_at" | "created_at";
}

interface IndexedChange {
  entity_type: PullEntitySpec["entityType"];
  entity_id: string;
  data: Record<string, unknown>;
  _cursor_iso: string;
  _cursor_ms: number;
}

const PULL_ENTITY_SPECS: PullEntitySpec[] = [
  { entityType: "lead", tableName: "leads", cursorColumn: "updated_at" },
  { entityType: "job", tableName: "jobs", cursorColumn: "updated_at" },
  { entityType: "followup_sequence", tableName: "followup_sequences", cursorColumn: "updated_at" },
  { entityType: "followup_message", tableName: "followup_messages", cursorColumn: "updated_at" },
  { entityType: "call_log", tableName: "call_logs", cursorColumn: "created_at" },
  { entityType: "message_template", tableName: "message_templates", cursorColumn: "updated_at" },
  { entityType: "organization", tableName: "organizations", cursorColumn: "updated_at" },
  { entityType: "profile", tableName: "profiles", cursorColumn: "updated_at" },
];

function jsonResponse(payload: ApiSuccess | ApiError, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "content-type": "application/json; charset=utf-8",
    },
  });
}

function parseRequest(url: URL): SyncPullRequest {
  const cursor = url.searchParams.get("cursor")?.trim() ?? undefined;
  const limitRaw = url.searchParams.get("limit")?.trim();
  const deviceId = url.searchParams.get("device_id")?.trim() ?? undefined;

  if (cursor) {
    const timestamp = Date.parse(cursor);
    if (Number.isNaN(timestamp)) {
      throw new ValidationError("cursor", "cursor must be a valid ISO-8601 datetime.");
    }
  }

  let limit = 200;
  if (limitRaw) {
    const parsed = Number.parseInt(limitRaw, 10);
    if (!Number.isInteger(parsed) || parsed < 1 || parsed > 500) {
      throw new ValidationError("limit", "limit must be an integer between 1 and 500.");
    }
    limit = parsed;
  }

  if (deviceId && !isUuid(deviceId)) {
    throw new ValidationError("device_id", "device_id must be a valid UUID when provided.");
  }

  return {
    cursor,
    limit,
    device_id: deviceId,
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

async function queryEntityChanges(
  auth: Awaited<ReturnType<typeof requireAuthContext>>,
  payload: SyncPullRequest,
  spec: PullEntitySpec,
): Promise<IndexedChange[]> {
  let query = auth.client
    .from(spec.tableName)
    .select("*")
    .order(spec.cursorColumn, { ascending: true })
    .order("id", { ascending: true })
    .limit(payload.limit);

  if (payload.cursor) {
    query = query.gt(spec.cursorColumn, payload.cursor);
  }

  const { data, error } = await query;
  if (error) {
    throw new HttpError(500, "internal_error", `Failed to query ${spec.tableName} changes.`);
  }

  const rows = Array.isArray(data) ? data : [];
  const indexedRows: IndexedChange[] = [];
  for (const row of rows) {
    if (typeof row?.id !== "string") {
      continue;
    }

    const cursorRaw = row[spec.cursorColumn];
    if (typeof cursorRaw !== "string") {
      continue;
    }

    const cursorMs = Date.parse(cursorRaw);
    if (Number.isNaN(cursorMs)) {
      continue;
    }

    indexedRows.push({
      entity_type: spec.entityType,
      entity_id: row.id,
      data: row as Record<string, unknown>,
      _cursor_iso: new Date(cursorMs).toISOString(),
      _cursor_ms: cursorMs,
    });
  }

  return indexedRows;
}

Deno.serve(async (request: Request) => {
  if (request.method !== "GET") {
    return jsonResponse(
      {
        ok: false,
        error: {
          code: "method_not_allowed",
          message: "Only GET is supported for this endpoint.",
        },
      },
      405,
    );
  }

  try {
    const auth = await requireAuthContext(request);
    const payload = parseRequest(new URL(request.url));

    if (payload.device_id) {
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
    }

    const changesByEntity = await Promise.all(
      PULL_ENTITY_SPECS.map((spec) => queryEntityChanges(auth, payload, spec)),
    );

    const merged = changesByEntity
      .flat()
      .sort((a, b) => {
        if (a._cursor_ms !== b._cursor_ms) {
          return a._cursor_ms - b._cursor_ms;
        }

        const idCompare = a.entity_id.localeCompare(b.entity_id);
        if (idCompare !== 0) {
          return idCompare;
        }

        return a.entity_type.localeCompare(b.entity_type);
      });

    const page = merged.slice(0, payload.limit);
    const nextCursor =
      page.length > 0 ? page[page.length - 1]._cursor_iso : (payload.cursor ?? new Date().toISOString());

    return jsonResponse({
      ok: true,
      data: {
        organization_id: auth.organizationId,
        requested_cursor: payload.cursor ?? null,
        next_cursor: nextCursor,
        limit: payload.limit,
        changes: page.map((change) => ({
          entity_type: change.entity_type,
          entity_id: change.entity_id,
          data: change.data,
        })),
        has_more: page.length === payload.limit,
      },
    });
  } catch (error) {
    const mappedError = mapError(error);
    return jsonResponse(mappedError.body, mappedError.status);
  }
});
