# Local Storage

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/core/storage/secure_storage_service.dart`, `vithey_app/lib/core/storage/local_storage_service.dart`, `vithey_app/lib/data/local/isar/`, `vithey_app/lib/data/local/search_recent_store.dart`

Vithey uses three local persistence mechanisms, each with a distinct purpose:

| Mechanism | Package | Stores | Evidence |
| --- | --- | --- | --- |
| Secure storage | `flutter_secure_storage` 9.0 | Access + refresh tokens | `lib/core/storage/secure_storage_service.dart` |
| Key-value prefs | `shared_preferences` 2.2 | Theme, language, funnel flags, privacy/notification prefs, verification, mock state, chat folders | `lib/core/storage/local_storage_service.dart` |
| Local database | `isar` 3.1 | Chat conversations, messages, pending outbox | `lib/data/local/isar/` |

Web/Chrome is unsupported precisely because Isar, secure storage, and camera are mobile-only. [VERIFIED] `AGENTS.md`.

## 1. Secure storage (tokens)

`SecureStorageService` wraps a single `FlutterSecureStorage` and reads/writes two keys (`lib/core/storage/secure_storage_service.dart`):

| Key | Purpose |
| --- | --- |
| `access_token` | Bearer token attached by `DioClient` |
| `refresh_token` | Used for 401 refresh / logout revocation |

API: `saveTokens`, `readAccessToken`, `readRefreshToken`, `hasAccessToken`, `clearTokens`. There is no encryption policy configured, so platform defaults apply. [VERIFIED]

Tokens prefixed with `mock` are treated as non-real throughout the app (interceptor skips them; splash clears them). [VERIFIED] `dio_client.dart:42,71`, `splash_controller.dart:204-209`.

## 2. Shared preferences

`LocalStorageService` is the sole wrapper around `SharedPreferences`. It stores (key → purpose) [VERIFIED] `local_storage_service.dart`:

| Key | Type | Purpose |
| --- | --- | --- |
| `theme_mode` | String | `light`/`dark`/`system` |
| `language` | String | Selected language code (default `en`) |
| `language_selected` | Bool | Select-Language completed |
| `onboarding_completed` | Bool | Onboarding completed |
| `startup_completed` | Bool | Startup skills/interests completed |
| `verification_status` | String | `notSubmitted`/`pending`/`verified`/`rejected` (mock-first) |
| `verification_student_id` / `_email` / `_submitted_at` / `_document_file_name` | String | Verification draft |
| `privacy_profile_visible` / `_data_sharing` / `_activity_tracking` | Bool | Privacy settings |
| `biometric_enabled` | Bool | Biometric preference (feature not implemented) |
| `notifications_enabled` / `_chat_messages` / `_reminders` / `_announcements` / `_app_updates` | Bool | Notification preferences |
| `chat_folders_json` | String (JSON) | Custom chat folders |
| `muted_chat_conversations` | StringList | Muted conversation ids |
| `mock_deleted_post_ids` | StringList | Persisted deletes in mock mode |
| `mock_applied_job_ids` | StringList | Persisted applications in mock mode |
| `mock_application_statuses_json` | String (JSON) | Mock status overrides |
| `mock_submitted_applications_json` | String (JSON) | Mock submitted application details |
| `mock_catalog_restored_v1` | Bool | One-shot demo catalog restore guard |

Key observations:

- Many keys are **mock/demo only** (`mock_*`, verification, chat folders, muted conversations). [VERIFIED]
- `clearSessionPreferences()` on logout removes only `startup_completed`. `SettingsController.logout()` additionally clears search recents and calls `AuthRepository.logout()` → `secureStorage.clearTokens()`. [VERIFIED] `settings_controller.dart:92-120`.
- Notification preferences default: `enabled=true`, `chat_messages=true`, `reminders=true`, `announcements=false`, `app_updates=true`. [VERIFIED] `local_storage_service.dart:292-301`.
- Privacy defaults: `profileVisible=true`, `dataSharing=false`, `activityTracking=false`. [VERIFIED] `local_storage_service.dart:250-263`.

## 3. Isar database (chat only)

`IsarService` opens a database named `vithey_chat` in the application documents directory with three schemas (`lib/data/local/isar/isar_service.dart:10-18`):

| Schema | File | Purpose |
| --- | --- | --- |
| `LocalConversationSchema` | `local_conversation.dart` | Conversation list, unread count, typing, last-message preview |
| `LocalChatMessageSchema` | `local_chat_message.dart` | Messages per conversation |
| `PendingOutboxMessageSchema` | `pending_outbox_message.dart` | Outbox queue for sends |

`*.g.dart` files are generated with `isar_generator` via `dart run build_runner build --delete-conflicting-outputs`; they are committed and excluded from the analyzer. [VERIFIED] `AGENTS.md`.

Key operations [VERIFIED] `isar_service.dart`:

- `watchConversations()` — stream sorted by `updatedAt` desc.
- `watchMessages(conversationId)` — stream sorted by `createdAt`.
- `upsertConversation(s)`, `upsertMessage(s)`, `setUnreadCount`, `setTyping`, `markMessageDeleted`.
- `enqueueOutbox`, `pendingOutbox`, `removeOutbox(clientId)`.
- `searchMessagesByText(query)` — case-insensitive `textContains`.
- `deleteConversation`, `clearAll`.

Isar is used for **chat only**; there is no offline cache for feed, profile, jobs, or map. [VERIFIED] repository-wide.

### Offline outbox

`ChatRepository.sendMessage` enqueues a `PendingOutboxMessage` before sending, then removes it on success (`lib/data/repositories/chat_repository.dart:246-300`). There is **no automatic retry/backoff worker** that drains the outbox after connectivity returns in the reviewed code — retry is user-initiated per message (`ChatDetailController.retryMessage`). [INFERRED] Inferred from implementation — requires business confirmation.

## 4. Search recent store

`SearchRecentStore` persists recent queries/users locally (used by the search module). It is registered as a permanent GetX singleton and can be seeded from fixtures when `useMockSearch` is on. [VERIFIED] `lib/data/local/search_recent_store.dart`, `lib/core/di/app_bindings.dart:185`.

## 5. Clearing local data

| Trigger | What is cleared |
| --- | --- |
| Logout (`SettingsController.logout`) | FCM unregister, notification session, tokens, `startup_completed`, search recents |
| `IsarService.clearAll()` | All chat tables |
| `LocalStorageService.clearVerificationData()` | Verification keys (called on boot when `useMockApi`) |

[VERIFIED] `settings_controller.dart:102-114`, `app_bindings.dart:127-129`.

## 6. TBDs

- [TBD] No data-retention / purge policy is implemented beyond logout and demo resets. TBD — Requires confirmation.
- [TBD] The "Data & storage" settings row is a stub; no storage-size UI or cache management exists. TBD — Requires confirmation.
- [TBD] Outbox offline retry semantics (drain on reconnect) are unspecified. TBD — Requires confirmation.
