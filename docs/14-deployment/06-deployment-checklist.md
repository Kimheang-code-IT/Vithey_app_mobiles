# Deployment Checklist

> Status: Verified (local) · Last reviewed: 2026-09-30
> Evidence: `backend/scripts/*.ps1`, `backend/.env.example`, `backend/DEMO.md`, `backend/DOCKER.md`, `monitoring/README.md`, `.github/workflows/ci-promote-dev.yml`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [Development deployment](03-development-deployment.md) · [Rollback plan](07-rollback-plan.md)

> This checklist covers deployment to the **verified local demo environment**. Staging and production do not exist; the "remote deployment" section is a recommendation stub only.

## A. Pre-flight (local demo)

- [ ] Docker Desktop running; WSL2 backend healthy.
- [ ] `ai_core/.env` exists with `DEEPSEEK_API_KEY` set. [VERIFIED — required by `docker-up-demo.ps1`]
- [ ] Optional: `backend/.env` copied from `.env.example` to tune limits.
- [ ] Optional: `backend/infrastructure/.env`, `monitoring/.env`, `vithey_app/.env` copied.
- [ ] Optional: `GOOGLE_PLACES_API_KEY` set if the `map` profile is needed.
- [ ] Ports 8080-8088, 8090, 8100, 8761, 8888, 15432, 16379, 5672, 15672, 19000-19001 free.
- [ ] Docker Desktop memory cap acceptable (`set-docker-limits.ps1` if needed).

[VERIFIED — `docker-up-demo.ps1`, `DEMO.md`, `DOCKER.md`]

## B. Build & start

- [ ] `cd backend`
- [ ] `.\scripts\docker-up-demo.ps1` (or `-Profiles map`, or `-Services ...` for a subset)
- [ ] First build completes (can take several minutes).
- [ ] `docker compose -f docker-compose.yml -f docker-compose.demo.yml ps` shows expected containers.

[VERIFIED]

## C. Health verification

- [ ] `.\scripts\check-service-health.ps1` — all required services `UP`.
- [ ] `.\scripts\verify-docker.ps1` — "Core stack looks healthy."
- [ ] `Invoke-RestMethod http://localhost:8080/actuator/health` → `status: UP`.
- [ ] `Invoke-RestMethod http://localhost:8100/health` → healthy.
- [ ] Eureka dashboard `http://localhost:8761` shows registered services.

[VERIFIED]

## D. Functional smoke

- [ ] `.\scripts\smoke-api.ps1` — registration, login, profile, posts, comments, reactions all PASS.
- [ ] AI chat + `cv/generate` + `cv/suggest` PASS.
- [ ] Student verify → fees/payments (403 before, 200 after) PASS.
- [ ] Peer chat (message-request → accept → message) PASS.
- [ ] Notifications PASS.
- [ ] `map-service` places PASS only if started with `-Profiles map` (otherwise note the skip).
- [ ] No `vithey-ai-service` container present.

[VERIFIED — `smoke-api.ps1`]

## E. Client configuration

- [ ] `vithey_app/.env` `API_BASE_URL` points at the running gateway (`10.0.2.2` emulator or LAN IP).
- [ ] `USE_MOCK_AI=false` for live AI.
- [ ] App installed and able to log in.

[VERIFIED]

## F. Monitoring (optional)

- [ ] `cd monitoring; docker compose --profile monitoring up -d`
- [ ] Prometheus targets `UP` at `http://localhost:9090/targets`.
- [ ] Grafana login works; **Vithey App** dashboards visible.
- [ ] Loki Explore returns logs for a service, e.g. `{service="auth-service"}`.

[VERIFIED — `monitoring/README.md`]

## G. CI gate (for code changes)

- [ ] `ci-promote-dev.yml` three test jobs green.
- [ ] Images built/pushed to GHCR (push events).
- [ ] Commit fast-forwarded to `dev`.
- [ ] No edit to an already-applied Flyway migration.

[VERIFIED]

## H. Remote deployment (recommendation — no environment exists)

> Staging and production do not exist. This section is a stub for a future process.

- [ ] (future) Staging validated — **not possible today** (staging does not exist).
- [ ] (future) Images pinned to `sha-<short>`.
- [ ] (future) Production secrets injected from a secret manager.
- [ ] (future) Rollback path confirmed (see [Rollback plan](07-rollback-plan.md)).

[PLANNED / TBD — Requires confirmation]
