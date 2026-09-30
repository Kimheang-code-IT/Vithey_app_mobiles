# Project Scope

> Status: Partially complete — agreed demo scope implemented; assurance and future items outstanding · Last reviewed: 2026-09-30
> Evidence: `plan.md` §0/§3.2/§8, `api_docs.md`, `backend/DOCKER.md`, `docs/_meta/EVIDENCE-BASIS.md`, `Action_Plan_Vithey.csv`
> Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)

This document deliberately separates **five distinct categories** so that no reader mistakes
implemented work for agreed work, or a future idea for a delivered feature.

## 1. Agreed scope (locked demo — "Profile M")

The locked delivery decision was a **local demonstration** in which all Vithey domain services
run live on a single computer for roughly **10 concurrent users**, together with `ai_core` and
the Flutter client. [VERIFIED] `plan.md` §0 — see [`../00-project-overview/03-project-scope.md`](../00-project-overview/03-project-scope.md)

| Agreed scope element | Status |
| --- | --- |
| All domain services live: auth, user-profile, file, content, career, finance, chat, notification, map (opt-in) | [VERIFIED] `plan.md` §3.2 |
| API gateway as the single entry point | [VERIFIED] `config-repo/api-gateway.yml` |
| Real AI CV generation (`POST /ai/cv/generate`) via LLM | [VERIFIED] `ai_core/vithey_ai/cv_app_service.py` |
| AI assistant chat = topic **stub**, no GDCE/RAG | [VERIFIED] `ai_core/vithey_ai/api/flutter_routes.py` |
| Peer chat live (REST + STOMP WebSocket) | [VERIFIED] `backend/services/chat-service/` |
| Notification inbox live (in-app; push optional/stub) | [VERIFIED] `backend/services/notification-service/` |
| Map live **only if** a Google Places server key is set | [VERIFIED] `plan.md` §0 |
| Shared single PostgreSQL, Redis, RabbitMQ, MinIO | [VERIFIED] `backend/docker-compose.yml` |
| Resource caps driven from environment files | [VERIFIED] `backend/.env.example` |

## 2. Implemented scope (evidence-backed)

Everything in the agreed scope above has corresponding repository evidence. In addition, the
following were implemented as part of delivering that scope:

- Flyway migrations for every service; one database per service. [VERIFIED]
- RabbitMQ event integration on exchange `vithey.events` (notifications, profile, finance consumers). [VERIFIED]
- Redis rate limiting at the gateway; chat and map caching. [VERIFIED]
- CI pipelines, demo Compose overlay, operational scripts, and an opt-in monitoring stack. [VERIFIED]
- Automated test skeleton across backend, Flutter, and ai_core. [VERIFIED]

Full feature list: [`08-implemented-features.md`](08-implemented-features.md).

## 3. Additional work (beyond the literal demo plan)

The following were delivered even though the locked plan did not strictly require them for the
demo path. They are real and verified, and should be recognised as extra value:

- **Monitoring/observability stack** (Prometheus, Grafana, Loki, Promtail, node-exporter,
  cAdvisor) as an opt-in Compose profile. [VERIFIED] `monitoring/`
- **Offline chat persistence** with Isar (conversations, messages, pending outbox). [VERIFIED]
- **Isar-backed local storage, ACLEDA Mobile launcher, invoice preview** and other client polish. [VERIFIED]
- **Architecture documentation package** under `docs/`. [VERIFIED]

## 4. Future enhancements (planned, not built)

Explicitly out of the locked demo scope or identified as future work. None is implemented.

| Enhancement | Basis |
| --- | --- |
| Production deployment (bank-approved hosted environment) | [PLANNED] `Action_Plan_Vithey.csv` 17.5 |
| GDCE / `general-service` RAG for the assistant | [PLANNED] excluded by `plan.md` §8 |
| Google sign-in | [PLANNED] UI stub only; `Action_Plan_Vithey.csv` 9.15 |
| Push notifications (FCM) | [PLANNED] Firebase not integrated; `Action_Plan_Vithey.csv` 9.14 |
| Two-factor and biometric login | [PLANNED] "coming soon"; `Action_Plan_Vithey.csv` 11.5 |
| Admin reporting / analytics module | [PLANNED] `Action_Plan_Vithey.csv` 13.4 |
| OCR / PDF parsing of CVs | [PLANNED] `plan.md` §8 |
| Khmer-language UI (Khmer is currently a stored preference only) | [INFERRED/PLANNED] EVIDENCE-BASIS §7 |

## 5. Outstanding issues (in agreed scope, not finished)

| Issue | Severity | Basis |
| --- | --- | --- |
| Duplicate Flyway `V3` in career-service | High | [VERIFIED] BUG-001 |
| `UserCv` entity `@Id` vs DB PK mismatch | High | [VERIFIED] BUG-002 |
| user-profile trigram GIN index is a no-op | Medium | [VERIFIED] BUG-003 |
| `cv_app_service.to_draft` field mismatch drops CV fields | Medium | [VERIFIED] BUG-004 |
| Smoke ITs never run by `mvn test`/CI (no Failsafe) | Medium | [VERIFIED] BUG-005 |
| `PATCH /posts/{id}` not implemented (client gets `404`) | Medium | [VERIFIED] `api_docs.md` §15 |
| Android release signs with debug keys | Medium | [VERIFIED] BUG-008 |
| Flutter test coverage is thin | Medium | [VERIFIED] `Action_Plan_Vithey.csv` 14.5 |
| Formal security assessment not performed | High (governance) | [VERIFIED] EVIDENCE-BASIS §12 |
| UAT not executed; no sign-off | High (governance) | [VERIFIED] `../12-uat/05-UAT-signoff.md` |

Full list: [`15-outstanding-items.md`](15-outstanding-items.md).

## 6. Scope boundaries and assumptions

- The demo machine is assumed to have sufficient RAM (16 GB recommended; stack ~10–12 GB). [VERIFIED] `plan.md` §3.1
- A valid LLM API key must be present in `ai_core/.env`; CV generation fails clearly without it. [VERIFIED] `plan.md` §3.5
- Flutter can run against mock data or live APIs depending on `USE_MOCK_*` flags. [VERIFIED] `vithey_app/README.md`

## 7. Open questions

- Whether the bank expects a hosted environment, and its specification. [TBD] `TBD — Requires confirmation.`
- Regulatory / data-residency requirements for student data. [TBD] `TBD — Requires confirmation.`

## 8. Related documents

- [`03-project-objectives.md`](03-project-objectives.md) · [`08-implemented-features.md`](08-implemented-features.md) · [`15-outstanding-items.md`](15-outstanding-items.md)
- [`../00-project-overview/03-project-scope.md`](../00-project-overview/03-project-scope.md)
