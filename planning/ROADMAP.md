# Roadmap: CrewCommand

## Overview

This roadmap delivers a production Flutter app that preserves the validated UX from the React prototype while adding the backend reliability required for offline lead capture, follow-up automation, and day-to-day job execution. Phases are sequenced to establish architecture first, then ship lead-to-revenue workflows, then complete platform-specific call detection and launch hardening.

## Phases

- [x] **Phase 0: Architecture & Setup** - Finalize core architecture, bootstrap infra, scaffold Flutter project, and lock collaboration workflow (Duration: 1 week)
- [ ] **Phase 1: Core Data & Auth** - Stand up backend, auth, schema, and secure app-to-backend connectivity (Duration: 1 week, in progress)
- [ ] **Phase 2: Lead Capture & Pipeline** - Ship lead capture, lead list/detail flows, and offline-first sync pipeline (Duration: 1.5 weeks, in progress)
- [ ] **Phase 3: Follow-Up Engine** - Implement sequence scheduler, SMS/email delivery, and sequence controls (Duration: 1.5 weeks, in progress)
- [ ] **Phase 4: Job Dashboard** - Deliver active-job management, phase progression, and photo uploads (Duration: 1 week, in progress)
- [ ] **Phase 5: Post-Call Detection** - Ship Android auto-detection, iOS fallback stack, and daily sweep review (Duration: 1.5 weeks)
- [ ] **Phase 6: Polish & Launch** - Add CSV import, quick estimate flow, onboarding polish, and launch readiness (Duration: 1 week)

## Collaboration Execution Rules

- `main` is always release-ready; no direct commits
- Branch naming: `feature/{phase}-{task}-{short-description}`
- Every plan/task must include owner tag: `[JUNIOR-DEV]` or `[BIZ-COFOUNDER]`
- Parallel execution allowed only when file ownership does not overlap
- Any shared-file touchpoint requires sequential ordering and explicit handoff

## Phase Details

### Phase 0: Architecture & Setup
**Goal**: Lock technical foundation and project operating model before feature coding begins.
**Depends on**: Nothing (first phase)
**Requirements**: [PLAT-01, PLAT-03]
**Success Criteria** (what must be TRUE):
1. Backend/auth/database/storage/notification choices are documented with tradeoffs and costs
2. API contracts and schema are defined with clear ownership and migration strategy
3. Flutter project scaffold exists with Riverpod architecture and theme token mapping
4. Team branching and execution rules are documented and accepted
**Plans**: 4 plans

Plans:
- [x] 00-01: Architecture decision record and cost model [JUNIOR-DEV]
- [x] 00-02: Database schema, RLS strategy, and API contracts [JUNIOR-DEV]
- [x] 00-03: Flutter scaffold + navigation + theme token baseline [JUNIOR-DEV]
- [x] 00-04: UX parity checklist from React reference screens [BIZ-COFOUNDER]

### Phase 1: Core Data & Auth
**Goal**: Bring live backend online with secure auth and production schema.
**Depends on**: Phase 0
**Requirements**: [AUTH-01, AUTH-02, AUTH-03, AUTH-04]
**Success Criteria** (what must be TRUE):
1. Users can sign up/sign in and persist sessions securely
2. Core entities (leads, jobs, follow-up, calls) exist in Postgres with RLS enabled
3. Flutter app can read/write tenant-scoped data against production backend
**Plans**: 5 plans

Plans:
- [ ] 01-01: Provision Supabase project, environments, secrets, and auth [JUNIOR-DEV]
- [ ] 01-02: Create migrations for core schema + indexes + RLS [JUNIOR-DEV]
- [ ] 01-03: Build auth/onboarding UI screens in Flutter from reference UX [BIZ-COFOUNDER]
- [x] 01-04: Reconcile roadmap/state truth and stabilization resume point [BIZ-COFOUNDER]
- [x] 01-05: Auth/workspace local-cache integrity and settings data flow cleanup [JUNIOR-DEV]

### Phase 2: Lead Capture & Pipeline
**Goal**: Ship fast, offline-capable lead pipeline workflow.
**Depends on**: Phase 1
**Requirements**: [PLAT-02, LEAD-01, LEAD-02, LEAD-03, LEAD-04, LEAD-05, LEAD-06, LEAD-07, LEAD-08]
**Success Criteria** (what must be TRUE):
1. Contractor can capture leads in seconds online/offline
2. Lead status pipeline and conversion UX behave as defined
3. Offline mutations sync safely without duplicate or lost records
**Plans**: 5 plans

Plans:
- [ ] 02-01: Implement local Drift schema + sync queue engine [JUNIOR-DEV]
- [ ] 02-02: Build lead capture/list/detail Flutter screens from React reference [BIZ-COFOUNDER]
- [ ] 02-03: Implement lead status transitions + conversion actions [JUNIOR-DEV]
- [ ] 02-04: Home screen reminders for won leads without projects [BIZ-COFOUNDER]
- [x] 02-05: Device registration + sync hardening + outbox entity alignment [JUNIOR-DEV]

### Phase 3: Follow-Up Engine
**Goal**: Deliver reliable automated follow-up messaging workflow.
**Depends on**: Phase 2
**Requirements**: [FUP-01, FUP-02, FUP-03, FUP-04, FUP-05, FUP-06, FUP-07]
**Success Criteria** (what must be TRUE):
1. Estimate send (or manual confirmation) starts follow-up sequence
2. Day 2/5/10 messages send inside allowed hours only
3. Pause/stop controls work and are reflected in UI state
**Plans**: 5 plans

Plans:
- [ ] 03-01: Build sequence scheduler Edge Functions + cron dispatcher [JUNIOR-DEV]
- [ ] 03-02: Integrate Twilio + email provider + template token rendering [JUNIOR-DEV]
- [ ] 03-03: Implement follow-up status UI and controls in lead screens [BIZ-COFOUNDER]
- [ ] 03-04: Add reliability observability and retry controls [JUNIOR-DEV]
- [x] 03-05: Follow-up template/notification hardening via shared lead action service [JUNIOR-DEV]

### Phase 4: Job Dashboard
**Goal**: Convert won leads into active jobs and track delivery progress.
**Depends on**: Phase 3
**Requirements**: [JOB-01, JOB-02, JOB-03, JOB-04, JOB-05]
**Success Criteria** (what must be TRUE):
1. Owner can create and manage jobs with phase progression
2. Job status and ETA are visible at a glance
3. Job photos upload with timestamps and are retrievable on detail view
**Plans**: 4 plans

Plans:
- [ ] 04-01: Implement job schema endpoints and phase transition rules [JUNIOR-DEV]
- [ ] 04-02: Build jobs list/detail/create screens in Flutter [BIZ-COFOUNDER]
- [ ] 04-03: Implement photo capture/upload pipeline with storage policies [JUNIOR-DEV]
- [x] 04-04: Jobs UX semantic normalization (phase + health labels) [BIZ-COFOUNDER]

### Phase 1.1: Stabilization Wave (Cross-Phase)
**Goal**: Stabilize and harden the in-progress P1/P2 base without losing brownfield momentum.
**Depends on**: Phase 0
**Requirements**: [AUTH-03, AUTH-04, LEAD-03, LEAD-05, FUP-04, JOB-02, JOB-03]
**Success Criteria** (what must be TRUE):
1. Authenticated users hydrate local org/profile cache before settings/follow-up screens depend on Drift-only reads
2. Sync push no longer relies on placeholder device IDs
3. Template editing and lead follow-up actions are consistent across Home, Leads, and Lead Detail
4. Flutter analyzer and test suite are clean after stabilization refactor
**Plans**: 6 plans

Plans:
- [x] 01-04: Reconcile roadmap/state truth and stabilization resume point [BIZ-COFOUNDER]
- [x] 01-05: Auth/workspace local-cache integrity and settings data flow cleanup [JUNIOR-DEV]
- [x] 02-05: Device registration + sync hardening + outbox entity alignment [JUNIOR-DEV]
- [x] 03-05: Follow-up template/notification hardening via shared lead action service [JUNIOR-DEV]
- [x] 04-04: Jobs UX semantic normalization (phase + health labels) [BIZ-COFOUNDER]
- [x] 05-01: Regression tests, analyzer clean, verification/state updates [JUNIOR-DEV]

### Phase 5: Post-Call Detection
**Goal**: Capture missed opportunities from phone activity across platforms.
**Depends on**: Phase 4
**Requirements**: [CALL-01, CALL-02, CALL-03, CALL-04]
**Success Criteria** (what must be TRUE):
1. Android call events create near-real-time capture prompts
2. iOS fallback channels reliably prefill number capture flow
3. Daily sweep review allows save or skip for unknown calls
**Plans**: 4 plans

Plans:
- [ ] 05-01: Android native call detection + Flutter platform channel bridge [JUNIOR-DEV]
- [ ] 05-02: iOS fallback package (resume prompt, Share Sheet, widget, Siri shortcut) [JUNIOR-DEV]
- [ ] 05-03: Build daily sweep review UI and actions [BIZ-COFOUNDER]
- [ ] 05-04: Notification orchestration and permissions UX [JUNIOR-DEV]

### Phase 6: Polish & Launch
**Goal**: Complete onboarding, estimate flow, and launch readiness.
**Depends on**: Phase 5
**Requirements**: [IMP-01, IMP-02, IMP-03, EST-01, EST-02]
**Success Criteria** (what must be TRUE):
1. CSV onboarding import works with clear mapping and import results
2. Quick estimate SMS path reliably triggers follow-up workflow
3. App store submissions and beta pilot are launch-ready
**Plans**: 4 plans

Plans:
- [ ] 06-01: Implement CSV parser/mapping/import pipeline [JUNIOR-DEV]
- [ ] 06-02: Build onboarding/import/settings/quick-estimate screens [BIZ-COFOUNDER]
- [ ] 06-03: Complete app permissions docs, store assets, and release checklists [BIZ-COFOUNDER]
- [ ] 06-04: Pilot rollout instrumentation + bugfix hardening [JUNIOR-DEV]

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 0. Architecture & Setup | 4/4 | Complete | 2026-02-26 |
| 1. Core Data & Auth | 2/5 | In progress | - |
| 1.1 Stabilization Wave | 6/6 | Complete | 2026-03-01 |
| 2. Lead Capture & Pipeline | 1/5 | In progress | - |
| 3. Follow-Up Engine | 1/5 | In progress | - |
| 4. Job Dashboard | 1/4 | In progress | - |
| 5. Post-Call Detection | 1/4 | In progress | - |
| 6. Polish & Launch | 0/4 | Not started | - |
