# Requirements Traceability Matrix (RTM)

> Status: Verified baseline · Last reviewed: 2026-09-30
> Evidence: `api_docs.md`, `backend/infrastructure/config-repo/`, `backend/services/`, `ai_core/vithey_ai/api/flutter_routes.py`, `monitoring/`
> Rule: **Status = Verified only when a file path plus an endpoint/entity is cited.** Otherwise **TBD — Requires confirmation.**
> Verification here means a code/config artefact exists; it does **not** assert a passing test or successful runtime execution.

## 1. Legend

| Status | Meaning |
| --- | --- |
| Verified | Path + endpoint/entity evidence cited in the repository |
| Partial | Implemented with a documented gap or stub |
| Gap | Known missing behaviour |
| TBD — Requires confirmation. | No sufficient evidence, or a business decision is needed |

## 2. Functional requirements

### 2.1 Authentication

| Req ID | Description | Endpoint / entity | Evidence path | Status |
| --- | --- | --- | --- | --- |
| FR-AUTH-001 | Register with email/phone/password/role | `POST /auth/register` | `api_docs.md` §3; `AuthController.java` | Verified |
| FR-AUTH-002 | Login returns tokens | `POST /auth/login` | `api_docs.md` §3; `AuthService.java` | Verified |
| FR-AUTH-003 | Refresh token | `POST /auth/refresh` | `api_docs.md` §3; `TokenService.java` | Verified |
| FR-AUTH-004 | Logout | `POST /auth/logout` | `api_docs.md` §3 | Verified |
| FR-AUTH-005 | Current identity | `GET /auth/me` | `api_docs.md` §3 | Verified |
| FR-AUTH-006 | Email verification | `POST /auth/verify-email` | `EmailVerificationToken.java` | Verified |
| FR-AUTH-007 | Password reset | `POST /auth/forgot-password`, `/reset-password` | `PasswordResetService.java` | Verified |
| FR-AUTH-008 | Change password | `PATCH /auth/me/password` | `ChangePasswordRequest.java` | Verified |
| FR-AUTH-009 | Student verification | `POST /students/verify` | `StudentVerificationController.java` | Verified |
| FR-AUTH-010 | Publish auth events | exchange `vithey.events` | EVIDENCE-BASIS §4 | Verified |
| FR-AUTH-011 | Send verification/reset mail | `AuthMailSender`, `LoggingAuthMailSender` | `auth-service/.../mail/` | Verified |
| FR-AUTH-012 | Gateway JWT gate for verify | gateway route | `PublicPathMatcher.java`; `api_docs.md` §15 | Verified |

### 2.2 User profile & search

| Req ID | Description | Endpoint / entity | Evidence path | Status |
| --- | --- | --- | --- | --- |
| FR-USER-001 | Get own profile | `GET /users/me` | `api_docs.md` §4; `UserController` | Verified |
| FR-USER-002 | Get public profile | `GET /users/{user_id}` | `api_docs.md` §4 | Verified |
| FR-USER-003 | Update own profile | `PATCH /users/me` | `api_docs.md` §4 | Verified |
| FR-USER-004 | Set avatar | `PATCH /users/me/avatar` | `api_docs.md` §4 | Verified |
| FR-USER-005 | Settings read/update | `GET/PATCH /users/me/settings` | `SettingsController` | Verified |
| FR-USER-006 | User search (min 2 chars) | `GET /users/search` | `api_docs.md` §4; `UserSearchService` | Verified |
| FR-USER-007 | Publish `profile.updated` | exchange `vithey.events` | EVIDENCE-BASIS §4 | Verified |
| FR-USER-008 | Consume `user.registered` | queue `user-profile.user.registered` | EVIDENCE-BASIS §4 | Verified |

### 2.3 Files

| Req ID | Description | Endpoint / entity | Evidence path | Status |
| --- | --- | --- | --- | --- |
| FR-FILE-001 | Upload with type | `POST /files/upload` | `api_docs.md` §5; `FileController` | Verified |
| FR-FILE-002 | File metadata + URL | `GET /files/{file_id}` | `api_docs.md` §5 | Verified |
| FR-FILE-003 | Owner-restricted download | `GET /files/{file_id}/download` | `api_docs.md` §5 | Verified |
| FR-FILE-004 | Delete owned file | `DELETE /files/{file_id}` | `api_docs.md` §5 | Verified |
| FR-FILE-005 | MinIO + metadata storage | `FileMetadata` | EVIDENCE-BASIS §3, §8 | Verified |

### 2.4 Content & social

| Req ID | Description | Endpoint / entity | Evidence path | Status |
| --- | --- | --- | --- | --- |
| FR-CONTENT-001 | Paginated feed | `GET /posts` | `PostController` | Verified |
| FR-CONTENT-002 | Create post | `POST /posts` | `api_docs.md` §6 | Verified |
| FR-CONTENT-003 | Get post | `GET /posts/{post_id}` | `api_docs.md` §6 | Verified |
| FR-CONTENT-004 | Delete post | `DELETE /posts/{post_id}` | `api_docs.md` §6 | Verified |
| FR-CONTENT-005 | User posts | `GET /users/{user_id}/posts` | `api_docs.md` §6 | Verified |
| FR-CONTENT-006 | Comment CRUD | `/posts/{id}/comments` | `CommentService` | Verified |
| FR-CONTENT-007 | Toggle reaction | `POST /posts/{id}/reactions` | `api_docs.md` §6 | Verified |
| FR-CONTENT-008 | Follow graph | `/users/{id}/follow...` | `FollowService` | Verified |
| FR-CONTENT-009 | Post update missing | `PATCH /posts/{post_id}` | `api_docs.md` §15 | Gap |
| FR-CONTENT-010 | Publish content events | exchange `vithey.events` | EVIDENCE-BASIS §4 | Verified |

### 2.5 Career

| Req ID | Description | Endpoint / entity | Evidence path | Status |
| --- | --- | --- | --- | --- |
| FR-CAREER-001 | Submit application | `POST /job-applications` | `JobApplicationService` | Verified |
| FR-CAREER-002 | List applications | `GET /job-applications` | `api_docs.md` §7 | Verified |
| FR-CAREER-003 | Application detail | `GET /job-applications/{id}` | `api_docs.md` §7 | Verified |
| FR-CAREER-004 | CV preview | `GET /job-applications/{id}/cv-preview` | `api_docs.md` §7 | Verified |
| FR-CAREER-005 | Poster-only status update | `PATCH /job-applications/{id}/status` | Action_Plan 7.5 | Verified |
| FR-CAREER-006 | User default CV | `GET/PUT /users/me/cv` | `UserCv` entity | Verified |
| FR-CAREER-007 | Idempotent apply | `Idempotency-Key` | `api_docs.md` §7 | Verified |
| FR-CAREER-008 | Jobs are content posts | `GET /posts?type=JOB` | `api_docs.md` §7, §15 | Gap |

### 2.6 Finance

| Req ID | Description | Endpoint / entity | Evidence path | Status |
| --- | --- | --- | --- | --- |
| FR-FINANCE-001 | List payments | `GET /payments` | `PaymentController` | Verified |
| FR-FINANCE-002 | Own payment detail | `GET /payments/{payment_id}` | `api_docs.md` §8 | Verified |
| FR-FINANCE-003 | Payment alerts | `GET /payments/alerts` | `api_docs.md` §8 | Verified |
| FR-FINANCE-004 | Fee catalog/categories | `GET /fees`, `/fees/categories` | `FeeController` | Verified |
| FR-FINANCE-005 | STUDENT-only enforcement | `@PreAuthorize("hasRole('STUDENT')")` | `FeeController.java`; `PaymentController.java` | Verified |
| FR-FINANCE-006 | Publish payment events | exchange `vithey.events` | EVIDENCE-BASIS §4 | Verified |
| FR-FINANCE-007 | Read-only finance | n/a | Action_Plan 7.6 | Verified |
| FR-FINANCE-008 | ACLEDA Mobile launch | `acleda_mobile_launcher.dart` | Action_Plan 13.2 | TBD — Requires confirmation. |

### 2.7 Chat

| Req ID | Description | Endpoint / entity | Evidence path | Status |
| --- | --- | --- | --- | --- |
| FR-CHAT-001 | List conversations | `GET /conversations` | `api_docs.md` §9 | Verified |
| FR-CHAT-002 | Create message request | `POST /message-requests` | `api_docs.md` §9 | Verified |
| FR-CHAT-003 | Accept/decline/block | `/conversations/{id}/...` | `api_docs.md` §9 | Verified |
| FR-CHAT-004 | History + presence | `/conversations/{id}/messages`, `/presence` | `api_docs.md` §9 | Verified |
| FR-CHAT-005 | Send + mark read | `/messages...` | `api_docs.md` §9 | Verified |
| FR-CHAT-006 | STOMP realtime | `ChatStompController`; `/ws` | Action_Plan 7.8 | Verified |
| FR-CHAT-007 | Block + report | `POST /users/{user_id}/report` | Action_Plan 7.9 | Verified |
| FR-CHAT-008 | Offline Isar cache/outbox | Isar chat models | EVIDENCE-BASIS §7 | Verified |
| FR-CHAT-009 | Publish chat events | exchange `vithey.events` | EVIDENCE-BASIS §4 | Verified |

### 2.8 Notifications

| Req ID | Description | Endpoint / entity | Evidence path | Status |
| --- | --- | --- | --- | --- |
| FR-NOTIF-001 | List notifications | `GET /notifications` | `api_docs.md` §11 | Verified |
| FR-NOTIF-002 | Unread count | `GET /notifications/unread-count` | `api_docs.md` §11 | Verified |
| FR-NOTIF-003 | Mark read / read-all | `PATCH /notifications/...` | `api_docs.md` §11 | Verified |
| FR-NOTIF-004 | Delete notification | `DELETE /notifications/{id}` | `api_docs.md` §11 | Verified |
| FR-NOTIF-005 | Device token register | `POST/DELETE /notifications/devices` | `api_docs.md` §11 | Verified |
| FR-NOTIF-006 | Consume domain events | queues `notification.<rk>` | EVIDENCE-BASIS §4 | Verified |
| FR-NOTIF-007 | Push optional (FCM no-op) | `FcmPushService` | Action_Plan 7.11 | Partial |

### 2.9 Map

| Req ID | Description | Endpoint / entity | Evidence path | Status |
| --- | --- | --- | --- | --- |
| FR-MAP-001 | Nearby places | `GET /places/nearby` | `api_docs.md` §12 | Verified |
| FR-MAP-002 | Search + autocomplete | `/places/search`, `/autocomplete` | `api_docs.md` §12 | Verified |
| FR-MAP-003 | Place detail | `GET /places/{google_place_id}` | `api_docs.md` §12 | Verified |
| FR-MAP-004 | Favorites + history | `/places/favorites`, `/history` | `api_docs.md` §12 | Verified |
| FR-MAP-005 | Graceful degradation | `PlaceCacheService` | `plan.md` §0 | Verified |
| FR-MAP-006 | Opt-in Compose profile | `docker-compose.demo.yml` | `backend/DOCKER.md` | Verified |

### 2.10 AI

| Req ID | Description | Endpoint / entity | Evidence path | Status |
| --- | --- | --- | --- | --- |
| FR-AI-001 | Stub chat | `POST /api/v1/ai/chat` | `flutter_routes.py`; `chat_service.py` | Verified |
| FR-AI-002 | SSE stream | `POST /api/v1/ai/chat/stream` | `flutter_routes.py` | Verified |
| FR-AI-003 | Regenerate | `POST /api/v1/ai/messages/{id}/regenerate` | `flutter_routes.py` | Verified |
| FR-AI-004 | Cancel request | `DELETE /api/v1/ai/chat/requests/{id}` | `chat_registry.py` | Verified |
| FR-AI-005 | Sessions/messages | `/api/v1/ai/sessions...` | `chat_service.py` | Verified |
| FR-AI-006 | CV generate (LLM) | `POST /api/v1/ai/cv/generate` | `cv_app_service.py` | Verified |
| FR-AI-007 | CV suggest | `POST /api/v1/ai/cv/suggest` | `cv_app_service.py` | Partial (stub) |
| FR-AI-008 | Envelope | `flutter_envelope.py` | `ai_core/.../flutter_envelope.py` | Verified |
| FR-AI-009 | Cache + LLM rate limit | `cache.py`; `ratelimit.py` | EVIDENCE-BASIS §6 | Verified |
| FR-AI-010 | Health | `GET /health` | `ai_core/README.md` | Verified |
| FR-AI-011 | Incomplete-profile path | `cv_app_service.py` | `plan.md` §4.1 | Verified |
| FR-AI-012 | Target role + language | `POST /api/v1/ai/cv/generate` | `api_docs.md` §10 | Verified |

### 2.11 Search & gateway

| Req ID | Description | Endpoint / entity | Evidence path | Status |
| --- | --- | --- | --- | --- |
| FR-SEARCH-001 | People search | `GET /users/search` | `api_docs.md` §13 | Verified |
| FR-SEARCH-002 | Post/job/video search | `GET /posts?search=&type=` | `api_docs.md` §13 | Verified |
| FR-SEARCH-003 | Debounce + min length | client behaviour | `api_docs.md` §13 | TBD — Requires confirmation. |
| FR-SEARCH-004 | Device-local recents | client storage | `api_docs.md` §13 | Verified |
| FR-SEARCH-005 | No server aggregator | n/a | `api_docs.md` §13 | Verified |
| FR-GATEWAY-001 | JWT validation | `JwtAuthenticationGlobalFilter` | `api-gateway/.../filter/` | Verified |
| FR-GATEWAY-002 | Header injection | `UserHeaderForwardFilter` | `api-gateway/.../filter/` | Verified |
| FR-GATEWAY-003 | Redis rate limiting | `RedisRateLimiterConfig` | `config-repo/api-gateway.yml` | Verified |
| FR-GATEWAY-004 | CORS | `CorsConfig` | `api-gateway/.../config/` | Verified |
| FR-GATEWAY-005 | Direct AI route | route id `ai-core` | `config-repo/api-gateway.yml` | Verified |
| FR-GATEWAY-006 | WebSocket route | route id `chat-websocket` | `config-repo/api-gateway.yml` | Verified |
| FR-GATEWAY-007 | Request ID | `RequestIdGlobalFilter` | `api-gateway/.../filter/` | Verified |

## 3. Non-functional requirements

| Req ID | Description | Evidence path | Status |
| --- | --- | --- | --- |
| NFR-SEC-001 | JWT on protected APIs | `JwtAuthenticationGlobalFilter` | Verified |
| NFR-SEC-002 | JWT TTLs 15m/7d | `config-repo/application.yml` | Verified |
| NFR-SEC-003 | Bcrypt passwords | `PasswordEncoderConfig` | Verified |
| NFR-SEC-004 | Hashed tokens | `TokenHash`; migrations | Verified |
| NFR-SEC-005 | No committed secrets | EVIDENCE-BASIS §13 | Verified |
| NFR-SEC-006 | STUDENT-only finance | `@PreAuthorize` | Verified |
| NFR-SEC-007 | Formal security assessment | none | TBD — Requires confirmation. |
| NFR-SEC-008 | Secure token storage | `flutter_secure_storage` | Verified |
| NFR-PERF-001 | Redis caching | chat/map cache services | Verified |
| NFR-PERF-002 | LLM input caps | `ai_core/.env.example` | Verified |
| NFR-PERF-003 | Extraction cache | `cache.py` | Verified |
| NFR-PERF-004 | Gateway rate limit | `config-repo/api-gateway.yml` | Verified |
| NFR-PERF-005 | CV latency < 60s | `plan.md` §7.2 | TBD — Requires confirmation. |
| NFR-PERF-006 | SSE streaming | `flutter_routes.py` | Verified |
| NFR-SCAL-001 | ~10 concurrent users | `plan.md` §0 | Verified (design) |
| NFR-SCAL-002 | Container caps | `docker-compose.demo.yml` | Verified |
| NFR-SCAL-003 | DB pool caps | `backend/.env.example` | Verified |
| NFR-SCAL-004 | Horizontal scale | none | TBD — Requires confirmation. |
| NFR-AVAIL-001 | Health endpoints | `/actuator/health`; `/health` | Verified |
| NFR-AVAIL-002 | Circuit breaker | `config-repo/application.yml` | Verified |
| NFR-AVAIL-003 | Map degradation | `PlaceCacheService` | Verified |
| NFR-AVAIL-004 | Production HA | none | TBD — Requires confirmation. |
| NFR-AVAIL-005 | Staging/production | EVIDENCE-BASIS §9 | TBD — Requires confirmation. |
| NFR-MAINT-001 | Maven multi-module | `backend/pom.xml` | Verified |
| NFR-MAINT-002 | Standard package layout | `docs/Prompt Backend/COMMON_CONTEXT.md` | Verified |
| NFR-MAINT-003 | snake_case envelope | `api_docs.md` §1 | Verified |
| NFR-MAINT-004 | Central config | `config-repo/*.yml` | Verified |
| NFR-MAINT-005 | CI quality gates | `.github/workflows/` | Verified |
| NFR-COMPAT-001 | Java 21 | `backend/pom.xml` | Verified |
| NFR-COMPAT-002 | Python 3.10+ | `ai_core/pyproject.toml` | Verified |
| NFR-COMPAT-003 | Android target | `vithey_app/README.md` | Verified |
| NFR-COMPAT-004 | Web unsupported | `vithey_app/README.md` | Verified |
| NFR-COMPAT-005 | iOS support | none | TBD — Requires confirmation. |
| NFR-OBS-001 | Prometheus metrics | `/actuator/prometheus` | Verified |
| NFR-OBS-002 | Scrape 8 services | `monitoring/prometheus/prometheus.yml` | Verified |
| NFR-OBS-003 | Grafana dashboards | `monitoring/grafana/dashboards/` | Verified |
| NFR-OBS-004 | Loki/Promtail | `monitoring/loki/`, `promtail/` | Verified |
| NFR-OBS-005 | Alertmanager routing | none | TBD — Requires confirmation. |
| NFR-OBS-006 | X-Request-ID tracing | `RequestIdGlobalFilter` | Verified |
| NFR-DATA-001 | DB per service | `backend/services/*/.../db/migration/` | Verified |
| NFR-DATA-002 | Flyway, no edits | migrations; `AGENTS.md` | Verified |
| NFR-DATA-003 | Schema validation | `config-repo/application.yml` | Verified |
| NFR-DATA-004 | Data defect fixes | DD-01..DD-04 | TBD — Requires confirmation. |
| NFR-DATA-005 | Bounded retention | `plan.md` §3.4 | TBD — Requires confirmation. |
| NFR-COST-001 | Chat is zero-cost stub | `chat_service.py` | Verified |
| NFR-COST-002 | LLM rate limit | `ratelimit.py` | Verified |
| NFR-COST-003 | Content-hash cache | `cache.py` | Verified |
| NFR-COST-004 | Single-PC budget | `plan.md` §3 | Verified (design) |
| NFR-USAB-001 | Light/dark themes | theme files | Verified |
| NFR-USAB-002 | English UI / Khmer pref | `AppStrings` | Verified |
| NFR-USAB-003 | en/km CV output | `api_docs.md` §10 | Verified |
| NFR-USAB-004 | Full Khmer l10n | none | TBD — Requires confirmation. |
| NFR-USAB-005 | Accessibility | placeholder | TBD — Requires confirmation. |
| NFR-USAB-006 | 2FA/biometrics | placeholder | TBD — Requires confirmation. |
| NFR-I18N-001 | en/km preference | `api_docs.md` §4 | Verified |
| NFR-I18N-002 | snake_case always | `application.yml` | Verified |
| NFR-COMP-001 | CV owner-restricted | `api_docs.md` §5 | Verified |
| NFR-COMP-002 | Block/report | chat-service | Verified |
| NFR-COMP-003 | Data protection obligations | none | TBD — Requires confirmation. |
| NFR-TEST-001 | Unit/context tests | `backend/TESTING.md` | Verified |
| NFR-TEST-002 | Smoke ITs | `*SmokeIT` | Verified |
| NFR-TEST-003 | ai_core pytest | `ai_core/tests/` | Verified |
| NFR-TEST-004 | Expand Flutter tests | only 3 files | Partial |
| NFR-TEST-005 | Smoke in default build | no failsafe | TBD — Requires confirmation. |

## 4. Use case → requirement mapping

| Use case | Requirements |
| --- | --- |
| UC-AUTH-001 | FR-AUTH-001, FR-AUTH-010 |
| UC-AUTH-002 | FR-AUTH-002 |
| UC-AUTH-003 | FR-AUTH-003, FR-AUTH-004 |
| UC-AUTH-004 | FR-AUTH-009, FR-FINANCE-005 |
| UC-USER-001 | FR-USER-001..005, FR-USER-007 |
| UC-USER-002 | FR-USER-006 |
| UC-CONTENT-001 | FR-CONTENT-001, 006..008 |
| UC-CONTENT-002 | FR-CONTENT-002, FR-FILE-001 |
| UC-CAREER-001 | FR-CAREER-001, FR-CAREER-007 |
| UC-CAREER-002 | FR-CAREER-005 |
| UC-FINANCE-001 | FR-FINANCE-001..005 |
| UC-CHAT-001 | FR-CHAT-002, FR-CHAT-003 |
| UC-CHAT-002 | FR-CHAT-005, FR-CHAT-006, FR-CHAT-008 |
| UC-AI-001 | FR-AI-006, FR-AI-011, NFR-COST-002 |
| UC-AI-002 | FR-AI-001..005 |
| UC-NOTIF-001 | FR-NOTIF-001..005 |
| UC-MAP-001 | FR-MAP-001..005 |

## 5. Outstanding items requiring confirmation

- ACLEDA Mobile deep-link acceptance (FR-FINANCE-008): requires device confirmation.
- Data defects DD-01..DD-04 (NFR-DATA-004): require a fix decision.
- Smoke tests in the default build (NFR-TEST-005): requires build wiring.
- Alertmanager routing (NFR-OBS-005): requires decision.
- iOS support (NFR-COMPAT-005), Khmer l10n (NFR-USAB-004), accessibility (NFR-USAB-005), 2FA/biometrics (NFR-USAB-006): require scope decisions.
- Formal security assessment (NFR-SEC-007), UAT, and production deployment: not executed.

## 6. Related documents

- [`03-functional-requirements.md`](03-functional-requirements.md)
- [`04-non-functional-requirements.md`](04-non-functional-requirements.md)
- [`08-acceptance-criteria.md`](08-acceptance-criteria.md)
- [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)
