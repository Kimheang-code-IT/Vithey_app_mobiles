# Test Cases

> Status: Verified baseline (catalogue) · Last reviewed: 2026-09-30
> Evidence: `backend/**/src/test/java`, `vithey_app/test/`, `ai_core/tests/`, `backend/scripts/smoke-api.ps1`
> **Execution status:** none of these were executed during this documentation task. Result column = `Test implemented — current execution result not independently verified.` (abbreviated `TI-CERUNIV`). No case is marked "Passed".

Result legend: `TI-CERUNIV` = Test implemented — current execution result not independently verified.

## 1. Backend unit tests (19 files, Surefire)

| TC | Unit under test | Test file | Expected behaviour | Result |
| --- | --- | --- | --- | --- |
| UT-AUTH-01 | `JwtProvider` | `auth/security/JwtProviderTest.java` | Create+parse access token includes `sub`, `email`, `roles`; expiry = 900s | TI-CERUNIV |
| UT-AUTH-02 | `AuthService.changePassword` | `auth/service/AuthServiceChangePasswordTest.java` | Correct current password re-hashes; wrong password rejected | TI-CERUNIV |
| UT-AUTH-03 | `AuthService.register` + mail | `auth/service/AuthServiceRegisterMailTest.java` | Verification mail sent with hashed token stored | TI-CERUNIV |
| UT-AUTH-04 | `PasswordResetService` | `auth/service/PasswordResetServiceTest.java` | Single-use, expiring reset token; password re-hashed | TI-CERUNIV |
| UT-GW-01 | `JwtValidator` | `api-gateway/security/JwtValidatorTest.java` | Valid HMAC token → subject/email/roles | TI-CERUNIV |
| UT-PROF-01 | `ProfileService` | `user-profile/service/ProfileServiceTest.java` | Profile read/update rules | TI-CERUNIV |
| UT-PROF-02 | `UserSearchService` | `user-profile/service/UserSearchServiceTest.java` | Name search + pagination | TI-CERUNIV |
| UT-CONT-01 | `PostService` | `content/service/PostServiceTest.java` | Post create/feed rules | TI-CERUNIV |
| UT-CONT-02 | `CommentService` | `content/service/CommentServiceTest.java` | Comment rules | TI-CERUNIV |
| UT-CONT-03 | `FollowService` | `content/service/FollowServiceTest.java` | Follow/unfollow, no self-follow | TI-CERUNIV |
| UT-CAR-01 | `JobApplicationService` | `career/service/JobApplicationServiceTest.java` | Apply/idempotency/status rules | TI-CERUNIV |
| UT-CHAT-01 | `ConversationService` | `chat/service/ConversationServiceTest.java` | Request/accept/message rules | TI-CERUNIV |
| UT-FIN-01 | `PaymentService` | `finance/service/PaymentServiceTest.java` | Payment listing/scoping | TI-CERUNIV |
| UT-NOTIF-01 | `NotificationService` | `notification/service/NotificationServiceTest.java` | Notification creation/read rules | TI-CERUNIV |
| UT-FILE-01 | `FileValidationService` | `file/service/FileValidationServiceTest.java` | MIME allow-list, size cap, filename sanitisation | TI-CERUNIV |
| UT-MAP-01 | `GooglePlacesClient` | `map/GooglePlacesClientTest.java` | Places API mapping/error handling | TI-CERUNIV |
| UT-MAP-02 | `NearbySearchService` | `map/NearbySearchServiceTest.java` | Nearby search | TI-CERUNIV |
| UT-MAP-03 | `PlaceCacheService` | `map/PlaceCacheServiceTest.java` | Search/detail TTL + degrade | TI-CERUNIV |
| UT-MAP-04 | `PlaceFavoriteService` | `map/PlaceFavoriteServiceTest.java` | Favourites | TI-CERUNIV |

## 2. Backend context tests (11 files, H2)

| TC | Service | Test file | Expected | Result |
| --- | --- | --- | --- | --- |
| CT-GW-01 | api-gateway | `ApiGatewayContextTest.java` | Context loads on H2 | TI-CERUNIV |
| CT-AUTH-01 | auth-service | `AuthServiceContextTest.java` | Context loads | TI-CERUNIV |
| CT-PROF-01 | user-profile | `UserProfileServiceContextTest.java` | Context loads | TI-CERUNIV |
| CT-CONT-01 | content | `ContentServiceContextTest.java` | Context loads | TI-CERUNIV |
| CT-CAR-01 | career | `CareerServiceContextTest.java` | Context loads | TI-CERUNIV |
| CT-CHAT-01 | chat | `ChatServiceContextTest.java` | Context loads | TI-CERUNIV |
| CT-FIN-01 | finance | `FinanceServiceContextTest.java` | Context loads | TI-CERUNIV |
| CT-NOTIF-01 | notification | `NotificationServiceContextTest.java` | Context loads | TI-CERUNIV |
| CT-FILE-01 | file | `FileServiceContextTest.java` | Context loads | TI-CERUNIV |
| CT-CFG-01 | config-server | `ConfigServerContextTest.java` | Context loads | TI-CERUNIV |
| CT-EUR-01 | eureka-server | `EurekaServerContextTest.java` | Context loads | TI-CERUNIV |

> map-service has no context test (no test-support dependency). [VERIFIED]

## 3. Backend smoke integration tests (11 files, Testcontainers, Docker-gated)

Each boots the service and asserts `GET /actuator/health` → `{"status":"UP"}`. Not run by
`mvn test` (no Failsafe).

| TC | Service | Container set | Result |
| --- | --- | --- | --- |
| IT-GW-01 | api-gateway | Redis | TI-CERUNIV |
| IT-AUTH-01 | auth-service | PostgreSQL + RabbitMQ | TI-CERUNIV |
| IT-PROF-01 | user-profile | PostgreSQL + RabbitMQ | TI-CERUNIV |
| IT-CONT-01 | content | PostgreSQL + RabbitMQ | TI-CERUNIV |
| IT-CAR-01 | career | PostgreSQL + RabbitMQ | TI-CERUNIV |
| IT-CHAT-01 | chat | PostgreSQL + RabbitMQ + Redis | TI-CERUNIV |
| IT-FIN-01 | finance | PostgreSQL + RabbitMQ | TI-CERUNIV |
| IT-NOTIF-01 | notification | PostgreSQL + RabbitMQ | TI-CERUNIV |
| IT-FILE-01 | file | PostgreSQL + MinIO | TI-CERUNIV |
| IT-CFG-01 | config-server | (native config) | TI-CERUNIV |
| IT-EUR-01 | eureka-server | (none) | TI-CERUNIV |

## 4. ai_core tests (11 pytest files)

| TC | Module | Test file | Expected | Result |
| --- | --- | --- | --- | --- |
| AI-01 | HTTP API | `test_api.py` | Envelope, health, error mapping | TI-CERUNIV |
| AI-02 | Flutter routes | `test_flutter_routes.py` | `/api/v1/ai/**` auth + envelope | TI-CERUNIV |
| AI-03 | extraction | `test_extraction.py` | JSON-mode extraction + cache | TI-CERUNIV |
| AI-04 | dedupe | `test_dedupe.py` | Duplicate removal | TI-CERUNIV |
| AI-05 | generation | `test_generation.py` | Prompt build + LLM call | TI-CERUNIV |
| AI-06 | normalize | `test_normalize.py` | Deterministic CV normalisation | TI-CERUNIV |
| AI-07 | quality | `test_quality.py` | 100-pt scoring rubric | TI-CERUNIV |
| AI-08 | DeepSeek client | `test_deepseek_client.py` | Client retries/timeouts | TI-CERUNIV |
| AI-09 | rate limit | `test_ratelimit.py` | 120/60s + per-IP 30/min | TI-CERUNIV |
| AI-10 | service | `test_service.py` | End-to-end service orchestration | TI-CERUNIV |
| AI-11 | CLI | `test_cli.py` | `extract`/`generate`/`serve` CLI | TI-CERUNIV |

## 5. Flutter tests (3 files)

| TC | Focus | Test file | Expected | Result |
| --- | --- | --- | --- | --- |
| FE-01 | `AppLogo` widget renders | `test/widget_test.dart` | Widget found once | TI-CERUNIV |
| FE-02 | Notification preferences model | `test/data/models/notification_preferences_test.dart` | Serialisation/defaults | TI-CERUNIV |
| FE-03 | Notification utils | `test/modules/home/notification/notification_utils_test.dart` | Formatting/helpers | TI-CERUNIV |

## 6. End-to-end cases (`smoke-api.ps1`)

These run against the live demo stack through the gateway; each line prints PASS/FAIL. Full
script: `backend/scripts/smoke-api.ps1`.

| TC | Step | Expected | Result |
| --- | --- | --- | --- |
| E2E-01 | Gateway health | `UP` | Not executed here |
| E2E-02 | ai_core health | `healthy` | Not executed here |
| E2E-03 | Register USER | token returned | Not executed here |
| E2E-04 | Login | 200 | Not executed here |
| E2E-05 | `GET /auth/me` | user_id present | Not executed here |
| E2E-06 | `GET`/`PATCH /users/me` | 200 | Not executed here |
| E2E-07 | Create post + feed | post_id + list | Not executed here |
| E2E-08 | Comment + reaction | 2xx/204 | Not executed here |
| E2E-09 | `/ai/chat`, `/ai/sessions`, regenerate | 2xx | Not executed here |
| E2E-10 | `/ai/cv/generate`, `/ai/cv/suggest` | 2xx | Not executed here |
| E2E-11 | `GET /fees` before verify | **403** | Not executed here |
| E2E-12 | `POST /students/verify` | verified=true | Not executed here |
| E2E-13 | Refresh (STUDENT JWT) | 200 | Not executed here |
| E2E-14 | `GET /fees` after verify | 200 | Not executed here |
| E2E-15 | Payments / conversations / requests | 2xx | Not executed here |
| E2E-16 | Peer message request → accept → message | 2xx | Not executed here |
| E2E-17 | Notifications + unread count | 2xx | Not executed here |
| E2E-18 | CV library, places history | 200/404/503 tolerated | Not executed here |
| E2E-19 | Logout | 200/204 | Not executed here |
| E2E-20 | No retired `vithey-ai-service` container | absent/exited | Not executed here |

## 7. Notes

- Every backend/Flutter/ai_core case is **implementation-only** evidence: the test file exists.
- E2E cases are **proposed/derived** from the actual script steps and are also unexecuted here.
- See [12-test-results.md](12-test-results.md) for the recorded run status and
  [13-test-summary-report.md](13-test-summary-report.md) for the overall position.

## 8. Cross-references

- [04-unit-testing.md](04-unit-testing.md) · [05-integration-testing.md](05-integration-testing.md) · [06-api-testing.md](06-api-testing.md) · [07-mobile-testing.md](07-mobile-testing.md)
