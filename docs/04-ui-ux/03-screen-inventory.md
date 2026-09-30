# Screen Inventory

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/routes/app_pages.dart`, `vithey_app/lib/core/constants/app_routes.dart`, `vithey_app/lib/modules/**`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [UI/UX overview](01-ui-ux-overview.md) · [User flow](02-user-flow.md) · [Navigation flow](05-navigation-flow.md)

All 46 routes below are registered in `AppPages.routes` and reference real screen classes. **There are no GetX middleware guards**; "gated" simply means the app reaches the screen only after the manual funnel in `SplashController`/`AuthNavigation`, or the API rejects the call. [VERIFIED — `app_pages.dart`, `splash_controller.dart`]

## 1. Auth & first-run (module `auth`)

| Route | Screen class | Binding | Notes |
|---|---|---|---|
| `/splash` | `SplashScreen` | `SplashBinding` | animation + route decision |
| `/select-language` | `IntroRibbonScreen` (page 0) | `IntroRibbonBinding` | no transition |
| `/onboarding` | `IntroRibbonScreen` (page 1) | `IntroRibbonBinding` | 3 slides |
| `/auth` | `IntroRibbonScreen` (page 4) | `IntroRibbonBinding` | sign-in |
| `/login` | `IntroRibbonScreen` (page 4) | `IntroRibbonBinding` | sign-in |
| `/register` | `IntroRibbonScreen` (page 5) | `IntroRibbonBinding` | sign-up |
| `/auth/forgot-password` | `ForgotPasswordScreen` | `AuthBinding` | |
| `/auth/google` | `GoogleAccountChooserScreen` | `AuthBinding` | stub unless `ENABLE_GOOGLE_AUTH` |
| `/auth/google/confirm` | `GoogleAuthConfirmationScreen` | `AuthBinding` | stub |
| `/startup/skills` | `StartupScreen` | `StartupBinding` | selects skills |
| `/startup/interests` | `StartupScreen` | `StartupBinding` | selects interests |
| `/startup/discovery` | `StartupScreen` | `StartupBinding` | discovery sources |

## 2. Home, content & social (module `home`)

| Route | Screen class | Binding | Notes |
|---|---|---|---|
| `/home` | `MainShellScreen` | `MainShellBinding` | hosts Profile/Home/Reels/Notifications tabs |
| `/reels` | `ReelsScreen` | `ReelsBinding` | video reels |
| `/create-post` | `CreatePostScreen` | `CreatePostBinding` | |
| `/posts/detail` | `PostDetailScreen` | `PostDetailBinding` | comments/@mentions |
| `/posts/analytics` | `PostAnalyticsScreen` | — | derived stats |
| `/notifications` | `NotificationScreen` | `NotificationBinding` | All/Unread filters |
| `/search` | `SearchScreen` | `SearchBinding` | |
| `/search/see-all` | `SearchSeeAllScreen` | `SearchSeeAllBinding` | |

## 3. Jobs & CV (module `jobs`)

| Route | Screen class | Binding | Notes |
|---|---|---|---|
| `/apply-cv` | `ApplyCvScreen` | `ApplyCvBinding` | apply with CV |
| `/apply-cv/templates` | `CvTemplateGalleryScreen` | `CvTemplateGalleryBinding` | |
| `/apply-cv/ai-create` | `AiCvScreen` | `AiCvBinding` | real LLM CV generation |
| `/apply-cv/success` | `ApplySuccessScreen` | — | |
| `/apply-cv/status` | `ApplicationStatusScreen` | `ApplicationStatusBinding` | |

## 4. Profile (module `profile`)

| Route | Screen class | Binding | Notes |
|---|---|---|---|
| `/profile` | `ProfileScreen` | `ProfileBinding` | tab host; `embedded: true` in shell |
| `/profile/view` | `ProfileViewScreen` | `ProfileViewBinding` | other user view |
| `/profile/jobs/applicants` | `JobApplicantsScreen` | `JobApplicantsBinding` | |
| `/profile/applicants/cv` | `ApplicantCvScreen` | `ApplicantCvBinding` | |
| `/profile/cv` | `PreviewOwnCvScreen` | — | |
| `/profile/applicants/detail` | `ApplicantDetailScreen` | `ApplicantDetailBinding` | |
| `/profile/scan-qr` | `ScanQrScreen` | — | `mobile_scanner` |
| `/profile/edit` | `EditProfileScreen` | `EditProfileBinding` | |

## 5. Finance & verification (module `finance`)

| Route | Screen class | Binding | Notes |
|---|---|---|---|
| `/finance` | `FinanceScreen` | `FinanceBinding` | STUDENT role data |
| `/finance/pay` | `PaymentScreen` | `PaymentBinding` | ACLEDA deep link |
| `/student-verification` | `StudentVerificationScreen` | `StudentVerificationBinding` | |
| `/verification-status` | `VerificationStatusScreen` | `VerificationStatusBinding` | |

## 6. Chat, AI, notifications & map

| Route | Screen class | Binding | Module |
|---|---|---|---|
| `/chat` | `ChatListScreen` | `ChatListBinding` | chat |
| `/chat/detail` | `ChatDetailScreen` | `ChatDetailBinding` | chat |
| `/chat/profile` | `ChatProfileScreen` | `ChatProfileBinding` | chat |
| `/chatbot` | `ChatbotScreen` | `ChatbotBinding` | chatbot |
| `/notifications` | `NotificationScreen` | `NotificationBinding` | home/notification |
| `/map` | `MapScreen` | `MapBinding` | map |

## 7. Settings (module `settings`)

| Route | Screen class | Binding |
|---|---|---|
| `/settings` | `SettingsHomeScreen` | `SettingsBinding` |
| `/settings/account` | `AccountSettingsScreen` | `AccountSettingsBinding` |
| `/settings/account/edit` | `EditAccountSettingsScreen` | `EditAccountSettingsBinding` |
| `/settings/privacy` | `PrivacySettingsScreen` | `PrivacySettingsBinding` |
| `/settings/privacy/practices` | `PrivacyPracticesScreen` | — |
| `/settings/notifications` | `NotificationPreferencesScreen` | `NotificationPreferencesBinding` |
| `/settings/security` | `SecuritySettingsScreen` | `SecuritySettingsBinding` |
| `/settings/security/change-password` | `ChangePasswordScreen` | `ChangePasswordBinding` |
| `/settings/help-center` | `HelpCenterScreen` | `HelpCenterBinding` |
| `/settings/about` | `AboutScreen` | `AboutBinding` |

## 8. Screen → backend service mapping

| Screens | Backend service(s) |
|---|---|
| Splash, Select Language, Onboarding, Startup | local only |
| Auth, forgot password, student verification, change password | `auth-service` |
| Home, create post, post detail, reels, profile, search | `content-service`, `file-service`, `user-profile-service` |
| Apply / CV preview / applicants | `career-service`, `file-service` |
| Finance, payment | `finance-service` (STUDENT role) |
| Chat | `chat-service` (REST + STOMP) |
| Chatbot, AI CV | `ai_core` via gateway `/api/v1/ai/**` |
| Notifications | `notification-service` |
| Map / nearby shops | `map-service` (`/api/v1/places/**`) |

[VERIFIED — gateway routes in `config-repo/api-gateway.yml`, `docs/_shared/SERVICE_REGISTRY.md` (paths corrected to `/api/v1/places/**`)]

## 9. Coverage gaps

- No standalone route for a dedicated "2FA", "biometric" or "data & storage" screen — those appear as coming-soon entries. [VERIFIED — `app_strings.dart`, `EVIDENCE-BASIS.md` §7]
- Flutter tests cover only 3 files; there are no screen/golden tests. [VERIFIED — `EVIDENCE-BASIS.md` §10]

[TBD] Authoritative per-screen acceptance criteria — TBD — Requires confirmation.
