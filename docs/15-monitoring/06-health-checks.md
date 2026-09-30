# Health Checks

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/docker-compose.yml`, `backend/infrastructure/config-repo/application.yml`, `backend/scripts/check-service-health.ps1`, `backend/scripts/verify-docker.ps1`, `backend/scripts/smoke-api.ps1`, `ai_core/README.md`, service Dockerfiles

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [Monitoring overview](01-monitoring-overview.md) · [Incident response](07-incident-response.md) · [Health check runbook](../16-operations/03-health-check.md)

## 1. Endpoints

| Component | Endpoint | Expected |
|---|---|---|
| All Spring Boot services | `http://<host>:<port>/actuator/health` | `{"status":"UP"}` |
| ai_core | `http://localhost:8100/health` | `healthy` (or `degraded`) |
| Eureka dashboard | `http://localhost:8761/` | UI |
| Prometheus | `http://localhost:9090/-/healthy` | 200 |

Actuator exposure is configured in `config-repo/application.yml`: `health,info,metrics,prometheus` (and `application-prod.yml` narrows it to `health,info` with `show-details: when_authorized`). [VERIFIED]

## 2. Docker health checks

Every Java service defines a container health check that greps the actuator response:

```yaml
test: ["CMD-SHELL", "wget -qO- http://localhost:<port>/actuator/health | grep -q '\"status\":\"UP\"'"]
```

Domain services use the shared `x-service-health` anchor: interval 15s, timeout 5s, start-period 120s, retries 12. Platform services use a shorter start-period. ai_core probes `/health` with Python's `urllib`. Infra services use native checks (`pg_isready`, `redis-cli ping`, `rabbitmq-diagnostics ping`, MinIO health). [VERIFIED — `backend/docker-compose.yml`]

Images also carry an image-level `HEALTHCHECK` (30s interval, 60s start-period). [VERIFIED — service Dockerfiles]

`depends_on` uses `condition: service_healthy`, so the stack starts in dependency order. [VERIFIED]

## 3. Application-level readiness

- Gateway injects/validates JWT and does not need a database (it needs Redis for rate limiting). [VERIFIED]
- Services with `ddl-auto: validate` will report `DOWN` if Flyway schema does not match entities (e.g. the career `V3` duplication). [VERIFIED — `EVIDENCE-BASIS.md` §8]

## 4. Health-check scripts

### `check-service-health.ps1`
Checks `/actuator/health` for eureka, config, gateway and the 8 domain services (ports 8761, 8888, 8080-8088), then optionally `map-service` and `ai_core`. Exits non-zero if any required service fails.

```powershell
cd backend
.\scripts\check-service-health.ps1
.\scripts\check-service-health.ps1 -BaseHost <LAN-IP>
```

[VERIFIED]

### `verify-docker.ps1`
Inspects containers (`docker inspect -f '{{.State.Status}}'`) for the 6 infra + 10 required services, optionally `map-service`, and probes Eureka, Gateway, Auth and ai_core health. Prints a pass/fail summary and exits non-zero on failure. [VERIFIED]

### `smoke-api.ps1`
Exercises the full API surface and asserts gateway + ai_core health first. [VERIFIED]

## 5. Manual probes

```powershell
Invoke-RestMethod http://localhost:8080/actuator/health
Invoke-RestMethod http://localhost:8081/actuator/health
Invoke-RestMethod http://localhost:8100/health
Invoke-RestMethod http://localhost:8761/actuator/health
```

[VERIFIED — `DEMO.md`]

## 6. Interpreting failures

| Symptom | Likely cause |
|---|---|
| Service `DOWN` at start | dependency not healthy yet (wait for start-period 120s) |
| `DOWN` after config change | config-server not serving new config |
| DB validation failure | Flyway/entity mismatch (career `V3` duplication) |
| ai_core `degraded` | missing/invalid `DEEPSEEK_API_KEY` |
| Gateway 503 on a route | the target service is not running (subset mode) |

[VERIFIED / INFERRED — see [Troubleshooting](../16-operations/04-troubleshooting.md)]
