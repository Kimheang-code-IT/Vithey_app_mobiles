import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/onboarding_background.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/onboarding_bottom_section.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/wave_ribbon.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Visual-only Select Language for Splash handoff.
/// Must NOT use GetX — Splash deletes/replaces routes around this widget.
class SelectLanguagePreview extends StatelessWidget {
  const SelectLanguagePreview({
    super.key,
    this.contentReveal = 1.0,
  });

  final double contentReveal;

  static const introDotCount = 4;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary =
        isDark ? const Color(0xFFB0B0BE) : const Color(0xFF5A5A68);
    final border = context.appColors.border;
    final reveal = contentReveal.clamp(0.0, 1.0);
    final contentT = Curves.easeOutCubic.transform(reveal);

    return Scaffold(
      backgroundColor: context.appColors.cardSurface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const OnboardingBackground(
            profile: WaveRibbon.language,
          ),
          Opacity(
            opacity: contentT,
            child: Transform.translate(
              offset: Offset(0, (1.0 - contentT) * 48),
              child: IgnorePointer(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Column(
                      children: [
                        const Expanded(
                          flex: 34,
                          child: SafeArea(
                            bottom: false,
                            child: Center(
                              child: AppLogo(size: 100, onWhiteCircle: true),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 66,
                          child: SafeArea(
                            top: false,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 112),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  8,
                                  24,
                                  8,
                                ),
                                child: Column(
                                  children: [
                                    const Spacer(flex: 5),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 420,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Select Language',
                                            textAlign: TextAlign.center,
                                            style: context.text.headlineSmall
                                                ?.copyWith(height: 1.25),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Choose your preferred language for the app.',
                                            textAlign: TextAlign.center,
                                            style: context.text.bodyMedium
                                                ?.copyWith(
                                              color: secondary,
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 40),
                                          DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              border: Border.all(color: border),
                                            ),
                                            child: Column(
                                              children: [
                                                _PreviewRow(
                                                  flagAsset:
                                                      AppAssets.englishLanguage,
                                                  title: 'English (US)',
                                                  subtitle: 'English',
                                                  selected: true,
                                                  secondary: secondary,
                                                ),
                                                Divider(
                                                  height: 1,
                                                  color: border,
                                                ),
                                                _PreviewRow(
                                                  flagAsset:
                                                      AppAssets.khmerLanguage,
                                                  title: 'Khmer',
                                                  subtitle: 'ភាសាខ្មែរ',
                                                  selected: false,
                                                  secondary: secondary,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(flex: 2),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: OnboardingBottomChrome(
                        currentPage: 0,
                        totalPages: introDotCount,
                        onNext: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.flagAsset,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.secondary,
  });

  final String flagAsset;
  final String title;
  final String subtitle;
  final bool selected;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              flagAsset,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.text.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.text.bodySmall?.copyWith(color: secondary),
                ),
              ],
            ),
          ),
          if (selected)
            const VitheyIcon(LucideIcons.check, color: AppColors.primary, size: 24)
          else
            const SizedBox(width: 24),
        ],
      ),
    );
  }
}
