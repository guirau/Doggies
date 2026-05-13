# ARCHITECTURE.md

Project-specific architectural guidelines. Reference this file in planning-phase work that involves new modules, new external integrations, or any non-trivial structural decision.

## Principle

**Modular backend with swappable boundaries. Frontend and backend deployed separately.**

The application has two deployable units:

* **Backend** — a single deployable application with internal modular boundaries. Deployed to a server-side host.
* **Frontend** — a separate application deployed to a static/frontend host.

This client-server split is structural, not architectural. It exists because frontend and backend have fundamentally different runtimes — one ships static assets to browsers, the other handles HTTP requests with secrets and database access. Two deployments, but the backend remains one application internally.

Which specific host to use for each is a project decision recorded in `docs/`, not here.

**Microservices are explicitly out of scope.** Microservices means splitting the *backend* into multiple independently deployed services (auth-service, users-service, payments-service, each with its own database and its own ops surface). We do not do this. The backend is one application, modular internally.

The operational cost of microservices - multiple deployments, inter-service communication, distributed debugging, more infrastructure - is not justified at this stage. Modularity comes from internal boundaries within the backend, not from network boundaries between services.

## 1. Swappable external dependencies

Every third-party service is wrapped behind an interface. The vendor SDK never leaks into business logic.

### The rule

For every external service the app depends on (LLM provider, transcription, payments, email, vector DB, storage, analytics, auth, etc.):

* Define an interface that describes what the app needs from this category of service. In Python, use `Protocol` or `ABC`. In TypeScript, use `interface`.
* Implement the interface in an adapter module that contains all vendor SDK calls.
* Business logic depends on the interface, never on the vendor SDK directly.
* The vendor name does not appear in business logic file names, function names, or imports outside the adapter.

### Example: transcription

#### Python (Protocol)

```
core/
  transcription.py        # defines: class Transcriber(Protocol): def transcribe(audio_bytes: bytes) -> str
adapters/
  whisper_adapter.py      # implements Transcriber using OpenAI Whisper SDK
  deepgram_adapter.py     # implements Transcriber using Deepgram (added later, no business logic changes)
wiring/
  container.py            # decides which adapter to use based on config
```

#### TypeScript (interface + class)

```
core/
  transcription.ts        # defines: export interface Transcriber { transcribe(audio: Buffer): Promise<string> }
adapters/
  whisper-adapter.ts      # implements Transcriber using OpenAI Whisper SDK
  deepgram-adapter.ts     # implements Transcriber using Deepgram (added later, no business logic changes)
wiring/
  container.ts            # decides which adapter to use based on config
```

Business logic calls `transcriber.transcribe(audio)`. It does not know or care whether Whisper or Deepgram is behind the interface.

### The swap test

To replace vendor A with vendor B, you should change one adapter file and one line of wiring. If swapping requires touching business logic, the boundary was drawn in the wrong place. Stop and fix the boundary before continuing.

### Hard signal of violation

The specific vendor list for this project is in `PROJECT.md`. If any of those vendor package names appears as an import outside `adapters/` and `wiring/`, the boundary is wrong. Stop and fix it.

## 2. Layered structure (backend)

The backend is organized into layers with a strict dependency direction. Inner layers know nothing about outer layers.

```
core/         # pure business logic and domain models. No framework, no SDK imports, no I/O.
adapters/     # implementations of external service interfaces (one file per vendor).
api/          # framework layer (FastAPI routes, Telegram handlers, etc.). Thin - delegates to core.
wiring/       # dependency injection / composition root. Decides which adapter is used where.
config/       # environment variables, settings, feature flags.
```

### Dependency direction

* `core` depends on nothing in this project except itself.
* `adapters` depends on `core` (to implement its interfaces) and on vendor SDKs.
* `api` depends on `core` and on `wiring`.
* `wiring` depends on `core`, `adapters`, and `config`.

If you find yourself importing a vendor SDK in `core`, or importing `api` from `core`, the dependency direction is wrong. Stop and fix it.

### Why this direction matters

* `core` has no external dependencies → it is trivially unit-testable, no mocks needed for transport or vendors.
* Swapping vendors only touches `adapters` and `wiring`.
* Swapping the web framework only touches `api`.
* Business logic is portable across all of these changes.

## 3. Frontend-backend contract

The frontend and backend communicate over HTTP. The contract between them is a deliberate design surface, not an implementation detail.

* The backend exposes a documented API (OpenAPI spec, or equivalent). The frontend depends on the documented contract, not on backend internals.
* Shared types (request/response shapes) are either generated from the OpenAPI spec or maintained in a shared types package. Do not duplicate them by hand on both sides.
* The frontend has no direct access to the backend's database. All data flows through the API.
* CORS, authentication, and rate limiting live in the `api/` layer of the backend, not in `core/`.

The same boundary discipline applies here as everywhere else: the frontend should be portable across backend implementations as long as the contract is honored, and the backend should be portable across frontend implementations.

## 4. Framework code stays thin

Framework-layer code (route handlers, message handlers, CLI commands) is a thin shell. It handles transport concerns only: parsing input, calling a core service, formatting output.

* Route handlers should be short. If a handler grows past ~20 lines, the logic belongs in `core`.
* No business rules in route handlers. No validation logic beyond input shape. No external service calls.
* Routes call core services. Core services do the work.

### Bad

```python
@app.post("/transcribe")
async def transcribe(audio: UploadFile):
    # 80 lines of validation, Whisper API call, prompt construction, DB write, response formatting
```

### Good

```python
@app.post("/transcribe")
async def transcribe(
    audio: UploadFile,
    service: TranscriptionService = Depends(get_service),
):
    result = await service.transcribe(await audio.read())
    return {"text": result.text}
```

The route is responsible for HTTP. The service is responsible for transcription. Test the service without booting the framework.

## 5. Data access behind repositories

Database access goes through repository interfaces, not direct ORM or SQL calls in business logic.

* Define repository interfaces in `core` (e.g., `UserRepository`, `OrderRepository`).
* Implement them in `adapters` using the actual database client.
* Business logic calls `repo.find_by_id(some_id)`. It does not write SQL or touch the database client directly.

The swap test applies here too: switching from one database to another should be one adapter change. Same rule, same boundary.

### Repositories are not generic CRUD wrappers

A repository exposes methods that match how business logic actually uses the data:

* `user_repo.find_active_subscribers()` — yes
* `user_repo.query(filter, sort, limit)` — no (just leaks query syntax through the interface)

If the interface forces business logic to construct queries, the boundary is in the wrong place.

## 6. Module boundaries within core

Inside `core`, organize by domain concern, not by technical type.

### Prefer

```
core/
  users/           # everything about user domain - models, services, repository interface
  orders/          # order flow logic
  notifications/   # notification logic
  transcription.py # cross-cutting service interface
```

### Not

```
core/
  models/          # all models from all domains lumped together
  services/        # all services lumped together
```

Why: domain-organized code groups things that change together. Type-organized code scatters a single domain concern across many directories, so any feature change touches many folders.

### Coupling rules between domain modules

* Domain modules should be loosely coupled.
* If module A needs something from module B, it imports from B explicitly.
* If two modules need the same thing, the shared thing moves to a clearly named shared location, not silently duplicated.
* Avoid bidirectional dependencies between domain modules. If you have one, it usually means the two modules are actually one - or there's a missing third module both should depend on.

## 7. Wiring and composition root

`wiring/` is the only place that knows which concrete adapter is paired with which interface.

* Read config in `wiring/`, not in `core/`.
* Construct adapter instances in `wiring/`, inject them where needed.
* Use dependency injection patterns appropriate to the framework.
* Adapters and core services should accept their dependencies as constructor arguments. No global singletons fetched from inside business logic.

This is what makes the swap test work: change config or change the wiring file, and the system runs with a different adapter without touching anything else.

## 8. Configuration

* All environment variables and settings live in `config/`.
* `core/` and `adapters/` receive config values as arguments, not by reading env vars directly.
* Vendor-specific config (API keys, endpoints) lives near the adapter that uses it, surfaced through the central config module.
* Feature flags live in config, not scattered through code.

## 9. When to violate these rules

These rules exist to make change cheap. They have cost - more files, more indirection, more setup for the first feature. For genuinely throwaway code, they may be overkill.

### Acceptable to skip the structure

* One-time migration scripts
* Data fixes that will be deleted after running
* Exploratory prototypes that will be rewritten
* Scripts in a `scripts/` folder clearly marked as such

### Not acceptable to skip the structure

* "Just a quick endpoint" (it will not stay quick)
* "We'll refactor later" (later doesn't come)
* "The MVP doesn't need this" (the MVP especially needs this - the whole point is keeping change cheap while learning what to build)

If you think a piece of code should skip the structure, say so explicitly and explain why. Otherwise, follow the rules. When in doubt, follow them.

## 10. When splitting the backend WOULD make sense

The "modular backend, not microservices" rule is not permanent. It reflects the current stage. Splitting the backend into separate services becomes worth considering when:

* A specific component has fundamentally different scaling needs (e.g., a heavy ML inference path that needs GPUs while the rest of the app doesn't).
* A specific component has fundamentally different runtime needs (e.g., long-running background jobs vs. low-latency HTTP).
* The team is large enough that coordination on a single deployable becomes the bottleneck.
* Compliance or security requirements force isolation (e.g., a PCI-scoped service).

None of these apply right now. If they start to apply, revisit this section explicitly - do not drift into microservices by accident.

## 11. How to use this document

* **In planning prompts:** @-mention this file and the section relevant to the task. Example: "Plan the transcription module. Follow @ARCHITECTURE.md sections 1, 2, 4."
* **During implementation:** the always-on swap test in `CLAUDE.md` Section 6 covers the critical case (no vendor leaks). Other rules in this doc apply when the work touches structure.
* **When extending this doc:** new rules go in numbered sections. Keep examples concrete. Keep the "Hard signal of violation" pattern where possible - it gives Claude a specific trigger to stop on.
