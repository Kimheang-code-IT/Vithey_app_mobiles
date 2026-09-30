# Vithey Backend — Testing Guide

## Test layers

| Layer | Location | What it verifies | Requires Docker |
|-------|----------|------------------|-----------------|
| Unit tests | `src/test/java/**/*Test.java` | Business logic with mocks | No |
| Context tests | `src/test/java/**/*ContextTest.java` | Spring beans wire correctly (H2 in-memory) | No |
| Smoke integration tests | `src/test/java/**/*SmokeIT.java` | Full stack + Flyway + `/actuator/health` | **Yes** (skipped if Docker unavailable) |
| Runtime health script | `scripts/check-service-health.ps1` | Live stack after `docker compose up` | Running stack |

## Prerequisites for integration tests

1. **Docker Desktop** running (Testcontainers pulls `postgres`, `rabbitmq`, `redis`, `minio` images on first run).
2. Java 21 + Maven from `backend/`.

## Run all tests

```powershell
cd backend
mvn test
```

## Run only smoke tests (one service)

```powershell
cd backend/services/career-service
mvn test -Dtest=CareerServiceSmokeIT
```

## Run only unit tests (skip smoke)

```powershell
cd backend
mvn test -Dtest='!*SmokeIT'
```

## Shared test module

`shared/vithey-test-support` provides Testcontainers base classes:

| Base class | Containers | Used by |
|------------|------------|---------|
| `AbstractPostgresRabbitSmokeTestBase` | PostgreSQL + RabbitMQ | auth, profile, content, career, finance, notification |
| `AbstractPostgresRabbitRedisSmokeTestBase` | PostgreSQL + RabbitMQ + Redis | chat-service |
| `AbstractPostgresMinioSmokeTestBase` | PostgreSQL + MinIO | file-service |
| `AbstractRedisSmokeTestBase` | Redis | api-gateway |

Each smoke test:

1. Starts the service on a random port with profile `test`.
2. Disables Eureka and Config Server.
3. Wires Testcontainers via `@DynamicPropertySource`.
4. Asserts `GET /actuator/health` returns `{"status":"UP"}`.

## Check live stack health

After starting infrastructure + services with Docker Compose:

```powershell
cd backend/scripts
.\check-service-health.ps1
```

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `Could not find a valid Docker environment` | Start Docker Desktop |
| Smoke test timeout on first run | Image pull; retry or pre-pull `postgres:16-alpine` |
| Health `DOWN` for Rabbit/Redis | Ensure base class matches service dependencies |
| Port conflicts in live checks | Stop local instances on 8080–8090, 8100, 8761, 8888 |
