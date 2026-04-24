# Doggies — Feature Proposals

**Status:** Draft — for developer review  
**Last Updated:** 2026-04-23

This document extends the developer's original feature ideas with additional proposals. Items marked ✅ are confirmed for MVP. Items marked 💡 are proposals for discussion.

---

## MVP Features (Confirmed)

### ✅ Admin Panel
- Post a new dog (name, breed, age, gender, size, personality traits, health status)
- Upload photos and videos for each dog
- Post diary updates for a dog (health, mood, activity, milestones)
- View list of adopter leads and their status
- Mark a dog's status (available / fostered / adopted / medical hold)

### ✅ Public Dog Discovery Page
- Grid of available dogs with primary photo, name, breed, size
- Individual dog profile page with full bio, photo gallery, diary updates
- Filter by size, gender, personality traits
- "I'm interested in adopting" CTA → opens chatbot or sends contact

### ✅ AI Chatbot
- Natural language Q&A about dogs ("Which dogs are good with kids?")
- Dog-specific questions ("Tell me about Max's health status")
- Adoption interest → triggers Telegram notification to admin
- Embedded as a widget on the discovery page and individual dog pages

### ✅ Donation Link
- A prominent "Donate" button or section on the public site
- Links to the existing external crowdfunding page
- No payment integration in MVP

---

## Phase 2 Feature Proposals

### 💡 Dog Diary / Status Updates (Public Feed)
A scrollable feed of recent updates across all dogs — like an Instagram Stories-style timeline. Donors and supporters see "Bella had her vaccinations today!" without having to visit individual profiles.

**Why:** Keeps casual supporters engaged even if they're not adopting. Increases return visits. Emotional connection = more donations.

### 💡 Dog Sponsorship
Allow a supporter to "sponsor" a specific dog for a monthly amount that covers that dog's food/vet costs. The dog's profile shows "Sponsored by [name/handle]" with a small badge.

**Why:** Creates named, recurring donations. Donors feel ownership without adopting. The shelter owner gets predictable monthly income.

**Implementation note:** Requires a payment integration (Stripe or Omise for Thailand). Phase 2.

### 💡 Instagram Auto-Posting on New Dog Intake
When the admin posts a new dog via the admin panel, automatically generate an Instagram post: caption with dog name, traits, and an adoption CTA, plus the primary photo.

**Why:** The admin is drowning in ops. Auto-posting saves 15–30 minutes per dog. Consistent posting = more followers = more visibility.

**Implementation note:** Requires Meta Graph API + Business account + App Review. Can take 2–4 weeks. Start the approval process early.

### 💡 Instagram Chatbot (Top of Funnel)
An Instagram DM chatbot that responds to story replies and DMs on the shelter's account. Uses the same AI agent backend as the web chatbot.

**Why:** Instagram is where adopters currently discover the shelter. Meeting them where they are removes friction.

**Implementation note:** Requires Meta Messaging API approval (separate from Graph API). ManyChat is a SaaS shortcut that handles the Meta integration and connects to the backend via webhooks.

### 💡 Adoption Application Form
A structured form for serious adopters: living situation, experience with dogs, home environment, preferred dog size. Feeds directly into the admin panel as a lead with structured data.

**Why:** Currently the admin has to chase adopters for basic info. A form collects it upfront, saving admin time.

### 💡 Virtual or In-Person Meet Booking
Visitors can request a scheduled meeting (video call or in-person at the shelter) with a specific dog. Admin receives the request via Telegram and confirms. A simple calendar integration (Calendly or manual) handles scheduling.

**Why:** Bridges online discovery → real-world commitment. Meeting a dog is the highest-conversion step in adoption.

---

## Phase 3 Proposals (Community)

- **Dog-related business directory** (vets, groomers, pet shops on Koh Phangan)
- **Events calendar** (shelter fundraisers, adoption days, dog meetups)
- **Foster network** (list of active foster families + their dogs)
- **Community forum** (dog owners on the island)

---

## Feature → Problem Mapping

| Feature | Visibility | Funding | Matching | Ops |
|---------|-----------|---------|---------|-----|
| Public discovery page | ✅ | | ✅ | |
| AI chatbot | ✅ | | ✅ | |
| Donation link | | ✅ | | |
| Dog diary feed | ✅ | ✅ | | |
| Dog sponsorship | | ✅ | ✅ | |
| Instagram auto-post | ✅ | | | ✅ |
| Instagram chatbot | ✅ | ✅ | ✅ | |
| Adoption application | | | ✅ | ✅ |
| Virtual meet booking | | | ✅ | ✅ |
| Admin panel | | | | ✅ |
