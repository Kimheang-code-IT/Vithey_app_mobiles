# Project Objectives

> Status: Partially complete · Last reviewed: 2026-09-30
> Evidence: `plan.md` §0/§9, `docs/Prompt Frontend/00-project-summary.md`, `Action_Plan_Vithey.csv`, `AGENTS.md`

## 1. Vision statement

Build **Vithey**, a youth-focused mobile superapp that gives AUB students one place to
socialise, find and apply for jobs with an AI-assisted CV, manage student finance,
message peers, and reach an AI assistant — delivered as a Flutter client over a
Spring Cloud microservice backend with a Python AI engine. [VERIFIED] `docs/Prompt Frontend/00-project-summary.md`

## 2. Business objectives

| ID | Objective | Rationale | Status |
| --- | --- | --- | --- |
| BO-01 | Enter the **ACLEDA Bank App Competition 2026** with a demonstrable student superapp | Competition entry is the stated delivery context | [VERIFIED] `docs/Prompt Backend/COMMON_CONTEXT.md` |
| BO-02 | Cover **at least five youth-relevant features** in one app | Competition requirement: feed, jobs, finance, chat, AI (+ notifications, profile) | [VERIFIED] `docs/Prompt Frontend/00-project-summary.md` |
| BO-03 | Support register/login, a settings menu, and light/dark theme | Competition requirement | [VERIFIED] same |
| BO-04 | Demonstrate a credible student-to-career journey (jobs + AI CV builder) | Core differentiator; AI CV is the P0 AI focus | [VERIFIED] `plan.md` §0 |
| BO-05 | Demonstrate student finance tied to ACLEDA Mobile | Finance module includes an ACLEDA Mobile launcher | [INFERRED] Inferred from implementation (`acleda_mobile_launcher.dart`, Action_Plan 13.2) — requires business confirmation. |
| BO-06 | Produce a working local demonstration for internal pitch to ~10 users | Locked Profile M decision | [VERIFIED] `plan.md` §0 |
| BO-07 | Establish a path to a bank-approved production deployment | Out of demo scope; requires future work | [PLANNED] `Action_Plan_Vithey.csv` 17.5 (Not Started) |

## 3. Technical objectives

| ID | Objective | Evidence | Status |
| --- | --- | --- | --- |
| TO-01 | Gateway-first microservice architecture | `backend/infrastructure/config-repo/api-gateway.yml`, `api_docs.md` §15 | [VERIFIED] |
| TO-02 | One database per service with Flyway migrations | `backend/services/*/src/main/resources/db/migration/` | [VERIFIED] |
| TO-03 | Domain-event integration over RabbitMQ (`vithey.events`) | `config-repo/application.yml`, EVIDENCE-BASIS §4 | [VERIFIED] |
| TO-04 | Centralised runtime config (Spring Cloud Config native) and discovery (Eureka) | `backend/infrastructure/` | [VERIFIED] |
| TO-05 | AI served by a Python engine (`ai_core`) behind the gateway | `ai_core/vithey_ai/api/flutter_routes.py` | [VERIFIED] |
| TO-06 | Fit all services on one PC under memory caps | `backend/docker-compose.demo.yml`, `backend/.env.example` | [VERIFIED] |
| TO-07 | Automated CI: per-service tests + promotion to `dev` + GHCR images | `.github/workflows/` | [VERIFIED] |

## 4. Demo success criteria

The following pass conditions are defined in `plan.md` §9 (locked demo plan). None have
been independently executed as part of this documentation task.

| # | Criterion | Pass condition | Execution status |
| --- | --- | --- | --- |
| 1 | Full Profile M stack runs on one PC without thrashing | RAM stable 15+ minutes | Not independently verified |
| 2 | 10 users can log in and browse | No mass `500`s | Not independently verified |
| 3 | Seed user generates CV via live API | Draft matches profile/posts | Not independently verified |
| 4 | Empty profile returns incomplete message | No wasted LLM call | Not independently verified |
| 5 | Concurrent CV generation is capped | Extra requests get a clear busy error | Not independently verified |
| 6 | Chatbot answers with a stub reply (no GDCE) | Demo path works | Not independently verified |
| 7 | Flutter Auto-Create CV works with `USE_MOCK_AI=false` | End-to-end | Not independently verified |

## 5. Non-goals

- GDCE / `general-service` RAG, Kubernetes, production HA, local GPU LLM, OCR/PDF parsing,
  and Google OAuth are explicitly out of the locked demo scope. [VERIFIED] `plan.md` §8
- A formal security assessment and UAT are not yet performed. [VERIFIED] EVIDENCE-BASIS §12

## 6. Open questions

- Whether the objective set is the contractually agreed bank scope: [TBD] TBD — Requires confirmation.
- Business acceptance thresholds beyond the demo criteria above: [TBD] TBD — Requires confirmation.

## 7. Related documents

- [`03-project-scope.md`](03-project-scope.md)
- [`../01-requirements/01-business-requirements-BRD.md`](../01-requirements/01-business-requirements-BRD.md)
- [`../01-requirements/08-acceptance-criteria.md`](../01-requirements/08-acceptance-criteria.md)
