# Feature: Social - Home feed

- Issue: #13
- Component: Social
- Status: Done
- Branch: `feature/social-feed`

## Objective

Show students a paginated feed of posts.

## What exists

PostController GET /posts, FeedService; tests.

## Endpoints / components

GET /posts

## Evidence

PostServiceTest, ContentServiceContextTest; smoke-api feed step

## Limitations

Chronological ordering for the demo.
