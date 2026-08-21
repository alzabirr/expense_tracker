import 'package:intl/intl.dart';

/// Locale-aware currency formatting utilities.
/// All currency display MUST go through this class — never hardcode symbols.
abstract final class CurrencyFormatter {
  static NumberFormat _formatter(String currencyCode, String locale) =>
      NumberFormat.currency(
        locale: locale,
        symbol: _symbol(currencyCode),
        decimalDigits: 2,
      );

  static String format(
    double amount, {
    String currencyCode = 'USD',
    String locale = 'en_US',
  }) =>
      _formatter(currencyCode, locale).format(amount);

  /// Formats without currency symbol, e.g. "1,234.56".
  static String formatAmount(
    double amount, {
    String locale = 'en_US',
  }) =>
      NumberFormat('#,##0.00', locale).format(amount);

  /// Formats a compact value: "1.2K", "1.5M", etc.
  static String formatCompact(
    double amount, {
    String currencyCode = 'USD',
  }) {
    final symbol = _symbol(currencyCode);
    if (amount.abs() >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  static String _symbol(String code) {
    return switch (code) {
      'USD' => '\$',
      'EUR' => '€',
      'JPY' => '¥',
      'GBP' => '£',
      'CNY' => '¥',
      'CHF' => 'CHF',
      'CAD' => 'C\$',
      'AUD' => 'A\$',
      'HKD' => 'HK\$',
      'SGD' => 'S\$',
      'INR' => '₹',
      'KRW' => '₩',
      'NZD' => 'NZ\$',
      'SEK' => 'kr',
      'NOK' => 'kr',
      'DKK' => 'kr',
      'AED' => 'د.إ',
      'SAR' => '﷼',
      'TRY' => '₺',
      'BDT' => '৳',
      _ => code,
    };
  }

  static String symbol(String currencyCode) => _symbol(currencyCode);
}
