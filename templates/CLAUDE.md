# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. This file is project-agnostic - the same content can be dropped into any project. Project-specific rules live in `ARCHITECTURE.md` and `PROJECT.md`, both in the project root.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 0. Project Context

Before starting any non-trivial task in this project, read `PROJECT.md` in the project root. It contains the project-specific configuration this file refers to (test framework, doc paths, available skills, vendor list, etc.).

If `PROJECT.md` does not exist, ask the user before continuing.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

* State your assumptions explicitly. If uncertain, ask.
* If multiple interpretations exist, present them - don't pick silently.
* If a simpler approach exists, say so. Push back when warranted.
* If you're choosing between options based on a guess, say it's a guess and name the alternatives.
* If something is unclear, stop. Name what's confusing. Ask.

## 2. Read Before Writing

**Understand the code that exists before adding more.**

Before writing new code in an existing codebase:

* Read the surrounding module, not just the file you're editing.
* Grep for existing patterns, utilities, or helpers that solve the same problem.
* If a pattern already exists, use it. Don't reinvent.
* If conventions are unclear, ask before introducing new ones.

For new files or new modules with no existing style, default to boring. Don't invent baroque conventions.

## 3. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

* No features beyond what was asked.
* No abstractions for single-use code.
* No "flexibility" or "configurability" that wasn't requested.
* No error handling for impossible scenarios.
* If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 4. Test-Driven Development

**Failing test first. Always. No exceptions in planning phase.**

* Write the failing test before the implementation.
* For bugs: write a test that reproduces the bug, then fix it.
* For features: write tests for the contract, then build to pass them.
* Every acceptance criterion in the project's planning docs (PRD, spec, issue) must be independently testable.

**Forcing line: If you're about to write code without a failing test first, stop and write the test.**

Test layers to consider (apply those that fit the project shape):

* Unit tests for individual functions and components
* Integration tests for boundaries between the app and external services
* End-to-end tests for critical flows from the user's perspective

No percentage coverage target. The bar is: each acceptance criterion has at least one test. Specific test frameworks for this project are listed in `PROJECT.md`.

## 5. Tool & Dependency Selection

**Don't pick tools unilaterally. This is a user decision with research support.**

Before adding any tool, library, service, or platform that is core to business value (anything users depend on, anything that costs money, anything hard to swap later), follow the `tool-selection` skill if it is installed in this project (check `PROJECT.md`).

If `tool-selection` is not installed, fall back to: present 2-3 options with tradeoffs (open-source first, then SaaS), explicitly offer the user the option to provide a GitHub repo instead, and wait for them to pick one of the options or supply their own repo.

This rule does NOT apply to dev-time engineering details (linters, formatters, test runners, individual utility packages). Use judgment for those.

## 6. Architecture

**Third-party SDKs do not leak into business logic. The swap test must hold.**

For every external service the app depends on:

* Define an interface (Python `Protocol`/`ABC`, TypeScript `interface`, or equivalent) that describes what the app needs from this category of service.
* Implement the interface in an adapter module that contains all vendor SDK calls.
* Business logic depends on the interface, never on the vendor SDK directly.
* Vendor SDK imports (the package names of third-party services) appear only inside adapter modules and the wiring/composition layer.

**The swap test (always-on):** To replace vendor A with vendor B, you should change one adapter file and one line of wiring - nothing else. If you find yourself importing a vendor SDK outside an adapter module, stop and fix the boundary before continuing.

**For all planning-phase work** that involves new modules, new external integrations, or any non-trivial structural decision: read `ARCHITECTURE.md` in the project root and follow its guidance. If the user @-mentions `@ARCHITECTURE.md`, treat it as the authoritative reference for the task.

If `ARCHITECTURE.md` does not exist in this project, the swap test still applies, but ask the user whether broader architectural rules should be defined before proceeding with structural work.

## 7. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

* Don't "improve" adjacent code, comments, or formatting.
* Don't refactor things that aren't broken.
* Match existing style, even if you'd do it differently.
* If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:

* Remove imports/variables/functions that YOUR changes made unused.
* Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 8. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

* "Add validation" → "Write tests for invalid inputs, then make them pass"
* "Fix the bug" → "Write a test that reproduces it, then make it pass"
* "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

For single-step changes, skip the plan and proceed.

**Verification means executing the test or command and reading the output. Not "this should work."**

* Run the test. Read the result. Report what actually happened.
* If a command was supposed to produce output, show the output.
* "The tests should pass now" is not verification. "I ran the tests, here's the output, they pass" is.

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, tests exist before implementations, tool decisions go through the user, external vendors are wrapped behind interfaces, and verification means "I ran it" not "it should work."
