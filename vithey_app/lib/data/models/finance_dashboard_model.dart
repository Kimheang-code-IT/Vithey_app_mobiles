import 'package:aub_connect_app/data/models/money_model.dart';

enum PaymentStatus { paid, unpaid, overdue }

class PaymentSummary {
  const PaymentSummary({
    required this.id,
    required this.feeName,
    required this.amount,
    required this.status,
    required this.dueDate,
    this.paidAt,
    this.baseAmount,
  });

  final String id;
  final String feeName;

  /// Total charged (base + processing fee + late charges). Shown in Recent Transaction.
  final Money amount;

  /// Base fee before fees/charges. Used when building invoice breakdown.
  /// When null, [amount] is treated as the base (API payloads without a split).
  final Money? baseAmount;

  final PaymentStatus status;
  final DateTime dueDate;
  final DateTime? paidAt;

  Money get invoiceBase => baseAmount ?? amount;

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

  /// Newest-first list order uses due date only (status is not a sort key).
  DateTime get sortDate => dueDate;

  /// Display date under the fee name (mock uses a plain calendar date).
  String get dateLabel {
    final date = status == PaymentStatus.paid && paidAt != null ? paidAt! : dueDate;
    return _formatDate(date);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class FinanceDashboard {
  const FinanceDashboard({
    required this.totalDue,
    required this.totalPaycheck,
    required this.nextDueDate,
    required this.daysRemaining,
    required this.summaryStatus,
    required this.payments,
    this.nextDuePaymentId,
    this.hasMore = false,
  });

  /// Outstanding Balance on the teal card.
  final Money totalDue;

  /// Total Paycheck strip below the card (paid-to-date / period total).
  final Money totalPaycheck;

  final DateTime nextDueDate;
  final int daysRemaining;
  final String summaryStatus;
  final List<PaymentSummary> payments;
  final String? nextDuePaymentId;
  final bool hasMore;

  String get dueBadgeLabel =>
      daysRemaining > 0 ? 'Due in $daysRemaining Days' : 'Due Today';

  String get nextDueDateLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[nextDueDate.month - 1]} ${nextDueDate.day}, ${nextDueDate.year}';
  }
}
