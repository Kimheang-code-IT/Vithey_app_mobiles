# Business Requirements Document (BRD)

> Status: Partially complete · Last reviewed: 2026-09-30
> Evidence: `docs/Prompt Frontend/00-project-summary.md`, `docs/Prompt Backend/COMMON_CONTEXT.md`, `plan.md`, `Action_Plan_Vithey.csv`
> Note: This is a **business-level** document. It intentionally avoids fabricated contractual or financial detail. Items without repository evidence are marked TBD.

## 1. Document purpose

Define the business context, needs, and high-level requirements for **Vithey**, an AUB
student superapp developed for the **ACLEDA Bank App Competition 2026**. It establishes
why the product is being built and what business outcomes it targets. Detailed functional
and technical requirements are in the SRS and functional requirements documents.

## 2. Business context

| Item | Description | Status |
| --- | --- | --- |
| Business driver | Enter and perform well in the ACLEDA Bank App Competition 2026 | [VERIFIED] `docs/Prompt Backend/COMMON_CONTEXT.md` |
| Target market | AUB students and general youth users | [VERIFIED] `docs/Prompt Frontend/00-project-summary.md` |
| Product concept | One app combining social, jobs/CV, finance, chat, and AI assistance | [VERIFIED] same |
| Delivery model (current) | Locally demonstrated demo (~10 concurrent users), not production | [VERIFIED] `plan.md` §0 |
| Revenue model | Not stated in the repository | [TBD] TBD — Requires confirmation. |
| Contract / commercial terms | Not established | [TBD] TBD — Requires confirmation. |

## 3. Business problem and opportunity

- **Problem:** student needs (social connection, internships/jobs, CV creation, tuition
  payments, peer communication, guidance) are fragmented across many apps. [INFERRED] Inferred from implementation — requires business confirmation.
- **Opportunity:** a single youth-focused superapp can improve engagement and provide a
  showcase for ACLEDA digital services. [INFERRED] Inferred from implementation — requires business confirmation.
- **Differentiator:** AI-assisted CV creation from a student's own profile and posts. [VERIFIED] `plan.md` §4.1

## 4. Business objectives

| ID | Objective | Success indicator | Status |
| --- | --- | --- | --- |
| BO-01 | Deliver a competition-ready student superapp | Demonstrable app covering required features | [VERIFIED] |
| BO-02 | Satisfy the competition's feature checklist (≥5 features, auth, settings, light/dark) | Checklist met | [VERIFIED] `docs/Prompt Frontend/00-project-summary.md` |
| BO-03 | Demonstrate a credible jobs + AI CV journey | Working live demo | [VERIFIED] `plan.md` §9 |
| BO-04 | Show a finance experience connected to ACLEDA Mobile | ACLEDA launcher present | [INFERRED] Action_Plan 13.2 |
| BO-05 | Provide a path to production with the bank | Not started | [PLANNED] Action_Plan 17.5 |

## 5. Scope of business requirements

### 5.1 In-scope business capabilities

| Capability | Business value | Status |
| --- | --- | --- |
| Social feed & networking | Student engagement | [VERIFIED] |
| Jobs & applications | Career development | [VERIFIED] |
| AI CV builder | Differentiation, career support | [VERIFIED] |
| Student finance | Link to ACLEDA services | [VERIFIED] |
| Peer chat | Private communication | [VERIFIED] |
| AI assistant | Guidance on CV/jobs/interviews/finance | [VERIFIED] (stub) |
| Notifications | Re-engagement | [VERIFIED] |
| Map / nearby places | Local discovery | [VERIFIED] (opt-in) |

### 5.2 Out-of-scope business capabilities

GDCE/RAG, production HA, K8s, Google OAuth, OCR/PDF CV parsing, and admin reporting are
out of the current demo scope. [VERIFIED] `plan.md` §8, Action_Plan 13.4

## 6. Stakeholders (summary)

| Stakeholder | Business interest | Status |
| --- | --- | --- |
| ACLEDA Bank competition | Competition evaluation | [VERIFIED] |
| AUB students | Superapp serving their needs | [VERIFIED] |
| Product owner / sponsor | Product outcomes and sign-off | [TBD] identity TBD — Requires confirmation. |
| Job-poster companies | Recruitment reach | [VERIFIED] |

Detail: [`../00-project-overview/04-stakeholders.md`](../00-project-overview/04-stakeholders.md).

## 7. Business assumptions and constraints

| ID | Assumption / constraint | Status |
| --- | --- | --- |
| BA-01 | Demo runs locally for ~10 users, not in production | [VERIFIED] `plan.md` §0 |
| BA-02 | An LLM API key is available locally for the AI CV feature | [VERIFIED] `plan.md` §3.5 |
| BA-03 | Google Places key optional; map degrades gracefully without it | [VERIFIED] `plan.md` §0 |
| BA-04 | Target users are AUB students and youth users | [VERIFIED] |
| BA-05 | FCM push is optional; email delivery defaults to logging in local demo | [VERIFIED] Action_Plan 6.3, 7.11 |
| BA-06 | No formal security review or UAT has occurred | [VERIFIED] EVIDENCE-BASIS §12 |

## 8. Business risks

| ID | Risk | Impact | Mitigation (as evidenced) | Status |
| --- | --- | --- | --- | --- |
| BR-01 | Demo PC out of memory | Demo failure | Profile M caps; SerialGC small heaps | [VERIFIED] `plan.md` §10 |
| BR-02 | LLM slow/down or missing key | AI CV unavailable | Timeouts, clear errors | [VERIFIED] `plan.md` §10 |
| BR-03 | Token cost | Budget | Flash model, rate limits, capped posts | [VERIFIED] `plan.md` §10 |
| BR-04 | No production path defined | Competition/go-live | Not addressed | [PLANNED] Action_Plan 17.5 |
| BR-05 | No security assessment | Compliance | Not yet performed | [TBD] TBD — Requires confirmation. |

## 9. Compliance and governance

- Competition rules reference: ACLEDA Bank App Competition 2026. [VERIFIED] `docs/Prompt Frontend/00-project-summary.md`
- Formal acceptance, UAT, and security assessment: **not yet executed**. [VERIFIED] EVIDENCE-BASIS §12
- Regulatory/data-protection obligations for student data: [TBD] TBD — Requires confirmation.

## 10. Acceptance of business requirements

| Sign-off | Name | Date | Status |
| --- | --- | --- | --- |
| Product owner / sponsor | | | [TBD] TBD — Requires confirmation. |
| Bank-side evaluator | | | [TBD] TBD — Requires confirmation. |

## 11. Related documents

- [`02-software-requirements-SRS.md`](02-software-requirements-SRS.md)
- [`03-functional-requirements.md`](03-functional-requirements.md)
- [`../00-project-overview/02-project-objectives.md`](../00-project-overview/02-project-objectives.md)
