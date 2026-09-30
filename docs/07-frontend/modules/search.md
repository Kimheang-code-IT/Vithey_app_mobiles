# Module: Search

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/modules/search/`, `vithey_app/lib/data/repositories/search_repository.dart`, `vithey_app/lib/data/services/user_search_service.dart`, `vithey_app/lib/data/services/post_search_service.dart`

## Purpose

Unified search across people, posters, jobs, and videos, plus "see all" per category. Also used as a people-picker to start a chat. Recents are stored locally. Backed by `user-profile-service` (`/users/search`) and `content-service` (`/posts`). [VERIFIED]

## Screens & routes

| Screen | Route | File |
| --- | --- | --- |
| Search | `/search` | `lib/modules/search/search_screen.dart` |
| See all | `/search/see-all` | `lib/modules/search/search_see_all_screen.dart` |

[VERIFIED] `lib/routes/app_pages.dart`.

## Main widgets

`search_app_bar.dart`, `search_filter_bar.dart`, `search_results_view.dart`, `search_person_tile.dart`, `search_post_tile.dart`, `search_job_tile.dart`, `search_video_tile.dart`, `search_recent_section.dart`, `search_recent_tile.dart`, `search_empty_state.dart`, `search_loading_skeleton.dart`, `search_highlight_text.dart`, `search_result_tile_shell.dart`, `search_section_header.dart`.

[VERIFIED]

## Controller / state

`SearchController` (`search_controller.dart`): `query`, `resultFilter`, `recentItems`, `isLoadingRecents`, `isSearching`, `searchError`, `people`, `posts`, `jobs`, `videos`; `mode` (`browse` vs `pickUserForChat`), debounce 350 ms, generation token `_searchGeneration`.

Commands: `onQueryChanged`, `submitSearch`, `clearQuery`, `openRecentItem`, `toggleRecentPin`, `removeRecent`, `confirmClearRecents`, `openPerson`, `messagePerson`, `openSeeAll`, `retrySearch`, `setResultFilter`.

`SearchSeeAllController` (`search_see_all_controller.dart`) handles paginated categories.

Search runs only when the query has **≥ 2 characters** (`showResults`). [VERIFIED]

## Repository / API dependencies

| Dependency | File | Endpoints |
| --- | --- | --- |
| `SearchRepository` | `lib/data/repositories/search_repository.dart` | `searchAll`, `searchPeople`, `searchPosts`, recents; mock-first via `USE_MOCK_SEARCH` |
| `UserSearchService` | `lib/data/services/user_search_service.dart` | `GET /users/search` |
| `PostSearchService` | `lib/data/services/post_search_service.dart` | `GET /posts` (with search/type) |
| `SearchRecentStore` | `lib/data/local/search_recent_store.dart` | local recents |
| `ChatRepository` | `lib/data/repositories/chat_repository.dart` | `pickUserForChat` start conversation |

[VERIFIED]

## User flow

1. Open with optional `SearchArgs(mode, initialQuery)`.
2. Recents load first (seeded from fixtures in mock mode).
3. Typing ≥2 chars debounces 350 ms then runs four parallel searches (people, posters, jobs, videos); partial failures are tolerated — a bundle is thrown only if all four fail. [VERIFIED] `search_repository.dart:61-115`.
4. Tapping a person opens their profile (or starts a chat in `pickUserForChat` mode); tapping a post/video opens post detail.
5. "See all" opens a paginated category; in chat-pick mode only People is available.
6. Recents can be pinned/removed/cleared (pinned kept on clear).

[VERIFIED]

## Loading / error / empty states

- `isLoadingRecents` / `isSearching` skeletons.
- `searchError` (mapped via `search_api_error.dart`) with retry.
- `SearchEmptyState` for no results and no recents.
- Query <2 chars shows recents rather than results.

[VERIFIED]

## Permissions

None.

## Known limitations / stubs

- **Mock-first**: `USE_MOCK_SEARCH` filters local fixtures. [VERIFIED]
- Search is preview-limited (3 per category in the main search); "see all" paginates. [VERIFIED]
- No debounced server-side suggestion endpoint; recents are the only suggestion source. [VERIFIED]
- `pickUserForChat` restricts results to people. [VERIFIED]

## TBDs

- [TBD] Whether search should use a dedicated backend search service/index (currently reuses users + posts endpoints). TBD — Requires confirmation.
- [TBD] Trie/fuzzy matching / typo tolerance. TBD — Requires confirmation.
