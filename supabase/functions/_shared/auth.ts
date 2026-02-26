import { createClient, type SupabaseClient, type User } from "npm:@supabase/supabase-js@2.49.8";

export type AuthErrorCode =
  | "missing_authorization"
  | "invalid_authorization"
  | "invalid_token"
  | "profile_missing"
  | "profile_lookup_failed"
  | "configuration_error";

export class HttpError extends Error {
  readonly status: number;
  readonly code: string;

  constructor(status: number, code: AuthErrorCode | string, message: string) {
    super(message);
    this.name = "HttpError";
    this.status = status;
    this.code = code;
  }
}

export interface AuthContext {
  accessToken: string;
  user: User;
  userId: string;
  profileId: string;
  organizationId: string;
  role: string;
  client: SupabaseClient;
}

function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) {
    throw new HttpError(500, "configuration_error", `Missing required environment variable: ${name}`);
  }
  return value;
}

function parseBearerToken(request: Request): string {
  const headerValue = request.headers.get("authorization")?.trim();

  if (!headerValue) {
    throw new HttpError(401, "missing_authorization", "Authorization header is required.");
  }

  const [scheme, token] = headerValue.split(" ");

  if (scheme?.toLowerCase() !== "bearer" || !token) {
    throw new HttpError(401, "invalid_authorization", "Authorization header must use Bearer token format.");
  }

  return token;
}

export function createRequestClient(accessToken: string): SupabaseClient {
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

export async function requireAuthContext(request: Request): Promise<AuthContext> {
  const accessToken = parseBearerToken(request);
  const client = createRequestClient(accessToken);

  const { data: userData, error: userError } = await client.auth.getUser(accessToken);
  if (userError || !userData.user) {
    throw new HttpError(401, "invalid_token", "Unable to validate the provided access token.");
  }

  const user = userData.user;

  const { data: profile, error: profileError } = await client
    .from("profiles")
    .select("id, organization_id, role")
    .eq("auth_user_id", user.id)
    .maybeSingle();

  if (profileError) {
    throw new HttpError(500, "profile_lookup_failed", "Failed to resolve profile context for authenticated user.");
  }

  if (!profile?.id || !profile.organization_id) {
    throw new HttpError(403, "profile_missing", "Authenticated user is not linked to an organization profile.");
  }

  return {
    accessToken,
    user,
    userId: user.id,
    profileId: profile.id,
    organizationId: profile.organization_id,
    role: typeof profile.role === "string" ? profile.role : "member",
    client,
  };
}

export function isHttpError(error: unknown): error is HttpError {
  return error instanceof HttpError;
}
