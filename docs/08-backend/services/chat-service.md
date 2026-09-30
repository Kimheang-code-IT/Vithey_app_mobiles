# chat-service

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/chat-service/`, `backend/infrastructure/config-repo/chat-service.yml`, `backend/services/chat-service/src/main/resources/db/migration/`

Part of the Vithey documentation set · Master index:
[`../../00-project-overview/07-document-index.md`](../../00-project-overview/07-document-index.md) ·
Siblings: [Backend architecture](../01-backend-architecture.md) ·
[Microservice architecture](../02-microservice-architecture.md) · [Cache strategy](../07-cache-strategy.md) ·
[Event-driven](../06-event-driven-architecture.md) · [Error handling](../08-error-handling.md) ·
API: [`../../06-api/09-chat-api.md`](../../06-api/09-chat-api.md) ·
WebSocket: [`../../06-api/13-websocket-api.md`](../../06-api/13-websocket-api.md).

## 1. Purpose

Peer-to-peer chat: message requests, conversations, messages (text/image/file), read receipts,
typing/presence and user reports — over REST plus STOMP/WebSocket. [VERIFIED]

## 2. Responsibilities

- Create message requests; recipient accept/decline; block.
- Send/list messages; batch or single read receipts; reply-to support.
- Validate chat attachments via file-service.
- Real-time delivery via STOMP user destinations; presence and typing in Redis.
- Report a user (moderation record only).

## 3. Port and identity

| Item | Value |
|---|---|
| Port | `8087` (`SERVER_PORT`) |
| Eureka name | `chat-service` |
| Database | `chat_db` + Redis |
| Gateway routes | `/api/v1/conversations/**`, `/messages/**`, `/message-requests/**`, `/users/*/report`, `/ws/**` (`lb:ws://chat-service`) |

[VERIFIED]

## 4. Main controllers

| Controller | Base path / mapping |
|---|---|
| `ConversationController` | `/api/v1/conversations` (list, start, accept, decline, block, presence, `GET/POST …/messages`, `…/messages/read`) |
| `MessageController` | `/api/v1/conversations/{id}/messages`, `/api/v1/messages/{id}/read` |
| `MessageRequestController` | `/api/v1/message-requests` |
| `ReportController` | `/api/v1/users/{userId}/report` |
| `ChatStompController` | STOMP `/chat.send`, `/chat.typing`, `/chat.heartbeat`, `/chat.read` |

[VERIFIED]

## 5. Main services

| Service | Responsibility |
|---|---|
| `ConversationService` | Requests, accept/decline/block, presence, conversation DTOs; publish `chat.request.received` |
| `MessageService` | Send/list/read; idempotent by `client_message_id`; media validation; publish `chat.message.sent` |
| `ConversationAccessService` | Participant/recipient/active-messaging/block checks |
| `ChatFileValidationService` | File type `CHAT_ATTACHMENT`, ownership, MIME for IMAGE |
| `RealtimeMessageService` | `convertAndSendToUser` for messages/receipts/typing/presence |
| `MessageCacheService` | `chat:recent:*` list (24 h, trimmed) |
| `PresenceService` | `chat:presence:*` (90 s TTL) + broadcast |
| `TypingService` | `chat:typing:*` (5 s TTL) + broadcast |
| `ParticipantProfileService` | Feign profile resolution for participants |
| `ReportService` | Persist user reports |

[VERIFIED]

## 6. Repositories

`ConversationRepository`, `ConversationParticipantRepository`, `MessageRepository`,
`BlockRepository`, `UserReportRepository`. [VERIFIED]

## 7. Entities and tables (`chat_db`)

| Entity | Table |
|---|---|
| `Conversation` | `conversations` (`status`) |
| `ConversationParticipant` | `conversation_participants` (composite PK, `role`) |
| `Message` | `messages` (`conversation_id`, `sender_id`, `text`, `message_type`, `file_id`, `reply_to_message_id`, `client_message_id`, `status`, `deleted_at`) |
| `Block` | `blocks` (composite PK `blocker_id`/`blocked_id`) |
| `UserReport` | `user_reports` (`reporter_id`, `reported_id`, `reason`) |

`ConversationStatus`, `ParticipantRole`, `MessageType` (`TEXT|IMAGE|FILE`), `MessageStatus`. [VERIFIED]

## 8. Database

Flyway: `V1__init_chat_schema.sql`, `V2__message_media_and_reply.sql`,
`V3__cascade_deletes_checks_and_indexes.sql` (3). `ddl-auto: validate`.
DB `CHECK` supersets (`ARCHIVED`/`CLOSED`, `MEMBER`/`ADMIN`, `DELETED`) — defect #4. [VERIFIED]

## 9. API routes

REST: [`../../06-api/09-chat-api.md`](../../06-api/09-chat-api.md). Real-time: STOMP 1.2 over `/ws`
(app prefix `/app`, user prefix `/user`, simple broker `/queue`,`/topic`), documented in
[`../../06-api/13-websocket-api.md`](../../06-api/13-websocket-api.md).

## 10. Events

| Direction | Routing keys |
|---|---|
| Produces | `chat.request.received`, `chat.message.sent` |

No consumers. Notification-service consumes both (never including message bodies). [VERIFIED]

## 11. Cache usage

Redis (imperative): `chat:recent:<conversationId>` (24 h), `chat:presence:<userId>` (90 s),
`chat:typing:<conversationId>:<userId>` (5 s). See [Cache strategy](../07-cache-strategy.md).
[VERIFIED]

## 12. External dependencies

- Feign `FileServiceClient` → `GET /api/v1/files/{fileId}` (chat attachments).
- Feign `UserProfileClient` → `GET /api/v1/users/{userId}` (participant profiles).
- `FeignAuthConfig` forwards identity headers. RabbitMQ for events. Redis for real-time state.
  [VERIFIED]

## 13. Auth and authorization

JWT validated at the WebSocket handshake (`JwtHandshakeInterceptor`) and per message
(`StompAuthChannelInterceptor`). REST requires JWT; all operations enforce participant/recipient
checks; blocks are enforced on send. [VERIFIED]

## 14. Configuration (env names only)

`SERVER_PORT`, `CHAT_DB_URL`, `CHAT_DB_USERNAME`, `CHAT_DB_PASSWORD`, `RABBITMQ_*`, `REDIS_HOST`,
`REDIS_PORT`, `EUREKA_CLIENT_ENABLED`, `EUREKA_URL`, `VITHEY_JWT_SECRET`, `VITHEY_EVENTS_EXCHANGE`.
Chat TTLs use `vithey.chat.*` code defaults (90 s presence, 5 s typing, 50 recent). [VERIFIED]

## 15. Health checks

`GET /actuator/health`. [VERIFIED]

## 16. Tests

| Type | Path |
|---|---|
| Context (H2, mock Rabbit+Redis) | `ChatServiceContextTest.java` |
| Smoke (Postgres+Rabbit+Redis) | `ChatServiceSmokeIT.java` |
| Unit | `service/ConversationServiceTest.java` |

Test implemented — current execution result not independently verified.

## 17. Known limitations / TBD

- Simple in-memory broker → multi-replica fan-out would need a broker relay. `TBD — Requires
  confirmation.`
- No conversation close/archive endpoint despite DB states. `TBD — Requires confirmation.`
- Message history cursors: only `page`/`limit` (no `after`/`before`). `TBD — Requires confirmation.`
- Enum vs DB `CHECK` supersets (defect #4).
