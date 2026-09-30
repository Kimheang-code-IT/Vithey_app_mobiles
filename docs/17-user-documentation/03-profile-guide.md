# Profile & Account Guide

> Status: Verified (core) · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/modules/profile/**`, `vithey_app/lib/modules/settings/account/**`, `vithey_app/lib/routes/app_pages.dart`, `api_docs.md` §4
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

## 1. Overview

Your profile is the first bottom-nav tab (avatar icon). It shows your identity, professional
details, posts/reels, and CV. It also hosts entry points to job applicants, post analytics, QR
sharing, and student verification [VERIFIED: `lib/modules/profile/profile_screen.dart`,
`lib/core/widgets/app_bottom_navigation.dart`].

Profile data comes from `user-profile-service` (`/users/me`, `/users/{id}`) with CV data from
`career-service` (`/users/me/cv`) [VERIFIED: `api_docs.md` §4, §7, §15].

## 2. Profile screen

Key elements [VERIFIED: `lib/modules/profile/widgets/**`, `profile_controller.dart`]:

| Element | Purpose |
| --- | --- |
| Header / cover | Avatar, name, headline; app-bar menu opens Settings (`/settings`) |
| Skills | Skill chips; edited via the edit-profile bottom sheet |
| Reels / media grid | Your video/poster content; "create" tile opens the post composer |
| Posts tab | Your posts and job listings |
| CV entry | Opens saved CV / AI CV creation |
| QR / scan | Share your profile via QR; open the scanner (`/profile/scan-qr`) |
| Insights / analytics | Post analytics (`/posts/analytics`) for your content |
| Verify student | Opens student verification (`/student-verification`) |

## 3. Edit profile

Editing lives in **Edit Profile** (`/profile/edit`) and a bottom sheet for quick edits
[VERIFIED: `lib/modules/profile/edit_profile_screen.dart`, `widgets/edit_profile_bottom_sheet.dart`].

Editable fields (sent via `PATCH /users/me`, all optional)
[VERIFIED: `api_docs.md` §4]:

`full_name`, `bio`, `telegram_link`, `facebook_link`, `university`, `major`, `graduation_year`,
`location`, `date_of_birth`, `workplace`, `portfolio_url`, `phone`, `email`, `skills[]`,
`education[]`, `field_visibility`.

Avatar: upload via `POST /files/upload` (`type=AVATAR`) then `PATCH /users/me/avatar` with the
returned `avatar_file_id` [VERIFIED: `api_docs.md` §4, §5].

> Field visibility is stored as `field_visibility`; the privacy toggles below are the user-facing
> controls [VERIFIED: `api_docs.md` §4].

## 4. Account settings

**Settings → Account** (`/settings/account`) shows private identity and a verification summary
[VERIFIED: `lib/modules/settings/account/account_settings_screen.dart`]:

- Avatar (change via camera button), full name, email, phone, date of birth, gender, location.
- **Student verification** row → `/student-verification` (submits `student_id` + `university_email`).

> Professional fields (bio, skills, work, links) live in **Edit Profile**, not Account settings —
> the split is intentional in the UI.

## 5. Views a user can see

| Screen | Route | Notes |
| --- | --- | --- |
| Own profile | `/profile` | Tab 0 |
| Other user's profile | `/profile/view` | Public view; follow/unfollow, message |
| QR scanner | `/profile/scan-qr` | Scans a profile QR |
| Post analytics | `/posts/analytics` | Insights for your posts |
| Job applicants | `/profile/jobs/applicants` | For your job listings |
| Applicant detail | `/profile/applicants/detail` | Review an applicant |
| Applicant CV preview | `/profile/applicants/cv` | View applicant's CV |
| Own CV preview | `/profile/cv` | Preview your saved CV |

[VERIFIED: `lib/routes/app_pages.dart`, `lib/core/constants/app_routes.dart`]

## 6. Privacy & preferences

- **Settings → Privacy** (`/settings/privacy`): Profile Visibility, Data Sharing, Activity
  Tracking toggles, plus a "Privacy practices" information screen
  [VERIFIED: `lib/modules/settings/privacy/privacy_settings_screen.dart`].
- **Settings → Language**: English or Khmer. The stored preference is applied; note that app UI
  strings are currently hardcoded in English — Khmer is a stored preference and a CV label only
  (no `.arb` localization) [VERIFIED: `_meta/EVIDENCE-BASIS.md` §7].
- **Settings → Dark Mode**: light/dark theme toggle [VERIFIED: `settings_controller.dart`].

## 7. Not yet available

- **Data & storage** and **Accessibility** menu rows show "coming soon" [VERIFIED: `settings_home_screen.dart`].
- Two-Factor Authentication and Biometric Login are **"Coming soon"** [VERIFIED: `security_settings_screen.dart`].
- Device/session management is display-only ("Current Device — Active"); no remove-session action
  is exposed [VERIFIED: `security_settings_screen.dart`].

## 8. Related

- [02-login-registration.md](02-login-registration.md) · [05-job-cv-guide.md](05-job-cv-guide.md) · [06-finance-guide.md](06-finance-guide.md)
- [../06-api/04-user-profile-api.md](../06-api/04-user-profile-api.md)
- Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)
