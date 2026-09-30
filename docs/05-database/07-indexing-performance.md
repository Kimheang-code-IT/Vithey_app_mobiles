# Indexing & Performance

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/*/src/main/resources/db/migration/*.sql`, service caches in `chat-service` / `map-service` / `api-gateway`

## 1. Index inventory (post-migration)

### auth_db
| Index | Table | Definition | Kind |
|---|---|---|---|
| `idx_users_email_active` | users | `(lower(email)) WHERE deleted_at IS NULL` | partial unique (V1) |
| `idx_users_phone_active` | users | `(phone) WHERE deleted_at IS NULL` | partial unique (V1) |
| `uq_users_email_active` | users | `(LOWER(email)) WHERE deleted_at IS NULL` | partial unique (V2) |
| `uq_users_phone_active` | users | `(phone) WHERE deleted_at IS NULL` | partial unique (V2) |
| `refresh_tokens.token_hash` | refresh_tokens | UNIQUE | unique |
| `password_reset_tokens.token_hash` | password_reset_tokens | UNIQUE | unique |
| `email_verification_tokens.token_hash` | email_verification_tokens | UNIQUE | unique |
| `idx_student_verifications_university_email` | student_verifications | `(lower(university_email))` | unique (V1) |
| `uq_student_verifications_university_email` | student_verifications | `(LOWER(university_email))` | unique (V4) |

`user_id`/`expires_at`/`status` indexes were deliberately dropped in V3 (token lookup is by hash).

### user_db
| Index | Table | Definition | Kind |
|---|---|---|---|
| `idx_profiles_full_name_trgm` | profiles | `USING GIN (full_name gin_trgm_ops)` | GIN (V1) |
| intended `LOWER(full_name)` GIN | profiles | never created (V3 no-op — defect #3) | — |

### file_db
| Index | Table | Definition |
|---|---|---|
| `uq_file_metadata_object_key` | file_metadata | UNIQUE `(object_key)` |
| `idx_file_metadata_owner_active` | file_metadata | `(owner_user_id) WHERE deleted_at IS NULL` |

`idx_file_metadata_file_type` was dropped in V2 and not recreated.

### content_db
| Index | Table | Definition |
|---|---|---|
| `idx_posts_author_created_active` | posts | `(author_id, created_at DESC) WHERE deleted_at IS NULL` |
| `idx_posts_created_active` | posts | `(created_at DESC) WHERE deleted_at IS NULL` |
| `idx_comments_post_created` | comments | `(post_id, created_at DESC)` |
| `idx_mentions_comment` | mentions | `(comment_id)` |
| `reactions uq_reactions_post_user` | reactions | UNIQUE `(post_id, user_id)` |
| `idx_reactions_post` | reactions | `(post_id)` |
| `idx_follows_follower_created` | follows | `(follower_id, created_at DESC)` |
| `idx_follows_following_created` | follows | `(following_id, created_at DESC)` |
| `uq_follows_pair` | follows | UNIQUE `(follower_id, following_id)` |

### career_db
| Index | Table | Definition |
|---|---|---|
| `idx_user_cvs_user_id` | user_cvs | `(user_id)` |
| `uq_user_cvs_cv_file_id` | user_cvs | UNIQUE `(cv_file_id)` |
| `uq_job_applications_post_applicant` | job_applications | UNIQUE `(job_post_id, applicant_id)` |
| `idx_job_applications_applicant_applied` | job_applications | `(applicant_id, applied_at DESC)` |
| `idx_job_applications_post_applied` | job_applications | `(job_post_id, applied_at DESC)` |
| `uq_job_applications_applicant_idempotency` | job_applications | UNIQUE `(applicant_id, idempotency_key) WHERE idempotency_key IS NOT NULL` |

### finance_db
| Index | Table | Definition |
|---|---|---|
| `idx_fees_category_id` | fees | `(category_id)` |
| `idx_payments_status_due` | payments | `(status, due_date)` |
| `idx_payments_user_due_created` | payments | `(user_id, due_date ASC, created_at DESC)` |
| `idx_payments_unpaid_due_date` | payments | `(due_date) WHERE status <> 'PAID'` |
| `idx_payments_fee_id` | payments | `(fee_id)` |

### chat_db
| Index | Table | Definition |
|---|---|---|
| PK | conversation_participants | `(conversation_id, user_id)` |
| `idx_conversation_participants_user` | conversation_participants | `(user_id)` |
| `idx_messages_conversation_created` | messages | `(conversation_id, created_at DESC)` |
| `idx_messages_sender` | messages | `(sender_id)` |
| `uq_messages_client_id` | messages | UNIQUE `(conversation_id, sender_id, client_message_id) WHERE client_message_id IS NOT NULL` |
| `idx_conversations_updated_at` | conversations | `(updated_at DESC)` |
| `idx_conversations_status` | conversations | `(status)` |
| PK | blocks | `(blocker_id, blocked_id)` |
| `idx_blocks_blocked` | blocks | `(blocked_id)` |
| `idx_user_reports_reporter` / `_reported` | user_reports | `(reporter_id)` / `(reported_id)` |

### notification_db
| Index | Table | Definition |
|---|---|---|
| `idx_notifications_user_created` | notifications | `(user_id, created_at DESC)` |
| `idx_notifications_user_unread` | notifications | `(user_id, created_at DESC) WHERE is_read = FALSE` |
| `idx_notifications_user_read_created` | notifications | `(user_id, is_read, created_at DESC)` |
| `ux_notifications_user_dedupe` | notifications | UNIQUE `(user_id, dedupe_key) WHERE dedupe_key IS NOT NULL` |
| `uq_device_tokens_fcm_token` | device_tokens | UNIQUE `(fcm_token)` |
| `idx_device_tokens_user` | device_tokens | `(user_id)` |

### map_db
| Index | Table | Definition |
|---|---|---|
| `uq_place_favorites_user_place` | place_favorites | UNIQUE `(user_id, google_place_id)` |
| `idx_place_favorites_user_created` | place_favorites | `(user_id, created_at DESC)` |
| `idx_place_search_history_user_created` | place_search_history | `(user_id, created_at DESC)` |

## 2. Design patterns

- **Soft-delete-aware indexes everywhere.** Feed/read paths filter `deleted_at IS NULL`, and indexes
  are partial to keep them small (`posts`, `file_metadata`, `users`).
- **Recency-ordered composites.** `(owner, created_at DESC)` indexes back the feed, lists, and
  notification inbox.
- **Idempotency via partial unique indexes.** `idempotency_key`, `client_message_id`, and
  `dedupe_key` are protected only when non-null so normal inserts are unaffected.
- **No cross-database indexes.** References to other services' UUIDs are plain columns; joins
  happen in the application, not the DB.

## 3. Known index issue

The user-search trigram index is effectively a **no-op** (defect #3). `profiles` is indexed with
`GIN (full_name gin_trgm_ops)` from V1, but the V3 intent was `GIN (LOWER(full_name) gin_trgm_ops)`
to match the case-insensitive `ILIKE` search in `UserSearchService`. Because the index name already
exists, the case-folding expression index is skipped. Consequence: search correctness is
unaffected, but the planner cannot use a case-folded trigram index. See
[`06-migration-strategy.md`](06-migration-strategy.md) §4.

## 4. Application-level caches (not DB)

| Cache | Store | Key | TTL | Source |
|---|---|---|---|---|
| Gateway rate limit | Redis | per client (`#{@rateLimitKeyResolver}`) | sliding window | `api-gateway.yml` |
| Chat recent messages | Redis | `chat:recent:*` | 24 h | `MessageCacheService.java:13-14` |
| Chat presence | Redis | presence key | 90 s (`presenceTtlSeconds`) | `ChatProperties.java`, `PresenceService.java` |
| Chat typing | Redis | typing key | 5 s (`typingTtlSeconds`) | `ChatProperties.java`, `TypingService.java` |
| Map search results | Redis | `places:search:{hash}` | 5 min | `PlaceCacheService.SEARCH_TTL` |
| Map place detail | Redis | `places:detail:{id}` | 24 h | `PlaceCacheService.DETAIL_TTL` |

Map cache degrades gracefully on Redis failure ("cache miss / no-op"). The extraction cache and LLM
rate limiter in `ai_core` are in-process, not Redis.

## 5. Pooling and tuning knobs

| Knob | Default | Where |
|---|---|---|
| `DB_POOL_MAX` (Hikari max pool) | 5 | `config-repo/application.yml` |
| `DB_POOL_MIN` (Hikari min idle) | 1 | `config-repo/application.yml` |
| `VITHEY_GATEWAY_RATE_LIMIT_REPLENISH` / `BURST` | 100 / 100 | gateway |
| Places-specific rate limit | 30 / 60 | gateway `map-service` route |

## 6. TBD

- No `EXPLAIN`/slow-query baselines or index-usage metrics are captured in the repo:
  `TBD — Requires confirmation.`
- Production index strategy / PgBouncer / read replicas: `TBD — Requires confirmation.`
