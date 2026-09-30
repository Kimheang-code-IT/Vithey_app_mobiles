# Decision Log

> Status: Partially complete / Requires confirmation · Last reviewed: 2026-09-30
> Evidence: `plan.md` §0/§13, `AGENTS.md`, `api_docs.md`, `backend/infrastructure/config-repo/*.yml`, `ai_core/`, `docs/_meta/EVIDENCE-BASIS.md`
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

Part of the Vithey documentation set · Master index:
[`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) ·
Sibling: [Change request log](08-change-request-log.md) · [Project plan](01-project-plan.md) · [Risk register](../18-risk-management/01-risk-register.md).

## 1. How to read

Each decision is tagged:
- **[VERIFIED] documented** — the decision is stated in a tracked repository document or config.
- **[VERIFIED] implemented** — the decision is reflected in code/config even if not formally written.
- **[INFERRED]** — implied by implementation; requires business confirmation.

No decision has a formal approval record (no dated sign-off was found). Approvals are `TBD`.

## 2. Decision register

| ID | Decision | Rationale / scope | Evidence | Status | Decider |
| --- | --- | --- | --- | --- | --- |
| D-01 | Deliver a **local demo only** using **"Profile M"** (all Vithey domain services live; ~10 concurrent users; one PC) | Time/resource-bounded competition demo; no cluster | `plan.md` §0, §3.2 | [VERIFIED] documented | [TBD] |
| D-02 | **Python `ai_core` owns the entire `/api/v1/ai/**` surface** (chat + CV); the Java `ai-service` is retired | Simplify AI deployment; single AI surface behind the gateway | `plan.md` update banner; `AGENTS.md`; `api_docs.md` §10; `ai_core/vithey_ai/api/flutter_routes.py` | [VERIFIED] documented + implemented | [TBD] |
| D-03 | **GDCE / `general-service` RAG is out of scope**; Vithey AI chat is a topic **stub** | Avoid a second AI stack; no RAG for the demo | `plan.md` §8; `AGENTS.md`; `AI_CHAT_MODE=stub` | [VERIFIED] documented + implemented | [TBD] |
| D-04 | LLM access uses the `DEEPSEEK_*` env names but defaults to **OpenRouter GLM** (`z-ai/glm-5.3-flash`); API key only, no local GPU/LLM | Cost/speed; keep env names for legacy compatibility | `AGENTS.md`; `ai_core/vithey_ai/config.py`; `EVIDENCE-BASIS.md` §6 | [VERIFIED] implemented | [TBD] |
| D-05 | **One PostgreSQL instance per environment hosting per-service databases** (no shared schema); demo uses one shared Postgres container | Isolation per service with simple local ops | `init-databases.sql`; `config-repo/*.yml`; `plan.md` §3.4/§8 | [VERIFIED] implemented | [TBD] |
| D-06 | **RabbitMQ only** for async messaging on a single topic exchange `vithey.events`; **no Kafka** | Simpler single-broker demo; adequate for event notifications | `backend/services/*/event/*`; `EVIDENCE-BASIS.md` §4 | [VERIFIED] implemented | [TBD] |
| D-07 | The Flutter client calls **only the API gateway** (`/api/v1/**`); never `ai_core` or the LLM directly | Single security/entry boundary | `AGENTS.md`; `api-gateway.yml`; `plan.md` §2 rule 1 | [VERIFIED] documented + implemented | [TBD] |
| D-08 | **Eureka** for service discovery and **Spring Cloud Config (native)** for centralized config, files in `config-repo/` | Standard Spring Cloud topology; native profile for local demo | `backend/infrastructure/`; `config-repo/*.yml` | [VERIFIED] implemented | [TBD] |
| D-09 | **JWT (HMAC/JJWT)** validated at the gateway and again per service (defense in depth); gateway injects `X-User-*` headers | Stateless auth; layered validation | `JwtAuthenticationGlobalFilter`, per-service `SecurityConfig` | [VERIFIED] implemented | [TBD] |
| D-10 | **`map-service` and `monitoring` are opt-in Compose profiles**, not removed files | Keep the lean demo light; enable on demand | `AGENTS.md`; `monitoring/README.md`; `docker-compose.demo.yml` | [VERIFIED] implemented | [TBD] |
| D-11 | **Resource caps are env-driven** from `backend/.env` / `.env.example`; never hardcoded in Compose | Fit the stack on one PC; tunable | `AGENTS.md`; `backend/.env.example`; `docker-compose.demo.yml` | [VERIFIED] implemented | [TBD] |
| D-12 | **Never edit an applied Flyway migration**; add a new version instead | Avoid checksum mismatches; reset local DBs with `-v` | `AGENTS.md`; `05-database/06-migration-strategy.md` | [VERIFIED] documented | [TBD] |
| D-13 | Flutter is **mock-first** (`USE_MOCK_*`, `FeatureFlags`), switching to live APIs module by module | Allow UI work before backends are healthy | `vithey_app/README.md`; `EVIDENCE-BASIS.md` §7 | [VERIFIED] implemented | [TBD] |
| D-14 | **Android release currently signs with debug keys** (explicit TODO) | Placeholder pending a release keystore | `android/app/build.gradle` TODO; VA-15 | [VERIFIED] implemented | [TBD] |
| D-15 | **CI auto-promotes passing commits** from `kimheang`/`main` to `dev` and publishes GHCR images | Continuous delivery to an integration branch | `.github/workflows/ci-promote-dev.yml` | [VERIFIED] documented + implemented | [TBD] |
| D-16 | **Exact production model/provider, retention and multi-worker cache strategy** | Not decided in-repo | `docs/09-ai/11-ai-limitations.md` §8/§10 | [TBD] TBD — Requires confirmation. | [TBD] |

## 3. Open decisions

| Question | Status |
| --- | --- |
| Production hosting target (bank-approved) and topology | [TBD] TBD — Requires confirmation. |
| Whether Vithey AI chat will ever be wired to a real LLM/RAG | [TBD] TBD — Requires confirmation. |
| Whether to add a shared cache/limiter store for multi-worker deployments | [TBD] TBD — Requires confirmation. |
| Fate of placeholders (Google auth, FCM, 2FA/biometric) | [TBD] TBD — Requires confirmation. |
| Release signing keystore ownership and custody | [TBD] TBD — Requires confirmation. |

## 4. Cross-links

- [Change request log](08-change-request-log.md) · [Project plan](01-project-plan.md) · [Action plan](02-action-plan.md)
- [AI limitations](../09-ai/11-ai-limitations.md) · [System architecture](../03-system-design/01-system-architecture.md)
