# Document Index (Master Documentation Homepage)

> Status: Verified (structure) · Last reviewed: 2026-09-30 · Product: **Vithey**
> This is the single entry point for the Vithey documentation package. All statements are drawn from repository evidence; verification/status tags follow the documented conventions.

## How to use this index

- **Status** values: `Verified` (evidence-based), `Partially complete` (has TBDs), `Not executed` (governance artefact only), `Template` (to be filled by stakeholders).
- Every document carries its own `> Status:` header and inline `[VERIFIED] / [INFERRED] / [PLANNED] / [TBD]` tags.
- Legacy reference material (kept in the repository under `docs/_shared`) is **preserved in the repository** and treated as *planned* input, not as implemented truth.

## Recommended reading order

1. **Everyone:** [01-project-overview](01-project-overview.md) → [03-project-scope](03-project-scope.md) → [20-final-report/01-executive-summary](../20-final-report/01-executive-summary.md).
2. **Engineers:** [03-system-design/01-system-architecture](../03-system-design/01-system-architecture.md) → [08-backend/01-backend-architecture](../08-backend/01-backend-architecture.md) → [09-ai/01-ai-overview](../09-ai/01-ai-overview.md) → [06-api/01-api-overview](../06-api/01-api-overview.md) → [05-database/01-database-overview](../05-database/01-database-overview.md).
3. **Mobile devs:** [07-frontend/01-flutter-architecture](../07-frontend/01-flutter-architecture.md) → module docs.
4. **DevOps/Ops:** [13-devops/01-devops-overview](../13-devops/01-devops-overview.md) → [14-deployment/01-deployment-architecture](../14-deployment/01-deployment-architecture.md) → [16-operations/01-operation-manual](../16-operations/01-operation-manual.md).
5. **QA/Security:** [11-testing/01-test-strategy](../11-testing/01-test-strategy.md) → [10-security/01-security-overview](../10-security/01-security-overview.md) → [12-uat/01-UAT-plan](../12-uat/01-UAT-plan.md).
6. **Bank/Management:** [20-final-report/01-executive-summary](../20-final-report/01-executive-summary.md) → [02-project-management/02-action-plan](../02-project-management/02-action-plan.md) → [18-risk-management/01-risk-register](../18-risk-management/01-risk-register.md).

---

## 00 — Project Overview

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-project-overview](01-project-overview.md) | What Vithey is; components; demo scope | Verified | All |
| [02-project-objectives](02-project-objectives.md) | Objectives and success criteria | Partially complete | Business/PM |
| [03-project-scope](03-project-scope.md) | In/out of scope (demo vs excluded) | Verified | All |
| [04-stakeholders](04-stakeholders.md) | Stakeholder map | Partially complete | Business/PM |
| [05-team-roles-responsibilities](05-team-roles-responsibilities.md) | Team roles (inferred from git) | Partially complete | PM |
| [06-glossary](06-glossary.md) | Terms and abbreviations | Verified | All |
| [07-document-index](07-document-index.md) | This master index | Verified | All |

## 01 — Requirements

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-business-requirements-BRD](../01-requirements/01-business-requirements-BRD.md) | Business background, rules, success criteria | Partially complete | Business/Bank |
| [02-software-requirements-SRS](../01-requirements/02-software-requirements-SRS.md) | SRS with FR/NFR IDs | Partially complete | Dev/QA |
| [03-functional-requirements](../01-requirements/03-functional-requirements.md) | Functional requirements per module | Partially complete | Dev/QA |
| [04-non-functional-requirements](../01-requirements/04-non-functional-requirements.md) | NFRs (perf, security, availability) | Partially complete | Dev/QA/Ops |
| [05-user-roles-permissions](../01-requirements/05-user-roles-permissions.md) | RBAC matrix | Verified | Dev/QA |
| [06-use-cases](../01-requirements/06-use-cases.md) | Use cases and flows | Verified | QA/Business |
| [07-user-stories](../01-requirements/07-user-stories.md) | User stories with acceptance notes | Partially complete | PM/QA |
| [08-acceptance-criteria](../01-requirements/08-acceptance-criteria.md) | Acceptance criteria | Partially complete | Business/QA |
| [09-requirements-traceability-matrix](../01-requirements/09-requirements-traceability-matrix.md) | Requirement → impl/API/DB/test mapping | Partially complete | QA/PM |

## 02 — Project Management

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-project-plan](../02-project-management/01-project-plan.md) | Plan and approach | Partially complete | PM |
| [02-action-plan](../02-project-management/02-action-plan.md) | Bank-friendly action plan (150 rows) | Partially complete | Bank/PM |
| [03-milestones](../02-project-management/03-milestones.md) | Milestones | Partially complete | PM |
| [04-work-breakdown-structure](../02-project-management/04-work-breakdown-structure.md) | WBS | Partially complete | PM |
| [05-team-assignment](../02-project-management/05-team-assignment.md) | Assignments (inferred) | Partially complete | PM |
| [06-project-timeline](../02-project-management/06-project-timeline.md) | Timeline (evidence-derived) | Partially complete | PM |
| [07-project-status-report](../02-project-management/07-project-status-report.md) | Status snapshot | Partially complete | PM/Bank |
| [08-change-request-log](../02-project-management/08-change-request-log.md) | Evidenced changes | Partially complete | PM |
| [09-decision-log](../02-project-management/09-decision-log.md) | Key decisions | Verified | PM/Architects |
| [10-meeting-minutes](../02-project-management/10-meeting-minutes/README.md) | No minutes found; template | Not executed | PM |

## 03 — System Design

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-system-architecture](../03-system-design/01-system-architecture.md) | End-to-end architecture (Mermaid) | Verified | Dev/Architects |
| [02-high-level-design-HLD](../03-system-design/02-high-level-design-HLD.md) | HLD | Verified | Architects |
| [03-low-level-design-LLD](../03-system-design/03-low-level-design-LLD.md) | LLD | Verified | Dev |
| [04-component-diagram](../03-system-design/04-component-diagram.md) | Component diagram | Verified | Architects |
| [05-data-flow-diagram](../03-system-design/05-data-flow-diagram.md) | Data flows | Verified | Dev |
| [06-sequence-diagrams](../03-system-design/06-sequence-diagrams.md) | Key sequences | Verified | Dev |
| [07-network-architecture](../03-system-design/07-network-architecture.md) | Ports/network topology | Verified | DevOps |
| [08-technology-stack](../03-system-design/08-technology-stack.md) | Stack with versions | Verified | All |

## 04 — UI/UX

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-ui-ux-overview](../04-ui-ux/01-ui-ux-overview.md) | UI/UX approach | Verified | Design/PM |
| [02-user-flow](../04-ui-ux/02-user-flow.md) | User flows | Verified | Design/QA |
| [03-screen-inventory](../04-ui-ux/03-screen-inventory.md) | Screen/route inventory | Verified | Design/QA |
| [04-design-system](../04-ui-ux/04-design-system.md) | Tokens & components | Verified | Design/Dev |
| [05-navigation-flow](../04-ui-ux/05-navigation-flow.md) | Navigation + gating | Verified | Design/Dev |
| [06-responsive-design](../04-ui-ux/06-responsive-design.md) | Layout/responsiveness | Partially complete | Design |
| [07-figma-reference](../04-ui-ux/07-figma-reference.md) | Figma links (none found) | Requires confirmation | Design |

## 05 — Database

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-database-overview](../05-database/01-database-overview.md) | DB inventory & ownership | Verified | Dev/DBA |
| [02-ERD](../05-database/02-ERD.md) | ER diagrams (Mermaid) | Verified | Dev/DBA |
| [03-database-schema](../05-database/03-database-schema.md) | Per-service schema | Verified | Dev/DBA |
| [04-table-dictionary](../05-database/04-table-dictionary.md) | Table/column dictionary | Verified | Dev/DBA |
| [05-data-dictionary](../05-database/05-data-dictionary.md) | Field semantics | Verified | Dev/DBA |
| [06-migration-strategy](../05-database/06-migration-strategy.md) | Flyway + known defects | Verified | Dev |
| [07-indexing-performance](../05-database/07-indexing-performance.md) | Indexes & performance notes | Verified | Dev/DBA |
| [08-backup-restore](../05-database/08-backup-restore.md) | Backup/restore (no automation) | Partially complete | DBA/Ops |
| [09-data-retention](../05-database/09-data-retention.md) | Retention/erasure (policy TBD) | Requires confirmation | DBA/Legal |

## 06 — API

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-api-overview](../06-api/01-api-overview.md) | Conventions & envelope | Verified | Dev |
| [02-api-gateway](../06-api/02-api-gateway.md) | Gateway routes & filters | Verified | Dev |
| [03-authentication-api](../06-api/03-authentication-api.md) | Auth endpoints | Verified | Dev |
| [04-user-profile-api](../06-api/04-user-profile-api.md) | Profile/settings endpoints | Verified | Dev |
| [05-content-api](../06-api/05-content-api.md) | Posts/comments/reactions/follow | Verified | Dev |
| [06-file-api](../06-api/06-file-api.md) | File upload/download | Verified | Dev |
| [07-career-api](../06-api/07-career-api.md) | CV/job application endpoints | Verified | Dev |
| [08-finance-api](../06-api/08-finance-api.md) | Fees/payments endpoints | Verified | Dev |
| [09-chat-api](../06-api/09-chat-api.md) | Conversations/messages | Verified | Dev |
| [10-notification-api](../06-api/10-notification-api.md) | Notifications/devices | Verified | Dev |
| [11-map-api](../06-api/11-map-api.md) | Places endpoints | Verified | Dev |
| [12-ai-api](../06-api/12-ai-api.md) | AI endpoints (CV real, chat stub) | Verified | Dev |
| [13-websocket-api](../06-api/13-websocket-api.md) | STOMP/WebSocket | Verified | Dev |
| [14-error-codes](../06-api/14-error-codes.md) | Error envelope & codes | Verified | Dev |
| [15-openapi-swagger](../06-api/15-openapi-swagger.md) | OpenAPI/Swagger (no spec file) | Partially complete | Dev |

## 07 — Frontend

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-flutter-architecture](../07-frontend/01-flutter-architecture.md) | Flutter architecture | Verified | Mobile dev |
| [02-project-structure](../07-frontend/02-project-structure.md) | Folder structure | Verified | Mobile dev |
| [03-routing](../07-frontend/03-routing.md) | Routes & gating | Verified | Mobile dev |
| [04-state-management](../07-frontend/04-state-management.md) | GetX state/DI | Verified | Mobile dev |
| [05-network-layer](../07-frontend/05-network-layer.md) | Dio/interceptors | Verified | Mobile dev |
| [06-local-storage](../07-frontend/06-local-storage.md) | Isar/secure storage/prefs | Verified | Mobile dev |
| [07-authentication-flow](../07-frontend/07-authentication-flow.md) | Auth flow | Verified | Mobile dev/QA |
| [08-error-handling](../07-frontend/08-error-handling.md) | Error/loading patterns | Verified | Mobile dev |
| [modules/auth](../07-frontend/modules/auth.md) | Auth module | Verified | Mobile dev |
| [modules/home-feed](../07-frontend/modules/home-feed.md) | Feed module | Verified | Mobile dev |
| [modules/profile](../07-frontend/modules/profile.md) | Profile module | Verified | Mobile dev |
| [modules/jobs-cv](../07-frontend/modules/jobs-cv.md) | Jobs/CV module | Verified | Mobile dev |
| [modules/finance](../07-frontend/modules/finance.md) | Finance module | Verified | Mobile dev |
| [modules/chat](../07-frontend/modules/chat.md) | Chat module | Verified | Mobile dev |
| [modules/chatbot](../07-frontend/modules/chatbot.md) | Chatbot module | Verified | Mobile dev |
| [modules/notifications](../07-frontend/modules/notifications.md) | Notifications module | Verified | Mobile dev |
| [modules/search](../07-frontend/modules/search.md) | Search module | Verified | Mobile dev |
| [modules/settings](../07-frontend/modules/settings.md) | Settings module | Verified | Mobile dev |
| [modules/map](../07-frontend/modules/map.md) | Map module | Verified | Mobile dev |

## 08 — Backend

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-backend-architecture](../08-backend/01-backend-architecture.md) | Backend architecture | Verified | Backend dev |
| [02-microservice-architecture](../08-backend/02-microservice-architecture.md) | Microservices model | Verified | Backend dev |
| [03-service-discovery](../08-backend/03-service-discovery.md) | Eureka | Verified | Backend/DevOps |
| [04-config-server](../08-backend/04-config-server.md) | Spring Cloud Config (native) | Verified | Backend/DevOps |
| [05-api-gateway](../08-backend/05-api-gateway.md) | Gateway internals | Verified | Backend dev |
| [06-event-driven-architecture](../08-backend/06-event-driven-architecture.md) | RabbitMQ events | Verified | Backend dev |
| [07-cache-strategy](../08-backend/07-cache-strategy.md) | Redis usage | Verified | Backend dev |
| [08-error-handling](../08-backend/08-error-handling.md) | Error handling | Verified | Backend dev |
| [services/auth-service](../08-backend/services/auth-service.md) | Auth service | Verified | Backend dev |
| [services/user-profile-service](../08-backend/services/user-profile-service.md) | User profile service | Verified | Backend dev |
| [services/file-service](../08-backend/services/file-service.md) | File service | Verified | Backend dev |
| [services/content-service](../08-backend/services/content-service.md) | Content service | Verified | Backend dev |
| [services/career-service](../08-backend/services/career-service.md) | Career service | Verified | Backend dev |
| [services/finance-service](../08-backend/services/finance-service.md) | Finance service | Verified | Backend dev |
| [services/chat-service](../08-backend/services/chat-service.md) | Chat service | Verified | Backend dev |
| [services/notification-service](../08-backend/services/notification-service.md) | Notification service | Verified | Backend dev |
| [services/map-service](../08-backend/services/map-service.md) | Map service | Verified | Backend dev |

## 09 — AI

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-ai-overview](../09-ai/01-ai-overview.md) | AI scope (real CV vs stub chat) | Verified | Dev/PM |
| [02-ai-architecture](../09-ai/02-ai-architecture.md) | ai_core architecture | Verified | Dev |
| [03-ai-core](../09-ai/03-ai-core.md) | Package & CLI | Verified | Dev |
| [04-llm-integration](../09-ai/04-llm-integration.md) | LLM client/provider | Verified | Dev |
| [05-cv-generation](../09-ai/05-cv-generation.md) | CV pipeline | Verified | Dev |
| [06-chatbot](../09-ai/06-chatbot.md) | Chat stub behaviour | Verified | Dev |
| [07-prompt-management](../09-ai/07-prompt-management.md) | Prompts | Verified | Dev |
| [08-ai-data-flow](../09-ai/08-ai-data-flow.md) | Data flow | Verified | Dev |
| [09-rate-limit-cache](../09-ai/09-rate-limit-cache.md) | Limits & cache | Verified | Dev/Ops |
| [10-ai-error-handling](../09-ai/10-ai-error-handling.md) | Errors & retries | Verified | Dev |
| [11-ai-limitations](../09-ai/11-ai-limitations.md) | Limitations | Verified | Dev/PM |

## 10 — Security

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-security-overview](../10-security/01-security-overview.md) | Security posture | Verified | Security/Dev |
| [02-authentication](../10-security/02-authentication.md) | Authentication | Verified | Security/Dev |
| [03-authorization-RBAC](../10-security/03-authorization-RBAC.md) | RBAC | Verified | Security/Dev |
| [04-JWT-security](../10-security/04-JWT-security.md) | JWT | Verified | Security/Dev |
| [05-password-security](../10-security/05-password-security.md) | Password/token storage | Verified | Security/Dev |
| [06-data-security](../10-security/06-data-security.md) | Data protection | Verified | Security/Dev |
| [07-api-security](../10-security/07-api-security.md) | API security | Verified | Security/Dev |
| [08-secrets-management](../10-security/08-secrets-management.md) | Secrets (names only) | Verified | DevOps/Security |
| [09-security-checklist](../10-security/09-security-checklist.md) | Checklist | Verified | Security/Dev |
| [10-vulnerability-assessment](../10-security/10-vulnerability-assessment.md) | **Not yet formally assessed** | Not executed | Security |
| [11-security-review-report](../10-security/11-security-review-report.md) | **Not yet formally assessed** | Not executed | Security |

## 11 — Testing

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-test-strategy](../11-testing/01-test-strategy.md) | Strategy | Partially complete | QA |
| [02-test-plan](../11-testing/02-test-plan.md) | Plan | Partially complete | QA |
| [03-test-cases](../11-testing/03-test-cases.md) | Test cases | Partially complete | QA |
| [04-unit-testing](../11-testing/04-unit-testing.md) | Unit tests inventory | Verified | QA/Dev |
| [05-integration-testing](../11-testing/05-integration-testing.md) | Context/IT inventory | Verified | QA/Dev |
| [06-api-testing](../11-testing/06-api-testing.md) | API test approach | Partially complete | QA |
| [07-mobile-testing](../11-testing/07-mobile-testing.md) | Flutter testing | Partially complete | QA/Mobile |
| [08-performance-testing](../11-testing/08-performance-testing.md) | **Not performed** | Not executed | QA/Ops |
| [09-security-testing](../11-testing/09-security-testing.md) | **Not performed** | Not executed | Security/QA |
| [10-regression-testing](../11-testing/10-regression-testing.md) | Regression approach | Partially complete | QA |
| [11-bug-report](../11-testing/11-bug-report.md) | Defect log | Partially complete | QA/Dev |
| [12-test-results](../11-testing/12-test-results.md) | Results (**not executed**) | Not executed | QA/PM |
| [13-test-summary-report](../11-testing/13-test-summary-report.md) | Summary (**no verdict**) | Not executed | PM/QA |

## 12 — UAT

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-UAT-plan](../12-uat/01-UAT-plan.md) | UAT plan | Not executed | QA/Business |
| [02-UAT-test-cases](../12-uat/02-UAT-test-cases.md) | Proposed UAT cases | Not executed | QA/Business |
| [03-UAT-results](../12-uat/03-UAT-results.md) | **Not executed** | Not executed | Business |
| [04-UAT-issues](../12-uat/04-UAT-issues.md) | **Not executed** | Not executed | QA |
| [05-UAT-signoff](../12-uat/05-UAT-signoff.md) | **Template — no sign-off** | Template | Business |

## 13 — DevOps

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-devops-overview](../13-devops/01-devops-overview.md) | DevOps overview | Verified | DevOps |
| [02-docker-architecture](../13-devops/02-docker-architecture.md) | Dockerfiles | Verified | DevOps |
| [03-docker-compose](../13-devops/03-docker-compose.md) | Compose stacks | Verified | DevOps |
| [04-environment-configuration](../13-devops/04-environment-configuration.md) | Env vars (names) | Verified | DevOps |
| [05-CI-CD](../13-devops/05-CI-CD.md) | CI/CD flow | Verified | DevOps |
| [06-github-actions](../13-devops/06-github-actions.md) | Workflows | Verified | DevOps |
| [07-image-registry](../13-devops/07-image-registry.md) | GHCR | Verified | DevOps |
| [08-release-process](../13-devops/08-release-process.md) | Release process | Partially complete | DevOps/PM |

## 14 — Deployment

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-deployment-architecture](../14-deployment/01-deployment-architecture.md) | Deployment topology | Verified | DevOps |
| [02-environment-setup](../14-deployment/02-environment-setup.md) | Env setup | Verified | DevOps |
| [03-development-deployment](../14-deployment/03-development-deployment.md) | Local dev/demo | Verified | DevOps/Dev |
| [04-staging-deployment](../14-deployment/04-staging-deployment.md) | **Staging does not exist** | Not executed | DevOps |
| [05-production-deployment](../14-deployment/05-production-deployment.md) | **Not deployed** (+ recommendation) | Not executed | DevOps/Bank |
| [06-deployment-checklist](../14-deployment/06-deployment-checklist.md) | Checklist | Partially complete | DevOps |
| [07-rollback-plan](../14-deployment/07-rollback-plan.md) | Rollback | Partially complete | DevOps |
| [08-disaster-recovery](../14-deployment/08-disaster-recovery.md) | DR | Requires confirmation | DevOps/Ops |

## 15 — Monitoring

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-monitoring-overview](../15-monitoring/01-monitoring-overview.md) | Monitoring overview | Verified | Ops |
| [02-prometheus](../15-monitoring/02-prometheus.md) | Prometheus targets | Verified | Ops |
| [03-grafana](../15-monitoring/03-grafana.md) | Grafana dashboards | Verified | Ops |
| [04-loki-logging](../15-monitoring/04-loki-logging.md) | Loki/Promtail | Verified | Ops |
| [05-alerting](../15-monitoring/05-alerting.md) | Alerts (**no Alertmanager**) | Partially complete | Ops |
| [06-health-checks](../15-monitoring/06-health-checks.md) | Health endpoints | Verified | Ops/Dev |
| [07-incident-response](../15-monitoring/07-incident-response.md) | Incident response | Partially complete | Ops |

## 16 — Operations

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-operation-manual](../16-operations/01-operation-manual.md) | Operations manual | Verified | Ops |
| [02-start-stop-system](../16-operations/02-start-stop-system.md) | Start/stop runbook | Verified | Ops |
| [03-health-check](../16-operations/03-health-check.md) | Health runbook | Verified | Ops |
| [04-troubleshooting](../16-operations/04-troubleshooting.md) | Troubleshooting | Verified | Ops/Dev |
| [05-backup-restore](../16-operations/05-backup-restore.md) | Backup/restore (manual) | Partially complete | Ops/DBA |
| [06-maintenance](../16-operations/06-maintenance.md) | Maintenance | Partially complete | Ops |
| [07-support-escalation](../16-operations/07-support-escalation.md) | Escalation (no formal process) | Requires confirmation | Ops/PM |

## 17 — User Documentation

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-user-manual](../17-user-documentation/01-user-manual.md) | End-user manual | Verified | End user |
| [02-login-registration](../17-user-documentation/02-login-registration.md) | Sign-up/sign-in | Verified | End user |
| [03-profile-guide](../17-user-documentation/03-profile-guide.md) | Profile | Verified | End user |
| [04-feed-guide](../17-user-documentation/04-feed-guide.md) | Feed | Verified | End user |
| [05-job-cv-guide](../17-user-documentation/05-job-cv-guide.md) | Jobs/CV | Verified | End user |
| [06-finance-guide](../17-user-documentation/06-finance-guide.md) | Finance (read-only; payment stub) | Verified | End user |
| [07-chat-guide](../17-user-documentation/07-chat-guide.md) | Chat | Verified | End user |
| [08-ai-assistant-guide](../17-user-documentation/08-ai-assistant-guide.md) | AI (CV real; chat stub) | Verified | End user |
| [09-map-guide](../17-user-documentation/09-map-guide.md) | Map | Verified | End user |
| [10-FAQ](../17-user-documentation/10-FAQ.md) | FAQ | Verified | End user |

## 18 — Risk Management

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-risk-register](../18-risk-management/01-risk-register.md) | Risks (25) | Partially complete | PM/Bank |
| [02-issue-log](../18-risk-management/02-issue-log.md) | Issues (26) | Partially complete | PM/Dev |
| [03-known-limitations](../18-risk-management/03-known-limitations.md) | Limitations (21) | Verified | All |
| [04-technical-debt](../18-risk-management/04-technical-debt.md) | Technical debt (20) | Verified | Dev/PM |
| [05-mitigation-plan](../18-risk-management/05-mitigation-plan.md) | Mitigations (22) | Partially complete | PM |

## 19 — Handover

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-handover-plan](../19-handover/01-handover-plan.md) | Handover plan | Template | PM/Bank |
| [02-handover-checklist](../19-handover/02-handover-checklist.md) | Checklist | Template | PM/Bank |
| [03-source-code-handover](../19-handover/03-source-code-handover.md) | Code/repo handover | Verified | Dev |
| [04-environment-handover](../19-handover/04-environment-handover.md) | Environment handover | Partially complete | DevOps |
| [05-credential-handover-checklist](../19-handover/05-credential-handover-checklist.md) | Credentials (names only) | Template | IT/Security |
| [06-training-plan](../19-handover/06-training-plan.md) | Training (**not conducted**) | Not executed | PM |
| [07-knowledge-transfer](../19-handover/07-knowledge-transfer.md) | KT plan | Template | PM |
| [08-handover-signoff](../19-handover/08-handover-signoff.md) | **Template — no sign-off** | Template | Bank |

## 20 — Final Report

| Document | Purpose | Status | Audience |
|---|---|---|---|
| [01-executive-summary](../20-final-report/01-executive-summary.md) | Executive summary | Partially complete | Bank/Management |
| [02-project-background](../20-final-report/02-project-background.md) | Background | Verified | Bank |
| [03-project-objectives](../20-final-report/03-project-objectives.md) | Objectives | Verified | Bank |
| [04-project-scope](../20-final-report/04-project-scope.md) | Scope (agreed vs built) | Partially complete | Bank |
| [05-project-team](../20-final-report/05-project-team.md) | Team (inferred) | Partially complete | Bank |
| [06-solution-overview](../20-final-report/06-solution-overview.md) | Solution overview | Verified | Bank |
| [07-system-architecture](../20-final-report/07-system-architecture.md) | Architecture summary | Verified | Bank/Technical |
| [08-implemented-features](../20-final-report/08-implemented-features.md) | Implemented vs stub | Verified | Bank |
| [09-action-plan](../20-final-report/09-action-plan.md) | Action plan summary | Partially complete | Bank |
| [10-project-progress](../20-final-report/10-project-progress.md) | Progress (**no invented %**) | Partially complete | Bank |
| [11-testing-results](../20-final-report/11-testing-results.md) | **Not executed** | Not executed | Bank/QA |
| [12-security-summary](../20-final-report/12-security-summary.md) | **Not yet assessed** | Not executed | Bank/Security |
| [13-deployment-status](../20-final-report/13-deployment-status.md) | **Local only** | Verified | Bank/DevOps |
| [14-risks-issues](../20-final-report/14-risks-issues.md) | Risks & issues | Partially complete | Bank |
| [15-outstanding-items](../20-final-report/15-outstanding-items.md) | Outstanding items | Partially complete | Bank |
| [16-lessons-learned](../20-final-report/16-lessons-learned.md) | Lessons learned | Partially complete | PM |
| [17-recommendations](../20-final-report/17-recommendations.md) | Recommendations | Verified | Bank/PM |
| [18-conclusion](../20-final-report/18-conclusion.md) | Conclusion | Verified | Bank |
| [19-final-acceptance](../20-final-report/19-final-acceptance.md) | **Acceptance template — no signature** | Template | Bank |

---

## Documentation status summary

| Category | Status |
|---|---|
| 00 Project overview | Verified (stakeholders/team partially complete) |
| 01 Requirements | Partially complete (contractual/business inputs TBD) |
| 02 Project management | Partially complete (owners/dates inferred) |
| 03 System design | Verified |
| 04 UI/UX | Verified (Figma TBD) |
| 05 Database | Verified (backup/retention TBD) |
| 06 API | Verified |
| 07 Frontend | Verified |
| 08 Backend | Verified |
| 09 AI | Verified |
| 10 Security | Code-level findings only — **Not yet formally assessed** |
| 11 Testing | Inventory verified; execution **not performed** |
| 12 UAT | Plan only — **not executed** |
| 13 DevOps | Verified |
| 14 Deployment | Local only — staging/production do not exist |
| 15 Monitoring | Verified (no Alertmanager) |
| 16 Operations | Verified (backup/escalation TBD) |
| 17 User documentation | Verified (stubs flagged) |
| 18 Risk management | Verified (owners TBD) |
| 19 Handover | Templates — handover **not executed** |
| 20 Final report | Partially complete (UAT/security/acceptance TBD) |

## Known missing information (open TBDs)

- Contractual client/legal entity, product owner, and signatories.
- Approved scope baseline and weighting (needed for any completion %).
- UAT execution and sign-off; formal security assessment; staging/production environments.
- Owner/date for every open defect and risk item.
- Data retention/erasure policy and RPO/RTO targets.
- Figma/design source links; iOS release readiness; Khmer full localisation; accessibility target.
- Published OpenAPI specification artefact.

> For the full, live list see [`../20-final-report/15-outstanding-items.md`](../20-final-report/15-outstanding-items.md).
