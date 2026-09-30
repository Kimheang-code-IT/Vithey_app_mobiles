# Host-run dev mode: run infra in Docker, selected Spring Boot services on the host.
#
# Why: fewer container JVMs, much faster iteration, and per-service heaps/logs.
#
#   .\scripts\start-dev-host.ps1
#   .\scripts\start-dev-host.ps1 -Services auth-service,user-profile-service,api-gateway
#   .\scripts\start-dev-host.ps1 -Heap 128m
#   .\scripts\start-dev-host.ps1 -SkipInfra        # infra already running
#   .\scripts\start-dev-host.ps1 -Down             # stop infra containers
#
# Each service opens in its own PowerShell window (close the window to stop it).
param(
    [string[]]$Services = @("auth-service", "user-profile-service", "api-gateway"),
    [string]$Heap = "160m",
    [switch]$SkipInfra,
    [switch]$Down
)

$ErrorActionPreference = "Stop"
$backend = Split-Path -Parent $PSScriptRoot
Set-Location $backend

$infraArgs = @("-f", "docker-compose.yml", "-f", "docker-compose.demo.yml")
$infraServices = @("postgres", "redis", "rabbitmq", "minio", "eureka-server", "config-server")

if ($Down) {
    Write-Host "Stopping host-dev infra..." -ForegroundColor Yellow
    docker compose @infraArgs stop @infraServices
    exit $LASTEXITCODE
}

# DB env var + database name per service (host port 15432).
$dbVar = @{
    "auth-service"         = @("AUTH_DB_URL", "auth_db")
    "user-profile-service" = @("USER_DB_URL", "user_db")
    "file-service"         = @("FILE_DB_URL", "file_db")
    "content-service"      = @("CONTENT_DB_URL", "content_db")
    "career-service"       = @("CAREER_DB_URL", "career_db")
    "finance-service"      = @("FINANCE_DB_URL", "finance_db")
    "chat-service"         = @("CHAT_DB_URL", "chat_db")
    "notification-service" = @("NOTIFICATION_DB_URL", "notification_db")
    "map-service"          = @("MAP_DB_URL", "map_db")
}

$commonEnv = [ordered]@{
    CONFIG_SERVER_URL       = "http://localhost:8888"
    EUREKA_URL              = "http://localhost:8761/eureka/"
    EUREKA_CLIENT_ENABLED   = "true"
    VITHEY_JWT_SECRET       = "change-me-to-a-strong-256-bit-secret-for-local-dev"
    RABBITMQ_HOST           = "localhost"
    RABBITMQ_PORT           = "5672"
    RABBITMQ_USERNAME       = "guest"
    RABBITMQ_PASSWORD       = "guest"
    REDIS_HOST              = "localhost"
    REDIS_PORT              = "6379"
    MINIO_ENDPOINT          = "http://localhost:19000"
    MINIO_PUBLIC_ENDPOINT   = "http://localhost:19000"
    MINIO_ACCESS_KEY        = "minioadmin"
    MINIO_SECRET_KEY        = "minioadmin"
    MINIO_BUCKETS           = "avatars,cvs,posters,videos"
}

if (-not $SkipInfra) {
    Write-Host "Starting infra in Docker (postgres, redis, rabbitmq, minio, eureka, config)..." -ForegroundColor Cyan
    docker compose @infraArgs up -d @infraServices
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host "Waiting for config-server + eureka..." -ForegroundColor DarkGray
    foreach ($url in @("http://localhost:8888/actuator/health", "http://localhost:8761/actuator/health")) {
        for ($i = 0; $i -lt 60; $i++) {
            try { if ((Invoke-RestMethod -Uri $url -TimeoutSec 3).status -eq "UP") { break } } catch {}
            Start-Sleep -Seconds 3
        }
    }
}

$tmpDir = Join-Path $env:TEMP "vithey-dev"
New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null
$jvm = "-Xms64m -Xmx$Heap -XX:+UseSerialGC -XX:MaxMetaspaceSize=96m -Dspring.jmx.enabled=false"

foreach ($svc in $Services) {
    $lines = @("`$host.UI.RawUI.WindowTitle = 'vithey/$svc'")
    foreach ($k in $commonEnv.Keys) { $lines += "`$env:$k='$($commonEnv[$k])'" }
    if ($dbVar.ContainsKey($svc)) {
        $v, $dbName = $dbVar[$svc]
        $lines += "`$env:$v='jdbc:postgresql://localhost:15432/$dbName'"
        $lines += "`$env:${v}_USERNAME='postgres'"
        $lines += "`$env:${v}_PASSWORD='postgres'"
    }
    $lines += "Write-Host 'Starting $svc (heap $Heap)...' -ForegroundColor Green"
    $lines += "mvn -f services/$svc/pom.xml spring-boot:run '-Dspring-boot.run.jvmArguments=$jvm'"

    $scriptPath = Join-Path $tmpDir "run-$svc.ps1"
    Set-Content -Path $scriptPath -Value $lines -Encoding UTF8

    $portHint = switch ($svc) {
        "api-gateway" { "http://localhost:8080" }
        default { "" }
    }
    Write-Host "Launching $svc $portHint" -ForegroundColor Green
    Start-Process powershell -ArgumentList @("-NoExit", "-ExecutionPolicy", "Bypass", "-File", $scriptPath) -WorkingDirectory $backend
}

Write-Host ""
Write-Host "Services launched in separate windows. Close a window to stop that service." -ForegroundColor Green
Write-Host "Stop infra: .\scripts\start-dev-host.ps1 -Down" -ForegroundColor DarkGray
if ($Services -contains "api-gateway") {
    Write-Host "Gateway: http://localhost:8080/actuator/health" -ForegroundColor DarkGray
}
