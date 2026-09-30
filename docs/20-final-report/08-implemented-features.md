# Implemented Features

> Status: Partially complete — core demo features implemented; listed stubs and gaps remain · Last reviewed: 2026-09-30
> Evidence: `api_docs.md`, `backend/services/`, `ai_core/vithey_ai/`, `vithey_app/lib/modules/`, `Action_Plan_Vithey.csv`
> Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)

This list reflects **repository evidence only**. Status uses the vocabulary: `Implemented`,
`Partial`, `Stub/Placeholder`, `Planned`, `Not started`, `Deprecated/Retired`.

## 1. Live backend domain services

All of the following exist as runnable Spring Boot services behind the gateway. [VERIFIED]

| Service | Capability delivered | Status |
| --- | --- | --- |
| `auth-service` | Register, login, refresh, logout, email verification, password reset, student verification (`STUDENT` role) | Implemented |
| `user-profile-service` | Profile read/update, avatar, settings, paginated user search | Implemented |
| `file-service` | Upload/get/download/delete for AVATAR, CV, POSTER, VIDEO, CHAT_ATTACHMENT via MinIO | Implemented |
| `content-service` | Feed, posts (poster/video/job), comments, reactions, follow graph | Implemented (no post update) |
| `career-service` | Job applications with idempotency, applicant listing, CV preview, status update, default CV metadata | Implemented |
| `finance-service` | Fees, categories, payments, alerts — `STUDENT`-gated, read-only | Implemented |
| `chat-service` | Conversations, message requests, history, read receipts, STOMP realtime, block/report | Implemented |
| `notification-service` | In-app inbox, unread count, read/read-all, delete, device token registration | Implemented |
| `map-service` | Nearby/search/autocomplete/detail, favorites, history | Implemented (opt-in) |

## 2. AI engine (`ai_core`)

| Capability | Detail | Status |
| --- | --- | --- |
| Auto-Create CV | `POST /api/v1/ai/cv/generate`; real LLM pipeline: extract → dedupe → prompt → LLM → normalize → quality score | Implemented |
| CV quality scoring | Deterministic 0–100 rubric | Implemented |
| CV section suggest | `POST /api/v1/ai/cv/suggest` | Stub/Placeholder |
| AI assistant chat | `POST /api/v1/ai/chat` and SSE stream; **topic stub**, no RAG/GDCE | Stub/Placeholder |
| Chat sessions/history | Session list, messages, delete, regenerate | Implemented (stub replies) |

[VERIFIED] `ai_core/vithey_ai/api/flutter_routes.py`, `ai_core/vithey_ai/cv_app_service.py`, `../09-ai/05-cv-generation.md`

> The LLM client keeps legacy `DEEPSEEK_*` environment variable names but defaults to an
> OpenRouter GLM endpoint and model. [VERIFIED] `../_meta/EVIDENCE-BASIS.md` §6

## 3. Mobile application modules

| Module | Status | Notes |
| --- | --- | --- |
| Auth / onboarding | Implemented | Splash, language select, onboarding, login, register, forgot password, startup wizard |
| Home feed & reels | Implemented | Mixed poster/video/job cards |
| Create post & post detail | Implemented | Post editing depends on missing `PATCH /posts/{id}` |
| Notifications | Implemented | Inbox, filters, grouping, read actions |
| Profile | Implemented | Own/other profile, edit, applicants, CV preview, QR scan |
| Jobs & CV | Implemented | Apply flow, AI CV builder, templates, status |
| Finance & verification | Implemented | Dashboard, receipts, invoice preview, ACLEDA Mobile launcher |
| Peer chat | Implemented | REST + STOMP; Isar offline persistence and outbox |
| AI chatbot | Implemented (UI) over stub replies | Streaming markdown, history drawer |
| Search | Implemented | Debounced, fans out to user/post search |
| Settings | Implemented | Account, privacy, notifications, security, help, about |
| Map | Implemented (opt-in) | Google Maps view, place search, favorites |

[VERIFIED] `vithey_app/lib/modules/`, `Action_Plan_Vithey.csv` §3/§9

## 4. Platform, DevOps, and operations

| Capability | Status |
| --- | --- |
| API gateway (routing, JWT, headers, CORS, rate limiting) | Implemented |
| Eureka service discovery | Implemented |
| Centralized config (Spring Cloud Config native) | Implemented |
| RabbitMQ event integration (`vithey.events`) | Implemented |
| Per-service Flyway migrations | Implemented (career V3 defect) |
| Docker packaging + Profile M Compose overlay | Implemented |
| CI: per-service workflows + promotion pipeline + GHCR images | Implemented |
| Monitoring stack (Prometheus, Grafana, Loki, …) | Implemented (opt-in) |
| Operational scripts (up/down/health/smoke) | Implemented |
| Automated tests (backend, Flutter, ai_core) | Implemented — not executed for this report |

[VERIFIED] `.github/workflows/`, `backend/scripts/`, `monitoring/`, `../11-testing/13-test-summary-report.md`

## 5. Known stubs, gaps, and non-implemented features

| Item | Status |
| --- | --- |
| Google sign-in | Stub/Placeholder (UI only) |
| Push notifications (FCM) | Stub/Placeholder (no Firebase) |
| Two-factor / biometric login | Not started ("coming soon") |
| `PATCH /posts/{id}` | Not started (client receives `404`) |
| Admin reporting / analytics | Not started |
| Production deployment | Not started |
| Khmer UI strings | Not started (preference only) |
| Map-service integration tests | Not started |

[VERIFIED] `api_docs.md` §15, `../00-project-overview/03-project-scope.md`, `Action_Plan_Vithey.csv`

## 6. Related documents

- [`06-solution-overview.md`](06-solution-overview.md) · [`07-system-architecture.md`](07-system-architecture.md) · [`15-outstanding-items.md`](15-outstanding-items.md)
- [`../03-system-design/01-system-architecture.md`](../03-system-design/01-system-architecture.md) · [`../09-ai/01-ai-overview.md`](../09-ai/01-ai-overview.md)
