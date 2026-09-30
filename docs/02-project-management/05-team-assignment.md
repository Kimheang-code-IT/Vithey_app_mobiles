# Team Assignment

> Status: Requires confirmation · Last reviewed: 2026-09-30
> Evidence: git author metadata (`git shortlog -sne --all`, `git log`), `Action_Plan_Vithey.csv` "Responsible Party" column
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md` §11
> **Important:** This document is [INFERRED]. There is no authoritative staffing record or org chart in the repository. Names, roles and assignments require business confirmation.

Part of the Vithey documentation set · Master index:
[`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) ·
Sibling: [Project plan](01-project-plan.md) · [Action plan](02-action-plan.md) · [WBS](04-work-breakdown-structure.md).
See also [Team roles & responsibilities](../00-project-overview/05-team-roles-responsibilities.md).

## 1. Basis for inference

Two evidence sources were cross-referenced:

1. **Git author identities** — commit metadata across `backend/`, `vithey_app/`, `ai_core/`, `docs/`, `monitoring/`.
2. The **Responsible Party** column of `Action_Plan_Vithey.csv`.

Neither is a formal staffing record. All assignments below are provisional.
[INFERRED] Inferred from implementation — requires business confirmation.

## 2. Inferred contributors

Commit-count figures are from `git shortlog -sne --all` at documentation time (2026-09-30).

| Name (git) | Commits | Inferred primary area | Confidence |
| --- | --- | --- | --- |
| Kim heang | 41 | Project lead; backend, DevOps, integration, home/chat/create-post UI; merges | High (activity) / Role unconfirmed |
| KhornMolika | 31 | Flutter profile, settings/media, map | Medium |
| namayheng | 24 | Flutter auth, settings, theme | Medium |
| ponloengbora / Ponloeng Bora / bora | 10 + 6 + 2 (+1 Bora) | Gateway, auth, infrastructure (Eureka/Config), DB layout | Medium |
| KosalChansothay | 6 | `ai_core` (Python AI engine) | High |
| sovannarith / Sovannarith | 3 + 1 | Flutter finance / ACLEDA payment screen | Medium |
| Icesuza (Heng Liza) | 1 | UI polish, app display name ("Vithey") | Low–Medium |

[INFERRED] Inferred from implementation — requires business confirmation.

## 3. Assignment by WBS section

| WBS | Section | Probable owner | Source | Status |
| --- | --- | --- | --- | --- |
| 1 | Initiation & Requirements | Kim heang | CSV (all rows) | [INFERRED] |
| 2 | Analysis & Architecture | Kim heang (2.1–2.4), Ponloeng Bora (2.5) | CSV | [INFERRED] |
| 3 | UI/UX Design | namayheng, KhornMolika, Kim heang, Sovannarith | CSV | [INFERRED] |
| 4 | Database Design | Ponloeng Bora (4.1, 4.2), Kim heang (rest) | CSV | [INFERRED] |
| 5 | Setup & DevOps | Kim heang, Ponloeng Bora | CSV | [INFERRED] |
| 6 | Gateway & Identity | Ponloeng Bora (6.1–6.4), Kim heang (6.5–6.6) | CSV | [INFERRED] |
| 7 | Domain Services | Kim heang | CSV | [INFERRED] |
| 8 | AI Engine `ai_core` | KosalChansothay | CSV, branch `sothay_dev` | [INFERRED] |
| 9 | Flutter App | Kim heang, namayheng, KhornMolika, Sovannarith | CSV | [INFERRED] |
| 10 | System Integration | Kim heang | CSV | [INFERRED] |
| 11 | Auth & Authorization | Ponloeng Bora (11.1–11.3), Kim heang (11.4) | CSV | [INFERRED] |
| 12 | Security | Ponloeng Bora, Kim heang | CSV | [INFERRED] |
| 13 | Finance & Reporting | Sovannarith | CSV, branch `sovannarith/finace` | [INFERRED] |
| 14 | Testing & QA | Kim heang, KosalChansothay | CSV | [INFERRED] |
| 15 | Bug Fixing & Defects | Kim heang | CSV | [INFERRED] |
| 16 | Performance | Kim heang, KosalChansothay | CSV | [INFERRED] |
| 17 | Deployment | Kim heang | CSV | [INFERRED] |
| 18 | Monitoring | Kim heang | CSV | [INFERRED] |
| 19 | Documentation | Kim heang, KosalChansothay | CSV | [INFERRED] |
| 20 | UAT | TBD | — | [TBD] |
| 21 | Training & KT | TBD | — | [TBD] |
| 22 | Handover | TBD | — | [TBD] |
| 23 | Closure | TBD | — | [TBD] |

## 4. Unassigned / unfilled roles

| Role | Status | Note |
| --- | --- | --- |
| Product owner / client signatory | [TBD] | Blank fields in `plan.md` §14. TBD — Requires confirmation. |
| Security reviewer | [TBD] | No security review performed. TBD — Requires confirmation. |
| QA / UAT lead | [TBD] | UAT not executed. TBD — Requires confirmation. |
| DevOps owner of production | [TBD] | No production environment. TBD — Requires confirmation. |
| Operations / on-call owner | [TBD] | No runbooks training record. TBD — Requires confirmation. |

## 5. Open questions

- Correct mapping of git aliases (`bora`, `Icesuza`, `namayheng`) to legal names: [TBD] TBD — Requires confirmation.
- Formal role titles, reporting lines and capacity (FTE): [TBD] TBD — Requires confirmation.
- Which person is accountable for the unassigned WBS 20–23 sections: [TBD] TBD — Requires confirmation.

## 6. Cross-links

- [Team roles & responsibilities](../00-project-overview/05-team-roles-responsibilities.md)
- [Stakeholders](../00-project-overview/04-stakeholders.md)
- [Action plan](02-action-plan.md)
