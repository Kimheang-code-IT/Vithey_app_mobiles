# Staging Deployment

> Status: Verified (staging does not exist) · Last reviewed: 2026-09-30
> Evidence: `EVIDENCE-BASIS.md` §9, §12; `.github/workflows/ci-promote-dev.yml`; absence of any staging configuration in the repository

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [Deployment architecture](01-deployment-architecture.md) · [Production deployment](05-production-deployment.md)

## 1. Status: Staging (does not exist)

**There is no staging environment.** No staging host, cluster, namespace, compose override, or workflow exists in this repository.

[VERIFIED — `EVIDENCE-BASIS.md` §12; no staging files/commands; no deploy job in any workflow]

## 2. Evidence for the absence

| Expectation if staging existed | Found? |
|---|---|
| A staging deploy workflow (`.github/workflows/*staging*`) | No |
| A staging compose file / override | No |
| Staging-specific config (`config-repo/*staging*.yml`) | No |
| Cloud/infra-as-code (Terraform, Helm, K8s manifests) | No |
| Staging secrets or environments in workflows | No |
| A documented staging URL | No |

[VERIFIED — repository search]

The only environment-like config file is `backend/infrastructure/config-repo/application-prod.yml`, and nothing activates it. [VERIFIED]

## 3. What CI does instead

`ci-promote-dev.yml` runs tests and publishes images, then fast-forwards to `dev`. There is **no** deployment to any environment — staging included. [VERIFIED]

## 4. Consequence

- Integration/end-to-end validation happens only on a developer's local demo stack (`backend/scripts/docker-up-demo.ps1`) and via Testcontainers smoke tests.
- There is no pre-production environment to validate a release candidate before (hypothetical) production.

## 5. If staging is later required (recommendation — not current state)

> Recommendation only. No staging environment exists.

A future staging environment would most naturally reuse the local demo model: a persistent host running the base + demo compose (or an orchestrated equivalent), `SPRING_PROFILES_ACTIVE=prod` with staging secrets, images pinned to `sha-<short>`, and the monitoring profile enabled. This is `[PLANNED]`; no such environment is implemented. [INFERRED]

[TBD] Whether a staging environment is in scope for the project — TBD — Requires confirmation.
