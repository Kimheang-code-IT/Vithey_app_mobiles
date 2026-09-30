# Verify Vithey Docker stack (Profile M - no GDCE)
$ErrorActionPreference = "Continue"

$infra = @(
    "vithey-eureka-server",
    "vithey-config-server",
    "vithey-postgres",
    "vithey-redis",
    "vithey-rabbitmq",
    "vithey-minio"
)

$services = @(
    "vithey-auth-service",
    "vithey-user-profile-service",
    "vithey-file-service",
    "vithey-content-service",
    "vithey-career-service",
    "vithey-finance-service",
    "vithey-chat-service",
    "vithey-notification-service",
    "vithey-api-gateway",
    "vithey-ai-core"
)

# Opt-in via COMPOSE_PROFILES=map (docker-up-demo.ps1 -Profiles map)
$demoOptional = @(
    "vithey-map-service"
)

function Test-ContainerRunning($name) {
    $state = docker inspect -f "{{.State.Status}}" $name 2>$null
    if ($state -eq "running") {
        Write-Host "[OK]   $name" -ForegroundColor Green
        return $true
    }
    Write-Host "[FAIL] $name (status: $state)" -ForegroundColor Red
    return $false
}

function Test-ContainerOptional($name) {
    $state = docker inspect -f "{{.State.Status}}" $name 2>$null
    if ($state -eq "running") {
        Write-Host "[OK]   $name (demo)" -ForegroundColor Green
        return $true
    }
    Write-Host "[SKIP] $name (not running - start with -Profiles map)" -ForegroundColor DarkYellow
    return $false
}

function Test-Http($label, $url, $pattern) {
    try {
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
        if ($resp.Content -match $pattern -or $resp.StatusCode -eq 200) {
            Write-Host "[OK]   $label" -ForegroundColor Green
            return $true
        }
        Write-Host "[FAIL] $label (unexpected response)" -ForegroundColor Red
        return $false
    } catch {
        Write-Host "[FAIL] $label ($($_.Exception.Message))" -ForegroundColor Red
        return $false
    }
}

function Test-HttpOptional($label, $url, $pattern) {
    try {
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
        if ($resp.Content -match $pattern -or $resp.StatusCode -eq 200) {
            Write-Host "[OK]   $label (demo)" -ForegroundColor Green
            return $true
        }
        Write-Host "[SKIP] $label (unexpected response)" -ForegroundColor DarkYellow
        return $false
    } catch {
        Write-Host "[SKIP] $label (not up - demo overlay)" -ForegroundColor DarkYellow
        return $false
    }
}

Write-Host "`n=== Infrastructure ===" -ForegroundColor Cyan
$ok = 0
foreach ($c in $infra) { if (Test-ContainerRunning $c) { $ok++ } }

Write-Host "`n=== Microservices ===" -ForegroundColor Cyan
foreach ($c in $services) { if (Test-ContainerRunning $c) { $ok++ } }

Write-Host "`n=== Demo optional (map) ===" -ForegroundColor Cyan
$demoOk = 0
foreach ($c in $demoOptional) { if (Test-ContainerOptional $c) { $demoOk++ } }

Write-Host "`n=== Health endpoints ===" -ForegroundColor Cyan
$healthOk = 0
$healthRequired = 4
if (Test-Http "Eureka" "http://localhost:8761/actuator/health" '"status"') { $healthOk++ }
if (Test-Http "Gateway" "http://localhost:8080/actuator/health" '"status"') { $healthOk++ }
if (Test-Http "Auth" "http://localhost:8081/actuator/health" '"status"') { $healthOk++ }
if (Test-Http "ai_core" "http://localhost:8100/health" "healthy|status") { $healthOk++ }
$demoHealth = 0
if (Test-HttpOptional "map-service" "http://localhost:8090/actuator/health" '"status"') { $demoHealth++ }

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
$requiredTotal = $infra.Count + $services.Count
Write-Host "Required containers OK: $ok / $requiredTotal"
Write-Host "Demo containers OK: $demoOk / $($demoOptional.Count)"
Write-Host "Required health checks: $healthOk / $healthRequired"
Write-Host "Demo health checks: $demoHealth / 1"
Write-Host ""

if ($healthOk -eq $healthRequired -and $ok -eq $requiredTotal) {
    Write-Host "Core stack looks healthy." -ForegroundColor Green
    if ($demoOk -lt $demoOptional.Count) {
        Write-Host "map-service not running (optional) - start with -Profiles map." -ForegroundColor Yellow
    }
    exit 0
}

Write-Host "Some required checks failed. See prompt/Prompt Devops/DOCKER-VERIFY.md for fixes." -ForegroundColor Yellow
exit 1