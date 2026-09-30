# Start Vithey Profile M demo stack (env-tunable caps + external-services/ai-core; map is opt-in)
#
# Usage (from backend/):
#   copy .env.example .env        # then tune resource knobs
#   .\scripts\docker-up-demo.ps1
#   .\scripts\docker-up-demo.ps1 -Profiles map            # also start map-service
#   .\scripts\docker-up-demo.ps1 -Services auth-service,user-profile-service,api-gateway
#
# Subset mode starts only the listed services (+ their infra deps). Anything not
# started returns 503 at the gateway, so start what the feature you test needs.
param(
    [string]$Profiles = "",
    [string[]]$Services = @()
)

$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

$aiEnv = Join-Path (Resolve-Path "..\external-services\ai-core") ".env"
if (-not (Test-Path $aiEnv)) {
  Write-Host "Missing external-services/ai-core/.env - copy .env.example and set DEEPSEEK_API_KEY" -ForegroundColor Red
  exit 1
}

if (-not (Test-Path (Join-Path (Get-Location) ".env"))) {
  Write-Host "backend/.env not found - using built-in defaults. Copy .env.example to tune limits." -ForegroundColor DarkYellow
}

if ($Profiles) {
  $env:COMPOSE_PROFILES = $Profiles
  Write-Host "COMPOSE_PROFILES=$Profiles" -ForegroundColor DarkGray
}

$composeArgs = @("-f", "docker-compose.yml", "-f", "docker-compose.demo.yml", "up", "-d", "--build")
if ($Services.Count -gt 0) {
  Write-Host "Subset mode: $($Services -join ', ')" -ForegroundColor DarkGray
  $composeArgs += $Services
}

Write-Host "Starting Vithey DEMO stack (Profile M)..." -ForegroundColor Cyan
docker compose @composeArgs

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Demo stack is starting. Check:" -ForegroundColor Green
Write-Host "  docker compose -f docker-compose.yml -f docker-compose.demo.yml ps" -ForegroundColor Green
Write-Host "  Invoke-RestMethod http://localhost:8080/actuator/health" -ForegroundColor Green
Write-Host "  Invoke-RestMethod http://localhost:8100/health" -ForegroundColor Green
Write-Host ""
Write-Host "Optional: -Profiles map (map-service), COMPOSE_PROFILES=map in backend/.env" -ForegroundColor DarkGray
Write-Host "Docs: DEMO.md" -ForegroundColor DarkGray
