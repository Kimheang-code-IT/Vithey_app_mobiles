import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

/// Official Vithey app logo (`assets/images/brand/app_logo.png`).
///
/// Always rendered on a white circular background (same treatment as auth).
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 120,
    this.onWhiteCircle = true,
  });

  final double size;

  /// Kept for call-site compatibility; the logo always uses a white circle.
  final bool onWhiteCircle;

  @override
  Widget build(BuildContext context) {
    final imageSize = size * 0.86;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accentLight,
        boxShadow: [
          BoxShadow(
            color: context.appColors.subtleShadow,
            blurRadius: size >= 64 ? 12 : 6,
            offset: Offset(0, size >= 64 ? 4 : 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Image.asset(
        AppAssets.logoApp,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.contain,
      ),
    );
  }
}
