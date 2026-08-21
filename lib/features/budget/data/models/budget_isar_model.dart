import 'package:isar/isar.dart';

part 'budget_isar_model.g.dart';

@collection
class BudgetIsarModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  /// null = overall budget; non-null = per-category budget
  String? categoryId;

  double amount = 0.0;

  @Index()
  DateTime? periodStart;

  /// 0 = monthly, 1 = weekly
  int periodTypeIndex = 0;

  /// Stored as comma-separated or as individual ints
  List<int> alertThresholds = [80, 100];
}
