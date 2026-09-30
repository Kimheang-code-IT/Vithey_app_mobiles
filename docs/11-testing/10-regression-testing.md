# Regression Testing

> Status: Verified baseline (plan) · Last reviewed: 2026-09-30
> Evidence: `.github/workflows/ci-promote-dev.yml`, `.github/workflows/*-service-ci.yml`, `backend/scripts/smoke-api.ps1`, `backend/**/src/test/java`
> Result status: `Test implemented — current execution result not independently verified.`

## 1. What "regression" means here

Any change to a shared module, config, or contract that can break an already-working feature.
The main automated regression nets are CI (backend + Flutter + ai_core) and the E2E smoke
script. Both exist; neither was run during this documentation task.

## 2. Automated regression nets (as configured)

| Net | Trigger | Coverage | Evidence |
| --- | --- | --- | --- |
| Full-stack CI | push to `kimheang`/`main`; PR to `kimheang`/`main`/`dev` | backend `mvn test`, `flutter analyze`+`test`, `pytest -q` | `ci-promote-dev.yml` |
| Per-service CI (9) | path-filtered push/PR | `mvn -pl services/<svc> -am test` | `*-service-ci.yml` |
| Image build + compose validate | CI | Docker build, `docker compose config` | per-service workflows |
| E2E API smoke | **manual** | gateway contract | `smoke-api.ps1` |
| Live health sweep | **manual** | all services UP | `check-service-health.ps1` |

## 3. Regression risk areas

| Area | Why risky | Existing net |
| --- | --- | --- |
| Gateway public-path / JWT filter | Every request depends on it | `JwtValidatorTest`, smoke script |
| Auth token lifecycle | Refresh rotation, logout revocation | `JwtProviderTest`, `AuthService*Test`, `PasswordResetServiceTest` |
| Shared `vithey-test-support` / config-repo | One change affects many services | context + (manual) smoke ITs |
| Service contracts (Feign) | inter-service drift | none |
| Flutter↔gateway contract | app breaks silently | `smoke-api.ps1` only |
| ai_core envelope `{data,meta,error}` | Flutter depends on shape | `test_flutter_routes.py` |
| Flyway migrations | destructive / checksum mismatch | none automated |

## 4. Regression suite tiers

| Tier | Run when | Duration (expected) | Scope |
| --- | --- | --- | --- |
| R1 | every PR | fast | unit + context (`mvn test -Dtest='!*SmokeIT'`), `flutter test`, `pytest` |
| R2 | pre-merge to `main` | medium | R1 + `smoke-api.ps1` on demo stack |
| R3 | release candidate | long | R2 + smoke ITs (Docker) + manual device sweep |
| R4 | post-deploy | n/a | **no target environment exists** |

## 5. Known regression gaps

| Gap | Impact |
| --- | --- |
| Smoke ITs not in CI | Boot/Flyway regressions not caught |
| E2E smoke is manual | Contract drift not caught automatically |
| map-service has no CI workflow | map changes bypass the per-service gate |
| No contract tests | Cross-service field drift |
| No coverage baseline | Cannot quantify regression surface |
| Career `V3` duplicate Flyway version | Migration failure risk (see EVIDENCE-BASIS §8) |

## 6. Recommended regression additions

1. Add Failsafe (or rename to `*IT` with Failsafe) so smoke ITs run in CI.
2. Run `smoke-api.ps1` as a CI job against a compose-up stack.
3. Add a contract/schema diff check between `api_docs.md` and DTOs.
4. Add a Flyway `validate`/migration-equivalence check to catch duplicate versions.

## 7. Result status

No regression suite was executed during this documentation task.
`Test implemented — current execution result not independently verified.`

## 8. Cross-references

- [02-test-plan.md](02-test-plan.md) · [12-test-results.md](12-test-results.md) · [13-test-summary-report.md](13-test-summary-report.md)
- `../../backend/TESTING.md` · `../_meta/EVIDENCE-BASIS.md` §8
