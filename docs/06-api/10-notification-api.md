# Notification API (notification-service)

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/notification-service/src/main/java/com/vithey/notification/controller/*.java`, `dto/**`

Base path: `/api/v1/notifications` (`NotificationController` + `DeviceTokenController`). Service port
`8088`. All endpoints require JWT. The notification `meta` may include an extra `unread_total`.
FCM push delivery is **not** wired in Flutter (Firebase commented out), but the device API exists.

## 1. Endpoint inventory

| Method | Path | Auth | Required role | Purpose | Request | Response | Errors |
|---|---|---|---|---|---|---|---|
| GET | `/api/v1/notifications` | JWT | any | List my inbox | `?page=&limit=&is_read=` | `NotificationResponse[]` + meta (may include `unread_total`) | 401 |
| GET | `/api/v1/notifications/unread-count` | JWT | any | Unread badge count | — | `UnreadCountResponse` | 401 |
| PATCH | `/api/v1/notifications/read-all` | JWT | any | Mark all read | — | `MarkAllReadResponse` | 401 |
| PATCH | `/api/v1/notifications/{notificationId}/read` | JWT | owner | Mark one read | path | `NotificationResponse` | 401, 404 |
| DELETE | `/api/v1/notifications/{notificationId}` | JWT | owner | Delete notification | path | `204` | 401, 404 |
| POST | `/api/v1/notifications/devices` | JWT | any | Register FCM device | `RegisterDeviceRequest` | `DeviceTokenResponse` | 400, 401 |
| DELETE | `/api/v1/notifications/devices/{token}` | JWT | owner | Unregister device | path `token` | `204` | 401 |

## 2. Schemas

`RegisterDeviceRequest`: `fcm_token` (required), `platform` (`ANDROID`|`IOS`, required).
`NotificationResponse` = `id, notification_id, type, event, title, body, is_read, created_at,
read_at, reference_id, reference_type, actor { id, full_name, avatar_url }, destination, dedupe_key`.
`MarkAllReadResponse` = `{ updated_count }`. `UnreadCountResponse` = `{ count }`.
`DeviceTokenResponse` = `{ device_id, fcm_token, platform }`.

`notification_id` is a backward-compatible alias of `id`.

### Types (canonical `NotificationType` enum)
`LIKE, COMMENT, MENTION, FOLLOW, CHAT, CHAT_REQUEST, JOB, PAYMENT, SYSTEM, STUDENT_VERIFICATION`.
The DB CHECK additionally allows `MESSAGE, APPLICATION_UPDATE, PAYMENT_DUE, POST_SHARE, AI`
(defect #4). Flutter additionally defines `postShare`/`aiAssistantResponse`, which the backend never
emits.

### Producers (events → inbox)
Notification consumes RabbitMQ queues for comment/reaction/follow/mention/chat.request/chat.message/
payment.due/payment.overdue/job.* on exchange `vithey.events`. Idempotent ingestion is enforced by
`ux_notifications_user_dedupe` on `(user_id, dedupe_key)`.

## 3. Examples

### GET `/api/v1/notifications?page=1&limit=20&is_read=false` → 200

```json
{
  "data": [
    {
      "id": "e5f6a7b8-...",
      "notification_id": "e5f6a7b8-...",
      "type": "LIKE",
      "event": "reaction.added",
      "title": "New like",
      "body": "Jane liked your post",
      "is_read": false,
      "created_at": "2026-09-30T08:00:00Z",
      "read_at": null,
      "reference_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "reference_type": "POST",
      "actor": {
        "id": "018a4379-a9e0-4391-8285-c231aeea577c",
        "full_name": "Jane Doe",
        "avatar_url": "http://localhost:19000/avatars/..."
      },
      "destination": { "screen": "post" },
      "dedupe_key": null
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 1, "total_pages": 1, "unread_total": 1 }
}
```

### POST `/api/v1/notifications/devices` → 201

```json
{ "fcm_token": "device-token", "platform": "ANDROID" }
```

### PATCH `/api/v1/notifications/read-all` → 200

```json
{ "data": { "updated_count": 5 } }
```

## 4. Data touched

`notification_db`: `notifications`, `device_tokens`. See
[`../05-database/03-database-schema.md`](../05-database/03-database-schema.md) §8.

## 5. TBD

- FCM push sending on the server (Firebase credentials path config exists but delivery is not
  verifiable from the repo): `TBD — Requires confirmation.`
- Allowed keys in `destination`: `TBD — Requires confirmation.`
