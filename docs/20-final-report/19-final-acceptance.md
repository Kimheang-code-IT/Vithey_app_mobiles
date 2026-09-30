# Final Acceptance Certificate (Template)

> Status: **Template — not executed, no acceptance granted** · Last reviewed: 2026-09-30
> Evidence: none — no acceptance event has occurred; blank fields in `plan.md` §14
> Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)

> **This is a blank acceptance template.** No acceptance has been granted, decided, or implied.
> Every field that cannot be evidenced is left blank or marked `TBD — Requires confirmation.`
> Do **not** cite this document as approval. Filling it in requires a real UAT run
> ([`../12-uat/03-UAT-results.md`](../12-uat/03-UAT-results.md)) and the signatories below.

## 1. Project identification

| Field | Entry |
| --- | --- |
| Project / product name | Vithey (student superapp) |
| Customer / client | `TBD — Requires confirmation.` |
| Customer legal entity / address | `TBD — Requires confirmation.` |
| Supplier / delivery team | `TBD — Requires confirmation.` (team members inferred from git history; see [`05-project-team.md`](05-project-team.md)) |
| Governing agreement / competition | ACLEDA Bank App Competition 2026 (context only) [VERIFIED] |
| Repository / version under review | `TBD — Requires confirmation.` (branch and commit SHA) |
| Delivery target | Local demo ("Profile M") — see [`04-project-scope.md`](04-project-scope.md) |

## 2. Delivered scope proposed for acceptance

The following is a **proposed** list drawn from repository evidence. It is not accepted until the
signatures below are completed.

| # | Deliverable | Status (evidence) | Accepted? |
| --- | --- | --- | --- |
| D-01 | Flutter mobile application (10 modules) | Implemented [VERIFIED] | ☐ |
| D-02 | API gateway + 9 domain services + Eureka + Config | Implemented [VERIFIED] | ☐ |
| D-03 | Real AI CV generation (`POST /ai/cv/generate`) | Implemented [VERIFIED] | ☐ |
| D-04 | AI assistant chat | Stub/Placeholder [VERIFIED] | ☐ |
| D-05 | Peer chat (REST + realtime WebSocket) | Implemented [VERIFIED] | ☐ |
| D-06 | Student finance (read-only, `STUDENT`-gated) | Implemented [VERIFIED] | ☐ |
| D-07 | Notifications inbox (in-app) | Implemented [VERIFIED] | ☐ |
| D-08 | Map / nearby places (opt-in) | Implemented [VERIFIED] | ☐ |
| D-09 | Local demo Compose + scripts | Implemented [VERIFIED] | ☐ |
| D-10 | CI pipelines + monitoring stack | Implemented [VERIFIED] | ☐ |
| D-11 | Documentation package | Implemented [VERIFIED] | ☐ |

## 3. Items explicitly not delivered (proposed exclusions)

| Item | Reason |
| --- | --- |
| Google sign-in | Stub only [VERIFIED] |
| Push notifications (FCM) | No Firebase integrated [VERIFIED] |
| Two-factor / biometric login | Not started [VERIFIED] |
| Production deployment | Does not exist [VERIFIED] |
| Security assessment / penetration test | Not performed [VERIFIED] |
| UAT execution | Not performed [VERIFIED] |

## 4. Outstanding items affecting acceptance

| Item | Severity | Reference |
| --- | --- | --- |
| Duplicate Flyway `V3` (career-service) | High | BUG-001 |
| `UserCv` identity mapping mismatch | High | BUG-002 |
| `PATCH /posts/{id}` missing | Medium | `api_docs.md` §15 |
| Full test suite not executed | High | [`11-testing-results.md`](11-testing-results.md) |
| Security assessment not performed | High | [`12-security-summary.md`](12-security-summary.md) |
| UAT not executed / no sign-off | High | [`../12-uat/05-UAT-signoff.md`](../12-uat/05-UAT-signoff.md) |

Full list: [`15-outstanding-items.md`](15-outstanding-items.md).

## 5. Acceptance decision

| Decision | State |
| --- | --- |
| Accepted | ☐ not selected |
| Accepted with conditions | ☐ not selected |
| Rejected | ☐ not selected |
| **Undecided — no acceptance event has occurred** | ☐ (current state) |

## 6. Conditions of acceptance

`TBD — Requires confirmation.` (To be defined by the customer once UAT results exist. None apply
today.)

## 7. Representations to be confirmed before signing

- [ ] UAT executed and results recorded.
- [ ] Defects triaged; all blocker/high defects resolved or formally waived.
- [ ] Security assessment completed and residual risks accepted.
- [ ] Contractual scope and weighting confirmed.
- [ ] Delivered scope table (§2) agreed and marked.

## 8. Acceptance date

| Field | Entry |
| --- | --- |
| Acceptance date | `TBD — Requires confirmation.` |

## 9. Signatures

| Role | Name | Organisation | Date | Signature |
| --- | --- | --- | --- | --- |
| Customer representative | | | | |
| Customer / product owner | | | | |
| Supplier / project representative | | | | |
| Technical lead | | | | |
| Witness (optional) | | | | |

> All names, dates, and signatures are intentionally blank. **No approval, explicit or implied,
> exists.** Signatories are `TBD — Requires confirmation.`

## 10. Related documents

- [`04-project-scope.md`](04-project-scope.md) · [`10-project-progress.md`](10-project-progress.md) · [`15-outstanding-items.md`](15-outstanding-items.md)
- [`../12-uat/05-UAT-signoff.md`](../12-uat/05-UAT-signoff.md) · `../../plan.md` §14
