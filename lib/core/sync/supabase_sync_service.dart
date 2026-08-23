import 'package:flutter/foundation.dart' show debugPrint;
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendra/features/budget/data/models/budget_isar_model.dart';
import 'package:spendra/features/budget/domain/entities/budget.dart';
import 'package:spendra/features/category/data/models/category_isar_model.dart';
import 'package:spendra/features/category/domain/entities/category.dart';
import 'package:spendra/features/expense/data/models/expense_isar_model.dart';
import 'package:spendra/features/expense/domain/entities/expense.dart';
import 'package:spendra/features/settings/data/models/settings_isar_model.dart';
import 'package:spendra/features/settings/domain/entities/app_settings.dart';

class SupabaseSyncService {
  SupabaseSyncService(this._supabase);

  final SupabaseClient _supabase;

  String? get currentUserId => _supabase.auth.currentUser?.id;

  // ── Sync single Expense ───────────────────────────────────────────────────
  Future<void> syncExpense(Expense expense) async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      final payload = {
        'id': expense.id,
        'user_id': userId,
        'title': expense.title,
        'amount': expense.amount,
        'category_id': expense.categoryId,
        'type': expense.type.name,
        'payment_method': expense.paymentMethod.name,
        'date': expense.date.toIso8601String(),
        'created_at': expense.createdAt.toIso8601String(),
        'updated_at': expense.updatedAt.toIso8601String(),
        'merchant': expense.merchant,
        'note': expense.note,
        'location': expense.location,
        'receipt_path': expense.receiptPath,
        'tags': expense.tags,
        'is_deleted': expense.isDeleted,
      };

      await _supabase.from('expenses').upsert(payload, onConflict: 'id');
    } catch (e) {
      debugPrint('SupabaseSync: syncExpense error: $e');
    }
  }

  // ── Sync single Category ──────────────────────────────────────────────────
  Future<void> syncCategory(Category category) async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      final payload = {
        'id': category.id,
        'user_id': userId,
        'name': category.name,
        'icon_key': category.iconKey,
        'color_token': category.colorToken,
        'parent_id': category.parentId,
        'is_default': category.isDefault,
        'monthly_budget': category.monthlyBudget,
        'is_archived': category.isArchived,
        'sort_order': category.sortOrder,
      };

      await _supabase.from('categories').upsert(payload, onConflict: 'id');
    } catch (e) {
      debugPrint('SupabaseSync: syncCategory error: $e');
    }
  }

  // ── Sync single Budget ────────────────────────────────────────────────────
  Future<void> syncBudget(Budget budget) async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      final payload = {
        'id': budget.id,
        'user_id': userId,
        'category_id': budget.categoryId,
        'amount': budget.amount,
        'period_start': budget.periodStart.toIso8601String(),
        'period_type': budget.periodType.name,
        'alert_thresholds': budget.alertThresholds,
      };

      await _supabase.from('budgets').upsert(payload, onConflict: 'id');
    } catch (e) {
      debugPrint('SupabaseSync: syncBudget error: $e');
    }
  }

  // ── Sync User Settings (Currency, Region, Theme) ──────────────────────────
  Future<void> syncSettings(AppSettings settings) async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      final payload = {
        'user_id': userId,
        'currency_code': settings.currencyCode,
        'locale': settings.locale,
        'theme_mode': settings.themeMode.name,
        'is_biometric_lock_enabled': settings.isBiometricLockEnabled,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('user_settings').upsert(payload, onConflict: 'user_id');
    } catch (e) {
      debugPrint('SupabaseSync: syncSettings error: $e');
    }
  }

  // ── Delete single records from Supabase ──────────────────────────────────
  Future<void> deleteExpense(String id) async {
    final userId = currentUserId;
    if (userId == null) return;
    try {
      await _supabase.from('expenses').delete().eq('id', id).eq('user_id', userId);
    } catch (e) {
      debugPrint('SupabaseSync: deleteExpense error: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    final userId = currentUserId;
    if (userId == null) return;
    try {
      await _supabase.from('categories').delete().eq('id', id).eq('user_id', userId);
    } catch (e) {
      debugPrint('SupabaseSync: deleteCategory error: $e');
    }
  }

  Future<void> deleteBudget(String id) async {
    final userId = currentUserId;
    if (userId == null) return;
    try {
      await _supabase.from('budgets').delete().eq('id', id).eq('user_id', userId);
    } catch (e) {
      debugPrint('SupabaseSync: deleteBudget error: $e');
    }
  }

  // ── Push all local data to Supabase (Full Initial / Manual Sync) ──────────
  Future<void> pushAllLocalData(Isar isar) async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      // 1. Categories
      final catModels = await isar.categoryIsarModels.where().findAll();
      if (catModels.isNotEmpty) {
        final catPayloads = catModels.map((m) => {
          'id': m.uuid,
          'user_id': userId,
          'name': m.name,
          'icon_key': m.iconKey,
          'color_token': m.colorToken,
          'parent_id': m.parentId,
          'is_default': m.isDefault,
          'monthly_budget': m.monthlyBudget,
          'is_archived': m.isArchived,
          'sort_order': m.sortOrder,
        }).toList();
        await _supabase.from('categories').upsert(catPayloads);
      }

      // 2. Expenses
      final expModels = await isar.expenseIsarModels.where().findAll();
      if (expModels.isNotEmpty) {
        final expPayloads = expModels.map((m) => {
          'id': m.uuid,
          'user_id': userId,
          'title': m.title,
          'amount': m.amount,
          'category_id': m.categoryId,
          'type': TransactionType.values[m.typeIndex].name,
          'payment_method': PaymentMethod.values[m.paymentMethodIndex].name,
          'date': (m.date ?? DateTime.now()).toIso8601String(),
          'created_at': (m.createdAt ?? DateTime.now()).toIso8601String(),
          'updated_at': (m.updatedAt ?? DateTime.now()).toIso8601String(),
          'merchant': m.merchant,
          'note': m.note,
          'location': m.location,
          'receipt_path': m.receiptPath,
          'tags': m.tags,
          'is_deleted': m.isDeleted,
        }).toList();
        await _supabase.from('expenses').upsert(expPayloads);
      }

      // 4. Budgets
      final budgetModels = await isar.budgetIsarModels.where().findAll();
      if (budgetModels.isNotEmpty) {
        final budgetPayloads = budgetModels.map((m) => {
          'id': m.uuid,
          'user_id': userId,
          'category_id': m.categoryId,
          'amount': m.amount,
          'period_start': (m.periodStart ?? DateTime.now()).toIso8601String(),
          'period_type': BudgetPeriod.values[m.periodTypeIndex].name,
          'alert_thresholds': m.alertThresholds,
        }).toList();
        await _supabase.from('budgets').upsert(budgetPayloads);
      }

      // 4. User Settings (Currency, Region, Theme)
      final settingsModel = await isar.settingsIsarModels.get(0);
      if (settingsModel != null) {
        final settingsPayload = {
          'user_id': userId,
          'currency_code': settingsModel.currencyCode,
          'locale': settingsModel.locale,
          'theme_mode': AppThemeMode.values[settingsModel.themeModeIndex].name,
          'is_biometric_lock_enabled': settingsModel.isBiometricLockEnabled,
          'updated_at': DateTime.now().toIso8601String(),
        };
        await _supabase.from('user_settings').upsert(settingsPayload);
      }
    } catch (e) {
      debugPrint('SupabaseSync: pushAllLocalData error: $e');
    }
  }

  // ── Pull all cloud data from Supabase to Local Isar DB ────────────────────
  Future<void> pullAllCloudData(Isar isar) async {
    final userId = currentUserId;
    if (userId == null) return;

    try {
      // 1. Pull Categories
      final catData = await _supabase.from('categories').select().eq('user_id', userId);
      if (catData.isNotEmpty) {
        await isar.writeTxn(() async {
          for (final row in catData) {
            final uuid = row['id'] as String;
            final existing = await isar.categoryIsarModels.filter().uuidEqualTo(uuid).findFirst();
            final model = existing ?? (CategoryIsarModel()..uuid = uuid);
            model
              ..name = (row['name'] as String?) ?? 'Category'
              ..iconKey = (row['icon_key'] as String?) ?? 'more_horizontal'
              ..colorToken = (row['color_token'] as String?) ?? 'coral'
              ..parentId = row['parent_id'] as String?
              ..isDefault = (row['is_default'] as bool?) ?? false
              ..monthlyBudget = (row['monthly_budget'] as num?)?.toDouble()
              ..isArchived = (row['is_archived'] as bool?) ?? false
              ..sortOrder = (row['sort_order'] as int?) ?? 0;
            await isar.categoryIsarModels.put(model);
          }
        });
      }

      // 2. Pull Expenses
      final expData = await _supabase.from('expenses').select().eq('user_id', userId);
      if (expData.isNotEmpty) {
        await isar.writeTxn(() async {
          for (final row in expData) {
            final uuid = row['id'] as String;
            final existing = await isar.expenseIsarModels.filter().uuidEqualTo(uuid).findFirst();
            final model = existing ?? (ExpenseIsarModel()..uuid = uuid);

            final typeStr = row['type'] as String? ?? 'expense';
            final type = TransactionType.values.firstWhere(
              (t) => t.name == typeStr,
              orElse: () => TransactionType.expense,
            );

            final pmStr = row['payment_method'] as String? ?? 'cash';
            final pm = PaymentMethod.values.firstWhere(
              (p) => p.name == pmStr,
              orElse: () => PaymentMethod.cash,
            );

            model
              ..title = (row['title'] as String?) ?? 'Transaction'
              ..amount = (row['amount'] as num?)?.toDouble() ?? 0.0
              ..categoryId = (row['category_id'] as String?) ?? ''
              ..typeIndex = type.index
              ..paymentMethodIndex = pm.index
              ..date = row['date'] != null ? DateTime.tryParse(row['date'] as String) : DateTime.now()
              ..createdAt = row['created_at'] != null ? DateTime.tryParse(row['created_at'] as String) : DateTime.now()
              ..updatedAt = row['updated_at'] != null ? DateTime.tryParse(row['updated_at'] as String) : DateTime.now()
              ..merchant = row['merchant'] as String?
              ..note = row['note'] as String?
              ..location = row['location'] as String?
              ..receiptPath = row['receipt_path'] as String?
              ..tags = (row['tags'] as List?)?.map((e) => e.toString()).toList() ?? []
              ..isDeleted = (row['is_deleted'] as bool?) ?? false;

            await isar.expenseIsarModels.put(model);
          }
        });
      }

      // 3. Pull Budgets
      final budgetData = await _supabase.from('budgets').select().eq('user_id', userId);
      if (budgetData.isNotEmpty) {
        await isar.writeTxn(() async {
          for (final row in budgetData) {
            final uuid = row['id'] as String;
            final existing = await isar.budgetIsarModels.filter().uuidEqualTo(uuid).findFirst();
            final model = existing ?? (BudgetIsarModel()..uuid = uuid);

            final ptStr = row['period_type'] as String? ?? 'monthly';
            final pt = BudgetPeriod.values.firstWhere(
              (p) => p.name == ptStr,
              orElse: () => BudgetPeriod.monthly,
            );

            model
              ..categoryId = row['category_id'] as String?
              ..amount = (row['amount'] as num?)?.toDouble() ?? 0.0
              ..periodStart = row['period_start'] != null ? DateTime.tryParse(row['period_start'] as String) : DateTime.now()
              ..periodTypeIndex = pt.index
              ..alertThresholds = (row['alert_thresholds'] as List?)?.map((e) => (e as num).toInt()).toList() ?? [80, 100];

            await isar.budgetIsarModels.put(model);
          }
        });
      }

      // 4. Pull User Settings
      final settingsData = await _supabase.from('user_settings').select().eq('user_id', userId).maybeSingle();
      if (settingsData != null) {
        final currency = (settingsData['currency_code'] as String?) ?? 'USD';
        final locale = (settingsData['locale'] as String?) ?? 'en_US';
        final themeStr = (settingsData['theme_mode'] as String?) ?? 'system';
        final themeMode = AppThemeMode.values.firstWhere(
          (t) => t.name == themeStr,
          orElse: () => AppThemeMode.system,
        );
        final isBio = (settingsData['is_biometric_lock_enabled'] as bool?) ?? false;

        await isar.writeTxn(() async {
          final existing = await isar.settingsIsarModels.get(0) ?? SettingsIsarModel();
          existing
            ..currencyCode = currency
            ..locale = locale
            ..themeModeIndex = themeMode.index
            ..isBiometricLockEnabled = isBio;
          await isar.settingsIsarModels.put(existing);
        });
      }
    } catch (e) {
      debugPrint('SupabaseSync: pullAllCloudData error: $e');
    }
  }
}
