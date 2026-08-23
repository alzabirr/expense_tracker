import 'package:isar/isar.dart';
import 'package:spendra/features/category/data/models/category_isar_model.dart';
import 'package:spendra/features/category/domain/entities/category.dart';
import 'package:spendra/features/category/domain/repositories/category_repository.dart';
import 'package:spendra/core/utils/result.dart';
import 'package:spendra/core/sync/supabase_sync_service.dart';
import 'package:spendra/features/expense/data/models/expense_isar_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._isar, [this._syncService]);

  final Isar _isar;
  final SupabaseSyncService? _syncService;

  // ── Mappers ──────────────────────────────────────────────────────────────
  Category _toEntity(CategoryIsarModel m) => Category(
        id: m.uuid,
        name: m.name,
        iconKey: m.iconKey,
        colorToken: m.colorToken,
        parentId: m.parentId,
        isDefault: m.isDefault,
        monthlyBudget: m.monthlyBudget,
        isArchived: m.isArchived,
        sortOrder: m.sortOrder != 0 ? m.sortOrder : m.id,
      );

  CategoryIsarModel _toModel(Category e) => CategoryIsarModel()
    ..uuid = e.id
    ..name = e.name
    ..iconKey = e.iconKey
    ..colorToken = e.colorToken
    ..parentId = e.parentId
    ..isDefault = e.isDefault
    ..monthlyBudget = e.monthlyBudget
    ..isArchived = e.isArchived
    ..sortOrder = e.sortOrder;

  // ── Queries ──────────────────────────────────────────────────────────────
  @override
  Stream<List<Category>> watchAll({bool includeArchived = false}) {
    final query = _isar.categoryIsarModels
        .filter()
        .optional(!includeArchived, (q) => q.isArchivedEqualTo(false))
        .sortBySortOrderDesc()
        .build();
    return query.watch(fireImmediately: true).map(
          (list) => list.map(_toEntity).toList(),
        );
  }

  @override
  Stream<List<Category>> watchTopLevel() {
    return _isar.categoryIsarModels
        .filter()
        .parentIdIsNull()
        .isArchivedEqualTo(false)
        .sortBySortOrderDesc()
        .build()
        .watch(fireImmediately: true)
        .map((list) => list.map(_toEntity).toList());
  }

  @override
  Future<Result<Category>> getById(String uuid) async {
    try {
      final model = await _isar.categoryIsarModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (model == null) {
        return const Failure(NotFoundFailure('Category not found'));
      }
      return Success(_toEntity(model));
    } catch (e, st) {
      return Failure(DatabaseFailure(e.toString()), stackTrace: st);
    }
  }

  @override
  Future<Result<void>> add(Category category) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.categoryIsarModels.put(_toModel(category));
      });
      _syncService?.syncCategory(category);
      return const Success(null);
    } catch (e, st) {
      return Failure(DatabaseFailure(e.toString()), stackTrace: st);
    }
  }

  @override
  Future<Result<void>> update(Category category) async {
    try {
      final existing = await _isar.categoryIsarModels
          .filter()
          .uuidEqualTo(category.id)
          .findFirst();
      if (existing == null) {
        return const Failure(NotFoundFailure('Category not found'));
      }
      final model = _toModel(category)..id = existing.id;
      await _isar.writeTxn(() async {
        await _isar.categoryIsarModels.put(model);
      });
      _syncService?.syncCategory(category);
      return const Success(null);
    } catch (e, st) {
      return Failure(DatabaseFailure(e.toString()), stackTrace: st);
    }
  }

  @override
  Future<Result<void>> archive(String uuid) async {
    try {
      final model = await _isar.categoryIsarModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (model == null) return const Failure(NotFoundFailure('Not found'));
      model.isArchived = true;
      await _isar.writeTxn(() async {
        await _isar.categoryIsarModels.put(model);
      });
      _syncService?.syncCategory(_toEntity(model));
      return const Success(null);
    } catch (e, st) {
      return Failure(DatabaseFailure(e.toString()), stackTrace: st);
    }
  }

  @override
  Future<Result<void>> delete(String uuid) async {
    try {
      final model = await _isar.categoryIsarModels
          .filter()
          .uuidEqualTo(uuid)
          .findFirst();
      if (model == null) return const Failure(NotFoundFailure('Not found'));
      await _isar.writeTxn(() async {
        await _isar.categoryIsarModels.delete(model.id);
      });
      _syncService?.deleteCategory(uuid);
      return const Success(null);
    } catch (e, st) {
      return Failure(DatabaseFailure(e.toString()), stackTrace: st);
    }
  }

  @override
  Future<bool> hasTransactions(String uuid) async {
    final count = await _isar.expenseIsarModels
        .filter()
        .categoryIdEqualTo(uuid)
        .isDeletedEqualTo(false)
        .count();
    return count > 0;
  }
}
