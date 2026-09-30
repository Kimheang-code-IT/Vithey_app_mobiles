/// GenZ shape-language tokens for Vithey.
///
/// Single source of truth for corner radii, matching DESIGN_SYSTEM.md
/// ("Radii (target)"). Feature modules must read these instead of
/// hardcoding 8/12 — soft geometry everywhere.
abstract final class VitheyRadii {
  /// Icon chrome container (squircle) — app bar actions, list-row leads.
  static const double iconSquircle = 18;

  /// Minimum tap target for an icon button (see [VitheyIconButton]).
  static const double iconButton = 48;

  /// Cards / list rows / info panels.
  static const double card = 18;

  /// Bottom sheets and dialogs.
  static const double sheet = 24;

  /// Search pills, chips, pill-shaped CTAs.
  static const double pill = 24;

  /// Text fields / inputs (slightly roomier GenZ fields).
  static const double field = 16;

  /// Media thumbnails and image containers.
  static const double media = 14;
}
