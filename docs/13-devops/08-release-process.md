# Release Process

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `.github/workflows/ci-promote-dev.yml`, `.github/workflows/*-service-ci.yml`, `git tag`, `vithey_app/pubspec.yaml`, `ai_core/pyproject.toml`, `backend/pom.xml`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [CI/CD](05-CI-CD.md) · [Image registry](07-image-registry.md) · [Rollback plan](../14-deployment/07-rollback-plan.md)

## 1. Current release reality

There is **no formal release process** and **no release/tagging workflow**. What exists is continuous integration that:

1. runs tests on `kimheang`/`main`,
2. builds and pushes images to GHCR with `latest` + `sha-<short>` tags,
3. fast-forwards the passing commit to `dev`.

Nothing is deployed as part of a "release". [VERIFIED — `.github/workflows/ci-promote-dev.yml`]

## 2. Branches

| Branch | Role |
|---|---|
| `kimheang` | current documentation-time integration branch (also a CI trigger) |
| `main` | main integration branch (CI trigger) |
| `dev` | auto-promotion target; receives tested commits |
| feature branches | `Prompt`, `ayheng`, `bora`, `liza`, `molika`, `sothay_dev`, `sovannarith`, `wip/*` |

[VERIFIED — `git branch`, `EVIDENCE-BASIS.md` §1]

Promotion is a fast-forward push of the exact tested SHA; if `dev` has diverged the push fails (no merge, no retry). [VERIFIED]

## 3. Versions in the repo

| Component | Version string | Source |
|---|---|---|
| Flutter app | `1.0.0+1` | `vithey_app/pubspec.yaml` |
| ai_core dist | `vithey-ai` `0.2.0` | `ai_core/pyproject.toml` |
| backend | `vithey-backend` `0.0.1-SNAPSHOT` | `backend/pom.xml` |

[VERIFIED — `EVIDENCE-BASIS.md` §1]

Git tags present: `presync-20260930` (commit `3537584`, "updaate version 0.0.3") and `stash-20260829`. These are manual, not pipeline-produced. [VERIFIED — `git tag`]

## 4. How a "release" works today (manual, per component)

### Backend image
1. Merge/push to `kimheang` or `main`.
2. `ci-promote-dev.yml` runs tests; on success builds/pushes GHCR images.
3. Record the `sha-<short>` tag for the released commit.
4. Deploy manually by pulling that tag (see [Production deployment](../14-deployment/05-production-deployment.md) — currently not performed).

### Flutter APK
1. `copy .env.example .env` in `vithey_app/`.
2. `flutter pub get`, `flutter analyze --no-fatal-infos`, `flutter test`.
3. `flutter build apk` (release). **Note:** Android release currently signs with debug keys — an explicit TODO in `android/app/build.gradle`. A signed store release is not prepared. [VERIFIED — `EVIDENCE-BASIS.md` §7]

### ai_core
1. `pip install -e ".[server,dev]"`, `pytest`.
2. Image is built by CI as `ghcr.io/<owner>/vithey-ai-core:<tag>`.

## 5. Release checklist (advisory — not automated)

- [ ] All three test jobs green in `ci-promote-dev.yml`.
- [ ] `dev` fast-forwarded successfully.
- [ ] `sha-<short>` tag noted for every service to deploy.
- [ ] Config-repo changes verified (a config change requires a config-server image rebuild).
- [ ] Migrations reviewed — **never edit an already-applied Flyway migration**; add a new version. [VERIFIED — `AGENTS.md`]
- [ ] Flutter release signing configured before any store submission. [VERIFIED — current TODO]

## 6. Gaps

| Gap | Status |
|---|---|
| Semantic versioning / changelog automation | Not implemented |
| Release/tag workflow | Not implemented |
| Environment deployment on release | Not implemented |
| Rollback automation | Not implemented |
| Release notes / artefact archiving | Not implemented |
| Flutter release signing | Not started (debug keys) |

[VERIFIED unless marked]

[TBD] Whether/when a formal versioning scheme, changelog or signed mobile release is required — TBD — Requires confirmation. No evidence; appears to have been out of scope for the competition demo.
