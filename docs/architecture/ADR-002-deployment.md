# ADR-002: Deployment — Cloud Run (Backend) + Vercel (Frontend)

## Status
Accepted

## Context
The backend is Python (FastAPI) and the frontend is Next.js. The developer wants to deploy on Vercel, but Vercel's Python serverless support has hard limits (250MB bundle, 60s max execution, no persistent connections, cold starts on every request). AI agent calls to Claude can take 5–30 seconds and may stream; this is incompatible with Vercel's Python function model.

## Decision
- **Frontend (Next.js):** Vercel — zero-config, preview deployments per PR, automatic CDN, Next.js-optimised.
- **Backend (FastAPI):** Google Cloud Run — containerised, scales to zero, supports long-running requests (up to 3600s), persistent connections, and streaming responses via Server-Sent Events.

## Alternatives Considered

**Backend hosting alternatives:**
- **Vercel Python Serverless** — honors "Vercel only" preference, but 60s timeout kills AI streaming; cold starts hurt chatbot UX; 250MB bundle limit is tight with LangChain. Rejected.
- **Railway** — simplest Docker deployment for a solo dev, $5/mo starter. Good alternative if Google Cloud is too complex to set up initially. Keep as fallback.
- **Fly.io** — similar to Railway, global edge deployments. More complex networking than Cloud Run.
- **Cloud Run** (chosen) — native GCP, Docker-native, pay-per-request, integrates cleanly with Secret Manager, Cloud Storage, and Artifact Registry if needed.

**Frontend hosting alternatives:**
- **Cloud Run (Next.js container)** — keeps everything on GCP, but loses Vercel's automatic preview deployments, image optimisation CDN, and Next.js-specific build pipeline. Not worth the trade.

## Consequences
- **Positive:** Cloud Run handles streaming without timeout; scales to zero (free when idle, important for a shelter with low traffic); Docker container isolates Python environment cleanly. Vercel handles CDN, image optimisation, and preview deployments for free.
- **Negative:** Two platforms to manage. Cloud Run requires a `Dockerfile` and Artifact Registry or Cloud Build for deployments. Adds ~15 minutes of initial setup.

## Trade-offs
Operational correctness (AI streaming works) is prioritised over platform simplicity (single provider). Cloud Run's managed nature keeps operational burden low for a solo developer.

## Deployment Configuration Notes
- Cloud Run: min instances = 0 (scale to zero), max instances = 3 for MVP; 2 vCPU, 2GB RAM per container.
- Environment variables via Cloud Run secrets or Secret Manager — never baked into the image.
- Vercel: production branch = `main`, preview deployments on all PRs, `NEXT_PUBLIC_API_URL` points to Cloud Run service URL.

## Most Likely Failure Mode
Cold start latency on Cloud Run (scale from 0 → 1 can take 2–5s). Mitigation: set min-instances=1 during active hours via Cloud Scheduler, or accept the cold start for a low-traffic MVP.
