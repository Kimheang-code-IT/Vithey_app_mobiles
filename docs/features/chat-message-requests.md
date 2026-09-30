# Feature: Chat - Message requests and reporting

- Issue: #24
- Component: Chat
- Status: Done
- Branch: `feature/chat-message-requests`

## Objective

Gate unsolicited DMs; report abuse.

## What exists

MessageRequestController, ReportController.

## Endpoints / components

POST /message-requests; POST /reports

## Evidence

chat-service tests; smoke-api steps

## Limitations

No moderation tooling.
