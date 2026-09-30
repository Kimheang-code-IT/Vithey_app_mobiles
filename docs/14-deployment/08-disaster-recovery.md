# Disaster Recovery

> Status: Verified (local only) · Last reviewed: 2026-09-30
> Evidence: `backend/scripts/*.ps1`, `backend/docker-compose.yml`, `monitoring/README.md`, `EVIDENCE-BASIS.md` §9, §12

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [Backup/restore](../16-operations/05-backup-restore.md) · [Rollback plan](07-rollback-plan.md) · [Troubleshooting](../16-operations/04-troubleshooting.md)

## 1. Scope and status

There is **no disaster recovery capability** for any remote environment because no remote environment exists (staging and production do not exist). There is also **no automated backup** of the local stack. [VERIFIED — `EVIDENCE-BASIS.md` §9]

This document covers recovery of the **local demo/development** environment from component failure, and states the gaps for any future environment.

## 2. Failure domains (local)

| Component | Failure | Recovery |
|---|---|---|
| Single service container | crash / unhealthy | `docker compose ... restart <svc>` or rebuild |
| Postgres | corruption / lost volume | restore from dump or reset volumes (data loss) |
| Redis | flush / restart | cache only; recovers empty (rate limits, chat recent cache, map cache) |
| RabbitMQ | restart | messages may be lost (no durable policy documented) |
| MinIO | lost volume | files lost without external backup |
| Config-server | bad config | revert `config-repo`, rebuild config-server |
| Host / Docker Desktop | crash | restart Docker Desktop; volumes persist unless wiped |
| Full PC loss | — | no off-host backup exists |

[VERIFIED — compose volumes and services; [INFERRED] for behaviours not explicitly configured]

## 3. Recovery procedures

### 3.1 Restart a failed service

```powershell
cd backend
docker compose -f docker-compose.yml -f docker-compose.demo.yml restart <service>
# or rebuild the image
docker compose -f docker-compose.yml -f docker-compose.demo.yml up -d --build <service>
```

### 3.2 Recover Postgres

- If the volume is intact, restarting the `postgres` container recovers automatically.
- If data is lost, either restore a `pg_dump` (see [Backup/restore](../16-operations/05-backup-restore.md)) or reset:

```powershell
.\scripts\docker-down-demo.ps1 -v
.\scripts\docker-up-demo.ps1
```

This is **destructive** and reinitialises all databases via `init-databases.sql`. [VERIFIED]

### 3.3 Full stack rebuild

```powershell
cd backend
.\scripts\docker-down-demo.ps1
.\scripts\docker-up-demo.ps1
.\scripts\check-service-health.ps1
```

### 3.4 Config recovery

Revert the offending `backend/infrastructure/config-repo/*.yml`, then rebuild config-server:

```powershell
docker compose -f docker-compose.yml -f docker-compose.demo.yml up -d --build config-server
```

[VERIFIED — config is baked into the image]

## 4. Recovery objectives

| Objective | Value | Evidence |
|---|---|---|
| RPO (recovery point objective) | No backup ⇒ last-known-good = current volume state; effectively undefined for off-host loss | no backup exists |
| RTO (recovery time objective) | Time to rebuild images + DB init (minutes to tens of minutes on a warm cache) | inferred from build times |

[INFERRED — no documented RPO/RTO. Requires business confirmation.]

## 5. Gaps (must be resolved before any real environment)

| Gap | Status |
|---|---|
| Automated DB backups | Not implemented — `TBD — Requires confirmation.` |
| Off-host/off-site backups | Not implemented |
| Restore drill / tested recovery | Not executed |
| Multi-node redundancy / failover | Not implemented |
| Documented RPO/RTO | `TBD — Requires confirmation.` |
| Incident communications plan | Not implemented (see [Incident response](../15-monitoring/07-incident-response.md)) |

[VERIFIED]
