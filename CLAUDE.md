# CLAUDE.md — QuickLeads / CrewCommand (Contractor Communication App)

## What This App Does

A **mobile-first CRM and job tracker** for solo contractors and small construction crews. It helps them manage their entire business pipeline — from capturing a new lead on the phone, to tracking an active job on-site, to maintaining a client history after the job is done.

---

## Core Features

### 1. Lead Pipeline
Leads flow through a 4-status pipeline:
`call-back-now` → `estimate-sent` → `won` | `cold`

- **Lead Capture** (`/lead-capture`): A quick standalone form for capturing a new inbound lead. Supports pre-filling phone number via query param (`?phone=...`), intended for use directly after a missed or answered call.
- **Lead List** (`/leads`): Filterable by status. Surfaces urgent leads ("call-back-now") at the top.
- **Lead Detail** (`/leads/:id`): Full lead view with one-tap actions to:
  - Mark estimate sent (activates follow-up sequence)
  - Mark as won (stops follow-ups, prompts to create a job)
  - Mark as cold (stops follow-ups)
  - Pause or stop follow-up sequences
  - Delete lead
- **Action Confirmation Dialogs**: Key status changes (mark won, mark cold, delete) use confirm dialogs to prevent accidental taps.

### 2. Automated Follow-Up Sequences
When an estimate is sent, a follow-up sequence activates automatically:
- **Day 2** — First nudge
- **Day 5** — Second check-in
- **Day 10** — Final follow-up

Templates use `{client_name}`, `{job_type}`, `{contractor_name}` tokens. Sequences can be paused or stopped per lead. Configurable via `/follow-up-settings`.

### 3. Daily Sweep — Missed Call Review (`/daily-sweep`)
Surfaces incoming calls from **unknown numbers** (numbers not in the leads list).
- Shows phone number, call time, duration, and direction (iOS hides duration/direction due to OS limitations)
- One-tap to **"Save as Lead"** — routes to `/lead-capture` with phone pre-filled
- One-tap to **Skip** — dismisses the call from the queue

### 4. Job Tracking
Active jobs move through 6 construction phases:
`demo` → `rough` → `electrical-plumbing` → `finishing` → `walkthrough` → `complete`

Each job has a status: `on-track` | `needs-attention` | `behind`

- **Jobs List** (`/jobs`): Overview of all active jobs with phase and status.
- **Job Detail** (`/jobs/:id`): Phase progress indicator, notes, client contact info.
- **New Project Creation** (`/projects/new`): Create a job and optionally link it to an existing won lead (auto-fills name, phone, job type). Supports pre-filling via query params (`?leadId=`, `?name=`, `?phone=`, `?jobType=`).

### 5. Won Lead → Project Reminder
The app tracks `wonLeadsWithoutProject` — won leads with no linked job yet. The Home screen and Lead Detail surface a prompt to convert the won lead into an active project before it slips through the cracks.

### 6. Client Database
- **Clients List** (`/clients`): Existing customers.
- **Client Detail** (`/clients/:id`): Full project history with photos, notes, and contact info.
- **Add Client** (`/clients/new`): Manual client creation.

### 7. Settings & Onboarding
- **Settings** (`/settings`): Business name, contractor name, phone, notification prefs.
- **Follow-Up Settings** (`/follow-up-settings`): Edit Day 2/5/10 message templates.
- **Data Import** (`/onboarding`): CSV import flow for bringing in existing contacts.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | React 18 + TypeScript (via Vite) |
| Routing | `react-router` v7 (`createBrowserRouter`) |
| UI Kit | `konsta` (iOS-style mobile UI, `theme="ios" dark`) |
| Styling | Tailwind CSS v4 |
| Animations | `motion` (Framer Motion v12) |
| Icons | `lucide-react` |
| State | React Context (`LeadsContext`) — see below |
| Dev server | Vite → `npm run dev` → `http://localhost:5173` |

---

## Project Structure

```
src/
├── main.tsx
└── app/
    ├── App.tsx                     # KonstaApp wrapper + RouterProvider
    ├── routes.ts                   # All route definitions
    ├── types.ts                    # All shared TypeScript types (single source of truth)
    ├── state/
    │   └── LeadsContext.tsx        # Global state: leads, jobs, unknownCalls
    ├── data/
    │   └── mockData.ts             # All in-memory mock data (no backend)
    ├── hooks/
    │   └── useInlineSavedIndicator.ts
    ├── screens/                    # Full-page views (14 screens)
    └── components/                 # Reusable UI components
        ├── ui/                     # shadcn/ui primitives (48 components)
        ├── BottomNav.tsx
        ├── LeadCard.tsx
        ├── LeadActionCard.tsx
        ├── JobCard.tsx
        ├── PhaseProgress.tsx
        ├── StatusPill.tsx
        ├── FloatingActionButton.tsx
        ├── ActionConfirmDialog.tsx
        ├── EstimateSentConfirmDialog.tsx
        └── InlineSavedIndicator.tsx
```

---

## State Management (`LeadsContext`)

All mutable app state lives in `src/app/state/LeadsContext.tsx`. Screens consume it via `useLeads()`. **No Redux, no Zustand.**

Key actions exposed by the context:
| Action | What it does |
|---|---|
| `updateLeadStatus` | Generic status updater |
| `markEstimateSent` | Sets status → `estimate-sent`, activates follow-up sequence |
| `markLeadWon` | Sets status → `won`, deactivates follow-ups |
| `markLeadCold` | Sets status → `cold`, deactivates follow-ups |
| `pauseFollowUps` / `stopFollowUps` | Pause or permanently stop a follow-up sequence |
| `deleteLead` | Removes a lead |
| `createLead` | Adds a new lead (from capture form) |
| `createJob` | Creates a new active job, optionally linked to a lead via `leadId` |
| `skipUnknownCall` | Dismisses a call from the Daily Sweep queue |
| `wonLeadsWithoutProject` | Computed: won leads with no linked job (reminder surface) |

---

## Core Data Types (`src/app/types.ts`)

- **`Lead`** — Inbound prospect. Has status, optional follow-up sequence, prior project history.
- **`Job`** — Active in-progress job. Has phase, status, optional `leadId` link.
- **`Client`** — Past customer with full project history and photos.
- **`UnknownCall`** — A call from a number not in the leads list (used by Daily Sweep).
- **`AppSettings`** — Business info + follow-up configuration.

---

## Routing Map

| Path | Screen | Notes |
|---|---|---|
| `/` | `HomeScreen` | Dashboard |
| `/leads` | `LeadsScreen` | Lead list |
| `/leads/:id` | `LeadDetailScreen` | Full lead view + actions |
| `/jobs` | `JobsScreen` | Job list |
| `/jobs/:id` | `JobDetailScreen` | Job detail + phase view |
| `/clients` | `ClientsScreen` | Client list |
| `/clients/new` | `AddClientScreen` | Manual new client |
| `/clients/:id` | `ClientDetailScreen` | Client detail + history |
| `/lead-capture` | `LeadCaptureScreen` | Outside Layout (no nav bar) |
| `/projects/new` | `ProjectCreationScreen` | Outside Layout |
| `/daily-sweep` | `DailySweepReviewScreen` | Outside Layout |
| `/follow-up-settings` | `FollowUpSettingsScreen` | Outside Layout |
| `/onboarding` | `DataImportScreen` | Outside Layout |
| `/settings` | `SettingsScreen` | Outside Layout |

---

## Development Notes

- **No backend** — all data is in-memory mock data, resets on page refresh. This is expected.
- **No persistence** — no localStorage, no API calls anywhere.
- **TypeScript strictly typed** — add new types to `types.ts` first.
- **New screen pattern**: create in `screens/` → import in `routes.ts` → add to `LeadsProvider` if it needs state.
- **iOS conventions**: the app uses `konsta` with `safeAreas` — mind bottom padding near the nav bar.
- **No tests** — verification is done visually in the browser.
