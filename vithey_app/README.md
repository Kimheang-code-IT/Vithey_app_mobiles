# Vithey App (Flutter)

AUB student mobile app — social feed, jobs, finance, chat, AI chatbot, notifications.

## Tech stack

- Flutter + GetX
- Dio (API via gateway `http://localhost:8080/api/v1`)
- Light + Dark theme

## Setup

### Clone and run (another machine)

```powershell
git clone <your-repo-url>
cd vithey_app
copy .env.example .env
flutter pub get
flutter emulators --launch Medium_Phone_API_36.1   # or plug in a phone
flutter run
```

**Still required on every machine (not in GitHub):**
- Flutter SDK (`flutter doctor` should be mostly green)
- JDK 17+ available on `PATH` / `JAVA_HOME` (do **not** hardcode a PC path in `gradle.properties`)
- Android SDK + an emulator **or** a physical Android phone with USB debugging
- On Windows: Developer Mode enabled (for Flutter plugin symlinks)

`.env` is gitignored. Always copy from `.env.example` after clone. Mock flags in `.env.example` mean UI works without a backend.

### Option A: VS Code (recommended — no Android Studio)

1. Install [VS Code](https://code.visualstudio.com/)
2. Install extensions (VS Code will prompt when you open this folder):
   - **Flutter** (`Dart-Code.flutter`)
   - **Dart** (`Dart-Code.dart-code`)
3. One-time SDK setup (Android Studio **not** required):

```powershell
cd "D:\project\Acleda Mobile App\vithey_app"
copy .env.example .env
flutter pub get
flutter doctor
```

If `flutter doctor` shows **cmdline-tools component is missing**, install command-line tools only:

1. Download [Android command-line tools](https://developer.android.com/studio#command-line-tools-only)
2. Extract and place at `%LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest\`
3. Set environment variable `ANDROID_HOME` = `%LOCALAPPDATA%\Android\Sdk`
4. Add to `Path`: `%ANDROID_HOME%\platform-tools` and `%ANDROID_HOME%\cmdline-tools\latest\bin`
5. Run `.\scripts\setup-android-sdk.ps1` to accept licenses and install packages

### Run from VS Code

1. **Enable Windows Developer Mode** (required for Flutter plugins/symlinks):
   - Open `ms-settings:developers` → turn on **Developer Mode**
2. Start the Android emulator:

```powershell
flutter emulators --launch Medium_Phone_API_36.1
```

2. In VS Code: **Run and Debug** (F5) → choose **Vithey (Android emulator)**

Or from terminal:

```powershell
cd "D:\project\Acleda Mobile App\vithey_app"
flutter run
```

> **Note:** This is a mobile app (Isar, secure storage, camera, etc.). Chrome/web is **not** supported. Use Android emulator or a physical Android device.

### Option B: Terminal only

```powershell
cd "D:\project\Acleda Mobile App\vithey_app"
copy .env.example .env
flutter pub get
flutter emulators --launch Medium_Phone_API_36.1
flutter run
```

### UI-only development (no backend)

The default `.env.example` is set up for mock data so the Flutter UI can run without the backend. Login/register accepts any email and password, and the repositories serve mock feed, profile, finance, chat, notifications, search, and AI data.

```env
APP_ENV=dev
API_BASE_URL=http://10.0.2.2:8080/api/v1
USE_MOCK_AUTH=true
USE_MOCK_API=true
USE_MOCK_CHAT=true
USE_MOCK_NOTIFICATIONS=true
USE_MOCK_SEARCH=true
USE_MOCK_AI=true
```

### Real API testing

Keep the API integration code unchanged and switch `.env` flags when testing against the gateway:

```env
USE_MOCK_AUTH=false
USE_MOCK_API=false
USE_MOCK_CHAT=false
USE_MOCK_NOTIFICATIONS=false
USE_MOCK_SEARCH=false
USE_MOCK_AI=false
```

For Android emulator API calls, use `10.0.2.2` instead of `localhost`:

```env
API_BASE_URL=http://10.0.2.2:8080/api/v1
WS_BASE_URL=ws://10.0.2.2:8080/ws
```

### Physical device on same Wi‑Fi

Use your PC LAN IP instead of `localhost`.

## Project structure

```text
lib/
  core/       # theme, network, storage, reusable widgets
  data/       # models, repositories, services
  modules/    # one folder per screen/feature
  routes/     # GetX pages
```

## Build order (from prompts)

1. ✅ Foundation (`docs/Prompt Frontend/Screen prompt/00-foundation-prompt.md`)
2. ✅ Auth flow (`auth/01-splash` → `09-startup-3`)
3. ✅ Media feed — Home, poster/video/job cards, comments, share, create post
4. ✅ Post detail — full post, comments, @mentions, video player, Apply CV
5. ✅ Profile — shell, All/Reels/Posters/Jobs tabs, applicants, CV preview
6. ✅ Upload CV — job context, file picker, saved CV, submit pipeline
7. ✅ Finance — verification form/status, Finance Home, invoice preview
8. ✅ Chat — conversation list, message thread, participant profile
9. ✅ Chatbot — Vithey AI shell, history drawer, composer, responses
10. ✅ Notifications — inbox, All/Unread filters, action sheet, routing
11. ✅ Settings — home, account, privacy, security, change password, help, about

## Backend

Ensure Docker backend is running:

```powershell
cd "D:\project\Acleda Mobile App\backend"
.\scripts\verify-docker.ps1
```
