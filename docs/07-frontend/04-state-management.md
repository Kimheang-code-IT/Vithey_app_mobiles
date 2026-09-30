# State Management & Dependency Injection

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/core/di/app_bindings.dart`, `vithey_app/lib/modules/**/*_controller.dart`, `vithey_app/lib/core/session/current_user_service.dart`

Vithey uses **GetX 4.6.6** for state management, dependency injection, and routing. There is no Provider/Riverpod/Bloc. See [`03-routing.md`](03-routing.md) for navigation and [`01-flutter-architecture.md`](01-flutter-architecture.md) for the layer overview.

## 1. Controller pattern

Each module has one or more `GetxController` subclasses. Conventions observed throughout the codebase:

- UI state uses reactive fields: `final foo = Rxn<T>()`, `<T>[].obs`, `.obs`, `.obs` wrappers. Example: `HomeController` (`lib/modules/home/home_controller.dart:32-41`).
- Screens are `GetView<TController>` or plain `StatelessWidget`, wrapping reactive regions in `Obx(...)`/`Obx(() => ...)`.
- Controllers receive dependencies via constructor injection (usually repositories fetched with `Get.find<Repo>()`).
- Controllers expose commands (methods) and derived getters; they never build widgets.
- `onInit()` triggers initial loads; `onClose()` disposes `TextEditingController`, `FocusNode`, `ScrollController`, `TabController`, and cancels subscriptions/timers.

[VERIFIED] e.g. `lib/modules/home/home_controller.dart`, `lib/modules/chat/chat_detail_controller.dart:678-688`.

## 2. Dependency injection

### 2.1 App-wide (`AppBindings`)

`AppBindings.init()` runs before `runApp` and registers all shared dependencies with `Get.put(..., permanent: true)` (`lib/core/di/app_bindings.dart:47-206`):

- Config/storage: `FeatureFlags`, `SecureStorageService`, `LocalStorageService`, `InAppAlertService`, `DioClient`, `ApiService`.
- Auth/session: `AuthService`, `CurrentUserService`, `AuthRepository`.
- Content/social: `PostService`, `PostRepository`, `CommentRepository`, `ProfileService`, `UploadService`.
- Jobs/CV: `JobApplicationService`, `CvRepository`, `JobApplicationRepository`, `ProfileRepository`, `StudentVerificationService`, `StudentVerificationRepository`.
- Finance: `FinanceService`, `FinanceRepository`.
- Chat: `IsarService`, `ChatStompService`, `ChatRealtimeHub`, `ChatService`, `ChatRepository`.
- Notifications: `NotificationService`, `FcmService`, `NotificationRepository`.
- AI: `AiService`, `AiRepository`.
- Settings/search/map: `SettingsService`, `SettingsRepository`, `SearchRecentStore`, `UserSearchService`, `PostSearchService`, `SearchRepository`, `PlaceService`, `PlaceRepository`.

Order matters where hydration occurs: repositories are registered, then `hydrateMockState()` runs when `useMockApi` is on (`app_bindings.dart:88-92,110-112`). `CurrentUserService.restoreSession()` is the last step. [VERIFIED]

### 2.2 Per-route (`Bindings`)

Screens declare a binding in `AppPages` (see the route table). Bindings use `Get.lazyPut(..., fenix: true)` or `Get.put(...)`, e.g.:

- `HomeBinding` → `HomeController` (`lib/modules/home/home_binding.dart`).
- `ApplyCvBinding` → `ApplyCvController`; `ApplicationStatusBinding` → `ApplicationStatusController` (`lib/modules/jobs/apply_cv_binding.dart`).
- `ChatListBinding`/`ChatDetailBinding`/`ChatProfileBinding` (`lib/modules/chat/chat_binding.dart`).
- `MainShellBinding` registers `HomeBinding`, `ProfileBinding`, `ReelsBinding`, `NotificationBinding` and a `fenix` `MainShellController` (`lib/modules/home/shell/main_shell_screen.dart:154-163`).

`SplashBinding` is declared inline inside `app_pages.dart:78-89` because it constructs `SplashController` from three core services.

## 3. Session state

`CurrentUserService extends GetxService` (`lib/core/session/current_user_service.dart`) is the single source for the authenticated user id/display name/avatar across the app.

- `user = Rxn<UserModel>()`; `userId` falls back to `MockIdentities.mockUserId` when unset.
- `restoreSession()` runs at boot: if no token → clear; if `useMockAuth` → seed mock user; otherwise `GET /auth/me` and refresh the student-verified flag.
- Login/register writes the user via `AuthRepository._saveTokens`; logout calls `_currentUser.clear()`.

[VERIFIED]

## 4. Repository mock-vs-live branching

Repositories read `FeatureFlags` and branch internally, so controllers are mode-agnostic. Examples:

- `PostRepository.fetchFeed` returns fixtures with simulated latency when `useMockApi`, else `PostService.fetchFeed` (`lib/data/repositories/post_repository.dart:147-178`).
- `ChatRepository` uses an in-memory mock conversation set or `ChatService` + Isar (`lib/data/repositories/chat_repository.dart:200-244`).
- `AiRepository` returns fixtures when `useMockAi`, else delegates to `AiService` (SSE) (`lib/data/repositories/ai_repository.dart`).

`FeatureFlags` is the single read point; its comment states "repositories must read mock/real mode from here only." [VERIFIED] `lib/core/config/feature_flags.dart:5-8`.

## 5. Streams and realtime state

- **Isar streams**: `ChatRepository.watchConversations()` / `watchMessages()` expose Isar query streams mapped to models; controllers subscribe in `onInit` and cancel in `onClose`.
- **STOMP**: `ChatStompService` broadcasts events; `ChatRealtimeHub` forwards them to `ChatRepository.handleStompPayload` (`lib/core/di/app_bindings.dart:167-168`). In mock mode `connect()` immediately reports connected and events are simulated.
- **SSE (chatbot)**: `AiService.streamChat` yields `AiStreamMeta`/`AiStreamToken`/`AiStreamDone`/`AiStreamError`; `ChatbotController` consumes with a request token to discard stale streams.

[VERIFIED] `lib/data/services/chat_stomp_service.dart`, `lib/data/services/ai_service.dart:96-150`.

## 6. State patterns worth noting

- **Optimistic updates with rollback**: reactions/follows (`HomeController.setReaction`, `toggleFollow`), notification read state (`NotificationController.markAsRead`).
- **Mutation locks**: controllers guard duplicate submits with `_sendLocked` / `_mutationPosts` sets.
- **Generation tokens**: `ChatbotController._requestToken` and `SearchController._searchGeneration` discard out-of-order async results.
- **Debounce**: search query (350 ms), map autocomplete (250 ms), chat list message search (220 ms).
- **Cached per-filter state**: `NotificationController._filterStates` preserves items/page/scroll per filter tab.

[VERIFIED] respective files.

## 7. TBDs

- [TBD] No global error/analytics observer is wired into GetX. Whether crash reporting is planned is unspecified. TBD — Requires confirmation.
- [TBD] Controller test coverage is absent (only 3 tests total, none for controllers). TBD — Requires confirmation.
