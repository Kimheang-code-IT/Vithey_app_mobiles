# Pull Request Process

## Opening a PR

1. Branch from `dev` using the naming convention (`feature/*`, `fix/*`, …).
2. Push the branch and open a PR **into `dev`**.
3. Fill in the pull request template.
4. The `CI Gate` check runs automatically (see [ci-pipeline.md](ci-pipeline.md)).

## Review

- At least one reviewer should approve.
- Resolve every review conversation.
- Keep the PR focused; split unrelated changes.

## Required checks

| Target branch | Required check |
| --- | --- |
| `dev` | `CI Gate` |
| `main` | `Main Gate` |

A required check must have appeared and passed at least once before it is added
to a branch ruleset. Path-filtered workflows are never used as required checks;
the gate jobs always report.

## Merging

- Do not merge with failing, pending, or unresolved checks.
- Do not force-push to `main` or `dev`.
- Do not bypass protection rules.

## `dev → main`

After `dev` is stable and integration-validated, open a PR `dev → main`. This
runs the Level 3 validation and requires `Main Gate`.
