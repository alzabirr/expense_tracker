import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

/// Domain entity for a transaction category.
/// Immutable — all mutations return new instances via copyWith.
@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required String iconKey,
    required String colorToken,
    String? parentId,
    @Default(false) bool isDefault,
    double? monthlyBudget,
    @Default(false) bool isArchived,
    @Default(0) int sortOrder,
  }) = _Category;

  const Category._();

  bool get isTopLevel => parentId == null;
  bool get hasMonthlyBudget => monthlyBudget != null && monthlyBudget! > 0;
}
