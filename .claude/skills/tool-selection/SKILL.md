---
name: tool-selection
description: Use this skill during the planning phase when deciding which tool, library, service, or platform to build a core feature on. Triggers for runtime and infrastructure decisions that affect business value (databases, auth, payments, hosting, messaging, AI providers, search, storage, analytics, etc.). Do NOT use for dev-time engineering details (linters, test runners, formatters, build tools, individual utility packages). The skill enforces an open-source-first preference with structured research and explicit user input at each branch.
---
# Tool Selection

When a planning task requires choosing a tool to build on, do not pick unilaterally. Run this procedure.

## Scope check

Trigger this skill only when:

- The decision is made during planning, not during implementation.
- The tool is core to business value (what the product does), not engineering hygiene.
- Examples that trigger: database, vector store, auth provider, payment processor, email service, hosting platform, queue, LLM provider, monitoring.
- Examples that do NOT trigger: ESLint config, choice of pytest plugin, npm utility library, formatter, type checker.

If unsure, ask the user: "This feels like a tool decision - run the tool-selection procedure?"

## Procedure

### Step 1: Open-source research

Always start here. Present 2-3 open-source options that meet the use case, plus an empty slot for the user to paste a repo they want considered.

**Selection criteria for repos presented:**

- Actively maintained: commit activity within the last ~6 months
- Reasonable adoption for the category (stars, contributors, real-world deployments)
- License compatible with the project's use (MIT, Apache 2.0, BSD preferred; check copyleft carefully)
- Self-hostable or vendorable (not a thin wrapper around a paid service)

**Output format per option:**

- Name + one-line description
- Why it fits this use case
- Key tradeoffs (limitations, scaling concerns, operational burden)
- Cost to run (hosting, ops time) - open-source is not free, just no license fee
- Effort to integrate (low / medium / high)

**Present to the user like this:**

```
Open-source options for [use case]:

A. [Name] - [one-liner]
   Fit: ...
   Tradeoffs: ...
   Run cost: ...
   Integration effort: ...

B. [Name] - [one-liner]
   ...

C. [Name] - [one-liner]
   ...

D. Paste your own repo: ____________

E. None of these work for me - move to SaaS / custom
```

Wait for the user to pick A/B/C, paste a repo into D, or select E.

If the user pastes a repo (D), evaluate it against the same criteria and present the analysis before confirming.

### Step 2: Custom build or SaaS

Only run this step if Step 1 produced no satisfactory option (user picked E, or evaluation of their pasted repo was rejected).

Ask the user directly:

```
Open-source didn't work for [use case]. Two paths:

1. Custom build - we implement it ourselves
2. SaaS - we integrate a hosted service

Which direction?
```

If the user picks **Custom**: stop the skill. Move into normal planning for the custom build. The CLAUDE.md rules about simplicity and minimum scope apply.

If the user picks **SaaS**: continue to Step 3.

### Step 3: SaaS research

Research and present **at least one free option AND at least one paid option**, even if one is clearly better. The user sees the tradeoff explicitly.

**Selection criteria:**

- Free tier must be usable for the actual use case, not a trial
- Paid option should be a credible production choice, not a random expensive one
- Note pricing model (per seat, per request, per GB, etc.) and what triggers cost increases
- Flag lock-in risks (proprietary APIs, data export limitations)

**Output format per option (same as Step 1 plus pricing):**

- Name + one-line description
- Why it fits this use case
- Key tradeoffs (limitations, lock-in, scaling concerns)
- Cost: pricing model, what's in the free tier (if any), what triggers cost jumps
- Effort to integrate (low / medium / high)

**Present to the user like this:**

```
SaaS options for [use case]:

FREE:
A. [Name] - [one-liner]
   Fit: ...
   Tradeoffs: ...
   Cost: Free tier covers [X]. Paid starts at [Y] when [trigger].
   Integration effort: ...

PAID:
B. [Name] - [one-liner]
   Fit: ...
   Tradeoffs: ...
   Cost: [pricing]
   Integration effort: ...

Recommendation: [A or B] because [specific reason tied to the project stage / use case].
The other is better if [specific scenario].
```

Wait for the user to pick.

## After selection

Once a tool is chosen:

- Document the choice and the reasoning in the project's planning doc or PRD
- Note what would trigger revisiting the decision (cost threshold, scale threshold, feature gap)
- Move into implementation planning under normal CLAUDE.md rules

## What this skill is NOT

- Not a replacement for the user's judgment - it surfaces options, the user decides
- Not a blocker for trivial choices - scope check exists for a reason
- Not a one-time decision - revisit when the triggers documented above are hit
