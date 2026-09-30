import 'package:flutter/material.dart';

/// Illustration only — no card / fill background behind the asset.
class OnboardingTopSection extends StatelessWidget {
  const OnboardingTopSection({
    super.key,
    required this.imageAsset,
  });

  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.60;

    return SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: imageAsset == null
              ? const SizedBox.shrink()
              : Image.asset(
                  imageAsset!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
        ),
      ),
    );
  }
}
