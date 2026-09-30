# Contributing to Vithey / AUB Connect

Thanks for contributing. This document describes the branching model, commit
style, and pull-request process used by the repository.

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

## Code references

- Backend: `backend/` (Maven multi-module; Java 21).
- Flutter: `vithey_app/`.
- AI Core: `external-services/ai-core/`.
- Fake Payment: `external-services/fake-payment-service/`.
- Monitoring: `monitoring/`.
