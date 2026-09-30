# content-service

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/content-service/`, `backend/infrastructure/config-repo/content-service.yml`, `backend/infrastructure/config-repo/api-gateway.yml`

Part of the Vithey documentation set · Master index:
[`../../00-project-overview/07-document-index.md`](../../00-project-overview/07-document-index.md) ·
Siblings: [Backend architecture](../01-backend-architecture.md) ·
[Microservice architecture](../02-microservice-architecture.md) ·
[Event-driven](../06-event-driven-architecture.md) · [Error handling](../08-error-handling.md) ·
API: [`../../06-api/05-content-api.md`](../../06-api/05-content-api.md).

## 1. Purpose

Owns the social graph and content: posts (including job posts), comments, likes/reactions, follows
and mentions. Feeds and global content search live here. [VERIFIED]

## 2. Responsibilities

- Create/read/soft-delete posts; validate media via file-service; enrich responses with author and
  media URL via user-profile and file services.
- Comment CRUD with mention fan-out.
- Toggle like/reaction and report counts.
- Follow/unfollow (self-follow rejected) and follower/following lists.
- Compose the home feed (followed users + self, newest first) and content search (`type` filter).
- Publish content events.

## 3. Port and identity

| Item | Value |
|---|---|
| Port | `8084` (`SERVER_PORT`) |
| Eureka name | `content-service` |
| Database | `content_db` |
| Gateway routes | `/api/v1/posts/**`, `/comments/**`, `/reactions/**`, `/follows/**`, `/users/*/{follow,followers,following,posts}` |

[VERIFIED]

## 4. Main controllers

| Controller | Base path | Endpoints |
|---|---|---|
| `PostController` | `/api/v1` | `GET/POST /posts`, `GET/DELETE /posts/{postId}`, `GET /users/{userId}/posts` |
| `CommentController` | `/api/v1/posts/{postId}/comments` | list, create, patch, delete |
| `ReactionController` | `/api/v1/posts/{postId}/reactions` | `POST` toggle, `GET` summary |
| `FollowController` | `/api/v1/users/{userId}` | `POST/DELETE /follow`, `GET /followers`, `GET /following` |

[VERIFIED]

## 5. Main services

| Service | Responsibility |
|---|---|
| `PostService` | Create/get/delete posts; media validation via file-service; publish `post.created` |
| `FeedService` | Home feed: followed author IDs + self, `createdAt` descending |
| `PostSearchService` | Global search (`search` ≥ 2 chars, optional `type`) |
| `PostEnrichmentService` | Batch author/media resolution + reaction/comment counts; per-request in-memory caches |
| `CommentService` | Comments + mentions; publish `comment.added`, `mention.created` |
| `ReactionService` | Toggle reaction; publish `reaction.added` |
| `FollowService` | Follow/unfollow; publish `follow.created` |

[VERIFIED]

## 6. Repositories

`PostRepository` (incl. `searchByText`, grouped counts), `CommentRepository`, `ReactionRepository`,
`FollowRepository`, `MentionRepository`. [VERIFIED]

## 7. Entities and tables (`content_db`)

| Entity | Table |
|---|---|
| `Post` | `posts` (`author_id`, `type` `VIDEO|POSTER|JOB`, `content`, `media_file_id`, job_* columns, `created_at`, `deleted_at`) |
| `Comment` | `comments` (`post_id`, `author_id`, `text`) |
| `Reaction` | `reactions` (`post_id`, `user_id`) |
| `Follow` | `follows` (`follower_id`, `following_id`) |
| `Mention` | `mentions` (`comment_id`, `mentioned_user_id`) |

[VERIFIED]

## 8. Database

Flyway: `V1__init_content_schema.sql`, `V2__Content_indexes_checks_and_drop_dead.sql`,
`V3__Restore_reaction_and_mention_indexes.sql`, `V4__Cascade_deletes_and_no_self_follow.sql`,
`V5__Posts_created_active_partial_index.sql` (5). `ddl-auto: validate`. [VERIFIED]

## 9. API routes

See [`../../06-api/05-content-api.md`](../../06-api/05-content-api.md). `PATCH /posts/{post_id}` is
referenced by `api_docs.md` but has **no controller mapping** → `404`.

## 10. Events

| Direction | Routing keys |
|---|---|
| Produces | `post.created`, `comment.added`, `reaction.added`, `follow.created`, `mention.created` |

No consumers. `post.created` has no consumer queue. [VERIFIED]

## 11. Cache usage

None (no Redis). `PostEnrichmentService` keeps **per-request** maps only. [VERIFIED]

## 12. External dependencies

- Feign `UserProfileClient` → `GET /api/v1/users/{userId}` (author summaries).
- Feign `FileServiceClient` → `GET /api/v1/files/{fileId}` (media URL, type validation).
- `FeignAuthConfig` forwards `Authorization` + `X-User-*`. RabbitMQ for events. [VERIFIED]

## 13. Auth and authorization

All endpoints require JWT. Delete/edit require author ownership; self-follow returns
`BUSINESS_RULE_VIOLATION` (422). [VERIFIED]

## 14. Configuration (env names only)

`SERVER_PORT`, `CONTENT_DB_URL`, `CONTENT_DB_USERNAME`, `CONTENT_DB_PASSWORD`, `RABBITMQ_*`,
`EUREKA_CLIENT_ENABLED`, `EUREKA_URL`, `VITHEY_JWT_SECRET`, `VITHEY_EVENTS_EXCHANGE`. [VERIFIED]

## 15. Health checks

`GET /actuator/health`. [VERIFIED]

## 16. Tests

| Type | Path |
|---|---|
| Context (H2) | `ContentServiceContextTest.java` |
| Smoke (Postgres+Rabbit) | `ContentServiceSmokeIT.java` |
| Unit | `service/PostServiceTest.java`, `service/CommentServiceTest.java`, `service/FollowServiceTest.java` |

Test implemented — current execution result not independently verified.

## 17. Known limitations / TBD

- `PATCH /posts/{post_id}` not implemented (contract gap).
- Enum vs DB `CHECK` superset (`STANDARD`) — defect #4.
- Feed ranking is recency + follow graph only; ranking algorithm `TBD — Requires confirmation.`
- Job listings use `posts` with `type=JOB`; the gateway `/api/v1/jobs/**` route has no controller.
