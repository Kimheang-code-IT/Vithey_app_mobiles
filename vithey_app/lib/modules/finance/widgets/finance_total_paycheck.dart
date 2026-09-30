import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/data/models/money_model.dart';

/// Soft strip under the balance card — Total Paycheck.
class FinanceTotalPaycheck extends StatelessWidget {
  const FinanceTotalPaycheck({super.key, required this.amount});

  final Money amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(VitheyRadii.card),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '\$',
              style: context.text.titleMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              'Total Paycheck',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.titleSmall
                  ?.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              amount.formatted,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: context.text.titleMedium
                  ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
