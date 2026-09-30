# career-service

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/career-service/`, `backend/infrastructure/config-repo/career-service.yml`, `backend/services/career-service/src/main/resources/db/migration/`

Part of the Vithey documentation set · Master index:
[`../../00-project-overview/07-document-index.md`](../../00-project-overview/07-document-index.md) ·
Siblings: [Backend architecture](../01-backend-architecture.md) ·
[Microservice architecture](../02-microservice-architecture.md) ·
[Event-driven](../06-event-driven-architecture.md) · [Error handling](../08-error-handling.md) ·
API: [`../../06-api/07-career-api.md`](../../06-api/07-career-api.md).

## 1. Purpose

Owns a user's default CV reference and the job-application workflow (apply, list, view, CV preview,
status update). [VERIFIED]

## 2. Responsibilities

- Store/replace the user's default CV (`user_cvs`) after validating the file is a `CV`.
- Apply to a job post (validates the post is a `JOB` via content-service, CV via file-service);
  idempotent via `Idempotency-Key`.
- List applications (applicant view or poster view), get detail, produce a CV preview link.
- Poster-only status transitions with timeline timestamps and events.

## 3. Port and identity

| Item | Value |
|---|---|
| Port | `8085` (`SERVER_PORT`) |
| Eureka name | `career-service` |
| Database | `career_db` |
| Gateway routes | `/api/v1/users/me/cv`, `/api/v1/job-applications/**` |

[VERIFIED]

## 4. Main controllers

| Controller | Base path | Endpoints |
|---|---|---|
| `UserCvController` | `/api/v1/users/me/cv` | `GET`, `PUT` |
| `JobApplicationController` | `/api/v1/job-applications` | `POST`, `GET`, `GET /{id}`, `GET /{id}/cv-preview`, `PATCH /{id}/status` |

[VERIFIED]

## 5. Main services

| Service | Responsibility |
|---|---|
| `JobApplicationService` | Apply/list/get/status; idempotency; poster authorization; publish events |
| `UserCvService` | Get/set default CV (validates file type `CV`) |
| `UpstreamValidationService` | Feign lookups: job post must be `JOB`; CV file must be `CV`; poster check |
| `JobApplicationResponseBuilder` | Assemble responses using content + file + profile lookups |

[VERIFIED]

## 6. Repositories

`JobApplicationRepository`, `UserCvRepository`. [VERIFIED]

## 7. Entities and tables (`career_db`)

| Entity | Table | Notes |
|---|---|---|
| `JobApplication` | `job_applications` | `job_post_id`, `applicant_id`, `cv_file_id`, `cover_note`, `status`, timeline timestamps, `reviewer_note`, `idempotency_key` |
| `UserCv` | `user_cvs` | PK mapped as `user_id` |

`ApplicationStatus`: `PENDING | REVIEWED | ACCEPTED | REJECTED`. [VERIFIED]

## 8. Database

Flyway: `V1__init_career_schema.sql`, `V2__application_timeline_and_idempotency.sql`,
`V3__Job_application_composite_indexes_and_status_check.sql`,
`V3__User_cv_file_unique_and_application_fk.sql`. `ddl-auto: validate`.

**Known defects (documented, not fixed):**
1. **Duplicate Flyway version `V3`** — two migration files share version 3 (Flyway conflict).
2. `UserCv` entity `@Id` maps `user_id` while the DB primary key is `id`.
3. DB `CHECK` also permits `UNDER_REVIEW`/`WITHDRAWN` (enum superset — defect #4).

[VERIFIED: `EVIDENCE-BASIS.md` §8]

## 9. API routes

See [`../../06-api/07-career-api.md`](../../06-api/07-career-api.md). Status update is restricted to
the job poster in service logic (not `@PreAuthorize`).

## 10. Events

| Direction | Routing keys |
|---|---|
| Produces | `job.application.submitted`, `job.application.status_changed` |

No consumers. Notification-service consumes both. [VERIFIED]

## 11. Cache usage

None. [VERIFIED]

## 12. External dependencies

- Feign `ContentServiceClient` → `GET /api/v1/posts/{postId}` (job post + author/poster).
- Feign `FileServiceClient` → `GET /api/v1/files/{fileId}` (CV metadata/preview).
- Feign `UserProfileClient` → `GET /api/v1/users/{userId}` (applicant profile).
- RabbitMQ for events. [VERIFIED]

## 13. Auth and authorization

All endpoints require JWT. Apply/list scope by JWT subject; detail/view requires applicant or poster;
status update poster-only. [VERIFIED]

## 14. Configuration (env names only)

`SERVER_PORT`, `CAREER_DB_URL`, `CAREER_DB_USERNAME`, `CAREER_DB_PASSWORD`, `RABBITMQ_*`,
`EUREKA_CLIENT_ENABLED`, `EUREKA_URL`, `VITHEY_JWT_SECRET`, `VITHEY_EVENTS_EXCHANGE`. [VERIFIED]

## 15. Health checks

`GET /actuator/health`. [VERIFIED]

## 16. Tests

| Type | Path |
|---|---|
| Context (H2) | `CareerServiceContextTest.java` |
| Smoke (Postgres+Rabbit) | `CareerServiceSmokeIT.java` |
| Unit | `service/JobApplicationServiceTest.java` |

Test implemented — current execution result not independently verified.

## 17. Known limitations / TBD

- Duplicate Flyway `V3` will fail a clean `flyway migrate` (`EVIDENCE-BASIS.md` §8 defect 1).
- `UserCv @Id`/PK mismatch (defect 2).
- Whether `organization`/`job_title` are enriched or left null: `TBD — Requires confirmation.`
- `GET /job-applications` without `job_post_id` returns only the caller's applications.
