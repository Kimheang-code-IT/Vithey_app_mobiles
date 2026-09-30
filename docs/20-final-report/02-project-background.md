# Project Background

> Status: Verified baseline · Last reviewed: 2026-09-30
> Evidence: `docs/Prompt Frontend/00-project-summary.md`, `docs/Prompt Backend/COMMON_CONTEXT.md`, `plan.md`, `AGENTS.md`, git history
> Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)

## 1. Context

Vithey was conceived and built in the context of a **student app competition** run by ACLEDA
Bank. The intended audience is university students, represented in the repository by an AUB
student context. The goal was to demonstrate that a single youth-focused mobile application can
credibly combine several day-to-day needs that students currently spread across multiple apps.
[VERIFIED] `docs/Prompt Frontend/00-project-summary.md`, `docs/Prompt Backend/COMMON_CONTEXT.md`

## 2. Problem statement

Students juggle separate tools for social interaction, internship/job search, CV creation,
tuition and fee payments, peer messaging, and general assistance. This fragmentation makes each
task slower and less discoverable. Vithey addresses this by offering one app with a shared
identity, a consistent look and feel, and an AI assistant that can help with the employment
journey (notably CV creation).

## 3. Programme identity

| Item | Value | Status |
| --- | --- | --- |
| Product name | **Vithey** (on-device display name **Vithey**) | [VERIFIED] |
| Programme / initiative | ACLEDA Bank App Competition 2026 | [VERIFIED] `docs/Prompt Backend/COMMON_CONTEXT.md` |
| Contractual client / legal entity | Not established in the repository | [TBD] `TBD — Requires confirmation.` |
| Repository | Monorepo at `D:\project\Acleda Mobile App` | [VERIFIED] |
| Remote `origin` | `https://github.com/Kimheang-code-IT/Mobile-App-ACLEDA.git` | [VERIFIED] git remote |
| Remote `upstream` | `https://github.com/vithey-mobile/Mobile-App-ACLEDA.git` | [VERIFIED] git remote |
| Integration / promotion branches | `main` / `dev` (auto-promotion by CI) | [VERIFIED] `.github/workflows/ci-promote-dev.yml` |
| Version strings | Flutter `1.0.0+1`; `vithey-ai` `0.2.0`; backend `0.0.1-SNAPSHOT` | [VERIFIED] `../_meta/EVIDENCE-BASIS.md` §1 |

## 4. How the product was built

The project began from written build specifications and prompts captured under `docs/Prompt *`
(reference material only). Implementation then proceeded across the monorepo, with architectural
decisions locked late in the cycle in `plan.md` (the "Profile M" demo plan) and `api_docs.md`
(the Flutter ↔ gateway contract). Code is treated as the source of truth: where plans and code
differ, the code wins. [VERIFIED] `../_meta/EVIDENCE-BASIS.md`

## 5. Indicative timeline (activity window)

The following dates are an **activity window derived from git history**, not a contractual
schedule. [VERIFIED] `../_meta/EVIDENCE-BASIS.md` §1

| Milestone | Date | Basis |
| --- | --- | --- |
| First commit (`7e35770` "Prompt") | 2026-06-27 | git log |
| Demo plan locked ("Profile M") | ~2026-09-19 to 2026-09-20 | `plan.md` activity |
| Documentation baseline reviewed | 2026-09-30 | `../_meta/EVIDENCE-BASIS.md` |
| Latest commit (`d11106f`) at review | 2026-09-30 | git log |

## 6. Original delivery intent vs reality

The original prompts describe a broader, production-oriented ambition. The **locked delivery
decision** narrowed this to a local demo where all domain services run live on one computer for
about ten users, with GDCE/RAG, Kubernetes, production high availability, and local GPU LLMs
explicitly excluded. [VERIFIED] `plan.md` §0, §8

## 7. Open questions

- The exact contractual client, sponsor, and legal signatory. [TBD] `TBD — Requires confirmation.`
- Whether a formally approved contract schedule and scope baseline exist outside the repository. [TBD] `TBD — Requires confirmation.`

## 8. Related documents

- [`03-project-objectives.md`](03-project-objectives.md) · [`04-project-scope.md`](04-project-scope.md) · [`06-solution-overview.md`](06-solution-overview.md)
- [`../00-project-overview/01-project-overview.md`](../00-project-overview/01-project-overview.md) · `../../plan.md`
