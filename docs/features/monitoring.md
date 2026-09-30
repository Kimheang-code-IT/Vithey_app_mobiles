# Feature: Monitoring - Prometheus and Grafana

- Issue: #32
- Component: Monitoring
- Status: Done
- Branch: `feature/monitoring`

## Objective

Operational visibility into service health.

## What exists

monitoring/prometheus + grafana provisioning/dashboards.

## Endpoints / components

Prometheus :9090, Grafana :3000

## Evidence

promtool check config; Grafana YAML/JSON parse; CI Monitoring job

## Limitations

ai_core/eureka/config/map not scraped.
