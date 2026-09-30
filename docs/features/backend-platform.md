# Feature: Backend - Discovery, Config and Gateway

- Issue: #10
- Component: Backend
- Status: Done
- Branch: `feature/backend-platform`

## Objective

Service discovery, centralised config and one secured API entry point.

## What exists

eureka-server, config-server (config-repo), api-gateway (JWT + Redis rate limit).

## Endpoints / components

gateway /api/v1/**, /actuator/**

## Evidence

EurekaServerContextTest, ConfigServerContextTest, ApiGatewayContextTest, JwtValidatorTest

## Limitations

Gateway context test isolation fixed in #37.
