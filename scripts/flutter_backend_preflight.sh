#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

required_env=(SUPABASE_URL SUPABASE_ANON_KEY)
for key in "${required_env[@]}"; do
  if [[ -z "${!key:-}" ]]; then
    echo "[FAIL] Missing environment variable: $key"
    exit 1
  fi
done

echo "[INFO] Using Supabase URL: ${SUPABASE_URL}"

MIGRATION="supabase/migrations/20260306_000006_phase4_clients_photos_sync.sql"
if [[ ! -f "$MIGRATION" ]]; then
  echo "[FAIL] Missing required migration: $MIGRATION"
  exit 1
fi
echo "[PASS] Migration present: $MIGRATION"

required_functions=(sync-pull sync-push auth-bootstrap leads-estimate-sent followup-dispatcher)
for fn in "${required_functions[@]}"; do
  if [[ ! -d "supabase/functions/${fn}" ]]; then
    echo "[FAIL] Missing function directory: supabase/functions/${fn}"
    exit 1
  fi
done
echo "[PASS] Function directories present"

probe() {
  local method="$1"
  local fn="$2"
  local payload="${3:-}"
  local tmp
  tmp="$(mktemp)"

  local code
  if [[ "$method" == "GET" ]]; then
    code="$(curl -sS -o "$tmp" -w "%{http_code}" \
      "${SUPABASE_URL}/functions/v1/${fn}?limit=1" \
      -H "apikey: ${SUPABASE_ANON_KEY}" \
      -H "Authorization: Bearer invalid-token")"
  else
    code="$(curl -sS -o "$tmp" -w "%{http_code}" \
      "${SUPABASE_URL}/functions/v1/${fn}" \
      -X "$method" \
      -H "content-type: application/json" \
      -H "apikey: ${SUPABASE_ANON_KEY}" \
      -H "Authorization: Bearer invalid-token" \
      -d "$payload")"
  fi

  if rg -qi "scaffold-only|not_implemented" "$tmp"; then
    echo "[FAIL] ${fn} still reports scaffold/not_implemented"
    echo "--- response ---"
    cat "$tmp"
    rm -f "$tmp"
    exit 1
  fi

  if [[ "$code" != "401" && "$code" != "403" ]]; then
    echo "[FAIL] ${fn} returned HTTP $code (expected 401/403 for auth-required endpoint)"
    echo "--- response ---"
    cat "$tmp"
    rm -f "$tmp"
    exit 1
  fi

  echo "[PASS] ${fn} auth gate status: $code"
  rm -f "$tmp"
}

probe GET sync-pull
probe POST sync-push '{"device_id":"00000000-0000-0000-0000-000000000001","mutations":[]}'
probe POST auth-bootstrap '{"business_name":"Demo","timezone":"America/New_York"}'
probe POST leads-estimate-sent '{"lead_id":"00000000-0000-0000-0000-000000000001"}'
probe POST followup-dispatcher '{}'

echo "[PASS] Flutter backend preflight completed."
