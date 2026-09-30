# Error Handling

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/core/network/api_response.dart`, `vithey_app/lib/core/errors/app_exception.dart`, `vithey_app/lib/core/errors/error_mapper.dart`, `vithey_app/lib/core/widgets/`, `vithey_app/lib/core/utils/connectivity_wrapper.dart`

Vithey has a typed error model (`AppException`/`AppErrorKind` + `ErrorMapper`) but its adoption is **partial**: most modules surface raw exception messages through `Get.snackbar` or `AppErrorWidget`, while the chatbot and search modules use the mapper. This document describes both the intended model and the actual usage. See [`05-network-layer.md`](05-network-layer.md).

## 1. Error envelope

Errors arriving from the gateway use the `{data, meta, error}` envelope; `ApiError` maps `code`, `message`, `details` (`lib/core/network/api_response.dart:1-19`). `ApiService` returns this envelope rather than throwing, and each service throws its own typed exception when `!response.isSuccess` (e.g. `AuthServiceException`, `PostServiceException`, `ChatServiceException`, `AiServiceException`). [VERIFIED]

Service exceptions follow a consistent pattern: a small class with a `message` field and `toString() => message` (e.g. `post_service.dart:256-263`, `chat_service.dart:214-221`). Backend validation details may be extracted from `error.details` (`auth_service.dart:28-38` picks `details[0].message`). [VERIFIED]

## 2. Typed application errors

`lib/core/errors/app_exception.dart` defines:

- `enum AppErrorKind { network, unauthorized, notFound, validation, upstream, conflict, unknown }`
- `class AppException implements Exception { kind, message, code?, cause? }`

[VERIFIED]

## 3. `ErrorMapper`

`ErrorMapper` (`lib/core/errors/error_mapper.dart`) maps low-level errors to `AppException` and to user-facing strings:

| Input | Result kind |
| --- | --- |
| `DioException` 401 | `unauthorized` |
| `DioException` 404 | `notFound` |
| `DioException` 409 | `conflict` |
| `DioException` >= 500 | `upstream` |
| Timeout / connection error | `network` |
| `AuthServiceException` | `unauthorized` |
| `AiServiceException` | inferred from message text |
| Other service exceptions | `unknown` |

`userMessage()` maps kinds to copy such as network ("Network error. Check your connection and try again."), unauthorized, notFound, upstream, validation, conflict, unknown. [VERIFIED] `error_mapper.dart:46-64`.

### Actual adoption

Only two call sites use `ErrorMapper` [VERIFIED]:

- `lib/modules/chatbot/utils/ai_api_error.dart` (`aiApiErrorMessage`).
- `lib/modules/search/utils/search_api_error.dart` (`searchApiErrorMessage`).

Most other controllers catch `e` and either show `e.toString()`/`error.toString()` via `Get.snackbar` or set an `errorMessage.value`. [VERIFIED] e.g. `home_controller.dart:141-143`, `profile_controller.dart:102-104`.

## 4. Widget-level error states

Shared UI for failures and empty states lives in `lib/core/widgets/`:

| Widget | Purpose |
| --- | --- |
| `LoadingWidget` | Centered spinner |
| `AppErrorWidget` | Inline error + retry callback |
| `EmptyStateWidget` | Empty/`No matches` state with icon |
| `ShimmerListTile` | Loading skeleton |
| `OfflineBanner` | Connectivity banner |
| `FormErrorHost` | Form validation error orchestration |

[VERIFIED] `lib/core/widgets/`.

Patterns observed:

- **Initial load error** → `AppErrorWidget(message, onRetry)` (e.g. `NotificationScreen`, `ApplicationStatusScreen`, `ProfileScreen`).
- **Pagination error** → inline "Retry" button (e.g. `NotificationController.paginationError`).
- **Mutation error** → `Get.snackbar` + optimistic rollback (reactions/follows/read).
- **Empty state** → `EmptyStateWidget` with title/subtitle/icon.
- **Loading** → `LoadingWidget` or skeleton list.

[VERIFIED] respective screens/controllers.

## 5. Network/offline handling

`ConnectivityWrapper` (installed once in `app.dart`) watches `connectivity_plus` and renders an `OfflineBanner` above the app when offline. It is informational only — requests are still attempted and fail through the normal Dio path. [VERIFIED] `lib/core/utils/connectivity_wrapper.dart`.

## 6. Logging

There is **no** structured logging, crash reporting, or analytics library in the app. Errors are not forwarded to any backend. The `AppException.cause` field exists but is not logged anywhere by default. [VERIFIED] `pubspec.yaml`, `lib/core/errors/`.

## 7. Summary of gaps

- `AppErrorKind.validation` is defined but `ErrorMapper._fromDio` never produces it (400s fall through to `unknown`). [VERIFIED]
- Error copy is inconsistent between mapper-driven and raw-message screens. [VERIFIED]
- No centralized error boundary around the widget tree. [VERIFIED]

## 8. TBDs

- [TBD] Whether `ErrorMapper` should be applied app-wide (refactor) is undocumented. TBD — Requires confirmation.
- [TBD] Crash reporting / observability tooling selection. TBD — Requires confirmation.
