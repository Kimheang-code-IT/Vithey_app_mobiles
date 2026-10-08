# DEPLOYMENT.md — Vithey backend

Concise production runbook. Detailed component docs live in
`docs/14-deployment/` and `docs/13-devops/`; this file is the operator-facing
summary and the source of required production configuration.

## 1. Required production environment variables

Validate all of these on startup (fail fast; do not ship defaults):

| Variable | Purpose | Production requirement |
|---|---|---|
| `VITHEY_JWT_SECRET` | HS256 signing secret shared by gateway + services | Random ≥ 256-bit (32+ bytes), from a secret manager. Never the `.env.example` placeholder. |
| `VITHEY_CORS_ALLOWED_ORIGINS` | Gateway CORS | Explicit web origins; never `*` in production. Mobile apps are not subject to CORS. |
| `AUTH_DB_URL` / `*_DB_*` | PostgreSQL per service | Managed DB, TLS, least-privilege user. |
| `RABBITMQ_*`, `REDIS_*`, `MINIO_*` | Messaging / cache / storage | Managed services or secured containers. |
| `GOOGLE_WEB_CLIENT_ID` | Google ID-token audience | The Web OAuth client ID; no client secret stored server-side. |
| `VITHEY_ACCESS_TOKEN_TTL` | Access token TTL (default `15m`) | Keep short. |
| `VITHEY_REFRESH_TOKEN_TTL` | Refresh token TTL (default `7d`) | Policy-dependent. |
| `DEEPSEEK_API_KEY` / `DEEPSEEK_BASE_URL` / `DEEPSEEK_MODEL` | ai-core LLM | Provided via `ai-core/.env` (`env_file`), not compose `environment`. |

`backend/.env.example` and each service `.env.example` list every knob with
safe placeholders. Only `.env.example` is committed.

## 2. Start order

1. Datastores: PostgreSQL, Redis, RabbitMQ, MinIO.
2. Platform: `eureka-server` (:8761), `config-server` (:8888).
3. Services (registered with Eureka): auth, user-profile, file, content,
   career, finance, chat, notification, map.
4. Gateway (:8080) — single public entry point.
5. Optional: `ai-core` (:8100), `fake-payment-service` (demo only), monitoring
   profile.

Docker Compose: `cd backend && docker compose up -d --build`
(demo overlay: `-f docker-compose.yml -f docker-compose.demo.yml`).

## 3. Database migrations

Flyway runs automatically per service on startup
(`spring.flyway.locations=classpath:db/migration`, `ddl-auto=validate`).
Migrations are forward-only and live under
`backend/services/<svc>/src/main/resources/db/migration/`. Never edit an
applied migration; add a new versioned file.

## 4. HTTPS / reverse proxy

Terminate TLS at a reverse proxy/load balancer in front of the gateway.
Forward `Authorization`, `Upgrade`/`Connection` (for `/ws/**`), and
`X-Request-ID`. Do not enable cleartext HTTP in production.

## 5. Health, monitoring, logging

- Liveness/readiness: `GET /actuator/health` on every service.
- Metrics: `/actuator/prometheus`; scrape via `monitoring/prometheus`.
- Logs: structured; never log passwords, tokens, cookies, or the
  `Authorization` header. Request correlation uses `X-Request-ID`.
- Rate limiting is enforced at the gateway (Redis token bucket); the auth and
  `/places/**` routes have tuned limits.

## 6. Backup / restore / rollback

- **Backup:** nightly PostgreSQL base backup + WAL archiving; versioned MinIO
  bucket replication; snapshot Redis/RabbitMQ only if durability is required.
- **Restore:** restore the latest verified base backup, replay WAL, then start
  services; Flyway validates schema on boot.
- **Rollback:** redeploy the previous immutable service images. Because
  migrations are forward-only, roll back code only to a version compatible with
  the current schema, or write a compensating migration.

See `docs/14-deployment/07-rollback-plan.md` and
`docs/14-deployment/08-disaster-recovery.md` for full procedures.

## 7. Secret hygiene

- `vithey-secrets/`, `*.jks`, `*.keystore`, `key.properties`, `.env` are
  git-ignored.
- Rotate `VITHEY_JWT_SECRET` with a staged key rollout (access tokens expire in
  ≤15m).
- Never commit production URLs, keys, or service-account JSON.
