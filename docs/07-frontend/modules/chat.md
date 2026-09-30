# Module: Chat

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/modules/chat/`, `vithey_app/lib/data/repositories/chat_repository.dart`, `vithey_app/lib/data/services/chat_service.dart`, `vithey_app/lib/data/services/chat_stomp_service.dart`, `vithey_app/lib/data/local/isar/`

## Purpose

Peer-to-peer messaging: conversation list, message requests, folders, thread view with reactions/replies/attachments, shared media, participant profile, mute/block/report, and simulated calls. Uses REST for history and STOMP over WebSocket for realtime; messages are persisted locally in Isar. Backed by `chat-service`. [VERIFIED]

## Screens & routes

| Screen | Route | File |
| --- | --- | --- |
| Chat list | `/chat` | `lib/modules/chat/chat_list_screen.dart` |
| Chat detail | `/chat/detail` | `lib/modules/chat/chat_detail_screen.dart` |
| Chat profile | `/chat/profile` | `lib/modules/chat/chat_profile_screen.dart` |

[VERIFIED] `lib/routes/app_pages.dart`.

## Main widgets

`chat_list_app_bar.dart`, `chat_list_flexible_header.dart`, `conversation_list_tile.dart`, `chat_folder_tabs.dart`, `chat_folders_sheet.dart`, `add_chat_contacts_row.dart`, `message_bubble.dart`, `chat_composer.dart`, `chat_detail_header.dart`, `reply_preview_bar.dart`, `date_separator.dart`, `chat_emoji_panel.dart`, `chat_shared_content.dart`, `jump_to_latest_chip.dart`, `chat_call_sheet.dart`, `delete_message_dialog.dart`.

[VERIFIED]

## Controller / state

- `ChatListController` (`chat_list_controller.dart`): `conversations`, `messageRequests`, `recentContacts`, `customFolders`, `selectedFolderId`, `isLoading`, `hasError`, search (`searchQuery`, `messageSearchSnippets`, debounce 220 ms), folder management. Subscribes to `watchConversations()` and calls `connectRealtime()`.
- `ChatDetailController` (`chat_detail_controller.dart`): `messages`, `participant`, `isLoading`, `isSending`, `isTyping`, `replyToMessage`, `pendingAttachments` (max 5), thread search, reactions (one per user). Optimistic send + failed/retry state.
- `ChatProfileController` (`chat_profile_screen.dart`): participant info, shared content, mute, call simulations.

[VERIFIED]

## Repository / API dependencies

| Dependency | File | Endpoints |
| --- | --- | --- |
| `ChatRepository` | `lib/data/repositories/chat_repository.dart` | orchestrates REST + Isar + STOMP; mock-first via `USE_MOCK_CHAT` |
| `ChatService` | `lib/data/services/chat_service.dart` | `GET /conversations`, `GET /message-requests`, `POST /message-requests`, `POST /conversations/{id}/accept|decline|block`, `GET/POST /conversations/{id}/messages`, `PATCH /messages/{id}/read`, `POST /users/{id}/report` |
| `ChatStompService` | `lib/data/services/chat_stomp_service.dart` | WS `/ws`, subscribe `/user/queue/messages`, send `/app/chat.send` |
| `IsarService` | `lib/data/local/isar/isar_service.dart` | local persistence + watch streams |
| `UploadService` | `lib/data/services/upload_service.dart` | attachment upload (not wired into send payload) |

[VERIFIED] `lib/core/constants/api_endpoints.dart`.

## User flow

1. List loads conversations + requests + recent contacts in parallel; Isar stream keeps the list live.
2. STOMP connects (no-op in mock mode); inbound events (`typing`, `read_receipt`, `message`, `call_invite`) are handled by `ChatRepository.handleStompPayload`.
3. Opening a thread streams local messages, fetches history, marks read, and scrolls to bottom.
4. Send: enqueue outbox → optimistic bubble (`sending`) → REST send + STOMP publish → mark `sent`; on failure mark `failed` with retry.
5. Replies, reactions, copy, delete (own), block, report, and mute are available.
6. In mock mode, sending triggers a simulated typing indicator and an auto-reply after ~2 s, plus a second ping after 6 s.

[VERIFIED]

## Loading / error / empty states

- List: `isLoading` skeleton/empty state (`app_strings` `chatNoMessages*`); error snackbar/state.
- Detail: `isLoading` spinner; load failure snackbar ("Could not load messages").
- Empty thread: "No messages yet" / "Say hello!".
- Send failure: bubble marked failed + snackbar + input restored.
- Search: "No chats or messages found".

[VERIFIED]

## Permissions

- Photos/videos via `image_picker`; files via `file_picker` (platform-managed).
- Camera not required for chat.

## Known limitations / stubs

- **Calls are simulated**: incoming-call banner and call sheet have no WebRTC/audio; `simulateIncomingCall` only fires in mock mode. [VERIFIED] `chat_repository.dart:167-181`, `chat_widgets/chat_call_sheet.dart`.
- **Attachments are label-only**: picked attachments are serialized into the message text (`Photo: <name>`) rather than uploaded; `UploadService` is not invoked by chat send. [VERIFIED] `chat_detail_controller.dart:400-411`.
- **Mock auto-reply** (`_simulateMockReply`) is demo behaviour only. [VERIFIED]
- Recent contacts are empty on the live API (`fetchRecentContacts` returns `[]`). [VERIFIED] `chat_repository.dart:222-228`.
- Folders and muted conversations are stored locally only, not synced. [VERIFIED]
- Reactions are local-only (no endpoint). [VERIFIED]
- **Isar is chat-only**; a schema change requires `build_runner`. [VERIFIED]

## TBDs

- [TBD] Real-time call/voice/video support. TBD — Requires confirmation.
- [TBD] Media/attachment upload wiring to `file-service`. TBD — Requires confirmation.
- [TBD] Server-side reactions and folder sync. TBD — Requires confirmation.
