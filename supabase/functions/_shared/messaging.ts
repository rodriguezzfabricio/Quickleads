export interface MessageSendResult {
  success: boolean;
  provider_message_id?: string;
  error?: string;
}

export interface TemplateTokens {
  client_name?: string;
  job_type?: string;
  contractor_name?: string;
  amount?: string;
  business_name?: string;
}

function requiredEnv(name: string): string | null {
  const value = Deno.env.get(name)?.trim();
  return value && value.length > 0 ? value : null;
}

function safeErrorMessage(error: unknown): string {
  if (error instanceof Error && error.message.trim().length > 0) {
    return error.message;
  }
  return "Unknown provider error.";
}

export function renderTemplate(template: string | null | undefined, tokens: TemplateTokens): string {
  const base = (template ?? "").toString();
  return base.replace(/\{([a-zA-Z0-9_]+)\}/g, (_, rawKey: string) => {
    const key = rawKey as keyof TemplateTokens;
    const value = tokens[key];
    return typeof value === "string" ? value : "";
  });
}

export async function sendSms(params: {
  to: string;
  body: string;
}): Promise<MessageSendResult> {
  const to = params.to?.trim();
  if (!to) {
    return { success: false, error: "Missing recipient phone number." };
  }

  const accountSid = requiredEnv("TWILIO_ACCOUNT_SID");
  const authToken = requiredEnv("TWILIO_AUTH_TOKEN");
  const fromNumber = requiredEnv("TWILIO_FROM_NUMBER");

  if (!accountSid || !authToken || !fromNumber) {
    return {
      success: false,
      error: "Twilio is not configured. Set TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, and TWILIO_FROM_NUMBER.",
    };
  }

  try {
    const response = await fetch(`https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`, {
      method: "POST",
      headers: {
        Authorization: `Basic ${btoa(`${accountSid}:${authToken}`)}`,
        "content-type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({
        To: to,
        From: fromNumber,
        Body: params.body,
      }),
    });

    const json = await response.json().catch(() => null);

    if (!response.ok) {
      const providerMessage =
        typeof json?.message === "string"
          ? json.message
          : `Twilio request failed (${response.status}).`;
      return { success: false, error: providerMessage };
    }

    const sid = typeof json?.sid === "string" ? json.sid : undefined;
    return {
      success: true,
      provider_message_id: sid,
    };
  } catch (error) {
    return {
      success: false,
      error: safeErrorMessage(error),
    };
  }
}

export async function sendEmail(params: {
  to: string;
  subject: string;
  body: string;
}): Promise<MessageSendResult> {
  const to = params.to?.trim();
  if (!to) {
    return { success: false, error: "Missing recipient email address." };
  }

  const apiKey = requiredEnv("RESEND_API_KEY");
  const fromEmail = requiredEnv("RESEND_FROM_EMAIL");

  if (!apiKey || !fromEmail) {
    return {
      success: false,
      error: "Email provider is not configured. Set RESEND_API_KEY and RESEND_FROM_EMAIL.",
    };
  }

  try {
    const response = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        from: fromEmail,
        to: [to],
        subject: params.subject,
        text: params.body,
      }),
    });

    const json = await response.json().catch(() => null);

    if (!response.ok) {
      let providerMessage = `Email request failed (${response.status}).`;
      if (typeof json?.message === "string" && json.message.trim().length > 0) {
        providerMessage = json.message;
      } else if (typeof json?.error === "string" && json.error.trim().length > 0) {
        providerMessage = json.error;
      }

      return {
        success: false,
        error: providerMessage,
      };
    }

    const providerId =
      typeof json?.id === "string"
        ? json.id
        : typeof json?.data?.id === "string"
          ? json.data.id
          : undefined;

    return {
      success: true,
      provider_message_id: providerId,
    };
  } catch (error) {
    return {
      success: false,
      error: safeErrorMessage(error),
    };
  }
}
