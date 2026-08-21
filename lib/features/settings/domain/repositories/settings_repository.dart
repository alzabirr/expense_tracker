import 'package:spendra/features/settings/domain/entities/app_settings.dart';

abstract class SettingsRepository {
  Stream<AppSettings> watch();
  Future<AppSettings> get();
  Future<void> save(AppSettings settings);
  Future<void> updateTheme(AppThemeMode mode);
  Future<void> updateCurrency(String code, String locale);
  Future<void> markFirstLaunchComplete();
}
