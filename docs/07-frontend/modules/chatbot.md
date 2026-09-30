# Module: Chatbot (Vithey AI)

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/modules/chatbot/`, `vithey_app/lib/data/repositories/ai_repository.dart`, `vithey_app/lib/data/services/ai_service.dart`

## Purpose

The Vithey AI assistant: multi-session chat with streaming responses, markdown/code rendering, reasoning display, attachments, history management (rename/pin/delete), and deep-link prompts from other modules (e.g. "Improve" CV). Routed through the gateway to `ai_core` (`/api/v1/ai/**`). [VERIFIED]

## Screens & routes

| Screen | Route | File |
| --- | --- | --- |
| Chatbot | `/chatbot` | `lib/modules/chatbot/chatbot_screen.dart` |

Opened full-screen from the bottom bar (tab index 3) and via deep-link arguments (`ChatbotArgs`). [VERIFIED] `lib/core/navigation/main_tab_navigation.dart:19-26`.

## Main widgets

`chatbot_app_bar.dart`, `chatbot_history_drawer.dart`, `chatbot_composer.dart`, `chatbot_suggestion_list.dart`, `assistant_message.dart`, `assistant_reasoning_block.dart`, `assistant_thinking_indicator.dart`, `user_message_bubble.dart`, `markdown_message_body.dart`, `streaming_markdown.dart`, `code_block_card.dart`, `message_action_row.dart`, `chatbot_state_views.dart`, `jump_to_latest_button.dart`.

Markdown is rendered with `gpt_markdown` (`pubspec.yaml`). [VERIFIED]

## Controller / state

`ChatbotController` (`chatbot_controller.dart`): `sessions`, `messages`, `isLoadingSessions`, `isLoadingMessages`, `isGenerating`, `showJumpToLatest`, `pendingAttachments`; `_currentSessionId`, `_selectedTopic`, `_drafts` per session, `_requestToken` (stale-stream guard), `_streamCancelToken`.

Commands: `loadSessions`, `selectSession`, `newChat`, `sendMessage`, `sendStarterPrompt`, `stopGenerating`, `regenerateMessage`, `renameSession`, `togglePin`, `deleteSession`, `openAttachmentMenu`, `openDrawer`, `copyMessage`, `copyCodeBlock`, `shareMessage`.

Starter prompts are hardcoded: `Help me write a CV`, `How do I apply for this job?`, `Test my Flutter skills`.

[VERIFIED]

## Repository / API dependencies

| Dependency | File | Endpoints / events |
| --- | --- | --- |
| `AiRepository` | `lib/data/repositories/ai_repository.dart` | sessions/messages/chat, CV generate/suggest; mock-first via `USE_MOCK_AI` |
| `AiService` | `lib/data/services/ai_service.dart` | `POST /ai/chat`, `POST /ai/chat/stream` (SSE), `GET /ai/sessions`, `GET /ai/sessions/{id}/messages`, `DELETE /ai/sessions/{id}`, `POST /ai/messages/{id}/regenerate`, `DELETE /ai/chat/requests/{id}`, `POST /ai/cv/generate`, `POST /ai/cv/suggest` |
| `ErrorMapper` (via `ai_api_error.dart`) | `lib/modules/chatbot/utils/ai_api_error.dart` | maps errors to friendly messages |

[VERIFIED]

## User flow

1. `onInit` loads sessions and applies navigation arguments (`ChatbotArgs`/String prompt).
2. Sending appends a user bubble and a "thinking" assistant bubble, then:
   - **Mock mode**: `AiRepository.sendMessage` returns a fixture reply + reasoning, played back word-by-word (`_playChatGptStream`).
   - **Live mode**: `AiService.streamChat` SSE emits `meta`, `token`s, then `done`/`error`; `_consumeLiveStream` buffers tokens.
3. Stale/aborted streams are discarded via `_requestToken`; `stopGenerating` cancels with `CancelToken` and calls `DELETE /ai/chat/requests/{requestId}` on live.
4. Sessions can be renamed, pinned, or deleted from the history drawer.

[VERIFIED]

## Loading / error / empty states

- `isLoadingSessions` / `isLoadingMessages` spinners and skeleton state views (`chatbot_state_views.dart`).
- Failure adds or replaces a message with `AiMessageStatus.failed` and restores input/attachments.
- Empty chat shows the starter suggestions (`chatbot_suggestion_list.dart`).
- `AiStreamError` becomes a thrown `AiServiceException` → failed message.

[VERIFIED]

## Permissions

- Photos/videos/files via platform pickers for attachments (client-side only).

## Known limitations / stubs

- **Backend chat is a stub** (`EVIDENCE-BASIS §6`): `ai_core` `ChatService` always returns `stub_reply`; `AI_CHAT_MODE` is read but not branched on. The Flutter client is real but the answer is a stub on the server.
- **Attachments are label-only** — `_buildApiMessage` appends `Photo: <name>` etc. text; no upload. [VERIFIED] `chatbot_controller.dart:472-485`.
- **History search is "coming soon"**; the toolbar tooltip states so. [VERIFIED] `chatbot_history_drawer.dart:71`.
- **Live session rename/pin are no-ops** (`AiRepository.renameSession`/`togglePinSession` only mutate mock state). [VERIFIED] `ai_repository.dart:217-237`.
- `useMockAi` defaults to `useMockApi` when `USE_MOCK_AI` is unset; `.env.example` default is off. [VERIFIED]
- Related AI features (job match, skills, feed) are mock/zero on live. See [`jobs-cv.md`](jobs-cv.md).

## TBDs

- [TBD] Real backend chat (RAG/GDCE is explicitly out of scope per `AGENTS.md`). TBD — Requires confirmation.
- [TBD] Server-side session rename/pin endpoints. TBD — Requires confirmation.
- [TBD] Attachment upload support in AI chat. TBD — Requires confirmation.
