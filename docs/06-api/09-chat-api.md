# Chat API (chat-service)

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/chat-service/src/main/java/com/vithey/chat/controller/*.java`, `websocket/ChatStompController.java`, `dto/**`

Base paths: `/api/v1/conversations`, `/api/v1/messages`, `/api/v1/message-requests`,
`/api/v1/users/{userId}/report`. Service port `8087`. All REST endpoints require JWT. Real-time
chat uses STOMP over `/ws` — see [`13-websocket-api.md`](13-websocket-api.md).

## 1. REST endpoint inventory

| Method | Path | Auth | Required role | Purpose | Request | Response | Errors |
|---|---|---|---|---|---|---|---|
| GET | `/api/v1/conversations` | JWT | any | List my conversations | `?page=&limit=` | `ConversationResponse[]` + meta | 401 |
| POST | `/api/v1/conversations/start` | JWT | any | Create a message request (alias) | `MessageRequestDto` | `ConversationResponse` | 400, 401 |
| POST | `/api/v1/conversations/{conversationId}/accept` | JWT | recipient | Accept pending request | path | `ConversationResponse` | 401, 403, 404 |
| POST | `/api/v1/conversations/{conversationId}/decline` | JWT | recipient | Decline request | path | `ConversationResponse` | 401, 403, 404 |
| POST | `/api/v1/conversations/{conversationId}/block` | JWT | participant | Block conversation | path | `ConversationResponse` | 401, 403, 404 |
| GET | `/api/v1/conversations/{conversationId}/presence` | JWT | participant | Partner presence | path | `PresenceResponse` | 401, 403, 404 |
| GET | `/api/v1/conversations/{conversationId}/messages` | JWT | participant | List messages | `?page=&limit=` | `MessageResponse[]` + meta | 401, 403 |
| POST | `/api/v1/conversations/{conversationId}/messages` | JWT | participant | Send message (REST) | `SendMessageRequest` | `MessageResponse` | 400, 401, 403 |
| POST | `/api/v1/conversations/{conversationId}/messages/read` | JWT | participant | Batch mark read | `BatchReadRequest` | `MessageResponse[]` | 400, 401, 403 |
| PATCH | `/api/v1/messages/{messageId}/read` | JWT | recipient | Mark one read | path | `MessageResponse` | 401, 403, 404 |
| GET | `/api/v1/message-requests` | JWT | any | Pending request inbox | — | `ConversationResponse[]` | 401 |
| POST | `/api/v1/message-requests` | JWT | any | Create pending request (preferred) | `MessageRequestDto` | `ConversationResponse` | 400, 401 |
| POST | `/api/v1/users/{userId}/report` | JWT | any | Report a user | `ReportUserRequest` (`reason`) | `ReportResponse` | 400, 401 |

> `POST /conversations/start` and `POST /message-requests` both call
> `ConversationService.createRequest`. The message-request path is preferred; the controller comment
> notes `/conversations/start` can 401 on some deployments due to `/{conversationId}/**` matching.

## 2. Schemas

`MessageRequestDto`: `to_user_id` (required), `initial_message` (required).
`SendMessageRequest`: `text`, `client_message_id`, `reply_to_message_id`, `message_type`
(`TEXT|IMAGE|FILE`), `file_id`. `BatchReadRequest`: `message_ids[]`. `ReportUserRequest`: `reason`.

`MessageResponse` = `message_id, conversation_id, sender_id, text, message_type, file_id, file_url,
reply_to_message_id, status, created_at`.
`ConversationResponse` = `conversation_id, status, participant { ... }, last_message { ... },
unread_count, is_online, updated_at`.
`PresenceResponse` = `user_id, status, last_seen_at`.
`ReportResponse` = `report_id, reported_id, reason, created_at`.

`message_type`: `TEXT | IMAGE | FILE` — upload a `CHAT_ATTACHMENT` file first for media. Events
published: `chat.request.received`, `chat.message.sent`. Recent messages cached in Redis
(`chat:recent:*`, 24 h). [VERIFIED]

## 3. Examples

### POST `/api/v1/message-requests` → 201

```json
{ "to_user_id": "018a4379-a9e0-4391-8285-c231aeea577c", "initial_message": "Hi!" }
```

### POST `/api/v1/conversations/{conversationId}/messages` → 201

```json
{
  "text": "Hello",
  "client_message_id": "client-uuid",
  "message_type": "TEXT",
  "reply_to_message_id": null,
  "file_id": null
}
```

```json
{
  "data": {
    "message_id": "d4e5f6a7-...",
    "conversation_id": "c1d2e3f4-...",
    "sender_id": "018a4379-a9e0-4391-8285-c231aeea577c",
    "text": "Hello",
    "message_type": "TEXT",
    "file_id": null,
    "file_url": null,
    "reply_to_message_id": null,
    "status": "SENT",
    "created_at": "2026-09-30T08:00:00Z"
  }
}
```

### POST `/api/v1/conversations/{conversationId}/messages/read` → 200

```json
{ "message_ids": ["d4e5f6a7-...", "d4e5f6a8-..."] }
```

## 4. Data touched

`chat_db`: `conversations`, `conversation_participants`, `messages`, `blocks`, `user_reports`.
Several CHECK supersets apply (`ARCHIVED`/`CLOSED`, `MEMBER`/`ADMIN`, `DELETED`) — defect #4. See
[`../05-database/03-database-schema.md`](../05-database/03-database-schema.md) §7.

## 5. TBD

- Conversation "close"/"archive" endpoints (DB allows the states but no REST mapping found):
  `TBD — Requires confirmation.`
- `after`/`before` message cursors (only `page`/`limit` are implemented): `TBD — Requires
  confirmation.`
