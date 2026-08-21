import 'package:spendra/features/budget/domain/entities/budget.dart';
import 'package:spendra/core/utils/result.dart';

abstract class BudgetRepository {
  Stream<Budget?> watchOverallBudget();
  Stream<List<Budget>> watchAll();
  Future<Budget?> getOverallBudget();
  Future<Budget?> getByCategoryId(String categoryId);
  Future<Result<void>> saveOverallBudget(double amount);
  Future<Result<void>> saveCategoryBudget(String categoryId, double amount);
  Future<Result<void>> deleteBudget(String uuid);
}
