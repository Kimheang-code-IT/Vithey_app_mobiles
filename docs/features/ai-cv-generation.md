# Feature: AI - AI CV generation

- Issue: #30
- Component: AI
- Status: Done
- Branch: `feature/ai-cv-generation`

## Objective

Generate a CV from profile data.

## What exists

ai_core FastAPI pipeline (extraction/generation/quality/dedupe/cache/ratelimit).

## Endpoints / components

POST /ai/cv/generate, /ai/cv/suggest

## Evidence

ai-core pytest (70)

## Limitations

Live LLM needs DEEPSEEK_API_KEY.
