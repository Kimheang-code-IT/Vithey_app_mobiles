import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';

/// Status chip for payments, messages, etc.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  factory StatusBadge.paid() => const StatusBadge(label: 'Paid', color: AppColors.paid);
  factory StatusBadge.unpaid() => const StatusBadge(label: 'Unpaid', color: AppColors.unpaid);
  factory StatusBadge.pending() => const StatusBadge(label: 'Pending', color: AppColors.pending);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: context.text.labelMedium
            ?.copyWith(fontWeight: VitheyWeight.semibold, color: color),
      ),
    );
  }
}
