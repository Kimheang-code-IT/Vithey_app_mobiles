# Change Request Log

> Status: Requires confirmation · Last reviewed: 2026-09-30
> Evidence: git history, `plan.md` update banner, `AGENTS.md`, `api_docs.md` §10, `backend/DOCKER.md`, `backend/DEMO.md`
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

Part of the Vithey documentation set · Master index:
[`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) ·
Sibling: [Decision log](09-decision-log.md) · [Project plan](01-project-plan.md) · [Risk register](../18-risk-management/01-risk-register.md).

## 1. Caveat

**No formal change-request process or approved CR forms exist in the repository.** This log
records only changes that are **evidenced** in git history or the tracked planning docs. Each entry
is **[INFERRED]** as a change (the fact of the change is verified; its status *as an approved change
request* is not). Absence of an approval record is stated explicitly. Anything not evidenced is
`None found` / `TBD`.

Dates are **evidence-derived** from the relevant commit and are not formal CR dates.

## 2. Change log

| CR | Date (evidence-derived) | Change | Type | Evidence | Impact | Approval |
| --- | --- | --- | --- | --- | --- | --- |
| CR-01 | 2026-09-05 → 2026-09-20 | **Java `ai-service` retired**; Python `ai_core` owns the entire `/api/v1/ai/**` surface (chat + CV) behind the gateway | Scope/architecture | `plan.md` update banner; `AGENTS.md`; `api_docs.md` §10; `backend/DOCKER.md`; `backend/DEMO.md`; no `services/ai-service` in `git ls-files` | Removes a service; gateway route `/api/v1/ai/**` now targets `ai_core:8100` directly | [TBD] No approval record. TBD — Requires confirmation. |
| CR-02 | 2026-08-30 → 2026-09-05 | **`map-service` added** (service + Flutter map module + compose integration) | Additional scope | commits `1420b0d`, `f096bf5`, `be87718`, `5b16cb9`, `d11106f`; `backend/services/map-service/` | New service on port 8090; opt-in `map` Compose profile | [TBD] No approval record. TBD — Requires confirmation. |
| CR-03 | 2026-09-05 → 2026-09-20 | **Chat made a stub** (`AI_CHAT_MODE=stub`); GDCE/RAG explicitly out of scope | Scope | `plan.md` §0/§8; `AGENTS.md`; `ai_core/vithey_ai/chat_service.py` | Chatbot served from topic stubs; no LLM cost | [TBD] No approval record. TBD — Requires confirmation. |
| CR-04 | 2026-09-19 → 2026-09-20 | **Production-oriented config update** and version bump to `0.0.3` | Config/version | commits `c93d138` "update production 01", `3537584` "updaate version 0.0.3" | `application-prod.yml` present; still not activated in CI | [TBD] No approval record. TBD — Requires confirmation. |
| CR-05 | 2026-09-20 | **Backend refactor to "reusable resource"** (env-driven resource limits) | Internal technical improvement | commit `ac227fd`; `AGENTS.md` resource-cap convention; `backend/.env` sizing knobs | Resource caps come from `.env`; no hardcoded limits | [TBD] No approval record. TBD — Requires confirmation. |
| CR-06 | 2026-09-14 | **API integration contracts + compose/build management scripts added** | Process/config | commits `caf5e95`, `5b16cb9`; `backend/scripts/` | Adds smoke/health/up/down scripts; documents contracts | [TBD] No approval record. TBD — Requires confirmation. |
| CR-07 | 2026-08-06 → 2026-08-29 | **Migration fixes** (finance/career schema bugs, file-service fixes) | Defect fix | commits `4ac45f8`, `976bbe8`, `a4117ac` | Corrects migration defects; see issue log | [TBD] No approval record. TBD — Requires confirmation. |
| CR-08 | (no date found) | **Notification UI upgrade** (migration `V4__notification_ui_upgrade`) | Enhancement | `backend/services/notification-service/.../V4__notification_ui_upgrade.sql` (migration inventory `05-database/06-migration-strategy.md`) | Notification schema/UI extended | [TBD] No approval record. TBD — Requires confirmation. |

## 3. Changes with no evidence

| Candidate change | Status | Note |
| --- | --- | --- |
| Backend AI service reintroduction | None found | Explicitly discouraged (`AGENTS.md`); no module exists |
| GDCE / `general-service` RAG wiring | None found | Explicitly out of scope (`plan.md` §8) |
| Kubernetes / Helm / Terraform deployment | None found | Not present (`EVIDENCE-BASIS.md` §9) |
| Formal CR process introduction | None found | No CR templates or registers in the repository |
| Any client-requested change with a written CR | None found | Requires confirmation if such requests exist outside the repo |

## 4. Process gap

The repository provides **no** change-request template, approval workflow, or impact-assessment
record. If the bank requires a controlled change process, one must be established and this log
migrated into it. Status: [TBD] TBD — Requires confirmation.

## 5. Cross-links

- [Decision log](09-decision-log.md) · [Issue log](../18-risk-management/02-issue-log.md)
- [Migration strategy](../05-database/06-migration-strategy.md)
