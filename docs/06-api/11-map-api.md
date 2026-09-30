# Map API (map-service)

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/map-service/src/main/java/com/vithey/map/controller/*.java`, `dto/**`, `service/PlaceCacheService.java`

Base path: `/api/v1/places`. Service port `8090`. **Optional** service: it starts only with the
Compose profile `map` (`docker-up-demo.ps1 -Profiles map`). Requires a server-side
`GOOGLE_PLACES_API_KEY`; the app never sees the key. All endpoints require JWT. Search/detail use a
Redis cache (5 min / 24 h) and degrade gracefully if Redis is unavailable.

## 1. Endpoint inventory

| Method | Path | Auth | Required role | Purpose | Request | Response | Errors |
|---|---|---|---|---|---|---|---|
| GET | `/api/v1/places/nearby` | JWT | any | Nearby places by lat/lng | `NearbySearchRequest` (query) | `PlaceSearchResultResponse` | 400, 401, 502 |
| GET | `/api/v1/places/search` | JWT | any | Keyword search near user | `TextSearchRequest` (query) | `PlaceSearchResultResponse` | 400, 401, 502 |
| GET | `/api/v1/places/autocomplete` | JWT | any | Typeahead suggestions | `?input=&lat=&lng=` | `AutocompleteSuggestionResponse[]` | 400, 401, 502 |
| GET | `/api/v1/places/{googlePlaceId}` | JWT | any | Place detail | path | `PlaceDetailResponse` | 401, 404, 502 |
| GET | `/api/v1/places/favorites` | JWT | any | My saved places | — | `PlaceCardResponse[]` | 401 |
| POST | `/api/v1/places/favorites` | JWT | any | Save/upsert favorite | `SaveFavoriteRequest` | `PlaceCardResponse` | 400, 401 |
| DELETE | `/api/v1/places/favorites/{googlePlaceId}` | JWT | owner | Remove favorite | path | `204` | 401, 404 |
| GET | `/api/v1/places/history` | JWT | any | Recent searches (max 20) | — | `PlaceHistoryResponse[]` | 401 |
| DELETE | `/api/v1/places/history` | JWT | any | Clear history | — | `204` | 401 |

> `PlaceDetailController` and `PlaceFavoriteController` are mapped under
> `/api/v1/places`; `GET /{googlePlaceId}` shares the base with `/nearby`, `/search`,
> `/autocomplete`, `/favorites`, `/history`. Literal segments take precedence.

## 2. Query parameters

`nearby` / `search` (`NearbySearchRequest` / `TextSearchRequest`): `lat` (required, −90..90),
`lng` (required, −180..180), `radius_m` (100..20000, default 1500), `category`, `open_now`,
`min_rating` (1..5), `price_level` (0..4), `page_token`, `limit` (1..40, default 20). `search` also
requires `query` (2..100). `autocomplete` requires `input` and optional `lat`/`lng`.

## 3. Schemas

`PlaceSearchResultResponse` = `center { lat, lng }, radius_m, places[] (PlaceCardResponse),
next_page_token`.
`PlaceCardResponse` = `google_place_id, name, address, category, latitude, longitude, rating,
user_rating_count, price_level, open_now, distance_m, photo_url, is_favorite`.
`PlaceDetailResponse` = card fields plus `opening_hours[], phone, website, google_maps_uri,
photo_urls[]`.
`AutocompleteSuggestionResponse` = `google_place_id, primary_text, secondary_text, distance_m`.
`PlaceHistoryResponse` = `query, category, latitude, longitude, radius_m, created_at`.
`SaveFavoriteRequest` = `google_place_id, name` (required), `address`, `latitude`, `longitude`,
`category`, `photo_url`.

## 4. Examples

### GET `/api/v1/places/nearby?lat=11.55&lng=104.92&radius_m=1500&limit=20` → 200

```json
{
  "data": {
    "center": { "lat": 11.55, "lng": 104.92 },
    "radius_m": 1500,
    "places": [
      {
        "google_place_id": "ChIJ...",
        "name": "Cafe",
        "address": "Phnom Penh",
        "category": "cafe",
        "latitude": 11.551,
        "longitude": 104.921,
        "rating": 4.5,
        "user_rating_count": 120,
        "price_level": 2,
        "open_now": true,
        "distance_m": 250,
        "photo_url": "https://...",
        "is_favorite": false
      }
    ],
    "next_page_token": null
  }
}
```

### POST `/api/v1/places/favorites` → 201

```json
{
  "google_place_id": "ChIJ...",
  "name": "Cafe",
  "address": "Phnom Penh",
  "latitude": 11.551,
  "longitude": 104.921,
  "category": "cafe",
  "photo_url": "https://..."
}
```

## 5. Data touched

`map_db`: `place_favorites` (unique per user+place), `place_search_history` (capped 20/user in code).
See [`../05-database/03-database-schema.md`](../05-database/03-database-schema.md) §9.

## 6. TBD

- Google Places API version/quota/billing config: `TBD — Requires confirmation.`
- Whether search history rows are written automatically on every search or only via an explicit
  call: `TBD — Requires confirmation.`
