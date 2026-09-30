# Table Dictionary

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/*/src/main/resources/db/migration/*.sql`

One row per physical table. "Owner entity" is the JPA class that maps the table (when one exists).
"Soft delete" indicates a `deleted_at` column. Row-volume estimates are not available from the
repository and are marked TBD.

## auth_db

| Table | Owner entity | Rows 1/user | Soft delete | Purpose |
|---|---|---|---|---|
| `users` | `User` | 1 | yes | Identity, role, verification flags |
| `refresh_tokens` | `RefreshToken` | N | no (revoke/expire) | Hashed refresh tokens, 7-day TTL |
| `password_reset_tokens` | `PasswordResetToken` | N | no (used/expire) | One-time reset tokens |
| `email_verification_tokens` | `EmailVerificationToken` | N | no (used/expire) | One-time email verification tokens |
| `student_verifications` | `StudentVerification` | 0–1 | no | AUB student verification record |
| `user_external_identities` | `UserExternalIdentity` | N | no | Provider identity links (Google `sub`); `UNIQUE(provider, provider_subject)` |

## user_db

| Table | Owner entity | Rows 1/user | Soft delete | Purpose |
|---|---|---|---|---|
| `profiles` | `Profile` | 1 | no | Public/private profile fields + skills/education JSON |
| `user_settings` | `UserSettings` | 1 | no | Language, theme, notification/privacy JSON, legacy fcm_token |

## file_db

| Table | Owner entity | Rows 1/user | Soft delete | Purpose |
|---|---|---|---|---|
| `file_metadata` | `FileMetadata` | N | yes | Object metadata for bytes stored in MinIO |

## content_db

| Table | Owner entity | Rows 1/user | Soft delete | Purpose |
|---|---|---|---|---|
| `posts` | `Post` | N | yes | Feed posts: VIDEO/POSTER/JOB |
| `comments` | `Comment` | N | no | Comments on posts |
| `mentions` | `Mention` | N | no | `@user` mentions inside comments |
| `reactions` | `Reaction` | N | no | Likes (one per post+user) |
| `follows` | `Follow` | N | no | Directed follow graph |

## career_db

| Table | Owner entity | Rows 1/user | Soft delete | Purpose |
|---|---|---|---|---|
| `user_cvs` | `UserCv` (defect #2) | 0–1 | no | Default CV pointer for a user |
| `job_applications` | `JobApplication` | N | no | Job applications + review timeline |

## finance_db

| Table | Owner entity | Rows 1/user | Soft delete | Purpose |
|---|---|---|---|---|
| `student_finance_accounts` | `StudentFinanceAccount` | 0–1 | no | Link between app user and student finance identity |
| `fee_categories` | `FeeCategory` | global | no | Fee catalogue categories (seeded) |
| `fees` | `Fee` | global | no | Fee catalogue items (seeded) |
| `payments` | `Payment` | N | no | Per-student amounts due/paid |

## chat_db

| Table | Owner entity | Rows 1/user | Soft delete | Purpose |
|---|---|---|---|---|
| `conversations` | `Conversation` | N | no | 1:1 conversation lifecycle |
| `conversation_participants` | `ConversationParticipant` | N | no | Composite-keyed participants + role |
| `messages` | `Message` | N | yes (`deleted_at`) | Messages incl. media/replies/idempotency key |
| `blocks` | `Block` | N | no | User block edges |
| `user_reports` | `UserReport` | N | no | Abuse reports |

## notification_db

| Table | Owner entity | Rows 1/user | Soft delete | Purpose |
|---|---|---|---|---|
| `notifications` | `Notification` | N | no (delete row) | Inbox rows with actor/destination metadata |
| `device_tokens` | `DeviceToken` | N | no | FCM device registrations |

## map_db

| Table | Owner entity | Rows 1/user | Soft delete | Purpose |
|---|---|---|---|---|
| `place_favorites` | `PlaceFavorite` | N | no | Saved Google place snapshots |
| `place_search_history` | `PlaceSearchHistory` | ≤20 | no | Recent searches (capped in code) |

## ai_db

| Table | Owner | Rows | Soft delete | Purpose |
|---|---|---|---|---|
| `ai_cv_interactions` | Python `ai_core` (`cv_app_service.suggest`) | N | no | Records each CV section suggestion |

The `ai_db` table is created by Python code (`INSERT INTO ai_cv_interactions (...)`) and has **no
Flyway migration in the Java tree**; its exact DDL is not part of the Java migration set. The
schema is therefore `TBD — Requires confirmation.` for a Java-side migration. Evidence:
`ai_core/vithey_ai/cv_app_service.py:95-109`.

## Database summary

| Database | Tables | Migration files | Owned by |
|---|---|---|---|
| `auth_db` | 5 | 4 | auth-service |
| `user_db` | 2 | 3 | user-profile-service |
| `file_db` | 1 | 3 | file-service |
| `content_db` | 5 | 5 | content-service |
| `career_db` | 2 | 4 files / 3 versions | career-service |
| `finance_db` | 4 | 3 | finance-service |
| `chat_db` | 5 | 3 | chat-service |
| `notification_db` | 2 | 4 | notification-service |
| `map_db` | 2 | 1 | map-service |
| `ai_db` | ≥1 | 0 (Python-managed) | ai_core |

Total service-owned tables: **28**. See [`05-data-dictionary.md`](05-data-dictionary.md) for column
enums and JSON shapes.
