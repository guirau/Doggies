# Doggies

A web platform for a dog shelter on Koh Phangan, Thailand, focused on increasing adoptions and donations.

## What it does

The shelter receives a steady stream of street dogs and runs almost entirely on donations and one admin's time. Doggies addresses four problems at once:

- **Visibility** — a public discovery page so adopters can see which dogs need homes
- **Matching** — an AI chatbot that answers natural-language questions about specific dogs
- **Admin load** — a dashboard for managing dog profiles, media, and status updates
- **Engagement** — diary-style updates today; Telegram and Instagram integrations later

## Status

Pre-development. Planning is complete; the first MVP phase (frontend shell) is the next build.

See `ROADMAP.md` for the phased build order, `REQUIREMENTS.md` for scoped requirement IDs, and `docs/architecture/` for the technical decisions made so far.

## Stack

- **Frontend:** Next.js 15 (App Router, TypeScript) + Tailwind CSS — deployed to Vercel
- **Backend:** FastAPI (Python 3.12) — deployed to Google Cloud Run (from MVP Phase 0.3)
- **Database / Auth / Storage:** Supabase (managed PostgreSQL + pgvector)
- **AI:** LangChain + Anthropic Claude (Claude Tool Use, not RAG, for the MVP chatbot)
- **Notifications:** Telegram Bot API
