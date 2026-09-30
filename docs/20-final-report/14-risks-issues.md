# Risks & Issues

> Status: Requires confirmation · Last reviewed: 2026-09-30
> Evidence: `Action_Plan_Vithey.csv`, `../11-testing/11-bug-report.md`, `../10-security/11-security-review-report.md`, `plan.md` §10, `../_meta/EVIDENCE-BASIS.md`
> Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)

## 1. Open issues (repository-evidenced)

These are confirmed by repository evidence. **None was found by a test run** — no test was
executed for this report.

| ID | Issue | Severity | Component | Status |
| --- | --- | --- | --- | --- |
| BUG-001 | Duplicate Flyway version `V3` in career-service | High | career-service | Open |
| BUG-002 | `UserCv` entity `@Id` maps `user_id` while DB PK is `id` | High | career-service | Open |
| BUG-003 | user-profile trigram GIN index is a no-op migration | Medium | user-profile-service | Open |
| BUG-004 | `cv_app_service.to_draft` field mismatch drops CV fields | Medium | ai_core | Open |
| BUG-005 | Smoke ITs never run by `mvn test`/CI (no Failsafe) | Medium | backend/CI | Open |
| BUG-006 | `/api/v1/students/verify` requires a JWT (public-path discrepancy) | Low | api-gateway | Open |
| BUG-007 | Enum vs DB CHECK supersets allow states entities cannot represent | Low–Medium | 5 services | Open |
| BUG-008 | Android release build signs with debug keys | Medium | vithey_app | Open |
| BUG-009 | map-service has no CI workflow, context, or smoke test | Low | map-service / CI | Open |
| BUG-010 | Documentation test counts drift from a verified recount (41 / 11) | Low | docs | Open |

[VERIFIED] `../11-testing/11-bug-report.md`

> BUG-001, BUG-002, BUG-003, BUG-007 are data-integrity defects that must be fixed with a **new**
> migration, never by editing an applied migration (Flyway checksum). [VERIFIED] `AGENTS.md`

## 2. Delivery and governance risks

| # | Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- | --- |
| R-01 | No UAT or formal acceptance, so the delivered scope cannot be contractually confirmed | High | High | Execute UAT; obtain sign-off (see [`19-final-acceptance.md`](19-final-acceptance.md)) |
| R-02 | No security assessment; production exposure could introduce unacceptable risk | High | High | Commission assessment before any exposure |
| R-03 | No staging/production; behaviour under real load/hosting is unknown | High | High | Stand up staging and run the suite + E2E there |
| R-04 | Database defects may break a fresh migration/boot | Medium | High | Fix BUG-001…003 with new migrations |
| R-05 | Tests exist but are unexecuted, so quality is unproven | High | Medium | Execute the full suite and record results |
| R-06 | Thin Flutter test coverage | High | Medium | Expand tests for auth/feed/CV paths |
| R-07 | Demo built for ~10 local users; capacity beyond that is unknown | Medium | Medium | Performance testing before any scale-up |
| R-08 | LLM cost/latency/key dependency for CV generation | Medium | Medium | Existing caps/caching; monitor usage; document fallback |
| R-09 | Debug-signed Android release blocks distribution | High | Medium | Configure real release signing |
| R-10 | Stale documentation (mock flags, retired ai-service references) can mislead | Medium | Low | Complete documentation corrections |

[INFERRED] Risk ratings are provisional and require business confirmation.

## 3. Recurring architectural risk

Service ports trust identity headers injected by the gateway and are only safe if never directly
reachable. This is the highest-leverage item to validate before any network exposure. [VERIFIED]
`../10-security/11-security-review-report.md` §4

## 4. Closed / non-risks (for completeness)

| Item | Reason |
| --- | --- |
| GDCE/RAG availability | Deliberately out of scope; assistant is a stub. [VERIFIED] |
| Kubernetes/autoscaling | Not in demo scope; no orchestration required locally. [VERIFIED] |
| Local GPU LLM | Not used; cloud API key only. [VERIFIED] |

## 5. Open questions

- Which risks the bank formally accepts, and under what conditions. [TBD] `TBD — Requires confirmation.`
- Target environment and any regulatory/data-residency constraints. [TBD] `TBD — Requires confirmation.`

## 6. Related documents

- [`15-outstanding-items.md`](15-outstanding-items.md) · [`11-testing-results.md`](11-testing-results.md) · [`12-security-summary.md`](12-security-summary.md)
- [`../11-testing/11-bug-report.md`](../11-testing/11-bug-report.md) · `../../plan.md` §10
