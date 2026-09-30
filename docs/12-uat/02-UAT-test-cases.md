# UAT Test Cases

> Status: **Proposed — not executed** · Last reviewed: 2026-09-30
> Evidence: derived from real screens (`vithey_app/lib/modules/`) and endpoints (`api_docs.md`, `../06-api/`), and the flows exercised by `backend/scripts/smoke-api.ps1`
> **UAT has not yet been formally executed / evidence was not found.** Every case has an empty outcome.

Outcome legend: `Not run` (default) · `Pass` · `Fail` · `Blocked`. Do **not** fill in a Pass
without an observed run.

## 1. Authentication & onboarding (module `auth`)

| ID | Scenario (Given/When/Then) | Endpoint/Screen | Expected user-visible result | Outcome |
| --- | --- | --- | --- | --- |
| UAT-AUTH-01 | Given a new visitor, when they register as a student `USER`, then they land authenticated | `POST /auth/register`; register screen | Account created, redirected into app | Not run |
| UAT-AUTH-02 | Given a registered user, when they log in with email/phone + password, then they reach the home feed | `POST /auth/login` | Logged in | Not run |
| UAT-AUTH-03 | Given a logged-in user, when the access token expires, then the app silently refreshes and continues | `POST /auth/refresh`; Dio interceptor | No forced logout | Not run |
| UAT-AUTH-04 | Given a user, when they log out, then tokens are cleared and they return to auth | `POST /auth/logout` | Session ended | Not run |
| UAT-AUTH-05 | Given a user who forgot their password, when they request a reset link and set a new password, then they can log in with it | `/auth/forgot-password`, `/auth/reset-password` | Reset succeeds | Not run |
| UAT-AUTH-06 | Given a new account, when they open the verification link, then email shows verified | `/auth/verify-email` | Verified state | Not run |
| UAT-AUTH-07 | Given a user with student details, when they submit student verification, then their role becomes `STUDENT` | `POST /students/verify` | Verification confirmed | Not run |
| UAT-AUTH-08 | Given invalid credentials, when they attempt login, then a clear error appears (no account enumeration) | `POST /auth/login` | Friendly error | Not run |

## 2. Home feed & social (module `home`, `content-service`)

| ID | Scenario | Endpoint/Screen | Expected | Outcome |
| --- | --- | --- | --- | --- |
| UAT-FEED-01 | View the home feed and scroll | `GET /posts`; home | Posts render, pagination works | Not run |
| UAT-FEED-02 | Create a text post | `POST /posts`; composer | Post appears in feed | Not run |
| UAT-FEED-03 | Comment on a post | `POST /posts/{id}/comments` | Comment visible | Not run |
| UAT-FEED-04 | React to a post | `POST /posts/{id}/reactions` | Reaction toggles | Not run |
| UAT-FEED-05 | Follow / unfollow a user | `/users/{id}/follow` | Follower state changes | Not run |
| UAT-FEED-06 | Empty/offline state | home | Friendly empty/offline banner | Not run |

## 3. Jobs & CV (modules `jobs`, `chatbot` for CV)

| ID | Scenario | Endpoint/Screen | Expected | Outcome |
| --- | --- | --- | --- | --- |
| UAT-JOB-01 | Browse job listings | `GET /jobs`; jobs | List renders | Not run |
| UAT-JOB-02 | Apply to a job | `POST /job-applications` | Application confirmed | Not run |
| UAT-JOB-03 | Upload a CV (PDF) | `POST /files/upload` (type=CV) | Upload succeeds, metadata shown | Not run |
| UAT-JOB-04 | Generate a CV with AI | `POST /ai/cv/generate` | Draft CV returned (real LLM) | Not run |
| UAT-JOB-05 | Request a CV section suggestion | `POST /ai/cv/suggest` | Suggested text shown | Not run |
| UAT-JOB-06 | Company user posts a job | `POST /posts` (type=JOB) as `COMPANY` | Job listing created | Not run |

## 4. Profile (module `profile`)

| ID | Scenario | Endpoint/Screen | Expected | Outcome |
| --- | --- | --- | --- | --- |
| UAT-PROF-01 | View own profile | `GET /users/me` | Profile renders | Not run |
| UAT-PROF-02 | Edit bio/major/location | `PATCH /users/me` | Changes saved | Not run |
| UAT-PROF-03 | Update avatar | `POST /files/upload` + `PATCH /users/me/avatar` | New avatar shown | Not run |
| UAT-PROF-04 | View another user's public profile | `GET /users/{id}` | Read-only profile | Not run |
| UAT-PROF-05 | Search users | `GET /users/search` | Matching users listed | Not run |

## 5. Peer chat (module `chat`)

| ID | Scenario | Endpoint/Screen | Expected | Outcome |
| --- | --- | --- | --- | --- |
| UAT-CHAT-01 | Send a message request to a peer | `POST /message-requests` | Request sent | Not run |
| UAT-CHAT-02 | Accept a request and reply | `/conversations/{id}/accept`, `/conversations/{id}/messages` | Conversation active | Not run |
| UAT-CHAT-03 | Open the conversation list | `GET /conversations` | Conversations listed | Not run |
| UAT-CHAT-04 | Offline send queues and sends later | Isar outbox + `POST messages` | Message delivered on reconnect | Not run |
| UAT-CHAT-05 | Report a user | `POST /users/{id}/report` | Report submitted | Not run |

## 6. AI assistant (module `chatbot`)

| ID | Scenario | Endpoint/Screen | Expected | Outcome |
| --- | --- | --- | --- | --- |
| UAT-AI-01 | Open AI chat and send a message | `POST /ai/chat` | Reply shown (stub) | Not run |
| UAT-AI-02 | List AI sessions | `GET /ai/sessions` | Sessions listed | Not run |
| UAT-AI-03 | Regenerate a reply | `POST /ai/messages/{id}/regenerate` | New reply | Not run |

> AI chat is a **stub** (`AI_CHAT_MODE=stub`). Acceptance should be scoped accordingly.

## 7. Student finance (module `finance`)

| ID | Scenario | Endpoint/Screen | Expected | Outcome |
| --- | --- | --- | --- | --- |
| UAT-FIN-01 | Non-verified user opens finance | `GET /fees` | Clear "verify to view" state (403 handled) | Not run |
| UAT-FIN-02 | Verified `STUDENT` views fees | `GET /fees` | Fee list renders | Not run |
| UAT-FIN-03 | View payments and alerts | `GET /payments`, `/payments/alerts` | Payments/alerts render | Not run |
| UAT-FIN-04 | ACLEDA payment action | payment screen | Payment flow presented | Not run |

## 8. Notifications, search, settings, map

| ID | Scenario | Endpoint/Screen | Expected | Outcome |
| --- | --- | --- | --- | --- |
| UAT-NOT-01 | View notifications and unread count | `GET /notifications`, `/notifications/unread-count` | List + badge | Not run |
| UAT-NOT-02 | Toggle notification preferences | settings screen | Preferences persist | Not run |
| UAT-SRCH-01 | Search posts/users | search screen | Relevant results | Not run |
| UAT-SET-01 | Change theme | settings | Theme applies and persists | Not run |
| UAT-SET-02 | Change language to Khmer | settings | Preference stored | Not run |
| UAT-MAP-01 | Browse nearby places | `GET /places/...`; map | Places render | Not run |
| UAT-MAP-02 | View place detail / favourite | places endpoints | Detail + favourite work | Not run |
| UAT-MAP-03 | Map unavailable degrades gracefully | map | Friendly message, no crash | Not run |

## 9. Non-functional UAT (light)

| ID | Scenario | Expected | Outcome |
| --- | --- | --- | --- |
| UAT-NFR-01 | App cold start to usable | Reasonable time, no crash | Not run |
| UAT-NFR-02 | Token security on device | Tokens not visible in plain app storage | Not run |
| UAT-NFR-03 | Error messaging clarity | Understandable errors | Not run |

## 10. Status

- All cases: **Not run**.
- **UAT has not yet been formally executed / evidence was not found.**
- Record outcomes in [03-UAT-results.md](03-UAT-results.md); log defects in
  [04-UAT-issues.md](04-UAT-issues.md).

## 11. Cross-references

- [01-UAT-plan.md](01-UAT-plan.md) · [03-UAT-results.md](03-UAT-results.md) · [05-UAT-signoff.md](05-UAT-signoff.md)
- `../06-api/01-api-overview.md` · `../../api_docs.md`
