# Config Server (Spring Cloud Config, native)

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/infrastructure/config-server/`, `backend/infrastructure/config-repo/*.yml`, `backend/infrastructure/config-server/Dockerfile`, `backend/docker-compose.demo.yml`

Vithey centralises runtime configuration in a **Spring Cloud Config** server running the **native**
profile. Configuration is served from Markdown files in `backend/infrastructure/config-repo/`, which
are **baked into the config-server image**. [VERIFIED]

Part of the Vithey documentation set · Master index:
[`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) ·
Siblings: [Backend architecture](01-backend-architecture.md) · [Service discovery](03-service-discovery.md).

## 1. Server identity

| Item | Value |
|---|---|
| Module | `backend/infrastructure/config-server` |
| Main class | `com.vithey.config.ConfigServerApplication` (`@EnableConfigServer`) |
| Port | `8888` (`SERVER_PORT`) |
| App name | `config-server` |
| Active profile | `native` |
| Search locations | `${CONFIG_REPO_LOCATION:file:./config-repo,classpath:/config-repo}` |
| Image default | `CONFIG_REPO_LOCATION=file:/app/config-repo` |

[VERIFIED: `config-server.yml`, `ConfigServerApplication.java`, `config-server/Dockerfile`]

## 2. Client wiring

Each service imports the config server optionally, so startup does not hard-fail if config is
unreachable:

```yaml
spring:
  config:
    import: optional:configserver:${CONFIG_SERVER_URL:http://localhost:8888}
```

In Docker the default becomes `http://config-server:8888` (`application-docker.yml`). [VERIFIED]

## 3. `config-repo` inventory

| File | Served to | Key contents |
|---|---|---|
| `application.yml` | all services | datasource/Hikari, JPA validate, Jackson snake_case + non_null, RabbitMQ, Redis, Feign CB, Eureka, JWT TTLs, `vithey.events.exchange`, Resilience4j |
| `application-prod.yml` | all services (profile `prod`) | JWT from env, health exposure, metrics tags, springdoc disabled |
| `api-gateway.yml` | api-gateway | route table, Redis rate-limiter args, CORS, `vithey.gateway.rate-limit` |
| `auth-service.yml` | auth-service | `auth_db` datasource, RabbitMQ, mail mode |
| `user-profile-service.yml` | user-profile-service | `user_db` datasource |
| `file-service.yml` | file-service | `file_db` datasource, MinIO endpoint/keys/buckets |
| `content-service.yml` | content-service | `content_db` datasource, RabbitMQ |
| `career-service.yml` | career-service | `career_db` datasource, RabbitMQ |
| `finance-service.yml` | finance-service | `finance_db` datasource, alert due-days / cron |
| `chat-service.yml` | chat-service | `chat_db` datasource, RabbitMQ |
| `notification-service.yml` | notification-service | `notification_db` datasource, Firebase credentials path |
| `map-service.yml` | map-service | `map_db` datasource |
| `eureka-server.yml` | eureka-server | port, self-preservation, empty-sync wait |
| `config-server.yml` | config-server | native profile + search locations |

[VERIFIED: directory listing of `config-repo/`]

> The config-server **also mints its own** config file (`config-server.yml`) which it serves to
> itself; the eureka-server likewise. [VERIFIED]

## 4. Rebuild constraint (important)

The Dockerfile copies `infrastructure/config-repo` into the image:

```dockerfile
ENV CONFIG_REPO_LOCATION=file:/app/config-repo
COPY infrastructure/config-repo /app/config-repo
```

Therefore **any change under `config-repo/` requires rebuilding the config-server image**
(`docker compose build config-server` or a full `docker-up-demo.ps1`). For local convenience the
demo compose also bind-mounts the repo, but the image copy is the source of truth for a fresh
build. [VERIFIED]

## 5. Environment overrides

`config-repo/application.yml` uses `${VAR:default}` placeholders so deployments override without
editing files. Examples (names only): `RABBITMQ_HOST`, `REDIS_HOST`, `EUREKA_URL`,
`VITHEY_JWT_SECRET`, `VITHEY_ACCESS_TOKEN_TTL`, `VITHEY_REFRESH_TOKEN_TTL`,
`VITHEY_EVENTS_EXCHANGE`, `DB_POOL_MAX`. Never commit secret values; `.env` files are gitignored and
only `.env.example` is tracked. [VERIFIED: `EVIDENCE-BASIS.md` §13]

## 6. Profiles

- Default local/demo: no active Spring profile beyond `native` on the config-server.
- `prod` profile exists (`application-prod.yml`) but **nothing activates it in CI**; there is no
  staging or production environment. [VERIFIED: `EVIDENCE-BASIS.md` §9]

## 7. Tests

`config-server/src/test/java/com/vithey/config/` has `ConfigServerContextTest` (active profiles
`test,native`) and `ConfigServerSmokeIT`. Test implemented — current execution result not
independently verified. [VERIFIED]

## 8. Known limitations / TBD

- No Git-backed config, encryption (`{cipher}`), or `/actuator/env` hardening beyond defaults.
  `TBD — Requires confirmation.`
- No config version pinning per service release. `TBD — Requires confirmation.`
