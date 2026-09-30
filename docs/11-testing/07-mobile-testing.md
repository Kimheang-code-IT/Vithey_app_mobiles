# Mobile Testing

> Status: Verified baseline (inventory) · Last reviewed: 2026-09-30
> Evidence: `vithey_app/test/`, `vithey_app/lib/`, `vithey_app/pubspec.yaml`, `.github/workflows/ci-promote-dev.yml`
> Result status: `Test implemented — current execution result not independently verified.`

## 1. Platform constraints

- Android only for testing (emulator or physical device). Web/Chrome is unsupported (Isar,
  secure storage, camera). [VERIFIED] `vithey_app/README.md`, EVIDENCE-BASIS §7.
- The emulator reaches the host at `10.0.2.2`; a physical device needs the PC LAN IP.
  [VERIFIED] `.env.example`.
- `.env` is a declared pubspec asset and gitignored — copy it before `flutter test`/`run`.
  [VERIFIED] AGENTS.md.

## 2. Automated tests (real inventory)

| File | Type | Checks |
| --- | --- | --- |
| `test/widget_test.dart` | widget | `AppLogo` renders once |
| `test/data/models/notification_preferences_test.dart` | unit | notification preferences serialisation/defaults |
| `test/modules/home/notification/notification_utils_test.dart` | unit | notification formatting helpers |

[VERIFIED] `vithey_app/test/`. **Three files total.** No integration tests, no golden tests,
no widget tests for auth/feed/chat/finance/map. [VERIFIED]

## 3. Lint / static analysis gate

`flutter analyze --no-fatal-infos` is the CI lint gate. [VERIFIED] `ci-promote-dev.yml`.
Run it before tests:

```powershell
copy .env.example .env
flutter pub get
flutter analyze --no-fatal-infos
flutter test
```

## 4. Manual test areas (device/emulator)

Because automation is thin, these are the manual areas a tester must cover. Status is
**Not performed** in this task.

| ID | Area | Screens (from `lib/modules/`) | Status |
| --- | --- | --- | --- |
| MT-01 | Onboarding / splash / auth funnel | auth | Not performed |
| MT-02 | Register / login / forgot / reset / verify | auth | Not performed |
| MT-03 | Home feed (posts, reactions, comments) | home | Not performed |
| MT-04 | Jobs browse / apply / CV upload | jobs | Not performed |
| MT-05 | Profile view/edit, avatar, skills | profile | Not performed |
| MT-06 | Peer chat (request, accept, send, media) | chat | Not performed |
| MT-07 | AI chatbot (chat stub, CV generate/suggest) | chatbot | Not performed |
| MT-08 | Student finance (fees/payments) | finance | Not performed |
| MT-09 | Search (users, posts) | search | Not performed |
| MT-10 | Settings (notifications, theme, language) | settings | Not performed |
| MT-11 | Map / places | map | Not performed |
| MT-12 | Offline handling / connectivity banner | `core/utils/connectivity_wrapper.dart` | Not performed |
| MT-13 | Secure-storage token persistence + 401 refresh | `core/network/dio_client.dart` | Not performed |

## 5. Known stubs / disabled features to exclude or mark

| Feature | State | Evidence |
| --- | --- | --- |
| Google auth | UI-only; throws unless mock | EVIDENCE-BASIS §7 |
| FCM push | Commented out; no Firebase packages | EVIDENCE-BASIS §7 |
| 2FA / biometric | "coming soon" | settings UI |
| Chat call simulation | Simulation only | EVIDENCE-BASIS §7 |
| AI chat | Stub replies | EVIDENCE-BASIS §6 |

## 6. Release readiness

- Android **release builds currently sign with debug keys** (`android/app/build.gradle` TODO).
  [VERIFIED] — a release/QA concern, not a functional test.
- No iOS build/test evidence. [TBD] TBD — Requires confirmation.

## 7. Gaps

| Gap | Impact |
| --- | --- |
| 3 automated tests for a full superapp | High regression risk |
| No integration_driver/golden tests | UI regressions undetected |
| Mock-first flags (`USE_MOCK_*`) can mask live-API issues | Test config must set them false |
| No accessibility testing | A11y unverified |
| No localization tests (Khmer is a stored preference only) | i18n unverified |

## 8. Result status

No Flutter test or `flutter analyze` run was performed during this documentation task.
`Test implemented — current execution result not independently verified.`

## 9. Cross-references

- [01-test-strategy.md](01-test-strategy.md) · [03-test-cases.md](03-test-cases.md) §5 · [10-regression-testing.md](10-regression-testing.md)
- `../12-uat/02-UAT-test-cases.md` (screen-derived UAT cases)
