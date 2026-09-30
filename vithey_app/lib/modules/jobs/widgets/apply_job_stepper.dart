import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ApplyJobStepper extends StatelessWidget {
  const ApplyJobStepper({
    super.key,
    required this.currentStep,
  });

  /// 0 = upload, 1 = review, 2 = success (visual only on wizard)
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 6, 0, 16),
        child: SizedBox(
          width: 164,
          child: Row(
            children: [
              _StepNode(active: currentStep >= 0, completed: currentStep > 0),
              Expanded(child: _StepLine(active: currentStep >= 1)),
              _StepNode(active: currentStep >= 1, completed: currentStep > 1),
              Expanded(child: _StepLine(active: currentStep >= 2)),
              _StepNode(active: currentStep >= 2, completed: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({required this.active, required this.completed});

  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : context.appColors.border;
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed ? AppColors.primary : Colors.transparent,
        border: Border.all(color: color, width: 2),
        boxShadow: active && !completed
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : const [],
      ),
      child: completed
          ? const VitheyIcon(LucideIcons.check, size: 10, color: Colors.white)
          : null,
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : context.appColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
