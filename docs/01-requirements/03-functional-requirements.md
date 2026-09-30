# Functional Requirements

> Status: Verified baseline · Last reviewed: 2026-09-30
> Evidence: `api_docs.md`, `backend/infrastructure/config-repo/`, `backend/services/`, `ai_core/vithey_ai/api/flutter_routes.py`
> Rule: a requirement is marked **Verified** only when a path plus an endpoint or entity is cited; otherwise **TBD — Requires confirmation.**
> ID convention: `FR-<MODULE>-NNN`.

## 1. Authentication & identity (auth-service)

| ID | Requirement | Interface / entity | Evidence | Status |
| --- | --- | --- | --- | --- |
| FR-AUTH-001 | The system shall allow a new user to register with email, phone, password, full name, and role (`USER`\|`COMPANY`). | `POST /auth/register` | `api_docs.md` §3; `AuthController.java` | Verified |
| FR-AUTH-002 | The system shall authenticate a user with email or phone and password and return access/refresh tokens. | `POST /auth/login` | `api_docs.md` §3; `AuthService.java` | Verified |
| FR-AUTH-003 | The system shall refresh an access token using a valid refresh token. | `POST /auth/refresh` | `api_docs.md` §3; `TokenService.java` | Verified |
| FR-AUTH-004 | The system shall invalidate a session on logout. | `POST /auth/logout` (JWT) | `api_docs.md` §3 | Verified |
| FR-AUTH-005 | The system shall return the current authenticated identity. | `GET /auth/me` | `api_docs.md` §3 | Verified |
| FR-AUTH-006 | The system shall support email verification via a one-time token. | `POST /auth/verify-email` | `api_docs.md` §3; `EmailVerificationToken.java` | Verified |
| FR-AUTH-007 | The system shall support password reset via forgot/reset tokens. | `POST /auth/forgot-password`, `POST /auth/reset-password` | `api_docs.md` §3; `PasswordResetService.java` | Verified |
| FR-AUTH-008 | The system shall allow an authenticated user to change their password. | `PATCH /auth/me/password` | `api_docs.md` §3; `ChangePasswordRequest.java` | Verified |
| FR-AUTH-009 | The system shall grant the `STUDENT` role to a user who verifies a student ID and university email. | `POST /students/verify` | `api_docs.md` §3; `StudentVerificationController.java`, `StudentVerification.java` | Verified |
| FR-AUTH-010 | The system shall publish `user.registered` and `student.verified` events. | RabbitMQ exchange `vithey.events` | EVIDENCE-BASIS §4 | Verified |
| FR-AUTH-011 | The system shall send verification/reset emails; local demo defaults to logging sender. | `AuthMailSender`, `LoggingAuthMailSender` | `auth-service/.../mail/`; Action_Plan 6.3 | Verified |
| FR-AUTH-012 | The system shall gate `/students/verify` behind a JWT at the gateway. | gateway route | `api_docs.md` §15 (documented discrepancy) | Verified |

## 2. User profiles & search (user-profile-service)

| ID | Requirement | Interface / entity | Evidence | Status |
| --- | --- | --- | --- | --- |
| FR-USER-001 | The system shall return the authenticated user's full private profile. | `GET /users/me` | `api_docs.md` §4 | Verified |
| FR-USER-002 | The system shall return another user's public profile. | `GET /users/{user_id}` | `api_docs.md` §4 | Verified |
| FR-USER-003 | The system shall partially update the authenticated user's profile. | `PATCH /users/me` | `api_docs.md` §4 | Verified |
| FR-USER-004 | The system shall set a user's avatar from an uploaded file. | `PATCH /users/me/avatar` | `api_docs.md` §4 | Verified |
| FR-USER-005 | The system shall read and update user settings (language, theme, notifications, privacy). | `GET/PATCH /users/me/settings` | `api_docs.md` §4; `SettingsController` | Verified |
| FR-USER-006 | The system shall provide paginated user search by name (min length 2). | `GET /users/search` | `api_docs.md` §4; Action_Plan 6.6 | Verified |
| FR-USER-007 | The system shall publish `profile.updated` events. | RabbitMQ `vithey.events` | EVIDENCE-BASIS §4 | Verified |
| FR-USER-008 | The system shall consume `user.registered` to seed a profile. | queue `user-profile.user.registered` | EVIDENCE-BASIS §4 | Verified |

## 3. File storage (file-service)

| ID | Requirement | Interface / entity | Evidence | Status |
| --- | --- | --- | --- | --- |
| FR-FILE-001 | The system shall accept multipart uploads with a declared type (`AVATAR`\|`CV`\|`POSTER`\|`VIDEO`\|`CHAT_ATTACHMENT`). | `POST /files/upload` | `api_docs.md` §5; `FileController` | Verified |
| FR-FILE-002 | The system shall return file metadata and a short-lived URL. | `GET /files/{file_id}` | `api_docs.md` §5 | Verified |
| FR-FILE-003 | The system shall stream a file download, restricting CV downloads to the owner. | `GET /files/{file_id}/download` | `api_docs.md` §5; Action_Plan 7.1 | Verified |
| FR-FILE-004 | The system shall allow an owner to delete a file. | `DELETE /files/{file_id}` | `api_docs.md` §5 | Verified |
| FR-FILE-005 | The system shall store file content in MinIO and metadata in PostgreSQL. | `FileMetadata`, MinIO | EVIDENCE-BASIS §3, §8 | Verified |

## 4. Content & social (content-service)

| ID | Requirement | Interface / entity | Evidence | Status |
| --- | --- | --- | --- | --- |
| FR-CONTENT-001 | The system shall list a paginated feed. | `GET /posts` | `api_docs.md` §6; `PostController` | Verified |
| FR-CONTENT-002 | The system shall create poster/video/job posts. | `POST /posts` | `api_docs.md` §6 | Verified |
| FR-CONTENT-003 | The system shall return a single post. | `GET /posts/{post_id}` | `api_docs.md` §6 | Verified |
| FR-CONTENT-004 | The system shall delete an owned post. | `DELETE /posts/{post_id}` | `api_docs.md` §6 | Verified |
| FR-CONTENT-005 | The system shall list a user's posts. | `GET /users/{user_id}/posts` | `api_docs.md` §6 | Verified |
| FR-CONTENT-006 | The system shall support comment create/list/update/delete. | `/posts/{id}/comments` | `api_docs.md` §6; `CommentService` | Verified |
| FR-CONTENT-007 | The system shall toggle reactions on a post. | `POST /posts/{id}/reactions` | `api_docs.md` §6 | Verified |
| FR-CONTENT-008 | The system shall support follow/unfollow and list followers/following. | `/users/{id}/follow` etc. | `api_docs.md` §6; `FollowService` | Verified |
| FR-CONTENT-009 | Post update (PATCH) is not implemented; clients receive `404`. | `PATCH /posts/{post_id}` | `api_docs.md` §6, §15 | Verified (gap) |
| FR-CONTENT-010 | The system shall publish post/comment/reaction/follow/mention events. | RabbitMQ `vithey.events` | EVIDENCE-BASIS §4 | Verified |

## 5. Career & jobs (career-service)

| ID | Requirement | Interface / entity | Evidence | Status |
| --- | --- | --- | --- | --- |
| FR-CAREER-001 | The system shall accept a job application referencing a job post and CV file. | `POST /job-applications` | `api_docs.md` §7; `JobApplicationService` | Verified |
| FR-CAREER-002 | The system shall list applications, optionally filtered by job post. | `GET /job-applications` | `api_docs.md` §7 | Verified |
| FR-CAREER-003 | The system shall return application detail. | `GET /job-applications/{id}` | `api_docs.md` §7 | Verified |
| FR-CAREER-004 | The system shall return a CV preview reference for an application. | `GET /job-applications/{id}/cv-preview` | `api_docs.md` §7 | Verified |
| FR-CAREER-005 | Only the job poster shall update an application status. | `PATCH /job-applications/{id}/status` | `api_docs.md` §7; Action_Plan 7.5 | Verified |
| FR-CAREER-006 | The system shall store and serve a user's default CV reference. | `GET/PUT /users/me/cv` | `api_docs.md` §7; `UserCv` | Verified |
| FR-CAREER-007 | The system shall support idempotent application submission. | `Idempotency-Key` header | `api_docs.md` §7 | Verified |
| FR-CAREER-008 | Job listings are content posts (`type=JOB`); the `/jobs/**` gateway route has no controller. | `GET /posts?type=JOB` | `api_docs.md` §7, §15 | Verified (gap) |

## 6. Finance (finance-service)

| ID | Requirement | Interface / entity | Evidence | Status |
| --- | --- | --- | --- | --- |
| FR-FINANCE-001 | The system shall list a verified student's payments with pagination. | `GET /payments` | `api_docs.md` §8; `PaymentController` | Verified |
| FR-FINANCE-002 | The system shall return a single owned payment. | `GET /payments/{payment_id}` | `api_docs.md` §8 | Verified |
| FR-FINANCE-003 | The system shall return payment deadline alerts. | `GET /payments/alerts` | `api_docs.md` §8 | Verified |
| FR-FINANCE-004 | The system shall return the fee catalog and categories. | `GET /fees`, `GET /fees/categories` | `api_docs.md` §8; `FeeController` | Verified |
| FR-FINANCE-005 | The system shall restrict finance endpoints to `STUDENT` (else `403`). | `@PreAuthorize("hasRole('STUDENT')")` | `FeeController.java`, `PaymentController.java` | Verified |
| FR-FINANCE-006 | The system shall publish `payment.due` / `payment.overdue` events. | RabbitMQ `vithey.events` | EVIDENCE-BASIS §4 | Verified |
| FR-FINANCE-007 | The system is read-only; there is no payment mutation endpoint. | n/a | Action_Plan 7.6 | Verified (constraint) |
| FR-FINANCE-008 | The client shall launch ACLEDA Mobile from the finance screen. | `acleda_mobile_launcher.dart` | Action_Plan 13.2 | [INFERRED] — requires business confirmation. |

## 7. Peer chat (chat-service)

| ID | Requirement | Interface / entity | Evidence | Status |
| --- | --- | --- | --- | --- |
| FR-CHAT-001 | The system shall list a user's conversations with pagination. | `GET /conversations` | `api_docs.md` §9 | Verified |
| FR-CHAT-002 | The system shall create a message request to a new peer. | `POST /message-requests` | `api_docs.md` §9 | Verified |
| FR-CHAT-003 | The system shall allow accepting, declining, and blocking a conversation. | `/conversations/{id}/accept|decline|block` | `api_docs.md` §9 | Verified |
| FR-CHAT-004 | The system shall return message history and presence. | `/conversations/{id}/messages`, `/presence` | `api_docs.md` §9 | Verified |
| FR-CHAT-005 | The system shall send messages and mark them read (single and batch). | `/conversations/{id}/messages`, `/messages/{id}/read` | `api_docs.md` §9 | Verified |
| FR-CHAT-006 | The system shall deliver realtime messages over STOMP at `/ws`. | `ChatStompController`, `WebSocketConfig` | `api_docs.md` §9; Action_Plan 7.8 | Verified |
| FR-CHAT-007 | The system shall support blocking and user reporting. | `POST /users/{user_id}/report` | `api_docs.md` §9; Action_Plan 7.9 | Verified |
| FR-CHAT-008 | The client shall cache conversations/messages and queue offline sends in Isar. | Isar `chat` models | EVIDENCE-BASIS §7 | Verified |
| FR-CHAT-009 | The system shall publish `chat.request.received` and `chat.message.sent` events. | RabbitMQ `vithey.events` | EVIDENCE-BASIS §4 | Verified |

## 8. Notifications (notification-service)

| ID | Requirement | Interface / entity | Evidence | Status |
| --- | --- | --- | --- | --- |
| FR-NOTIF-001 | The system shall list notifications with read filters and pagination. | `GET /notifications` | `api_docs.md` §11 | Verified |
| FR-NOTIF-002 | The system shall return an unread count. | `GET /notifications/unread-count` | `api_docs.md` §11 | Verified |
| FR-NOTIF-003 | The system shall mark one or all notifications read. | `PATCH /notifications/{id}/read`, `/read-all` | `api_docs.md` §11 | Verified |
| FR-NOTIF-004 | The system shall delete a notification. | `DELETE /notifications/{id}` | `api_docs.md` §11 | Verified |
| FR-NOTIF-005 | The system shall register/unregister device tokens for push. | `POST/DELETE /notifications/devices` | `api_docs.md` §11 | Verified |
| FR-NOTIF-006 | The system shall consume domain events and create notifications. | queues `notification.<routing-key>` | EVIDENCE-BASIS §4 | Verified |
| FR-NOTIF-007 | Push delivery shall be optional; FCM is a no-op without credentials. | `FcmPushService` | Action_Plan 7.11 | Verified (constraint) |

## 9. Map & places (map-service, opt-in)

| ID | Requirement | Interface / entity | Evidence | Status |
| --- | --- | --- | --- | --- |
| FR-MAP-001 | The system shall return nearby places for coordinates with filters. | `GET /places/nearby` | `api_docs.md` §12 | Verified |
| FR-MAP-002 | The system shall support text search and autocomplete. | `GET /places/search`, `/autocomplete` | `api_docs.md` §12 | Verified |
| FR-MAP-003 | The system shall return place detail. | `GET /places/{google_place_id}` | `api_docs.md` §12 | Verified |
| FR-MAP-004 | The system shall manage favorites and search history. | `/places/favorites`, `/places/history` | `api_docs.md` §12 | Verified |
| FR-MAP-005 | The service shall degrade gracefully if the Places key is absent. | `PlaceCacheService`, circuit breaker | `plan.md` §0; Action_Plan 7.12 | Verified |
| FR-MAP-006 | The service shall be opt-in via the `map` Compose profile. | `docker-compose.demo.yml` | `backend/DOCKER.md` | Verified |

## 10. AI (ai_core)

| ID | Requirement | Interface / entity | Evidence | Status |
| --- | --- | --- | --- | --- |
| FR-AI-001 | The system shall provide a chat endpoint returning a topic-stub reply. | `POST /api/v1/ai/chat` | `flutter_routes.py`; `chat_service.py` | Verified |
| FR-AI-002 | The system shall stream chat replies as SSE (`meta`→`token`*→`done`/`error`). | `POST /api/v1/ai/chat/stream` | `flutter_routes.py` | Verified |
| FR-AI-003 | The system shall regenerate an assistant reply. | `POST /api/v1/ai/messages/{id}/regenerate` | `flutter_routes.py` | Verified |
| FR-AI-004 | The system shall cancel an in-flight chat request. | `DELETE /api/v1/ai/chat/requests/{request_id}` | `flutter_routes.py`; `chat_registry.py` | Verified |
| FR-AI-005 | The system shall list and delete chat sessions and messages with pagination. | `/api/v1/ai/sessions...` | `flutter_routes.py`; `chat_service.py` | Verified |
| FR-AI-006 | The system shall generate an `AiCvDraft` from profile and recent posts using the LLM. | `POST /api/v1/ai/cv/generate` | `cv_app_service.py` | Verified |
| FR-AI-007 | The system shall provide CV section suggestions (stubbed). | `POST /api/v1/ai/cv/suggest` | `cv_app_service.py` | Verified (stub) |
| FR-AI-008 | The system shall return the `{data,meta,error}` envelope. | `flutter_envelope.py` | `ai_core/.../flutter_envelope.py` | Verified |
| FR-AI-009 | The system shall cache extraction results by content hash and rate-limit LLM calls. | `cache.py`, `ratelimit.py` | EVIDENCE-BASIS §6 | Verified |
| FR-AI-010 | The system shall report liveness/config health. | `GET /health` | `ai_core/README.md` | Verified |
| FR-AI-011 | The system shall return an incomplete-profile result without calling the LLM when inputs are insufficient. | `cv_app_service.py` | `plan.md` §4.1 | Verified |
| FR-AI-012 | The system may support CV tailoring to a target role and language (`en`\|`km`). | `POST /api/v1/ai/cv/generate` body | `api_docs.md` §10 | Verified |

## 11. Search (client fan-out)

| ID | Requirement | Interface / entity | Evidence | Status |
| --- | --- | --- | --- | --- |
| FR-SEARCH-001 | The client shall search people via the user endpoint. | `GET /users/search` | `api_docs.md` §13 | Verified |
| FR-SEARCH-002 | The client shall search posts/jobs/videos via the content endpoint. | `GET /posts?search=&type=` | `api_docs.md` §13 | Verified |
| FR-SEARCH-003 | The client shall debounce queries and enforce a minimum length of 2. | client behaviour | `api_docs.md` §13 | [INFERRED] — requires confirmation |
| FR-SEARCH-004 | Recent search history shall be device-local only. | client storage | `api_docs.md` §13 | Verified |
| FR-SEARCH-005 | There shall be no server-side `/search` aggregator. | n/a | `api_docs.md` §13 | Verified |

## 12. Gateway & cross-cutting

| ID | Requirement | Interface / entity | Evidence | Status |
| --- | --- | --- | --- | --- |
| FR-GATEWAY-001 | The gateway shall validate JWTs on protected routes. | `JwtAuthenticationGlobalFilter` | `api-gateway/.../filter/` | Verified |
| FR-GATEWAY-002 | The gateway shall inject `X-User-Id`, `X-User-Roles`, `X-User-Email`. | `UserHeaderForwardFilter` | same | Verified |
| FR-GATEWAY-003 | The gateway shall rate-limit routes using Redis. | `RedisRateLimiterConfig` | `config-repo/api-gateway.yml` | Verified |
| FR-GATEWAY-004 | The gateway shall apply CORS policy. | `CorsConfig` | same | Verified |
| FR-GATEWAY-005 | The gateway shall route `/api/v1/ai/**` directly to `ai_core` (not Eureka). | route id `ai-core` | `config-repo/api-gateway.yml` | Verified |
| FR-GATEWAY-006 | The gateway shall route `/ws/**` to chat-service over WebSocket. | route id `chat-websocket` | `config-repo/api-gateway.yml` | Verified |
| FR-GATEWAY-007 | The gateway shall forward `X-Request-ID`. | `RequestIdGlobalFilter` | `api-gateway/.../filter/` | Verified |

## 13. Related documents

- [`04-non-functional-requirements.md`](04-non-functional-requirements.md)
- [`06-use-cases.md`](06-use-cases.md)
- [`09-requirements-traceability-matrix.md`](09-requirements-traceability-matrix.md)
