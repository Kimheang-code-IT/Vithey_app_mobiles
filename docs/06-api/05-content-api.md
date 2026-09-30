# Content API (content-service)

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/content-service/src/main/java/com/vithey/content/controller/*.java`, `dto/**`

Base paths: `/api/v1` (posts), `/api/v1/posts/{postId}/comments`, `/api/v1/posts/{postId}/reactions`,
`/api/v1/users/{userId}` (follow graph). Service port `8084`.

Job **listings** are posts with `type=JOB`; there is no separate `/api/v1/jobs` controller even
though the gateway has a `/api/v1/jobs/**` route. [VERIFIED: `PostController`, `api-gateway.yml`]

## 1. Endpoint inventory

| Method | Path | Auth | Required role | Purpose | Request | Response | Errors |
|---|---|---|---|---|---|---|---|
| GET | `/api/v1/posts` | JWT | any | Home feed or search | `?search=&type=&page=&limit=` | `PostResponse[]` + meta | 401 |
| POST | `/api/v1/posts` | JWT | any | Create post | `CreatePostRequest` | `PostResponse` | 400, 401 |
| GET | `/api/v1/posts/{postId}` | JWT | any | Post detail | path | `PostResponse` | 401, 404 |
| DELETE | `/api/v1/posts/{postId}` | JWT | owner | Soft-delete own post | path | `204` | 401, 403, 404 |
| PATCH | `/api/v1/posts/{postId}` | JWT | owner | Update own post (content; `job_meta` for JOB) | `UpdatePostRequest` | `PostResponse` | 400, 401, 403, 404 |
| GET | `/api/v1/users/{userId}/posts` | JWT | any | A user's posts | `?type=&page=&limit=` | `PostResponse[]` + meta | 401 |
| GET | `/api/v1/posts/{postId}/comments` | JWT | any | List comments | `?page=&limit=` | `CommentResponse[]` + meta | 401, 404 |
| POST | `/api/v1/posts/{postId}/comments` | JWT | any | Add comment (+mentions) | `CreateCommentRequest` | `CommentResponse` | 400, 401, 404 |
| PATCH | `/api/v1/posts/{postId}/comments/{commentId}` | JWT | author | Edit comment | `UpdateCommentRequest` | `CommentResponse` | 400, 401, 403, 404 |
| DELETE | `/api/v1/posts/{postId}/comments/{commentId}` | JWT | author | Delete comment | path | `204` | 401, 403, 404 |
| POST | `/api/v1/posts/{postId}/reactions` | JWT | any | Toggle like | path | `ReactionSummaryResponse` | 401, 404 |
| GET | `/api/v1/posts/{postId}/reactions` | JWT | any | Reaction summary | path | `ReactionSummaryResponse` | 401, 404 |
| POST | `/api/v1/users/{userId}/follow` | JWT | any | Follow user (idempotent) | path | `201` empty | 401, 422 (self-follow) |
| DELETE | `/api/v1/users/{userId}/follow` | JWT | any | Unfollow | path | `204` | 401 |
| GET | `/api/v1/users/{userId}/followers` | JWT | any | List followers | `?page=&limit=` | `AuthorSummaryResponse[]` + meta | 401 |
| GET | `/api/v1/users/{userId}/following` | JWT | any | List following | `?page=&limit=` | `AuthorSummaryResponse[]` + meta | 401 |

Feed semantics: without `search`, returns posts from followed users plus the viewer, newest first.
With `search`, performs global content search (optional `type` filter).

## 2. Request/response schemas

`CreatePostRequest`: `type` (`VIDEO`|`POSTER`|`JOB`), `content`, `media_file_id`, `job_meta`
(`{ title, description, requirement, deadline }`). `CreateCommentRequest`: `text` (required),
`mention_user_ids[]`. `UpdateCommentRequest`: `text`.

`PostResponse` = `post_id, author { user_id, full_name, avatar_url }, type, content, media_url,
job_meta { title, description, requirement, deadline }, reaction_count, comment_count,
user_reacted, created_at`.
`CommentResponse` = `comment_id, post_id, author, text, created_at`.
`ReactionSummaryResponse` = `reaction_count, user_reacted`.
`AuthorSummaryResponse` = `user_id, full_name, avatar_url`.

> Media posts require `media_file_id` validated via file-service. Events published:
> `post.created`, `comment.added`, `reaction.added`, `follow.created`, `mention.created`.
> [VERIFIED: `AGENTS.md` §RabbitMQ, controllers]

## 3. Examples

### GET `/api/v1/posts?page=1&limit=20` → 200

```json
{
  "data": [
    {
      "post_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "author": {
        "user_id": "f984000a-38f4-46e5-a047-019d20a66ce0",
        "full_name": "Jane Doe",
        "avatar_url": "http://localhost:19000/avatars/..."
      },
      "type": "POSTER",
      "content": "Check out my project poster",
      "media_url": "http://localhost:19000/posters/...",
      "job_meta": null,
      "reaction_count": 3,
      "comment_count": 1,
      "user_reacted": true,
      "created_at": "2026-07-28T02:00:00Z"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 1, "total_pages": 1 }
}
```

### POST `/api/v1/posts` → 201 (JOB)

```json
{
  "type": "JOB",
  "content": "We are hiring",
  "job_meta": {
    "title": "Flutter Intern",
    "description": "Build mobile features",
    "requirement": "Year 3+ CS",
    "deadline": "2026-08-01"
  }
}
```

### POST `/api/v1/posts/{postId}/comments` → 201

```json
{ "text": "Great post!", "mention_user_ids": ["018a4379-a9e0-4391-8285-c231aeea577c"] }
```

### POST `/api/v1/posts/{postId}/reactions` → 200

```json
{ "data": { "reaction_count": 4, "user_reacted": true } }
```

## 4. Data touched

`content_db`: `posts`, `comments`, `mentions`, `reactions`, `follows`. Enum/CHECK differences (e.g.
DB allows `STANDARD`) are defect #4. See
[`../05-database/03-database-schema.md`](../05-database/03-database-schema.md) §4.

## 5. Known gaps

- `PATCH /api/v1/posts/{postId}` is implemented in `PostController` (owner-only: updates `content`
  and, for JOB posts, `job_meta`). Post type and media are immutable. [VERIFIED]
- The gateway `/api/v1/jobs/**` route has no controller. [VERIFIED]

## 6. TBD

- Post edit concurrency/versioning (optimistic locking): `TBD — Requires confirmation.`
- Feed ranking algorithm (only recency + follow graph is verifiable): `TBD — Requires confirmation.`
