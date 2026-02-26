# Interaction Rules

Scope: Shared UX behavior rules for Flutter parity scaffolds during Phase 0 and implementation phases.

## Mobile-First Input Rules

- Minimum tap target: 48x48 dp for all primary and secondary actions.
- Keep one-thumb reach in mind: place primary actions near lower half when possible.
- Keep text hierarchy simple: one primary action per screen section.

## Navigation Rules

- Match React route intent and order:
  - `/` home dashboard
  - `/leads`, `/leads/:leadId`, `/lead-capture`
  - `/clients`, `/clients/new`, `/clients/:clientId`
  - `/jobs`, `/jobs/:jobId`, `/projects/new`
  - `/daily-sweep-review`, `/follow-up-settings`, `/onboarding`, `/settings`
- Back behavior should always return to previous screen context and avoid dead ends.

## Form Rules

- Required fields are visually explicit and validated before save actions enable.
- Preserve prefill behavior where React uses query params (`name`, `phone`, `leadId`, `jobType`).
- Keep data-entry blocks short with clear labels and single-purpose placeholders.

## Status And Confirmation Rules

- High-impact transitions require confirm UI (cold, stop, delete, automation changes).
- Estimate-sent and won transitions remain explicit action buttons, not hidden menu options.
- Follow-up status must be glanceable from list and detail surfaces.

## Content Density Rules

- Use short labels and plain language for non-technical contractor users.
- Prefer one card/list section per intent (capture, history, actions, settings).
- Empty states must include next action guidance.

## Placeholder Rules (Phase 0)

- Every scaffold subtitle must include the owning feature area and target phase.
- Placeholder screens must not contain backend calls, auth flow logic, or persistence.
- Keep route wiring complete so parity testing can happen before business logic work starts.
