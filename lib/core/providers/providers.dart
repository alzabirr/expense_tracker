import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendra/core/database/isar_provider.dart';
import 'package:spendra/features/category/data/repositories/category_repository_impl.dart';
import 'package:spendra/features/category/domain/entities/category.dart';
import 'package:spendra/features/category/domain/repositories/category_repository.dart';
import 'package:spendra/features/expense/data/repositories/expense_repository_impl.dart';
import 'package:spendra/features/expense/domain/entities/expense.dart';
import 'package:spendra/features/expense/domain/repositories/expense_repository.dart';
import 'package:spendra/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:spendra/features/budget/domain/entities/budget.dart';
import 'package:spendra/features/budget/domain/repositories/budget_repository.dart';
import 'package:spendra/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:spendra/features/settings/domain/entities/app_settings.dart';
import 'package:spendra/features/settings/domain/repositories/settings_repository.dart';
import 'package:spendra/core/constants/app_constants.dart';
import 'package:spendra/core/utils/date_utils.dart';

// ── Repository Providers ─────────────────────────────────────────────────────

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(isarProvider));
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(ref.watch(isarProvider));
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepositoryImpl(ref.watch(isarProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(isarProvider));
});

// ── Settings Providers ───────────────────────────────────────────────────────

final settingsStreamProvider = StreamProvider<AppSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watch();
});

final themeModeProvider = Provider<AppThemeMode>((ref) {
  return ref.watch(settingsStreamProvider).valueOrNull?.themeMode ??
      AppThemeMode.system;
});

final currencyCodeProvider = Provider<String>((ref) {
  return ref.watch(settingsStreamProvider).valueOrNull?.currencyCode ?? 'USD';
});

final localeProvider = Provider<String>((ref) {
  return ref.watch(settingsStreamProvider).valueOrNull?.locale ?? 'en_US';
});

// ── Category Providers ───────────────────────────────────────────────────────

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

final topLevelCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchTopLevel();
});

// ── Expense Providers ────────────────────────────────────────────────────────

final allExpensesStreamProvider = StreamProvider<List<Expense>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchAll();
});

final currentMonthExpensesProvider = StreamProvider<List<Expense>>((ref) {
  final start = AppDateUtils.startOfMonth;
  final end = AppDateUtils.endOfMonth;
  return ref.watch(expenseRepositoryProvider).watchByDateRange(start, end);
});

// ── Budget Providers ─────────────────────────────────────────────────────────

final overallBudgetProvider = StreamProvider<Budget?>((ref) {
  return ref.watch(budgetRepositoryProvider).watchOverallBudget();
});

final allBudgetsProvider = StreamProvider<List<Budget>>((ref) {
  return ref.watch(budgetRepositoryProvider).watchAll();
});

// ── Dashboard Summary Provider ───────────────────────────────────────────────

class DashboardSummary {
  const DashboardSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.budgetAmount,
    required this.budgetSpent,
    required this.recentTransactions,
  });

  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final double budgetAmount;
  final double budgetSpent;
  final List<Expense> recentTransactions;

  double get budgetProgress =>
      budgetAmount <= 0 ? 0 : (budgetSpent / budgetAmount).clamp(0.0, 1.0);

  double get budgetRemaining => budgetAmount - budgetSpent;
}

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final expenses = ref.watch(currentMonthExpensesProvider).valueOrNull ?? [];
  final budget = ref.watch(overallBudgetProvider).valueOrNull;
  final all = ref.watch(allExpensesStreamProvider).valueOrNull ?? [];

  final income = expenses
      .where((e) => e.isIncome)
      .fold(0.0, (sum, e) => sum + e.amount);
  final spent = expenses
      .where((e) => e.isExpense)
      .fold(0.0, (sum, e) => sum + e.amount);

  final allIncome = all
      .where((e) => e.isIncome)
      .fold(0.0, (sum, e) => sum + e.amount);
  final allSpent = all
      .where((e) => e.isExpense)
      .fold(0.0, (sum, e) => sum + e.amount);

  return DashboardSummary(
    totalBalance: allIncome - allSpent,
    totalIncome: income,
    totalExpense: spent,
    budgetAmount: budget?.amount ?? 0,
    budgetSpent: spent,
    recentTransactions:
        all.take(AppConstants.recentTransactionsCount).toList(),
  );
});
