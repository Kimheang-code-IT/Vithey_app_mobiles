# Feature: Social - Follow system

- Issue: #16
- Component: Social
- Status: Done
- Branch: `feature/social-follow`

## Objective

Build a social graph.

## What exists

FollowController; FollowCreated event.

## Endpoints / components

POST/DELETE /users/{id}/follow

## Evidence

FollowServiceTest

## Limitations

No follower-count caching.
