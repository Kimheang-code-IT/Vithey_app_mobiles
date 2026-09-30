import 'package:aub_connect_app/data/models/payment_invoice_model.dart';

enum PaymentMethodType { acleda, otherBank }

class PaymentArgs {
  const PaymentArgs({required this.invoice, required this.method, this.bankName});

  final PaymentInvoice invoice;
  final PaymentMethodType method;

  /// Set when [method] is [PaymentMethodType.otherBank] — the bank picked from [BankSelectSheet].
  final String? bankName;
}
