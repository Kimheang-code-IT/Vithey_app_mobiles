# Vithey / AUB Connect

Vithey (AUB Connect) is a student "superapp" built for the **ACLEDA Bank App
Competition 2026**. This repository is a monorepo containing a Flutter mobile
app, a Spring Boot microservices backend, a Python AI CV engine, a demo payment
provider, and a monitoring stack.

## Overview

Vithey gives students one place to manage their university life: a social feed,
career/job tools with AI CV generation, finance and fees, chat, notifications,
maps, and an AI assistant. The system is a set of Spring Cloud microservices
behind an API gateway, a Flutter client, and Python services for AI and a fake
payment provider.

## Architecture

- **API Gateway** — single entry point, JWT validation, routing.
- **Service discovery** — Eureka.
- **Configuration** — Spring Cloud Config (native `config-repo`).
- **Microservices** — auth, user-profile, file, content, career, finance, chat,
  notification, map.
- **AI Core** — FastAPI service that owns the AI surface (CV generation + chat).
- **Fake Payment** — FastAPI demo payment provider (dev/demo/UAT only).
- **Data** — PostgreSQL, Redis, RabbitMQ, MinIO.
- **Monitoring** — Prometheus + Grafana (opt-in profile).

See [docs/03-system-design/01-system-architecture.md](docs/03-system-design/01-system-architecture.md).

## Main Features

- Social feed (posts, comments, reactions, follows)
- Career tools and AI-assisted CV generation
- Student finance and fee views
- Real-time chat and message requests
- Notifications
- Maps / places
- AI assistant (CV generation is real; chat is a stub in the demo)

## Technology Stack

| Area | Technology |
| --- | --- |
| Mobile | Flutter, Dart, GetX, Dio, Isar |
| Backend | Java 21, Spring Boot, Spring Cloud, Maven |
| AI | Python 3.12, FastAPI |
| Payment (demo) | Python, FastAPI |
| Data | PostgreSQL 16, Redis 7, RabbitMQ, MinIO |
| Monitoring | Prometheus, Grafana |
| CI/CD | GitHub Actions |

## Repository Structure

```text
.
├── .github/                     # workflows, templates, CODEOWNERS, dependabot
├── backend/                     # Maven multi-module Spring Cloud stack
│   ├── services/                # 10 microservices
│   ├── shared/vithey-test-support/
│   ├── infrastructure/          # eureka-server, config-server, config-repo
│   ├── docker/                  # Docker helpers
│   ├── scripts/                 # operational scripts
│   ├── docker-compose.yml
│   └── pom.xml
├── external-services/
│   ├── ai-core/                 # Python AI engine (FastAPI)
│   └── fake-payment-service/    # FastAPI demo payment provider
├── vithey_app/                  # Flutter application
├── monitoring/                  # Prometheus + Grafana
├── docs/                        # documentation package
├── CONTRIBUTING.md
├── SECURITY.md
└── README.md
```

> `AGENTS.md`, `plan.md`, and `api_docs.md` are not present at this revision.

## Prerequisites

- Git
- Java 21 + Maven 3.9+
- Flutter (stable) — verified with 3.44.5 / Dart 3.12
- Python 3.12
- Docker Desktop (for compose stacks and integration tests)

## Local Development

Clone and create your working branch from `dev`:

```bash
git clone https://github.com/Kimheang-code-IT/Vithey_app_mobiles.git
cd Vithey_app_mobiles
git checkout dev
git checkout -b feature/<your-task>
```

Per-component setup follows.

## Backend Setup

```bash
# Run all module tests
mvn -B -f backend/pom.xml test

# Or from backend/
cd backend
mvn test
```

Testcontainers-based `*SmokeIT` tests require Docker.

## Flutter Setup

```bash
cd vithey_app
cp .env.example .env
flutter pub get
flutter analyze --no-fatal-infos
flutter test
```

## AI Core Setup

```bash
cd external-services/ai-core
cp .env.example .env          # set your own values; never commit .env
pip install -e ".[server,dev]"
pytest -q
python main.py serve --port 8100
```

## Fake Payment Setup

```bash
cd external-services/fake-payment-service
cp .env.example .env
pip install -r requirements-dev.txt
pytest -q
```

## Monitoring

Opt-in profile (requires the shared `vithey-network`):

```bash
cd monitoring
docker compose --profile monitoring up -d
# Prometheus: http://localhost:9090   Grafana: http://localhost:3000
```

## Environment Configuration

- Commit only `.env.example` files (placeholders).
- Never commit real `.env` files or secrets.
- Real credentials are local-only (git-ignored) or provided via a secret manager
  / GitHub Secrets at runtime.

## Testing

| Component | Command |
| --- | --- |
| Backend | `mvn -B -f backend/pom.xml test` |
| Flutter | `flutter analyze --no-fatal-infos && flutter test` |
| AI Core | `pytest -q` (in `external-services/ai-core`) |
| Fake Payment | `pytest -q` (in `external-services/fake-payment-service`) |
| Compose | `docker compose -f backend/docker-compose.yml config` |
| Monitoring | `promtool check config monitoring/prometheus/prometheus.yml` |

## Docker

```bash
# Full stack
cd backend
docker compose up -d --build

# Demo overlay (resource-tuned)
docker compose -f docker-compose.yml -f docker-compose.demo.yml up -d --build

# Or via scripts
./scripts/docker-up-demo.ps1      # PowerShell
```

See [backend/DOCKER.md](backend/DOCKER.md) and [backend/DEMO.md](backend/DEMO.md).

## Git Workflow

`main` ← `dev` ← task branches. See [CONTRIBUTING.md](CONTRIBUTING.md) and
[docs/ci-cd/branching-strategy.md](docs/ci-cd/branching-strategy.md).

## CI/CD

Three workflows:

- `ci.yml` — pull request → `dev`; path-aware component checks ending in `CI Gate`.
- `dev-integration.yml` — push → `dev`; broader integration validation.
- `main.yml` — pull request → `main`; strongest validation ending in `Main Gate`.

See [docs/ci-cd/ci-pipeline.md](docs/ci-cd/ci-pipeline.md).

## Security Notes

- Report vulnerabilities privately — see [SECURITY.md](SECURITY.md).
- `.env`, `client_secret*.json`, key material, and `vithey-secrets/` are git-ignored.
- Never paste secrets into issues, PRs, or commits.

## Documentation

The documentation package starts at
[docs/00-project-overview/07-document-index.md](docs/00-project-overview/07-document-index.md).
