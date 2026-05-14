# Doggies — Requirements

**Last Updated:** 2026-05-14
**Status:** Active — fill in each section as work begins on that feature.

---

## How to read this file

- Each requirement has a stable **ID** that maps to tests, ADRs, and PR descriptions.
- **Scope** maps to release milestones: `v1` = full MVP (Phases 1–3) · `v2` = post-MVP backlog · `out-of-scope` = community features and anything explicitly excluded.
- A requirement is _done_ when a test, Playwright check, or manual verification step can confirm it passes. "Implemented" is not done.
- When starting a feature, find its requirements here, write tests against them first, then build to make them pass.

### Prefix legend

| Prefix | Concern |
|--------|---------|
| `INFRA` | Infrastructure — deployments, CI/CD, project setup |
| `AUTH` | Authentication and authorization |
| `UI` | User-facing interface and rendering |
| `DATA` | Database schema, RLS, seeding, state machines |
| `MEDIA` | Photo and video upload, storage, retrieval |
| `API` | HTTP endpoints and contracts (FastAPI, MVP Phase 0.3) |
| `AI` | AI chatbot agent behaviour and grounding contract |
| `NOTIF` | Notifications (Telegram adoption alerts) |
| `AGENT` | Telegram admin agent (voice/text DB updates) |
| `FORM` | Adoption application form |
| `FEED` | Public dog diary / status update feed |
| `SOCIAL` | Instagram integrations |
| `BOOKING` | Virtual or in-person meet scheduling |
| `PAYMENT` | Dog sponsorship and recurring payments |
| `PERF` | Performance budgets |
| `SEC` | Security constraints |

---

## MVP Phase 0.1 — Frontend Shell

> Goal: Live deployed frontend on Vercel with placeholder data. No backend, no database.

### INFRA — Infrastructure

| ID | Requirement | Scope |
|----|-------------|-------|
| INFRA-01 | Next.js 15 project initialised with App Router, TypeScript, and Tailwind CSS | v1 |
| INFRA-02 | `pnpm build` completes with zero errors and zero TypeScript errors | v1 |
| INFRA-03 | GitHub Actions CI/CD pipeline deploys to Vercel on every merge to `main` | v1 |
| INFRA-04 | Vercel creates a preview deployment for every open PR | v1 |
| INFRA-05 | All routes (`/`, `/dogs`, `/dogs/[id]`, `/admin`) render correctly on the Vercel preview URL | v1 |

### UI — Public Discovery Page

| ID | Requirement | Scope |
|----|-------------|-------|
| UI-01 | `/dogs` renders a grid of dog cards; each card shows name, breed, size, and a primary photo placeholder | v1 |
| UI-02 | `/dogs/[id]` renders an individual dog profile with bio, photo gallery placeholder, and diary placeholder | v1 |
| UI-03 | Filter bar on `/dogs` renders controls for size, gender, and personality traits (UI only — no logic in MVP Phase 0.1) | v1 |
| UI-04 | `/dogs` is server-side rendered (no `"use client"` at the page level) | v1 |
| UI-05 | All mock dog data lives in a single fixture file; no hardcoded values scattered across components | v1 |

### UI — Admin Panel Shell

| ID | Requirement | Scope |
|----|-------------|-------|
| UI-06 | `/admin/dogs` renders a list of dogs with status badge and last-updated date | v1 |
| UI-07 | `/admin/dogs/new` renders a dog creation form with all fields: name, breed, age, gender, size, traits, health status | v1 |
| UI-08 | `/admin/leads` renders a list of adopter leads with contact handle, contact type, and status | v1 |
| UI-09 | Media upload field renders in the dog form (non-functional in MVP Phase 0.1; button present, no action) | v1 |
| UI-10 | All admin UI uses placeholder/hardcoded data in MVP Phase 0.1; no real API calls | v1 |

### UI — Donation

| ID | Requirement | Scope |
|----|-------------|-------|
| UI-11 | A prominent donation section is visible on the public-facing homepage or discovery page | v1 |
| UI-12 | The donation CTA links to the external crowdfunding page and opens in a new tab | v1 |
| UI-13 | No payment processing, no payment credentials, and no payment SDK are present in MVP Phase 0.1 | v1 |

---

## MVP Phase 0.2 — Database Integration

> Goal: Replace all mock data with real Supabase data. Admin can manage dogs and leads from the dashboard.
> **Prerequisite:** MVP Phase 0.1 complete and deployed.

### INFRA — Supabase Setup

| ID | Requirement | Scope |
|----|-------------|-------|
| INFRA-06 | Supabase project created; `SUPABASE_URL` and `SUPABASE_ANON_KEY` set as Vercel environment variables | v1 |
| INFRA-07 | `SUPABASE_SERVICE_ROLE_KEY` present only in server-side Vercel env vars; never exposed to the browser | v1 |
| INFRA-08 | No secrets or credentials appear in any committed file | v1 |

### AUTH — Admin Authentication

| ID | Requirement | Scope |
|----|-------------|-------|
| AUTH-01 | Admin can log in at `/admin/login` with email and password via Supabase Auth | v1 |
| AUTH-02 | Successful login issues a JWT stored as a secure httpOnly cookie; session persists across page reloads | v1 |
| AUTH-03 | All routes under `/admin/*` redirect to `/admin/login` when accessed without a valid JWT | v1 |
| AUTH-04 | Admin can log out; logging out clears the session and redirects to `/admin/login` | v1 |
| AUTH-05 | Public routes (`/`, `/dogs`, `/dogs/[id]`) are accessible without authentication | v1 |
| AUTH-06 | A single admin account is sufficient for MVP; no multi-user or role management required | v1 |

### DATA — Schema, RLS, and Seeding

| ID | Requirement | Scope |
|----|-------------|-------|
| DATA-01 | Supabase schema matches `docs/architecture/data-model.md` (tables: `dogs`, `dog_media`, `dog_updates`, `adopter_leads`, `visitors`, `chat_sessions`) | v1 |
| DATA-02 | RLS policy: public (`anon` role) can `SELECT` from `dogs` where `status = 'available'` | v1 |
| DATA-03 | RLS policy: public (`anon` role) can `SELECT` from `dog_media` and `dog_updates` for available dogs only | v1 |
| DATA-04 | RLS policy: only the authenticated admin can `INSERT`, `UPDATE`, or `DELETE` on all tables | v1 |
| DATA-05 | Database seeded with at least 5 sample dogs, each with at least one media record and one diary update | v1 |
| DATA-06 | Dog status transitions follow the defined state machine; invalid transitions are rejected at the application layer | v1 |
| DATA-07 | `pgvector` extension enabled; `embedding vector(1536)` column exists on `dogs` (reserved for v2 semantic search, nullable in v1) | v1 |

### MEDIA — Photos and Videos

| ID | Requirement | Scope |
|----|-------------|-------|
| MEDIA-01 | Photos and videos are stored in Supabase Storage under a per-dog prefix (e.g., `dogs/{dog_id}/`) | v1 |
| MEDIA-02 | Video uploads are rejected if the file exceeds 50 MB | v1 |
| MEDIA-03 | Each dog must have exactly one `DogMedia` record with `is_primary = true` | v1 |
| MEDIA-04 | All media URLs are publicly accessible Supabase Storage URLs; no signed URLs required for public images | v1 |
| MEDIA-05 | All photo rendering uses `next/image`; no raw `<img>` tags for dog photos | v1 |

### UI — Discovery Page (wired)

| ID | Requirement | Scope |
|----|-------------|-------|
| UI-14 | `/dogs` fetches live data from Supabase: `SELECT * FROM dogs WHERE status = 'available'` | v1 |
| UI-15 | Individual dog profile at `/dogs/[id]` fetches the dog bio, full media gallery, and diary updates from Supabase | v1 |
| UI-16 | Size, gender, and personality trait filters on `/dogs` are functional and filter results without a full page reload | v1 |

### UI — Admin Panel (wired)

| ID | Requirement | Scope |
|----|-------------|-------|
| UI-17 | Admin can create a new dog via the form; the dog appears in the discovery page immediately after save | v1 |
| UI-18 | Admin can edit any dog field inline on `/admin/dogs`; changes are persisted to Supabase | v1 |
| UI-19 | Admin can change a dog's status to any valid state from the dog list view | v1 |
| UI-20 | Admin can post a diary update for a dog (type: `health`, `mood`, `activity`, `milestone`, `general`) | v1 |
| UI-21 | Admin can upload photos and videos for a dog; uploaded media appears in the dog's gallery immediately | v1 |
| UI-22 | Admin can view all adopter leads on `/admin/leads` with contact handle, contact type, and current status | v1 |
| UI-23 | Admin can inline-edit a lead's status and notes; changes are persisted to Supabase | v1 |

---

## MVP Phase 0.3 — AI Chatbot

> Goal: Grounded AI chatbot on the discovery page that answers visitor questions and notifies admin of adoption intent.
> **Prerequisite:** MVP Phase 0.2 complete.
> **New infrastructure:** FastAPI on Google Cloud Run.

### INFRA — FastAPI and Cloud Run

| ID | Requirement | Scope |
|----|-------------|-------|
| INFRA-09 | FastAPI service packaged as a Docker container and pushed to Artifact Registry | v1 |
| INFRA-10 | Cloud Run service deployed from Artifact Registry; accessible via a public HTTPS URL | v1 |
| INFRA-11 | GitHub Actions CI/CD: on merge to `main`, builds container, pushes to Artifact Registry, deploys to Cloud Run | v1 |
| INFRA-12 | All Cloud Run secrets (Telegram token, Claude API key, Supabase service role key) stored in Secret Manager; never as plain env vars in source | v1 |
| INFRA-13 | Cloud Run service minimum instances: 0; maximum instances: configurable via env var (default: 3) | v1 |

### API — Chat Endpoint

| ID | Requirement | Scope |
|----|-------------|-------|
| API-01 | `POST /api/chat` accepts `{message: string, visitor_id: string}` and returns a Server-Sent Events (SSE) stream | v1 |
| API-02 | CORS on `/api/chat` allows requests only from the configured Vercel frontend origin | v1 |
| API-03 | Rate limiting on `/api/chat`: maximum 20 requests per `visitor_id` per minute; excess requests receive `429` | v1 |
| API-04 | All API error responses return `{error: string, code: string}`; no stack traces in production responses | v1 |
| API-05 | `/health` endpoint returns `200 OK` (used by Cloud Run health checks) | v1 |

### AI — Chatbot Agent

| ID | Requirement | Scope |
|----|-------------|-------|
| AI-01 | The chatbot answers natural language questions about dogs using tool results only; it never fabricates facts about specific dogs | v1 |
| AI-02 | All dog-specific facts (name, breed, traits, health, availability) in chatbot responses are sourced from tool return values | v1 |
| AI-03 | Tool `search_dogs(traits, size, gender, ...)` queries Supabase and returns matching available dogs | v1 |
| AI-04 | Tool `get_dog_profile(dog_id)` returns the full profile for a single dog | v1 |
| AI-05 | Tool `signal_adoption_intent(dog_name, visitor_context)` triggers a Telegram notification and returns confirmation | v1 |
| AI-06 | The agent maintains conversation context within a single session; earlier messages inform later responses | v1 |
| AI-07 | On returning visitor's first message, prior session summaries are injected into the Claude context (see data model `Visitor.conversation_summary`) | v1 |
| AI-08 | Sessions end after 30 minutes of inactivity; `ChatSession.session_summary` is written to the DB on session end | v1 |
| AI-09 | `ChatSession` records are deleted for visitors with `last_seen < NOW() - INTERVAL '30 days'`; `Visitor` and `AdopterLead` records are retained | v1 |

### NOTIF — Telegram Adoption Alerts

| ID | Requirement | Scope |
|----|-------------|-------|
| NOTIF-01 | Admin receives a Telegram message when `signal_adoption_intent` is called | v1 |
| NOTIF-02 | Telegram message contains: dog name, a brief visitor context snippet, and a link to `/admin/leads` | v1 |
| NOTIF-03 | Telegram Bot token is read from Secret Manager at runtime; it does not appear in source code or build logs | v1 |
| NOTIF-04 | A Telegram delivery failure is logged but does not cause the chat response to fail or return an error to the visitor | v1 |

### UI — Chatbot Widget

| ID | Requirement | Scope |
|----|-------------|-------|
| UI-24 | A chatbot widget is embedded on `/dogs` and on each `/dogs/[id]` page | v1 |
| UI-25 | Widget streams responses from `/api/chat` via SSE; partial tokens appear progressively | v1 |
| UI-26 | An "I'm interested in adopting" CTA on a dog's profile page opens the chatbot pre-filled with the dog's name | v1 |
| UI-27 | Admin can view the last N chatbot sessions at `/admin/chat` (default N = 10, configurable) | v1 |

---

## Feature Backlog (v2)

> Requirements below are stubs. Fill in detail as each feature is prioritised for development.
> Reference: `docs/prd/features-proposal.md` for full feature descriptions.

### AGENT — Telegram Admin Agent

| ID | Requirement | Scope | Notes |
|----|-------------|-------|-------|
| AGENT-01 | Admin can send a voice note to the Telegram bot to create or update a dog record | v2 | Whisper API transcription |
| AGENT-02 | Admin can send a text message to the Telegram bot to update any dog field | v2 | |
| AGENT-03 | Agent asks clarifying questions if the intent is ambiguous before writing to the DB | v2 | e.g. "update the brown dog" with multiple brown dogs |
| AGENT-04 | Agent writes to the DB only after all required fields are collected | v2 | |
| AGENT-05 | `TelegramSession` table tracks multi-turn clarification conversations | v2 | Already in data model |
| AGENT-06 | An active session is abandoned after 30 minutes of inactivity | v2 | |
| AGENT-07 | Admin receives a confirmation message after a successful DB write | v2 | |

**Depends on:** MVP Phase 0.3 deployed (Cloud Run + Telegram bot infrastructure exists).
**See:** `docs/architecture/ADR-006-telegram-admin-agent.md`

---

### FORM — Adoption Application Form

| ID | Requirement | Scope |
|----|-------------|-------|
| FORM-01 | Visitor can submit an adoption application form with fields: living situation, dog experience, home environment, preferred dog size | v2 |
| FORM-02 | Submitted form creates an `AdopterLead` record in Supabase | v2 |
| FORM-03 | Admin sees structured form data alongside the lead in `/admin/leads` | v2 |
| FORM-04 | Form includes basic validation; required fields cannot be submitted empty | v2 |

**Depends on:** MVP Phase 0.2 (Supabase + leads table).

---

### FEED — Dog Diary / Status Updates (Public Feed)

| ID | Requirement | Scope |
|----|-------------|-------|
| FEED-01 | A public feed at `/updates` shows recent `DogUpdate` records across all available dogs in reverse-chronological order | v2 |
| FEED-02 | Feed is paginated or infinite-scroll; at least 20 items per page | v2 |
| FEED-03 | Each feed entry shows: dog name (linked to dog profile), update type, content text, and date | v2 |

**Depends on:** MVP Phase 0.2 (`dog_updates` table populated).

---

### SOCIAL — Instagram Auto-Posting

| ID | Requirement | Scope | Notes |
|----|-------------|-------|-------|
| SOCIAL-01 | When admin posts a new dog, an Instagram post is automatically created | v2 | |
| SOCIAL-02 | Auto-post includes: dog name, key personality traits, adoption CTA, and primary photo | v2 | |
| SOCIAL-03 | Integration uses Meta Graph API connected to a Business account | v2 | Meta App Review required — allow 2–4 weeks |
| SOCIAL-04 | Meta App Review is completed and approved before this feature is shipped | v2 | Start approval process early |

**Depends on:** MVP Phase 0.2 (dog creation flow exists).

---

### SOCIAL — Instagram Chatbot

| ID | Requirement | Scope | Notes |
|----|-------------|-------|-------|
| SOCIAL-05 | A chatbot responds to Instagram DMs and story replies on the shelter's account | v2 | |
| SOCIAL-06 | Chatbot uses the same AI agent backend as the web chatbot (`/api/chat` or equivalent) | v2 | |
| SOCIAL-07 | Integration delivered via Meta Messaging API or ManyChat webhooks | v2 | ManyChat is the lower-friction path |

**Depends on:** MVP Phase 0.3 (AI agent backend deployed).

---

### BOOKING — Virtual or In-Person Meet Booking

| ID | Requirement | Scope |
|----|-------------|-------|
| BOOKING-01 | Visitor can request a virtual or in-person meeting with a specific dog | v2 |
| BOOKING-02 | Meeting request creates or updates an `AdopterLead` with status `meeting_scheduled` | v2 |
| BOOKING-03 | Admin receives the meeting request via Telegram | v2 |
| BOOKING-04 | Admin can confirm or decline the request; visitor receives confirmation | v2 |

**Depends on:** MVP Phase 0.2 (leads table); optionally MVP Phase 0.3 (chatbot can surface the CTA).

---

### PAYMENT — Dog Sponsorship

| ID | Requirement | Scope | Notes |
|----|-------------|-------|-------|
| PAYMENT-01 | Supporter can choose a monthly sponsorship amount for a specific dog | v2 | |
| PAYMENT-02 | Payment is processed via Stripe or Omise | v2 | Omise preferred for Thailand |
| PAYMENT-03 | Dog profile displays "Sponsored by [name/handle]" badge while sponsorship is active | v2 | |
| PAYMENT-04 | Recurring billing is managed by the payment provider; cancellation is available to the sponsor | v2 | |
| PAYMENT-05 | No payment card data is stored in Supabase; only payment provider customer/subscription IDs | v2 | |

**Depends on:** MVP Phase 0.2. Requires business account and payment provider onboarding.

---

## Cross-Cutting Requirements

These apply across all features and phases. Verify at each phase boundary.

### PERF — Performance

| ID | Requirement | Scope |
|----|-------------|-------|
| PERF-01 | Discovery page (`/dogs`) LCP < 2.5 s on a simulated 4G connection (Lighthouse) | v1 |
| PERF-02 | Discovery page CLS < 0.1; dog cards do not shift during photo load | v1 |
| PERF-03 | Frontend JS bundle (gzipped) for the landing/discovery page < 150 kb | v1 |
| PERF-04 | Hero/above-the-fold photos use `fetchpriority="high"` and `loading="eager"`; all other dog photos use `loading="lazy"` | v1 |
| PERF-05 | Chat widget SSE response time-to-first-token < 2 s under normal load | v1 |

### SEC — Security

| ID | Requirement | Scope |
|----|-------------|-------|
| SEC-01 | No route under `/admin/*` is accessible without a valid Supabase JWT | v1 |
| SEC-02 | No secret or credential appears in any committed file, build log, or client-side bundle | v1 |
| SEC-03 | CSP headers are configured in production (Vercel `next.config.js` or middleware) | v1 |
| SEC-04 | RLS policies are enforced at the database layer; the application does not rely solely on its own access control | v1 |
| SEC-05 | Visitor PII is not stored in the `Visitor` table; PII moves to `AdopterLead` only when the visitor explicitly provides it | v1 |
| SEC-06 | Rate limiting on `/api/chat` prevents a single visitor from flooding the Claude API | v1 |
| SEC-07 | Media uploads are validated server-side for type and size before writing to Supabase Storage | v1 |

---

## Out of Scope

The following features are explicitly excluded from the product. Do not implement without a deliberate decision to re-scope.

| Feature | Reason |
|---------|--------|
| Dog-related business directory | Community feature — Horizon 3 |
| Events calendar (fundraisers, adoption days) | Community feature — Horizon 3 |
| Foster network listing | Community feature — Horizon 3 |
| Community forum | Community feature — Horizon 3 |
| International adoption logistics | Transport + regulatory complexity out of MVP scope (see `system-overview.md`) |
| Multi-admin / role management | Single admin for MVP; Supabase Auth handles one user |
| Payment card data storage | All payment data lives with the payment provider (PCI compliance) |
