# Feature: Chat - Real-time messaging (STOMP)

- Issue: #23
- Component: Chat
- Status: Done
- Branch: `feature/chat-realtime-messaging`

## Objective

Deliver messages in real time.

## What exists

ChatStompController + Flutter realtime hub with Isar outbox.

## Endpoints / components

WebSocket STOMP; REST /conversations/{id}/messages

## Evidence

chat-service tests

## Limitations

Presence/typing basic.
