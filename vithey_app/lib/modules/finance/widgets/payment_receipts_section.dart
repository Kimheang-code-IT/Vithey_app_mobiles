import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';
import 'package:aub_connect_app/modules/finance/widgets/payment_receipt_tile.dart';

/// Fixed section header + scrollable transaction list (list scrolls under the title).
class PaymentReceiptsSection extends StatelessWidget {
  const PaymentReceiptsSection({
    super.key,
    required this.payments,
    required this.showAll,
    required this.onToggleShowAll,
    required this.onPaymentTap,
    this.onRefresh,
    this.searchQuery = '',
    this.isSearching = false,
  });

  final List<PaymentSummary> payments;
  final bool showAll;
  final VoidCallback onToggleShowAll;
  final ValueChanged<String> onPaymentTap;
  final Future<void> Function()? onRefresh;
  final String searchQuery;
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    final listContent = payments.isEmpty
        ? ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 32, bottom: 24),
            children: [
              EmptyStateWidget(
                title: 'No transactions yet',
                subtitle: isSearching ? AppStrings.financeSearchEmpty : 'Your payments will appear here',
              ),
            ],
          )
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: payments.length,
            itemBuilder: (_, index) {
              final payment = payments[index];
              return PaymentReceiptTile(
                payment: payment,
                searchQuery: searchQuery,
                onTap: () => onPaymentTap(payment.id),
              );
            },
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              isSearching ? 'Search Results' : 'Recent Transaction',
              style: context.text.titleLarge,
            ),
            const Spacer(),
            if (!isSearching)
              GestureDetector(
                onTap: onToggleShowAll,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text(
                    showAll ? 'See Less' : 'See All',
                    style: context.text.labelLarge
                        ?.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: onRefresh == null
              ? listContent
              : RefreshIndicator(onRefresh: onRefresh!, child: listContent),
        ),
      ],
    );
  }
}
