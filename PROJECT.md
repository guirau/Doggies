# PROJECT.md

Project-level configuration referenced by `CLAUDE.md`. This file answers the questions "what kind of project is this, what tools does it use, what conventions apply" so that the generic behavioral guidelines in `CLAUDE.md` can be specialized for this project.

## 1. Project shape

**Project type:** Web app with a separate frontend (Next.js on Vercel) and backend (FastAPI on Cloud Run), sharing a managed Supabase database. Includes an AI chatbot, a Telegram notification integration, and a Telegram admin agent (post-MVP).

**One-sentence description:** A dog shelter platform for Koh Phangan, Thailand, that lets local visitors discover and adopt dogs, gives the admin a dashboard and Telegram-based interface to manage the shelter, and uses an AI chatbot to qualify adopters.

**Deployment targets:**

* Frontend: Vercel (auto CI/CD via GitHub Actions on merge to `main`; preview deployments on every PR)
* Backend: Google Cloud Run (containerised FastAPI; CI/CD via GitHub Actions on merge to `main`) — MVP Phase 0.3+
* Other: N/A

## 2. Stack

**Backend (MVP Phase 0.3+):**

* Language: Python 3.12
* Framework: FastAPI
* Dependency file: `pyproject.toml` (package manager TBD when MVP Phase 0.3 begins)

**Frontend:**

* Framework: Next.js 15 (App Router, TypeScript)
* Styling: Tailwind CSS
* Package manager: pnpm

**Database / Auth / Storage:** Supabase (managed PostgreSQL + pgvector + Storage + Auth). Accessed from the frontend via the Supabase JS client (`@supabase/supabase-js`). Accessed from the backend via the Supabase Python client.

**Other key runtime dependencies:**

* LangChain + Anthropic Claude API — AI chatbot agent (MVP Phase 0.3+)
* Telegram Bot API — adoption intent notifications (MVP Phase 0.3) and admin agent (post-MVP)
* OpenAI Whisper API — voice transcription for Telegram admin agent (post-MVP)

## 3. External services (vendor list)

This list is referenced by the swap test in `CLAUDE.md` Section 6. Vendor SDK imports from these packages should only appear inside `adapters/` and `wiring/`.

| Service category          | Vendor                | Package name(s) to watch                                    | Phase    |
| ------------------------- | --------------------- | ----------------------------------------------------------- | -------- |
| LLM inference             | Anthropic Claude      | `anthropic`, `langchain-anthropic`                      | MVP Phase 0.3+ |
| Database / Auth / Storage | Supabase              | `@supabase/supabase-js` (frontend), `supabase` (Python) | MVP Phase 0.2+ |
| Notifications             | Telegram Bot API      | direct HTTP — no SDK; if adopted:`python-telegram-bot`   | MVP Phase 0.3+ |
| Voice transcription       | OpenAI Whisper API    | `openai`                                                  | Post-MVP |
| Payments                  | Stripe or Omise (TBD) | `stripe` or `omise`                                     | Post-MVP |
| Social posting            | Meta Graph API        | direct HTTP — no SDK                                       | Post-MVP |

If a vendor SDK import from any package in the "Package name(s) to watch" column appears outside `adapters/` or `wiring/`, the boundary is wrong. Stop and fix it.

## 4. Testing

**Test frameworks:**

* Frontend unit/integration: TBD — to be decided when MVP Phase 0.1 begins
* Backend unit/integration: pytest (Python standard; to be confirmed when MVP Phase 0.3 begins)
* End-to-end: Playwright (decided by project testing rules)

**Test commands:** TBD — fill in when MVP Phase 0.1 project is initialised.

**Coverage policy:** No percentage target. Each requirement ID in `REQUIREMENTS.md` must have at least one test that can confirm it passes. "Implemented" is not done; a passing test or verified Playwright check is done.

## 5. Planning documents

**PRD:** Yes — `docs/prd/features-proposal.md`

**Other planning documents:**

* `ROADMAP.md` — phased build order, deliverables, and done criteria per phase
* `REQUIREMENTS.md` — requirement IDs (INFRA-01, AUTH-01, …) with scope labels (v1 / v2 / out-of-scope); the primary reference for writing tests
* `docs/learnings.md` — project memory: root causes, fixes, and lessons from development (read this before starting any feature)
* `docs/architecture/system-overview.md` — high-level architecture, component responsibilities, key data flows
* `docs/architecture/data-model.md` — full entity definitions, field types, status machines, RLS notes
* `docs/architecture/ADR-001-tech-stack.md` — FastAPI + Next.js decision
* `docs/architecture/ADR-002-deployment.md` — Cloud Run + Vercel decision
* `docs/architecture/ADR-003-database.md` — Supabase decision
* `docs/architecture/ADR-004-ai-chatbot.md` — Claude Tool Use + grounding contract
* `docs/architecture/ADR-005-notifications.md` — Telegram for adoption alerts
* `docs/architecture/ADR-006-telegram-admin-agent.md` — voice-note admin agent (deferred, post-MVP)

## 6. Available skills

### Project-scope skills (`.claude/skills/`)

Source: [jeffallan/claude-skills](https://github.com/jeffallan/claude-skills)

Most relevant to this project:

| Skill                  | Purpose                                               |
| ---------------------- | ----------------------------------------------------- |
| `fastapi-expert`     | FastAPI patterns and best practices (MVP Phase 0.3 backend) |
| `nextjs-developer`   | Next.js App Router patterns (MVP Phase 0.1+)                |
| `typescript-pro`     | TypeScript patterns and idioms                        |
| `python-pro`         | Python patterns and idioms                            |
| `postgres-pro`       | PostgreSQL query and schema patterns                  |
| `react-expert`       | React component patterns                              |
| `playwright-expert`  | Playwright E2E test patterns                          |
| `api-designer`       | API contract design                                   |
| `database-optimizer` | Query optimisation                                    |
| `the-fool`           | Devil's advocate / challenge assumptions              |
| `code-documenter`    | Documentation generation                              |

Also installed (lower relevance for this project): `architecture-designer`, `cloud-architect`, `devops-engineer`, `javascript-pro`, `kubernetes-specialist`, `microservices-architect`, `ml-pipeline`, `rag-architect`, `react-native-expert`, `sql-pro`, `terraform-engineer`

#### Custom project skills

| Skill                | Purpose                                                                        |
| -------------------- | ------------------------------------------------------------------------------ |
| `tool-selection`  | Referenced by `CLAUDE.md` Section 5 — use before adding any core dependency |

---

### User-scope skills

These are installed at the user level and available across all projects.

**Superpowers** — [obra/superpowers](https://github.com/obra/superpowers)
Plan-and-execute workflow: `/write-plan`, `/execute-plan`, `/brainstorm`, git worktrees, code review, TDD, systematic debugging, subagent-driven development.

**Agent Skills** — [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills)
Development lifecycle skills: `spec-driven-development`, `planning-and-task-breakdown`, `incremental-implementation`, `test-driven-development`, `debugging-and-error-recovery`, `code-review-and-quality`, `frontend-ui-engineering`, `api-and-interface-design`, `git-workflow-and-versioning`, `documentation-and-adrs`, `shipping-and-launch`, and others. See the skill discovery flowchart in the `using-agent-skills` meta-skill.

## 7. Available agents

Project-scope agents live in `.claude/agents/`. Each runs as a sub-agent with its own model and focused scope.

| Agent             | Model  | Purpose                                                                                                        | When to use                                                                                                                           |
| ----------------- | ------ | -------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `planner`       | Opus   | Interrogates requirements via `AskUserQuestion`, then produces an agent-optimised PRD at `docs/prd/prd.md` | Scoping a new v2 backlog feature that only has a stub in `REQUIREMENTS.md`. Not needed for MVP — planning artifacts already exist. |
| `code-refactor` | Sonnet | Refactors existing code for clarity, dead-code removal, and type tightening without changing behaviour         | After a feature is complete and passing tests, to clean up shape without altering logic.                                              |

**Notes:**

- `code-refactor` verifies with `pnpm build` / `pnpm lint` / `pnpm test` — update the agent file once the project is initialised if the commands differ.
- `planner` outputs to the hardcoded path `docs/prd/prd.md`. If used for multiple features, rename the output file per feature after generation to avoid overwrites.
- `planner`'s "be ambitious about scope" instruction conflicts with CLAUDE.md Section 3 (YAGNI). Treat its scope suggestions as options to evaluate, not directives to implement.

---

## 8. Conventions

**Code style:**

* TypeScript/frontend: Prettier + ESLint (configuration TBD when MVP Phase 0.1 begins)
* Python/backend: Black + Ruff (configuration TBD when MVP Phase 0.3 begins)

**Commit message style:** Conventional Commits — types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

**Branch strategy:** GitHub Flow — trunk is `main`; feature work in branches; merge via PR; deploy on merge to `main`

**Other project-specific conventions:**

* All dates stored and displayed in ISO 8601 (`YYYY-MM-DD`)
* All third-party SDK imports must appear only inside `adapters/` or `wiring/` modules (see CLAUDE.md Section 6 swap test)
* Vendor SDK selection for core services (LLM, payments, social) goes through the user before adoption — do not add unilaterally
* Dog status transitions must follow the state machine in `docs/architecture/data-model.md`; invalid transitions rejected at the application layer
* The Supabase `SERVICE_ROLE_KEY` is server-side only; never expose to the browser
* All secrets via environment variables or Cloud Run Secret Manager; never in source code or build logs

## 9. Out of scope (for the current stage)

* **Community features** — business directory, events calendar, foster network listing, community forum (Horizon 3; see REQUIREMENTS.md)
* **International adoption** — transport and regulatory complexity excluded from all phases
* **Mobile apps** — web only
* **Multi-admin / role management** — single admin account for all MVP phases; Supabase Auth handles one user
* **Payment processing** — no payment SDK or payment credential storage until post-MVP (v2)
* **RAG / vector semantic search** — pgvector column exists but is unused in v1; semantic search deferred to Phase 2 backlog if corpus grows beyond ~300 dogs
* **LangGraph** — overkill for MVP chatbot; LangChain is sufficient; revisit if agent state complexity warrants it
* **LINE / WhatsApp notifications** — Telegram only for MVP; LINE (Thailand-dominant) deferred to Phase 2

---

**This file should be updated when:** a new external service is added to the vendor list, the stack changes, a "currently out of scope" item moves into scope, test frameworks are chosen, or a new skill is installed.
