# Technical Debt

> Status: Partially complete / Requires confirmation · Last reviewed: 2026-09-30
> Evidence: `docs/_meta/EVIDENCE-BASIS.md` §6/§8/§9/§10, `backend/`, `vithey_app/`, `ai_core/`, `.github/workflows/`, `docs/10-security/`
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

Part of the Vithey documentation set · Master index:
[`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) ·
Siblings: [Risk register](01-risk-register.md) · [Issue log](02-issue-log.md) ·
[Known limitations](03-known-limitations.md) · [Mitigation plan](05-mitigation-plan.md).

## 1. Scope

**Technical debt** is a structural shortcut or deferred cleanup that has a future cost. It is kept
separate from [issues](02-issue-log.md) (current defects), [risks](01-risk-register.md) (future
uncertainties) and [limitations](03-known-limitations.md) (accepted behaviour). Some items share a
root cause with issues; cross-references are given.

Priority is a triage aid (High / Medium / Low), not a formal assessment.

## 2. Debt register

| ID | Debt item | Area | Origin (why it exists) | Cost / future work | Priority | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| TD-01 | Duplicate Flyway `V3` in career-service | Database | Two migrations authored under the same version | Requires a coordinated rename + DB reset/`flyway repair`; blocks reproducible `career_db` | High | [I-01](02-issue-log.md); `EVIDENCE-BASIS.md` §8.1 |
| TD-02 | `UserCv @Id` maps `user_id` while PK is `id` | JPA / Data | Entity written before schema settled | Fix mapping + add unique constraint; add regression test | High | [I-02](02-issue-log.md); `docs/05-database/06-migration-strategy.md` §4 |
| TD-03 | user-profile trigram index no-op | Database | `IF NOT EXISTS` name collision | New migration to drop/recreate the expression index; verify with `EXPLAIN` | Medium | [I-03](02-issue-log.md) |
| TD-04 | Missing `PATCH /posts/{id}`; client `updatePost` gets 404 | API / Client | Endpoint never built | Implement update endpoint or remove client path; align `api_docs.md` | Medium | `Action_Plan_Vithey.csv` 15.2; [I-21](02-issue-log.md) |
| TD-05 | `*SmokeIT` not wired (no Maven Failsafe) | Test harness | Surefire-only default build | Add Failsafe config so `*IT` run in `verify`; wire into CI | High | [I-05](02-issue-log.md); `EVIDENCE-BASIS.md` §10 |
| TD-06 | No CI workflow for map-service or infrastructure | CI | Added later than the 9-service workflows | Add workflows; map-service lacks context/smoke IT | Medium | [I-20](02-issue-log.md); `Action_Plan_Vithey.csv` 5.7 |
| TD-07 | Gateway routes duplicated (local `application.yml` vs `config-repo`) and public paths duplicated across 10 places | Config / Security | Incremental edits | Single-source route and public-path policy | Medium | [I-24](02-issue-log.md); [I-09](02-issue-log.md); VA-10 |
| TD-08 | Service config baked into the config-server image | DevOps | Image-based config distribution | Rebuild on every config change; drift risk | Medium | [I-12](02-issue-log.md); `AGENTS.md` |
| TD-09 | In-memory caches / rate limiters in `ai_core` (and Redis used imperatively, no Spring Cache) | Performance | Demo-scale choices | Externalise to a shared store before scaling | Medium | [I-11](02-issue-log.md); `EVIDENCE-BASIS.md` §4 |
| TD-10 | Two AI response envelopes and legacy non-gateway routes | API / AI | Layered evolution of `ai_core` | Normalise envelope; retire or gateway-route legacy paths | Low | `docs/09-ai/11-ai-limitations.md` §5–§6 |
| TD-11 | `ai_db` schema created by `CREATE TABLE IF NOT EXISTS`, not Flyway | Database / AI | Python-owned tables | No migration history; add versioned management or document ownership | Low | `docs/09-ai/11-ai-limitations.md` §4 |
| TD-12 | Thin Flutter test coverage (3 files) | Quality | UI-first delivery | Expand widget/unit/integration tests | High | [I-19](02-issue-log.md); `EVIDENCE-BASIS.md` §10 |
| TD-13 | Android release signed with debug keys | Release | Placeholder signing | Configure release keystore/signing | High | [I-08](02-issue-log.md); VA-15 |
| TD-14 | Hardcoded English strings; no `.arb` i18n | Client | MVP | Introduce localisation framework | Low | `EVIDENCE-BASIS.md` §7 |
| TD-15 | Enum vs DB CHECK superset drift | Data | Schema and enums evolved separately | Reconcile per service; keep contract tests | Medium | [I-04](02-issue-log.md); `EVIDENCE-BASIS.md` §8.4 |
| TD-16 | No code-coverage config (no JaCoCo) | Quality | Not set up | Add coverage reporting and thresholds | Low | `EVIDENCE-BASIS.md` §10 |
| TD-17 | No dependency/secret/image scanning in CI | Security / Supply chain | Not set up | Add Dependabot/OSV + gitleaks + image scanning | Medium | VA-16 |
| TD-18 | Manual-only backups; no retention/RPO/RTO | Operations | Demo scope | Automate backups and define DR objectives | High | [I-10](02-issue-log.md); `docs/05-database/08-backup-restore.md` |
| TD-19 | Stale docs (retired `ai-service`, README mock guidance, `plan.md` historical sections) | Documentation | Rapid iteration | Reconcile docs with code | Medium | [I-23](02-issue-log.md); `Action_Plan_Vithey.csv` 15.4 |
| TD-20 | No structured audit logging or security headers at the gateway | Security | Not built | Add audit logging + security-header filter | Low | VA-17, VA-18 |

## 3. Priority summary (triage aid only)

| Priority | IDs | Count |
| --- | --- | --- |
| High | TD-01, TD-02, TD-05, TD-12, TD-13, TD-18 | 6 |
| Medium | TD-03, TD-04, TD-06, TD-07, TD-08, TD-09, TD-15, TD-17, TD-19 | 9 |
| Low | TD-10, TD-11, TD-14, TD-16, TD-20 | 5 |

> Counts are [INFERRED] from repository evidence; not a formal assessment.

## 4. Open items

- Debt-owner and repayment schedule: [TBD] TBD — Requires confirmation.
- Whether any debt is formally accepted: [TBD] TBD — Requires confirmation.

## 5. Cross-links

- [Risk register](01-risk-register.md) · [Issue log](02-issue-log.md) · [Known limitations](03-known-limitations.md) · [Mitigation plan](05-mitigation-plan.md)
- [Vulnerability assessment](../10-security/10-vulnerability-assessment.md) · [Test strategy](../11-testing/01-test-strategy.md)
