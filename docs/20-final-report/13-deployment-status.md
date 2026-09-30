# Deployment Status

> Status: Partially complete — local only · Last reviewed: 2026-09-30
> Evidence: `backend/docker-compose.demo.yml`, `backend/scripts/`, `.github/workflows/`, `.github/workflows/ci-promote-dev.yml`, `monitoring/`
> Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)

## 1. Headline

**Only local environments exist.** Vithey runs on a developer's computer as a local development
setup and as the "Profile M" local demo. **Staging and production do not exist.** No Kubernetes,
Helm, Terraform, or Jenkins is present; `application-prod.yml` exists but nothing activates it in
CI. [VERIFIED] `../_meta/EVIDENCE-BASIS.md` §9

## 2. Environment status

| Environment | Status | Evidence |
| --- | --- | --- |
| Local development | Local development (verified) | `backend/scripts/start-dev-host.ps1` |
| Local demo ("Profile M") | Local demo (verified) | `backend/scripts/docker-up-demo.ps1`, `backend/docker-compose.demo.yml` |
| Staging | Staging (does not exist) | No config, no workflow |
| Production | Production (does not exist) | `application-prod.yml` exists but is not activated |

## 3. Local demo mechanics

- One command starts the stack from `backend/`: `.\scripts\docker-up-demo.ps1` (base +
  `docker-compose.demo.yml` overlay). [VERIFIED]
- Resource caps (`mem_limit`, JVM flags, pool sizes) come from `backend/.env` / `.env.example`;
  defaults apply if `backend/.env` is absent. [VERIFIED]
- `map` and `monitoring` are opt-in Compose profiles. [VERIFIED]
- Teardown: `.\scripts\docker-down-demo.ps1` (add `-v` to wipe volumes). [VERIFIED]
- `ai_core` requires `ai_core/.env` with an API key; CV generation fails clearly without it. [VERIFIED]

## 4. Container images and CI

| Aspect | Status |
| --- | --- |
| Java Dockerfiles (multi-stage, non-root) | 12 images (services + infrastructure) [VERIFIED] |
| `ai_core` image (python:3.12-slim) | Implemented [VERIFIED] |
| Flutter image | None (client is built separately) |
| Per-service CI workflows | 9 workflows: test → docker build → compose validate [VERIFIED] |
| Promotion pipeline | `ci-promote-dev.yml`: backend + Flutter + ai_core tests → build/push 13 images to GHCR → fast-forward passing commit to `dev` [VERIFIED] |
| Registry | `ghcr.io/<owner>/vithey-<service>`, tags `latest`, `sha-<short>` [VERIFIED] |
| CI workflow for map-service / infrastructure | None [VERIFIED] |

## 5. Monitoring

- Profile-gated (`--profile monitoring`); nothing starts without it. [VERIFIED]
- Prometheus scrapes `/actuator/prometheus` for 8 services (not eureka/config/map/ai_core).
- Alerts are defined but there is **no Alertmanager**. [VERIFIED]
- Grafana dashboards are provisioned; Loki retains logs for 168 hours. [VERIFIED]

## 6. Deployment readiness assessment

| Question | Answer |
| --- | --- |
| Can a developer run the demo locally? | Yes — evidenced by scripts and Compose. [VERIFIED] |
| Has the demo been executed and verified for this report? | No — not independently verified. |
| Is there a staging environment? | No. |
| Is there a production environment? | No. |
| Is the release signed for distribution? | No — Android release signs with debug keys. [VERIFIED] |
| Is TLS enforced anywhere? | No — local HTTP only. [VERIFIED] |

## 7. What must be added for staging/production

1. A bank-approved hosting target and environment configuration (activate a real prod profile).
2. TLS termination and secrets management appropriate to the environment.
3. Real Android release signing and store/distribution path.
4. Failsafe-wired smoke tests and an E2E gate in CI.
5. Alertmanager (or equivalent) and production dashboards.
6. Network isolation proof for service ports (per security recommendations).

## 8. Related documents

- [`12-security-summary.md`](12-security-summary.md) · [`17-recommendations.md`](17-recommendations.md) · [`15-outstanding-items.md`](15-outstanding-items.md)
- [`../03-system-design/07-network-architecture.md`](../03-system-design/07-network-architecture.md)
