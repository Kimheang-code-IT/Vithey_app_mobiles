# Bug Report / Defect Log

> Status: Requires confirmation · Last reviewed: 2026-09-30
> Evidence: `../_meta/EVIDENCE-BASIS.md` §8, `backend/**`, `vithey_app/**`, `ai_core/**`
> **No testing was executed during this documentation task**, so no defect below was found by a test run. Items are repository-evidenced defects recorded for tracking.

## 1. Defect log

| ID | Title | Severity | Component | Evidence | Status |
| --- | --- | --- | --- | --- | --- |
| BUG-001 | Duplicate Flyway version `V3` in career-service | High | career-service | `db/migration/V3__Job_application_composite_indexes_and_status_check.sql` + `V3__User_cv_file_unique_and_application_fk.sql` | Open — not fixed |
| BUG-002 | `UserCv` entity `@Id` maps `user_id` while DB PK is `id` | High | career-service | career entity vs `V1` migration | Open — not fixed |
| BUG-003 | user-profile trigram GIN index not created (no-op migration) | Medium | user-profile-service | `V3__Enable_pg_trgm_and_full_name_gin_index.sql` | Open — not fixed |
| BUG-004 | `cv_app_service.to_draft` field mismatch drops CV fields in Flutter draft (`items` vs `skills`, `summary` vs `bullets`) | Medium | ai_core | EVIDENCE-BASIS §6 | Open — not fixed |
| BUG-005 | Smoke ITs never run by `mvn test`/CI (no Failsafe) | Medium | backend/CI | EVIDENCE-BASIS §8; `.github/workflows` | Open — process gap |
| BUG-006 | `/api/v1/students/verify` requires a JWT despite being registration-like (public-path discrepancy) | Low | api-gateway | `PublicPathMatcher.java`, `api-gateway.yml` | Open — documented |
| BUG-007 | Enum vs DB CHECK supersets allow DB states entities cannot represent | Low–Medium | career/content/chat/finance/notification | EVIDENCE-BASIS §8 | Open |
| BUG-008 | Android release build signs with debug keys | Medium | vithey_app | `android/app/build.gradle` TODO | Open |
| BUG-009 | map-service has no CI workflow, context, or smoke test | Low | map-service / CI | `.github/workflows`, `src/test` | Open |
| BUG-010 | EVIDENCE-BASIS §10 test counts were stale (40 Java / 12 pytest) vs verified (41 / 11) | Low | docs | EVIDENCE-BASIS §10 vs `src/test` | Resolved — anchor corrected 2026-09-30 |

> BUG-001…004, 007 are pre-existing repository defects documented in EVIDENCE-BASIS §8 and are
> **not** the result of test execution. They are repeated here for traceability.

## 2. Report template (for future test runs)

Use one row per defect. Severity = Impact × Likelihood (Blocker/High/Medium/Low).

| Field | Description |
| --- | --- |
| ID | `BUG-NNN` |
| Title | Short summary |
| Severity / Priority | Blocker/High/Medium/Low |
| Environment | e.g. local demo, commit sha, host |
| Component / endpoint | Path or class |
| Preconditions | Tokens, roles, data |
| Steps to reproduce | Numbered, exact |
| Expected | |
| Actual | |
| Evidence | Logs, request-id, screenshots (redact secrets/tokens) |
| Owner / Status | |

## 3. Triage rules

- **Security defects** are cross-linked to `../10-security/10-vulnerability-assessment.md` (only
  code-level so far — **Not yet formally assessed**) and are not filed there.
- **Data-integrity defects** (BUG-001…003, 007) must be fixed with a new migration, never by
  editing an applied migration (Flyway checksum). [VERIFIED] AGENTS.md.
- Never paste real tokens, passwords, or `.env` values into a defect record.

## 4. Status

No defect has been confirmed by running a test. All entries are repository-evidenced.
Defect-verification outcome: `Test implemented — current execution result not independently verified.`

## 5. Cross-references

- [12-test-results.md](12-test-results.md) · [13-test-summary-report.md](13-test-summary-report.md)
- `../_meta/EVIDENCE-BASIS.md` §8 · `../10-security/10-vulnerability-assessment.md`
