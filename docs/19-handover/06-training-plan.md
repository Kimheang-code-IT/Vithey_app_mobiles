# Training Plan

> Status: **Planned** — training has NOT been conducted · Last reviewed: 2026-09-30
> Evidence: `AGENTS.md`, `plan.md`, `api_docs.md`; no training records found
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

> **No training has been conducted and no training evidence exists.** This is a **proposed plan**.
> All dates, trainers, attendees, and materials are TBD. Any training record must be created once
> sessions actually occur.

## 1. Objectives

Enable the receiving team to independently build, run, operate, and extend Vithey across its three
toolchains (Flutter, Spring Boot backend, Python `ai_core`) within the constraints of the verified
local demo environment.

## 2. Audience & prerequisites

| Audience | Prerequisite knowledge | Focus |
| --- | --- | --- |
| New developers | Git, one of Dart/Java/Python | Build/run each toolchain |
| DevOps/handover engineers | Docker, PowerShell, CI | Demo stack, CI, monitoring |
| Support/ops | Basic API/HTTP | Health checks, smoke, troubleshooting |
| Stakeholders | None | Product walkthrough + limitations |

## 3. Proposed curriculum

| Module | Duration (proposed) | Content | Evidence source |
| --- | --- | --- | --- |
| T1 — Product & architecture | 1 h | Superapp scope, gateway-only rule, AI flow, environments | `AGENTS.md`, `plan.md`, `api_docs.md` |
| T2 — Flutter app | 2 h | GetX/DI/routing, Dio interceptor, Isar, `.env`, build_runner, run on emulator/device | `vithey_app/README.md`, `AGENTS.md` |
| T3 — Backend services | 3 h | Maven modules, Eureka/Config, JWT filter chain, RabbitMQ events, per-service DB + Flyway | `backend/TESTING.md`, `_meta/EVIDENCE-BASIS.md` §3–§5 |
| T4 — ai_core | 2 h | FastAPI surface, real CV pipeline, stub chat, LLM config, cost guards | `ai_core/README.md`, `../06-api/12-ai-api.md` |
| T5 — Demo stack & CI | 2 h | `docker-up-demo.ps1`, smoke script, resource caps, `ci-promote-dev.yml`, GHCR | `plan.md`, `.github/workflows/ci-promote-dev.yml` |
| T6 — Monitoring | 1 h | Prometheus/Grafana/Loki profile, what is not scraped, no Alertmanager | `monitoring/README.md`, `_meta/EVIDENCE-BASIS.md` §9 |
| T7 — Known limitations & defects | 1 h | Stubs, data defects, unsigned release | `_meta/EVIDENCE-BASIS.md` §7, §8 |

## 4. Format

- Live, hands-on sessions on the receiving team's own machine (not screenshots only).
- Each module ends with a reproduceable exercise (see [02-handover-checklist.md](02-handover-checklist.md)).
- Recordings and notes stored in: TBD — Requires confirmation.

## 5. Responsibilities

| Role | Name | Status |
| --- | --- | --- |
| Training coordinator | TBD — Requires confirmation. | Not started |
| Flutter trainer | TBD — Requires confirmation. | Not started |
| Backend trainer | TBD — Requires confirmation. | Not started |
| AI trainer | TBD — Requires confirmation. | Not started |
| Operations trainer | TBD — Requires confirmation. | Not started |

## 6. Proposed schedule

| Session | Proposed date | Actual date | Status |
| --- | --- | --- | --- |
| T1–T2 | TBD | — | Not conducted |
| T3–T4 | TBD | — | Not conducted |
| T5–T7 | TBD | — | Not conducted |

## 7. Assessment & completion

- [ ] Each module exercise reproduced by the recipient.
- [ ] Recipient successfully starts the demo stack unassisted.
- [ ] Recipient generates an AI CV and explains why chat is a stub.
- [ ] Training attendance recorded (none exists today).

## 8. Current status

**Training has not yet been conducted. No training evidence was found.**

## 9. Related

- [07-knowledge-transfer.md](07-knowledge-transfer.md) · [02-handover-checklist.md](02-handover-checklist.md) · [08-handover-signoff.md](08-handover-signoff.md)
- [../00-project-overview/07-document-index.md](../00-project-overview/07-document-index.md)
