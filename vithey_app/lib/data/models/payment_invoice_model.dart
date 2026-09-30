import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';
import 'package:aub_connect_app/data/models/money_model.dart';

class PaymentInvoiceArgs {
  const PaymentInvoiceArgs({required this.paymentId});

  final String paymentId;
}

class PaymentInvoice {
  const PaymentInvoice({
    required this.paymentId,
    required this.invoiceReference,
    required this.feeName,
    required this.status,
    required this.baseAmount,
    required this.processingFee,
    required this.lateCharges,
    required this.total,
    this.dueAt,
    this.paidAt,
    this.invoiceFileId,
  });

  final String paymentId;
  final String invoiceReference;
  final String feeName;
  final PaymentStatus status;
  final Money baseAmount;
  final Money processingFee;
  final Money lateCharges;
  final Money total;
  final DateTime? dueAt;
  final DateTime? paidAt;
  final String? invoiceFileId;

  /// Mock / v1 UI uses "Total Due" for both Paid and Pending states.
  String get totalLabel => 'Total Due';

  String get statusLabel {
    switch (status) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.unpaid:
        return 'Pending';
      case PaymentStatus.overdue:
        return 'Overdue';
    }
  }
}
