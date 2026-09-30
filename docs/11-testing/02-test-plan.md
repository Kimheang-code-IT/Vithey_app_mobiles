# Test Plan

> Status: Verified baseline (plan) · Last reviewed: 2026-09-30
> Evidence: `backend/TESTING.md`, `backend/**/src/test/java`, `vithey_app/test/`, `ai_core/tests/`, `backend/scripts/smoke-api.ps1`, `.github/workflows/`
> Related: [01-test-strategy.md](01-test-strategy.md)

## 1. Objectives

1. Verify each backend service's business logic (unit), Spring wiring (context), and
   boot+health (smoke).
2. Verify the Flutter app's pure logic/widgets that can be tested headlessly.
3. Verify ai_core's CV pipeline, chat stub, HTTP envelope, and rate limits.
4. Verify end-to-end gateway behaviour with `smoke-api.ps1`.
5. Produce honest, evidence-backed results — never a "Passed" without a run.

## 2. Scope

| In scope | Out of scope |
| --- | --- |
| Backend unit/context/smoke tests | Production (does not exist) |
| ai_core pytest suite | Load/performance testing (not performed) |
| Flutter unit/widget tests + `flutter analyze` | Flutter integration/golden tests (none) |
| `smoke-api.ps1` E2E on the local demo stack | Manual device/emulator UX regression (separate) |
| CI workflows as test gates | Third-party SDK internals |

## 3. Test items & environments

| Environment | Status | How tests run |
| --- | --- | --- |
| Local development | Local development (verified) | H2 for context; Testcontainers for smoke |
| Local demo stack | Local demo (verified) | `docker-up-demo.ps1` then `smoke-api.ps1` |
| CI (GitHub Actions) | Verified | `mvn test`, `flutter test`, `pytest` |
| Staging | Does not exist | — |
| Production | Does not exist | — |

## 4. Entry criteria

- Repository checked out on an integration branch with passing (or accepted) prior CI.
- Java 21 + Maven for backend; Flutter SDK + `.env` copied for the app; Python 3.10+ for ai_core.
- Docker Desktop running **only** if smoke ITs are to be executed.
- For `smoke-api.ps1`: the demo stack is up.

## 5. Exit criteria

- All non-Docker tests execute with no failures (or every failure is triaged and recorded in
  [11-bug-report.md](11-bug-report.md)).
- `flutter analyze --no-fatal-infos` reports zero errors.
- Smoke ITs either pass or their unrun status is explicitly recorded (Docker unavailable).
- E2E smoke summary recorded with the actual PASS/FAIL counts (never assumed).

> Current status: these criteria have **not** been evaluated in this task. See
> [13-test-summary-report.md](13-test-summary-report.md).

## 6. Test approach per layer

| Layer | Approach | Data | Tooling |
| --- | --- | --- | --- |
| Unit | Mock collaborators (Mockito); assert business rules | In-memory objects | JUnit 5, Mockito, AssertJ |
| Context | Load full Spring context on H2; assert beans + mappings | H2 schema | Spring Boot Test |
| Smoke IT | Boot service + containers; assert `/actuator/health` = UP | Testcontainers | Testcontainers |
| ai_core | Call services/routes with fakes; assert envelope | Fixtures | pytest, FastAPI TestClient |
| Flutter | Widget + pure-function tests | In-code fixtures | flutter_test |
| E2E | Scripted HTTP sequence through the gateway | Fresh random user | PowerShell `smoke-api.ps1` |

## 7. Schedule & effort (proposed)

| Phase | Activity | Owner (suggested) | Status |
| --- | --- | --- | --- |
| T0 | Author/maintain tests | per-service owners | Implemented (see inventory) |
| T1 | Run unit + context in CI | CI | Configured, execution result not independently verified |
| T2 | Run smoke ITs (Docker) | backend owner | Not run in CI |
| T3 | E2E `smoke-api.ps1` on demo | QA/lead | Not executed in this task |
| T4 | Performance/security testing | TBD — Requires confirmation. | Not performed |

## 8. Roles & responsibilities

Roles are inferred from git authorship and require confirmation. [INFERRED] — requires
business confirmation.

| Responsibility | Suggested owner | Status |
| --- | --- | --- |
| Backend test ownership | service authors | [INFERRED] |
| Flutter test ownership | Flutter authors | [INFERRED] |
| ai_core test ownership | ai_core author | [INFERRED] |
| Test/release sign-off | TBD — Requires confirmation. | [TBD] |

## 9. Deliverables

- This test plan, test cases ([03-test-cases.md](03-test-cases.md)), and per-layer guides.
- Execution results ([12-test-results.md](12-test-results.md)) when a run actually occurs.
- Defect log ([11-bug-report.md](11-bug-report.md)).
- Summary report ([13-test-summary-report.md](13-test-summary-report.md)).

## 10. Risks & mitigations

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Smoke ITs not run by `mvn test` | Low integration coverage in CI | Add Failsafe or document explicit invocation |
| No coverage tooling | Unknown blind spots | Add JaCoCo when time permits |
| Flutter coverage minimal (3 files) | Regressions in UI logic | Add widget tests for auth/feed/CV |
| No performance testing | Unknown capacity | Schedule load tests (currently `TBD`) |
| No security testing tooling | Unknown security posture | See `../10-security/10-vulnerability-assessment.md` |

## 11. Cross-references

- [01-test-strategy.md](01-test-strategy.md) · [03-test-cases.md](03-test-cases.md) · [12-test-results.md](12-test-results.md)
- `../../backend/TESTING.md`
