# Error Handling

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/*/src/main/java/**/util/ApiResponseWrapper.java`, `backend/services/*/src/main/java/**/exception/*.java`, `backend/services/api-gateway/.../exception/GatewayErrorHandler.java`, `ai_core/vithey_ai/api/*.py`, `docs/06-api/14-error-codes.md`

Every domain service returns the same envelope and maps domain exceptions to stable `ErrorCode`s
and HTTP statuses. The gateway emits its own compact error body. `ai_core` mirrors the service
envelope on `/api/v1/ai/**`. [VERIFIED]

Part of the Vithey documentation set · Master index:
[`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) ·
Siblings: [API gateway](05-api-gateway.md) · [Microservice architecture](02-microservice-architecture.md) ·
Full code catalogue: [`../06-api/14-error-codes.md`](../06-api/14-error-codes.md).

## 1. Standard response envelope

Domain services return `ApiResponseWrapper<T>(data, meta, error)` with
`@JsonInclude(JsonInclude.Include.NON_NULL)`, so null members are omitted when serialized. Jackson
is configured globally as snake_case (`property-naming-strategy: SNAKE_CASE`). [VERIFIED:
`config-repo/application.yml`]

```json
{ "data": { }, "error": null }
```

```json
{
  "data": [],
  "meta": { "page": 1, "limit": 20, "total": 42, "total_pages": 3 },
  "error": null
}
```

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [{ "field": "email", "message": "must be a valid email" }]
  }
}
```

- `auth-service` uses a two-field wrapper `ApiResponseWrapper<T>(data, error)` (no `meta`), because
  it exposes no list endpoints. [VERIFIED]
- `notification-service` `meta` may carry an extra `unread_total`. [VERIFIED]

> Note: `api_docs.md` prints `meta`/`error` as explicit `null`. In practice they are omitted via
> `NON_NULL`; clients must treat missing and null as equivalent.

## 2. Domain exception handling

Each service ships `ApiException` (carries an `ErrorCode`) and a `GlobalExceptionHandler`
(`@RestControllerAdvice`) that translates to `ApiResponseWrapper.error(code, message, details)` and
the HTTP status from the enum. Bean-validation failures produce `VALIDATION_ERROR` (400) with field
`details`. [VERIFIED: `exception/` package in every domain service]

`ErrorCode` is **per service**, not globally unified; consumers should key off `code` + HTTP status.
The merged vocabulary (from `docs/06-api/14-error-codes.md`):

| Code | HTTP | Services |
|---|---|---|
| `VALIDATION_ERROR` | 400 | all domain services |
| `INVALID_FILE_TYPE`, `FILE_TOO_LARGE` | 400 | file |
| `INVALID_FILE` | 400 | career, content, profile |
| `INVALID_CREDENTIALS`, `INVALID_TOKEN` | 401 | auth |
| `UNAUTHORIZED` | 401 | all + gateway |
| `FORBIDDEN` | 403 | career, chat, content, file, finance |
| `NOT_FOUND` | 404 | all domain services |
| `CONFLICT` | 409 | auth, career, chat |
| `BUSINESS_RULE_VIOLATION` | 422 | auth, chat, content |
| `UPSTREAM_ERROR` | 502 | career, map |
| `INTERNAL_ERROR` | 500 | all domain services |

## 3. Security-layer errors

Each service's `SecurityConfig` installs an `authenticationEntryPoint` that writes the wrapped
`UNAUTHORIZED` body for `401`, rather than the default Spring error JSON. Framework-level failures
that bypass the domain handlers can still produce a default Spring error body. [VERIFIED:
e.g. `auth-service/.../config/SecurityConfig.java`]

## 4. Gateway errors

`GatewayErrorHandler` writes a compact body **without** `data`/`meta`:

```json
{ "error": { "code": "UNAUTHORIZED", "message": "Missing or invalid token", "details": [] } }
```

The Redis rate limiter returns `429` with Spring's default body when a route limit is exceeded.
[VERIFIED: `GatewayErrorHandler.java`]

## 5. Feign / upstream errors

Services that make synchronous calls catch `FeignException`:

- `FeignException.NotFound` → domain `NOT_FOUND` / `INVALID_FILE`.
- other `FeignException` → `UPSTREAM_ERROR` (502) or `INVALID_FILE` depending on the service.
- Circuit breaker: `spring.cloud.openfeign.circuitbreaker.enabled: true`; Resilience4j named
  instances for `content-service`, `file-service`, `user-profile-service` and `googlePlaces`.
  `CallNotPermittedException` (open circuit) in map-service maps to `UPSTREAM_ERROR` with HTTP 503.

[VERIFIED: `UpstreamValidationService.java`, `GooglePlacesClient.java`, `config-repo/application.yml`]

## 6. `ai_core` envelopes

`ai_core` exposes two surfaces:

- **Flutter routes** `/api/v1/ai/**` → `{data, meta, error}` (`flutter_envelope.py`).
- **Legacy engine routes** → `{success, data, meta}` (`envelope.py`).

Error codes: `UNAUTHORIZED` (401), `VALIDATION_ERROR` (400), `NOT_FOUND` (404), `UPSTREAM_ERROR`
(502), `HTTP_ERROR`, plus the engine codes `AI_RATE_LIMITED` (429), `RATE_LIMIT_EXCEEDED` (429),
`INPUT_TOO_LARGE`/`REQUEST_TOO_LARGE` (413), `INVALID_INPUT`/`EMPTY_INPUT`/`UNSUPPORTED_LANGUAGE`
(400), `AI_INVALID_RESPONSE`/`UPSTREAM_AI_ERROR` (502). See
[09-ai/10-ai-error-handling.md](../09-ai/10-ai-error-handling.md).

## 7. HTTP → client action

| HTTP | Frontend action |
|---|---|
| 400 | show `error.details` field errors |
| 401 | refresh once, else logout |
| 403 | show role/verify message |
| 404 | remove from UI / toast |
| 409 | show message (duplicate apply, etc.) |
| 413 | shrink request |
| 422 | show message (e.g. self-follow) |
| 429 | back off / retry after `Retry-After` |
| 500 | generic retry |
| 502 | generic retry |

## 8. Known limitations / TBD

- No single canonical cross-service error catalogue; codes are per-service. `TBD — Requires
  confirmation.`
- Error messages are not localised (English only). `TBD — Requires confirmation.`
- No correlation of errors to `X-Request-ID` in log aggregation beyond gateway-set headers. `TBD —
  Requires confirmation.`
