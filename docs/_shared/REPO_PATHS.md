# Repository Paths

Canonical output paths for generated code. Use **`backend/`** everywhere (not `vithey-backend/`).

| Output | Path | Stack |
| --- | --- | --- |
| Flutter app | `vithey_app/` | Flutter, GetX, Dio — `pubspec.yaml` name: `aub_connect_app` |
| Java backend | `backend/` | Java 21, Spring Boot 3.3.5, Maven multi-module |
| Shared infra | `backend/infrastructure/` | Eureka, Config, Postgres, Redis, RabbitMQ, MinIO |
| Microservice | `backend/services/<name>/` | One Spring Boot app per folder |
| Docker scripts | `backend/scripts/` | `start-all.ps1`, `verify-docker.ps1` |
| Monitoring | `monitoring/` | Prometheus, Grafana, Loki, Promtail |
| CI workflows | `.github/workflows/` | Per-service and monorepo CI |

## Docker compose layout (current)

```text
backend/
├── infrastructure/docker-compose.yml    # creates vithey-network + shared infra
└── services/<name>/docker-compose.yml   # service + service Postgres only
```

Each `docker compose` run from its folder = separate Docker Desktop project.

Operational docs: `Prompt Devops/DOCKER.md`.

## Prompt docs (not in backend/)

All markdown documentation lives under `prompt/`:

- `prompt/_shared/` — registry, paths, read order
- `prompt/Prompt Backend/` — service build prompts
- `prompt/Prompt Devops/` — Docker and CI prompts
- `prompt/Prompt Frontend/` — UI and API contract

Do **not** create `README.md`, `API.md`, or `docs/` inside `backend/`.
