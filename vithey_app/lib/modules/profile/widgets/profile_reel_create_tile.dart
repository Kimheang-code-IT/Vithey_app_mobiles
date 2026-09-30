import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// “Create reel” tile — orange → purple gradient, GenZ rounded (r16).
class ProfileReelCreateTile extends StatelessWidget {
  const ProfileReelCreateTile({super.key, required this.onTap});

  final VoidCallback onTap;

  static const _gradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0xFFFF6A00),
      Color(0xFFE040A0),
      Color(0xFF7B2FF7),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        child: Ink(
          decoration: BoxDecoration(
            gradient: _gradient,
            borderRadius: BorderRadius.circular(VitheyRadii.card),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VitheyIcon(
                      LucideIcons.video,
                      color: AppColors.error.withValues(alpha: 0.9),
                      size: 26,
                    ),
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const VitheyIcon(
                          LucideIcons.plus,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Create reel',
                textAlign: TextAlign.center,
                style: context.text.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
