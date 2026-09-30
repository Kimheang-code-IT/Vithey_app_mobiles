# Release Process

This project has no production deployment configured yet. This document
describes the intended flow once environments exist.

## Current state

- No production deployment and no environment secrets are configured.
- No container images are published from CI during the initial setup.
- Deployment is intentionally out of scope until a verified environment exists.

## Promotion flow

1. Work lands on `dev` through PRs (`CI Gate`).
2. `dev-integration.yml` validates `dev` on every push.
3. A PR `dev → main` runs the full Level 3 validation (`Main Gate`).
4. After review, `dev` is merged into `main`.

## Versioning

Use semantic versioning for releases (`MAJOR.MINOR.PATCH`). Tag releases on
`main` after validation.

## Future deployment

When an environment exists, add a deployment workflow that:

- deploys only from `main`,
- uses GitHub Environments with protection rules,
- reads secrets from a secret manager,
- can be rolled back.

Do not enable production deployment before these safeguards are in place.
