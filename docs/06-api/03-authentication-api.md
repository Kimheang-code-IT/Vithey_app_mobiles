# Authentication API (auth-service)

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/auth-service/src/main/java/com/vithey/auth/controller/*.java`, `dto/request/*.java`, `dto/response/*.java`

Base paths: `/api/v1/auth` (`AuthController`), `/api/v1/students` (`StudentVerificationController`).
Service port `8081`; routed by the gateway via `auth-service`. Envelope: `{data, meta, error}`
(auth uses the 2-field wrapper, so `meta` is absent).

## 1. Endpoint inventory

| Method | Path | Auth | Required role | Purpose | Request | Response | Errors |
|---|---|---|---|---|---|---|---|
| POST | `/api/v1/auth/register` | Public | — | Create USER/COMPANY account | `RegisterRequest` | `AuthResponse` | 400, 409 |
| POST | `/api/v1/auth/login` | Public | — | Login by email or phone | `LoginRequest` | `AuthResponse` | 400, 401 |
| POST | `/api/v1/auth/google` | Public | — | Verify Google ID token & issue Vithey tokens | `GoogleLoginRequest` | `AuthResponse` | 400, 401 |
| POST | `/api/v1/auth/refresh` | Public | — | Rotate refresh token | `RefreshTokenRequest` | `TokenResponse` | 400, 401 |
| POST | `/api/v1/auth/forgot-password` | Public | — | Start reset (always generic) | `ForgotPasswordRequest` | `MessageResponse` | 400 |
| POST | `/api/v1/auth/reset-password` | Public | — | Complete reset with one-time token | `ResetPasswordRequest` | `MessageResponse` | 400 |
| POST | `/api/v1/auth/verify-email` | Public | — | Mark email verified | `VerifyEmailRequest` | `MessageResponse` | 400 |
| GET | `/api/v1/auth/me` | JWT | any | Current identity + roles | — | `UserAuthResponse` | 401 |
| PATCH | `/api/v1/auth/me/password` | JWT | any | Change password | `ChangePasswordRequest` | `MessageResponse` | 400, 401 |
| POST | `/api/v1/auth/logout` | JWT | any | Revoke refresh token | `LogoutRequest` | `204 No Content` | 401 |
| POST | `/api/v1/students/verify` | JWT | any (promotes to STUDENT) | Verify AUB student | `StudentVerifyRequest` | `StudentVerificationResponse` | 400, 401, 409 |

> `/api/v1/students/verify` is routed by the gateway but **not** in the public matcher, so a JWT is
> required even though it is a registration-like action. [VERIFIED: `PublicPathMatcher.java`]

## 2. Request/response schemas (snake_case)

`RegisterRequest`: `email`, `phone`, `password` (8–72), `full_name` (≤160), `role`
(`USER`|`COMPANY`; `STUDENT` is not self-assignable). `LoginRequest`: `email_or_phone`, `password`.
`RefreshTokenRequest`/`LogoutRequest`: `refresh_token`. `ForgotPasswordRequest`: `email`.
`ResetPasswordRequest`: `token`, `new_password`. `VerifyEmailRequest`: `token`.
`ChangePasswordRequest`: `current_password`, `new_password`. `StudentVerifyRequest`: `student_id`,
`university_email`.

`AuthResponse` = `{ user, tokens }` where `UserAuthResponse` = `user_id, email, phone, full_name,
role, is_student_verified, is_email_verified` and `TokenResponse` = `access_token, refresh_token,
expires_in`. `StudentVerificationResponse` = `user_id, student_id, university_email, role,
is_student_verified, status, verified_at`. `MessageResponse` = `{ message }`.

## 3. Examples

### POST `/api/v1/auth/register` → 201

```json
{
  "email": "student@aub.edu.kh",
  "phone": "+855123456789",
  "password": "SecurePass123!",
  "full_name": "Jane Doe",
  "role": "USER"
}
```

```json
{
  "data": {
    "user": {
      "user_id": "018a4379-a9e0-4391-8285-c231aeea577c",
      "email": "student@aub.edu.kh",
      "phone": "+855123456789",
      "full_name": "Jane Doe",
      "role": "USER",
      "is_student_verified": false,
      "is_email_verified": false
    },
    "tokens": {
      "access_token": "<jwt>",
      "refresh_token": "<opaque>",
      "expires_in": 900
    }
  }
}
```

### POST `/api/v1/auth/login` → 200

```json
{ "email_or_phone": "student@aub.edu.kh", "password": "SecurePass123!" }
```

### POST `/api/v1/auth/google` → 200

```json
{ "id_token": "<google-id-token>" }
```

Returns the same `{data: {user, tokens}}` shape as `/auth/login`. The ID token is verified
server-side (signature, issuer, audience = `GOOGLE_WEB_CLIENT_ID`, expiry, verified email) and is
never used as the session token. See [`../10-security/12-google-sign-in.md`](../10-security/12-google-sign-in.md).

### POST `/api/v1/students/verify` → 200 (JWT)

```json
{ "student_id": "AUB-2026-00123", "university_email": "jane@aub.edu.kh" }
```

```json
{
  "data": {
    "user_id": "018a4379-a9e0-4391-8285-c231aeea577c",
    "student_id": "AUB-2026-00123",
    "university_email": "jane@aub.edu.kh",
    "role": "STUDENT",
    "is_student_verified": true,
    "status": "VERIFIED",
    "verified_at": "2026-09-30T08:00:00Z"
  }
}
```

### Password reset

```json
POST /api/v1/auth/forgot-password
{ "email": "student@aub.edu.kh" }
```
```json
{ "data": { "message": "If the email exists, a password reset was started." } }
```

## 4. Security behaviour

- Password storage: BCrypt. Refresh tokens stored **hashed** (`token_hash`) and rotated on refresh.
- Email/reset tokens stored hashed, one-time (`used_at`), with `expires_at`.
- Access token TTL 15 min, refresh 7 d (`VITHEY_ACCESS_TOKEN_TTL`, `VITHEY_REFRESH_TOKEN_TTL`).
- The auth-service `SecurityConfig` independently permits the same six public auth endpoints plus
  actuator/swagger; everything else requires authentication (defense in depth).
- Google sign-in verifies the ID token with Google's JWKS before any account is created/linked;
  `email_verified` must be true. Roles are never elevated from provider authentication.

## 5. Data touched

`auth_db`: `users`, `refresh_tokens`, `password_reset_tokens`, `email_verification_tokens`,
`student_verifications`, `user_external_identities`. See
[`../05-database/03-database-schema.md`](../05-database/03-database-schema.md) §1.

## 6. TBD

- Mail delivery in non-log mode (SMTP config exists) is not exercised end-to-end:
  `TBD — Requires confirmation.`
- Rate limiting/abuse protection for login/forgot-password beyond the shared gateway limiter:
  `TBD — Requires confirmation.`
