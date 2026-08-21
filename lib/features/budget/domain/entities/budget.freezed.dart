// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Budget {
  String get id => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get periodStart => throw _privateConstructorUsedError;
  String? get categoryId =>
      throw _privateConstructorUsedError; // null = overall budget
  BudgetPeriod get periodType => throw _privateConstructorUsedError;
  List<int> get alertThresholds => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BudgetCopyWith<Budget> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BudgetCopyWith<$Res> {
  factory $BudgetCopyWith(Budget value, $Res Function(Budget) then) =
      _$BudgetCopyWithImpl<$Res, Budget>;
  @useResult
  $Res call(
      {String id,
      double amount,
      DateTime periodStart,
      String? categoryId,
      BudgetPeriod periodType,
      List<int> alertThresholds});
}

/// @nodoc
class _$BudgetCopyWithImpl<$Res, $Val extends Budget>
    implements $BudgetCopyWith<$Res> {
  _$BudgetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? periodStart = null,
    Object? categoryId = freezed,
    Object? periodType = null,
    Object? alertThresholds = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      periodStart: null == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      periodType: null == periodType
          ? _value.periodType
          : periodType // ignore: cast_nullable_to_non_nullable
              as BudgetPeriod,
      alertThresholds: null == alertThresholds
          ? _value.alertThresholds
          : alertThresholds // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BudgetImplCopyWith<$Res> implements $BudgetCopyWith<$Res> {
  factory _$$BudgetImplCopyWith(
          _$BudgetImpl value, $Res Function(_$BudgetImpl) then) =
      __$$BudgetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      double amount,
      DateTime periodStart,
      String? categoryId,
      BudgetPeriod periodType,
      List<int> alertThresholds});
}

/// @nodoc
class __$$BudgetImplCopyWithImpl<$Res>
    extends _$BudgetCopyWithImpl<$Res, _$BudgetImpl>
    implements _$$BudgetImplCopyWith<$Res> {
  __$$BudgetImplCopyWithImpl(
      _$BudgetImpl _value, $Res Function(_$BudgetImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? periodStart = null,
    Object? categoryId = freezed,
    Object? periodType = null,
    Object? alertThresholds = null,
  }) {
    return _then(_$BudgetImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      periodStart: null == periodStart
          ? _value.periodStart
          : periodStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      periodType: null == periodType
          ? _value.periodType
          : periodType // ignore: cast_nullable_to_non_nullable
              as BudgetPeriod,
      alertThresholds: null == alertThresholds
          ? _value._alertThresholds
          : alertThresholds // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc

class _$BudgetImpl extends _Budget {
  const _$BudgetImpl(
      {required this.id,
      required this.amount,
      required this.periodStart,
      this.categoryId,
      this.periodType = BudgetPeriod.monthly,
      final List<int> alertThresholds = const [80, 100]})
      : _alertThresholds = alertThresholds,
        super._();

  @override
  final String id;
  @override
  final double amount;
  @override
  final DateTime periodStart;
  @override
  final String? categoryId;
// null = overall budget
  @override
  @JsonKey()
  final BudgetPeriod periodType;
  final List<int> _alertThresholds;
  @override
  @JsonKey()
  List<int> get alertThresholds {
    if (_alertThresholds is EqualUnmodifiableListView) return _alertThresholds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alertThresholds);
  }

  @override
  String toString() {
    return 'Budget(id: $id, amount: $amount, periodStart: $periodStart, categoryId: $categoryId, periodType: $periodType, alertThresholds: $alertThresholds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BudgetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.periodType, periodType) ||
                other.periodType == periodType) &&
            const DeepCollectionEquality()
                .equals(other._alertThresholds, _alertThresholds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      amount,
      periodStart,
      categoryId,
      periodType,
      const DeepCollectionEquality().hash(_alertThresholds));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BudgetImplCopyWith<_$BudgetImpl> get copyWith =>
      __$$BudgetImplCopyWithImpl<_$BudgetImpl>(this, _$identity);
}

abstract class _Budget extends Budget {
  const factory _Budget(
      {required final String id,
      required final double amount,
      required final DateTime periodStart,
      final String? categoryId,
      final BudgetPeriod periodType,
      final List<int> alertThresholds}) = _$BudgetImpl;
  const _Budget._() : super._();

  @override
  String get id;
  @override
  double get amount;
  @override
  DateTime get periodStart;
  @override
  String? get categoryId;
  @override // null = overall budget
  BudgetPeriod get periodType;
  @override
  List<int> get alertThresholds;
  @override
  @JsonKey(ignore: true)
  _$$BudgetImplCopyWith<_$BudgetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
