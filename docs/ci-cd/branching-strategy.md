# Branching Strategy

## Branches

| Branch | Purpose | Who writes to it |
| --- | --- | --- |
| `main` | Stable, integration-validated. | Only via PR from `dev`. |
| `dev` | Integration branch; all work lands here first. | Only via PR from task branches. |
| `feature/*` | New features. | Developers / agents, branched from `dev`. |
| `fix/*` | Bug fixes. | Developers / agents, branched from `dev`. |
| `chore/*` | Maintenance, tooling, dependencies. | Developers / agents, branched from `dev`. |
| `docs/*` | Documentation only. | Developers / agents, branched from `dev`. |
| `test/*` | Test-only changes. | Developers / agents, branched from `dev`. |
| `refactor/*` | Behaviour-preserving refactors. | Developers / agents, branched from `dev`. |

## Flow

```
feature/*  fix/*  chore/*  docs/*  test/*  refactor/*
        │
        ▼  pull request
       dev
        │  integration validation (dev-integration.yml)
        ▼  pull request
       main
```

## Rules

- Never commit directly to `main` or `dev`.
- Task branches always start from the latest `dev`.
- One topic per branch; keep pull requests focused.
- `main` only receives reviewed, validated changes.
