# File API (file-service)

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/file-service/src/main/java/com/vithey/file/controller/FileController.java`, `entity/StoredFileType.java`, `service/FileMetadataService.java`

Base path: `/api/v1/files`. Service port `8083`. Bytes are stored in MinIO; `file_db` holds only
metadata. All endpoints require JWT. Success bodies use `{data, meta, error}`; binary download
returns `application/octet-stream`.

## 1. Endpoint inventory

| Method | Path | Auth | Required role | Purpose | Request | Response | Errors |
|---|---|---|---|---|---|---|---|
| POST | `/api/v1/files/upload` | JWT | any | Multipart upload | `multipart/form-data`: `file`, `type` | `FileUploadResponse` | 400, 401 |
| GET | `/api/v1/files/{fileId}` | JWT | any | Metadata + fresh presigned URL | path | `FileMetadataResponse` | 401, 404 |
| GET | `/api/v1/files/{fileId}/download` | JWT | any (CV: owner-only) | Stream binary bytes | path | binary stream | 401, 403, 404 |
| DELETE | `/api/v1/files/{fileId}` | JWT | owner | Soft-delete + remove MinIO object | path | `204` | 401, 403, 404 |

## 2. Upload types and limits (VERIFIED)

`StoredFileType` defines the bucket and max size:

| `type` | MinIO bucket | Max size | Notes |
|---|---|---|---|
| `AVATAR` | `avatars` | 10 MB | profile picture |
| `CV` | `cvs` | 10 MB | owner-only download |
| `POSTER` | `posters` | 10 MB | image post |
| `VIDEO` | `videos` | 50 MB | video post |
| `CHAT_ATTACHMENT` | `chat-attachments` | 10 MB | chat media |

The `FileController` Swagger annotation lists only `AVATAR, CV, POSTER, VIDEO`, but the endpoint
binds the full `StoredFileType` enum, so `CHAT_ATTACHMENT` is also accepted. MIME type is validated
against an allow-list; size and MIME violations return `400` (`INVALID_FILE_TYPE` / `FILE_TOO_LARGE`).

## 3. Schemas

`FileUploadResponse` = `file_id, file_name, file_type, mime_type, size_bytes, url, created_at` (the
`url` is a 1-hour presigned URL). `FileMetadataResponse` = `file_id, file_name, type, mime_type,
size_bytes, url, created_at` (note: field is serialized as `type`, not `file_type`).

## 4. Examples

### POST `/api/v1/files/upload` → 201

```http
Content-Type: multipart/form-data; boundary=...
Authorization: Bearer <jwt>

--boundary
Content-Disposition: form-data; name="type"

AVATAR
--boundary
Content-Disposition: form-data; name="file"; filename="avatar.png"
Content-Type: image/png

<binary>
--boundary--
```

```json
{
  "data": {
    "file_id": "1ae1e48f-2a5a-4b91-af42-ecf3cc0acf54",
    "file_name": "avatar.png",
    "file_type": "AVATAR",
    "mime_type": "image/png",
    "size_bytes": 24576,
    "url": "http://localhost:19000/avatars/.../avatar.png?X-Amz-Algorithm=...",
    "created_at": "2026-07-27T15:00:00Z"
  }
}
```

### GET `/api/v1/files/{fileId}` → 200

```json
{
  "data": {
    "file_id": "1ae1e48f-2a5a-4b91-af42-ecf3cc0acf54",
    "file_name": "avatar.png",
    "type": "AVATAR",
    "mime_type": "image/png",
    "size_bytes": 24576,
    "url": "http://localhost:19000/avatars/...?X-Amz-Algorithm=...",
    "created_at": "2026-07-27T15:00:00Z"
  }
}
```

### Download access rules
`AVATAR`/`POSTER`/`VIDEO`/`CHAT_ATTACHMENT` may be downloaded by any authenticated user; `CV` is
restricted to the owner (else `403`).

## 5. Cross-service usage

| Consumer | Workflow |
|---|---|
| user-profile | upload `AVATAR` → `PATCH /users/me/avatar` |
| content | upload `POSTER`/`VIDEO` → `POST /posts` with `media_file_id` |
| career | upload `CV` → `PUT /users/me/cv` / `POST /job-applications` |
| chat | upload `CHAT_ATTACHMENT` → send message with `file_id` |

## 6. Data touched

`file_db.file_metadata` (+ MinIO objects). Soft-delete marks metadata and removes the object. See
[`../05-database/03-database-schema.md`](../05-database/03-database-schema.md) §3.

## 7. TBD

- Presigned URL TTL is documented as 1 hour in code/Swagger; whether it is configurable:
  `TBD — Requires confirmation.`
- Malware scanning / content moderation of uploads: none found — `TBD — Requires confirmation.`
