# Known Limitations

> Status: Partially complete / Requires confirmation · Last reviewed: 2026-09-30
> Evidence: `docs/_meta/EVIDENCE-BASIS.md` §6/§7/§9, `plan.md` §8, `ai_core/`, `vithey_app/`, `docs/09-ai/11-ai-limitations.md`
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

Part of the Vithey documentation set · Master index:
[`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) ·
Siblings: [Risk register](01-risk-register.md) · [Issue log](02-issue-log.md) ·
[Technical debt](04-technical-debt.md) · [Mitigation plan](05-mitigation-plan.md).

## 1. Scope

**Known limitations** are behaviours that are intended, scoped, or accepted — not necessarily
defects to be fixed. They differ from [issues](02-issue-log.md) (unresolved defects) and from
[technical debt](04-technical-debt.md) (structural shortcuts with a future cost).

## 2. Limitations register

| ID | Limitation | Area | Nature | Impact | Evidence |
| --- | --- | --- | --- | --- | --- |
| L-01 | Vithey AI **chat is a stub**; `AI_CHAT_MODE` defaults to `stub` and `ChatService` always calls `stub_reply` | AI | By design (locked scope) | No real assistant answers; no LLM cost for chat | `ai_core/vithey_ai/chat_service.py`, `chat_stubs.py`; `EVIDENCE-BASIS.md` §6 |
| L-02 | **GDCE / `general-service` RAG is out of scope** | AI | Locked scope | No retrieval-augmented answers | `plan.md` §8; `AGENTS.md` |
| L-03 | `POST /ai/cv/suggest` is a **stub** while `/ai/cv/generate` uses the real LLM | AI | Partial by design | CV suggestions are canned | `docs/09-ai/11-ai-limitations.md` §1 |
| L-04 | **FCM push is a no-op without Firebase credentials**; device-token registration exists but push is disabled | Notifications | Scoped stub | No OS-level push in the demo; in-app notifications still work | `EVIDENCE-BASIS.md` §7; `Action_Plan_Vithey.csv` 7.11 |
| L-05 | **Google sign-in is UI-only** (throws unless mock) | Auth | Scoped stub | Google login unavailable | `EVIDENCE-BASIS.md` §7 |
| L-06 | **2FA and biometric login are not implemented** (switches kept off as "coming soon") | Security | Scoped stub | Only password login | `Action_Plan_Vithey.csv` 11.5 |
| L-07 | **Web/Chrome is unsupported** (Isar, secure storage, camera) | Client | By design | Must use Android emulator/device | `AGENTS.md`; `EVIDENCE-BASIS.md` §7 |
| L-08 | **Khmer is a stored preference + CV label only**; strings are hardcoded English (`AppStrings`), no `.arb` | Client | Partial | No full Khmer localisation | `EVIDENCE-BASIS.md` §7 |
| L-09 | **Map is opt-in and needs a Google Places key**; otherwise it returns a clear config error | Map | Scoped dependency | Map unavailable without a key | `plan.md` §0; `backend/DEMO.md` |
| L-10 | The demo targets **~10 concurrent users on one PC** with strict memory caps | Environment | Locked scope | Not load-tested beyond demo size | `plan.md` §0/§3 |
| L-11 | **No staging and no production environment** exist | Environment | Not built | Cannot validate release beyond local demo | `EVIDENCE-BASIS.md` §9 |
| L-12 | Several client features are **placeholders** (some settings rows, chatbot attachments, history search) | Client | Scoped stub | Features visibly incomplete | `EVIDENCE-BASIS.md` §7 |
| L-13 | `to_draft` field mapping can **drop skills/experience fields** in the CV draft | AI | Known data limitation | Draft may be less complete than the LLM output | `ai_core/vithey_ai/cv_app_service.py`; `docs/09-ai/11-ai-limitations.md` §2 |
| L-14 | Legacy `ai_core` routes (`/api/v1/activities/**`, `/api/v1/cv/generate`) are **not gateway-routed** | AI | By design | Reachable only inside the compose network / `:8100` | `docs/09-ai/11-ai-limitations.md` §6 |
| L-15 | Two error envelopes can occur (`{data,meta,error}` vs `{success,data,meta}`) on legacy/middleware paths | API | Known inconsistency | Clients may see either shape on error | `docs/09-ai/11-ai-limitations.md` §5 |
| L-16 | **No OCR/PDF parsing of CVs** | AI | Out of scope | CVs come from profile/posts only | `plan.md` §8 |
| L-17 | Flutter is **mock-first**; many modules defaulted to mocks until flags flipped | Client | Delivery approach | Live behaviour depends on `USE_MOCK_*` flags | `vithey_app/README.md`; `EVIDENCE-BASIS.md` §7 |
| L-18 | `ai_core` caches/rate-limits are **in-process** (single worker) | AI | Demo constraint | Cache/limit semantics break under replicas | `docs/09-ai/11-ai-limitations.md` §3 |
| L-19 | **No token/cost metering, budget cap, prompt versioning, or model fallback** | AI | Not built | Cost/quality governance limited | `docs/09-ai/11-ai-limitations.md` §8 |
| L-20 | PII and datastore contents are **plaintext** (no at-rest encryption) | Data / Security | Not built | Exposure risk if storage compromised | VA-12; `docs/05-database/08-backup-restore.md` |
| L-21 | `ai_db` schema is created by Python `ensure_schema()` (`CREATE TABLE IF NOT EXISTS`), **not Flyway** | Data | By design | No versioned migration history for AI tables | `docs/09-ai/11-ai-limitations.md` §4 |

## 3. Notes

- Items L-01–L-03 and L-09 are explicitly locked in `plan.md` §0/§8 and are **not defects**.
- Items L-06, L-08, L-12, L-19 and L-20 are gaps that would need new scope to close; see the
  [action plan](../02-project-management/02-action-plan.md) `Future Enhancement` rows.
- No formal acceptance of these limitations exists: [TBD] TBD — Requires confirmation.

## 4. Cross-links

- [AI limitations](../09-ai/11-ai-limitations.md) · [Project scope](../00-project-overview/03-project-scope.md)
- [Risk register](01-risk-register.md) · [Technical debt](04-technical-debt.md)
