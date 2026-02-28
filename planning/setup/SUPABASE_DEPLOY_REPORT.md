# Supabase Deploy Report

Date: 2026-02-27
Repo: `/Users/fabriciorodriguez/Desktop/Contractor Communication App`
Branch: `feature/1-0-pre-supabase-readiness`

## Target Project

- Project ref: `seuoakzowzmqsmbqzznm`
- Project name: Test Quickleads
- Project URL: `https://seuoakzowzmqsmbqzznm.supabase.co`
- Region: US East (North Virginia)

## Execution Summary

1. Link Supabase CLI to project: **SUCCESS**
2. Push migrations: **SUCCESS** (3/3 applied)
3. Deploy edge functions: **SUCCESS** (3/3 active)
4. Set function secrets: **N/A** (SUPABASE_ vars auto-injected; Twilio/Resend/FCM deferred to Phase 3)
5. Verify REST API: **SUCCESS** (14 tables + 6 RPC functions responding)

## Migration Status

| Migration | Status |
|-----------|--------|
| `20260226_000001_init_schema.sql` | APPLIED |
| `20260227_000001_rls_role_hardening.sql` | APPLIED |
| `20260228_000001_followup_and_onboarding_hardening.sql` | APPLIED |

Note: Migration filenames were renumbered from original `20260226_000002/3` to unique date prefixes to resolve Supabase CLI version key collisions.

## Function Deployment Status

| Function | Status | Version |
|----------|--------|---------|
| `leads-estimate-sent` | ACTIVE | 1 |
| `sync-push` | ACTIVE | 1 |
| `sync-pull` | ACTIVE | 1 |

All functions currently return 501 `not_implemented` (stubs). Real logic will be implemented in Phase 2 (sync) and Phase 3 (follow-ups).

## Tables Live

organizations, profiles, devices, leads, jobs, job_photos, followup_sequences, followup_messages, call_logs, message_templates, imports, import_rows, sync_mutations, notifications

## RPC Functions Live

bootstrap_organization, current_organization_id, is_organization_member, is_organization_owner, is_organization_manager, is_organization_manager_or_owner, has_organization_role

## Security

- `.env` files gitignored — no credentials committed
- RLS enabled and forced on all 14 tables
- `bootstrap_organization` restricted to `service_role` only
- Delete policies require `owner` or `manager` role

## Remaining for Phase 1

- [ ] 01-02: Wire auth (sign up / sign in / session) in React prototype
- [ ] 01-03: Build onboarding UI (bootstrap_organization call after first sign-up)
