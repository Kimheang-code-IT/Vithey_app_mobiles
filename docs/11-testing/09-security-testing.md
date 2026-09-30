# Security Testing

> Status: **Not performed** (no dedicated suite) · Last reviewed: 2026-09-30
> Evidence: `backend/**/src/test/java` (JWT unit tests), `ai_core/tests/test_flutter_routes.py` (auth paths), `backend/scripts/smoke-api.ps1` (RBAC 403 step); no DAST/SAST config found
> Related: `../10-security/10-vulnerability-assessment.md`, `../10-security/11-security-review-report.md`

## 1. Status

**No dedicated security testing has been performed.** There is no SAST, DAST, dependency,
secret, or container scanning configured in `.github/workflows/`. No penetration test exists.
The items below describe what *incidental* security coverage exists in functional tests, plus
a **proposed** security test plan that has not been executed.

## 2. Incidental coverage that exists

| Area | What exists | Evidence |
| --- | --- | --- |
| JWT create/parse | `JwtProviderTest` asserts claims/expiry | `auth-service` |
| JWT validation | `JwtValidatorTest` asserts subject/email/roles | `api-gateway` |
| ai_core auth | `test_flutter_routes.py` exercises gateway-header and JWT paths | `ai_core/tests` |
| RBAC (STUDENT) | `smoke-api.ps1` asserts `GET /fees` → **403**, then 200 after verification | `smoke-api.ps1` |
| File validation | `FileValidationServiceTest` covers MIME/size/traversal | `file-service` |

> These are functional tests that touch security-adjacent code; they are **not** a security
> test suite. `Test implemented — current execution result not independently verified.`

## 3. Security test plan (proposed — none executed)

### 3.1 Authentication

| ID | Test | Expected | Status |
| --- | --- | --- | --- |
| ST-A1 | Request protected endpoint with no token | 401 | Not performed |
| ST-A2 | Tampered JWT signature | 401 | Not performed |
| ST-A3 | Expired JWT | 401 | Not performed |
| ST-A4 | JWT signed with wrong secret | 401 | Not performed |
| ST-A5 | Replay a rotated/revoked refresh token | 401 | Not performed |
| ST-A6 | Reuse an already-used reset/verify token | 401 | Not performed |
| ST-A7 | Brute-force login (rate limit / lockout) | throttled | Not performed |
| ST-A8 | Account enumeration via forgot-password | generic response | Not performed |

### 3.2 Authorization

| ID | Test | Expected | Status |
| --- | --- | --- | --- |
| ST-Z1 | `USER` calls `/api/v1/fees` | 403 | Not performed |
| ST-Z2 | `STUDENT` calls `/api/v1/fees` | 200 | Not performed |
| ST-Z3 | Non-owner downloads a CV file | 403 | Not performed |
| ST-Z4 | Non-owner deletes a file | 403 | Not performed |
| ST-Z5 | Access another user's conversation/messages | denied | Not performed |
| ST-Z6 | Non-COMPANY posts a JOB listing | denied | Not performed |
| ST-Z7 | Spoof `X-User-Id` directly to a service port | denied (should fail) | Not performed |

### 3.3 Input & data

| ID | Test | Expected | Status |
| --- | --- | --- | --- |
| ST-I1 | Malicious filename / path traversal on upload | sanitised | Not performed |
| ST-I2 | Oversized request body to ai_core | 413 | Not performed |
| ST-I3 | Disallowed MIME type / oversized file | 400 | Not performed |
| ST-I4 | SQL/NoSQL injection in search/query params | no injection | Not performed |
| ST-I5 | XSS payload in post/comment/bio | escaped/neutralised | Not performed |

### 3.4 Edge / transport

| ID | Test | Expected | Status |
| --- | --- | --- | --- |
| ST-E1 | CORS with arbitrary Origin | not over-permissive | Not performed |
| ST-E2 | Rate-limit boundary (burst) | 429 past limit | Not performed |
| ST-E3 | Websocket connection flood | capped | Not performed |
| ST-E4 | Actuator endpoint exposure | restricted | Not performed |

## 4. Tooling gaps

| Tool class | Status |
| --- | --- |
| SAST (e.g. CodeQL, Semgrep) | Not configured |
| Dependency/OSV scan | Not configured |
| Secret scanning (gitleaks) | Not configured |
| Container image scan (Trivy/Grype) | Not configured |
| DAST (ZAP/Burp) | Not performed |
| Penetration test | Not performed |

## 5. Result status

No security test was executed during this documentation task, and none of the proposed cases
have been run: `Not performed.`

## 6. Cross-references

- `../10-security/10-vulnerability-assessment.md` (findings register — **Not yet formally assessed**)
- `../10-security/09-security-checklist.md` · [06-api-testing.md](06-api-testing.md) · [12-test-results.md](12-test-results.md)
