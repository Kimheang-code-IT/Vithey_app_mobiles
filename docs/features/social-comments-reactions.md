# Feature: Social - Comments and reactions

- Issue: #15
- Component: Social
- Status: Done
- Branch: `feature/social-comments-reactions`

## Objective

Discussion and light engagement on posts.

## What exists

CommentController, ReactionController; notification events.

## Endpoints / components

POST/GET /posts/{id}/comments, /reactions

## Evidence

CommentServiceTest

## Limitations

Limited reaction types.
