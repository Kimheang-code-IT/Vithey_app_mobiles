# Feature: User Profile - Skills and extended fields

- Issue: #8
- Component: User Profile
- Status: Done
- Branch: `feature/profile-skills`

## Objective

Capture skills/major so CV generation and matching have data.

## What exists

ProfileSkillEntry + V2 migration; used by AI CV pipeline.

## Endpoints / components

PATCH /users/me (skills)

## Evidence

user-profile-service tests; ai-core CV tests

## Limitations

Free-text skill vocabulary.
