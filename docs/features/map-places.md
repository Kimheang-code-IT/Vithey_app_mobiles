# Feature: Map - Place search, details and favorites

- Issue: #29
- Component: Map
- Status: Done
- Branch: `feature/map-places`

## Objective

Search places, view details, save favorites.

## What exists

PlaceSearch/Detail/Favorite/History controllers; tests.

## Endpoints / components

GET /places/search, /places/{id}, /places/favorites, /places/history

## Evidence

NearbySearchServiceTest, PlaceCacheServiceTest, PlaceFavoriteServiceTest, PlaceQueryParameterBindingTest

## Limitations

Live data depends on Google Places quota.
