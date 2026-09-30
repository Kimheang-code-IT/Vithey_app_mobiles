# Module: Jobs & CV

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/modules/jobs/`, `vithey_app/lib/data/repositories/job_application_repository.dart`, `vithey_app/lib/data/repositories/cv_repository.dart`

## Purpose

Job application flow (pick/upload/AI-generate a CV, review, submit), application status tracking, CV template gallery, and AI CV generation. Backed by `career-service`, `file-service`, and `ai_core` (CV). [VERIFIED]

## Screens & routes

| Screen | Route | File |
| --- | --- | --- |
| Apply CV (upload → review) | `/apply-cv` | `lib/modules/jobs/apply_cv_screen.dart` |
| CV template gallery | `/apply-cv/templates` | `lib/modules/jobs/ai_cv/templates/cv_template_gallery_screen.dart` |
| AI CV create/edit | `/apply-cv/ai-create` | `lib/modules/jobs/ai_cv/ai_cv_screen.dart` |
| Apply success | `/apply-cv/success` | `lib/modules/jobs/apply_success_screen.dart` |
| Application status | `/apply-cv/status` | `lib/modules/jobs/application_status_screen.dart` |

[VERIFIED] `lib/routes/app_pages.dart`.

## Main widgets

- `apply_job_stepper.dart`, `apply_job_context.dart`, `cv_upload_zone.dart`, `choose_saved_cv_sheet.dart`, `selected_cv_card.dart`, `review_cv_card.dart`, `position_selector.dart`, `job_match_score_card.dart`, `privacy_footer_note.dart`, `what_happens_next_list.dart`, `application_submitted_hero.dart`, `application_status_widgets.dart`.
- AI CV: `templates/cv_pdf_builder.dart`, `cv_template_preview.dart`, `cv_template_gallery_controller.dart`.

[VERIFIED]

## Controller / state

- `ApplyCvController` (`apply_cv_controller.dart`): `ApplyCvPhase {loadingJob, ready, uploadingCv, applying, error}`, `ApplyCvStep {upload, review}`, `CvSelectionMode`, `job`, `eligibility`, `savedCv(s)`, `localCv`, `isSubmitting`, `submitError`. Commands: `loadJobEligibility`, `pickLocalCv`, `selectSavedCv`, `openAiCvCreator`, `goToReview`, `submit`, `viewApplicationStatus`.
- `AiCvController` (`ai_cv/ai_cv_controller.dart`): `AiCvPhase {generating, preview, saving, error}`, `draft`, `activeSection`, `isRegeneratingSummary`, `isDownloading`. Commands: `_generate`, `updateSection`, `regenerateSummary`, `confirmUseForJob`, `saveOnly`, `downloadPdf`, `cancelToApply`.
- `CvTemplateGalleryController` (`ai_cv/templates/cv_template_gallery_controller.dart`).
- `ApplicationStatusController` (`application_status_screen.dart`): `detail`, `loadStatus`, `cycleMockStatus` (demo).
- `ApplySuccessScreen`/`ApplicationStatusScreen` are partly binding-less for success.

[VERIFIED]

## Repository / API dependencies

| Dependency | File | Endpoints |
| --- | --- | --- |
| `JobApplicationRepository` | `lib/data/repositories/job_application_repository.dart` | eligibility, submit, detail, applicants, applied jobs, status update |
| `JobApplicationService` | `lib/data/services/job_application_service.dart` | `GET/POST /job-applications`, `GET /job-applications/{id}`, `PATCH /job-applications/{id}/status`, `GET /job-applications/{id}/cv-preview` |
| `CvRepository` | `lib/data/repositories/cv_repository.dart` | saved CV list/default, upload, draft save, download |
| `UploadService` | `lib/data/services/upload_service.dart` | `POST /files/upload` |
| `AiRepository` | `lib/data/repositories/ai_repository.dart` | `POST /ai/cv/generate`, `POST /ai/cv/suggest`, `POST /ai/jobs/{id}/match` (not shipped live) |

[VERIFIED] `lib/core/constants/api_endpoints.dart`.

## User flow

### Apply
1. From a job post (feed/profile) → `/apply-cv` with `ApplyCvArgs(jobPostId, jobPreview)`.
2. `_loadInitialData` loads eligibility + saved CVs in parallel.
3. Eligibility enums: `eligible`, `alreadyApplied`, `ownJob`, `closed`, `notFound`, `notJob` (`job_application_repository.dart:12-19`). Non-eligible shows a message; already-applied can open status.
4. Select a saved CV or pick a local file (PDF/DOC/DOCX, ≤10 MB) or launch AI CV creator.
5. Review step shows job context + optional AI match card; `submit()` re-checks eligibility, optionally uploads, then creates the application and navigates to success.

### AI CV
1. Template gallery → `/apply-cv/ai-create` with `AiCvArgs`.
2. `_generate` calls `AiRepository.generateCvDraft()` (mock fixture or `POST /ai/cv/generate`).
3. Incomplete profile → error phase with guidance.
4. Edit sections, regenerate summary, download/share PDF, or save + return to apply.

[VERIFIED]

## Loading / error / empty states

- Apply: phase-driven (`loadingJob` spinner, `uploadingCv`/`applying` button labels via `submitLabel`, `error` view with `AppStrings.applyJobLoadError`), inline `fileError`/`submitError`.
- AI CV: generating spinner, error view with retry, preview editor.
- Application status: `LoadingWidget` / `AppErrorWidget` / status timeline.
- Duplicate submit is guarded by `_submitLocked`.

[VERIFIED]

## Permissions

- File picking (platform file picker); no runtime permission required for document pick on modern Android/iOS.
- PDF share uses `share_plus`.

## Known limitations / stubs

- **Mock-first** application/CV state: persisted via `shared_preferences` mock keys. [VERIFIED]
- **Live AI job match / skills are not shipped**: `matchJob` and `skillScores` return zero/empty on live API. [VERIFIED] `ai_repository.dart:100-136`.
- `CvRepository.saveDraftAsCv` writes a local temp PDF and stores a mock library entry; live mode still treats CVs as a single default. [VERIFIED]
- **Known backend defect affecting Flutter draft**: `cv_app_service.to_draft` field mismatch can drop fields (`EVIDENCE-BASIS §6`). [VERIFIED]
- `ApplicationStatusController.cycleMockStatus` is a demo-only status cycler. [VERIFIED]
- Warm CV policy label is "JPG, PNG, or PDF (Max 5MB)" while the enforced rule is PDF/DOC/DOCX ≤10 MB — copy/behavior mismatch. [VERIFIED] `app_strings.dart:63` vs `cv_repository.dart:27-33`.

## TBDs

- [TBD] Live job-match endpoint (`POST /ai/jobs/{id}/match`). TBD — Requires confirmation.
- [TBD] CV library (multi-CV) server support; live API returns a single default. TBD — Requires confirmation.
