# Cap Docker Desktop (WSL2 backend) memory/CPU so containers cannot starve the host.
#
#   .\scripts\set-docker-limits.ps1
#   .\scripts\set-docker-limits.ps1 -Memory 8GB -Processors 6
#
# Writes %UserProfile%\.wslconfig (backing up any existing file) and shuts WSL
# down so the new limits take effect. Restart Docker Desktop afterwards.
param(
    [string]$Memory = "6GB",
    [int]$Processors = 4,
    [string]$Swap = "2GB"
)

$ErrorActionPreference = "Stop"

$target = Join-Path $env:USERPROFILE ".wslconfig"

if (Test-Path $target) {
    $backup = "$target.bak-$(Get-Date -Format yyyyMMddHHmmss)"
    Copy-Item -LiteralPath $target -Destination $backup -Force
    Write-Host "Existing .wslconfig backed up to $backup" -ForegroundColor DarkYellow
}

$content = @"
# Managed by Vithey backend/scripts/set-docker-limits.ps1
[wsl2]
memory=$Memory
processors=$Processors
swap=$Swap

[experimental]
autoMemoryReclaim=gradual
sparseVhd=true
"@

# UTF8 without BOM (WSL parses this file strictly).
$utf8 = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($target, $content, $utf8)

Write-Host "Wrote $target (memory=$Memory, processors=$Processors, swap=$Swap)" -ForegroundColor Green

Write-Host "Applying (wsl --shutdown)..." -ForegroundColor Cyan
wsl --shutdown 2>$null

Write-Host ""
Write-Host "Done. Restart Docker Desktop, then verify with:" -ForegroundColor Green
Write-Host "  docker info --format '{{.MemTotal}}'" -ForegroundColor Green
Write-Host "Remove the cap later by deleting $target and running: wsl --shutdown" -ForegroundColor DarkGray
