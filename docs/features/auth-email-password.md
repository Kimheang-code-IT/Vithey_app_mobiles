# Feature: Auth - Email/password authentication

- Issue: #3
- Component: Auth
- Status: Done
- Branch: `feature/auth-email-password`

## Objective

Let students register and sign in with email/phone + password and receive a Vithey JWT.

## What exists

AuthController register/login/me/logout; JwtProvider; BCrypt; tests.

## Endpoints / components

POST /auth/register, /auth/login, /auth/me, /auth/logout

## Evidence

auth-service tests (AuthServiceContextTest, AuthServiceRegisterMailTest, JwtProviderTest)

## Limitations

Token secret provided via VITHEY_JWT_SECRET.
