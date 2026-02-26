import { HttpError, isHttpError, requireAuthContext } from "../_shared/auth.ts";
import { ValidationError, isUuid } from "../_shared/validation.ts";

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

    // TODO(PHASE-2-sync-read): Query tenant-scoped table deltas since cursor with deterministic ordering.
    // TODO(PHASE-2-sync-pagination): Return paginated change batches and stable next cursor semantics.

    return jsonResponse({
      ok: true,
      data: {
        organization_id: auth.organizationId,
        requested_cursor: payload.cursor ?? null,
        next_cursor: new Date().toISOString(),
        limit: payload.limit,
        changes: [],
        has_more: false,
      },
    });
  } catch (error) {
    const mappedError = mapError(error);
    return jsonResponse(mappedError.body, mappedError.status);
  }
});
