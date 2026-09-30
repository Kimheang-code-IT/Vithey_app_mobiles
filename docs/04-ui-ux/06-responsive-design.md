# Responsive Design

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/core/widgets/*`, `vithey_app/lib/modules/**/widgets/*`, `vithey_app/lib/modules/auth/**`, `vithey_app/README.md`, `vithey_app/pubspec.yaml`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [UI/UX overview](01-ui-ux-overview.md) · [Design system](04-design-system.md)

## 1. Target form factor

Vithey is an **Android-only mobile app**. Web/Chrome is explicitly unsupported (Isar, secure storage and camera), so the responsive contract targets phones — with a tablet-tolerant, width-capped layout. [VERIFIED — `vithey_app/README.md`, `EVIDENCE-BASIS.md` §7]

## 2. Strategy (as implemented)

There is **no formal breakpoint grid** (no `LayoutBuilder`-driven adaptive scaffold, no `MediaQuery` breakpoint table). Responsiveness relies on four concrete techniques: [VERIFIED]

| Technique | Mechanism | Evidence |
|---|---|---|
| Width caps | `ConstrainedBox(maxWidth: 420)` on auth/dialog/form content, `512` for editing sheets | `vithey_dialog.dart:14`, `login_screen.dart`, `edit_account_settings_controller.dart:68` |
| Proportional sizing | widths/heights as a fraction of `MediaQuery.sizeOf(context)` | `chat/widgets/message_bubble.dart:44`, `profile/widgets/profile_qr_bottom_sheet.dart:49`, `splash_screen.dart:84` |
| Intrinsic layout | `LayoutBuilder` for chip flow, media header, analytics grid | `packed_skill_chip_flow.dart:80`, `home_media_header.dart:104`, `post_analytics_screen.dart:376` |
| Safe areas | `SafeArea` + `scrollClearance()` so content clears the floating bottom nav | `app_bottom_navigation.dart:38-42` |

## 3. Layout rules

- **Max content width:** interactive auth and dialog content is centred and capped (commonly 420 logical px), so it stays comfortable on tablets. [VERIFIED]
- **Chat bubbles:** width capped at `0.78 × screen width`. [VERIFIED — `chat/widgets/message_bubble.dart`]
- **Bottom navigation:** floating pill, 64 high, 10 bottom margin, inset for device safe area; expose `AppBottomNavigation.scrollClearance(context)` so lists don't slide under it. [VERIFIED — `app_bottom_navigation.dart`]
- **Dynamic type:** text uses the platform text scaler; the type tokens are base sizes, and `context.text.*.copyWith(fontSize: …)` is used for rare one-off sizes. [VERIFIED — `vithey_type.dart` doc comment]
- **Scroll behavior:** a custom `VitheyScrollBehavior` is applied for consistent overscroll. [VERIFIED — `lib/core/theme/vithey_scroll_behavior.dart`]

## 4. Orientation

The app is portrait-first. There is no evidence of orientation locking or landscape-specific layouts; proportional layouts tolerate rotation but no dedicated landscape screen exists. [INFERRED] Inferred from implementation — requires business confirmation.

## 5. Density and spacing

- Standard horizontal padding 16–20; section gaps 12–16; grid gaps 12. The startup interests grid uses `crossAxisCount: 2`, `childAspectRatio: 1.9`. [VERIFIED — `startup_step_pages.dart`]
- Tap targets: icon actions use a minimum 48 (`VitheyRadii.iconButton`) and visuals are 42–48. [VERIFIED — `app_bottom_navigation.dart`, `vithey_radii.dart`]

## 6. Device configuration

| Setting | Value | Evidence |
|---|---|---|
| Platform | Android (emulator or physical) | `vithey_app/README.md` |
| Emulator reference device | `Medium_Phone_API_36.1` | `README.md` |
| Minimum Dart SDK | `>=3.3.0 <4.0.0` | `pubspec.yaml` |
| Emulator host alias | `10.0.2.2` for backend access | `app_config.dart` |

## 7. Known limitations

- No golden/screenshot tests and no multi-device visual regression. [VERIFIED — `EVIDENCE-BASIS.md` §10]
- No explicit large-screen/tablet navigation rail; the pill nav is used at all widths. [VERIFIED — `app_bottom_navigation.dart`]
- [TBD] Official minimum screen size and tablet support decision — TBD — Requires confirmation.
- [TBD] Dynamic text-scale accessibility limit (e.g. max scale factor) — TBD — Requires confirmation.
