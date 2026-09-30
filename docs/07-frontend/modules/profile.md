# Module: Profile

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/modules/profile/`, `vithey_app/lib/data/repositories/profile_repository.dart`, `vithey_app/lib/data/services/profile_service.dart`

## Purpose

Own profile and visitor profile, editing, skills management, posted content tabs, applied jobs, job applicants + applicant detail, own/visitor CV preview, post analytics, and QR scanning. Backed by `user-profile-service`, `auth-service`, `content-service`, and `career-service`. [VERIFIED]

## Screens & routes

| Screen | Route | File |
| --- | --- | --- |
| Own Profile (tab 0) | `/profile` | `lib/modules/profile/profile_screen.dart` |
| Visitor Profile | `/profile/view` | `lib/modules/profile/profile_view_screen.dart` |
| Scan QR | `/profile/scan-qr` | `lib/modules/profile/scan_qr_screen.dart` |
| Edit Profile | `/profile/edit` | `lib/modules/profile/edit_profile_screen.dart` |
| Job Applicants | `/profile/jobs/applicants` | `lib/modules/profile/job_applicants_screen.dart` |
| Applicant Detail | `/profile/applicants/detail` | `lib/modules/profile/applicant_detail_screen.dart` |
| Applicant CV preview | `/profile/applicants/cv` | `lib/modules/profile/cv_screens.dart` |
| Preview own CV | `/profile/cv` | `lib/modules/profile/cv_screens.dart` |
| Post Analytics | `/posts/analytics` | `lib/modules/profile/post_analytics_screen.dart` |

[VERIFIED] `lib/routes/app_pages.dart`.

## Main widgets

- Header/cover: `profile_header.dart`, `profile_cover_redesign.dart`, `profile_qr_bottom_sheet.dart`, `qr_scan_corner_frame.dart`.
- Tabs: `profile_tabs.dart`, `profile_all.dart`, `profile_reels.dart`, `profile_skills.dart`, `skill_icon.dart`.
- Content: `profile_post_insights_bar.dart`, `profile_content_analytics_tile.dart`, `profile_job_card.dart`, `profile_section_sheets.dart`, `experience_timeline.dart`.
- Story/Reel tiles: `profile_reels_card.dart`, `profile_reel_grid_tile.dart`, `profile_reel_create_tile.dart`.
- Applicants: `applicant_ai_match_panel.dart`, `ai_match_badge.dart`, `application_feedback_success.dart`, `secure_cv_preview.dart`.
- AI CV entry: `profile_cv_ai_entry.dart`.

[VERIFIED]

## Controller / state

- `ProfileController` (`profile_controller.dart`) — own profile; implements `ProfileTabsHost` + `ProfileAllPostsMixin`. `TabController(length: 5)`: All / Videos / Posters / Jobs / Applied. State: `profile`, `isLoading`, `hasError`, `errorMessage`, `appliedJobs`, `appliedJobsLoading`, per-type `tabPosts`/`tabLoading`/`tabLoaded`. Commands: `loadProfile`, `refreshProfile`, `shareProfile`, `openEditProfile`, `saveSkills`, `openVerifyStudent`, `openPreviewOwnCv`, `openPost`, `editPost`, `deletePost`, `openJobApplicants`, `editJobPost`, `deleteJobPost`, `applyToJob`.
- `ProfileViewController` (`profile_view_controller.dart`) — visitor profile; read-only profile editing hooks are empty; adds `toggleFollow`, `startMessage`.
- `EditProfileController` (`edit_profile_screen.dart`), `JobApplicantsController` (`job_applicants_screen.dart`), `ApplicantDetailController` (`applicant_detail_screen.dart`), CV screen controllers (`cv_screens.dart`), `PostAnalyticsController` (`post_analytics_screen.dart`).
- Shared mixin `ProfileAllPostsMixin` (`profile_all_posts_mixin.dart`) and interface `ProfileTabsHost` (`profile_tabs_host.dart`).

[VERIFIED]

## Repository / API dependencies

| Dependency | File | Endpoints |
| --- | --- | --- |
| `ProfileRepository` | `lib/data/repositories/profile_repository.dart` | `GET /users/me`, `GET /users/{id}`, `PUT/PATCH` profile fields, applicant detail |
| `ProfileService` | `lib/data/services/profile_service.dart` | `/users/me`, `/users/{id}` |
| `PostRepository` | `lib/data/repositories/post_repository.dart` | user posts, follow state |
| `JobApplicationRepository` | `lib/data/repositories/job_application_repository.dart` | applicants, applied jobs, status updates |
| `CvRepository` | `lib/data/repositories/cv_repository.dart` | own CV metadata / download |
| `StudentVerificationRepository` | `lib/data/repositories/student_verification_repository.dart` | verify entry state |
| `ChatRepository` | `lib/data/repositories/chat_repository.dart` | `startMessage` |

[VERIFIED]

## User flow

1. Profile tab loads own profile + all post types (`ensureAllPostsLoaded`).
2. Tabs lazily load each post type on first view; Applied tab lazy-loads applied jobs.
3. FAB opens Edit Profile; on `true` return the profile refreshes.
4. Skills can be added/edited/removed and persisted via `updateProfile`.
5. Visitors: `ProfileViewController` loads by `ProfileArgs(userId)` and offers follow + message; `startMessage` finds/creates a conversation and opens chat detail.
6. Job owners open applicant lists and applicant detail; statuses can be updated (mock cycling supported).
7. Own CV can be previewed; AI CV entry routes to the template gallery/AI CV.

[VERIFIED]

## Loading / error / empty states

- `isLoading` → `LoadingWidget`; `hasError` → `AppErrorWidget` with retry.
- Tab load failures → snackbar.
- Applicant/CV screens have dedicated loading/error/empty views (`cv_screens.dart` notes "CV file is saved but preview URL is not available yet." for missing previews). [VERIFIED]

## Permissions

- Camera permission for QR scanning (`mobile_scanner`); declared in the Android manifest (`CAMERA`). [VERIFIED] `android/app/src/main/AndroidManifest.xml:15`.

## Known limitations / stubs

- **Mock-first**: `USE_MOCK_API` returns fixture profiles/applicants; mock profile remaps fixture authors to the logged-in user. [VERIFIED]
- Visitor profile applied-jobs returns empty unless it is the current user on the live API. [VERIFIED] `profile_repository.dart:96-105`.
- Own-profile route gate relies on `ProfileRepository.currentUserId`; there is no server authorization check in the client. [VERIFIED]
- Applicant AI match panel is mock-driven (live match endpoint not shipped). [VERIFIED]
- QR scan route has no binding and pushes results via navigation; behavior is client-side.

## TBDs

- [TBD] Live applicant AI-match scoring endpoint. TBD — Requires confirmation.
- [TBD] Whether visitor profiles expose applied jobs on the live API. TBD — Requires confirmation.
