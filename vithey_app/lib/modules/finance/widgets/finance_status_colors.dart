import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';

/// Status chrome for Finance.
/// List: Paid → green · Pending → orange · Overdue → red.
/// Invoice: Paid → primary (teal) · Pending → orange · Overdue → red.
abstract final class FinanceStatusColors {
  static Color listAccent(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return AppColors.success;
      case PaymentStatus.unpaid:
        return AppColors.pending;
      case PaymentStatus.overdue:
        return AppColors.error;
    }
  }

  static Color invoiceAccent(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return AppColors.primary;
      case PaymentStatus.unpaid:
        return AppColors.pending;
      case PaymentStatus.overdue:
        return AppColors.error;
    }
  }

  static Color invoicePanelFill(PaymentStatus status) =>
      invoiceAccent(status).withValues(alpha: 0.12);
}
