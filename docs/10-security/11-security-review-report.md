# Security Review Report

> Status: **Not yet formally assessed** · Last reviewed: 2026-09-30
> Evidence: repository code review only (`backend/`, `ai_core/`, `vithey_app/`, `.github/workflows/`)
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md` §5, §12

## 1. Executive summary

**Not yet formally assessed.**

No formal security review, penetration test, or audit of Vithey has been conducted. This
document exists to record that fact explicitly and to collect **code-level observations** made
while producing this documentation set. It is **not** a security certification, clearance, or
approval of any kind.

The implementation does contain several sound baseline controls: bcrypt password storage,
hashed opaque refresh/reset/verify tokens, HMAC JWT validation at the gateway and again in each
service, stateless sessions, Redis rate limiting, and a strict "no `.env` committed" secrets
policy. At the same time, authorization is thin outside finance, the service layer trusts
identity headers passed by the gateway, and there is no formal assessment or production
hardening. The highest-leverage items (VA-01, VA-11) are conditional on network exposure and
the non-existence of a production environment.

## 2. Scope reviewed

| In scope (read-only) | Out of scope |
| --- | --- |
| `backend/services/**` (gateway + 9 services + infra) | Live/running system |
| `backend/infrastructure/config-repo/**` | Penetration testing |
| `ai_core/vithey_ai/**` | Production (does not exist) |
| `vithey_app/lib/core/**` | Third-party SDK internals |
| `.github/workflows/**`, compose files | Infrastructure that does not exist |

## 3. Controls confirmed present

| Control | Evidence |
| --- | --- |
| bcrypt password hashing | `PasswordEncoderConfig.java` |
| JWT HMAC validation at gateway + per-service | `JwtValidator`, `JwtAuthenticationFilter` |
| Short access TTL (15m), refresh rotation (7d) | `application.yml`, `TokenService.java` |
| Opaque tokens stored hashed | `TokenHash.java`, migrations |
| Stateless sessions, CSRF disabled by design | every `SecurityConfig.java` |
| Rate limiting on HTTP routes | `config-repo/api-gateway.yml` |
| File MIME allow-list + filename sanitisation | `FileValidationService.java` |
| `.env` never committed | `.gitignore`, `git ls-files` |
| Prod profile restricts actuator + disables Swagger | `config-repo/application-prod.yml` |

## 4. Observations by theme

The full register (IDs, severity, evidence, recommendation) is in
[10-vulnerability-assessment.md](10-vulnerability-assessment.md). Summary:

- **Identity trust at services (VA-01, VA-02, VA-10):** services accept gateway headers without
  a token. Correct only if service ports are never directly reachable. This is the single most
  important thing to validate before exposure.
- **Authorization coverage (VA-04, VA-09):** method-level authorization exists only for finance;
  public-path definitions are duplicated and already inconsistent (`/students/verify`).
- **Authentication hardening (VA-05, VA-06, VA-07):** no lockout, no session invalidation on
  password change, no access-token revocation.
- **Transport & edge (VA-03, VA-08, VA-11, VA-14, VA-17):** no TLS, permissive CORS default,
  unprotected websocket route, broad actuator exposure, no security headers.
- **Data (VA-12, VA-13):** plaintext PII and trivial demo credentials.
- **Supply chain & response (VA-15, VA-16, VA-18):** no scanning, debug-signed Android release,
  no audit logging.

## 5. Residual risk statement

Because (a) no formal assessment occurred and (b) the system has only ever run as a local demo,
an accurate residual-risk statement **cannot be made**. Any risk rating would be speculative.
Formal risk acceptance must follow a real assessment. **Not yet formally assessed.**

## 6. Recommendations (prioritised)

| Priority | Action | Addresses |
| --- | --- | --- |
| P0 | Keep service ports network-isolated; validate this assumption explicitly | VA-01 |
| P0 | Require/validate TLS before any non-local deployment; real release signing | VA-11, VA-15 |
| P1 | Require the JWT secret (no defaults); restrict CORS; lock down actuator | VA-02, VA-03, VA-14 |
| P1 | Systematise authorization; single-source public paths | VA-04, VA-09, VA-10 |
| P2 | Add login throttling and session invalidation on credential change | VA-05, VA-06 |
| P2 | Add CI scanning (deps/secrets/images); add security-event logging | VA-16, VA-18 |

## 7. Approval

**No approval is given or implied.** The fields below are intentionally blank.

| Role | Name | Date | Signature |
| --- | --- | --- | --- |
| Reviewer | _____________________ | ____________ | _____________________ |
| Engineering lead | _____________________ | ____________ | _____________________ |
| Product owner | _____________________ | ____________ | _____________________ |

## 8. Cross-references

- [10-vulnerability-assessment.md](10-vulnerability-assessment.md) · [09-security-checklist.md](09-security-checklist.md) · [01-security-overview.md](01-security-overview.md)
- `../_meta/EVIDENCE-BASIS.md` §12 (governance status)
