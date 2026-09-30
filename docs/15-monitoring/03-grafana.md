# Grafana

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `monitoring/docker-compose.yml`, `monitoring/grafana/provisioning/datasources/datasource.yml`, `monitoring/grafana/provisioning/dashboards/dashboard.yml`, `monitoring/grafana/dashboards/*.json`, `monitoring/.env.example`, `monitoring/README.md`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [Monitoring overview](01-monitoring-overview.md) · [Prometheus](02-prometheus.md) · [Loki logging](04-loki-logging.md)

## 1. Access

| Property | Value |
|---|---|
| URL | `http://localhost:3000` |
| Admin user | `${GRAFANA_USER}` |
| Admin password | `${GRAFANA_PASSWORD}` |
| Sign-up | disabled (`GF_USERS_ALLOW_SIGN_UP=false`) |

Credentials come from `monitoring/.env` (defaults in `.env.example`). Values are `<REDACTED>` here — never commit real credentials. [VERIFIED — `monitoring/docker-compose.yml`, `.env.example`]

## 2. Provisioning as code

Grafana is fully provisioned from mounted read-only directories:

```
monitoring/grafana/
├── provisioning/
│   ├── datasources/datasource.yml
│   └── dashboards/dashboard.yml
└── dashboards/
    ├── spring-boot-microservices.json
    ├── infrastructure.json
    ├── docker-containers.json
    └── chat-service.json
```

[VERIFIED]

### Datasources (`datasource.yml`)

| Name | UID | Type | URL | Default |
|---|---|---|---|---|
| Prometheus | `prometheus` | prometheus | `http://prometheus:9090` | yes |
| Loki | `loki` | loki | `http://loki:3100` | no |

Both are `editable: false`. [VERIFIED]

### Dashboard provider (`dashboard.yml`)

A file provider named **Vithey**, folder **Vithey App**, path `/etc/grafana/dashboards`. Dashboards are editable in the UI (`editable: true`, `disableDeletion: false`). [VERIFIED]

## 3. Dashboards

| Dashboard | Contents |
|---|---|
| Spring Boot Microservices | request rate, latency, 5xx, JVM memory/CPU, threads, GC |
| Infrastructure | host CPU, RAM, disk, network (node-exporter) |
| Docker Containers | per-container CPU, memory, status (cAdvisor) |
| Chat Service | WebSocket, message rate, Redis, error logs |

[VERIFIED — `monitoring/README.md`, dashboard JSON files]

## 4. Data volumes and persistence

- `vithey-grafana-data` persists Grafana's database across restarts.
- Provisioned datasources/dashboards are re-applied on every start, so UI edits to **provided** properties are overwritten; ad-hoc dashboards created in the UI persist in the volume.

[VERIFIED — `monitoring/docker-compose.yml`]

## 5. Log search (Explore → Loki)

Use Grafana **Explore** with the Loki datasource:

```logql
{service="auth-service"}
{service="chat-service"} |= "ERROR"
{service=~"api-gateway|auth-service"}
```

Promtail labels Docker containers matching `vithey-*` as `service` (prefix stripped) and flags lines matching `error|exception|failed` with `level="error"`. [VERIFIED — `promtail-config.yml`]

## 6. Operations

```powershell
cd monitoring
docker compose --profile monitoring up -d grafana
docker compose --profile monitoring restart grafana
docker compose --profile monitoring logs -f grafana
```

[VERIFIED]

## 7. Gaps / notes

- No SSO/OAuth; local admin user only. [VERIFIED]
- Monitoring README warns to restrict the Grafana port and use strong passwords in any non-local environment. [VERIFIED — `monitoring/README.md` "Security Notes"]
- No alerting contact points are configured in Grafana. [VERIFIED]
