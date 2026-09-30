# Login & Registration Guide

> Status: Verified (core + Google sign-in) · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/modules/auth/**`, `vithey_app/lib/routes/app_pages.dart`, `api_docs.md` §3
> Evidence anchor: `../_meta/EVIDENCE-BASIS.md`

## 1. Entry flow

On first launch you pass through a single continuum: **Language → Onboarding (×3) → Sign In /
Sign Up**. Navigation inside this continuum is button-driven only (swipe is disabled)
[VERIFIED: `lib/modules/auth/intro_ribbon_controller.dart`].

| Step | Route | What you do |
| --- | --- | --- |
| Select language | `/select-language` | Choose English or Khmer, then Continue |
| Onboarding 1–3 | `/onboarding` | Read the three value slides; Skip or Next |
| Sign In | `/login` (`/auth`) | Sign in with email/phone + password |
| Sign Up | `/register` | Create an account in two steps |
| Forgot password | `/auth/forgot-password` | Request a reset link by email |
| Google sign-in | Sign In / Sign Up | Tap **Continue with Google** — see §6 |
| StartUp funnel | `/startup/skills` → `/startup/interests` → `/startup/discovery` | Optional profile seeding after first sign-up |

The language choice is saved locally; onboarding completion is stored so returning users skip
straight to Sign In [VERIFIED: `intro_ribbon_controller.dart`, `LocalStorageService`].

## 2. Sign in

- Fields: **Email or phone** and **Password**.
- Endpoint: `POST /auth/login` with `{ "email_or_phone", "password" }` → `200`
  [VERIFIED: `api_docs.md` §3].
- On success the app stores the access token (15-min TTL) and refresh token (7-day TTL) in secure
  storage and routes you onward. A `401` during a session triggers one silent
  `POST /auth/refresh`; if that fails you are logged out [VERIFIED: `lib/core/network/dio_client.dart`, `api_docs.md` §1].

## 3. Register

Registration is a **two-step** form [VERIFIED: `lib/modules/auth/auth_controller.dart`]:

1. **Part 1 — credentials:** email, password, confirm password, phone.
2. **Part 2 — profile:** full name, phone, and date of birth (date picker limits to ages 13–~75).

Endpoint: `POST /auth/register` with `role` of `USER` or `COMPANY` only; `STUDENT` is granted later
via verification [VERIFIED: `api_docs.md` §3, §18].

After a new registration, `AuthNavigation.goAfterAuth(isNewUser: true)` sends you into the
**StartUp** funnel (pick skills, interests, discovery source), which can be skipped
[VERIFIED: `lib/modules/auth/startup/startup_controller.dart`].

## 4. Forgot password

- Open **Forgot password?** on the Sign In screen (it morphs in place, staying on the continuum).
- Enter your email → `POST /auth/forgot-password` returns a **generic** success message regardless
  of whether the account exists (anti-enumeration) [VERIFIED: `api_docs.md` §3].
- Completing a reset with the emailed token uses `POST /auth/reset-password`
  (`{ "token", "new_password" }`).

> The current mail mode defaults to `VITHEY_MAIL_MODE=log`, so reset/verify tokens appear in the
> auth-service **logs** rather than a real inbox in the demo [VERIFIED: `auth-service/.env.example`].

## 5. Email verification

`POST /auth/verify-email` with `{ "token" }` verifies an email. `is_email_verified` is returned in
the user object [VERIFIED: `api_docs.md` §3].

## 6. Google sign-in

- On the Sign In or Sign Up form, tap **Continue with Google**. The real Google account chooser
  opens (Android Credential Manager). Pick an account to continue.
- The app sends the Google ID token to `POST /auth/google`. The backend verifies it with Google,
  finds or creates the Vithey account, links the Google identity, and returns the normal Vithey
  access + refresh tokens [VERIFIED: `docs/10-security/12-google-sign-in.md`].
- New Google users get the default `USER` role (never `STUDENT`/`COMPANY`/`ADMIN`). If an account
  already exists for the same verified Google email, it is linked — no duplicate is created.
- If you cancel the chooser, you return to the login screen with no error.
- Setup (client IDs) is required before this works — see
  [`../10-security/12-google-sign-in.md`](../10-security/12-google-sign-in.md) §7.

## 7. Session, logout, and security settings

- Change password: **Settings → Security → Change Password** → `PATCH /auth/me/password`
  (`{ "current_password", "new_password" }`) [VERIFIED: `lib/modules/settings/change_password/`, `api_docs.md` §3].
- Logout (Settings): unregisters the device token (if any), clears session preferences and recent
  searches, then routes to `/login` [VERIFIED: `lib/modules/settings/settings_controller.dart`].
- Two-Factor Authentication and Biometric Login appear under Security but are **"Coming soon"**
  [VERIFIED: `lib/modules/settings/security/security_settings_screen.dart`].

## 8. Tips & troubleshooting

| Symptom | Likely cause | Action |
| --- | --- | --- |
| "Something went wrong" on login | Gateway/demo stack not running | Start `backend/scripts/docker-up-demo.ps1`; verify `:8080/actuator/health` |
| Login fails on a device | Wrong `API_BASE_URL` | Use `10.0.2.2` (emulator) or PC LAN IP (device) |
| Values reset | Mocks enabled | Ensure `USE_MOCK_AUTH=false` in `.env` |
| No reset email | Demo mail mode | Read the token from auth-service logs |

## 9. Related

- [03-profile-guide.md](03-profile-guide.md) · [10-FAQ.md](10-FAQ.md) · [01-user-manual.md](01-user-manual.md)
- [../06-api/03-authentication-api.md](../06-api/03-authentication-api.md)
- Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md)
