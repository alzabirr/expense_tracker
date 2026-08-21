// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AppSettings {
  AppThemeMode get themeMode => throw _privateConstructorUsedError;
  String get currencyCode => throw _privateConstructorUsedError;
  String get locale => throw _privateConstructorUsedError;
  bool get isBiometricLockEnabled => throw _privateConstructorUsedError;
  DateTime? get lastBackupAt => throw _privateConstructorUsedError;
  bool get isFirstLaunch => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AppSettingsCopyWith<AppSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsCopyWith<$Res> {
  factory $AppSettingsCopyWith(
          AppSettings value, $Res Function(AppSettings) then) =
      _$AppSettingsCopyWithImpl<$Res, AppSettings>;
  @useResult
  $Res call(
      {AppThemeMode themeMode,
      String currencyCode,
      String locale,
      bool isBiometricLockEnabled,
      DateTime? lastBackupAt,
      bool isFirstLaunch});
}

/// @nodoc
class _$AppSettingsCopyWithImpl<$Res, $Val extends AppSettings>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? currencyCode = null,
    Object? locale = null,
    Object? isBiometricLockEnabled = null,
    Object? lastBackupAt = freezed,
    Object? isFirstLaunch = null,
  }) {
    return _then(_value.copyWith(
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as AppThemeMode,
      currencyCode: null == currencyCode
          ? _value.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      locale: null == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as String,
      isBiometricLockEnabled: null == isBiometricLockEnabled
          ? _value.isBiometricLockEnabled
          : isBiometricLockEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      lastBackupAt: freezed == lastBackupAt
          ? _value.lastBackupAt
          : lastBackupAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isFirstLaunch: null == isFirstLaunch
          ? _value.isFirstLaunch
          : isFirstLaunch // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppSettingsImplCopyWith<$Res>
    implements $AppSettingsCopyWith<$Res> {
  factory _$$AppSettingsImplCopyWith(
          _$AppSettingsImpl value, $Res Function(_$AppSettingsImpl) then) =
      __$$AppSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AppThemeMode themeMode,
      String currencyCode,
      String locale,
      bool isBiometricLockEnabled,
      DateTime? lastBackupAt,
      bool isFirstLaunch});
}

/// @nodoc
class __$$AppSettingsImplCopyWithImpl<$Res>
    extends _$AppSettingsCopyWithImpl<$Res, _$AppSettingsImpl>
    implements _$$AppSettingsImplCopyWith<$Res> {
  __$$AppSettingsImplCopyWithImpl(
      _$AppSettingsImpl _value, $Res Function(_$AppSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? themeMode = null,
    Object? currencyCode = null,
    Object? locale = null,
    Object? isBiometricLockEnabled = null,
    Object? lastBackupAt = freezed,
    Object? isFirstLaunch = null,
  }) {
    return _then(_$AppSettingsImpl(
      themeMode: null == themeMode
          ? _value.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as AppThemeMode,
      currencyCode: null == currencyCode
          ? _value.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      locale: null == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as String,
      isBiometricLockEnabled: null == isBiometricLockEnabled
          ? _value.isBiometricLockEnabled
          : isBiometricLockEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      lastBackupAt: freezed == lastBackupAt
          ? _value.lastBackupAt
          : lastBackupAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isFirstLaunch: null == isFirstLaunch
          ? _value.isFirstLaunch
          : isFirstLaunch // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$AppSettingsImpl extends _AppSettings {
  const _$AppSettingsImpl(
      {this.themeMode = AppThemeMode.system,
      this.currencyCode = 'USD',
      this.locale = 'en_US',
      this.isBiometricLockEnabled = false,
      this.lastBackupAt,
      this.isFirstLaunch = false})
      : super._();

  @override
  @JsonKey()
  final AppThemeMode themeMode;
  @override
  @JsonKey()
  final String currencyCode;
  @override
  @JsonKey()
  final String locale;
  @override
  @JsonKey()
  final bool isBiometricLockEnabled;
  @override
  final DateTime? lastBackupAt;
  @override
  @JsonKey()
  final bool isFirstLaunch;

  @override
  String toString() {
    return 'AppSettings(themeMode: $themeMode, currencyCode: $currencyCode, locale: $locale, isBiometricLockEnabled: $isBiometricLockEnabled, lastBackupAt: $lastBackupAt, isFirstLaunch: $isFirstLaunch)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingsImpl &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.locale, locale) || other.locale == locale) &&
            (identical(other.isBiometricLockEnabled, isBiometricLockEnabled) ||
                other.isBiometricLockEnabled == isBiometricLockEnabled) &&
            (identical(other.lastBackupAt, lastBackupAt) ||
                other.lastBackupAt == lastBackupAt) &&
            (identical(other.isFirstLaunch, isFirstLaunch) ||
                other.isFirstLaunch == isFirstLaunch));
  }

  @override
  int get hashCode => Object.hash(runtimeType, themeMode, currencyCode, locale,
      isBiometricLockEnabled, lastBackupAt, isFirstLaunch);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      __$$AppSettingsImplCopyWithImpl<_$AppSettingsImpl>(this, _$identity);
}

abstract class _AppSettings extends AppSettings {
  const factory _AppSettings(
      {final AppThemeMode themeMode,
      final String currencyCode,
      final String locale,
      final bool isBiometricLockEnabled,
      final DateTime? lastBackupAt,
      final bool isFirstLaunch}) = _$AppSettingsImpl;
  const _AppSettings._() : super._();

  @override
  AppThemeMode get themeMode;
  @override
  String get currencyCode;
  @override
  String get locale;
  @override
  bool get isBiometricLockEnabled;
  @override
  DateTime? get lastBackupAt;
  @override
  bool get isFirstLaunch;
  @override
  @JsonKey(ignore: true)
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
