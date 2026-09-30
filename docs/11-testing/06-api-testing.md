# API Testing

> Status: Verified baseline (inventory + script) · Last reviewed: 2026-09-30
> Evidence: `backend/scripts/smoke-api.ps1`, `backend/scripts/check-service-health.ps1`, `ai_core/tests/test_api.py`, `ai_core/tests/test_flutter_routes.py`, `backend/services/*/src/test`
> Result status: `Test implemented — current execution result not independently verified.`

## 1. Levels of API testing

| Level | Where | Tooling | Docker |
| --- | --- | --- | --- |
| Route/unit | `ai_core/tests/test_api.py`, `test_flutter_routes.py` | FastAPI `TestClient` + fake AI | No |
| Context mapping | `*ContextTest` | H2 | No |
| Smoke health | `*SmokeIT` | Testcontainers | Yes |
| Live health sweep | `backend/scripts/check-service-health.ps1` | PowerShell | Running stack |
| End-to-end contract | `backend/scripts/smoke-api.ps1` | PowerShell | Running stack |

There are **no** MockMvc/RestAssured/schema-validation tests in the Java services. [VERIFIED]

## 2. End-to-end smoke (`smoke-api.ps1`)

The script drives the **Flutter contract** through the gateway at `http://localhost:8080/api/v1`
and prints a PASS/FAIL table. It uses `ExpectStatus` sets so that documented statuses (e.g.
`403` before student verification, `404` empty CV) count as expected. [VERIFIED]

### 2.1 Coverage map

| Area | Endpoint(s) exercised | Notes |
| --- | --- | --- |
| Health | `/actuator/health`, ai_core `/health` | `UP` / `healthy` |
| Auth | `/auth/register`, `/auth/login`, `/auth/me`, `/auth/refresh`, `/auth/logout` | fresh random user |
| Profile | `GET`/`PATCH /users/me` | |
| Content | `POST /posts`, `GET /posts`, comments, reactions | |
| AI | `/ai/chat`, `/ai/sessions`, `/ai/messages/{id}/regenerate`, `/ai/cv/generate`, `/ai/cv/suggest` | chat is stubbed |
| Student/RBAC | `GET /fees` expects **403**, then `POST /students/verify`, refresh, `GET /fees` 200 | only role-gated flow |
| Finance | `GET /payments` | |
| Chat | `/conversations`, `/message-requests`, accept, send message | two-user flow |
| Notifications | `GET /notifications`, `/notifications/unread-count` | |
| Career/Map | `GET /users/me/cv`, `/places/history` | tolerates 404/503 |
| Regression guard | asserts **no** `vithey-ai-service` container | retired service |

### 2.2 Parameters

| Param | Default |
| --- | --- |
| `-BaseUrl` | `http://localhost:8080/api/v1` |
| `-GatewayHealth` | `http://localhost:8080/actuator/health` |
| `-AiCoreHealth` | `http://localhost:8100/health` |

Exit code `0` if all steps pass, `1` otherwise. [VERIFIED]

## 3. Live health sweep (`check-service-health.ps1`)

Queries each service's `/actuator/health` (and ai_core `/health`) on the running stack and
reports UP/DOWN per service; useful as a post-`docker-up-demo` gate. [VERIFIED] `TESTING.md`.

## 4. ai_core API tests

- `test_api.py` — legacy engine routes, envelope, error mapping.
- `test_flutter_routes.py` — `/api/v1/ai/**` routes, `require_user` auth (gateway header path
  and JWT path), `{data,meta,error}` envelope. [VERIFIED]

## 5. Contract reference

Expected request/response shapes live in `api_docs.md` and `../06-api/01-api-overview.md`;
auth details in `../06-api/03-authentication-api.md`. The smoke script is the executable
subset of that contract.

## 6. Gaps

| Gap | Impact |
| --- | --- |
| E2E script is manual; not in CI | Contract regressions can merge unnoticed |
| No automated status/schema assertions in Java | Only the PS script checks status codes |
| No negative/security cases (expired JWT, tampered signature) in E2E | Security edge untested |
| WebSocket protocol untested | `/ws/**` has no test |

## 7. Result status

Neither `smoke-api.ps1` nor any API test was executed during this documentation task.
`Test implemented — current execution result not independently verified.`

## 8. Cross-references

- [03-test-cases.md](03-test-cases.md) §6 · [09-security-testing.md](09-security-testing.md) · [12-test-results.md](12-test-results.md)
- `../06-api/01-api-overview.md` · `../../api_docs.md`
