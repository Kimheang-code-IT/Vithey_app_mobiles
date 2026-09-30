# Module: Auth

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/modules/auth/`, `vithey_app/lib/data/repositories/auth_repository.dart`, `vithey_app/lib/data/services/auth_service.dart`

## Purpose

Owns the first-run funnel and authentication: splash intro, language selection, onboarding, the sign-in/sign-up intro ribbon, forgot password, Google sign-in, and the three-step startup profile (skills → interests → discovery). Backed by `auth-service`. [VERIFIED]

## Screens & routes

| Screen | Route | File |
| --- | --- | --- |
| Splash | `/splash` | `lib/modules/auth/splash/splash_screen.dart` |
| Select Language | `/select-language` | `lib/modules/auth/intro_ribbon_screen.dart` (page 0) |
| Onboarding | `/onboarding` | `intro_ribbon_screen.dart` |
| Sign In / Sign Up continuum | `/login`, `/register`, `/auth` | `intro_ribbon_screen.dart` |
| Forgot Password | `/auth/forgot-password` | `lib/modules/auth/forgot_password_screen.dart` |
| Startup (skills/interests/discovery) | `/startup/skills`, `/startup/interests`, `/startup/discovery` | `lib/modules/auth/startup/startup_screen.dart` |

Google sign-in uses the OS-provided chooser (`google_sign_in`) launched from the Sign In / Sign Up
forms; there are no in-app Google routes/screens. See
[`../07-authentication-flow.md`](../07-authentication-flow.md) §7.

[VERIFIED] `lib/routes/app_pages.dart`, `lib/core/constants/app_routes.dart`.

## Main widgets

- `IntroRibbonScreen` + `IntroRibbonController` — a single continuum that morphs between language, onboarding, sign-in and sign-up; `AuthController` coordinates the auth forms (`lib/modules/auth/intro_ribbon_screen.dart`, `intro_ribbon_controller.dart`).
- `SplashScreen` — intro beats (white → teal drop → brand → handoff) using `SplashController` animation fields and `widgets/splash_background.dart`.
- Onboarding widgets: `onboarding_top_section.dart`, `onboarding_bottom_section.dart`, `onboarding_background.dart`, `wave_ribbon.dart`.
- Startup widgets: `startup_step_indicator.dart`, `selectable_skill_chip.dart`, `selectable_interest_card.dart`, `discovery_source_row.dart`, `startup_bottom_navigation.dart`.
- Auth form widgets: `widgets/oauth_button.dart`, `widgets/register_step_slider.dart`, `widgets/vithey_genz.dart`.
- `LanguagePickerSheet` is shared from settings (`lib/modules/settings/widgets/language_picker_sheet.dart`).

[VERIFIED]

## Controller / state

- `AuthController` (`lib/modules/auth/auth_controller.dart`): form keys and text controllers; `isLoading`, `isGoogleLoading`, `isForgotPasswordLoading`, `errorMessage`, `authIntent`, `authPageIndex`, `registerStep`, `showForgotPassword`. Commands: `login`, `register`, `goToRegisterPart2`, `requestPasswordReset`, `continueWithGoogle`, `beginGoogleEmailChange`.
- `SplashController` (`lib/modules/auth/splash/splash_controller.dart`): animation fills (`washFill`, `tealFill`, `brandOpacity`, `handoffProgress`, `languageContentReveal`) and `_resolveNextRouteLocal()` gating.
- `IntroRibbonController` — ribbon page index and morph state.
- `StartupController` (`lib/modules/auth/startup/startup_controller.dart`): `currentStep` 0–2, `StartupProfileDraft` (skillIds, interestIds, discoverySource), max 5 interests.
- `SelectLanguageController` (`lib/modules/auth/language/select_language_controller.dart`).

[VERIFIED]

## Repository / API dependencies

| Dependency | File | Endpoints |
| --- | --- | --- |
| `AuthRepository` | `lib/data/repositories/auth_repository.dart` | login, register, signInWithGoogle, googleEmailForAccountChange, validateSession, logout, changePassword, requestPasswordReset |
| `AuthService` | `lib/data/services/auth_service.dart` | `POST /auth/login`, `POST /auth/register`, `POST /auth/google`, `GET /auth/me`, `POST /auth/logout`, `POST /auth/refresh`, `PATCH /auth/me/password`, `POST /auth/forgot-password` |
| `GoogleAuthService` | `lib/data/services/google_auth_service.dart` | `google_sign_in` wrapper: initialize + authenticate → Google ID token |
| `SecureStorageService` | `lib/core/storage/secure_storage_service.dart` | token persistence |
| `LocalStorageService` | `lib/core/storage/local_storage_service.dart` | language/onboarding/startup flags |
| `CurrentUserService` | `lib/core/session/current_user_service.dart` | session restore |
| `AuthNavigation` | `lib/core/utils/auth_navigation.dart` | post-auth routing |

[VERIFIED]

## User flow

1. Splash resolves the next route from local flags/token (see [`../07-authentication-flow.md`](../07-authentication-flow.md)).
2. First run → Select Language → Onboarding → Sign In / Sign Up.
3. Sign Up is two steps (credentials → profile); date of birth is collected but not submitted.
4. On success: new user → Startup skills/interests/discovery; returning user → Home shell.
5. Forgot password sends a reset link and shows a neutral confirmation.
6. Google sign-in runs the real OS chooser, exchanges the ID token at `POST /auth/google`, stores the
   Vithey tokens, then routes like a normal login. Cancellation returns to the form cleanly.

[VERIFIED]

## Loading / error / empty states

- `isLoading`/`isGoogleLoading`/`isForgotPasswordLoading` drive button spinners.
- Auth errors surface as `errorMessage` text; forgot-password uses `forgotPasswordError`/`forgotPasswordSuccess`.
- Splash animation has no error state; storage reads time out at 500 ms and fall back safely.
- Startup steps have no empty state (selectable lists).

[VERIFIED]

## Permissions

None required for email/password. Google sign-in uses the `google_sign_in` plugin (Google Play
Services / Credential Manager on Android) — no extra app permission is declared.

## Known limitations / stubs

- **No route middleware guards**; gating is manual in `SplashController`/`AuthNavigation`. [VERIFIED]
- `validateSession()` is unused by the funnel. [VERIFIED]
- Date of birth not sent to the backend. [VERIFIED]
- English-only strings (no `.arb`). [VERIFIED]

## TBDs

- [TBD] End-to-end Google Sign-In on a real device (registered SHA-1 + live Web client ID) is a
  manual verification step. See [`../10-security/12-google-sign-in.md`](../10-security/12-google-sign-in.md) §9.
- [TBD] Email verification / reset-password completion screens (endpoints public but no client screen). TBD — Requires confirmation.
