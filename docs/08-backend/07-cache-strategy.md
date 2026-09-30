# Cache Strategy (Redis)

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/api-gateway/.../RedisRateLimiterConfig.java`, `backend/services/chat-service/.../service/{MessageCacheService,PresenceService,TypingService}.java`, `backend/services/map-service/.../service/PlaceCacheService.java`, `backend/infrastructure/config-repo/application.yml`

Vithey uses Redis **imperatively** through `StringRedisTemplate` / `ReactiveStringRedisTemplate`.
There is **no Spring Cache abstraction** (`@Cacheable`, `CacheManager`) anywhere in the backend.
Redis is used for three things: the gateway rate limiter, chat ephemeral state, and the map-service
response cache. [VERIFIED]

Part of the Vithey documentation set · Master index:
[`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) ·
Siblings: [API gateway](05-api-gateway.md) · [Microservice architecture](02-microservice-architecture.md).

## 1. Redis connection

```yaml
spring:
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
```

Host ports in the demo: Redis 16379 (dev), 6379 in-network. [VERIFIED:
`config-repo/application.yml`, `EVIDENCE-BASIS.md` §3]

## 2. Gateway — distributed rate limiting

`RedisRateLimiter` (Spring Cloud Gateway) with `rateLimitKeyResolver`:

- Key: `user:<X-User-Id>` if present, else `ip:<client-ip>` (honours `X-Forwarded-For`).
- Defaults 100 req/s refill, 100 burst; places route 30/60.
- Redis is the backing store, so limits are shared if the gateway is replicated. [VERIFIED]

## 3. chat-service — ephemeral real-time state

All chat cache keys are prefixed `chat:` and use TTLs (no persistence guarantee):

| Key pattern | Type | TTL | Purpose | Source |
|---|---|---|---|---|
| `chat:recent:<conversationId>` | list | 24 h | Recent message IDs, trimmed to `recentMessagesLimit` (default 50) | `MessageCacheService` |
| `chat:presence:<userId>` | string | `presenceTtlSeconds` (default 90 s) | Online marker; heartbeats re-arm it | `PresenceService` |
| `chat:typing:<conversationId>:<userId>` | string | `typingTtlSeconds` (default 5 s) | Typing indicator | `TypingService` |

Chat properties (`vithey.chat.*`, record defaults 90/5/50) are not declared in `config-repo/chat-service.yml`
in this revision; the record defaults apply unless overridden by env. [VERIFIED: `ChatProperties.java`]

> Redis is required for chat presence/typing; the recent-message cache is best-effort. The chat
> service does not degrade as gracefully as map-service — a Redis outage affects presence/typing.
> [INFERRED] Inferred from implementation — requires business confirmation.

## 4. map-service — response cache with graceful degradation

`PlaceCacheService` caches serialized JSON:

| Item | Key | TTL |
|---|---|---|
| Nearby/text search | `places:<kind>:<sha256(canonical parts)>` (`kind` = `nearby` or `search`) | 5 min (`SEARCH_TTL`) |
| Place detail | `places:detail:<googlePlaceId>` | 24 h (`DETAIL_TTL`) |

- Cache keys round coordinates to ~4 decimals (~11 m) to improve hit rate.
- Every read/write is wrapped in `try/catch (DataAccessException | JsonProcessingException)` and
  **degrades to a cache miss / no-op** on Redis failure, so the request still succeeds against
  Google. [VERIFIED: `PlaceCacheService.java`]
- `is_favorite` is always computed per caller and is **never** cached. [VERIFIED]

The `application.yml` also exposes `vithey.map.cache.search-ttl` (`MAP_CACHE_SEARCH_TTL`, default
`5m`) and `vithey.map.cache.detail-ttl` (`MAP_CACHE_DETAIL_TTL`, default `24h`), although the
`PlaceCacheService` constants are the values actually used in code. [VERIFIED]

## 5. Services without a cache

auth, user-profile, file, content, career, finance and notification do **no** Redis caching; they
read/write PostgreSQL (and MinIO for files) directly. Cross-service data (author profiles, file
URLs) is resolved synchronously per request via Feign. [VERIFIED]

## 6. Ownership summary

| Service | Uses Redis |
|---|---|
| api-gateway | Yes — rate limiter |
| chat-service | Yes — recent messages, presence, typing |
| map-service | Yes — search/detail cache (degrading) |
| auth, user-profile, file, content, career, finance, notification | No |

`ai_core` (Python) does **not** use Redis; it has its own in-process extraction cache and rate
limiter — see [09-ai/09-rate-limit-cache.md](../09-ai/09-rate-limit-cache.md).

## 7. Known limitations / TBD

- No cache eviction/invalidation on data mutation (chat recent IDs are append+trim; map cache is
  pure TTL). [VERIFIED]
- No Redis persistence/HA configuration is defined in the repo (defaults). `TBD — Requires
  confirmation.`
- `vithey.chat.*` TTLs are code defaults; whether ops overrides them via env is `TBD — Requires
  confirmation.`
