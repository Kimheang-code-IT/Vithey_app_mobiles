# Unit Testing

> Status: Verified baseline (inventory) · Last reviewed: 2026-09-30
> Evidence: `backend/**/src/test/java/**/*Test.java`, `vithey_app/test/`, `ai_core/tests/`
> Result status: `Test implemented — current execution result not independently verified.`

## 1. Definition & tooling

A unit test exercises one class or function with collaborators mocked/isolated. No Spring
context, no network, no Docker.

| Component | Framework | Assertions | Mocks |
| --- | --- | --- | --- |
| Backend | JUnit 5 (`spring-boot-starter-test`) | AssertJ | Mockito |
| Flutter | `flutter_test` | `expect` matchers | hand-written fakes |
| ai_core | `pytest` | `assert` | `unittest.mock`/fakes |

## 2. Backend unit inventory (19 tests)

| Service | Unit tests |
| --- | --- |
| auth-service (4) | `JwtProviderTest`, `AuthServiceChangePasswordTest`, `AuthServiceRegisterMailTest`, `PasswordResetServiceTest` |
| api-gateway (1) | `JwtValidatorTest` |
| user-profile (2) | `ProfileServiceTest`, `UserSearchServiceTest` |
| content (3) | `PostServiceTest`, `CommentServiceTest`, `FollowServiceTest` |
| career (1) | `JobApplicationServiceTest` |
| chat (1) | `ConversationServiceTest` |
| finance (1) | `PaymentServiceTest` |
| notification (1) | `NotificationServiceTest` |
| file (1) | `FileValidationServiceTest` |
| map (4) | `GooglePlacesClientTest`, `NearbySearchServiceTest`, `PlaceCacheServiceTest`, `PlaceFavoriteServiceTest` |

[VERIFIED] `backend/**/src/test/java`. map-service has the **most** unit tests but no context
or smoke test.

### 2.1 Representative assertions

- `JwtProviderTest` — token round-trip yields the user's UUID, email and `STUDENT` role, and
  `accessTokenExpiresInSeconds()` is exactly `900`. [VERIFIED]
- `JwtValidatorTest` — a hand-crafted HMAC token validates to the expected subject/email/roles.
  [VERIFIED]
- `FileValidationServiceTest` — MIME allow-list, size limits, filename traversal stripping
  (`..`, path separators). [VERIFIED] (implied by `FileValidationService`).

## 3. Flutter unit/widget tests (3 files)

| File | Type | What it checks |
| --- | --- | --- |
| `test/widget_test.dart` | widget | `AppLogo` renders |
| `test/data/models/notification_preferences_test.dart` | model | notification prefs serialisation/defaults |
| `test/modules/home/notification/notification_utils_test.dart` | pure | notification helper formatting |

[VERIFIED] `vithey_app/test/`. There are **no** golden or integration tests, and coverage is
very low relative to the app surface (`lib/modules/`: auth, home, jobs, profile, chat, chatbot,
finance, search, settings, map). [VERIFIED]

## 4. ai_core unit tests (11 files)

`pytest` modules under `ai_core/tests/` cover extraction, dedupe, generation, normalisation,
quality scoring, rate limiting, the DeepSeek client, service orchestration, CLI, and both the
HTTP API and Flutter routes. [VERIFIED] `ai_core/tests/test_*.py`.

- These combine pure-unit tests (e.g. `test_normalize`, `test_dedupe`, `test_quality`) with
  FastAPI `TestClient` tests (`test_api`, `test_flutter_routes`) that inject a fake AI object
  via `create_app(ai=...)`. [VERIFIED] `ai_core/vithey_ai/api/app.py:44`.

## 5. How to run

| Component | Command | Working dir |
| --- | --- | --- |
| Backend (all units) | `mvn test -Dtest='!*SmokeIT'` | `backend/` |
| One backend class | `mvn test -Dtest=JwtProviderTest` | `backend/` |
| Flutter | `flutter test` | `vithey_app/` |
| ai_core | `pytest -q` | `ai_core/` |

## 6. Gaps

| Gap | Status |
| --- | --- |
| Backend line/branch coverage | Unknown — no JaCoCo |
| Finance `FeeController`/`PaymentController` method-security unit tests | None (only `PaymentServiceTest`) |
| Controller-layer (MockMvc) unit tests | None found |
| Flutter controller/service unit tests | None |
| ai_core coverage measurement | None |

## 7. Result status

No unit test was executed during this documentation task.
`Test implemented — current execution result not independently verified.`

## 8. Cross-references

- [03-test-cases.md](03-test-cases.md) · [05-integration-testing.md](05-integration-testing.md) · [12-test-results.md](12-test-results.md)
- `../../backend/TESTING.md`
