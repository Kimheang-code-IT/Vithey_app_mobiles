# Peer Chat Guide

> Status: Verified (core) / call & video are simulated · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/modules/chat/**`, `vithey_app/lib/data/services/chat_stomp_service.dart`, `api_docs.md` §9
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

## 1. Overview

Peer chat is a **live** feature backed by `chat-service` (`:8087`) with REST for history and STOMP
over WebSocket for realtime [VERIFIED: `api_docs.md` §9]. You reach it from the **Home app-bar
composer icon** (with an unread badge) → `/chat` [VERIFIED: `lib/modules/home/widgets/home_app_bar.dart`].

This is separate from the **Vithey AI chatbot** (see [08-ai-assistant-guide.md](08-ai-assistant-guide.md)).

## 2. Chat list

`/chat` shows [VERIFIED: `lib/modules/chat/chat_list_controller.dart`]:

- **Conversations** with unread counts and last-message previews.
- **Message requests** (pending inbox) you can accept or decline.
- **Recent contacts** to quickly resume a chat.
- **Folders**: All, Unread, and custom folders you create (stored locally on the device).
- **Search** across conversations and message snippets.

| Action | Endpoint |
| --- | --- |
| List conversations | `GET /conversations?page=&limit=` |
| List requests | `GET /message-requests` |
| Accept request | `POST /conversations/{id}/accept` |
| Decline request | `POST /conversations/{id}/decline` |
| Block | `POST /conversations/{id}/block` |
| Start chat | `POST /message-requests` (`{ "to_user_id", "initial_message" }`) |

[VERIFIED: `api_docs.md` §9]

> To start a new chat the app uses `POST /message-requests` (a pending request). The server also has
> `POST /conversations/start`, but Flutter does not use it [VERIFIED: `api_docs.md` §9, §15].

## 3. Conversation

`/chat/detail` (and `/chat/profile` for the partner's shared media)
[VERIFIED: `lib/modules/chat/`].

| Action | Endpoint / channel |
| --- | --- |
| Load history | `GET /conversations/{id}/messages?page=&limit=&before=` |
| Send message | `POST /conversations/{id}/messages` |
| Mark read (one) | `PATCH /messages/{id}/read` |
| Mark read (batch) | `POST /conversations/{id}/messages/read` |
| Presence | `GET /conversations/{id}/presence` |
| Report user | `POST /users/{user_id}/report` |

Message types: `TEXT`, `IMAGE`, `FILE`. For media, upload a `CHAT_ATTACHMENT` first, then send with
`file_id` [VERIFIED: `api_docs.md` §9].

## 4. Realtime (STOMP)

| Item | Value |
| --- | --- |
| URL | `ws://{host}:8080/ws` |
| Protocol | STOMP 1.2 |
| Auth | `Authorization: Bearer {jwt}` on CONNECT |
| Inbox | `/user/queue/messages` |
| Presence | `/user/queue/presence` |
| Send / typing / heartbeat | `/app/chat.send`, `/app/chat.typing`, `/app/chat.heartbeat` |

Frames carry a `type`: `MESSAGE`, `READ_RECEIPT`, `TYPING`, `PRESENCE`
[VERIFIED: `api_docs.md` §9]. Recent messages are cached in Redis (`chat:recent:*`, 24h)
[VERIFIED: `_meta/EVIDENCE-BASIS.md` §4].

## 5. Folders (device-local)

Custom folders ("New folder", rename, delete, move chats) are stored **locally** (JSON in local
storage), not on the server [VERIFIED: `chat_list_controller.dart` `_persistFolders`].

## 6. Not active / simulated

- **Calls and video calls are simulated.** The "Call" / "Video" actions trigger a mock in-app
  incoming-call banner and simulated typing — there is no real telephony or WebRTC
  [VERIFIED: `chat_stomp_service.dart` `simulateIncomingCall`, `chat_repository.dart`].
- **Mute** only shows a local notification ("Notifications muted for this chat"); there is no
  server mute endpoint [VERIFIED: `AppStrings.chatNotificationsMuted`].
- The current backend has no `/api/v1/chat/**` REST namespace; realtime uses STOMP plus the
  `/conversations`, `/message-requests`, and `/messages` routes above [VERIFIED: `api_docs.md` §15].

## 7. Model storage

Chat conversations, messages, and an outbox are persisted locally with **Isar** (the only Isar use
in the app) [VERIFIED: `_meta/EVIDENCE-BASIS.md` §7].

## 8. Related

- [08-ai-assistant-guide.md](08-ai-assistant-guide.md) · [04-feed-guide.md](04-feed-guide.md)
- [../06-api/09-chat-api.md](../06-api/09-chat-api.md) · [../06-api/13-websocket-api.md](../06-api/13-websocket-api.md)
- Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)
