# file-service

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `backend/services/file-service/`, `backend/infrastructure/config-repo/file-service.yml`

Part of the Vithey documentation set · Master index:
[`../../00-project-overview/07-document-index.md`](../../00-project-overview/07-document-index.md) ·
Siblings: [Backend architecture](../01-backend-architecture.md) ·
[Microservice architecture](../02-microservice-architecture.md) · [Cache strategy](../07-cache-strategy.md) ·
API: [`../../06-api/06-file-api.md`](../../06-api/06-file-api.md).

## 1. Purpose

Stores binary objects in **MinIO** and owns the file metadata catalogue (owner, type, MIME, size,
bucket/object key). Provides presigned URLs and streams downloads. [VERIFIED]

## 2. Responsibilities

- Multipart uploads with per-type bucket routing, MIME allow-list and size limits.
- Metadata persistence and soft delete (also removes the MinIO object).
- Fresh 1-hour presigned URLs for stored objects.
- Owner-scoped delete and owner-only CV download.

## 3. Port and identity

| Item | Value |
|---|---|
| Port | `8083` (`SERVER_PORT`) |
| Eureka name | `file-service` |
| Database | `file_db` + MinIO buckets |
| Gateway route | `/api/v1/files/**` |

[VERIFIED]

## 4. Main controllers

| Controller | Base path | Endpoints |
|---|---|---|
| `FileController` | `/api/v1/files` | `POST /upload` (multipart), `GET /{fileId}`, `GET /{fileId}/download`, `DELETE /{fileId}` |

[VERIFIED]

## 5. Main services

| Service | Responsibility |
|---|---|
| `FileStorageService` | MinIO put/get/presign/remove; creates metadata after upload; cleans up orphaned objects on metadata failure |
| `FileMetadataService` | Upload orchestration, metadata lookup, download authorization, delete |
| `FileValidationService` | MIME allow-list per `StoredFileType`, size limits, filename sanitisation |
| `FileMetadataPersistence` | Transactional metadata save/soft-delete helpers |

[VERIFIED]

## 6. Repositories

`FileMetadataRepository`. [VERIFIED]

## 7. Entities and tables (`file_db`)

| Entity | Table | Notes |
|---|---|---|
| `FileMetadata` | `file_metadata` | `owner_user_id`, `file_name`, `file_type`, `mime_type`, `size_bytes`, `bucket`, unique `object_key`, `created_at`, `deleted_at` |

`StoredFileType`: `AVATAR` (`avatars`, 10 MB), `CV` (`cvs`, 10 MB), `POSTER` (`posters`, 10 MB),
`VIDEO` (`videos`, 50 MB), `CHAT_ATTACHMENT` (`chat-attachments`, 10 MB). [VERIFIED]

## 8. Database

Flyway: `V1__init_file_schema.sql`, `V2__Drop_unused_file_metadata_indexes.sql`,
`V3__File_type_size_checks_and_owner_active_index.sql` (3). `ddl-auto: validate`. [VERIFIED]

## 9. API routes

See [`../../06-api/06-file-api.md`](../../06-api/06-file-api.md). CV downloads are owner-only (else
`403`); other types may be downloaded by any authenticated user.

## 10. Events

None (no RabbitMQ, no publishers/consumers). [VERIFIED]

## 11. Cache usage

None (no Redis). [VERIFIED]

## 12. External dependencies

MinIO (`io.minio`), with separate storage and presign clients. No Feign/WebClient. [VERIFIED]

## 13. Auth and authorization

All endpoints require JWT. Uploads record the JWT subject as `owner_user_id`; delete requires owner;
CV download requires owner. [VERIFIED]

## 14. Configuration (env names only)

`SERVER_PORT`, `FILE_DB_URL`, `FILE_DB_USERNAME`, `FILE_DB_PASSWORD`, `MINIO_ENDPOINT`,
`MINIO_ACCESS_KEY`, `MINIO_SECRET_KEY`, `MINIO_BUCKETS` (default `avatars,cvs,posters,videos`; note
`chat-attachments` is a code enum bucket), `EUREKA_CLIENT_ENABLED`, `EUREKA_URL`, `VITHEY_JWT_SECRET`.
[VERIFIED]

## 15. Health checks

`GET /actuator/health`. [VERIFIED]

## 16. Tests

| Type | Path |
|---|---|
| Context (H2) | `FileServiceContextTest.java` |
| Smoke (Postgres+MinIO) | `FileServiceSmokeIT.java` |
| Unit | `service/FileValidationServiceTest.java` |

Test implemented — current execution result not independently verified.

## 17. Known limitations / TBD

- Presigned URL TTL is fixed at 1 hour in code; configurability `TBD — Requires confirmation.`
- No malware scanning / content moderation found. `TBD — Requires confirmation.`
- `MINIO_BUCKETS` default omits `chat-attachments` even though the enum uses it; bucket provisioning
  behaviour is `TBD — Requires confirmation.`
