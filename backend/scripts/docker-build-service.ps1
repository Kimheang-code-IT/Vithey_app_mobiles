# Build or run a single Vithey microservice from its own folder.
# Usage:
#   .\scripts\docker-build-service.ps1 auth-service
#   .\scripts\docker-build-service.ps1 career-service -Up
#   .\scripts\docker-build-service.ps1 api-gateway -BuildOnly

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Service,

    [switch]$Up,
    [switch]$BuildOnly,
    [switch]$Down
)

$ErrorActionPreference = "Stop"
$backendRoot = Split-Path $PSScriptRoot -Parent

if ($Service -eq "ai-core") {
    Write-Host "ai-core is built from the monorepo root compose files." -ForegroundColor Cyan
    Write-Host "  cd backend; docker compose -f docker-compose.yml build ai-core" -ForegroundColor Green
    Write-Host "  or: .\scripts\docker-up-demo.ps1" -ForegroundColor Green
    exit 0
}

$serviceMap = @{
    "eureka-server"        = @{ Path = "infrastructure\eureka-server"; Port = 8761 }
    "config-server"        = @{ Path = "infrastructure\config-server"; Port = 8888 }
    "api-gateway"          = @{ Path = "services\api-gateway"; Port = 8080 }
    "auth-service"         = @{ Path = "services\auth-service"; Port = 8081 }
    "user-profile-service" = @{ Path = "services\user-profile-service"; Port = 8082 }
    "file-service"         = @{ Path = "services\file-service"; Port = 8083 }
    "content-service"      = @{ Path = "services\content-service"; Port = 8084 }
    "career-service"       = @{ Path = "services\career-service"; Port = 8085 }
    "finance-service"      = @{ Path = "services\finance-service"; Port = 8086 }
    "chat-service"         = @{ Path = "services\chat-service"; Port = 8087 }
    "notification-service" = @{ Path = "services\notification-service"; Port = 8088 }
    "map-service"          = @{ Path = "services\map-service"; Port = 8090 }
}

if (-not $serviceMap.ContainsKey($Service)) {
    Write-Host "Unknown service: $Service" -ForegroundColor Red
    Write-Host "Available: $($serviceMap.Keys -join ', ')"
    exit 1
}

$serviceDir = Join-Path $backendRoot $serviceMap[$Service].Path
if (-not (Test-Path (Join-Path $serviceDir "docker-compose.yml"))) {
    Write-Host "No docker-compose.yml in $serviceDir" -ForegroundColor Red
    exit 1
}

# Ensure shared Docker network exists
$networkExists = docker network inspect vithey-network 2>$null
if (-not $networkExists) {
    Write-Host "Creating vithey-network (start infrastructure for Postgres/Redis/...)..." -ForegroundColor Yellow
    docker network create vithey-network | Out-Null
}

Push-Location $serviceDir
try {
    if ($Down) {
        docker compose down
        exit $LASTEXITCODE
    }

    if ($BuildOnly) {
        docker compose build
    }
    elseif ($Up) {
        docker compose up -d --build
    }
    else {
        docker compose build
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Built $($serviceMap[$Service].Path). Start with: docker compose up -d" -ForegroundColor Green
            Write-Host "Or: .\scripts\docker-build-service.ps1 $Service -Up" -ForegroundColor Green
        }
    }

    if ($LASTEXITCODE -eq 0 -and ($Up -or $BuildOnly)) {
        $port = $serviceMap[$Service].Port
        Write-Host "Service folder: $serviceDir" -ForegroundColor Cyan
        Write-Host "Health: http://localhost:$port/actuator/health" -ForegroundColor Cyan
    }

    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
