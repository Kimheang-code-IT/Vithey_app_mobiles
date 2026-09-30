# Recommendations

> Status: Partially complete — prioritised for bank review · Last reviewed: 2026-09-30
> Evidence: `../_meta/EVIDENCE-BASIS.md`, `../11-testing/13-test-summary-report.md`, `../10-security/11-security-review-report.md`, `../11-testing/11-bug-report.md`, `Action_Plan_Vithey.csv`
> Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)

Recommendations are grouped by priority. Priority reflects risk to a bank-facing decision, not
implementation effort. Each maps to a tracked item or sibling document.

## 1. P0 — Required before any production decision

| # | Recommendation | Rationale | Evidence |
| --- | --- | --- | --- |
| P0-1 | Fix the career-service Flyway duplicate `V3` and `UserCv` identity mapping with **new** migrations | A fresh database migration/boot may fail | BUG-001, BUG-002 |
| P0-2 | Execute the full test suite on the current commit and record raw results | Quality is currently unproven | `../11-testing/12-test-results.md` |
| P0-3 | Commission a formal security assessment / penetration test | No assessment has occurred | `../10-security/11-security-review-report.md` |
| P0-4 | Validate network isolation of service ports (or add token checks at services) | Identity-header trust is only safe if ports are unreachable | VA-01 |
| P0-5 | Stand up a staging environment and re-run tests + E2E there | Production behaviour is unknown | `../_meta/EVIDENCE-BASIS.md` §9 |
| P0-6 | Configure real Android release signing | Release currently uses debug keys | BUG-008 |

## 2. P1 — Before UAT sign-off

| # | Recommendation | Rationale | Evidence |
| --- | --- | --- | --- |
| P1-1 | Prepare and execute UAT; obtain sign-off | Scope cannot be contractually confirmed otherwise | `../12-uat/` |
| P1-2 | Wire smoke ITs into CI (Failsafe) and run E2E smoke in CI | No automated full-stack gate today | BUG-005 |
| P1-3 | Add JaCoCo and establish a coverage baseline | Blind spots unknown | `../11-testing/13-test-summary-report.md` |
| P1-4 | Expand Flutter tests for auth/feed/CV critical paths | Coverage is ~3 files | Action_Plan 14.5 |
| P1-5 | Enforce TLS and restrict CORS before any exposure | Edge controls are missing/permissive | VA-03, VA-11 |
| P1-6 | Systematise authorization; single-source the public-path list | Method security exists only in finance | VA-04, VA-09 |

## 3. P2 — Hardening and completeness

| # | Recommendation | Rationale | Evidence |
| --- | --- | --- | --- |
| P2-1 | Add login throttling and session invalidation on credential change | No lockout/revocation today | VA-05, VA-06 |
| P2-2 | Add dependency/secret/image scanning and security-event logging | No supply-chain or audit controls | VA-16, VA-18 |
| P2-3 | Fix the user-profile trigram index and align enum/DB CHECK supersets | Search works only incidentally; state drift | BUG-003, BUG-007 |
| P2-4 | Implement or explicitly close the placeholder features (Google sign-in, FCM, 2FA, chat search) | Avoid ambiguous scope | Action_Plan 15.6 |
| P2-5 | Add map-service integration tests and a CI workflow | Only untested boot path | BUG-009 |
| P2-6 | Run performance/load testing at and beyond ~10 users | Capacity unknown | Action_Plan 14.8 |

## 4. P3 — Governance and sustainability

| # | Recommendation | Rationale |
| --- | --- | --- |
| P3-1 | Confirm contractual client, signatories, approved scope, and weighting | Enables an accurate completion statement |
| P3-2 | Complete source/environment handover and operations training | Action_Plan 21.1, 22.1 |
| P3-3 | Establish alerting (e.g. Alertmanager) for the monitoring stack | Alerts exist but are not delivered |
| P3-4 | Adopt a phase-gated "definition of done" (tests, UAT, assessment) | Prevent end-loaded assurance |
| P3-5 | Keep the WIP branch buildable / archive it deliberately | Blocks parallel contribution today |

## 5. Assessment of the current build

The delivered local demo is a strong, coherent engineering artefact and is suitable for
demonstration and internal evaluation. It is **not** suitable for production without the P0 and
P1 actions above. See [`10-project-progress.md`](10-project-progress.md) and
[`19-final-acceptance.md`](19-final-acceptance.md).

## 6. Related documents

- [`15-outstanding-items.md`](15-outstanding-items.md) · [`14-risks-issues.md`](14-risks-issues.md) · [`16-lessons-learned.md`](16-lessons-learned.md)
- [`../11-testing/13-test-summary-report.md`](../11-testing/13-test-summary-report.md) · [`../10-security/11-security-review-report.md`](../10-security/11-security-review-report.md)
