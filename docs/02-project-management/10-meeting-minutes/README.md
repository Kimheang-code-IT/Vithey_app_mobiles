# Meeting Minutes

> Status: Requires confirmation · Last reviewed: 2026-09-30
> Evidence: repository search for minutes/meeting records (none found); git history
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md` §12

Part of the Vithey documentation set · Master index:
[`../../00-project-overview/07-document-index.md`](../../00-project-overview/07-document-index.md) ·
Parent: [Project management](../) · Sibling: [Project plan](../01-project-plan.md) · [Status report](../07-project-status-report.md).

## 1. Finding: no meeting minutes exist in the repository

**No formal meeting minutes were found in the repository.**

- No `minutes`, `meeting`, or `MoM` documents, folders, or templates were located under `docs/`
  or anywhere else in the tracked tree.
- No dated attendance, agenda, action-item, or decision records attributed to a meeting exist.
- The repository does **not** contain any artefact from which a meeting could be reconstructed.

Accordingly, **no meetings are recorded here and none are invented.** This file provides a template
so that future meetings can be captured consistently. Until minutes are produced, project decisions
and changes must be tracked in [`../09-decision-log.md`](../09-decision-log.md) and
[`../08-change-request-log.md`](../08-change-request-log.md).

Status of meeting minutes as a governance artefact: **Not yet executed / Not present.**
[TBD] TBD — Requires confirmation whether any meetings occurred and were minuted outside the repository.

## 2. Purpose of this folder

This folder is the home for dated minutes, one file per meeting (recommended naming:
`YYYY-MM-DD-<topic>.md`). When the first real minutes are added, list them here.

| Date | Meeting | Minutes file | Status |
| --- | --- | --- | --- |
| — | *(none recorded)* | — | — |

## 3. Template

Copy the block below into a new file `YYYY-MM-DD-<topic>.md` and fill it in. Leave fields blank
rather than guessing; use `TBD — Requires confirmation.` where unknown.

```markdown
# Meeting Minutes — <topic>

> Date: YYYY-MM-DD · Time: HH:MM (TZ) · Location/Platform: <...>
> Minutes by: <name> · Status: Draft / Approved
> Scope tag: VERIFIED / INFERRED / PLANNED / TBD

## 0. Attendance

| Name | Role | Present | Apologies |
| --- | --- | --- | --- |
|  |  | Yes/No |  |

Quorum: Yes/No/N/A. Chair: <name>. Note-taker: <name>.

## 1. Agenda

1. <item>
2. <item>

## 2. Discussion and decisions

| # | Topic | Decision | Rationale | Decision-log ref |
| --- | --- | --- | --- | --- |
| 1 |  |  |  |  |

> Record decisions that must persist in ../../09-decision-log.md as well.

## 3. Action items

| # | Action | Owner | Due date | Status | Linked task ID |
| --- | --- | --- | --- | --- | --- |
| 1 |  |  |  | Open | (Action_Plan_Vithey.csv Task ID) |

## 4. Risks / issues raised

| # | Item | Type (Risk/Issue/Blocker) | Owner | Link to register |
| --- | --- | --- | --- | --- |
| 1 |  |  |  | ../../18-risk-management/ |

## 5. Change requests raised

| # | Change | Type | Raised by | Link to CR log |
| --- | --- | --- | --- | --- |
| 1 |  |  |  | ../../08-change-request-log.md |

## 6. Next meeting

Date: TBD · Agenda owner: TBD
```

## 4. Cross-links

- [Decision log](../09-decision-log.md) · [Change request log](../08-change-request-log.md)
- [Action plan](../02-action-plan.md) · [Risk register](../../18-risk-management/01-risk-register.md) · [Issue log](../../18-risk-management/02-issue-log.md)
