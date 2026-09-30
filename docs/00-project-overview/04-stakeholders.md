# Stakeholders

> Status: Requires confirmation · Last reviewed: 2026-09-30
> Evidence: `docs/Prompt Frontend/00-project-summary.md`, `docs/Prompt Backend/COMMON_CONTEXT.md`, `Action_Plan_Vithey.csv`, git history
> Note: Named individuals and formal signatories are **not** established in the repository. Team membership below is inferred from commit metadata and marked accordingly.

## 1. Stakeholder groups

| ID | Stakeholder | Interest | Type | Status |
| --- | --- | --- | --- | --- |
| SH-01 | ACLEDA Bank — App Competition 2026 organisers / evaluators | Assess Vithey against competition rules and requirements | External / governance | [VERIFIED] competition context |
| SH-02 | AUB student community | Primary end users of the superapp | External / user | [VERIFIED] student context (`docs/Prompt Frontend/00-project-summary.md`) |
| SH-03 | Product owner / sponsor | Owns product direction and demo sign-off | Internal / decision | [TBD] identity TBD — Requires confirmation. |
| SH-04 | Project team (dev/design) | Build, integrate, test the system | Internal / delivery | [INFERRED] from git authors & Action_Plan — requires confirmation |
| SH-05 | Job-poster companies (`COMPANY` role) | Post jobs and review applicants | External / user | [VERIFIED] `api_docs.md` §18 |
| SH-06 | Operations / support (future) | Run and monitor the stack if productionised | Internal / operational | [PLANNED] not yet staffed |
| SH-07 | Bank security / compliance reviewer (future) | Security and data-handling review before production | External / governance | [TBD] review not performed — Requires confirmation. |

## 2. Stakeholder needs

| Stakeholder | Need | Addressed by | Status |
| --- | --- | --- | --- |
| SH-01 | A youth mobile app with ≥5 features, register/login, settings, light/dark mode | Vithey feature set | [VERIFIED] `docs/Prompt Frontend/00-project-summary.md` |
| SH-02 | Social feed, jobs, finance, chat, AI help in one app | `vithey_app/` modules | [VERIFIED] |
| SH-03 | A credible local demo for ~10 users | Profile M demo | [VERIFIED] `plan.md` |
| SH-04 | Clear build/run/test instructions | `AGENTS.md`, `backend/DOCKER.md`, `backend/TESTING.md` | [VERIFIED] |
| SH-05 | Post jobs and review applicants | career-service, content-service | [VERIFIED] `api_docs.md` §7 |
| SH-07 | A security assessment before go-live | Not yet performed | [TBD] TBD — Requires confirmation. |

## 3. RACI snapshot (delivery)

Roles are inferred; names are not assigned here because they are unconfirmed.

| Activity | Product owner | Backend | Frontend | AI | DevOps |
| --- | --- | --- | --- | --- | --- |
| Scope freeze / demo plan | A | R | C | C | C |
| Backend services | I | A/R | I | C | C |
| Flutter app | C | I | A/R | I | I |
| AI CV engine | I | C | C | A/R | I |
| CI / Compose / monitoring | I | C | I | I | A/R |
| UAT & acceptance | A | C | C | C | I |

A = accountable, R = responsible, C = consulted, I = informed. [INFERRED] Inferred from implementation and Action_Plan owner columns — requires business confirmation.

## 4. Governance status

| Artefact | Status |
| --- | --- |
| UAT | Not yet executed [VERIFIED] EVIDENCE-BASIS §12 |
| Formal acceptance / sign-off | Not present (blank fields in `plan.md` §14) [VERIFIED] |
| Security assessment | Not yet formally assessed [VERIFIED] |
| Production deployment | Not performed [VERIFIED] |

## 5. Open questions

- Who is the accountable product owner/sponsor and the bank-side signatory? [TBD] TBD — Requires confirmation.
- Who owns security/compliance sign-off and what standard applies? [TBD] TBD — Requires confirmation.
- Which organisation legally owns the delivered code and data? [TBD] TBD — Requires confirmation.

## 6. Related documents

- [`05-team-roles-responsibilities.md`](05-team-roles-responsibilities.md)
- [`../01-requirements/01-business-requirements-BRD.md`](../01-requirements/01-business-requirements-BRD.md)
