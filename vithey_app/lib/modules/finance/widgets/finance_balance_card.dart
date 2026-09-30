import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';

/// v1 Outstanding Balance card — wallet on right, Due under amount, Pay Now CTA.
/// GenZ soft card: token radius + tinted border + subtle shadow (dark-mode safe).
class FinanceBalanceCard extends StatelessWidget {
  const FinanceBalanceCard({
    super.key,
    required this.dashboard,
    required this.onPayNow,
  });

  final FinanceDashboard dashboard;
  final VoidCallback onPayNow;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.cardSurface,
            AppColors.primary.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: colors.subtleShadow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Outstanding Balance',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          dashboard.totalDue.formatted,
                          maxLines: 1,
                          softWrap: false,
                          style: context.text.headlineSmall
                              ?.copyWith(fontSize: 32, height: 1.1),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(VitheyRadii.pill),
                        ),
                        child: Text(
                          dashboard.dueBadgeLabel,
                          maxLines: 1,
                          softWrap: false,
                          style: context.text.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const VitheyIcon(
                    LucideIcons.wallet,
                    size: 36,
                    color: AppColors.primary,
                  ),
                ),

              ],
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            label: 'Pay Now',
            variant: CustomButtonVariant.primary,
            onPressed: onPayNow,
          ),
        ],
      ),
    );
  }
}
