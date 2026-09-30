class Money {
  const Money({required this.amountMinor, this.currency = 'USD'});

  final int amountMinor;
  final String currency;

  double get amount => amountMinor / 100;

  String get formatted {
    final symbol = currency == 'KHR' ? '៛' : '\$';
    if (currency == 'KHR') {
      return '$symbol${_withCommas(amountMinor.toString())}';
    }
    final whole = amountMinor ~/ 100;
    final cents = (amountMinor.abs() % 100).toString().padLeft(2, '0');
    return '$symbol${_withCommas(whole.toString())}.$cents';
  }

  static String _withCommas(String digits) {
    return digits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  factory Money.fromJson(Map<String, dynamic> json) {
    return Money(
      amountMinor: json['amount_minor'] as int? ?? (json['amount'] as num? ?? 0).round(),
      currency: json['currency'] as String? ?? 'USD',
    );
  }
}
