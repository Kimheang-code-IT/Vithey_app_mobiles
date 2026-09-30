# Vithey Backend — Docker

Three ways to run the stack. Prefer the **full stack** or **Profile M demo** for end-to-end work.

## Layout

```
backend/
  .env.example                    # env-tunable resource limits / profiles
  docker-compose.yml              # full Java stack + infra + Python ai-core (external-services/)
  docker-compose.demo.yml         # Profile M overlay (env-driven caps; map opt-in)
  DEMO.md                         # demo prerequisites and smoke
  infrastructure/docker-compose.yml   # infra-only (legacy / incremental)
  services/<name>/
    Dockerfile
    docker-compose.yml            # single-service incremental run
    .env.example
```

## Option A — Full Java stack

From `backend/`:

```powershell
.\scripts\docker-up.ps1
# or: docker compose -f docker-compose.yml up -d --build
```

Stops with `.\scripts\docker-down.ps1`.

Includes Postgres, Redis, RabbitMQ, MinIO, Eureka, Config Server, all Java microservices (the Java `ai-service` is retired), Python `ai-core` (`external-services/ai-core`), and the API gateway. Does **not** include `map-service` (gateway `/places/**` returns 503 until map is started with the `map` profile).

## Option B — Profile M demo (recommended for Flutter live API)

Adds env-driven JVM/memory caps and Python AI (`external-services/ai-core`, chat stub, no GDCE):

```powershell
copy .env.example .env          # tune limits / profiles (optional)
.\scripts\docker-up-demo.ps1
.\scripts\docker-down-demo.ps1
# Pass -v on down to wipe volumes (Flyway / DB reset)
# Pass -Profiles map to also start map-service
```

Details: [DEMO.md](DEMO.md). Smoke: `.\scripts\smoke-api.ps1`.

Gateway routes `/api/v1/ai/**` to `http://ai-core:8100`. Python `ai-core` (`external-services/ai-core`) owns the whole AI surface (chat + CV), so no Java AI service is needed.

### Lean / 3-user mode (no hardcoding)

All resource limits are read from `backend/.env` (Compose auto-loads it). Copy `backend/.env.example` and edit numbers to scale up later — no compose edits:

| Knob | Purpose | Lean default |
|------|---------|--------------|
| `SERVICE_JAVA_OPTS` / `SERVICE_MEM_LIMIT` | every domain JVM | `-Xmx192m` / `320m` |
| `GATEWAY_JAVA_OPTS` / `GATEWAY_MEM_LIMIT` | API gateway | `-Xmx256m` / `384m` |
| `PLATFORM_JAVA_OPTS` / `PLATFORM_MEM_LIMIT` | Eureka + Config | `-Xmx160m` / `256m` |
| `PG_*`, `REDIS_*`, `RABBITMQ_MEM_LIMIT`, `MINIO_MEM_LIMIT` | infra | see `.env.example` |
| `DB_POOL_MAX`, `DB_POOL_MIN` | Hikari pool per service | `5` / `1` |
| `RABBIT_CONCURRENCY` / `RABBIT_MAX_CONCURRENCY` | listener pool | `1` / `2` |
| `AI_CORE_MEM_LIMIT`, `AI_CORE_WORKERS` | external-services/ai-core | `256m` / `1` |

Optional services are opt-in through Compose profiles:

| Profile | Starts | Command |
|---------|--------|---------|
| `map` | `map-service` | `.\scripts\docker-up-demo.ps1 -Profiles map` (or `COMPOSE_PROFILES=map` in `.env`) |
| `monitoring` | Prometheus/Grafana/Loki/... | `cd monitoring; docker compose --profile monitoring up -d` |

`monitoring/` starts nothing without its profile, so the lean stack leaves it off. Monitoring stack: see `../monitoring/README.md`.

### Even leaner: run only what you need

**Subset mode** — start only the services a feature touches. Gateway routes for anything not running return `503` (Flutter can mock those), so nothing else is forced to start:

```powershell
# auth + profile + gateway (+ their infra deps only)
.\scripts\docker-up-demo.ps1 -Services auth-service,user-profile-service,api-gateway
```

Common useful subsets:

| Working on | `-Services` |
|------------|-------------|
| Login / profile | `auth-service,user-profile-service,api-gateway` |
| Feed / posts | `auth-service,user-profile-service,content-service,file-service,api-gateway` |
| Jobs / CV | `auth-service,user-profile-service,content-service,career-service,api-gateway` |
| AI only | `auth-service,user-profile-service,content-service,ai-core,api-gateway` |

**Host-run dev mode** — infra in Docker, selected JVMs on the host with tiny heaps and hot logs. Lowest overhead and fastest iteration:

```powershell
.\scripts\start-dev-host.ps1
.\scripts\start-dev-host.ps1 -Services auth-service,api-gateway -Heap 128m
.\scripts\start-dev-host.ps1 -Down   # stop infra
```

Each service opens in its own PowerShell window; close it to stop that service.

**Cap Docker Desktop itself (WSL2)** — the host-level guarantee that containers cannot starve Windows:

```powershell
.\scripts\set-docker-limits.ps1                 # 6 GB / 4 CPUs
.\scripts\set-docker-limits.ps1 -Memory 8GB -Processors 6
```

This writes `%UserProfile%\.wslconfig` from `.wslconfig.example`, backs up any existing file, and runs `wsl --shutdown`. Restart Docker Desktop, then check `docker info --format '{{.MemTotal}}'`.

> After retiring the Java `ai-service`, an old container may linger. Clean it with:
> `docker compose -f docker-compose.yml -f docker-compose.demo.yml down --remove-orphans`

## Option C — One service at a time

Infra once:

```powershell
cd backend/infrastructure
docker compose up -d
```

Then from a service folder (or helper script):

```powershell
cd backend
.\scripts\docker-build-service.ps1 auth-service -Up
```

Available names: `auth-service`, `user-profile-service`, `file-service`, `content-service`, `career-service`, `finance-service`, `chat-service`, `notification-service`, `map-service`, `ai-core`, `api-gateway`, `eureka-server`, `config-server`.

Maven build context remains the backend monorepo root (`context: .` or `../..` depending on compose file).

## Port map

| Service | Host port |
|---------|-----------|
| API Gateway | 8080 |
| auth | 8081 |
| user-profile | 8082 |
| file | 8083 |
| content | 8084 |
| career | 8085 |
| finance | 8086 |
| chat | 8087 |
| notification | 8088 |
| map-service (demo) | 8090 |
| ai-core | 8100 |
| Eureka | 8761 |
| Config Server | 8888 |
| PostgreSQL | 15432 |
| Redis | 16379 |
| RabbitMQ / management | 5672 / 15672 |
| MinIO API / console | 19000 / 19001 |

## Health & verify

```powershell
cd backend
.\scripts\check-service-health.ps1
.\scripts\verify-docker.ps1
```

## Notes

- Network: `vithey-network`
- Spring profile: `docker` via each `services/*/ .env.example`
- Config repo is embedded in the `config-server` image
- Monitoring stack (`../monitoring`) is opt-in via its `monitoring` profile; cAdvisor uses host **8095** so it does not clash with map **8090**

See `TESTING.md`, `DEMO.md`, and `infrastructure/.env.example`.
