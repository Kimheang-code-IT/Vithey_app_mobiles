# UAT Issues

> Status: **No UAT executed** · Last reviewed: 2026-09-30
> Evidence: none — no UAT session has occurred
> **UAT has not yet been formally executed / evidence was not found.**

## 1. Issue log

No UAT issues have been raised because **no UAT session has been run**. The log is therefore
empty; the table below is the template to populate during a future session.

| Issue ID | Related case | Title | Severity | Component | Description | Status | Owner |
| --- | --- | --- | --- | --- | --- | --- | --- |
| — | — | *(none — UAT not executed)* | — | — | — | — | — |

> Do **not** pre-fill discovered issues here. Pre-existing repository defects are tracked in
> `../11-testing/11-bug-report.md` (BUG-001…010) and are not UAT observations.

## 2. Severity definitions

| Severity | Meaning | Example |
| --- | --- | --- |
| Blocker | Cannot proceed / data loss / security | Login broken; tokens exposed |
| High | Major function broken | Cannot apply to a job |
| Medium | Function works with significant friction | CV draft drops a field |
| Low | Cosmetic/minor | Alignment, wording |

## 3. Triage process (proposed)

1. Tester logs the issue with a case ID, screenshot, and `X-Request-ID`.
2. UAT coordinator assigns severity and owner.
3. Owner fixes; tester retests the exact case.
4. Close when retest passes; otherwise reopen.

## 4. Relationship to other defect logs

| Log | Scope | Status |
| --- | --- | --- |
| [04-UAT-issues.md](04-UAT-issues.md) (this file) | Issues found during UAT | Empty — UAT not executed |
| `../11-testing/11-bug-report.md` | Repository-evidenced defects | BUG-001…010 open |
| `../10-security/10-vulnerability-assessment.md` | Code-level security observations | **Not yet formally assessed** |

## 5. Status

**UAT has not yet been formally executed / evidence was not found.** No issue to report.

## 6. Cross-references

- [02-UAT-test-cases.md](02-UAT-test-cases.md) · [03-UAT-results.md](03-UAT-results.md) · [05-UAT-signoff.md](05-UAT-signoff.md)
- [../11-testing/11-bug-report.md](../11-testing/11-bug-report.md)
