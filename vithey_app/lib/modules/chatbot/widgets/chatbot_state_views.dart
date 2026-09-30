import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Shared empty / loading / error views for the chatbot module.
///
/// GenZ kit styling: soft squircle chrome, pill geometry, muted washes.

/// Empty-chat hero: logo + title, centered. No description.
class ChatbotEmptyHero extends StatelessWidget {
  const ChatbotEmptyHero({
    super.key,
    this.title = 'How can I help you today?',
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppAssets.logoApp,
          width: 64,
          height: 64,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: context.text.titleLarge,
        ),
      ],
    );
  }
}

/// Skeleton chat while session messages load — bubble placeholders only,
/// no spinners.
class ChatbotLoadingView extends StatelessWidget {
  const ChatbotLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _Skeleton(
            width: 220,
            height: 48,
            color: colors.inputFill,
          ),
        ),
        const SizedBox(height: 16),
        _Skeleton(width: 280, height: 16, color: colors.inputFill),
        const SizedBox(height: 10),
        _Skeleton(width: 240, height: 16, color: colors.inputFill),
        const SizedBox(height: 10),
        _Skeleton(width: 180, height: 16, color: colors.inputFill),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: _Skeleton(
            width: 160,
            height: 48,
            color: colors.inputFill,
          ),
        ),
        const SizedBox(height: 16),
        _Skeleton(width: 260, height: 16, color: colors.inputFill),
        const SizedBox(height: 10),
        _Skeleton(width: 200, height: 16, color: colors.inputFill),
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

/// Soft error bubble for failed assistant replies — error wash, radius 18,
/// never a raw red box.
class ChatbotErrorBubble extends StatelessWidget {
  const ChatbotErrorBubble({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.appColors.dangerSurface,
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VitheyIcon(
            LucideIcons.circleAlert,
            size: 20,
            color: AppColors.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: context.text.titleSmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
