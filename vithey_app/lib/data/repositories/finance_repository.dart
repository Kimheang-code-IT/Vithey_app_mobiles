import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/data/fixtures/finance_fixtures.dart';
import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';
import 'package:aub_connect_app/data/models/money_model.dart';
import 'package:aub_connect_app/data/models/payment_invoice_model.dart';
import 'package:aub_connect_app/data/services/finance_service.dart';

class FinanceRepository {
  FinanceRepository(this._financeService, this._flags);

  final FinanceService _financeService;
  final FeatureFlags _flags;

  bool get useMockApi => _flags.useMockApi;

  Future<FinanceDashboard> getFinanceDashboard({int page = 1, int limit = 20}) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return FinanceFixtures.buildDashboard();
    }

    final payments = List<PaymentSummary>.from(
      await _financeService.fetchPayments(page: page, limit: limit),
    )..sort((a, b) => b.sortDate.compareTo(a.sortDate));
    final unpaid = payments.where((p) => p.status != PaymentStatus.paid).toList();
    final totalMinor = unpaid.fold<int>(0, (sum, p) => sum + p.amount.amountMinor);
    final paycheckMinor = payments
        .where((p) => p.status == PaymentStatus.paid)
        .fold<int>(0, (sum, p) => sum + p.amount.amountMinor);
    final nextDuePayment = unpaid.isEmpty
        ? null
        : unpaid.reduce((a, b) => a.dueDate.isBefore(b.dueDate) ? a : b);
    final nextDue = nextDuePayment?.dueDate ?? DateTime.now();
    return FinanceDashboard(
      totalDue: Money(amountMinor: totalMinor),
      totalPaycheck: Money(amountMinor: paycheckMinor),
      nextDueDate: nextDue,
      daysRemaining: nextDue.difference(DateTime.now()).inDays.clamp(0, 999),
      summaryStatus: totalMinor == 0 ? 'Paid' : 'Not Yet Paid',
      payments: payments,
      nextDuePaymentId: nextDuePayment?.id,
      hasMore: payments.length >= limit,
    );
  }

  Future<PaymentInvoice> getPaymentInvoice(String paymentId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return FinanceFixtures.buildInvoice(paymentId);
    }
    return _financeService.fetchPaymentInvoice(paymentId);
  }

  /// Fee catalog (`GET /fees`) — STUDENT role required on backend.
  Future<List<Map<String, dynamic>>> getFees() async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return const [];
    }
    return _financeService.fetchFees();
  }

  Future<void> downloadInvoice(String paymentId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      return;
    }
    await _financeService.fetchPaymentInvoice(paymentId);
  }
}
