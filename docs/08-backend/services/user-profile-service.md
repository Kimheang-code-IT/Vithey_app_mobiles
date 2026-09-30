# user-profile-service

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/user-profile-service/`, `backend/infrastructure/config-repo/user-profile-service.yml`

Part of the Vithey documentation set · Master index:
[`../../00-project-overview/07-document-index.md`](../../00-project-overview/07-document-index.md) ·
Siblings: [Backend architecture](../01-backend-architecture.md) ·
[Microservice architecture](../02-microservice-architecture.md) ·
[Event-driven](../06-event-driven-architecture.md) · [Error handling](../08-error-handling.md) ·
API: [`../../06-api/04-user-profile-api.md`](../../06-api/04-user-profile-api.md).

## 1. Purpose

Owns user profile data (bio, education, skills, links, visibility), app settings
(language/theme/notifications/privacy) and user search. [VERIFIED]

## 2. Responsibilities

- Serve and update the authenticated user's profile and avatar reference.
- Apply field visibility when returning another user's public profile.
- Manage `user_settings` and upsert a default profile/settings row on registration.
- Search users by full name (case-insensitive `ILIKE`, trigram-intended index).
- Publish `profile.updated` on mutations.

## 3. Port and identity

| Item | Value |
|---|---|
| Port | `8082` (`SERVER_PORT`) |
| Eureka name | `user-profile-service` |
| Database | `user_db` |
| Gateway route | `/api/v1/users/**` (order 1 catch-all) |

[VERIFIED]

## 4. Main controllers

| Controller | Base path | Endpoints |
|---|---|---|
| `UserController` | `/api/v1/users` | `GET /search`, `GET /me`, `GET /{userId}`, `PATCH /me`, `PATCH /me/avatar` |
| `SettingsController` | `/api/v1/users/me/settings` | `GET`, `PATCH` |

[VERIFIED]

## 5. Main services

| Service | Responsibility |
|---|---|
| `ProfileService` | Read/update profile, resolve avatar via file-service, create profile on registration, publish `profile.updated` |
| `ProfileVisibilityService` | Map entity → public/owner response; redact `phone`/`email` unless public |
| `SettingsService` | Language/theme/notification/privacy prefs, default settings creation |
| `UserSearchService` | `ILIKE` search with min length 2, page ≤ 100, limit ≤ 50, escaped wildcards |

[VERIFIED]

## 6. Repositories

`ProfileRepository` (also `searchByFullName` and `findLanguageThemeByUserId` projections),
`UserSettingsRepository`. [VERIFIED]

## 7. Entities and tables (`user_db`)

| Entity | Table | Notes |
|---|---|---|
| `Profile` | `profiles` | PK `user_id`; jsonb `skills` (`{name, proficiency}`), `education` (string[]), `field_visibility` map; `avatar_file_id`/`avatar_url` cross-service reference |
| `UserSettings` | `user_settings` | PK `user_id`; `language`, `theme`, jsonb `notification_prefs`/`privacy_prefs`, `fcm_token` |

Enums `AppLanguage` (`en`/`km`), `AppTheme` (`light`/`dark`/`system`), `FieldVisibility`. [VERIFIED]

## 8. Database

Flyway: `V1__init_profile_schema.sql`, `V2__profile_extended_fields.sql`,
`V3__Enable_pg_trgm_and_full_name_gin_index.sql` (3). `ddl-auto: validate`.

**Known defect:** the V3 trigram index is created with `IF NOT EXISTS`, so the intended
`LOWER(full_name)` GIN index is a no-op (documented, not fixed). [VERIFIED: `EVIDENCE-BASIS.md` §8
defect 3]

## 9. API routes

See [`../../06-api/04-user-profile-api.md`](../../06-api/04-user-profile-api.md). Route ownership
note: `/users/me/cv` → career, `/users/*/follow|followers|following|posts` → content,
`/users/*/report` → chat; the rest → this service.

## 10. Events

| Direction | Routing key | Payload |
|---|---|---|
| Produces | `profile.updated` | `ProfileUpdatedEvent(userId, updatedAt)` (no known consumer) |
| Consumes | `user.registered` (queue `user-profile.user.registered`) | `UserRegisteredEvent` → creates profile + default settings |

Consumer uses INFERRED type precedence + trusted packages to read auth's payload type. [VERIFIED]

## 11. Cache usage

None. [VERIFIED]

## 12. External dependencies

- Feign `FileServiceClient` → `GET /api/v1/files/{fileId}` (validate avatar file, type `AVATAR`,
  owner check). Called **outside** the DB transaction to avoid holding a Hikari connection.
- RabbitMQ for produce/consume. [VERIFIED]

## 13. Auth and authorization

All endpoints require JWT. Ownership is enforced by using the JWT subject (`CurrentUserProvider`);
the public profile projection redacts private fields. [VERIFIED]

## 14. Configuration (env names only)

`SERVER_PORT`, `USER_DB_URL`, `USER_DB_USERNAME`, `USER_DB_PASSWORD`, `RABBITMQ_*`,
`EUREKA_CLIENT_ENABLED`, `EUREKA_URL`, `VITHEY_JWT_SECRET`, `VITHEY_EVENTS_EXCHANGE`. [VERIFIED]

## 15. Health checks

`GET /actuator/health`. [VERIFIED]

## 16. Tests

| Type | Path |
|---|---|
| Context (H2) | `UserProfileServiceContextTest.java` |
| Smoke (Postgres+Rabbit) | `UserProfileServiceSmokeIT.java` |
| Unit | `service/ProfileServiceTest.java`, `service/UserSearchServiceTest.java` |

Test implemented — current execution result not independently verified.

## 17. Known limitations / TBD

- Trigram index no-op (defect above) may slow `ILIKE` search at scale.
- Exact field-visibility projection semantics: `TBD — Requires confirmation.`
- Whether `user_settings.fcm_token` is superseded by the notification device-token API:
  `TBD — Requires confirmation.`
