import 'package:aub_connect_app/data/fixtures/mock_clock.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';
import 'package:aub_connect_app/data/models/money_model.dart';
import 'package:aub_connect_app/data/models/payment_invoice_model.dart';

abstract final class FinanceFixtures {
  /// Mixed statuses with interleaved due dates so newest-first order
  /// shows recent Paid and Pending together (not all pending on top).
  static List<PaymentSummary> buildPayments() {
    return [
      _payment(
        id: MockIds.pay1,
        feeName: 'School Fee',
        baseMinor: 120000,
        status: PaymentStatus.unpaid,
        dueDate: MockClock.daysFromNow(16),
      ),
      _payment(
        id: MockIds.pay2,
        feeName: 'Housing Fee',
        baseMinor: 250000,
        status: PaymentStatus.paid,
        dueDate: MockClock.daysFromNow(14),
        paidAt: MockClock.daysAgo(1),
      ),
      _payment(
        id: MockIds.pay3,
        feeName: 'Library Fee',
        baseMinor: 1000,
        status: PaymentStatus.unpaid,
        dueDate: MockClock.daysFromNow(12),
      ),
      _payment(
        id: MockIds.pay4,
        feeName: 'Food Fee',
        baseMinor: 50000,
        status: PaymentStatus.paid,
        dueDate: MockClock.daysFromNow(10),
        paidAt: MockClock.daysAgo(2),
      ),
      _payment(
        id: MockIds.pay5,
        feeName: 'Trip',
        baseMinor: 5000,
        status: PaymentStatus.unpaid,
        dueDate: MockClock.daysFromNow(8),
      ),
      _payment(
        id: MockIds.pay6,
        feeName: 'Tuition Fee',
        baseMinor: 450000,
        status: PaymentStatus.paid,
        dueDate: MockClock.daysFromNow(6),
        paidAt: MockClock.daysAgo(3),
      ),
      _payment(
        id: MockIds.pay7,
        feeName: 'Lab Equipment',
        baseMinor: 45000,
        status: PaymentStatus.unpaid,
        dueDate: MockClock.daysFromNow(4),
      ),
      _payment(
        id: MockIds.pay8,
        feeName: 'Sports Club',
        baseMinor: 35000,
        status: PaymentStatus.paid,
        dueDate: MockClock.daysFromNow(2),
        paidAt: MockClock.now,
      ),
      _payment(
        id: MockIds.pay9,
        feeName: 'Exam Fee',
        baseMinor: 25000,
        status: PaymentStatus.unpaid,
        dueDate: MockClock.daysFromNow(1),
      ),
      _payment(
        id: MockIds.pay10,
        feeName: 'Dormitory Deposit',
        baseMinor: 150000,
        status: PaymentStatus.overdue,
        dueDate: MockClock.daysAgo(2),
      ),
      _payment(
        id: MockIds.pay11,
        feeName: 'ID Card Replacement',
        baseMinor: 1500,
        status: PaymentStatus.paid,
        dueDate: MockClock.daysAgo(4),
        paidAt: MockClock.daysAgo(5),
      ),
      _payment(
        id: MockIds.pay12,
        feeName: 'Workshop Fee',
        baseMinor: 8000,
        status: PaymentStatus.overdue,
        dueDate: MockClock.daysAgo(7),
      ),
      _payment(
        id: MockIds.pay13,
        feeName: 'Internet Package',
        baseMinor: 20000,
        status: PaymentStatus.paid,
        dueDate: MockClock.daysAgo(9),
        paidAt: MockClock.daysAgo(8),
      ),
      _payment(
        id: MockIds.pay14,
        feeName: 'Parking Permit',
        baseMinor: 12000,
        status: PaymentStatus.unpaid,
        dueDate: MockClock.daysFromNow(28),
      ),
      _payment(
        id: MockIds.pay15,
        feeName: 'Graduation Fee',
        baseMinor: 75000,
        status: PaymentStatus.paid,
        dueDate: MockClock.daysAgo(18),
        paidAt: MockClock.daysAgo(16),
      ),
    ];
  }

  static FinanceDashboard buildDashboard() {
    final payments = List<PaymentSummary>.from(buildPayments())
      ..sort((a, b) => b.sortDate.compareTo(a.sortDate));
    final unpaid = payments.where((p) => p.status != PaymentStatus.paid).toList();
    final totalMinor = unpaid.fold<int>(0, (sum, p) => sum + p.amount.amountMinor);
    final paycheckMinor = payments
        .where((p) => p.status == PaymentStatus.paid)
        .fold<int>(0, (sum, p) => sum + p.amount.amountMinor);
    final nextDuePayment = unpaid.isEmpty
        ? null
        : unpaid.reduce((a, b) => a.dueDate.isBefore(b.dueDate) ? a : b);
    final nextDue = nextDuePayment?.dueDate ?? MockClock.daysFromNow(14);
    final daysRemaining = nextDue.difference(MockClock.now).inDays.clamp(0, 999);
    return FinanceDashboard(
      totalDue: Money(amountMinor: totalMinor, currency: 'USD'),
      totalPaycheck: Money(amountMinor: paycheckMinor, currency: 'USD'),
      nextDueDate: nextDue,
      daysRemaining: daysRemaining,
      summaryStatus: totalMinor == 0 ? 'Paid' : 'Not Yet Paid',
      payments: payments,
      nextDuePaymentId: nextDuePayment?.id,
      hasMore: false,
    );
  }

  static PaymentInvoice buildInvoice(String paymentId) {
    final payment = buildPayments().firstWhere((p) => p.id == paymentId);
    final base = payment.invoiceBase.amountMinor;
    final parts = _feeParts(base: base, status: payment.status);
    return PaymentInvoice(
      paymentId: payment.id,
      invoiceReference: _referenceFor(payment.id),
      feeName: payment.feeName,
      status: payment.status,
      baseAmount: Money(amountMinor: base),
      processingFee: Money(amountMinor: parts.processing),
      lateCharges: Money(amountMinor: parts.late),
      total: Money(amountMinor: parts.total),
      dueAt: payment.dueDate,
      paidAt: payment.paidAt,
      invoiceFileId: 'invoice-${payment.id}',
    );
  }

  static PaymentSummary _payment({
    required String id,
    required String feeName,
    required int baseMinor,
    required PaymentStatus status,
    required DateTime dueDate,
    DateTime? paidAt,
  }) {
    final parts = _feeParts(base: baseMinor, status: status);
    return PaymentSummary(
      id: id,
      feeName: feeName,
      baseAmount: Money(amountMinor: baseMinor),
      amount: Money(amountMinor: parts.total),
      status: status,
      dueDate: dueDate,
      paidAt: paidAt,
    );
  }

  static ({int processing, int late, int total}) _feeParts({
    required int base,
    required PaymentStatus status,
  }) {
    final processing = (base * 0.02).round();
    final late = status == PaymentStatus.overdue ? 1500 : 0;
    return (
      processing: processing,
      late: late,
      total: base + processing + late,
    );
  }

  static String _referenceFor(String paymentId) {
    final seed = paymentId.hashCode.abs().toRadixString(16).toUpperCase();
    final padded = '${seed}A34D1B522'.substring(0, 8);
    final prefix = paymentId.contains('1') || paymentId.contains('6')
        ? 'Y3T'
        : paymentId.contains('3')
            ? 'TEXU'
            : 'VTH';
    return '$prefix-$padded';
  }
}
