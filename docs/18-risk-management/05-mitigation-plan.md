# Mitigation Plan

> Status: Requires confirmation · Last reviewed: 2026-09-30
> Evidence: [Risk register](01-risk-register.md), [Issue log](02-issue-log.md), [Known limitations](03-known-limitations.md), [Technical debt](04-technical-debt.md), `plan.md` §10, `docs/_meta/EVIDENCE-BASIS.md`
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

Part of the Vithey documentation set · Master index:
[`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) ·
Siblings: [Risk register](01-risk-register.md) · [Issue log](02-issue-log.md) ·
[Known limitations](03-known-limitations.md) · [Technical debt](04-technical-debt.md).

## 1. Purpose and caveat

This plan turns the registers into concrete actions, ordered by priority. **No action here has an
agreed owner or date** — owners are `TBD` where not evidenced and all target dates are
`TBD — Requires confirmation.` Steps are written to be verifiable; none claim completion.

Priority bands:
- **P0** — blocks a trustworthy or distributable delivery (data integrity, release readiness, security baseline).
- **P1** — materially improves reliability, observability or quality.
- **P2** — cleanup, hardening and governance.

## 2. P0 — delivery-blocking

| # | Action | Addresses | Concrete step | Owner | Target | Verification |
| --- | --- | --- | --- | --- | --- | --- |
| M-01 | Resolve career duplicate Flyway `V3` | R-01, I-01, TD-01 | Rename one `V3__*.sql` to an unused version after confirming it was not applied under that version; rebuild `career_db` from scratch with `docker-down-demo.ps1 -v` and confirm `spring.flyway` applies cleanly | Kim heang [I] | TBD | Clean `career_db` migrates with distinct versions; `mvn -pl services/career-service -am test` green |
| M-02 | Fix `UserCv @Id` mapping | R-02, I-02, TD-02 | Map `id` as `@Id` (or add `id` consistently) and add a unique constraint on `user_id`; add a repository test for `findById` | Kim heang [I] | TBD | Career service tests pass; Hibernate `validate` passes |
| M-03 | Wire `*SmokeIT` into the build | R-05, I-05, TD-05 | Add Maven Failsafe config; run `mvn verify` with Docker; add to CI | Kim heang [I] | TBD | `*IT` execute under `verify`; CI log shows smoke runs |
| M-04 | Configure release signing (Android) | R-08, I-08, TD-13 | Create a release keystore, configure `signingConfigs.release`, remove the debug-key TODO | Kim heang [I] | TBD | `flutter build apk --release` signed with the release key |
| M-05 | Establish backup/restore | R-12, I-10, TD-18 | Script scheduled `pg_dump` per DB and MinIO sync; document restore; define RPO/RTO | TBD | TBD | A restore drill succeeds on a clean host |
| M-06 | Commission security assessment | R-16, I-16 | Threat model + pen test; record findings and risk acceptance | TBD | TBD | Written assessment report + sign-off |

## 3. P1 — reliability, observability, quality

| # | Action | Addresses | Concrete step | Owner | Target | Verification |
| --- | --- | --- | --- | --- | --- | --- |
| M-07 | Add Alertmanager + close scrape gaps | R-06, R-07, I-06, I-07 | Add Alertmanager with receivers; add scrape targets for eureka/config/map/`ai_core`; add dashboards | Kim heang [I] | TBD | Test alert fires and is delivered; all targets UP |
| M-08 | Fix enum/DB CHECK supersets | R-04, I-04, TD-15 | Reconcile enums vs CHECK per service; add tests | Kim heang [I] | TBD | No DB-only state can reach an enum converter |
| M-09 | Decide and align `/students/verify` auth | R-15, I-09 | Choose intended auth and align `PublicPathMatcher` + `api_docs.md` | Ponloeng Bora [I] | TBD | Endpoint auth matches documentation |
| M-10 | Reconcile route/public-path definitions | R-21, R-25, I-24, TD-07 | Single-source gateway routes and public paths | Ponloeng Bora [I] | TBD | One config source; gateway tests pass |
| M-11 | Expand Flutter tests | R-19, I-19, TD-12 | Add widget/unit tests for auth, chat, finance, jobs, profile, AI, repositories | Kim heang [I] | TBD | `flutter test` covers main modules (coverage report) |
| M-12 | Add map-service/infra CI + tests | R-20, I-20, TD-06 | Add workflow(s); add map-service ContextTest/SmokeIT | Kim heang [I] | TBD | CI builds and tests map-service |
| M-13 | Fix `to_draft` field mapping | I-25 | Align `to_draft` keys with normalizer output (`skills`, `bullets`) | KosalChansothay [I] | TBD | CV draft retains skills/experience |
| M-14 | Fix trigram index | R-03, I-03, TD-03 | New migration drop/recreate `LOWER(full_name)` GIN | Kim heang [I] | TBD | `EXPLAIN` shows index use |
| M-15 | Execute test suites and record results | (all) | Run backend, Flutter and `ai_core` suites; record pass/fail as evidence | Kim heang [I] | TBD | Test-result record per suite |

## 4. P2 — cleanup, hardening, governance

| # | Action | Addresses | Concrete step | Owner | Target | Verification |
| --- | --- | --- | --- | --- | --- | --- |
| M-16 | Reconcile stale docs | R-23, I-23, TD-19 | Remove retired `ai-service` references; fix README mock guidance; mark `plan.md` historical sections | Kim heang [I] | TBD | No links to retired service; README matches `.env.example` |
| M-17 | Externalise caches/limits | R-13, I-11, TD-09 | Share a store for cache/rate-limit before multi-worker | KosalChansothay [I] | TBD | Correct limits under >1 worker |
| M-18 | Add scanning + coverage | TD-16, TD-17 | Add Dependabot/OSV, gitleaks, image scanning, JaCoCo | Kim heang [I] | TBD | CI reports scans and coverage |
| M-19 | Add audit logging + security headers | TD-20 | Gateway security-header filter; structured auth/authorization logs | Ponloeng Bora [I] | TBD | Headers present; events logged |
| M-20 | Establish governance records | R-24, I-17, I-26 | Adopt minute/decision/change templates; execute UAT and record sign-off | TBD | TBD | Minutes, UAT log, sign-off exist |
| M-21 | Recover non-compiling WIP branch | I-22 | Restore missing files so `wip/stash-20260829` analyses cleanly | TBD | TBD | `flutter analyze` clean on that branch |
| M-22 | Decide placeholder fate | I-14, L-04, L-05, L-06 | Implement Google auth/FCM/2FA/biometric or mark out of scope | TBD | TBD | Each placeholder implemented or documented |

## 5. Owner assignments required

Every action with a `TBD` owner, and every unowned High-severity item, needs a named accountable
person and a target date. Status: [TBD] TBD — Requires confirmation.

## 6. Cross-links

- [Risk register](01-risk-register.md) · [Issue log](02-issue-log.md) · [Known limitations](03-known-limitations.md) · [Technical debt](04-technical-debt.md)
- [Project action plan](../02-project-management/02-action-plan.md) · [Project status report](../02-project-management/07-project-status-report.md)
