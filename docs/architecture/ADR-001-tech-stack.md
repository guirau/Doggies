# ADR-001: Primary Technology Stack

## Status
Accepted

## Context
Doggies needs a web frontend for public visitors and a backend capable of serving data, handling media uploads, and running AI agents. The solo developer has explicit preferences: Python for backend, Next.js for frontend, and a preference for well-known OSS/SaaS solutions with minimal custom code.

## Decision
- **Backend:** FastAPI (Python 3.12)
- **Frontend:** Next.js 15 with App Router (TypeScript)
- **AI Agents:** LangChain + Anthropic Claude API (Python, inside the backend)

## Alternatives Considered

**Backend alternatives:**
- **Django + DRF** — batteries-included, better admin out of the box, but heavier and slower iteration speed for an API-first app. FastAPI's async support is better suited for streaming AI responses.
- **Next.js API Routes only** — would eliminate the Python backend entirely, keeping everything on Vercel. Rejected because the developer plans to build Python AI agents — maintaining two languages for backend logic (TypeScript API routes + Python AI) is worse than one Python backend.
- **Node.js (Express/Hono)** — faster cold starts, but conflicts with the developer's Python preference and AI agent requirements.

**Frontend alternatives:**
- **Remix** — good DX but smaller ecosystem; Next.js has better Vercel integration, larger community, and more documented patterns.
- **SvelteKit** — excellent performance, but the developer's stack is TypeScript/React-oriented and the community is smaller for complex AI UIs.

**AI Agent framework alternatives:**
- **LangGraph** — better for complex stateful agents; overkill for MVP chatbot. Can migrate later.
- **Raw Claude API** — viable for simple cases, but LangChain's tool-use abstractions reduce boilerplate for structured DB queries.
- **OpenAI Agents SDK** — locked to OpenAI. Rejected given Claude is the chosen model.

## Consequences
- **Positive:** Python backend aligns with AI agent development; FastAPI async support handles streaming chat responses without blocking; Next.js App Router with React Server Components gives excellent SEO for public dog profiles.
- **Negative:** Two deployment targets (Vercel + Cloud Run) add operational surface area. A solo developer must maintain two runtimes.

## Trade-offs
Developer velocity and AI alignment (Python) are prioritised over operational simplicity (single platform). The split is acceptable because Vercel and Cloud Run are both managed services with minimal DevOps burden.

## Most Likely Failure Mode
LangChain abstraction leaks at scale — tool schemas evolve and LangChain's version compatibility can be brittle. Mitigation: pin versions in `pyproject.toml`; keep tool definitions thin and testable.
