# Team Roles & Responsibilities

> Status: Requires confirmation · Last reviewed: 2026-09-30
> Evidence: git author metadata (`git log`), `Action_Plan_Vithey.csv` "Responsible Party" column
> **Important:** This document is [INFERRED]. Names come from commit metadata and a planning CSV; roles and responsibilities require business confirmation. No formal org chart exists in the repository.

## 1. Basis for inference

Two evidence sources were cross-referenced:

1. **Git author identities** from commit metadata across `backend/`, `vithey_app/`, and `ai_core/`.
2. The **Responsible Party** column in `Action_Plan_Vithey.csv`.

Neither is an authoritative staffing record. Treat every role below as provisional.
[INFERRED] Inferred from implementation — requires business confirmation.

## 2. Inferred team and areas

| Name (git) | Inferred primary area | Supporting evidence | Confidence |
| --- | --- | --- | --- |
| Kim heang | Project lead; backend, DevOps, integration, home/chat/create-post UI | Most merge commits; parent POM, Compose, CI, scripts; branch merges for AI, finance, map, UI | High (activity) / Role unconfirmed |
| Ponloeng Bora (bora) | Gateway, auth, infrastructure (Eureka/Config), DB layout | `api-gateway`, `auth-service`, `infrastructure`, CI integration contracts commit | Medium |
| namayheng | Flutter auth, settings, theme | Commits "Update auth", "Settings UI", "colors, profile & auth" | Medium |
| KhornMolika | Flutter profile, settings/media, map | Branches `molika`, `add map`, `update map` | Medium |
| KosalChansothay | `ai_core` (Python AI engine) | Branch `sothay_dev`, "AI CV core" merge; Action_Plan ai_core owner | High |
| sovannarith | Flutter finance / ACLEDA payment screen | Branch `sovannarith/finace`, finance commits | Medium |
| Heng Liza / Icesuza | UI, app display name ("Vithey") | "UI check up"; merge "app display name Vithey" | Low–Medium |

[INFERRED] Inferred from implementation — requires business confirmation.

## 3. Responsibility matrix (provisional)

| Domain | Areas | Probable owner | Status |
| --- | --- | --- | --- |
| Product / scope | Demo scope freeze, plan, API contract | Kim heang | [INFERRED] |
| Backend platform | Gateway, Eureka, Config, discovery, DBs | Ponloeng Bora | [INFERRED] |
| Identity | auth-service, JWT, student verification | Ponloeng Bora | [INFERRED] |
| Domain services | content, career, finance, chat, notification, file, map | Kim heang et al. | [INFERRED] |
| Flutter | auth/settings/theme, profile/map, finance | namayheng, KhornMolika, sovannarith | [INFERRED] |
| AI engine | `ai_core` CV pipeline, tests | KosalChansothay | [INFERRED] |
| DevOps | Compose, scripts, CI, monitoring | Kim heang | [INFERRED] |
| UI/UX | Shared theme, design tokens, branding | namayheng, Liza/Icesuza | [INFERRED] |

## 4. Skill coverage map

| Capability required by the repo | Evidence it is covered | Status |
| --- | --- | --- |
| Java 21 / Spring Boot 3.x | `backend/` services and tests | [VERIFIED] |
| Flutter / Dart / GetX | `vithey_app/` | [VERIFIED] |
| Python / FastAPI | `ai_core/` | [VERIFIED] |
| Docker / Compose / CI | `backend/scripts`, `.github/workflows` | [VERIFIED] |
| Observability | `monitoring/` | [VERIFIED] |
| Security review expertise | No evidence found | [TBD] TBD — Requires confirmation. |
| UAT / QA sign-off | No evidence found | [TBD] TBD — Requires confirmation. |

## 5. Open questions

- Formal role titles and reporting lines: [TBD] TBD — Requires confirmation.
- Named security reviewer and QA/UAT owner: [TBD] TBD — Requires confirmation.
- Correct mapping of git aliases (e.g. `bora`, `Icesuza`) to legal names: [TBD] TBD — Requires confirmation.

## 6. Related documents

- [`04-stakeholders.md`](04-stakeholders.md)
- [`../01-requirements/01-business-requirements-BRD.md`](../01-requirements/01-business-requirements-BRD.md)
