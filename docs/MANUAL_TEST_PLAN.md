# MANUAL_TEST_PLAN.md — Vithey / AUB Connect

Complete hands-on test plan for the whole system. Use it to test the app on the
Android emulator against the local Docker stack.

## 0. Status already verified automatically (this run)

| Layer | Result |
|---|---|
| Backend unit/context tests (`mvn -B -f backend/pom.xml test`) | 14/14 modules PASS |
| Backend E2E API smoke (`backend/scripts/smoke-api.ps1`) | **34 PASS / 0 FAIL** |
| Flutter analyze | No issues |
| Flutter tests | +24 PASS |
| Release APK | built, signed, installed, launched |
| App startup on emulator | launches, onboarding renders, no unhandled exceptions |

`map-service` / Places is **not** testable: the backend
`GOOGLE_PLACES_API_KEY` is not set, so `/api/v1/places/**` returns 503.

## 1. Environment setup

1. Backend stack (already running):
   ```powershell
   cd backend
   docker compose -f docker-compose.yml -f docker-compose.demo.yml up -d --no-build
   ```
   Health: `http://localhost:8080/actuator/health` → `{"status":"UP"}`.
2. Emulator: `Medium_Phone_API_36.1`, app installed `com.vithey.aub_connect_app`
   (debug build, reaches the stack via `10.0.2.2:8080`). If needed:
   ```powershell
   cd vithey_app
   flutter build apk --debug
   & "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" install -r build\app\outputs\flutter-apk\app-debug.apk
   ```
3. Logs while testing:
   ```powershell
   & "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" logcat -s flutter:* AndroidRuntime:E
   ```

## 2. Test accounts / data

- No seeded accounts. Create accounts from the app (Register) or the API.
- Suggested: `manual1@aub.edu.kh`, `manual2@aub.edu.kh`, password `SecurePass123!`.
- Two accounts are required to test follow, chat, message requests, job
  applications between users.
- Generate peer data with `backend/scripts/smoke-api.ps1` (creates posts, a job
  post, a conversation) if you want pre-populated content.

## 3. Test cases

Mark Actual + Pass/Fail as you go. IDs are stable for bug reports.

### A. Startup / session / language

| ID | Steps | Expected |
|---|---|---|
| A1 | Fresh install, launch | Splash → language selection; no crash |
| A2 | Select Khmer, Continue | Khmer locale applied; onboarding in Khmer |
| A3 | Complete onboarding → login | Login screen reached |
| A4 | Kill app, relaunch (logged in) | Restores session → Home (no login) |
| A5 | Stop Docker stack, relaunch | Splash/Home with graceful network error, no crash |
| A6 | Expired/revoked token (logout on 2nd device), use app | 401 → auto-refresh or redirect to login, no infinite loop |

### B. Authentication

| ID | Steps | Expected |
|---|---|---|
| B1 | Register valid new user | Account created, lands in app/startup profile |
| B2 | Register duplicate email/phone | Friendly "already exists" error, no crash |
| B3 | Register weak/short password | Inline validation error |
| B4 | Login valid | Home |
| B5 | Login wrong password | Friendly invalid-credentials error |
| B6 | Login unknown email | Friendly error |
| B7 | Forgot password | Generic "if email exists" success |
| B8 | Change password (correct current) | Success message |
| B9 | Change password (wrong current) | Error, password unchanged |
| B10 | Logout | Returns to login, tokens cleared (relaunch stays logged out) |
| B11 | Google sign-in (if `ENABLE_GOOGLE_AUTH=true`) | Google flow → Home; else button hidden/disabled |

### C. Startup profile (skills / interests / discovery)

| ID | Steps | Expected |
|---|---|---|
| C1 | Complete skills step | Selections saved, next enabled |
| C2 | Skip allowed steps | Skip works, does not crash |
| C3 | Finish startup | Lands on Home; profile reflects choices |

### D. Home feed

| ID | Steps | Expected |
|---|---|---|
| D1 | Open Home | Feed loads (loading → list/empty state) |
| D2 | Pull to refresh | Refreshes, no duplicate posts |
| D3 | Scroll to bottom | Pagination loads more; stops at end |
| D4 | Filter by type (posts/jobs/reels) | Filtered list |
| D5 | Like/unlike a post | Icon toggles, persists after refresh |
| D6 | Comment on a post | Comment appears, count updates |
| D7 | Reply to a comment | Threaded reply shows |
| D8 | Edit/delete own comment/post | Owner actions work; non-owner cannot |
| D9 | Share post | Share sheet opens/works |
| D10 | Job post card | Job meta renders; "Apply" opens flow |
| D11 | Follow/unfollow author | State toggles; persists |
| D12 | Offline then online | Error/empty state then recovers on retry |

### E. Create / edit post

| ID | Steps | Expected |
|---|---|---|
| E1 | Create text post | Appears at top of feed |
| E2 | Create with image (camera/gallery) | Uploads; media renders |
| E3 | Create with video | Uploads; plays in feed/reels |
| E4 | Create job post with meta | Renders as job card |
| E5 | Schedule post | Scheduled state handled |
| E6 | Empty content submit | Validation blocks submit |
| E7 | Large file upload | Progress/failure handled without crash |
| E8 | Edit own post | Updates; remove media works |
| E9 | Delete own post | Removed from feed/profile |

### F. Post detail / reels

| ID | Steps | Expected |
|---|---|---|
| F1 | Open post detail | Wrapped text, media, author, actions |
| F2 | Comments list scroll/paginate | Loads more |
| F3 | Open reels | Video autoplays, scroll between reels |
| F4 | Fullscreen media viewer | Opens/closes correctly |

### G. Profile

| ID | Steps | Expected |
|---|---|---|
| G1 | Open own profile | Header, stats, tabs render |
| G2 | Open another user's profile by id | Loads public profile |
| G3 | Edit profile (bio, major, location, skills, avatar) | Saves and reflects |
| G4 | Profile tabs (posts/reels/tagged) | Content loads |
| G5 | Post analytics (own post) | Metrics render |
| G6 | QR / scan QR | Screens open (camera permission prompt) |
| G7 | View KiKhmer/Unicode text | Renders without tofu/overflow |

### H. Search

| ID | Steps | Expected |
|---|---|---|
| H1 | Search users | Results + highlight |
| H2 | Search posts/keyword | Results |
| H3 | Search jobs | Job results with apply entry |
| H4 | Empty result | Empty state |
| H5 | Recent searches | Persisted, tappable |
| H6 | See-all pagination | Loads more |

### I. Notifications

| ID | Steps | Expected |
|---|---|---|
| I1 | Open notifications | List grouped by day, skeletons first |
| I2 | Filter read/unread/all | Filters apply |
| I3 | Mark single read | Unread count decrements |
| I4 | Mark all read | Count → 0 |
| I5 | Delete notification | Removed |
| I6 | Trigger event (like/comment/follow/chat/job/payment) from peer | New notification appears |
| I7 | Tap notification | Deep-links to correct screen |

### J. Chat

| ID | Steps | Expected |
|---|---|---|
| J1 | Open chat list | Conversations load |
| J2 | Send chat request to peer | Peer sees request in Message Requests |
| J3 | Peer accepts | Conversation appears for both |
| J4 | Send/receive text message | Real-time delivery |
| J5 | Send with reply | Reply preview renders |
| J6 | Mark read | Read state updates |
| J7 | Block/decline | Conversation blocked/declined |
| J8 | Report user | Reason submitted |
| J9 | Offline send | Queued outbox, delivered on reconnect |
| J10 | Chat profile screen | Opens correct participant |

### K. AI chatbot / CV

| ID | Steps | Expected |
|---|---|---|
| K1 | Open chatbot, send message | Streamed reply (SSE) with thinking indicator |
| K2 | Cancel streaming | Stream stops cleanly |
| K3 | Regenerate reply | New reply |
| K4 | History drawer: sessions list | Sessions load; select shows messages |
| K5 | Delete session | Removed |
| K6 | AI CV generate | Draft generated or "incomplete profile" handled |
| K7 | AI CV suggest a section | Suggested text returned |
| K8 | Save CV / preview CV | CV stored and previewable |

### L. Jobs / applications

| ID | Steps | Expected |
|---|---|---|
| L1 | Open a job → Apply | Apply CV flow opens |
| L2 | Select saved CV / upload new CV | CV selected/uploaded |
| L3 | Submit application | Success screen; application status visible |
| L4 | Duplicate application | Conflict handled gracefully |
| L5 | Job applicants (as poster) | Applicant list loads |
| L6 | Applicant detail + CV preview | Secure preview renders |
| L7 | Update application status (reviewed/accepted/rejected) | Status changes; notifications fire |

### M. Finance / student verification

| ID | Steps | Expected |
|---|---|---|
| M1 | Open Finance as unverified user | Prompt to verify student |
| M2 | Submit student verification | Pending status |
| M3 | GET fees before verified (API) | 403 |
| M4 | After verification, open Finance | Fees + balance load |
| M5 | Fees list | 3 seeded fees render |
| M6 | Open a payment invoice | Breakdown: base/processing/late/total |
| M7 | Pay (fake payment provider) | Redirects to payment; returns status |
| M8 | Payment receipts | Past payments listed |
| M9 | Payment alerts | Alerts render |

### N. Map / Places (BLOCKED — needs GOOGLE_PLACES_API_KEY)

| ID | Steps | Expected |
|---|---|---|
| N1 | Open map | Map renders (needs Android Maps key: present) |
| N2 | Nearby/search/autocomplete | **BLOCKED**: backend returns 503 without `GOOGLE_PLACES_API_KEY` |
| N3 | Favorites/history | BLOCKED (depends on map-service) |

### O. Settings

| ID | Steps | Expected |
|---|---|---|
| O1 | Account settings / edit account | Loads/saves |
| O2 | Notification preferences toggles | Persist |
| O3 | Privacy settings + practices | Toggles/pages open |
| O4 | Security settings | Options render |
| O5 | Change password screen | Validation + success |
| O6 | Help center | Content/links open |
| O7 | About | Version/legal render |
| O8 | Logout | Returns to login |

### P. Cross-cutting quality

| ID | Steps | Expected |
|---|---|---|
| P1 | Rotate device on key screens | No overflow/layout break |
| P2 | Small-screen / large font | No overflow, readable |
| P3 | Dark mode toggle | All screens legible |
| P4 | Back navigation on every screen | No dead-ends/crashes |
| P5 | Background → foreground | State preserved |
| P6 | Kill + relaunch mid-flow | Recovers safely |
| P7 | Slow network (emulator network throttle) | Timeouts show retry, no crash |
| P8 | Airplane mode | Offline banner/empty states |
| P9 | Unicode/Khmer text, long text, null optional fields | Renders correctly |
| P10 | Double-tap submit buttons | No duplicate records |

## 4. Defects found and fixed during this test pass

| ID | Severity | Issue | Root cause | Fix |
|---|---|---|---|---|
| D-1 | P1 | `/users/me`, `POST /posts`, AI chat, `/message-requests` etc. returned 500/503 | Demo Postgres `max_connections=40` < 10 services × pool 5 + ai-core/Flyway → "too many clients already" | Raised `PG_MAX_CONNECTIONS` default to 100 (`docker-compose.demo.yml`, `.env.example`, `.env`); recreated Postgres. Smoke went 21/32 → **34/34**. |
| D-2 | P2 | Unhandled Dart exception `Missing or invalid token` on fresh-app startup | `StudentVerificationRepository` constructor eagerly called authenticated `/auth/me` before any session | Guarded the initial sync (skip until a token exists) and catch failures (`student_verification_repository.dart`). |

## 5. Results recording template

```
Env: emulator Medium_Phone_API_36.1 | API http://10.0.2.2:8080/api/v1 | build: debug
Tester: ____  Date: ____

A1 __  A2 __  ...  P10 __
Failures: ID | actual | screenshot/log
```
