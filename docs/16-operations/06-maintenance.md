# Maintenance

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/scripts/*.ps1`, `backend/docker-compose.yml`, `backend/.env.example`, `backend/infrastructure/config-repo/*.yml`, `monitoring/README.md`, `AGENTS.md`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [Operation manual](01-operation-manual.md) · [Backup & restore](05-backup-restore.md) · [Troubleshooting](04-troubleshooting.md)

## 1. Routine maintenance tasks

| Cadence | Task | Command / action |
|---|---|---|
| Per change | Rebuild affected image(s) | `docker-up-demo.ps1` or `docker-build-service.ps1 <svc> -Up` |
| Per change | Run tests + lint | backend `mvn test`; Flutter `flutter analyze --no-fatal-infos` + `flutter test`; ai_core `pytest` |
| Weekly | Pull updated base/infra images | `docker compose ... pull` then `up -d` |
| As needed | Clear stale containers | `down --remove-orphans` |
| As needed | Prune dangling images | `docker image prune` |
| As needed | Reclaim host RAM | `set-docker-limits.ps1`, restart Docker Desktop |
| Quarterly | Review `.env` knobs vs load | edit `backend/.env` |

[VERIFIED / INFERRED — no scheduled maintenance automation exists]

## 2. Configuration maintenance

### Service config (`config-repo`)
`backend/infrastructure/config-repo/*.yml` is baked into the config-server image. Changing it requires a config-server rebuild, **except** locally where the repo is bind-mounted read-only (live).

```powershell
# apply a config change locally
docker compose -f docker-compose.yml -f docker-compose.demo.yml up -d --build config-server
```

[VERIFIED]

> Note: `vithey-app` gateway routes/params can be changed via bind mount locally, but in an image deployment the config-server must be rebuilt. [VERIFIED — `docker-compose.yml:128-130`]

### Resource limits
All caps come from `backend/.env`. Never hardcode limits in compose; add/use a `${VAR:-default}` knob. [VERIFIED — `AGENTS.md`]

## 3. Database maintenance

- Flyway runs forward-only on service start; **never edit an applied migration** (checksum mismatch). Add a new version instead. [VERIFIED]
- Known maintenance blocker: career-service has duplicate `V3__` migrations; a fresh DB apply will fail until versioning is fixed. Reset with `docker-down-demo.ps1 -v` when needed. [VERIFIED — `EVIDENCE-BASIS.md` §8]
- Keep connection pools aligned with `DB_POOL_MAX` / `DB_POOL_MIN`. [VERIFIED]

## 4. Image and dependency maintenance

| Item | Current practice |
|---|---|
| Java build/runtime images | pinned (`maven:3.9.11-...`, `eclipse-temurin:21-jre-alpine`) |
| Postgres/Redis/RabbitMQ/MinIO/monitoring | floating `latest`/`16-alpine`/`7-alpine` — update deliberately |
| Maven deps | Spring Boot 3.3.5 / Spring Cloud 2023.0.3 |
| ai_core deps | pinned ranges in `ai_core/Dockerfile` |

[VERIFIED]

Updating a floating infra image:

```powershell
cd backend
docker compose -f docker-compose.yml -f docker-compose.demo.yml pull postgres redis rabbitmq minio
docker compose -f docker-compose.yml -f docker-compose.demo.yml up -d
```

[VERIFIED]

## 5. Monitoring maintenance

- Prometheus TSDB and Loki data live in named volumes; Loki prunes logs older than **168h** automatically. [VERIFIED]
- Grafana provisioned dashboards/datasources are re-applied on start; UI-created dashboards persist in the volume. [VERIFIED]
- Periodically review Prometheus `/targets` and `/alerts`. [VERIFIED]

## 6. Security maintenance

| Task | Status |
|---|---|
| Rotate `VITHEY_JWT_SECRET` | manual; must be updated on gateway + all services together |
| Rotate `DEEPSEEK_API_KEY`, `GOOGLE_PLACES_API_KEY` | manual |
| Rotate DB/MinIO/Rabbit credentials | manual (infra `.env`) |
| Dependency/vulnerability scanning | Not implemented |
| Secret scanning in CI | Not implemented |

[VERIFIED — no automated rotation/scanning]

> `VITHEY_JWT_SECRET` must match across gateway and every service or all tokens are rejected. [VERIFIED]

## 7. Cleanup procedures

```powershell
cd backend
# stop everything
.\scripts\docker-down-demo.ps1

# remove orphan containers from retired services
docker compose -f docker-compose.yml -f docker-compose.demo.yml down --remove-orphans

# optional: prune unused images
docker image prune
```

[VERIFIED]

## 8. Maintenance windows

No scheduled maintenance window process exists (no production). For local work, maintenance is simply stopping/starting the stack. [TBD]

[TBD] Formal patching cadence, dependency upgrade policy and maintenance-window process — TBD — Requires confirmation.
