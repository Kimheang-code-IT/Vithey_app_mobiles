# User Stories

> Status: Verified baseline · Last reviewed: 2026-09-30
> Evidence: `api_docs.md`, `backend/services/`, `ai_core/`, `vithey_app/`
> ID convention: `US-<MODULE>-NNN`. Each story cites the interface it is based on. Priority uses MoSCoW (Must / Should / Could).

## 1. Authentication

| ID | Story | Interface | Priority | Status |
| --- | --- | --- | --- | --- |
| US-AUTH-001 | As a guest, I want to register with email/phone so I can access the app. | `POST /auth/register` | Must | Implemented |
| US-AUTH-002 | As a user, I want to log in and receive tokens so my session persists. | `POST /auth/login` | Must | Implemented |
| US-AUTH-003 | As a user, I want my token refreshed automatically so I am not logged out mid-session. | `POST /auth/refresh` + Dio 401 interceptor | Must | Implemented |
| US-AUTH-004 | As a user, I want to log out so my session is invalidated. | `POST /auth/logout` | Must | Implemented |
| US-AUTH-005 | As a user, I want to verify my email so my account is trusted. | `POST /auth/verify-email` | Should | Implemented |
| US-AUTH-006 | As a user, I want to reset a forgotten password so I can regain access. | `POST /auth/forgot-password`, `/reset-password` | Should | Implemented |
| US-AUTH-007 | As a user, I want to change my password from settings. | `PATCH /auth/me/password` | Should | Implemented |
| US-AUTH-008 | As a student, I want to verify my student ID so I can access finance. | `POST /students/verify` | Must | Implemented |
| US-AUTH-009 | As a user, I want to sign in with Google so registration is faster. | No endpoint (UI stub) | Could | [PLANNED] not implemented |

## 2. Profile & search

| ID | Story | Interface | Priority | Status |
| --- | --- | --- | --- | --- |
| US-USER-001 | As a user, I want to view and edit my profile so it reflects who I am. | `GET/PATCH /users/me` | Must | Implemented |
| US-USER-002 | As a user, I want an avatar so others recognise me. | `PATCH /users/me/avatar` | Should | Implemented |
| US-USER-003 | As a user, I want to set language/theme/notification preferences. | `PATCH /users/me/settings` | Should | Implemented |
| US-USER-004 | As a user, I want to find other people by name so I can connect. | `GET /users/search` | Must | Implemented |

## 3. Social feed & content

| ID | Story | Interface | Priority | Status |
| --- | --- | --- | --- | --- |
| US-CONTENT-001 | As a user, I want to browse a feed so I stay informed. | `GET /posts` | Must | Implemented |
| US-CONTENT-002 | As a user, I want to create a post with media so I can share. | `POST /files/upload`, `POST /posts` | Must | Implemented |
| US-CONTENT-003 | As a user, I want to react, comment, and follow so I can engage. | reactions/comments/follow endpoints | Must | Implemented |
| US-CONTENT-004 | As a user, I want to edit my post. | `PATCH /posts/{id}` | Could | Not implemented (gap) |
| US-CONTENT-005 | As a user, I want to delete my post. | `DELETE /posts/{id}` | Should | Implemented |

## 4. Jobs & career

| ID | Story | Interface | Priority | Status |
| --- | --- | --- | --- | --- |
| US-CAREER-001 | As a user, I want to upload my CV so I can apply to jobs. | `POST /files/upload` (`CV`) | Must | Implemented |
| US-CAREER-002 | As a user, I want to apply to a job so I can be considered. | `POST /job-applications` | Must | Implemented |
| US-CAREER-003 | As a user, I want a default CV so I can apply quickly. | `GET/PUT /users/me/cv` | Should | Implemented |
| US-CAREER-004 | As a company, I want to review applicants and update status. | `/job-applications` + `PATCH .../status` | Must | Implemented |

## 5. Finance

| ID | Story | Interface | Priority | Status |
| --- | --- | --- | --- | --- |
| US-FINANCE-001 | As a student, I want to see my payments and due dates. | `GET /payments` | Must | Implemented |
| US-FINANCE-002 | As a student, I want deadline alerts. | `GET /payments/alerts` | Should | Implemented |
| US-FINANCE-003 | As a student, I want to browse the fee catalog. | `GET /fees` | Should | Implemented |
| US-FINANCE-004 | As a student, I want to open ACLEDA Mobile to pay. | `acleda_mobile_launcher.dart` | Should | [INFERRED] device confirmation pending |

## 6. Peer chat

| ID | Story | Interface | Priority | Status |
| --- | --- | --- | --- | --- |
| US-CHAT-001 | As a user, I want to send a message request so I control who contacts me. | `POST /message-requests` | Must | Implemented |
| US-CHAT-002 | As a user, I want to accept/decline/block requests. | `/conversations/{id}/accept|decline|block` | Must | Implemented |
| US-CHAT-003 | As a user, I want realtime messaging with read receipts. | STOMP `/ws` | Must | Implemented |
| US-CHAT-004 | As a user, I want offline chat that syncs when back online. | Isar outbox | Should | Implemented |
| US-CHAT-005 | As a user, I want to report abusive users. | `POST /users/{id}/report` | Should | Implemented |

## 7. AI

| ID | Story | Interface | Priority | Status |
| --- | --- | --- | --- | --- |
| US-AI-001 | As a user, I want an AI-generated CV draft from my profile and posts. | `POST /ai/cv/generate` | Must | Implemented |
| US-AI-002 | As a user, I want suggestions to improve a CV section. | `POST /ai/cv/suggest` | Should | Stub/Placeholder |
| US-AI-003 | As a user, I want to chat with an AI assistant about CV/jobs/interviews/finance. | `POST /ai/chat` (+ stream) | Must | Implemented (stub) |
| US-AI-004 | As a user, I want to view and manage my chat history. | `/ai/sessions...` | Should | Implemented |
| US-AI-005 | As a user, I want to stop a streaming response. | `DELETE /ai/chat/requests/{id}` | Could | Implemented |
| US-AI-006 | As a user, I want AI job matching and feed recommendations. | Not shipped | Could | [PLANNED] Flutter stubs only |

## 8. Notifications

| ID | Story | Interface | Priority | Status |
| --- | --- | --- | --- | --- |
| US-NOTIF-001 | As a user, I want an in-app inbox of events relevant to me. | `GET /notifications` | Must | Implemented |
| US-NOTIF-002 | As a user, I want an unread badge. | `GET /notifications/unread-count` | Should | Implemented |
| US-NOTIF-003 | As a user, I want to mark read or delete notifications. | `PATCH`, `DELETE` | Should | Implemented |
| US-NOTIF-004 | As a user, I want push notifications on my device. | FCM device registration | Could | [PLANNED] FCM disabled/no-op |

## 9. Map

| ID | Story | Interface | Priority | Status |
| --- | --- | --- | --- | --- |
| US-MAP-001 | As a user, I want to find nearby places. | `GET /places/nearby` | Should | Implemented (opt-in) |
| US-MAP-002 | As a user, I want to search places and see detail. | `/places/search`, `/places/{id}` | Should | Implemented (opt-in) |
| US-MAP-003 | As a user, I want to favorite places. | `/places/favorites` | Could | Implemented (opt-in) |

## 10. Search

| ID | Story | Interface | Priority | Status |
| --- | --- | --- | --- | --- |
| US-SEARCH-001 | As a user, I want to search people and posts from one screen. | fan-out endpoints | Should | Implemented |
| US-SEARCH-002 | As a user, I want recent searches remembered on my device. | client storage | Could | Implemented |
| US-SEARCH-003 | As a user, I want AI-assisted search within chat history. | placeholder | Could | [PLANNED] not implemented |

## 11. Settings & preferences

| ID | Story | Interface | Priority | Status |
| --- | --- | --- | --- | --- |
| US-SET-001 | As a user, I want privacy controls for my profile. | `PATCH /users/me/settings` | Should | Implemented |
| US-SET-002 | As a user, I want two-factor authentication. | placeholder | Could | [PLANNED] not implemented |
| US-SET-003 | As a user, I want biometric unlock. | placeholder | Could | [PLANNED] not implemented |

## 12. Cross-cutting

| ID | Story | Interface | Priority | Status |
| --- | --- | --- | --- | --- |
| US-USER-005 | As a user, I want the app to work offline for chat. | Isar | Should | Implemented |
| US-APP-001 | As a user, I want a light and dark theme. | theme system | Should | Implemented |
| US-APP-002 | As a user, I want Khmer language support. | settings + CV `language=km` | Could | Partial (UI English-only) |

## 13. Related documents

- [`06-use-cases.md`](06-use-cases.md)
- [`08-acceptance-criteria.md`](08-acceptance-criteria.md)
- [`03-functional-requirements.md`](03-functional-requirements.md)
