# Testing Results

> Status: **Not executed** · Last reviewed: 2026-09-30
> Evidence: test inventory only — `backend/**/src/test/java`, `vithey_app/test/`, `ai_core/tests/`
> Result phrase used throughout: `Test implemented — current execution result not independently verified.`
> Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · Detailed sibling: [`../11-testing/12-test-results.md`](../11-testing/12-test-results.md)

## 1. Headline

Vithey has an established, layered automated-test skeleton. **However, no test was executed for
this report, so no pass/fail statement can be made.** A test file existing is not evidence of a
passing run.

## 2. What exists (inventory)

| Tier | Test artifacts | Execution |
| --- | --- | --- |
| Backend unit tests (`*Test`) | 19 files | Not executed — `Test implemented — current execution result not independently verified.` |
| Backend context tests (`*ContextTest`, H2) | 11 files | Not executed — `Test implemented — current execution result not independently verified.` |
| Backend smoke tests (`*SmokeIT`, Testcontainers) | 11 files | Not executed; not wired into `mvn test`/CI |
| **Backend total** | **41 files** | Not executed |
| Flutter tests | 3 files | Not executed — `Test implemented — current execution result not independently verified.` |
| `ai_core` pytest files | 11 files | Not executed — `Test implemented — current execution result not independently verified.` |
| End-to-end API smoke (`smoke-api.ps1`) | 1 manual script | Not executed |
| Coverage measurement | Not configured (no JaCoCo) | Not measured |

[VERIFIED] `../11-testing/13-test-summary-report.md`, `../11-testing/12-test-results.md`

## 3. Test layers described by the project

| Layer | Purpose | Notes |
| --- | --- | --- |
| Unit | Business logic with mocks | Per service |
| Context | Spring bean wiring under H2 | All services except map-service |
| Smoke (IT) | Full stack with Flyway + Testcontainers | Docker-gated; only map-service lacks one |
| End-to-end API smoke | Health + auth + AI + RBAC (`/fees` 403→200) | Manual PowerShell script |
| Flutter | Widget + notification utilities | Thin coverage |
| ai_core | API, CLI, extraction, generation, normalize, quality, dedupe, rate limit | pytest |

## 4. Test-execution gap

- Plain `mvn test` runs the 30 unit + context tests and **skips** the 11 smoke ITs (no Failsafe).
- CI runs the non-Docker backend tests, `flutter analyze` + `flutter test`, and `pytest`, but the
  smoke ITs and E2E smoke script are not part of CI. [VERIFIED] `../11-testing/13-test-summary-report.md`
- The E2E smoke script needs a running stack and was not executed here.

## 5. Known test-coverage gaps

| Gap | Impact |
| --- | --- |
| Smoke ITs excluded from `mvn test`/CI | No automated full-stack boot test |
| Flutter coverage ~3 files | UI regressions undetected |
| No coverage tooling | Blind spots unknown |
| map-service has no context/smoke/CI gate | Untested wiring/boot |
| No performance testing | Capacity unknown |
| No security testing | Security posture unknown |

## 6. What is required to declare a result

A future run must record: date/time, operator, git commit SHA, branch; exact command(s) and
working directory; raw outputs (surefire reports, pytest output, smoke table); and environment
details. Results are then recorded in [`../11-testing/12-test-results.md`](../11-testing/12-test-results.md).

## 7. Conclusion

- **Tests implemented, not executed. No pass/fail claim is made.**
- Test execution status is **unknown** as of this report.

## 8. Related documents

- [`14-risks-issues.md`](14-risks-issues.md) · [`15-outstanding-items.md`](15-outstanding-items.md) · [`17-recommendations.md`](17-recommendations.md)
- [`../11-testing/13-test-summary-report.md`](../11-testing/13-test-summary-report.md) · [`../12-uat/03-UAT-results.md`](../12-uat/03-UAT-results.md)
