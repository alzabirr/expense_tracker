import 'package:isar/isar.dart';

part 'expense_isar_model.g.dart';

@collection
class ExpenseIsarModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String title;
  String? merchant;
  double amount = 0.0;

  /// 0 = expense, 1 = income
  int typeIndex = 0;

  @Index()
  late String categoryId;

  /// PaymentMethod enum index
  int paymentMethodIndex = 0;

  @Index()
  DateTime? date;

  String? note;
  List<String> tags = [];
  String? location;
  String? receiptPath;

  @Index()
  bool isDeleted = false;

  DateTime? createdAt;
  DateTime? updatedAt;
}
