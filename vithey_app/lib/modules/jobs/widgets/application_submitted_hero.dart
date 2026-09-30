import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ApplicationSubmittedHero extends StatelessWidget {
  const ApplicationSubmittedHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 24,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Container(
                  width: 3,
                  height: 12.0 + i * 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
          Positioned(
            left: 22,
            top: 32,
            child: Transform.rotate(
              angle: -0.08,
              child: VitheyIcon(
                LucideIcons.fileText,
                size: 76,
                color: AppColors.info.withValues(alpha: 0.18),
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              VitheyIcon(LucideIcons.fileText,
                  size: 88, color: AppColors.info.withValues(alpha: 0.85)),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const VitheyIcon(LucideIcons.check, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
