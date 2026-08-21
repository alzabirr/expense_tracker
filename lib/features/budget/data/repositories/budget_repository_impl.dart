import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:spendra/features/budget/data/models/budget_isar_model.dart';
import 'package:spendra/features/budget/domain/entities/budget.dart';
import 'package:spendra/features/budget/domain/repositories/budget_repository.dart';
import 'package:spendra/core/utils/result.dart';
import 'package:spendra/core/utils/date_utils.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  BudgetRepositoryImpl(this._isar);

  final Isar _isar;
  final _uuid = const Uuid();

  Budget _toEntity(BudgetIsarModel m) => Budget(
        id: m.uuid,
        amount: m.amount,
        periodStart: m.periodStart ?? DateTime.now(),
        categoryId: m.categoryId,
        periodType: BudgetPeriod.values[m.periodTypeIndex],
        alertThresholds: List<int>.from(m.alertThresholds),
      );

  @override
  Stream<Budget?> watchOverallBudget() {
    return _isar.budgetIsarModels
        .filter()
        .categoryIdIsNull()
        .build()
        .watch(fireImmediately: true)
        .map((list) => list.isEmpty ? null : _toEntity(list.first));
  }

  @override
  Stream<List<Budget>> watchAll() {
    return _isar.budgetIsarModels
        .where()
        .watch(fireImmediately: true)
        .map((list) => list.map(_toEntity).toList());
  }

  @override
  Future<Budget?> getOverallBudget() async {
    final m = await _isar.budgetIsarModels
        .filter()
        .categoryIdIsNull()
        .findFirst();
    return m == null ? null : _toEntity(m);
  }

  @override
  Future<Budget?> getByCategoryId(String categoryId) async {
    final m = await _isar.budgetIsarModels
        .filter()
        .categoryIdEqualTo(categoryId)
        .findFirst();
    return m == null ? null : _toEntity(m);
  }

  @override
  Future<Result<void>> saveOverallBudget(double amount) async {
    try {
      final existing = await _isar.budgetIsarModels
          .filter()
          .categoryIdIsNull()
          .findFirst();
      final model = existing ?? (BudgetIsarModel()..uuid = _uuid.v4());
      model
        ..amount = amount
        ..periodStart = AppDateUtils.startOfMonth
        ..periodTypeIndex = BudgetPeriod.monthly.index
        ..alertThresholds = [80, 100];
      await _isar.writeTxn(() async {
        await _isar.budgetIsarModels.put(model);
      });
      return const Success(null);
    } catch (e, st) {
      return Failure(DatabaseFailure(e.toString()), stackTrace: st);
    }
  }

  @override
  Future<Result<void>> saveCategoryBudget(
      String categoryId, double amount) async {
    try {
      final existing = await _isar.budgetIsarModels
          .filter()
          .categoryIdEqualTo(categoryId)
          .findFirst();
      final model = existing ?? (BudgetIsarModel()..uuid = _uuid.v4());
      model
        ..categoryId = categoryId
        ..amount = amount
        ..periodStart = AppDateUtils.startOfMonth
        ..periodTypeIndex = BudgetPeriod.monthly.index;
      await _isar.writeTxn(() async {
        await _isar.budgetIsarModels.put(model);
      });
      return const Success(null);
    } catch (e, st) {
      return Failure(DatabaseFailure(e.toString()), stackTrace: st);
    }
  }

  @override
  Future<Result<void>> deleteBudget(String uuid) async {
    try {
      final m = await _isar.budgetIsarModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (m == null) return const Failure(NotFoundFailure('Not found'));
      await _isar.writeTxn(() async {
        await _isar.budgetIsarModels.delete(m.id);
      });
      return const Success(null);
    } catch (e, st) {
      return Failure(DatabaseFailure(e.toString()), stackTrace: st);
    }
  }
}
