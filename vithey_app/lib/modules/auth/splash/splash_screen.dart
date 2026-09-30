import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:aub_connect_app/modules/auth/language/select_language_preview.dart';
import 'package:aub_connect_app/modules/auth/splash/splash_controller.dart';
import 'package:aub_connect_app/modules/auth/splash/widgets/splash_background.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller starts the intro timeline.
    controller;
    final screenH = MediaQuery.sizeOf(context).height;
    final baseColor = context.appColors.cardSurface;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: baseColor,
        body: Obx(() {
          final showUnderlay = controller.showLanguageUnderlay.value;
          final rise = controller.handoffProgress.value;
          final brand = controller.brandOpacity.value;
          final wash = controller.washFill.value;
          final teal = controller.tealFill.value;
          final contentReveal = controller.languageContentReveal.value;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Teal splash stays put (does not peel away).
              SplashBackground(
                washFill: wash,
                tealFill: teal,
              ),
              // Brand — fade in after teal; fully faded out before rise.
              IgnorePointer(
                child: Opacity(
                  opacity: brand,
                  child: Transform.scale(
                    scale: 0.92 + 0.08 * brand,
                    child: const Center(child: _SplashLogo()),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: SafeArea(
                  child: Opacity(
                    opacity: brand,
                    child: const Center(child: _SplashTitle()),
                  ),
                ),
              ),

              // Select Language background rises from the bottom over teal.
              if (showUnderlay)
                Transform.translate(
                  offset: Offset(0, screenH * (1.0 - rise)),
                  child: SelectLanguagePreview(
                    contentReveal: contentReveal,
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    final circleSize = MediaQuery.sizeOf(context).width * 0.35;
    return AppLogo(size: circleSize, onWhiteCircle: true);
  }
}

class _SplashTitle extends StatelessWidget {
  const _SplashTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppStrings.appName.split(' ').first,
      style: context.text.titleLarge?.copyWith(
        color: AppColors.accentLight,
        fontSize: 30,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
