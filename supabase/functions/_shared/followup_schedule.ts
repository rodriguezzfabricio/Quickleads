const SEND_WINDOW_START_MINUTE = 9 * 60;
const SEND_WINDOW_END_MINUTE = 18 * 60;

export const FOLLOWUP_TEMPLATE_BY_STEP: Record<number, string> = {
  2: "day_2_followup",
  5: "day_5_followup",
  10: "day_10_followup",
};

export const FOLLOWUP_STEPS = [2, 5, 10] as const;
export const FOLLOWUP_CHANNELS = ["sms", "email"] as const;

export interface FollowupScheduleEntry {
  stepNumber: number;
  channel: "sms" | "email";
  templateKey: string;
  scheduledAt: string;
}

interface LocalDateParts {
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
  second: number;
}

function formatDateParts(date: Date, timezone: string): LocalDateParts {
  const formatter = new Intl.DateTimeFormat("en-US", {
    timeZone: timezone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: false,
  });

  const parts = formatter.formatToParts(date);
  const partMap: Record<string, string> = {};
  for (const part of parts) {
    partMap[part.type] = part.value;
  }

  return {
    year: Number.parseInt(partMap.year ?? "0", 10),
    month: Number.parseInt(partMap.month ?? "1", 10),
    day: Number.parseInt(partMap.day ?? "1", 10),
    hour: Number.parseInt(partMap.hour ?? "0", 10),
    minute: Number.parseInt(partMap.minute ?? "0", 10),
    second: Number.parseInt(partMap.second ?? "0", 10),
  };
}

function timezoneOffsetMs(instant: Date, timezone: string): number {
  const local = formatDateParts(instant, timezone);
  const utcFromLocal = Date.UTC(
    local.year,
    local.month - 1,
    local.day,
    local.hour,
    local.minute,
    local.second,
  );
  return utcFromLocal - instant.getTime();
}

function localDateTimeToUtc(parts: LocalDateParts, timezone: string): Date {
  const utcGuess = Date.UTC(
    parts.year,
    parts.month - 1,
    parts.day,
    parts.hour,
    parts.minute,
    parts.second,
  );

  const firstGuess = new Date(utcGuess);
  const firstOffset = timezoneOffsetMs(firstGuess, timezone);
  let resolved = new Date(utcGuess - firstOffset);

  const secondOffset = timezoneOffsetMs(resolved, timezone);
  if (secondOffset !== firstOffset) {
    resolved = new Date(utcGuess - secondOffset);
  }

  return resolved;
}

function clampLocalClock(hour: number, minute: number, second: number): Pick<LocalDateParts, "hour" | "minute" | "second"> {
  const minuteOfDay = hour * 60 + minute;

  if (minuteOfDay < SEND_WINDOW_START_MINUTE) {
    return { hour: 9, minute: 0, second: 0 };
  }

  if (minuteOfDay > SEND_WINDOW_END_MINUTE) {
    return { hour: 18, minute: 0, second: 0 };
  }

  return { hour, minute, second };
}

function localDateWithDayOffset(parts: LocalDateParts, dayOffset: number): Pick<LocalDateParts, "year" | "month" | "day"> {
  const anchorUtcDate = new Date(Date.UTC(parts.year, parts.month - 1, parts.day));
  anchorUtcDate.setUTCDate(anchorUtcDate.getUTCDate() + dayOffset);

  return {
    year: anchorUtcDate.getUTCFullYear(),
    month: anchorUtcDate.getUTCMonth() + 1,
    day: anchorUtcDate.getUTCDate(),
  };
}

export function normalizeTimezone(timezone: string | null | undefined): string {
  const normalized = typeof timezone === "string" ? timezone.trim() : "";
  if (!normalized) {
    return "America/New_York";
  }

  try {
    new Intl.DateTimeFormat("en-US", { timeZone: normalized });
    return normalized;
  } catch {
    return "America/New_York";
  }
}

export function buildFollowupSchedule(estimateSentAtIso: string, timezone: string): FollowupScheduleEntry[] {
  const normalizedTimezone = normalizeTimezone(timezone);
  const estimateInstant = new Date(estimateSentAtIso);
  const localEstimate = formatDateParts(estimateInstant, normalizedTimezone);
  const localClock = clampLocalClock(localEstimate.hour, localEstimate.minute, localEstimate.second);

  const schedule: FollowupScheduleEntry[] = [];

  for (const step of FOLLOWUP_STEPS) {
    const templateKey = FOLLOWUP_TEMPLATE_BY_STEP[step];
    const localDate = localDateWithDayOffset(localEstimate, step);
    const sendAt = localDateTimeToUtc(
      {
        year: localDate.year,
        month: localDate.month,
        day: localDate.day,
        hour: localClock.hour,
        minute: localClock.minute,
        second: localClock.second,
      },
      normalizedTimezone,
    );

    for (const channel of FOLLOWUP_CHANNELS) {
      schedule.push({
        stepNumber: step,
        channel,
        templateKey,
        scheduledAt: sendAt.toISOString(),
      });
    }
  }

  return schedule;
}

export function isWithinSendWindow(atIso: string, timezone: string): boolean {
  const local = formatDateParts(new Date(atIso), normalizeTimezone(timezone));
  const minuteOfDay = local.hour * 60 + local.minute;
  return minuteOfDay >= SEND_WINDOW_START_MINUTE && minuteOfDay <= SEND_WINDOW_END_MINUTE;
}

export function nextSendWindowStart(atIso: string, timezone: string): string {
  const normalizedTimezone = normalizeTimezone(timezone);
  const local = formatDateParts(new Date(atIso), normalizedTimezone);
  const minuteOfDay = local.hour * 60 + local.minute;

  let date = new Date(Date.UTC(local.year, local.month - 1, local.day));
  if (minuteOfDay > SEND_WINDOW_END_MINUTE) {
    date.setUTCDate(date.getUTCDate() + 1);
  }

  const sendAt = localDateTimeToUtc(
    {
      year: date.getUTCFullYear(),
      month: date.getUTCMonth() + 1,
      day: date.getUTCDate(),
      hour: 9,
      minute: 0,
      second: 0,
    },
    normalizedTimezone,
  );

  return sendAt.toISOString();
}

export function applyRetryDelay(baseIso: string, timezone: string, nextRetryCount: number): string {
  const retryDelayMinutes =
    nextRetryCount <= 1 ? 15 : nextRetryCount === 2 ? 60 : 180;

  const delayed = new Date(baseIso);
  delayed.setUTCMinutes(delayed.getUTCMinutes() + retryDelayMinutes);

  const delayedIso = delayed.toISOString();
  if (isWithinSendWindow(delayedIso, timezone)) {
    return delayedIso;
  }

  return nextSendWindowStart(delayedIso, timezone);
}

export function localDateIso(atIso: string, timezone: string): string {
  const local = formatDateParts(new Date(atIso), normalizeTimezone(timezone));
  const month = String(local.month).padStart(2, "0");
  const day = String(local.day).padStart(2, "0");
  return `${local.year}-${month}-${day}`;
}
