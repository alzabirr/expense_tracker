import 'package:flutter_test/flutter_test.dart';
import 'package:spendra/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('formatAmount correctly formats standard decimals', () {
      expect(CurrencyFormatter.formatAmount(1234.5), '1,234.50');
      expect(CurrencyFormatter.formatAmount(1000000), '1,000,000.00');
      expect(CurrencyFormatter.formatAmount(0), '0.00');
    });

    test('symbol returns correct currency symbols', () {
      expect(CurrencyFormatter.symbol('USD'), '\$');
      expect(CurrencyFormatter.symbol('EUR'), '€');
      expect(CurrencyFormatter.symbol('GBP'), '£');
      expect(CurrencyFormatter.symbol('JPY'), '¥');
      expect(CurrencyFormatter.symbol('BDT'), '৳');
      expect(CurrencyFormatter.symbol('UNKNOWN'), 'UNKNOWN');
    });
  });
}
