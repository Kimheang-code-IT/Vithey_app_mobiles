# Password Security

> Status: Verified baseline (code-level) · Last reviewed: 2026-09-30
> Evidence: `backend/services/auth-service/.../security/PasswordEncoderConfig.java`, `.../service/AuthService.java`, `.../service/PasswordResetService.java`, `.../util/OpaqueTokenGenerator.java`, `.../util/TokenHash.java`, `.../dto/request/*.java`, migrations
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md` §5

## 1. Password hashing

Passwords are hashed with **bcrypt** via Spring Security's `BCryptPasswordEncoder` with the
library default strength (10, i.e. 2^10 iterations). [VERIFIED]
`PasswordEncoderConfig.java:13`.

| Aspect | Value | Evidence |
| --- | --- | --- |
| Algorithm | bcrypt (`BCryptPasswordEncoder`) | `PasswordEncoderConfig.java` |
| Column | `users.password_hash VARCHAR(255)` | `V1__init_auth_schema.sql:5` |
| Encode on register | `passwordEncoder.encode(request.password())` | `AuthService.java:77` |
| Verify on login | `passwordEncoder.matches(...)` | `AuthService.java:97` |
| Encode on change/reset | `passwordEncoder.encode(newPassword)` | `AuthService.java:123`, `PasswordResetService.java:66` |

No custom `pepper`/secret is applied beyond bcrypt itself. [VERIFIED]

## 2. Password policy (input validation)

`RegisterRequest` and the reset/change DTOs constrain the password. Per
`../06-api/03-authentication-api.md`, the register password is validated to **8–72**
characters (the 72-byte cap matches bcrypt's input truncation limit). [VERIFIED]
`dto/request/RegisterRequest.java`, `ResetPasswordRequest.java`, `ChangePasswordRequest.java`.

- No evidence of a complexity/breach-list requirement beyond length. [VERIFIED — absence]
- Registration accepts `USER`/`COMPANY` only, enforced in `AuthService`. [VERIFIED]

## 3. Password change & reset

### 3.1 Authenticated change

`PATCH /api/v1/auth/me/password` → `AuthService.changePassword` [VERIFIED]:

1. Load the active, non-deleted user.
2. `passwordEncoder.matches(currentPassword, hash)` — else `INVALID_CREDENTIALS`.
3. Re-bcrypt and persist the new password.

### 3.2 Forgot / reset (unauthenticated)

`PasswordResetService` [VERIFIED]:

| Step | Detail |
| --- | --- |
| Trigger | `POST /auth/forgot-password` with `email` |
| Enumeration defence | Always responds generically; token only created if the account exists |
| Token | 40 random bytes via `OpaqueTokenGenerator`, base64url |
| Storage | SHA-256 **hash** only, `password_reset_tokens.token_hash` (unique) |
| TTL | 30 minutes |
| Single-use | `used_at` set on success; `isUsable(now)` rejects used/expired |
| Effect | New password bcrypt-encoded and saved |

## 4. Opaque token generation & hashing

- `OpaqueTokenGenerator` produces cryptographically random tokens: **48 bytes** for refresh,
  **40 bytes** for reset and email-verification. [VERIFIED]
- `TokenHash.sha256` stores only the hex SHA-256 digest; raw values are never persisted.
  [VERIFIED] `TokenHash.java`; migrations `V1__init_auth_schema.sql` (`token_hash VARCHAR(255)`).
- Because tokens are high-entropy random values (not user-chosen), unsalted SHA-256 is an
  acceptable at-rest representation (preimage resistance is sufficient for random tokens).

## 5. Transport & client storage

| Concern | Handling | Evidence |
| --- | --- | --- |
| Password in transit | HTTPS is expected at the edge but **not enforced** in code (TLS is deployment's responsibility); local demo uses plain HTTP | [INFERRED] plan/demo; requires deployment confirmation |
| Token at rest on device | `flutter_secure_storage` (OS keychain/keystore) | `vithey_app/lib/core/storage/secure_storage_service.dart` |
| Password on device | Not persisted; entered per session | [VERIFIED — absence of storage] |

## 6. Observations & risks

| # | Observation | Severity | Evidence |
| --- | --- | --- | --- |
| P1 | No account lockout / exponential backoff on repeated failed logins in `auth-service`; only the gateway rate limiter throttles | Medium | `AuthService.login`; `api-gateway.yml` |
| P2 | `changePassword` / `resetPassword` do not invalidate existing refresh tokens, so a compromised session may survive a password change | Medium | `AuthService.changePassword`, `PasswordResetService.resetPassword` |
| P3 | Minimum length is 8; no complexity or breached-password check | Low | `RegisterRequest` |
| P4 | `LoggingAuthMailSender` (`VITHEY_MAIL_MODE=log`) may log verification/reset links in local mode; ensure it is not enabled with real tokens in shared environments | Low | `auth-service/.env.example` (`VITHEY_MAIL_MODE=log`) |
| P5 | bcrypt strength is the library default (10); not externally tuned | Low | `PasswordEncoderConfig.java` |

**Not yet formally assessed.** These are code-level observations, not audit findings.

## 7. Cross-references

- [02-authentication.md](02-authentication.md) · [04-JWT-security.md](04-JWT-security.md)
- [08-secrets-management.md](08-secrets-management.md)
- API schemas: `../06-api/03-authentication-api.md`
