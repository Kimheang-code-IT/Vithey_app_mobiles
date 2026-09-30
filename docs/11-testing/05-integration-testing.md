# Integration Testing

> Status: Verified baseline (inventory) · Last reviewed: 2026-09-30
> Evidence: `backend/**/src/test/java/**/*ContextTest.java`, `*SmokeIT.java`, `backend/shared/vithey-test-support`, `backend/TESTING.md`
> Result status: `Test implemented — current execution result not independently verified.`

## 1. Overview

Vithey has two integration layers:

1. **Context tests** (`*ContextTest`) — start the Spring application context against **H2**
   in-memory to prove beans wire and JPA mappings validate. No Docker.
2. **Smoke integration tests** (`*SmokeIT`) — start the service against **Testcontainers**
   (real Postgres/RabbitMQ/Redis/MinIO) and assert the health endpoint. Docker required.

## 2. Shared test base classes

`backend/shared/vithey-test-support` (`Abstract*SmokeTestBase`) [VERIFIED] `TESTING.md`:

| Base class | Containers | Used by |
| --- | --- | --- |
| `AbstractPostgresRabbitSmokeTestBase` | Postgres + RabbitMQ | auth, profile, content, career, finance, notification |
| `AbstractPostgresRabbitRedisSmokeTestBase` | Postgres + RabbitMQ + Redis | chat |
| `AbstractPostgresMinioSmokeTestBase` | Postgres + MinIO | file |
| `AbstractRedisSmokeTestBase` | Redis | api-gateway |

Each smoke test [VERIFIED] `TESTING.md`:

1. starts the service on a **random port** with profile `test`;
2. disables Eureka and Config Server;
3. wires Testcontainers via `@DynamicPropertySource`;
4. asserts `GET /actuator/health` returns `{"status":"UP"}`.

## 3. Inventory

| Service | Context test | Smoke IT | Containers |
| --- | --- | --- | --- |
| api-gateway | `ApiGatewayContextTest` | `ApiGatewaySmokeIT` | Redis |
| auth-service | `AuthServiceContextTest` | `AuthServiceSmokeIT` | Postgres + RabbitMQ |
| user-profile | `UserProfileServiceContextTest` | `UserProfileServiceSmokeIT` | Postgres + RabbitMQ |
| content | `ContentServiceContextTest` | `ContentServiceSmokeIT` | Postgres + RabbitMQ |
| career | `CareerServiceContextTest` | `CareerServiceSmokeIT` | Postgres + RabbitMQ |
| chat | `ChatServiceContextTest` | `ChatServiceSmokeIT` | Postgres + RabbitMQ + Redis |
| finance | `FinanceServiceContextTest` | `FinanceServiceSmokeIT` | Postgres + RabbitMQ |
| notification | `NotificationServiceContextTest` | `NotificationServiceSmokeIT` | Postgres + RabbitMQ |
| file | `FileServiceContextTest` | `FileServiceSmokeIT` | Postgres + MinIO |
| config-server | `ConfigServerContextTest` | `ConfigServerSmokeIT` | — |
| eureka-server | `EurekaServerContextTest` | `EurekaServerSmokeIT` | — |
| map-service | **none** | **none** | — |

[VERIFIED] `backend/**/src/test/java`; map-service has neither context nor smoke test.

## 4. Critical execution caveat

**`mvn test` does not run `*SmokeIT`.** There is **no Maven Failsafe plugin**, and Surefire's
default includes do not match the `SmokeIT` suffix. Consequences:

- CI (`ci-promote-dev.yml` and per-service workflows) runs `mvn test`, so smoke ITs are
  **never executed in CI**, even though runners have Docker. [VERIFIED] `.github/workflows/`
- To run them you must invoke them explicitly, e.g.
  `mvn test -Dtest=CareerServiceSmokeIT` from `backend/services/career-service` (Docker on).
  [VERIFIED] `TESTING.md`.

> This is also recorded as data/CI defect #5 in `../_meta/EVIDENCE-BASIS.md` §8.

## 5. How to run

```powershell
# Context tests only (fast, no Docker)
cd backend
mvn test -Dtest='*ContextTest'

# One smoke IT (Docker required)
cd backend/services/career-service
mvn test -Dtest=CareerServiceSmokeIT

# Live-stack health sweep (after docker-up-demo.ps1)
cd backend/scripts
.\check-service-health.ps1
```

## 6. Coverage gaps

| Gap | Impact |
| --- | --- |
| Smoke ITs excluded from `mvn test`/CI | No automated full-stack boot verification |
| map-service lacks context + smoke tests | Untested wiring/boot |
| Smoke tests only assert health | No API-level integration assertions |
| No contract tests between services/Feign | Cross-service drift risk |

## 7. Result status

No integration or smoke test was executed during this documentation task.
`Test implemented — current execution result not independently verified.`

## 8. Cross-references

- [04-unit-testing.md](04-unit-testing.md) · [06-api-testing.md](06-api-testing.md) · [12-test-results.md](12-test-results.md)
- `../../backend/TESTING.md`
