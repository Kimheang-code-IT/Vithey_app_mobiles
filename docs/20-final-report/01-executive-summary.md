# Executive Summary

> Status: Partially complete — demo delivered; governance items outstanding · Last reviewed: 2026-09-30
> Evidence: `plan.md`, `AGENTS.md`, `api_docs.md`, `Action_Plan_Vithey.csv`, `backend/`, `vithey_app/`, `ai_core/`, `monitoring/`
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`
> Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)

## 1. Purpose of this report

This is the final report package prepared for bank and management stakeholders. It summarises
what **Vithey** is, what was built, what was verified from repository evidence, and — equally
important — what was **not** done. It is written to be read without code-level detail, while
every material claim is traceable to a repository path or to a sibling document.

## 2. What Vithey is

**Vithey** is a student "superapp" — a single mobile application for AUB-style student life that
combines a social feed, jobs and an AI-assisted CV builder, student finance, peer chat, an AI
assistant, notifications, and a nearby-places map. It is delivered as a monorepo with three
runnable tiers: a **Flutter mobile app**, a **Java/Spring Boot microservice backend**, and a
**Python AI engine (`ai_core`)**. [VERIFIED] `AGENTS.md`, `../03-system-design/01-system-architecture.md`

The stated delivery context is the **ACLEDA Bank App Competition 2026**. The exact contractual
client/legal entity and signatories are not established in the repository. [TBD] `TBD — Requires confirmation.`

## 3. What has been delivered

The delivered target is the **"Profile M" local demo**: all Vithey domain services running live
on a single local computer together with `ai_core`, for roughly **10 concurrent users**.

| Area | Status | Evidence |
| --- | --- | --- |
| Flutter mobile app (10 modules) | Implemented | `vithey_app/lib/modules/` |
| Gateway + 9 domain services + Eureka + Config | Implemented | `backend/services/`, `backend/infrastructure/` |
| Real AI CV generation via LLM | Implemented | `ai_core/vithey_ai/cv_app_service.py` |
| AI assistant chat | Stub/Placeholder (topic stub, no RAG) | `ai_core/vithey_ai/api/flutter_routes.py` |
| Peer chat (REST + realtime WebSocket) | Implemented | `backend/services/chat-service/` |
| Student finance (read-only, `STUDENT`-gated) | Implemented | `backend/services/finance-service/` |
| Map / nearby places | Implemented (opt-in, needs Places key) | `backend/services/map-service/` |
| Notifications inbox | Implemented (in-app; push is a no-op) | `backend/services/notification-service/` |
| CI, Compose demo, monitoring | Implemented | `.github/workflows/`, `monitoring/` |

Full detail: [`08-implemented-features.md`](08-implemented-features.md).

## 4. What has not been done

These are contractually and reputationally material, and are stated plainly:

- **No staging and no production environment exist.** Only local development and the local demo
  are verified. [VERIFIED] `../_meta/EVIDENCE-BASIS.md` §9 — see [`13-deployment-status.md`](13-deployment-status.md).
- **No formal security assessment, penetration test, or audit has occurred.** Not yet formally
  assessed. [VERIFIED] `../10-security/11-security-review-report.md` — see [`12-security-summary.md`](12-security-summary.md).
- **No User Acceptance Testing (UAT) has been executed and no sign-off exists.** Not yet
  executed. [VERIFIED] `../12-uat/05-UAT-signoff.md` — see [`19-final-acceptance.md`](19-final-acceptance.md).
- **Automated tests exist but were not executed for this report.** All results read
  `Test implemented — current execution result not independently verified.` [VERIFIED]
  `../11-testing/12-test-results.md` — see [`11-testing-results.md`](11-testing-results.md).
- **No Google sign-in and no push notifications.** Both are stubs. [VERIFIED] `../_meta/EVIDENCE-BASIS.md` §7.

## 5. Progress statement

The implemented system is substantial and covers every module named in the agreed demo scope.
However, **Overall contractual completion percentage requires confirmation of the approved scope
and weighting.** A raw task count must not be read as contractual completion; the breakdown of
completed, in-progress, and not-started work by phase is in [`10-project-progress.md`](10-project-progress.md)
and [`09-action-plan.md`](09-action-plan.md).

## 6. Headline findings

**Strengths**
- A complete, coherent gateway-first microservice architecture with one database per service,
  event-driven integration over RabbitMQ, and centralized config and discovery. [VERIFIED]
- Real, cost-bounded LLM CV generation with deterministic normalization and quality scoring.
- Broad automated-test skeleton (41 backend Java test files, 11 pytest files, 3 Flutter files)
  and CI that builds 13 images. [VERIFIED] `../11-testing/13-test-summary-report.md`

**Gaps and risks**
- Assurance is incomplete: no UAT, no security assessment, no production deployment.
- Known data defects (duplicate Flyway `V3` in career-service; `UserCv` identity mapping;
  a no-op trigram index) that could cause migration failure on a fresh database. [VERIFIED]
  `../11-testing/11-bug-report.md` BUG-001…003.
- Thin Flutter test coverage and a debug-signed Android release build. [VERIFIED]

## 7. Recommendation

Treat the current build as a **verified local demonstration**, not a production release. Before
any bank-facing production decision, complete the prioritised actions in
[`17-recommendations.md`](17-recommendations.md) and [`15-outstanding-items.md`](15-outstanding-items.md):
fix the database defects, execute tests and UAT, perform a security assessment, and stand up a
staging environment.

## 8. Related documents

- [`02-project-background.md`](02-project-background.md) · [`03-project-objectives.md`](03-project-objectives.md) · [`04-project-scope.md`](04-project-scope.md)
- [`06-solution-overview.md`](06-solution-overview.md) · [`07-system-architecture.md`](07-system-architecture.md) · [`10-project-progress.md`](10-project-progress.md)
- [`19-final-acceptance.md`](19-final-acceptance.md) · [`../00-project-overview/01-project-overview.md`](../00-project-overview/01-project-overview.md)
