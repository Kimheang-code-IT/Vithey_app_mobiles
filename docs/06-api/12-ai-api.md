# AI API (ai_core)

> Status: Partially complete · Last reviewed: 2026-09-30
> Evidence: `ai_core/vithey_ai/api/flutter_routes.py`, `ai_core/vithey_ai/api/routes.py`, `ai_core/vithey_ai/api/auth.py`, `ai_core/vithey_ai/cv_app_service.py`, `api_docs.md` §10

`ai_core` (Python FastAPI, port `8100`) is the AI engine. The gateway routes `/api/v1/ai/**` directly
to `http://ai-core:8100` (not via Eureka). Two surfaces exist:

1. **Flutter contract** — `/api/v1/ai/**`, returns the Vithey `{data, meta, error}` envelope.
2. **Legacy engine** — `/api/v1/activities/**`, `/api/v1/cv/generate`, `GET /health`, returns the
   `{success, data, meta}` envelope. Not routed by the gateway.

> **CV generation uses the real LLM.** **Chat and CV-suggest are stubs** (`AI_CHAT_MODE=stub` is
> read but never branched on; chat always calls `stub_reply`). [VERIFIED]

## 1. Flutter endpoints (`/api/v1/ai/**`)

Auth: `require_user` accepts gateway-injected `X-User-Id`/`X-User-Email`/`X-User-Roles`, else a
Bearer JWT (`HS256`, `VITHEY_JWT_SECRET`, claim `sub`). Envelope `{data, meta, error}`.

| Method | Path | Auth | Required role | Purpose | Request | Response | Errors |
|---|---|---|---|---|---|---|---|
| POST | `/api/v1/ai/chat` | JWT/headers | any | Chat reply — **Stub** | `{message, topic?, session_id?, client_message_id?}` | `{session_id, reply, topic, message_id, request_id}` | 400, 404, 502 |
| POST | `/api/v1/ai/chat/stream` | JWT/headers | any | SSE chat — **Stub** | same as `/chat` | SSE `meta`→`token`*→`done`\|`error` | stream errors |
| POST | `/api/v1/ai/messages/{message_id}/regenerate` | JWT/headers | owner | Replace assistant reply | path | chat data | 400, 404 |
| DELETE | `/api/v1/ai/chat/requests/{request_id}` | JWT/headers | owner | Stop a stream | path | `204` | 404 |
| GET | `/api/v1/ai/sessions` | JWT/headers | any | List chat sessions | `?page=&limit=` | session list + meta | — |
| GET | `/api/v1/ai/sessions/{session_id}/messages` | JWT/headers | owner | Session messages (ASC) | `?page=&limit=` | message list + meta | 404 |
| DELETE | `/api/v1/ai/sessions/{session_id}` | JWT/headers | owner | Delete session | path | `204` | 404 |
| POST | `/api/v1/ai/cv/generate` | JWT/headers | any | Auto-create CV — **real LLM** | `{target_role?, language?, template_id?}` | `AiCvDraft` | — |
| POST | `/api/v1/ai/cv/suggest` | JWT/headers | any | Section suggestion — **Stub** | `{section, original_text, cv_file_id?}` | `{suggested_text, interaction_id}` | — |

Notes:
- `ChatBody.message` has `min_length=1` only; the `max 4000` rule in `api_docs.md` is not enforced
  by the Pydantic model.
- `topic` ∈ `CV | JOB | INTERVIEW | STUDENT | FINANCE` (via `normalize_topic`, unknown → `STUDENT`).
- `page` default 1 (≥1), `limit` default 20 (1..100).

## 2. Legacy endpoints (not gateway-routed)

| Method | Path | Envelope | Purpose | Auth |
|---|---|---|---|---|
| GET | `/health` | `{success,...}` | Liveness + LLM config check | none |
| POST | `/api/v1/activities/extract` | `{success,...}` | Extract one activity (LLM, cached) | none |
| POST | `/api/v1/activities/extract-batch` | `{success,...}` | Batch extraction (dedupe + failures) | none |
| POST | `/api/v1/cv/generate` | `{success,...}` | Generate `{cv, quality}` | none |

`/api/v1/cv/generate` takes exactly one of `posts` or `activities` plus optional `profile`,
`target_role`, `job_description`, `language`, `on_error`. Errors: `INVALID_INPUT`, `AI_RATE_LIMITED`
(429), `INPUT_TOO_LARGE` (413), `EMPTY_INPUT` (400), `UNSUPPORTED_LANGUAGE` (400),
`AI_INVALID_RESPONSE` (502), `UPSTREAM_AI_ERROR` (502).

## 3. Examples

### POST `/api/v1/ai/chat` → 200 (STUB)

```json
{
  "message": "How do I write a good CV?",
  "topic": "CV",
  "session_id": null,
  "client_message_id": "client-1735123456789"
}
```

```json
{
  "data": {
    "session_id": "uuid",
    "reply": "## CV tips (demo stub)\n\n…",
    "topic": "CV",
    "message_id": "uuid",
    "request_id": "uuid"
  },
  "meta": null,
  "error": null
}
```

### POST `/api/v1/ai/chat/stream` (SSE, STUB)

```
event: meta
data: {"request_id":"uuid","session_id":"uuid","user_message_id":"uuid","topic":"CV"}

event: token
data: ## CV tips (demo stub)

event: done
data: {"request_id":"uuid","session_id":"uuid","message_id":"uuid","cancelled":false}
```

### POST `/api/v1/ai/cv/generate` → 200 (real LLM)

```json
{ "target_role": "Software Engineer Intern", "language": "en", "template_id": null }
```

```json
{
  "data": {
    "full_name": "Jane Doe",
    "summary": "…",
    "skills": ["Dart", "Flutter"],
    "education": ["BSc CS — AUB"],
    "experience": ["Intern — Acme"],
    "projects": ["Vithey App"],
    "contact": "jane@aub.edu.kh",
    "template_id": null,
    "incomplete_profile": false,
    "incomplete_message": null,
    "quality_score": 85,
    "quality_grade": "B"
  }
}
```

If the user has no posts or the LLM is unavailable, `cv/generate` returns an "incomplete draft"
(`incomplete_profile: true` with a message) rather than an error.

### POST `/api/v1/ai/cv/suggest` → 200 (STUB)

```json
{ "section": "summary", "original_text": "I am a student...", "cv_file_id": null }
```
```json
{ "data": { "suggested_text": "## Improved summary (demo stub)\n\n…", "interaction_id": "uuid" } }
```

## 4. Protections and cost controls (VERIFIED)

- Per-client-IP HTTP rate limit default **30/min** (`API_RATE_LIMIT_PER_MINUTE`), body cap
  **512 KB** (`API_MAX_BODY_BYTES`), `Retry-After` + `X-RateLimit-*` headers.
- LLM knobs: `MAX_TOKENS=3000`, `TEMPERATURE=0.2`, `TIMEOUT_SECONDS=30`, `MAX_RETRIES=2`,
  `MAX_POSTS_PER_BUILD=100`, `MAX_CONTENT_CHARS=6000`, `AI_CV_MAX_POSTS=20`.
- In-memory extraction cache (512) and in-memory LLM rate limiter (120/60s).
- `DEEPSEEK_*` env names retained but default to OpenRouter GLM
  (`DEEPSEEK_BASE_URL=https://openrouter.ai/api/v1`, `DEEPSEEK_MODEL=z-ai/glm-5.3-flash`).

## 5. Known limitation

`CvAppService.to_draft` maps `StandardCV` fields to the Flutter `AiCvDraft`. A field-name mismatch
(`items` vs `skills`, `summary` vs `bullets` in some paths) can drop fields in the draft; the
`cv/generate` response is still valid but may be less complete. [VERIFIED: `EVIDENCE-BASIS.md` §6]

## 6. Data touched

`ai_db`: `ai_cv_interactions` (written on every `cv/suggest`). Chat sessions/messages are stored via
Python-managed tables in `ai_db`. Exact DDL is not in the Java migration tree —
`TBD — Requires confirmation.`

## 7. TBD

- Published OpenAPI spec for `ai_core` (FastAPI exposes `/docs`/`/openapi.json` at runtime, but no
  committed spec): `TBD — Requires confirmation.`
- Session/message retention in `ai_db`: `TBD — Requires confirmation.`
- Wiring `AI_CHAT_MODE` to a real LLM or RAG: explicitly out of scope (chat is a stub).
