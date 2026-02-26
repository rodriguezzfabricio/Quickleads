# Screen Parity Matrix

Scope: Phase 0 UX parity mapping from React reference screens (`src/app/screens/**`) to Flutter presentation targets.

Status legend:
- `Not Started`: No Flutter target file or route scaffold yet
- `Stubbed`: Flutter file/route exists with placeholder UI only
- `Complete`: Flutter UX behavior is implemented and parity-verified

| React Screen | Source File | Flutter Target | Status | Required Interactions | Acceptance Checks |
|---|---|---|---|---|---|
| Home | `src/app/screens/HomeScreen.tsx` | `flutter_app/lib/features/home/home_screen.dart` | Stubbed | View dashboard metrics, open settings, navigate to leads/jobs, quick filter by status | Home route loads at `/`; placeholder explicitly references dashboard parity scope |
| Leads List | `src/app/screens/LeadsScreen.tsx` | `flutter_app/lib/features/leads/leads_screen.dart` | Stubbed | Filter segments, review calls CTA, expand card actions, open lead detail | Leads route resolves at `/leads`; screen placeholder remains mobile-first and Phase 2 tagged |
| Lead Capture | `src/app/screens/LeadCaptureScreen.tsx` | `flutter_app/lib/features/leads/lead_capture_screen.dart` | Stubbed | Structured capture fields, quick text fallback, save/cancel navigation | Route `/lead-capture` opens dedicated capture stub with clear Phase 2 intent |
| Lead Detail | `src/app/screens/LeadDetailScreen.tsx` | `flutter_app/lib/features/leads/lead_detail_screen.dart` | Stubbed | Edit profile fields, status changes, follow-up controls, call/text CTAs, project creation CTA | Route `/leads/:leadId` resolves and renders lead detail placeholder |
| Jobs List | `src/app/screens/JobsScreen.tsx` | `flutter_app/lib/features/jobs/jobs_screen.dart` | Stubbed | Job filter tabs, open job details | Route `/jobs` works and keeps list-to-detail flow intact |
| Job Detail | `src/app/screens/JobDetailScreen.tsx` | `flutter_app/lib/features/jobs/job_detail_screen.dart` | Stubbed | Update phase/status/date, add notes/photos, call CTA | Route `/jobs/:jobId` resolves with placeholder for full detail parity |
| Clients List | `src/app/screens/ClientsScreen.tsx` | `flutter_app/lib/features/clients/clients_screen.dart` | Stubbed | Search clients, open client detail, open add-client flow | Route `/clients` loads client list placeholder with Phase 2 scope |
| Add Client | `src/app/screens/AddClientScreen.tsx` | `flutter_app/lib/features/clients/client_detail_screen.dart` | Stubbed | Add/convert client form, previous projects draft list, save | Route `/clients/new` maps to create mode inside client detail scaffold |
| Client Detail | `src/app/screens/ClientDetailScreen.tsx` | `flutter_app/lib/features/clients/client_detail_screen.dart` | Stubbed | Edit fields, show prior projects, details accordion, call/text/project CTAs | Route `/clients/:clientId` resolves client detail mode placeholder |
| Project Creation | `src/app/screens/ProjectCreationScreen.tsx` | `flutter_app/lib/features/projects/project_creation_screen.dart` | Stubbed | Link lead search, prefill client info, set phase/status/date, save | Route `/projects/new` resolves with project creation scaffold |
| Daily Sweep Review | `src/app/screens/DailySweepReviewScreen.tsx` | `flutter_app/lib/features/calls/daily_sweep_screen.dart` | Stubbed | Review unknown calls, save-as-lead, skip, completion states | Route `/daily-sweep-review` resolves with review placeholder |
| Follow-up Settings | `src/app/screens/FollowUpSettingsScreen.tsx` | `flutter_app/lib/features/followups/followup_settings_screen.dart` | Stubbed | Toggle automation, choose channel, edit day templates | Route `/follow-up-settings` resolves with settings placeholder |
| Data Import (Onboarding) | `src/app/screens/DataImportScreen.tsx` | `flutter_app/lib/features/import/data_import_screen.dart` | Stubbed | Upload/import CTA, fresh-start CTA, success state | Route `/onboarding` resolves import scaffold |
| Settings | `src/app/screens/SettingsScreen.tsx` | `flutter_app/lib/features/settings/settings_screen.dart` | Stubbed | Edit business fields, open follow-up settings, toggle notifications | Route `/settings` resolves and keeps React settings flow parity |

## Coverage Snapshot

- React screens in scope: 14
- Flutter targets mapped: 14
- Mapping coverage: 100%
- Current implementation level: 14 Stubbed, 0 Complete
