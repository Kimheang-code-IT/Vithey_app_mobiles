# Feature: DevOps - Docker Compose stack

- Issue: #11
- Component: DevOps
- Status: Done
- Branch: `feature/docker-compose`

## Objective

One-command local/production-like stack.

## What exists

backend/docker-compose.yml + demo overlay + per-service compose; external-services Dockerfiles.

## Endpoints / components

docker compose up

## Evidence

compose config validation in CI (backend/demo/infra/monitoring + 10 services)

## Limitations

map-service is opt-in (map profile).
