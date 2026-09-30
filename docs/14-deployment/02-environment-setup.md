# Environment Setup

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `AGENTS.md`, `backend/.env.example`, `backend/infrastructure/.env.example`, `backend/services/*/.env.example`, `ai_core/.env.example`, `monitoring/.env.example`, `vithey_app/.env.example`, `backend/scripts/*.ps1`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [Deployment architecture](01-deployment-architecture.md) · [Development deployment](03-development-deployment.md) · [Environment configuration](../13-devops/04-environment-configuration.md)

## 1. Machine prerequisites

| Tool | Version | Needed for |
|---|---|---|
| Docker Desktop (WSL2 backend) | recent | compose stack, monitoring, smoke IT |
| Java JDK | 21 | backend build/test, host-run services |
| Maven | bundled wrapper / 3.9.x | backend |
| Flutter SDK | CI pins `3.16.9` | mobile app |
| Python | 3.10+ (CI uses 3.12) | ai_core |
| PowerShell | 5.1+ | operational scripts |

[VERIFIED — `AGENTS.md`, workflow tool versions]

## 2. Environment status

| Environment | Status |
|---|---|
| Local development | Local development (verified) |
| Local demo (Profile M) | Local demo (verified) |
| Staging | Staging (does not exist) |
| Production | Production (does not exist) |

Setup below configures the two **local** environments only.

## 3. Copy `.env` files (never commit)

All `.env` files are gitignored; only `.env.example` is tracked.

```powershell
# from backend/
Copy-Item .env.example .env
Copy-Item infrastructure/.env.example infrastructure/.env

# ai_core (required before any demo stack start)
Copy-Item ..\ai_core\.env.example ..\ai_core\.env     # then set DEEPSEEK_API_KEY

# monitoring (optional)
Copy-Item ..\monitoring\.env.example ..\monitoring\.env

# Flutter (required before build/analyze/test)
Copy-Item ..\vithey_app\.env.example ..\vithey_app\.env
```

[VERIFIED — `AGENTS.md`, `backend/scripts/docker-up-demo.ps1`]

> `ai_core/.env` must exist with `DEEPSEEK_API_KEY` set, otherwise `docker-up-demo.ps1` exits with an error. [VERIFIED]

## 4. Flutter app

```powershell
cd vithey_app
Copy-Item .env.example .env
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter run          # Android emulator or physical device
```

Set `API_BASE_URL=http://10.0.2.2:8080/api/v1` for an emulator, or `http://<PC-LAN-IP>:8080/api/v1` for a physical device. Web/Chrome is unsupported. [VERIFIED — `vithey_app/.env.example`, `AGENTS.md`]

## 5. Backend (host toolchain)

```powershell
cd backend
mvn test
```

Java 21 required. `*SmokeIT` need Docker and are skipped otherwise. [VERIFIED — `AGENTS.md`, `TESTING.md`]

## 6. ai_core (host toolchain)

```powershell
cd ai_core
pip install -e ".[server,dev]"
pytest
python main.py serve --port 8100
```

[VERIFIED — `AGENTS.md`, `ai_core/README.md`]

## 7. Docker stack

```powershell
cd backend
.\scripts\docker-up-demo.ps1            # Profile M
```

Requires `ai_core/.env` (DEEPSEEK key). `.\scripts\set-docker-limits.ps1` optionally caps Docker Desktop (WSL2) RAM/CPU. [VERIFIED]

## 8. Monitoring (optional)

```powershell
cd monitoring
Copy-Item .env.example .env
docker compose --profile monitoring up -d
```

`vithey-network` must exist (start the backend stack first). [VERIFIED — `monitoring/README.md`]

## 9. Configuration sources summary

| Concern | Source |
|---|---|
| JVM heap / mem limits | `backend/.env` (demo overlay) |
| DB/Rabbit/MinIO credentials | `backend/infrastructure/.env` |
| Service URLs, profiles | `backend/services/<svc>/.env` |
| LLM key/knobs | `ai_core/.env` |
| Grafana admin | `monitoring/.env` |
| Flutter API endpoints | `vithey_app/.env` |
| Image-baked service defaults | `backend/infrastructure/config-repo/*.yml` |

[VERIFIED]

## 10. Verification

```powershell
cd backend
.\scripts\check-service-health.ps1
.\scripts\verify-docker.ps1
.\scripts\smoke-api.ps1
```

[VERIFIED — `backend/scripts/`]

[TBD] Network/security prerequisites for any shared or remote environment — TBD — Requires confirmation.
