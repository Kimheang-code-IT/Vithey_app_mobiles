# Module: Notifications

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/modules/home/notification/`, `vithey_app/lib/data/repositories/notification_repository.dart`, `vithey_app/lib/data/services/notification_service.dart`, `vithey_app/lib/data/push/`

## Purpose

In-app notification center (list, filters, search, grouping, mark read/unread, delete) plus deep-link routing from notifications and (disabled) FCM push. Backed by `notification-service`. [VERIFIED]

## Screens & routes

| Screen | Route | File |
| --- | --- | --- |
| Notifications | `/notifications` | `lib/modules/home/notification/notification_screen.dart` |

Also rendered as tab index 4 inside the main shell and reachable via deep links. [VERIFIED] `lib/routes/app_pages.dart`, `lib/core/navigation/main_tab_navigation.dart`.

## Main widgets

`notification_filter_bar.dart`, `notification_item.dart`, `notification_item_skeleton.dart`, `notification_group_header.dart`, `notification_type_badge.dart`, `notification_list_entrance.dart`, `delete_notification_dialog.dart`. Utilities: `utils/notification_display_text.dart`, `utils/notification_grouping.dart`.

[VERIFIED]

## Controller / state

`NotificationController` (`notification_controller.dart`): `filter` (`all`/`read`/`unread`), `notifications`, `isLoading`, `isLoadingMore`, `isRefreshing`, `hasError`, `paginationError`, `mutatingIds`, `isSearchOpen`, `searchQuery`, `slideDirection`. Per-filter cached state `_NotificationFilterState` (items/page/hasMore/loaded/scrollOffset).

Commands: `loadNotifications`, `loadMore`, `refreshNotifications`, `selectFilter`, `markAllAsRead`, `openNotification`, `openActionSheet`, `markAsRead`, `requestDelete`.

`NotificationRepository extends GetxService` holds `unreadCount` and an in-memory cache; `onUserAuthenticated`/`onAppResumed` reconcile the unread count. [VERIFIED]

## Repository / API dependencies

| Dependency | File | Endpoints |
| --- | --- | --- |
| `NotificationRepository` | `lib/data/repositories/notification_repository.dart` | fetch, markAsRead, markAllAsRead, delete, reconcile, cache |
| `NotificationService` | `lib/data/services/notification_service.dart` | `GET /notifications?page&limit&is_read`, `GET /notifications/unread-count`, `PATCH /notifications/{id}/read`, `PATCH /notifications/read-all`, `DELETE /notifications/{id}`, `POST /notifications/devices`, `DELETE /notifications/devices/{token}` |
| `NotificationRouter` | `lib/data/push/notification_router.dart` | type → route deep links |
| `FcmService` | `lib/data/push/fcm_service.dart` | disabled; device registration when `FCM_ENABLED` |

[VERIFIED] `lib/core/constants/api_endpoints.dart`.

## User flow

1. `onInit` loads notifications and reconciles the unread count.
2. Filter tabs are cached; switching restores items/page/scroll.
3. Tapping a notification optimistically marks it read and routes by type: post → post detail; follow → user profile; job application → applicants; status → application status; chat → list/detail; payment → finance; AI → chatbot; verification → status; `system` → `route_name` or snackbar. [VERIFIED] `notification_router.dart:60-129`.
4. Action sheet offers mark-read and delete; mark-all-read clears unread.
5. Pull-to-refresh; infinite scroll pagination with retry.

[VERIFIED]

## Loading / error / empty states

- Initial: skeleton list (`NotificationItemSkeleton`×7).
- Error: `AppErrorWidget` with retry.
- Empty per filter: "No notifications yet" / "Nothing here yet" / "You're all caught up"; search no-match: "No matches".
- Pagination error: inline Retry button.
- Mutation failure: rollback + snackbar.

[VERIFIED]

## Permissions

- `POST_NOTIFICATIONS` declared for OS notifications, but FCM is disabled so no runtime request is wired. [VERIFIED] `android/app/src/main/AndroidManifest.xml:14`.

## Known limitations / stubs

- **FCM push is disabled**: `FcmService.init`/`registerToken` contain commented-out Firebase calls; no Firebase packages or `google-services.json`. `FCM_ENABLED` defaults false. [VERIFIED] `fcm_service.dart:30-37,54`, `pubspec.yaml`.
- `NotificationService._readUnreadTotal` always returns `null` (does not yet model `unread_total` from meta). [VERIFIED] `notification_service.dart:54-58`.
- `NotificationFilter` is all/read/unread only; no category filters in the UI. [VERIFIED]
- Deep-link routing for `jobApplicationReceived` uses a generic "Job" title. [VERIFIED]

## TBDs

- [TBD] Real FCM project, `google-services.json`, and token lifecycle. TBD — Requires confirmation.
- [TBD] `unread_total` in the list `meta` contract. TBD — Requires confirmation.
- [TBD] OS notification permission request UX. TBD — Requires confirmation.
