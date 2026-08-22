import 'package:isar/isar.dart';
import 'package:spendra/features/expense/data/models/expense_isar_model.dart';
import 'package:spendra/features/expense/domain/entities/expense.dart';
import 'package:spendra/features/expense/domain/repositories/expense_repository.dart';
import 'package:spendra/core/utils/result.dart';

import 'package:spendra/core/sync/supabase_sync_service.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(this._isar, [this._syncService]);

  final Isar _isar;
  final SupabaseSyncService? _syncService;

  // ── Mappers ──────────────────────────────────────────────────────────────
  Expense _toEntity(ExpenseIsarModel m) => Expense(
        id: m.uuid,
        title: m.title,
        amount: m.amount,
        categoryId: m.categoryId,
        type: TransactionType.values[m.typeIndex],
        paymentMethod: PaymentMethod.values[m.paymentMethodIndex],
        date: m.date ?? DateTime.now(),
        createdAt: m.createdAt ?? DateTime.now(),
        updatedAt: m.updatedAt ?? DateTime.now(),
        merchant: m.merchant,
        note: m.note,
        location: m.location,
        receiptPath: m.receiptPath,
        tags: List<String>.from(m.tags),
        isDeleted: m.isDeleted,
      );

  ExpenseIsarModel _toModel(Expense e) => ExpenseIsarModel()
    ..uuid = e.id
    ..title = e.title
    ..amount = e.amount
    ..categoryId = e.categoryId
    ..typeIndex = e.type.index
    ..paymentMethodIndex = e.paymentMethod.index
    ..date = e.date
    ..createdAt = e.createdAt
    ..updatedAt = e.updatedAt
    ..merchant = e.merchant
    ..note = e.note
    ..location = e.location
    ..receiptPath = e.receiptPath
    ..tags = e.tags
    ..isDeleted = e.isDeleted;

  // ── Reactive streams ─────────────────────────────────────────────────────
  @override
  Stream<List<Expense>> watchAll({bool includeDeleted = false}) {
    final query = _isar.expenseIsarModels
        .filter()
        .optional(!includeDeleted, (q) => q.isDeletedEqualTo(false))
        .sortByDateDesc()
        .build();
    return query
        .watch(fireImmediately: true)
        .map((list) => list.map(_toEntity).toList());
  }

  @override
  Stream<List<Expense>> watchByDateRange(DateTime start, DateTime end) {
    return _isar.expenseIsarModels
        .filter()
        .isDeletedEqualTo(false)
        .dateBetween(start, end)
        .sortByDateDesc()
        .build()
        .watch(fireImmediately: true)
        .map((list) => list.map(_toEntity).toList());
  }

  @override
  Stream<List<Expense>> watchByCategory(String categoryId) {
    return _isar.expenseIsarModels
        .filter()
        .isDeletedEqualTo(false)
        .categoryIdEqualTo(categoryId)
        .sortByDateDesc()
        .build()
        .watch(fireImmediately: true)
        .map((list) => list.map(_toEntity).toList());
  }

  @override
  Future<List<Expense>> getForPeriod(DateTime start, DateTime end) async {
    final models = await _isar.expenseIsarModels
        .filter()
        .isDeletedEqualTo(false)
        .dateBetween(start, end)
        .sortByDateDesc()
        .findAll();
    return models.map(_toEntity).toList();
  }

  @override
  Future<Result<Expense>> getById(String uuid) async {
    try {
      final m = await _isar.expenseIsarModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (m == null) return const Failure(NotFoundFailure('Expense not found'));
      return Success(_toEntity(m));
    } catch (e, st) {
      return Failure(DatabaseFailure(e.toString()), stackTrace: st);
    }
  }

  @override
  Future<Result<void>> add(Expense expense) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.expenseIsarModels.put(_toModel(expense));
      });
      _syncService?.syncExpense(expense);
      return const Success(null);
    } catch (e, st) {
      return Failure(DatabaseFailure(e.toString()), stackTrace: st);
    }
  }

  @override
  Future<Result<void>> update(Expense expense) async {
    try {
      final existing = await _isar.expenseIsarModels
          .filter()
          .uuidEqualTo(expense.id)
          .findFirst();
      if (existing == null) {
        return const Failure(NotFoundFailure('Expense not found'));
      }
      final model = _toModel(expense)..id = existing.id;
      await _isar.writeTxn(() async {
        await _isar.expenseIsarModels.put(model);
      });
      _syncService?.syncExpense(expense);
      return const Success(null);
    } catch (e, st) {
      return Failure(DatabaseFailure(e.toString()), stackTrace: st);
    }
  }

  @override
  Future<Result<void>> softDelete(String uuid) async {
    try {
      final model = await _isar.expenseIsarModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (model == null) return const Failure(NotFoundFailure('Not found'));
      model
        ..isDeleted = true
        ..updatedAt = DateTime.now();
      await _isar.writeTxn(() async {
        await _isar.expenseIsarModels.put(model);
      });
      _syncService?.syncExpense(_toEntity(model));
      return const Success(null);
    } catch (e, st) {
      return Failure(DatabaseFailure(e.toString()), stackTrace: st);
    }
  }

  @override
  Future<Result<void>> hardDelete(String uuid) async {
    try {
      final model = await _isar.expenseIsarModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (model == null) return const Failure(NotFoundFailure('Not found'));
      await _isar.writeTxn(() async {
        await _isar.expenseIsarModels.delete(model.id);
      });
      _syncService?.deleteExpense(uuid);
      return const Success(null);
    } catch (e, st) {
      return Failure(DatabaseFailure(e.toString()), stackTrace: st);
    }
  }

  @override
  Future<List<Expense>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final matches = await _isar.expenseIsarModels
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .group((q) => q
            .titleContains(query, caseSensitive: false)
            .or()
            .merchantContains(query, caseSensitive: false)
            .or()
            .noteContains(query, caseSensitive: false))
        .sortByDateDesc()
        .findAll();
    return matches.map(_toEntity).toList();
  }

  @override
  Future<void> purgeOldDeleted(int retentionDays) async {
    final cutoff = DateTime.now().subtract(Duration(days: retentionDays));
    final old = await _isar.expenseIsarModels
        .filter()
        .isDeletedEqualTo(true)
        .updatedAtLessThan(cutoff)
        .findAll();
    if (old.isEmpty) return;
    await _isar.writeTxn(() async {
      await _isar.expenseIsarModels.deleteAll(old.map((m) => m.id).toList());
    });
  }
}
