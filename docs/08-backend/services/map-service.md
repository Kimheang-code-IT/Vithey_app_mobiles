# map-service

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/map-service/`, `backend/services/map-service/src/main/resources/application.yml`, `backend/services/map-service/src/main/resources/db/migration/V1__init_map_schema.sql`

Part of the Vithey documentation set · Master index:
[`../../00-project-overview/07-document-index.md`](../../00-project-overview/07-document-index.md) ·
Siblings: [Backend architecture](../01-backend-architecture.md) ·
[Microservice architecture](../02-microservice-architecture.md) · [Cache strategy](../07-cache-strategy.md) ·
[Error handling](../08-error-handling.md) ·
API: [`../../06-api/11-map-api.md`](../../06-api/11-map-api.md).

## 1. Purpose

Server-side proxy and normaliser for **Google Places API (New)**: nearby/text search, autocomplete,
place detail, plus per-user favorites and recent-search history. The API key never leaves the
server. [VERIFIED]

## 2. Responsibilities

- Keyword/nearby search biased to user coordinates; normalise Google payloads; apply server-side
  filters (rating, price, open-now) and distance sort.
- Autocomplete suggestions with coordinate bias.
- Place detail with a 24 h cache; `is_favorite` computed per caller.
- Owner-scoped favorites (idempotent upsert) and recent-search history (capped at 20/user).
- Wrap Google calls with a Resilience4j circuit breaker and map upstream errors.

## 3. Port and identity

| Item | Value |
|---|---|
| Port | `8090` (`SERVER_PORT`) |
| Eureka name | `map-service` |
| Database | `map_db` + Redis |
| Gateway route | `/api/v1/places/**` (rate limit 30/60) |
| Deployment | **Optional** compose profile `map` |

[VERIFIED: `config-repo/api-gateway.yml`, `AGENTS.md`, `EVIDENCE-BASIS.md` §9]

## 4. Main controllers

| Controller | Base path | Endpoints |
|---|---|---|
| `PlaceSearchController` | `/api/v1/places` | `GET /nearby`, `GET /search`, `GET /autocomplete` |
| `PlaceDetailController` | `/api/v1/places` | `GET /{googlePlaceId}` |
| `PlaceFavoriteController` | `/api/v1/places/favorites` | `GET`, `POST`, `DELETE /{googlePlaceId}` |
| `PlaceHistoryController` | `/api/v1/places/history` | `GET`, `DELETE` |

Literal path segments take precedence over `/{googlePlaceId}`. [VERIFIED]

## 5. Main services

| Service | Responsibility |
|---|---|
| `NearbySearchService` | Google Nearby (New), normalize, filter, favorite flags, optional history |
| `TextSearchService` | Google Text Search (New), same pipeline with query history |
| `AutocompleteService` | Predictions with ~50 km bias |
| `PlaceDetailService` | Detail with 24 h cache; per-caller favorite |
| `PlaceFavoriteService` | Favorites upsert/remove/list |
| `PlaceHistoryService` | Record/trim (max 20)/clear history |
| `PlaceCacheService` | Redis search/detail cache with graceful degradation |
| `GooglePlacesClient` | WebClient to Places (New) with circuit breaker + error mapping |

[VERIFIED]

## 6. Repositories

`PlaceFavoriteRepository`, `PlaceSearchHistoryRepository`. [VERIFIED]

## 7. Entities and tables (`map_db`)

| Entity | Table | Notes |
|---|---|---|
| `PlaceFavorite` | `place_favorites` | unique per `(user_id, google_place_id)`; snapshot fields (name, address, lat/lng, category, photo_url) |
| `PlaceSearchHistory` | `place_search_history` | `query` (≤100), `category`, lat/lng, `radius_m`; trimmed to 20 (`MAX_ENTRIES_PER_USER`) |

[VERIFIED]

## 8. Database

Flyway: `V1__init_map_schema.sql` (1). `ddl-auto: validate`. [VERIFIED]

## 9. API routes

See [`../../06-api/11-map-api.md`](../../06-api/11-map-api.md) for query parameters and schemas
(`NearbySearchRequest`/`TextSearchRequest` limits, categories, pagination).

## 10. Events

None. [VERIFIED]

## 11. Cache usage

Redis (imperative, degrading): search `places:search:*`/`places:nearby:*` (5 min), detail
`places:detail:<id>` (24 h). Redis failure falls back to cache miss. See
[Cache strategy](../07-cache-strategy.md). [VERIFIED]

## 12. External dependencies

- `GooglePlacesClient` (Spring `WebClient`, reactive) to `GOOGLE_PLACES_BASE_URL` (default
  `https://places.googleapis.com/v1`), sending `X-Goog-Api-Key` and `X-Goog-FieldMask`.
- Resilience4j `googlePlaces` circuit breaker (window 10, min calls 5, failure 50%, open 30 s).
- Redis for caching. [VERIFIED]

## 13. Auth and authorization

All endpoints require JWT; favorites and history are scoped to the JWT subject; favorites are
owner-scoped for delete. [VERIFIED]

## 14. Configuration (env names only)

`SERVER_PORT`, `MAP_DB_URL`, `MAP_DB_USERNAME`, `MAP_DB_PASSWORD`, `REDIS_HOST`, `REDIS_PORT`,
`EUREKA_CLIENT_ENABLED`, `EUREKA_URL`, `VITHEY_JWT_SECRET`, `GOOGLE_PLACES_API_KEY`,
`GOOGLE_PLACES_BASE_URL`, `GOOGLE_PLACES_CONNECT_TIMEOUT_MS`, `GOOGLE_PLACES_RESPONSE_TIMEOUT_MS`,
`GOOGLE_PLACES_PHOTO_URL_TEMPLATE`, `MAP_CACHE_SEARCH_TTL`, `MAP_CACHE_DETAIL_TTL`,
`HIKARI_MAX_POOL`, `HIKARI_MIN_IDLE`. No secret values. [VERIFIED]

## 15. Health checks

`GET /actuator/health`. [VERIFIED]

## 16. Tests

Unit only (no context/IT, no test-support dependency):
`GooglePlacesClientTest.java`, `NearbySearchServiceTest.java`, `PlaceCacheServiceTest.java`,
`PlaceFavoriteServiceTest.java`. Test implemented — current execution result not independently
verified. [VERIFIED: `EVIDENCE-BASIS.md` §10]

## 17. Known limitations / TBD

- No `*ContextTest` / `*SmokeIT` (unlike other services). [VERIFIED]
- Google Places API version, quota and billing configuration: `TBD — Requires confirmation.`
- Whether history is written on every search or only explicit calls: `TBD — Requires confirmation.`
