import 'package:isar/isar.dart';

part 'settings_isar_model.g.dart';

@collection
class SettingsIsarModel {
  /// Fixed ID = 0. Only one settings record ever exists.
  Id id = 0;

  /// 0 = system, 1 = light, 2 = dark
  int themeModeIndex = 0;

  String currencyCode = 'USD';
  String locale = 'en_US';
  bool isBiometricLockEnabled = false;
  DateTime? lastBackupAt;
  bool isFirstLaunch = true;
}
