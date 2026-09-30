# AI Limitations

> Status: Partially complete · Last reviewed: 2026-09-30
> Evidence: `ai_core/vithey_ai/cv_app_service.py`, `ai_core/vithey_ai/chat_service.py`, `ai_core/vithey_ai/chat_stubs.py`, `ai_core/vithey_ai/config.py`, `docs/_meta/EVIDENCE-BASIS.md` §6

Part of the Vithey documentation set · Master index:
[`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) ·
Siblings: [AI overview](01-ai-overview.md) · [Chatbot](06-chatbot.md) · [CV generation](05-cv-generation.md) ·
[Rate limit & cache](09-rate-limit-cache.md).

This page consolidates known, evidence-backed limitations. It documents behaviour; it does not fix
code.

## 1. Chat and CV-suggest are stubs

- `AI_CHAT_MODE` defaults to `stub`, is read into `Config`, but **is never branched on**.
- `ChatService.chat` / streaming always call `stub_reply`; `/cv/suggest` always calls
  `stub_cv_suggest`. No LLM call occurs on these paths.
- No RAG, no GDCE/general-service retrieval; explicitly out of scope.

[VERIFIED: `config.py`, `chat_service.py`, `chat_stubs.py`, `EVIDENCE-BASIS.md` §6]

## 2. `to_draft` field mismatch (known data defect)

`CvAppService.to_draft` maps the normalizer's `StandardCV` to the Flutter `AiCvDraft`. Field names do
not line up:

| `to_draft` reads | Normalizer actually emits | Effect |
|---|---|---|
| `group.get("items")` for skills | `SkillGroup.skills` | skills can be **dropped** from the draft |
| `item.get("summary")` for experience | `ExperienceItem.bullets` | experience bullets can be **dropped** |
| contact/email/phone | `ContactInfo.*` | handled correctly |

The `cv/generate` HTTP response is still valid; the Flutter draft may simply be less complete.
[VERIFIED: `cv_app_service.py`, `EVIDENCE-BASIS.md` §6]

## 3. In-process state limits scaling

The extraction cache, LLM rate limiter and chat cancel registry are all in-process. With
`AI_CORE_WORKERS > 1` or multiple replicas:

- Cache hit rate drops (each worker has its own cache).
- The effective LLM/HTTP budget multiplies.
- Stream cancellation only reaches the worker that registered it.

[VERIFIED: `cache.py`, `ratelimit.py`, `chat_registry.py`]

## 4. Persistence and schema governance

- `ai_db` schema is created by Python `ensure_schema()` (`CREATE TABLE IF NOT EXISTS`), **not**
  Flyway. There is no versioned migration history for these tables. [VERIFIED: `db.py`]
- `Database.connection()` opens a new `psycopg` connection per operation — no pooling. [VERIFIED]
- No read API for `ai_cv_interactions`; only inserts occur. [VERIFIED]
- Retention policy for chat sessions/messages and CV interactions: `TBD — Requires confirmation.`

## 5. Two response envelopes

- Flutter routes `/api/v1/ai/**` use `{data, meta, error}`.
- Legacy engine routes and the **middleware** error paths use `{success, data, meta}`.

Clients can therefore receive either shape on error. [VERIFIED: `flutter_envelope.py`,
`envelope.py`, `middleware.py`]

## 6. Legacy routes are not gateway-routed

`/api/v1/activities/**` and `/api/v1/cv/generate` exist in ai_core but are **not** reachable through
the gateway (which only routes `/api/v1/ai/**`). They are usable only inside the compose network or
directly against `:8100`. [VERIFIED: `api-gateway.yml`]

## 7. Input validation gaps

- `ChatBody.message` enforces `min_length=1` only; the `max 4000` documented in `api_docs.md` is not
  implemented. [VERIFIED]
- `PerClientRateLimitMiddleware` keys on the direct client IP and does not read `X-Forwarded-For`, so
  behind the gateway the IP may be the gateway's. [VERIFIED]

## 8. Cost, model and prompt governance

- No token/cost metering, budget cap, prompt versioning, or model fallback chain. [VERIFIED]
- Exact production model/version selection: `TBD — Requires confirmation.`
- No prompt-injection guard beyond deterministic normalisation and content truncation.
  [INFERRED] Inferred from implementation — requires business confirmation.

## 9. Stubs / not shipped

| Feature | Status |
|---|---|
| Job matching (`/ai/jobs/{id}/match`) | Not shipped (Flutter stub) |
| Skill score (`/ai/skills/score`) | Not shipped (Flutter stub) |
| Feed recommendations (`/ai/feed/recommendations`) | Not shipped (Flutter stub) |
| Real LLM chat / streaming | Not implemented (stub) |

[VERIFIED: `docs/06-api/01-api-overview.md` §7]

## 10. Summary of TBDs

- Retention/archival for `ai_db` tables: `TBD — Requires confirmation.`
- Production model/provider and quota handling: `TBD — Requires confirmation.`
- Whether chat will be wired to a real LLM/RAG: out of scope today — `TBD — Requires confirmation.`
- Shared cache/limiter store for multi-worker deployments: `TBD — Requires confirmation.`
