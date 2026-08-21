import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';

enum BudgetPeriod { monthly, weekly }

/// Domain entity for a budget limit.
/// If [categoryId] is null, it represents the overall monthly budget.
@freezed
class Budget with _$Budget {
  const factory Budget({
    required String id,
    required double amount,
    required DateTime periodStart,
    String? categoryId, // null = overall budget
    @Default(BudgetPeriod.monthly) BudgetPeriod periodType,
    @Default([80, 100]) List<int> alertThresholds,
  }) = _Budget;

  const Budget._();

  bool get isOverall => categoryId == null;
}
