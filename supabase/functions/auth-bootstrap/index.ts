import { createClient, type SupabaseClient, type User } from "npm:@supabase/supabase-js@2.49.8";

import { ValidationError, parseJsonObject, readOptionalString, readRequiredString } from "../_shared/validation.ts";

type ErrorCode =
  | "method_not_allowed"
  | "invalid_request"
  | "unauthorized"
  | "conflict"
  | "internal_error";

interface ApiError {
  ok: false;
  error: {
    code: ErrorCode;
    message: string;
  };
}

interface ApiSuccess {
  ok: true;
  data: {
    organization_id: string;
    profile_id: string;
  };
}

interface BootstrapRequest {
  business_name: string;
  timezone?: string;
}

class HttpError extends Error {
  readonly status: number;
  readonly code: ErrorCode;

  constructor(status: number, code: ErrorCode, message: string) {
    super(message);
    this.name = "HttpError";
    this.status = status;
    this.code = code;
  }
}

const CORS_HEADERS = {
  "access-control-allow-origin": "*",
  "access-control-allow-methods": "POST, OPTIONS",
  "access-control-allow-headers": "authorization, x-client-info, apikey, content-type",
};

function jsonResponse(payload: ApiSuccess | ApiError, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      ...CORS_HEADERS,
      "content-type": "application/json; charset=utf-8",
    },
  });
}

function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) {
    throw new HttpError(500, "internal_error", `Missing required environment variable: ${name}`);
  }
  return value;
}

function parseBearerToken(request: Request): string {
  const headerValue = request.headers.get("authorization")?.trim();
  if (!headerValue) {
    throw new HttpError(401, "unauthorized", "Authorization header is required.");
  }

  const [scheme, token] = headerValue.split(" ");
  if (scheme?.toLowerCase() !== "bearer" || !token) {
    throw new HttpError(401, "unauthorized", "Authorization header must use Bearer token format.");
  }

  return token;
}

function createRequestClient(accessToken: string): SupabaseClient {
  const supabaseUrl = requireEnv("SUPABASE_URL");
  const supabaseAnonKey = requireEnv("SUPABASE_ANON_KEY");

  return createClient(supabaseUrl, supabaseAnonKey, {
    global: {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    },
  });
}

function createServiceRoleClient(): SupabaseClient {
  const supabaseUrl = requireEnv("SUPABASE_URL");
  const serviceRoleKey = requireEnv("SUPABASE_SERVICE_ROLE_KEY");

  return createClient(supabaseUrl, serviceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}

function parseBootstrapRequest(input: Record<string, unknown>): BootstrapRequest {
  return {
    business_name: readRequiredString(input, "business_name", 120),
    timezone: readOptionalString(input, "timezone", 100),
  };
}

async function requireAuthenticatedUser(request: Request): Promise<User> {
  const accessToken = parseBearerToken(request);
  const client = createRequestClient(accessToken);

  const { data: userData, error: userError } = await client.auth.getUser(accessToken);
  if (userError || !userData.user) {
    throw new HttpError(401, "unauthorized", "Unable to validate the provided access token.");
  }

  return userData.user;
}

function resolveFullName(user: User): string {
  const metadata = user.user_metadata;
  if (metadata && typeof metadata === "object") {
    const fullNameRaw = metadata.full_name;
    if (typeof fullNameRaw === "string") {
      const normalized = fullNameRaw.trim();
      if (normalized.length > 0) {
        return normalized;
      }
    }
  }

  if (typeof user.email === "string" && user.email.trim().length > 0) {
    return user.email.trim();
  }

  return "Workspace Owner";
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

  if (error instanceof HttpError) {
    return {
      status: error.status,
      body: {
        ok: false,
        error: {
          code: error.code,
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
  if (request.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: CORS_HEADERS,
    });
  }

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
    const user = await requireAuthenticatedUser(request);
    const body = await parseJsonObject(request);
    const payload = parseBootstrapRequest(body);

    const serviceRoleClient = createServiceRoleClient();
    const fullName = resolveFullName(user);
    const timezone = payload.timezone ?? "America/New_York";

    const { data, error } = await serviceRoleClient.rpc("bootstrap_organization", {
      p_auth_user_id: user.id,
      p_business_name: payload.business_name,
      p_full_name: fullName,
      p_timezone: timezone,
    });

    if (error) {
      if (typeof error.message === "string" && error.message.includes("user already has an owner profile")) {
        throw new HttpError(409, "conflict", "Workspace is already initialized for this user.");
      }

      throw new HttpError(500, "internal_error", "Failed to bootstrap organization and owner profile.");
    }

    if (
      !data ||
      typeof data !== "object" ||
      typeof (data as Record<string, unknown>).organization_id !== "string" ||
      typeof (data as Record<string, unknown>).profile_id !== "string"
    ) {
      throw new HttpError(500, "internal_error", "bootstrap_organization returned an invalid payload.");
    }

    const bootstrapData = data as { organization_id: string; profile_id: string };

    return jsonResponse({
      ok: true,
      data: {
        organization_id: bootstrapData.organization_id,
        profile_id: bootstrapData.profile_id,
      },
    });
  } catch (error) {
    const mapped = mapError(error);
    return jsonResponse(mapped.body, mapped.status);
  }
});
