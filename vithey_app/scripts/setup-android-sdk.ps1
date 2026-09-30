# Install Android SDK command-line tools (no Android Studio required)
# Run in PowerShell: .\scripts\setup-android-sdk.ps1

$ErrorActionPreference = "Stop"

$sdkRoot = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { "$env:LOCALAPPDATA\Android\Sdk" }
$cmdlineRoot = Join-Path $sdkRoot "cmdline-tools\latest"
$sdkmanager = Join-Path $cmdlineRoot "bin\sdkmanager.bat"

Write-Host "Android SDK root: $sdkRoot"

if (-not (Test-Path $sdkmanager)) {
    Write-Host ""
    Write-Host "Command-line tools are missing. Install them once (no Android Studio needed):" -ForegroundColor Yellow
    Write-Host "1. Download: https://developer.android.com/studio#command-line-tools-only"
    Write-Host "2. Extract the zip to a temp folder"
    Write-Host "3. Move the inner 'cmdline-tools' folder to:"
    Write-Host "   $sdkRoot\cmdline-tools\latest"
    Write-Host ""
    Write-Host "Expected file: $sdkmanager"
    Write-Host ""
    Write-Host "Then set environment variables (User or System):"
    Write-Host "  ANDROID_HOME = $sdkRoot"
    Write-Host "  Path += $sdkRoot\platform-tools"
    Write-Host "  Path += $sdkRoot\cmdline-tools\latest\bin"
    Write-Host ""
    exit 1
}

Write-Host "Accepting SDK licenses..."
& $sdkmanager --licenses

Write-Host "Installing required SDK packages..."
& $sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"

Write-Host ""
Write-Host "Done. Verify with: flutter doctor" -ForegroundColor Green
Write-Host "Launch emulator: flutter emulators --launch Medium_Phone_API_36.1"
Write-Host "Run app: flutter run"
