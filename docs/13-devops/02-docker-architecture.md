# Docker Architecture

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/*/Dockerfile`, `backend/infrastructure/*/Dockerfile`, `ai_core/Dockerfile`, `backend/docker-compose.yml`, `.github/workflows/ci-promote-dev.yml`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [Compose model](03-docker-compose.md) · [Image registry](07-image-registry.md) · [Network architecture](../03-system-design/07-network-architecture.md)

## 1. Image inventory

| Image (local build tag) | Dockerfile | Base | Port |
|---|---|---|---|
| `vithey-eureka-server:local` | `backend/infrastructure/eureka-server/Dockerfile` | `eclipse-temurin:21-jre-alpine` | 8761 |
| `vithey-config-server:local` | `backend/infrastructure/config-server/Dockerfile` | `eclipse-temurin:21-jre-alpine` | 8888 |
| `vithey-api-gateway:local` | `backend/services/api-gateway/Dockerfile` | `eclipse-temurin:21-jre-alpine` | 8080 |
| `vithey-auth-service:local` | `backend/services/auth-service/Dockerfile` | `eclipse-temurin:21-jre-alpine` | 8081 |
| `vithey-user-profile-service:local` | `backend/services/user-profile-service/Dockerfile` | `eclipse-temurin:21-jre-alpine` | 8082 |
| `vithey-file-service:local` | `backend/services/file-service/Dockerfile` | `eclipse-temurin:21-jre-alpine` | 8083 |
| `vithey-content-service:local` | `backend/services/content-service/Dockerfile` | `eclipse-temurin:21-jre-alpine` | 8084 |
| `vithey-career-service:local` | `backend/services/career-service/Dockerfile` | `eclipse-temurin:21-jre-alpine` | 8085 |
| `vithey-finance-service:local` | `backend/services/finance-service/Dockerfile` | `eclipse-temurin:21-jre-alpine` | 8086 |
| `vithey-chat-service:local` | `backend/services/chat-service/Dockerfile` | `eclipse-temurin:21-jre-alpine` | 8087 |
| `vithey-notification-service:local` | `backend/services/notification-service/Dockerfile` | `eclipse-temurin:21-jre-alpine` | 8088 |
| `vithey-map-service:local` | `backend/services/map-service/Dockerfile` | `eclipse-temurin:21-jre-alpine` | 8090 |
| `vithey-ai-core:local` | `ai_core/Dockerfile` | `python:3.12-slim` | 8100 |

[VERIFIED — Dockerfiles and `docker-compose.yml` image tags]

There is **no Flutter Dockerfile** — the mobile app is built with the Flutter SDK, not containerised. [VERIFIED — no Dockerfile under `vithey_app/`]

## 2. Java image pattern (multi-stage)

All Java services and platform apps share one pattern:

1. **Build stage** — `maven:3.9.11-eclipse-temurin-21-alpine`. Copies the root `pom.xml`, all module `pom.xml`s and the target module's `src`, then runs `mvn -pl <module> -am -Dmaven.test.skip=true package` with a BuildKit `--mount=type=cache,target=/root/.m2`.
2. **Runtime stage** — `eclipse-temurin:21-jre-alpine`, creates non-root user `vithey`, copies `app.jar`.

```dockerfile
FROM maven:3.9.11-eclipse-temurin-21-alpine AS build
...
RUN --mount=type=cache,target=/root/.m2 \
    mvn -B -q -pl services/auth-service -am -Dmaven.test.skip=true package && \
    cp services/auth-service/target/*.jar app.jar

FROM eclipse-temurin:21-jre-alpine AS runtime
RUN apk add --no-cache wget grep && addgroup -S vithey && adduser -S vithey -G vithey
USER vithey
ENV JAVA_TOOL_OPTIONS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]
```

[VERIFIED — `backend/services/auth-service/Dockerfile`; identical structure across Java modules]

Key properties:

- The build context is the **backend monorepo root**, so all module `pom.xml`s must be copied even though only one module is built.
- `SERVICE_PORT` is a build `ARG` that sets `ENV SERVER_PORT` and `EXPOSE`.
- The default heap flag `-XX:MaxRAMPercentage=75.0` is **overridden by `JAVA_TOOL_OPTIONS`** from `backend/.env` in the demo overlay — so compose is authoritative at runtime.
- An image-level `HEALTHCHECK` (interval 30s, start-period 60s) probes `/actuator/health` with `wget` and greps `"status":"UP"`.

## 3. ai_core image (single-stage)

```dockerfile
FROM python:3.12-slim
COPY pyproject.toml README.md ./
COPY vithey_ai ./vithey_ai
COPY main.py ./
RUN pip install --upgrade pip && pip install "openai>=1.40,<2" ... && pip install --no-deps -e .
EXPOSE 8100
ENV AI_CORE_WORKERS=1
CMD uvicorn vithey_ai.api.app:create_app --factory --host 0.0.0.0 --port 8100 --workers ${AI_CORE_WORKERS:-1}
```

[VERIFIED — `ai_core/Dockerfile`]

- No multi-stage build; dependency wheels are installed at build time and pinned with ranges to avoid pip backtracking.
- Worker count is env-driven (`AI_CORE_WORKERS`), default `1`.
- No `USER` directive — the image runs as root by default. [INFERRED — security hardening opportunity; `Inferred from implementation — requires business confirmation.`]

## 4. Data-plane and third-party images

| Image | Version | Container |
|---|---|---|
| `postgres` | 16-alpine | `vithey-postgres` |
| `redis` | 7-alpine | `vithey-redis` |
| `rabbitmq` | 3-management-alpine | `vithey-rabbitmq` |
| `quay.io/minio/minio` | latest | `vithey-minio` |
| `prom/prometheus` | latest | `vithey-prometheus` |
| `grafana/grafana` | latest | `vithey-grafana` |
| `grafana/loki` | latest | `vithey-loki` |
| `grafana/promtail` | latest | `vithey-promtail` |
| `prom/node-exporter` | latest | `vithey-node-exporter` |
| `gcr.io/cadvisor/cadvisor` | latest | `vithey-cadvisor` |

[VERIFIED — `backend/docker-compose.yml`, `monitoring/docker-compose.yml`]

> Note: third-party images use floating `latest` tags. This is a reproducibility risk for any future non-local environment. [INFERRED]

## 5. Build and caching

- CI uses BuildKit GitHub Actions cache (`cache-from/to: type=gha`) per service matrix entry. [VERIFIED — `ci-promote-dev.yml`]
- Local builds run through `docker compose ... build` or `docker build` with the `backend/` root context.
- Build-time Maven dependency caching uses a BuildKit cache mount (`/root/.m2`), not a committed `settings.xml`.

Build a single service image:

```powershell
cd backend
.\scripts\docker-build-service.ps1 auth-service -BuildOnly
```

[VERIFIED — `backend/scripts/docker-build-service.ps1`]
