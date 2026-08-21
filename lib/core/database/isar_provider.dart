import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:spendra/features/category/data/models/category_isar_model.dart';
import 'package:spendra/features/expense/data/models/expense_isar_model.dart';
import 'package:spendra/features/budget/data/models/budget_isar_model.dart';
import 'package:spendra/features/settings/data/models/settings_isar_model.dart';

/// Riverpod provider that holds the open [Isar] instance.
/// The actual instance is injected via ProviderScope.overrides in main.dart
/// after async initialisation — the throw here is never reached at runtime.
final isarProvider = Provider<Isar>(
  (ref) => throw StateError('Isar not initialised — check bootstrap.dart'),
  name: 'isarProvider',
);

/// Opens the Isar database. Called once in bootstrap before ProviderScope.
Future<Isar> openIsar() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Isar.getInstance('momentum_db') != null) {
    return Isar.getInstance('momentum_db')!;
  }
  if (Isar.getInstance() != null) {
    return Isar.getInstance()!;
  }

  String path = '';
  try {
    final dir = await getApplicationDocumentsDirectory();
    path = dir.path;
  } catch (_) {
    try {
      final supportDir = await getApplicationSupportDirectory();
      path = supportDir.path;
    } catch (_) {
      final tempDir = await getTemporaryDirectory();
      path = tempDir.path;
    }
  }

  try {
    return await Isar.open(
      [
        CategoryIsarModelSchema,
        ExpenseIsarModelSchema,
        BudgetIsarModelSchema,
        SettingsIsarModelSchema,
      ],
      directory: path,
      name: 'momentum_db',
      inspector: false,
    );
  } catch (e) {
    debugPrint('Isar.open with name failed: $e. Opening default instance.');
    return await Isar.open(
      [
        CategoryIsarModelSchema,
        ExpenseIsarModelSchema,
        BudgetIsarModelSchema,
        SettingsIsarModelSchema,
      ],
      directory: path,
      inspector: false,
    );
  }
}
