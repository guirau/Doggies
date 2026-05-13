# PROJECT.md

Project-level configuration referenced by `CLAUDE.md`. This file answers the questions "what kind of project is this, what tools does it use, what conventions apply" so that the generic behavioral guidelines in `CLAUDE.md` can be specialized for this project.

Fill in each section. Leave a section blank or write "N/A" if it does not apply.

## 1. Project shape

**Project type:** [e.g., web app with separate frontend and backend, CLI tool, library, data pipeline, bot, etc.]

**One-sentence description:** [what this project does and for whom]

**Deployment targets:**

* Frontend: [e.g., Vercel, Netlify, N/A]
* Backend: [e.g., Cloud Run, Fly, VPS, N/A]
* Other: [e.g., Cloudflare Workers for cron, N/A]

## 2. Stack

**Backend:**

* Language: [e.g., Python 3.12, Node 20, Go 1.22]
* Framework: [e.g., FastAPI, Express, Fiber]
* Database: [e.g., Supabase Postgres, self-hosted Postgres, SQLite]

**Frontend (if applicable):**

* Framework: [e.g., Next.js, Remix, SvelteKit]
* Styling: [e.g., Tailwind, vanilla CSS]

**Other key runtime dependencies:** [anything else core to how the app runs]

## 3. External services (vendor list)

This list is referenced by the swap test in `CLAUDE.md` Section 6. Vendor SDK imports from these packages should only appear inside `adapters/` and `wiring/`.

| Service category      | Vendor                 | Package name(s) to watch |
| --------------------- | ---------------------- | ------------------------ |
| [e.g., LLM]           | [e.g., Anthropic]      | [e.g.,`anthropic`]     |
| [e.g., Transcription] | [e.g., OpenAI Whisper] | [e.g.,`openai`]        |
| [e.g., Database]      | [e.g., Supabase]       | [e.g.,`supabase`]      |
| [e.g., Payments]      | [e.g., Stripe]         | [e.g.,`stripe`]        |
| ...                   | ...                    | ...                      |

If a vendor SDK import from any package in the rightmost column appears outside `adapters/` or `wiring/`, the boundary is wrong. Stop and fix it.

## 4. Testing

**Test frameworks:**

* Unit: [e.g., pytest, vitest, jest]
* Integration: [e.g., pytest with test client, supertest]
* End-to-end: [e.g., Playwright, Cypress, N/A]

**Test commands:**

* Run all tests: [e.g., `pytest`, `npm test`]
* Run unit tests only: [e.g., `pytest tests/unit`, `npm run test:unit`]
* Run a single test: [e.g., `pytest tests/unit/test_foo.py::test_bar`]

**Coverage policy:** [e.g., no percentage target, each acceptance criterion has at least one test, or specify a target if the project has one]

## 5. Planning documents

**Does this project have a PRD?** [yes / no / N/A]

* If yes, location: [e.g., `docs/PRD.md`, Notion link]

**Other planning documents:**

* [e.g., `docs/architecture/decisions/` for ADRs]
* [e.g., `ROADMAP.md`]

## 6. Available skills

Skills installed and available to Claude for this project (these affect which rules in `CLAUDE.md` apply with their preferred procedure, vs. falling back to defaults):

* [ ] `tool-selection` — referenced by `CLAUDE.md` Section 5
* [ ] [other skill name] — [what it does]

Check the boxes for skills that are actually installed. If a skill is not installed, `CLAUDE.md` will fall back to a sensible default.

## 7. Conventions

**Code style:** [e.g., Black + Ruff for Python, Prettier + ESLint for TypeScript, or "match existing"]

**Commit message style:** [e.g., Conventional Commits, free-form, or "match existing"]

**Branch strategy:** [e.g., trunk-based, GitHub Flow, GitFlow]

**Other project-specific conventions:**

* [e.g., "no em dashes in user-facing copy"]
* [e.g., "all dates in ISO 8601"]
* [e.g., "all log lines structured JSON"]

## 8. Out of scope (for the current stage)

Things that are deliberately not being built or used yet. Listing these here prevents Claude from suggesting them or planning around them.

* [e.g., "Multi-tenancy - single-tenant for now"]
* [e.g., "Internationalization - English only for now"]
* [e.g., "Mobile apps - web only for now"]

---

**This file should be updated when:** new external services are added, the stack changes, a new skill is installed, or a "currently out of scope" item moves into scope.
