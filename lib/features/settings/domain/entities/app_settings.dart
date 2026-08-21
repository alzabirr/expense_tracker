import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

enum AppThemeMode { system, light, dark }

/// Domain entity for user preferences.
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(AppThemeMode.system) AppThemeMode themeMode,
    @Default('USD') String currencyCode,
    @Default('en_US') String locale,
    @Default(false) bool isBiometricLockEnabled,
    DateTime? lastBackupAt,
    @Default(false) bool isFirstLaunch,
  }) = _AppSettings;

  const AppSettings._();

  static const AppSettings defaults = AppSettings(isFirstLaunch: true);
}
