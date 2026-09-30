import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_qr_bottom_sheet.dart';
import 'package:get/get.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Profile Home header redesign (`update.md` + `Profile_Background_Redesign.png`).
///
/// Backup of the previous header remains in [ProfileWavyHeader].
/// Layers: flat soft teal → fixed decor → layered white analog waves → avatar.
class ProfileCoverRedesign extends StatelessWidget {
  const ProfileCoverRedesign({
    super.key,
    required this.profile,
    this.showMenu = true,
    this.showBack = false,
    this.showQrScan,
    this.onMenuTap,
    this.onBack,
    this.onQrScanTap,
    this.onEditProfile,
    this.onVerifyStudent,
    this.isStudentVerified = false,
  });

  final UserProfileModel profile;
  final bool showMenu;
  final bool showBack;

  /// Top-right QR scan; defaults to [showMenu] (own profile).
  final bool? showQrScan;
  final VoidCallback? onMenuTap;
  final VoidCallback? onBack;
  final VoidCallback? onQrScanTap;

  /// Own-profile header actions (icons instead of Edit/Verify buttons).
  final VoidCallback? onEditProfile;
  final VoidCallback? onVerifyStudent;
  final bool isStudentVerified;

  /// Larger than v1 (r56) — focal point.
  static const avatarRadius = 66.0;
  static const headerHeight = 390.0;
  static const _avatarBorder = 4.0;
  static const _waveHeightFactor = 0.52;
  /// Must match front layer in [_AnalogWavePainter].
  static const _frontMidYFactor = 0.14;
  static const _frontCenterHigh = 14.0;

  static Color tealColor(BuildContext context) {
    // Soft cover teal.
    return const Color(0xFF99E3DF);
  }

  static Color decorColor(BuildContext context) {
    // Decor line-art at 40% — softer on the teal cover.
    return const Color(0xFF016560).withValues(alpha: 0.40);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final teal = tealColor(context);
    final decor = decorColor(context);
    final sheet = context.appColors.bodyBackground;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final onCover =
        teal.computeLuminance() > 0.45
            ? AppColors.lightText
            : Colors.white;
    final qrVisible = showQrScan ?? showMenu;

    // Keep wave geometry fixed — only reposition the avatar on the boundary.
    final waveH = headerHeight * _waveHeightFactor;
    final waveBoxTop = headerHeight - waveH;
    // Center-high of the front white wave (= teal / white split under avatar).
    final boundaryY =
        waveBoxTop + waveH * _frontMidYFactor - _frontCenterHigh;

    final avatarExtent = avatarRadius * 2 + _avatarBorder * 2;
    // Half on teal, half on white: avatar center sits on the wave edge.
    // Nudge avatar up 20 from the wave boundary.
    final avatarTop = boundaryY - avatarExtent / 2 - 20;
    // End the cover at the avatar bottom — do not keep empty headerHeight
    // whitespace under the avatar (that pushed name/bio too far down).
    const avatarBottomGap = 18.0;
    final stackHeight = avatarTop + avatarExtent + avatarBottomGap;

    return SizedBox(
      height: stackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1) Flat soft teal — stop at avatar stack (not full headerHeight)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: stackHeight,
            child: ColoredBox(color: teal),
          ),

          // 2) Fixed decor — frames avatar, center kept clean
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: stackHeight,
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ProfileDecorPainter(
                  color: decor,
                  topPad: topPad,
                ),
              ),
            ),
          ),

          // 3) Layered white analog waves (keep waveH so curve geometry
          // matches avatar boundaryY; white overflow below is harmless)
          Positioned(
            top: waveBoxTop,
            left: 0,
            right: 0,
            height: waveH,
            child: CustomPaint(
              painter: _AnalogWavePainter(
                front: sheet,
                mid: sheet.withValues(alpha: isDark ? 0.45 : 0.70),
                rear: sheet.withValues(alpha: isDark ? 0.28 : 0.50),
              ),
            ),
          ),

          // 4) Header icons — own: settings + edit/verify/QR; visitor: back
          if (showMenu)
            Positioned(
              top: topPad + 12,
              left: 4,
              child: _CoverIconButton(
                icon: LucideIcons.settings,
                color: onCover,
                tooltip: 'Settings',
                onPressed: onMenuTap ?? () => Get.toNamed(AppRoutes.settings),
              ),
            ),
          if (showBack)
            Positioned(
              top: topPad + 12,
              left: 4,
              child: _CoverIconButton(
                icon: LucideIcons.arrowLeft,
                color: onCover,
                tooltip: 'Back',
                onPressed: onBack ?? () => Get.back(),
              ),
            ),
          Positioned(
            top: topPad + 12,
            right: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEditProfile != null)
                  _CoverIconButton(
                    icon: LucideIcons.userPen,
                    color: onCover,
                    tooltip: 'Edit profile',
                    onPressed: onEditProfile!,
                  ),
                if (onVerifyStudent != null)
                  _CoverIconButton(
                    icon: isStudentVerified
                        ? LucideIcons.badgeCheck
                        : LucideIcons.shieldCheck,
                    color: onCover,
                    tooltip: isStudentVerified ? 'Review verification' : 'Verify',
                    onPressed: onVerifyStudent!,
                  ),
                if (qrVisible)
                  _CoverIconButton(
                    icon: LucideIcons.scanLine,
                    color: onCover,
                    tooltip: 'Scan QR code',
                    onPressed: onQrScanTap ??
                        () => showProfileQrBottomSheet(
                              context: context,
                              userId: profile.id,
                              userName: profile.fullName,
                            ),
                  ),
              ],
            ),
          ),

          // 5) Avatar — half on teal, half on white (center on wave edge)
          Positioned(
            top: avatarTop,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primary, width: _avatarBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: UserAvatar(
                  name: profile.fullName,
                  imageUrl: profile.avatarUrl,
                  radius: avatarRadius,
                  backgroundColor: sheet,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverIconButton extends StatelessWidget {
  const _CoverIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: color,
        shadowColor: Colors.transparent,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.all(8),
      ),
      icon: VitheyIcon(icon, color: color, size: 22),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}

/// Multi-layer white analog wave.
///
/// Shape (L→R): **left low → middle high → right low**.
/// Each layer uses a different midY / amplitude so paths never match.
class _AnalogWavePainter extends CustomPainter {
  const _AnalogWavePainter({
    required this.front,
    required this.mid,
    required this.rear,
  });

  final Color front;
  final Color mid;
  final Color rear;

  @override
  void paint(Canvas canvas, Size size) {
    // Rear (50%): lowest, widest swing
    canvas.drawPath(
      _wavePath(
        size,
        midY: size.height * 0.30,
        sideLow: 28,
        centerHigh: 22,
      ),
      Paint()..color = rear,
    );
    // Mid (~70%): offset curve
    canvas.drawPath(
      _wavePath(
        size,
        midY: size.height * 0.22,
        sideLow: 24,
        centerHigh: 18,
      ),
      Paint()..color = mid,
    );
    // Front (solid): highest elevation, gentler swing
    canvas.drawPath(
      _wavePath(
        size,
        midY: size.height * 0.14,
        sideLow: 20,
        centerHigh: 14,
      ),
      Paint()..color = front,
    );
  }

  /// White fill below an analog-signal top edge.
  /// `sideLow` = how deep left/right dip; `centerHigh` = how high the middle rises.
  Path _wavePath(
    Size size, {
    required double midY,
    required double sideLow,
    required double centerHigh,
  }) {
    final w = size.width;
    final h = size.height;

    // Larger y = lower on screen (white edge dips down).
    // Smaller y = higher on screen (white edge rises under avatar).
    double edge(double delta) => midY + delta;

    final path = Path()..moveTo(0, edge(sideLow * 0.55));

    // Left low (trough)
    path.cubicTo(
      w * 0.08, edge(sideLow),
      w * 0.14, edge(sideLow),
      w * 0.22, edge(sideLow * 0.65),
    );
    // Rise to nearly-flat center high (avatar shelf)
    path.cubicTo(
      w * 0.32, edge(-centerHigh * 0.35),
      w * 0.40, edge(-centerHigh),
      w * 0.50, edge(-centerHigh),
    );
    path.cubicTo(
      w * 0.60, edge(-centerHigh),
      w * 0.68, edge(-centerHigh * 0.35),
      w * 0.78, edge(sideLow * 0.65),
    );
    // Right low (trough) → edge
    path.cubicTo(
      w * 0.86, edge(sideLow),
      w * 0.92, edge(sideLow),
      w, edge(sideLow * 0.50),
    );

    path
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _AnalogWavePainter oldDelegate) {
    return front != oldDelegate.front ||
        mid != oldDelegate.mid ||
        rear != oldDelegate.rear;
  }
}

/// Fixed intentional decor — frames avatar, generous whitespace in center.
///
/// Sizes: small 28–30 · medium 40–44 · large 58.
class _ProfileDecorPainter extends CustomPainter {
  const _ProfileDecorPainter({
    required this.color,
    required this.topPad,
  });

  final Color color;
  final double topPad;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Composition from redesign mock / update.md layout example.
    // Center column left empty for avatar.
    //
    //   ⚙(btn)           </>
    //      ✨                  🎲
    //   ≡≡
    //         💬                  □
    //                              ✨
    //   ≡≡

    // 5 — code: top area
    _drawCode(canvas, Offset(w * 0.48 - 20, topPad + 38), 58, fill);

    // 4 — sparkle: slightly lower
    _drawSparkle(canvas, Offset(w * 0.16, h * 0.32), 40, stroke);
    // 3 — chat: slightly lower
    _drawChat(canvas, Offset(w * 0.24, h * 0.54), 40, stroke);
    // 7 — dice: near avatar, down 10 (bigger)
    _drawDice(canvas, Offset(w * 0.68, h * 0.40 - 10), 56, stroke);
    // 8 — cube: down 20 (smaller)
    _drawCube(canvas, Offset(w * 0.84, h - 20 - 48), 28, stroke);

    // 6 — sparkle: right 10 (bigger)
    _drawSparkle(canvas, Offset(w - 20 - 20 + 10, h * 0.58 - 30), 40, stroke);
    // 2 — hatch: slightly lower
    _drawHatch(canvas, Offset(w * 0.05, h * 0.72), 28, stroke);
    // 9 — hatch: top-right (≡ lines), move left 20
    _drawHatch(canvas, Offset(w * 0.82 - 10, h * 0.26 - 15), 28, stroke);
  }

  void _drawCode(Canvas canvas, Offset c, double size, Paint paint) {
    final tp = TextPainter(
      text: TextSpan(
        text: '</>',
        style: TextStyle(
          color: paint.color,
          fontSize: size * 0.82,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
  }

  void _drawSparkle(Canvas canvas, Offset c, double size, Paint paint) {
    final r = size / 2;
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawChat(Canvas canvas, Offset c, double size, Paint paint) {
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: size, height: size * 0.85),
      Radius.circular(size * 0.22),
    );
    canvas.drawRRect(r, paint);
    final eye = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(c.dx - size * 0.18, c.dy - size * 0.04), 1.3, eye);
    canvas.drawCircle(Offset(c.dx + size * 0.18, c.dy - size * 0.04), 1.3, eye);
  }

  void _drawDice(Canvas canvas, Offset c, double size, Paint paint) {
    final s = size * 0.52;
    canvas.save();
    canvas.translate(c.dx - s * 0.28, c.dy + s * 0.12);
    canvas.rotate(-0.16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: s, height: s),
        Radius.circular(s * 0.18),
      ),
      paint,
    );
    canvas.restore();
    canvas.save();
    canvas.translate(c.dx + s * 0.30, c.dy - s * 0.14);
    canvas.rotate(0.20);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: s, height: s),
        Radius.circular(s * 0.18),
      ),
      paint,
    );
    canvas.restore();
  }

  void _drawCube(Canvas canvas, Offset c, double size, Paint paint) {
    final s = size * 0.42;
    final path = Path()
      ..moveTo(c.dx, c.dy - s)
      ..lineTo(c.dx + s, c.dy - s * 0.35)
      ..lineTo(c.dx + s, c.dy + s * 0.45)
      ..lineTo(c.dx, c.dy + s)
      ..lineTo(c.dx - s, c.dy + s * 0.45)
      ..lineTo(c.dx - s, c.dy - s * 0.35)
      ..close()
      ..moveTo(c.dx - s, c.dy - s * 0.35)
      ..lineTo(c.dx, c.dy)
      ..lineTo(c.dx + s, c.dy - s * 0.35)
      ..moveTo(c.dx, c.dy)
      ..lineTo(c.dx, c.dy + s);
    canvas.drawPath(path, paint);
  }

  void _drawHatch(Canvas canvas, Offset c, double size, Paint paint) {
    final gap = size * 0.24;
    for (var i = 0; i < 4; i++) {
      final dy = c.dy - size * 0.35 + i * gap;
      final lineW = size * (1.05 - i * 0.1);
      canvas.drawLine(
        Offset(c.dx, dy),
        Offset(c.dx + lineW, dy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProfileDecorPainter oldDelegate) {
    return color != oldDelegate.color || topPad != oldDelegate.topPad;
  }
}
