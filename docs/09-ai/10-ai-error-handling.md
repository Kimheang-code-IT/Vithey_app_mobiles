# AI Error Handling

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `ai_core/vithey_ai/errors.py`, `ai_core/vithey_ai/api/routes.py`, `ai_core/vithey_ai/api/flutter_routes.py`, `ai_core/vithey_ai/api/flutter_envelope.py`, `ai_core/vithey_ai/api/envelope.py`, `ai_core/vithey_ai/api/app.py`, `ai_core/vithey_ai/api/middleware.py`

Part of the Vithey documentation set · Master index:
[`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) ·
Siblings: [AI overview](01-ai-overview.md) · [ai_core](03-ai-core.md) ·
[CV generation](05-cv-generation.md) · [Limitations](11-ai-limitations.md) ·
Backend error model: [`../08-backend/08-error-handling.md`](../08-backend/08-error-handling.md).

## 1. Exception hierarchy

```
VitheyAIError
├── AIClientError              # LLM call failed after retries        → 502 UPSTREAM_AI_ERROR
├── AIResponseValidationError  # invalid JSON / schema validation     → 502 AI_INVALID_RESPONSE
├── EmptyInputError            # no posts/activities                  → 400 EMPTY_INPUT
├── RateLimitError             # LLM sliding-window limit hit         → 429 AI_RATE_LIMITED
├── InputLimitError            # too many posts / input too large     → 413 INPUT_TOO_LARGE
└── UnsupportedLanguageError   # language not in {en, km}             → 400 UNSUPPORTED_LANGUAGE
```

[VERIFIED: `errors.py`, `api/routes.py` `_ERROR_MAP`]

## 2. Legacy engine routes (`{success, data, meta}`)

`_map_error` maps `VitheyAIError` subtypes to HTTP/status codes:

| Exception | HTTP | Code |
|---|---|---|
| `RateLimitError` | 429 | `AI_RATE_LIMITED` |
| `InputLimitError` | 413 | `INPUT_TOO_LARGE` |
| `EmptyInputError` | 400 | `EMPTY_INPUT` |
| `UnsupportedLanguageError` | 400 | `UNSUPPORTED_LANGUAGE` |
| `AIResponseValidationError` | 502 | `AI_INVALID_RESPONSE` |
| `AIClientError` | 502 | `UPSTREAM_AI_ERROR` |
| other `VitheyAIError` | 400 | `VITHEY_AI_ERROR` |

`/api/v1/cv/generate` additionally returns `INVALID_INPUT` (400) when not exactly one of
`posts`/`activities` is provided. [VERIFIED]

Error body (`envelope.py`):

```json
{
  "success": false,
  "error": { "code": "AI_RATE_LIMITED", "message": "…", "details": {} },
  "meta": { "request_id": "…", "timestamp": "…", "service": "vithey-ai" }
}
```

## 3. Middleware errors

| Condition | HTTP | Code | Envelope |
|---|---|---|---|
| Body over `API_MAX_BODY_BYTES` | 413 | `REQUEST_TOO_LARGE` | legacy `{success,...}` via `error()` |
| Per-IP limit exceeded | 429 | `RATE_LIMIT_EXCEEDED` | legacy, with `Retry-After` + `X-RateLimit-*` |

Note: `BodySizeLimitMiddleware` and `PerClientRateLimitMiddleware` return the **legacy**
`{success:false,...}` envelope, not the Flutter `{data,meta,error}` envelope. [VERIFIED:
`middleware.py`]

## 4. Flutter routes (`/api/v1/ai/**`, `{data, meta, error}`)

`flutter_routes.py` maps route-level failures explicitly:

| Route | Exception | HTTP | Code |
|---|---|---|---|
| `/chat`, `/regenerate` | `LookupError` | 404 | `NOT_FOUND` |
| `/chat`, `/regenerate` | `ValueError` | 400 | `VALIDATION_ERROR` |
| `/chat` | other | 502 | `UPSTREAM_ERROR` |
| `/chat/stream` | any | SSE `error` event | `UPSTREAM_ERROR` |
| `/chat/requests/{id}`, `/sessions/...` | `LookupError` | 404 | `NOT_FOUND` |

The app-level `HTTPException` handler emits the Flutter envelope for paths starting `/api/v1/ai/`:
`UNAUTHORIZED` for 401, else `HTTP_ERROR`. Non-AI paths keep FastAPI's `{"detail": ...}`. [VERIFIED:
`app.py`]

Envelope (`flutter_envelope.py`):

```json
{ "data": null, "meta": null, "error": { "code": "NOT_FOUND", "message": "…", "details": null } }
```

## 5. Auth errors

`require_user` raises `HTTPException(401)` for a missing/invalid token, invalid `X-User-Id`, or a
missing JWT secret; the handler renders `UNAUTHORIZED` in the Flutter envelope. [VERIFIED]

## 6. Graceful degradation (no error)

- `cv/generate` with no posts or an LLM failure returns an **incomplete draft**
  (`incomplete_profile: true` + `incomplete_message`) with HTTP 200 — not an error.
- Profile/post fetch failures are swallowed (empty result). [VERIFIED: `cv_app_service.py`]

## 7. Response headers

`X-Request-ID`, `X-Process-Time-Ms`, `X-RateLimit-Limit`, `X-RateLimit-Remaining`, and
`Retry-After` (on 429). `X-Request-ID` is echoed/created by `RequestContextMiddleware`. [VERIFIED]

## 8. Known limitations / TBD

- Middleware errors use the legacy envelope, so `/api/v1/ai/**` clients can receive two envelope
  shapes on error. [VERIFIED]
- No localisation of AI error messages. `TBD — Requires confirmation.`
