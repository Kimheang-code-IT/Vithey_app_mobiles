# Use Cases

> Status: Verified baseline · Last reviewed: 2026-09-30
> Evidence: `api_docs.md`, `backend/services/`, `ai_core/vithey_ai/api/flutter_routes.py`, `plan.md`
> ID convention: `UC-<MODULE>-NNN`. Each use case cites the interface it is based on. Behaviour described is the intended contract; runtime execution was not performed for this document.

## 1. Actors

| Actor | Role | Description |
| --- | --- | --- |
| Guest | — | Unauthenticated visitor |
| User | `USER` | Registered general user |
| Student | `STUDENT` | Verified student |
| Company | `COMPANY` | Job poster / recruiter |
| Admin | `ADMIN` | Backend-only administrator |
| LLM Provider | — | External LLM API used by `ai_core` |
| Places Provider | — | Google Places used by map-service |

## 2. Use case index

| ID | Name | Primary actor | Service |
| --- | --- | --- | --- |
| UC-AUTH-001 | Register an account | Guest | auth-service |
| UC-AUTH-002 | Log in and obtain tokens | Guest | auth-service |
| UC-AUTH-003 | Refresh or log out | User | auth-service |
| UC-AUTH-004 | Verify student status | User | auth-service |
| UC-USER-001 | View and edit profile | User | user-profile-service |
| UC-USER-002 | Search for people | User | user-profile-service |
| UC-CONTENT-001 | Browse the feed | User | content-service |
| UC-CONTENT-002 | Create a post with media | User | file-service + content-service |
| UC-CAREER-001 | Apply to a job | User | file-service + career-service |
| UC-CAREER-002 | Review applicants | Company | career-service |
| UC-FINANCE-001 | View payments and fee alerts | Student | finance-service |
| UC-CHAT-001 | Start a peer conversation | User | chat-service |
| UC-CHAT-002 | Exchange realtime messages | User | chat-service |
| UC-AI-001 | Generate a CV | User | ai_core |
| UC-AI-002 | Chat with the AI assistant | User | ai_core |
| UC-NOTIF-001 | Manage notifications | User | notification-service |
| UC-MAP-001 | Find nearby places | User | map-service |

## 3. Detailed use cases

### UC-AUTH-001 — Register an account

| Field | Detail |
| --- | --- |
| Primary actor | Guest |
| Precondition | None; user has a valid email/phone |
| Trigger | User submits the registration form |
| Interfaces | `POST /auth/register` [VERIFIED] `api_docs.md` §3 |
| Main flow | 1. Client sends email, phone, password, `full_name`, `role` (`USER`\|`COMPANY`). 2. Service validates and creates the user with bcrypt password. 3. Service publishes `user.registered`. 4. Service returns `201` with the user identity. |
| Alternative | `409` if email/phone already exists; `400` on validation failure. |
| Postcondition | User exists with `USER` or `COMPANY` role; profile is seeded asynchronously. |
| Related | FR-AUTH-001, FR-AUTH-010 |

### UC-AUTH-002 — Log in and obtain tokens

| Field | Detail |
| --- | --- |
| Primary actor | Guest |
| Precondition | Account exists |
| Interfaces | `POST /auth/login` [VERIFIED] `api_docs.md` §3 |
| Main flow | 1. Client sends `email_or_phone` + password. 2. Service verifies password. 3. Service returns `user` + `tokens` (`access_token`, `refresh_token`, `expires_in=900`). |
| Alternative | `401` on bad credentials. |
| Postcondition | Client stores tokens in secure storage. |
| Related | FR-AUTH-002, NFR-SEC-001, NFR-SEC-008 |

### UC-AUTH-003 — Refresh or log out

| Field | Detail |
| --- | --- |
| Primary actor | User |
| Precondition | Valid refresh token |
| Interfaces | `POST /auth/refresh`, `POST /auth/logout` [VERIFIED] `api_docs.md` §3 |
| Main flow | 1a. On refresh: service issues new tokens. 1b. On logout: service invalidates the refresh token and returns `204`. |
| Alternative | Client refreshes **once** on `401`, then logs out if it fails. [VERIFIED] `api_docs.md` §1 |
| Related | FR-AUTH-003, FR-AUTH-004 |

### UC-AUTH-004 — Verify student status

| Field | Detail |
| --- | --- |
| Primary actor | User |
| Precondition | Authenticated |
| Interfaces | `POST /students/verify` [VERIFIED] `api_docs.md` §3 |
| Main flow | 1. Client submits `student_id` and `university_email`. 2. Service records verification and grants `STUDENT`. 3. Service publishes `student.verified`. |
| Alternative | Duplicate university email rejected (unique constraint). |
| Postcondition | User gains finance access. |
| Related | FR-AUTH-009, FR-FINANCE-005 |

### UC-USER-001 — View and edit profile

| Field | Detail |
| --- | --- |
| Primary actor | User |
| Interfaces | `GET /users/me`, `PATCH /users/me`, `PATCH /users/me/avatar`, `GET/PATCH /users/me/settings` [VERIFIED] `api_docs.md` §4 |
| Main flow | 1. Client loads own profile. 2. User edits fields or uploads an avatar. 3. Service persists and publishes `profile.updated`. |
| Related | FR-USER-001..005, FR-USER-007 |

### UC-USER-002 — Search for people

| Field | Detail |
| --- | --- |
| Primary actor | User |
| Interfaces | `GET /users/search?search=&page=&limit=` (min length 2) [VERIFIED] `api_docs.md` §4 |
| Main flow | 1. Client sends a query (debounced). 2. Service returns paginated matches via trigram-backed search. |
| Related | FR-USER-006 |

### UC-CONTENT-001 — Browse the feed

| Field | Detail |
| --- | --- |
| Primary actor | User |
| Interfaces | `GET /posts` (+ reactions/follow) [VERIFIED] `api_docs.md` §6 |
| Main flow | 1. Client requests the paginated feed. 2. Service returns posts with counts and `user_reacted`. 3. User may react, comment, or follow. |
| Related | FR-CONTENT-001, FR-CONTENT-006..008 |

### UC-CONTENT-002 — Create a post with media

| Field | Detail |
| --- | --- |
| Primary actor | User |
| Interfaces | `POST /files/upload` then `POST /posts` [VERIFIED] `api_docs.md` §6, §14 |
| Main flow | 1. Client uploads media (`POSTER` or `VIDEO`) and receives `file_id`. 2. Client creates a post referencing `media_file_id`. 3. Service stores the post and publishes `post.created`. |
| Alternative | Job posts use `type=JOB` with `job_meta` (no media). |
| Related | FR-CONTENT-002, FR-FILE-001 |

### UC-CAREER-001 — Apply to a job

| Field | Detail |
| --- | --- |
| Primary actor | User |
| Precondition | Authenticated; a job post exists |
| Interfaces | `POST /files/upload` (`CV`) → optional `PUT /users/me/cv` → `POST /job-applications` [VERIFIED] `api_docs.md` §7, §14 |
| Main flow | 1. Client uploads the CV. 2. Client optionally sets it as the default. 3. Client submits the application (with optional `Idempotency-Key`). |
| Alternative | Duplicate application returns `409`. |
| Postcondition | Application exists with status `PENDING`; `job.application.submitted` published. |
| Related | FR-CAREER-001, FR-CAREER-007 |

### UC-CAREER-002 — Review applicants

| Field | Detail |
| --- | --- |
| Primary actor | Company (job poster) |
| Interfaces | `GET /job-applications?job_post_id=`, `GET /job-applications/{id}/cv-preview`, `PATCH /job-applications/{id}/status` [VERIFIED] `api_docs.md` §7 |
| Main flow | 1. Poster lists applicants for their job. 2. Poster previews a CV. 3. Poster updates status (`PENDING`\|`REVIEWED`\|`ACCEPTED`\|`REJECTED`). |
| Alternative | Non-poster status update is denied. |
| Related | FR-CAREER-005 |

### UC-FINANCE-001 — View payments and fee alerts

| Field | Detail |
| --- | --- |
| Primary actor | Student |
| Precondition | User has `STUDENT` role |
| Interfaces | `GET /payments`, `GET /payments/alerts`, `GET /fees`, `GET /fees/categories` [VERIFIED] `api_docs.md` §8 |
| Main flow | 1. Client requests payments and alerts. 2. Service returns the student's payments and deadlines. |
| Alternative | Non-student receives `403`. |
| Related | FR-FINANCE-001..005 |

### UC-CHAT-001 — Start a peer conversation

| Field | Detail |
| --- | --- |
| Primary actor | User |
| Interfaces | `POST /message-requests`, then `POST /conversations/{id}/accept` [VERIFIED] `api_docs.md` §9 |
| Main flow | 1. Sender creates a message request. 2. Recipient accepts (or declines/blocks). 3. A conversation becomes active. |
| Related | FR-CHAT-002, FR-CHAT-003 |

### UC-CHAT-002 — Exchange realtime messages

| Field | Detail |
| --- | --- |
| Primary actor | User |
| Interfaces | STOMP `/ws` (`/app/chat.send`, `/user/queue/messages`) + REST history [VERIFIED] `api_docs.md` §9 |
| Main flow | 1. Client connects with Bearer JWT. 2. Subscribes to inbox/presence. 3. Sends and receives messages; read receipts and typing indicators flow. |
| Alternative | Offline sends are queued locally in Isar. |
| Related | FR-CHAT-005, FR-CHAT-006, FR-CHAT-008 |

### UC-AI-001 — Generate a CV

| Field | Detail |
| --- | --- |
| Primary actor | User |
| Precondition | Authenticated; profile/posts available |
| Interfaces | `POST /api/v1/ai/cv/generate` [VERIFIED] `flutter_routes.py`, `cv_app_service.py` |
| Main flow | 1. Client requests generation (optional `target_role`, `language`). 2. `ai_core` fetches profile + recent posts. 3. It extracts activities via the LLM and builds a `StandardCV`. 4. It returns an `AiCvDraft` in the `{data,meta,error}` envelope. |
| Alternative | Insufficient inputs → `incomplete_profile` with no LLM call. LLM/key failure → clear error. |
| Related | FR-AI-006, FR-AI-011, NFR-COST-002 |

### UC-AI-002 — Chat with the AI assistant

| Field | Detail |
| --- | --- |
| Primary actor | User |
| Interfaces | `POST /api/v1/ai/chat`, `/chat/stream`, sessions/regenerate/cancel [VERIFIED] `flutter_routes.py` |
| Main flow | 1. Client sends a message (optional `topic`). 2. `ai_core` persists the session and returns a topic-stub Markdown reply (streamed over SSE if used). |
| Alternative | User cancels a stream via `DELETE /ai/chat/requests/{id}`. |
| Related | FR-AI-001..005 |

### UC-NOTIF-001 — Manage notifications

| Field | Detail |
| --- | --- |
| Primary actor | User |
| Interfaces | `/notifications` list, unread count, read/read-all, delete, devices [VERIFIED] `api_docs.md` §11 |
| Main flow | 1. Client loads the inbox. 2. User marks read or deletes. 3. Client registers/unregisters device tokens. |
| Related | FR-NOTIF-001..005 |

### UC-MAP-001 — Find nearby places

| Field | Detail |
| --- | --- |
| Primary actor | User |
| Precondition | map-service running (opt-in) with a Places key |
| Interfaces | `/places/nearby`, `/places/search`, `/places/{id}`, favorites/history [VERIFIED] `api_docs.md` §12 |
| Main flow | 1. Client requests nearby places or search. 2. Service queries Google Places (cached) and returns place cards. 3. User saves favorites. |
| Alternative | Without a Places key the service returns a clear config error. |
| Related | FR-MAP-001..005 |

## 4. Related documents

- [`03-functional-requirements.md`](03-functional-requirements.md)
- [`07-user-stories.md`](07-user-stories.md)
- [`08-acceptance-criteria.md`](08-acceptance-criteria.md)
