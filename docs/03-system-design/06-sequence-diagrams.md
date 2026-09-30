# Sequence Diagrams

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `auth-service/**`, `api-gateway/**`, `content-service/**`, `notification-service/**`, `ai_core/vithey_ai/**`, `chat-service/**`, `vithey_app/lib/core/network/dio_client.dart`, `vithey_app/lib/data/services/chat_stomp_service.dart`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [Data flow](05-data-flow-diagram.md) · [LLD](03-low-level-design-LLD.md)

All participants are real components; every message reflects verified code/config. Error branches (invalid token, refresh failure) are shown where the code implements them.

## 1. Login and JWT refresh

```mermaid
sequenceDiagram
  autonumber
  participant App as Flutter app
  participant Dio as DioClient
  participant GW as api-gateway
  participant Auth as auth-service
  participant DB as auth_db

  App->>Dio: submit login(email, password)
  Dio->>GW: POST /api/v1/auth/login
  Note over GW: /auth/login is a public path
  GW->>Auth: lb://auth-service
  Auth->>DB: find user by email
  Auth->>Auth: bcrypt verify + mint JWT (sub,email,roles)
  Auth->>DB: store hashed refresh token
  Auth-->>GW: 200 data{access_token,refresh_token}
  GW-->>Dio: 200
  Dio->>App: save tokens in secure storage

  Note over App,Auth: Later, access token expired
  App->>Dio: any protected request
  Dio->>GW: GET /api/v1/... Authorization Bearer <expired>
  GW-->>Dio: 401 UNAUTHORIZED
  Dio->>GW: POST /api/v1/auth/refresh {refresh_token}
  GW->>Auth: lb://auth-service
  Auth-->>GW: 200 data{access_token,refresh_token}
  GW-->>Dio: 200
  Dio->>Dio: save new tokens
  Dio->>GW: replay original request with new token
  GW-->>Dio: 200
  Dio-->>App: response
```

[VERIFIED — `dio_client.dart` interceptor (`onError` 401 → `_tryRefreshToken` → replay), `PublicPathMatcher`, `JwtProvider`, `config-repo/application.yml` TTLs]

## 2. Create post → notification event

```mermaid
sequenceDiagram
  autonumber
  participant App as Flutter app
  participant GW as api-gateway
  participant Content as content-service
  participant CDB as content_db
  participant MQ as RabbitMQ vithey.events
  participant Notif as notification-service
  participant NDB as notification_db

  App->>GW: POST /api/v1/posts (Bearer JWT)
  GW->>GW: validate JWT, inject X-User-Id
  GW->>Content: lb://content-service
  Content->>CDB: save post
  Content->>MQ: publish post.created
  Note over MQ: no notification queue bound for post.created
  Content-->>GW: 201 data{post}
  GW-->>App: 201

  Note over App,NDB: A follower comments on the post
  App->>GW: POST /api/v1/comments (Bearer JWT)
  GW->>Content: lb://content-service
  Content->>CDB: save comment
  Content->>MQ: publish comment.added
  MQ->>Notif: notification.comment.added
  Notif->>NDB: persist notification
  Notif-->>App: appears via GET /api/v1/notifications
```

[VERIFIED — `PostService.java:70` `publishPostCreated`, `ContentEventPublisher.java`, `notification-service/.../RabbitMqConfig.java` binds `comment.added` → `notification.comment.added`]

## 3. AI CV generation (real LLM)

```mermaid
sequenceDiagram
  autonumber
  participant App as Flutter app
  participant GW as api-gateway
  participant AI as ai_core
  participant Prof as user-profile-service
  participant Cont as content-service
  participant LLM as LLM provider

  App->>GW: POST /api/v1/ai/cv/generate (Bearer JWT)
  GW->>AI: http://ai-core:8100/api/v1/ai/cv/generate (direct route)
  AI->>AI: authenticate (JWT sub or X-User headers)
  AI->>Prof: httpx GET profile
  AI->>Cont: httpx GET user posts
  Prof-->>AI: profile
  Cont-->>AI: posts
  AI->>AI: extraction cache lookup (SHA-256)
  alt cache miss
    AI->>LLM: JSON-mode extraction prompt
    LLM-->>AI: extracted activities
  end
  AI->>AI: dedupe + build prompt
  AI->>LLM: CV generation prompt
  LLM-->>AI: draft CV
  AI->>AI: normalize_cv + score_cv rubric
  AI-->>GW: 200 data{StandardCV, quality}
  GW-->>App: 200
  Note over AI: on LLM failure after retries -> 502 UPSTREAM_ERROR
```

[VERIFIED — `flutter_routes.py` `/cv/generate`, `cv_app_service.py`, `extraction.py`, `quality.py`, `api-gateway.yml` ai-core route, `auth.py`]

## 4. Chat send over STOMP

```mermaid
sequenceDiagram
  autonumber
  participant App as Flutter app
  participant STOMP as ChatStompService
  participant GW as api-gateway
  participant Chat as chat-service
  participant Redis as Redis chat:recent
  participant CDB as chat_db
  participant MQ as RabbitMQ vithey.events
  participant Notif as notification-service
  participant Peer as Peer Flutter app

  App->>STOMP: connect(jwt)
  STOMP->>GW: WSS /ws (Authorization header)
  GW->>Chat: lb:ws://chat-service
  Chat->>Chat: JwtHandshakeInterceptor validate
  Chat-->>STOMP: STOMP CONNECTED
  STOMP->>Chat: SUBSCRIBE /user/queue/messages

  App->>STOMP: sendMessage(conversationId,text,clientMessageId)
  STOMP->>Chat: SEND /app/chat.send
  Chat->>Chat: StompAuthChannelInterceptor validate
  Chat->>CDB: persist message
  Chat->>Redis: update recent cache (24h)
  Chat->>MQ: publish chat.message.sent
  Chat-->>STOMP: MESSAGE /user/queue/messages
  Chat-->>Peer: MESSAGE /user/queue/messages
  MQ->>Notif: notification.chat.message.sent
```

[VERIFIED — `WebSocketConfig.java`, `ChatStompController`, `chat_stomp_service.dart:33-92`, `EVIDENCE-BASIS.md` §4]

## 5. Student verification → finance (event chain)

```mermaid
sequenceDiagram
  autonumber
  participant App as Flutter app
  participant Auth as auth-service
  participant MQ as RabbitMQ vithey.events
  participant Finance as finance-service
  participant FDB as finance_db

  App->>Auth: POST /api/v1/students/verify (JWT required at gateway)
  Auth->>Auth: record StudentVerification
  Auth->>MQ: publish student.verified
  MQ->>Finance: finance.student.verified
  Finance->>FDB: unlock student fee/payment scope
  App->>Finance: GET /api/v1/fees (STUDENT role)
  Finance-->>App: 200 data{fees}
```

[VERIFIED — auth `StudentVerificationService`/publisher, finance `@PreAuthorize("hasRole('STUDENT')")`, `EVIDENCE-BASIS.md` §4-5]

Cross-reference the [component diagram](04-component-diagram.md) for the static view behind these interactions.
