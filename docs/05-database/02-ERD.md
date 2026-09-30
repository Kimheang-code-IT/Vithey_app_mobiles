# Entity Relationship Diagrams (ERD)

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/*/src/main/resources/db/migration/*.sql`, `backend/services/*/src/main/java/**/entity/*.java`

These diagrams reflect the **actual** PostgreSQL schema (derived from Flyway migrations), not
Hibernate model inference. Cross-database references are shown as comments, not solid
relationships, because there are no cross-database foreign keys. Relationship labels use Mermaid
`erDiagram` crow's-foot notation.

## 1. auth_db (auth-service)

```mermaid
erDiagram
  USERS ||--o{ REFRESH_TOKENS : "issues"
  USERS ||--o{ PASSWORD_RESET_TOKENS : "resets"
  USERS ||--o{ EMAIL_VERIFICATION_TOKENS : "verifies"
  USERS ||--o| STUDENT_VERIFICATIONS : "submits"

  USERS {
    uuid id PK
    varchar email
    varchar phone
    varchar password_hash
    varchar full_name
    varchar role
    boolean is_active
    boolean is_student_verified
    boolean is_email_verified
    timestamptz created_at
    timestamptz updated_at
    timestamptz deleted_at
  }
  REFRESH_TOKENS {
    uuid id PK
    uuid user_id FK
    varchar token_hash
    timestamptz expires_at
    timestamptz revoked_at
    timestamptz created_at
  }
  PASSWORD_RESET_TOKENS {
    uuid id PK
    uuid user_id FK
    varchar token_hash
    timestamptz expires_at
    timestamptz used_at
    timestamptz created_at
  }
  EMAIL_VERIFICATION_TOKENS {
    uuid id PK
    uuid user_id FK
    varchar token_hash
    timestamptz expires_at
    timestamptz used_at
    timestamptz created_at
  }
  STUDENT_VERIFICATIONS {
    uuid id PK
    uuid user_id FK
    varchar student_id
    varchar university_email
    varchar status
    timestamptz verified_at
    timestamptz created_at
    timestamptz updated_at
  }
```

`users.role` ∈ `USER | STUDENT | COMPANY | ADMIN`; `student_verifications.status` ∈
`PENDING | VERIFIED | REJECTED`. Token FKs cascade on user hard-delete (V2/V4).

## 2. user_db (user-profile-service)

```mermaid
erDiagram
  PROFILES {
    uuid user_id PK
    varchar full_name
    text bio
    uuid avatar_file_id
    text avatar_url
    text telegram_link
    text facebook_link
    varchar university
    varchar major
    integer graduation_year
    varchar location
    date date_of_birth
    varchar workplace
    text portfolio_url
    varchar phone
    varchar email
    jsonb skills
    jsonb education
    jsonb field_visibility
    timestamptz created_at
    timestamptz updated_at
  }
  USER_SETTINGS {
    uuid user_id PK
    varchar language
    varchar theme
    jsonb notification_prefs
    jsonb privacy_prefs
    text fcm_token
    timestamptz updated_at
  }
```

`profiles` and `user_settings` share the same logical key (`user_id`) but have no FK between them;
`avatar_file_id` is a cross-service reference to file_db (unconstrained).

## 3. file_db (file-service)

```mermaid
erDiagram
  FILE_METADATA {
    uuid id PK
    uuid owner_user_id
    varchar file_name
    varchar file_type
    varchar mime_type
    bigint size_bytes
    varchar bucket
    text object_key
    timestamptz created_at
    timestamptz deleted_at
  }
```

`file_type` ∈ `AVATAR | CV | POSTER | VIDEO | CHAT_ATTACHMENT` (V3). `owner_user_id` is a logical
reference to auth_db; `object_key` is unique.

## 4. content_db (content-service)

```mermaid
erDiagram
  POSTS ||--o{ COMMENTS : "has"
  POSTS ||--o{ REACTIONS : "reacted"
  COMMENTS ||--o{ MENTIONS : "mentions"

  POSTS {
    uuid id PK
    uuid author_id
    varchar type
    text content
    uuid media_file_id
    varchar job_title
    text job_description
    text job_requirement
    date job_deadline
    timestamptz created_at
    timestamptz updated_at
    timestamptz deleted_at
  }
  COMMENTS {
    uuid id PK
    uuid post_id FK
    uuid author_id
    text text
    timestamptz created_at
  }
  MENTIONS {
    uuid id PK
    uuid comment_id FK
    uuid mentioned_user_id
  }
  REACTIONS {
    uuid id PK
    uuid post_id FK
    uuid user_id
    timestamptz created_at
  }
  FOLLOWS {
    uuid id PK
    uuid follower_id
    uuid following_id
    timestamptz created_at
  }
```

`posts.type` DB CHECK ∈ `VIDEO | POSTER | JOB | STANDARD` (entity enum only `VIDEO | POSTER | JOB`
— defect #4). `reactions` unique `(post_id, user_id)`; `follows` unique `(follower_id,
following_id)` and self-follow check. `author_id`, `user_id`, `follower_id`, `following_id`,
`mentioned_user_id`, `media_file_id` are cross-service refs.

## 5. career_db (career-service)

```mermaid
erDiagram
  USER_CVS ||--o{ JOB_APPLICATIONS : "cv_file_id"

  USER_CVS {
    uuid id PK
    uuid user_id
    uuid cv_file_id
    varchar file_name
    timestamptz updated_at
  }
  JOB_APPLICATIONS {
    uuid id PK
    uuid job_post_id
    uuid applicant_id
    uuid cv_file_id FK
    text cover_note
    varchar status
    timestamptz applied_at
    timestamptz updated_at
    timestamptz review_started_at
    timestamptz decided_at
    text reviewer_note
    varchar idempotency_key
  }
```

`job_applications.cv_file_id` → `user_cvs(cv_file_id)` (the only same-DB FK in career_db). Note
the entity model defect: `UserCv` `@Id` maps `user_id`, while the DB primary key is `id`
(defect #2). `status` DB CHECK is a superset of the `ApplicationStatus` enum (defect #4).

## 6. finance_db (finance-service)

```mermaid
erDiagram
  FEE_CATEGORIES ||--o{ FEES : "categorizes"
  FEES ||--o{ PAYMENTS : "billed"

  STUDENT_FINANCE_ACCOUNTS {
    uuid user_id PK
    varchar student_id
    timestamptz linked_at
  }
  FEE_CATEGORIES {
    uuid id PK
    varchar name
    text description
    timestamptz created_at
  }
  FEES {
    uuid id PK
    uuid category_id FK
    varchar name
    numeric amount
    varchar currency
    timestamptz created_at
  }
  PAYMENTS {
    uuid id PK
    uuid user_id
    uuid fee_id FK
    numeric amount
    varchar currency
    varchar status
    date due_date
    timestamptz paid_at
    timestamptz created_at
    timestamptz updated_at
  }
```

`fees`/`payments` amount checks are `amount > 0`. `status` DB CHECK ∈
`UNPAID | PAID | OVERDUE | PENDING | CANCELLED` while `PaymentStatus` enum is `UNPAID | PAID |
OVERDUE` (defect #4). `currency` ∈ `KHR | USD` (enum, no DB CHECK). Seed data: 2 categories,
3 fees.

## 7. chat_db (chat-service)

```mermaid
erDiagram
  CONVERSATIONS ||--o{ CONVERSATION_PARTICIPANTS : "includes"
  CONVERSATIONS ||--o{ MESSAGES : "contains"
  MESSAGES ||--o{ MESSAGES : "replies to"

  CONVERSATIONS {
    uuid id PK
    varchar status
    timestamptz created_at
    timestamptz updated_at
  }
  CONVERSATION_PARTICIPANTS {
    uuid conversation_id PK
    uuid user_id PK
    varchar role
    timestamptz joined_at
  }
  MESSAGES {
    uuid id PK
    uuid conversation_id FK
    uuid sender_id
    text text
    varchar message_type
    uuid file_id
    uuid reply_to_message_id FK
    varchar client_message_id
    varchar status
    timestamptz deleted_at
    timestamptz created_at
  }
  BLOCKS {
    uuid blocker_id PK
    uuid blocked_id PK
    timestamptz created_at
  }
  USER_REPORTS {
    uuid id PK
    uuid reporter_id
    uuid reported_id
    text reason
    timestamptz created_at
  }
```

`conversations.status` DB CHECK ∈ `PENDING | ACTIVE | BLOCKED | DECLINED | ARCHIVED | CLOSED`
(entity only `PENDING | ACTIVE | BLOCKED | DECLINED`); `conversation_participants.role` DB CHECK ∈
`REQUESTER | RECIPIENT | MEMBER | ADMIN` (entity only `REQUESTER | RECIPIENT`); `messages.status`
CHECK ∈ `SENT | DELIVERED | READ | DELETED` (entity only `SENT | DELIVERED | READ`) — all defect
#4. `message_type` ∈ `TEXT | IMAGE | FILE`.

## 8. notification_db (notification-service)

```mermaid
erDiagram
  NOTIFICATIONS {
    uuid id PK
    uuid user_id
    varchar type
    varchar event
    varchar title
    text body
    uuid reference_id
    varchar reference_type
    boolean is_read
    timestamptz read_at
    uuid actor_id
    varchar actor_name
    text actor_avatar_url
    jsonb destination
    varchar dedupe_key
    timestamptz created_at
  }
  DEVICE_TOKENS {
    uuid id PK
    uuid user_id
    text fcm_token
    varchar platform
    timestamptz created_at
    timestamptz updated_at
  }
```

`type` DB CHECK is a large superset including `LIKE | COMMENT | MENTION | FOLLOW | CHAT |
CHAT_REQUEST | JOB | PAYMENT | SYSTEM | STUDENT_VERIFICATION | ...`; the entity enum omits
`SYSTEM`-legacy `MESSAGE`/`APPLICATION_UPDATE`/`PAYMENT_DUE` and `POST_SHARE`/`AI`, so it is both
a subset and a superset of the DB list (defect #4).

## 9. map_db (map-service)

```mermaid
erDiagram
  PLACE_FAVORITES {
    uuid id PK
    uuid user_id
    varchar google_place_id
    varchar name
    varchar address
    double latitude
    double longitude
    varchar category
    varchar photo_url
    timestamptz created_at
    timestamptz updated_at
  }
  PLACE_SEARCH_HISTORY {
    uuid id PK
    uuid user_id
    varchar query
    varchar category
    double latitude
    double longitude
    int radius_m
    timestamptz created_at
  }
```

`place_favorites` unique `(user_id, google_place_id)`. `PlaceSearchHistory.MAX_ENTRIES_PER_USER =
20` (application-enforced). No FKs (only logical `user_id`).

## 10. Grouped overview

```mermaid
flowchart TB
  USERID[/"user_id (JWT sub)"/]
  USERID -.-> AUTHDB
  USERID -.-> PROFILES
  USERID -.-> POSTS
  USERID -.-> USERCVS
  USERID -.-> PAYMENTS
  USERID -.-> CONVERSATIONS
  USERID -.-> NOTIFICATIONS
  USERID -.-> PLACEFAV

  AUTHDB[(auth_db.users)]
  PROFILES[(user_db.profiles)]
  POSTS[(content_db.posts)]
  USERCVS[(career_db.user_cvs)]
  PAYMENTS[(finance_db.payments)]
  CONVERSATIONS[(chat_db.conversations)]
  NOTIFICATIONS[(notification_db.notifications)]
  PLACEFAV[(map_db.place_favorites)]
```

See [`03-database-schema.md`](03-database-schema.md) for full column/constraint/index detail.
