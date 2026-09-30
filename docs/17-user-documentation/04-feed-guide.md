# Feed, Posts, Search & Notifications Guide

> Status: Verified (core) · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/modules/home/**`, `vithey_app/lib/modules/search/**`, `api_docs.md` §6, §11, §13
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

## 1. Home feed

The Home tab (`/home`) shows a paginated feed of `POSTER`, `VIDEO`, and `JOB` posts
[VERIFIED: `lib/modules/home/home_controller.dart`, `api_docs.md` §6].

- Feed source: `GET /posts?page=&limit=`; infinite scroll loads the next page and de-duplicates by
  post id [VERIFIED: `home_controller.dart`].
- Media header (Telegram-style) shows circular recent-media items; tapping your own opens the
  composer, others open the post or author profile [VERIFIED: `home_controller.dart`].
- **Smart ranking:** page 1 can be re-ranked by AI feed recommendations (`USE_AI_FEED`), with a
  **chronological fallback** when AI is off, empty, or fails. Eligible job posts may be boosted
  [VERIFIED: `home_controller.dart` `_applySmartRanking`].
- Pull to refresh; pagination errors are surfaced non-destructively [VERIFIED: `home_controller.dart`].

### Interactions

| Action | Endpoint | Notes |
| --- | --- | --- |
| React (like) | `POST /posts/{id}/reactions` | Toggle; returns `reaction_count`, `user_reacted` |
| Comment | `GET/POST /posts/{id}/comments` | Add/edit/delete comments |
| Follow / unfollow | `POST`/`DELETE /users/{id}/follow` | Idempotent |
| Share | in-app share sheet | Uses device share |
| Edit post | `PATCH /posts/{post_id}` | **Not implemented server-side** → `404` |
| Delete post | `DELETE /posts/{post_id}` | Owner only → `204` |

[VERIFIED: `api_docs.md` §6, §15 known gaps]

> **Known gap:** the app's edit-post action calls `PATCH /posts/{post_id}`, which has no backend
> mapping today and returns `404` [VERIFIED: `api_docs.md` §6, §15].

## 2. Reels

The Reel tab (`/reels`) plays video posts full-screen [VERIFIED: `lib/modules/home/reels/`].

## 3. Create a post

The composer (`/create-post`) supports [VERIFIED: `lib/modules/home/create_post/`]:

1. **Poster / video:** upload media first (`POST /files/upload`, `type=POSTER` or `VIDEO`) → then
   `POST /posts` with `media_file_id`.
2. **Job listing** (`COMPANY`): `POST /posts` with `type=JOB` and `job_meta`
   (`title`, `description`, `requirement`, `deadline`).

A scheduling sheet is available in the composer UI [VERIFIED: `create_post/widgets/create_post_schedule_sheet.dart`].

## 4. Post detail

`/posts/detail` shows a full post with comments [VERIFIED: `lib/modules/home/post_detail/`].
Comment actions: `GET /posts/{id}/comments`, `POST` (with optional `mention_user_ids`), `PATCH`,
`DELETE` [VERIFIED: `api_docs.md` §6]. Mentions render a mention-user box.

## 5. Search

Cross-service search (no single aggregator) [VERIFIED: `lib/modules/search/`, `api_docs.md` §13]:

| Tab | Endpoint |
| --- | --- |
| People | `GET /users/search?search={q}` (min 2 chars) |
| Posts / Jobs / Videos | `GET /posts?search={q}&type=` |

- Debounce 350 ms; **recent search history is device-local only** (not an API)
  [VERIFIED: `api_docs.md` §13].
- "See all" results open `/search/see-all`; tapping a place-style result can open the Map with the
  query [VERIFIED: `lib/modules/search/search_controller.dart`, `search_results_view.dart`].

## 6. Notifications

Notifications tab (`/notifications`) shows a paginated inbox with **All / Unread / Read** filters and
in-header search [VERIFIED: `lib/modules/home/notification/notification_controller.dart`].

| Action | Endpoint |
| --- | --- |
| List | `GET /notifications?page&limit&is_read=` |
| Unread count | `GET /notifications/unread-count` |
| Mark one | `PATCH /notifications/{id}/read` |
| Mark all | `PATCH /notifications/read-all` |
| Delete | `DELETE /notifications/{id}` |

Notification types emitted by the backend: `LIKE`, `COMMENT`, `MENTION`, `FOLLOW`, `CHAT`,
`CHAT_REQUEST`, `JOB`, `PAYMENT`, `SYSTEM`, `STUDENT_VERIFICATION` [VERIFIED: `api_docs.md` §11].

- Tapping a notification routes to the relevant screen via `NotificationRouter`
  [VERIFIED: `lib/data/push/notification_router.dart`].
- The Flutter enum also defines `postShare` and `aiAssistantResponse`, but the backend never emits
  them [VERIFIED: `api_docs.md` §11].

> **Push delivery is not active (Stub).** FCM is disabled (`FCM_ENABLED=false`) and no Firebase
> packages/`google-services.json` are wired; the in-app inbox works from the REST API, but device
> push banners do not [VERIFIED: `.env.example`, `_meta/EVIDENCE-BASIS.md` §7].

## 7. Related

- [05-job-cv-guide.md](05-job-cv-guide.md) · [08-ai-assistant-guide.md](08-ai-assistant-guide.md) · [09-map-guide.md](09-map-guide.md)
- [../06-api/05-content-api.md](../06-api/05-content-api.md) · [../06-api/10-notification-api.md](../06-api/10-notification-api.md)
- Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)
