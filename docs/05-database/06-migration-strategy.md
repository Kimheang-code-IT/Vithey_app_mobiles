# Migration Strategy

> Status: Partially complete · Last reviewed: 2026-09-30
> Evidence: `backend/services/*/src/main/resources/db/migration/*.sql`, `backend/services/*/src/main/resources/application.yml`, `backend/infrastructure/config-repo/application.yml`, `AGENTS.md`

## 1. How migrations run

- Tool: **Flyway**, enabled per service. Configuration in each service `application.yml`:
  `spring.flyway.enabled: true`, `spring.flyway.locations: classpath:db/migration`.
  [VERIFIED: e.g. `backend/services/auth-service/src/main/resources/application.yml:21-23`]
- Migration files are versioned `V<n>__<snake_case_description>.sql`, one folder per service.
- Hibernate runs with `ddl-auto: validate`, so the schema must match the entities exactly after
  Flyway completes. [VERIFIED: `config-repo/application.yml:6-8`]
- Flyway history table is the default `flyway_schema_history` inside each database.
- Local DB reset: `.\scripts\docker-down-demo.ps1 -v` wipes the Postgres volume so migrations
  re-run from scratch. [VERIFIED: `AGENTS.md`, `backend/scripts/docker-down-demo.ps1`]

## 2. Migration inventory

| Service / DB | Files (ordered) | Versions |
|---|---|---|
| auth / `auth_db` | `V1__init_auth_schema`, `V2__Soft_delete_unique_email_phone_and_cascade_tokens`, `V3__Drop_unused_token_and_student_verification_indexes`, `V4__Student_verification_cascade_and_university_email_unique` | V1–V4 |
| user-profile / `user_db` | `V1__init_profile_schema`, `V2__profile_extended_fields`, `V3__Enable_pg_trgm_and_full_name_gin_index` | V1–V3 |
| file / `file_db` | `V1__init_file_schema`, `V2__Drop_unused_file_metadata_indexes`, `V3__File_type_size_checks_and_owner_active_index` | V1–V3 |
| content / `content_db` | `V1__init_content_schema`, `V2__Content_indexes_checks_and_drop_dead`, `V3__Restore_reaction_and_mention_indexes`, `V4__Cascade_deletes_and_no_self_follow`, `V5__Posts_created_active_partial_index` | V1–V5 |
| career / `career_db` | `V1__init_career_schema`, `V2__application_timeline_and_idempotency`, `V3__Job_application_composite_indexes_and_status_check`, **`V3__User_cv_file_unique_and_application_fk`** | V1–V2 + **duplicate V3** |
| finance / `finance_db` | `V1__init_finance_schema`, `V2__Payment_indexes_and_status_check`, `V3__Payment_fee_index_and_positive_amount_checks` | V1–V3 |
| chat / `chat_db` | `V1__init_chat_schema`, `V2__message_media_and_reply`, `V3__cascade_deletes_checks_and_indexes` | V1–V3 |
| notification / `notification_db` | `V1__init_notification_schema`, `V2__Notification_type_and_platform_checks`, `V3__Notifications_unread_recency_index`, `V4__notification_ui_upgrade` | V1–V4 |
| map / `map_db` | `V1__init_map_schema` | V1 |

Total migration files: **30** (career has 4 files but only 3 distinct versions).

## 3. Applied migration conventions (observed)

- **Idempotency guards:** several later migrations use `IF EXISTS` / `IF NOT EXISTS` or
  `DO $$ ... pg_constraint ... $$` blocks so they can re-run in already-provisioned environments
  (e.g. `content V4`, `finance V3`, `chat V3`).
- **Replace, don't stack:** CHECK constraints are dropped and re-added under the same name to widen
  the value set (e.g. `posts.type`, `payments.status`, `conversations.status`).
- **Partial indexes dominate:** uniqueness and feed indexes use `WHERE deleted_at IS NULL` or
  `WHERE is_read = FALSE`; soft-delete safety relies on these.
- **Never edit an applied migration:** per `AGENTS.md`, add a new version instead; a checksum
  mismatch blocks Flyway.

## 4. Documented data defects (VERIFIED — do not silently fix)

### Defect #1 — career-service duplicate Flyway version `V3`

Two files share version 3:
- `V3__Job_application_composite_indexes_and_status_check.sql`
- `V3__User_cv_file_unique_and_application_fk.sql`

Flyway identifies migrations by version, so a clean database cannot apply both deterministically —
it will reject the duplicate version. `V1__init_career_schema.sql` already declares
`cv_file_id UUID NOT NULL UNIQUE` and the `fk_job_applications_cv_file` FK, and
`V3__User_cv_file_unique_and_application_fk.sql` re-adds both (`CREATE UNIQUE INDEX
uq_user_cvs_cv_file_id` and the FK). The composite-index/status file is the other `V3`. The current
running databases were migrated before both files existed (or by a non-standard path), so they are
**ahead of a reproducible baseline**.

Remediation guidance (not executed): rename one of the two files to a new, unused version
(e.g. `V4__User_cv_file_unique_and_application_fk.sql`) after confirming neither has been applied
under that version in any environment. Because editing/renaming applied migrations risks checksum
mismatches, the change must be coordinated with a DB reset or a Flyway repair.

### Defect #2 — career `UserCv` `@Id` mismatch

`UserCv.java:18-20` annotates `user_id` as `@Id`, but the table PK is `id`
(`V1__init_career_schema.sql:2`). The JPA identity/proxy semantics are therefore wrong (e.g.
`findById` would use `user_id`). `[VERIFIED]` The observation that Hibernate `validate` does not
currently fail is `[INFERRED]`
(`Inferred from implementation — requires business confirmation.`). Remediation: either map `id` as
`@Id` and add a unique constraint on `user_id`, or add an `id` column consistently.

### Defect #3 — user-profile trigram index no-op

`V1__init_profile_schema.sql:30` creates `idx_profiles_full_name_trgm` GIN over `full_name`.
`V3__Enable_pg_trgm_and_full_name_gin_index.sql:7` then runs
`CREATE INDEX IF NOT EXISTS idx_profiles_full_name_trgm ON profiles USING GIN (LOWER(full_name)
gin_trgm_ops)`. Because the index name already exists, the `IF NOT EXISTS` short-circuits and the
expression index intended for `UserSearchService` is **not created**. Search still works via
`ILIKE` but without the intended trigram optimisation.

Remediation guidance (not executed): add a new migration that first `DROP INDEX
idx_profiles_full_name_trgm` then `CREATE INDEX` on `LOWER(full_name)`, or give the expression
index a new name.

### Defect #4 — enum vs DB CHECK supersets

Career/content/chat/finance/notification DB CHECK constraints permit states the Java enums cannot
represent (details in [`05-data-dictionary.md`](05-data-dictionary.md) §1). Practical impact:
reading a row in a DB-only state (e.g. `REVIEWED`, `UNDER_REVIEW`, `STANDARD`, `ARCHIVED`,
`MEMBER`, payment `PENDING`/`CANCELLED`) can raise an enum conversion error, and the application
cannot produce those states. Remediation: either extend the enums to match the DB or tighten the
CHECK constraints, per service.

### Defect #5 — `*SmokeIT` not auto-run

`*SmokeIT` classes are Testcontainers integration tests, but no Maven Failsafe plugin is configured
and `mvn test` only runs Surefire `*Test`/`*ContextTest`. Docker-gated smoke tests therefore do not
execute in the default build. Remediation guidance (not executed): add Failsafe configuration so
`*IT` runs during `verify`.

## 5. Naming and review rules for new migrations

1. Version must be unused in that service. Check for duplicate versions before merging (defect #1
   is the cautionary example).
2. One concern per migration; use `V<n>__lower_snake_case.sql`.
3. Never modify an applied file — add a new version (checksum safety).
4. Prefer idempotent DDL (`IF EXISTS`/`IF NOT EXISTS`, `DO $$` guard blocks) for constraint/index
   changes.
5. Keep entity and CHECK vocabularies in sync (defect #4).
6. After editing schema, run `flutter`/backend tests relevant to the service and reset local DBs
   with `docker-down-demo.ps1 -v` when verifying a clean migrate.

## 6. TBD

- Which of the two `V3` files was actually applied in the currently running demo databases, and
  whether any environment has both: `TBD — Requires confirmation.`
- Formal migration rollback strategy (down-migrations are not used; no rollback scripts exist):
  `TBD — Requires confirmation.`
- Automated migration verification in CI beyond service build: `TBD — Requires confirmation.`

## 7. Cross-links

- Schema detail: [`03-database-schema.md`](03-database-schema.md)
- Backup/restore: [`08-backup-restore.md`](08-backup-restore.md)
- Indexing: [`07-indexing-performance.md`](07-indexing-performance.md)
