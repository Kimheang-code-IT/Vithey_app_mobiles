import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/status_badge.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';
import 'package:aub_connect_app/modules/finance/widgets/finance_status_colors.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class PaymentReceiptTile extends StatelessWidget {
  const PaymentReceiptTile({
    super.key,
    required this.payment,
    required this.onTap,
    this.searchQuery = '',
  });

  final PaymentSummary payment;
  final VoidCallback onTap;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final statusColor = FinanceStatusColors.listAccent(payment.status);
    final statusIcon = payment.status == PaymentStatus.paid
        ? LucideIcons.circleCheck
        : LucideIcons.clock;

    return VitheyCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      borderRadius: VitheyRadii.card,
      onTap: onTap,
      child: Row(
        children: [
          VitheyIcon(statusIcon, color: statusColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HighlightedText(
                  text: payment.feeName,
                  query: searchQuery,
                  style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: context.appColors.heading),
                ),
                const SizedBox(height: 2),
                Text(
                  payment.dateLabel,
                  style: context.text.bodySmall?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                payment.amount.formatted,
                style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: context.appColors.heading),
              ),
              const SizedBox(height: 4),
              StatusBadge(label: payment.statusLabel, color: statusColor),
            ],
          ),
        ],
      ),
    );
  }

}

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
  });

  final String text;
  final String query;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = trimmed.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index < 0) {
        if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (index > start) spans.add(TextSpan(text: text.substring(start, index)));
      spans.add(
        TextSpan(
          text: text.substring(index, index + trimmed.length),
          style: style?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
      start = index + trimmed.length;
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(style: style, children: spans),
    );
  }
}
