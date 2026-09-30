# Solution Overview

> Status: Verified baseline · Last reviewed: 2026-09-30
> Evidence: `AGENTS.md`, `api_docs.md`, `plan.md`, `backend/`, `vithey_app/`, `ai_core/`
> Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)

## 1. Summary

Vithey is delivered as a **mobile application backed by a microservice platform and a Python AI
engine**. A student uses one Flutter app; every request flows through a single API gateway; each
business capability is a separate service with its own database; and all AI work is handled by a
dedicated Python engine (`ai_core`) behind the gateway. [VERIFIED] `AGENTS.md`, `../03-system-design/01-system-architecture.md`

## 2. Solution tiers

| Tier | Technology | Role |
| --- | --- | --- |
| Mobile client | Flutter / Dart (GetX, Dio, Isar) | User experience for all ten modules |
| Backend platform | Java 21 / Spring Boot 3.3.5 / Spring Cloud 2023.0.3 | Business logic, persistence, integration |
| AI engine | Python 3.10+ / FastAPI (`vithey_ai`) | CV generation (real LLM) and assistant chat (stub) |
| Data & messaging | PostgreSQL, Redis, RabbitMQ, MinIO | Per-service persistence, caching, events, files |
| Operations | Docker Compose, GitHub Actions, Prometheus/Grafana/Loki | Local demo, CI, monitoring |

[VERIFIED] `../03-system-design/08-technology-stack.md`

## 3. Functional capabilities

| Capability | What the user gets | Status |
| --- | --- | --- |
| Social feed | Posts, videos, job posts, comments, reactions, follow | Implemented |
| Jobs & CV | Job applications, applicant review, AI-assisted CV creation | Implemented (update-post gap) |
| Student finance | Payments, alerts, fee catalog for verified students | Implemented (read-only) |
| Peer chat | Conversations, message requests, realtime messaging, block/report | Implemented |
| AI assistant | Topic-stub answers, streaming, session history | Stub/Placeholder |
| Notifications | In-app inbox, unread count, read actions | Implemented (push is a no-op) |
| Profile & settings | Profile editing, avatar, settings, user search | Implemented |
| Search | People and post/job/video search | Implemented (client fan-out) |
| Map | Nearby places, search, favorites, history | Implemented (opt-in) |
| Auth | Register, login, refresh, email verification, password reset, student verification | Implemented |

[VERIFIED] `api_docs.md`, `../00-project-overview/03-project-scope.md`

## 4. Design principles actually applied

- **Single entry point:** the client never calls a domain service, `ai_core`, or the LLM directly. [VERIFIED]
- **One database per service:** no shared schema; Flyway manages migrations per service. [VERIFIED]
- **Event-driven integration:** services publish/subscribe on the `vithey.events` RabbitMQ topic exchange. [VERIFIED]
- **Defense in depth:** JWT is validated at the gateway and again in every service. [VERIFIED]
- **Cost-bounded AI:** real LLM only for CV generation, with caching, rate limiting, and input caps; the assistant is a zero-cost stub. [VERIFIED]
- **Environment-driven configuration:** resource caps and secrets come from `.env` files; no secrets committed. [VERIFIED]

## 5. What is deliberately not part of the solution

A Retrieval-Augmented Generation (RAG) knowledge stack (GDCE/`general-service`), Kubernetes,
production high availability, local GPU LLMs, OCR/PDF CV parsing, Google sign-in, and push
notifications are all out of the agreed demo scope. [VERIFIED] `plan.md` §8

## 6. Known limitations carried by the solution

- The AI assistant returns canned topic replies — it is not a live reasoning assistant. [VERIFIED]
- Finance is read-only (no payment mutation endpoint). [VERIFIED] `Action_Plan_Vithey.csv` 7.6
- The map requires a Google Places server key; without it, the service returns a config error. [VERIFIED]
- The user interface is English-only; Khmer is stored as a preference and a CV label only. [VERIFIED]
- Push notifications do not work without Firebase credentials (none integrated). [VERIFIED]

## 7. Related documents

- [`07-system-architecture.md`](07-system-architecture.md) · [`08-implemented-features.md`](08-implemented-features.md) · [`04-project-scope.md`](04-project-scope.md)
- [`../03-system-design/02-high-level-design-HLD.md`](../03-system-design/02-high-level-design-HLD.md) · [`../03-system-design/08-technology-stack.md`](../03-system-design/08-technology-stack.md)
