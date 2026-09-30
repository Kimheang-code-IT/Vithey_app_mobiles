# Data Retention

> Status: Partially complete · Last reviewed: 2026-09-30
> Evidence: `backend/infrastructure/config-repo/application.yml`, `backend/services/*/db/migration/*.sql`, service cache classes

> There is **no formal data-retention policy** in the repository. This document records the
> verifiable, implementation-level retention behaviour and marks policy decisions
> `TBD — Requires confirmation.`

## 1. Verifiable retention (implementation)

### 1.1 Authentication tokens

| Token | Retention mechanism | Value | Evidence |
|---|---|---|---|
| Access JWT | Expiry (not stored server-side) | 15 min (`VITHEY_ACCESS_TOKEN_TTL`) | `config-repo/application.yml:54` |
| Refresh token | `expires_at` (7d) + `revoked_at`; rotated on use | 7 d (`VITHEY_REFRESH_TOKEN_TTL`) | `config-repo/application.yml:55`, `RefreshToken.java` |
| Password reset token | One-time `used_at` + `expires_at` | set by service at creation | `PasswordResetToken.java` |
| Email verification token | One-time `used_at` + `expires_at` | set by service at creation | `EmailVerificationToken.java` |

Rows are **not purged on expiry by a scheduled job**; expiry is enforced at read time
(`isExpired`/`isUsable`). Rows are removed only by cascade when the owning `users` row is
hard-deleted (`ON DELETE CASCADE`, V2/V4). No cleanup scheduler was found. `TBD — Requires
confirmation.` for whether expired token rows are ever hard-deleted.

Hashed-at-rest: `token_hash` is stored hashed; passwords use BCrypt. No plaintext tokens at rest.

### 1.2 Soft-deleted domain rows

Soft-delete columns exist but **no automatic hard-delete/compaction** is implemented:

| Table | Soft-delete column | Effect on reads |
|---|---|---|
| `users` | `deleted_at` | partial unique email/phone allow re-registration |
| `posts` | `deleted_at` | feed/detail queries exclude deleted rows |
| `file_metadata` | `deleted_at` | metadata hidden; MinIO object removed on delete |
| `messages` | `deleted_at` | message hidden (DB CHECK also allows `DELETED` status) |

Because soft-deleted rows persist indefinitely, the delete user flow is logically "reversible" in
the database until a hard-delete policy exists. `TBD — Requires confirmation.`

### 1.3 Application caches (short-lived, non-authoritative)

| Cache | TTL | Evidence |
|---|---|---|
| Gateway rate limit | rolling window (Redis) | `api-gateway.yml` |
| Chat recent messages | 24 h | `MessageCacheService.java:14` |
| Chat presence | 90 s | `ChatProperties.java` (`presenceTtlSeconds=90`) |
| Chat typing | 5 s | `ChatProperties.java` (`typingTtlSeconds=5`) |
| Map search results | 5 min | `PlaceCacheService.SEARCH_TTL` |
| Map place detail | 24 h | `PlaceCacheService.DETAIL_TTL` |
| `ai_core` extraction cache | in-memory, bounded (size from config) | `ai_core` README |

### 1.4 Map history cap

`place_search_history` is capped to **20 rows per user** in application code
(`PlaceSearchHistory.MAX_ENTRIES_PER_USER = 20`); older rows are removed on insert. This is the only
explicit row-count retention rule found.

### 1.5 Monitoring/log retention

Loki is configured with **168 h (7 days)** retention when the optional `monitoring` profile is
running. [VERIFIED: `monitoring/`; `AGENTS.md`]. This applies to logs, not databases.

### 1.6 Device tokens

`device_tokens` rows are removed when the client calls `DELETE /api/v1/notifications/devices/{token}`.
There is no automatic expiry for stale FCM tokens. `TBD — Requires confirmation.`

## 2. Data classification (partial)

| Class | Examples | Handling |
|---|---|---|
| Credentials | `password_hash`, `*_token.token_hash` | hashed (BCrypt / hashed token) |
| PII | email, phone, full_name, date_of_birth, location, university | plaintext in DB; access gated by JWT/roles |
| Financial | `payments.amount`, `currency`, `status` | plaintext; student-role gated |
| Content | posts, comments, messages | plaintext; owner/participant-gated |
| Media | file bytes | MinIO; metadata in `file_metadata` |

Formal PII retention periods and deletion-on-request (right-to-erasure) procedures:
`TBD — Requires confirmation.`

## 3. Policy gaps (all TBD)

| Topic | Status |
|---|---|
| Retention period per table/class | `TBD — Requires confirmation.` |
| Scheduled purge of expired tokens | `TBD — Requires confirmation.` |
| Hard-delete/compaction of soft-deleted rows | `TBD — Requires confirmation.` |
| Account-deletion cascade across services (auth → profile/posts/files/chat) | `TBD — Requires confirmation.` |
| Backup retention/expiry | `TBD — Requires confirmation.` (see [`08-backup-restore.md`](08-backup-restore.md)) |
| Audit-log retention | `TBD — Requires confirmation.` |
| Legal/regulatory retention (financial records) | `TBD — Requires confirmation.` |

## 4. Environment status

Local development/demo retention is the only behaviour that can be verified today. Staging and
production do not exist, so no environment-specific retention is configured.
