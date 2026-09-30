# Map & Places Guide

> Status: Verified (core) / requires server Google Places key · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/modules/map/**`, `backend/services/map-service/.env.example`, `api_docs.md` §12
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

## 1. Overview

The Map screen (`/map`) shows nearby places using `map-service` (`:8090`). It is reachable from the
**Home app-bar map icon** and from search results [VERIFIED: `lib/modules/home/widgets/home_app_bar.dart`,
`lib/modules/search/widgets/search_results_view.dart`].

> **Dependency.** `map-service` is an **optional Compose profile** (`map`) and needs a
> **server-side** `GOOGLE_PLACES_API_KEY`. Without it the map returns a clear config error, and the
> Flutter app never sees the key [VERIFIED: `api_docs.md` §12, `backend/.env.example`,
> `map-service/.env.example`, `plan.md` §0]. Start it with
> `backend/scripts/docker-up-demo.ps1 -Profiles map`.

## 2. Permissions & location

On open, the app requests **location-when-in-use**. If granted, it centres on your GPS position and
loads nearby places; if denied, it loads nearby places around a default centre and offers a
"Settings" shortcut to enable location [VERIFIED: `lib/modules/map/map_controller.dart`
`_checkLocationPermission`, `onMyLocationTap`].

## 3. Finding places

| Capability | Detail |
| --- | --- |
| Nearby | `GET /places/nearby` around the current/search centre |
| Text search | `GET /places/search` (`query` ≥ 2 chars) |
| Autocomplete | `GET /places/autocomplete` (250 ms debounce) |
| Search this area | Pan the map, then "Search this area" re-centres and reloads |
| Long-press | Long-press the map to "Search around here" |
| Filters | Category, radius (500–5000 m), Open now, Minimum rating |

[VERIFIED: `map_controller.dart`]

## 4. Place details & actions

Tapping a marker opens a bottom sheet with [VERIFIED: `map_controller.dart` `openPlaceSheet`]:

- Name, address, rating, distance, category, and an "Open now" flag.
- **Favorite / Saved** — `POST`/`DELETE /places/favorites`, list via `GET /places/favorites`.
- **Directions** — opens external Google Maps at the destination

## 5. Dropped pin & route

You can drop a pin (long-press flow / "drop pin" mode), see a straight-line route with distance, and
launch external driving directions to the pin [VERIFIED: `map_controller.dart` `startDropPin`,
`setDroppedLocation`, `directionsToDroppedPin`].

> The in-app route line is a **straight geodesic** between origin and destination (with a distance
> read-out), not turn-by-turn navigation; real routing is delegated to the external Google Maps app
> [VERIFIED: `map_controller.dart` `_rebuildRouteLine`].

## 6. History & favorites

- Recent places: `GET /places/history` (max 20), clear with `DELETE /places/history`.
- Favorites are stored server-side via the `/places/favorites` endpoints [VERIFIED: `api_docs.md` §12].
- `map-service` caches searches for 5 minutes and details for 24 hours in Redis, degrading
  gracefully if Redis is unavailable [VERIFIED: `_meta/EVIDENCE-BASIS.md` §4].

## 7. Notes & limitations

- The app uses `google_maps_flutter` for rendering; the Android key is configured separately in
  `android/local.properties` (`GOOGLE_MAPS_API_KEY`) and iOS in `Secrets.xcconfig`
  [VERIFIED: `.env.example` comments].
- Place photo handling is template-based; photo proxying is deferred
  [VERIFIED: `map-service/.env.example`].
- Map is only started under the `map` Compose profile, so it is absent from the default demo stack
  [VERIFIED: `backend/.env.example`].

## 8. Related

- [04-feed-guide.md](04-feed-guide.md) · [10-FAQ.md](10-FAQ.md) · [01-user-manual.md](01-user-manual.md)
- [../06-api/11-map-api.md](../06-api/11-map-api.md)
- Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)
