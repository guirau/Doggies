# Doggies — Feature Proposals

**Status:** Active
**Last Updated:** 2026-05-13

MVP features are ordered by build phase. Backlog items are numbered in suggested priority order.

---

## MVP Features

### Phase 1 — Donation Link

- A prominent "Donate" button or section on the public site
- Links to the existing external crowdfunding page
- No payment integration in MVP

### Phase 1–2 — Admin Panel

- UI shell with placeholder data (Phase 1)
- Post a new dog: name, breed, age, gender, size, personality traits, health status (Phase 2)
- Upload photos and videos for each dog (Phase 2)
- Post diary updates for a dog: health, mood, activity, milestones (Phase 2)
- View list of adopter leads and their status (Phase 2)
- Mark a dog's status: available / fostered / adopted / medical hold (Phase 2)

### Phase 1–2 — Public Dog Discovery Page

- UI shell with placeholder data (Phase 1)
- Grid of available dogs with primary photo, name, breed, size (Phase 2)
- Individual dog profile page with full bio, photo gallery, diary updates (Phase 2)
- Filter by size, gender, personality traits (Phase 2)
- "I'm interested in adopting" CTA → opens chatbot (Phase 3)

### Phase 3 — AI Chatbot

- Natural language Q&A about dogs ("Which dogs are good with kids?")
- Dog-specific questions ("Tell me about Max's health status")
- Adoption interest → triggers Telegram notification to admin
- Embedded as a widget on the discovery page and individual dog pages

---

## Feature Backlog

> Numbered in suggested build order. Re-prioritise freely — none are dependencies of each other except where noted.

### 1. Telegram Admin Agent

The admin can send voice notes, text, or photos to a Telegram bot to update the database without opening the web dashboard. The agent transcribes audio (Whisper API), extracts intent, asks clarifying questions if needed, and writes to the DB.

**Why:** The admin already uses Telegram daily. Voice is the lowest-friction interface for someone managing a shelter alone. The web dashboard handles deliberate, structured edits; Telegram handles quick field updates.

**Implementation note:** Requires Whisper API, LangChain agent with write tools, stateful `TelegramSession` table (already in data model). See [ADR-006](../architecture/ADR-006-telegram-admin-agent.md) for full design.

### 2. Adoption Application Form

A structured form for serious adopters: living situation, experience with dogs, home environment, preferred dog size. Feeds directly into the admin panel as a lead with structured data.

**Why:** Currently the admin has to chase adopters for basic info. A form collects it upfront, saving admin time.

### 3. Dog Diary / Status Updates (Public Feed)

A scrollable feed of recent updates across all dogs — like a timeline. Donors and supporters see "Bella had her vaccinations today!" without visiting individual profiles.

**Why:** Keeps casual supporters engaged even if they're not adopting. Increases return visits. Emotional connection drives donations.

### 4. Instagram Auto-Posting on New Dog Intake

When the admin posts a new dog, automatically generate an Instagram post: caption with dog name, traits, and an adoption CTA, plus the primary photo.

**Why:** The admin is drowning in ops. Auto-posting saves 15–30 minutes per dog. Consistent posting = more followers = more visibility.

**Implementation note:** Requires Meta Graph API + Business account + App Review. Can take 2–4 weeks. Start the approval process early.

### 5. Virtual or In-Person Meet Booking

Visitors can request a scheduled meeting (video call or in-person at the shelter) with a specific dog. Admin receives the request via Telegram and confirms. A simple calendar integration (Calendly or manual) handles scheduling.

**Why:** Bridges online discovery to real-world commitment. Meeting a dog is the highest-conversion step in adoption.

### 6. Instagram Chatbot (Top of Funnel)

An Instagram DM chatbot that responds to story replies and DMs on the shelter's account. Uses the same AI agent backend as the web chatbot.

**Why:** Instagram is where adopters currently discover the shelter. Meeting them where they are removes friction.

**Implementation note:** Requires Meta Messaging API approval (separate from Graph API). ManyChat is a SaaS shortcut that handles the Meta integration and connects to the backend via webhooks.

### 7. Dog Sponsorship

Allow a supporter to sponsor a specific dog for a monthly amount that covers food and vet costs. The dog's profile shows "Sponsored by [name/handle]" with a small badge.

**Why:** Creates named, recurring donations. Donors feel ownership without adopting. The shelter owner gets predictable monthly income.

**Implementation note:** Requires a payment integration (Stripe or Omise for Thailand). Most complex item — depends on business account setup.

---

## Community Features

- Dog-related business directory (vets, groomers, pet shops on Koh Phangan)
- Events calendar (shelter fundraisers, adoption days, dog meetups)
- Foster network (list of active foster families + their dogs)
- Community forum (dog owners on the island)

---

## Feature → Problem Mapping

| Feature               | Visibility | Funding | Matching | Ops |
| --------------------- | ---------- | ------- | -------- | --- |
| Public discovery page | x          |         | x        |     |
| AI chatbot            | x          |         | x        |     |
| Donation link         |            | x       |          |     |
| Dog diary feed        | x          | x       |          |     |
| Dog sponsorship       |            | x       | x        |     |
| Instagram auto-post   | x          |         |          | x   |
| Instagram chatbot     | x          | x       | x        |     |
| Adoption application  |            |         | x        | x   |
| Virtual meet booking  |            |         | x        | x   |
| Admin panel           |            |         |          | x   |
