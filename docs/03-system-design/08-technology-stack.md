# Technology Stack

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/pom.xml`, `backend/services/*/pom.xml`, `vithey_app/pubspec.yaml`, `ai_core/pyproject.toml`, `ai_core/Dockerfile`, `backend/docker-compose.yml`, `.github/workflows/`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [System architecture](01-system-architecture.md) · [Network architecture](07-network-architecture.md)

Versions below are taken directly from build manifests or pinned image tags. Where a value is a caret/range dependency, the declared constraint is shown verbatim.

## 1. Backend (`backend/`)

| Technology | Version (declared) | Evidence |
|---|---|---|
| Java | 21 | `backend/pom.xml` `<java.version>21` |
| Spring Boot | 3.3.5 (parent) | `backend/pom.xml` |
| Spring Cloud | 2023.0.3 | `backend/pom.xml` `<spring-cloud.version>` |
| Spring Cloud Gateway | managed by SD 2023.0.3 (reactive) | `api-gateway.yml` `web-application-type: reactive` |
| Spring Cloud Netflix Eureka | managed | `eureka-server` module |
| Spring Cloud Config (native) | managed | `config-server` module |
| Spring Cloud OpenFeign | managed; circuit breaker enabled | `config-repo/application.yml` |
| Spring AMQP (RabbitMQ) | managed | service `RabbitMqConfig` |
| MapStruct | 1.5.5.Final | `backend/pom.xml` |
| JJWT | 0.12.6 | `backend/pom.xml` |
| Resilience4j | 2.2.0 | `backend/pom.xml` |
| Testcontainers | 1.20.4 | `backend/pom.xml` |
| Flyway | Spring Boot-managed | service `application.yml` `flyway.enabled: true` |
| Build tool | Maven (multi-module) | `backend/pom.xml` `<modules>` |
| Packaging runtime | Temurin 21 JRE / alpine, non-root `vithey` | service `Dockerfile` |
| API docs | springdoc / Swagger UI (`/swagger-ui.html`) | `auth-service/application.yml` |

Properties block (verbatim): `java.version=21`, `spring-cloud.version=2023.0.3`, `mapstruct.version=1.5.5.Final`, `jjwt.version=0.12.6`, `testcontainers.version=1.20.4`, `resilience4j.version=2.2.0`.

## 2. Flutter client (`vithey_app/`)

| Package | Declared constraint | Evidence |
|---|---|---|
| Dart SDK | `>=3.3.0 <4.0.0` | `pubspec.yaml` `environment.sdk` |
| App version | `1.0.0+1` | `pubspec.yaml` |
| Package name | `aub_connect_app` | `pubspec.yaml` |
| GetX | `^4.6.6` | state / DI / routing |
| shadcn_flutter | `^0.0.52` | design layer |
| Dio | `^5.4.0` | HTTP |
| flutter_secure_storage | `^9.0.0` | token storage |
| shared_preferences | `^2.2.2` | settings |
| flutter_dotenv | `^5.1.0` | `.env` config |
| intl | `^0.20.2` | formatting |
| cached_network_image | `^3.3.1` | image cache |
| connectivity_plus | `^5.0.2` | network state |
| file_picker | `^8.1.0` | CV upload |
| image_picker | `^1.0.7` | media |
| video_player | `^2.8.2` | reels |
| permission_handler | `^11.1.0` | runtime permissions |
| url_launcher | `^6.2.4` | external links |
| webview_flutter | `^4.10.0` | in-app web |
| package_info_plus | `^8.0.0` | app info |
| share_plus | `^10.1.4` | sharing |
| stomp_dart_client | `^2.0.0` | chat STOMP |
| isar | `^3.1.0+1` | local DB |
| isar_flutter_libs | `^3.1.0+1` | Isar native libs |
| path_provider | `^2.1.4` | file paths |
| mobile_scanner | `^7.4.0` | QR scan |
| google_maps_flutter | `^2.18.0` | map |
| geolocator | `^14.0.2` | location |
| pdf | `^3.13.0` | CV export |
| gpt_markdown | `^1.2.1` | AI markdown rendering |
| flutter_lints (dev) | `^5.0.0` | lint gate |
| isar_generator (dev) | `^3.1.0+1` | codegen |
| build_runner (dev) | `^2.4.13` | codegen |

Target platform: **Android only** (Isar, secure storage and camera are unsupported on web). [VERIFIED — `vithey_app/README.md`]

## 3. AI engine (`ai_core/`)

| Technology | Version | Evidence |
|---|---|---|
| Python | `>=3.10` (runtime image `python:3.12-slim`) | `pyproject.toml`, `Dockerfile` |
| Distribution | `vithey-ai` 0.2.0, import package `vithey_ai` | `pyproject.toml`, `config.py` |
| FastAPI | `>=0.110,<1` | `Dockerfile` |
| Uvicorn | `>=0.29,<1` (standard) | `Dockerfile` |
| openai SDK | `>=1.40,<2` (wraps any OpenAI-compatible endpoint) | `Dockerfile` |
| pydantic | `>=2.7,<3` | `Dockerfile` |
| httpx | `>=0.27,<1` | `Dockerfile` |
| PyJWT | `>=2.8,<3` | `Dockerfile` |
| psycopg | `>=3.1,<4` (binary) | `Dockerfile` |
| python-dotenv | `>=1.0,<2` | `Dockerfile` |
| Default LLM | OpenRouter GLM `z-ai/glm-5.3-flash` | `config.py` |

Env variable names keep the legacy `DEEPSEEK_*` prefix (`DEEPSEEK_API_KEY`, `DEEPSEEK_BASE_URL`, `DEEPSEEK_MODEL`) even though defaults target OpenRouter. [VERIFIED — `config.py`]

## 4. Data and infrastructure

| Component | Image / version | Host port | Evidence |
|---|---|---|---|
| PostgreSQL | `postgres:16-alpine` | 15432 (15433 infra-only) | `backend/docker-compose.yml` |
| Redis | `redis:7-alpine` | 16379 | `backend/docker-compose.yml` |
| RabbitMQ | `rabbitmq:3-management-alpine` | 5672 / 15672 | `backend/docker-compose.yml` |
| MinIO | `quay.io/minio/minio:latest` | 19000 / 19001 | `backend/docker-compose.yml` |
| Prometheus | `prom/prometheus:latest` | 9090 | `monitoring/docker-compose.yml` |
| Grafana | `grafana/grafana:latest` | 3000 | `monitoring/docker-compose.yml` |
| Loki | `grafana/loki:latest` | 3100 | `monitoring/docker-compose.yml` |
| Promtail | `grafana/promtail:latest` | — | `monitoring/docker-compose.yml` |
| node-exporter | `prom/node-exporter:latest` | 9100 | `monitoring/docker-compose.yml` |
| cAdvisor | `gcr.io/cadvisor/cadvisor:latest` | 8095 | `monitoring/docker-compose.yml` |

RabbitMQ exchange: single topic exchange `vithey.events`. No Kafka anywhere. [VERIFIED — `config-repo/application.yml`, `RabbitMqConfig.java`]

## 5. Build, CI and delivery

| Tool | Detail | Evidence |
|---|---|---|
| CI provider | GitHub Actions | `.github/workflows/` |
| Promotion workflow | `ci-promote-dev.yml` — tests backend + Flutter + ai_core, builds/pushes 13 images to GHCR, fast-forwards passing commit to `dev` | `.github/workflows/ci-promote-dev.yml` |
| Per-service workflows | 9 (`api-gateway`, `auth`, `career`, `chat`, `content`, `file`, `finance`, `notification`, `user-profile`) — test → docker build → compose validate | `.github/workflows/*-ci.yml` |
| Registry | `ghcr.io/<owner>/vithey-<service>`, tags `latest`, `sha-<short>` | workflows |
| Coverage / failsafe | No JaCoCo coverage, no failsafe config; `*SmokeIT` not run by plain `mvn test` | `EVIDENCE-BASIS.md` §8-9 |
| Orchestration | None (no K8s/Helm/Terraform/Jenkins) | `EVIDENCE-BASIS.md` §9 |

## 6. Version governance notes

- Android release currently **signs with debug keys** (explicit TODO in `android/app/build.gradle`). [VERIFIED — `EVIDENCE-BASIS.md` §7]
- Secrets are provided via `.env` (`VITHEY_JWT_SECRET`, `DEEPSEEK_API_KEY`, `MINIO_SECRET_KEY`, `POSTGRES_PASSWORD`, `GOOGLE_PLACES_API_KEY`); only `.env.example` files are tracked. Values must never be documented. [VERIFIED — `EVIDENCE-BASIS.md` §13]
- [TBD] A pinned version matrix/release calendar for the demo — TBD — Requires confirmation.
