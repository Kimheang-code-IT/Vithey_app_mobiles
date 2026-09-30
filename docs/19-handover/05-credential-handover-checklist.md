# Credential & Secret Handover Checklist

> Status: **Template** — credentials have NOT been transferred · Last reviewed: 2026-09-30
> Evidence: `**/.env.example`, `backend/services/*/.env.example`, `ai_core/.env.example`, `monitoring/.env.example`, `_meta/EVIDENCE-BASIS.md` §13
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

> **Never place real values in this document.** All values are shown as `<REDACTED>` or
> `TBD — Requires confirmation.` Transfer actual secrets only through an approved secure channel
> (e.g. a bank-approved password manager), never via git, docs, chat, or email.

## 1. How to use this checklist

For each secret below: (a) confirm it exists in the source environment, (b) record its custody, and
(c) confirm the recipient can set it in the listed location. **No secret has been transferred yet.**

## 2. Required secrets and configuration

| # | Secret / variable name | Purpose | Where it is configured | Required for | Value | Transferred? |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `VITHEY_JWT_SECRET` | HMAC signing of access/refresh JWTs; shared by gateway, all services, ai_core | `backend/.env`, `backend/infrastructure/.env.example`, `backend/services/*/.env.example`, `ai_core/.env` | Core auth (all envs) | `<REDACTED>` | ☐ No |
| 2 | `DEEPSEEK_API_KEY` | LLM key for **real AI CV generation** (OpenRouter GLM by default) | `ai_core/.env` | AI CV only | `<REDACTED>` | ☐ No |
| 3 | `DEEPSEEK_BASE_URL` | LLM endpoint (non-secret) | `ai_core/.env` | AI CV | `https://openrouter.ai/api/v1` (default) | ☐ No |
| 4 | `DEEPSEEK_MODEL` | LLM model id (non-secret) | `ai_core/.env` | AI CV | `z-ai/glm-5.3-flash` (default) | ☐ No |
| 5 | `POSTGRES_PASSWORD` | Shared Postgres password (per-service DBs) | `backend/infrastructure/.env.example`, `backend/services/*/.env.example` | All services | `<REDACTED>` | ☐ No |
| 6 | `POSTGRES_USER` | Postgres user | same | All services | `<REDACTED>` | ☐ No |
| 7 | `RABBITMQ_DEFAULT_PASS` / `RABBITMQ_PASSWORD` | RabbitMQ credentials (events) | `backend/infrastructure/.env.example`, `auth-service/.env.example` | Auth, content, career, chat, finance, notification, user-profile | `<REDACTED>` | ☐ No |
| 8 | `MINIO_ROOT_PASSWORD` | MinIO root password | `backend/infrastructure/.env.example` | file-service | `<REDACTED>` | ☐ No |
| 9 | `MINIO_ACCESS_KEY` | MinIO/S3 access key | `file-service/.env.example` | file-service | `<REDACTED>` | ☐ No |
| 10 | `MINIO_SECRET_KEY` | MinIO/S3 secret key | `file-service/.env.example` | file-service | `<REDACTED>` | ☐ No |
| 11 | `GRAFANA_PASSWORD` | Grafana admin password | `monitoring/.env.example` | Monitoring profile | `<REDACTED>` | ☐ No |
| 12 | `GRAFANA_USER` | Grafana admin user | `monitoring/.env.example` | Monitoring profile | `<REDACTED>` | ☐ No |
| 13 | `GOOGLE_PLACES_API_KEY` | **Server-side** Google Places key for map-service | `map-service/.env.example`, `backend/.env` (map profile) | Map only | `<REDACTED>` | ☐ No |
| 14 | `GOOGLE_PLACES_PHOTO_URL_TEMPLATE` | Places photo URL template (optional) | `map-service/.env.example` | Map only | `<REDACTED>` / unset | ☐ No |
| 15 | `SMTP_HOST` / `SMTP_PORT` / `SMTP_USERNAME` / `SMTP_PASSWORD` | Outbound mail for reset/verify (only when `VITHEY_MAIL_MODE=smtp`) | `auth-service/.env.example` | Email delivery | `<REDACTED>` / unset (default mode `log`) | ☐ No |
| 16 | `FCM_DEBUG_TOKEN` | Debug device token (client) | `vithey_app/.env` | FCM (disabled) | `<REDACTED>` / unset | ☐ No |
| 17 | `GOOGLE_MAPS_API_KEY` (client) | Android/iOS map rendering key | `android/local.properties`, `ios/Flutter/Secrets.xcconfig` | Map rendering | `<REDACTED>` | ☐ No |
| 18 | `FIREBASE_CREDENTIALS_PATH` | Firebase service-account path | **Not configured in repo** (FCM disabled) | Push (not active) | TBD — Requires confirmation. | ☐ N/A |
| 19 | GHCR / GitHub secrets | CI login + auto-promote (`GITHUB_TOKEN`) | GitHub Actions (`secrets.GITHUB_TOKEN`) | CI | Managed by GitHub | ☐ No |
| 20 | GPG / release signing keys | Android release signing | `android/app/build.gradle` (**currently debug keys**) | Release build | TBD — Requires confirmation. | ☐ No |

[VERIFIED: `.env.example` files, `ai_core/.env.example`, `monitoring/.env.example`,
`backend/services/*/.env.example`; `_meta/EVIDENCE-BASIS.md` §5, §13]

## 3. Non-secret configuration (for completeness)

These are frequently mistaken for secrets and are safe to document:

`POSTGRES_DB`, `AUTH_DB_URL`, `MAP_DB_URL`, `FILE_DB_URL`, `REDIS_HOST`, `REDIS_PORT`,
`RABBITMQ_HOST`, `MINIO_ENDPOINT`, `MINIO_BUCKETS`, `EUREKA_URL`, `CONFIG_SERVER_URL`,
`VITHEY_ACCESS_TOKEN_TTL` (15m), `VITHEY_REFRESH_TOKEN_TTL` (7d), `VITHEY_EVENTS_EXCHANGE`
(`vithey.events`), `DATABASE_URL` (ai_core), `APP_ENV`, `API_BASE_URL`, `WS_BASE_URL`, `USE_MOCK_*`.

[VERIFIED: `.env.example` files]

## 4. Handling rules (mandatory)

- Do **not** commit any `.env` file — only `.env.example` is tracked
  [VERIFIED: `_meta/EVIDENCE-BASIS.md` §5].
- Do **not** paste real values into this or any documentation; use `<REDACTED>`.
- After transfer, the recipient should **rotate** all secrets (JWT secret, DB/queue/MinIO, LLM key,
  Grafana) so the development team's local copies are invalidated.
- Confirm the `.env.example` **placeholder** value for `VITHEY_JWT_SECRET` is not used in any shared
  environment; replace it with a strong, unique secret.

## 5. Transfer verification

| Step | Done? |
| --- | --- |
| Inventory reviewed against source environment | ☐ |
| Secrets shared over approved secure channel | ☐ |
| Recipient set each value in the correct location | ☐ |
| Secrets rotated post-transfer | ☐ |
| No real values in git history or docs | ☐ |

**No credential handover has occurred.**

## 6. Related

- [03-source-code-handover.md](03-source-code-handover.md) · [04-environment-handover.md](04-environment-handover.md) · [08-handover-signoff.md](08-handover-signoff.md)
- [../10-security/](../10-security/) · [../00-project-overview/07-document-index.md](../00-project-overview/07-document-index.md)
