# Action Plan

> Status: Partially complete — 124 of 150 tracked actions marked Completed in the plan; assurance and closure actions outstanding · Last reviewed: 2026-09-30
> Evidence: `Action_Plan_Vithey.csv` (150 rows), `plan.md`, `backend/`, `vithey_app/`, `ai_core/`
> Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)

> **Important:** the task counts below are taken from the project's own action-plan spreadsheet
> and describe **tracked activities**, not contractual deliverables. They must not be read as a
> contractual completion percentage. See [`10-project-progress.md`](10-project-progress.md).

## 1. Plan structure

The action plan organises work into 23 sections spanning 150 tracked actions, from project
initiation through to handover and closure. [VERIFIED] `Action_Plan_Vithey.csv`

| # | Section | Actions |
| --- | --- | --- |
| 1 | Project initiation and requirements | 5 |
| 2 | System analysis and architecture | 5 |
| 3 | UI and UX design | 14 |
| 4 | Database design | 11 |
| 5 | Project setup and DevOps | 8 |
| 6 | Backend — gateway and identity | 6 |
| 7 | Backend — domain services | 12 |
| 8 | AI engine `ai_core` | 8 |
| 9 | Frontend — Flutter app | 15 |
| 10 | System integration | 7 |
| 11 | Authentication and authorization | 5 |
| 12 | Security | 7 |
| 13 | Finance and reporting | 4 |
| 14 | Testing and QA | 8 |
| 15 | Bug fixing and defects | 6 |
| 16 | Performance optimization | 6 |
| 17 | Deployment | 5 |
| 18 | Monitoring and observability | 4 |
| 19 | Documentation | 5 |
| 20 | User acceptance testing | 3 |
| 21 | Training and knowledge transfer | 2 |
| 22 | Handover | 2 |
| 23 | Project closure | 2 |
| | **Total** | **150** |

## 2. Tracked status (as recorded in the plan)

| Status | Count |
| --- | --- |
| Completed | 124 |
| Not started | 20 |
| In progress | 3 |
| Pending review | 2 |
| Blocked | 1 |
| **Total** | **150** |

[VERIFIED] `Action_Plan_Vithey.csv` "Status" column

## 3. Open actions

| Task ID | Section | Action | Status |
| --- | --- | --- | --- |
| 4.11 | Database | Prepare demo seed data | Not started |
| 7.12 | Domain services | Implement map and places | Pending review |
| 9.14 | Frontend | Implement push notification client | Not started |
| 9.15 | Frontend | Implement Google sign-in | Not started |
| 11.5 | Auth | Implement two-factor and biometric login | Not started |
| 12.7 | Security | Perform a formal security review | Not started |
| 13.4 | Finance | Implement a reporting and analytics module | Not started |
| 14.5 | Testing | Expand Flutter tests | In progress |
| 14.7 | Testing | Add map-service integration tests | Not started |
| 14.8 | Testing | Execute user acceptance testing | Not started |
| 15.1 | Defects | Resolve the duplicate Flyway V3 migration | Pending review |
| 15.2 | Defects | Implement the missing post update endpoint | Not started |
| 15.3 | Defects | Align map-service compose gating | Not started |
| 15.4 | Documentation | Correct stale documentation | In progress |
| 15.5 | Defects | Recover the non-compiling WIP branch | Blocked |
| 15.6 | Defects | Replace placeholder features or mark them out of scope | Not started |
| 17.5 | Deployment | Deploy to a production environment | Not started |
| 20.1 | UAT | Prepare UAT plan and test cases | Not started |
| 20.2 | UAT | Execute UAT with stakeholders | Not started |
| 20.3 | UAT | Obtain UAT sign-off | Not started |
| 21.1 | Training | Deliver developer onboarding | Not started |
| 21.2 | Training | Deliver operational runbook training | Not started |
| 22.1 | Handover | Hand over source code and environments | Not started |
| 22.2 | Handover | Prepare the bank reporting pack | In progress |
| 23.1 | Closure | Obtain final acceptance | Not started |
| 23.2 | Closure | Produce the closure report | Not started |

## 4. Phased delivery view

The locked plan describes a phased path: Phase 0 (freeze) → Phase 1 (infra) → Phase 2 (wire
`ai_core`) → Phase 3 (chat stub) → Phase 4 (Flutter live switch) → Phase 5 (optional rule-based
AI). Implementation evidence supports delivery of Phases 0–4; Phase 5 was optional. [VERIFIED]
`plan.md` §5

## 5. Interpreting the counts

The 124 "Completed" actions are largely design, implementation, and documentation tasks. The 26
non-completed actions cluster in **assurance, deployment, handover, and closure** — precisely the
areas a bank would require before production. This distribution is the central message of
[`10-project-progress.md`](10-project-progress.md).

## 6. Related documents

- [`10-project-progress.md`](10-project-progress.md) · [`14-risks-issues.md`](14-risks-issues.md) · [`15-outstanding-items.md`](15-outstanding-items.md)
- [`17-recommendations.md`](17-recommendations.md)
