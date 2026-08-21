import 'package:spendra/features/expense/domain/entities/expense.dart';
import 'package:spendra/core/utils/result.dart';

abstract class ExpenseRepository {
  Stream<List<Expense>> watchAll({bool includeDeleted = false});
  Stream<List<Expense>> watchByDateRange(DateTime start, DateTime end);
  Stream<List<Expense>> watchByCategory(String categoryId);
  Future<List<Expense>> getForPeriod(DateTime start, DateTime end);
  Future<Result<Expense>> getById(String uuid);
  Future<Result<void>> add(Expense expense);
  Future<Result<void>> update(Expense expense);
  Future<Result<void>> softDelete(String uuid);
  Future<Result<void>> hardDelete(String uuid);
  Future<List<Expense>> search(String query);
  Future<void> purgeOldDeleted(int retentionDays);
}
