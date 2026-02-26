# Phase 0 Security Baseline

**Phase:** 0 - Architecture & Setup  
**Owner:** [JUNIOR-DEV]  
**Date:** 2026-02-26

## Scope

This baseline covers the initial backend foundation for Supabase schema and Edge Function stubs. It defines mandatory controls before Phase 1 feature logic begins.

## Required Controls

1. **No hardcoded secrets**
- Runtime secrets are read from environment variables only (`SUPABASE_URL`, `SUPABASE_ANON_KEY` in edge functions).
- No API keys, tokens, or credentials are committed to source control.

2. **Tenant isolation with RLS**
- All Phase 0 tables have RLS enabled and forced.
- Access is organization-scoped via profile membership helper functions.
- Client-provided organization IDs are not trusted for authorization decisions.

3. **Server-side input validation**
- Every edge function validates method, payload shape, UUIDs, and timestamp formats.
- Validation failures return explicit `invalid_request` errors with safe messages.

4. **Auth-derived organization context**
- Edge functions derive user/profile/organization from bearer token + `profiles` lookup.
- Organization membership is verified before any table operations.

5. **Sync idempotency safety**
- `sync_mutations` has unique `(organization_id, client_mutation_id)` index.
- This prevents replay from applying the same client mutation multiple times.

## Security Review Checklist

- [x] No hardcoded secrets in SQL or TypeScript
- [x] RLS enabled for all Phase 0 tables
- [x] RLS forced for all Phase 0 tables
- [x] Organization-scoped policies present
- [x] Sync idempotency unique index present
- [x] Edge stubs validate request inputs
- [x] Edge stubs derive org from auth context
- [x] Error responses use explicit error codes without leaking internals

## Deferred Security Work

- TODO(PHASE-1-auth-hardening): Add privileged service-role path for onboarding/invite workflows.
- TODO(PHASE-2-rate-limit): Add endpoint-level throttling and abuse controls.
- TODO(PHASE-3-provider-secrets): Configure Twilio/Resend/FCM secret management and rotation runbook.
