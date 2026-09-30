import 'package:flutter/material.dart';

/// Typography size tokens — matches current Vithey call sites (DESIGN.md).
///
/// Sizes come from existing call sites, not Material defaults. Do not snap
/// nearby values; rare one-off sizes (9, 11.5, 17, 24, 28) stay as
/// `context.text.*.copyWith(fontSize: …)`.
abstract final class VitheyType {
  /// Nav badge, tiny labels.
  static const double micro = 10;

  /// Timestamps, micro meta.
  static const double caption = 11;

  /// Secondary meta.
  static const double meta = 12;

  /// List subtitles (very common).
  static const double subtitle = 13;

  /// Body copy.
  static const double body = 14;

  /// [VitheyListTile] titles.
  static const double titleSm = 15;

  /// Fields, composers, section titles.
  static const double title = 16;

  /// Emphasized section titles.
  static const double titleLg = 18;

  /// Screen / sheet titles.
  static const double headline = 20;

  /// Large screen titles.
  static const double display = 22;
}

/// Font weight tokens.
abstract final class VitheyWeight {
  /// Body.
  static const FontWeight regular = FontWeight.w400;

  /// Labels / soft emphasis.
  static const FontWeight medium = FontWeight.w500;

  /// Titles, list rows.
  static const FontWeight semibold = FontWeight.w600;

  /// Headlines; maps `FontWeight.bold`.
  static const FontWeight bold = FontWeight.w700;
}
