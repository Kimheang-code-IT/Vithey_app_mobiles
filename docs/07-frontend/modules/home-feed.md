# Module: Home Feed

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/modules/home/`, `vithey_app/lib/data/repositories/post_repository.dart`, `vithey_app/lib/data/services/post_service.dart`

## Purpose

The social core: a mixed feed of posters/videos/jobs, reels (video-only feed), post creation/editing, post detail with comments, sharing, and the main tab shell. Backed by `content-service` + `file-service`. [VERIFIED]

## Screens & routes

| Screen | Route | File |
| --- | --- | --- |
| Main shell (tabs) | `/home` | `lib/modules/home/shell/main_shell_screen.dart` |
| Reels | `/reels` | `lib/modules/home/reels/reels_screen.dart` |
| Create/Edit Post | `/create-post` | `lib/modules/home/create_post/create_post_screen.dart` |
| Post Detail | `/posts/detail` | `lib/modules/home/post_detail/post_detail_screen.dart` |
| Post Analytics | `/posts/analytics` | `lib/modules/profile/post_analytics_screen.dart` |

[VERIFIED] `lib/routes/app_pages.dart`.

## Main widgets

- Feed cards: `post_card.dart`, `poster_post_card.dart`, `video_post_card.dart`, `job_poster_card.dart`, `mixed_post_feed.dart`, `post_author_header.dart`, `home_media_header.dart`.
- Interaction: `feed_action_bar.dart`, `comment_sheet.dart`, `share_sheet.dart`, `media_fullscreen_viewer.dart`, `post_owner_actions.dart`.
- Home header: `home_app_bar.dart` (with media "stories" circles).
- Create post: `create_post_media_zone.dart`, `create_post_schedule_sheet.dart`.
- Post detail: `widgets/post_detail_header.dart`, `post_detail_media.dart`, `comment_section.dart`, `mention_user_box.dart`.
- Reels: `widgets/reel_video_page.dart`.

[VERIFIED]

## Controller / state

`HomeController` (`lib/modules/home/home_controller.dart`): `posts`, `isInitialLoading`, `isRefreshing`, `isLoadingMore`, `hasMore`, `hasError`, `errorMessage`, `paginationError`, `activeVideoId`, `currentTab`; page counter `_page`; mutation guards `_mutationPosts`/`_mutationAuthors`.

Key commands: `fetchInitialFeed`, `refreshFeed`, `loadMore`, `retryFeed`, `setReaction`, `toggleFollow`, `openComments`, `openShareSheet`, `openPost`, `openCreatePost`, `editPost`, `deletePost`, `insertCreatedPost`, `openJobApplication`, `openJobApplicants`, `mediaStories`.

- `CreatePostController` (`create_post/create_post_controller.dart`): post type, audience, job fields, media, schedule, CV limit, validation (`canPublish`).
- `PostDetailController` (`post_detail/post_detail_controller.dart`).
- `ReelsController` (`reels/reels_controller.dart`).
- `MainShellController` (`shell/main_shell_screen.dart`): tab index + nav visibility on scroll.

[VERIFIED]

## Repository / API dependencies

| Dependency | File | Endpoints |
| --- | --- | --- |
| `PostRepository` | `lib/data/repositories/post_repository.dart` | wraps `PostService`; mock-first with fixtures + local state |
| `PostService` | `lib/data/services/post_service.dart` | `GET /posts?page&limit[&type]`, `GET /posts/{id}`, `PATCH/DELETE /posts/{id}`, `GET/POST /posts/{id}/comments`, `PATCH/DELETE /posts/{id}/comments/{cid}`, `POST /posts/{id}/reactions`, `POST/DELETE /users/{id}/follow`, `GET /users/{id}/posts?type` |
| `CommentRepository` | `lib/data/repositories/comment_repository.dart` | delegates to `PostRepository` |
| `UploadService` | `lib/data/services/upload_service.dart` | `POST /files/upload` (media) |
| `AiRepository` | `lib/data/repositories/ai_repository.dart` | optional feed ranking (`USE_AI_FEED`) |
| `JobApplicationRepository` | `lib/data/repositories/job_application_repository.dart` | applied-state overlay |

[VERIFIED]

## User flow

1. Shell loads → `HomeController.fetchInitialFeed()` (page 1).
2. Page-1 feed is optionally re-ranked via `_applySmartRanking` using `AiRepository.feedRecommendations()` when `USE_AI_FEED`; falls back to chronological order on empty/error. Open apply-eligible jobs are promoted. [VERIFIED] `home_controller.dart:188-233`.
3. Local overlay applies reacted/following/applied state (`_applyLocalState`).
4. Pull-to-refresh, infinite scroll (`loadMore` page N), pagination retry.
5. Reactions/follows update optimistically with rollback on failure.
6. Create post returns a `FeedPost` inserted at the top; edit updates in place; delete removes it.
7. Post detail returns an updated `FeedPost` or a `PostMutationResult` (deletion).

[VERIFIED]

## Loading / error / empty states

- Initial: `isInitialLoading` (skeletons/spinner); error → `hasError` + snackbar/retry.
- Refresh: `isRefreshing` (RefreshIndicator).
- Pagination: `isLoadingMore`; failure → `paginationError` with inline retry.
- Empty feed: `EmptyStateWidget`.
- Mutation failure: `Get.snackbar` + state rollback.

[VERIFIED]

## Permissions

- Camera/photos/video via `image_picker` for create-post media (handled by platform).
- No manifest change beyond INTERNET.

## Known limitations / stubs

- **Mock-first**: `USE_MOCK_API` returns fixtures with simulated latency (600 ms feed, 400 ms user posts). [VERIFIED]
- **Smart ranking is mock-first on live API** — `GET /ai/feed/recommendations` is not shipped; live returns empty. [VERIFIED]
- **Share privacy actions** (`sharePublicly`/`savePrivately`) are no-op delays. [VERIFIED] `post_repository.dart:482-488`.
- Post audience (`public/friends/private`) is UI-only and not sent to the API. [VERIFIED] `create_post_controller.dart:25`.
- CV limit slider for jobs is client-side only. [VERIFIED]
- Scheduled posts are sent as `scheduled_at` but no scheduling UI state beyond create; behavior depends on backend. [INFERRED] Inferred from implementation — requires business confirmation.

## TBDs

- [TBD] Server-side feed ranking / job-boost algorithm ownership. TBD — Requires confirmation.
- [TBD] Moderation/reporting for posts (user report only exists for chat users). TBD — Requires confirmation.
