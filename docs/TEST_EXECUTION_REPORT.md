# TEST_EXECUTION_REPORT.md — Vithey complete test pass

Date: 2026-10-08. Tester: automated UI driver (Flutter `uiautomator` semantics) +
APIs. Device: Android emulator `Medium_Phone_API_36.1` (1080x2400), debug build
`com.vithey.aub_connect_app`, backend = local Docker stack via `10.0.2.2:8080`.

## 1. Summary

| Layer | Result |
|---|---|
| Backend Java tests | 14/14 modules PASS |
| Python tests (ai-core / fake-payment) | 70 PASS / 19 PASS |
| Backend E2E API smoke | 34 PASS / 0 FAIL |
| Authorization (ownership/spoof/auth) | PASS |
| Flutter analyze + unit/widget tests | No issues / +24 PASS |
| UI end-to-end (this pass) | 14 flows PASS, 3 defects found (2 fixed, 1 open) |

## 2. UI flows executed on the emulator

| # | Flow | Steps performed | Result |
|---|---|---|---|
| U1 | Launch + language | cold start → language select (English/Khmer) | PASS |
| U2 | Onboarding | Continue → 4 onboarding pages → sign-in | PASS |
| U3 | Login (email/password) | typed `manualtest@aub.edu.kh` / password → Sign In | PASS — Home loaded |
| U4 | Home feed | empty state → job post rendered with author/stats | PASS |
| U5 | Create Post (Job) | category→Job, default title, Post | PASS — appears in feed |
| U6 | Create Post (General/text) | default "General" category, text only, Post | **FAIL** — "Media posts require media_file_id" (D-6) |
| U7 | Reels | bottom nav → reels player | PASS |
| U8 | AI chatbot | bottom nav → Vithey AI, welcome + suggestion chips | PASS |
| U9 | Notifications | bottom nav → empty state + tabs | PASS |
| U10 | Profile | tabs All/Reels/Posters/Jobs/Applied Jobs, stats, actions | PASS |
| U11 | Profile → Jobs tab | created job listed | PASS |
| U12 | Settings home | Preferences/System/Support sections | PASS |
| U13 | Account settings | personal info screen | PASS (D-9 minor) |
| U14 | Security settings | Change Password / 2FA / Biometric / Sessions | PASS |
| U15 | Search | query "Manual" → People result + tabs + Places | PASS |
| U16 | Chat list | empty state + Message Requests | PASS |
| U17 | Student verification | fill Student ID + email → Verify Student Status | PASS — verified instantly |
| U18 | Finance dashboard | after verification → balances + transactions | **FIXED** → PASS (D-7, D-8) |
| U19 | Google Sign-In button | tap → Google GMS activity opens | PARTIAL — needs device Google account + Android OAuth SHA-1 (D-5) |

## 3. Defects found in this pass

| ID | Sev | Area | Status | Detail |
|---|---|---|---|---|
| D-6 | P1 | Create Post | **OPEN (owner decision)** | The default category **"General"** is described "Community or social post" but the backend `POSTER` type requires `media_file_id`; a text-only General post fails with the raw message `Media posts require media_file_id`. There is no text post type in the API (`VIDEO/POSTER/JOB`). Fix requires either allowing `POSTER` without media on the backend, or adding a text type, or changing the product flow. |
| D-7 | P1 | Finance | FIXED | `GET /payments` returns flat `amount` (number) + `currency`; Flutter cast `amount` to `Map<String,dynamic>` → `type 'double' is not a subtype of type 'Map<String, dynamic>?'`, Finance screen error. Fixed `finance_service.dart` `_parsePayment`/`_parseInvoice` to accept flat or nested amounts. Re-tested: Finance renders. |
| D-8 | P2 | Finance | FIXED | Dashboard totals dropped currency (defaulted USD), so KHR summed as `$30,000.00`. Fixed `finance_repository.dart` to use the payments' currency → `៛3,000,000` / `៛25,000`. |
| D-9 | P3 | Account settings | OPEN (minor) | Account screen shows `Email | Not set`, `Phone | Not set` although the account has them (`/users/me` profile payload omits auth email/phone). |
| D-1 | P1 | Backend DB | FIXED | Postgres `max_connections=40` exhausted by 10×5 pools → 500/503. Raised to 100. |
| D-2 | P2 | App startup | FIXED | Unhandled `Missing or invalid token` on fresh start. Guarded session probe. |
| D-3 | P1 | Map/Places | BLOCKED | `map-service` stopped + `GOOGLE_PLACES_API_KEY` unset. |
| D-4 | P1 | Stale images | FIXED | Running images predated `PATCH /posts/{id}`; rebuilt all images. |
| D-5 | P1 | Google Sign-In | PARTIAL | Wired with owner Web client ID; needs Android OAuth SHA-1 + device Google account. |

## 4. Backend API coverage (smoke + authz)

All of these returned expected results: register, login, `/auth/me`, refresh
(rotation), logout, `/users/me`, `PATCH /users/me`, create/list/detail/update/
delete post, comments, reactions, follow, file upload/download, job
applications, CV get/save, fees (403→200 after verify), payments, invoice,
conversations, message requests, chat messages, notifications, AI chat/stream/
sessions/regenerate/cv-generate/cv-suggest, places history (503 – map down).

Authorization: B PATCH/DELETE A's post → 403; A own → 200/204; forged
`X-User-Id` ignored; unauth → 401; non-student `/fees` → 403.

## 5. Environment / blockers (owner input)

| Item | Needed from owner |
|---|---|
| D-6 text post | Product decision: allow `POSTER` without media, or add a text type |
| D-5 Google Sign-In | Android OAuth client + SHA-1 (`com.vithey.aub_connect_app`) in the Google Cloud project; Google account on the test device |
| D-3 Map/Places | `GOOGLE_PLACES_API_KEY` + start `map` profile |
| Production release | Owner keystore + production HTTPS API URL |
| Physical device | Optional real-device run |

## 6. How to reproduce

1. `cd backend && docker compose -f docker-compose.yml -f docker-compose.demo.yml up -d --no-build`
2. `cd vithey_app && flutter build apk --debug && adb install -r build/app/outputs/flutter-apk/app-debug.apk`
3. Launch app, log in with a registered account, walk sections U1–U19 above.
4. `backend/scripts/smoke-api.ps1` for the API matrix.
