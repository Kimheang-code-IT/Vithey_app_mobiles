# Data Security

> Status: Verified baseline (code-level) · Last reviewed: 2026-09-30
> Evidence: `backend/services/*/src/main/resources/db/migration/*.sql`, `backend/infrastructure/config-repo/application.yml`, `backend/services/auth-service/.../util/TokenHash.java`, `vithey_app/lib/data/local/isar/`, `vithey_app/lib/core/storage/`
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md` §5, §8, §13

## 1. Data classification (as observed)

| Data | Where it lives | Protection | Tag |
| --- | --- | --- | --- |
| Passwords | `auth_db.users.password_hash` | bcrypt hash | [VERIFIED] |
| Refresh tokens | `auth_db.refresh_tokens.token_hash` | SHA-256 hash, unique | [VERIFIED] |
| Reset tokens | `auth_db.password_reset_tokens.token_hash` | SHA-256 hash, unique, single-use | [VERIFIED] |
| Email-verify tokens | `auth_db.email_verification_tokens.token_hash` | SHA-256 hash, unique, single-use | [VERIFIED] |
| Student verification (`student_id`, `university_email`) | `auth_db.student_verifications` | Plaintext columns; unique on lower(university_email) | [VERIFIED] `V1__init_auth_schema.sql` |
| Profile PII (name, bio, avatar, major, location) | `user_db.profiles` | Plaintext; `public` schema | [VERIFIED] |
| Posts / comments / messages | `content_db`, `chat_db` | Plaintext | [VERIFIED] |
| Files (avatar/CV/poster/video) | MinIO objects + `file_db.file_metadata` | MIME allow-list, size caps, filename sanitisation | [VERIFIED] `FileValidationService` |
| Device tokens & access tokens | Device keychain/keystore | `flutter_secure_storage` | [VERIFIED] |
| Chat cache / outbox | On-device Isar (`chat` only) | App-private storage | [VERIFIED] |

## 2. Data isolation

- **One database per service**, each with its own Flyway migrations; no shared DB.
  [VERIFIED] `init-databases.sql`, service `application.yml`.
- Services talk over HTTP (via Eureka/Feign) and RabbitMQ, not direct DB access.
- Postgres/Redis/RabbitMQ/MinIO are **localhost-bound in the demo compose** and reached over
  the Docker network in the stack; they are not exposed as public endpoints in the documented
  demo. [VERIFIED] `docker-compose.demo.yml`, port map in EVIDENCE-BASIS §3.

## 3. Encryption

| Layer | Status | Tag |
| --- | --- | --- |
| Password hashing | bcrypt | [VERIFIED] |
| Opaque token hashing | SHA-256 (random, high-entropy tokens) | [VERIFIED] |
| JWT signing | HMAC | [VERIFIED] |
| TLS in transit | Not configured in code; expected to be terminated by a deployment edge that does not yet exist | [TBD] TBD — Requires confirmation. |
| Encryption at rest (DB/MinIO/backups) | No repository evidence | [TBD] TBD — Requires confirmation. |
| Field-level encryption for PII | None implemented | [VERIFIED — absence] |

> **Note:** local development/demo uses plain HTTP (`http://10.0.2.2:8080/api/v1`). No staging
> or production environment exists in which TLS could be verified. [VERIFIED] EVIDENCE-BASIS §9.

## 4. Token & secret at-rest handling

- Raw refresh/reset/verify tokens are **never stored**; only SHA-256 digests are persisted,
  so a database read does not yield usable tokens. [VERIFIED] `TokenHash.java`, migrations.
- File objects in MinIO are referenced by presigned URLs (1-hour validity on upload/metadata),
  limiting direct object exposure. [VERIFIED] `FileController.java` (docs), `FileMetadataService`.
- CV downloads are owner-only; other media types require authentication but are not
  owner-scoped. [VERIFIED] `FileController.java:83`.

## 5. Soft delete & data lifecycle

- `users` supports soft delete (`deleted_at`) with partial unique indexes on active rows.
  [VERIFIED] `V1__init_auth_schema.sql:16-17`, `V2__Soft_delete_unique_email_phone_and_cascade_tokens.sql`.
- Token tables cascade on user delete (`ON DELETE CASCADE`). [VERIFIED]
- No documented data-retention or right-to-erasure workflow. [TBD] TBD — Requires confirmation.

## 6. Client-side data

- Only chat persistence uses Isar (conversations, messages, outbox); no other local DB.
  [VERIFIED] EVIDENCE-BASIS §7.
- Secure storage holds only `access_token` and `refresh_token`. [VERIFIED]
  `secure_storage_service.dart`.
- `shared_preferences` holds non-secret settings (e.g. notification prefs, theme).
  [VERIFIED] EVIDENCE-BASIS §7.

## 7. Observations & risks

| # | Observation | Severity | Evidence |
| --- | --- | --- | --- |
| D1 | No TLS enforcement anywhere in code; plain-HTTP local demo | High (for production) | `app_config.dart` default; `vithey_app/.env.example` |
| D2 | PII (student id, university email, profile) stored in plaintext columns | Medium | migrations |
| D3 | No at-rest encryption for databases/MinIO documented | Medium | `docker-compose.demo.yml` |
| D4 | Demo datastore credentials are trivial placeholders (`postgres`/`guest`) in `.env.example` | Medium (non-prod) | `backend/.env.example`, service `.env.example` |
| D5 | No retention/erasure policy documented | Low | absence |
| D6 | Non-CV file downloads are authenticated but not owner-scoped by design | Low | `FileController.java` |

**Not yet formally assessed.** See [10-vulnerability-assessment.md](10-vulnerability-assessment.md).

## 8. Cross-references

- [04-JWT-security.md](04-JWT-security.md) · [05-password-security.md](05-password-security.md) · [08-secrets-management.md](08-secrets-management.md)
- Data model: `../05-database/01-database-overview.md`
- Network/transport: `../03-system-design/07-network-architecture.md`
