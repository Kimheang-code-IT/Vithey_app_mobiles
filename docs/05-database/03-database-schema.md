# Database Schema

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/*/src/main/resources/db/migration/*.sql`
> All names/constraints/indexes below are taken from the applied migration files. Where an entity
> cannot represent the DB CHECK, that is called out explicitly (defect #4).

This document is the authoritative **post-migration** schema. It records columns, primary keys,
foreign keys, CHECK constraints, and indexes per database. Column-level enums and JSON shapes are
summarised in [`05-data-dictionary.md`](05-data-dictionary.md).

---

## 1. auth_db — auth-service

Migrations: `V1__init_auth_schema`, `V2__Soft_delete_unique_email_phone_and_cascade_tokens`,
`V3__Drop_unused_token_and_student_verification_indexes`,
`V4__Student_verification_cascade_and_university_email_unique`,
`V5__user_external_identities`.

### 1.1 `users`

| Column | Type | Null | Default | Notes |
|---|---|---|---|---|
| `id` | UUID | no | — | PK |
| `email` | VARCHAR(255) | no | — | case-insensitive uniqueness via partial index |
| `phone` | VARCHAR(32) | yes | — | uniqueness via partial index; nullable since V5 (provider-created accounts have no phone) |
| `password_hash` | VARCHAR(255) | no | — | BCrypt |
| `full_name` | VARCHAR(160) | no | — | |
| `role` | VARCHAR(32) | no | — | CHECK `USER,STUDENT,COMPANY,ADMIN` |
| `is_active` | BOOLEAN | no | TRUE | |
| `is_student_verified` | BOOLEAN | no | FALSE | |
| `is_email_verified` | BOOLEAN | no | FALSE | |
| `created_at` | TIMESTAMPTZ | no | — | |
| `updated_at` | TIMESTAMPTZ | no | — | |
| `deleted_at` | TIMESTAMPTZ | yes | — | soft delete |

Indexes: `idx_users_email_active` and `idx_users_phone_active` (V1, partial on `deleted_at IS NULL`);
`uq_users_email_active` on `LOWER(email)` and `uq_users_phone_active` (V2, also partial). V2 drops the
legacy `users_email_key`/`users_phone_key` constraints but **does not drop the V1 indexes**, so both
V1- and V2-named partial unique indexes coexist. [VERIFIED]

### 1.2 Token tables

`refresh_tokens`, `password_reset_tokens`, `email_verification_tokens` share this shape:

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | UUID | no | PK |
| `user_id` | UUID | no | FK → `users(id)` ON DELETE CASCADE (V2) |
| `token_hash` | VARCHAR(255) | no | UNIQUE; stored hashed |
| `expires_at` | TIMESTAMPTZ | no | |
| `created_at` | TIMESTAMPTZ | no | |
| `revoked_at` | TIMESTAMPTZ | yes | refresh only |
| `used_at` | TIMESTAMPTZ | yes | reset/email only |

V1 created per-table `user_id`/`expires_at` indexes; **V3 drops all of them** (repos look up by
`token_hash`, which remains UNIQUE). [VERIFIED: `V3__Drop_unused_token_and_student_verification_indexes.sql`]

### 1.3 `student_verifications`

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | UUID | no | PK |
| `user_id` | UUID | no | UNIQUE, FK → `users(id)` ON DELETE CASCADE |
| `student_id` | VARCHAR(64) | no | |
| `university_email` | VARCHAR(255) | no | case-insensitive unique |
| `status` | VARCHAR(32) | no | CHECK `PENDING,VERIFIED,REJECTED` |
| `verified_at` | TIMESTAMPTZ | yes | |
| `created_at` | TIMESTAMPTZ | no | |
| `updated_at` | TIMESTAMPTZ | no | |

Indexes: `idx_student_verifications_status` (V1) is dropped in V3. `idx_student_verifications_university_email`
(V1) and `uq_student_verifications_university_email` (V4) are both partial name variants over
`LOWER(university_email)`; V1's index is not dropped, so two unique indexes exist. [VERIFIED]

### 1.4 `user_external_identities`

Provider-neutral external identity linkage (Google, and future providers). Added in V5.

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | UUID | no | PK |
| `user_id` | UUID | no | FK → `users(id)` ON DELETE CASCADE |
| `provider` | VARCHAR(32) | no | e.g. `GOOGLE` |
| `provider_subject` | VARCHAR(255) | no | provider-issued stable id (Google `sub`), not email |
| `created_at` | TIMESTAMPTZ | no | |
| `updated_at` | TIMESTAMPTZ | no | |

Constraints/indexes: `uq_user_external_identities_provider_subject` UNIQUE `(provider, provider_subject)`;
`idx_user_external_identities_user_id` on `user_id`. [VERIFIED]

V5 also runs `ALTER TABLE users ALTER COLUMN phone DROP NOT NULL` so provider-created accounts can
exist without a phone (the existing partial unique index keeps non-null phones unique).

---

## 2. user_db — user-profile-service

Migrations: `V1__init_profile_schema`, `V2__profile_extended_fields`,
`V3__Enable_pg_trgm_and_full_name_gin_index`.

### 2.1 `profiles`

| Column | Type | Null | Notes |
|---|---|---|---|
| `user_id` | UUID | no | PK |
| `full_name` | VARCHAR(160) | no | |
| `bio` | TEXT | yes | |
| `avatar_file_id` | UUID | yes | cross-service ref → file_db |
| `avatar_url` | TEXT | yes | |
| `telegram_link` | TEXT | yes | |
| `facebook_link` | TEXT | yes | |
| `university` | VARCHAR(160) | yes | |
| `major` | VARCHAR(160) | yes | |
| `graduation_year` | INTEGER | yes | CHECK `NULL OR BETWEEN 1950 AND 2100` |
| `created_at` | TIMESTAMPTZ | no | default NOW() |
| `updated_at` | TIMESTAMPTZ | no | default NOW() |
| `location` | VARCHAR(160) | yes | V2 |
| `date_of_birth` | DATE | yes | V2 |
| `workplace` | VARCHAR(160) | yes | V2 |
| `portfolio_url` | TEXT | yes | V2 |
| `phone` | VARCHAR(32) | yes | V2 |
| `email` | VARCHAR(160) | yes | V2 |
| `skills` | JSONB | no | V2, default `[]` |
| `education` | JSONB | no | V2, default `[]` |
| `field_visibility` | JSONB | no | V2, default `{}` |

Index: `idx_profiles_full_name_trgm` GIN. **Defect #3:** V1 already created it over `full_name`;
V3 does `CREATE INDEX IF NOT EXISTS ... ON profiles USING GIN (LOWER(full_name) gin_trgm_ops)` —
because the name already exists, the expression index on `LOWER(full_name)` is **never created**.
See [`06-migration-strategy.md`](06-migration-strategy.md) §4.

### 2.2 `user_settings`

| Column | Type | Null | Default | Notes |
|---|---|---|---|---|
| `user_id` | UUID | no | — | PK |
| `language` | VARCHAR(8) | no | `en` | CHECK `en,km` |
| `theme` | VARCHAR(16) | no | `system` | CHECK `light,dark,system` |
| `notification_prefs` | JSONB | no | `{}` | |
| `privacy_prefs` | JSONB | no | `{}` | |
| `fcm_token` | TEXT | yes | — | legacy; device tokens are in notification_db |
| `updated_at` | TIMESTAMPTZ | no | NOW() | |

---

## 3. file_db — file-service

Migrations: `V1__init_file_schema`, `V2__Drop_unused_file_metadata_indexes`,
`V3__File_type_size_checks_and_owner_active_index`.

### 3.1 `file_metadata`

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | UUID | no | PK |
| `owner_user_id` | UUID | no | cross-service ref → auth_db |
| `file_name` | VARCHAR(255) | no | |
| `file_type` | VARCHAR(32) | no | CHECK = `AVATAR,CV,POSTER,VIDEO,CHAT_ATTACHMENT` (V3) |
| `mime_type` | VARCHAR(160) | no | validated against MIME allow-list in service |
| `size_bytes` | BIGINT | no | CHECK `> 0` |
| `bucket` | VARCHAR(64) | no | derived from `StoredFileType` |
| `object_key` | TEXT | no | UNIQUE |
| `created_at` | TIMESTAMPTZ | no | NOW() |
| `deleted_at` | TIMESTAMPTZ | yes | soft delete |

Indexes: `uq_file_metadata_object_key` (UNIQUE), `idx_file_metadata_owner_active` (partial
`deleted_at IS NULL`). `idx_file_metadata_file_type` is dropped in V2 and not recreated.
The V1 CHECK values (`CV,POST_MEDIA,PROFILE_PICTURE,CHAT_ATTACHMENT`) were **replaced**, and the
`StoredFileType` enum values (`AVATAR,CV,POSTER,VIDEO,CHAT_ATTACHMENT`) are the live set. [VERIFIED]

---

## 4. content_db — content-service

Migrations: `V1__init_content_schema`, `V2__Content_indexes_checks_and_drop_dead`,
`V3__Restore_reaction_and_mention_indexes`, `V4__Cascade_deletes_and_no_self_follow`,
`V5__Posts_created_active_partial_index`.

### 4.1 `posts`

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | UUID | no | PK |
| `author_id` | UUID | no | cross-service ref → auth_db |
| `type` | VARCHAR(32) | no | CHECK `VIDEO,POSTER,JOB,STANDARD` (V2) |
| `content` | TEXT | yes | |
| `media_file_id` | UUID | yes | cross-service ref → file_db |
| `job_title` | VARCHAR(180) | yes | |
| `job_description` | TEXT | yes | |
| `job_requirement` | TEXT | yes | |
| `job_deadline` | DATE | yes | |
| `created_at` | TIMESTAMPTZ | no | |
| `updated_at` | TIMESTAMPTZ | no | |
| `deleted_at` | TIMESTAMPTZ | yes | soft delete |

Indexes: `idx_posts_author_created_active` (V2, `author_id, created_at DESC` partial) and
`idx_posts_created_active` (V5, `created_at DESC` partial). **Defect #4:** the DB allows `STANDARD`
but the `PostType` enum only has `VIDEO, POSTER, JOB`, so an entity can never read/write `STANDARD`.

### 4.2 `comments`

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | UUID | no | PK |
| `post_id` | UUID | no | FK → `posts(id)` ON DELETE CASCADE (V4) |
| `author_id` | UUID | no | cross-service ref |
| `text` | TEXT | no | |
| `created_at` | TIMESTAMPTZ | no | |

Index: `idx_comments_post_created` (`post_id, created_at DESC`). `idx_comments_author` dropped in V2.

### 4.3 `mentions`

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | UUID | no | PK |
| `comment_id` | UUID | no | FK → `comments(id)` ON DELETE CASCADE (V4) |
| `mentioned_user_id` | UUID | no | cross-service ref |

Index: `idx_mentions_comment` (restored in V3). `idx_mentions_user` dropped in V2 and not restored.

### 4.4 `reactions`

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | UUID | no | PK |
| `post_id` | UUID | no | FK → `posts(id)` ON DELETE CASCADE (V4) |
| `user_id` | UUID | no | cross-service ref |
| `created_at` | TIMESTAMPTZ | no | |

Constraint: UNIQUE `(post_id, user_id)`. Index: `idx_reactions_post` (restored in V3).

### 4.5 `follows`

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | UUID | no | PK |
| `follower_id` | UUID | no | |
| `following_id` | UUID | no | |
| `created_at` | TIMESTAMPTZ | no | |

Constraints: UNIQUE `(follower_id, following_id)`; CHECK `follower_id <> following_id`.
Indexes: `idx_follows_follower_created`, `idx_follows_following_created` (V2; V1's
`idx_follows_following` is dropped).

---

## 5. career_db — career-service

Migrations: `V1__init_career_schema`, `V2__application_timeline_and_idempotency`, and **two files
sharing `V3`**: `V3__Job_application_composite_indexes_and_status_check` and
`V3__User_cv_file_unique_and_application_fk`.

### 5.1 `user_cvs`

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | UUID | no | PK (per migration) |
| `user_id` | UUID | no | |
| `cv_file_id` | UUID | no | UNIQUE (V1) + unique index `uq_user_cvs_cv_file_id` (V3) |
| `file_name` | VARCHAR(255) | no | |
| `updated_at` | TIMESTAMPTZ | no | |

Index: `idx_user_cvs_user_id` (V1).
**Defect #2:** the `UserCv` entity maps `@Id` to `user_id` (`UserCv.java:18-20`) while the DB PK is
`id`, so the JPA identity semantics are wrong. `[VERIFIED]` The claim that `ddl-auto: validate` does
not currently reject this is `[INFERRED]` from the current setup
(`Inferred from implementation — requires business confirmation.`).

### 5.2 `job_applications`

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | UUID | no | PK |
| `job_post_id` | UUID | no | cross-service ref → content_db |
| `applicant_id` | UUID | no | cross-service ref |
| `cv_file_id` | UUID | no | FK → `user_cvs(cv_file_id)` (V1/V3) |
| `cover_note` | TEXT | yes | |
| `status` | VARCHAR(32) | no | CHECK `PENDING,REVIEWED,ACCEPTED,REJECTED,UNDER_REVIEW,WITHDRAWN` |
| `applied_at` | TIMESTAMPTZ | no | |
| `updated_at` | TIMESTAMPTZ | no | |
| `review_started_at` | TIMESTAMPTZ | yes | V2 |
| `decided_at` | TIMESTAMPTZ | yes | V2 |
| `reviewer_note` | TEXT | yes | V2 |
| `idempotency_key` | VARCHAR(128) | yes | V2 |

Constraints: UNIQUE `(job_post_id, applicant_id)`; unique partial `(applicant_id, idempotency_key)`
WHERE `idempotency_key IS NOT NULL`. Indexes: `idx_job_applications_applicant_applied`,
`idx_job_applications_post_applied` (V3); V1's single-column indexes are dropped.
**Defect #4:** DB CHECK includes `UNDER_REVIEW` and `WITHDRAWN`; `ApplicationStatus` enum only has
`PENDING, REVIEWED, ACCEPTED, REJECTED`.

---

## 6. finance_db — finance-service

Migrations: `V1__init_finance_schema`, `V2__Payment_indexes_and_status_check`,
`V3__Payment_fee_index_and_positive_amount_checks`.

### 6.1 `student_finance_accounts`
`user_id` UUID PK, `student_id` VARCHAR(64) NOT NULL, `linked_at` TIMESTAMPTZ NOT NULL.

### 6.2 `fee_categories`
`id` UUID PK, `name` VARCHAR(120) NOT NULL, `description` TEXT, `created_at` TIMESTAMPTZ NOT NULL.
Seeded: `Tuition` and `Services`.

### 6.3 `fees`
`id` UUID PK, `category_id` UUID FK → `fee_categories(id)`, `name` VARCHAR(180) NOT NULL,
`amount` NUMERIC(14,2) NOT NULL CHECK `> 0`, `currency` VARCHAR(8) NOT NULL, `created_at`.
Index `idx_fees_category_id`. Seeded: Tuition Semester 1/2 (1,500,000 KHR), Library Membership (25,000 KHR).

### 6.4 `payments`

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | UUID | no | PK |
| `user_id` | UUID | no | cross-service ref |
| `fee_id` | UUID | no | FK → `fees(id)` |
| `amount` | NUMERIC(14,2) | no | CHECK `> 0` |
| `currency` | VARCHAR(8) | no | enum `KHR,USD` |
| `status` | VARCHAR(32) | no | CHECK `UNPAID,PAID,OVERDUE,PENDING,CANCELLED` |
| `due_date` | DATE | yes | |
| `paid_at` | TIMESTAMPTZ | yes | |
| `created_at` | TIMESTAMPTZ | no | |
| `updated_at` | TIMESTAMPTZ | no | |

Indexes: `idx_payments_status_due` (`status, due_date`), `idx_payments_user_due_created`
(`user_id, due_date ASC, created_at DESC`), `idx_payments_unpaid_due_date` (partial `status <> 'PAID'`),
`idx_payments_fee_id`. **Defect #4:** DB CHECK includes `PENDING,CANCELLED`; `PaymentStatus` enum is
`UNPAID, PAID, OVERDUE`.

---

## 7. chat_db — chat-service

Migrations: `V1__init_chat_schema`, `V2__message_media_and_reply`,
`V3__cascade_deletes_checks_and_indexes`.

### 7.1 `conversations`
`id` UUID PK, `status` VARCHAR(32) NOT NULL, `created_at`, `updated_at`.
CHECK status ∈ `PENDING,ACTIVE,BLOCKED,DECLINED,ARCHIVED,CLOSED` (V3). Indexes:
`idx_conversations_updated_at`, `idx_conversations_status`.

### 7.2 `conversation_participants`
PK `(conversation_id, user_id)`; `role` VARCHAR(32) CHECK ∈ `REQUESTER,RECIPIENT,MEMBER,ADMIN`;
`joined_at`; FK `conversation_id` → `conversations(id)` ON DELETE CASCADE. Index
`idx_conversation_participants_user`.

### 7.3 `messages`

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | UUID | no | PK |
| `conversation_id` | UUID | no | FK → `conversations(id)` ON DELETE CASCADE |
| `sender_id` | UUID | no | |
| `text` | TEXT | yes | NOT NULL dropped in V2 |
| `message_type` | VARCHAR(16) | no | default `TEXT` |
| `file_id` | UUID | yes | cross-service ref → file_db |
| `reply_to_message_id` | UUID | yes | FK → `messages(id)` |
| `client_message_id` | VARCHAR(64) | yes | idempotency |
| `status` | VARCHAR(32) | no | CHECK `SENT,DELIVERED,READ,DELETED` |
| `deleted_at` | TIMESTAMPTZ | yes | |
| `created_at` | TIMESTAMPTZ | no | |

Indexes: `idx_messages_conversation_created`, `idx_messages_sender`, unique partial
`uq_messages_client_id` (`conversation_id, sender_id, client_message_id` where client id not null).

### 7.4 `blocks`
PK `(blocker_id, blocked_id)`, CHECK no self-block, `created_at`, index `idx_blocks_blocked`.

### 7.5 `user_reports`
`id` PK, `reporter_id`, `reported_id`, `reason` TEXT, `created_at`, CHECK no self-report,
indexes `idx_user_reports_reporter`, `idx_user_reports_reported`.

---

## 8. notification_db — notification-service

Migrations: `V1__init_notification_schema`, `V2__Notification_type_and_platform_checks`,
`V3__Notifications_unread_recency_index`, `V4__notification_ui_upgrade`.

### 8.1 `notifications`

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | UUID | no | PK |
| `user_id` | UUID | no | cross-service ref |
| `type` | VARCHAR(32) | no | CHECK superset (V4) |
| `event` | VARCHAR(64) | yes | V4 |
| `title` | VARCHAR(180) | no | |
| `body` | TEXT | no | |
| `reference_id` | UUID | yes | |
| `reference_type` | VARCHAR(64) | yes | |
| `is_read` | BOOLEAN | no | FALSE |
| `read_at` | TIMESTAMPTZ | yes | V4 |
| `actor_id` | UUID | yes | V4 |
| `actor_name` | VARCHAR(120) | yes | V4 |
| `actor_avatar_url` | TEXT | yes | V4 |
| `destination` | JSONB | yes | V4 |
| `dedupe_key` | VARCHAR(180) | yes | V4 |
| `created_at` | TIMESTAMPTZ | no | |

Indexes: `idx_notifications_user_created`, `idx_notifications_user_unread`
(partial `is_read = FALSE`), `idx_notifications_user_read_created`, unique partial
`ux_notifications_user_dedupe` (`user_id, dedupe_key`). V3's drop of `idx_notifications_user_read`
targets an index that never existed. **Defect #4:** allowed `type` set is larger than the
`NotificationType` enum (see [`05-data-dictionary.md`](05-data-dictionary.md) §8).

### 8.2 `device_tokens`
`id` PK, `user_id`, `fcm_token` TEXT NOT NULL UNIQUE (`uq_device_tokens_fcm_token`),
`platform` VARCHAR(16) CHECK `ANDROID,IOS`, `created_at`, `updated_at`, index `idx_device_tokens_user`.

---

## 9. map_db — map-service

Migration: `V1__init_map_schema`.

### 9.1 `place_favorites`
`id` PK, `user_id`, `google_place_id` VARCHAR(255), `name` VARCHAR(255), `address` VARCHAR(512),
`latitude` DOUBLE PRECISION, `longitude` DOUBLE PRECISION, `category` VARCHAR(64),
`photo_url` VARCHAR(1024), `created_at`, `updated_at`. UNIQUE `(user_id, google_place_id)`.
Index `idx_place_favorites_user_created`.

### 9.2 `place_search_history`
`id` PK, `user_id`, `query` VARCHAR(100), `category` VARCHAR(64), `latitude`,
`longitude`, `radius_m` INT default 1500, `created_at`. Index
`idx_place_search_history_user_created`. Capped to 20 rows/user in application code
(`PlaceSearchHistory.MAX_ENTRIES_PER_USER`).

---

## 10. Documented data defects (do not silently fix)

| # | Defect | Evidence | Impact |
|---|---|---|---|
| 1 | career-service has **duplicate Flyway version `V3`** | two files named `V3__*` | Flyway would fail/reject on a clean migrate; current DB is ahead of a reproducible baseline |
| 2 | career `UserCv` entity `@Id` maps `user_id`, DB PK is `id` | `UserCv.java:18-20` vs `V1__init_career_schema.sql` | wrong identity semantics; risky for future writes |
| 3 | user-profile `LOWER(full_name)` GIN index never created | `V3:7` `CREATE INDEX IF NOT EXISTS` vs V1 existing name | user-search trigram/index intent is a no-op |
| 4 | Enum vs DB CHECK supersets | career/content/chat/finance/notification entities | JPA cannot represent all DB-permitted states; possible read/write failures for `REVIEWED`, `UNDER_REVIEW`, `WITHDRAWN`, `STANDARD`, `ARCHIVED`, `MEMBER`, `DELETED`, `PENDING`/`CANCELLED` payments |
| 5 | `*SmokeIT` tests are **not** run by plain `mvn test` | no failsafe plugin / no auto-run | integration drift can go unnoticed in CI |

These are **VERIFIED** against the repository. They are intentionally **not changed** by this
documentation task. See [`06-migration-strategy.md`](06-migration-strategy.md) for remediation
guidance (also not executed).
