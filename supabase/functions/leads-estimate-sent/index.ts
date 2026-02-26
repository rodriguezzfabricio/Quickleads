import { HttpError, isHttpError, requireAuthContext } from "../_shared/auth.ts";
import {
  ValidationError,
  parseJsonObject,
  readOptionalIsoDateTime,
  readOptionalString,
  readRequiredUuid,
} from "../_shared/validation.ts";

type ErrorCode =
  | "method_not_allowed"
  | "invalid_request"
  | "unauthorized"
  | "forbidden"
  | "not_found"
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

const TRIGGER_SOURCES = new Set(["manual", "sent_from_another_tool"] as const);

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

    const { data: lead, error: leadLookupError } = await auth.client
      .from("leads")
      .select("id")
      .eq("id", payload.lead_id)
      .eq("organization_id", auth.organizationId)
      .is("deleted_at", null)
      .maybeSingle();

    if (leadLookupError) {
      throw new HttpError(500, "internal_error", "Failed to verify lead ownership for this organization.");
    }

    if (!lead) {
      throw new HttpError(404, "not_found", "Lead was not found in the authenticated organization.");
    }

    const estimateSentAt = payload.estimate_sent_at ?? new Date().toISOString();

    // TODO(PHASE-1-domain-transition): Persist lead status and estimate timestamp with version-safe writes.
    // TODO(PHASE-3-followup-scheduler): Create follow-up sequence and queued day 2/5/10 follow-up messages.

    return jsonResponse({
      ok: true,
      data: {
        lead_id: payload.lead_id,
        organization_id: auth.organizationId,
        estimate_sent_at: estimateSentAt,
        accepted: true,
      },
    });
  } catch (error) {
    const mappedError = mapError(error);
    return jsonResponse(mappedError.body, mappedError.status);
  }
});
