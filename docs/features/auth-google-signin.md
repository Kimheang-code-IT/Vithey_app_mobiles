# Feature: Auth - Google Sign-In

- Issue: #5
- Component: Auth
- Status: Done (verification pending)
- Branch: `feature/auth-google-signin`

## Objective

Allow sign-in with Google via server-side ID-token verification.

## What exists

GoogleTokenVerifier, GoogleAuthService, UserExternalIdentity + V5 migration; Flutter google_auth_service; tests.

## Endpoints / components

POST /auth/google

## Evidence

GoogleTokenVerifierTest, GoogleAuthServiceTest, AuthControllerGoogleTest; Flutter google tests

## Limitations

Live Google-client end-to-end verification pending; no client secret stored server-side.
