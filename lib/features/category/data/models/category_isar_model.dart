import 'package:isar/isar.dart';

part 'category_isar_model.g.dart';

@collection
class CategoryIsarModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String name;
  late String iconKey;
  late String colorToken;
  String? parentId;
  bool isDefault = false;
  double? monthlyBudget;
  bool isArchived = false;
  int sortOrder = 0;
}
