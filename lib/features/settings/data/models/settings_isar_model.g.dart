// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_isar_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSettingsIsarModelCollection on Isar {
  IsarCollection<SettingsIsarModel> get settingsIsarModels => this.collection();
}

const SettingsIsarModelSchema = CollectionSchema(
  name: r'SettingsIsarModel',
  id: 8715387425811400240,
  properties: {
    r'currencyCode': PropertySchema(
      id: 0,
      name: r'currencyCode',
      type: IsarType.string,
    ),
    r'isBiometricLockEnabled': PropertySchema(
      id: 1,
      name: r'isBiometricLockEnabled',
      type: IsarType.bool,
    ),
    r'isFirstLaunch': PropertySchema(
      id: 2,
      name: r'isFirstLaunch',
      type: IsarType.bool,
    ),
    r'lastBackupAt': PropertySchema(
      id: 3,
      name: r'lastBackupAt',
      type: IsarType.dateTime,
    ),
    r'locale': PropertySchema(
      id: 4,
      name: r'locale',
      type: IsarType.string,
    ),
    r'themeModeIndex': PropertySchema(
      id: 5,
      name: r'themeModeIndex',
      type: IsarType.long,
    )
  },
  estimateSize: _settingsIsarModelEstimateSize,
  serialize: _settingsIsarModelSerialize,
  deserialize: _settingsIsarModelDeserialize,
  deserializeProp: _settingsIsarModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _settingsIsarModelGetId,
  getLinks: _settingsIsarModelGetLinks,
  attach: _settingsIsarModelAttach,
  version: '3.1.0+1',
);

int _settingsIsarModelEstimateSize(
  SettingsIsarModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.currencyCode.length * 3;
  bytesCount += 3 + object.locale.length * 3;
  return bytesCount;
}

void _settingsIsarModelSerialize(
  SettingsIsarModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.currencyCode);
  writer.writeBool(offsets[1], object.isBiometricLockEnabled);
  writer.writeBool(offsets[2], object.isFirstLaunch);
  writer.writeDateTime(offsets[3], object.lastBackupAt);
  writer.writeString(offsets[4], object.locale);
  writer.writeLong(offsets[5], object.themeModeIndex);
}

SettingsIsarModel _settingsIsarModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SettingsIsarModel();
  object.currencyCode = reader.readString(offsets[0]);
  object.id = id;
  object.isBiometricLockEnabled = reader.readBool(offsets[1]);
  object.isFirstLaunch = reader.readBool(offsets[2]);
  object.lastBackupAt = reader.readDateTimeOrNull(offsets[3]);
  object.locale = reader.readString(offsets[4]);
  object.themeModeIndex = reader.readLong(offsets[5]);
  return object;
}

P _settingsIsarModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _settingsIsarModelGetId(SettingsIsarModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _settingsIsarModelGetLinks(
    SettingsIsarModel object) {
  return [];
}

void _settingsIsarModelAttach(
    IsarCollection<dynamic> col, Id id, SettingsIsarModel object) {
  object.id = id;
}

extension SettingsIsarModelQueryWhereSort
    on QueryBuilder<SettingsIsarModel, SettingsIsarModel, QWhere> {
  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SettingsIsarModelQueryWhere
    on QueryBuilder<SettingsIsarModel, SettingsIsarModel, QWhereClause> {
  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SettingsIsarModelQueryFilter
    on QueryBuilder<SettingsIsarModel, SettingsIsarModel, QFilterCondition> {
  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      currencyCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currencyCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      currencyCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currencyCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      currencyCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currencyCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      currencyCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currencyCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      currencyCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currencyCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      currencyCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currencyCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      currencyCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currencyCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      currencyCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currencyCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      currencyCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currencyCode',
        value: '',
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      currencyCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currencyCode',
        value: '',
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      isBiometricLockEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isBiometricLockEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      isFirstLaunchEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFirstLaunch',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      lastBackupAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastBackupAt',
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      lastBackupAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastBackupAt',
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      lastBackupAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastBackupAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      lastBackupAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastBackupAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      lastBackupAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastBackupAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      lastBackupAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastBackupAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      localeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      localeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      localeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      localeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locale',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      localeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      localeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      localeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'locale',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      localeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'locale',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      localeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locale',
        value: '',
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      localeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'locale',
        value: '',
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      themeModeIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themeModeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      themeModeIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'themeModeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      themeModeIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'themeModeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterFilterCondition>
      themeModeIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'themeModeIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SettingsIsarModelQueryObject
    on QueryBuilder<SettingsIsarModel, SettingsIsarModel, QFilterCondition> {}

extension SettingsIsarModelQueryLinks
    on QueryBuilder<SettingsIsarModel, SettingsIsarModel, QFilterCondition> {}

extension SettingsIsarModelQuerySortBy
    on QueryBuilder<SettingsIsarModel, SettingsIsarModel, QSortBy> {
  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByCurrencyCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByCurrencyCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByIsBiometricLockEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricLockEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByIsBiometricLockEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricLockEnabled', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByIsFirstLaunch() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFirstLaunch', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByIsFirstLaunchDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFirstLaunch', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByLastBackupAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupAt', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByLastBackupAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupAt', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByThemeModeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeModeIndex', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      sortByThemeModeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeModeIndex', Sort.desc);
    });
  }
}

extension SettingsIsarModelQuerySortThenBy
    on QueryBuilder<SettingsIsarModel, SettingsIsarModel, QSortThenBy> {
  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByCurrencyCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByCurrencyCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currencyCode', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByIsBiometricLockEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricLockEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByIsBiometricLockEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBiometricLockEnabled', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByIsFirstLaunch() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFirstLaunch', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByIsFirstLaunchDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFirstLaunch', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByLastBackupAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupAt', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByLastBackupAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupAt', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByLocale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByLocaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locale', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByThemeModeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeModeIndex', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QAfterSortBy>
      thenByThemeModeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeModeIndex', Sort.desc);
    });
  }
}

extension SettingsIsarModelQueryWhereDistinct
    on QueryBuilder<SettingsIsarModel, SettingsIsarModel, QDistinct> {
  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QDistinct>
      distinctByCurrencyCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currencyCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QDistinct>
      distinctByIsBiometricLockEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBiometricLockEnabled');
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QDistinct>
      distinctByIsFirstLaunch() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFirstLaunch');
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QDistinct>
      distinctByLastBackupAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastBackupAt');
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QDistinct>
      distinctByLocale({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locale', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SettingsIsarModel, SettingsIsarModel, QDistinct>
      distinctByThemeModeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themeModeIndex');
    });
  }
}

extension SettingsIsarModelQueryProperty
    on QueryBuilder<SettingsIsarModel, SettingsIsarModel, QQueryProperty> {
  QueryBuilder<SettingsIsarModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SettingsIsarModel, String, QQueryOperations>
      currencyCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currencyCode');
    });
  }

  QueryBuilder<SettingsIsarModel, bool, QQueryOperations>
      isBiometricLockEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBiometricLockEnabled');
    });
  }

  QueryBuilder<SettingsIsarModel, bool, QQueryOperations>
      isFirstLaunchProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFirstLaunch');
    });
  }

  QueryBuilder<SettingsIsarModel, DateTime?, QQueryOperations>
      lastBackupAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastBackupAt');
    });
  }

  QueryBuilder<SettingsIsarModel, String, QQueryOperations> localeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locale');
    });
  }

  QueryBuilder<SettingsIsarModel, int, QQueryOperations>
      themeModeIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themeModeIndex');
    });
  }
}
