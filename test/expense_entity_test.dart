import 'package:flutter_test/flutter_test.dart';
import 'package:spendra/features/expense/domain/entities/expense.dart';

void main() {
  group('Expense Domain Entity Tests', () {
    test('isExpense and isIncome return correct boolean states', () {
      final now = DateTime.now();
      final expense = Expense(
        id: '1',
        title: 'Lunch',
        amount: 15.5,
        type: TransactionType.expense,
        categoryId: 'food',
        date: now,
        createdAt: now,
        updatedAt: now,
      );

      final income = Expense(
        id: '2',
        title: 'Salary',
        amount: 3000.0,
        type: TransactionType.income,
        categoryId: 'salary',
        date: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(expense.isExpense, isTrue);
      expect(expense.isIncome, isFalse);
      expect(expense.signedAmount, -15.5);

      expect(income.isExpense, isFalse);
      expect(income.isIncome, isTrue);
      expect(income.signedAmount, 3000.0);
    });
  });
}
