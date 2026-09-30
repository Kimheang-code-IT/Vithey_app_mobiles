# Security Summary

> Status: **Not yet formally assessed** · Last reviewed: 2026-09-30
> Evidence: repository code review only (`backend/`, `ai_core/`, `vithey_app/`, `.github/workflows/`)
> Detailed sibling: [`../10-security/11-security-review-report.md`](../10-security/11-security-review-report.md)
> Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)

## 1. Headline

**Not yet formally assessed.**

No formal security review, penetration test, or audit of Vithey has been conducted. This
document records that fact explicitly and summarises code-level observations collected during
documentation. It is **not** a security certification, clearance, or approval of any kind.

## 2. Baseline controls confirmed present

These are positive, verifiable controls — not a substitute for assessment. [VERIFIED]

| Control | Evidence |
| --- | --- |
| bcrypt password hashing | `PasswordEncoderConfig.java` |
| JWT HMAC validation at gateway and per service | `JwtValidator`, `JwtAuthenticationFilter` |
| Short access token (15 min), refresh rotation (7 days) | `application.yml`, `TokenService.java` |
| Opaque refresh/reset/verify tokens stored hashed | `TokenHash.java`, migrations |
| Stateless sessions; CSRF disabled by design | each `SecurityConfig.java` |
| Redis rate limiting on HTTP routes | `config-repo/api-gateway.yml` |
| File MIME allow-list + filename sanitization | `FileValidationService.java` |
| No `.env` files committed; secrets only in gitignored env | `.gitignore`, `git ls-files` |
| Prod profile restricts actuator and disables Swagger | `config-repo/application-prod.yml` |

## 3. Principal observations (code-level, not an assessment)

These are concerns recorded from reading the code. They are **not** the result of testing.
Full register: [`../10-security/10-vulnerability-assessment.md`](../10-security/10-vulnerability-assessment.md)

| Theme | Observation | Priority |
| --- | --- | --- |
| Identity trust | Services accept gateway-injected identity headers without a token; safe only if service ports are never directly reachable | P0 to validate |
| Authorization coverage | Method-level authorization exists only in finance (`@PreAuthorize` on fee/payment controllers) | P1 |
| Public-path inconsistency | `/api/v1/students/verify` is routed but not in the public matcher, so it requires a JWT | P1 |
| Authentication hardening | No login lockout, no session invalidation on password change, no access-token revocation | P2 |
| Transport & edge | No TLS; permissive CORS default; unprotected WebSocket route; broad actuator, if exposed | P0–P1 before exposure |
| Mobile release | Android release build signs with debug keys | P0 before release |
| Supply chain / response | No dependency/secret/image scanning; no security-event audit logging | P2 |

## 4. Residual risk statement

Because no formal assessment occurred and the system has only ever run as a local demo, an
accurate residual-risk statement **cannot be made**. Any rating would be speculative. Formal risk
acceptance must follow a real assessment. **Not yet formally assessed.**

## 5. What is required before any bank-facing production use

1. Perform a formal security assessment / penetration test against a deployed environment.
2. Deploy real release signing and enforce TLS.
3. Validate the network-isolation assumption for service ports.
4. Systematise authorization and single-source the public-path list.
5. Establish security-event logging and dependency/secret/image scanning in CI.
6. Obtain formal security sign-off and record residual risk acceptance.

## 6. Status

- Formal assessment: **Not yet formally assessed.**
- Penetration test: **Not performed.**
- Audit / certification: **Not performed.**
- Sign-off: **No approval is given or implied.**

## 7. Related documents

- [`../10-security/11-security-review-report.md`](../10-security/11-security-review-report.md) · [`../10-security/10-vulnerability-assessment.md`](../10-security/10-vulnerability-assessment.md)
- [`14-risks-issues.md`](14-risks-issues.md) · [`17-recommendations.md`](17-recommendations.md) · [`19-final-acceptance.md`](19-final-acceptance.md)
