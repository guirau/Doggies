# Doggies — Development Learnings

**Last Updated:** 2026-05-14
**Status:** Active — append entries as development progresses.

---

## Purpose

This file is a project memory. It records what went wrong, what was discovered by trial and error, and what the correct approach turned out to be — so the same mistake is never made twice and future sessions (human or AI) start with accumulated context.

**Rules for this file:**
- Record the root cause, not just the symptom.
- Record the fix, not just "it's fixed".
- Be specific: file paths, package versions, error messages, and commands matter.
- Do not record general programming advice — only lessons specific to this project and its stack.
- Keep entries short. One paragraph max per entry.

---

## How to Add an Entry

Copy this template and fill it in:

```
### [Short title describing what happened]
**Date:** YYYY-MM-DD
**Phase:** Phase 1 / Phase 2 / Phase 3 / Backlog
**Area:** e.g. Supabase · Next.js · Cloud Run · LangChain · CI/CD · Testing
**What happened:** [Symptom or discovery — what broke or surprised us]
**Root cause:** [Why it happened]
**Fix / correct approach:** [What to do instead — be specific]
```

---

## Learnings

> No entries yet — development has not started. The first entries will be added during Phase 1.

<!-- 
ENTRIES GO BELOW THIS LINE.
Keep them in reverse-chronological order (newest first) within each section.
-->

---

### Infrastructure & Deployment

<!-- Cloud Run, Vercel, GitHub Actions, Docker, CI/CD pipeline -->

---

### Database & Supabase

<!-- Schema, RLS policies, migrations, Supabase JS client, Storage, Auth -->

---

### Frontend — Next.js

<!-- App Router, SSR/SSG, data fetching, next/image, hydration, routing -->

---

### AI & LangChain

<!-- Claude Tool Use, grounding contract, prompt engineering, LangChain agent setup, SSE streaming -->

---

### Testing

<!-- Vitest, Playwright, test isolation, mock strategies, flaky tests -->

---

### DX & Tooling

<!-- TypeScript errors, ESLint, pnpm, build performance, local dev setup -->

---

### Security

<!-- RLS gaps found in practice, secret exposure incidents, CORS issues -->
