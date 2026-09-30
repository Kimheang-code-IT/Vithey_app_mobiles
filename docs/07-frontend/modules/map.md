# Module: Map

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/modules/map/`, `vithey_app/lib/data/repositories/place_repository.dart`, `vithey_app/lib/data/services/place_service.dart`

## Purpose

Nearby places / campus map: Google Maps rendering, location, autocomplete search, category/radius/rating filters, favorites, dropped pins with a straight-line route, and directions hand-off to external Google Maps. Backed by `map-service` (Google Places proxy). Optional Compose profile `map`. [VERIFIED] `AGENTS.md`.

## Screens & routes

| Screen | Route | File |
| --- | --- | --- |
| Map | `/map` | `lib/modules/map/map_screen.dart` |

[VERIFIED] `lib/routes/app_pages.dart`.

## Main widgets / helpers

`map_screen.dart` (GoogleMap + sheets), `map_style.dart` (`darkMapStyle`), `map_controller.dart` (including the round `_SheetAction`). Filter/marker logic is in the controller; there is no `widgets/` subfolder. [VERIFIED]

## Controller / state

`MapController` (`map_controller.dart`): `searchQuery`, `suggestions`, `places`, `markers`, `isSearching`, `isLoadingPlaces`, `isLocationGranted`, `isFollowingGps`, `isDroppingPin`, `showSearchThisArea`, `errorMessage`, `selectedPlace`, `droppedPin`, `routeDistanceM`, `polylines`, `filter` (default category `cafe`), `gpsLatLng`, `searchCenter`.

Commands: `_checkLocationPermission`, `onMapCreated`, `goToCurrentLocation`, `onMyLocationTap`, `onCameraMove`, `searchThisArea`, `setSearchCenter`, `onMapLongPress`, `onSearchChanged` (debounce 250 ms), `onSearchSubmitted`, `selectSuggestion`, `loadNearby`, `loadSearch`, `updateFilter`, `openFilterModal`, `openPlaceSheet`, `openDirections`, `startDropPin`/`setDroppedLocation`/`clearDroppedPin`/`directionsToDroppedPin`, `goBack`.

[VERIFIED]

## Repository / API dependencies

| Dependency | File | Endpoints |
| --- | --- | --- |
| `PlaceRepository` | `lib/data/repositories/place_repository.dart` | nearby/search/autocomplete/detail/favorites; mock-first via `USE_MOCK_MAP` |
| `PlaceService` | `lib/data/services/place_service.dart` | `GET /places/nearby`, `/places/search`, `/places/autocomplete`, `/places/{id}`, `GET/POST /places/favorites`, `DELETE /places/favorites/{id}`, `/places/history` |
| Google Maps SDK | `google_maps_flutter` | map tiles/rendering (client) |
| `geolocator` | — | device position + distance |
| `permission_handler` | — | location permission |
| `url_launcher` | — | external directions |

[VERIFIED] `lib/core/constants/api_endpoints.dart`.

## User flow

1. On init, request `locationWhenInUse`; if granted go to current location and load nearby, else load nearby around the default center (`PlaceFixtures.defaultLat/Lng`).
2. Search box autocompletes after 250 ms; selecting a suggestion centers the map (falling back to a text search).
3. "Search this area" re-centers on the visible region; long-press offers "Search around here".
4. Filter modal sets category, radius (500–5000 m), open-now, and min rating.
5. Place card offers Favorite (persisted) and Directions (external Google Maps).
6. Drop-pin mode draws a straight polyline + distance and can hand off driving directions.

[VERIFIED]

## Loading / error / empty states

- `isSearching` / `isLoadingPlaces` for autocomplete and list loading.
- `errorMessage` set on repository failures (no dedicated error widget; surfaced in UI).
- Permission denied → snackbar with a Settings action (`openAppSettings`).
- No places → empty list/markers; filter default is `cafe`.

[VERIFIED]

## Permissions

- `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` (Android manifest); `NSLocationWhenInUseUsageDescription` (iOS). [VERIFIED] `AndroidManifest.xml:17-18`, `Info.plist:5-6`.
- Google Maps API key: Android via `local.properties`/env `GOOGLE_MAPS_API_KEY`; iOS via `Secrets.xcconfig`. Missing key disables map tiles. [VERIFIED] `.env.example:41-42`, `android/app/build.gradle:25-28`.

## Known limitations / stubs

- **Mock-first**: `USE_MOCK_MAP` uses `place_fixtures`. [VERIFIED]
- **Map-service is optional** (Compose profile `map`); when it is not running, live place calls fail and the module falls back to fixtures only if a mock flag is on. [VERIFIED] `AGENTS.md`.
- Routes are **straight lines**, not road-following directions. [VERIFIED] `_rebuildRouteLine`.
- "Add place" (mentioned in `SERVICE_REGISTRY`) is not present in the Flutter module. [VERIFIED]
- Direction hand-off leaves the app (no in-app turn-by-turn). [VERIFIED]
- A Google Maps API key is required; there is no checked-in key. [VERIFIED]

## TBDs

- [TBD] Whether `/add-place` is planned in the client. TBD — Requires confirmation.
- [TBD] Production Google Maps key provisioning in CI. TBD — Requires confirmation.
- [TBD] Favorites/history sync semantics on the live API. TBD — Requires confirmation.
