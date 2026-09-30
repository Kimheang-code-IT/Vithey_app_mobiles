# Outstanding Items

> Status: Requires confirmation · Last reviewed: 2026-09-30
> Evidence: `Action_Plan_Vithey.csv` (non-completed rows), `../11-testing/11-bug-report.md`, `../_meta/EVIDENCE-BASIS.md`, `api_docs.md`
> Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)

This is the consolidated list of what remains. Items are grouped by nature and each is tagged.
Where a resolution requires a decision, it is marked `TBD — Requires confirmation.`

## 1. Assurance and governance (highest priority)

| Item | Tag | Basis |
| --- | --- | --- |
| Formal security assessment / penetration test not performed | [TBD] | `../10-security/11-security-review-report.md` |
| User Acceptance Testing not executed | [TBD] | `../12-uat/03-UAT-results.md` |
| UAT sign-off not obtained | [TBD] | `../12-uat/05-UAT-signoff.md` |
| Formal project acceptance not obtained | [TBD] | `Action_Plan_Vithey.csv` 23.1 |
| No staging environment | [TBD] | `../_meta/EVIDENCE-BASIS.md` §9 |
| No production deployment | [TBD] | `Action_Plan_Vithey.csv` 17.5 |

## 2. Confirmed defects to fix

| Item | Severity | Tag | Basis |
| --- | --- | --- | --- |
| Duplicate Flyway `V3` (career-service) | High | [VERIFIED] | BUG-001 |
| `UserCv` entity `@Id` vs DB PK mismatch | High | [VERIFIED] | BUG-002 |
| user-profile trigram GIN index no-op | Medium | [VERIFIED] | BUG-003 |
| `cv_app_service.to_draft` drops CV fields | Medium | [VERIFIED] | BUG-004 |
| Smoke ITs excluded from `mvn test`/CI | Medium | [VERIFIED] | BUG-005 |
| `PATCH /posts/{id}` missing (`404` in client) | Medium | [VERIFIED] | `api_docs.md` §15 |
| Android release signs with debug keys | Medium | [VERIFIED] | BUG-008 |
| Enum/DB CHECK supersets in 5 services | Low–Medium | [VERIFIED] | BUG-007 |
| `/api/v1/students/verify` public-path inconsistency | Low | [VERIFIED] | BUG-006 |
| map-service lacks context/smoke/CI test | Low | [VERIFIED] | BUG-009 |

## 3. Testing gaps

| Item | Tag | Basis |
| --- | --- | --- |
| Full test suite not executed on the current commit | [TBD] | `../11-testing/12-test-results.md` |
| Flutter test coverage thin (~3 files) | [VERIFIED] | Action_Plan 14.5 |
| No coverage tooling (JaCoCo) | [VERIFIED] | `../11-testing/13-test-summary-report.md` |
| E2E smoke script not wired into CI | [VERIFIED] | `../11-testing/13-test-summary-report.md` |
| No performance/load testing | [VERIFIED] | `../11-testing/13-test-summary-report.md` |
| No security testing/scanning | [VERIFIED] | `../10-security/11-security-review-report.md` |

## 4. Feature items not implemented (agreed-scope-adjacent)

| Item | Tag | Basis |
| --- | --- | --- |
| Google sign-in | [PLANNED] | UI stub only; Action_Plan 9.15 |
| Push notifications (FCM) | [PLANNED] | No Firebase; Action_Plan 9.14 |
| Two-factor / biometric login | [PLANNED] | "coming soon"; Action_Plan 11.5 |
| Admin reporting / analytics module | [PLANNED] | Action_Plan 13.4 |
| Demo seed data script | [PLANNED] | Action_Plan 4.11 |
| Khmer-language UI | [PLANNED] | Preference only; EVIDENCE-BASIS §7 |

## 5. Documentation and housekeeping

| Item | Tag | Basis |
| --- | --- | --- |
| Correct stale docs (mock flags; retired ai-service refs) | [VERIFIED open] | Action_Plan 15.4 |
| Align map-service compose gating with docs | [VERIFIED open] | Action_Plan 15.3 |
| Update EVIDENCE-BASIS test counts (41 / 11) | [VERIFIED open] | BUG-010 |
| Recover non-compiling WIP branch (`stale WIP`) | [VERIFIED blocked] | Action_Plan 15.5 |

## 6. Handover and closure (not started)

| Item | Tag | Basis |
| --- | --- | --- |
| Developer onboarding / knowledge transfer | [TBD] | Action_Plan 21.1 |
| Operations runbook training | [TBD] | Action_Plan 21.2 |
| Source code and environment handover | [TBD] | Action_Plan 22.1 |
| Bank reporting pack completion | In progress | Action_Plan 22.2 |
| Final acceptance | [TBD] | Action_Plan 23.1 |
| Project closure report | [TBD] | Action_Plan 23.2 |

## 7. Information still required (TBD)

- Contractual client/legal entity and signatories. [TBD] `TBD — Requires confirmation.`
- Approved scope baseline and deliverable weighting. [TBD] `TBD — Requires confirmation.`
- Bank hosting environment and data-residency/regulatory requirements. [TBD] `TBD — Requires confirmation.`
- Named security reviewer and UAT owner. [TBD] `TBD — Requires confirmation.`

## 8. Related documents

- [`14-risks-issues.md`](14-risks-issues.md) · [`17-recommendations.md`](17-recommendations.md) · [`19-final-acceptance.md`](19-final-acceptance.md)
- [`../11-testing/11-bug-report.md`](../11-testing/11-bug-report.md) · `../Action_Plan_Vithey.csv`
