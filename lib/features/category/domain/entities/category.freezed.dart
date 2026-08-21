// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Category {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get iconKey => throw _privateConstructorUsedError;
  String get colorToken => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  double? get monthlyBudget => throw _privateConstructorUsedError;
  bool get isArchived => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CategoryCopyWith<Category> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryCopyWith<$Res> {
  factory $CategoryCopyWith(Category value, $Res Function(Category) then) =
      _$CategoryCopyWithImpl<$Res, Category>;
  @useResult
  $Res call(
      {String id,
      String name,
      String iconKey,
      String colorToken,
      String? parentId,
      bool isDefault,
      double? monthlyBudget,
      bool isArchived,
      int sortOrder});
}

/// @nodoc
class _$CategoryCopyWithImpl<$Res, $Val extends Category>
    implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? iconKey = null,
    Object? colorToken = null,
    Object? parentId = freezed,
    Object? isDefault = null,
    Object? monthlyBudget = freezed,
    Object? isArchived = null,
    Object? sortOrder = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      iconKey: null == iconKey
          ? _value.iconKey
          : iconKey // ignore: cast_nullable_to_non_nullable
              as String,
      colorToken: null == colorToken
          ? _value.colorToken
          : colorToken // ignore: cast_nullable_to_non_nullable
              as String,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      monthlyBudget: freezed == monthlyBudget
          ? _value.monthlyBudget
          : monthlyBudget // ignore: cast_nullable_to_non_nullable
              as double?,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategoryImplCopyWith<$Res>
    implements $CategoryCopyWith<$Res> {
  factory _$$CategoryImplCopyWith(
          _$CategoryImpl value, $Res Function(_$CategoryImpl) then) =
      __$$CategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String iconKey,
      String colorToken,
      String? parentId,
      bool isDefault,
      double? monthlyBudget,
      bool isArchived,
      int sortOrder});
}

/// @nodoc
class __$$CategoryImplCopyWithImpl<$Res>
    extends _$CategoryCopyWithImpl<$Res, _$CategoryImpl>
    implements _$$CategoryImplCopyWith<$Res> {
  __$$CategoryImplCopyWithImpl(
      _$CategoryImpl _value, $Res Function(_$CategoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? iconKey = null,
    Object? colorToken = null,
    Object? parentId = freezed,
    Object? isDefault = null,
    Object? monthlyBudget = freezed,
    Object? isArchived = null,
    Object? sortOrder = null,
  }) {
    return _then(_$CategoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      iconKey: null == iconKey
          ? _value.iconKey
          : iconKey // ignore: cast_nullable_to_non_nullable
              as String,
      colorToken: null == colorToken
          ? _value.colorToken
          : colorToken // ignore: cast_nullable_to_non_nullable
              as String,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      isDefault: null == isDefault
          ? _value.isDefault
          : isDefault // ignore: cast_nullable_to_non_nullable
              as bool,
      monthlyBudget: freezed == monthlyBudget
          ? _value.monthlyBudget
          : monthlyBudget // ignore: cast_nullable_to_non_nullable
              as double?,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$CategoryImpl extends _Category {
  const _$CategoryImpl(
      {required this.id,
      required this.name,
      required this.iconKey,
      required this.colorToken,
      this.parentId,
      this.isDefault = false,
      this.monthlyBudget,
      this.isArchived = false,
      this.sortOrder = 0})
      : super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final String iconKey;
  @override
  final String colorToken;
  @override
  final String? parentId;
  @override
  @JsonKey()
  final bool isDefault;
  @override
  final double? monthlyBudget;
  @override
  @JsonKey()
  final bool isArchived;
  @override
  @JsonKey()
  final int sortOrder;

  @override
  String toString() {
    return 'Category(id: $id, name: $name, iconKey: $iconKey, colorToken: $colorToken, parentId: $parentId, isDefault: $isDefault, monthlyBudget: $monthlyBudget, isArchived: $isArchived, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.iconKey, iconKey) || other.iconKey == iconKey) &&
            (identical(other.colorToken, colorToken) ||
                other.colorToken == colorToken) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.monthlyBudget, monthlyBudget) ||
                other.monthlyBudget == monthlyBudget) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, iconKey, colorToken,
      parentId, isDefault, monthlyBudget, isArchived, sortOrder);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryImplCopyWith<_$CategoryImpl> get copyWith =>
      __$$CategoryImplCopyWithImpl<_$CategoryImpl>(this, _$identity);
}

abstract class _Category extends Category {
  const factory _Category(
      {required final String id,
      required final String name,
      required final String iconKey,
      required final String colorToken,
      final String? parentId,
      final bool isDefault,
      final double? monthlyBudget,
      final bool isArchived,
      final int sortOrder}) = _$CategoryImpl;
  const _Category._() : super._();

  @override
  String get id;
  @override
  String get name;
  @override
  String get iconKey;
  @override
  String get colorToken;
  @override
  String? get parentId;
  @override
  bool get isDefault;
  @override
  double? get monthlyBudget;
  @override
  bool get isArchived;
  @override
  int get sortOrder;
  @override
  @JsonKey(ignore: true)
  _$$CategoryImplCopyWith<_$CategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
