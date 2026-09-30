# Prometheus

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `monitoring/prometheus/prometheus.yml`, `monitoring/prometheus/alerts.yml`, `monitoring/docker-compose.yml`, `backend/infrastructure/config-repo/application.yml`, `ai_core/README.md`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [Monitoring overview](01-monitoring-overview.md) · [Grafana](03-grafana.md) · [Alerting](05-alerting.md)

## 1. Configuration

`monitoring/prometheus/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
rule_files:
  - /etc/prometheus/alerts.yml
```

The container runs with `--config.file`, `--storage.tsdb.path=/prometheus` and `--web.enable-lifecycle` (reload via `POST /-/reload`). Metric data is stored in the `vithey-prometheus-data` volume. [VERIFIED — `monitoring/docker-compose.yml`, `prometheus.yml`]

## 2. Scrape jobs

| Job | Target | Metrics path |
|---|---|---|
| `prometheus` | `localhost:9090` | default |
| `node-exporter` | `node-exporter:9100` | default |
| `cadvisor` | `cadvisor:8080` | default |
| `api-gateway` | `vithey-api-gateway:8080` | `/actuator/prometheus` |
| `auth-service` | `vithey-auth-service:8081` | `/actuator/prometheus` |
| `user-profile-service` | `vithey-user-profile-service:8082` | `/actuator/prometheus` |
| `file-service` | `vithey-file-service:8083` | `/actuator/prometheus` |
| `content-service` | `vithey-content-service:8084` | `/actuator/prometheus` |
| `career-service` | `vithey-career-service:8085` | `/actuator/prometheus` |
| `finance-service` | `vithey-finance-service:8086` | `/actuator/prometheus` |
| `chat-service` | `vithey-chat-service:8087` | `/actuator/prometheus` |
| `notification-service` | `vithey-notification-service:8088` | `/actuator/prometheus` |
| `map-service` | *(not scraped)* | — |
| `eureka-server` / `config-server` | *(not scraped)* | — |
| `ai_core` | *(not scraped)* | — |

That is **12 scrape jobs total**, of which **9** are Spring Boot microservice jobs. `eureka-server`, `config-server`, `map-service` and `ai_core` are intentionally absent. [VERIFIED — `prometheus.yml:8-76`]

> ai_core exposes `GET /health` (liveness + config check) but no Prometheus endpoint. [VERIFIED — `ai_core/README.md`, no micrometer registry]

## 3. Available metrics (Spring Boot)

All services include `spring-boot-starter-actuator` + `micrometer-registry-prometheus`, exposing:

- `http_server_requests_seconds_*` — request rate, latency, status classes.
- `jvm_memory_*`, `jvm_gc_*`, `jvm_threads_*`, `process_cpu_usage`.
- `hikaricp_connections_*` — connection pool.
- Metrics are tagged `application=${spring.application.name}`. [VERIFIED — `config-repo/application.yml:42-49`]

## 4. Rule files

`/etc/prometheus/alerts.yml` is loaded from `monitoring/prometheus/alerts.yml`. Prometheus evaluates these rules, but **there is no `alerting:` block and no Alertmanager container** — alerts are only visible on the Prometheus **Alerts** tab. See [05-alerting.md](05-alerting.md). [VERIFIED]

## 5. Operations

| Task | Command |
|---|---|
| Check targets | open `http://localhost:9090/targets` |
| Check rules/alerts | open `http://localhost:9090/alerts` |
| Reload config | `Invoke-RestMethod -Method Post http://localhost:9090/-/reload` |
| Restart | `docker compose --profile monitoring restart prometheus` (from `monitoring/`) |

[VERIFIED — lifecycle flag in compose]

Targets show **DOWN** when the backend service is not running on `vithey-network`, or when a service lacks the Prometheus registry. [VERIFIED — `monitoring/README.md`]

## 6. Gaps

- No Alertmanager (no email/Slack/PagerDuty routing). [VERIFIED]
- No remote write / long-term storage. [VERIFIED]
- No recording rules. [VERIFIED]
- No dashboards for ai_core (no metrics exposed). [VERIFIED]
