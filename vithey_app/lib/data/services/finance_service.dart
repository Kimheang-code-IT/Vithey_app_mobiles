import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_service.dart';
import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';
import 'package:aub_connect_app/data/models/money_model.dart';
import 'package:aub_connect_app/data/models/payment_invoice_model.dart';

class FinanceService {
  FinanceService(this._api);

  final ApiService _api;

  Future<List<PaymentSummary>> fetchPayments({required int page, int limit = 10}) async {
    final response = await _api.get<List<PaymentSummary>>(
      ApiEndpoints.payments,
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) {
        final list = json as List<dynamic>? ?? [];
        return list.map((item) => _parsePayment(item as Map<String, dynamic>)).toList();
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw FinanceServiceException(response.error?.message ?? 'Failed to load payments');
    }
    return response.data!;
  }

  Future<PaymentInvoice> fetchPaymentInvoice(String paymentId) async {
    final response = await _api.get<PaymentInvoice>(
      '${ApiEndpoints.payments}/$paymentId',
      fromJson: (json) => _parseInvoice(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw FinanceServiceException(response.error?.message ?? 'Payment not found');
    }
    return response.data!;
  }

  Future<List<Map<String, dynamic>>> fetchFees() async {
    final response = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.fees,
      fromJson: (json) {
        final list = json as List<dynamic>? ?? [];
        return list
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw FinanceServiceException(response.error?.message ?? 'Failed to load fees');
    }
    return response.data!;
  }

  Future<List<Map<String, dynamic>>> fetchPaymentAlerts() async {
    final response = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.paymentsAlerts,
      fromJson: (json) {
        final list = json as List<dynamic>? ?? [];
        return list
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw FinanceServiceException(response.error?.message ?? 'Failed to load alerts');
    }
    return response.data!;
  }

  PaymentSummary _parsePayment(Map<String, dynamic> json) {
    final currency = json['currency'] as String?;
    final amount = _money(json['amount'], currency);
    final baseAmount = _optionalMoney(json['base_amount'], currency);
    return PaymentSummary(
      id: json['payment_id']?.toString() ?? json['id']?.toString() ?? '',
      feeName: json['fee_name'] as String? ?? 'Fee',
      amount: amount,
      baseAmount: baseAmount,
      status: _parseStatus(json['status'] as String?),
      dueDate: DateTime.tryParse(json['due_date']?.toString() ?? '') ?? DateTime.now(),
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at'].toString()) : null,
    );
  }

  PaymentInvoice _parseInvoice(Map<String, dynamic> json) {
    final currency = json['currency'] as String?;
    final total = _money(json['total'] ?? json['amount'], currency);
    return PaymentInvoice(
      paymentId: json['payment_id']?.toString() ?? json['id']?.toString() ?? '',
      invoiceReference:
          json['invoice_reference'] as String? ?? json['payment_id']?.toString() ?? '',
      feeName: json['fee_name'] as String? ?? 'Fee',
      status: _parseStatus(json['status'] as String?),
      baseAmount: _optionalMoney(json['base_amount'], currency) ?? total,
      processingFee: _money(json['processing_fee'] ?? 0, currency),
      lateCharges: _money(json['late_charges'] ?? 0, currency),
      total: total,
      dueAt: json['due_at'] != null
          ? DateTime.tryParse(json['due_at'].toString())
          : DateTime.tryParse(json['due_date']?.toString() ?? ''),
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at'].toString()) : null,
      invoiceFileId: json['invoice_file_id'] as String?,
    );
  }

  /// Accepts an amount as either a nested Money object (`{amount, currency}`)
  /// or the flat backend shape (`amount` number + sibling `currency`).
  Money _money(dynamic value, String? currency) {
    if (value is Map<String, dynamic>) return Money.fromJson(value);
    if (value is Map) return Money.fromJson(Map<String, dynamic>.from(value));
    return Money.fromJson({'amount': value, 'currency': currency});
  }

  Money? _optionalMoney(dynamic value, String? currency) =>
      value == null ? null : _money(value, currency);

  PaymentStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PAID':
        return PaymentStatus.paid;
      case 'OVERDUE':
        return PaymentStatus.overdue;
      default:
        return PaymentStatus.unpaid;
    }
  }
}

class FinanceServiceException implements Exception {
  FinanceServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
