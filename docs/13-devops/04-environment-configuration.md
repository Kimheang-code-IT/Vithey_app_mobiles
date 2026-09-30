# Environment Configuration

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/.env.example`, `backend/infrastructure/.env.example`, `backend/services/*/.env.example`, `ai_core/.env.example`, `monitoring/.env.example`, `vithey_app/.env.example`, `backend/infrastructure/config-repo/*.yml`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [Compose model](03-docker-compose.md) · [Environment setup](../14-deployment/02-environment-setup.md)

> **Secrets policy.** This document lists environment variable **names only**. Never commit or print values. Where a value is unavoidable, it is shown as `<REDACTED>`.

## 1. Where configuration lives

| Layer | File | Committed | Loaded by |
|---|---|---|---|
| Backend resource limits / profiles | `backend/.env` | No (`.env.example` is) | Docker Compose auto-load |
| Infra credentials | `backend/infrastructure/.env` | No | Compose `env_file` |
| Per-service runtime | `backend/services/<name>/.env` | No | Compose `env_file` |
| AI engine | `ai_core/.env` | No | Compose `env_file` + app |
| Monitoring UI | `monitoring/.env` | No | Compose `env_file` |
| Flutter app | `vithey_app/.env` | No | declared pubspec asset |
| Service defaults (image-baked) | `backend/infrastructure/config-repo/*.yml` | Yes | `config-server` |

[VERIFIED — repo layout and `.gitignore`]

`backend/.env` is **absent by default**; the stack still boots using the `${VAR:-default}` fallbacks in the demo overlay. [VERIFIED — `docker-up-demo.ps1` warning branch]

## 2. `backend/.env` — resource limits (names only)

All compose resource caps are `${VAR:-default}`. Do **not** hardcode limits in compose; add a knob instead. [VERIFIED — `backend/docker-compose.demo.yml`, `AGENTS.md`]

| Variable | Purpose | Lean default |
|---|---|---|
| `COMPOSE_PROFILES` | optional services (`map`, `monitoring`) | empty |
| `VITHEY_JWT_SECRET` | HMAC signing secret (dev default only) | placeholder |
| `SERVICE_JAVA_OPTS` / `SERVICE_MEM_LIMIT` | domain JVMs | `-Xmx192m` / `320m` |
| `PLATFORM_JAVA_OPTS` / `PLATFORM_MEM_LIMIT` | Eureka + Config | `-Xmx160m` / `256m` |
| `GATEWAY_JAVA_OPTS` / `GATEWAY_MEM_LIMIT` | API gateway | `-Xmx256m` / `384m` |
| `PG_MEM_LIMIT`, `PG_MAX_CONNECTIONS`, `PG_SHARED_BUFFERS`, `PG_WORK_MEM`, `PG_EFFECTIVE_CACHE_SIZE` | Postgres | see `.env.example` |
| `REDIS_MEM_LIMIT`, `REDIS_MAXMEMORY` | Redis | `96m` / `64mb` |
| `RABBITMQ_MEM_LIMIT` | RabbitMQ | `192m` |
| `MINIO_MEM_LIMIT` | MinIO | `128m` |
| `DB_POOL_MAX`, `DB_POOL_MIN` | Hikari per service | `5` / `1` |
| `RABBIT_CONCURRENCY`, `RABBIT_MAX_CONCURRENCY` | listener pool | `1` / `2` |
| `AI_CORE_MEM_LIMIT`, `AI_CORE_WORKERS` | ai_core | `256m` / `1` |
| `GOOGLE_PLACES_API_KEY` | map-service (profile `map`) | empty |

[VERIFIED — `backend/.env.example`, `docs/../DOCKER.md`]

## 3. `backend/infrastructure/.env.example` (names)

| Variable | Used by |
|---|---|
| `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` | Postgres container |
| `RABBITMQ_DEFAULT_USER`, `RABBITMQ_DEFAULT_PASS` | RabbitMQ container |
| `MINIO_ROOT_USER`, `MINIO_ROOT_PASSWORD` | MinIO container |
| `EUREKA_URL`, `CONFIG_SERVER_URL`, `CONFIG_REPO_LOCATION` | platform wiring |
| `VITHEY_JWT_SECRET` | gateway/services |
| `VITHEY_GATEWAY_RATE_LIMIT_REPLENISH`, `..._BURST`, `..._TOKENS` | gateway rate limiter |
| `VITHEY_CORS_ALLOWED_ORIGINS` | gateway CORS |

[VERIFIED — `backend/infrastructure/.env.example`]

## 4. Per-service variables (names)

Each `backend/services/<name>/.env.example` supplies at least `SERVER_PORT`, `SPRING_PROFILES_ACTIVE=docker`, `CONFIG_SERVER_URL`, `EUREKA_CLIENT_ENABLED`, `EUREKA_URL`, plus service-specific keys. Examples:

| Service | Extra names |
|---|---|
| `auth-service` | `AUTH_DB_URL`, `AUTH_DB_USERNAME`, `AUTH_DB_PASSWORD`, `RABBITMQ_*`, `VITHEY_ACCESS_TOKEN_TTL`, `VITHEY_REFRESH_TOKEN_TTL`, `VITHEY_EVENTS_EXCHANGE`, `VITHEY_MAIL_MODE`, `SMTP_*` |
| `api-gateway` | `REDIS_HOST`, `REDIS_PORT`, `VITHEY_CORS_ALLOWED_ORIGINS` |
| `map-service` | `MAP_DB_URL`, `MAP_DB_USERNAME`, `MAP_DB_PASSWORD`, `REDIS_HOST`, `REDIS_PORT`, `GOOGLE_PLACES_API_KEY`, `GOOGLE_PLACES_PHOTO_URL_TEMPLATE` |
| others | `<SVC>_DB_URL`, `<SVC>_DB_USERNAME`, `<SVC>_DB_PASSWORD`, `RABBITMQ_*` / `MINIO_*` as needed |

[VERIFIED — `backend/services/*/.env.example`]

`VITHEY_JWT_SECRET` must be the **same value** across gateway and all services, or JWT validation fails. [VERIFIED — shared secret in `config-repo/application.yml`, per-service env]

## 5. `ai_core/.env` (names)

| Variable | Default | Notes |
|---|---|---|
| `DEEPSEEK_API_KEY` | — | **required**; LLM credential `<REDACTED>` |
| `DEEPSEEK_BASE_URL` | `https://openrouter.ai/api/v1` | legacy prefix, OpenRouter endpoint |
| `DEEPSEEK_MODEL` | `z-ai/glm-5.3-flash` | LLM model id |
| `AI_CHAT_MODE` | `stub` | read but not branched (chat is a stub) |
| `AI_CV_MAX_POSTS`, `MAX_POSTS_PER_BUILD`, `MAX_CONTENT_CHARS`, `MAX_TOKENS`, `TEMPERATURE`, `TIMEOUT_SECONDS`, `MAX_RETRIES` | see evidence | cost/limit knobs |
| `CACHE_MAX_SIZE`, `API_RATE_LIMIT_PER_MINUTE`, `LOG_LEVEL` | see evidence | runtime knobs |
| `VITHEY_JWT_SECRET`, `USER_PROFILE_BASE_URL`, `CONTENT_BASE_URL`, `DATABASE_URL` | compose-set | wiring |

[VERIFIED — `ai_core/.env.example`, `ai_core/config.py`, `backend/docker-compose.yml` ai-core env]

## 6. `vithey_app/.env`

Declared as a pubspec **asset** and gitignored, so it must exist before build/analyze/test. Key names: `APP_ENV`, `API_BASE_URL`, `WS_BASE_URL`, `API_CONNECT_TIMEOUT_SECONDS`, `API_RECEIVE_TIMEOUT_SECONDS`, `USE_MOCK_*`, `USE_AI_*`, `FORCE_*`, `ENABLE_GOOGLE_AUTH`, `FCM_ENABLED`/`FCM_DEBUG_TOKEN`. [VERIFIED — `vithey_app/.env.example`]

## 7. Service defaults (config-repo)

`backend/infrastructure/config-repo/application.yml` defines image-baked defaults, e.g. Hikari `maximum-pool-size: ${DB_POOL_MAX:5}`, Rabbit concurrency `${RABBIT_CONCURRENCY:1}`, `ddl-auto: validate`, snake_case JSON, actuator exposure `health,info,metrics,prometheus`, and Resilience4j circuit-breaker/timelimiter config. [VERIFIED]

> Config changes require rebuilding the `config-server` image, except locally where the repo is bind-mounted read-only. [VERIFIED — `backend/docker-compose.yml:128-130`]

## 8. Secrets handling summary

| Secret (name only) | Where it must come from |
|---|---|
| `VITHEY_JWT_SECRET` | environment; no production default (`application-prod.yml` has no fallback) |
| `DEEPSEEK_API_KEY` | `ai_core/.env` (user-supplied) |
| `POSTGRES_PASSWORD`, `MINIO_ROOT_PASSWORD`, `RABBITMQ_DEFAULT_PASS` | infra `.env` |
| `GOOGLE_PLACES_API_KEY` | map-service `.env` |
| `GRAFANA_USER` / `GRAFANA_PASSWORD` | `monitoring/.env` |
| `SMTP_*` | auth-service `.env` when `VITHEY_MAIL_MODE=smtp` |

[VERIFIED — `.env.example` files; `application-prod.yml`]

> `application-prod.yml` exists in `config-repo` (removes dev defaults, disables Swagger/actuator prometheus exposure) but **nothing activates `SPRING_PROFILES_ACTIVE=prod`**. It is currently unused. [VERIFIED — `EVIDENCE-BASIS.md` §9]
