# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If you're choosing between options based on a guess, say it's a guess and name the alternatives.
- If something is unclear, stop. Name what's confusing. Ask.

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

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 4. Test-Driven Development

**Failing test first. Always. No exceptions in planning phase.**

* Write the failing test before the implementation.
* Every acceptance criterion in the PRD must be independently testable.
* For bugs: write a test that reproduces the bug, then fix it.
* For features: write tests for the contract, then build to pass them.

**Forcing line: If you're about to write code without a failing test first, stop and write the test.**

Test layers expected:

* Unit tests for individual functions and components
* Integration tests for API routes and external service boundaries
* End-to-end tests for critical user flows

No percentage coverage target. The bar is: each acceptance criterion has at least one test.

## 5. Tool & Dependency Selection

**Don't pick tools unilaterally. This is a user decision with research support.**

Before adding any tool, library, service, or platform that is core to business value (database, auth, payments, hosting, AI provider, messaging, etc.), follow the `tool-selection` skill.

This does NOT apply to dev-time engineering details (linters, formatters, test runners, individual utility packages). Use judgment for those.

## 6. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 7. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

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

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, tests exist before implementations, tool decisions go through the user, verification means "I ran it" not "it should work.", and clarifying questions come before implementation rather than after mistakes.
