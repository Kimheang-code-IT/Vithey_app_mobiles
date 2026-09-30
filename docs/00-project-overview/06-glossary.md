# Glossary

> Status: Verified baseline · Last reviewed: 2026-09-30
> Evidence: `AGENTS.md`, `api_docs.md`, `plan.md`, `backend/`, `ai_core/`

Terminology follows `../_meta/DOCUMENTATION-CONVENTIONS.md` §5. Where a term is specific to
the codebase, the defining path is cited.

## 1. Product and project terms

| Term | Definition | Status |
| --- | --- | --- |
| Vithey | The product under development: an AUB student superapp. On-device display name is **Vithey**. | [VERIFIED] |
| Vithey backend | The aggregate of Spring Boot microservices in `backend/`. | [VERIFIED] |
| AUB | The university context for the student users. Full institution name is not expanded in the repository. | [VERIFIED] / expansion [TBD] |
| ACLEDA | ACLEDA Bank, organiser of the App Competition 2026 and the target of the finance/deep-link feature. | [VERIFIED] |
| Profile M | The locked **demo** profile: all Vithey domain services live on one local PC, ~10 concurrent users. | [VERIFIED] `plan.md` §0 |
| GDCE | An external retrieval stack intentionally excluded from the demo; Vithey AI chat is a stub instead. | [VERIFIED] `plan.md` §8 |
| RAG | Retrieval-Augmented Generation; explicitly out of scope for this project. | [VERIFIED] `plan.md` §8 |
| Demo scope | The locally runnable subset defined by Profile M. | [VERIFIED] |
| Out of scope | Items explicitly excluded (K8s, production HA, Google OAuth, OCR/PDF, local LLM, GDCE). | [VERIFIED] `plan.md` §8 |

## 2. Architecture terms

| Term | Definition | Status |
| --- | --- | --- |
| api-gateway | Reactive Spring Cloud Gateway entry point on `:8080`; validates JWT, rate-limits, routes to services. | [VERIFIED] `config-repo/api-gateway.yml` |
| Eureka | Netflix Eureka service discovery (`eureka-server :8761`). | [VERIFIED] |
| config-server | Spring Cloud Config server (`:8888`) serving the **native** `config-repo/` files. | [VERIFIED] |
| config-repo | Directory of per-service YAML config baked into the config-server image. | [VERIFIED] `backend/infrastructure/config-repo/` |
| OpenFeign | Declarative HTTP client used for inter-service calls, resolved via Eureka. | [VERIFIED] EVIDENCE-BASIS §4 |
| `vithey.events` | The single RabbitMQ topic exchange used for domain events. | [VERIFIED] `config-repo/application.yml` |
| Envelope | Standard JSON response shape `{ data, meta, error }` with snake_case fields. | [VERIFIED] `api_docs.md` §1 |
| `ai_core` | The Python FastAPI AI engine (importable package `vithey_ai`, `:8100`). | [VERIFIED] `ai_core/README.md` |
| ai-service | The **retired** Java Spring AI service. Do not reintroduce. | [VERIFIED] `backend/DOCKER.md` |
| STOMP | Simple Text Oriented Messaging Protocol used for peer-chat WebSocket at `/ws`. | [VERIFIED] `api_docs.md` §9 |
| SSE | Server-Sent Events used by `/ai/chat/stream`. | [VERIFIED] `ai_core/vithey_ai/api/flutter_routes.py` |

## 3. Services

| Service | Port | Purpose |
| --- | --- | --- |
| `api-gateway` | 8080 | Routing, JWT validation, rate limiting, CORS |
| `auth-service` | 8081 | Register/login/refresh, RBAC, student verification |
| `user-profile-service` | 8082 | Profile, settings, user search |
| `file-service` | 8083 | Upload/download via MinIO |
| `content-service` | 8084 | Posts, comments, reactions, follows, mentions |
| `career-service` | 8085 | Job applications, user CV metadata |
| `finance-service` | 8086 | Fees, payments, alerts (STUDENT only) |
| `chat-service` | 8087 | Peer conversations and realtime messaging |
| `notification-service` | 8088 | In-app notifications (FCM optional) |
| `map-service` | 8090 | Nearby places, favorites, history (opt-in) |
| `eureka-server` | 8761 | Service discovery |
| `config-server` | 8888 | Central configuration |
| `ai_core` | 8100 | AI: CV generation + chat stub |

[VERIFIED] `config-repo/*.yml`, EVIDENCE-BASIS §3.

## 4. Databases and infrastructure

| Term | Definition |
| --- | --- |
| `auth_db`, `user_db`, `file_db`, `content_db`, `career_db`, `finance_db`, `chat_db`, `notification_db`, `map_db`, `ai_db` | One PostgreSQL database per service; `ai_db` is created but unused by Java. |
| Flyway | Database migration tool; one migration set per service. |
| HikariCP | JDBC connection pool used by the services. |
| Redis | Cache and gateway rate-limit backing store (host `:16379`). |
| RabbitMQ | Message broker (host `:5672`, UI `:15672`). |
| MinIO | S3-compatible object storage (host `:19000` API / `:19001` console). |

[VERIFIED] EVIDENCE-BASIS §3, §8.

## 5. Roles and security

| Term | Definition |
| --- | --- |
| `USER` | Default registered user. |
| `STUDENT` | Verified AUB student; granted via `POST /students/verify`; finance access. |
| `COMPANY` | Job poster / recruiter. |
| `ADMIN` | Backend-only administrative role; outside Flutter scope. |
| JWT | JSON Web Token; HMAC-signed; claims `sub`, `email`, `roles`; access TTL 15m, refresh TTL 7d. |
| `ROLE_<name>` | Spring Security authority derived from a role. |

[VERIFIED] `auth-service/.../entity/Role.java`, EVIDENCE-BASIS §5.

## 6. AI and CV terms

| Term | Definition |
| --- | --- |
| `StandardCV` | Guaranteed-shape CV model produced by `ai_core`. |
| `AiCvDraft` | Flutter-facing flat CV draft returned by `POST /ai/cv/generate`. |
| Extraction cache | In-memory cache keyed by content hash to avoid repeat LLM cost. |
| Quality score | Deterministic 0–100 CV completeness score with a letter grade. |
| Chat stub | Topic-based canned Markdown reply; no LLM call. |
| OpenRouter GLM | Default LLM endpoint/model (`z-ai/glm-5.3-flash`) despite `DEEPSEEK_*` env names. |

[VERIFIED] `ai_core/README.md`, EVIDENCE-BASIS §6.

## 7. DevOps terms

| Term | Definition |
| --- | --- |
| Profile M demo overlay | `backend/docker-compose.demo.yml`, env-driven resource caps. |
| GHCR | GitHub Container Registry; images published as `ghcr.io/<owner>/vithey-<service>`. |
| CI promotion | `ci-promote-dev.yml` runs tests and fast-forwards passing commits to `dev`. |
| Smoke test (`*SmokeIT`) | Testcontainers integration test, Docker-gated; not run by plain `mvn test`. |
| Actuator | Spring Boot health/metrics endpoints (`/actuator/health`, `/actuator/prometheus`). |

[VERIFIED] EVIDENCE-BASIS §9, `backend/TESTING.md`.

## 8. Related documents

- [`01-project-overview.md`](01-project-overview.md)
- [`../01-requirements/02-software-requirements-SRS.md`](../01-requirements/02-software-requirements-SRS.md)
