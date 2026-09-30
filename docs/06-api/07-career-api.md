# Career API (career-service)

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/career-service/src/main/java/com/vithey/career/controller/*.java`, `dto/**`, `security/CurrentUserProvider.java`

Base paths: `/api/v1/users/me/cv` (`UserCvController`) and `/api/v1/job-applications`
(`JobApplicationController`). Service port `8085`. All endpoints require JWT. Job **listings** are
content posts (`GET /api/v1/posts?type=JOB`), not a career endpoint.

## 1. Endpoint inventory

| Method | Path | Auth | Required role | Purpose | Request | Response | Errors |
|---|---|---|---|---|---|---|---|
| GET | `/api/v1/users/me/cv` | JWT | any | Get my default CV | — | `UserCvResponse` | 401, 404 |
| PUT | `/api/v1/users/me/cv` | JWT | any | Set default CV | `SetCvRequest` (`cv_file_id`) | `UserCvResponse` | 400, 401 |
| POST | `/api/v1/job-applications` | JWT | any | Apply to a job post | `ApplyJobRequest`; optional `Idempotency-Key` header | `JobApplicationResponse` | 400, 401, 409 |
| GET | `/api/v1/job-applications` | JWT | any | List my applications / applicants | `?job_post_id=&page=&limit=` | `JobApplicationResponse[]` + meta | 401 |
| GET | `/api/v1/job-applications/{applicationId}` | JWT | participant/owner | Application detail | path | `JobApplicationResponse` | 401, 403, 404 |
| GET | `/api/v1/job-applications/{applicationId}/cv-preview` | JWT | participant/owner | CV preview link | path | `CvPreviewResponse` | 401, 403, 404 |
| PATCH | `/api/v1/job-applications/{applicationId}/status` | JWT | poster only | Update application status | `UpdateApplicationStatusRequest` | `JobApplicationResponse` | 400, 401, 403, 404 |

Role note: `PATCH /status` is restricted to the job poster in service logic (not `@PreAuthorize`).
`GET /job-applications?job_post_id=` returns applicants for that post (poster view).

## 2. Schemas

`SetCvRequest`: `cv_file_id` (required). `ApplyJobRequest`: `job_post_id` (required), `cv_file_id`
(required), `cover_note` (required) — the JSON aliases `application_note` and `cover_note` are both
accepted. `UpdateApplicationStatusRequest`: `status` (required), `reviewer_note`.

`UserCvResponse` = `user_id, cv_file_id, file_name, updated_at`.
`JobApplicationResponse` = `application_id, job_post_id, job_title, organization,
applicant { ... }, cv_file_id, cv_file_name, status, cover_note, applied_at, review_started_at,
decided_at, reviewer_note`.
`CvPreviewResponse` = `application_id, cv_file_id, cv_file_name, download_url`.

**Status enum (entity):** `PENDING | REVIEWED | ACCEPTED | REJECTED`.
The DB CHECK also permits `UNDER_REVIEW` and `WITHDRAWN` (defect #4) — clients should not rely on
those states being settable.

## 3. Examples

### Apply flow

```text
1. POST /api/v1/files/upload   (type=CV)              -> file_id
2. (optional) PUT /api/v1/users/me/cv  { cv_file_id } -> default CV
3. POST /api/v1/job-applications
```

### POST `/api/v1/job-applications` → 201

```http
Idempotency-Key: 0f1f2b3c-...
```

```json
{
  "job_post_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "cv_file_id": "1ae1e48f-2a5a-4b91-af42-ecf3cc0acf54",
  "cover_note": "I would love to join your team."
}
```

```json
{
  "data": {
    "application_id": "b7c8d9e0-...",
    "job_post_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "job_title": "Flutter Intern",
    "organization": null,
    "applicant": { "user_id": "018a4379-...", "full_name": "Jane Doe" },
    "cv_file_id": "1ae1e48f-2a5a-4b91-af42-ecf3cc0acf54",
    "cv_file_name": "cv.pdf",
    "status": "PENDING",
    "cover_note": "I would love to join your team.",
    "applied_at": "2026-09-30T08:00:00Z",
    "review_started_at": null,
    "decided_at": null,
    "reviewer_note": null
  }
}
```

### PATCH `/api/v1/job-applications/{applicationId}/status` → 200

```json
{ "status": "ACCEPTED", "reviewer_note": "Great fit" }
```

## 4. Data touched

`career_db`: `user_cvs`, `job_applications`. Two defects apply: duplicate Flyway `V3` and
`UserCv @Id` mismatch. See [`../05-database/03-database-schema.md`](../05-database/03-database-schema.md) §5.

## 5. TBD

- Whether `organization`/`job_title` are enriched via a content-service/company call or left null:
  `TBD — Requires confirmation.`
- Access rule for `GET /job-applications` without `job_post_id` (applicant scoping vs global):
  `TBD — Requires confirmation.`
