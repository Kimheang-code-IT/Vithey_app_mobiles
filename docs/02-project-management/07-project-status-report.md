# Project Status Report

> Status: Partially complete / Requires confirmation · Report date: 2026-09-30
> Evidence: repository inspection (`backend/`, `vithey_app/`, `ai_core/`, `monitoring/`, `.github/`, `docs/`), `Action_Plan_Vithey.csv`, `plan.md`, git history
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

Part of the Vithey documentation set · Master index:
[`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) ·
Sibling: [Project plan](01-project-plan.md) · [Action plan](02-action-plan.md) · [Milestones](03-milestones.md) ·
[Timeline](06-project-timeline.md) · [Risk register](../18-risk-management/01-risk-register.md) · [Issue log](../18-risk-management/02-issue-log.md).

## 1. Executive summary

Vithey is a monorepo implementing an AUB student superapp: a Flutter client, a Java 21 / Spring
Cloud backend, and a Python FastAPI AI engine (`ai_core`), with an opt-in monitoring stack. The
**locked delivery target is a local demo ("Profile M")** run on one PC for ~10 concurrent users.
[VERIFIED] `plan.md` §0/§3.2.

At report time the repository contains **complete, verifiable source and configuration** for the
demo: all services, migrations, Docker Compose overlays, scripts, CI workflows, dashboards and
docs. [VERIFIED] `EVIDENCE-BASIS.md` §2–§9.

What is **not** evidenced and must not be reported as done:

- Test suites were **not executed** during this documentation task. [VERIFIED] `EVIDENCE-BASIS.md` §10.
- **UAT was not executed**; **no security assessment**; **no staging**; **no production deployment**;
  **no formal acceptance/sign-off**. [VERIFIED] `EVIDENCE-BASIS.md` §12.
- Several client features are **stubs/placeholders** (Google auth, FCM push, 2FA/biometric, parts of
  chatbot history search, some settings rows). [VERIFIED] `EVIDENCE-BASIS.md` §6–§7.
- **No meeting minutes** were found; governance artefacts are largely absent. [VERIFIED] [`10-meeting-minutes/README.md`](10-meeting-minutes/README.md).

## 2. Status dashboard

| Area | Status | Basis |
| --- | --- | --- |
| Requirements & architecture docs | Implemented | `docs/01-*`, `docs/03-*` |
| Backend services (9 + gateway + Eureka + Config) | Implemented | `backend/`, `EVIDENCE-BASIS.md` §3 |
| Database schemas & Flyway migrations | Implemented with **defects** | `EVIDENCE-BASIS.md` §8 (duplicate V3, `@Id` mismatch, trigram no-op, enum/CHECK supersets) |
| `ai_core` CV pipeline (real LLM) | Implemented | `ai_core/vithey_ai/` |
| AI chat | Stub/Placeholder | `AI_CHAT_MODE=stub`, `EVIDENCE-BASIS.md` §6 |
| Flutter app modules | Implemented (some stubs) | `vithey_app/lib/modules/` |
| Demo Docker stack + scripts | Implemented | `backend/scripts/`, `backend/DEMO.md` |
| CI (per-service + promote-to-dev) | Implemented | `.github/workflows/` |
| Monitoring | Partial | profile-gated; no Alertmanager; scrape gaps (`monitoring/README.md`, `EVIDENCE-BASIS.md` §9) |
| Backend tests | Implemented, **not executed** here | `EVIDENCE-BASIS.md` §10 |
| Flutter tests | Thin (3 files) | `EVIDENCE-BASIS.md` §10 |
| UAT | **Not yet executed** | `EVIDENCE-BASIS.md` §12 |
| Security assessment | **Not yet formally assessed** | `../10-security/11-security-review-report.md` |
| Staging / Production | **Do not exist** | `EVIDENCE-BASIS.md` §9 |
| Backups | **No automation** | `../05-database/08-backup-restore.md` |

## 3. Progress by action-plan section

Statuses are the `Action_Plan_Vithey.csv` reported values, grouped by section. **They are not
independently verified.** Details in [`02-action-plan.md`](02-action-plan.md).

| WBS | Section | Reported status |
| --- | --- | --- |
| 1–2 | Initiation, Architecture | Completed |
| 3 | UI/UX Design | Completed |
| 4 | Database Design | Completed except 4.11 seed data (Not Started) |
| 5–10 | DevOps, backend, ai_core, Flutter, integration | Completed (7.12 Pending Review; 9.14/9.15 Not Started) |
| 11–13 | Auth, Security, Finance | Completed (11.5, 12.7, 13.4 Not Started) |
| 14 | Testing & QA | Completed except 14.5 In Progress (40%), 14.7/14.8 Not Started |
| 15 | Bug Fixing & Defects | 15.1 Pending Review; 15.4 In Progress (25%); 15.5 Blocked; others Not Started |
| 16–19 | Performance, Deployment, Monitoring, Documentation | Completed except 17.5 Not Started |
| 20–23 | UAT, Training, Handover, Closure | Not Started (22.2 In Progress 50%) |

> **Do not** derive an overall contractual completion percentage from Future Enhancement or
> Internal Technical Improvement tasks.

## 4. Current issues (top)

Full detail in [`../18-risk-management/02-issue-log.md`](../18-risk-management/02-issue-log.md).

| ID | Issue | Impact |
| --- | --- | --- |
| I-01 | career-service duplicate Flyway `V3` | Clean `career_db` cannot migrate deterministically |
| I-02 | Career `UserCv @Id` maps `user_id` but DB PK is `id` | Incorrect JPA identity semantics |
| I-03 | user-profile trigram index is a no-op | Intended search optimiser not created |
| I-04 | Enum vs DB CHECK supersets | Possible enum conversion errors on DB-only states |
| I-05 | `*SmokeIT` not run by default `mvn test` | Integration regressions can pass CI unnoticed |
| I-06 | No Alertmanager | Defined alerts have no delivery route |
| I-07 | Monitoring scrape gaps (eureka/config/map/ai_core) | Blind spots in observability |
| I-08 | Android release signs with debug keys | Not distributable |
| I-09 | `/api/v1/students/verify` public-path discrepancy | Route requires a JWT contrary to intent |
| I-10 | No automated backups | Data loss risk |
| I-11 | Single-worker in-memory caches/rate-limits | Incorrect under horizontal scaling |
| I-12 | Config baked into config-server image | Config change requires image rebuild |
| I-13 | AI chat stub; FCM/Google auth stubs | Features incomplete |
| I-14 | No staging/production, no security assessment, no UAT | Not release-ready |

## 5. Risks

See [`../18-risk-management/01-risk-register.md`](../18-risk-management/01-risk-register.md). The
highest-severity technical risks mirror the issues above; the highest programme-level risk is the
absence of staging/production plus no formal security assessment and no UAT.

## 6. Next steps (evidence-based, not scheduled)

1. Resolve career duplicate `V3` and `UserCv @Id` defects; re-verify clean migration on `career_db`.
2. Enable Failsafe so `*SmokeIT` run; run backend/Flutter/`ai_core` suites and record results.
3. Add Alertmanager + close monitoring scrape gaps (eureka, config, map, `ai_core`).
4. Replace debug signing with a release keystore before any distribution.
5. Define a backup/restore approach (schema-only reproducibility exists; row data has no automation).
6. Commission a security assessment and UAT plan; establish staging and production targets.
7. Decide the fate of placeholders (Google auth, FCM, 2FA/biometric, chat search).

> All next steps require owner and date assignment: [TBD] TBD — Requires confirmation.

## 7. Open questions

- Client acceptance criteria owner and date: [TBD] TBD — Requires confirmation.
- Whether the bank expects a hosted environment: [TBD] TBD — Requires confirmation.

## 8. Cross-links

- [Action plan](02-action-plan.md) · [Milestones](03-milestones.md) · [Timeline](06-project-timeline.md)
- [Risk register](../18-risk-management/01-risk-register.md) · [Known limitations](../18-risk-management/03-known-limitations.md) · [Technical debt](../18-risk-management/04-technical-debt.md)
