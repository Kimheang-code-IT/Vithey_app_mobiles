# Development Deployment

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/scripts/docker-up-demo.ps1`, `backend/scripts/start-dev-host.ps1`, `backend/scripts/docker-up.ps1`, `backend/scripts/docker-down-demo.ps1`, `backend/DOCKER.md`, `backend/DEMO.md`, `monitoring/README.md`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [Environment setup](02-environment-setup.md) · [Staging deployment](04-staging-deployment.md) · [Start/stop system](../16-operations/02-start-stop-system.md)

## 1. Scope

This is the **verified local development / demo** deployment. There is no remote development server. All commands run from `backend/` on Windows PowerShell.

## 2. Prerequisites

- Docker Desktop running (for container modes).
- `ai_core/.env` with `DEEPSEEK_API_KEY` set.
- Optional: `backend/.env` copied from `.env.example` to tune resource caps.
- Optional: `GOOGLE_PLACES_API_KEY` for the `map` profile.

[VERIFIED — `backend/DEMO.md`, `docker-up-demo.ps1`]

## 3. Mode A — Profile M demo (recommended, Docker)

```powershell
cd backend
Copy-Item .env.example .env          # optional: tune limits
.\scripts\docker-up-demo.ps1
```

This runs `docker compose -f docker-compose.yml -f docker-compose.demo.yml up -d --build`.

Variants:

```powershell
.\scripts\docker-up-demo.ps1 -Profiles map
.\scripts\docker-up-demo.ps1 -Services auth-service,user-profile-service,api-gateway
```

[VERIFIED — `docker-up-demo.ps1`]

Stop:

```powershell
.\scripts\docker-down-demo.ps1          # stop, keep volumes
.\scripts\docker-down-demo.ps1 -v       # stop and wipe DBs (Flyway reset)
.\scripts\docker-down-demo.ps1 -Profiles map
```

[VERIFIED — `docker-down-demo.ps1`]

## 4. Mode B — Host-run dev (fastest iteration)

Runs infra in Docker and selected JVMs on the host, each in its own PowerShell window.

```powershell
.\scripts\start-dev-host.ps1
.\scripts\start-dev-host.ps1 -Services auth-service,api-gateway -Heap 128m
.\scripts\start-dev-host.ps1 -SkipInfra        # infra already running
.\scripts\start-dev-host.ps1 -Down             # stop infra containers
```

Defaults to `auth-service,user-profile-service,api-gateway` with `-Heap 160m`. Each service connects to Postgres on host port `15432`, RabbitMQ `localhost:5672`, Redis `localhost:6379`, MinIO `http://localhost:19000`. [VERIFIED — `start-dev-host.ps1`]

## 5. Mode C — Full Java stack (no demo caps)

```powershell
.\scripts\docker-up.ps1
# or
docker compose up -d --build
```

Includes infra, platform, all Java services and `ai_core`; does **not** include `map-service`. [VERIFIED — `docker-up.ps1`, `DOCKER.md`]

## 6. Mode D — Infra only / single service

```powershell
cd backend/infrastructure
docker compose up -d --build
cd ..
.\scripts\docker-build-service.ps1 auth-service -Up
```

[VERIFIED — `docker-build-service.ps1`, `DOCKER.md`]

## 7. Flutter against the local stack

```powershell
cd vithey_app
Copy-Item .env.example .env
# emulator:   API_BASE_URL=http://10.0.2.2:8080/api/v1
# device:     API_BASE_URL=http://<PC-LAN-IP>:8080/api/v1
flutter pub get
flutter run
```

Set `USE_MOCK_AI=false` after the stack is healthy to use live CV generation + stub chat. [VERIFIED — `vithey_app/.env.example`, `DEMO.md`]

## 8. Monitoring (optional)

```powershell
cd monitoring
Copy-Item .env.example .env
docker compose --profile monitoring up -d
```

Requires `vithey-network` to exist (start the backend stack first). [VERIFIED — `monitoring/README.md`]

## 9. Verify the deployment

```powershell
cd backend
.\scripts\check-service-health.ps1
.\scripts\verify-docker.ps1
.\scripts\smoke-api.ps1
```

`smoke-api.ps1` exercises register/login, profile, posts, AI chat/sessions/CV, student verify, fees/payments, peer chat, notifications and places, and asserts no `vithey-ai-service` container exists. [VERIFIED — `smoke-api.ps1`]

## 10. Teardown / cleanup

```powershell
.\scripts\docker-down-demo.ps1 -v
docker compose -f docker-compose.yml -f docker-compose.demo.yml down --remove-orphans
```

`--remove-orphans` is useful after retiring the Java `ai-service`. [VERIFIED — `DOCKER.md`]

## 11. Notes for sibling environments

Development deployment is the same model used for the local demo. Staging and production do **not** exist — see [Staging deployment](04-staging-deployment.md) and [Production deployment](05-production-deployment.md).
