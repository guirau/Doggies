# ADR-004: AI Chatbot — Grounded Tool Use with Strict Data Contract

## Status
Accepted (updated after The Fool review)

## Context
The visitor-facing chatbot lets users ask natural language questions about dogs at the shelter. The chatbot must:
1. Be strictly grounded in real DB data for all dog-specific facts — hallucination is unacceptable.
2. Guide visitors toward understanding if they are a good fit for a dog, not just push them toward adoption.
3. Supplement dog-specific facts with general care knowledge (breed needs, lifestyle fit) from Claude's training.

The primary risk is Claude generating confident, fluent sentences about a specific dog that are factually wrong — even when using tool results correctly. Tools constrain the data retrieved, but not the prose generated.

## Decision
**Claude Tool Use with a two-layer grounding contract.**

### Layer 1: Tools constrain the data
Claude is given read-only database tools. Dog-specific facts can only enter the response via tool results:
- `list_available_dogs()` — all dogs with status = available
- `search_dogs(traits: list[str], size: str?, gender: str?)` — filtered query
- `get_dog_details(dog_id: str)` — full profile: name, breed, age, gender, size, traits, health, status
- `get_recent_updates(dog_id: str)` — latest diary entries for a dog

Claude decides which tools to call, executes them, and receives structured results back.

### Layer 2: System prompt contract prohibits fabrication
The system prompt explicitly instructs Claude:

```
You are a helpful assistant for a dog shelter on Koh Phangan, Thailand.

STRICT RULES:
- NEVER state any fact about a specific dog (name, breed, age, health, 
  status, availability) unless that fact came directly from a tool result 
  in this conversation.
- If a tool result does not contain the requested information, say so 
  clearly: "I don't have that information for [dog name]."
- Do not infer, estimate, or extrapolate dog-specific facts.

WHAT YOU CAN DO:
- Share general knowledge about dog breeds, care requirements, and 
  lifestyle compatibility from your own training.
- Ask the visitor questions to understand if they and a specific dog 
  are a good match (lifestyle, living situation, experience with dogs).
- Guide the visitor — help them discover what kind of dog suits them, 
  not just which dogs are available.

YOUR PRIMARY GOAL is to help the visitor understand whether they are 
a good fit for adopting a dog, and if so, which dog fits their life.
```

### What the chatbot can and cannot say

| Type of information | Source | Allowed |
|--------------------|--------|---------|
| Dog's name | Tool result only | ✅ |
| Dog's availability status | Tool result only | ✅ |
| Dog's health / vaccination | Tool result only | ✅ |
| Dog's personality traits | Tool result only | ✅ |
| Breed general care needs | Claude training | ✅ |
| "A calm dog suits apartment living" | Claude reasoning | ✅ |
| "Bella is probably healthy" (not in tool result) | Fabricated | ❌ |
| "Max is good with kids" (not in tool result) | Fabricated | ❌ |

## Chatbot Goal: Qualifying, Not Selling

The chatbot's primary role is **adopter qualification**, not conversion pressure. It should:
- Ask questions about the visitor's lifestyle, living situation, and experience with dogs
- Help them articulate what they're looking for in a dog
- Match that profile against available dogs using tools
- Be honest when no current dog is a great fit
- Never pressure or urgency-sell ("this dog won't be here long!")

This builds trust, reduces bad-fit adoptions (which result in returns), and serves the shelter's long-term health better than maximising short-term adoption numbers.

## Alternatives Considered

**RAG (vector similarity search):**
- Embed dog profiles → pgvector → cosine similarity search.
- Rejected for MVP: with 20–100 dogs, a full dog list fits in Claude's context. RAG adds embedding pipeline complexity without benefit at this scale.
- **Adopt in Phase 2** if: corpus grows beyond ~300 dogs, or semantic matching ("a dog like the one I grew up with") becomes a priority.

**Full dog dump in every prompt:**
- Inject all dog data into every prompt. Simple, always fresh.
- Rejected: expensive at scale, and still doesn't prevent fabrication of facts not in the data.

**Rule-based NLP + hardcoded responses:**
- Deterministic but brittle. Requires significant maintenance. Poor UX for nuanced adopter questions.

## Consequences
- **Positive:** Zero embedding infrastructure for MVP. Tool results are always real-time. The two-layer contract makes fabrication structurally harder. Qualifying-first approach builds trust with visitors.
- **Negative:** The system prompt contract is enforced by Claude's instruction-following, not a hard technical constraint. Adversarial inputs could still probe edges. Mitigation: log all conversations; review weekly in early phase; tighten system prompt based on observed failures.
- **Streaming:** FastAPI streams via Server-Sent Events. Next.js chatbot widget renders tokens as they arrive, masking latency.

## Implementation Notes
- Tools are plain Python functions passed to the Claude API as tool definitions (or LangChain `@tool`).
- Tool descriptions must be precise — Claude uses them to decide when to call each one.
- Adoption intent detection: if the conversation reaches clear adoption interest, FastAPI dispatches a Telegram notification to the admin. This is a post-processing step, not a tool.
- Conversation history stored in `ChatSession.messages` (JSON). Max 10 turns retained in context window.
- Log every tool call with inputs and outputs for debugging and weekly review.

## Trade-offs
Data correctness and adopter trust are prioritised over response fluency. A chatbot that occasionally says "I don't have that information" is better than one that invents convincing but wrong dog facts.

## Most Likely Failure Mode
Claude generates a plausible-sounding dog fact not in the tool result (e.g., "Bella seems like a gentle dog" when gentleness wasn't in the profile). Mitigation: system prompt prohibition + weekly log review + output validation layer in Phase 2 (classify each sentence as tool-grounded vs. Claude-generated and flag ungrounded dog-specific claims).
