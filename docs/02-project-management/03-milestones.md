# Milestones

> Status: Requires confirmation · Last reviewed: 2026-09-30
> Evidence: git history (`git log --date=short`), `Action_Plan_Vithey.csv`, `plan.md`, `docs/_meta/EVIDENCE-BASIS.md`
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

Part of the Vithey documentation set · Master index:
[`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) ·
Sibling: [Project plan](01-project-plan.md) · [Action plan](02-action-plan.md) ·
[WBS](04-work-breakdown-structure.md) · [Timeline](06-project-timeline.md) · [Status report](07-project-status-report.md).

## 1. Important caveat

**No formally approved milestone schedule exists in the repository.** The table below is
**[INFERRED]** from git commit activity windows and the section structure of
`Action_Plan_Vithey.csv`. The dates are **evidence-derived** (the date of the relevant commit),
**not** contractual milestone dates or approval dates. Milestone *acceptance* is `TBD`.

## 2. Evidence-derived milestone timeline

| # | Milestone | Basis | Evidence-derived date | Status |
| --- | --- | --- | --- | --- |
| M0 | Repository / prompt baseline created | first commit `7e35770` "Prompt" | 2026-06-27 | [VERIFIED] exists |
| M1 | Backend and infrastructure build-out begins | `Action_Plan_Vithey.csv` §2/§5 window; `backend/infrastructure` activity | 2026-07-05 | [VERIFIED] artefacts exist |
| M2 | Requirements and per-service specs drafted | `docs/Prompt *` sets; CSV §1 | 2026-07-05 → 2026-09-30 | [VERIFIED] docs exist |
| M3 | Migration fixes (finance/career schema bugs) | commit `4ac45f8` "update and fx migration bugs" | 2026-08-06 | [VERIFIED] commit exists |
| M4 | Auth/UI iteration | commits `4c1f151`, `b261c1f`, `c93d138` era | 2026-08-21 → 2026-08-30 | [VERIFIED] commits exist |
| M5 | `ai_core` AI CV feature first commit | commit `6d794a5` "1st commit for the AI feature" | 2026-08-24 | [VERIFIED] commit exists |
| M6 | AI CV enhancements (model, normalizer) | commits `307f2cd`, `906cf11` | 2026-08-26 | [VERIFIED] commits exist |
| M7 | Map feature added (client + service) | commits `f096bf5`, `be87718`, `1420b0d` | 2026-08-30 → 2026-09-05 | [VERIFIED] commits exist |
| M8 | Branch consolidation (bora, molika, liza, sovannarith, sothay_dev) | merge commits `bcb3eea`, `40cfc86`, `5ab1bb7`, `b7acec7`, `8e727b3` | 2026-09-05 | [VERIFIED] merges exist |
| M9 | API integration v0.0.1 | commits `3d0810f`, `332ca4a` | 2026-09-12 | [VERIFIED] commits exist |
| M10 | API integration contracts + compose/build scripts | commits `caf5e95`, `5b16cb9` | 2026-09-14 | [VERIFIED] commits exist |
| M11 | Production-oriented config update | commit `c93d138` "update production 01" | 2026-09-19 | [VERIFIED] commit exists |
| M12 | Version 0.0.3 + reusable resource refactor | commits `3537584`, `ac227fd` | 2026-09-20 | [VERIFIED] commits exist |
| M13 | Upstream/dev merge (map-service + build scripts) | commit `d11106f` | 2026-09-30 | [VERIFIED] commit exists |

> Tag `presync-20260930` points at commit `3537584` ("updaate version 0.0.3"). [VERIFIED] `EVIDENCE-BASIS.md` §1.

## 3. Milestones that do NOT exist yet

These are commonly expected project milestones; there is **no evidence** they occurred. They are
listed so the gap is explicit, not to assert they were planned.

| Expected milestone | Status | Evidence |
| --- | --- | --- |
| Code freeze / release candidate sign-off | Not evidenced | No tag/branch named as a release candidate beyond `presync-20260930` |
| UAT start / completion | **Not executed** | `../12-uat/`; `EVIDENCE-BASIS.md` §12 |
| Security assessment / pen test | **Not performed** | `../10-security/11-security-review-report.md` |
| Staging environment ready | **Does not exist** | `EVIDENCE-BASIS.md` §9 |
| Production go-live | **Not performed** | `EVIDENCE-BASIS.md` §9 |
| Formal client acceptance | **Not present** | blank fields in `plan.md` §14 |
| Project handover | Not evidenced | `Action_Plan_Vithey.csv` 22.1 Not Started |
| Project closure | Not evidenced | `Action_Plan_Vithey.csv` 23.x Not Started |

## 4. Open questions

- Formal milestone names, baseline dates and acceptance owners: [TBD] TBD — Requires confirmation.
- Which git activity window (if any) constitutes the client's agreed end date: [TBD] TBD — Requires confirmation.

## 5. Cross-links

- [Action plan](02-action-plan.md) · [Timeline](06-project-timeline.md) · [Status report](07-project-status-report.md)
- [Risk register](../18-risk-management/01-risk-register.md)
