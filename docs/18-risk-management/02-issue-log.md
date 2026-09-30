# Issue Log

> Status: Partially complete / Requires confirmation · Last reviewed: 2026-09-30
> Evidence: `docs/_meta/EVIDENCE-BASIS.md` §5/§8/§9/§10/§12, `backend/`, `vithey_app/`, `ai_core/`, `monitoring/`, `.github/workflows/`, `docs/10-security/`
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

Part of the Vithey documentation set · Master index:
[`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) ·
Siblings: [Risk register](01-risk-register.md) · [Known limitations](03-known-limitations.md) ·
[Technical debt](04-technical-debt.md) · [Mitigation plan](05-mitigation-plan.md).

## 1. Scope

This log records **current issues**: matters already known to be defective, missing, or
unresolved in the repository at report time. It is separate from the [risk register](01-risk-register.md)
(future uncertainties), [known limitations](03-known-limitations.md) (accepted behaviour) and
[technical debt](04-technical-debt.md) (structural shortcuts).

- Severity is a triage aid (High / Medium / Low), not a formal assessment.
- Owner is `TBD` where unknown.
- No issue has a formal resolution record in the repository.

## 2. Issue log

| ID | Issue | Category | Severity | Status | Owner | Opened (evidence-derived) | Evidence | Related risk |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| I-01 | career-service has **two Flyway files with version `V3`**, so a clean `career_db` cannot migrate deterministically | Data / Migration | High | Pending Review | Kim heang [I] | TBD | `V3__Job_application_composite_indexes_and_status_check.sql` + `V3__User_cv_file_unique_and_application_fk.sql`; `EVIDENCE-BASIS.md` §8.1 | R-01 |
| I-02 | career `UserCv` entity `@Id` maps `user_id` while the DB PK is `id` | Data / Code | Medium | Open | Kim heang [I] | TBD | `UserCv.java`; `V1__init_career_schema.sql:2`; `EVIDENCE-BASIS.md` §8.2 | R-02 |
| I-03 | user-profile trigram index is a **no-op**; `IF NOT EXISTS` short-circuits the intended `LOWER(full_name)` GIN index | Performance / Data | Low | Open | Kim heang [I] | TBD | `V1__init_profile_schema.sql:30`; `V3__Enable_pg_trgm_and_full_name_gin_index.sql:7`; `EVIDENCE-BASIS.md` §8.3 | R-03 |
| I-04 | Enum vs DB CHECK **supersets** in career/content/chat/finance/notification | Data / Code | Medium | Open | Kim heang [I] | TBD | `EVIDENCE-BASIS.md` §8.4; `docs/05-database/05-data-dictionary.md` §1 | R-04 |
| I-05 | `*SmokeIT` Testcontainers tests are **not run by plain `mvn test`** (no Failsafe config) | Quality | High | Open | Kim heang [I] | TBD | `EVIDENCE-BASIS.md` §8.5, §10; `AGENTS.md` | R-05 |
| I-06 | **No Alertmanager**; alert rules have no delivery mechanism | Observability | Medium | Open | TBD | TBD | `monitoring/`; `EVIDENCE-BASIS.md` §9 | R-06 |
| I-07 | Prometheus **does not scrape** eureka-server, config-server, map-service or `ai_core` | Observability | Medium | Open | Kim heang [I] | TBD | `monitoring/prometheus/prometheus.yml`; `EVIDENCE-BASIS.md` §9 | R-07 |
| I-08 | Android **release signs with debug keys** | Release / Security | High | Open | Kim heang [I] | TBD | `vithey_app/android/app/build.gradle` TODO; VA-15 | R-08 |
| I-09 | `/api/v1/students/verify` is routed but **not in the gateway public matcher**, so it requires a JWT | Security / API | Low | Open | Ponloeng Bora [I] | TBD | `PublicPathMatcher.java`; `config-repo/api-gateway.yml`; VA-09 | R-15 |
| I-10 | **No automated backup or restore**; only manual volume snapshots are possible | Operations | High | Open | TBD | TBD | `docs/05-database/08-backup-restore.md` | R-12 |
| I-11 | `ai_core` extraction cache, LLM rate limiter and HTTP limiter are **single-worker in-process** | Performance / AI | Medium | Open | KosalChansothay [I] | TBD | `ai_core/vithey_ai/cache.py`, `ratelimit.py`; `docs/09-ai/11-ai-limitations.md` §3 | R-13 |
| I-12 | Service runtime config is **baked into the config-server image**; changes need a rebuild | DevOps | Medium | Open | Ponloeng Bora [I] | TBD | `AGENTS.md`; `EVIDENCE-BASIS.md` §4 | R-14 |
| I-13 | Vithey AI **chat is a stub** (`AI_CHAT_MODE` read but never branched on) | Product / AI | Medium | Open | KosalChansothay [I] | TBD | `docs/09-ai/11-ai-limitations.md` §1 | R-09 |
| I-14 | **FCM push** (commented out) and **Google sign-in** (mock UI only) are stubs | Product | Medium | Open | TBD | TBD | `EVIDENCE-BASIS.md` §7 | R-10 |
| I-15 | **No staging and no production deployment** exist | Environment | High | Open | TBD | TBD | `EVIDENCE-BASIS.md` §9, §12 | R-11 |
| I-16 | **No formal security assessment / pen test**; residual risk unquantified | Security / Governance | High | Open | TBD | TBD | `docs/10-security/11-security-review-report.md` | R-16 |
| I-17 | **UAT has not been executed**; no plan, log or sign-off | Governance | High | Open | TBD | TBD | `EVIDENCE-BASIS.md` §12; `docs/12-uat/` | R-24 |
| I-18 | **No demo seed-data script** exists although `plan.md` §4.5 requests 10 seed accounts | Data / Demo | Medium | Open | TBD | TBD | `Action_Plan_Vithey.csv` 4.11; `plan.md` §4.5 | R-11 |
| I-19 | Flutter test coverage is **thin** (3 files) | Quality | Medium | In Progress | Kim heang [I] | TBD | `EVIDENCE-BASIS.md` §10; `Action_Plan_Vithey.csv` 14.5 | R-19 |
| I-20 | **No CI workflow for map-service or infrastructure**; map-service has no context/smoke IT | DevOps / Quality | Medium | Open | Kim heang [I] | TBD | `.github/workflows/`; `EVIDENCE-BASIS.md` §10 | R-20 |
| I-21 | **Post update endpoint missing**: Flutter `updatePost` receives 404 (no PATCH `/posts/{id}`) | API / Functional | Medium | Open | Kim heang [I] | TBD | `Action_Plan_Vithey.csv` 15.2 | (see [TD-04](04-technical-debt.md)) |
| I-22 | **Non-compiling WIP branch** with ~7 missing files (e.g. `auth_genz_tokens.dart`) | Build / VCS | Low | Blocked | TBD | TBD | `Action_Plan_Vithey.csv` 15.5 | R-23 |
| I-23 | **Stale docs** (retired `ai-service` references; Flutter README mock guidance) | Documentation | Medium | In Progress | Kim heang [I] | TBD | `Action_Plan_Vithey.csv` 15.4; `AGENTS.md` | R-23 |
| I-24 | Gateway route/path definitions **duplicated** between local `application.yml` and `config-repo` | DevOps | Low | Open | Ponloeng Bora [I] | TBD | `Action_Plan_Vithey.csv` 6.1 remark; `config-repo/api-gateway.yml` | R-25 |
| I-25 | `cv_app_service.to_draft` field mismatch can **drop skills/experience fields** in the Flutter CV draft | Functional / AI | Medium | Open | KosalChansothay [I] | TBD | `ai_core/vithey_ai/cv_app_service.py`; `docs/09-ai/11-ai-limitations.md` §2 | R-09 |
| I-26 | **Governance gap**: no meeting minutes, no formal approvals, no risk-acceptance records | Governance | Medium | Open | TBD | TBD | `EVIDENCE-BASIS.md` §12; `../02-project-management/10-meeting-minutes/README.md` | R-24 |

## 3. Severity summary (triage aid only)

| Severity | IDs | Count |
| --- | --- | --- |
| High | I-01, I-05, I-08, I-10, I-15, I-16, I-17 | 7 |
| Medium | I-02, I-04, I-06, I-07, I-11, I-12, I-13, I-14, I-18, I-19, I-20, I-21, I-23, I-25, I-26 | 15 |
| Low | I-03, I-09, I-22, I-24 | 4 |

> Counts are [INFERRED] from repository evidence; not the output of a formal assessment.

## 4. Open items

- Owner and target date for each High-severity issue: [TBD] TBD — Requires confirmation.
- Whether any issue has an informal fix in a branch outside `main`/`dev`: [TBD] TBD — Requires confirmation.

## 5. Cross-links

- [Risk register](01-risk-register.md) · [Known limitations](03-known-limitations.md) · [Technical debt](04-technical-debt.md) · [Mitigation plan](05-mitigation-plan.md)
- [Vulnerability assessment](../10-security/10-vulnerability-assessment.md) · [Migration strategy](../05-database/06-migration-strategy.md)
