# Operation Manual

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/scripts/*.ps1`, `backend/DOCKER.md`, `backend/DEMO.md`, `backend/TESTING.md`, `monitoring/README.md`, `AGENTS.md`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [Start/stop system](02-start-stop-system.md) · [Health check](03-health-check.md) · [Troubleshooting](04-troubleshooting.md) · [Backup/restore](05-backup-restore.md)

## 1. Scope

This manual is the practical runbook for operating the **local Vithey stack** on Windows. Staging and production do not exist; nothing here assumes a remote host.

## 2. System components

| Group | Components |
|---|---|
| Infra | postgres, redis, rabbitmq, minio |
| Platform | eureka-server, config-server |
| Domain services | auth, user-profile, file, content, career, finance, chat, notification (ports 8081-8088) |
| Optional | map-service (8090, profile `map`), ai_core (8100) |
| Gateway | api-gateway (8080) |
| Observability | prometheus, grafana, loki, promtail, node-exporter, cAdvisor (profile `monitoring`) |

Full port map: [Deployment architecture](../14-deployment/01-deployment-architecture.md).

## 3. Daily operations quick reference

| Task | Command (from `backend/`) |
|---|---|
| Start demo stack | `.\scripts\docker-up-demo.ps1` |
| Start with map | `.\scripts\docker-up-demo.ps1 -Profiles map` |
| Start subset | `.\scripts\docker-up-demo.ps1 -Services auth-service,api-gateway` |
| Start host-run dev | `.\scripts\start-dev-host.ps1` |
| Stop (keep data) | `.\scripts\docker-down-demo.ps1` |
| Stop and wipe data | `.\scripts\docker-down-demo.ps1 -v` |
| Health | `.\scripts\check-service-health.ps1` |
| Container verify | `.\scripts\verify-docker.ps1` |
| API smoke | `.\scripts\smoke-api.ps1` |
| Logs (whole stack) | `docker compose -f docker-compose.yml -f docker-compose.demo.yml logs --tail=200` |
| Logs (one service) | `... logs -f <service>` |
| Restart one service | `... restart <service>` |

[VERIFIED — `backend/scripts/`, `DOCKER.md`]

## 4. Single-service operations

```powershell
cd backend
.\scripts\docker-build-service.ps1 auth-service            # build
.\scripts\docker-build-service.ps1 auth-service -Up        # build + run
.\scripts\docker-build-service.ps1 auth-service -Down      # stop
```

Requires infra (`vithey-network`) to exist. `ai-core` is built from the monorepo compose, not this script. [VERIFIED]

## 5. Monitoring operations

```powershell
cd monitoring
Copy-Item .env.example .env
docker compose --profile monitoring up -d
docker compose --profile monitoring ps
docker compose --profile monitoring down
```

See [Monitoring overview](../15-monitoring/01-monitoring-overview.md). [VERIFIED]

## 6. Build and test operations

| Component | Commands |
|---|---|
| Backend | `mvn test`; single service `mvn -pl services/<svc> -am test` |
| Flutter | `Copy-Item .env.example .env; flutter pub get; flutter analyze --no-fatal-infos; flutter test` |
| ai_core | `pip install -e ".[server,dev]"; pytest` |

[VERIFIED — `AGENTS.md`, `TESTING.md`]

## 7. Resource management

- `backend/.env` controls heap and memory caps (demo overlay). Absent by default → built-in defaults apply.
- `.\scripts\set-docker-limits.ps1` caps Docker Desktop (WSL2) RAM/CPU and restarts WSL.
- Subset mode (`-Services`) and host-run mode reduce footprint for a 3-user laptop. [VERIFIED]

## 8. Change management

- **Flyway:** never edit an applied migration; add a new version. Reset local DBs with `docker-down-demo.ps1 -v`. [VERIFIED — `AGENTS.md`]
- **Config:** editing `config-repo/*.yml` requires a config-server image rebuild in non-bind-mount deployments. [VERIFIED]
- **Secrets:** `.env` only; `.env.example` holds placeholders. Never commit values. [VERIFIED]

## 9. Escalation

No formal support process exists — see [Support escalation](07-support-escalation.md). `TBD — Requires confirmation.`

## 10. Sibling runbooks

[Start/stop](02-start-stop-system.md) · [Health check](03-health-check.md) · [Troubleshooting](04-troubleshooting.md) · [Backup/restore](05-backup-restore.md) · [Maintenance](06-maintenance.md)
