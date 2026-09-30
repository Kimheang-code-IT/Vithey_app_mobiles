# Secrets Management

> Status: Verified baseline (code-level) · Last reviewed: 2026-09-30
> Evidence: `.gitignore`, `backend/.env.example`, `backend/infrastructure/.env.example`, `backend/services/*/.env.example`, `ai_core/.env.example`, `vithey_app/.env.example`, `monitoring/.env.example`, `backend/infrastructure/config-repo/application*.yml`
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md` §13

## 1. Policy (as implemented)

- **No real secret is committed.** `.env` is gitignored at the repo root; only `.env.example`
  templates are tracked. [VERIFIED] `.gitignore`:
  ```
  # Environment (keep .env.example)
  .env
  !.env.example
  ```
- `git ls-files` returns **no committed `.env`** files. [VERIFIED]
- Secrets are injected at runtime via environment variables; config-server files reference
  them as `${VAR}` placeholders only. [VERIFIED] `config-repo/application.yml`, service yml.
- This document lists **variable names only**. No value is reproduced; where a template
  placeholder must be referenced it is shown as `<REDACTED>`.

## 2. Secret variables by component

### 2.1 Backend (config-server / services)

| Variable | Consumed by | Notes |
| --- | --- | --- |
| `VITHEY_JWT_SECRET` | gateway, all services, ai_core | HMAC signing key (≥256-bit). No default in prod config. |
| `POSTGRES_PASSWORD` / `<SVC>_DB_PASSWORD` | each service | Per-service DB password |
| `RABBITMQ_PASSWORD`, `RABBITMQ_USERNAME` | services | Defaults `guest`/`guest` |
| `REDIS_*` | gateway, chat, map | Host/port (no password by default) |
| `MINIO_ACCESS_KEY` / `MINIO_SECRET_KEY` | file-service | Object storage |
| `GOOGLE_PLACES_API_KEY` | map-service | Optional profile |
| `SMTP_USERNAME` / `SMTP_PASSWORD` | auth-service | Only for `VITHEY_MAIL_MODE=smtp` |

[VERIFIED] `.env.example` files. Values in templates are local placeholders (e.g.
`postgres`, `guest`, `change-me-...`) and must **not** be used outside local development.

### 2.2 ai_core

| Variable | Purpose |
| --- | --- |
| `DEEPSEEK_API_KEY` | LLM provider key (OpenRouter/DeepSeek) |
| `DEEPSEEK_BASE_URL`, `DEEPSEEK_MODEL` | Provider endpoint/model (non-secret) |
| `VITHEY_JWT_SECRET` | JWT verification for `/api/v1/ai/**` |
| `DATABASE_URL` | ai_db connection string (contains password) |

[VERIFIED] `ai_core/.env.example`, `vithey_ai/config.py`. ai_core ships a **default**
`VITHEY_JWT_SECRET` placeholder (`change-me-...`) used when unset. [VERIFIED] `config.py:86`.

### 2.3 Flutter app

| Variable | Purpose |
| --- | --- |
| `API_BASE_URL`, `WS_BASE_URL` | Endpoints (non-secret) |
| `GOOGLE_MAPS_API_KEY` (in `android/local.properties`) | Maps SDK |
| `FCM_DEBUG_TOKEN` | Optional debug only; FCM disabled |

[VERIFIED] `vithey_app/.env.example`. The app embeds **no** server secret; `.env` is a declared
pubspec asset and gitignored, so it must be copied before build/analyze/test. [VERIFIED] AGENTS.md.

### 2.4 Monitoring

`monitoring/.env.example` holds Grafana admin credentials and retention knobs. [VERIFIED]

## 3. How secrets flow

```mermaid
flowchart LR
  Dev[Local: copy .env.example to .env] --> Env[Environment variables]
  Env --> CS[config-server native config-repo]
  CS --> SVC[Services read ${VAR}]
  Env --> Compose[docker-compose demo interpolation]
  Env --> AI[ai_core Config]
  Compose --> SVC
  Compose --> AI
```

- Config-repo files are **baked into the config-server image**; changing config requires a
  config-server rebuild. [VERIFIED] EVIDENCE-BASIS §4.
- Compose reads `backend/.env` for resource caps and secrets. [VERIFIED] `docker-up-demo.ps1`.

## 4. Rotation & production readiness

| Concern | Status |
| --- | --- |
| Secret rotation procedure | None documented — TBD — Requires confirmation. |
| Secret manager (Vault/KMS/SSM) | Not used — plain env vars only. |
| CI secret handling | Only `${{ secrets.GITHUB_TOKEN }}` for GHCR; no app secrets in CI. [VERIFIED] `ci-promote-dev.yml` |
| Leak scanning (gitleaks/trufflehog) | Not configured. |
| `application-prod.yml` | Requires all secrets via env; disables Swagger; narrower actuator. [VERIFIED] |

## 5. Observations & risks

| # | Observation | Severity | Evidence |
| --- | --- | --- | --- |
| S1 | `.env.example` contains weak **dev-only** placeholders; risk only if copied to a real environment | Low | all `.env.example` |
| S2 | `ai_core` default `VITHEY_JWT_SECRET` means a misconfigured deployment silently verifies tokens with a public string | Medium | `config.py:86` |
| S3 | No secret rotation / no vault integration | Medium | absence |
| S4 | No automated secret scanning in CI | Low | `.github/workflows` |
| S5 | Compose datastore creds are trivial in templates | Low (non-prod) | `backend/.env.example` |

**Not yet formally assessed.** No credentials were exposed during production of this document;
only variable names appear above.

## 6. Cross-references

- [01-security-overview.md](01-security-overview.md) · [04-JWT-security.md](04-JWT-security.md) · [06-data-security.md](06-data-security.md)
- Deployment/runbook secrets: `../../backend/DOCKER.md`, `../../DEMO.md`
