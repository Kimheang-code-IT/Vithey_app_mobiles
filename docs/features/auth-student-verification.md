# Feature: Auth - Student verification

- Issue: #6
- Component: Auth
- Status: Done
- Branch: `feature/auth-student-verification`

## Objective

Gate student-only features behind verified student status.

## What exists

POST /students/verify elevates role; finance gating; tests/smoke.

## Endpoints / components

POST /students/verify

## Evidence

auth-service tests; smoke-api verify steps

## Limitations

Real institutional verification out of demo scope.
