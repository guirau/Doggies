# ADR-003: Database and Storage

## Status
Accepted

## Context
The system needs:
1. A relational database for dogs, media metadata, updates, adopter leads, and chat sessions.
2. Object storage for dog photos and videos.
3. Authentication for the single admin user.
4. Optionally, vector search for future semantic dog matching (Phase 2).

The developer is a solo dev deploying on Cloud Run + Vercel. Preference is for managed services with free tiers, minimal ops, and OSS-first.

## Decision
**Supabase** — managed PostgreSQL + pgvector + Object Storage + Auth in a single platform.

- **Database:** Supabase PostgreSQL (managed, automatic backups, connection pooling via pgBouncer)
- **Vector extension:** pgvector (pre-installed on Supabase) — ready for Phase 2 semantic search without migration
- **Object Storage:** Supabase Storage (S3-compatible, CDN-backed, free tier: 1GB)
- **Auth:** Supabase Auth (JWT-based, admin-only for MVP)

## Alternatives Considered

**Database alternatives:**
- **Cloud SQL (PostgreSQL on GCP)** — keeps everything on Google Cloud alongside Cloud Run. Better GCP IAM integration. But more expensive ($9/mo minimum), no built-in auth or storage, requires more setup. Recommended if Supabase causes friction.
- **PlanetScale (MySQL)** — excellent branching workflow, but MySQL lacks pgvector and has weaker JSON support. Rejected.
- **Firebase Firestore** — NoSQL, simpler for rapid prototyping. But schema-less design complicates relational queries (dog + leads + updates). Rejected.
- **Neon** — serverless PostgreSQL, excellent cold-start story, pgvector support. Strong alternative to Supabase if auth/storage aren't needed from the same provider.

**Storage alternatives:**
- **Cloudflare R2** — cheaper at scale ($0.015/GB vs Supabase's free 1GB then $0.021/GB), zero egress fees. Preferred if media volume is high. Can be swapped in later without schema changes.
- **Google Cloud Storage** — keeps everything on GCP, good IAM integration with Cloud Run. More complex setup for a solo dev.
- **Supabase Storage** (proposed) — simplest: same dashboard, same auth tokens, same SDK. Acceptable for MVP scale.

## Consequences
- **Positive:** One dashboard for DB + storage + auth. Supabase's JavaScript and Python SDKs are well-documented. Free tier (500MB DB, 1GB storage, 50MB file uploads) is sufficient for MVP. pgvector is ready for Phase 2 without a separate vector DB.
- **Negative:** Supabase free tier has connection limits (60 concurrent) — fine for MVP but needs connection pooling (pgBouncer, already included). Large video files (>50MB) need to be chunked or stored elsewhere.
- **Lock-in:** Supabase is open source and self-hostable. The underlying PostgreSQL is portable. Low lock-in risk.

## Trade-offs
Developer velocity and unified tooling are prioritised over GCP-native integration. If the project scales significantly, Cloud SQL + Cloud Storage is the natural migration path.

## Most Likely Failure Mode
Supabase Storage 50MB file size limit for individual uploads. Mitigation: for videos, implement client-side chunked uploads or direct-to-storage signed URLs. Alternatively, cap video uploads at 50MB in the admin panel with a clear error message.
