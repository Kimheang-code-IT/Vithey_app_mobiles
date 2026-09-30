# Project Scope

> Status: Verified baseline · Last reviewed: 2026-09-30
> Evidence: `plan.md` §0/§3.2/§8, `backend/DOCKER.md`, `backend/DEMO.md`, `api_docs.md`

## 1. Scope statement

Vithey is delivered as a **local demo** ("Profile M") in which all domain services run
live on a single developer PC for roughly **10 concurrent users**, together with the
Python `ai_core` engine and the Flutter client. The demo intentionally excludes
GDCE/RAG, orchestration platforms, production-grade high availability, Google
sign-in, and document OCR/PDF parsing. [VERIFIED] `plan.md` §0, §8

## 2. In scope — demo (Profile M)

### 2.1 Runtime environment

| Aspect | Scope | Status |
| --- | --- | --- |
| Host | One local computer (not a cloud cluster / shared server) | [VERIFIED] `plan.md` §0 |
| Concurrency | ~10 users at once | [VERIFIED] `plan.md` §0 |
| Deployment | Docker Compose (base + `docker-compose.demo.yml` overlay) | [VERIFIED] `backend/docker-compose.demo.yml` |
| Services live | All Vithey domain services + gateway + Eureka + Config + `ai_core` | [VERIFIED] `plan.md` §3.2 |
| Databases | One PostgreSQL instance hosting per-service databases | [VERIFIED] `init-databases.sql` |
| Map service | Live **only** if a Google Places server key is set; otherwise a clear config error | [VERIFIED] `plan.md` §0, `backend/DEMO.md` |
| Resource caps | Env-driven `mem_limit` / JVM opts from `backend/.env` (defaults for ~3 users) | [VERIFIED] `backend/.env.example` |

### 2.2 Functional scope by client module

| Module | Included capabilities | Status |
| --- | --- | --- |
| Auth | Register, login, refresh, logout, email verification, password reset, student verification | [VERIFIED] `api_docs.md` §3 |
| Home / content | Feed, posts (poster/video/job), comments, reactions, follow, create post | [VERIFIED] `api_docs.md` §6 |
| Profile / settings | Profile read/update, avatar, settings, user search | [VERIFIED] `api_docs.md` §4 |
| Files | Upload/get/download/delete; types AVATAR, CV, POSTER, VIDEO, CHAT_ATTACHMENT | [VERIFIED] `api_docs.md` §5 |
| Jobs / career | Job applications, applicant review, user CV metadata | [VERIFIED] `api_docs.md` §7 |
| Finance | Payments, alerts, fee catalog for verified `STUDENT` | [VERIFIED] `api_docs.md` §8 |
| Peer chat | Conversations, message requests, history, STOMP realtime, block/report | [VERIFIED] `api_docs.md` §9 |
| AI chatbot | Topic-stub chat, SSE streaming, sessions | [VERIFIED] `ai_core/vithey_ai/api/flutter_routes.py` |
| AI CV | `POST /ai/cv/generate` (real LLM), `POST /ai/cv/suggest` (stub) | [VERIFIED] `ai_core/vithey_ai/cv_app_service.py` |
| Notifications | Inbox, unread count, read/read-all, delete, device registration | [VERIFIED] `api_docs.md` §11 |
| Search | Client-side fan-out to user search and post search | [VERIFIED] `api_docs.md` §13 |
| Map | Nearby/search/autocomplete/detail, favorites, history (opt-in) | [VERIFIED] `api_docs.md` §12 |

### 2.3 Platform / DevOps scope

| Capability | Scope | Status |
| --- | --- | --- |
| CI | Per-service workflows + promotion pipeline to `dev` with GHCR image publishing | [VERIFIED] `.github/workflows/` |
| Monitoring | Opt-in Compose profile: Prometheus, Grafana, Loki, Promtail, node-exporter, cAdvisor | [VERIFIED] `monitoring/README.md` |
| Health | `/actuator/health` per Java service; `/health` on `ai_core` | [VERIFIED] `backend/DEMO.md` |
| Smoke | `scripts/smoke-api.ps1` end-to-end API smoke | [VERIFIED] `backend/DEMO.md` |

## 3. Out of scope

| Item | Reason | Status |
| --- | --- | --- |
| GDCE / `general-service` RAG | Locked out of demo; Vithey AI chat is a stub | [VERIFIED] `plan.md` §8 |
| Kubernetes / multi-node / autoscaling / cloud deploy | Demo runs on one PC | [VERIFIED] `plan.md` §8 |
| Production HA (replicated Redis/Postgres, real FCM scale) | Not in demo scope | [VERIFIED] `plan.md` §8 |
| Local GPU LLM (Ollama, vLLM) | API key only | [VERIFIED] `plan.md` §8 |
| Google OAuth / 2FA (Google sign-in) | UI stub only in Flutter | [VERIFIED] EVIDENCE-BASIS §7 |
| OCR / PDF parsing of CVs | Not built | [VERIFIED] `plan.md` §8 |
| Per-service PostgreSQL containers | One shared Postgres in demo | [VERIFIED] `plan.md` §8 |
| Full feed ML recommendations | Rule/match AI optional only | [VERIFIED] `plan.md` §4.3 |
| Staging environment | Does not exist | [VERIFIED] EVIDENCE-BASIS §9 |
| Production environment | Does not exist | [VERIFIED] EVIDENCE-BASIS §9 |
| Admin reporting / analytics module | Not built | [PLANNED] `Action_Plan_Vithey.csv` 13.4 (Not Started) |

## 4. Scope boundaries and assumptions

- **Assumption:** the demo machine has sufficient RAM (16 GB system recommended; stack
  ~10–12 GB). [VERIFIED] `plan.md` §3.1
- **Assumption:** a valid LLM API key is present in `ai_core/.env`; CV generation fails
  clearly without it. [VERIFIED] `plan.md` §3.5
- **Boundary:** Flutter uses mock data by default (`USE_MOCK_*` flags) and switches to
  live APIs module by module. [VERIFIED] `vithey_app/README.md`
- **Boundary:** FCM push is a no-op without Firebase credentials; in-app notifications
  still work. [VERIFIED] `Action_Plan_Vithey.csv` 7.11

## 5. Open questions

- Whether the bank expects a hosted environment, and its specification: [TBD] TBD — Requires confirmation.
- Any regulatory or data-residency requirements for student data: [TBD] TBD — Requires confirmation.

## 6. Related documents

- [`02-project-objectives.md`](02-project-objectives.md)
- [`../01-requirements/01-business-requirements-BRD.md`](../01-requirements/01-business-requirements-BRD.md)
- [`../01-requirements/03-functional-requirements.md`](../01-requirements/03-functional-requirements.md)
