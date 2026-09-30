# Frontend Project Structure

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/`, `vithey_app/pubspec.yaml`, `vithey_app/test/`, `vithey_app/android/`, `vithey_app/ios/`

Describes how the Vithey Flutter app is organized on disk and the module → service API dependency map. See the master index at [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md).

## 1. Top-level layout

```
vithey_app/
├── .env.example              # declared asset; copy to .env before build/analyze/test
├── pubspec.yaml              # package aub_connect_app, version 1.0.0+1
├── android/                  # Android host project (minSdk from Flutter, targetSdk 36)
├── ios/                      # iOS host project
├── test/                     # 3 test files only
└── lib/
    ├── main.dart             # entrypoint: AppBindings.init -> runApp
    ├── app.dart              # GetMaterialApp, themes, shadcn injection
    ├── routes/
    │   └── app_pages.dart    # GetPage list + SplashBinding
    ├── core/                 # cross-cutting: config, network, storage, theme, widgets, DI
    ├── data/                 # models, fixtures, repositories, services, local, push
    └── modules/              # feature UI + controllers (one folder per module)
```

[VERIFIED] `vithey_app/` tree listing.

The pubspec package name is `aub_connect_app` even though the product is **Vithey**; imports use `package:aub_connect_app/...`. [VERIFIED] `vithey_app/pubspec.yaml:1`.

## 2. `lib/core/` — cross-cutting

| Folder | Contents | Evidence |
| --- | --- | --- |
| `alerts/` | In-app alert host/service + message/call banners | `lib/core/alerts/` |
| `config/` | `AppConfig`, `AppEnvironment`, `FeatureFlags` | `lib/core/config/` |
| `constants/` | `AppRoutes`, `ApiEndpoints`, `AppStrings`, colors, assets, mock identities | `lib/core/constants/` |
| `di/` | `AppBindings.init()` — all app-wide DI | `lib/core/di/app_bindings.dart` |
| `errors/` | `AppException`/`AppErrorKind`, `ErrorMapper` | `lib/core/errors/` |
| `icons/` | `VitheyIcon`, `LucideIcons` set | `lib/core/icons/` |
| `navigation/` | `MainTabNavigation` tab index constants | `lib/core/navigation/main_tab_navigation.dart` |
| `network/` | `DioClient`, `ApiService`, `ApiResponse`/`ApiError`/`ApiMeta` | `lib/core/network/` |
| `session/` | `CurrentUserService` (auth user holder) | `lib/core/session/current_user_service.dart` |
| `storage/` | `SecureStorageService`, `LocalStorageService` | `lib/core/storage/` |
| `theme/` | `AppTheme`, light/dark, semantic colors, type, radii | `lib/core/theme/` |
| `utils/` | `AuthNavigation`, `ConnectivityWrapper`, `Validators`, `RelativeTime` | `lib/core/utils/` |
| `widgets/` | Shared UI kit (buttons, fields, dialogs, states, nav bar) | `lib/core/widgets/` |

## 3. `lib/data/` — data access

| Folder | Contents | Evidence |
| --- | --- | --- |
| `models/` | Plain DTOs (`FeedPost`, `UserProfileModel`, `ChatMessage`, `AiChatModel`, etc.) | `lib/data/models/` |
| `fixtures/` | Mock data used when `USE_MOCK_*` is on (`post_fixtures`, `ai_*_fixtures`, ...) | `lib/data/fixtures/` |
| `repositories/` | One per domain; own mock-vs-live branching | `lib/data/repositories/` |
| `services/` | Thin API wrappers over `ApiService` (+ STOMP, realtime hub) | `lib/data/services/` |
| `local/` | `isar/` (chat DB), `search_recent_store.dart` | `lib/data/local/` |
| `push/` | `FcmService` (disabled), `NotificationRouter` deep-link router | `lib/data/push/` |

**Naming note:** `lib/data/services/` are HTTP/service adapters, not backend microservices. `lib/data/repositories/` hold business branching. [INFERRED] Inferred from implementation — requires business confirmation.

## 4. `lib/modules/` — feature UI

Modules present (matches the brief): **auth, home, jobs, profile, chat, chatbot, finance, search, settings, map**. There is **no** `lib/features/`. [VERIFIED] directory listing.

Each module typically contains: `*_screen.dart` (UI), `*_controller.dart` (state), `*_binding.dart` (per-route DI), and a `widgets/` subfolder.

```
lib/modules/
├── auth/        # splash, language, onboarding, intro ribbon, login/register, startup skills, Google UI
├── home/        # feed (shell), reels, create-post, post-detail, notification/
├── jobs/        # apply-cv, ai_cv/, application status, templates
├── profile/     # own/visitor profile, edit, applicants, CV screens, QR scan, analytics
├── chat/        # list, detail, profile, folders, calls (simulated)
├── chatbot/     # Vithey AI chat (SSE)
├── finance/     # dashboard, payment (mock), verification/
├── search/      # unified search + see-all
├── settings/    # home + account, privacy, notifications, security, about, help
└── map/         # Google Maps nearby places
```

[VERIFIED] `lib/modules/`.

## 5. Module → backend service API dependency map

Table maps each module to the gateway-backed services it calls. "Mock-first" marks modules whose live endpoints are absent/stubbed and that therefore rely on `USE_MOCK_*` fixtures. [VERIFIED] `lib/core/constants/api_endpoints.dart`, repositories/services.

| Module | Backend service(s) | Key endpoint prefixes | Mock flag | Notes |
| --- | --- | --- | --- | --- |
| auth | `auth-service` | `/auth/*`, `/users/me/settings` | `USE_MOCK_AUTH` | Google auth is UI-only stub |
| home (feed/posts) | `content-service`, `file-service` | `/posts`, `/posts/{id}`, `/users/{id}/posts`, `/files/upload` | `USE_MOCK_API` | Reels filter `type=VIDEO` |
| home (notifications) | `notification-service` | `/notifications*` | `USE_MOCK_NOTIFICATIONS` | See [`modules/notifications.md`](modules/notifications.md) |
| jobs / CV | `career-service`, `file-service`, `auth-service` | `/job-applications`, `/users/me/cv`, `/students/verify`, `/files/upload` | `USE_MOCK_API`, `USE_AI_CV` | AI match live endpoint not shipped |
| profile | `user-profile-service`, `auth-service`, `content-service`, `career-service` | `/users/me`, `/users/{id}`, `/users/{id}/posts`, `/users/{id}/follow`, `/users/search` | `USE_MOCK_API` | Applicant detail falls back to fixtures |
| finance | `finance-service`, `auth-service` | `/fees`, `/payments`, `/payments/alerts`, `/students/verify` | `USE_MOCK_API` | Payment screen is a mock UI |
| chat | `chat-service`, `content-service` (users) | `/conversations*`, `/message-requests`, `/messages/{id}/read`, `/users/{id}/report`, WS `/ws` | `USE_MOCK_CHAT` | Isar persists locally |
| chatbot | `ai_core` via gateway `/api/v1/ai/**` | `/ai/chat`, `/ai/chat/stream`, `/ai/sessions*`, `/ai/cv/generate`, `/ai/cv/suggest` | `USE_MOCK_AI` | Live chat is SSE |
| search | `user-profile-service`, `content-service` | `/users/search`, `/posts?search=` | `USE_MOCK_SEARCH` | Recents stored locally |
| settings | `user-profile-service` (settings), `auth-service` (password) | `/users/me/settings`, `/auth/me/password` | `USE_MOCK_API` | Mostly local preferences |
| map | `map-service` | `/places/nearby`, `/places/search`, `/places/autocomplete`, `/places/favorites`, `/places/history` | `USE_MOCK_MAP` | Google Maps rendering client-side |

For endpoint-level detail see [`../06-api/`](../06-api/) and [`05-network-layer.md`](05-network-layer.md).

## 6. Tests

Only **3** test files exist under `test/` [VERIFIED]:

| File | Kind |
| --- | --- |
| `test/widget_test.dart` | Widget test — asserts `AppLogo` renders |
| `test/data/models/notification_preferences_test.dart` | Unit test — notification preference gating |
| `test/modules/home/notification/notification_utils_test.dart` | Unit test — grouping + relative time |

No integration, golden, or E2E tests are present. **Test results are not claimed** — no test execution was performed for this documentation task. Any statement of correctness must be written as `Test implemented — current execution result not independently verified.` [VERIFIED]

## 7. Platform configuration

| Item | Value | Evidence |
| --- | --- | --- |
| Android applicationId | `com.vithey.aub_connect_app` | `android/app/build.gradle:49` |
| compileSdk / targetSdk | 36 | `android/app/build.gradle:32,51` |
| Android permissions | INTERNET, POST_NOTIFICATIONS, CAMERA, ACCESS_FINE/COARSE_LOCATION | `android/app/src/main/AndroidManifest.xml:13-18` |
| `usesCleartextTraffic` | debug `true`, release `false` | `android/app/build.gradle:55-70` |
| Android release signing | debug keys (TODO) | `android/app/build.gradle:65-70` |
| iOS bundle name | `Vithey` / `aub_connect_app` | `ios/Runner/Info.plist:9-17` |
| iOS usage descriptions | Location when-in-use, Camera (QR) | `ios/Runner/Info.plist:5-6,54-55` |
| Google Maps key | Android `local.properties`/env; iOS `Secrets.xcconfig` | `android/app/build.gradle:25-28`, `.env.example:41` |

There is no `google-services.json` (Firebase/FCM not configured). [VERIFIED] repository listing.

## 8. TBDs

- [TBD] Real release signing configuration and store distribution. TBD — Requires confirmation.
- [TBD] Real FCM project and `google-services.json`. TBD — Requires confirmation.
