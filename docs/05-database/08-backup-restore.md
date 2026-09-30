# Backup & Restore

> Status: Requires confirmation · Last reviewed: 2026-09-30
> Evidence: `backend/docker-compose.yml`, `backend/scripts/docker-down-demo.ps1`, `backend/scripts/docker-up-demo.ps1`, `backend/infrastructure/scripts/init-databases.sql`

> **There is no automated backup or restore mechanism in this repository.** No backup scripts, cron
> jobs, retention settings, or object-store replication configuration exist. The content below
> documents the only recoverable state that exists today (Docker volumes + Flyway) and marks
> production backup as `TBD — Requires confirmation.`

## 1. What persists, and where

All durable state is held in four named Docker volumes created by `backend/docker-compose.yml`:

| Volume | Holds | Backed up? |
|---|---|---|
| `vithey-postgres-data` | All nine databases (`auth_db` … `map_db`, `ai_db`) | No automation; manual only |
| `vithey-minio-data` | Uploaded file bytes (avatars, CVs, posters, videos, chat attachments) | No automation; manual only |
| `vithey-redis-data` | Cache/rate-limit state (not authoritative) | Not required |
| `vithey-rabbitmq-data` | Broker definitions/queues (transient) | Not required |

Evidence: `backend/docker-compose.yml:26-28, 43-44, 62-63, 82-84, 455-459`.

Databases and databases only are initialised by `init-databases.sql` on first container start
(`/docker-entrypoint-initdb.d/01-init-databases.sql`). That script only runs on an **empty** data
volume; it does not re-create data on an existing volume.

## 2. Flyway as the schema recovery path

The schema itself is reproducible from source: each service re-applies its
`src/main/resources/db/migration/*.sql` on startup against its database. So a *schema* recovery is
as simple as pointing a fresh database at the same service and letting Flyway migrate. This does
**not** restore row data. See [`06-migration-strategy.md`](06-migration-strategy.md).

> Caveat: the career-service duplicate `V3` (defect #1) means a clean `career_db` cannot be rebuilt
> deterministically from the current file set. This affects schema reproducibility for one database.

## 3. Volume-based backup (manual, current realistic approach)

Because there is no automation, any backup today is a manual operation against the volumes. The
generic approach (not implemented as a script in the repo):

```powershell
# 1) Stop the stack so the Postgres volume is quiescent (avoids torn pages)
.\scripts\docker-down-demo.ps1

# 2) Snapshot the named volumes from the host (Docker Desktop volume path)
#    e.g. copy to a timestamped folder:
#    docker run --rm -v vithey-postgres-data:/data -v ${PWD}:/backup alpine `
#      tar czf /backup/postgres-$(Get-Date -Format yyyyMMdd-HHmm).tgz -C /data .
#    Repeat for vithey-minio-data.

# 3) Restart the stack
.\scripts\docker-up-demo.ps1
```

Alternatively (logical, per-database) using `pg_dump` against the exposed Postgres port `15432`:

```powershell
# Replace <db> with auth_db, user_db, ... map_db  (credentials: POSTGRES_USER / POSTGRES_PASSWORD)
docker exec vithey-postgres pg_dump -U postgres -Fc <db> > <db>.dump
# Restore:
docker exec -i vithey-postgres pg_restore -U postgres -d <db> --clean --if-exists < <db>.dump
```

No such commands are wrapped in a checked-in script; they are documented here for operators.

## 4. Standard recovery procedure (manual)

1. Provision/host a Docker engine with the same compose setup.
2. Restore `vithey-postgres-data` and `vithey-minio-data` volumes (or `pg_restore` each database).
3. Ensure `backend/.env` / service `.env` values match the target environment (no secrets are
   committed; see `AGENTS.md`).
4. Start the stack: `.\scripts\docker-up-demo.ps1`.
5. Confirm Flyway applied no unexpected migrations and services report `UP` at
   `/actuator/health`.
6. Verify a sample API round-trip with `.\scripts\smoke-api.ps1`.

Object bytes and their `file_metadata` rows must be restored **together**, or `file-service`
downloads will 404 even though metadata exists (and vice versa).

## 5. Point-in-time / DR

- WAL archiving / PITR: not configured. `TBD — Requires confirmation.`
- Cross-region replication: none. `TBD — Requires confirmation.`
- Backup retention policy: none defined. `TBD — Requires confirmation.`
- RPO/RTO targets: not stated anywhere. `TBD — Requires confirmation.`
- Encryption/access control for backups: not specified. `TBD — Requires confirmation.`

## 6. Environment status

| Environment | Deployment | Backup |
|---|---|---|
| Local development | Verified | none (volumes can be wiped with `docker-down-demo.ps1 -v`) |
| Local demo (Profile M) | Verified | none |
| Staging | **Does not exist** | n/a |
| Production | **Does not exist** | `TBD — Requires confirmation.` |

See [`09-data-retention.md`](09-data-retention.md) for retention and
[`03-database-schema.md`](03-database-schema.md) for the data model.
