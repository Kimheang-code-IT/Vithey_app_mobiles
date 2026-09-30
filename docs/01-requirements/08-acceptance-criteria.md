# Acceptance Criteria

> Status: Partially complete · Last reviewed: 2026-09-30
> Evidence: `plan.md` §9, `api_docs.md`, `backend/`, `ai_core/`
> **Execution note:** User Acceptance Testing has **not** been executed. All criteria below are the *intended* pass conditions. Test files existing does not mean tests pass. See EVIDENCE-BASIS §10, §12.

## 1. Demo-level acceptance criteria

Derived from the locked demo plan `plan.md` §9.

| ID | Criterion | Given / When / Then | Status |
| --- | --- | --- | --- |
| AC-DEMO-001 | Full stack runs without thrashing | **Given** the Profile M stack started, **when** it runs 15+ minutes, **then** RAM stays within budget and containers do not restart. | Not yet executed |
| AC-DEMO-002 | Multi-user browsing | **Given** ~10 users, **when** they log in and browse, **then** there are no mass `500` responses. | Not yet executed |
| AC-DEMO-003 | Live CV generation | **Given** a seed user with posts, **when** they call CV generate, **then** the draft matches profile/posts. | Not yet executed |
| AC-DEMO-004 | Incomplete profile path | **Given** an empty profile, **when** CV generate is called, **then** an incomplete message is returned without an LLM call. | Not yet executed |
| AC-DEMO-005 | Concurrency cap | **Given** a generation is in flight, **when** a second is requested, **then** a clear busy error is returned. | Not yet executed |
| AC-DEMO-006 | Chat stub | **Given** a chat message, **when** sent, **then** a stub reply is returned with no GDCE/RAG call. | Not yet executed |
| AC-DEMO-007 | Flutter end-to-end CV | **Given** `USE_MOCK_AI=false`, **when** the user taps Auto-Create CV, **then** the live API draft renders. | Not yet executed |

## 2. Authentication acceptance criteria

| ID | Given / When / Then | Requirement | Status |
| --- | --- | --- | --- |
| AC-AUTH-001 | **Given** a unique email, **when** register is submitted validly, **then** `201` with user identity is returned. | FR-AUTH-001 | Not independently verified |
| AC-AUTH-002 | **Given** valid credentials, **when** login is submitted, **then** `200` with access and refresh tokens is returned. | FR-AUTH-002 | Not independently verified |
| AC-AUTH-003 | **Given** a valid refresh token, **when** refresh is called, **then** new tokens are returned. | FR-AUTH-003 | Not independently verified |
| AC-AUTH-004 | **Given** an expired access token, **when** a request gets `401`, **then** the client refreshes once and retries, otherwise logs out. | FR-AUTH-003 | Not independently verified |
| AC-AUTH-005 | **Given** valid student ID + university email, **when** verify is called, **then** the user gains `STUDENT`. | FR-AUTH-009 | Not independently verified |
| AC-AUTH-006 | **Given** a duplicate university email, **when** verify is called, **then** the request is rejected. | FR-AUTH-009 | Not independently verified |

## 3. Profile & search acceptance criteria

| ID | Given / When / Then | Requirement | Status |
| --- | --- | --- | --- |
| AC-USER-001 | **Given** authentication, **when** `GET /users/me` is called, **then** the private profile is returned. | FR-USER-001 | Not independently verified |
| AC-USER-002 | **Given** a partial update, **when** `PATCH /users/me` is called, **then** only provided fields change. | FR-USER-003 | Not independently verified |
| AC-USER-003 | **Given** a query shorter than 2 chars, **when** user search is called, **then** no results (or a validation error) are returned. | FR-USER-006 | Not independently verified |

## 4. Content acceptance criteria

| ID | Given / When / Then | Requirement | Status |
| --- | --- | --- | --- |
| AC-CONTENT-001 | **Given** a valid token, **when** `GET /posts` is called, **then** a paginated list with `meta` is returned. | FR-CONTENT-001 | Not independently verified |
| AC-CONTENT-002 | **Given** an uploaded `file_id`, **when** a poster post is created, **then** `201` with post data is returned. | FR-CONTENT-002 | Not independently verified |
| AC-CONTENT-003 | **Given** an owned post, **when** delete is called, **then** `204` is returned. | FR-CONTENT-004 | Not independently verified |
| AC-CONTENT-004 | **Given** an existing post, **when** `PATCH /posts/{id}` is called, **then** the current implementation returns `404` (documented gap). | FR-CONTENT-009 | Verified gap |

## 5. Career acceptance criteria

| ID | Given / When / Then | Requirement | Status |
| --- | --- | --- | --- |
| AC-CAREER-001 | **Given** a CV file, **when** an application is submitted, **then** `201` with `PENDING` status is returned. | FR-CAREER-001 | Not independently verified |
| AC-CAREER-002 | **Given** a repeated request with the same `Idempotency-Key`, **when** resubmitted, **then** no duplicate application is created. | FR-CAREER-007 | Not independently verified |
| AC-CAREER-003 | **Given** a non-poster, **when** status update is called, **then** the request is denied. | FR-CAREER-005 | Not independently verified |

## 6. Finance acceptance criteria

| ID | Given / When / Then | Requirement | Status |
| --- | --- | --- | --- |
| AC-FINANCE-001 | **Given** a non-`STUDENT`, **when** finance endpoints are called, **then** `403` is returned. | FR-FINANCE-005 | Not independently verified |
| AC-FINANCE-002 | **Given** a `STUDENT`, **when** payments are requested, **then** only their own payments are returned. | FR-FINANCE-001 | Not independently verified |
| AC-FINANCE-003 | **Given** a `STUDENT`, **when** alerts are requested, **then** upcoming deadlines are returned. | FR-FINANCE-003 | Not independently verified |

## 7. Chat acceptance criteria

| ID | Given / When / Then | Requirement | Status |
| --- | --- | --- | --- |
| AC-CHAT-001 | **Given** a new peer, **when** a message request is created, **then** it is `PENDING` until accepted. | FR-CHAT-002 | Not independently verified |
| AC-CHAT-002 | **Given** an accepted conversation, **when** a message is sent over STOMP, **then** the peer receives it in real time. | FR-CHAT-006 | Not independently verified |
| AC-CHAT-003 | **Given** no connectivity, **when** a message is sent, **then** it is queued in the Isar outbox and retried later. | FR-CHAT-008 | Not independently verified |

## 8. AI acceptance criteria

| ID | Given / When / Then | Requirement | Status |
| --- | --- | --- | --- |
| AC-AI-001 | **Given** a message, **when** `POST /ai/chat` is called, **then** a stub Markdown reply and `session_id` are returned. | FR-AI-001 | Not independently verified |
| AC-AI-002 | **Given** a stream request, **when** it starts, **then** events arrive as `meta` → `token`* → `done`. | FR-AI-002 | Not independently verified |
| AC-AI-003 | **Given** insufficient profile data, **when** CV generate is called, **then** `incomplete_profile=true` is returned with no LLM call. | FR-AI-011 | Not independently verified |
| AC-AI-004 | **Given** a rich profile, **when** CV generate is called, **then** an `AiCvDraft` with `quality_score` is returned. | FR-AI-006 | Not independently verified |
| AC-AI-005 | **Given** a mid-stream cancel, **when** `DELETE /ai/chat/requests/{id}` is called, **then** the stream terminates and may report `cancelled`. | FR-AI-004 | Not independently verified |
| AC-AI-006 | **Given** a missing LLM key, **when** CV generate is called, **then** a clear error/degraded health is returned. | FR-AI-006 | Not independently verified |

## 9. Notifications acceptance criteria

| ID | Given / When / Then | Requirement | Status |
| --- | --- | --- | --- |
| AC-NOTIF-001 | **Given** notifications exist, **when** the inbox is loaded, **then** a paginated list with read state is returned. | FR-NOTIF-001 | Not independently verified |
| AC-NOTIF-002 | **Given** unread items, **when** read-all is called, **then** the unread count becomes zero. | FR-NOTIF-003 | Not independently verified |
| AC-NOTIF-003 | **Given** a domain event, **when** consumed, **then** a matching notification is created. | FR-NOTIF-006 | Not independently verified |

## 10. Map acceptance criteria

| ID | Given / When / Then | Requirement | Status |
| --- | --- | --- | --- |
| AC-MAP-001 | **Given** valid coordinates, **when** nearby is requested, **then** place cards are returned. | FR-MAP-001 | Not independently verified |
| AC-MAP-002 | **Given** no Places key, **when** map endpoints are called, **then** a clear config error is returned. | FR-MAP-005 | Not independently verified |
| AC-MAP-003 | **Given** `--profile map` is not set, **when** the demo starts, **then** map-service does not run. | FR-MAP-006 | Not independently verified |

## 11. Non-functional acceptance criteria

| ID | Given / When / Then | Requirement | Status |
| --- | --- | --- | --- |
| AC-NFR-001 | **Given** the demo stack, **when** `docker stats` is checked, **then** total RAM stays within the Profile M budget. | NFR-PERF/SCAL | Not independently verified |
| AC-NFR-002 | **Given** a protected route without a token, **when** called, **then** `401` is returned. | NFR-SEC-001 | Not independently verified |
| AC-NFR-003 | **Given** a non-`STUDENT`, **when** finance is called, **then** `403` is returned. | NFR-SEC-006 | Not independently verified |
| AC-NFR-004 | **Given** rate limits, **when** exceeded, **then** `429` is returned. | NFR-PERF-004 | Not independently verified |

## 12. UAT governance

| Item | Status |
| --- | --- |
| UAT plan | Does not exist → TBD — Requires confirmation. |
| UAT execution log | Does not exist → TBD — Requires confirmation. |
| Sign-off | Not present → TBD — Requires confirmation. |

## 13. Related documents

- [`06-use-cases.md`](06-use-cases.md)
- [`07-user-stories.md`](07-user-stories.md)
- [`09-requirements-traceability-matrix.md`](09-requirements-traceability-matrix.md)
- [`../00-project-overview/02-project-objectives.md`](../00-project-overview/02-project-objectives.md)
