# Requirements: CrewCommand

**Defined:** 2026-02-26
**Core Value:** A contractor can capture a lead and never forget to follow up again.

## v1 Requirements

### Platform & UX

- [ ] **PLAT-01**: App runs on both iOS and Android from a shared Flutter codebase
- [ ] **PLAT-02**: Core workflows are optimized for one-hand mobile use with large tap targets
- [ ] **PLAT-03**: React prototype screens/flows are replicated in Flutter for v1

### Authentication & Workspace

- [ ] **AUTH-01**: Contractor can create account with email and password
- [ ] **AUTH-02**: Contractor can sign in via magic link fallback
- [ ] **AUTH-03**: Session persists securely across app restarts
- [ ] **AUTH-04**: App data is tenant-isolated by contractor workspace

### Lead Capture & Pipeline

- [ ] **LEAD-01**: User can create lead from structured form (name, phone, job type)
- [ ] **LEAD-02**: User can create lead from shorthand free-text input
- [ ] **LEAD-03**: Lead capture works offline and syncs automatically when online
- [ ] **LEAD-04**: Leads progress through 4 statuses: New/Call Back, Estimate Sent, Won, Cold
- [ ] **LEAD-05**: Lead cards show automation status at a glance
- [ ] **LEAD-06**: Lead card has prominent "Estimate Sent" action (not buried in menu)
- [ ] **LEAD-07**: Marking lead as Won prompts project creation with pre-filled data
- [ ] **LEAD-08**: Home screen surfaces won leads without projects

### Follow-Up Automation

- [ ] **FUP-01**: Sending estimate triggers Day 2/5/10 follow-up sequence
- [ ] **FUP-02**: Sequence sends via SMS (Twilio) and email
- [ ] **FUP-03**: Templates support `{client_name}`, `{job_type}`, `{contractor_name}` tokens
- [ ] **FUP-04**: Contractor can pause and stop sequence per lead
- [ ] **FUP-05**: Sequence sends only between 9 AM and 6 PM local time
- [ ] **FUP-06**: Lead view shows sent and upcoming follow-up state
- [ ] **FUP-07**: Manual "Sent from another tool" trigger can start sequence

### Job Dashboard

- [ ] **JOB-01**: User can create job from won lead or manually
- [ ] **JOB-02**: Job tracks fixed phases: Demo, Rough, Electrical/Plumbing, Finishing, Walkthrough, Complete
- [ ] **JOB-03**: One-tap phase advancement updates job timeline
- [ ] **JOB-04**: Job has status color (green/yellow/red) for risk visibility
- [ ] **JOB-05**: Job supports photo uploads with timestamps

### Post-Call Detection & Daily Sweep

- [ ] **CALL-01**: Android detects calls and prompts lead creation within 30 seconds
- [ ] **CALL-02**: iOS supports fallback flow: on-resume prompt, Share Sheet, widget, Siri shortcut
- [ ] **CALL-03**: Daily 6 PM sweep prompts review of unknown calls
- [ ] **CALL-04**: Unknown call can be saved as lead or skipped

### Import & Estimate Sending

- [ ] **IMP-01**: User can import CSV/spreadsheet during onboarding
- [ ] **IMP-02**: Import supports simple mapping (name, phone, job type)
- [ ] **IMP-03**: Import provides clear success/failure summary
- [ ] **EST-01**: Lead card supports quick estimate SMS send with entered amount
- [ ] **EST-02**: Estimate SMS send is branded with contractor name/business

## v2 Requirements

### Expansion (Deferred)

- **V2-01**: QuickBooks/Jobber integrations
- **V2-02**: Client-facing portal
- **V2-03**: Advanced estimating engine
- **V2-04**: Crew scheduling and dispatch board

## Out of Scope

| Feature | Reason |
|---------|--------|
| Invoicing/payments | Not required to validate follow-up and pipeline value |
| Crew scheduling | Different workflow domain than lead-to-job pipeline |
| Client portal | Internal owner operations are priority |
| Desktop/web product | Mobile-first needed for field environment |
| Jobber/QuickBooks integrations | Premature integration complexity for MVP |
| Full estimating engine | Quick estimate text covers MVP need |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| PLAT-01 | Phase 0 | Pending |
| PLAT-02 | Phase 2 | Pending |
| PLAT-03 | Phase 0 | Pending |
| AUTH-01 | Phase 1 | Pending |
| AUTH-02 | Phase 1 | Pending |
| AUTH-03 | Phase 1 | Pending |
| AUTH-04 | Phase 1 | Pending |
| LEAD-01 | Phase 2 | Pending |
| LEAD-02 | Phase 2 | Pending |
| LEAD-03 | Phase 2 | Pending |
| LEAD-04 | Phase 2 | Pending |
| LEAD-05 | Phase 2 | Pending |
| LEAD-06 | Phase 2 | Pending |
| LEAD-07 | Phase 2 | Pending |
| LEAD-08 | Phase 2 | Pending |
| FUP-01 | Phase 3 | Pending |
| FUP-02 | Phase 3 | Pending |
| FUP-03 | Phase 3 | Pending |
| FUP-04 | Phase 3 | Pending |
| FUP-05 | Phase 3 | Pending |
| FUP-06 | Phase 3 | Pending |
| FUP-07 | Phase 3 | Pending |
| JOB-01 | Phase 4 | Pending |
| JOB-02 | Phase 4 | Pending |
| JOB-03 | Phase 4 | Pending |
| JOB-04 | Phase 4 | Pending |
| JOB-05 | Phase 4 | Pending |
| CALL-01 | Phase 5 | Pending |
| CALL-02 | Phase 5 | Pending |
| CALL-03 | Phase 5 | Pending |
| CALL-04 | Phase 5 | Pending |
| IMP-01 | Phase 6 | Pending |
| IMP-02 | Phase 6 | Pending |
| IMP-03 | Phase 6 | Pending |
| EST-01 | Phase 6 | Pending |
| EST-02 | Phase 6 | Pending |

**Coverage:**
- v1 requirements: 36 total
- Mapped to phases: 36
- Unmapped: 0

---
*Requirements defined: 2026-02-26*
*Last updated: 2026-02-26 after `/gsd:new-project` initialization*
