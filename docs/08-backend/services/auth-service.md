# auth-service

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/auth-service/`, `backend/infrastructure/config-repo/auth-service.yml`, `backend/services/auth-service/src/main/resources/db/migration/`

Part of the Vithey documentation set · Master index:
[`../../00-project-overview/07-document-index.md`](../../00-project-overview/07-document-index.md) ·
Siblings: [Backend architecture](../01-backend-architecture.md) ·
[Microservice architecture](../02-microservice-architecture.md) ·
[Event-driven](../06-event-driven-architecture.md) · [Error handling](../08-error-handling.md) ·
API: [`../../06-api/03-authentication-api.md`](../../06-api/03-authentication-api.md).

## 1. Purpose

Owns account identity: registration, login, JWT/refresh token issuance and rotation, email
verification, password reset/change, and AUB student verification. [VERIFIED]

## 2. Responsibilities

- Create `USER`/`COMPANY` accounts (bcrypt password hashes; `STUDENT` is not self-assignable).
- Issue 15-minute access JWTs and 7-day opaque refresh tokens; rotate/revoke refresh tokens.
- Store email-verification and password-reset tokens **hashed**, one-time, with expiry.
- Promote a user to `STUDENT` via student verification and emit an event.
- Send verification/reset mail through a pluggable `AuthMailSender`.

## 3. Port and identity

| Item | Value |
|---|---|
| Port | `8081` (`SERVER_PORT`) |
| Eureka name | `auth-service` |
| Database | `auth_db` |
| Gateway route | `/api/v1/auth/**`, `/api/v1/students/verify` |

[VERIFIED: `config-repo/auth-service.yml`, `config-repo/api-gateway.yml`]

## 4. Main controllers

| Controller | Base path | Endpoints |
|---|---|---|
| `AuthController` | `/api/v1/auth` | register, login, google, refresh, forgot-password, reset-password, verify-email, `GET /me`, `PATCH /me/password`, logout |
| `StudentVerificationController` | `/api/v1/students` | `POST /verify` |

[VERIFIED: `controller/*.java`]

## 5. Main services

| Service | Responsibility |
|---|---|
| `AuthService` | Register, login, `getMe`, change password, verify email |
| `TokenService` | Issue/rotate/revoke refresh tokens; build access JWTs via `JwtProvider` |
| `PasswordResetService` | Start reset (generic response) and complete reset with a one-time token |
| `StudentVerificationService` | Validate `@aub.edu.kh` domain, set role `STUDENT`, publish event |

Mail: `AuthMailSender` with `LoggingAuthMailSender` (default) and `SmtpAuthMailSender` selected by
`VITHEY_MAIL_MODE`. [VERIFIED: `mail/*.java`]

## 6. Repositories

`UserRepository`, `RefreshTokenRepository`, `PasswordResetTokenRepository`,
`EmailVerificationTokenRepository`, `StudentVerificationRepository`. [VERIFIED]

## 7. Entities and tables (`auth_db`)

| Entity | Table |
|---|---|
| `User` | `users` (`id`, `email`, `phone`, `password_hash`, `full_name`, `role`, `is_active`, `is_student_verified`, `is_email_verified`, timestamps, `deleted_at`) |
| `RefreshToken` | `refresh_tokens` (hashed `token_hash`, expiry, revoked) |
| `PasswordResetToken` | `password_reset_tokens` (hashed, one-time, expiry) |
| `EmailVerificationToken` | `email_verification_tokens` (hashed, one-time, expiry) |
| `StudentVerification` | `student_verifications` (`student_id`, `university_email`, status, `verified_at`) |

Enums `Role` and `StudentVerificationStatus`. [VERIFIED]

## 8. Database

Flyway migrations: `V1__init_auth_schema.sql`, `V2__Soft_delete_unique_email_phone_and_cascade_tokens.sql`,
`V3__Drop_unused_token_and_student_verification_indexes.sql`,
`V4__Student_verification_cascade_and_university_email_unique.sql` (4). `ddl-auto: validate`.
[VERIFIED]

## 9. API routes

See [`../../06-api/03-authentication-api.md`](../../06-api/03-authentication-api.md) for the full
endpoint inventory and examples. Note `/api/v1/students/verify` is routed but **not** in the gateway
public matcher → JWT required. The service's own `SecurityConfig` permits the six public auth
endpoints plus actuator/swagger.

## 10. Events

| Direction | Routing key | Payload |
|---|---|---|
| Produces | `user.registered` | `UserRegisteredEvent(userId, email, fullName, role, occurredAt)` |
| Produces | `student.verified` | `StudentVerifiedEvent(userId, studentId, occurredAt)` |

Both published on `vithey.events`; publish failures are logged, not raised.
Consumers: user-profile (`user.registered`), finance (`student.verified`). [VERIFIED]

## 11. Cache usage

None. [VERIFIED]

## 12. External dependencies

None (no Feign/WebClient). Outbound SMTP only when `VITHEY_MAIL_MODE=smtp`. [VERIFIED]

## 13. Auth and authorization

- JWT HMAC (JJWT 0.12.6), claims `sub`, `email`, `roles`. Access TTL 15 m, refresh 7 d.
- Password hashing: bcrypt. Refresh/reset/email tokens stored as SHA-256 hashes.
- `SecurityConfig`: stateless, permits register/login/google/refresh/forgot/reset/verify-email,
  `/actuator/health`, `/actuator/info`, swagger; everything else authenticated.
- `JwtAuthenticationFilter` re-validates the bearer token. [VERIFIED]

## 14. Configuration (env names only)

`SERVER_PORT`, `AUTH_DB_URL`, `AUTH_DB_USERNAME`, `AUTH_DB_PASSWORD`, `RABBITMQ_HOST`,
`RABBITMQ_PORT`, `RABBITMQ_USERNAME`, `RABBITMQ_PASSWORD`, `EUREKA_CLIENT_ENABLED`, `EUREKA_URL`,
`VITHEY_MAIL_MODE`, `VITHEY_MAIL_FROM`, `VITHEY_JWT_SECRET`, `VITHEY_ACCESS_TOKEN_TTL`,
`VITHEY_REFRESH_TOKEN_TTL`, `VITHEY_EVENTS_EXCHANGE`. No values. [VERIFIED]

## 15. Health checks

`GET /actuator/health` (and `/actuator/info`, `metrics`, `prometheus`). [VERIFIED]

## 16. Tests

| Type | Path |
|---|---|
| Context (H2) | `src/test/java/com/vithey/auth/AuthServiceContextTest.java` |
| Smoke (Postgres+Rabbit) | `src/test/java/com/vithey/auth/AuthServiceSmokeIT.java` |
| Unit | `security/JwtProviderTest.java`, `service/AuthServiceChangePasswordTest.java`, `service/AuthServiceRegisterMailTest.java`, `service/PasswordResetServiceTest.java` |

Test implemented — current execution result not independently verified.

## 17. Known limitations / TBD

- `/api/v1/students/verify` requires a JWT at the gateway (documented discrepancy).
- Mail defaults to `log`; SMTP delivery is not exercised end-to-end. `TBD — Requires confirmation.`
- No login/forgot-password-specific abuse throttling beyond the gateway rate limiter. `TBD — Requires
  confirmation.`
- Soft-delete uniqueness strategy means deleted emails/phones may still be reused only per migration
  design; re-registration semantics are `TBD — Requires confirmation.`
