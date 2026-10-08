# ANDROID_RELEASE.md — signed APK / AAB without exposing secrets

## 1. Identity (do not change without owner approval)

| Field | Value |
|---|---|
| Application ID | `com.vithey.aub_connect_app` |
| Application label | `Vithey` |
| versionName / versionCode | `1.0.0` / `1` (`pubspec.yaml` `version: 1.0.0+1`) |
| minSdk / targetSdk / compileSdk | 24 / 36 / 36 |
| AGP / Kotlin | 8.11.1 / 2.2.20 |

The application ID and namespace are fixed; changing either breaks upgrades.

## 2. Signing setup (owner keystore, outside git)

1. Generate an owner-controlled upload keystore **outside** the repository:

   ```powershell
   keytool -genkeypair -v -keystore D:\keys\vithey-upload.jks `
     -keyalg RSA -keysize 2048 -validity 10000 -alias vithey-upload
   ```

2. Copy `vithey_app/android/key.properties.example` to
   `vithey_app/android/key.properties` and fill it in. `storeFile` is resolved
   relative to `vithey_app/android/app/`; absolute paths also work.

   ```
   storePassword=...
   keyPassword=...
   keyAlias=vithey-upload
   storeFile=D:/keys/vithey-upload.jks
   ```

3. `key.properties`, `*.jks`, and `*.keystore` are git-ignored. Never commit
   them or the passwords. Back them up securely — losing the key blocks future
   updates to the same application ID.

When `key.properties` is absent, the release build falls back to debug signing
and prints a warning; such an artifact is for local smoke tests only and cannot
be published.

## 3. Build commands

Set the API for the build with `--dart-define` (release config forbids HTTP):

```powershell
cd vithey_app
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define=APP_ENV=production `
  --dart-define=API_BASE_URL=https://<production-api-host>/api/v1 `
  --dart-define=WS_BASE_URL=wss://<production-api-host>/ws
```

Per-ABI APKs (after the universal APK is verified):

```powershell
flutter build apk --release --split-per-abi --dart-define=APP_ENV=production `
  --dart-define=API_BASE_URL=https://<production-api-host>/api/v1
```

Play Store bundle:

```powershell
flutter build appbundle --release --dart-define=APP_ENV=production `
  --dart-define=API_BASE_URL=https://<production-api-host>/api/v1
```

`APP_ENV=production` makes `AppConfig` reject a non-HTTPS URL at startup, so a
misconfigured release fails fast instead of silently talking cleartext.

Artifacts:
- APK: `vithey_app/build/app/outputs/flutter-apk/app-release.apk`
- AAB: `vithey_app/build/app/outputs/bundle/release/app-release.aab`

## 4. Verify the artifact

```powershell
# SHA-256
Get-FileHash -Algorithm SHA256 build\app\outputs\flutter-apk\app-release.apk

# Signature / certificate
& "$env:LOCALAPPDATA\Android\Sdk\build-tools\36.1.0\apksigner.bat" verify --print-certs `
  build\app\outputs\flutter-apk\app-release.apk

# Manifest facts
& "$env:LOCALAPPDATA\Android\Sdk\build-tools\33.0.1\aapt.exe" dump badging `
  build\app\outputs\flutter-apk\app-release.apk
```

Confirm: `usesCleartextTraffic=false` in the merged release manifest (release
build type sets `manifestPlaceholders.usesCleartextTraffic = "false"`), correct
application ID, version code/name, and that no debug menu/logging is present.

## 5. Install / upgrade smoke

```powershell
adb install -r build\app\outputs\flutter-apk\app-release.apk
adb shell pm list packages | Select-String com.vithey.aub_connect_app
adb shell monkey -p com.vithey.aub_connect_app -c android.intent.category.LAUNCHER 1
```

A release build targeting a cleartext (HTTP) URL will launch but fail network
calls by design. Always ship a release pointed at an HTTPS API.

## 6. Local verification artifact (this pass)

A signed release APK was produced using a **locally generated verification
keystore** (not an owner key) because no owner signing material was supplied.
It validates the pipeline only; the owner must rebuild with their keystore
before distribution. See the Completion Report for path, SHA-256, and
certificate fingerprint.
