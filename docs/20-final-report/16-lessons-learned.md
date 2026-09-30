# Lessons Learned

> Status: Partially complete — retrospective from repository evidence · Last reviewed: 2026-09-30
> Evidence: `plan.md`, `AGENTS.md`, `Action_Plan_Vithey.csv`, `../_meta/EVIDENCE-BASIS.md`, `backend/`, `vithey_app/`, `ai_core/`
> Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)

> These lessons are drawn from **repository evidence and documented defects**. They are not
> attributions of fault and should be confirmed with the delivery team before adoption.

## 1. What worked well

| Lesson | Evidence |
| --- | --- |
| **A gateway-first architecture kept the client simple.** Flutter talks to one base URL, which made module-by-module mock-to-live switching practical. | `api_docs.md`, `vithey_app/lib/core/network/` |
| **Writing the API contract down early paid off.** `api_docs.md` is the single reference and matches the gateway route table. | `api_docs.md`, `config-repo/api-gateway.yml` |
| **Locking demo scope prevented scope creep.** The explicit "no GDCE/RAG, all services live, one PC" decision kept the build bounded. | `plan.md` §0 |
| **Cost-bounded AI design.** Caching, rate limits, input caps, and a stub chatbot kept LLM spend controllable. | `ai_core/`, `../09-ai/09-rate-limit-cache.md` |
| **Environment-driven resource caps made a large stack fit one PC.** | `backend/.env.example`, `backend/docker-compose.demo.yml` |

## 2. What proved difficult

| Lesson | Evidence |
| --- | --- |
| **Plans outpaced the contract.** Many prompt docs describe aspirations (RAG, orchestration, OAuth) that were never built, risking stakeholder mis-expectation. | `docs/Prompt *`, `../_meta/EVIDENCE-BASIS.md` §2 |
| **Migrations are easy to get subtly wrong.** A duplicate Flyway version and an entity ID mismatch exist in career-service. | BUG-001, BUG-002 |
| **Silent no-op migrations are dangerous.** The profile trigram index re-create was skipped, so the intended index does not exist. | BUG-003 |
| **Feature velocity outran test execution.** A broad test skeleton exists but coverage and execution lag the feature set. | `../11-testing/13-test-summary-report.md` |
| **Prose and code drift.** Documentation still referenced a retired `ai-service` and stale mock-flag guidance. | Action_Plan 15.4 |
| **Client i18n was deferred.** UI strings are hardcoded English; Khmer is a preference only. | `../_meta/EVIDENCE-BASIS.md` §7 |
| **Security was scaffolded but not assessed.** Baseline controls exist, yet no review was performed. | `../10-security/11-security-review-report.md` |

## 3. Structural observations

- **Weak "definition of done".** Where done was not defined to include test execution, UAT, and
  an assessment, those activities were deferred together to the end. A phase-gated "done" would
  have surfaced this earlier. [INFERRED]
- **Documentation is a first-class risk.** Since the repository is the only source of truth, stale
  docs can mislead new contributors and reviewers. [INFERRED]
- **The WIP branch being non-compiling** indicates a workflow where work-in-progress is not always
  kept buildable; this blocks parallel contribution. [VERIFIED] Action_Plan 15.5

## 4. Recommendations distilled

The action-oriented version of these lessons is in [`17-recommendations.md`](17-recommendations.md).

## 5. Related documents

- [`17-recommendations.md`](17-recommendations.md) · [`10-project-progress.md`](10-project-progress.md) · [`14-risks-issues.md`](14-risks-issues.md)
