# 🐶 Doggies: Development Workflow

## Integrations

| Tool                      | Scope   | Role                                                               |
| ------------------------- | ------- | ------------------------------------------------------------------ |
| **Superpowers v5+** | project | Brainstorming, planning, TDD execution, code review, branch finish |
| **ECC**             | global  | Code review (TypeScript, Python, security, database)               |
| **Templates**       | project | Agents + rules from templates                                      |
| **GitHub**          | CI/CD   | PR workflow, Actions for type-check + lint + tests                 |
| **Vercel**          | CI/CD   | Auto-deploy `staging` to staging, `main` to production         |
| **ECC Memory**      | global  | Cross-session continuity via `ecc:save-session`                  |

---

## Workflow Overview

```mermaid
flowchart TD

    P1["PHASE 1 — PRD
     Written manually (or via brainstorming)
     → docs/prd/prd.md"]

    P2["PHASE 2 — Project Initialization
      CLAUDE.md + Templates + git + CI
     → CLAUDE.md references PRD, REQUIREMENTS, FEATURES"]

    subgraph loop["PHASE 3 — Feature Loop ↺ per feature"]
        S1["1. Brainstorm
         'I want to build &ltfeature&gt'
         → docs/superpowers/specs/YYYY-MM-DD-<feature>-design.md"]

        S2["2. Plan
         'Write the plan'
         → docs/superpowers/plans/YYYY-MM-DD-<feature>.md
         + spec-review subagent"]

        S3["3. Execute (subagent-driven, TDD)
         'Go' / 'Execute the plan'
         → code + tests, inter-task code review auto-runs"]

        S3b["3b. Structural Refactor (optional)
         'Run the code-refactor agent'"]

        S4["4. Verify
         verification-before-completion
         (auto-runs after executing the plan, or
	 re-run after refactoring with 'Verify the feature')
         → evidence of passing tests"]

        S5["5. Review (optional, domain-specific)
         ecc:python-reviewer / typescript-reviewer /
         security-reviewer / database-reviewer..."]

        S6["6. Ship to staging
         finishing-a-development-branch
         → PR (feature/* → staging) → Vercel preview → merge"]

        S1 --> S2 --> S3 --> S3b --> S4 --> S5 --> S6
    end

    P4["PHASE 4 — Release
     PR (staging → main) → full E2E on staging → merge → smoke test prod
     → tagged release, production live"]

    P1 --> P2 --> S1
    S6 -->|"next feature"| S1
    S6 -->|"ready to ship"| P4
    P4 -->|"next cycle"| S1
```

---

## PHASE 1 — PRD *(once per project)*

**Purpose:** Define what the product is at a level that won't churn weekly. The PRD answers "what and why"; it's a reference, not a contract.

**How to create it:** two options.

**Option A (recommended for Doggies):** write it yourself. PRDs are short, you have the product vision, and the Socratic back-and-forth is overkill for something this size. Put it at `docs/prd/prd.md`.

**Option B (best automated option): invoke the Planner agent.** Say:

> *"Run the planner agent."*

The `planner` agent from `.claude/agents/planner.md` runs a structured Socratic discovery loop using `AskUserQuestion` — it won't stop asking until *you* say you're satisfied. It then generates a comprehensive, agent-optimized PRD at `docs/prd/prd.md` with:

* Structured user stories with hard-threshold acceptance criteria
* Data model and API endpoint specs
* UI/UX screen map with loading/empty/error states
* Sprint contracts (each task has an explicit "done" condition)
* Evaluation criteria (what an evaluator agent would grade against)
* Open questions

This is the right option when the product vision is still forming or when you want a PRD an AI coding agent can consume without ambiguity. The output is considerably more detailed than what Superpowers brainstorming produces.

**Option C:** invoke Superpowers' brainstorming skill for a lighter-touch project-level topic. Say:

> *"I want to brainstorm the PRD for Doggies."*

The `brainstorming` skill asks one question at a time, proposes options, and writes the output to `docs/superpowers/specs/YYYY-MM-DD-doggies-prd-design.md`. Move that to `docs/prd/prd.md` after review. Less structured than Option B, but faster for a product you already understand well.

Either way, the PRD should contain at minimum:

* Problem & users
* Core value (one sentence)
* Core flows (the 3–5 things users do)
* Data model (entities + relationships, not schemas)
* Non-goals (what the product is  *not* )
* Open questions

**Output:** `docs/prd/prd.md`

**Living doc rule:** PRD can change. Log meaningful changes somewhere visible — either in the PRD itself (changelog section) or in a `DECISIONS.md` at the repo root. When the PRD changes, ask: *does this invalidate shipped features?* If yes, either remove/migrate the feature or the PRD change is wrong.

---

## PHASE 2 — Project Initialization *(once per project)*

**Purpose:** Scaffold the project — template agents/rules, git branches, CI, deploys, and the CLAUDE.md that wires Superpowers to your project context. Everything here is one-time setup.

### 2a. Install Superpowers

```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

Quit and restart Claude Code. Verify with `/help` — you should see Superpowers skills listed (though most of them auto-trigger, so you won't invoke them directly).

### 2b. Template Integration

**Purpose:** Drop in the agents and rules you've battle-tested in prior projects.

* **`code-refactor`** — Handles whole-feature structural cleanup after execution; Superpowers' inter-task review doesn't do this.
* **`planner`** — A Socratic PRD generation agent (Phase 1, once per project). It's *not* the same as Superpowers' `writing-plans` — that skill produces feature-level TDD execution plans, while `planner` produces a project-level PRD with evaluation criteria and sprint contracts. Different scope entirely.
* **`e2e-testing`** — TBD. E2E testing with Playwright

**Output:** `.claude/agents/*` `.claude/rules/*`

### 2c. Write CLAUDE.md

**Purpose:** This is the project contract. Superpowers v5+ explicitly instructs agents to prefer your CLAUDE.md over its own internal instructions.

Create `CLAUDE.md` at the repo root with these sections:

* **Mission + current status** — one paragraph each.
* **Stack + env vars + invariants** — the operating contract.
* **Build philosophy** — your Doggies-specific directives:
  * Preference order: OSS → free SaaS → paid SaaS → custom
  * Propose 2–3 options per feature; flag SaaS replacements (payments → Stripe, chat → Discord, etc.)
  * Custom is last resort and must be justified
* **TDD directive** — *"If about to write code without a failing test first, stop and write the test."* (Superpowers' `test-driven-development` skill enforces this anyway, but the redundancy is cheap.)
* **Reading order at session start** — tell Claude to read `docs/prd/prd.md`, `REQUIREMENTS.md`, and `FEATURES.md` before starting any brainstorm. Also include reference to any markdown memory files like `docs/progress.md` or `docs/learnings.md`

Optional sidecars (create only if you need them): [work on then in CLAUDE.md]

* **`REQUIREMENTS.md`** — REQ-IDs (`AUTH-01`, `PROF-02`), v1 scope + deferred v2 + out-of-scope. Superpowers doesn't auto-read this; CLAUDE.md must tell it to. Add this line to CLAUDE.md: *"Before brainstorming any feature, identify which REQ-IDs from REQUIREMENTS.md this feature satisfies. The spec doc must list them under a `Satisfies:` header."*
* **`FEATURES.md`** — flat list of features with status (`not-started` / `spec'd` / `planned` / `executing` / `shipped`) and assigned REQ-IDs. Replaces GSD's ROADMAP.md. Update manually after each feature ships.

**What you're NOT creating:**

* `STATE.md` — Superpowers has no state-injection hook. The plan file's checkboxes are the state-across-sessions mechanism (unchecked boxes tell the next session where to resume). Good enough for a solo project.
* `.planning/research/*` — no auto-read equivalent. If you need research for a feature, either reference it manually during brainstorming (`"read docs/research/pgvector.md before we design this"`) or write a tiny custom skill that auto-loads a research directory. For Doggies the stack is known, so this is unlikely to matter.

### 2d. Git Branch Structure

**Purpose:** Two-environment deploy model — `staging` is the staging branch, `main` is production.

```bash
git checkout -b staging main
git push -u origin staging
```

**Branches:**

* `main` — production, protected, tagged releases
* `staging` — integration + staging deploy (auto-deploys to Vercel staging)
* `feature/*` — per-feature, created from `staging`, merged back to `staging`

Superpowers' `finishing-a-development-branch` skill integrates with this model — it handles PR creation and worktree cleanup when you're done with a feature.

### 2e. CI + Vercel Setup

**Purpose:** Automated safety net. Superpowers generates standard code + tests, works with any CI.

**GitHub Actions** — create `.github/workflows/ci.yml`:

* On PR to `staging`: type-check, lint, unit + integration tests
* On PR to `main`: all of the above + E2E against Vercel staging URL
* Block merge on red

**Vercel:**

* Connect repo
* Set `staging` branch → staging environment
* Set `main` branch → production environment
* Preview deployments auto-generated for every PR

**Output:** `.github/workflows/ci.yml`, Vercel project configured

### 2f. Memory Path Fix (ECC)

Pin ECC memory to a stable location.

**Option A — Per-project (recommended):**

```json
{ "MEMORY_FILE_PATH": "/Users/guirau/GitHub/guirau/Experiments/Doggies/.claude/memory.jsonl" }
```

in `settings.local.json`.

**Option B — Global shared memory:**

```json
{ "MEMORY_FILE_PATH": "/Users/guirau/.claude/memory.jsonl" }
```

in `~/.claude/settings.json`.

`ecc:save-session` (at session end) is what actually writes. Superpowers itself has no memory system in the core plugin — if you want cross-session recall of past conversations, there's a separate `episodic-memory` plugin from the same author. Don't install it yet; start with ECC-only and see if you miss anything.

---

## PHASE 3 — Feature Development Loop *(repeat per feature)*

**Purpose:** Build each feature with consistent discipline — brainstorm a spec, generate a TDD plan, execute via subagents with inter-task review, verify, ship to staging.

### Step 1 — Brainstorm the feature

**Purpose:** Produce a design spec Superpowers can plan from.

**How to trigger:** just describe the feature in natural language.

> *"I want to build the visit-booking feature — adopters pick a time slot from available Google Calendar windows and the bot confirms with the shelter."*

The `using-superpowers` meta-skill detects feature intent and auto-triggers the `brainstorming` skill. It will:

1. Explore project context (reads CLAUDE.md, and anything CLAUDE.md tells it to read).
2. Ask clarifying questions one at a time, multiple-choice where possible.
3. Propose 2–3 approaches (your build-philosophy directive in CLAUDE.md reinforces this — OSS → free SaaS → paid SaaS → custom).
4. Present the design in sections for your approval.
5. Write the spec to `docs/superpowers/specs/YYYY-MM-DD-<feature>-design.md`.
6. Run a spec-review subagent to catch `TBD`s, contradictions, ambiguity.
7. Ask you to review the file.

If you need to reference unfamiliar tech, tell Claude mid-brainstorm: *"Before we continue, search the Supabase pgvector docs and come back with the three main gotchas."* The brainstorming skill is fine with this.

If you've already written a detailed spec, just paste it into the conversation or say *"read docs/features/visit-booking-spec.md and use that as the starting point."* The brainstorming skill will refine it rather than ignore it.

**Output:** `docs/superpowers/specs/YYYY-MM-DD-<feature>-design.md` with sections for goal, architecture, tech stack, requirements (functional + non-functional), data model, API, non-goals, and (because your CLAUDE.md asks for it) a `Satisfies:` header listing REQ-IDs.

### Step 2 — Plan

**Purpose:** Break the feature into granular TDD tasks with a self-contained plan subagents can execute.

**How to trigger:** after approving the spec, say:

> *"Write the plan."*

The `writing-plans` skill takes over. It will:

1. Produce `docs/superpowers/plans/YYYY-MM-DD-<feature>.md` with each task broken into 2–5 minute steps.
2. Enforce the TDD structure — every task has  *Step 1: write the failing test* ,  *Step 2: verify it fails* ,  *Step 3: write minimal implementation* , etc. No implementation step without a preceding test step.
3. Include a "File Structure" section (v5+) deciding which files exist and what each owns.
4. Run a spec-review subagent one more time against the plan itself, checking for placeholders, type inconsistencies, missing spec coverage.

**Feature branch:** Superpowers prefers git worktrees per feature (the brainstorming skill may offer to create one). If you'd rather stay in a traditional feature branch:

```bash
git checkout -b feature/<feature-name> staging
```

**Your job:** skim the plan before executing. Check that every acceptance criterion from the spec has ≥1 test, API routes have integration tests, and the critical flows (adoption / donation / shelter onboarding / visit booking) have e2e tests. If something's missing, tell Claude to revise. Don't execute a half-baked plan.

**Output:** `docs/superpowers/plans/YYYY-MM-DD-<feature>.md`, feature branch (or worktree).

### Step 3 — Execute with TDD

**Purpose:** Build the feature. Tests first, code second. Subagent-driven so each task gets a fresh context.

**How to trigger:**

> *"Go."* *(or "Execute the plan.")*

`subagent-driven-development` auto-triggers (on Claude Code and Codex — platforms with subagent support). For each task:

1. A fresh subagent is dispatched with only the context it needs.
2. It writes the failing test (RED), verifies it fails, writes minimal code (GREEN), verifies it passes, refactors (IMPROVE), commits.
3. Between tasks, `requesting-code-review` runs automatically. Critical issues block progress until fixed.
4. The `test-driven-development` skill enforces red-green-refactor. If Claude tries to write code before a test, it deletes the code and starts over. Keep the CLAUDE.md TDD forcing line as belt-and-suspenders.

**Run tests locally in watch mode:** keep a terminal tab open with `npm test -- --watch`. Subagents run their own tests, but your watch mode catches things the minute they happen.

**Security checklist:** for auth, payment, or external API code, the executor subagent should consult `.claude/skills/backend-security/references/security-checklist.md` inline. Make sure CLAUDE.md has a line pointing to it: *"For auth/payment/external-API code, consult `.claude/skills/backend-security/references/security-checklist.md` during execution, not as a separate step."*

**Your job during execution:** you can largely step away for 30–120 minutes, but check the inter-task code review output. If a critical finding blocks progress and the proposed fix looks wrong to you, intervene.

**Output:** working code + tests, commits on the feature branch, per-task code review trail.

### Step 3b — Structural Refactor *(optional)*

**Purpose:** Whole-feature cleanup pass after execution. The subagent executor refactors per-task — this catches structural issues only visible across the full diff.

**When to use:** after execution completes, skim the diff. If you see structural problems (long functions across tasks, duplicated logic, loose types), run this. If the code already looks tight, skip it.

**How to invoke:**

> *"Run the code-refactor agent."*

Same sub-agent mechanism as before. Lives in `.claude/agents/code-refactor.md`.

The agent:

* Renames confusing identifiers, flattens nested conditionals, splits long functions
* Extracts shared logic only when it appears 3+ times
* Tightens loose `any`/`unknown` types — never widens
* Removes dead code (unused imports, unreachable branches)
* Runs `npm run build` → `npm run lint` → tests after each batch — stops if anything breaks
* Stops and reports if more than 5 files need touching (run in batches by area for large features)

**Hard rule:** no behavior changes, no bug fixes, no new features in a refactor pass. If a bug is spotted mid-refactor, note it and stop.

**After the refactor:** verification does not auto-re-run. Manually trigger it — say *"Verify the feature."* This is the Step 4 run that actually counts before moving to review.

### Step 4 — Verify

**Purpose:** Evidence-based check that the feature actually works before declaring completion.

**How it triggers:** Two scenarios:

* **After Execute (Step 3):** `verification-before-completion` auto-runs after the last task in the plan completes — no command needed.
* **After Refactor (Step 3b):** verification does *not* re-run automatically. Say *"Verify the feature."* to trigger it manually before moving on.

In both cases it requires concrete evidence — running the actual verification commands from the plan, not claims.

If you want an explicit coverage gap check, either:

* Write a task into the plan itself that runs coverage and lists gaps, or
* Tell Claude: *"Run the coverage report and identify missing test cases against the spec's must/mustn't requirements."*

**Output:** verification report with evidence (test outputs, coverage %, etc.).

### Step 5 — Domain Review *(optional)*

**Purpose:** Superpowers' inter-task code review handles plan-level quality. ECC reviewers handle domain-specific concerns Superpowers doesn't know about — TypeScript idioms, Python idioms, security, database.

**Commands (pick what applies):**

| Changed                                | Reviewer                    |
| -------------------------------------- | --------------------------- |
| Any TS/JS code                         | `ecc:typescript-reviewer` |
| Any Python code                        | `ecc:python-reviewer`     |
| Auth, sessions, tokens, user data      | +`ecc:security-reviewer`  |
| Payment flows, API keys, webhooks      | +`ecc:security-reviewer`  |
| External API calls                     | +`ecc:security-reviewer`  |
| DB schema, migrations, complex queries | +`ecc:database-reviewer`  |
| Trivial (copy fix, config tweak)       | skip review                 |

**Action:** fix all CRITICAL findings. Consider HIGH findings. Note MEDIUM/LOW.

### Step 6 — Ship to Dev

**Purpose:** Merge the feature branch to `staging`. This is a PR from `feature/<name>` to `staging`. CI and Vercel handle the rest.

**How to trigger:** after verification and review pass, say:

> *"Finish the branch"* *(or "Wrap up this feature".)*

The `finishing-a-development-branch` skill auto-triggers. It:

1. Runs the full test suite one more time.
2. Offers options: merge locally, open a PR, keep working, or discard the branch.
3. If you choose PR, creates it and cleans up the worktree.

Pick **open a PR**. Target `--base staging`.

* GitHub Actions runs: type-check + lint + tests
* Vercel generates preview URL for visual check
* Merge to `staging` on green

Then persist ECC session memory:

```
ecc:save-session
```

**Output:** merged feature, Vercel preview URL, session memory saved.

### Step 7 — Archive

**Purpose:** Keep `docs/superpowers/specs/` and `/plans/` as a historical record. Nothing to do — files stay where Superpowers wrote them, dated by creation day. No archiving step needed. Update `FEATURES.md` to mark the feature as `shipped`.

---

## PHASE 4 — Release *(staging → main)*

**Purpose:** Ship accumulated features in `staging` to production, with full E2E safety check.

```bash
gh pr create --base main --head staging
```

* GitHub Actions runs full suite including E2E against `staging`'s Vercel staging URL
* If red: fix on a feature branch, re-merge to `staging`, re-test
* If green: merge to `main`

```bash
git tag v<version>
git push origin v<version>
```

* Vercel auto-deploys `main` to production
* Smoke test the production URL (critical paths manually)

**Output:** tagged release, live production deployment.

---

## Evolving the Roadmap

**This is the biggest honest loss vs. GSD.** GSD had a rich roadmap-evolution command set (`/gsd-add-phase`, `/gsd-insert-phase`, `/gsd-add-backlog`, `/gsd-review-backlog`, `/gsd-new-milestone`). Superpowers has none of this. The roadmap is whatever you maintain in `FEATURES.md`, and you update it by hand.

What to do instead:

| GSD behavior                                | Superpowers equivalent                                          |
| ------------------------------------------- | --------------------------------------------------------------- |
| `/gsd-add-phase <description>`            | Add a line to `FEATURES.md` under current milestone           |
| `/gsd-insert-phase <after> <description>` | Add a line to `FEATURES.md` in the right position             |
| `/gsd-add-backlog <description>`          | Add a line to `FEATURES.md` under a `## Backlog` section    |
| `/gsd-review-backlog`                     | Open `FEATURES.md`, read the Backlog section, decide for each |
| `/gsd-new-milestone <n>`                  | Add a `## Milestone N` section to `FEATURES.md`             |
| Promoting a backlog item to next feature    | Move the line from `## Backlog` to the current milestone      |

**Recommended habit:** capture every feature idea as a Backlog entry in `FEATURES.md` the moment it comes up. At milestone end, triage the Backlog section. Simple and works.

**If this friction annoys you after a few weeks:** write a small custom slash command `/features-add <description>` that appends to `FEATURES.md`. Superpowers supports custom slash commands alongside its own — put them in `.claude/commands/`. But start with manual edits; the overhead is smaller than you think.

---

## Continuous Practices

| Practice           | When                                                  | Tool / Action                                                               |
| ------------------ | ----------------------------------------------------- | --------------------------------------------------------------------------- |
| Tests in watch     | While coding (every feature)                          | `npm test -- --watch` (or equiv)                                          |
| Session memory     | End of every session                                  | `ecc:save-session`                                                        |
| FEATURES.md update | After each feature ships                              | Mark feature as `shipped`, update milestone progress                      |
| CLAUDE.md update   | When a project-level decision changes                 | Edit directly — it's the project contract                                  |
| PRD update         | When product vision shifts (rare)                     | Edit `docs/prd/prd.md` + log change                                       |
| Progress check     | Any time                                              | Read `FEATURES.md` + unchecked boxes in the active plan file              |
| Dead code cleanup  | End of milestone (or when the codebase feels bloated) | `refactor-clean`skill (if installed) — or*"Run the code-refactor agent"* |

---

## Essential Documents

**Product layer** (written once, updated rarely):

* `docs/prd/prd.md`

**Project layer** (you maintain):

* `CLAUDE.md` — project contract + reading order for Claude at session start
* `REQUIREMENTS.md` — REQ-IDs, v1/v2/out-of-scope (optional, recommended)
* `FEATURES.md` — feature list with status (replaces GSD's ROADMAP.md + STATE.md)

**Feature layer** (Superpowers-generated, one per feature):

* `docs/superpowers/specs/YYYY-MM-DD-<feature>-design.md` — the design spec
* `docs/superpowers/plans/YYYY-MM-DD-<feature>.md` — the TDD plan with checkboxes (also serves as session-resume state)

**Scaffolding** (static):

* `.claude/agents/code-refactor.md` — structural refactor pass (Step 3b)
* `.claude/agents/planner.md` — Socratic PRD generator (Phase 1, Option B)
* `.claude/rules/*`
* `.claude/skills/backend-security/references/security-checklist.md`
* `.github/workflows/ci.yml`

---

## Command & Trigger Summary

**Once per project:**

```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

Then write `CLAUDE.md`, `REQUIREMENTS.md`, `FEATURES.md`, `docs/prd/prd.md` by hand.

**Per feature** (mostly natural-language triggers, not slash commands):

| Step          | How to trigger                                           | What runs                                    |
| ------------- | -------------------------------------------------------- | -------------------------------------------- |
| 1. Brainstorm | *"I want to build `<feature>`."*                     | `brainstorming`skill auto-triggers         |
| 2. Plan       | *"Write the plan."*                                    | `writing-plans`skill auto-triggers         |
| 3. Execute    | *"Go."*/*"Execute the plan."*                        | `subagent-driven-development`auto-triggers |
| 3b. Refactor  | *"Run the code-refactor agent."*                       | Your custom agent                            |
| 4. Verify     | *(automatic after last task)*                          | `verification-before-completion`           |
| 5. Review     | `ecc:typescript-reviewer` *(+ others as needed)*     | ECC                                          |
| 6. Ship       | *"Finish the branch."* *(then `ecc:save-session`)* | `finishing-a-development-branch`           |

**End of session:**

```
ecc:save-session
```

**Release:**

```
gh pr create --base main --head staging
git tag v<version>
```

---

## Superpowers Skills Reference

The core `obra/superpowers` plugin ships 14 skills, grouped here by where they fire in the workflow.

### Meta / orchestration

**1. `using-superpowers`** — The bootstrap meta-skill. Loaded at session start. Enforces the "if there's even a 1% chance a skill applies, invoke it" rule, announces which skill is being used, and maintains the instruction-priority order (your CLAUDE.md > Superpowers skills > default behavior). This is what makes all the other skills auto-trigger.

**2. `writing-skills`** — Skill for writing new skills. Applies TDD to documentation: write pressure-test scenarios, watch them fail, write the skill, verify it passes. You'd use this when building your own custom skills.

### Design and planning

**3. `brainstorming`** — Socratic requirements clarification. Triggers before any code. Asks one question at a time, proposes 2–3 approaches, presents design in reviewable sections, writes the spec to `docs/superpowers/specs/`, then runs a spec-review subagent. Hard gate: no implementation until the spec is approved.

**4. `writing-plans`** — Converts an approved spec into an executable TDD plan. Breaks work into 2–5 minute tasks, each with exact file paths and a failing-test-first structure. Requires a "File Structure" section before task decomposition. Runs a plan-review subagent to catch TBDs and inconsistencies.

### Execution

**5. `using-git-worktrees`** — Creates an isolated workspace on a new branch after design approval, runs project setup, verifies a clean test baseline. This is what gives you per-feature isolation without context cross-contamination.

**6. `subagent-driven-development`** — The preferred execution mode on platforms with subagent support (Claude Code, Codex). Dispatches a fresh subagent per task with a two-stage review (spec compliance first, then code quality). This is where the main context stays lean and Haiku can be used for cheap implementation tasks.

**7. `executing-plans`** — Fallback execution mode for platforms without subagent support (Gemini CLI). Works through the plan batch-by-batch in a single session with human checkpoints. Less capable — the plugin actively tells you to upgrade to a subagent-capable harness if you can.

**8. `test-driven-development`** — Enforces red-green-refactor at the skill level. Write the failing test, watch it fail, write minimal code to pass, refactor, commit. If Claude tries to skip to implementation, this skill makes it delete the code and start over. Framework-agnostic — works for unit tests, integration tests, and E2E alike.

**9. `dispatching-parallel-agents`** — For running multiple independent tasks concurrently. Used within `subagent-driven-development` when the plan has tasks with no inter-dependencies. Each subagent gets only the context it needs, no shared pollution.

### Quality gates

**10. `requesting-code-review`** — Runs automatically between tasks during execution. Dispatches a specialized `code-reviewer` agent that grades the work by severity: critical issues block progress, high warrant attention, medium/low are noted. Not invoked by you — it's part of the execution loop.

**11. `receiving-code-review`** — The flip side. When a subagent gets a code review, this skill tells it how to process the findings — what to fix immediately, what to escalate, how to respond to disputed feedback. Keeps the review loop productive rather than endless.

**12. `systematic-debugging`** — Four-phase methodology: root cause investigation, pattern analysis, hypothesis testing, implementation. No guessing, no trial-and-error fixes. Triggers architectural review after three failed fix attempts. Fires when bugs appear during execution or when you explicitly describe a bug.

**13. `verification-before-completion`** — The final gate. Before declaring work done, require concrete evidence: actual test runs, actual command outputs, not claims. Auto-triggers after the last task in a plan completes. Replaces the "looks good to me" failure mode.

### Finishing

**14. `finishing-a-development-branch`** — Runs the full test suite one more time, then offers: merge locally, open a PR, keep working, or discard the branch. Handles worktree cleanup automatically.

---

### How they chain together

```
using-superpowers (always on)
  └─> brainstorming
       └─> using-git-worktrees
            └─> writing-plans
                 └─> subagent-driven-development
                      ├─> test-driven-development (per task)
                      ├─> systematic-debugging (on bugs)
                      ├─> requesting-code-review (between tasks)
                      └─> receiving-code-review (subagent side)
                           └─> verification-before-completion
                                └─> finishing-a-development-branch
```

`dispatching-parallel-agents` slots in as a helper wherever parallelism makes sense, and `writing-skills` is meta — you only use it when you're authoring a new skill of your own.

### What's NOT included

No PRD skill, no research skill, no roadmap skill, no E2E skill, no memory skill, no refactor skill. That's the honest scope of the core plugin — it's a software engineering methodology, not a project management or testing framework. Everything outside that scope lives alongside Superpowers, not inside it.

---

## What Changed vs. v1 (GSD)

**Lost:**

* Roadmap evolution commands — replaced by manual edits to FEATURES.md. -> maybe its a good idea to create a ROADMAP.md file like that of GSD
* Auto-loaded `research/` — reference research manually during brainstorming, or write a custom skill. -> Maybe it's a good idea to have a research skill?

**Net assessment:** for a solo-dev feature-shaped project like Doggies, the gains outweigh the losses. The one thing worth custom-building early is a `/features-add` slash command if FEATURES.md maintenance becomes annoying.
