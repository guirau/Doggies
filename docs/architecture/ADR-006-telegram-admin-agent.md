# ADR-006: Telegram Admin Agent — Voice-Note DB Updates

## Status
Accepted

## Context
The shelter is run by a single person who is already overwhelmed with operational tasks. A traditional web admin panel requires the admin to open a browser, log in, navigate to the right dog, and fill out a form — a workflow that will be abandoned under pressure.

The admin already uses Telegram daily. The goal is to let them update the database by doing what they already do: sending a voice note or photo on Telegram.

## Decision
Build a **Telegram-based admin AI agent** as the primary interface for updating the database.

The agent receives messages from the admin's Telegram chat and:
1. Transcribes voice notes to text (Whisper API)
2. Parses the transcription using Claude to extract structured intent (dog name, what changed, new info)
3. If a required field is missing, asks the admin a clarifying question via Telegram reply
4. When data is complete, calls database tool functions to create or update records
5. Accepts photos/videos directly from Telegram and stores them in object storage
6. Confirms the update back to the admin: "✅ Bella's status updated to fostered"

### Example Flows

**New intake:**
```
Admin (voice): "Hey, we just got a new dog, small female mixed breed, about 2 years old, 
               very shy, her name is Luna"
Agent → asks: "Does Luna have any known health issues or vaccination status?"
Admin (voice): "She's not vaccinated yet"
Agent → creates Dog record, replies: "✅ Luna added as available. ID: luna-001"
```

**Status update:**
```
Admin (voice): "Max got adopted today by a local family"
Agent → finds Max in DB, updates status to adopted, replies: "✅ Max marked as adopted"
```

**Diary update with photo:**
```
Admin: [sends photo] + "Bella had a great day at the beach with her foster family"
Agent → creates DogUpdate for Bella, stores photo, replies: "✅ Update posted for Bella"
```

## Architecture

```
Admin (Telegram) 
  → sends voice/photo/text
  → Telegram Bot API webhook
  → FastAPI /api/webhooks/telegram
  → Audio: Whisper API (transcription)
  → Claude: intent extraction + clarification agent
  → DB Tools: create_dog / update_dog / add_dog_update / upload_media
  → Supabase (write)
  → Reply to admin via Telegram Bot API
```

### Agent Tools
| Tool | Purpose |
|------|---------|
| `create_dog(...)` | New dog intake |
| `update_dog(dog_id, fields)` | Status, health, traits changes |
| `add_dog_update(dog_id, content, type, media_url?)` | Diary entry |
| `get_dog_by_name(name)` | Look up dog the admin is referring to |
| `list_dogs(status?)` | Resolve ambiguous references |
| `store_media(file, dog_id)` | Upload photo/video from Telegram |

## Alternatives Considered

**Web admin panel (original plan):**
- The admin must open a browser, log in, and fill forms.
- High compliance risk — will be abandoned when the admin is tired.
- Still useful as a read-only dashboard (see below).

**WhatsApp Business API:**
- More popular in some regions but requires Meta business verification (slow).
- Rejected for v1 in favour of Telegram's simpler bot API.

**Email or form-based updates:**
- Even higher friction than a web panel. Rejected.

## Consequences
- **Positive:** Eliminates the admin compliance problem. Updates happen in the flow of the admin's day. Voice is the lowest-friction interface. Photos upload directly from Telegram — no separate upload step.
- **Negative:** New dependency on Whisper API (or Google Speech-to-Text). Multi-turn clarification conversations require stateful session management in the agent.
- **Web admin panel:** Still built, but its role shifts. It becomes a **read-only dashboard** showing dog listings, lead status, and engagement stats. The admin uses it occasionally for overview, not for daily data entry.

## Audio Transcription
| Option | Cost | Accuracy | Setup |
|--------|------|---------|-------|
| OpenAI Whisper API | ~$0.006/min | Excellent | 5 min |
| Google Speech-to-Text | ~$0.009/min | Excellent | 15 min (GCP IAM) |
| Local Whisper (self-hosted) | Free | Good | Complex |

**Decision:** OpenAI Whisper API for MVP (simplest). Migrate to Google Speech-to-Text in Phase 2 to consolidate on GCP.

## Trade-offs
Workflow naturalness and admin compliance are prioritised over architectural simplicity. The multi-turn conversation adds statefulness that must be managed (stored in a `TelegramSession` table).

## Most Likely Failure Mode
The admin's voice note is ambiguous — "update the brown dog" when there are 3 brown dogs. Mitigation: agent asks clarifying questions; if still ambiguous after 2 turns, agent responds with a disambiguation list of matching dogs by name.
