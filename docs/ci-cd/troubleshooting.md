# CI Troubleshooting

## `CI Gate` never appears / is stuck

`CI Gate` is defined in an unfiltered workflow (`ci.yml`) and runs with
`if: always()`, so it always reports. If it is missing, check that `ci.yml`
exists on the PR's base branch (`dev`).

Do **not** make path-filtered workflows required — they would stay pending on
PRs that do not touch their paths.

## A job was skipped but `CI Gate` passed

That is expected: skipped jobs are not failures. Only failed or cancelled
applicable jobs fail the gate.

## Backend

- **`-pl services/<name> -am` fails to resolve a module** — the module must be
  declared in `backend/pom.xml`. Changing `backend/pom.xml` or
  `backend/shared/**` runs the full reactor instead.
- **Smoke tests (`*SmokeIT`) need Docker** — they use Testcontainers and only run
  where a Docker daemon is available.

## Flutter

- **`flutter pub get` fails on version constraints** — the workflow pins a
  verified Flutter version (`flutter-version` in the workflow). Update it
  deliberately when the project upgrades.

## Python

- **ai-core imports fail** — install with the server/dev extras:
  `pip install -e ".[server,dev]"`.
- **fake-payment tests can't find pytest** — install dev requirements:
  `pip install -r requirements-dev.txt`.

## Docker

- **`docker compose config` fails** — a referenced `env_file` or build context
  is missing. Paths are relative to the compose file.
- **Builds are slow** — builds are cached via BuildKit (`type=gha`) on `main`.

## Monitoring

- **`promtool` fails** — validate locally with:
  `docker run --rm --entrypoint promtool -v "$PWD/monitoring/prometheus:/etc/prometheus:ro" prom/prometheus:latest check config /etc/prometheus/prometheus.yml`

## Secrets

If CI fails because a secret is missing, do **not** commit it. Add it as a
GitHub Actions secret and reference it via `secrets.*`. See `SECURITY.md`.
