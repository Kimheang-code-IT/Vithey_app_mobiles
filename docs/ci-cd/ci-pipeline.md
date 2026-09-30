# CI Pipeline

Three workflows implement three validation levels.

## Level 1 — `ci.yml` (pull request → `dev`)

The workflow is **not** path-filtered, so the required check always reports.
A `Detect changes` job computes which components changed; individual jobs skip
when not applicable.

| Job | Runs when | What it does |
| --- | --- | --- |
| `Detect changes` | always | Computes changed components from the PR diff. |
| `Backend (<service>)` | a `backend/services/<service>/` path changed (and no full-reactor trigger) | `mvn -B -f backend/pom.xml -pl services/<service> -am test` |
| `Backend (full reactor)` | `backend/pom.xml`, `backend/shared/**`, `backend/infrastructure/**`, `backend/scripts/**`, or other non-service backend paths changed | `mvn -B -f backend/pom.xml test` |
| `Flutter` | `vithey_app/**` changed | `flutter pub get` → `analyze --no-fatal-infos` → `test` |
| `AI Core` | `external-services/ai-core/**` changed | `pip install -e ".[server,dev]"` → `pytest -q` |
| `Fake Payment` | `external-services/fake-payment-service/**` changed | `pip install -r requirements-dev.txt` → `pytest -q` |
| `Monitoring config` | `monitoring/**` changed | `promtool check config`, Grafana YAML/JSON parse |
| `Docker Compose config` | a compose/Dockerfile/workflow path changed | `docker compose config` for all stacks |
| **`CI Gate`** | always (`if: always()`) | Fails if any applicable job failed/cancelled; skipped jobs are fine. |

`CI Gate` is the single stable required check for the `dev` branch ruleset.

## Level 2 — `dev-integration.yml` (push → `dev`)

Runs the broader suite unconditionally: full backend reactor, Flutter, AI Core,
Fake Payment, Docker Compose config, and monitoring validation. It does **not**
publish images, push branches, or deploy.

## Level 3 — `main.yml` (pull request → `main`)

The strongest practical validation: full backend, Flutter, AI Core, Fake
Payment, Docker Compose config, monitoring, and Docker **image builds** for all
components (build only, no push). Ends with the required **`Main Gate`**.

## Concurrency and permissions

- All workflows use `permissions: contents: read`.
- Each workflow groups runs by PR/branch and cancels superseded runs
  (`cancel-in-progress: true`), so a newer commit cancels obsolete CI for the
  same PR without touching unrelated PRs.

## Caching

- Maven: `actions/setup-java` `cache: maven`.
- Flutter: `subosito/flutter-action` `cache: true`.
- Python: `actions/setup-python` `cache: pip`.
- Docker builds (main only): BuildKit GitHub Actions cache (`type=gha`).

No secrets are cached.
