# Contributing to Vithey / AUB Connect

Thanks for contributing. This document describes the project's development
resources, branching model, commit style, and pull-request process.

## Project Resources

| Resource | Purpose |
| --- | --- |
| Database Diagram | Database schema, tables, relationships, and data model |
| System Architecture | Complete Vithey / AUB Connect system architecture and service relationships |
| GitHub Repository | Source code, issues, pull requests, CI/CD, and project development |

### Database Diagram

dbdiagram.io:
https://dbdiagram.io/d/6abcd3790f25a52d014d678a

Use this resource when:

- reviewing the database schema
- creating or modifying tables
- checking relationships
- planning migrations
- reviewing database-related pull requests

### System Architecture

Eraser:
https://app.eraser.io/workspace/2Dx4uesY1V7HwZjqULJg?origin=share

Use this resource to understand:

- Flutter mobile application
- API Gateway
- Spring Boot services
- external-services
- AI Core
- Fake Payment Service
- PostgreSQL
- Redis
- RabbitMQ
- WebSocket/STOMP
- MinIO
- external integrations
- monitoring
- CI/CD and deployment

### Source Code

GitHub:
https://github.com/Kimheang-code-IT/Vithey_app_mobiles.git

Repository: `Kimheang-code-IT/Vithey_app_mobiles`

> **Documentation consistency:** When implementation changes affect the
> database, system architecture, API structure, deployment, or service
> relationships, contributors must update the corresponding technical
> documentation and diagrams so that the documentation remains consistent with
> the implementation.

## Branching model

```
main
  ↑
 dev
  ↑
feature/*   fix/*   chore/*   docs/*   test/*   refactor/*
```

- `main` — stable, integration-validated. **Never develop here directly.**
- `dev` — the integration branch. All feature work lands here first.
- Task branches (`feature/*`, `fix/*`, `chore/*`, `docs/*`, `test/*`, `refactor/*`)
  branch from `dev` and merge back into `dev` through a pull request.

Normal developers and AI agents must not commit directly to `main` or `dev`.

## Normal development flow

1. Update `dev`.
   ```bash
   git checkout dev
   git pull origin dev
   ```
2. Create a task branch from `dev`.
   ```bash
   git checkout -b feature/auth-google-sign-in
   ```
3. Make a focused change (one topic per branch).
4. Test locally (see the README for per-component commands).
5. Commit using Conventional Commits (below).
6. Push the task branch.
   ```bash
   git push -u origin feature/auth-google-sign-in
   ```
7. Open a pull request: `feature/... → dev`.
8. Wait for the `CI Gate` check.
9. Address review feedback.
10. Merge into `dev`.
11. Later, open a pull request `dev → main`.
12. Wait for the `Main Gate` check.
13. Review.
14. Merge into `main`.

## Contribution rules

- Create work from an appropriate `feature/`, `fix/`, `docs/`, `chore/`,
  `test/`, or `refactor/` branch.
- Do not commit directly to the protected `dev` or `main` branches.
- Submit changes to `dev` through a pull request.
- Make sure required CI checks pass before merging.
- Use `dev` for integration.
- Promote `dev` to `main` through a pull request after validation.
- Update the relevant files under `docs/` when behavior or architecture changes.
- Never commit passwords, API keys, OAuth secrets, tokens, private keys, or
  other credentials.

## Commit messages — Conventional Commits

Format: `<type>(<scope>): <short summary>`

Common types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `ci`, `build`, `perf`.

Examples:

```text
feat(auth): add Google sign-in
feat(finance): integrate demo payment provider
fix(map): align place query parameters
test(auth): add refresh token tests
docs(api): update finance API contract
chore(ci): add PR validation
```

## Pull requests

- Keep PRs small and single-purpose.
- Fill in the pull request template.
- The required check is `CI Gate` (feature → dev) and `Main Gate` (dev → main).
- Do not merge with failing or unresolved checks.
- Never commit secrets (see `SECURITY.md`).

## Database changes

1. Check the dbdiagram.io schema before making changes.
2. Update the application/database migration correctly.
3. Update the database diagram when the schema changes.
4. Update relevant documentation.
5. Test migrations against a safe development database.
6. Include database-impact information in the pull request.

## Architecture changes

1. Check the Eraser architecture before making major structural changes.
2. Update the implementation.
3. Update the Eraser diagram if services, integrations, data flow,
   infrastructure, or deployment relationships change.
4. Update the relevant docs.
5. Explain the architecture impact in the pull request.

## Code references

- Backend: `backend/` (Maven multi-module; Java 21).
- Flutter: `vithey_app/`.
- AI Core: `external-services/ai-core/`.
- Fake Payment: `external-services/fake-payment-service/`.
- Monitoring: `monitoring/`.
