# OpenAPI / Swagger

> Status: Partially complete · Last reviewed: 2026-09-30
> Evidence: `backend/services/*/src/main/java/**/config/OpenApiConfig.java`, `backend/services/*/src/main/resources/application.yml`, `backend/infrastructure/config-repo/application-prod.yml`, `ai_core/vithey_ai/api/app.py`

## 1. springdoc presence (VERIFIED)

All **ten** HTTP services (api-gateway + nine domain services) depend on springdoc-openapi and
configure Swagger UI at `/swagger-ui.html`:

```yaml
springdoc:
  swagger-ui:
    path: /swagger-ui.html
```

Each service also declares an `OpenApiConfig` bean with an `Info` title and a `bearerAuth` HTTP-bearer
security scheme:

| Service | OpenAPI title |
|---|---|
| api-gateway | Vithey API Gateway |
| auth-service | Vithey Auth Service API |
| user-profile-service | Vithey User Profile Service API |
| file-service | Vithey File Service API |
| content-service | Vithey Content Service API |
| career-service | Vithey Career Service API |
| finance-service | Vithey Finance Service API |
| chat-service | Vithey Chat Service API |
| notification-service | Vithey Notification Service API |
| map-service | Vithey Map Service API |

## 2. URLs

For each Java service, the generated JSON is at `/v3/api-docs` and the UI at `/swagger-ui.html`
(or `/swagger-ui/index.html`).

| Service | Port | `/v3/api-docs` | Swagger UI |
|---|---|---|---|
| api-gateway | 8080 | `http://localhost:8080/v3/api-docs` | `http://localhost:8080/swagger-ui.html` |
| auth-service | 8081 | `http://localhost:8081/v3/api-docs` | `http://localhost:8081/swagger-ui.html` |
| user-profile-service | 8082 | `http://localhost:8082/v3/api-docs` | `http://localhost:8082/swagger-ui.html` |
| file-service | 8083 | `http://localhost:8083/v3/api-docs` | `http://localhost:8083/swagger-ui.html` |
| content-service | 8084 | `http://localhost:8084/v3/api-docs` | `http://localhost:8084/swagger-ui.html` |
| career-service | 8085 | `http://localhost:8085/v3/api-docs` | `http://localhost:8085/swagger-ui.html` |
| finance-service | 8086 | `http://localhost:8086/v3/api-docs` | `http://localhost:8086/swagger-ui.html` |
| chat-service | 8087 | `http://localhost:8087/v3/api-docs` | `http://localhost:8087/swagger-ui.html` |
| notification-service | 8088 | `http://localhost:8088/v3/api-docs` | `http://localhost:8088/swagger-ui.html` |
| map-service | 8090 | `http://localhost:8090/v3/api-docs` | `http://localhost:8090/swagger-ui.html` |
| ai_core | 8100 | `http://localhost:8100/openapi.json` | `http://localhost:8100/docs` (FastAPI UI) |

> The gateway exposes **only its own** spec at `/v3/api-docs`; it does **not** aggregate downstream
> specs (no `springdoc.swagger-ui.urls` / `GroupedOpenApi` aggregation found). To browse a domain
> service's docs through the gateway you would need a direct route, which does not exist. Access each
> service on its own port.

## 3. Gateway public access to docs

The gateway `PublicPathMatcher` treats `/swagger-ui.html`, `/swagger-ui/**`, `/v3/api-docs/**` and
`/actuator/**` as public (no JWT). Per-service `SecurityConfig` classes also `permitAll()` those
paths. So docs are reachable without a token **in local/dev**.

## 4. Production behaviour

`backend/infrastructure/config-repo/application-prod.yml` (activated by `SPRING_PROFILES_ACTIVE=prod`)
disables API docs:

```yaml
springdoc:
  api-docs:
    enabled: false
  swagger-ui:
    enabled: false
```

It also narrows actuator exposure to `health,info`. **No CI workflow activates the `prod` profile**
and no production deployment exists, so this is configuration-only today. [VERIFIED: `application-prod.yml`]

## 5. Committed OpenAPI specification

There is **no committed OpenAPI/Swagger file** in the repository (no `openapi.json`,
`openapi.yaml`, or `swagger.*` under the tree). Specs are generated at runtime only. A published,
version-controlled API specification is therefore a gap:

> `TBD — Requires confirmation.` — whether a generated `openapi.json` should be exported and
> committed (e.g. as a CI artifact) for client generation and contract review.

## 6. Related

- Endpoint inventory: [`01-api-overview.md`](01-api-overview.md)
- Gateway: [`02-api-gateway.md`](02-api-gateway.md)
- Contract: [`../../api_docs.md`](../../api_docs.md)
