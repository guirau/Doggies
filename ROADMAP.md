# Doggies — Roadmap

**Last Updated:** 2026-05-13  
**Project Phase:** Pre-development (planning complete)  
**Branch:** `main`

---

## How to read this file

This file is the single source of truth for build order and project state.  
- **Status labels:** `[ ]` not started · `[~]` in progress · `[x]` done  
- When picking up work, start at the first `[ ]` or `[~]` item in the active phase.  
- Do not build anything outside the current phase without explicit approval.  
- For feature details, see [`docs/prd/features-proposal.md`](docs/prd/features-proposal.md).  
- For architecture rules, see [`ARCHITECTURE.md`](ARCHITECTURE.md) and [`docs/architecture/`](docs/architecture/).

---

## Current State

> **Where we are:** Planning complete. No code written yet. Ready to begin Phase 1 (frontend shell).

Planning artifacts completed:
- [x] Feature set defined (`docs/prd/features-proposal.md`)
- [x] System architecture defined (`docs/architecture/system-overview.md`)
- [x] ADRs written (ADR-001 through ADR-006)
- [x] Data model designed (`docs/architecture/data-model.md`)
- [x] `CLAUDE.md`, `ARCHITECTURE.md`, `PROJECT.md` scaffolded

---

## MVP

The MVP is three sequential phases. Each phase is independently deployable.

---

### Phase 1 — Frontend Shell

**Goal:** A live, deployed frontend on Vercel with placeholder data and CI/CD from GitHub. No backend, no database.

**Deployment:** Vercel (auto CI/CD via GitHub Actions on merge to `main`)

#### Deliverables

- [ ] Initialize Next.js 15 project (App Router, TypeScript, Tailwind)
- [ ] Configure Vercel deployment + GitHub Actions CI/CD pipeline
- [ ] Public dog discovery page — UI with mock/hardcoded data
  - Dog grid with name, breed, size, placeholder photo
  - Individual dog profile page with bio, photo gallery placeholder, diary placeholder
  - Filter bar (size, gender, personality traits) — UI only, no logic yet
- [ ] Admin panel — full UI shell with placeholder data
  - Dog list with status + last update date
  - Adopter leads list with contact info + status
  - Forms for adding/editing a dog (fields: name, breed, age, gender, size, traits, health)
  - Media upload UI (non-functional in Phase 1)
- [ ] Donation section — prominent button linking to external crowdfunding page
- [ ] Deploy and verify all routes render correctly on Vercel

**Done when:** The site is live on Vercel, all pages render with mock data, CI/CD deploys on push.

---

### Phase 2 — Database Integration

**Goal:** Replace all mock data with real Supabase data. Admin can manage dogs and leads from the dashboard.

**Prerequisite:** Phase 1 complete and deployed.  
**Deployment:** No new infrastructure — Supabase is managed. Vercel auto-deploys.

#### Deliverables

- [ ] Supabase project setup
  - Create project, configure environment variables
  - Apply schema from `docs/architecture/data-model.md`
  - Configure Row Level Security (RLS) policies (public read for dogs; admin-only write)
  - Supabase Auth — admin login/logout (JWT)
  - Seed database with representative sample dogs
- [ ] Wire discovery page → Supabase JS client
  - Dog grid: `SELECT * FROM dogs WHERE status = 'available'`
  - Individual dog profile: dog bio + media from Supabase Storage
  - Filters: size, gender, personality traits
- [ ] Wire admin panel → Supabase JS client
  - Dog CRUD: create, read, update, delete via Supabase JS
  - Mark dog status: available / fostered / adopted / medical hold
  - Post diary updates for a dog (health, mood, activity, milestones)
  - Media upload: photos and videos to Supabase Storage (≤50 MB per video)
  - Adopter leads: view list, inline-edit status and notes
- [ ] Protect admin routes behind Supabase Auth (JWT check)
- [ ] Verify all data flows end-to-end on Vercel

**Done when:** Admin can log in, add a dog with photos, and see it appear on the public discovery page. All data lives in Supabase.

---

### Phase 3 — AI Chatbot

**Goal:** A grounded AI chatbot on the discovery page that answers visitor questions and notifies the admin of adoption intent.

**Prerequisite:** Phase 2 complete.  
**New infrastructure:** FastAPI on Google Cloud Run (first backend deployment).

#### Deliverables

- [ ] FastAPI backend setup
  - Python 3.12, project structure following `ARCHITECTURE.md` (core / adapters / api / wiring / config)
  - Docker container, Artifact Registry, Cloud Run deployment
  - GitHub Actions CI/CD pipeline (build → push → deploy on merge to `main`)
  - `/api/chat` endpoint (POST, streaming via SSE)
- [ ] Visitor AI chatbot agent
  - LangChain + Claude API (Tool Use, strict grounding contract — see ADR-004)
  - Tool: `search_dogs(traits, size, gender, ...)` — queries Supabase directly
  - Tool: `get_dog_profile(dog_id)` — returns full dog profile
  - Tool: `signal_adoption_intent(dog_name, visitor_context)` → triggers Telegram notification
  - Grounding contract: agent only surfaces facts returned by tools; never fabricates
- [ ] Telegram adoption alert
  - Telegram Bot created, token stored in Cloud Run secrets
  - FastAPI calls Telegram Bot API when `signal_adoption_intent` is called
  - Admin receives: dog name, visitor context, link to `/admin/leads`
- [ ] Chatbot widget on frontend
  - Embedded on discovery page and individual dog profile pages
  - Streaming responses via SSE
  - "I'm interested in adopting" CTA opens chatbot with pre-fill
- [ ] Admin dashboard: chatbot conversation viewer
  - View last N sessions (default 10, configurable)
- [ ] CORS, rate limiting, and authentication on `/api/chat` endpoint
- [ ] End-to-end test: visitor asks about a dog → chatbot responds with real data → admin receives Telegram alert

**Done when:** A visitor can chat with the bot, get grounded answers about real dogs, and the admin receives a Telegram notification when adoption intent is expressed.

---

## Feature Backlog

> Items here do not have a committed build order. Re-prioritize freely. None block each other unless noted.  
> Reference: [`docs/prd/features-proposal.md`](docs/prd/features-proposal.md) for full descriptions.

### B1 — Telegram Admin Agent

Admin sends voice notes, text, or photos to a Telegram bot to update the database without opening the dashboard. Whisper API for transcription, LangChain agent with write tools.

**Depends on:** Phase 3 (Cloud Run deployed, Telegram bot exists)  
**See:** [ADR-006](docs/architecture/ADR-006-telegram-admin-agent.md), `TelegramSession` table already in data model.

### B2 — Adoption Application Form

Structured form for serious adopters (living situation, dog experience, home environment). Feeds into admin panel as a structured lead.

**Depends on:** Phase 2 (Supabase wired)

### B3 — Dog Diary / Status Updates (Public Feed)

Scrollable public timeline of recent updates across all dogs. Keeps donors and supporters engaged between visits.

**Depends on:** Phase 2 (diary updates already in DB model)

### B4 — Instagram Auto-Posting

When admin posts a new dog, auto-generate an Instagram post (caption + primary photo). Requires Meta Graph API + Business account + App Review (allow 2–4 weeks lead time).

**Depends on:** Phase 2  
**Note:** Start the Meta App Review process early — it is the long pole.

### B5 — Virtual or In-Person Meet Booking

Visitor requests a scheduled meeting (video or in-person) with a specific dog. Admin confirms via Telegram; Calendly or manual scheduling.

**Depends on:** Phase 2 (leads exist), optionally Phase 3 (chatbot can surface the CTA)

### B6 — Instagram Chatbot (Top of Funnel)

Instagram DM chatbot using the same AI agent backend as the web chatbot. Requires Meta Messaging API approval (separate from Graph API).

**Depends on:** Phase 3 (AI agent backend deployed)  
**Note:** ManyChat is a SaaS shortcut that handles Meta integration via webhooks.

### B7 — Dog Sponsorship

Supporters sponsor a specific dog monthly (food + vet coverage). Dog profile shows sponsor badge. Requires payment integration (Stripe or Omise for Thailand).

**Depends on:** Phase 2  
**Note:** Most complex backlog item — requires business account and payment provider setup.

---

## Community Features (Horizon 3)

Not scheduled. Consider only after the backlog above is substantially built.

- Dog-related business directory (vets, groomers, pet shops on Koh Phangan)
- Events calendar (fundraisers, adoption days, meetups)
- Foster network (active foster families + their dogs)
- Community forum (dog owners on the island)

---

## Architecture Quick Reference

| Layer | Technology | Hosting | First appears |
|-------|------------|---------|---------------|
| Frontend | Next.js 15 (App Router, TypeScript) | Vercel | Phase 1 |
| DB / Auth / Storage | Supabase JS Client → Supabase | Supabase (managed) | Phase 2 |
| Backend (AI only) | FastAPI (Python 3.12) | Google Cloud Run | Phase 3 |
| AI Agent | LangChain + Claude API | Cloud Run | Phase 3 |
| Notifications | Telegram Bot API | External | Phase 3 |
| Telegram Admin Agent | LangChain + Whisper + Claude | Cloud Run | Backlog B1 |

Key docs: [`ARCHITECTURE.md`](ARCHITECTURE.md) · [`docs/architecture/system-overview.md`](docs/architecture/system-overview.md) · [`docs/architecture/data-model.md`](docs/architecture/data-model.md)
