import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:spendra/core/constants/default_categories.dart';
import 'package:spendra/features/category/data/models/category_isar_model.dart';
import 'package:spendra/features/settings/data/models/settings_isar_model.dart';

/// Centralized seeder for initial and reset database states.
abstract final class DatabaseSeeder {
  /// Seeds default categories if no categories exist.
  static Future<void> seedDefaultCategories(Isar isar) async {
    final count = await isar.categoryIsarModels.count();
    if (count > 0) return; // Already seeded

    await _insertDefaultCategories(isar);
    debugPrint('✅ Seeded ${DefaultCategories.all.length} default categories');
  }

  /// Resets all user data (transactions, budgets, custom categories)
  /// and restores default categories and default settings.
  static Future<void> resetAllData(Isar isar) async {
    await isar.writeTxn(() async {
      await isar.clear();
      for (final data in DefaultCategories.all) {
        final model = CategoryIsarModel()
          ..uuid = data['uuid'] as String
          ..name = data['name'] as String
          ..iconKey = data['iconKey'] as String
          ..colorToken = data['colorToken'] as String
          ..parentId = data['parentId'] as String?
          ..isDefault = data['isDefault'] as bool
          ..sortOrder = DefaultCategories.all.indexOf(data);
        await isar.categoryIsarModels.put(model);
      }
      // Re-create default settings record
      final defaultSettings = SettingsIsarModel();
      await isar.settingsIsarModels.put(defaultSettings);
    });
  }

  static Future<void> _insertDefaultCategories(Isar isar) async {
    await isar.writeTxn(() async {
      for (final data in DefaultCategories.all) {
        final model = CategoryIsarModel()
          ..uuid = data['uuid'] as String
          ..name = data['name'] as String
          ..iconKey = data['iconKey'] as String
          ..colorToken = data['colorToken'] as String
          ..parentId = data['parentId'] as String?
          ..isDefault = data['isDefault'] as bool
          ..sortOrder = DefaultCategories.all.indexOf(data);
        await isar.categoryIsarModels.put(model);
      }
    });
  }
}
