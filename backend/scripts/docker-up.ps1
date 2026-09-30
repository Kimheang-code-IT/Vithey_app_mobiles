# Start full Vithey stack (infra + all microservices)
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

Write-Host "Starting Vithey full stack..." -ForegroundColor Cyan
docker compose up -d --build

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Stack is starting. Check status:" -ForegroundColor Green
Write-Host "  docker compose ps" -ForegroundColor Green
Write-Host "  Invoke-RestMethod http://localhost:8080/actuator/health" -ForegroundColor Green
Write-Host ""
Write-Host "Infra only:  cd infrastructure; docker compose up -d --build" -ForegroundColor DarkGray
Write-Host "One service: .\scripts\docker-build-service.ps1 auth-service -Up" -ForegroundColor DarkGray
