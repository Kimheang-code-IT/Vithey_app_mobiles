# finance-service

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/finance-service/`, `backend/infrastructure/config-repo/finance-service.yml`, `backend/services/finance-service/src/main/resources/db/migration/`

Part of the Vithey documentation set · Master index:
[`../../00-project-overview/07-document-index.md`](../../00-project-overview/07-document-index.md) ·
Siblings: [Backend architecture](../01-backend-architecture.md) ·
[Microservice architecture](../02-microservice-architecture.md) ·
[Event-driven](../06-event-driven-architecture.md) · [Error handling](../08-error-handling.md) ·
API: [`../../06-api/08-finance-api.md`](../../06-api/08-finance-api.md).

## 1. Purpose

Serves the student finance surface: fee catalogue, a student's payments and due/overdue alerts.
Read-only REST today; writes are event-driven. [VERIFIED]

## 2. Responsibilities

- Expose fee categories and fees to verified students.
- Serve a student's payments (pagination) and effective status (due date can override stored status).
- Compute upcoming/overdue alerts within `alert-due-days`.
- On `student.verified`, create `student_finance_accounts` and seed demo payments.
- Run a scheduled job that flags overdue payments and publishes `payment.due`/`payment.overdue`.

## 3. Port and identity

| Item | Value |
|---|---|
| Port | `8086` (`SERVER_PORT`) |
| Eureka name | `finance-service` |
| Database | `finance_db` |
| Gateway routes | `/api/v1/fees/**`, `/api/v1/payments/**` |

[VERIFIED]

## 4. Main controllers

| Controller | Base path | Enforced role | Endpoints |
|---|---|---|---|
| `FeeController` | `/api/v1/fees` | `@PreAuthorize("hasRole('STUDENT')")` | `GET`, `GET /categories` |
| `PaymentController` | `/api/v1/payments` | `@PreAuthorize("hasRole('STUDENT')")` | `GET`, `GET /alerts`, `GET /{paymentId}` |

Both controllers also call `requireStudent()` via `CurrentUserProvider`. [VERIFIED]

## 5. Main services

| Service | Responsibility |
|---|---|
| `FeeService` | Fee + category listing (requires finance account) |
| `PaymentService` | List/detail/alerts; `effectiveStatus` (due date → `OVERDUE`) |
| `StudentFinanceAccountService` | Account creation on verification; demo payment seeding; `requireAccount` gate |
| `PaymentAlertScheduler` | `@Scheduled` cron; marks overdue and publishes events |

[VERIFIED]

## 6. Repositories

`PaymentRepository` (incl. `findOverdueCandidates`, `findDueSoonCandidates`),
`FeeRepository`, `FeeCategoryRepository`, `StudentFinanceAccountRepository`. [VERIFIED]

## 7. Entities and tables (`finance_db`)

| Entity | Table |
|---|---|
| `StudentFinanceAccount` | `student_finance_accounts` (PK `user_id`, `student_id`, `linked_at`) |
| `FeeCategory` | `fee_categories` |
| `Fee` | `fees` (`category_id`, `name`, `amount`, `currency`) |
| `Payment` | `payments` (`user_id`, `fee_id`, `amount`, `currency`, `status`, `due_date`, `paid_at`) |

Enums `PaymentStatus` (`UNPAID | PAID | OVERDUE`) and `CurrencyCode` (`KHR | USD`). Seed data: 2
categories, 3 fees. [VERIFIED]

## 8. Database

Flyway: `V1__init_finance_schema.sql`, `V2__Payment_indexes_and_status_check.sql`,
`V3__Payment_fee_index_and_positive_amount_checks.sql` (3). `ddl-auto: validate`.
DB `CHECK` also allows `PENDING`, `CANCELLED` (enum superset — defect #4). [VERIFIED]

## 9. API routes

See [`../../06-api/08-finance-api.md`](../../06-api/08-finance-api.md). Every call requires role
`STUDENT`; `POST /api/v1/students/verify` must have succeeded first.

## 10. Events

| Direction | Routing key | Payload / trigger |
|---|---|---|
| Consumes | `student.verified` (queue `finance.student.verified`) | `StudentVerifiedEvent` → account + demo payments |
| Produces | `payment.due` | `PaymentDueEvent` (scheduler, due within window) |
| Produces | `payment.overdue` | `PaymentOverdueEvent` (scheduler, past due) |

Consumer uses INFERRED type precedence + trusted packages. [VERIFIED]

## 11. Cache usage

None. [VERIFIED]

## 12. External dependencies

None (no Feign/WebClient). RabbitMQ for the verification event and payment alerts. [VERIFIED]

## 13. Auth and authorization

`@PreAuthorize("hasRole('STUDENT')")` on both controllers (the only method-security usage in the
backend) plus an imperative `requireStudent()`/`requireAccount()` check. Non-students → `403`.
[VERIFIED]

## 14. Configuration (env names only)

`SERVER_PORT`, `FINANCE_DB_URL`, `FINANCE_DB_USERNAME`, `FINANCE_DB_PASSWORD`, `RABBITMQ_*`,
`EUREKA_CLIENT_ENABLED`, `EUREKA_URL`, `VITHEY_JWT_SECRET`, `VITHEY_EVENTS_EXCHANGE`,
`VITHEY_FINANCE_ALERT_DUE_DAYS` (default 7), `VITHEY_FINANCE_ALERT_CRON` (default `0 0 8 * * *`).
[VERIFIED]

## 15. Health checks

`GET /actuator/health`. [VERIFIED]

## 16. Tests

| Type | Path |
|---|---|
| Context (H2) | `FinanceServiceContextTest.java` |
| Smoke (Postgres+Rabbit) | `FinanceServiceSmokeIT.java` |
| Unit | `service/PaymentServiceTest.java` |

Test implemented — current execution result not independently verified.

## 17. Known limitations / TBD

- No payment initiation endpoint; the API is read-only.
- No ACLEDA payment integration found in this service. `TBD — Requires confirmation.`
- Demo payments are seeded on verification; production population strategy is `TBD — Requires
  confirmation.`
- Enum vs DB `CHECK` superset (defect #4).
