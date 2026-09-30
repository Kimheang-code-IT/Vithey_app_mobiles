# Stop Vithey Profile M demo stack (base + demo overlay)
# Pass -v to also remove volumes (wipes DBs - use for Flyway checksum recovery)
# Pass -Profiles map if the map profile was started.
param(
    [switch]$v,
    [string]$Profiles = ""
)

$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

if ($Profiles) { $env:COMPOSE_PROFILES = $Profiles }

Write-Host "Stopping Vithey DEMO stack (Profile M)..." -ForegroundColor Cyan
if ($v) {
  docker compose -f docker-compose.yml -f docker-compose.demo.yml down -v
} else {
  docker compose -f docker-compose.yml -f docker-compose.demo.yml down
}

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Demo stack stopped." -ForegroundColor Green
