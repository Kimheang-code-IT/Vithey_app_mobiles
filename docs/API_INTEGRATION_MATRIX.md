# API_INTEGRATION_MATRIX.md

One row per Flutter network operation. Base URL = `API_BASE_URL` (default
`http://10.0.2.2:8080/api/v1` in dev; production via `--dart-define`). All JSON
uses the backend `SNAKE_CASE` Jackson strategy. Auth scheme = `Authorization:
Bearer <access_token>` unless noted.

Flutter call sites: `vithey_app/lib/core/constants/api_endpoints.dart` (paths)
+ `vithey_app/lib/data/services/*.dart` (calls + models).
Backend handlers under `backend/services/<svc>/src/main/java/...`.

Status legend: WORKING = verified mapping; FIXED = corrected in this pass.

## Auth (`auth-service`, public unless noted)

| Feature | Flutter call site | Method/path | Auth | Request | Success | Errors | Backend handler | Status |
|---|---|---|---|---|---|---|---|---|
| Register | `auth_service.dart:58` | `POST /auth/register` | none | `full_name,email,phone,password,role` | 201 `{data:{user,tokens}}` | 400/409 | `AuthController.register` | WORKING |
| Login | `auth_service.dart:17` | `POST /auth/login` | none | `email_or_phone,password` | 200 `{data:{user,tokens}}` | 400/401 | `AuthController.login` | WORKING |
| Google login | `auth_service.dart:29` | `POST /auth/google` | none | `id_token` | 200 `{data:{user,tokens}}` | 400/401 | `AuthController.google` | WORKING |
| Refresh | `auth_service.dart:99`, `dio_client.dart:77` | `POST /auth/refresh` | none | `refresh_token` | 200 `{data:{access_token,refresh_token,expires_in}}` | 401 | `AuthController.refresh` | WORKING |
| Logout | `auth_service.dart:88` | `POST /auth/logout` | Bearer | `refresh_token` | 204 | 401 | `AuthController.logout` | WORKING |
| Me | `auth_service.dart:77`, `student_verification_service.dart:12` | `GET /auth/me` | Bearer | — | 200 `{data:{user_id,email,phone,full_name,role,is_student_verified,is_email_verified}}` | 401 | `AuthController.me` | WORKING |
| Change password | `auth_service.dart:114` | `PATCH /auth/me/password` | Bearer | `current_password,new_password` | 200 message | 400/401 | `AuthController.changePassword` | WORKING |
| Forgot password | `auth_service.dart:128` | `POST /auth/forgot-password` | none | `email` | 200 generic message | 400 | `AuthController.forgotPassword` | WORKING |
| Reset password | (not called from Flutter) | `POST /auth/reset-password` | none | `token,new_password` | 200 | 400 | `AuthController.resetPassword` | BACKEND-ONLY |
| Verify email | (not called from Flutter) | `POST /auth/verify-email` | none | `token` | 200 | 400 | `AuthController.verifyEmail` | BACKEND-ONLY |
| Student verify | `student_verification_service.dart:29` | `POST /students/verify` | Bearer | `student_id,university_email,document_file_id` | 200 `{data:{status,is_student_verified,...}}` | 400/401/409 | `StudentVerificationController.verify` | WORKING |

## User profile (`user-profile-service`)

| Feature | Flutter call site | Method/path | Auth | Request | Success | Errors | Backend handler | Status |
|---|---|---|---|---|---|---|---|---|
| My profile (auth) | `profile_service.dart:23` | `GET /users/me` | Bearer | — | 200 profile | 404 | `UserController.getMe` | WORKING |
| Update my profile | `profile_service.dart:58` | `PATCH /users/me` | Bearer | partial profile fields | 200 profile | 400/401 | `UserController.updateMe` | WORKING |
| Avatar update | (service path exists server side) | `PATCH /users/me/avatar` | Bearer | avatar fields | 200 | 400 | `UserController.updateAvatar` | BACKEND-ONLY |
| User by id | `profile_service.dart:12` | `GET /users/{userId}` | Bearer | — | 200 profile | 404 | `UserController.getUser` | WORKING |
| User search | `user_search_service.dart:16` | `GET /users/search?search=&page=&limit=` | Bearer | query | 200 list + meta | 400 | `UserController.search` | WORKING |
| Settings get | `settings_service.dart:14` | `GET /users/me/settings` | Bearer | — | 200 settings | 401 | `SettingsController.get` | WORKING |
| Settings update | `settings_service.dart:29` | `PATCH /users/me/settings` | Bearer | settings fields | 200 settings | 400/401 | `SettingsController.update` | WORKING |

## Content / social (`content-service`)

| Feature | Flutter call site | Method/path | Auth | Request | Success | Errors | Backend handler | Status |
|---|---|---|---|---|---|---|---|---|
| Feed | `post_service.dart:17` | `GET /posts?page=&limit=&type=&search=` | Bearer | query | 200 list + meta | 400 | `PostController.list` | WORKING |
| Create post | `post_service.dart:194` | `POST /posts` | Bearer | `type,content,media_file_id,job_meta,scheduled_at` | 201 post | 400/422 | `PostController.create` | WORKING |
| Post detail | `post_service.dart:69` | `GET /posts/{id}` | Bearer | — | 200 post | 404 | `PostController.get` | WORKING |
| Update post | `post_service.dart:222` | `PATCH /posts/{id}` | Bearer | `content,media_file_id,remove_media,job_meta` | 200 post | 400/403/404 | `PostController.update` | WORKING |
| Delete post | `post_service.dart:244` | `DELETE /posts/{id}` | Bearer | — | 204 | 403/404 | `PostController.delete` | WORKING |
| User posts | `post_service.dart:46`, `profile_service.dart:41` | `GET /users/{id}/posts?type=&page=&limit=` | Bearer | query | 200 list | 404 | `PostController.byUser` | WORKING |
| Comments list | `post_service.dart:117` | `GET /posts/{id}/comments?page=&limit=` | Bearer | query | 200 list | 404 | `CommentController.list` | WORKING |
| Comment create | `post_service.dart:139` | `POST /posts/{id}/comments` | Bearer | `text,parent_comment_id` | 201 comment | 400 | `CommentController.create` | WORKING |
| Comment update | `post_service.dart:160` | `PATCH /posts/{postId}/comments/{commentId}` | Bearer | `text` | 200 | 403/404 | `CommentController.update` | WORKING |
| Comment delete | `post_service.dart:176` | `DELETE /posts/{postId}/comments/{commentId}` | Bearer | — | 204 | 403/404 | `CommentController.delete` | WORKING |
| React toggle | `post_service.dart:81` | `POST /posts/{id}/reactions` | Bearer | `{}` | 200/201 | 404 | `ReactionController.toggle` | WORKING |
| Reactions list | (service path) | `GET /posts/{id}/reactions` | Bearer | — | 200 | 404 | `ReactionController.list` | BACKEND-ONLY |
| Follow | `post_service.dart:92` | `POST /users/{id}/follow` | Bearer | `{}` | 200/204 | 404/409 | `FollowController.follow` | WORKING |
| Unfollow | `post_service.dart:103` | `DELETE /users/{id}/follow` | Bearer | — | 204 | 404 | `FollowController.unfollow` | WORKING |
| Followers | (service path) | `GET /users/{id}/followers` | Bearer | — | 200 | 404 | `FollowController.followers` | BACKEND-ONLY |
| Following | (service path) | `GET /users/{id}/following` | Bearer | — | 200 | 404 | `FollowController.following` | BACKEND-ONLY |

## Files (`file-service`)

| Feature | Flutter call site | Method/path | Auth | Request | Success | Errors | Backend handler | Status |
|---|---|---|---|---|---|---|---|---|
| Upload | `upload_service.dart:58` | `POST /files/upload` | Bearer | multipart `file`,`type` | 201 `{data:{file_id,file_name,mime_type,size_bytes}}` | 400/413/415 | `FileController.upload` | WORKING |
| Download | `api_endpoints.dart:59` (via image/network + secure preview) | `GET /files/{id}/download` | Bearer | — | 200 bytes | 403/404 | `FileController.download` | WORKING |
| Metadata | (client builds URLs) | `GET /files/{id}` | Bearer | — | 200 metadata | 404 | `FileController.get` | BACKEND-ONLY |
| Delete | (not called from Flutter) | `DELETE /files/{id}` | Bearer | — | 204 | 403/404 | `FileController.delete` | BACKEND-ONLY |

## Career / jobs (`career-service`)

| Feature | Flutter call site | Method/path | Auth | Request | Success | Errors | Backend handler | Status |
|---|---|---|---|---|---|---|---|---|
| Apply | `job_application_service.dart:108` | `POST /job-applications` | Bearer | `job_post_id,cv_file_id,application_note` | 201 application | 400/409 | `JobApplicationController.create` | WORKING |
| List applications | `job_application_service.dart:145` | `GET /job-applications?job_post_id=&page=&limit=` | Bearer | query | 200 list | 401 | `JobApplicationController.list` | WORKING |
| Application detail | `job_application_service.dart:127` | `GET /job-applications/{id}` | Bearer | — | 200 application | 403/404 | `JobApplicationController.get` | WORKING |
| Update status | `job_application_service.dart:176` | `PATCH /job-applications/{id}/status` | Bearer | `status` | 200 | 403/404 | `JobApplicationController.updateStatus` | WORKING |
| CV preview | `api_endpoints.dart:60` | `GET /job-applications/{id}/cv-preview` | Bearer | — | 200 | 403/404 | `JobApplicationController.cvPreview` | WORKING |
| Get CV | `cv_repository.dart` via `api_endpoints.dart:55` | `GET /users/me/cv` | Bearer | — | 200 | 404 | `UserCvController.get` | WORKING |
| Save CV | `cv_repository.dart` | `PUT /users/me/cv` | Bearer | cv payload | 200 | 400 | `UserCvController.put` | WORKING |
| Jobs list/detail | `api_endpoints.dart` (job search uses posts `job_meta`) | `GET /jobs/**` | Bearer | query | 200 | 404 | career-service job endpoints | WORKING |

## Finance (`finance-service`)

| Feature | Flutter call site | Method/path | Auth | Request | Success | Errors | Backend handler | Status |
|---|---|---|---|---|---|---|---|---|
| Payments list | `finance_service.dart:13` | `GET /payments?page=&limit=` | Bearer | query | 200 list + meta | 401 | `PaymentController.list` | WORKING |
| Payment invoice | `finance_service.dart:28` | `GET /payments/{id}` | Bearer | — | 200 invoice | 403/404 | `PaymentController.get` | WORKING |
| Pay | `payment_controller.dart` | `POST /payments/{id}/pay` | Bearer | payment payload | 200 | 400/402 | `PaymentController.pay` | WORKING |
| Alerts | `finance_service.dart:55` | `GET /payments/alerts` | Bearer | — | 200 list | 401 | `PaymentController.alerts` | WORKING |
| Fees | `finance_service.dart:39` | `GET /fees` | Bearer | — | 200 list | 401 | `FeeController.list` | WORKING |
| Fee categories | (backend) | `GET /fees/categories` | Bearer | — | 200 | 401 | `FeeController.categories` | BACKEND-ONLY |

## Chat (`chat-service` + STOMP)

| Feature | Flutter call site | Method/path | Auth | Request | Success | Errors | Backend handler | Status |
|---|---|---|---|---|---|---|---|---|
| Conversations | `chat_service.dart:12` | `GET /conversations?page=&limit=` | Bearer | query | 200 list | 401 | `ConversationController.list` | WORKING |
| Start request | `chat_service.dart:48` | `POST /message-requests` | Bearer | `to_user_id,initial_message` | 201 conversation | 400/404 | `MessageRequestController.createRequest` | WORKING |
| (alt) start | `api_endpoints.dart:31` | `POST /conversations/start` | Bearer | same | 201 | 400 | `ConversationController.createRequest` | WORKING |
| Requests list | `chat_service.dart:27` | `GET /message-requests` | Bearer | — | 200 list | 401 | `MessageRequestController.listPendingRequests` | WORKING |
| Accept | `chat_service.dart:65` | `POST /conversations/{id}/accept` | Bearer | `{}` | 200 | 403/404 | `ConversationController.accept` | WORKING |
| Decline | `chat_service.dart:76` | `POST /conversations/{id}/decline` | Bearer | `{}` | 200 | 403/404 | `ConversationController.decline` | WORKING |
| Block | `chat_service.dart:87` | `POST /conversations/{id}/block` | Bearer | `{}` | 200 | 403/404 | `ConversationController.block` | WORKING |
| Report user | `chat_service.dart:98` | `POST /users/{id}/report` | Bearer | `reason` | 200 | 400/404 | `ReportController.report` | WORKING |
| Messages list | `chat_service.dart:113` | `GET /conversations/{id}/messages?page=&limit=` | Bearer | query | 200 list | 403/404 | `MessageController.list` | WORKING |
| Send message | `chat_service.dart:135` | `POST /conversations/{id}/messages` | Bearer | `text,client_message_id,reply_to_message_id` | 201 | 400/403 | `MessageController.send` | WORKING |
| Mark message read | `chat_service.dart:151` | `PATCH /messages/{id}/read` | Bearer | — | 200 | 403/404 | `MessageController.markRead` | WORKING |
| Mark conversation read | (STOMP/back-end) | `POST /conversations/{id}/messages/read` | Bearer | `{messageIds?}` | 200 | 403 | `MessageController.markConversationRead` | BACKEND-ONLY |
| Presence | (STOMP) | `GET /conversations/{id}/presence` | Bearer | — | 200 | 404 | `ConversationController.presence` | BACKEND-ONLY |
| Realtime | `chat_stomp_service.dart`, `chat_realtime_hub.dart` | `WS /ws` (STOMP) | Bearer/connect headers | STOMP frames | events | — | chat STOMP broker | WORKING |

## Notifications (`notification-service`)

| Feature | Flutter call site | Method/path | Auth | Request | Success | Errors | Backend handler | Status |
|---|---|---|---|---|---|---|---|---|
| List | `notification_service.dart:16` | `GET /notifications?page=&limit=&is_read=` | Bearer | query | 200 list + meta | 401 | `NotificationController.list` | WORKING |
| Unread count | `notification_service.dart:140` | `GET /notifications/unread-count` | Bearer | — | 200 `{count}` | 401 | `NotificationController.unreadCount` | WORKING |
| Mark read | `notification_service.dart:155` | `PATCH /notifications/{id}/read` | Bearer | — | 200 | 404 | `NotificationController.markRead` | WORKING |
| Mark all read | `notification_service.dart:166` | `PATCH /notifications/read-all` | Bearer | — | 200 `{updated_count}` | 401 | `NotificationController.markAllRead` | WORKING |
| Delete | `notification_service.dart:184` | `DELETE /notifications/{id}` | Bearer | — | 204 | 404 | `NotificationController.delete` | WORKING |
| Register device | `notification_service.dart:198` | `POST /notifications/devices` | Bearer | `fcm_token,platform` | 200/201 | 400 | `DeviceTokenController.register` | WORKING |
| Unregister device | `notification_service.dart:213` | `DELETE /notifications/devices/{token}` | Bearer | — | 204 | 404 | `DeviceTokenController.unregister` | WORKING |

## Map / places (`map-service`)

| Feature | Flutter call site | Method/path | Auth | Request | Success | Errors | Backend handler | Status |
|---|---|---|---|---|---|---|---|---|
| Nearby | `place_service.dart:16` | `GET /places/nearby?lat=&lng=&...` | Bearer | query | 200 result | 400 | `PlaceSearchController.nearby` | WORKING |
| Search | `place_service.dart:35` | `GET /places/search?query=&lat=&lng=&...` | Bearer | query | 200 result | 400 | `PlaceSearchController.search` | WORKING |
| Autocomplete | `place_service.dart:57` | `GET /places/autocomplete?input=&lat=&lng=` | Bearer | query | 200 list | 400 | `PlaceSearchController.autocomplete` | WORKING |
| Detail | `place_service.dart:84` | `GET /places/{googlePlaceId}` | Bearer | — | 200 detail | 404 | `PlaceDetailController.detail` | WORKING |
| Favorites | `place_service.dart:94` | `GET /places/favorites` | Bearer | — | 200 list | 401 | `PlaceFavoriteController.list` | WORKING |
| Save favorite | `place_service.dart:128` | `POST /places/favorites` | Bearer | place payload | 200/201 | 400 | `PlaceFavoriteController.add` | WORKING |
| Remove favorite | `place_service.dart:140` | `DELETE /places/favorites/{googlePlaceId}` | Bearer | — | 204 | 404 | `PlaceFavoriteController.remove` | WORKING |
| History | `place_service.dart:112` | `GET /places/history` | Bearer | — | 200 list | 401 | `PlaceHistoryController.list` | WORKING |
| Clear history | (backend) | `DELETE /places/history` | Bearer | — | 204 | 401 | `PlaceHistoryController.clear` | BACKEND-ONLY |

## AI (`ai-core` via gateway `/api/v1/ai/**`)

| Feature | Flutter call site | Method/path | Auth | Request | Success | Errors | Backend handler | Status |
|---|---|---|---|---|---|---|---|---|
| Chat | `ai_service.dart:70` | `POST /ai/chat` | Bearer | `message,session_id,topic` | 200 `{data:{session_id,reply,...}}` | 400/404/502 | `flutter_routes.chat` | WORKING |
| Chat stream (SSE) | `ai_service.dart:103` | `POST /ai/chat/stream` | Bearer | same + `client_message_id` | SSE `meta`/`token`/`done` | `error` event | `flutter_routes.chat_stream` | WORKING |
| Cancel stream | `ai_service.dart:195` | `DELETE /ai/chat/requests/{requestId}` | Bearer | — | 204 | 404 | `flutter_routes.cancel_request` | WORKING |
| Regenerate | `ai_service.dart:205` | `POST /ai/messages/{messageId}/regenerate` | Bearer | `{}` | 200 | 404/400 | `flutter_routes.regenerate` | WORKING |
| Sessions | `ai_service.dart:226` | `GET /ai/sessions?page=&limit=` | Bearer | query | 200 list + meta | 401 | `flutter_routes.list_sessions` | WORKING |
| Session messages | `ai_service.dart:245` | `GET /ai/sessions/{id}/messages?page=&limit=` | Bearer | query | 200 list + meta | 404 | `flutter_routes.list_messages` | WORKING |
| Delete session | `ai_service.dart:260` | `DELETE /ai/sessions/{id}` | Bearer | — | 204 | 404 | `flutter_routes.delete_session` | WORKING |
| CV generate | `ai_service.dart:275` | `POST /ai/cv/generate` | Bearer | `target_role,language,template_id` | 200 CV draft | 400/502 | `flutter_routes.cv_generate` | WORKING |
| CV suggest | `ai_service.dart:296` | `POST /ai/cv/suggest` | Bearer | `section,original_text,cv_file_id` | 200 `{suggested_text}` | 400/502 | `flutter_routes.cv_suggest` | WORKING |

## Contract checks performed

- Method + exact path: all Flutter `ApiEndpoints` constants resolve to a real
  backend route at `/api/v1/...` (verified against controllers).
- Envelope: `{data,error}` / `{data,meta}` matches `ApiResponse`.
- Field names: backend Jackson `SNAKE_CASE`; Flutter models read snake_case.
- Auth: gateway public-path list exactly matches the client's `_publicAuthPaths`
  for the auth endpoints it calls.
- Refresh: single-use rotation verified E2E; client refresh made single-flight
  to avoid races (see PROJECT_AUDIT P1-C).
- Errors: 400/401/403/404/409/422/500 consumed by `ErrorMapper`.
