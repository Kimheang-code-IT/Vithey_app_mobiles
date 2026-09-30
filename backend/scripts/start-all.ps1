param(
    [switch]$SkipBuild,
    [switch]$Down,
    [switch]$Logs,
    [switch]$InfraOnly
)

$ErrorActionPreference = "Stop"
$backend = Split-Path -Parent $PSScriptRoot

Set-Location $backend

function Wait-ForHealth {
    param(
        [string]$Url,
        [int]$MaxAttempts = 60,
        [int]$DelaySeconds = 5
    )

    for ($i = 0; $i -lt $MaxAttempts; $i++) {
        try {
            $health = Invoke-RestMethod -Uri $Url -TimeoutSec 3 -ErrorAction Stop
            if ($health.status -eq "UP") {
                return $true
            }
        } catch {
            Start-Sleep -Seconds $DelaySeconds
        }
    }

    return $false
}

if ($Logs) {
    Write-Host "=== Vithey stack logs (last 80 lines) ===" -ForegroundColor Cyan
    docker compose logs --tail 80
    exit $LASTEXITCODE
}

if ($Down) {
    Write-Host "Stopping Vithey full stack..." -ForegroundColor Yellow
    docker compose down
    exit $LASTEXITCODE
}

if ($InfraOnly) {
    Write-Host "Starting infrastructure only..." -ForegroundColor Green
    Set-Location (Join-Path $backend "infrastructure")
    if ($SkipBuild) {
        docker compose up -d
    } else {
        docker compose up -d --build
    }
    exit $LASTEXITCODE
}

Write-Host "Starting Vithey full stack (infra + all services)..." -ForegroundColor Green
Write-Host "First build can take several minutes." -ForegroundColor DarkGray

if ($SkipBuild) {
    docker compose up -d
} else {
    docker compose up -d --build
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "docker compose up failed" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Waiting for Eureka / Config / Gateway..." -ForegroundColor Cyan
$eurekaReady = Wait-ForHealth -Url "http://localhost:8761/actuator/health" -MaxAttempts 36
$configReady = Wait-ForHealth -Url "http://localhost:8888/actuator/health" -MaxAttempts 36
$gatewayReady = Wait-ForHealth -Url "http://localhost:8080/actuator/health" -MaxAttempts 72

Write-Host ""
Write-Host "=== Vithey stack status ===" -ForegroundColor Green
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

Write-Host ""
if ($eurekaReady) {
    Write-Host "Eureka:   http://localhost:8761  [UP]" -ForegroundColor Green
} else {
    Write-Host "Eureka:   still starting — docker compose logs eureka-server" -ForegroundColor Yellow
}

if ($configReady) {
    Write-Host "Config:   http://localhost:8888  [UP]" -ForegroundColor Green
} else {
    Write-Host "Config:   still starting — docker compose logs config-server" -ForegroundColor Yellow
}

if ($gatewayReady) {
    Write-Host "Gateway:  http://localhost:8080/actuator/health  [UP]" -ForegroundColor Green
} else {
    Write-Host "Gateway:  still starting — docker compose logs api-gateway" -ForegroundColor Yellow
}

Write-Host "RabbitMQ: http://localhost:15672  (guest/guest)"
Write-Host "MinIO:    http://localhost:19001  (minioadmin/minioadmin)"
Write-Host "Postgres: localhost:15432"
Write-Host "Redis:    localhost:16379"
Write-Host ""
Write-Host "Logs:     .\scripts\start-all.ps1 -Logs"
Write-Host "Stop:     .\scripts\start-all.ps1 -Down"
Write-Host "Infra:    .\scripts\start-all.ps1 -InfraOnly"
