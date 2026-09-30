# Service Registry

**Single source of truth** for build order, ports, and Eureka names.  
Other prompts must link here instead of copying this table.

## Build order

| # | Folder | Port | Eureka name | Notes |
| --- | --- | --- | --- | --- |
| 0 | `backend/infrastructure/` | 8761, 8888 | — | Start first; creates `vithey-network` |
| 1 | `backend/services/api-gateway/` | 8080 | `api-gateway` | Start **last** among apps |
| 2 | `backend/services/auth-service/` | 8081 | `auth-service` | |
| 3 | `backend/services/user-profile-service/` | 8082 | `user-profile-service` | |
| 4 | `backend/services/file-service/` | 8083 | `file-service` | Before content/career |
| 5 | `backend/services/content-service/` | 8084 | `content-service` | |
| 6 | `backend/services/career-service/` | 8085 | `career-service` | |
| 7 | `backend/services/finance-service/` | 8086 | `finance-service` | |
| 8 | `backend/services/chat-service/` | 8087 | `chat-service` | |
| 9 | `backend/services/notification-service/` | 8088 | `notification-service` | |
| 10 | `backend/services/ai-service/` | 8089 | `ai-service` | Java stub in repo; Python optional |
| 11 | `backend/services/map-service/` | 8090 | `map-service` | Google Places nearby/shop search + filters |

Paths relative to repo root. See [REPO_PATHS.md](REPO_PATHS.md).

## Shared infrastructure ports

| Component | Port |
| --- | --- |
| PostgreSQL | 5432 |
| Redis | 6379 |
| RabbitMQ | 5672 (AMQP), 15672 (UI) |
| MinIO | 9000 (API), 9001 (console) |
| Eureka | 8761 |
| Config Server | 8888 |

## Screen → backend map

| Screens | Backend services |
| --- | --- |
| Splash, Select Language, Onboarding | — (local only) |
| Auth (login/register/Google coming soon), Student Verification, change password | auth-service |
| Home, Create Post, Post Detail, Reels | content-service, file-service |
| Apply / Preview / Applicant CV | career-service, file-service |
| Profile, Settings | user-profile-service, auth-service |
| Finance | finance-service (STUDENT role) |
| Chat | chat-service |
| AI Chatbot | ai-service |
| Notification | notification-service |
| Map / nearby shops | map-service (`/map`, `/add-place`) |

Full screen index: `Prompt Frontend/Screen prompt/README.md`.

## Gateway route prefixes

**Order matters** — specific `/users/...` paths before `/api/v1/users/**`.

Full table: `Prompt Frontend/api-intergration/integration-contract.md` → Gateway routes.

## Per-service shared infra (Docker)

| Service | Service compose includes | Uses shared infra for |
| --- | --- | --- |
| api-gateway | api-gateway only | redis, eureka-server, config-server |
| auth-service | auth-service + auth-postgres | rabbitmq, eureka-server, config-server |
| user-profile-service | user-profile-service + profile-postgres | rabbitmq, eureka-server, config-server |
| file-service | file-service + file-postgres | minio, eureka-server, config-server |
| content-service | content-service + content-postgres | rabbitmq, eureka-server, config-server |
| career-service | career-service + career-postgres | rabbitmq, eureka-server, config-server |
| finance-service | finance-service + finance-postgres | rabbitmq, eureka-server, config-server |
| chat-service | chat-service + chat-postgres | redis, rabbitmq, eureka-server, config-server |
| notification-service | notification-service + notification-postgres | rabbitmq, eureka-server, config-server |
| ai-service | ai-service + ai-postgres | redis, eureka-server, config-server |
| map-service | map-service + map-postgres | redis, eureka-server, config-server |

Rule: **never duplicate** Eureka, Config, RabbitMQ, Redis, or MinIO in service compose files.
