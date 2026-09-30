import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/app_screen_body.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/modules/finance/finance_controller.dart';
import 'package:aub_connect_app/modules/finance/widgets/finance_app_bar.dart';
import 'package:aub_connect_app/modules/finance/widgets/finance_balance_card.dart';
import 'package:aub_connect_app/modules/finance/widgets/finance_total_paycheck.dart';
import 'package:aub_connect_app/modules/finance/widgets/payment_receipts_section.dart';

class FinanceScreen extends GetView<FinanceController> {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FinanceAppBar(),
      body: AppScreenBody(
        child: Obx(() {
          if (controller.isLoading.value) return const LoadingWidget();
          if (controller.hasError.value) {
            return AppErrorWidget(
              message: controller.errorMessage.value,
              onRetry: controller.loadFinanceHome,
            );
          }

          final data = controller.dashboard.value;
          if (data == null) return const LoadingWidget();

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FinanceBalanceCard(
                  dashboard: data,
                  onPayNow: controller.payNow,
                ),
                const SizedBox(height: 12),
                FinanceTotalPaycheck(amount: data.totalPaycheck),
                const SizedBox(height: 20),
                Expanded(
                  child: PaymentReceiptsSection(
                    payments: controller.visiblePayments,
                    showAll: controller.showAll.value,
                    isSearching: controller.isFilteringTransactions,
                    searchQuery: controller.searchQuery.value,
                    onToggleShowAll: controller.toggleShowAll,
                    onPaymentTap: controller.openPaymentDetail,
                    onRefresh: controller.refreshFinance,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
