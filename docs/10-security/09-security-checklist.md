# Security Checklist

> Status: Verified baseline (code-level) · Last reviewed: 2026-09-30
> Evidence: `backend/`, `ai_core/`, `vithey_app/`, `monitoring/`, `.github/workflows/`
> How to read: `[x]` = implemented in code (evidence cited); `[ ]` = not implemented / not verified; `[N/A]` = not applicable to the current demo scope.
> Governance: **Not yet formally assessed.** This checklist is a self-review aid, not an audit.

## A. Authentication

| # | Item | State | Evidence |
| --- | --- | --- | --- |
| A1 | Passwords hashed with bcrypt | [x] | `PasswordEncoderConfig.java` |
| A2 | Access tokens short-lived (15m) | [x] | `application.yml` |
| A3 | Refresh tokens opaque, hashed at rest, rotated | [x] | `TokenService.java`, `TokenHash.java` |
| A4 | Reset/verify tokens hashed, single-use, expiring | [x] | `PasswordResetService.java`, `AuthService.java` |
| A5 | Account lockout / login throttling | [ ] | Only gateway rate limit |
| A6 | Multi-factor authentication | [ ] | 2FA is a "coming soon" UI stub |
| A7 | Password reset invalidates existing sessions | [ ] | Not implemented |
| A8 | Refresh replay detection beyond revocation | [ ] | Rotation only |

## B. Authorization

| # | Item | State | Evidence |
| --- | --- | --- | --- |
| B1 | Every `/api/v1/**` route requires a JWT | [x] | `JwtAuthenticationGlobalFilter.java` |
| B2 | Services enforce `authenticated` | [x] | every `SecurityConfig.java` |
| B3 | Role-based checks (`@PreAuthorize`) beyond finance | [ ] | only 2 files |
| B4 | Ownership checks for files (CV owner-only on download/delete) | [x] | `FileController.java` |
| B5 | `ADMIN` has a defined, enforced surface | [ ] | role exists; no admin API |
| B6 | Public-path list is single-sourced | [ ] | duplicated / drift risk (A4 §7-api) |

## C. Token / JWT

| # | Item | State | Evidence |
| --- | --- | --- | --- |
| C1 | HMAC signature verified at gateway and services | [x] | `JwtValidator`, service filters, `auth.py` |
| C2 | `exp` enforced | [x] | JJWT `parseSignedClaims` |
| C3 | No default secret in production config | [x] | `application-prod.yml` |
| C4 | `iss`/`aud` claims | [ ] | not set |
| C5 | Access-token revocation / denylist | [ ] | not implemented |
| C6 | Key rotation / `kid` | [ ] | single static secret |
| C7 | ai_core rejects when secret unset | [x] (401) but default secret exists | `auth.py`, `config.py` |

## D. Transport & API edge

| # | Item | State | Evidence |
| --- | --- | --- | --- |
| D1 | Rate limiting on HTTP routes | [x] | `api-gateway.yml` |
| D2 | Rate limiting on websocket route | [ ] | no limiter on `/ws/**` |
| D3 | CORS restricted to known origins | [ ] | default `*` (creds off) |
| D4 | TLS terminated at an edge | [ ] | no env exists |
| D5 | Request-id correlation | [x] | `RequestIdGlobalFilter` |
| D6 | Body-size cap on AI service | [x] | `middleware.py` (512 KB) |
| D7 | Input validation on request DTOs | [x] | `jakarta.validation` `@Valid` |
| D8 | File MIME allow-list + name sanitisation | [x] | `FileValidationService.java` |

## E. Data

| # | Item | State | Evidence |
| --- | --- | --- | --- |
| E1 | Password/token material not stored raw | [x] | migrations, `TokenHash` |
| E2 | One DB per service | [x] | `init-databases.sql` |
| E3 | PII encrypted at rest | [ ] | plaintext columns |
| E4 | DB/MinIO encrypted at rest | [ ] | no evidence |
| E5 | Soft delete for users | [x] | `V1/V2` migrations |
| E6 | Retention / erasure policy | [ ] | no evidence |
| E7 | Device tokens in secure storage | [x] | `secure_storage_service.dart` |

## F. Secrets & supply chain

| # | Item | State | Evidence |
| --- | --- | --- | --- |
| F1 | `.env` never committed | [x] | `.gitignore`, `git ls-files` |
| F2 | `.env.example` templates tracked | [x] | repo |
| F3 | Secrets provided via env only | [x] | `config-repo/application*.yml` |
| F4 | Secret manager / vault | [ ] | none |
| F5 | Secret rotation runbook | [ ] | none |
| F6 | Secret-scanning in CI | [ ] | none |
| F7 | Dependency vulnerability scanning (OSV/Dependabot) | [ ] | not configured in `.github/workflows` |
| F8 | Release builds signed with a real key | [ ] | Android release signs with **debug keys** (`android/app/build.gradle` TODO) |

## G. Observability & response

| # | Item | State | Evidence |
| --- | --- | --- | --- |
| G1 | Health endpoints | [x] | `/actuator/health`, `/health` |
| G2 | Prometheus metrics (demo profile) | [x] | `application.yml`; prod hides them |
| G3 | Alert routing (Alertmanager) | [ ] | no Alertmanager |
| G4 | Security event logging / audit trail | [ ] | no dedicated security log |
| G5 | Incident-response plan | [ ] | no evidence |

## H. Sign-off

| Role | Name | Date | Signature |
| --- | --- | --- | --- |
| Security reviewer | TBD — Requires confirmation. | | |
| Engineering lead | TBD — Requires confirmation. | | |
| Product owner | TBD — Requires confirmation. | | |

> No signature has been collected. **Not yet formally assessed.**

## Cross-references

- [10-vulnerability-assessment.md](10-vulnerability-assessment.md) · [11-security-review-report.md](11-security-review-report.md)
- Testing counterparts: `../11-testing/09-security-testing.md`, `../11-testing/13-test-summary-report.md`
