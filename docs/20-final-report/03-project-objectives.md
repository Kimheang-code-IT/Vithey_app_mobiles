# Project Objectives

> Status: Partially complete — implementation objectives largely met; assurance objectives outstanding · Last reviewed: 2026-09-30
> Evidence: `plan.md` §0/§9, `docs/Prompt Frontend/00-project-summary.md`, `Action_Plan_Vithey.csv`, `../00-project-overview/02-project-objectives.md`
> Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)

## 1. Vision

Build **Vithey** — a youth-focused student superapp that gives students one place to socialise,
find and apply for jobs with an AI-assisted CV, manage student finance, message peers, and reach
an AI assistant — delivered as a Flutter client over a Spring Cloud microservice backend with a
Python AI engine. [VERIFIED] `plan.md`, `../00-project-overview/02-project-objectives.md`

## 2. Business objectives

| ID | Objective | Status |
| --- | --- | --- |
| BO-01 | Enter the **ACLEDA Bank App Competition 2026** with a demonstrable student superapp | [VERIFIED] competition context |
| BO-02 | Cover **at least five youth-relevant features** in one app (feed, jobs, finance, chat, AI) | [VERIFIED] `docs/Prompt Frontend/00-project-summary.md` |
| BO-03 | Support register/login, a settings menu, and light/dark theme | [VERIFIED] |
| BO-04 | Demonstrate a credible student-to-career journey (jobs + AI CV builder) | [VERIFIED] `plan.md` §0 |
| BO-05 | Demonstrate student finance tied to ACLEDA Mobile | [INFERRED] `acleda_mobile_launcher.dart` — Inferred from implementation — requires business confirmation. |
| BO-06 | Produce a working local demonstration for ~10 users | [VERIFIED] `plan.md` §0 |
| BO-07 | Establish a path to a bank-approved production deployment | [PLANNED] `Action_Plan_Vithey.csv` 17.5 (Not Started) |

## 3. Technical objectives

| ID | Objective | Status |
| --- | --- | --- |
| TO-01 | Gateway-first microservice architecture | [VERIFIED] `backend/infrastructure/config-repo/api-gateway.yml` |
| TO-02 | One database per service with Flyway migrations | [VERIFIED] `backend/services/*/src/main/resources/db/migration/` |
| TO-03 | Domain-event integration over RabbitMQ (`vithey.events`) | [VERIFIED] `../_meta/EVIDENCE-BASIS.md` §4 |
| TO-04 | Centralized config (Spring Cloud Config native) and discovery (Eureka) | [VERIFIED] `backend/infrastructure/` |
| TO-05 | AI served by a Python engine behind the gateway | [VERIFIED] `ai_core/vithey_ai/api/flutter_routes.py` |
| TO-06 | Fit all services on one PC under memory caps | [VERIFIED] `backend/docker-compose.demo.yml`, `backend/.env.example` |
| TO-07 | Automated CI: per-service tests, promotion to `dev`, GHCR images | [VERIFIED] `.github/workflows/` |

## 4. Demo success criteria and execution status

The locked plan defines seven pass conditions. **None was independently executed as part of this
reporting task**, so none is marked passed. [VERIFIED] `plan.md` §9

| # | Criterion | Pass condition | Execution status |
| --- | --- | --- | --- |
| 1 | Full Profile M stack runs on one PC without thrashing | RAM stable 15+ minutes | Test implemented — current execution result not independently verified. |
| 2 | 10 users can log in and browse | No mass `500`s | Test implemented — current execution result not independently verified. |
| 3 | Seed user generates CV via live API | Draft matches profile/posts | Test implemented — current execution result not independently verified. |
| 4 | Empty profile returns incomplete message | No wasted LLM call | Test implemented — current execution result not independently verified. |
| 5 | Concurrent CV generation is capped | Extra requests get a clear busy error | Test implemented — current execution result not independently verified. |
| 6 | Chatbot answers with a stub reply (no GDCE) | Demo path works | Test implemented — current execution result not independently verified. |
| 7 | Flutter Auto-Create CV works with `USE_MOCK_AI=false` | End-to-end | Test implemented — current execution result not independently verified. |

## 5. Non-goals (agreed out of scope)

GDCE / `general-service` RAG, Kubernetes, production high availability, local GPU LLMs, OCR/PDF
CV parsing, and Google OAuth are excluded from the locked demo scope. A formal security
assessment and UAT are not yet performed. [VERIFIED] `plan.md` §8, `../_meta/EVIDENCE-BASIS.md` §12

## 6. Objective assessment

- **Business objectives:** the feature-richness and demonstration objectives (BO-02, BO-04, BO-06)
  are supported by implemented modules. Competition entry and production-path objectives are
  governance matters. [VERIFIED] / [TBD]
- **Technical objectives:** all seven technical objectives are supported by repository evidence.
  [VERIFIED]
- **Assurance objectives** (UAT, security, deployment) remain open. [TBD]

## 7. Open questions

- Whether this objective set is the contractually agreed bank scope. [TBD] `TBD — Requires confirmation.`
- Business acceptance thresholds beyond the demo criteria. [TBD] `TBD — Requires confirmation.`

## 8. Related documents

- [`04-project-scope.md`](04-project-scope.md) · [`08-implemented-features.md`](08-implemented-features.md) · [`10-project-progress.md`](10-project-progress.md)
- [`../00-project-overview/02-project-objectives.md`](../00-project-overview/02-project-objectives.md)
