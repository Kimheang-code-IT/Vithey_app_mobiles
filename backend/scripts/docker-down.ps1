# Stop full Vithey stack (or pass -v to remove volumes)
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

Write-Host "Stopping Vithey full stack..." -ForegroundColor Cyan
docker compose down @args

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Stopped. Infra-only leftover? cd infrastructure; docker compose down" -ForegroundColor DarkGray
