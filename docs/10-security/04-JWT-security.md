# JWT Security

> Status: Verified baseline (code-level) · Last reviewed: 2026-09-30
> Evidence: `backend/services/auth-service/.../security/JwtProvider.java`, `backend/services/*/.../security/JwtAuthenticationFilter.java`, `backend/services/api-gateway/.../security/JwtValidator.java`, `backend/services/api-gateway/.../filter/JwtAuthenticationGlobalFilter.java`, `backend/infrastructure/config-repo/application.yml`, `ai_core/vithey_ai/api/auth.py`
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md` §5

## 1. Token format

Access tokens are **HMAC-signed JWTs** built with JJWT `0.12.6` (`io.jsonwebtoken`). The
signing key is derived from `vithey.jwt.secret` via `Keys.hmacShaKeyFor(secret bytes)`.
[VERIFIED] `JwtProvider.java:27`, `JwtValidator.java:18`.

| Property | Value | Tag |
| --- | --- | --- |
| Algorithm | HMAC (HS256 by default for a 256-bit key) | [VERIFIED] `signWith(secretKey)` / `verifyWith(secretKey)` |
| Key source | `VITHEY_JWT_SECRET` env → `vithey.jwt.secret` | [VERIFIED] `config-repo/application.yml:53` |
| Access TTL | 15m (`VITHEY_ACCESS_TOKEN_TTL`, default `15m`) | [VERIFIED] `application.yml:54` |
| Refresh TTL | 7d (`VITHEY_REFRESH_TOKEN_TTL`, default `7d`) | [VERIFIED] `application.yml:55` |
| Claims | `sub`, `email`, `roles`, `iat`, `exp` | [VERIFIED] `JwtProvider.createAccessToken` |
| Not present | `iss`, `aud`, `jti`, `nbf` | [VERIFIED] `JwtProvider.createAccessToken` |

Refresh tokens are **not** JWTs; they are opaque random strings (48 bytes) stored as SHA-256
hashes. See [02-authentication.md](02-authentication.md) §1.

## 2. Validation

### 2.1 Gateway (`JwtValidator`)

```java
Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token).getPayload();
```

`parseSignedClaims` enforces the signature and `exp`. `JwtAuthenticationGlobalFilter` maps
`JwtException | IllegalArgumentException` to `401 UNAUTHORIZED` and only forwards identity
headers on success. [VERIFIED]

### 2.2 Domain services (`JwtAuthenticationFilter`)

Each service has its own copy. It first tries `Authorization: Bearer`, then falls back to the
gateway headers `X-User-Id` / `X-User-Roles` / `X-User-Email`. Invalid Bearer tokens result in
an **unauthenticated** context that is then rejected by `anyRequest().authenticated()`.
[VERIFIED]

### 2.3 ai_core (`api/auth.py`)

`require_user` prefers `X-User-Id` (trusting the gateway), otherwise decodes the Bearer JWT
with `PyJWT` using `algorithms=["HS256"]` and `options={"require": ["sub"]}`. A missing
`VITHEY_JWT_SECRET` yields `401 JWT secret not configured`. [VERIFIED]

## 3. Trust boundaries

```mermaid
sequenceDiagram
  participant C as Client
  participant GW as api-gateway
  participant S as domain service
  participant AI as ai_core
  C->>GW: Authorization: Bearer <JWT>
  GW->>GW: verify HMAC + exp
  GW->>S: X-User-Id / X-User-Roles / X-User-Email
  GW->>AI: X-User-Id / X-User-Roles / X-User-Email
  Note over S: re-validates Bearer if present; else trusts headers
  Note over AI: trusts X-User-Id if present; else decodes JWT
```

## 4. Observations & risks (code-level)

| # | Observation | Severity | Evidence |
| --- | --- | --- | --- |
| J1 | Service filter accepts `X-User-*` headers with no Bearer token; if a service port is directly reachable, identity can be spoofed (roles default to `USER`) | High (conditional on network exposure) | `JwtAuthenticationFilter.java` (all services), `ai_core/api/auth.py` |
| J2 | No token revocation / denylist for access tokens; logout only revokes the refresh token, so access tokens remain valid ≤15m | Low–Medium | `TokenService.revokeRefreshToken` |
| J3 | No `iss`/`aud`/`jti` claims, so tokens are not bound to an issuer/audience and cannot be individually traced | Low | `JwtProvider.createAccessToken` |
| J4 | `ai_core` ships a default secret (`change-me-...`) when `VITHEY_JWT_SECRET` is unset | Medium | `ai_core/vithey_ai/config.py:86` |
| J5 | Single symmetric secret signs and verifies in every component — secret compromise is total (no key rotation/kid) | Medium | all `JwtProvider`/`JwtValidator`/`auth.py` |
| J6 | HS256 algorithm is fixed client-side in `ai_core` and JJWT verifies with the configured key; no explicit algorithm allow-list beyond that | Low | `auth.py:60`, `JwtValidator` |

These are observations, **not** the result of a formal assessment. **Not yet formally assessed.**
See [10-vulnerability-assessment.md](10-vulnerability-assessment.md).

## 5. Positive controls

- Access TTL is short (15m). [VERIFIED]
- Refresh tokens are opaque, hashed at rest, single-use and rotated. [VERIFIED]
- CSRF disabled deliberately because there is no cookie/session auth. [VERIFIED]
- `application-prod.yml` restricts actuator to `health,info` and disables Swagger/OpenAPI.
  [VERIFIED] `config-repo/application-prod.yml`

## 6. Cross-references

- [02-authentication.md](02-authentication.md) · [05-password-security.md](05-password-security.md)
- [08-secrets-management.md](08-secrets-management.md) (JWT secret handling)
- `../06-api/03-authentication-api.md` (token response schema)
