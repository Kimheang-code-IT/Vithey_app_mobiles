# Data Dictionary

> Status: Verified (exceptions tagged) · Last reviewed: 2026-09-30
> Evidence: `backend/services/*/src/main/java/**/entity/*.java`, `backend/services/*/src/main/resources/db/migration/*.sql`

This document defines the **vocabularies** (enums, CHECK sets, JSON shapes) and the meaning of
non-obvious columns. It is the companion to [`03-database-schema.md`](03-database-schema.md).

## 1. Enumerations

Legend: **DB** = CHECK constraint set; **Entity** = Java enum values. Differences are defect #4.

| Field | DB CHECK | Entity enum | Notes |
|---|---|---|---|
| `users.role` | `USER,STUDENT,COMPANY,ADMIN` | `Role` = same | identical |
| `student_verifications.status` | `PENDING,VERIFIED,REJECTED` | `StudentVerificationStatus` = same | identical |
| `profiles` skills/education/field_visibility | JSONB (no CHECK) | `ProfileSkillEntry`, `List<String>`, `Map<String,String>` | shapes in §2 |
| `user_settings.language` | `en,km` | `AppLanguage` = same | identical |
| `user_settings.theme` | `light,dark,system` | `AppTheme` = same | identical |
| `file_metadata.file_type` | `AVATAR,CV,POSTER,VIDEO,CHAT_ATTACHMENT` | `StoredFileType` = same | identical post-V3 |
| `posts.type` | `VIDEO,POSTER,JOB,STANDARD` | `PostType` = `VIDEO,POSTER,JOB` | **DB superset** — entity cannot read `STANDARD` |
| `job_applications.status` | `PENDING,REVIEWED,ACCEPTED,REJECTED,UNDER_REVIEW,WITHDRAWN` | `ApplicationStatus` = `PENDING,REVIEWED,ACCEPTED,REJECTED` | **DB superset** (`UNDER_REVIEW`, `WITHDRAWN`) |
| `fees.currency` | none | `CurrencyCode` = `KHR,USD` | entity-enforced only |
| `payments.currency` | none | `CurrencyCode` = `KHR,USD` | entity-enforced only |
| `payments.status` | `UNPAID,PAID,OVERDUE,PENDING,CANCELLED` | `PaymentStatus` = `UNPAID,PAID,OVERDUE` | **DB superset** (`PENDING`, `CANCELLED`) |
| `conversations.status` | `PENDING,ACTIVE,BLOCKED,DECLINED,ARCHIVED,CLOSED` | `ConversationStatus` = `PENDING,ACTIVE,BLOCKED,DECLINED` | **DB superset** (`ARCHIVED`, `CLOSED`) |
| `conversation_participants.role` | `REQUESTER,RECIPIENT,MEMBER,ADMIN` | `ParticipantRole` = `REQUESTER,RECIPIENT` | **DB superset** (`MEMBER`, `ADMIN`) |
| `messages.message_type` | none (VARCHAR default `TEXT`) | `MessageType` = `TEXT,IMAGE,FILE` | entity-enforced only |
| `messages.status` | `SENT,DELIVERED,READ,DELETED` | `MessageStatus` = `SENT,DELIVERED,READ` | **DB superset** (`DELETED`) |
| `notifications.type` | wide superset (V4) | `NotificationType` (10 values) | see §4 |
| `device_tokens.platform` | `ANDROID,IOS` | `DevicePlatform` = `ANDROID,IOS` | identical |

## 2. JSON column shapes

### `profiles.skills` (JSONB, default `[]`)
Array of `ProfileSkillEntry` objects: `{ "name": string, "proficiency": int }`.
Evidence: `ProfileSkillEntry.java`.

### `profiles.education` (JSONB, default `[]`)
Array of strings. Evidence: `Profile.java:80-82`.

### `profiles.field_visibility` (JSONB, default `{}`)
Map of field name → visibility constant `PUBLIC | PRIVATE | OWNER_ONLY`.
Evidence: `FieldVisibility.java`.

### `user_settings.notification_prefs` / `privacy_prefs` (JSONB, default `{}`)
Free-form maps of toggle keys to booleans (e.g. `{"likes":true,"chat":true}`,
`{"profile_visible":true}`). No DB-level schema; the API treats them as opaque objects.
Evidence: `UpdateSettingsRequest.java` example.

### `notifications.destination` (JSONB, nullable)
Structured navigation target for the Flutter notification center. Free-form map written by the
notification service. Exact allowed keys are not constrained in the repo —
`TBD — Requires confirmation.`

### `place_*` (no JSON; plain columns)
Coordinates are `DOUBLE PRECISION`; `radius_m` is metres (default 1500).

## 3. Common columns

| Column pattern | Meaning |
|---|---|
| `created_at` / `updated_at` | `TIMESTAMPTZ`, application-set for domain services; DB defaults `NOW()` on profile/settings. |
| `deleted_at` | Soft-delete marker; `NULL` = active. Partial unique indexes and partial feed/indexes filter on it. |
| `*_file_id` | Cross-service UUID reference to `file_db.file_metadata.id` (no cross-DB FK). |
| `user_id`, `author_id`, `applicant_id`, `sender_id`, `owner_user_id` | Cross-service UUID reference to `auth_db.users.id`. |
| `reference_id`, `reference_type` | Notification target (e.g. post id + `POST`); type vocabulary not DB-constrained. |

## 4. Notification type vocabulary

DB CHECK (V4) accepts:
`SYSTEM, MESSAGE, APPLICATION_UPDATE, PAYMENT_DUE, MENTION, LIKE, COMMENT, FOLLOW, CHAT,
CHAT_REQUEST, PAYMENT, JOB, POST_SHARE, AI, STUDENT_VERIFICATION`.

`NotificationType` Java enum contains:
`LIKE, COMMENT, MENTION, FOLLOW, CHAT, CHAT_REQUEST, JOB, PAYMENT, SYSTEM, STUDENT_VERIFICATION`.

So the entity omits DB-permitted `MESSAGE`, `APPLICATION_UPDATE`, `PAYMENT_DUE`, `POST_SHARE`, `AI`
— **defect #4**. The Flutter `NotificationType` additionally defines `postShare` and
`aiAssistantResponse`, which the backend never emits. [VERIFIED: `NotificationType.java`,
`V4__notification_ui_upgrade.sql:16-21`, `api_docs.md` §11]

## 5. Token TTLs and lifecycle (see retention doc)

| Token | Storage | TTL | Invalidation |
|---|---|---|---|
| Access JWT | not stored | 15m (`VITHEY_ACCESS_TOKEN_TTL` default `15m`) | expiry / signature |
| Refresh token | `refresh_tokens` hashed | 7d (`VITHEY_REFRESH_TOKEN_TTL` default `7d`) | `revoked_at`, rotation on refresh |
| Password reset | `password_reset_tokens` hashed | one-time | `used_at` |
| Email verification | `email_verification_tokens` hashed | one-time | `used_at` |

Evidence: `backend/infrastructure/config-repo/application.yml:51-55`.

## 6. TBD items

- Exact policy/DDL for `ai_db.ai_cv_interactions`: `TBD — Requires confirmation.`
- Allowed keys inside `notifications.destination`: `TBD — Requires confirmation.`
- Data classification (PII levels) for each table: `TBD — Requires confirmation.`
