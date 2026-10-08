# PROJECT_AUDIT.md — Vithey / AUB Connect

Baseline audit produced by the completion-plan workflow (Phase 0 + Phase 1).
All statements below are backed by command output run in this workspace on
2026-10-07. No success is claimed without evidence.

## 1. Repository inventory (Phase 0)

- Repo root: `D:\project\Acleda Mobile App` (git repo).
- Branch: `dev`, tracking `origin/dev`.
- Remote: `https://github.com/Kimheang-code-IT/Vithey_app_mobiles.git`
- Current revision: `441ed19` (docs(features): add Auth - Email/password authentication feature documentation (#50)).
- The plan's preamble ("only an empty `.git` directory") is **out of date**; real
  backend, Flutter, Python, monitoring, docs and CI sources are present.

Working-tree state at audit time (preserved, not reverted):

```
## dev...origin/dev
 M CONTRIBUTING.md
 M backend/docker-compose.demo.yml
 M backend/docker-compose.yml
 M backend/services/auth-service/src/main/resources/application.yml
D  backend/services/career-service/src/main/resources/db/migration/V3__User_cv_file_unique_and_application_fk.sql
 M docs/Action_Plan_Vithey.csv
 M vithey_app/android/build.gradle
?? docs/Action_Plan_Vithey.original.csv
?? docs/DEEPSEEK_PRODUCT_COMPLETION_PLAN.md
```

These pre-existing edits are legitimate (AI-core env de-duplication, mail health
tolerance, Android compileSdk alignment) and were left intact.

## 2. Technology inventory (verified versions)

| Area | Technology / version (observed) |
|---|---|
| Backend | Java 21 (Temurin 21.0.11), Spring Boot 3.3.5, Spring Cloud 2023.0.3, Maven 3.9.11 |
| Backend layout | Maven multi-module monorepo, 10 microservices + Eureka + Config Server + shared test support |
| Services | api-gateway(:8080), auth(:8081), user-profile(:8082), file(:8083), content(:8084), career(:8085), finance(:8086), chat(:8087), notification(:8088), map(:8090) |
| Data | PostgreSQL 16, Redis 7, RabbitMQ, MinIO |
| AI / Payment | Python 3.12 FastAPI — `ai-core` (:8100), `fake-payment-service` (:8090 in-container / :8110 host) |
| Flutter | Flutter 3.44.5, Dart 3.12.2 |
| Flutter stack | GetX (state/DI/routing), Dio (networking), Isar (local chat), flutter_secure_storage, shadcn_flutter, google_sign_in, google_maps_flutter, stomp_dart_client |
| Android | AGP 8.11.1, Kotlin 2.2.20, compileSdk/targetSdk 36, minSdk from Flutter, namespace `com.vithey.aub_connect_app`, applicationId `com.vithey.aub_connect_app`, version 1.0.0+1 |
| Signing | release buildType currently `signingConfigs.debug` (see P1-B) |
| Docker | Docker 29.8.1; full stack already running and healthy |
| adb | not on PATH |

### Baseline build/test evidence (before edits)

| Check | Command | Result |
|---|---|---|
| Backend tests | `mvn -B -f backend/pom.xml test` | **BUILD SUCCESS**, 14/14 modules, 0 failures/errors. Per-module totals incl. api-gateway 27, content 14, career 10, finance 11, map 26, notification 8, etc. |
| Flutter analyze | `flutter analyze --no-fatal-infos` | **No issues found** (20.5 s) |
| Flutter tests | `flutter test` | **All tests passed** (+23) |
| Live stack | `docker ps` | All containers healthy |
| E2E auth (gateway) | register→login→me→refresh→logout via `http://localhost:8080/api/v1` | register 201/OK, login OK, me OK, refresh rotated OK, logout 204, refresh-after-logout 401, refresh-reuse 401 |

## 3. Architecture summary

- Single entry point `api-gateway` validates JWT (HS256, `vithey.jwt.secret`) and
  forwards `X-User-Id` / `X-User-Roles` / `X-User-Email` downstream.
- Public gateway paths: `/api/v1/auth/{register,login,google,refresh,forgot-password,reset-password,verify-email}`, actuator, swagger.
- Envelope: `{ "data": ..., "error": { code, message, details } }` (Jackson
  `SNAKE_CASE`, NON_NULL). Flutter `ApiResponse`/`ApiError` match.
- Auth: HS256 access token TTL 15m; opaque refresh token TTL 7d, single-use
  rotation + revocation (verified). BCrypt password hashing.
- API prefix `/api/v1`. AI calls are proxied by gateway to Python `ai-core`.

## 4. Findings

Severity: P0 Blocker / P1 Critical / P2 Major / P3 Minor.

### P1-A — Release build ignores `--dart-define` URLs; defaults to an emulator cleartext URL
- Component: Flutter config.
- File/line: `vithey_app/lib/core/config/app_config.dart:46-62`.
- Observed: only `APP_ENV` is read via `String.fromEnvironment`; `API_BASE_URL`
  and `WS_BASE_URL` come solely from the **bundled `.env` asset**
  (`vithey_app/pubspec.yaml:59`). The checked-in `.env` points at
  `http://10.0.2.2:8080/api/v1`.
- Expected: release builds must target the production HTTPS API selected at
  build time (`--dart-define=API_BASE_URL=...`), validated at startup.
- Evidence: `grep fromEnvironment` returns only the `APP_ENV` define; no
  `API_BASE_URL` define is consumed anywhere. `flutter build apk --release`
  would embed the emulator cleartext URL while release sets
  `usesCleartextTraffic=false` (`android/app/build.gradle:69`), so the released
  app cannot reach any backend.
- Proposed fix: read compile-time define first, then dotenv, then a safe
  default; fail fast in production when missing/non-HTTPS.
- Dependencies: none.
- Verification: unit test on `AppConfig` override resolution + release build
  with `--dart-define`; inspect merged manifest / app config.

### P1-B — Release APK is signed with the debug keystore
- Component: Android build.
- File/line: `vithey_app/android/app/build.gradle:65-70`.
- Observed: `release { signingConfig signingConfigs.debug }`.
- Expected: release signed with an owner-controlled upload keystore referenced
  from a git-ignored `android/key.properties`; example file with placeholders.
- Evidence: file content above; no `key.properties`, `.jks` or `.keystore`
  exists in the repo (search returned none).
- Proposed fix: load `key.properties` when present and use a release signing
  config; fall back to debug only when absent (with a clear warning); add
  `key.properties.example`; git-ignore `key.properties`.
- Dependencies: P1-A for a meaningful production build.
- Verification: `flutter build apk --release` + `apksigner verify`.

### P1-C — Concurrent 401s can trigger a refresh-token race
- Component: Flutter network layer.
- File/line: `vithey_app/lib/core/network/dio_client.dart:49-63,70-93`.
- Observed: every 401 whose path is not a public auth path independently calls
  `POST /auth/refresh`. The backend rotates and **revokes** the old refresh
  token (verified: `REFRESH-REUSE rejected 401`,
  `REFRESH-AFTER-LOGOUT rejected 401`). Two parallel requests therefore race:
  the first rotation invalidates the token the second is using; the loser
  invokes `clearTokens()`, unexpectedly logging the user out.
- Expected: single-flight refresh; all waiters reuse one result; no redundant
  refresh and no forced logout on a benign race.
- Evidence: backend behavior confirmed E2E via gateway; client code path above.
- Proposed fix: guard refresh with a shared `Future<bool>?` in `DioClient`.
- Dependencies: none.
- Verification: widget/unit test with concurrent 401s (single refresh call).

### P2-A — Startup config has no fail-fast validation and hard-fails if `.env` is absent
- Component: Flutter config.
- File/line: `vithey_app/lib/core/config/app_config.dart:41-44`.
- Observed: `dotenv.load(fileName: '.env')` throws when the asset is missing
  (clean checkout before `cp .env.example .env`); no validation that a
  production URL is HTTPS/absolute.
- Expected: tolerant load + clear validation error in production.
- Proposed fix: wrap load in try/catch; validate scheme/host in production.
- Verification: `AppConfig.init` unit tests.

### P2-B — Gateway does not strip client-supplied identity headers
- Component: Backend gateway.
- File/line: `vithey_app/...` N/A; `backend/services/api-gateway/src/main/java/com/vithey/gateway/filter/UserHeaderForwardFilter.java` (no-op) and
  `JwtAuthenticationGlobalFilter.java:52-61`.
- Observed: the JWT filter sets `X-User-*` for authenticated requests, but
  public requests pass through untouched and no filter removes inbound
  `X-User-*` headers. Downstream services trust `X-User-Id`.
- Expected: strip all inbound `X-User-*` at the gateway (defense in depth) so a
  client can never inject an identity.
- Proposed fix: implement the passthrough filter as a request-header sanitizer.
- Verification: gateway unit test + curl with forged header returns token-derived id.

### P2-C — CORS defaults to `*`
- Component: Backend gateway.
- File/line: `backend/infrastructure/config-repo/api-gateway.yml:176`
  (`VITHEY_CORS_ALLOWED_ORIGINS:*`) and `CorsConfig.java:18`.
- Observed: wildcard origin patterns by default (`allowCredentials=false`, so no
  cookie risk). Mobile clients do not use CORS.
- Expected: restrict to intended web origins in production via env var.
- Proposed fix: document/validate; keep dev default only for non-prod.
- Verification: config check.

### P3-A — `.env` is bundled as a Flutter asset
- `vithey_app/pubspec.yaml:59`. Embeds environment config in the binary. After
  the P1-A fix, release must not depend on it; document `.env` as dev-only.
- No secrets are present in `vithey_app/.env` (public values only).

### P3-B — Access tokens remain valid until expiry after logout
- Logout revokes the refresh token only (`AuthController.logout`); the stateless
  JWT stays valid ≤15m. Acceptable given short TTL; documented mitigation.

### P3-C — Development JWT secret placeholder
- `VITHEY_JWT_SECRET` defaults to a placeholder in `.env.example` and compose.
  Production must override with a ≥256-bit random secret (documented in
  `docs/DEPLOYMENT.md`).

## 5. Frontend-to-backend endpoint mapping

Complete mapping is maintained in `docs/API_INTEGRATION_MATRIX.md`. At baseline
every `lib/core/constants/api_endpoints.dart` constant resolves to a real
backend route and every request/response field name agrees under the backend's
`SNAKE_CASE` Jackson strategy. No missing route and no schema mismatch was
found. Client `auth/me` and profile `users/me` are intentionally distinct.

## 6. Disposition plan (dependency order)

1. P1-A + P2-A (Flutter env/config) — unblocks release environment.
2. P1-C (refresh single-flight) — reliability.
3. P1-B (release signing) — unblocks signed APK gate.
4. P2-B, P2-C (gateway hardening) — security.
5. P3 documentation.

Phase 3 changes and Phase 4–6 verification evidence are appended below.

## 7. Disposition (updated after fixes)

| ID | Severity | Status | Fix / evidence |
|---|---|---|---|
| P1-A | P1 | FIXED | `app_config.dart` now resolves `API_BASE_URL`/`WS_BASE_URL`/timeouts from `--dart-define` first, then `.env`, then default; production requires HTTPS. See Appendix. |
| P1-B | P1 | FIXED (local key) | `android/app/build.gradle` release signing via `key.properties`; `key.properties.example` added; `.gitignore` updated. Local verification key used (owner must replace). |
| P1-C | P1 | FIXED | `dio_client.dart` single-flight refresh. |
| P2-A | P2 | FIXED | Tolerant dotenv load + prod validation. |
| P2-B | P2 | FIXED | `UserHeaderForwardFilter` now strips inbound `X-User-*`. |
| P2-C | P2 | MITIGATED/DOCUMENTED | `docs/DEPLOYMENT.md` requires `VITHEY_CORS_ALLOWED_ORIGINS` in prod. |
| P3-A | P3 | DOCUMENTED | `.env` is dev-only; release uses `--dart-define`. |
| P3-B | P3 | ACCEPTED | 15m TTL; documented. |
| P3-C | P3 | DOCUMENTED | `docs/DEPLOYMENT.md` secret requirements. |

### Findings discovered during Phase 4 E2E / manual testing

| ID | Severity | Status | Fix / evidence |
|---|---|---|---|
| D-1 | P1 | FIXED | Demo stack set Postgres `max_connections=40` while 10 services × `DB_POOL_MAX=5` (+ ai-core, Flyway) exceeded it → "FATAL: too many clients already", causing 503/500 on `/users/me`, `POST /posts`, `/ai/*`, `/message-requests`. Raised `PG_MAX_CONNECTIONS` default to 100 in `backend/docker-compose.demo.yml`, `backend/.env.example`, `backend/.env`; recreated Postgres. `smoke-api.ps1` went 21 PASS/11 FAIL → **34 PASS/0 FAIL**. |
| D-2 | P2 | FIXED | `StudentVerificationRepository` constructor eagerly called authenticated `GET /auth/me` before any session existed → unhandled Dart exception `Missing or invalid token` on fresh app start (logcat). Now skips the sync until an access token exists and catches failures. Verified: relaunch logcat shows no unhandled exception. |
| D-3 | P1 | BLOCKED | `map-service` not running and `GOOGLE_PLACES_API_KEY` unset → `/api/v1/places/**` returns 503; Places/Map cannot be tested. Owner must supply a Google Places API key and start the `map` profile. |
| D-4 | P1 | FIXED | Most running images predated later commits (e.g. content-service image built 2026-09-30 13:30, but `PATCH /posts/{id}` merged 15:41) → `PATCH /posts/{id}` returned 500 `Request method 'PATCH' is not supported`. Fixed by rebuilding all images from current source (`docker compose ... build`) and recreating the stack; PATCH now returns 403/200 correctly. |
| D-5 | P1 | PARTIAL | Google Sign-In wired end-to-end using the owner-supplied **Web client ID** (`GOOGLE_WEB_CLIENT_ID` in `backend/.env` + `vithey_app/.env`, `ENABLE_GOOGLE_AUTH=true`). Backend now returns 401 for a dummy token (configured) instead of "not configured". Interactive login still requires: (a) an Android OAuth client for `com.vithey.aub_connect_app` bound to the app signing SHA-1 in the Google Cloud project (currently only a generic `installed` client exists, project `yoeun-sokhon-pharmacy-backup`), and (b) a Google account on the emulator. The web `client_secret` is **not** used (backend verifies ID tokens). |
| D-6 | P1 | OPEN | Create Post "General" (poster) rejects text-only posts with raw backend message `Media posts require media_file_id`; API has no text post type. Needs a product/API decision (allow POSTER without media, or add a text type). Found via UI test U6. |
| D-7 | P1 | FIXED | Finance screen crashed: `type 'double' is not a subtype of type 'Map<String, dynamic>?'` because `GET /payments` returns flat `amount`+`currency` while `finance_service.dart` cast `amount` to a Map. Parser now accepts flat or nested amounts; Finance renders. Found via UI test U18. |
| D-8 | P2 | FIXED | Finance dashboard totals defaulted to USD, rendering KHR as `$30,000.00`. `finance_repository.dart` now uses the payments' currency → `៛3,000,000`. |
| D-9 | P3 | OPEN | Account settings shows `Email/Phone | Not set` though the account has them (profile payload omits auth email/phone). |




## Appendix — verification evidence (Phase 4–6)

Run after the Phase 3 fixes.

| Check | Command / scenario | Result |
|---|---|---|
| Backend suite | `mvn -B -f backend/pom.xml test` | BUILD SUCCESS, 14/14 modules, 0 failures/errors (5:16) |
| Gateway filter regression | `mvn -f backend/pom.xml -pl services/api-gateway -am test -Dtest=UserHeaderForwardFilterTest -Dsurefire.failIfNoSpecifiedTests=false` | Tests run 2, Failures 0 |
| Flutter analyze | `flutter analyze --no-fatal-infos` | No issues found |
| Flutter tests | `flutter test` | All tests passed (+24) incl. new `app_config_test.dart` |
| Backend E2E (gateway) | register→login→me→refresh→logout at `http://localhost:8080/api/v1` | 201/200/200/200/204; refresh reuse → 401; refresh after logout → 401 |
| Release APK build | `flutter clean; flutter pub get; flutter build apk --release --dart-define=APP_ENV=staging` | Built `build\app\outputs\flutter-apk\app-release.apk` (105,247,807 bytes) |
| APK signature | `apksigner verify --print-certs` | Signed; cert SHA-256 `24f39b37…57c6ac` (local verification key) |
| APK hash | `Get-FileHash -Algorithm SHA256` | `79CE531DEE43D4D2E3925C66E1BDCF355853B08C178C538676D82B84FEE13346` |
| APK manifest | `aapt dump badging` / merged manifest | `com.vithey.aub_connect_app` 1.0.0 (1), minSdk 24, targetSdk 36, `usesCleartextTraffic=false`, no `debuggable` |
| Clean install/launch | `adb uninstall`; `adb install`; `monkey … LAUNCHER` | Success; process running; `MainActivity` resumed on emulator `Medium_Phone_API_36.1` |
| Backend E2E API smoke | `backend/scripts/smoke-api.ps1` | **34 PASS / 0 FAIL** (after D-1 + D-4 fixes) |
| Service health | `backend/scripts/check-service-health.ps1` | 11 backend services OK; ai_core OK; map-service SKIP (not running) |
| Authorization (ownership) | B PATCH/DELETE A's post; A PATCH/DELETE own | 403 / 403 / 200 / 204 — correct |
| Identity spoof | forged `X-User-Id` on `GET /users/me` | returns token's user (spoof blocked) |
| Auth enforcement | unauth `/users/me`; non-student `/fees` | 401; 403 |
| Python tests | `pytest -q` in `external-services/ai-core` / `fake-payment-service` | 70 PASS / 19 PASS |
| Compose validity | `docker compose … config --quiet` | OK |
| Secret scan | tracked-file scan for `.env`, keystores, private keys, API keys | clean (no tracked secrets; DeepSeek key only in ignored `.env`) |
| Full stack rebuild | `docker compose … build` + `up -d --no-build` | all 13 images rebuilt; 11 services healthy |
| Flutter analyze + tests | `flutter analyze`; `flutter test` | No issues; +24 PASS |

### Not verified (blockers recorded in the Completion Report)

- Release-mode on-device E2E against a **production HTTPS** API: no production
  URL and no owner signing material were supplied.
- The release APK was built with `APP_ENV=staging` against the bundled
  dev/demo HTTP URL, so it cannot reach a backend in release (cleartext off) —
  by design.
- Map/Places UI + API (N1–N3): `map-service` stopped and backend
  `GOOGLE_PLACES_API_KEY` unset.
- Google Sign-In live flow: `ENABLE_GOOGLE_AUTH=false` / no client IDs.
- Physical-device testing: only the `Medium_Phone_API_36.1` emulator available.


