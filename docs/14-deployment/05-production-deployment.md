# Production Deployment

> Status: Verified (production does not exist) · Last reviewed: 2026-09-30
> Evidence: `EVIDENCE-BASIS.md` §9, §12; `.github/workflows/ci-promote-dev.yml`; `backend/infrastructure/config-repo/application-prod.yml`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [Deployment architecture](01-deployment-architecture.md) · [Staging deployment](04-staging-deployment.md) · [Rollback plan](07-rollback-plan.md)

## 1. Status: Production (does not exist)

**Production is not deployed.** No production environment, host, cluster, or pipeline exists. Nothing in this repository deploys Vithey to any remote environment.

[VERIFIED — `EVIDENCE-BASIS.md` §12; no deploy workflow; no K8s/Helm/Terraform/Jenkins]

## 2. Evidence for the absence

| Expectation if production existed | Found? |
|---|---|
| A deploy workflow with target-host/cloud credentials | No |
| `application-prod.yml` activated in CI | No (present but unused) |
| Infrastructure-as-code | No |
| Production secrets / environment protection rules | No |
| Load balancer / TLS / DNS config | No |
| Backup/DR automation | No |

[VERIFIED — repository search]

`application-prod.yml` only removes dev defaults and disables Swagger/actuator prometheus exposure; it is never activated by the pipeline. [VERIFIED — `config-repo/application-prod.yml`, `EVIDENCE-BASIS.md` §9]

## 3. What exists today (for reference)

Local demo deployment only — see [Development deployment](03-development-deployment.md). Published container images exist in GHCR, but nothing pulls and runs them in a remote environment. [VERIFIED]

## 4. Recommended Production Architecture (recommendation — not current state)

> **Recommendation only. Production is not deployed. This is not a description of an existing system.**

A future production architecture would need, at minimum:

| Area | Recommendation |
|---|---|
| Compute | Container host(s) or an orchestrator; one process per service (`8 domain + gateway + eureka + config + ai_core`) |
| Images | Pull `ghcr.io/<owner>/vithey-<service>:sha-<short>` (immutable tag), never `latest` |
| Data | Managed PostgreSQL (one DB per service), managed Redis, managed RabbitMQ (or containers), S3-compatible object storage in place of MinIO |
| Secrets | Secret manager injecting `VITHEY_JWT_SECRET`, `DEEPSEEK_API_KEY`, DB/MinIO/Rabbit credentials; `SPRING_PROFILES_ACTIVE=prod` |
| Ingress | TLS reverse proxy terminating in front of `api-gateway` only; keep `eureka`, `config`, `ai_core` internal |
| Observability | Persistent monitoring profile (Prometheus/Grafana/Loki) with retention and access control |
| Security | Add Alertmanager + alert routing; block public `/actuator/**`; run `ai_core` as non-root; image scanning/signing |
| Release | Already-published images + a real deploy/rollback pipeline (none exists) |

[INFERRED / PLANNED — `Inferred from implementation — requires business confirmation.`]

## 5. Mandatory caveats

- Do **not** describe production as running; it is not.
- No UAT, security assessment or formal sign-off has been executed. [VERIFIED — `EVIDENCE-BASIS.md` §12]
- `application-prod.yml` exists but is unexercised; treat any production behaviour as unverified.

[TBD] Target cloud/on-prem provider, region, sizing, SLA, and go-live date — TBD — Requires confirmation. No evidence exists.
