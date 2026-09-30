# Handover Checklist

> Status: **Template** — no items completed · Last reviewed: 2026-09-30
> Evidence: `AGENTS.md`, `plan.md`, `_meta/EVIDENCE-BASIS.md`
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

> **Nothing on this checklist has been completed.** Unticked boxes are the true current state;
> handover has NOT occurred. Record real evidence in the "Evidence" column before ticking anything.

## 1. Governance & scope

- [ ] Handover scope agreed and recorded ([01-handover-plan.md](01-handover-plan.md))
- [ ] Named handover lead and receiving lead confirmed (currently TBD)
- [ ] Environment status communicated (local dev/demo only; no staging/prod)
- [ ] Known limitations register reviewed (stubs, defects) — see `_meta/EVIDENCE-BASIS.md` §7, §8
- [ ] Legal/contractual client entity confirmed — TBD

## 2. Source code

- [ ] Repositories and remotes handed over ([03-source-code-handover.md](03-source-code-handover.md))
- [ ] Branch model explained (`main` / `dev` / `kimheang`, auto-promote to `dev`)
- [ ] Commit history and tag (`presync-20260930`) explained
- [ ] Generated files documented (Isar `*.g.dart`; build_runner step)
- [ ] Config-server rebuild caveat understood

## 3. Build & run verification

- [ ] Flutter: `copy .env.example .env` → `flutter pub get` → `flutter analyze` → `flutter test`
- [ ] Backend: `mvn test` (Docker-independent tests pass)
- [ ] ai_core: `pip install -e ".[server,dev]"` → `pytest`
- [ ] Demo stack: `backend/scripts/docker-up-demo.ps1` reaches health
- [ ] `backend/scripts/smoke-api.ps1` runs end-to-end
- [ ] Map profile (opt-in): `docker-up-demo.ps1 -Profiles map`

## 4. Environment & configuration

- [ ] All `.env.example` files reviewed ([04-environment-handover.md](04-environment-handover.md))
- [ ] Port map and host ports documented
- [ ] Docker resource caps (`backend/.env`) explained
- [ ] Monitoring profile (`--profile monitoring`) demonstrated

## 5. Credentials & secrets

- [ ] Credential inventory completed ([05-credential-handover-checklist.md](05-credential-handover-checklist.md))
- [ ] Secrets transferred over an approved secure channel (NOT in git, NOT in docs)
- [ ] Rotated/owned by recipient
- [ ] No real values present in any documentation artefact

## 6. Knowledge transfer & training

- [ ] Training plan delivered ([06-training-plan.md](06-training-plan.md)) — **not yet conducted**
- [ ] KT sessions delivered ([07-knowledge-transfer.md](07-knowledge-transfer.md)) — **not yet conducted**
- [ ] Recordings/notes stored

## 7. Verification & acceptance

- [ ] Recipient reproduced key user journeys (login, feed, apply, AI CV, chat, finance gate)
- [ ] Residual risks accepted and recorded
- [ ] Sign-off completed ([08-handover-signoff.md](08-handover-signoff.md))

## 8. Current status statement

**Handover has not occurred.** All boxes are unticked. This checklist must not be cited as evidence
of a completed transfer.

## 9. Related

- [01-handover-plan.md](01-handover-plan.md) · [08-handover-signoff.md](08-handover-signoff.md) · [../00-project-overview/07-document-index.md](../00-project-overview/07-document-index.md)
