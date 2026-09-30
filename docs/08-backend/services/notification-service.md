# notification-service

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/notification-service/`, `backend/infrastructure/config-repo/notification-service.yml`, `backend/services/notification-service/src/main/resources/db/migration/`

Part of the Vithey documentation set · Master index:
[`../../00-project-overview/07-document-index.md`](../../00-project-overview/07-document-index.md) ·
Siblings: [Backend architecture](../01-backend-architecture.md) ·
[Microservice architecture](../02-microservice-architecture.md) ·
[Event-driven](../06-event-driven-architecture.md) · [Error handling](../08-error-handling.md) ·
API: [`../../06-api/10-notification-api.md`](../../06-api/10-notification-api.md).

## 1. Purpose

Consumes domain events and materialises a per-user notification inbox, exposes list/unread/read/delete
APIs, and (optionally) sends FCM push. [VERIFIED]

## 2. Responsibilities

- Consume 10 routing keys on `vithey.events` and create deduplicated notifications.
- Resolve post authors via content-service for social events.
- Never leak sensitive bodies (chat text and CV URLs are excluded).
- Serve inbox, unread count, mark read / read-all, delete.
- Register/unregister FCM device tokens and push when Firebase is configured.

## 3. Port and identity

| Item | Value |
|---|---|
| Port | `8088` (`SERVER_PORT`) |
| Eureka name | `notification-service` |
| Database | `notification_db` |
| Gateway route | `/api/v1/notifications/**` |

[VERIFIED]

## 4. Main controllers

| Controller | Base path | Endpoints |
|---|---|---|
| `NotificationController` | `/api/v1/notifications` | `GET`, `GET /unread-count`, `PATCH /read-all`, `PATCH /{id}/read`, `DELETE /{id}` |
| `DeviceTokenController` | `/api/v1/notifications/devices` | `POST`, `DELETE /{token}` |

[VERIFIED]

## 5. Main services

| Service | Responsibility |
|---|---|
| `NotificationService` | List/unread/mark/delete; `createAndPush` with dedupe key; triggers FCM |
| `EventNotificationService` | Maps each consumed event to a notification type/title/destination; audience resolution |
| `DeviceTokenService` | Upsert/remove FCM tokens per user |
| `FcmPushService` | Sends FCM messages when `FirebaseApp.getApps()` is non-empty; data payload all-strings |

[VERIFIED]

## 6. Repositories

`NotificationRepository` (incl. `findByUserIdFilteringRead`, `markAllRead`,
`existsByUserIdAndDedupeKey`), `DeviceTokenRepository`. [VERIFIED]

## 7. Entities and tables (`notification_db`)

| Entity | Table |
|---|---|
| `Notification` | `notifications` (`user_id`, `type`, `title`, `body`, `reference_id`, `reference_type`, `is_read`, `read_at`, `event`, `actor_id`, `actor_name`, `actor_avatar_url`, jsonb `destination`, `dedupe_key`) |
| `DeviceToken` | `device_tokens` (`user_id`, `fcm_token`, `platform`) |

`NotificationType`: `LIKE, COMMENT, MENTION, FOLLOW, CHAT, CHAT_REQUEST, JOB, PAYMENT, SYSTEM,
STUDENT_VERIFICATION`. `DevicePlatform`: `ANDROID|IOS`. [VERIFIED]

## 8. Database

Flyway: `V1__init_notification_schema.sql`, `V2__Notification_type_and_platform_checks.sql`,
`V3__Notifications_unread_recency_index.sql`, `V4__notification_ui_upgrade.sql` (4).
`ddl-auto: validate`. Unique `ux_notifications_user_dedupe` on `(user_id, dedupe_key)`.
DB `CHECK` additionally allows `MESSAGE, APPLICATION_UPDATE, PAYMENT_DUE, POST_SHARE, AI`
(enum superset — defect #4). [VERIFIED]

## 9. API routes

See [`../../06-api/10-notification-api.md`](../../06-api/10-notification-api.md). `meta` may carry
`unread_total`; `notification_id` is a backward-compatible alias of `id`.

## 10. Events

Consumes (queues `notification.<routing-key>`): `comment.added`, `reaction.added`, `follow.created`,
`mention.created`, `chat.request.received`, `chat.message.sent`, `payment.due`, `payment.overdue`,
`job.application.submitted`, `job.application.status_changed`.

Produces: none. [VERIFIED]

## 11. Cache usage

None. [VERIFIED]

## 12. External dependencies

- Feign `ContentServiceClient` → `GET /api/v1/posts/{postId}` (resolve post author; failure returns
  `null` and the event is skipped).
- RabbitMQ (10 durable queues). Firebase Admin SDK when `FIREBASE_CREDENTIALS_PATH` is set.
  [VERIFIED]

## 13. Auth and authorization

All endpoints require JWT; notifications/devices are scoped to the JWT subject; `findById` filters
by `user_id`. [VERIFIED]

## 14. Configuration (env names only)

`SERVER_PORT`, `NOTIFICATION_DB_URL`, `NOTIFICATION_DB_USERNAME`, `NOTIFICATION_DB_PASSWORD`,
`RABBITMQ_*`, `EUREKA_CLIENT_ENABLED`, `EUREKA_URL`, `VITHEY_JWT_SECRET`, `VITHEY_EVENTS_EXCHANGE`,
`FIREBASE_CREDENTIALS_PATH` (empty by default → push disabled). [VERIFIED]

## 15. Health checks

`GET /actuator/health`. [VERIFIED]

## 16. Tests

| Type | Path |
|---|---|
| Context (H2) | `NotificationServiceContextTest.java` |
| Smoke (Postgres+Rabbit) | `NotificationServiceSmokeIT.java` |
| Unit | `service/NotificationServiceTest.java` |

Test implemented — current execution result not independently verified.

## 17. Known limitations / TBD

- Flutter has FCM commented out (no Firebase packages), but the server device API and push code
  exist. Server push delivery is not verifiable from the repo. `TBD — Requires confirmation.`
- Allowed keys in `destination`: `TBD — Requires confirmation.`
- Enum vs DB `CHECK` superset (defect #4).
