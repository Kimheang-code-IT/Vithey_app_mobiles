# Feature: Social - Post update endpoint

- Issue: #14
- Component: Social
- Status: Done
- Branch: `feature/social-post-update`

## Objective

Let authors edit their posts.

## What exists

PATCH /api/v1/posts/{id} (owner-only) added in PR #47 with UpdatePostRequest, service and controller.

## Endpoints / components

PATCH /posts/{id}

## Evidence

PostServiceTest (7 tests, incl. 403/404/update)

## Limitations

Type/media immutable.
