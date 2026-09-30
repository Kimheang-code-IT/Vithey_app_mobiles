# Risk Register

> Status: Partially complete / Requires confirmation · Last reviewed: 2026-09-30
> Evidence: `docs/_meta/EVIDENCE-BASIS.md`, `plan.md`, `AGENTS.md`, `backend/`, `vithey_app/`, `ai_core/`, `.github/workflows/`, `monitoring/`, `docs/10-security/`
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

Part of the Vithey documentation set · Master index:
[`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) ·
Siblings: [Issue log](02-issue-log.md) · [Known limitations](03-known-limitations.md) ·
[Technical debt](04-technical-debt.md) · [Mitigation plan](05-mitigation-plan.md).

## 1. Scope and method

This register lists **forward-looking risks** (uncertain events that could harm delivery or
quality). It is deliberately kept separate from [current issues](02-issue-log.md) (things already
known to be defective), [known limitations](03-known-limitations.md) (accepted behaviour), and
[technical debt](04-technical-debt.md) (structural shortcuts).

- **Impact** and **Likelihood** use **High / Medium / Low** as a triage aid only; they are not the
  output of a formal risk assessment.
- **Owner** is `TBD` where no accountable person is evidenced.
- No formal risk assessment or risk-acceptance record exists; all ratings are [INFERRED] and
  **require confirmation**.
- A risk may share an underlying cause with an issue; cross-references are given.

## 2. Risk register

| ID | Risk | Category | Impact | Likelihood | Mitigation | Owner | Status | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| R-01 | Duplicate Flyway version `V3` in career-service prevents deterministic migration on a clean `career_db`; fresh environments or DB resets fail | Data / Migration | High | High | Rename one `V3` file to an unused version after confirming it was never applied under that version; coordinate with DB reset or `flyway repair`; never edit applied files | Kim heang [I] | Open | two `V3__*.sql` files in `backend/services/career-service/.../db/migration/`; `EVIDENCE-BASIS.md` §8; [Issue I-01](02-issue-log.md) |
| R-02 | `UserCv` entity `@Id` maps `user_id` while DB PK is `id`, causing incorrect JPA identity/proxy semantics | Data / Code | Medium | Medium | Map `id` as `@Id` and add a unique constraint on `user_id`, or add `id` consistently; add regression test | Kim heang [I] | Open | `UserCv.java`; `V1__init_career_schema.sql`; [Issue I-02](02-issue-log.md) |
| R-03 | user-profile trigram GIN index is never created (name collision + `IF NOT EXISTS`), so user search does not use the intended optimiser | Performance / Data | Low | High | Add a migration that drops and recreates the expression index (`LOWER(full_name)`) or renames it; verify with `EXPLAIN` | Kim heang [I] | Open | `V1__init_profile_schema.sql:30`, `V3__Enable_pg_trgm...sql:7`; [Issue I-03](02-issue-log.md) |
| R-04 | Java enums are a subset of DB CHECK-permitted values; reading DB-only states can raise enum conversion errors | Data / Code | Medium | Medium | Extend enums to match DB or tighten CHECK constraints per service; add tests | Kim heang [I] | Open | `EVIDENCE-BASIS.md` §8.4; `05-data-dictionary.md` §1 |
| R-05 | `*SmokeIT` Testcontainers tests are not run by plain `mvn test` (no Failsafe), so integration regressions escape CI | Quality | High | High | Add Maven Failsafe config so `*IT` run in `verify`; wire into CI | Kim heang [I] | Open | `EVIDENCE-BASIS.md` §8.5, §10; `AGENTS.md`; [Issue I-05](02-issue-log.md) |
| R-06 | No Alertmanager, so Prometheus alert rules have no notification route; incidents go unseen | Observability | Medium | High | Deploy Alertmanager and configure receivers/routes; test an alert end-to-end | TBD | Open | `monitoring/`; `EVIDENCE-BASIS.md` §9 |
| R-07 | Prometheus scrapes only 8 services; eureka, config, map and `ai_core` are not scraped | Observability | Medium | High | Add scrape targets for the missing components and dashboards/alerts for them | Kim heang [I] | Open | `monitoring/prometheus/prometheus.yml`; `EVIDENCE-BASIS.md` §9 |
| R-08 | Android release builds sign with **debug keys**; a distributed build would be invalid and insecure | Release / Security | High | High | Configure a release keystore and signing config before any distribution | Kim heang [I] | Open | `vithey_app/android/app/build.gradle` TODO; VA-15; [Issue I-08](02-issue-log.md) |
| R-09 | Vithey AI chat is a **stub**; expectation of a real assistant is unmet | AI / Product | Medium | High | Treat stub as scoped; document clearly; wire a real LLM/RAG only if in scope | Kim heang [I] | Open | `AI_CHAT_MODE=stub`; `docs/09-ai/11-ai-limitations.md` §1 |
| R-10 | FCM push and Google sign-in are stubs; device push and Google login do not work | AI / Product | Medium | High | Implement or explicitly mark out of scope; document for demo | TBD | Open | `EVIDENCE-BASIS.md` §7; [Known limitation L-04](03-known-limitations.md) |
| R-11 | No staging or production environment exists; release behaviour is unvalidated outside a local demo | Environment | High | High | Define and provision staging + production; add deploy runbook | TBD | Open | `EVIDENCE-BASIS.md` §9, §12 |
| R-12 | No automated backup/restore; data loss is unrecoverable beyond volume snapshots | Operations / Data | High | Medium | Establish scheduled `pg_dump`/volume backups + restore drills; define RPO/RTO | TBD | Open | `docs/05-database/08-backup-restore.md`; [Issue I-10](02-issue-log.md) |
| R-13 | `ai_core` caches/rate-limits are in-process; a single worker or multi-replica setup multiplies budget and loses cache | Performance / AI | Medium | Medium | Keep 1 worker for demo; use a shared store before scaling | KosalChansothay [I] | Open | `ai_core/vithey_ai/cache.py`, `ratelimit.py`; `docs/09-ai/11-ai-limitations.md` §3 |
| R-14 | Service config is baked into the config-server image; config changes require an image rebuild and risk drift | DevOps | Medium | Medium | Mount config-repo in non-image environments or rebuild on change; single-source config | Ponloeng Bora [I] | Open | `AGENTS.md`; `EVIDENCE-BASIS.md` §4 |
| R-15 | `/api/v1/students/verify` is routed but not in the public matcher, so it requires a JWT contrary to intent | Security / API | Low | High | Decide intended auth requirement and align code with `api_docs.md` | Ponloeng Bora [I] | Open | `PublicPathMatcher.java`; `api-gateway.yml`; VA-09; [Issue I-09](02-issue-log.md) |
| R-16 | No formal security assessment or penetration test; residual risk is unquantified | Security / Governance | High | High | Commission a threat model and pen test before any exposure; then record risk acceptance | TBD | Open | `docs/10-security/11-security-review-report.md`; `EVIDENCE-BASIS.md` §12 |
| R-17 | LLM dependency (provider/key) can be slow, unavailable, or cost overrun | AI / Vendor | Medium | Medium | Timeouts, retries, input caps, rate limits, extraction cache; monitor usage; clear errors | KosalChansothay [I] | Open | `ai_core/vithey_ai/deepseek_client.py`; `plan.md` §3.5/§10 |
| R-18 | Single-PC resource exhaustion (OOM) with all services live under memory caps | Performance | Medium | Medium | Env-driven caps, small JVM heaps, SerialGC; recommend ≥16 GB; prefer phone over emulator | Kim heang [I] | Open | `plan.md` §3; `backend/.env.example` |
| R-19 | Flutter test coverage is thin (3 files); regressions may ship uncaught | Quality | Medium | High | Expand widget/unit/integration tests for auth, chat, finance, jobs, profile, AI | Kim heang [I] | Open | `EVIDENCE-BASIS.md` §10; [Issue I-19](02-issue-log.md) |
| R-20 | No CI workflow for map-service or infrastructure; changes there are not built/validated | DevOps / Quality | Medium | Medium | Add per-service workflow(s) for map-service and infra | Kim heang [I] | Open | `.github/workflows/`; [Issue I-20](02-issue-log.md) |
| R-21 | Public-path policy is duplicated across gateway and 9 services; drift can create auth gaps | Security | Medium | Medium | Single-source the public-path policy (shared module or generated config) | Ponloeng Bora [I] | Open | VA-10; `PublicPathMatcher.java` + `SecurityConfig.java` |
| R-22 | Service ports must never be directly reachable (service filters trust `X-User-*` headers) | Security | High | Low | Network-isolate service ports; validate the assumption; require signed internal credential | TBD | Open | VA-01; `docs/10-security/10-vulnerability-assessment.md` |
| R-23 | Docs drift from code (stale README/DOCKER sections; `plan.md` historical `ai-service` sections) | Documentation | Low | High | Reconcile docs with code; treat `plan.md` update banner as authoritative | Kim heang [I] | Open | `AGENTS.md`; `docs/05-database/06-migration-strategy.md`; CR-07 |
| R-24 | Governance gap: no meeting minutes, no formal approvals, no risk-acceptance records | Governance | Medium | High | Establish minute/decision/approval process; see [meeting minutes](../02-project-management/10-meeting-minutes/README.md) | TBD | Open | `EVIDENCE-BASIS.md` §12; `../02-project-management/10-meeting-minutes/README.md` |
| R-25 | Gateway route/path definitions are duplicated between local `application.yml` and `config-repo`; drift can misroute | DevOps | Low | Medium | Single-source route config; remove local duplication | Ponloeng Bora [I] | Open | `Action_Plan_Vithey.csv` 6.1 remark; `config-repo/api-gateway.yml` |

## 3. Risk counts (triage aid only)

| Impact | Count |
| --- | --- |
| High | 7 |
| Medium | 14 |
| Low | 4 |

> Counts derived from the table; ratings are [INFERRED] and not the product of a formal assessment.

## 4. Open items

- Assign an owner and review cadence for every `TBD` owner: [TBD] TBD — Requires confirmation.
- Formal risk scoring methodology and acceptance authority: [TBD] TBD — Requires confirmation.

## 5. Cross-links

- [Issue log](02-issue-log.md) · [Known limitations](03-known-limitations.md) · [Technical debt](04-technical-debt.md) · [Mitigation plan](05-mitigation-plan.md)
- [Project status report](../02-project-management/07-project-status-report.md)
