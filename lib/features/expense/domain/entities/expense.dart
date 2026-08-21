import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';

enum TransactionType { expense, income }

enum PaymentMethod {
  cash,
  debitCard,
  creditCard,
  bankTransfer,
  digitalWallet,
  other,
}

extension PaymentMethodLabel on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.cash => 'Cash',
        PaymentMethod.debitCard => 'Debit Card',
        PaymentMethod.creditCard => 'Credit Card',
        PaymentMethod.bankTransfer => 'Bank Transfer',
        PaymentMethod.digitalWallet => 'Digital Wallet',
        PaymentMethod.other => 'Other',
      };

  String get iconKey => switch (this) {
        PaymentMethod.cash => 'banknote',
        PaymentMethod.debitCard => 'credit_card',
        PaymentMethod.creditCard => 'credit_card',
        PaymentMethod.bankTransfer => 'landmark',
        PaymentMethod.digitalWallet => 'smartphone',
        PaymentMethod.other => 'more_horizontal',
      };
}

/// Domain entity for a transaction (both expense and income).
@freezed
class Expense with _$Expense {
  const factory Expense({
    required String id,
    required String title,
    required double amount,
    required String categoryId,
    required TransactionType type,
    required DateTime date,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? merchant,
    String? note,
    String? location,
    String? receiptPath,
    @Default([]) List<String> tags,
    @Default(PaymentMethod.cash) PaymentMethod paymentMethod,
    @Default(false) bool isDeleted,
  }) = _Expense;

  const Expense._();

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;

  /// Signed amount: negative for expenses, positive for income.
  double get signedAmount => isExpense ? -amount : amount;
}
