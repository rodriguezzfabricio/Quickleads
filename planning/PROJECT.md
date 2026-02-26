# CrewCommand

## What This Is

CrewCommand is a mobile-first CRM and job execution app for small residential contractors in Maryland/DC (1-15 employees). It helps crews capture leads in seconds, trigger reliable SMS/email follow-up automatically, and manage active jobs without desktop software. The React app in this repo is the UX reference; production is a Flutter iOS/Android app.

## Core Value

A contractor can capture a lead and never forget to follow up again.

## Requirements

### Validated

(None shipped yet in production. Validation so far is interview-based, not product-usage based.)

### Active

- [ ] 15-second lead capture with offline-first behavior
- [ ] Automated Day 2/5/10 follow-up via SMS + email, pause/stop controls, 9 AM-6 PM window
- [ ] Owner-only active job dashboard with phase progression and photo timestamps
- [ ] 4-stage lead pipeline with explicit estimate-sent and won conversion flows
- [ ] Post-call lead detection (Android automatic, iOS fallback suite, daily 6 PM sweep)
- [ ] CSV import for onboarding existing leads/jobs
- [ ] Quick estimate text that triggers follow-up automation

### Out of Scope

- Invoicing and payment processing in v1 - not part of validated MVP pain
- Crew scheduling/time tracking in v1 - expands scope beyond lead-to-job command center
- Estimating engine (line-item estimator) in v1 - quick estimate text is sufficient for MVP
- Client-facing portal in v1 - MVP is internal owner workflow only
- QuickBooks/Jobber integrations in v1 - defer until repeatable workflow value proven
- Desktop/web-first product in v1 - mobile-first required for field usage

## Context

- Users are non-technical contractors on job sites; every action must be low-friction with large touch targets
- UX benchmark is "as easy as sending a text"; enterprise-style complexity is unacceptable
- Existing codebase is React + TypeScript prototype with no backend/auth/persistence
- Production app will be Flutter + managed backend services to fit a 2-person team
- Follow-up automation reliability is the top revenue-critical feature from customer interviews

## Constraints

- **Budget**: $50-100/month all-in infrastructure target at MVP usage
- **Team**: 2 contributors, one technical and one non-technical, single shared repo
- **Offline**: Lead capture must work without connectivity and sync later
- **Messaging**: SMS must be first-class (not email-only) for customer behavior fit
- **Platform**: iOS + Android from a single Flutter codebase

## Collaboration Model

- Branch naming: `feature/{phase}-{task}-{short-description}`
- `main` is always deployable
- Task labels in all plans:
  - `[JUNIOR-DEV]` for backend/native/platform-channel/state-heavy tasks
  - `[BIZ-COFOUNDER]` for UI, copy/content, simple config/data tasks
- Parallel rule: tasks for different people can run in parallel only if they do not edit overlapping files
- If file overlap exists, tasks run sequentially with explicit handoff order in the plan

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Flutter for production app | Single mobile codebase, faster delivery for 2-person team | Pending |
| Supabase + Postgres backend | Managed auth/db/storage/functions with low ops overhead | Pending |
| Supabase Auth (email/password + magic link) | Avoid OTP SMS auth cost/complexity while keeping mobile-friendly login | Pending |
| Twilio SMS + Resend email | Direct fit for follow-up automation channels and template-driven messaging | Pending |
| Drift (SQLite) local data layer | Strong offline support and deterministic sync control in Flutter | Pending |
| FCM for push delivery | Cross-platform push channel with no separate APNs-only implementation path | Pending |

---
*Last updated: 2026-02-26 after `/gsd:new-project` initialization*
