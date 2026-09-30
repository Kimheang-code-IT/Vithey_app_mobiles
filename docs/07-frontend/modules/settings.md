# Module: Settings

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/modules/settings/`, `vithey_app/lib/data/repositories/settings_repository.dart`, `vithey_app/lib/data/services/settings_service.dart`

## Purpose

App and account configuration: account info, privacy, notification preferences, security (change password), help center, about, theme, and language. Backed by `user-profile-service` (`/users/me/settings`) and `auth-service` (password). Some rows are placeholders. [VERIFIED]

## Screens & routes

| Screen | Route | File |
| --- | --- | --- |
| Settings home | `/settings` | `lib/modules/settings/settings_home_screen.dart` |
| Account | `/settings/account` | `account/account_settings_screen.dart` |
| Edit account | `/settings/account/edit` | `account/edit_account_settings_screen.dart` |
| Privacy | `/settings/privacy` | `privacy/privacy_settings_screen.dart` |
| Privacy practices | `/settings/privacy/practices` | `privacy/privacy_practices_screen.dart` |
| Notifications | `/settings/notifications` | `notification_preferences/notification_preferences_screen.dart` |
| Security | `/settings/security` | `security/security_settings_screen.dart` |
| Change password | `/settings/security/change-password` | `change_password/change_password_screen.dart` |
| Help center | `/settings/help-center` | `help_center/help_center_screen.dart` |
| About | `/settings/about` | `about/about_screen.dart` |

[VERIFIED] `lib/routes/app_pages.dart`.

## Main widgets

`settings_scaffold.dart`, `settings_menu_tile.dart`, `settings_switch_tile.dart`, `settings_section_label.dart`, `settings_tile_divider.dart`, `settings_logout_button.dart`, `squircle_icon.dart`, `language_picker_sheet.dart`; account sheets `account/widgets/account_section_sheets.dart`; security `security_option_card.dart`; password `password_input_field.dart`, `password_requirement_card.dart`; about cards.

[VERIFIED]

## Controller / state

- `SettingsController` (`settings_controller.dart`): `isDarkMode`, `languageCode`, `isLoading`; `loadSettings`, `toggleDarkMode`, `openLanguagePicker`, `_selectLanguage`, `logout`.
- `AccountSettingsController`, `EditAccountSettingsController`.
- `PrivacySettingsController`.
- `NotificationPreferencesController`.
- `SecuritySettingsController` (`security/security_settings_controller.dart`): `twoFactorEnabled`, `biometricEnabled`; `twoFactorAvailable => false`, `biometricAvailable => false`.
- `ChangePasswordController`, `HelpCenterController`, `AboutController`.

[VERIFIED]

## Repository / API dependencies

| Dependency | File | Endpoints |
| --- | --- | --- |
| `SettingsRepository` | `lib/data/repositories/settings_repository.dart` | load/save settings, privacy, notification preferences; falls back to local |
| `SettingsService` | `lib/data/services/settings_service.dart` | `GET/PATCH /users/me/settings` |
| `AuthRepository` | `lib/data/repositories/auth_repository.dart` | `changePassword`, `logout` |
| `LocalStorageService` | `lib/core/storage/local_storage_service.dart` | theme, language, privacy, notification, biometric |
| `FcmService` / `NotificationRepository` | — | unregister/clear on logout |

[VERIFIED]

## User flow

1. Settings home lists sections: Preferences (Account, Privacy, Language), System (Notifications, Security, Dark Mode), Support (Help, About), General (Data & storage, Accessibility placeholders), then Logout.
2. Theme toggle applies immediately (`Get.changeThemeMode`) and persists.
3. Language selection stores the code and persists to the API when live; saving only changes the stored preference (UI stays English — see limitations).
4. Privacy switches persist locally + remotely.
5. Change password validates strength, then calls the API; `404` maps to "not available yet".
6. Logout confirms, unregisters FCM, clears session, and returns to `/login`.

[VERIFIED]

## Loading / error / empty states

- `isLoading` spinner on settings home.
- Save failures → snackbar (e.g. "Could not save language preference").
- Password field errors via `FormErrorHost`/`PasswordRequirementCard`.
- About/Help are static content.

[VERIFIED]

## Permissions

None.

## Known limitations / stubs

- **Localization is English-only**: language is a stored preference; no `.arb` and no runtime locale switch. Selecting Khmer persists `km` but the UI copy is unchanged. [VERIFIED]
- **2FA is not implemented** — the switch resets to off and shows "coming soon". [VERIFIED]
- **Biometric login is not implemented** — `biometricAvailable => false`. [VERIFIED]
- **Data & storage and Accessibility are placeholders** (snackbar "coming soon"). [VERIFIED]
- **Dark/light theming is implemented** (`AppTheme`, `app.dart`). [VERIFIED]
- Password change requires the backend endpoint; `404` is expected until shipped. [VERIFIED]

## TBDs

- [TBD] Khmer/English runtime localization. TBD — Requires confirmation.
- [TBD] 2FA and biometric login roadmaps. TBD — Requires confirmation.
- [TBD] Privacy toggles' backend enforcement semantics. TBD — Requires confirmation.
