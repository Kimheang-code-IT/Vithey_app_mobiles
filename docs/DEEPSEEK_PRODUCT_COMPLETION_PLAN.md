# DeepSeek Production Testing and Completion Plan

> Repository-specific execution brief for DeepSeek or another coding agent.
>
> Prepared: 2026-10-07  
> Scope: Flutter UI, Spring APIs, Python services, business logic, integrations, Android release, deployment, and competition rehearsal.  
> Evidence status: this document defines required work; unchecked items are **not tested** and must never be reported as passed without evidence.

{% hint style="danger" %}
This repository contains a demo payment provider and documented AI stubs. A successful local demo does not by itself make the system production-ready. Production acceptance requires real production integrations, HTTPS infrastructure, owner-controlled secrets and signing, monitoring, backup/restore, and device evidence.
{% endhint %}

## 1. Mission

Review, test, fix, and verify the complete Vithey / AUB Connect product so it is reliable for the ACLEDA Bank App Competition and has an honest production-readiness decision.

DeepSeek must validate the system vertically, not as isolated folders:

```text
Flutter screen
  -> controller/state/validation
  -> repository/API client/token refresh
  -> API gateway/JWT/user headers
  -> service controller/business rules
  -> database/cache/queue/object storage/third party
  -> response/error mapping
  -> visible UI result
```

The work is complete only when every required gate in this plan has evidence, all P0/P1 defects are closed, release-mode critical journeys pass on Android, and remaining limitations are disclosed.

## 2. Verified Repository Inventory

Use this as the starting map, then confirm it against the current revision before testing.

| Area | Present implementation | Required verification |
| --- | --- | --- |
| Mobile | Flutter/Dart app in `vithey_app`; GetX, Dio, secure storage, Isar, STOMP, Google Maps/sign-in | Analyze, unit/widget/integration tests, accessibility, release build, emulator and physical device |
| Gateway | Spring Cloud API gateway | JWT validation, route coverage, identity-header stripping, CORS, rate limits, timeout/error behavior |
| Platform | Eureka + Config Server | Startup ordering, registration, config loading, readiness and failure behavior |
| Services | auth, user-profile, file, content, career, finance, chat, notification, map | Unit, context, integration, authorization, migration, API contract and E2E tests |
| AI | FastAPI `external-services/ai-core`; real CV LLM path plus documented chat/suggestion stubs | Unit/API tests, auth, rate limits, timeout/retry, privacy, cost, fallback and stub disclosure |
| Payment | FastAPI `external-services/fake-payment-service` | Demo-only tests and isolation; replace or explicitly reject production status |
| Data | PostgreSQL, Redis, RabbitMQ, MinIO | Migrations, constraints, durability, permissions, backup/restore, retry and outage behavior |
| Runtime | Docker Compose and PowerShell/shell scripts | Clean start, health, smoke, restart, resource limits and logs |
| Monitoring | Prometheus + Grafana | Target health, dashboards, alerts, redaction and actionable diagnostics |
| CI | `ci.yml`, `dev-integration.yml`, `main.yml` | Reproduce gates locally and confirm required branch protection |

Current automated test inventory to confirm before execution:

- Flutter: 7 Dart test files.
- Java backend: 47 `*Test.java` / `*IT.java` files.
- AI Core: 11 Python test files.
- Fake payment provider: 1 Python test file.
- Runtime API smoke flow: `backend/scripts/smoke-api.ps1`.

Primary references:

- `PROJECT_AUDIT.md`
- `docs/API_INTEGRATION_MATRIX.md`
- `docs/MANUAL_TEST_PLAN.md`
- `docs/06-api/`
- `docs/11-testing/`
- `docs/12-uat/`
- `docs/14-deployment/`
- `docs/ANDROID_RELEASE.md`
- `backend/TESTING.md`

## 3. Non-Negotiable Agent Rules

1. Read the repository and `git status --short` before editing. Preserve all existing user changes.
2. Never run destructive Git commands or rewrite history.
3. Never print, commit, screenshot, or place in reports any password, token, JWT, API key, signing secret, private key, or personal data.
4. Use sanitized test accounts and disposable test data. Do not test destructive scenarios against real production users.
5. Reproduce a defect before fixing it. Add a regression test when practical, apply the smallest coherent fix, then rerun the nearest test and affected E2E journey.
6. Do not mark a test `PASS` because code exists or a request returned any 2xx response. Validate status, schema, persistence, authorization, side effects, UI state, logs, and retry behavior.
7. Never replace production integrations with mocks merely to make a gate green. Label demo, stub, fake, skipped, and blocked behavior accurately.
8. Release must use HTTPS. Do not disable TLS verification, enable broad cleartext traffic, weaken JWT validation, or use permissive production CORS.
9. Mobile apps cannot keep backend secrets. Only public client configuration may be compiled into Flutter.
10. Stop a production release for any open P0/P1, failed critical journey, fake payment dependency, debug signing, embedded secret, authorization bypass, or missing rollback capability.

## 4. Status and Severity Vocabulary

Use only these result values:

| Result | Meaning |
| --- | --- |
| PASS | Executed successfully with retained evidence |
| FAIL | Executed and actual behavior violated the expected result |
| BLOCKED | Could not execute; exact dependency and owner action are recorded |
| SKIPPED | Intentionally excluded with approved reason; never treated as pass |
| NOT RUN | No execution evidence yet |

Defect severity:

- **P0 Blocker:** build/start impossible, data loss, secret exposure, authentication bypass, unusable release, or production outage risk.
- **P1 Critical:** core journey broken, authorization/ownership failure, crash, API contract mismatch, corrupt state, payment/security failure, or release-mode failure.
- **P2 Major:** important error state missing, serious UX/accessibility/reliability/performance gap, or inadequate regression coverage.
- **P3 Minor:** polish, maintainability, low-risk inconsistency, or documentation gap.

## 5. Required Evidence Structure

Create a timestamped evidence folder outside committed source unless sanitized artifacts are intentionally versioned:

```text
test-evidence/<run-id>/
  environment.md
  commands.md
  automated-results/
  api/
  android/
  screenshots/
  performance/
  security/
  defects.md
  completion-report.md
```

For every test record:

| Field | Required value |
| --- | --- |
| Test ID | Stable ID from this plan or a new unique ID |
| Revision | Commit SHA plus dirty-worktree note |
| Environment | OS, tool versions, API URL type, emulator/device, build mode |
| Preconditions | Account role, seed data, services and feature flags |
| Steps | Exact reproducible actions or command |
| Expected | Status, schema, UI state, database/side effect and logs |
| Actual | Observed result without secrets |
| Result | PASS / FAIL / BLOCKED / SKIPPED |
| Evidence | Log path, screenshot, request ID, report file or artifact hash |
| Defect | Linked defect ID when failed |

## 6. Phase 0 — Baseline and Environment

### 6.1 Capture the baseline

```powershell
git status --short --branch
git rev-parse HEAD
git remote -v
java -version
mvn -version
flutter --version
dart --version
python --version
docker version
docker compose version
adb devices -l
```

Record sanitized configuration presence, not values:

- `backend/.env` and infrastructure configuration.
- `external-services/ai-core/.env`.
- `external-services/fake-payment-service/.env`.
- `vithey_app/.env` and all `--dart-define` values by name only.
- Android signing configuration presence and certificate fingerprint only.

### 6.2 Required environments

| Environment | Purpose | Minimum requirement |
| --- | --- | --- |
| Unit/local | Fast feedback | Java, Flutter, Python; no live business data |
| Demo integration | Full local stack | Docker Desktop, disposable data, fake payment clearly labelled |
| Android emulator | Repeatable UI/E2E | Clean API level supported by the app; gateway via `10.0.2.2` or approved URL |
| Physical Android | Device behavior | At least one representative phone; Wi-Fi/mobile-network checks |
| Staging | Production-like acceptance | HTTPS, isolated database/storage/keys, monitoring and safe test accounts |
| Production | Final deployment only | Owner approval, secret manager, backups, rollback, alerts and real integrations |

### Gate 0

- [ ] Revision, dirty state, tool versions, devices and environment are recorded.
- [ ] No secret value appears in evidence.
- [ ] Disposable test accounts/data are available.
- [ ] Missing staging, signing, provider credentials or devices are marked `BLOCKED`, not invented.

## 7. Phase 1 — Static Review, Configuration, and Contract Audit

### 7.1 Repository checks

- Search tracked files for secrets, private keys, production credentials, hard-coded tokens, localhost URLs, emulator URLs, debug flags, `TODO`, `FIXME`, unimplemented/stub/mock behavior, and swallowed exceptions.
- Confirm generated folders, `.env`, keystores, local properties and IDE files are ignored.
- Review dependency locks and scan for known high-severity vulnerabilities using ecosystem-appropriate tools.
- Confirm README, deployment, Android release, API, testing and UAT docs agree with actual code.
- Confirm debug/demo services cannot be enabled accidentally in production.

### 7.2 API integration contract

Fully validate every row in `docs/API_INTEGRATION_MATRIX.md`:

- Exact method, path and gateway prefix.
- Auth requirement and role/ownership rule.
- Headers, query parameters, multipart names and content types.
- Request/response/error JSON names, types, nullability, enums, pagination and timestamps.
- Client timeout, retry, cancellation, refresh and UI error mapping.
- Backend controller, service rule, persistence and side effects.
- Implemented, stubbed, deliberately unsupported and orphaned operations.

Any Flutter network operation absent from the matrix is a defect. Any documented API without an implementation must be labelled as unsupported or completed before release.

### 7.3 Production configuration review

- Release API URL comes from a deliberate build environment and never falls back to `10.0.2.2`, localhost, or cleartext HTTP.
- Required settings fail fast with a useful diagnostic.
- JWT secret/key material is strong, externalized and consistent across issuer/verifier services.
- Gateway strips untrusted identity headers and rebuilds trusted identity from the verified token.
- CORS is restricted for browser clients; CORS is not treated as mobile authorization.
- Spring Actuator exposes only intended endpoints.
- Database, Redis, RabbitMQ, MinIO and provider credentials are externalized and least-privileged.
- Logs redact authorization headers, tokens, reset links, passwords, student identifiers and personal data.

### Gate 1

- [ ] `PROJECT_AUDIT.md` contains evidence-backed findings and disposition.
- [ ] `docs/API_INTEGRATION_MATRIX.md` covers every Flutter request.
- [ ] No production secret or debug endpoint is committed/compiled.
- [ ] All known stubs/fakes are listed as release limitations or replaced.

## 8. Phase 2 — Automated Component Tests

Run from a clean dependency state where practical. Preserve complete command output and exit code.

### 8.1 Spring backend

```powershell
mvn -B -f backend/pom.xml test
```

Requirements:

- Unit and context tests pass for all modules.
- Docker/Testcontainers smoke tests actually execute; a skipped test is not a pass.
- Flyway migrations apply from an empty database and upgrade from the previous supported schema.
- Add missing tests for authorization, ownership, validation, duplicate actions, transaction rollback and concurrency.
- Verify test discovery configuration so `*SmokeIT` is included by the intended CI/integration command.

### 8.2 AI Core

```powershell
Push-Location external-services/ai-core
python -m pip install -e ".[server,dev]"
python -m pytest -q
Pop-Location
```

Test real client behavior with a controlled account only where authorized. Unit tests must mock external cost-bearing calls. Verify timeout, retry/backoff, malformed LLM output, prompt injection boundaries, rate limits, cache isolation, Unicode/Khmer input and safe logging.

### 8.3 Fake payment provider

```powershell
Push-Location external-services/fake-payment-service
python -m pip install -r requirements-dev.txt
python -m pytest -q
Pop-Location
```

Passing these tests proves only the demo provider works. It does not satisfy production payment acceptance.

### 8.4 Flutter

```powershell
Push-Location vithey_app
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-fatal-infos
flutter test --coverage
Pop-Location
```

Add or complete tests for:

- API models/envelopes and error mapping.
- token storage, concurrent 401 refresh, failed refresh and logout cleanup.
- controller loading/empty/success/error/retry state.
- validation and double-submit prevention.
- route guards and deep links.
- critical screens and accessibility semantics.
- upload progress/cancel/failure.
- STOMP reconnect and duplicate-message handling.

### 8.5 Docker/configuration validation

```powershell
docker compose -f backend/docker-compose.yml config
docker compose -f backend/docker-compose.yml -f backend/docker-compose.demo.yml config
docker compose -f monitoring/docker-compose.yml --profile monitoring config
```

### Gate 2

- [ ] All intended tests execute and pass.
- [ ] No unexplained analyzer/compiler warning remains.
- [ ] Coverage report is retained and critical business logic has direct tests.
- [ ] Skipped tests have explicit owners and do not hide required integration coverage.

## 9. Phase 3 — Full Stack Integration

### 9.1 Start from clean disposable data

Do not delete persistent owner data. Use the documented demo scripts and a confirmed disposable environment.

```powershell
Push-Location backend
.\scripts\docker-up-demo.ps1
.\scripts\check-service-health.ps1
.\scripts\verify-docker.ps1
.\scripts\smoke-api.ps1
Pop-Location
```

Validate:

- Startup succeeds from no containers and an empty test database.
- Config Server and Eureka dependencies do not create an endless restart loop.
- Every required container becomes healthy and every service registers.
- Migrations run once and are safe on restart.
- Gateway routes all documented APIs and rejects unknown/retired routes.
- Correlation/request IDs propagate across gateway and services.
- RabbitMQ events are delivered once or handled idempotently.
- Redis cache/session loss degrades safely.
- MinIO upload, download, authorization, expiry and deletion work.
- Restarting each service does not corrupt data or require manual repair.

### 9.2 API negative matrix

For every endpoint family, test:

| Case | Expected behavior |
| --- | --- |
| No token | `401` with stable safe error envelope |
| Expired/malformed/wrong-signature token | `401`; no internal detail leakage |
| Wrong role | `403` |
| Wrong owner/tenant | `403` or non-enumerating `404` per contract |
| Invalid body/query/path | `400`/validation status with field detail |
| Missing record | `404` |
| Duplicate/idempotent request | Documented `409`, replayed response or no-op |
| Unsupported media/oversized file | Rejected before unsafe storage/processing |
| Dependency unavailable | Bounded timeout and stable `5xx`/`503`; no hang |
| Concurrent update | No lost update, duplicate payment/application/message or corrupt count |
| Injection payload | Treated as data; no SQL/template/log/header injection |

### Gate 3

- [ ] Full stack starts cleanly and health checks pass.
- [ ] `smoke-api.ps1` passes with sanitized evidence.
- [ ] Negative auth/role/ownership/error cases pass.
- [ ] Data persists correctly across safe service restarts.
- [ ] Failure/recovery behavior is bounded and observable.

## 10. Phase 4 — Complete UI, API, and Business-Logic Matrix

Execute every journey in both debug (diagnosis) and release/profile mode (acceptance). Verify visible UI, API exchange, stored data, event side effects and permissions.

### 10.1 App shell and lifecycle

- [ ] UI-APP-01 fresh install opens correctly with no crash or stale session.
- [ ] UI-APP-02 relaunch with valid session restores the correct route.
- [ ] UI-APP-03 expired session performs one refresh and continues.
- [ ] UI-APP-04 failed refresh clears sensitive state and returns to login without a loop.
- [ ] UI-APP-05 offline launch shows a recoverable state, not an infinite spinner.
- [ ] UI-APP-06 background/foreground, process kill, rotation where supported, and back navigation preserve valid state.
- [ ] UI-APP-07 deep links and notification taps route safely after login/when logged out.
- [ ] UI-APP-08 Khmer/English, large text, keyboard, small screen, landscape where supported and dark theme do not hide critical controls.

### 10.2 Authentication and account

- [ ] UI-AUTH-01 register USER and COMPANY; validate duplicate email/phone and weak/invalid fields.
- [ ] UI-AUTH-02 login by supported identifier; validate wrong password, locked/rate-limited behavior and generic account-discovery errors.
- [ ] UI-AUTH-03 Google sign-in success, cancel, invalid token, missing configuration and account linking.
- [ ] UI-AUTH-04 refresh rotation works; an old refresh token cannot be replayed.
- [ ] UI-AUTH-05 forgot/reset password uses one-time expiring token and invalidates appropriately.
- [ ] UI-AUTH-06 change password verifies current password and handles token/session policy.
- [ ] UI-AUTH-07 student verification promotes only valid users and gates finance correctly.
- [ ] UI-AUTH-08 logout revokes refresh access, clears secure/local caches and disconnects STOMP.

### 10.3 Profile, settings and privacy

- [ ] UI-PROF-01 load/edit own profile with validation, optional/null fields and Unicode/Khmer.
- [ ] UI-PROF-02 upload/change avatar with camera/gallery denial, invalid type, large file, cancel and retry.
- [ ] UI-PROF-03 public profile hides private fields and prevents editing another user.
- [ ] UI-PROF-04 user search handles debounce, paging, empty, error and no duplicate rows.
- [ ] UI-PROF-05 skills add/edit/remove and persistence are correct.
- [ ] UI-PROF-06 language, theme, notifications and privacy settings persist across devices/relaunch as designed.
- [ ] UI-PROF-07 account deletion/data export behavior is implemented or explicitly blocked for production.

### 10.4 Social feed

- [ ] UI-SOC-01 feed loading, empty, paging, pull-to-refresh, retry and deduplication.
- [ ] UI-SOC-02 create text/image/video/job post; validation, upload progress and double-submit prevention.
- [ ] UI-SOC-03 view, edit and delete own post; reject edit/delete by another user.
- [ ] UI-SOC-04 comments create/edit/delete with ownership, mentions, long/Khmer text and paging.
- [ ] UI-SOC-05 reactions toggle idempotently and counts remain correct under fast repeated taps.
- [ ] UI-SOC-06 follow/unfollow, self-follow rejection, follower/following lists and counts.
- [ ] UI-SOC-07 media failure, slow network and deleted/private content show safe states.

### 10.5 Jobs, CV and applications

- [ ] UI-JOB-01 list/search/filter job posts with empty/paging/error behavior.
- [ ] UI-JOB-02 COMPANY creates/updates/deletes job content under correct authorization.
- [ ] UI-JOB-03 upload CV with valid PDF/type/size rules and set/retrieve default CV.
- [ ] UI-JOB-04 AI CV generation validates inputs, real/stub behavior, timeout, retry and generated content before save/export.
- [ ] UI-JOB-05 CV suggestion is labelled as stub or completed; it must not be presented as real production AI if stubbed.
- [ ] UI-JOB-06 apply once using idempotency; duplicate taps/network retry cannot create duplicate applications.
- [ ] UI-JOB-07 applicant sees only own application; poster sees only applicants for owned job.
- [ ] UI-JOB-08 status transitions enforce allowed order and poster-only authority.
- [ ] UI-JOB-09 CV preview/download is restricted to applicant and authorized poster.
- [ ] UI-JOB-10 generated PDF layout, Khmer/Unicode, page breaks, sharing and file integrity are checked on device.

### 10.6 Finance and payment

- [ ] UI-FIN-01 non-student receives understandable gated state; API returns `403`.
- [ ] UI-FIN-02 verified student sees correct fee categories, amounts, due dates and decimal/currency formatting.
- [ ] UI-FIN-03 payments list/detail/alerts are user-scoped and paginated correctly.
- [ ] UI-FIN-04 duplicate payment initiation/callback/retry cannot double-charge or double-record.
- [ ] UI-FIN-05 pending, successful, declined, expired, cancelled, timeout and unknown-provider outcomes reconcile correctly.
- [ ] UI-FIN-06 webhook/callback authenticity, replay protection and idempotency are verified for a real provider.
- [ ] UI-FIN-07 receipts/audit trail never expose another student's data.

{% hint style="warning" %}
The current fake payment service is suitable for demonstration only. All finance UI tests may pass locally while production payment remains `BLOCKED` until a real provider, legal/compliance approval, callback security and reconciliation are verified.
{% endhint %}

### 10.7 Chat and real-time messaging

- [ ] UI-CHAT-01 conversation list loading/empty/paging/unread state.
- [ ] UI-CHAT-02 message request create, duplicate, receive, accept, decline and block.
- [ ] UI-CHAT-03 unauthorized users cannot read/send in another conversation.
- [ ] UI-CHAT-04 REST and STOMP messages agree; ordering and timestamps are stable.
- [ ] UI-CHAT-05 reconnect after Wi-Fi loss/app background does not duplicate or lose acknowledged messages.
- [ ] UI-CHAT-06 optimistic send transitions through pending/sent/failed/retry safely.
- [ ] UI-CHAT-07 read receipts, presence and unread counts converge across two devices/users.
- [ ] UI-CHAT-08 report flow validates reason, prevents abuse and records an auditable event.

### 10.8 Notifications

- [ ] UI-NOTIF-01 list, paging, unread count, mark one/all read and delete.
- [ ] UI-NOTIF-02 device token register, refresh, logout/unregister and multi-device behavior.
- [ ] UI-NOTIF-03 foreground/background/terminated push behavior and deep-link destination.
- [ ] UI-NOTIF-04 permission denied/later/settings flows are usable.
- [ ] UI-NOTIF-05 duplicate event delivery does not create duplicate notifications.
- [ ] UI-NOTIF-06 notification privacy is safe on lock screen and logs.

### 10.9 Maps and places

- [ ] UI-MAP-01 location permission allow/deny/permanently-deny and services-disabled states.
- [ ] UI-MAP-02 nearby, text search and autocomplete validate coordinates/input and debounce correctly.
- [ ] UI-MAP-03 place detail, favorites add/remove and history clear persist correctly.
- [ ] UI-MAP-04 provider quota, invalid key, timeout, zero results and no network show safe fallbacks.
- [ ] UI-MAP-05 keys are correctly restricted by package/signing certificate and API scope.

### 10.10 AI assistant

- [ ] UI-AI-01 new/existing session, session paging, messages and delete.
- [ ] UI-AI-02 send, stream, cancel and regenerate show correct progress and do not duplicate messages.
- [ ] UI-AI-03 empty, long, Khmer/English, malicious and sensitive inputs are handled safely.
- [ ] UI-AI-04 rate limit, provider timeout, malformed result and quota exhaustion produce helpful retry guidance.
- [ ] UI-AI-05 one user's sessions/messages are never visible to another user.
- [ ] UI-AI-06 privacy notice, retention, logging and consent match actual behavior.
- [ ] UI-AI-07 stubbed chat/suggestion behavior is clearly disclosed and excluded from a production claim unless completed.

### 10.11 Search and cross-feature consistency

- [ ] UI-SEARCH-01 people, posts, jobs and videos return correct types and routes.
- [ ] UI-SEARCH-02 debounce/cancel prevents stale results from replacing the current query.
- [ ] UI-SEARCH-03 empty/error/offline/retry/paging and recent-search behavior.
- [ ] UI-X-01 avatar/name/post/application/notification changes converge across features.
- [ ] UI-X-02 logout/login as another user leaves no prior user's cache, messages, files or profile data.

### Gate 4

- [ ] Every applicable case above has result and evidence.
- [ ] Critical journeys pass in release/profile mode on an emulator and physical Android device.
- [ ] UI, API response, database state and async side effects agree.
- [ ] No P0/P1 remains open.

## 11. Phase 5 — Security, Privacy, Reliability, and Performance

### 11.1 Security tests

- OWASP MASVS/Mobile Top 10 review for local storage, screenshots, clipboard, logs, backups, WebView and network security.
- OWASP API Top 10 review for BOLA/IDOR, broken authentication, property-level authorization, resource exhaustion, unsafe business flows, SSRF, misconfiguration and inventory gaps.
- Verify server-side role and ownership checks for every object ID; UI hiding is not authorization.
- Test JWT algorithm, issuer, audience, expiry, clock skew, signature, refresh rotation and revocation policy.
- Test rate limits for login, registration, reset, AI, search, upload, messaging and provider callbacks.
- Validate file signature/content, not only extension; block traversal, executable content and oversized payloads.
- Verify dependency/container scans and triage high/critical findings.
- Arrange an independent penetration test before real production use.

### 11.2 Privacy and data lifecycle

- Document personal/student/financial/AI data collected, purpose, location, retention, deletion and access roles.
- Verify consent, privacy policy, account deletion/export and incident response.
- Confirm production data is never copied into demo/test environments.
- Confirm logs, metrics, traces, backups and AI prompts do not retain unnecessary personal data.

### 11.3 Reliability and recovery

- Kill/restart each service during safe test traffic.
- Interrupt PostgreSQL, Redis, RabbitMQ, MinIO, AI provider, maps provider and payment provider separately.
- Verify bounded connect/read/write timeouts, retries with jitter, circuit breakers and no retry storms.
- Verify graceful shutdown and message/idempotency recovery.
- Execute backup and restore into a separate environment; measure recovery time and data point.
- Execute documented rollback with database compatibility.

### 11.4 Performance targets

Agree targets before measurement. At minimum record p50/p95/p99, error rate, throughput and resource usage for:

- Login/refresh and profile.
- Feed first page and pagination.
- Post/comment/reaction/follow writes.
- File upload/download at allowed maximum.
- Job search/apply/status.
- Finance reads and payment state transition.
- Chat REST/STOMP fan-out and reconnect.
- Notification inbox/unread count.
- Maps and AI calls separated into internal and provider latency.

Mobile measurements must include cold start, warm start, dropped frames/jank, memory growth, CPU, network bytes, battery-sensitive background behavior and APK/AAB size on representative hardware.

### 11.5 Accessibility and usability

- Screen reader labels/order and meaningful button names.
- Touch targets, contrast, focus, keyboard behavior and error announcements.
- Text scaling at least through the agreed supported setting without clipped critical content.
- No color-only status communication.
- Destructive/payment actions require clear confirmation and recovery guidance.

### Gate 5

- [ ] Security and privacy review has no unresolved P0/P1.
- [ ] Backup restore and rollback were executed, not only documented.
- [ ] Performance targets are agreed and met with retained reports.
- [ ] Accessibility critical journeys pass.
- [ ] Monitoring detects injected failures without leaking sensitive data.

## 12. Phase 6 — Production Android Release

### 12.1 Build gates

Use the real HTTPS environment and owner-controlled signing. Never put secrets in the command history.

```powershell
Push-Location vithey_app
flutter clean
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter build apk --release `
  --dart-define=APP_ENV=production `
  --dart-define=API_BASE_URL=https://<approved-host>/api/v1 `
  --dart-define=WS_BASE_URL=wss://<approved-host>/ws
flutter build appbundle --release `
  --dart-define=APP_ENV=production `
  --dart-define=API_BASE_URL=https://<approved-host>/api/v1 `
  --dart-define=WS_BASE_URL=wss://<approved-host>/ws
Pop-Location
```

Verify:

- Application ID, app name, version name/code, icons, launch screen and supported SDK levels.
- Release is not debug-signed and keystore material is outside Git with secure backup.
- Correct API URL is compiled; cleartext is disabled; no debug banner, mock menu, test credentials or verbose sensitive logs.
- R8/minification/resource shrinking behavior if enabled.
- Google sign-in/maps credentials match release package and certificate.
- Manifest permissions are minimal and disclosures/store declarations are accurate.

### 12.2 Artifact evidence

```powershell
Get-FileHash -Algorithm SHA256 <apk-or-aab-path>
adb install -r <apk-path>
adb shell dumpsys package <application-id>
```

Record artifact path, SHA-256, size, version, package ID, signing certificate fingerprint, build command, revision and API environment. Test clean install, upgrade from the last supported version, login, all critical journeys, logout, offline/reconnect and relaunch.

### Gate 6

- [ ] Signed APK and AAB build reproducibly from the release revision.
- [ ] Signature, SHA-256, version and compiled environment are verified.
- [ ] Clean install and upgrade pass on real hardware.
- [ ] Release-mode E2E smoke passes against staging/production-like HTTPS.
- [ ] Store privacy/data-safety/permission requirements are complete.

## 13. Phase 7 — Competition Rehearsal

Run at least three timed rehearsals from a reset demo account/device.

### Critical demo script

1. Launch and authenticate.
2. Verify student role and open profile.
3. Load feed; create and interact with a post.
4. Find a job, generate/select a CV and submit an application.
5. Show application status as the correct role.
6. Show fees/payment demo with a visible statement that the provider is simulated.
7. Send/accept a message request and exchange messages on two users/devices.
8. Show notifications and unread/read transition.
9. Search a place and save it.
10. Demonstrate AI only for paths that are truly implemented; label stubs honestly.
11. Demonstrate offline/error recovery without exposing logs or credentials.

### Rehearsal acceptance

- [ ] Demo completes inside the allowed presentation time.
- [ ] Reset/seed script produces deterministic accounts and data.
- [ ] Backup network and local fallback plan are documented without faking production behavior.
- [ ] No raw secret, admin console, personal data or unstable debug screen is shown.
- [ ] Presenter knows every documented limitation and recovery step.
- [ ] A second team member can run the demo from the written instructions.

## 14. Production Go/No-Go Checklist

A **GO** requires every item:

- [ ] All automated component and integration suites pass on the release revision.
- [ ] All critical UI/API/business journeys pass in release mode.
- [ ] No open P0/P1; P2 risks have explicit owner acceptance and due date.
- [ ] Real payment integration is complete, or all payment capability is disabled for production.
- [ ] AI stubs are completed or clearly removed/disabled/disclosed.
- [ ] Staging and production use HTTPS, separate data and separate least-privileged secrets.
- [ ] Authorization, privacy, rate limiting, file safety and independent security review are accepted.
- [ ] Monitoring, alerts, runbooks, backups, restore and rollback have execution evidence.
- [ ] Signed release artifact and store declarations are verified.
- [ ] Product owner, engineering, security/operations and business representative sign off.

Any unchecked item means **NO-GO** or a formally documented limited demo—not production-ready.

## 15. Required Deliverables from DeepSeek

1. Updated `PROJECT_AUDIT.md` with final disposition for every finding.
2. Updated `docs/API_INTEGRATION_MATRIX.md` covering every real Flutter network operation.
3. Automated test changes and reports for backend, Flutter, AI and payment demo.
4. Completed UAT results and defect log under `docs/12-uat/`.
5. Completed manual UI results based on `docs/MANUAL_TEST_PLAN.md`.
6. Sanitized command, API, device, security and performance evidence.
7. Updated setup, deployment, rollback, backup and Android release documentation.
8. Reconciled stale feature, defect, signing and test-status claims across the documentation set.
9. Release APK/AAB metadata and hashes, or exact blockers if signing/production input is unavailable.
10. Final completion report using the format below.

## 16. Final Completion Report Template

```markdown
# Vithey Production Test Completion Report

## Decision
- Competition demo: GO / NO-GO / CONDITIONAL
- Production: GO / NO-GO / BLOCKED
- Revision:
- Test window:
- Environments/devices:

## Component status
| Area | Result | Passed/total | Evidence | Blocker/notes |
| --- | --- | ---: | --- | --- |
| Backend | | | | |
| Flutter | | | | |
| AI | | | | |
| Payment | | | | |
| Full-stack integration | | | | |
| Security/privacy | | | | |
| Performance/reliability | | | | |
| Android release | | | | |
| Competition rehearsal | | | | |

## Critical journey results
| Test ID | Journey | Build/device | Result | Evidence/defect |
| --- | --- | --- | --- | --- |

## Defects
| ID | Severity | Component | Reproduction | Impact | Fix/status | Evidence |
| --- | --- | --- | --- | --- | --- | --- |

## Release artifact
- Version/application ID:
- APK path and SHA-256:
- AAB path and SHA-256:
- Signing certificate fingerprint:
- API environment:

## Limitations and accepted risks
| Item | User/business impact | Owner | Decision | Due date |
| --- | --- | --- | --- | --- |

## Sign-off
- Product owner:
- Engineering:
- Security/operations:
- Business/UAT representative:
```

## 17. Current Completeness Assessment and Improvement Backlog

This is the evidence-based status as of 2026-10-07. It is a review snapshot, not a new test run. Evidence comes from `PROJECT_AUDIT.md`, `docs/MANUAL_TEST_PLAN.md`, the current configuration, and the existing UAT/security/deployment reports. Because the working tree contains uncommitted changes, DeepSeek must rerun every release gate on the final revision.

### 17.1 Is the system complete?

**No—not for production.** The local competition demo has a strong technical baseline and may be considered **conditional**, but formal competition acceptance and production readiness are not complete.

| Area | Current evidence | Assessment | What remains |
| --- | --- | --- | --- |
| Backend unit/context tests | `PROJECT_AUDIT.md` records Maven success across 14 modules | Locally passed on the audited working tree | Rerun on final revision; make Testcontainers smoke tests execute in CI |
| Flutter analyzer/tests | Audit records no analyzer issues and 24 passing tests | Locally passed but coverage is thin | Add controller/widget/integration coverage and rerun on final revision |
| API smoke | `docs/MANUAL_TEST_PLAN.md` records 34 PASS / 0 FAIL | Strong local demo evidence | Add negative/authorization cases and CI execution |
| API contract | `docs/API_INTEGRATION_MATRIX.md` maps Flutter calls to backend handlers | Largely mapped | Re-scan after every endpoint/client change and add contract automation |
| Android release artifact | APK built, signed with a local verification key, installed and launched | Suitable only for local release-mode smoke | Owner upload key, production HTTPS values, AAB, upgrade test and real-device E2E |
| Manual UI testing | A detailed manual plan exists | Not fully executed/evidenced | Execute every applicable case on emulator and physical device |
| Maps/Places | Backend key missing; map profile not verified | BLOCKED | Supply restricted Google Places key and test, or disable maps for the submitted build |
| AI | CV generation is real; chat and suggestion paths are documented as stubs | Partial | Complete, disable, or disclose stubs; test privacy, quota and provider failure |
| Payment | Fake provider works for demo | Demo only | Integrate an approved provider or disable payment for production |
| Google sign-in | Current frontend documentation says real; older reports say stub | Evidence conflict | Run real-device/provider E2E and update all stale documentation to one verified status |
| Push notifications | Older reports say FCM is not integrated | Incomplete/unverified | Implement and device-test FCM or explicitly remove it from submitted scope |
| Security | Code review exists; gateway hardening was added | No formal assessment | Run automated scans, authorization tests and independent review/penetration test |
| Performance/reliability | No retained load, soak, failover, backup-restore or rollback execution | Not complete | Establish targets and execute the Phase 5 matrix |
| UAT/business acceptance | UAT results and signatures are empty | Not complete | Assign testers, execute UAT, triage defects and sign off |
| Staging/production | Existing reports state neither environment exists | Not complete | Provision isolated HTTPS staging first, then approved production infrastructure |
| Monitoring/operations | Local Prometheus/Grafana assets exist | Partial | Verify alerts, add an alert receiver, run incident/restore/rollback drills |
| Documentation | New audit and plans exist, but older pages contain stale claims | Inconsistent | Reconcile evidence dates, feature status, bug status and release-signing language |

{% hint style="warning" %}
The recorded 34/34 API smoke result, passing unit tests, and installable APK are valuable evidence, but they do not cover full UI behavior, production providers, security, load, disaster recovery, UAT, or owner-signed distribution.
{% endhint %}

### 17.2 Highest-priority fixes before the competition

Complete these in order:

1. **Freeze one test revision.** Commit or otherwise identify the exact candidate SHA, preserve unrelated work, and rerun backend, Flutter, Python, Compose and release gates on that revision.
2. **Execute the manual competition path.** Use `docs/MANUAL_TEST_PLAN.md` on an Android emulator and a physical phone; retain screenshots, request IDs and defect results.
3. **Resolve Maps/Places.** Provide restricted Android Maps and backend Places credentials, start the map profile and execute map cases; otherwise remove/disable the feature for the competition build.
4. **Validate production-style release configuration.** Build with explicit `APP_ENV=production`, `API_BASE_URL=https://...` and `WS_BASE_URL=wss://...`; never rely on bundled development `.env` values.
5. **Use owner-controlled release signing.** Build and verify the APK/AAB with the permanent upload key, then test clean install and upgrade.
6. **Decide every incomplete feature.** Complete, disable, or clearly disclose AI chat/suggestion stubs, fake payment, FCM, biometrics/2FA and any provider-dependent Google sign-in behavior.
7. **Run formal UAT rehearsal.** Assign a product/business tester, execute all critical cases, fix blocker/high defects and obtain competition go/no-go sign-off.
8. **Prepare a deterministic demo.** Add sanitized seed/reset instructions, two-user chat accounts, COMPANY/STUDENT roles, known job/feed content and a recovery path for provider/network failure.

### 17.3 Production-blocking engineering work

| Priority | Work item | Acceptance evidence |
| --- | --- | --- |
| P0 | Provision isolated HTTPS staging and define the production topology, network boundaries and secret manager | Staging URL, TLS verification, access controls, deployment record and successful release E2E |
| P0 | Replace fake payment or disable production payment | Provider certification/sandbox-to-production evidence, signed callback validation, idempotency and reconciliation tests |
| P0 | Resolve/verify career-service migration and entity consistency | Clean migration + supported upgrade test; no duplicate version or `UserCv` identity mismatch |
| P0 | Complete authorization/BOLA coverage across every resource | Automated cross-user/role tests and independent security review |
| P0 | Complete owner signing and secure release configuration | Verified APK/AAB fingerprints, hashes, package/version, HTTPS endpoints and real-device results |
| P1 | Wire Testcontainers smoke tests and the live API smoke suite into CI | CI log proves tests executed rather than being skipped |
| P1 | Add Flutter integration automation for critical journeys | Repeatable emulator suite for auth, feed, apply, finance gate, chat and logout/data isolation |
| P1 | Validate JWT/session lifecycle and credential-change invalidation | Refresh replay, concurrent 401, logout and password-change regression tests |
| P1 | Add dependency, secret, SAST and container scanning | Required CI checks with high/critical triage policy |
| P1 | Finish operational monitoring and incident response | Alert receiver, actionable alerts, redacted logs and completed incident drill |
| P1 | Execute backup, restore and rollback | Timestamped restore/rollback report with measured RPO/RTO |
| P2 | Run load, soak and provider-failure testing | Agreed latency/error/resource targets and retained reports |
| P2 | Complete accessibility and Khmer/localization verification | Screen-reader, text-scale, contrast, keyboard and Khmer critical-flow evidence |
| P2 | Add deterministic demo seed/reset tooling | One documented command or safe process producing repeatable demo state |

### 17.4 Documentation corrections required

Several older pages predate current working-tree fixes. DeepSeek must compare every claim to the final revision and update all affected documents together. At minimum reconcile:

- Android signing: current Gradle supports `key.properties`, while older bug/final-report pages still say release always uses debug signing. The remaining blocker is the permanent owner key and verified distribution artifact.
- Google sign-in: `docs/07-frontend/07-authentication-flow.md` says it is real, while older scope, user and risk pages call it a stub. Only an executed provider/device test may settle the status.
- Post update: newer API docs/matrix describe `PATCH /posts/{id}` as implemented, while older outstanding-item pages call it missing.
- Gateway identity headers: the current filter strips inbound `X-User-*`; older security observations must be updated while retaining the requirement for service network isolation.
- Test counts/results: older testing pages list fewer Flutter/Java tests or say nothing was executed; distinguish historical documentation runs from the latest audited execution.
- Career migration defects: do not mark the duplicate `V3` or entity mapping resolved until clean-install and upgrade migration evidence exists.
- Deployment status: keep the statement that staging/production do not exist until infrastructure evidence proves otherwise.

### 17.5 Recommended next decision

- For the **competition**: target a **conditional GO** after the eight competition priorities pass, with fake payment and any AI stub visibly disclosed.
- For **production**: remain **NO-GO** until all P0 rows in section 17.3, formal UAT, security assessment, performance/recovery evidence, and operational sign-off are complete.

## 18. Ready-to-Paste DeepSeek Prompt

```text
Act as the senior mobile, backend, QA, security, SRE, and release engineer for the Vithey / AUB Connect repository. Read docs/DEEPSEEK_PRODUCT_COMPLETION_PLAN.md completely and execute it phase by phase. This is a real repository containing a Flutter app, Spring Cloud microservices, FastAPI AI and demo payment services, Docker infrastructure, monitoring, tests, and documentation.

Start by recording the revision, dirty worktree, tools, devices, and a sanitized configuration inventory. Preserve every existing user change and never reveal or commit secrets. Treat every unchecked item as NOT RUN. Do not claim PASS from code inspection, test existence, a generic 2xx response, or a debug-only run. Read section 17 first so that known blockers, evidence conflicts, and priority order are included in the execution plan.

Audit and verify the full vertical path for each feature: Flutter UI and state, validation, API client and token refresh, gateway authentication, service authorization and business logic, persistence/events/storage/providers, error handling, and the final visible UI state. Maintain docs/API_INTEGRATION_MATRIX.md for every Flutter network call.

Run all Java, Flutter, AI, fake-payment, Docker configuration, Testcontainers, runtime smoke, negative API, Android UI/E2E, security, accessibility, reliability, performance, release-build, and competition-rehearsal gates in the plan. Add regression tests before or with fixes when practical. Re-run every affected gate after a change.

Use only PASS, FAIL, BLOCKED, SKIPPED, and NOT RUN as defined by the plan. Preserve sanitized evidence with exact commands, exit codes, revision, environment, expected versus actual behavior, screenshots/logs/request IDs, and artifact hashes. Never invent a production URL, credential, device result, signing result, provider behavior, or test result.

The fake payment provider and documented AI chat/suggestion stubs cannot support an unconditional production GO. Replace them with approved real integrations, disable them for production, or report the exact blocker and limitation. Do not weaken TLS, JWT, authorization, CORS, file validation, or Android release security to make tests pass.

Finish with the exact report in section 16. A production GO is forbidden while any P0/P1 is open, a critical release-mode journey fails, payment remains fake but enabled, AI stubs are presented as real, secrets/debug signing are used, or backup/restore/rollback/monitoring lack execution evidence.
```
