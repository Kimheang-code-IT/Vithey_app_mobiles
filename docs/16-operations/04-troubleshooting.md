# Troubleshooting

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/scripts/*.ps1`, `backend/DOCKER.md`, `backend/DEMO.md`, `backend/TESTING.md`, `monitoring/README.md`, `EVIDENCE-BASIS.md` §8, `backend/.env.example`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [Operation manual](01-operation-manual.md) · [Health check](03-health-check.md) · [Incident response](../15-monitoring/07-incident-response.md)

## 1. First response

```powershell
cd backend
.\scripts\check-service-health.ps1
.\scripts\verify-docker.ps1
docker compose -f docker-compose.yml -f docker-compose.demo.yml ps
docker compose -f docker-compose.yml -f docker-compose.demo.yml logs --tail=200 <service>
```

## 2. Startup and build

| Symptom | Cause | Fix |
|---|---|---|
| `docker-up-demo.ps1` exits "Missing ai_core/.env" | no LLM key file | `Copy-Item ..\ai_core\.env.example ..\ai_core\.env` then set `DEEPSEEK_API_KEY` |
| "backend/.env not found" warning | no resource .env | optional; defaults apply — copy `.env.example` to tune |
| Build is slow the first time | image pulls + Maven downloads | expected; later builds use caches |
| Port already in use | another process/container on 8080-8100/15432/16379 | stop conflicting process; see port map |
| Service stuck "starting" | start-period up to 120s | wait; then inspect logs |

[VERIFIED — scripts, `DOCKER.md`]

## 3. Health and dependencies

| Symptom | Cause | Fix |
|---|---|---|
| Service `DOWN` for db | Postgres not healthy / URL wrong | ensure `postgres` healthy; check `<SVC>_DB_URL` |
| Service `DOWN` for rabbit | RabbitMQ not ready | check `rabbitmq-diagnostics ping`; health gate |
| Gateway 503 on a route | target service not running (subset mode) | start that service or use full stack |
| Eureka shows fewer services | service not registered/failed | check service logs; `EUREKA_URL` |
| Config not applied | config-server stale | rebuild config-server (image-baked config) or check bind mount |

[VERIFIED / INFERRED]

## 4. Database and migrations

| Symptom | Cause | Fix |
|---|---|---|
| Flyway checksum mismatch | an applied migration was edited | `docker-down-demo.ps1 -v` then start fresh; **never** edit applied migrations |
| Flyway "more than one migration with version V3" (career) | duplicate `V3__` migrations in career-service | known defect; reset volumes and fix versioning |
| `ddl-auto: validate` failure | entity vs schema mismatch | reconcile entity/migration; known career `UserCv` `@Id` issue |
| Trigram index missing (user-profile) | V3 index re-create skipped by `IF NOT EXISTS` | known defect; not silently fixable |

[VERIFIED — `EVIDENCE-BASIS.md` §8]

## 5. ai_core

| Symptom | Cause | Fix |
|---|---|---|
| `/health` returns `degraded` | missing/invalid `DEEPSEEK_API_KEY` | set key in `ai_core/.env`, restart ai_core |
| CV generation times out | LLM latency / `TIMEOUT_SECONDS` | retry; check egress to OpenRouter |
| Chat replies are canned | chat is a stub (`AI_CHAT_MODE=stub`) | expected — not a bug |
| 429 from ai_core | per-IP rate limit (30/min) | slow down; adjust `API_RATE_LIMIT_PER_MINUTE` |

[VERIFIED — `ai_core` README/config]

## 6. Flutter app

| Symptom | Cause | Fix |
|---|---|---|
| Build/analyze fails: `.env` missing | `.env` is a pubspec asset | `Copy-Item .env.example .env` |
| Cannot reach API | emulator vs device base URL | emulator `10.0.2.2`, device PC LAN IP |
| Web/Chrome fails | unsupported (Isar/secure storage/camera) | use Android emulator/device |
| Still seeing mock data | `USE_MOCK_*` true | set mocks false in `.env` |

[VERIFIED — `AGENTS.md`, `vithey_app/.env.example`]

## 7. Monitoring

| Symptom | Cause | Fix |
|---|---|---|
| `vithey-network` not found | backend stack not started | start backend compose first |
| Prometheus targets DOWN | service not running / no registry | start service; ensure micrometer registry |
| No Loki logs | no Docker socket access / naming | verify mount; container name starts `vithey-` |
| Empty JVM panels | no `micrometer-registry-prometheus` | rebuild service image |

[VERIFIED — `monitoring/README.md`]

## 8. Resource pressure (Windows)

| Symptom | Cause | Fix |
|---|---|---|
| Docker starves host | WSL2 unbounded | `.\scripts\set-docker-limits.ps1 -Memory 8GB -Processors 6`, restart Docker Desktop |
| Containers OOM-killed | caps too low | raise `*_MEM_LIMIT` / `*_JAVA_OPTS` in `backend/.env` |

[VERIFIED — `set-docker-limits.ps1`, `DOCKER.md`]

## 9. Tests

| Symptom | Cause | Fix |
|---|---|---|
| `*SmokeIT` not run by `mvn test` | no failsafe config | run explicitly `mvn test -Dtest=CareerServiceSmokeIT` |
| Smoke test needs Docker error | Docker not running | start Docker Desktop |

[VERIFIED — `TESTING.md`]

## 10. Escalation

If none of the above resolves the issue, record the failing command and logs, then see [Support escalation](07-support-escalation.md).
