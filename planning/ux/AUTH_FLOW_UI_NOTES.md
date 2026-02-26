# Auth Flow UI Notes

Scope: Phase 1 Flutter UI scaffolds only. No Supabase calls, no secrets, and no state persistence logic.

## Route Flow Map

`/sign-in`
- `Sign In` -> same screen (visual validation/success state only)
- `Use Magic Link` -> `/magic-link`
- `Create Account` -> `/sign-up`

`/sign-up`
- `Create Account` -> `/onboarding/workspace-setup` (only after client-side validation passes)
- `Use Magic Link Instead` -> `/magic-link`
- `Already have an account? Sign In` -> `/sign-in`

`/magic-link`
- `Send Magic Link` -> same screen (visual success state only)
- `Resend Magic Link` -> same screen (visual success state only)
- `Back to Sign In` -> `/sign-in`
- `Need an account? Sign Up` -> `/sign-up`

`/onboarding/workspace-setup`
- `Continue to Import` -> `/onboarding` (existing Data Import scaffold)
- `Skip for Now` -> `/`
- `Back to Sign Up` -> `/sign-up`

## Screen-Level CTA Copy

`Sign In screen`
- Primary: `Sign In`
- Secondary: `Use Magic Link`
- Tertiary: `Create Account`

`Sign Up screen`
- Primary: `Create Account`
- Secondary: `Use Magic Link Instead`
- Tertiary: `Already have an account? Sign In`

`Magic Link screen`
- Primary (initial): `Send Magic Link`
- Primary (after valid submit): `Resend Magic Link`
- Secondary: `Back to Sign In`
- Tertiary: `Need an account? Sign Up`

`Workspace Setup screen`
- Primary: `Continue to Import`
- Secondary: `Skip for Now`
- Tertiary: `Back to Sign Up`

## Visual State Coverage

`/sign-in`
- Empty state: no email/password entered.
- Validation state: required email/password, email format checks.
- Success preview: valid inputs acknowledged; backend integration pending.

`/sign-up`
- Empty state: no profile details entered.
- Validation state: required fields, email format, password length, password match.

`/magic-link`
- Empty state: no email entered.
- Validation state: required email + email format checks.
- Success preview: link sent confirmation card, resend CTA visible.

`/onboarding/workspace-setup`
- Empty state: no teammate invite entered.
- Validation state: required workspace name and business type; optional invite email format.
- Success preview: valid setup acknowledged before onboarding handoff.

## Handoff Notes For Fabricio Integration

- Wire primary CTAs to Supabase auth/session flows:
  - `/sign-in` -> email/password sign in.
  - `/sign-up` -> account creation then profile bootstrap.
  - `/magic-link` -> email OTP/magic-link send + verify callback.
- Persist onboarding progress after workspace creation and route to `/onboarding`.
- Replace visual-only success cards with real success/error states from API responses.
- Keep all CTA labels unchanged unless PM copy updates this document.
