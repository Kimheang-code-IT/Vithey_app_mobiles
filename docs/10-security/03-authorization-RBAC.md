# Authorization & RBAC

> Status: Verified baseline (code-level) · Last reviewed: 2026-09-30
> Evidence: `backend/services/auth-service/.../entity/Role.java`, all `backend/services/*/.../config/SecurityConfig.java`, `backend/services/finance-service/.../controller/*.java`, `backend/services/api-gateway/.../filter/JwtAuthenticationGlobalFilter.java`
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md` §5; role matrix `../01-requirements/05-user-roles-permissions.md`

## 1. Role model

Roles are defined in `auth-service` and propagated through the JWT `roles` claim and the
gateway `X-User-Roles` header. Spring authorities are prefixed `ROLE_`.

| Role | Granted by | Spring authority | Status |
| --- | --- | --- | --- |
| `USER` | `POST /auth/register` | `ROLE_USER` | Implemented |
| `COMPANY` | `POST /auth/register` (role=COMPANY) | `ROLE_COMPANY` | Implemented |
| `STUDENT` | `POST /students/verify` | `ROLE_STUDENT` | Implemented |
| `ADMIN` | Backend/DB only | `ROLE_ADMIN` | Implemented as a role; no admin API in client scope |

[VERIFIED] `Role.java`; `AuthService.register` rejects any registration role other than
`USER`/`COMPANY`. [VERIFIED]

## 2. Two enforcement layers

### 2.1 Edge (gateway)

`JwtAuthenticationGlobalFilter` is the only gate for **all** `/api/v1/**` paths: it validates
the JWT signature/expiry and forwards identity headers. It performs **no per-role routing** —
authorization decisions are delegated to services. [VERIFIED]

### 2.2 Service (defense in depth)

Every domain service (and `auth-service`) has a `SecurityConfig` that [VERIFIED]:

- disables CSRF and uses `STATELESS` sessions;
- `permitAll()` only actuator/swagger paths, then `.anyRequest().authenticated()`;
- installs a `JwtAuthenticationFilter` that builds the `Authentication` from either the
  Bearer JWT or the gateway `X-User-*` headers;
- enables `@EnableMethodSecurity` (so `@PreAuthorize` *could* be used anywhere).

> **Important gap:** `@EnableMethodSecurity` is on in all services, but the **only**
> `@PreAuthorize` usages in the entire backend are on `FeeController` and `PaymentController`
> in `finance-service`. All other endpoints are protected only by "is there an authenticated
> principal?", with any finer checks done ad hoc inside service methods. [VERIFIED]

## 3. Method security actually in use

| Controller | Rule | Effect |
| --- | --- | --- |
| `finance-service` `FeeController` | `@PreAuthorize("hasRole('STUDENT')")` | `/api/v1/fees`, `/api/v1/fees/categories` require STUDENT |
| `finance-service` `PaymentController` | `@PreAuthorize("hasRole('STUDENT')")` | `/api/v1/payments*` require STUDENT |

[VERIFIED] `FeeController.java:18`, `PaymentController.java:20`. Both also call
`currentUserProvider.requireStudent()` internally, so a denial is enforced twice.

## 4. Ownership-based authorization (service layer)

Roles are coarse; several resources are protected by ownership logic rather than roles:

| Resource | Rule | Evidence |
| --- | --- | --- |
| File download (CV) | CV download owner-only; AVATAR/POSTER/VIDEO downloadable by any authenticated user | `FileController.java:83`, `FileMetadataService` |
| File delete | Owner-only | `FileController.java:107` |
| Fee / payment read | Scoped to the current user id | `FeeController`, `PaymentController` |
| Profile edit | Only `/users/me` is writable for self; public profile is read-only | `UserController.java` |
| Conversation access | Participant membership enforced in `chat-service` | `ConversationService` |

[VERIFIED] controller/service code as cited. These are not expressed as `@PreAuthorize`
rules, so they are not centrally auditable.

## 5. Authorization decision flow

```mermaid
flowchart TD
  R[Request /api/v1/...] --> G{Gateway: public path?}
  G -->|yes| S[Forward]
  G -->|no| V{Valid Bearer JWT?}
  V -->|no| E401[401 UNAUTHORIZED]
  V -->|yes| H[Inject X-User-Id / Roles / Email]
  H --> F{Service SecurityConfig: authenticated?}
  F -->|no| E401b[401]
  F -->|yes| P{@PreAuthorize present?}
  P -->|finance STUDENT endpoints| P1[Require ROLE_STUDENT]
  P -->|otherwise| O[Service-layer ownership / business checks]
  P1 --> OK[Process]
  O --> OK
```

## 6. Gaps and observations

| # | Observation | Severity | Evidence |
| --- | --- | --- | --- |
| A1 | Role checks beyond "authenticated" exist only for finance; post ownership, company-only JOB posting, admin scope are not enforced via method security | Medium | grep `@PreAuthorize` → 2 files |
| A2 | Service filter trusts `X-User-Id`/`X-User-Roles` without a Bearer token; a directly reachable service port can be impersonated by header injection, and missing roles silently default to `USER` | High (if port exposed) | all `JwtAuthenticationFilter.java` |
| A3 | `ADMIN` has no dedicated endpoints/authorization surface in the codebase | Low | `Role.java`; controller inventory |
| A4 | Authorization for `COMPANY`-only job posting is not centralised (business rule spread in services) | Low | `career-service` controllers |

These are code-level observations only; **no formal assessment has been performed.** See
[10-vulnerability-assessment.md](10-vulnerability-assessment.md).

## 7. Cross-references

- [02-authentication.md](02-authentication.md) · [04-JWT-security.md](04-JWT-security.md)
- Role matrix: `../01-requirements/05-user-roles-permissions.md`
- API endpoints & required roles: `../06-api/01-api-overview.md`
