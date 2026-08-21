import 'package:spendra/features/category/domain/entities/category.dart';
import 'package:spendra/core/utils/result.dart';

abstract class CategoryRepository {
  Stream<List<Category>> watchAll({bool includeArchived = false});
  Stream<List<Category>> watchTopLevel();
  Future<Result<Category>> getById(String uuid);
  Future<Result<void>> add(Category category);
  Future<Result<void>> update(Category category);
  Future<Result<void>> archive(String uuid);
  Future<Result<void>> delete(String uuid);
  Future<bool> hasTransactions(String uuid);
}
