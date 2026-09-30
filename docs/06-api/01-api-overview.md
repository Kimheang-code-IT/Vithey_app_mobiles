# API Overview

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/*/src/main/java/**/controller/*.java`, `backend/infrastructure/config-repo/api-gateway.yml`, `api_docs.md`, `ai_core/vithey_ai/api/flutter_routes.py`

## 1. Audience and scope

Flutter calls **only** the API gateway at `http://<host>:8080/api/v1/**`. It never calls a domain
service or `ai_core` directly. This document set is the endpoint inventory for the Flutter ↔ gateway
contract, derived from the real controller mappings. [VERIFIED]

- Contract source: root [`api_docs.md`](../../api_docs.md)
- Gateway detail: [`02-api-gateway.md`](02-api-gateway.md)
- Errors: [`14-error-codes.md`](14-error-codes.md)
- WebSocket: [`13-websocket-api.md`](13-websocket-api.md)

## 2. Base URLs

| Platform | REST base | WebSocket |
|---|---|---|
| Desktop / iOS simulator | `http://localhost:8080/api/v1` | `ws://localhost:8080/ws` |
| Android emulator | `http://10.0.2.2:8080/api/v1` | `ws://10.0.2.2:8080/ws` |
| Physical device (LAN) | `http://<PC-LAN-IP>:8080/api/v1` | `ws://<PC-LAN-IP>:8080/ws` |

## 3. Conventions

- All JSON is **snake_case** (global Jackson `property-naming-strategy: SNAKE_CASE`).
  [VERIFIED: `backend/infrastructure/config-repo/application.yml:14-16`]
- List responses paginate with query params `page` (1-based, default 1) and `limit` (default 20,
  typically max 50) and return a `meta` block.
- Health: `/actuator/health` on services; `ai_core` exposes `GET /health`.

### Response envelope (VERIFIED)

Most services use `ApiResponseWrapper<T>(data, meta, error)` with
`@JsonInclude(NON_NULL)`, so null members are omitted:

```json
{ "data": { }, "meta": null, "error": null }
```

```json
{
  "data": [ ],
  "meta": { "page": 1, "limit": 20, "total": 42, "total_pages": 3 },
  "error": null
}
```

```json
{
  "data": null,
  "meta": null,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [{ "field": "email", "message": "must be a valid email" }]
  }
}
```

`auth-service` uses a two-field wrapper `ApiResponseWrapper<T>(data, error)` (no `meta`), because it
exposes no list endpoints. The notification `meta` may carry an extra `unread_total`.
[VERIFIED: `auth-service/.../util/ApiResponseWrapper.java`,
`notification-service/.../util/ApiResponseWrapper.java:25`]

The gateway's own rejection body is `{"error":{"code","message","details":[]}}` (no `data`/`meta`).
[VERIFIED: `api-gateway/.../exception/GatewayErrorHandler.java`]

> Note: `api_docs.md` prints `meta`/`error` as explicit `null`. In practice they are omitted when
> null. Clients must treat missing keys and null equivalently.

### Legacy `ai_core` envelope

The legacy engine routes (`/api/v1/activities/**`, `/api/v1/cv/generate`) return
`{success, data, meta}`, while the Flutter routes under `/api/v1/ai/**` return the Vithey
`{data, meta, error}` envelope. [VERIFIED: `ai_core/vithey_ai/api/envelope.py`,
`flutter_envelope.py`]. See [`12-ai-api.md`](12-ai-api.md).

## 4. Authentication

- `Authorization: Bearer <access_token>` on every non-public request.
- Access token TTL **15 min**; refresh token TTL **7 days**. On `401`, refresh once then retry.
- Gateway validates the JWT and injects `X-User-Id`, `X-User-Roles`, `X-User-Email` downstream.
- JWT claims: `sub` (userId), `email`, `roles[]`.
- Roles: `USER`, `STUDENT`, `COMPANY`, `ADMIN`.

Public (no JWT) paths: `POST /auth/register`, `/auth/login`, `/auth/google`, `/auth/refresh`,
`/auth/forgot-password`, `/auth/reset-password`, `/auth/verify-email`, plus `/actuator/**`,
`/swagger-ui/**`, `/v3/api-docs/**`. Note `/api/v1/students/verify` is routed by auth-service but is
**not** in the public matcher, so it requires a JWT. [VERIFIED: `PublicPathMatcher.java`]

## 5. Service endpoint inventory

| Service | Base path(s) | Endpoints | Doc |
|---|---|---|---|
| auth-service | `/api/v1/auth`, `/api/v1/students` | 10 | [`03-authentication-api.md`](03-authentication-api.md) |
| user-profile-service | `/api/v1/users`, `/api/v1/users/me/settings` | 7 | [`04-user-profile-api.md`](04-user-profile-api.md) |
| file-service | `/api/v1/files` | 4 | [`06-file-api.md`](06-file-api.md) |
| content-service | `/api/v1/posts`, `/api/v1/posts/{id}/comments`, reactions, `/api/v1/users/{id}/follow*` | 15 | [`05-content-api.md`](05-content-api.md) |
| career-service | `/api/v1/users/me/cv`, `/api/v1/job-applications` | 7 | [`07-career-api.md`](07-career-api.md) |
| finance-service | `/api/v1/fees`, `/api/v1/payments` | 5 | [`08-finance-api.md`](08-finance-api.md) |
| chat-service | `/api/v1/conversations`, `/api/v1/messages`, `/api/v1/message-requests` | 13 | [`09-chat-api.md`](09-chat-api.md) |
| notification-service | `/api/v1/notifications` | 7 | [`10-notification-api.md`](10-notification-api.md) |
| map-service | `/api/v1/places` | 9 | [`11-map-api.md`](11-map-api.md) |
| ai_core | `/api/v1/ai/**` (Flutter) + `/api/v1/**` (legacy) | 13 | [`12-ai-api.md`](12-ai-api.md) |

Total REST endpoints documented: **90** (9 Flutter AI + 4 legacy AI included; the legacy AI engine
routes are not exposed via the gateway because it only routes `/api/v1/ai/**`).

## 6. Endpoint status legend

| Tag | Meaning |
|---|---|
| Implemented | Controller mapping + service logic exist |
| Stub/Placeholder | Endpoint responds but returns canned content (AI chat/suggest) |
| Not exposed via gateway | Route path not matched by any gateway route |
| Not implemented | Referenced in Flutter/contract but no controller mapping |

## 7. Known contract gaps

| Item | Status |
|---|---|
| `PATCH /posts/{post_id}` | Not implemented in `PostController` → `404` |
| `POST /conversations/request` | Does not exist; use `POST /message-requests` |
| `GET /api/v1/jobs/**` | Gateway route exists; no controller (jobs are `POST /posts?type=JOB`) |
| `/api/v1/activities/**`, `/api/v1/cv/generate` (legacy AI engine) | Not routed by the gateway |
| `POST /ai/jobs/{id}/match`, `GET /ai/skills/score`, `GET /ai/feed/recommendations` | Not shipped (Flutter stubs) |
| Google sign-in | Stubbed in Flutter; no endpoint |

[VERIFIED: `api_docs.md` §15, gateway routes, controllers]
