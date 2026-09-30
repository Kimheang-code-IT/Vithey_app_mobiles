# Non-Functional Requirements

> Status: Verified baseline · Last reviewed: 2026-09-30
> Evidence: `backend/`, `ai_core/`, `vithey_app/`, `monitoring/`, `plan.md`, EVIDENCE-BASIS
> ID convention: `NFR-<AREA>-NNN`. Verification results are not claimed; see §14.

## 1. Security

| ID | Requirement | Target / evidence | Status |
| --- | --- | --- | --- |
| NFR-SEC-001 | All protected APIs shall require a valid Bearer JWT. | `JwtAuthenticationGlobalFilter`; `PublicPathMatcher` | Verified (implemented) |
| NFR-SEC-002 | JWTs shall be HMAC-signed with access TTL 15m and refresh TTL 7d. | `config-repo/application.yml` (`VITHEY_ACCESS_TOKEN_TTL`, `VITHEY_REFRESH_TOKEN_TTL`) | Verified (implemented) |
| NFR-SEC-003 | Passwords shall be stored using bcrypt. | `PasswordEncoderConfig` | Verified (implemented) |
| NFR-SEC-004 | Refresh, reset, and email-verification tokens shall be stored hashed. | `TokenHash`, migrations | Verified (implemented) |
| NFR-SEC-005 | Secrets shall never be committed; only `.env.example` files are tracked. | EVIDENCE-BASIS §13 | Verified (implemented) |
| NFR-SEC-006 | The system shall enforce role-based access for `STUDENT` finance endpoints. | `@PreAuthorize` on fee/payment controllers | Verified (implemented) |
| NFR-SEC-007 | A formal security assessment shall be performed before production. | None found | Not yet formally assessed → TBD — Requires confirmation. |
| NFR-SEC-008 | Device tokens shall be stored in platform secure storage. | `flutter_secure_storage` | Verified (implemented) |

## 2. Performance

| ID | Requirement | Target / evidence | Status |
| --- | --- | --- | --- |
| NFR-PERF-001 | Chat/map hot data shall be cached in Redis with TTLs. | chat recent 24h; map search 5m, detail 24h | Verified (implemented) |
| NFR-PERF-002 | LLM calls shall be bounded by input caps and retries. | `MAX_POSTS_PER_BUILD`, `MAX_CONTENT_CHARS`, `MAX_TOKENS=3000`, `MAX_RETRIES=2` | Verified (implemented) |
| NFR-PERF-003 | Extraction results shall be cached by content hash. | `cache.py` (512 entries) | Verified (implemented) |
| NFR-PERF-004 | Gateway routes shall be rate-limited. | Redis `RequestRateLimiter` | Verified (implemented) |
| NFR-PERF-005 | The AI CV generation latency target is < 60s per generation for the demo. | `plan.md` §7.2 | [PLANNED] not independently measured |
| NFR-PERF-006 | Chat API responses shall be streamed for perceived responsiveness. | SSE `/ai/chat/stream` | Verified (implemented) |

## 3. Scalability & capacity

| ID | Requirement | Target / evidence | Status |
| --- | --- | --- | --- |
| NFR-SCAL-001 | The demo shall support ~10 concurrent users on one PC. | `plan.md` §0 | Verified (design target) |
| NFR-SCAL-002 | Container memory shall be capped per service. | `docker-compose.demo.yml`, `backend/.env.example` | Verified (implemented) |
| NFR-SCAL-003 | Database connections per service shall be pooled and capped. | `DB_POOL_MAX=5` default | Verified (implemented) |
| NFR-SCAL-004 | The system shall horizontally scale beyond the demo. | No design evidence | TBD — Requires confirmation. |

## 4. Availability & resilience

| ID | Requirement | Target / evidence | Status |
| --- | --- | --- | --- |
| NFR-AVAIL-001 | Services shall expose health endpoints. | `/actuator/health`, `ai_core /health` | Verified (implemented) |
| NFR-AVAIL-002 | Inter-service calls shall use a circuit breaker. | Resilience4j via OpenFeign | Verified (implemented) |
| NFR-AVAIL-003 | Map shall degrade gracefully on Redis/Places failure. | `PlaceCacheService` | Verified (implemented) |
| NFR-AVAIL-004 | The system shall provide production-grade high availability. | None; explicitly out of scope | [PLANNED] out of demo scope |
| NFR-AVAIL-005 | Staging/production environments shall exist. | Staging (does not exist); Production (does not exist) | TBD — Requires confirmation. |

## 5. Maintainability & quality

| ID | Requirement | Target / evidence | Status |
| --- | --- | --- | --- |
| NFR-MAINT-001 | Backend shall be a Maven multi-module build. | `backend/pom.xml` | Verified (implemented) |
| NFR-MAINT-002 | Services shall follow a standard package layout. | `docs/Prompt Backend/COMMON_CONTEXT.md` | Verified (convention) |
| NFR-MAINT-003 | API payloads shall be snake_case with a standard envelope. | `api_docs.md` §1 | Verified (implemented) |
| NFR-MAINT-004 | Runtime config shall be centralised and versioned. | `config-repo/*.yml` | Verified (implemented) |
| NFR-MAINT-005 | Code shall pass `flutter analyze --no-fatal-infos` and backend tests in CI. | `.github/workflows/` | Verified (CI gate) |

## 6. Compatibility

| ID | Requirement | Target / evidence | Status |
| --- | --- | --- | --- |
| NFR-COMPAT-001 | Backend shall run on Java 21. | `AGENTS.md`, `backend/pom.xml` | Verified (implemented) |
| NFR-COMPAT-002 | AI engine shall run on Python 3.10+. | `ai_core/pyproject.toml` | Verified (implemented) |
| NFR-COMPAT-003 | Flutter app shall target Android (emulator or device). | `vithey_app/README.md` | Verified (implemented) |
| NFR-COMPAT-004 | Web/Chrome shall be unsupported. | Isar/secure-storage/camera constraints | Verified (constraint) |
| NFR-COMPAT-005 | iOS support status. | No evidence of iOS build/test | TBD — Requires confirmation. |

## 7. Observability

| ID | Requirement | Target / evidence | Status |
| --- | --- | --- | --- |
| NFR-OBS-001 | Services shall expose Prometheus metrics. | `/actuator/prometheus` | Verified (implemented) |
| NFR-OBS-002 | Prometheus shall scrape 8 services. | `monitoring/prometheus/prometheus.yml` | Verified (implemented) |
| NFR-OBS-003 | Grafana shall provision dashboards. | `monitoring/grafana/dashboards/` (4 dashboards) | Verified (implemented) |
| NFR-OBS-004 | Logs shall be aggregated via Loki/Promtail (168h retention). | `monitoring/loki/`, `promtail/` | Verified (implemented) |
| NFR-OBS-005 | Alerts shall be routed to an Alertmanager. | No Alertmanager configured | Not implemented → TBD — Requires confirmation. |
| NFR-OBS-006 | Request tracing shall propagate `X-Request-ID`. | `RequestIdGlobalFilter` | Verified (implemented) |

## 8. Data management

| ID | Requirement | Target / evidence | Status |
| --- | --- | --- | --- |
| NFR-DATA-001 | Each service shall own its database. | `backend/services/*/.../db/migration/` | Verified (implemented) |
| NFR-DATA-002 | Schema changes shall be applied via Flyway; applied migrations shall not be edited. | `AGENTS.md`, migrations | Verified (convention) |
| NFR-DATA-003 | Hibernate shall validate the schema (no auto-DDL). | `ddl-auto: validate` | Verified (implemented) |
| NFR-DATA-004 | Known migration/entity defects shall be resolved. | DD-01..DD-04 in SRS §5.1 | Not done → TBD — Requires confirmation. |
| NFR-DATA-005 | Demo data retention shall be bounded. | `plan.md` §3.4 (last 50 msgs / 7 days) | [PLANNED] demo setting |

## 9. Cost control

| ID | Requirement | Target / evidence | Status |
| --- | --- | --- | --- |
| NFR-COST-001 | Chat shall not incur LLM cost (stub only). | `chat_service.py` always calls `stub_reply` | Verified (implemented) |
| NFR-COST-002 | LLM calls shall be rate-limited (120/60s). | `ratelimit.py` | Verified (implemented) |
| NFR-COST-003 | Identical content shall not be billed twice. | extraction cache | Verified (implemented) |
| NFR-COST-004 | Resource consumption shall be bounded on a single PC. | `plan.md` §3 | Verified (design) |

## 10. Usability

| ID | Requirement | Target / evidence | Status |
| --- | --- | --- | --- |
| NFR-USAB-001 | The app shall provide light and dark themes. | theme files; competition requirement | Verified (implemented) |
| NFR-USAB-002 | The app shall support English UI; Khmer shall be a stored preference. | `AppStrings`; EVIDENCE-BASIS §7 | Verified (implemented) |
| NFR-USAB-003 | English and Khmer CV output shall be supported (`en`\|`km`). | `api_docs.md` §10 | Verified (implemented) |
| NFR-USAB-004 | Full Khmer localisation via `.arb` resources. | No `.arb` files | Not implemented → TBD — Requires confirmation. |
| NFR-USAB-005 | Accessibility features shall be provided. | Client placeholder only | [PLANNED] not in scope |
| NFR-USAB-006 | Two-factor authentication and biometrics shall be provided. | Client placeholders off | [PLANNED] not in scope |

## 11. Localisation & internationalisation

| ID | Requirement | Target / evidence | Status |
| --- | --- | --- | --- |
| NFR-I18N-001 | Backend `en`/`km` handling shall follow the settings preference. | `api_docs.md` §4 | Verified (implemented) |
| NFR-I18N-002 | All JSON field names shall be snake_case regardless of locale. | `application.yml` Jackson config | Verified (implemented) |

## 12. Compliance & privacy

| ID | Requirement | Target / evidence | Status |
| --- | --- | --- | --- |
| NFR-COMP-001 | CV files shall be owner-restricted for download. | `GET /files/{id}/download` | Verified (implemented) |
| NFR-COMP-002 | Users shall be able to block/report abusive users. | chat-service | Verified (implemented) |
| NFR-COMP-003 | Data-protection/regulatory obligations shall be identified. | None found | TBD — Requires confirmation. |

## 13. Testability

| ID | Requirement | Target / evidence | Status |
| --- | --- | --- | --- |
| NFR-TEST-001 | Backend shall have unit and context tests per service. | `backend/TESTING.md` | Verified (implemented) |
| NFR-TEST-002 | Smoke integration tests shall exist (Docker-gated). | `*SmokeIT`, Testcontainers | Verified (implemented) |
| NFR-TEST-003 | `ai_core` shall have a pytest suite. | `ai_core/tests/` (12 files) | Verified (implemented) |
| NFR-TEST-004 | The Flutter suite shall be expanded. | Only 3 test files exist | Partial |
| NFR-TEST-005 | Smoke tests shall run in the default build. | Not wired to failsafe | Not implemented → TBD — Requires confirmation. |

## 14. Verification status

No test suite, load test, security scan, or monitoring result was executed during this
documentation task. All "Verified (implemented)" tags indicate a code/config artefact
exists; they do not assert runtime success. See EVIDENCE-BASIS §10, §12.

## 15. Related documents

- [`03-functional-requirements.md`](03-functional-requirements.md)
- [`09-requirements-traceability-matrix.md`](09-requirements-traceability-matrix.md)
- [`../00-project-overview/03-project-scope.md`](../00-project-overview/03-project-scope.md)
