import 'package:isar/isar.dart';
import 'package:spendra/core/sync/supabase_sync_service.dart';
import 'package:spendra/features/settings/data/models/settings_isar_model.dart';
import 'package:spendra/features/settings/domain/entities/app_settings.dart';
import 'package:spendra/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._isar, [this._syncService]);

  final Isar _isar;
  final SupabaseSyncService? _syncService;

  AppSettings _toEntity(SettingsIsarModel m) => AppSettings(
        themeMode: AppThemeMode.values[m.themeModeIndex],
        currencyCode: m.currencyCode,
        locale: m.locale,
        isBiometricLockEnabled: m.isBiometricLockEnabled,
        lastBackupAt: m.lastBackupAt,
        isFirstLaunch: m.isFirstLaunch,
      );

  SettingsIsarModel _toModel(AppSettings s) => SettingsIsarModel()
    ..id = 0
    ..themeModeIndex = s.themeMode.index
    ..currencyCode = s.currencyCode
    ..locale = s.locale
    ..isBiometricLockEnabled = s.isBiometricLockEnabled
    ..lastBackupAt = s.lastBackupAt
    ..isFirstLaunch = s.isFirstLaunch;

  Future<SettingsIsarModel> _getOrCreate() async {
    final existing = await _isar.settingsIsarModels.get(0);
    if (existing != null) return existing;
    final model = SettingsIsarModel();
    await _isar.writeTxn(() async {
      await _isar.settingsIsarModels.put(model);
    });
    return model;
  }

  @override
  Stream<AppSettings> watch() {
    return _isar.settingsIsarModels
        .watchObject(0, fireImmediately: true)
        .map((m) => m == null ? AppSettings.defaults : _toEntity(m));
  }

  @override
  Future<AppSettings> get() async {
    final m = await _isar.settingsIsarModels.get(0);
    return m == null ? AppSettings.defaults : _toEntity(m);
  }

  @override
  Future<void> save(AppSettings settings) async {
    final model = _toModel(settings);
    await _isar.writeTxn(() async {
      await _isar.settingsIsarModels.put(model);
    });
    _syncService?.syncSettings(settings);
  }

  @override
  Future<void> updateTheme(AppThemeMode mode) async {
    final current = await _getOrCreate();
    current.themeModeIndex = mode.index;
    await _isar.writeTxn(() async {
      await _isar.settingsIsarModels.put(current);
    });
    _syncService?.syncSettings(_toEntity(current));
  }

  @override
  Future<void> updateCurrency(String code, String locale) async {
    final current = await _getOrCreate();
    current
      ..currencyCode = code
      ..locale = locale;
    await _isar.writeTxn(() async {
      await _isar.settingsIsarModels.put(current);
    });
    _syncService?.syncSettings(_toEntity(current));
  }

  @override
  Future<void> markFirstLaunchComplete() async {
    final current = await _getOrCreate();
    current.isFirstLaunch = false;
    await _isar.writeTxn(() async {
      await _isar.settingsIsarModels.put(current);
    });
  }
}
