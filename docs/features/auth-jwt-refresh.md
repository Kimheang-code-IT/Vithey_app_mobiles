# Feature: Auth - JWT refresh-token lifecycle

- Issue: #4
- Component: Auth
- Status: Done
- Branch: `feature/auth-jwt-refresh`

## Objective

Keep sessions long-lived safely via refresh tokens and explicit revocation.

## What exists

POST /auth/refresh and /auth/logout with rotation; tests.

## Endpoints / components

POST /auth/refresh, /auth/logout

## Evidence

auth-service tests; gateway JwtValidatorTest

## Limitations

Refresh tokens must be stored securely client-side.
