# User Profile API (user-profile-service)

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/user-profile-service/src/main/java/com/vithey/profile/controller/*.java`, `dto/**`, `service/UserSearchService.java`

Base paths: `/api/v1/users` (`UserController`) and `/api/v1/users/me/settings` (`SettingsController`).
Service port `8082`. All endpoints require JWT. Gateway routing: `/api/v1/users/me/cv` → career,
`/api/v1/users/*/follow|followers|following|posts` → content, `/api/v1/users/*/report` → chat-service,
everything else under `/api/v1/users/**` → user-profile-service (order 1).

## 1. Endpoint inventory

| Method | Path | Auth | Required role | Purpose | Request | Response | Errors |
|---|---|---|---|---|---|---|---|
| GET | `/api/v1/users/search` | JWT | any | Search users by full name | `?search=&page=&limit=` | list of `UserSearchResultResponse` + meta | 400, 401 |
| GET | `/api/v1/users/me` | JWT | any | My full profile + language/theme | — | `MeProfileResponse` | 401, 404 |
| GET | `/api/v1/users/{userId}` | JWT | any | Public profile by id | path `userId` | `ProfileResponse` | 401, 404 |
| PATCH | `/api/v1/users/me` | JWT | any (owner) | Partial profile update | `UpdateProfileRequest` | `ProfileResponse` | 400, 401 |
| PATCH | `/api/v1/users/me/avatar` | JWT | any (owner) | Set avatar from uploaded file | `UpdateAvatarRequest` (`avatar_file_id`) | `ProfileResponse` | 400, 401 |
| GET | `/api/v1/users/me/settings` | JWT | any | Get language/theme/notifications/privacy/fcm_token | — | `SettingsResponse` | 401 |
| PATCH | `/api/v1/users/me/settings` | JWT | any | Partial settings update | `UpdateSettingsRequest` | `SettingsResponse` | 400, 401 |

## 2. Search behaviour (VERIFIED)

- `search` is required; queries shorter than **2 characters** return an empty list with zeroed `meta`.
- `page` clamped 1..100; `limit` clamped to max **50** (default 20).
- Matching is case-insensitive `ILIKE` on `full_name` (backed by a trigram index intended to be
  `LOWER(full_name)` — currently a no-op; see [`../05-database/07-indexing-performance.md`](../05-database/07-indexing-performance.md)).
- `UserSearchResultResponse` = `user_id, full_name, avatar_url, university, major, headline`.

## 3. Request/response schemas

`UpdateProfileRequest` (all optional): `full_name`, `bio`, `telegram_link`, `facebook_link`,
`university`, `major`, `graduation_year` (1950–2100), `location`, `date_of_birth`, `workplace`,
`portfolio_url`, `phone`, `email`, `skills[]` (`{ name, proficiency 0–100 }`), `education[]` string,
`field_visibility` (map). `UpdateSettingsRequest`: `language` (`km|en`), `theme`
(`light|dark|system`), `notifications` (object), `privacy` (object), `fcm_token`.

`ProfileResponse` = `user_id, full_name, bio, avatar_url, telegram_link, facebook_link, university,
major, graduation_year, location, date_of_birth, workplace, portfolio_url, phone, email, skills[],
education[], field_visibility`. `MeProfileResponse` adds `language`, `theme`.
`SettingsResponse` = `user_id, language, theme, notifications, privacy, fcm_token`.

> The `GET /users/{userId}` "public" profile applies field visibility; the exact projection rules
> are service-internal. [VERIFIED: `ProfileService`]

## 4. Examples

### GET `/api/v1/users/search?search=ja&page=1&limit=20` → 200

```json
{
  "data": [
    {
      "user_id": "f984000a-38f4-46e5-a047-019d20a66ce0",
      "full_name": "Jane Doe",
      "avatar_url": "http://localhost:19000/avatars/...",
      "university": "AUB",
      "major": "Computer Science",
      "headline": "Computer Science · AUB"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 1, "total_pages": 1 }
}
```

### PATCH `/api/v1/users/me` → 200

```json
{
  "full_name": "Jane Doe",
  "bio": "AUB CS student",
  "university": "AUB",
  "major": "Computer Science",
  "graduation_year": 2026,
  "skills": [{ "name": "Flutter", "proficiency": 80 }],
  "education": ["BSc CS — AUB"],
  "field_visibility": { "phone": "PRIVATE" }
}
```

### PATCH `/api/v1/users/me/avatar` → 200

```json
{ "avatar_file_id": "1ae1e48f-2a5a-4b91-af42-ecf3cc0acf54" }
```

### PATCH `/api/v1/users/me/settings` → 200

```json
{
  "language": "km",
  "theme": "dark",
  "notifications": { "likes": true, "chat": true },
  "privacy": { "profile_visible": true },
  "fcm_token": "optional-device-token"
}
```

## 5. Data touched

`user_db`: `profiles`, `user_settings`. Avatar bytes live in file-service; `avatar_file_id` is a
cross-service reference. See [`../05-database/03-database-schema.md`](../05-database/03-database-schema.md) §2.

## 6. TBD

- Exact field-visibility projection for the public profile: `TBD — Requires confirmation.`
- Whether `fcm_token` on settings remains supported vs the dedicated device-token API:
  `TBD — Requires confirmation.`
