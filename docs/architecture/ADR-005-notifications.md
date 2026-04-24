# ADR-005: Admin Notifications — Telegram

## Status
Accepted

## Context
The shelter admin needs to be notified in near-real-time when:
1. A visitor expresses adoption interest in a specific dog via the chatbot.
2. A visitor asks to donate or get more information.

The admin is a single person running the shelter on Koh Phangan, Thailand. Notifications must reach them on their phone without requiring them to check a dashboard. The solution must be simple to set up and free.

## Decision
**Telegram Bot API.**

A Telegram bot is created (via BotFather, free). The FastAPI backend sends messages to the admin's Telegram chat ID when trigger events occur. No external service required — the Telegram Bot API is a free HTTP API.

## Alternatives Considered

**LINE:**
- LINE is the dominant messaging app in Thailand. More culturally appropriate for local adoption.
- Rejected for now because: the developer is not based in Thailand full-time; LINE's Messaging API requires a LINE Business account and approval process; Telegram is simpler to set up (5 minutes vs. LINE's ~1 day setup).
- **Revisit in Phase 2** when optimising for Thai user adoption.

**Email (Resend / SendGrid):**
- Reliable, professional, easy to set up.
- Rejected as primary channel because: email is not real-time enough for adoption inquiries; admin checks Telegram more than email.
- **Use as a secondary channel** (backup notifications) in Phase 2.

**WhatsApp Business API:**
- Not dominant in Thailand. Requires Meta business verification (days to weeks). Rejected.

**Push notifications (FCM / APNs):**
- Requires a native app. No native app in MVP. Rejected.

**Admin dashboard real-time alerts:**
- Requires the admin to have the dashboard open. Rejected as primary channel.

## Consequences
- **Positive:** Zero cost. 5-minute setup (create bot via BotFather, get chat ID, add to Cloud Run env vars). Works on any device. Telegram delivers instantly.
- **Negative:** Admin must have Telegram installed. Single point of failure if Telegram is blocked or unavailable. No message history in the admin panel (future work).
- **Security:** The admin's Telegram chat ID is stored as an environment variable in Cloud Run. The bot token is a secret — managed via Cloud Run Secrets.

## Notification Format
Messages sent to admin Telegram will include:
- Event type emoji (🐕 adoption interest, 💬 info request)
- Dog name and ID (if applicable)
- Visitor contact handle (if provided)
- Timestamp
- Link to the dog's admin panel page

Example:
```
🐕 Adoption Interest
Dog: Bella (#abc-123)
Visitor: @username (Telegram)
Time: 2026-04-23 14:32 UTC
→ View in admin: https://doggies.app/admin/dogs/abc-123
```

## Trade-offs
Setup speed and reliability are prioritised over cultural fit (LINE). This is acceptable for MVP where the admin is the primary user of notifications.

## Most Likely Failure Mode
Telegram rate limits (30 messages/second global, 1 message/second per chat). Mitigation: queue notifications through a simple async task queue (FastAPI BackgroundTasks for MVP; Celery/Redis in Phase 2 if volume warrants it).
