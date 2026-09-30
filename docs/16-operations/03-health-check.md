# Health Check

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/scripts/check-service-health.ps1`, `backend/scripts/verify-docker.ps1`, `backend/scripts/smoke-api.ps1`, `backend/docker-compose.yml`, `backend/infrastructure/config-repo/application.yml`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [Operation manual](01-operation-manual.md) · [Troubleshooting](04-troubleshooting.md) · [Monitoring health checks](../15-monitoring/06-health-checks.md)

## 1. Three levels of checking

| Level | Tool | What it proves |
|---|---|---|
| Container | `verify-docker.ps1` | containers running + key health endpoints UP |
| Service | `check-service-health.ps1` | `/actuator/health` = UP for each service |
| Functional | `smoke-api.ps1` | end-to-end API flows via the gateway |

[VERIFIED — `backend/scripts/`]

## 2. `verify-docker.ps1`

Checks `docker inspect -f '{{.State.Status}}'` for:

- Infra (6): eureka-server, config-server, postgres, redis, rabbitmq, minio
- Services (10): auth, user-profile, file, content, career, finance, chat, notification, api-gateway, ai-core
- Optional: map-service

Then probes health: Eureka, Gateway, Auth, ai_core (required = 4), plus optional map. Prints "Core stack looks healthy." and exits 0 only when all required containers are running and all required health checks pass. [VERIFIED]

```powershell
cd backend
.\scripts\verify-docker.ps1
```

## 3. `check-service-health.ps1`

Polls `http://<BaseHost>:<port>/actuator/health` for ports 8761 (eureka), 8888 (config), 8080 (gateway), 8081-8088 (domain services), and optionally 8090 (`map-service`) and 8100 (`ai_core` `/health`). Exits non-zero if any required service is not `status: UP`.

```powershell
.\scripts\check-service-health.ps1
.\scripts\check-service-health.ps1 -BaseHost 192.168.1.10
```

[VERIFIED]

## 4. `smoke-api.ps1`

Full gateway smoke (default base `http://localhost:8080/api/v1`). It verifies health first, then:

register → login → `/auth/me` → `/users/me` (GET/PATCH) → create post → feed → comment → reaction → AI chat → sessions → regenerate → `cv/generate` → `cv/suggest` → fees 403 before verify → student verify → refresh → fees after verify → payments → conversations → message-requests → peer registration → request/accept/message → notifications → unread count → `/users/me/cv` → places history → logout → asserts no `vithey-ai-service` container.

Summary prints `PASS/FAIL/total` and exits 1 on any failure. [VERIFIED]

```powershell
cd backend
.\scripts\smoke-api.ps1
```

## 5. Manual probes

```powershell
Invoke-RestMethod http://localhost:8080/actuator/health
Invoke-RestMethod http://localhost:8081/actuator/health
Invoke-RestMethod http://localhost:8100/health
```

[VERIFIED]

## 6. Expected response shape

```text
{"status":"UP","components":{"db":{"status":"UP"},"rabbit":{"status":"UP"},...}}
```

ai_core `/health` returns a status of `healthy` (or `degraded` when config such as the LLM key is missing). [VERIFIED — `ai_core/README.md`]

## 7. Health-check matrix

| Service | Port | Check |
|---|---|---|
| eureka-server | 8761 | `/actuator/health` |
| config-server | 8888 | `/actuator/health` |
| api-gateway | 8080 | `/actuator/health` |
| auth-service | 8081 | `/actuator/health` |
| user-profile-service | 8082 | `/actuator/health` |
| file-service | 8083 | `/actuator/health` |
| content-service | 8084 | `/actuator/health` |
| career-service | 8085 | `/actuator/health` |
| finance-service | 8086 | `/actuator/health` |
| chat-service | 8087 | `/actuator/health` |
| notification-service | 8088 | `/actuator/health` |
| map-service (optional) | 8090 | `/actuator/health` |
| ai_core (optional) | 8100 | `/health` |

[VERIFIED]

## 8. When a check fails

Consult [Troubleshooting](04-troubleshooting.md). If the issue persists beyond a local restart, see [Support escalation](07-support-escalation.md).
