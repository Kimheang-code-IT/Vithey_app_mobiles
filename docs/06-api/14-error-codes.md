# Error Codes

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/*/src/main/java/**/exception/ErrorCode.java`, `backend/services/api-gateway/src/main/java/**/exception/GatewayErrorHandler.java`, `ai_core/vithey_ai/api/{envelope,flutter_envelope,middleware,routes,flutter_routes}.py`

## 1. Error envelope

Java services return `{ data, meta, error }` where `error` is:

```json
{
  "data": null,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [{ "field": "email", "message": "must be a valid email" }]
  }
}
```

`details` is `null` when there are no field errors (omitted by `@JsonInclude(NON_NULL)`).
The gateway's own rejections return only `{"error":{"code","message","details":[]}}` (no
`data`/`meta`). Framework-level errors that bypass the domain handlers (e.g. raw Spring Security)
can still produce the default Spring error body; the per-service `authenticationEntryPoint` writes
the wrapped `UNAUTHORIZED` body for 401s.

## 2. Error code vocabulary by service

Each service owns its own `ErrorCode` enum. Codes are **not globally unified**; consumers should key
off `code` + HTTP status. The table merges the per-service enums.

| Code | HTTP | Meaning | Services that define it |
|---|---|---|---|
| `VALIDATION_ERROR` | 400 | Bean validation failed | auth, career, chat, content, file, finance, map, notification, profile |
| `INVALID_CREDENTIALS` | 401 | Bad email/phone/password | auth |
| `INVALID_TOKEN` | 401 | Invalid/expired token | auth |
| `UNAUTHORIZED` | 401 | Authentication required | auth, career, chat, content, file, finance, map, notification, profile; gateway |
| `NOT_FOUND` | 404 | Resource missing | auth, career, chat, content, file, finance, map, notification, profile |
| `FORBIDDEN` | 403 | Permission denied | career, chat, content, file, finance |
| `CONFLICT` | 409 | Duplicate resource | auth, career, chat |
| `BUSINESS_RULE_VIOLATION` | 422 | Rule violated (e.g. self-follow) | auth, chat, content |
| `INVALID_FILE` | 400 | Invalid/missing file reference | career, content, profile |
| `INVALID_FILE_TYPE` | 400 | Bad MIME/type | file |
| `FILE_TOO_LARGE` | 400 | Upload exceeds limit | file |
| `UPSTREAM_ERROR` | 502 | Downstream service unavailable | career, map |
| `INTERNAL_ERROR` | 500 | Unexpected server error | all domain services |

Gateway security filter codes: `UNAUTHORIZED` (401, missing/invalid Bearer). The Redis rate limiter
returns `429` with Spring's default body when a route limit is exceeded.

## 3. `ai_core` error codes

### Flutter routes (`/api/v1/ai/**`) — `{data, meta, error}`

| Code | HTTP | Source |
|---|---|---|
| `UNAUTHORIZED` | 401 | `require_user` / HTTPException handler |
| `VALIDATION_ERROR` | 400 | chat/regenerate `ValueError` |
| `NOT_FOUND` | 404 | chat/session lookups |
| `UPSTREAM_ERROR` | 502 | unexpected chat failure |
| `HTTP_ERROR` | varies | generic FastAPI `HTTPException` fallback |

### Legacy engine routes — `{success, data, meta}` / `{success:false, error:{...}}`

| Code | HTTP |
|---|---|
| `VITHEY_AI_ERROR` | 400 |
| `EMPTY_INPUT` | 400 |
| `UNSUPPORTED_LANGUAGE` | 400 |
| `INVALID_INPUT` | 400 |
| `INPUT_TOO_LARGE` | 413 |
| `REQUEST_TOO_LARGE` | 413 (middleware) |
| `AI_RATE_LIMITED` | 429 (engine) |
| `RATE_LIMIT_EXCEEDED` | 429 (per-IP middleware) |
| `AI_INVALID_RESPONSE` | 502 |
| `UPSTREAM_AI_ERROR` | 502 |

`ai_core` also returns `X-Request-ID`, `X-Process-Time-Ms`, `X-RateLimit-Limit`,
`X-RateLimit-Remaining`, and `Retry-After` (on 429) headers.

## 4. HTTP status → frontend action

| HTTP | Meaning | Frontend action |
|---|---|---|
| 400 | Validation / bad input | show `error.details` field errors |
| 401 | Unauthorized / expired | refresh once, else logout |
| 403 | Forbidden (e.g. not STUDENT) | show verify/role message |
| 404 | Not found | remove from UI / toast |
| 409 | Conflict (duplicate apply, etc.) | show message |
| 413 | Payload too large | shrink request |
| 422 | Business rule violation | show message (e.g. self-follow) |
| 429 | Rate limited | back off / retry after `Retry-After` |
| 500 | Server error | generic retry |
| 502 | Upstream failure | generic retry |

## 5. TBD

- A single canonical cross-service error catalogue does not exist; codes are per-service.
  Consolidation is `TBD — Requires confirmation.`
- Localisation of error messages: `TBD — Requires confirmation.`
