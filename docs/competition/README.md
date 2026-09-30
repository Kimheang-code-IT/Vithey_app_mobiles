# Competition Tracking and Reporting

This folder documents how Vithey / AUB Connect is tracked during the
4-month GenZ Mobile App Competition, and how progress is reported to the team,
management and the competition committee.

## GitHub Project

Work is tracked on a GitHub Project linked to this repository with these fields:

- **Status**: Backlog, Ready, In Progress, Review, Testing, Blocked, Done
- **Month**: Month 1, Month 2, Month 3, Month 4
- **Priority**: Critical, High, Medium, Low
- **Component**: Flutter, Backend, API Gateway, Auth, Social, Career, Chat,
  Finance, Map, Notification, User Profile, AI, Payment, Monitoring, DevOps,
  Documentation
- **Type**: Feature, Bug, Improvement, Testing, Documentation, DevOps, Monthly Report
- **Start Date** / **Target Date**

## Milestones

| Milestone | Deadline |
| --- | --- |
| Month 1 — Foundation | **June 30, 2026** |
| Month 2 — Core Features | No official deadline provided |
| Month 3 — Integration & Testing | No official deadline provided |
| Month 4 — Finalization & Submission | No official deadline provided |

No deadlines are invented for Months 2–4.

## Monthly reports

A report issue is maintained per month:

- `[REPORT] Month 1 Progress — June 2026`
- `[REPORT] Month 2 Progress`
- `[REPORT] Month 3 Progress`
- `[REPORT] Month 4 Progress`

Use [`monthly-report-template.md`](monthly-report-template.md) as the structure.
Reports must contain **verified evidence only** (linked issues, PRs, CI runs,
test results). No completion percentage is claimed unless it is evidence-based.

## Status definitions

| Status | Meaning |
| --- | --- |
| Backlog | Not started. |
| Ready | Scoped and ready to start. |
| In Progress | Actively being worked. |
| Review | Implementation done, under review. |
| Testing | Implemented, awaiting/undergoing testing. |
| Blocked | Cannot proceed (see `status:blocked`). |
| Done | Verified by code + tests/evidence. |

## Evidence policy

- "Implemented" is not the same as "tested"; "tested" is not the same as UAT.
- Only mark an item **Done** when code and testing evidence support it.
- Existing functionality already on `dev` is represented by Issues with
  evidence (code, tests, CI) rather than by fabricated branches or commits.
- Genuinely remaining work is done on real feature/fix/test/docs/chore branches
  and merged to `dev` through pull requests.
