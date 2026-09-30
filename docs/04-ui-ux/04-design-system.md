# Design System

> Status: Verified · Last reviewed: 2026-09-30
> Evidence: `vithey_app/lib/core/constants/app_colors.dart`, `vithey_app/lib/core/theme/{vithey_type,vithey_radii,app_semantic_colors,light_theme,dark_theme,app_theme}.dart`, `vithey_app/lib/core/widgets/*`, `docs/Prompt Frontend/run-genz-complete/DESIGN_SYSTEM.md`

Part of the Vithey documentation set · Master index: [`../00-project-overview/07-document-index.md`](../00-project-overview/07-document-index.md) · [UI/UX overview](01-ui-ux-overview.md) · [Screen inventory](03-screen-inventory.md) · [Responsive](06-responsive-design.md)

Design tokens are code, not external. The single sources of truth are `AppColors`, `VitheyType`, `VitheyWeight`, `VitheyRadii` and `AppSemanticColors`; screens must read these instead of hardcoding values. [VERIFIED]

## 1. Brand colors (`AppColors`)

| Token | Hex | Role |
|---|---|---|
| `primary` | `#03B4AC` | brand teal |
| `primaryLight` | `#33C7BF` | wash / hover |
| `primaryDark` | `#027F79` | pressed |
| `secondary` | `#03B03C` | brand green |
| `secondaryLight` | `#25CA2E` | |
| `secondaryDark` | `#028B4A` | |
| `accent` | `#C8CED4` | grey |
| `success` | `#2E7D32` | |
| `warning` | `#F9A825` | |
| `error` | `#E42407` | |
| `info` | `#0288D1` | |
| `paid` | `#2E7D32` | finance status |
| `unpaid` | `#E42407` | finance status |
| `pending` | `#FE863F` | finance status |
| `overdue` | `#E42407` | finance status |

Forbidden per the design contract: purple gradients, cream newspaper looks, random teal hexes (e.g. `0xFF00BFA5`), and `Colors.teal`. [VERIFIED — `DESIGN_SYSTEM.md`]

## 2. Semantic colors (light / dark)

`AppSemanticColors` is a `ThemeExtension` exposing `bodyBackground`, `cardSurface`, `heading`, `muted`, `inputFill`, `border`, `subtleShadow`, `dangerSurface`. Access at call sites via `context.appColors`. [VERIFIED — `app_semantic_colors.dart`]

| Token | Light | Dark |
|---|---|---|
| bodyBackground / cardSurface | `#FFFFFF` (`accentLight`) | `#12121A` / `#1E1E2C` |
| heading | `#303236` (`titleLight`) | `#F5F5F5` (`titleDark`) |
| muted | `#78909C` (`bodyLight`) | `#9E9EB0` (`bodyDark`) |
| inputFill | `#F5F5F5` | `#2A2A3A` |
| border | `#E0E0E0` | `#3A3A4E` |
| dangerSurface | `#FFEBEE` | `#3D2024` |

## 3. Typography (`VitheyType` + `VitheyWeight`)

| Token | Size (logical px) | Usage |
|---|---|---|
| `micro` | 10 | nav badge, tiny labels |
| `caption` | 11 | timestamps |
| `meta` | 12 | secondary meta |
| `subtitle` | 13 | list subtitles |
| `body` | 14 | body copy |
| `titleSm` | 15 | list-tile titles |
| `title` | 16 | fields, composers, section titles |
| `titleLg` | 18 | emphasized section titles |
| `headline` | 20 | screen/sheet titles |
| `display` | 22 | large screen titles |

Weights: `regular` 400, `medium` 500, `semibold` 600, `bold` 700. The `TextTheme` mapping is built once in `vitheyTextTheme()` and consumed as `context.text.*`. No new font families are introduced — the app uses the default platform font. [VERIFIED]

## 4. Shape / radii (`VitheyRadii`)

| Token | Value | Applied to |
|---|---|---|
| `iconSquircle` | 18 | app-bar actions, list-row leads |
| `iconButton` | 48 | minimum icon-button tap target |
| `card` | 18 | cards, list rows, info panels |
| `sheet` | 24 | bottom sheets, dialogs |
| `pill` | 24 | search pills, chips, pill CTAs |
| `field` | 16 | text fields |
| `media` | 14 | image thumbnails |

The floating bottom nav uses a private 32 radius and 64 height. [VERIFIED — `app_bottom_navigation.dart`]

## 5. Spacing and motion

- Horizontal content padding is typically 16–20; section gaps 12–16; auth/dialog content is width-capped (commonly `maxWidth: 420`). [VERIFIED — repeated across modules; `DESIGN_SYSTEM.md`]
- Motion is intentionally light: an 180–280 ms `easeOutCubic` for tab/scroll nav transitions; the splash intro uses a choreographed multi-controller sequence. [VERIFIED — `main_shell_screen.dart`, `splash_controller.dart`]

## 6. Component kit (`lib/core/widgets/`)

| Widget | Purpose |
|---|---|
| `custom_button.dart` | primary/outline/ghost/destructive CTA |
| `custom_text_field.dart`, `vithey_field.dart` | text input |
| `vithey_text_area.dart` | multiline input |
| `vithey_search_pill.dart` | search entry |
| `vithey_filter_chips.dart` | filter chips |
| `vithey_card.dart` | surface card |
| `vithey_switch.dart` | toggle |
| `vithey_icon_button.dart` | squircle/circular icon action |
| `vithey_dialog.dart`, `confirm_dialog.dart`, `vithey_action_sheet.dart` | dialogs / sheets |
| `report_reason_dialog.dart` | moderation report |
| `user_avatar.dart` | avatar (circular) |
| `status_badge.dart` | status chip |
| `loading_widget.dart`, `shimmer_list_tile.dart` | loading states |
| `empty_state_widget.dart` | empty state |
| `app_error_widget.dart` | error state |
| `offline_banner.dart` | offline state |
| `form_error_host.dart` | form error display |
| `app_app_bar.dart`, `app_screen_body.dart`, `app_logo.dart`, `vithey_text_link.dart` | chrome / layout |

Raw `ElevatedButton`/`TextButton`/`FilterChip`/`Card` are discouraged in feature work; modules should compose the kit. [VERIFIED — `DESIGN_SYSTEM.md` checklist; widgets directory]

## 7. Iconography

Icons come from the shadcn-flutter / Lucide set (`LucideIcons.house`, `clapperboard`, `sparkles`, `messageCircle`, `bell`, etc.) wrapped by `VitheyIcon` / `VitheyIconButton`. [VERIFIED — `app_bottom_navigation.dart`, `lib/core/icons/vithey_icons.dart`]

## 8. State matrix (per screen)

| State | Component | Notes |
|---|---|---|
| Loading | `LoadingWidget` / `ShimmerListTile` | skeletons for lists |
| Empty | `EmptyStateWidget` | title + subtitle + optional CTA |
| Error | `AppErrorWidget` | with retry |
| Disabled | `CustomButton` disabled variant | |
| Success | inline / `apply_success` feedback | |
| Offline | `OfflineBanner` | driven by connectivity |

## 9. Governance

- No formal design-tool source or versioned design tokens file is committed; the Dart token files are authoritative. See [Figma Reference](07-figma-reference.md).
- Accessibility audit: **Not yet formally assessed**.
- [TBD] Typography licensing for any custom font — TBD — Requires confirmation (none is currently bundled).
