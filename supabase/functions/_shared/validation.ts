export class ValidationError extends Error {
  readonly field: string;

  constructor(field: string, message: string) {
    super(message);
    this.name = "ValidationError";
    this.field = field;
  }
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

export async function parseJsonObject(request: Request): Promise<Record<string, unknown>> {
  let body: unknown;

  try {
    body = await request.json();
  } catch {
    throw new ValidationError("body", "Request body must be valid JSON.");
  }

  if (!isRecord(body)) {
    throw new ValidationError("body", "Request body must be a JSON object.");
  }

  return body;
}

export function isUuid(value: string): boolean {
  return UUID_PATTERN.test(value);
}

export function readRequiredUuid(input: Record<string, unknown>, field: string): string {
  const raw = input[field];
  if (typeof raw !== "string" || raw.trim().length === 0) {
    throw new ValidationError(field, `${field} is required and must be a UUID string.`);
  }

  if (!isUuid(raw)) {
    throw new ValidationError(field, `${field} must be a valid UUID.`);
  }

  return raw;
}

export function readOptionalUuid(input: Record<string, unknown>, field: string): string | undefined {
  const raw = input[field];
  if (raw == null) {
    return undefined;
  }

  if (typeof raw !== "string" || !isUuid(raw)) {
    throw new ValidationError(field, `${field} must be a valid UUID when provided.`);
  }

  return raw;
}

export function readRequiredString(input: Record<string, unknown>, field: string, maxLength = 255): string {
  const raw = input[field];
  if (typeof raw !== "string") {
    throw new ValidationError(field, `${field} is required and must be a string.`);
  }

  const normalized = raw.trim();
  if (normalized.length === 0 || normalized.length > maxLength) {
    throw new ValidationError(field, `${field} must be between 1 and ${maxLength} characters.`);
  }

  return normalized;
}

export function readOptionalString(input: Record<string, unknown>, field: string, maxLength = 255): string | undefined {
  const raw = input[field];
  if (raw == null) {
    return undefined;
  }

  if (typeof raw !== "string") {
    throw new ValidationError(field, `${field} must be a string when provided.`);
  }

  const normalized = raw.trim();
  if (normalized.length === 0 || normalized.length > maxLength) {
    throw new ValidationError(field, `${field} must be between 1 and ${maxLength} characters when provided.`);
  }

  return normalized;
}

export function readOptionalIsoDateTime(input: Record<string, unknown>, field: string): string | undefined {
  const raw = input[field];
  if (raw == null) {
    return undefined;
  }

  if (typeof raw !== "string") {
    throw new ValidationError(field, `${field} must be an ISO-8601 datetime string when provided.`);
  }

  const timestamp = Date.parse(raw);
  if (Number.isNaN(timestamp)) {
    throw new ValidationError(field, `${field} must be a valid ISO-8601 datetime string.`);
  }

  return new Date(timestamp).toISOString();
}

export function readOptionalInteger(
  input: Record<string, unknown>,
  field: string,
  options: { min?: number; max?: number } = {},
): number | undefined {
  const raw = input[field];
  if (raw == null) {
    return undefined;
  }

  if (typeof raw !== "number" || !Number.isInteger(raw)) {
    throw new ValidationError(field, `${field} must be an integer when provided.`);
  }

  if (options.min != null && raw < options.min) {
    throw new ValidationError(field, `${field} must be greater than or equal to ${options.min}.`);
  }

  if (options.max != null && raw > options.max) {
    throw new ValidationError(field, `${field} must be less than or equal to ${options.max}.`);
  }

  return raw;
}

export function readRequiredArray(input: Record<string, unknown>, field: string): unknown[] {
  const raw = input[field];
  if (!Array.isArray(raw)) {
    throw new ValidationError(field, `${field} is required and must be an array.`);
  }

  return raw;
}
