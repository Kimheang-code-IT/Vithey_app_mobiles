# Vithey App — Monitoring (minimal)

Low-resource local development monitoring: **Prometheus + Grafana only**.

| Service | URL | Purpose |
| --- | --- | --- |
| Prometheus | http://localhost:9090 | Metrics + target status |
| Grafana | http://localhost:3000 | Dashboards |

There is no log aggregation and no host/container exporter stack (no Loki,
Promtail, node-exporter, or cAdvisor). Docker logs stay in Docker; use
`docker logs <container>` if you need them.

> Historical reference: `docs/Prompt Devops/v1/08-monitoring-observability-prompt.md`.

## Prerequisites

1. The external network `vithey-network` exists — start the backend stack first:
   `cd backend && docker compose up -d` (or `.\scripts\docker-up-demo.ps1`).
2. The Spring Boot services are running and expose `/actuator/prometheus`.

## Quick start

The stack is opt-in (`profiles: ["monitoring"]`), so a plain `docker compose up`
starts nothing here.

```powershell
cd monitoring
docker compose --profile monitoring up -d
docker compose --profile monitoring ps
```

Grafana admin credentials default to `admin` / `admin123`; override with
`GRAFANA_USER` / `GRAFANA_PASSWORD` (see `.env.example`). No `.env` file is
required.

## Stop

```powershell
docker compose --profile monitoring down
```

## What is monitored

Prometheus scrapes **only** Vithey services that actually expose Micrometer
metrics at `/actuator/prometheus` (30s interval):

| Job | Target | Service port |
| --- | --- | --- |
| `prometheus` | `localhost:9090` | 9090 |
| `api-gateway` | `vithey-api-gateway:8080` | 8080 |
| `auth-service` | `vithey-auth-service:8081` | 8081 |
| `user-profile-service` | `vithey-user-profile-service:8082` | 8082 |
| `file-service` | `vithey-file-service:8083` | 8083 |
| `content-service` | `vithey-content-service:8084` | 8084 |
| `career-service` | `vithey-career-service:8085` | 8085 |
| `finance-service` | `vithey-finance-service:8086` | 8086 |
| `chat-service` | `vithey-chat-service:8087` | 8087 |
| `notification-service` | `vithey-notification-service:8088` | 8088 |

Not monitored (no Prometheus metrics endpoint / not always running):

- `external-services/ai-core` (FastAPI) — no `/metrics`.
- `eureka-server`, `config-server` — no `micrometer-registry-prometheus`.
- `map-service` — opt-in `map` profile; add a job in `prometheus/prometheus.yml`
  (`vithey-map-service:8090`) if you run it.

Backend metrics endpoint security: each servlet service permits
`/actuator/prometheus` (in addition to `/actuator/health` and `/actuator/info`)
so Prometheus can scrape without a JWT. The gateway already treats
`/actuator/**` as public. `application-prod.yml` only exposes `health,info`, so
nothing new is exposed in production.

## Dashboard

One dashboard, folder **Vithey App**: `Vithey Backend`
(`grafana/dashboards/vithey-backend.json`):

- Services up (stat) and per-service availability (`up`)
- HTTP request rate (`http_server_requests_seconds_count`)
- HTTP 5xx error rate and error ratio
- Response time p95 (`http_server_requests_seconds_bucket`)
- JVM heap used (`jvm_memory_used_bytes`) and JVM process CPU (`process_cpu_usage`)

Use the **Service** variable at the top to filter to one or more jobs.

## Verify

```powershell
# targets and their health
curl http://localhost:9090/api/v1/targets

# a sample query
curl "http://localhost:9090/api/v1/query?query=up"
```

Open http://localhost:9090/targets — each job should be **UP** while the
matching container runs on `vithey-network`.

## Resource usage

Defaults (override via env): Prometheus `512m`, Grafana `384m`, 30s scrape
interval, 6h TSDB retention (`PROMETHEUS_RETENTION`), json-file logs capped at
10m x 2. No exporters or log shipper are run.

## Troubleshooting

| Issue | Fix |
| --- | --- |
| `vithey-network` not found | Start the backend stack first (`backend/docker-compose.yml`). |
| A target is DOWN | Start that service; check `docker logs vithey-<service>`. |
| `401`/`403` when curling `/actuator/prometheus` | That service's `SecurityConfig` must permit `/actuator/prometheus`. |
| Empty JVM panels | The service image lacks `micrometer-registry-prometheus`; rebuild it. |
| Grafana login fails | Set `GRAFANA_USER` / `GRAFANA_PASSWORD` and recreate the container. |

## Security notes

- Do not commit `monitoring/.env`; keep real credentials out of the repo.
- In production, expose only `health,info` (already the case) and keep Grafana
  off the public network.
