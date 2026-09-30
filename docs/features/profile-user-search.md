# Feature: User Profile - User search

- Issue: #9
- Component: User Profile
- Status: Done
- Branch: `feature/profile-user-search`

## Objective

Let students find peers (e.g. to start a chat).

## What exists

pg_trgm GIN index (V3) + UserSearchService; tests.

## Endpoints / components

GET /users/search

## Evidence

UserSearchServiceTest

## Limitations

No advanced ranking.
