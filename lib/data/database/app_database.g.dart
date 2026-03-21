// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';


class $AircraftTypesTable extends AircraftTypes
    with TableInfo<$AircraftTypesTable, AircraftType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AircraftTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyMeta = const VerificationMeta('family');
  @override
  late final GeneratedColumn<String> family = GeneratedColumn<String>(
    'family',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longNameMeta = const VerificationMeta(
    'longName',
  );
  @override
  late final GeneratedColumn<String> longName = GeneratedColumn<String>(
    'long_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AircraftCategory, String>
  category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<AircraftCategory>($AircraftTypesTable.$convertercategory);
  @override
  late final GeneratedColumnWithTypeConverter<EngineType, String> engineType =
      GeneratedColumn<String>(
        'engine_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EngineType>($AircraftTypesTable.$converterengineType);
  static const VerificationMeta _mtowMeta = const VerificationMeta('mtow');
  @override
  late final GeneratedColumn<int> mtow = GeneratedColumn<int>(
    'mtow',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _engineCountMeta = const VerificationMeta(
    'engineCount',
  );
  @override
  late final GeneratedColumn<int> engineCount = GeneratedColumn<int>(
    'engine_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _multiPilotMeta = const VerificationMeta(
    'multiPilot',
  );
  @override
  late final GeneratedColumn<bool> multiPilot = GeneratedColumn<bool>(
    'multi_pilot',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("multi_pilot" IN (0, 1))',
    ),
  );
  static const VerificationMeta _complexMeta = const VerificationMeta(
    'complex',
  );
  @override
  late final GeneratedColumn<bool> complex = GeneratedColumn<bool>(
    'complex',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("complex" IN (0, 1))',
    ),
  );
  static const VerificationMeta _efisMeta = const VerificationMeta('efis');
  @override
  late final GeneratedColumn<bool> efis = GeneratedColumn<bool>(
    'efis',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("efis" IN (0, 1))',
    ),
  );
  static const VerificationMeta _highPerformanceMeta = const VerificationMeta(
    'highPerformance',
  );
  @override
  late final GeneratedColumn<bool> highPerformance = GeneratedColumn<bool>(
    'high_performance',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("high_performance" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    family,
    longName,
    manufacturer,
    category,
    engineType,
    mtow,
    engineCount,
    multiPilot,
    complex,
    efis,
    highPerformance,
    isLocked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'aircraft_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<AircraftType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('family')) {
      context.handle(
        _familyMeta,
        family.isAcceptableOrUnknown(data['family']!, _familyMeta),
      );
    } else if (isInserting) {
      context.missing(_familyMeta);
    }
    if (data.containsKey('long_name')) {
      context.handle(
        _longNameMeta,
        longName.isAcceptableOrUnknown(data['long_name']!, _longNameMeta),
      );
    } else if (isInserting) {
      context.missing(_longNameMeta);
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    }
    if (data.containsKey('mtow')) {
      context.handle(
        _mtowMeta,
        mtow.isAcceptableOrUnknown(data['mtow']!, _mtowMeta),
      );
    } else if (isInserting) {
      context.missing(_mtowMeta);
    }
    if (data.containsKey('engine_count')) {
      context.handle(
        _engineCountMeta,
        engineCount.isAcceptableOrUnknown(
          data['engine_count']!,
          _engineCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_engineCountMeta);
    }
    if (data.containsKey('multi_pilot')) {
      context.handle(
        _multiPilotMeta,
        multiPilot.isAcceptableOrUnknown(data['multi_pilot']!, _multiPilotMeta),
      );
    } else if (isInserting) {
      context.missing(_multiPilotMeta);
    }
    if (data.containsKey('complex')) {
      context.handle(
        _complexMeta,
        complex.isAcceptableOrUnknown(data['complex']!, _complexMeta),
      );
    } else if (isInserting) {
      context.missing(_complexMeta);
    }
    if (data.containsKey('efis')) {
      context.handle(
        _efisMeta,
        efis.isAcceptableOrUnknown(data['efis']!, _efisMeta),
      );
    } else if (isInserting) {
      context.missing(_efisMeta);
    }
    if (data.containsKey('high_performance')) {
      context.handle(
        _highPerformanceMeta,
        highPerformance.isAcceptableOrUnknown(
          data['high_performance']!,
          _highPerformanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_highPerformanceMeta);
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    } else if (isInserting) {
      context.missing(_isLockedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AircraftType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AircraftType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      family: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family'],
      )!,
      longName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}long_name'],
      )!,
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      ),
      category: $AircraftTypesTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      engineType: $AircraftTypesTable.$converterengineType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}engine_type'],
        )!,
      ),
      mtow: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mtow'],
      )!,
      engineCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}engine_count'],
      )!,
      multiPilot: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}multi_pilot'],
      )!,
      complex: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}complex'],
      )!,
      efis: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}efis'],
      )!,
      highPerformance: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}high_performance'],
      )!,
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
    );
  }

  @override
  $AircraftTypesTable createAlias(String alias) {
    return $AircraftTypesTable(attachedDatabase, alias);
  }

  static TypeConverter<AircraftCategory, String> $convertercategory =
      const AircraftCategoryConverter();
  static TypeConverter<EngineType, String> $converterengineType =
      const EngineTypeConverter();
}

class AircraftType extends DataClass implements Insertable<AircraftType> {
  /// Surrogate primary key.
  final int id;

  /// Short type code (e.g. A320).
  final String code;

  /// Family/group label.
  final String family;

  /// Human-readable long type name.
  final String longName;

  /// Optional manufacturer name.
  final String? manufacturer;

  /// Aircraft category enum stored via converter.
  final AircraftCategory category;

  /// Engine type enum stored via converter.
  final EngineType engineType;

  /// Maximum takeoff weight.
  final int mtow;

  /// Engine count.
  final int engineCount;

  /// Whether type requires multi-pilot operation.
  final bool multiPilot;

  /// Whether aircraft is complex.
  final bool complex;

  /// Whether cockpit is EFIS-equipped.
  final bool efis;

  /// Whether aircraft is high performance.
  final bool highPerformance;

  /// Lock flag preventing edits.
  final bool isLocked;
  const AircraftType({
    required this.id,
    required this.code,
    required this.family,
    required this.longName,
    this.manufacturer,
    required this.category,
    required this.engineType,
    required this.mtow,
    required this.engineCount,
    required this.multiPilot,
    required this.complex,
    required this.efis,
    required this.highPerformance,
    required this.isLocked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['family'] = Variable<String>(family);
    map['long_name'] = Variable<String>(longName);
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    {
      map['category'] = Variable<String>(
        $AircraftTypesTable.$convertercategory.toSql(category),
      );
    }
    {
      map['engine_type'] = Variable<String>(
        $AircraftTypesTable.$converterengineType.toSql(engineType),
      );
    }
    map['mtow'] = Variable<int>(mtow);
    map['engine_count'] = Variable<int>(engineCount);
    map['multi_pilot'] = Variable<bool>(multiPilot);
    map['complex'] = Variable<bool>(complex);
    map['efis'] = Variable<bool>(efis);
    map['high_performance'] = Variable<bool>(highPerformance);
    map['is_locked'] = Variable<bool>(isLocked);
    return map;
  }

  AircraftTypesCompanion toCompanion(bool nullToAbsent) {
    return AircraftTypesCompanion(
      id: Value(id),
      code: Value(code),
      family: Value(family),
      longName: Value(longName),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      category: Value(category),
      engineType: Value(engineType),
      mtow: Value(mtow),
      engineCount: Value(engineCount),
      multiPilot: Value(multiPilot),
      complex: Value(complex),
      efis: Value(efis),
      highPerformance: Value(highPerformance),
      isLocked: Value(isLocked),
    );
  }

  factory AircraftType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AircraftType(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      family: serializer.fromJson<String>(json['family']),
      longName: serializer.fromJson<String>(json['longName']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      category: serializer.fromJson<AircraftCategory>(json['category']),
      engineType: serializer.fromJson<EngineType>(json['engineType']),
      mtow: serializer.fromJson<int>(json['mtow']),
      engineCount: serializer.fromJson<int>(json['engineCount']),
      multiPilot: serializer.fromJson<bool>(json['multiPilot']),
      complex: serializer.fromJson<bool>(json['complex']),
      efis: serializer.fromJson<bool>(json['efis']),
      highPerformance: serializer.fromJson<bool>(json['highPerformance']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'family': serializer.toJson<String>(family),
      'longName': serializer.toJson<String>(longName),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'category': serializer.toJson<AircraftCategory>(category),
      'engineType': serializer.toJson<EngineType>(engineType),
      'mtow': serializer.toJson<int>(mtow),
      'engineCount': serializer.toJson<int>(engineCount),
      'multiPilot': serializer.toJson<bool>(multiPilot),
      'complex': serializer.toJson<bool>(complex),
      'efis': serializer.toJson<bool>(efis),
      'highPerformance': serializer.toJson<bool>(highPerformance),
      'isLocked': serializer.toJson<bool>(isLocked),
    };
  }

  AircraftType copyWith({
    int? id,
    String? code,
    String? family,
    String? longName,
    Value<String?> manufacturer = const Value.absent(),
    AircraftCategory? category,
    EngineType? engineType,
    int? mtow,
    int? engineCount,
    bool? multiPilot,
    bool? complex,
    bool? efis,
    bool? highPerformance,
    bool? isLocked,
  }) => AircraftType(
    id: id ?? this.id,
    code: code ?? this.code,
    family: family ?? this.family,
    longName: longName ?? this.longName,
    manufacturer: manufacturer.present ? manufacturer.value : this.manufacturer,
    category: category ?? this.category,
    engineType: engineType ?? this.engineType,
    mtow: mtow ?? this.mtow,
    engineCount: engineCount ?? this.engineCount,
    multiPilot: multiPilot ?? this.multiPilot,
    complex: complex ?? this.complex,
    efis: efis ?? this.efis,
    highPerformance: highPerformance ?? this.highPerformance,
    isLocked: isLocked ?? this.isLocked,
  );
  AircraftType copyWithCompanion(AircraftTypesCompanion data) {
    return AircraftType(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      family: data.family.present ? data.family.value : this.family,
      longName: data.longName.present ? data.longName.value : this.longName,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      category: data.category.present ? data.category.value : this.category,
      engineType: data.engineType.present
          ? data.engineType.value
          : this.engineType,
      mtow: data.mtow.present ? data.mtow.value : this.mtow,
      engineCount: data.engineCount.present
          ? data.engineCount.value
          : this.engineCount,
      multiPilot: data.multiPilot.present
          ? data.multiPilot.value
          : this.multiPilot,
      complex: data.complex.present ? data.complex.value : this.complex,
      efis: data.efis.present ? data.efis.value : this.efis,
      highPerformance: data.highPerformance.present
          ? data.highPerformance.value
          : this.highPerformance,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AircraftType(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('family: $family, ')
          ..write('longName: $longName, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('category: $category, ')
          ..write('engineType: $engineType, ')
          ..write('mtow: $mtow, ')
          ..write('engineCount: $engineCount, ')
          ..write('multiPilot: $multiPilot, ')
          ..write('complex: $complex, ')
          ..write('efis: $efis, ')
          ..write('highPerformance: $highPerformance, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    family,
    longName,
    manufacturer,
    category,
    engineType,
    mtow,
    engineCount,
    multiPilot,
    complex,
    efis,
    highPerformance,
    isLocked,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AircraftType &&
          other.id == this.id &&
          other.code == this.code &&
          other.family == this.family &&
          other.longName == this.longName &&
          other.manufacturer == this.manufacturer &&
          other.category == this.category &&
          other.engineType == this.engineType &&
          other.mtow == this.mtow &&
          other.engineCount == this.engineCount &&
          other.multiPilot == this.multiPilot &&
          other.complex == this.complex &&
          other.efis == this.efis &&
          other.highPerformance == this.highPerformance &&
          other.isLocked == this.isLocked);
}

class AircraftTypesCompanion extends UpdateCompanion<AircraftType> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> family;
  final Value<String> longName;
  final Value<String?> manufacturer;
  final Value<AircraftCategory> category;
  final Value<EngineType> engineType;
  final Value<int> mtow;
  final Value<int> engineCount;
  final Value<bool> multiPilot;
  final Value<bool> complex;
  final Value<bool> efis;
  final Value<bool> highPerformance;
  final Value<bool> isLocked;
  const AircraftTypesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.family = const Value.absent(),
    this.longName = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.category = const Value.absent(),
    this.engineType = const Value.absent(),
    this.mtow = const Value.absent(),
    this.engineCount = const Value.absent(),
    this.multiPilot = const Value.absent(),
    this.complex = const Value.absent(),
    this.efis = const Value.absent(),
    this.highPerformance = const Value.absent(),
    this.isLocked = const Value.absent(),
  });
  AircraftTypesCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String family,
    required String longName,
    this.manufacturer = const Value.absent(),
    required AircraftCategory category,
    required EngineType engineType,
    required int mtow,
    required int engineCount,
    required bool multiPilot,
    required bool complex,
    required bool efis,
    required bool highPerformance,
    required bool isLocked,
  }) : code = Value(code),
       family = Value(family),
       longName = Value(longName),
       category = Value(category),
       engineType = Value(engineType),
       mtow = Value(mtow),
       engineCount = Value(engineCount),
       multiPilot = Value(multiPilot),
       complex = Value(complex),
       efis = Value(efis),
       highPerformance = Value(highPerformance),
       isLocked = Value(isLocked);
  static Insertable<AircraftType> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? family,
    Expression<String>? longName,
    Expression<String>? manufacturer,
    Expression<String>? category,
    Expression<String>? engineType,
    Expression<int>? mtow,
    Expression<int>? engineCount,
    Expression<bool>? multiPilot,
    Expression<bool>? complex,
    Expression<bool>? efis,
    Expression<bool>? highPerformance,
    Expression<bool>? isLocked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (family != null) 'family': family,
      if (longName != null) 'long_name': longName,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (category != null) 'category': category,
      if (engineType != null) 'engine_type': engineType,
      if (mtow != null) 'mtow': mtow,
      if (engineCount != null) 'engine_count': engineCount,
      if (multiPilot != null) 'multi_pilot': multiPilot,
      if (complex != null) 'complex': complex,
      if (efis != null) 'efis': efis,
      if (highPerformance != null) 'high_performance': highPerformance,
      if (isLocked != null) 'is_locked': isLocked,
    });
  }

  AircraftTypesCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<String>? family,
    Value<String>? longName,
    Value<String?>? manufacturer,
    Value<AircraftCategory>? category,
    Value<EngineType>? engineType,
    Value<int>? mtow,
    Value<int>? engineCount,
    Value<bool>? multiPilot,
    Value<bool>? complex,
    Value<bool>? efis,
    Value<bool>? highPerformance,
    Value<bool>? isLocked,
  }) {
    return AircraftTypesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      family: family ?? this.family,
      longName: longName ?? this.longName,
      manufacturer: manufacturer ?? this.manufacturer,
      category: category ?? this.category,
      engineType: engineType ?? this.engineType,
      mtow: mtow ?? this.mtow,
      engineCount: engineCount ?? this.engineCount,
      multiPilot: multiPilot ?? this.multiPilot,
      complex: complex ?? this.complex,
      efis: efis ?? this.efis,
      highPerformance: highPerformance ?? this.highPerformance,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (family.present) {
      map['family'] = Variable<String>(family.value);
    }
    if (longName.present) {
      map['long_name'] = Variable<String>(longName.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $AircraftTypesTable.$convertercategory.toSql(category.value),
      );
    }
    if (engineType.present) {
      map['engine_type'] = Variable<String>(
        $AircraftTypesTable.$converterengineType.toSql(engineType.value),
      );
    }
    if (mtow.present) {
      map['mtow'] = Variable<int>(mtow.value);
    }
    if (engineCount.present) {
      map['engine_count'] = Variable<int>(engineCount.value);
    }
    if (multiPilot.present) {
      map['multi_pilot'] = Variable<bool>(multiPilot.value);
    }
    if (complex.present) {
      map['complex'] = Variable<bool>(complex.value);
    }
    if (efis.present) {
      map['efis'] = Variable<bool>(efis.value);
    }
    if (highPerformance.present) {
      map['high_performance'] = Variable<bool>(highPerformance.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AircraftTypesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('family: $family, ')
          ..write('longName: $longName, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('category: $category, ')
          ..write('engineType: $engineType, ')
          ..write('mtow: $mtow, ')
          ..write('engineCount: $engineCount, ')
          ..write('multiPilot: $multiPilot, ')
          ..write('complex: $complex, ')
          ..write('efis: $efis, ')
          ..write('highPerformance: $highPerformance, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }
}

class $AircraftsTable extends Aircrafts
    with TableInfo<$AircraftsTable, Aircraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AircraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _aircraftTypeIdMeta = const VerificationMeta(
    'aircraftTypeId',
  );
  @override
  late final GeneratedColumn<int> aircraftTypeId = GeneratedColumn<int>(
    'aircraft_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES aircraft_types (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _registrationMeta = const VerificationMeta(
    'registration',
  );
  @override
  late final GeneratedColumn<String> registration = GeneratedColumn<String>(
    'registration',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mtowMeta = const VerificationMeta('mtow');
  @override
  late final GeneratedColumn<int> mtow = GeneratedColumn<int>(
    'mtow',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSimulatorMeta = const VerificationMeta(
    'isSimulator',
  );
  @override
  late final GeneratedColumn<bool> isSimulator = GeneratedColumn<bool>(
    'is_simulator',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_simulator" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    aircraftTypeId,
    registration,
    mtow,
    isSimulator,
    isFavorite,
    isLocked,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'aircrafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Aircraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('aircraft_type_id')) {
      context.handle(
        _aircraftTypeIdMeta,
        aircraftTypeId.isAcceptableOrUnknown(
          data['aircraft_type_id']!,
          _aircraftTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aircraftTypeIdMeta);
    }
    if (data.containsKey('registration')) {
      context.handle(
        _registrationMeta,
        registration.isAcceptableOrUnknown(
          data['registration']!,
          _registrationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_registrationMeta);
    }
    if (data.containsKey('mtow')) {
      context.handle(
        _mtowMeta,
        mtow.isAcceptableOrUnknown(data['mtow']!, _mtowMeta),
      );
    }
    if (data.containsKey('is_simulator')) {
      context.handle(
        _isSimulatorMeta,
        isSimulator.isAcceptableOrUnknown(
          data['is_simulator']!,
          _isSimulatorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isSimulatorMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    } else if (isInserting) {
      context.missing(_isFavoriteMeta);
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    } else if (isInserting) {
      context.missing(_isLockedMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Aircraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Aircraft(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      aircraftTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}aircraft_type_id'],
      )!,
      registration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registration'],
      )!,
      mtow: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mtow'],
      ),
      isSimulator: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_simulator'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $AircraftsTable createAlias(String alias) {
    return $AircraftsTable(attachedDatabase, alias);
  }
}

class Aircraft extends DataClass implements Insertable<Aircraft> {
  /// Surrogate primary key.
  final int id;

  /// Linked aircraft type id.
  final int aircraftTypeId;

  /// Registration/tail number.
  final String registration;

  /// Optional per-aircraft MTOW override.
  final int? mtow;

  /// Marks this row as simulator device/entry.
  final bool isSimulator;

  /// Favorite/pinned flag.
  final bool isFavorite;

  /// Lock flag preventing edits.
  final bool isLocked;

  /// Optional notes.
  final String? notes;
  const Aircraft({
    required this.id,
    required this.aircraftTypeId,
    required this.registration,
    this.mtow,
    required this.isSimulator,
    required this.isFavorite,
    required this.isLocked,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['aircraft_type_id'] = Variable<int>(aircraftTypeId);
    map['registration'] = Variable<String>(registration);
    if (!nullToAbsent || mtow != null) {
      map['mtow'] = Variable<int>(mtow);
    }
    map['is_simulator'] = Variable<bool>(isSimulator);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_locked'] = Variable<bool>(isLocked);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  AircraftsCompanion toCompanion(bool nullToAbsent) {
    return AircraftsCompanion(
      id: Value(id),
      aircraftTypeId: Value(aircraftTypeId),
      registration: Value(registration),
      mtow: mtow == null && nullToAbsent ? const Value.absent() : Value(mtow),
      isSimulator: Value(isSimulator),
      isFavorite: Value(isFavorite),
      isLocked: Value(isLocked),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Aircraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Aircraft(
      id: serializer.fromJson<int>(json['id']),
      aircraftTypeId: serializer.fromJson<int>(json['aircraftTypeId']),
      registration: serializer.fromJson<String>(json['registration']),
      mtow: serializer.fromJson<int?>(json['mtow']),
      isSimulator: serializer.fromJson<bool>(json['isSimulator']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'aircraftTypeId': serializer.toJson<int>(aircraftTypeId),
      'registration': serializer.toJson<String>(registration),
      'mtow': serializer.toJson<int?>(mtow),
      'isSimulator': serializer.toJson<bool>(isSimulator),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isLocked': serializer.toJson<bool>(isLocked),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Aircraft copyWith({
    int? id,
    int? aircraftTypeId,
    String? registration,
    Value<int?> mtow = const Value.absent(),
    bool? isSimulator,
    bool? isFavorite,
    bool? isLocked,
    Value<String?> notes = const Value.absent(),
  }) => Aircraft(
    id: id ?? this.id,
    aircraftTypeId: aircraftTypeId ?? this.aircraftTypeId,
    registration: registration ?? this.registration,
    mtow: mtow.present ? mtow.value : this.mtow,
    isSimulator: isSimulator ?? this.isSimulator,
    isFavorite: isFavorite ?? this.isFavorite,
    isLocked: isLocked ?? this.isLocked,
    notes: notes.present ? notes.value : this.notes,
  );
  Aircraft copyWithCompanion(AircraftsCompanion data) {
    return Aircraft(
      id: data.id.present ? data.id.value : this.id,
      aircraftTypeId: data.aircraftTypeId.present
          ? data.aircraftTypeId.value
          : this.aircraftTypeId,
      registration: data.registration.present
          ? data.registration.value
          : this.registration,
      mtow: data.mtow.present ? data.mtow.value : this.mtow,
      isSimulator: data.isSimulator.present
          ? data.isSimulator.value
          : this.isSimulator,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Aircraft(')
          ..write('id: $id, ')
          ..write('aircraftTypeId: $aircraftTypeId, ')
          ..write('registration: $registration, ')
          ..write('mtow: $mtow, ')
          ..write('isSimulator: $isSimulator, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isLocked: $isLocked, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    aircraftTypeId,
    registration,
    mtow,
    isSimulator,
    isFavorite,
    isLocked,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Aircraft &&
          other.id == this.id &&
          other.aircraftTypeId == this.aircraftTypeId &&
          other.registration == this.registration &&
          other.mtow == this.mtow &&
          other.isSimulator == this.isSimulator &&
          other.isFavorite == this.isFavorite &&
          other.isLocked == this.isLocked &&
          other.notes == this.notes);
}

class AircraftsCompanion extends UpdateCompanion<Aircraft> {
  final Value<int> id;
  final Value<int> aircraftTypeId;
  final Value<String> registration;
  final Value<int?> mtow;
  final Value<bool> isSimulator;
  final Value<bool> isFavorite;
  final Value<bool> isLocked;
  final Value<String?> notes;
  const AircraftsCompanion({
    this.id = const Value.absent(),
    this.aircraftTypeId = const Value.absent(),
    this.registration = const Value.absent(),
    this.mtow = const Value.absent(),
    this.isSimulator = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.notes = const Value.absent(),
  });
  AircraftsCompanion.insert({
    this.id = const Value.absent(),
    required int aircraftTypeId,
    required String registration,
    this.mtow = const Value.absent(),
    required bool isSimulator,
    required bool isFavorite,
    required bool isLocked,
    this.notes = const Value.absent(),
  }) : aircraftTypeId = Value(aircraftTypeId),
       registration = Value(registration),
       isSimulator = Value(isSimulator),
       isFavorite = Value(isFavorite),
       isLocked = Value(isLocked);
  static Insertable<Aircraft> custom({
    Expression<int>? id,
    Expression<int>? aircraftTypeId,
    Expression<String>? registration,
    Expression<int>? mtow,
    Expression<bool>? isSimulator,
    Expression<bool>? isFavorite,
    Expression<bool>? isLocked,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (aircraftTypeId != null) 'aircraft_type_id': aircraftTypeId,
      if (registration != null) 'registration': registration,
      if (mtow != null) 'mtow': mtow,
      if (isSimulator != null) 'is_simulator': isSimulator,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isLocked != null) 'is_locked': isLocked,
      if (notes != null) 'notes': notes,
    });
  }

  AircraftsCompanion copyWith({
    Value<int>? id,
    Value<int>? aircraftTypeId,
    Value<String>? registration,
    Value<int?>? mtow,
    Value<bool>? isSimulator,
    Value<bool>? isFavorite,
    Value<bool>? isLocked,
    Value<String?>? notes,
  }) {
    return AircraftsCompanion(
      id: id ?? this.id,
      aircraftTypeId: aircraftTypeId ?? this.aircraftTypeId,
      registration: registration ?? this.registration,
      mtow: mtow ?? this.mtow,
      isSimulator: isSimulator ?? this.isSimulator,
      isFavorite: isFavorite ?? this.isFavorite,
      isLocked: isLocked ?? this.isLocked,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (aircraftTypeId.present) {
      map['aircraft_type_id'] = Variable<int>(aircraftTypeId.value);
    }
    if (registration.present) {
      map['registration'] = Variable<String>(registration.value);
    }
    if (mtow.present) {
      map['mtow'] = Variable<int>(mtow.value);
    }
    if (isSimulator.present) {
      map['is_simulator'] = Variable<bool>(isSimulator.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AircraftsCompanion(')
          ..write('id: $id, ')
          ..write('aircraftTypeId: $aircraftTypeId, ')
          ..write('registration: $registration, ')
          ..write('mtow: $mtow, ')
          ..write('isSimulator: $isSimulator, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isLocked: $isLocked, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $AirportsTable extends Airports with TableInfo<$AirportsTable, Airport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AirportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _icaoMeta = const VerificationMeta('icao');
  @override
  late final GeneratedColumn<String> icao = GeneratedColumn<String>(
    'icao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iataMeta = const VerificationMeta('iata');
  @override
  late final GeneratedColumn<String> iata = GeneratedColumn<String>(
    'iata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    icao,
    iata,
    name,
    city,
    country,
    latitude,
    longitude,
    isFavorite,
    isLocked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'airports';
  @override
  VerificationContext validateIntegrity(
    Insertable<Airport> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('icao')) {
      context.handle(
        _icaoMeta,
        icao.isAcceptableOrUnknown(data['icao']!, _icaoMeta),
      );
    } else if (isInserting) {
      context.missing(_icaoMeta);
    }
    if (data.containsKey('iata')) {
      context.handle(
        _iataMeta,
        iata.isAcceptableOrUnknown(data['iata']!, _iataMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    } else if (isInserting) {
      context.missing(_isFavoriteMeta);
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    } else if (isInserting) {
      context.missing(_isLockedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Airport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Airport(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      icao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icao'],
      )!,
      iata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}iata'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
    );
  }

  @override
  $AirportsTable createAlias(String alias) {
    return $AirportsTable(attachedDatabase, alias);
  }
}

class Airport extends DataClass implements Insertable<Airport> {
  /// Surrogate primary key.
  final int id;

  /// ICAO airport code.
  final String icao;

  /// Optional IATA airport code.
  final String? iata;

  /// Optional airport display name.
  final String? name;

  /// Optional city.
  final String? city;

  /// Optional country.
  final String? country;

  /// Latitude in decimal degrees.
  final double latitude;

  /// Longitude in decimal degrees.
  final double longitude;

  /// Whether airport is pinned by user.
  final bool isFavorite;

  /// Whether row is protected from edits.
  final bool isLocked;
  const Airport({
    required this.id,
    required this.icao,
    this.iata,
    this.name,
    this.city,
    this.country,
    required this.latitude,
    required this.longitude,
    required this.isFavorite,
    required this.isLocked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['icao'] = Variable<String>(icao);
    if (!nullToAbsent || iata != null) {
      map['iata'] = Variable<String>(iata);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_locked'] = Variable<bool>(isLocked);
    return map;
  }

  AirportsCompanion toCompanion(bool nullToAbsent) {
    return AirportsCompanion(
      id: Value(id),
      icao: Value(icao),
      iata: iata == null && nullToAbsent ? const Value.absent() : Value(iata),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      latitude: Value(latitude),
      longitude: Value(longitude),
      isFavorite: Value(isFavorite),
      isLocked: Value(isLocked),
    );
  }

  factory Airport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Airport(
      id: serializer.fromJson<int>(json['id']),
      icao: serializer.fromJson<String>(json['icao']),
      iata: serializer.fromJson<String?>(json['iata']),
      name: serializer.fromJson<String?>(json['name']),
      city: serializer.fromJson<String?>(json['city']),
      country: serializer.fromJson<String?>(json['country']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'icao': serializer.toJson<String>(icao),
      'iata': serializer.toJson<String?>(iata),
      'name': serializer.toJson<String?>(name),
      'city': serializer.toJson<String?>(city),
      'country': serializer.toJson<String?>(country),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isLocked': serializer.toJson<bool>(isLocked),
    };
  }

  Airport copyWith({
    int? id,
    String? icao,
    Value<String?> iata = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<String?> city = const Value.absent(),
    Value<String?> country = const Value.absent(),
    double? latitude,
    double? longitude,
    bool? isFavorite,
    bool? isLocked,
  }) => Airport(
    id: id ?? this.id,
    icao: icao ?? this.icao,
    iata: iata.present ? iata.value : this.iata,
    name: name.present ? name.value : this.name,
    city: city.present ? city.value : this.city,
    country: country.present ? country.value : this.country,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    isFavorite: isFavorite ?? this.isFavorite,
    isLocked: isLocked ?? this.isLocked,
  );
  Airport copyWithCompanion(AirportsCompanion data) {
    return Airport(
      id: data.id.present ? data.id.value : this.id,
      icao: data.icao.present ? data.icao.value : this.icao,
      iata: data.iata.present ? data.iata.value : this.iata,
      name: data.name.present ? data.name.value : this.name,
      city: data.city.present ? data.city.value : this.city,
      country: data.country.present ? data.country.value : this.country,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Airport(')
          ..write('id: $id, ')
          ..write('icao: $icao, ')
          ..write('iata: $iata, ')
          ..write('name: $name, ')
          ..write('city: $city, ')
          ..write('country: $country, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    icao,
    iata,
    name,
    city,
    country,
    latitude,
    longitude,
    isFavorite,
    isLocked,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Airport &&
          other.id == this.id &&
          other.icao == this.icao &&
          other.iata == this.iata &&
          other.name == this.name &&
          other.city == this.city &&
          other.country == this.country &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.isFavorite == this.isFavorite &&
          other.isLocked == this.isLocked);
}

class AirportsCompanion extends UpdateCompanion<Airport> {
  final Value<int> id;
  final Value<String> icao;
  final Value<String?> iata;
  final Value<String?> name;
  final Value<String?> city;
  final Value<String?> country;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<bool> isFavorite;
  final Value<bool> isLocked;
  const AirportsCompanion({
    this.id = const Value.absent(),
    this.icao = const Value.absent(),
    this.iata = const Value.absent(),
    this.name = const Value.absent(),
    this.city = const Value.absent(),
    this.country = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isLocked = const Value.absent(),
  });
  AirportsCompanion.insert({
    this.id = const Value.absent(),
    required String icao,
    this.iata = const Value.absent(),
    this.name = const Value.absent(),
    this.city = const Value.absent(),
    this.country = const Value.absent(),
    required double latitude,
    required double longitude,
    required bool isFavorite,
    required bool isLocked,
  }) : icao = Value(icao),
       latitude = Value(latitude),
       longitude = Value(longitude),
       isFavorite = Value(isFavorite),
       isLocked = Value(isLocked);
  static Insertable<Airport> custom({
    Expression<int>? id,
    Expression<String>? icao,
    Expression<String>? iata,
    Expression<String>? name,
    Expression<String>? city,
    Expression<String>? country,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<bool>? isFavorite,
    Expression<bool>? isLocked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (icao != null) 'icao': icao,
      if (iata != null) 'iata': iata,
      if (name != null) 'name': name,
      if (city != null) 'city': city,
      if (country != null) 'country': country,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isLocked != null) 'is_locked': isLocked,
    });
  }

  AirportsCompanion copyWith({
    Value<int>? id,
    Value<String>? icao,
    Value<String?>? iata,
    Value<String?>? name,
    Value<String?>? city,
    Value<String?>? country,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<bool>? isFavorite,
    Value<bool>? isLocked,
  }) {
    return AirportsCompanion(
      id: id ?? this.id,
      icao: icao ?? this.icao,
      iata: iata ?? this.iata,
      name: name ?? this.name,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFavorite: isFavorite ?? this.isFavorite,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (icao.present) {
      map['icao'] = Variable<String>(icao.value);
    }
    if (iata.present) {
      map['iata'] = Variable<String>(iata.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AirportsCompanion(')
          ..write('id: $id, ')
          ..write('icao: $icao, ')
          ..write('iata: $iata, ')
          ..write('name: $name, ')
          ..write('city: $city, ')
          ..write('country: $country, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }
}

class $TimeLinesTable extends TimeLines
    with TableInfo<$TimeLinesTable, TimeLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimeLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _eventDateTimeMeta = const VerificationMeta(
    'eventDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> eventDateTime =
      GeneratedColumn<DateTime>(
        'event_date_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [id, eventDateTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'time_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimeLine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_date_time')) {
      context.handle(
        _eventDateTimeMeta,
        eventDateTime.isAcceptableOrUnknown(
          data['event_date_time']!,
          _eventDateTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventDateTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimeLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimeLine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eventDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}event_date_time'],
      )!,
    );
  }

  @override
  $TimeLinesTable createAlias(String alias) {
    return $TimeLinesTable(attachedDatabase, alias);
  }
}

class TimeLine extends DataClass implements Insertable<TimeLine> {
  /// Primary key for a timeline row.
  final int id;

  /// UTC date-time value used by related records.
  final DateTime eventDateTime;
  const TimeLine({required this.id, required this.eventDateTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_date_time'] = Variable<DateTime>(eventDateTime);
    return map;
  }

  TimeLinesCompanion toCompanion(bool nullToAbsent) {
    return TimeLinesCompanion(
      id: Value(id),
      eventDateTime: Value(eventDateTime),
    );
  }

  factory TimeLine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimeLine(
      id: serializer.fromJson<int>(json['id']),
      eventDateTime: serializer.fromJson<DateTime>(json['eventDateTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventDateTime': serializer.toJson<DateTime>(eventDateTime),
    };
  }

  TimeLine copyWith({int? id, DateTime? eventDateTime}) => TimeLine(
    id: id ?? this.id,
    eventDateTime: eventDateTime ?? this.eventDateTime,
  );
  TimeLine copyWithCompanion(TimeLinesCompanion data) {
    return TimeLine(
      id: data.id.present ? data.id.value : this.id,
      eventDateTime: data.eventDateTime.present
          ? data.eventDateTime.value
          : this.eventDateTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimeLine(')
          ..write('id: $id, ')
          ..write('eventDateTime: $eventDateTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, eventDateTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeLine &&
          other.id == this.id &&
          other.eventDateTime == this.eventDateTime);
}

class TimeLinesCompanion extends UpdateCompanion<TimeLine> {
  final Value<int> id;
  final Value<DateTime> eventDateTime;
  const TimeLinesCompanion({
    this.id = const Value.absent(),
    this.eventDateTime = const Value.absent(),
  });
  TimeLinesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime eventDateTime,
  }) : eventDateTime = Value(eventDateTime);
  static Insertable<TimeLine> custom({
    Expression<int>? id,
    Expression<DateTime>? eventDateTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventDateTime != null) 'event_date_time': eventDateTime,
    });
  }

  TimeLinesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? eventDateTime,
  }) {
    return TimeLinesCompanion(
      id: id ?? this.id,
      eventDateTime: eventDateTime ?? this.eventDateTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventDateTime.present) {
      map['event_date_time'] = Variable<DateTime>(eventDateTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimeLinesCompanion(')
          ..write('id: $id, ')
          ..write('eventDateTime: $eventDateTime')
          ..write(')'))
        .toString();
  }
}

class $FlightsTable extends Flights with TableInfo<$FlightsTable, Flight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _aircraftIdMeta = const VerificationMeta(
    'aircraftId',
  );
  @override
  late final GeneratedColumn<int> aircraftId = GeneratedColumn<int>(
    'aircraft_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES aircrafts (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _departureAirportIdMeta =
      const VerificationMeta('departureAirportId');
  @override
  late final GeneratedColumn<int> departureAirportId = GeneratedColumn<int>(
    'departure_airport_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES airports (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _arrivalAirportIdMeta = const VerificationMeta(
    'arrivalAirportId',
  );
  @override
  late final GeneratedColumn<int> arrivalAirportId = GeneratedColumn<int>(
    'arrival_airport_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES airports (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _departureDateTimeIdMeta =
      const VerificationMeta('departureDateTimeId');
  @override
  late final GeneratedColumn<int> departureDateTimeId = GeneratedColumn<int>(
    'departure_date_time_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES time_lines (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _takeOffDateTimeMeta = const VerificationMeta(
    'takeOffDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> takeOffDateTime =
      GeneratedColumn<DateTime>(
        'take_off_date_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _landingDateTimeMeta = const VerificationMeta(
    'landingDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> landingDateTime =
      GeneratedColumn<DateTime>(
        'landing_date_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _arrivalDateTimeMeta = const VerificationMeta(
    'arrivalDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> arrivalDateTime =
      GeneratedColumn<DateTime>(
        'arrival_date_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _timePICMinutesMeta = const VerificationMeta(
    'timePICMinutes',
  );
  @override
  late final GeneratedColumn<int> timePICMinutes = GeneratedColumn<int>(
    'time_p_i_c_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timePICUSMinutesMeta = const VerificationMeta(
    'timePICUSMinutes',
  );
  @override
  late final GeneratedColumn<int> timePICUSMinutes = GeneratedColumn<int>(
    'time_p_i_c_u_s_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeSICMinutesMeta = const VerificationMeta(
    'timeSICMinutes',
  );
  @override
  late final GeneratedColumn<int> timeSICMinutes = GeneratedColumn<int>(
    'time_s_i_c_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeDualMinutesMeta = const VerificationMeta(
    'timeDualMinutes',
  );
  @override
  late final GeneratedColumn<int> timeDualMinutes = GeneratedColumn<int>(
    'time_dual_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeInstructorMinutesMeta =
      const VerificationMeta('timeInstructorMinutes');
  @override
  late final GeneratedColumn<int> timeInstructorMinutes = GeneratedColumn<int>(
    'time_instructor_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeIFRMinutesMeta = const VerificationMeta(
    'timeIFRMinutes',
  );
  @override
  late final GeneratedColumn<int> timeIFRMinutes = GeneratedColumn<int>(
    'time_i_f_r_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeInstrumentMinutesMeta =
      const VerificationMeta('timeInstrumentMinutes');
  @override
  late final GeneratedColumn<int> timeInstrumentMinutes = GeneratedColumn<int>(
    'time_instrument_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeSimulatedInstrumentMinutesMeta =
      const VerificationMeta('timeSimulatedInstrumentMinutes');
  @override
  late final GeneratedColumn<int> timeSimulatedInstrumentMinutes =
      GeneratedColumn<int>(
        'time_simulated_instrument_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _timeNightMinutesMeta = const VerificationMeta(
    'timeNightMinutes',
  );
  @override
  late final GeneratedColumn<int> timeNightMinutes = GeneratedColumn<int>(
    'time_night_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeCrossCountryMinutesMeta =
      const VerificationMeta('timeCrossCountryMinutes');
  @override
  late final GeneratedColumn<int> timeCrossCountryMinutes =
      GeneratedColumn<int>(
        'time_cross_country_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _timeCustom1MinutesMeta =
      const VerificationMeta('timeCustom1Minutes');
  @override
  late final GeneratedColumn<int> timeCustom1Minutes = GeneratedColumn<int>(
    'time_custom1_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeCustom2MinutesMeta =
      const VerificationMeta('timeCustom2Minutes');
  @override
  late final GeneratedColumn<int> timeCustom2Minutes = GeneratedColumn<int>(
    'time_custom2_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeCustom3MinutesMeta =
      const VerificationMeta('timeCustom3Minutes');
  @override
  late final GeneratedColumn<int> timeCustom3Minutes = GeneratedColumn<int>(
    'time_custom3_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeCustom4MinutesMeta =
      const VerificationMeta('timeCustom4Minutes');
  @override
  late final GeneratedColumn<int> timeCustom4Minutes = GeneratedColumn<int>(
    'time_custom4_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeFlightMinutesMeta = const VerificationMeta(
    'timeFlightMinutes',
  );
  @override
  late final GeneratedColumn<int> timeFlightMinutes = GeneratedColumn<int>(
    'time_flight_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeBlockMinutesMeta = const VerificationMeta(
    'timeBlockMinutes',
  );
  @override
  late final GeneratedColumn<int> timeBlockMinutes = GeneratedColumn<int>(
    'time_block_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeTotalBlockMinutesMeta =
      const VerificationMeta('timeTotalBlockMinutes');
  @override
  late final GeneratedColumn<int> timeTotalBlockMinutes = GeneratedColumn<int>(
    'time_total_block_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _distanceNMMeta = const VerificationMeta(
    'distanceNM',
  );
  @override
  late final GeneratedColumn<int> distanceNM = GeneratedColumn<int>(
    'distance_n_m',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ifrApproachesMeta = const VerificationMeta(
    'ifrApproaches',
  );
  @override
  late final GeneratedColumn<int> ifrApproaches = GeneratedColumn<int>(
    'ifr_approaches',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takeOffsDaysMeta = const VerificationMeta(
    'takeOffsDays',
  );
  @override
  late final GeneratedColumn<int> takeOffsDays = GeneratedColumn<int>(
    'take_offs_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takeOffsNightMeta = const VerificationMeta(
    'takeOffsNight',
  );
  @override
  late final GeneratedColumn<int> takeOffsNight = GeneratedColumn<int>(
    'take_offs_night',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _landingsDayMeta = const VerificationMeta(
    'landingsDay',
  );
  @override
  late final GeneratedColumn<int> landingsDay = GeneratedColumn<int>(
    'landings_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _landingsNightMeta = const VerificationMeta(
    'landingsNight',
  );
  @override
  late final GeneratedColumn<int> landingsNight = GeneratedColumn<int>(
    'landings_night',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PilotFunction, String>
  pilotFunction = GeneratedColumn<String>(
    'pilot_function',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PF'),
  ).withConverter<PilotFunction>($FlightsTable.$converterpilotFunction);
  static const VerificationMeta _approachTypeMeta = const VerificationMeta(
    'approachType',
  );
  @override
  late final GeneratedColumn<String> approachType = GeneratedColumn<String>(
    'approach_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
  );
  static const VerificationMeta _signatureImageMeta = const VerificationMeta(
    'signatureImage',
  );
  @override
  late final GeneratedColumn<Uint8List> signatureImage =
      GeneratedColumn<Uint8List>(
        'signature_image',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _endorsementDataMeta = const VerificationMeta(
    'endorsementData',
  );
  @override
  late final GeneratedColumn<String> endorsementData = GeneratedColumn<String>(
    'endorsement_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endorsementHashMeta = const VerificationMeta(
    'endorsementHash',
  );
  @override
  late final GeneratedColumn<String> endorsementHash = GeneratedColumn<String>(
    'endorsement_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    aircraftId,
    departureAirportId,
    arrivalAirportId,
    departureDateTimeId,
    takeOffDateTime,
    landingDateTime,
    arrivalDateTime,
    timePICMinutes,
    timePICUSMinutes,
    timeSICMinutes,
    timeDualMinutes,
    timeInstructorMinutes,
    timeIFRMinutes,
    timeInstrumentMinutes,
    timeSimulatedInstrumentMinutes,
    timeNightMinutes,
    timeCrossCountryMinutes,
    timeCustom1Minutes,
    timeCustom2Minutes,
    timeCustom3Minutes,
    timeCustom4Minutes,
    timeFlightMinutes,
    timeBlockMinutes,
    timeTotalBlockMinutes,
    distanceNM,
    ifrApproaches,
    takeOffsDays,
    takeOffsNight,
    landingsDay,
    landingsNight,
    pilotFunction,
    approachType,
    remarks,
    notes,
    isLocked,
    signatureImage,
    endorsementData,
    endorsementHash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flights';
  @override
  VerificationContext validateIntegrity(
    Insertable<Flight> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('aircraft_id')) {
      context.handle(
        _aircraftIdMeta,
        aircraftId.isAcceptableOrUnknown(data['aircraft_id']!, _aircraftIdMeta),
      );
    } else if (isInserting) {
      context.missing(_aircraftIdMeta);
    }
    if (data.containsKey('departure_airport_id')) {
      context.handle(
        _departureAirportIdMeta,
        departureAirportId.isAcceptableOrUnknown(
          data['departure_airport_id']!,
          _departureAirportIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departureAirportIdMeta);
    }
    if (data.containsKey('arrival_airport_id')) {
      context.handle(
        _arrivalAirportIdMeta,
        arrivalAirportId.isAcceptableOrUnknown(
          data['arrival_airport_id']!,
          _arrivalAirportIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_arrivalAirportIdMeta);
    }
    if (data.containsKey('departure_date_time_id')) {
      context.handle(
        _departureDateTimeIdMeta,
        departureDateTimeId.isAcceptableOrUnknown(
          data['departure_date_time_id']!,
          _departureDateTimeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departureDateTimeIdMeta);
    }
    if (data.containsKey('take_off_date_time')) {
      context.handle(
        _takeOffDateTimeMeta,
        takeOffDateTime.isAcceptableOrUnknown(
          data['take_off_date_time']!,
          _takeOffDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('landing_date_time')) {
      context.handle(
        _landingDateTimeMeta,
        landingDateTime.isAcceptableOrUnknown(
          data['landing_date_time']!,
          _landingDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('arrival_date_time')) {
      context.handle(
        _arrivalDateTimeMeta,
        arrivalDateTime.isAcceptableOrUnknown(
          data['arrival_date_time']!,
          _arrivalDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('time_p_i_c_minutes')) {
      context.handle(
        _timePICMinutesMeta,
        timePICMinutes.isAcceptableOrUnknown(
          data['time_p_i_c_minutes']!,
          _timePICMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timePICMinutesMeta);
    }
    if (data.containsKey('time_p_i_c_u_s_minutes')) {
      context.handle(
        _timePICUSMinutesMeta,
        timePICUSMinutes.isAcceptableOrUnknown(
          data['time_p_i_c_u_s_minutes']!,
          _timePICUSMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timePICUSMinutesMeta);
    }
    if (data.containsKey('time_s_i_c_minutes')) {
      context.handle(
        _timeSICMinutesMeta,
        timeSICMinutes.isAcceptableOrUnknown(
          data['time_s_i_c_minutes']!,
          _timeSICMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeSICMinutesMeta);
    }
    if (data.containsKey('time_dual_minutes')) {
      context.handle(
        _timeDualMinutesMeta,
        timeDualMinutes.isAcceptableOrUnknown(
          data['time_dual_minutes']!,
          _timeDualMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeDualMinutesMeta);
    }
    if (data.containsKey('time_instructor_minutes')) {
      context.handle(
        _timeInstructorMinutesMeta,
        timeInstructorMinutes.isAcceptableOrUnknown(
          data['time_instructor_minutes']!,
          _timeInstructorMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeInstructorMinutesMeta);
    }
    if (data.containsKey('time_i_f_r_minutes')) {
      context.handle(
        _timeIFRMinutesMeta,
        timeIFRMinutes.isAcceptableOrUnknown(
          data['time_i_f_r_minutes']!,
          _timeIFRMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeIFRMinutesMeta);
    }
    if (data.containsKey('time_instrument_minutes')) {
      context.handle(
        _timeInstrumentMinutesMeta,
        timeInstrumentMinutes.isAcceptableOrUnknown(
          data['time_instrument_minutes']!,
          _timeInstrumentMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeInstrumentMinutesMeta);
    }
    if (data.containsKey('time_simulated_instrument_minutes')) {
      context.handle(
        _timeSimulatedInstrumentMinutesMeta,
        timeSimulatedInstrumentMinutes.isAcceptableOrUnknown(
          data['time_simulated_instrument_minutes']!,
          _timeSimulatedInstrumentMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeSimulatedInstrumentMinutesMeta);
    }
    if (data.containsKey('time_night_minutes')) {
      context.handle(
        _timeNightMinutesMeta,
        timeNightMinutes.isAcceptableOrUnknown(
          data['time_night_minutes']!,
          _timeNightMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeNightMinutesMeta);
    }
    if (data.containsKey('time_cross_country_minutes')) {
      context.handle(
        _timeCrossCountryMinutesMeta,
        timeCrossCountryMinutes.isAcceptableOrUnknown(
          data['time_cross_country_minutes']!,
          _timeCrossCountryMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeCrossCountryMinutesMeta);
    }
    if (data.containsKey('time_custom1_minutes')) {
      context.handle(
        _timeCustom1MinutesMeta,
        timeCustom1Minutes.isAcceptableOrUnknown(
          data['time_custom1_minutes']!,
          _timeCustom1MinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeCustom1MinutesMeta);
    }
    if (data.containsKey('time_custom2_minutes')) {
      context.handle(
        _timeCustom2MinutesMeta,
        timeCustom2Minutes.isAcceptableOrUnknown(
          data['time_custom2_minutes']!,
          _timeCustom2MinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeCustom2MinutesMeta);
    }
    if (data.containsKey('time_custom3_minutes')) {
      context.handle(
        _timeCustom3MinutesMeta,
        timeCustom3Minutes.isAcceptableOrUnknown(
          data['time_custom3_minutes']!,
          _timeCustom3MinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeCustom3MinutesMeta);
    }
    if (data.containsKey('time_custom4_minutes')) {
      context.handle(
        _timeCustom4MinutesMeta,
        timeCustom4Minutes.isAcceptableOrUnknown(
          data['time_custom4_minutes']!,
          _timeCustom4MinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeCustom4MinutesMeta);
    }
    if (data.containsKey('time_flight_minutes')) {
      context.handle(
        _timeFlightMinutesMeta,
        timeFlightMinutes.isAcceptableOrUnknown(
          data['time_flight_minutes']!,
          _timeFlightMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeFlightMinutesMeta);
    }
    if (data.containsKey('time_block_minutes')) {
      context.handle(
        _timeBlockMinutesMeta,
        timeBlockMinutes.isAcceptableOrUnknown(
          data['time_block_minutes']!,
          _timeBlockMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeBlockMinutesMeta);
    }
    if (data.containsKey('time_total_block_minutes')) {
      context.handle(
        _timeTotalBlockMinutesMeta,
        timeTotalBlockMinutes.isAcceptableOrUnknown(
          data['time_total_block_minutes']!,
          _timeTotalBlockMinutesMeta,
        ),
      );
    }
    if (data.containsKey('distance_n_m')) {
      context.handle(
        _distanceNMMeta,
        distanceNM.isAcceptableOrUnknown(
          data['distance_n_m']!,
          _distanceNMMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distanceNMMeta);
    }
    if (data.containsKey('ifr_approaches')) {
      context.handle(
        _ifrApproachesMeta,
        ifrApproaches.isAcceptableOrUnknown(
          data['ifr_approaches']!,
          _ifrApproachesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ifrApproachesMeta);
    }
    if (data.containsKey('take_offs_days')) {
      context.handle(
        _takeOffsDaysMeta,
        takeOffsDays.isAcceptableOrUnknown(
          data['take_offs_days']!,
          _takeOffsDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_takeOffsDaysMeta);
    }
    if (data.containsKey('take_offs_night')) {
      context.handle(
        _takeOffsNightMeta,
        takeOffsNight.isAcceptableOrUnknown(
          data['take_offs_night']!,
          _takeOffsNightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_takeOffsNightMeta);
    }
    if (data.containsKey('landings_day')) {
      context.handle(
        _landingsDayMeta,
        landingsDay.isAcceptableOrUnknown(
          data['landings_day']!,
          _landingsDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_landingsDayMeta);
    }
    if (data.containsKey('landings_night')) {
      context.handle(
        _landingsNightMeta,
        landingsNight.isAcceptableOrUnknown(
          data['landings_night']!,
          _landingsNightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_landingsNightMeta);
    }
    if (data.containsKey('approach_type')) {
      context.handle(
        _approachTypeMeta,
        approachType.isAcceptableOrUnknown(
          data['approach_type']!,
          _approachTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_approachTypeMeta);
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    } else if (isInserting) {
      context.missing(_remarksMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    } else if (isInserting) {
      context.missing(_isLockedMeta);
    }
    if (data.containsKey('signature_image')) {
      context.handle(
        _signatureImageMeta,
        signatureImage.isAcceptableOrUnknown(
          data['signature_image']!,
          _signatureImageMeta,
        ),
      );
    }
    if (data.containsKey('endorsement_data')) {
      context.handle(
        _endorsementDataMeta,
        endorsementData.isAcceptableOrUnknown(
          data['endorsement_data']!,
          _endorsementDataMeta,
        ),
      );
    }
    if (data.containsKey('endorsement_hash')) {
      context.handle(
        _endorsementHashMeta,
        endorsementHash.isAcceptableOrUnknown(
          data['endorsement_hash']!,
          _endorsementHashMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Flight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Flight(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      aircraftId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}aircraft_id'],
      )!,
      departureAirportId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}departure_airport_id'],
      )!,
      arrivalAirportId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}arrival_airport_id'],
      )!,
      departureDateTimeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}departure_date_time_id'],
      )!,
      takeOffDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}take_off_date_time'],
      ),
      landingDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}landing_date_time'],
      ),
      arrivalDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}arrival_date_time'],
      ),
      timePICMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_p_i_c_minutes'],
      )!,
      timePICUSMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_p_i_c_u_s_minutes'],
      )!,
      timeSICMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_s_i_c_minutes'],
      )!,
      timeDualMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_dual_minutes'],
      )!,
      timeInstructorMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_instructor_minutes'],
      )!,
      timeIFRMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_i_f_r_minutes'],
      )!,
      timeInstrumentMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_instrument_minutes'],
      )!,
      timeSimulatedInstrumentMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_simulated_instrument_minutes'],
      )!,
      timeNightMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_night_minutes'],
      )!,
      timeCrossCountryMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_cross_country_minutes'],
      )!,
      timeCustom1Minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_custom1_minutes'],
      )!,
      timeCustom2Minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_custom2_minutes'],
      )!,
      timeCustom3Minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_custom3_minutes'],
      )!,
      timeCustom4Minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_custom4_minutes'],
      )!,
      timeFlightMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_flight_minutes'],
      )!,
      timeBlockMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_block_minutes'],
      )!,
      timeTotalBlockMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_total_block_minutes'],
      )!,
      distanceNM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance_n_m'],
      )!,
      ifrApproaches: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ifr_approaches'],
      )!,
      takeOffsDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}take_offs_days'],
      )!,
      takeOffsNight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}take_offs_night'],
      )!,
      landingsDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}landings_day'],
      )!,
      landingsNight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}landings_night'],
      )!,
      pilotFunction: $FlightsTable.$converterpilotFunction.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}pilot_function'],
        )!,
      ),
      approachType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}approach_type'],
      )!,
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
      signatureImage: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}signature_image'],
      ),
      endorsementData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endorsement_data'],
      ),
      endorsementHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endorsement_hash'],
      ),
    );
  }

  @override
  $FlightsTable createAlias(String alias) {
    return $FlightsTable(attachedDatabase, alias);
  }

  static TypeConverter<PilotFunction, String> $converterpilotFunction =
      const PilotFunctionConverter();
}

class Flight extends DataClass implements Insertable<Flight> {
  /// Surrogate primary key.
  final int id;

  /// Linked aircraft id.
  final int aircraftId;

  /// Departure airport id.
  final int departureAirportId;

  /// Arrival airport id.
  final int arrivalAirportId;

  /// Timeline id for departure/chocks-off event.
  final int departureDateTimeId;

  /// Optional takeoff timestamp.
  final DateTime? takeOffDateTime;

  /// Optional landing timestamp.
  final DateTime? landingDateTime;

  /// Optional arrival/chocks-on timestamp.
  final DateTime? arrivalDateTime;

  /// PIC time in minutes.
  final int timePICMinutes;

  /// PICUS time in minutes.
  final int timePICUSMinutes;

  /// SIC time in minutes.
  final int timeSICMinutes;

  /// Dual time in minutes.
  final int timeDualMinutes;

  /// Instructor time in minutes.
  final int timeInstructorMinutes;

  /// IFR time in minutes.
  final int timeIFRMinutes;

  /// Instrument time in minutes.
  final int timeInstrumentMinutes;

  /// Simulated instrument time in minutes.
  final int timeSimulatedInstrumentMinutes;

  /// Night time in minutes.
  final int timeNightMinutes;

  /// Cross-country time in minutes.
  final int timeCrossCountryMinutes;

  /// Custom time bucket 1 in minutes.
  final int timeCustom1Minutes;

  /// Custom time bucket 2 in minutes.
  final int timeCustom2Minutes;

  /// Custom time bucket 3 in minutes.
  final int timeCustom3Minutes;

  /// Custom time bucket 4 in minutes.
  final int timeCustom4Minutes;

  /// Airborne/flight time in minutes.
  final int timeFlightMinutes;

  /// Block time in minutes.
  final int timeBlockMinutes;

  /// Accumulated total block time in minutes.
  final int timeTotalBlockMinutes;

  /// Great-circle distance in nautical miles.
  final int distanceNM;

  /// Number of IFR approaches.
  final int ifrApproaches;

  /// Day takeoffs count.
  final int takeOffsDays;

  /// Night takeoffs count.
  final int takeOffsNight;

  /// Day landings count.
  final int landingsDay;

  /// Night landings count.
  final int landingsNight;

  /// Pilot function label (e.g. PF/PNF/IRP3/IRP4).
  final PilotFunction pilotFunction;

  /// Free-text approach type summary.
  final String approachType;

  /// User remarks.
  final String remarks;

  /// Private notes.
  final String notes;

  /// Lock flag to prevent editing.
  final bool isLocked;

  /// Optional endorsement/signature image bytes.
  final Uint8List? signatureImage;

  /// Optional serialized endorsement metadata.
  final String? endorsementData;

  /// Hash used to verify endorsement integrity.
  final String? endorsementHash;
  const Flight({
    required this.id,
    required this.aircraftId,
    required this.departureAirportId,
    required this.arrivalAirportId,
    required this.departureDateTimeId,
    this.takeOffDateTime,
    this.landingDateTime,
    this.arrivalDateTime,
    required this.timePICMinutes,
    required this.timePICUSMinutes,
    required this.timeSICMinutes,
    required this.timeDualMinutes,
    required this.timeInstructorMinutes,
    required this.timeIFRMinutes,
    required this.timeInstrumentMinutes,
    required this.timeSimulatedInstrumentMinutes,
    required this.timeNightMinutes,
    required this.timeCrossCountryMinutes,
    required this.timeCustom1Minutes,
    required this.timeCustom2Minutes,
    required this.timeCustom3Minutes,
    required this.timeCustom4Minutes,
    required this.timeFlightMinutes,
    required this.timeBlockMinutes,
    required this.timeTotalBlockMinutes,
    required this.distanceNM,
    required this.ifrApproaches,
    required this.takeOffsDays,
    required this.takeOffsNight,
    required this.landingsDay,
    required this.landingsNight,
    required this.pilotFunction,
    required this.approachType,
    required this.remarks,
    required this.notes,
    required this.isLocked,
    this.signatureImage,
    this.endorsementData,
    this.endorsementHash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['aircraft_id'] = Variable<int>(aircraftId);
    map['departure_airport_id'] = Variable<int>(departureAirportId);
    map['arrival_airport_id'] = Variable<int>(arrivalAirportId);
    map['departure_date_time_id'] = Variable<int>(departureDateTimeId);
    if (!nullToAbsent || takeOffDateTime != null) {
      map['take_off_date_time'] = Variable<DateTime>(takeOffDateTime);
    }
    if (!nullToAbsent || landingDateTime != null) {
      map['landing_date_time'] = Variable<DateTime>(landingDateTime);
    }
    if (!nullToAbsent || arrivalDateTime != null) {
      map['arrival_date_time'] = Variable<DateTime>(arrivalDateTime);
    }
    map['time_p_i_c_minutes'] = Variable<int>(timePICMinutes);
    map['time_p_i_c_u_s_minutes'] = Variable<int>(timePICUSMinutes);
    map['time_s_i_c_minutes'] = Variable<int>(timeSICMinutes);
    map['time_dual_minutes'] = Variable<int>(timeDualMinutes);
    map['time_instructor_minutes'] = Variable<int>(timeInstructorMinutes);
    map['time_i_f_r_minutes'] = Variable<int>(timeIFRMinutes);
    map['time_instrument_minutes'] = Variable<int>(timeInstrumentMinutes);
    map['time_simulated_instrument_minutes'] = Variable<int>(
      timeSimulatedInstrumentMinutes,
    );
    map['time_night_minutes'] = Variable<int>(timeNightMinutes);
    map['time_cross_country_minutes'] = Variable<int>(timeCrossCountryMinutes);
    map['time_custom1_minutes'] = Variable<int>(timeCustom1Minutes);
    map['time_custom2_minutes'] = Variable<int>(timeCustom2Minutes);
    map['time_custom3_minutes'] = Variable<int>(timeCustom3Minutes);
    map['time_custom4_minutes'] = Variable<int>(timeCustom4Minutes);
    map['time_flight_minutes'] = Variable<int>(timeFlightMinutes);
    map['time_block_minutes'] = Variable<int>(timeBlockMinutes);
    map['time_total_block_minutes'] = Variable<int>(timeTotalBlockMinutes);
    map['distance_n_m'] = Variable<int>(distanceNM);
    map['ifr_approaches'] = Variable<int>(ifrApproaches);
    map['take_offs_days'] = Variable<int>(takeOffsDays);
    map['take_offs_night'] = Variable<int>(takeOffsNight);
    map['landings_day'] = Variable<int>(landingsDay);
    map['landings_night'] = Variable<int>(landingsNight);
    {
      map['pilot_function'] = Variable<String>(
        $FlightsTable.$converterpilotFunction.toSql(pilotFunction),
      );
    }
    map['approach_type'] = Variable<String>(approachType);
    map['remarks'] = Variable<String>(remarks);
    map['notes'] = Variable<String>(notes);
    map['is_locked'] = Variable<bool>(isLocked);
    if (!nullToAbsent || signatureImage != null) {
      map['signature_image'] = Variable<Uint8List>(signatureImage);
    }
    if (!nullToAbsent || endorsementData != null) {
      map['endorsement_data'] = Variable<String>(endorsementData);
    }
    if (!nullToAbsent || endorsementHash != null) {
      map['endorsement_hash'] = Variable<String>(endorsementHash);
    }
    return map;
  }

  FlightsCompanion toCompanion(bool nullToAbsent) {
    return FlightsCompanion(
      id: Value(id),
      aircraftId: Value(aircraftId),
      departureAirportId: Value(departureAirportId),
      arrivalAirportId: Value(arrivalAirportId),
      departureDateTimeId: Value(departureDateTimeId),
      takeOffDateTime: takeOffDateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(takeOffDateTime),
      landingDateTime: landingDateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(landingDateTime),
      arrivalDateTime: arrivalDateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(arrivalDateTime),
      timePICMinutes: Value(timePICMinutes),
      timePICUSMinutes: Value(timePICUSMinutes),
      timeSICMinutes: Value(timeSICMinutes),
      timeDualMinutes: Value(timeDualMinutes),
      timeInstructorMinutes: Value(timeInstructorMinutes),
      timeIFRMinutes: Value(timeIFRMinutes),
      timeInstrumentMinutes: Value(timeInstrumentMinutes),
      timeSimulatedInstrumentMinutes: Value(timeSimulatedInstrumentMinutes),
      timeNightMinutes: Value(timeNightMinutes),
      timeCrossCountryMinutes: Value(timeCrossCountryMinutes),
      timeCustom1Minutes: Value(timeCustom1Minutes),
      timeCustom2Minutes: Value(timeCustom2Minutes),
      timeCustom3Minutes: Value(timeCustom3Minutes),
      timeCustom4Minutes: Value(timeCustom4Minutes),
      timeFlightMinutes: Value(timeFlightMinutes),
      timeBlockMinutes: Value(timeBlockMinutes),
      timeTotalBlockMinutes: Value(timeTotalBlockMinutes),
      distanceNM: Value(distanceNM),
      ifrApproaches: Value(ifrApproaches),
      takeOffsDays: Value(takeOffsDays),
      takeOffsNight: Value(takeOffsNight),
      landingsDay: Value(landingsDay),
      landingsNight: Value(landingsNight),
      pilotFunction: Value(pilotFunction),
      approachType: Value(approachType),
      remarks: Value(remarks),
      notes: Value(notes),
      isLocked: Value(isLocked),
      signatureImage: signatureImage == null && nullToAbsent
          ? const Value.absent()
          : Value(signatureImage),
      endorsementData: endorsementData == null && nullToAbsent
          ? const Value.absent()
          : Value(endorsementData),
      endorsementHash: endorsementHash == null && nullToAbsent
          ? const Value.absent()
          : Value(endorsementHash),
    );
  }

  factory Flight.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Flight(
      id: serializer.fromJson<int>(json['id']),
      aircraftId: serializer.fromJson<int>(json['aircraftId']),
      departureAirportId: serializer.fromJson<int>(json['departureAirportId']),
      arrivalAirportId: serializer.fromJson<int>(json['arrivalAirportId']),
      departureDateTimeId: serializer.fromJson<int>(
        json['departureDateTimeId'],
      ),
      takeOffDateTime: serializer.fromJson<DateTime?>(json['takeOffDateTime']),
      landingDateTime: serializer.fromJson<DateTime?>(json['landingDateTime']),
      arrivalDateTime: serializer.fromJson<DateTime?>(json['arrivalDateTime']),
      timePICMinutes: serializer.fromJson<int>(json['timePICMinutes']),
      timePICUSMinutes: serializer.fromJson<int>(json['timePICUSMinutes']),
      timeSICMinutes: serializer.fromJson<int>(json['timeSICMinutes']),
      timeDualMinutes: serializer.fromJson<int>(json['timeDualMinutes']),
      timeInstructorMinutes: serializer.fromJson<int>(
        json['timeInstructorMinutes'],
      ),
      timeIFRMinutes: serializer.fromJson<int>(json['timeIFRMinutes']),
      timeInstrumentMinutes: serializer.fromJson<int>(
        json['timeInstrumentMinutes'],
      ),
      timeSimulatedInstrumentMinutes: serializer.fromJson<int>(
        json['timeSimulatedInstrumentMinutes'],
      ),
      timeNightMinutes: serializer.fromJson<int>(json['timeNightMinutes']),
      timeCrossCountryMinutes: serializer.fromJson<int>(
        json['timeCrossCountryMinutes'],
      ),
      timeCustom1Minutes: serializer.fromJson<int>(json['timeCustom1Minutes']),
      timeCustom2Minutes: serializer.fromJson<int>(json['timeCustom2Minutes']),
      timeCustom3Minutes: serializer.fromJson<int>(json['timeCustom3Minutes']),
      timeCustom4Minutes: serializer.fromJson<int>(json['timeCustom4Minutes']),
      timeFlightMinutes: serializer.fromJson<int>(json['timeFlightMinutes']),
      timeBlockMinutes: serializer.fromJson<int>(json['timeBlockMinutes']),
      timeTotalBlockMinutes: serializer.fromJson<int>(
        json['timeTotalBlockMinutes'],
      ),
      distanceNM: serializer.fromJson<int>(json['distanceNM']),
      ifrApproaches: serializer.fromJson<int>(json['ifrApproaches']),
      takeOffsDays: serializer.fromJson<int>(json['takeOffsDays']),
      takeOffsNight: serializer.fromJson<int>(json['takeOffsNight']),
      landingsDay: serializer.fromJson<int>(json['landingsDay']),
      landingsNight: serializer.fromJson<int>(json['landingsNight']),
      pilotFunction: serializer.fromJson<PilotFunction>(json['pilotFunction']),
      approachType: serializer.fromJson<String>(json['approachType']),
      remarks: serializer.fromJson<String>(json['remarks']),
      notes: serializer.fromJson<String>(json['notes']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
      signatureImage: serializer.fromJson<Uint8List?>(json['signatureImage']),
      endorsementData: serializer.fromJson<String?>(json['endorsementData']),
      endorsementHash: serializer.fromJson<String?>(json['endorsementHash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'aircraftId': serializer.toJson<int>(aircraftId),
      'departureAirportId': serializer.toJson<int>(departureAirportId),
      'arrivalAirportId': serializer.toJson<int>(arrivalAirportId),
      'departureDateTimeId': serializer.toJson<int>(departureDateTimeId),
      'takeOffDateTime': serializer.toJson<DateTime?>(takeOffDateTime),
      'landingDateTime': serializer.toJson<DateTime?>(landingDateTime),
      'arrivalDateTime': serializer.toJson<DateTime?>(arrivalDateTime),
      'timePICMinutes': serializer.toJson<int>(timePICMinutes),
      'timePICUSMinutes': serializer.toJson<int>(timePICUSMinutes),
      'timeSICMinutes': serializer.toJson<int>(timeSICMinutes),
      'timeDualMinutes': serializer.toJson<int>(timeDualMinutes),
      'timeInstructorMinutes': serializer.toJson<int>(timeInstructorMinutes),
      'timeIFRMinutes': serializer.toJson<int>(timeIFRMinutes),
      'timeInstrumentMinutes': serializer.toJson<int>(timeInstrumentMinutes),
      'timeSimulatedInstrumentMinutes': serializer.toJson<int>(
        timeSimulatedInstrumentMinutes,
      ),
      'timeNightMinutes': serializer.toJson<int>(timeNightMinutes),
      'timeCrossCountryMinutes': serializer.toJson<int>(
        timeCrossCountryMinutes,
      ),
      'timeCustom1Minutes': serializer.toJson<int>(timeCustom1Minutes),
      'timeCustom2Minutes': serializer.toJson<int>(timeCustom2Minutes),
      'timeCustom3Minutes': serializer.toJson<int>(timeCustom3Minutes),
      'timeCustom4Minutes': serializer.toJson<int>(timeCustom4Minutes),
      'timeFlightMinutes': serializer.toJson<int>(timeFlightMinutes),
      'timeBlockMinutes': serializer.toJson<int>(timeBlockMinutes),
      'timeTotalBlockMinutes': serializer.toJson<int>(timeTotalBlockMinutes),
      'distanceNM': serializer.toJson<int>(distanceNM),
      'ifrApproaches': serializer.toJson<int>(ifrApproaches),
      'takeOffsDays': serializer.toJson<int>(takeOffsDays),
      'takeOffsNight': serializer.toJson<int>(takeOffsNight),
      'landingsDay': serializer.toJson<int>(landingsDay),
      'landingsNight': serializer.toJson<int>(landingsNight),
      'pilotFunction': serializer.toJson<PilotFunction>(pilotFunction),
      'approachType': serializer.toJson<String>(approachType),
      'remarks': serializer.toJson<String>(remarks),
      'notes': serializer.toJson<String>(notes),
      'isLocked': serializer.toJson<bool>(isLocked),
      'signatureImage': serializer.toJson<Uint8List?>(signatureImage),
      'endorsementData': serializer.toJson<String?>(endorsementData),
      'endorsementHash': serializer.toJson<String?>(endorsementHash),
    };
  }

  Flight copyWith({
    int? id,
    int? aircraftId,
    int? departureAirportId,
    int? arrivalAirportId,
    int? departureDateTimeId,
    Value<DateTime?> takeOffDateTime = const Value.absent(),
    Value<DateTime?> landingDateTime = const Value.absent(),
    Value<DateTime?> arrivalDateTime = const Value.absent(),
    int? timePICMinutes,
    int? timePICUSMinutes,
    int? timeSICMinutes,
    int? timeDualMinutes,
    int? timeInstructorMinutes,
    int? timeIFRMinutes,
    int? timeInstrumentMinutes,
    int? timeSimulatedInstrumentMinutes,
    int? timeNightMinutes,
    int? timeCrossCountryMinutes,
    int? timeCustom1Minutes,
    int? timeCustom2Minutes,
    int? timeCustom3Minutes,
    int? timeCustom4Minutes,
    int? timeFlightMinutes,
    int? timeBlockMinutes,
    int? timeTotalBlockMinutes,
    int? distanceNM,
    int? ifrApproaches,
    int? takeOffsDays,
    int? takeOffsNight,
    int? landingsDay,
    int? landingsNight,
    PilotFunction? pilotFunction,
    String? approachType,
    String? remarks,
    String? notes,
    bool? isLocked,
    Value<Uint8List?> signatureImage = const Value.absent(),
    Value<String?> endorsementData = const Value.absent(),
    Value<String?> endorsementHash = const Value.absent(),
  }) => Flight(
    id: id ?? this.id,
    aircraftId: aircraftId ?? this.aircraftId,
    departureAirportId: departureAirportId ?? this.departureAirportId,
    arrivalAirportId: arrivalAirportId ?? this.arrivalAirportId,
    departureDateTimeId: departureDateTimeId ?? this.departureDateTimeId,
    takeOffDateTime: takeOffDateTime.present
        ? takeOffDateTime.value
        : this.takeOffDateTime,
    landingDateTime: landingDateTime.present
        ? landingDateTime.value
        : this.landingDateTime,
    arrivalDateTime: arrivalDateTime.present
        ? arrivalDateTime.value
        : this.arrivalDateTime,
    timePICMinutes: timePICMinutes ?? this.timePICMinutes,
    timePICUSMinutes: timePICUSMinutes ?? this.timePICUSMinutes,
    timeSICMinutes: timeSICMinutes ?? this.timeSICMinutes,
    timeDualMinutes: timeDualMinutes ?? this.timeDualMinutes,
    timeInstructorMinutes: timeInstructorMinutes ?? this.timeInstructorMinutes,
    timeIFRMinutes: timeIFRMinutes ?? this.timeIFRMinutes,
    timeInstrumentMinutes: timeInstrumentMinutes ?? this.timeInstrumentMinutes,
    timeSimulatedInstrumentMinutes:
        timeSimulatedInstrumentMinutes ?? this.timeSimulatedInstrumentMinutes,
    timeNightMinutes: timeNightMinutes ?? this.timeNightMinutes,
    timeCrossCountryMinutes:
        timeCrossCountryMinutes ?? this.timeCrossCountryMinutes,
    timeCustom1Minutes: timeCustom1Minutes ?? this.timeCustom1Minutes,
    timeCustom2Minutes: timeCustom2Minutes ?? this.timeCustom2Minutes,
    timeCustom3Minutes: timeCustom3Minutes ?? this.timeCustom3Minutes,
    timeCustom4Minutes: timeCustom4Minutes ?? this.timeCustom4Minutes,
    timeFlightMinutes: timeFlightMinutes ?? this.timeFlightMinutes,
    timeBlockMinutes: timeBlockMinutes ?? this.timeBlockMinutes,
    timeTotalBlockMinutes: timeTotalBlockMinutes ?? this.timeTotalBlockMinutes,
    distanceNM: distanceNM ?? this.distanceNM,
    ifrApproaches: ifrApproaches ?? this.ifrApproaches,
    takeOffsDays: takeOffsDays ?? this.takeOffsDays,
    takeOffsNight: takeOffsNight ?? this.takeOffsNight,
    landingsDay: landingsDay ?? this.landingsDay,
    landingsNight: landingsNight ?? this.landingsNight,
    pilotFunction: pilotFunction ?? this.pilotFunction,
    approachType: approachType ?? this.approachType,
    remarks: remarks ?? this.remarks,
    notes: notes ?? this.notes,
    isLocked: isLocked ?? this.isLocked,
    signatureImage: signatureImage.present
        ? signatureImage.value
        : this.signatureImage,
    endorsementData: endorsementData.present
        ? endorsementData.value
        : this.endorsementData,
    endorsementHash: endorsementHash.present
        ? endorsementHash.value
        : this.endorsementHash,
  );
  Flight copyWithCompanion(FlightsCompanion data) {
    return Flight(
      id: data.id.present ? data.id.value : this.id,
      aircraftId: data.aircraftId.present
          ? data.aircraftId.value
          : this.aircraftId,
      departureAirportId: data.departureAirportId.present
          ? data.departureAirportId.value
          : this.departureAirportId,
      arrivalAirportId: data.arrivalAirportId.present
          ? data.arrivalAirportId.value
          : this.arrivalAirportId,
      departureDateTimeId: data.departureDateTimeId.present
          ? data.departureDateTimeId.value
          : this.departureDateTimeId,
      takeOffDateTime: data.takeOffDateTime.present
          ? data.takeOffDateTime.value
          : this.takeOffDateTime,
      landingDateTime: data.landingDateTime.present
          ? data.landingDateTime.value
          : this.landingDateTime,
      arrivalDateTime: data.arrivalDateTime.present
          ? data.arrivalDateTime.value
          : this.arrivalDateTime,
      timePICMinutes: data.timePICMinutes.present
          ? data.timePICMinutes.value
          : this.timePICMinutes,
      timePICUSMinutes: data.timePICUSMinutes.present
          ? data.timePICUSMinutes.value
          : this.timePICUSMinutes,
      timeSICMinutes: data.timeSICMinutes.present
          ? data.timeSICMinutes.value
          : this.timeSICMinutes,
      timeDualMinutes: data.timeDualMinutes.present
          ? data.timeDualMinutes.value
          : this.timeDualMinutes,
      timeInstructorMinutes: data.timeInstructorMinutes.present
          ? data.timeInstructorMinutes.value
          : this.timeInstructorMinutes,
      timeIFRMinutes: data.timeIFRMinutes.present
          ? data.timeIFRMinutes.value
          : this.timeIFRMinutes,
      timeInstrumentMinutes: data.timeInstrumentMinutes.present
          ? data.timeInstrumentMinutes.value
          : this.timeInstrumentMinutes,
      timeSimulatedInstrumentMinutes:
          data.timeSimulatedInstrumentMinutes.present
          ? data.timeSimulatedInstrumentMinutes.value
          : this.timeSimulatedInstrumentMinutes,
      timeNightMinutes: data.timeNightMinutes.present
          ? data.timeNightMinutes.value
          : this.timeNightMinutes,
      timeCrossCountryMinutes: data.timeCrossCountryMinutes.present
          ? data.timeCrossCountryMinutes.value
          : this.timeCrossCountryMinutes,
      timeCustom1Minutes: data.timeCustom1Minutes.present
          ? data.timeCustom1Minutes.value
          : this.timeCustom1Minutes,
      timeCustom2Minutes: data.timeCustom2Minutes.present
          ? data.timeCustom2Minutes.value
          : this.timeCustom2Minutes,
      timeCustom3Minutes: data.timeCustom3Minutes.present
          ? data.timeCustom3Minutes.value
          : this.timeCustom3Minutes,
      timeCustom4Minutes: data.timeCustom4Minutes.present
          ? data.timeCustom4Minutes.value
          : this.timeCustom4Minutes,
      timeFlightMinutes: data.timeFlightMinutes.present
          ? data.timeFlightMinutes.value
          : this.timeFlightMinutes,
      timeBlockMinutes: data.timeBlockMinutes.present
          ? data.timeBlockMinutes.value
          : this.timeBlockMinutes,
      timeTotalBlockMinutes: data.timeTotalBlockMinutes.present
          ? data.timeTotalBlockMinutes.value
          : this.timeTotalBlockMinutes,
      distanceNM: data.distanceNM.present
          ? data.distanceNM.value
          : this.distanceNM,
      ifrApproaches: data.ifrApproaches.present
          ? data.ifrApproaches.value
          : this.ifrApproaches,
      takeOffsDays: data.takeOffsDays.present
          ? data.takeOffsDays.value
          : this.takeOffsDays,
      takeOffsNight: data.takeOffsNight.present
          ? data.takeOffsNight.value
          : this.takeOffsNight,
      landingsDay: data.landingsDay.present
          ? data.landingsDay.value
          : this.landingsDay,
      landingsNight: data.landingsNight.present
          ? data.landingsNight.value
          : this.landingsNight,
      pilotFunction: data.pilotFunction.present
          ? data.pilotFunction.value
          : this.pilotFunction,
      approachType: data.approachType.present
          ? data.approachType.value
          : this.approachType,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      notes: data.notes.present ? data.notes.value : this.notes,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
      signatureImage: data.signatureImage.present
          ? data.signatureImage.value
          : this.signatureImage,
      endorsementData: data.endorsementData.present
          ? data.endorsementData.value
          : this.endorsementData,
      endorsementHash: data.endorsementHash.present
          ? data.endorsementHash.value
          : this.endorsementHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Flight(')
          ..write('id: $id, ')
          ..write('aircraftId: $aircraftId, ')
          ..write('departureAirportId: $departureAirportId, ')
          ..write('arrivalAirportId: $arrivalAirportId, ')
          ..write('departureDateTimeId: $departureDateTimeId, ')
          ..write('takeOffDateTime: $takeOffDateTime, ')
          ..write('landingDateTime: $landingDateTime, ')
          ..write('arrivalDateTime: $arrivalDateTime, ')
          ..write('timePICMinutes: $timePICMinutes, ')
          ..write('timePICUSMinutes: $timePICUSMinutes, ')
          ..write('timeSICMinutes: $timeSICMinutes, ')
          ..write('timeDualMinutes: $timeDualMinutes, ')
          ..write('timeInstructorMinutes: $timeInstructorMinutes, ')
          ..write('timeIFRMinutes: $timeIFRMinutes, ')
          ..write('timeInstrumentMinutes: $timeInstrumentMinutes, ')
          ..write(
            'timeSimulatedInstrumentMinutes: $timeSimulatedInstrumentMinutes, ',
          )
          ..write('timeNightMinutes: $timeNightMinutes, ')
          ..write('timeCrossCountryMinutes: $timeCrossCountryMinutes, ')
          ..write('timeCustom1Minutes: $timeCustom1Minutes, ')
          ..write('timeCustom2Minutes: $timeCustom2Minutes, ')
          ..write('timeCustom3Minutes: $timeCustom3Minutes, ')
          ..write('timeCustom4Minutes: $timeCustom4Minutes, ')
          ..write('timeFlightMinutes: $timeFlightMinutes, ')
          ..write('timeBlockMinutes: $timeBlockMinutes, ')
          ..write('timeTotalBlockMinutes: $timeTotalBlockMinutes, ')
          ..write('distanceNM: $distanceNM, ')
          ..write('ifrApproaches: $ifrApproaches, ')
          ..write('takeOffsDays: $takeOffsDays, ')
          ..write('takeOffsNight: $takeOffsNight, ')
          ..write('landingsDay: $landingsDay, ')
          ..write('landingsNight: $landingsNight, ')
          ..write('pilotFunction: $pilotFunction, ')
          ..write('approachType: $approachType, ')
          ..write('remarks: $remarks, ')
          ..write('notes: $notes, ')
          ..write('isLocked: $isLocked, ')
          ..write('signatureImage: $signatureImage, ')
          ..write('endorsementData: $endorsementData, ')
          ..write('endorsementHash: $endorsementHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    aircraftId,
    departureAirportId,
    arrivalAirportId,
    departureDateTimeId,
    takeOffDateTime,
    landingDateTime,
    arrivalDateTime,
    timePICMinutes,
    timePICUSMinutes,
    timeSICMinutes,
    timeDualMinutes,
    timeInstructorMinutes,
    timeIFRMinutes,
    timeInstrumentMinutes,
    timeSimulatedInstrumentMinutes,
    timeNightMinutes,
    timeCrossCountryMinutes,
    timeCustom1Minutes,
    timeCustom2Minutes,
    timeCustom3Minutes,
    timeCustom4Minutes,
    timeFlightMinutes,
    timeBlockMinutes,
    timeTotalBlockMinutes,
    distanceNM,
    ifrApproaches,
    takeOffsDays,
    takeOffsNight,
    landingsDay,
    landingsNight,
    pilotFunction,
    approachType,
    remarks,
    notes,
    isLocked,
    $driftBlobEquality.hash(signatureImage),
    endorsementData,
    endorsementHash,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Flight &&
          other.id == this.id &&
          other.aircraftId == this.aircraftId &&
          other.departureAirportId == this.departureAirportId &&
          other.arrivalAirportId == this.arrivalAirportId &&
          other.departureDateTimeId == this.departureDateTimeId &&
          other.takeOffDateTime == this.takeOffDateTime &&
          other.landingDateTime == this.landingDateTime &&
          other.arrivalDateTime == this.arrivalDateTime &&
          other.timePICMinutes == this.timePICMinutes &&
          other.timePICUSMinutes == this.timePICUSMinutes &&
          other.timeSICMinutes == this.timeSICMinutes &&
          other.timeDualMinutes == this.timeDualMinutes &&
          other.timeInstructorMinutes == this.timeInstructorMinutes &&
          other.timeIFRMinutes == this.timeIFRMinutes &&
          other.timeInstrumentMinutes == this.timeInstrumentMinutes &&
          other.timeSimulatedInstrumentMinutes ==
              this.timeSimulatedInstrumentMinutes &&
          other.timeNightMinutes == this.timeNightMinutes &&
          other.timeCrossCountryMinutes == this.timeCrossCountryMinutes &&
          other.timeCustom1Minutes == this.timeCustom1Minutes &&
          other.timeCustom2Minutes == this.timeCustom2Minutes &&
          other.timeCustom3Minutes == this.timeCustom3Minutes &&
          other.timeCustom4Minutes == this.timeCustom4Minutes &&
          other.timeFlightMinutes == this.timeFlightMinutes &&
          other.timeBlockMinutes == this.timeBlockMinutes &&
          other.timeTotalBlockMinutes == this.timeTotalBlockMinutes &&
          other.distanceNM == this.distanceNM &&
          other.ifrApproaches == this.ifrApproaches &&
          other.takeOffsDays == this.takeOffsDays &&
          other.takeOffsNight == this.takeOffsNight &&
          other.landingsDay == this.landingsDay &&
          other.landingsNight == this.landingsNight &&
          other.pilotFunction == this.pilotFunction &&
          other.approachType == this.approachType &&
          other.remarks == this.remarks &&
          other.notes == this.notes &&
          other.isLocked == this.isLocked &&
          $driftBlobEquality.equals(
            other.signatureImage,
            this.signatureImage,
          ) &&
          other.endorsementData == this.endorsementData &&
          other.endorsementHash == this.endorsementHash);
}

class FlightsCompanion extends UpdateCompanion<Flight> {
  final Value<int> id;
  final Value<int> aircraftId;
  final Value<int> departureAirportId;
  final Value<int> arrivalAirportId;
  final Value<int> departureDateTimeId;
  final Value<DateTime?> takeOffDateTime;
  final Value<DateTime?> landingDateTime;
  final Value<DateTime?> arrivalDateTime;
  final Value<int> timePICMinutes;
  final Value<int> timePICUSMinutes;
  final Value<int> timeSICMinutes;
  final Value<int> timeDualMinutes;
  final Value<int> timeInstructorMinutes;
  final Value<int> timeIFRMinutes;
  final Value<int> timeInstrumentMinutes;
  final Value<int> timeSimulatedInstrumentMinutes;
  final Value<int> timeNightMinutes;
  final Value<int> timeCrossCountryMinutes;
  final Value<int> timeCustom1Minutes;
  final Value<int> timeCustom2Minutes;
  final Value<int> timeCustom3Minutes;
  final Value<int> timeCustom4Minutes;
  final Value<int> timeFlightMinutes;
  final Value<int> timeBlockMinutes;
  final Value<int> timeTotalBlockMinutes;
  final Value<int> distanceNM;
  final Value<int> ifrApproaches;
  final Value<int> takeOffsDays;
  final Value<int> takeOffsNight;
  final Value<int> landingsDay;
  final Value<int> landingsNight;
  final Value<PilotFunction> pilotFunction;
  final Value<String> approachType;
  final Value<String> remarks;
  final Value<String> notes;
  final Value<bool> isLocked;
  final Value<Uint8List?> signatureImage;
  final Value<String?> endorsementData;
  final Value<String?> endorsementHash;
  const FlightsCompanion({
    this.id = const Value.absent(),
    this.aircraftId = const Value.absent(),
    this.departureAirportId = const Value.absent(),
    this.arrivalAirportId = const Value.absent(),
    this.departureDateTimeId = const Value.absent(),
    this.takeOffDateTime = const Value.absent(),
    this.landingDateTime = const Value.absent(),
    this.arrivalDateTime = const Value.absent(),
    this.timePICMinutes = const Value.absent(),
    this.timePICUSMinutes = const Value.absent(),
    this.timeSICMinutes = const Value.absent(),
    this.timeDualMinutes = const Value.absent(),
    this.timeInstructorMinutes = const Value.absent(),
    this.timeIFRMinutes = const Value.absent(),
    this.timeInstrumentMinutes = const Value.absent(),
    this.timeSimulatedInstrumentMinutes = const Value.absent(),
    this.timeNightMinutes = const Value.absent(),
    this.timeCrossCountryMinutes = const Value.absent(),
    this.timeCustom1Minutes = const Value.absent(),
    this.timeCustom2Minutes = const Value.absent(),
    this.timeCustom3Minutes = const Value.absent(),
    this.timeCustom4Minutes = const Value.absent(),
    this.timeFlightMinutes = const Value.absent(),
    this.timeBlockMinutes = const Value.absent(),
    this.timeTotalBlockMinutes = const Value.absent(),
    this.distanceNM = const Value.absent(),
    this.ifrApproaches = const Value.absent(),
    this.takeOffsDays = const Value.absent(),
    this.takeOffsNight = const Value.absent(),
    this.landingsDay = const Value.absent(),
    this.landingsNight = const Value.absent(),
    this.pilotFunction = const Value.absent(),
    this.approachType = const Value.absent(),
    this.remarks = const Value.absent(),
    this.notes = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.signatureImage = const Value.absent(),
    this.endorsementData = const Value.absent(),
    this.endorsementHash = const Value.absent(),
  });
  FlightsCompanion.insert({
    this.id = const Value.absent(),
    required int aircraftId,
    required int departureAirportId,
    required int arrivalAirportId,
    required int departureDateTimeId,
    this.takeOffDateTime = const Value.absent(),
    this.landingDateTime = const Value.absent(),
    this.arrivalDateTime = const Value.absent(),
    required int timePICMinutes,
    required int timePICUSMinutes,
    required int timeSICMinutes,
    required int timeDualMinutes,
    required int timeInstructorMinutes,
    required int timeIFRMinutes,
    required int timeInstrumentMinutes,
    required int timeSimulatedInstrumentMinutes,
    required int timeNightMinutes,
    required int timeCrossCountryMinutes,
    required int timeCustom1Minutes,
    required int timeCustom2Minutes,
    required int timeCustom3Minutes,
    required int timeCustom4Minutes,
    required int timeFlightMinutes,
    required int timeBlockMinutes,
    this.timeTotalBlockMinutes = const Value.absent(),
    required int distanceNM,
    required int ifrApproaches,
    required int takeOffsDays,
    required int takeOffsNight,
    required int landingsDay,
    required int landingsNight,
    this.pilotFunction = const Value.absent(),
    required String approachType,
    required String remarks,
    required String notes,
    required bool isLocked,
    this.signatureImage = const Value.absent(),
    this.endorsementData = const Value.absent(),
    this.endorsementHash = const Value.absent(),
  }) : aircraftId = Value(aircraftId),
       departureAirportId = Value(departureAirportId),
       arrivalAirportId = Value(arrivalAirportId),
       departureDateTimeId = Value(departureDateTimeId),
       timePICMinutes = Value(timePICMinutes),
       timePICUSMinutes = Value(timePICUSMinutes),
       timeSICMinutes = Value(timeSICMinutes),
       timeDualMinutes = Value(timeDualMinutes),
       timeInstructorMinutes = Value(timeInstructorMinutes),
       timeIFRMinutes = Value(timeIFRMinutes),
       timeInstrumentMinutes = Value(timeInstrumentMinutes),
       timeSimulatedInstrumentMinutes = Value(timeSimulatedInstrumentMinutes),
       timeNightMinutes = Value(timeNightMinutes),
       timeCrossCountryMinutes = Value(timeCrossCountryMinutes),
       timeCustom1Minutes = Value(timeCustom1Minutes),
       timeCustom2Minutes = Value(timeCustom2Minutes),
       timeCustom3Minutes = Value(timeCustom3Minutes),
       timeCustom4Minutes = Value(timeCustom4Minutes),
       timeFlightMinutes = Value(timeFlightMinutes),
       timeBlockMinutes = Value(timeBlockMinutes),
       distanceNM = Value(distanceNM),
       ifrApproaches = Value(ifrApproaches),
       takeOffsDays = Value(takeOffsDays),
       takeOffsNight = Value(takeOffsNight),
       landingsDay = Value(landingsDay),
       landingsNight = Value(landingsNight),
       approachType = Value(approachType),
       remarks = Value(remarks),
       notes = Value(notes),
       isLocked = Value(isLocked);
  static Insertable<Flight> custom({
    Expression<int>? id,
    Expression<int>? aircraftId,
    Expression<int>? departureAirportId,
    Expression<int>? arrivalAirportId,
    Expression<int>? departureDateTimeId,
    Expression<DateTime>? takeOffDateTime,
    Expression<DateTime>? landingDateTime,
    Expression<DateTime>? arrivalDateTime,
    Expression<int>? timePICMinutes,
    Expression<int>? timePICUSMinutes,
    Expression<int>? timeSICMinutes,
    Expression<int>? timeDualMinutes,
    Expression<int>? timeInstructorMinutes,
    Expression<int>? timeIFRMinutes,
    Expression<int>? timeInstrumentMinutes,
    Expression<int>? timeSimulatedInstrumentMinutes,
    Expression<int>? timeNightMinutes,
    Expression<int>? timeCrossCountryMinutes,
    Expression<int>? timeCustom1Minutes,
    Expression<int>? timeCustom2Minutes,
    Expression<int>? timeCustom3Minutes,
    Expression<int>? timeCustom4Minutes,
    Expression<int>? timeFlightMinutes,
    Expression<int>? timeBlockMinutes,
    Expression<int>? timeTotalBlockMinutes,
    Expression<int>? distanceNM,
    Expression<int>? ifrApproaches,
    Expression<int>? takeOffsDays,
    Expression<int>? takeOffsNight,
    Expression<int>? landingsDay,
    Expression<int>? landingsNight,
    Expression<String>? pilotFunction,
    Expression<String>? approachType,
    Expression<String>? remarks,
    Expression<String>? notes,
    Expression<bool>? isLocked,
    Expression<Uint8List>? signatureImage,
    Expression<String>? endorsementData,
    Expression<String>? endorsementHash,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (aircraftId != null) 'aircraft_id': aircraftId,
      if (departureAirportId != null)
        'departure_airport_id': departureAirportId,
      if (arrivalAirportId != null) 'arrival_airport_id': arrivalAirportId,
      if (departureDateTimeId != null)
        'departure_date_time_id': departureDateTimeId,
      if (takeOffDateTime != null) 'take_off_date_time': takeOffDateTime,
      if (landingDateTime != null) 'landing_date_time': landingDateTime,
      if (arrivalDateTime != null) 'arrival_date_time': arrivalDateTime,
      if (timePICMinutes != null) 'time_p_i_c_minutes': timePICMinutes,
      if (timePICUSMinutes != null) 'time_p_i_c_u_s_minutes': timePICUSMinutes,
      if (timeSICMinutes != null) 'time_s_i_c_minutes': timeSICMinutes,
      if (timeDualMinutes != null) 'time_dual_minutes': timeDualMinutes,
      if (timeInstructorMinutes != null)
        'time_instructor_minutes': timeInstructorMinutes,
      if (timeIFRMinutes != null) 'time_i_f_r_minutes': timeIFRMinutes,
      if (timeInstrumentMinutes != null)
        'time_instrument_minutes': timeInstrumentMinutes,
      if (timeSimulatedInstrumentMinutes != null)
        'time_simulated_instrument_minutes': timeSimulatedInstrumentMinutes,
      if (timeNightMinutes != null) 'time_night_minutes': timeNightMinutes,
      if (timeCrossCountryMinutes != null)
        'time_cross_country_minutes': timeCrossCountryMinutes,
      if (timeCustom1Minutes != null)
        'time_custom1_minutes': timeCustom1Minutes,
      if (timeCustom2Minutes != null)
        'time_custom2_minutes': timeCustom2Minutes,
      if (timeCustom3Minutes != null)
        'time_custom3_minutes': timeCustom3Minutes,
      if (timeCustom4Minutes != null)
        'time_custom4_minutes': timeCustom4Minutes,
      if (timeFlightMinutes != null) 'time_flight_minutes': timeFlightMinutes,
      if (timeBlockMinutes != null) 'time_block_minutes': timeBlockMinutes,
      if (timeTotalBlockMinutes != null)
        'time_total_block_minutes': timeTotalBlockMinutes,
      if (distanceNM != null) 'distance_n_m': distanceNM,
      if (ifrApproaches != null) 'ifr_approaches': ifrApproaches,
      if (takeOffsDays != null) 'take_offs_days': takeOffsDays,
      if (takeOffsNight != null) 'take_offs_night': takeOffsNight,
      if (landingsDay != null) 'landings_day': landingsDay,
      if (landingsNight != null) 'landings_night': landingsNight,
      if (pilotFunction != null) 'pilot_function': pilotFunction,
      if (approachType != null) 'approach_type': approachType,
      if (remarks != null) 'remarks': remarks,
      if (notes != null) 'notes': notes,
      if (isLocked != null) 'is_locked': isLocked,
      if (signatureImage != null) 'signature_image': signatureImage,
      if (endorsementData != null) 'endorsement_data': endorsementData,
      if (endorsementHash != null) 'endorsement_hash': endorsementHash,
    });
  }

  FlightsCompanion copyWith({
    Value<int>? id,
    Value<int>? aircraftId,
    Value<int>? departureAirportId,
    Value<int>? arrivalAirportId,
    Value<int>? departureDateTimeId,
    Value<DateTime?>? takeOffDateTime,
    Value<DateTime?>? landingDateTime,
    Value<DateTime?>? arrivalDateTime,
    Value<int>? timePICMinutes,
    Value<int>? timePICUSMinutes,
    Value<int>? timeSICMinutes,
    Value<int>? timeDualMinutes,
    Value<int>? timeInstructorMinutes,
    Value<int>? timeIFRMinutes,
    Value<int>? timeInstrumentMinutes,
    Value<int>? timeSimulatedInstrumentMinutes,
    Value<int>? timeNightMinutes,
    Value<int>? timeCrossCountryMinutes,
    Value<int>? timeCustom1Minutes,
    Value<int>? timeCustom2Minutes,
    Value<int>? timeCustom3Minutes,
    Value<int>? timeCustom4Minutes,
    Value<int>? timeFlightMinutes,
    Value<int>? timeBlockMinutes,
    Value<int>? timeTotalBlockMinutes,
    Value<int>? distanceNM,
    Value<int>? ifrApproaches,
    Value<int>? takeOffsDays,
    Value<int>? takeOffsNight,
    Value<int>? landingsDay,
    Value<int>? landingsNight,
    Value<PilotFunction>? pilotFunction,
    Value<String>? approachType,
    Value<String>? remarks,
    Value<String>? notes,
    Value<bool>? isLocked,
    Value<Uint8List?>? signatureImage,
    Value<String?>? endorsementData,
    Value<String?>? endorsementHash,
  }) {
    return FlightsCompanion(
      id: id ?? this.id,
      aircraftId: aircraftId ?? this.aircraftId,
      departureAirportId: departureAirportId ?? this.departureAirportId,
      arrivalAirportId: arrivalAirportId ?? this.arrivalAirportId,
      departureDateTimeId: departureDateTimeId ?? this.departureDateTimeId,
      takeOffDateTime: takeOffDateTime ?? this.takeOffDateTime,
      landingDateTime: landingDateTime ?? this.landingDateTime,
      arrivalDateTime: arrivalDateTime ?? this.arrivalDateTime,
      timePICMinutes: timePICMinutes ?? this.timePICMinutes,
      timePICUSMinutes: timePICUSMinutes ?? this.timePICUSMinutes,
      timeSICMinutes: timeSICMinutes ?? this.timeSICMinutes,
      timeDualMinutes: timeDualMinutes ?? this.timeDualMinutes,
      timeInstructorMinutes:
          timeInstructorMinutes ?? this.timeInstructorMinutes,
      timeIFRMinutes: timeIFRMinutes ?? this.timeIFRMinutes,
      timeInstrumentMinutes:
          timeInstrumentMinutes ?? this.timeInstrumentMinutes,
      timeSimulatedInstrumentMinutes:
          timeSimulatedInstrumentMinutes ?? this.timeSimulatedInstrumentMinutes,
      timeNightMinutes: timeNightMinutes ?? this.timeNightMinutes,
      timeCrossCountryMinutes:
          timeCrossCountryMinutes ?? this.timeCrossCountryMinutes,
      timeCustom1Minutes: timeCustom1Minutes ?? this.timeCustom1Minutes,
      timeCustom2Minutes: timeCustom2Minutes ?? this.timeCustom2Minutes,
      timeCustom3Minutes: timeCustom3Minutes ?? this.timeCustom3Minutes,
      timeCustom4Minutes: timeCustom4Minutes ?? this.timeCustom4Minutes,
      timeFlightMinutes: timeFlightMinutes ?? this.timeFlightMinutes,
      timeBlockMinutes: timeBlockMinutes ?? this.timeBlockMinutes,
      timeTotalBlockMinutes:
          timeTotalBlockMinutes ?? this.timeTotalBlockMinutes,
      distanceNM: distanceNM ?? this.distanceNM,
      ifrApproaches: ifrApproaches ?? this.ifrApproaches,
      takeOffsDays: takeOffsDays ?? this.takeOffsDays,
      takeOffsNight: takeOffsNight ?? this.takeOffsNight,
      landingsDay: landingsDay ?? this.landingsDay,
      landingsNight: landingsNight ?? this.landingsNight,
      pilotFunction: pilotFunction ?? this.pilotFunction,
      approachType: approachType ?? this.approachType,
      remarks: remarks ?? this.remarks,
      notes: notes ?? this.notes,
      isLocked: isLocked ?? this.isLocked,
      signatureImage: signatureImage ?? this.signatureImage,
      endorsementData: endorsementData ?? this.endorsementData,
      endorsementHash: endorsementHash ?? this.endorsementHash,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (aircraftId.present) {
      map['aircraft_id'] = Variable<int>(aircraftId.value);
    }
    if (departureAirportId.present) {
      map['departure_airport_id'] = Variable<int>(departureAirportId.value);
    }
    if (arrivalAirportId.present) {
      map['arrival_airport_id'] = Variable<int>(arrivalAirportId.value);
    }
    if (departureDateTimeId.present) {
      map['departure_date_time_id'] = Variable<int>(departureDateTimeId.value);
    }
    if (takeOffDateTime.present) {
      map['take_off_date_time'] = Variable<DateTime>(takeOffDateTime.value);
    }
    if (landingDateTime.present) {
      map['landing_date_time'] = Variable<DateTime>(landingDateTime.value);
    }
    if (arrivalDateTime.present) {
      map['arrival_date_time'] = Variable<DateTime>(arrivalDateTime.value);
    }
    if (timePICMinutes.present) {
      map['time_p_i_c_minutes'] = Variable<int>(timePICMinutes.value);
    }
    if (timePICUSMinutes.present) {
      map['time_p_i_c_u_s_minutes'] = Variable<int>(timePICUSMinutes.value);
    }
    if (timeSICMinutes.present) {
      map['time_s_i_c_minutes'] = Variable<int>(timeSICMinutes.value);
    }
    if (timeDualMinutes.present) {
      map['time_dual_minutes'] = Variable<int>(timeDualMinutes.value);
    }
    if (timeInstructorMinutes.present) {
      map['time_instructor_minutes'] = Variable<int>(
        timeInstructorMinutes.value,
      );
    }
    if (timeIFRMinutes.present) {
      map['time_i_f_r_minutes'] = Variable<int>(timeIFRMinutes.value);
    }
    if (timeInstrumentMinutes.present) {
      map['time_instrument_minutes'] = Variable<int>(
        timeInstrumentMinutes.value,
      );
    }
    if (timeSimulatedInstrumentMinutes.present) {
      map['time_simulated_instrument_minutes'] = Variable<int>(
        timeSimulatedInstrumentMinutes.value,
      );
    }
    if (timeNightMinutes.present) {
      map['time_night_minutes'] = Variable<int>(timeNightMinutes.value);
    }
    if (timeCrossCountryMinutes.present) {
      map['time_cross_country_minutes'] = Variable<int>(
        timeCrossCountryMinutes.value,
      );
    }
    if (timeCustom1Minutes.present) {
      map['time_custom1_minutes'] = Variable<int>(timeCustom1Minutes.value);
    }
    if (timeCustom2Minutes.present) {
      map['time_custom2_minutes'] = Variable<int>(timeCustom2Minutes.value);
    }
    if (timeCustom3Minutes.present) {
      map['time_custom3_minutes'] = Variable<int>(timeCustom3Minutes.value);
    }
    if (timeCustom4Minutes.present) {
      map['time_custom4_minutes'] = Variable<int>(timeCustom4Minutes.value);
    }
    if (timeFlightMinutes.present) {
      map['time_flight_minutes'] = Variable<int>(timeFlightMinutes.value);
    }
    if (timeBlockMinutes.present) {
      map['time_block_minutes'] = Variable<int>(timeBlockMinutes.value);
    }
    if (timeTotalBlockMinutes.present) {
      map['time_total_block_minutes'] = Variable<int>(
        timeTotalBlockMinutes.value,
      );
    }
    if (distanceNM.present) {
      map['distance_n_m'] = Variable<int>(distanceNM.value);
    }
    if (ifrApproaches.present) {
      map['ifr_approaches'] = Variable<int>(ifrApproaches.value);
    }
    if (takeOffsDays.present) {
      map['take_offs_days'] = Variable<int>(takeOffsDays.value);
    }
    if (takeOffsNight.present) {
      map['take_offs_night'] = Variable<int>(takeOffsNight.value);
    }
    if (landingsDay.present) {
      map['landings_day'] = Variable<int>(landingsDay.value);
    }
    if (landingsNight.present) {
      map['landings_night'] = Variable<int>(landingsNight.value);
    }
    if (pilotFunction.present) {
      map['pilot_function'] = Variable<String>(
        $FlightsTable.$converterpilotFunction.toSql(pilotFunction.value),
      );
    }
    if (approachType.present) {
      map['approach_type'] = Variable<String>(approachType.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (signatureImage.present) {
      map['signature_image'] = Variable<Uint8List>(signatureImage.value);
    }
    if (endorsementData.present) {
      map['endorsement_data'] = Variable<String>(endorsementData.value);
    }
    if (endorsementHash.present) {
      map['endorsement_hash'] = Variable<String>(endorsementHash.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlightsCompanion(')
          ..write('id: $id, ')
          ..write('aircraftId: $aircraftId, ')
          ..write('departureAirportId: $departureAirportId, ')
          ..write('arrivalAirportId: $arrivalAirportId, ')
          ..write('departureDateTimeId: $departureDateTimeId, ')
          ..write('takeOffDateTime: $takeOffDateTime, ')
          ..write('landingDateTime: $landingDateTime, ')
          ..write('arrivalDateTime: $arrivalDateTime, ')
          ..write('timePICMinutes: $timePICMinutes, ')
          ..write('timePICUSMinutes: $timePICUSMinutes, ')
          ..write('timeSICMinutes: $timeSICMinutes, ')
          ..write('timeDualMinutes: $timeDualMinutes, ')
          ..write('timeInstructorMinutes: $timeInstructorMinutes, ')
          ..write('timeIFRMinutes: $timeIFRMinutes, ')
          ..write('timeInstrumentMinutes: $timeInstrumentMinutes, ')
          ..write(
            'timeSimulatedInstrumentMinutes: $timeSimulatedInstrumentMinutes, ',
          )
          ..write('timeNightMinutes: $timeNightMinutes, ')
          ..write('timeCrossCountryMinutes: $timeCrossCountryMinutes, ')
          ..write('timeCustom1Minutes: $timeCustom1Minutes, ')
          ..write('timeCustom2Minutes: $timeCustom2Minutes, ')
          ..write('timeCustom3Minutes: $timeCustom3Minutes, ')
          ..write('timeCustom4Minutes: $timeCustom4Minutes, ')
          ..write('timeFlightMinutes: $timeFlightMinutes, ')
          ..write('timeBlockMinutes: $timeBlockMinutes, ')
          ..write('timeTotalBlockMinutes: $timeTotalBlockMinutes, ')
          ..write('distanceNM: $distanceNM, ')
          ..write('ifrApproaches: $ifrApproaches, ')
          ..write('takeOffsDays: $takeOffsDays, ')
          ..write('takeOffsNight: $takeOffsNight, ')
          ..write('landingsDay: $landingsDay, ')
          ..write('landingsNight: $landingsNight, ')
          ..write('pilotFunction: $pilotFunction, ')
          ..write('approachType: $approachType, ')
          ..write('remarks: $remarks, ')
          ..write('notes: $notes, ')
          ..write('isLocked: $isLocked, ')
          ..write('signatureImage: $signatureImage, ')
          ..write('endorsementData: $endorsementData, ')
          ..write('endorsementHash: $endorsementHash')
          ..write(')'))
        .toString();
  }
}

class $LimitRulesTable extends LimitRules
    with TableInfo<$LimitRulesTable, LimitRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LimitRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<int> ruleId = GeneratedColumn<int>(
    'rule_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ruleNameMeta = const VerificationMeta(
    'ruleName',
  );
  @override
  late final GeneratedColumn<String> ruleName = GeneratedColumn<String>(
    'rule_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metricMeta = const VerificationMeta('metric');
  @override
  late final GeneratedColumn<String> metric = GeneratedColumn<String>(
    'metric',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleTypeMeta = const VerificationMeta(
    'ruleType',
  );
  @override
  late final GeneratedColumn<String> ruleType = GeneratedColumn<String>(
    'rule_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _windowTypeMeta = const VerificationMeta(
    'windowType',
  );
  @override
  late final GeneratedColumn<String> windowType = GeneratedColumn<String>(
    'window_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _windowValueMeta = const VerificationMeta(
    'windowValue',
  );
  @override
  late final GeneratedColumn<int> windowValue = GeneratedColumn<int>(
    'window_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitValueMeta = const VerificationMeta(
    'limitValue',
  );
  @override
  late final GeneratedColumn<double> limitValue = GeneratedColumn<double>(
    'limit_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitUnitMeta = const VerificationMeta(
    'limitUnit',
  );
  @override
  late final GeneratedColumn<String> limitUnit = GeneratedColumn<String>(
    'limit_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _warnYellowBeforeMeta = const VerificationMeta(
    'warnYellowBefore',
  );
  @override
  late final GeneratedColumn<double> warnYellowBefore = GeneratedColumn<double>(
    'warn_yellow_before',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _warnRedBeforeMeta = const VerificationMeta(
    'warnRedBefore',
  );
  @override
  late final GeneratedColumn<double> warnRedBefore = GeneratedColumn<double>(
    'warn_red_before',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _warnYellowColorMeta = const VerificationMeta(
    'warnYellowColor',
  );
  @override
  late final GeneratedColumn<String> warnYellowColor = GeneratedColumn<String>(
    'warn_yellow_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#FFC107'),
  );
  static const VerificationMeta _warnRedColorMeta = const VerificationMeta(
    'warnRedColor',
  );
  @override
  late final GeneratedColumn<String> warnRedColor = GeneratedColumn<String>(
    'warn_red_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#DC3545'),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ruleId,
    ruleName,
    metric,
    ruleType,
    windowType,
    windowValue,
    limitValue,
    limitUnit,
    warnYellowBefore,
    warnRedBefore,
    warnYellowColor,
    warnRedColor,
    active,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'limit_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<LimitRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    }
    if (data.containsKey('rule_name')) {
      context.handle(
        _ruleNameMeta,
        ruleName.isAcceptableOrUnknown(data['rule_name']!, _ruleNameMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleNameMeta);
    }
    if (data.containsKey('metric')) {
      context.handle(
        _metricMeta,
        metric.isAcceptableOrUnknown(data['metric']!, _metricMeta),
      );
    } else if (isInserting) {
      context.missing(_metricMeta);
    }
    if (data.containsKey('rule_type')) {
      context.handle(
        _ruleTypeMeta,
        ruleType.isAcceptableOrUnknown(data['rule_type']!, _ruleTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleTypeMeta);
    }
    if (data.containsKey('window_type')) {
      context.handle(
        _windowTypeMeta,
        windowType.isAcceptableOrUnknown(data['window_type']!, _windowTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_windowTypeMeta);
    }
    if (data.containsKey('window_value')) {
      context.handle(
        _windowValueMeta,
        windowValue.isAcceptableOrUnknown(
          data['window_value']!,
          _windowValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_windowValueMeta);
    }
    if (data.containsKey('limit_value')) {
      context.handle(
        _limitValueMeta,
        limitValue.isAcceptableOrUnknown(data['limit_value']!, _limitValueMeta),
      );
    } else if (isInserting) {
      context.missing(_limitValueMeta);
    }
    if (data.containsKey('limit_unit')) {
      context.handle(
        _limitUnitMeta,
        limitUnit.isAcceptableOrUnknown(data['limit_unit']!, _limitUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_limitUnitMeta);
    }
    if (data.containsKey('warn_yellow_before')) {
      context.handle(
        _warnYellowBeforeMeta,
        warnYellowBefore.isAcceptableOrUnknown(
          data['warn_yellow_before']!,
          _warnYellowBeforeMeta,
        ),
      );
    }
    if (data.containsKey('warn_red_before')) {
      context.handle(
        _warnRedBeforeMeta,
        warnRedBefore.isAcceptableOrUnknown(
          data['warn_red_before']!,
          _warnRedBeforeMeta,
        ),
      );
    }
    if (data.containsKey('warn_yellow_color')) {
      context.handle(
        _warnYellowColorMeta,
        warnYellowColor.isAcceptableOrUnknown(
          data['warn_yellow_color']!,
          _warnYellowColorMeta,
        ),
      );
    }
    if (data.containsKey('warn_red_color')) {
      context.handle(
        _warnRedColorMeta,
        warnRedColor.isAcceptableOrUnknown(
          data['warn_red_color']!,
          _warnRedColorMeta,
        ),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ruleId};
  @override
  LimitRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LimitRule(
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rule_id'],
      )!,
      ruleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_name'],
      )!,
      metric: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric'],
      )!,
      ruleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_type'],
      )!,
      windowType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}window_type'],
      )!,
      windowValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}window_value'],
      )!,
      limitValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}limit_value'],
      )!,
      limitUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}limit_unit'],
      )!,
      warnYellowBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}warn_yellow_before'],
      )!,
      warnRedBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}warn_red_before'],
      )!,
      warnYellowColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warn_yellow_color'],
      )!,
      warnRedColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}warn_red_color'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $LimitRulesTable createAlias(String alias) {
    return $LimitRulesTable(attachedDatabase, alias);
  }
}

class LimitRule extends DataClass implements Insertable<LimitRule> {
  /// Surrogate primary key.
  final int ruleId;

  /// User-facing rule name.
  final String ruleName;

  /// Metric key (e.g. block, landings).
  final String metric;

  /// Rule semantics (`minimum` or `maximum`).
  final String ruleType;

  /// Window calculation mode descriptor.
  final String windowType;

  /// Window size in units implied by [windowType].
  final int windowValue;

  /// Threshold value in [limitUnit].
  final double limitValue;

  /// Unit label for [limitValue].
  final String limitUnit;

  /// Yellow warning threshold before limit.
  final double warnYellowBefore;

  /// Red warning threshold before/after limit.
  final double warnRedBefore;

  /// UI color for yellow state.
  final String warnYellowColor;

  /// UI color for red state.
  final String warnRedColor;

  /// Whether rule participates in calculations.
  final bool active;

  /// Optional free-form notes.
  final String? notes;
  const LimitRule({
    required this.ruleId,
    required this.ruleName,
    required this.metric,
    required this.ruleType,
    required this.windowType,
    required this.windowValue,
    required this.limitValue,
    required this.limitUnit,
    required this.warnYellowBefore,
    required this.warnRedBefore,
    required this.warnYellowColor,
    required this.warnRedColor,
    required this.active,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['rule_id'] = Variable<int>(ruleId);
    map['rule_name'] = Variable<String>(ruleName);
    map['metric'] = Variable<String>(metric);
    map['rule_type'] = Variable<String>(ruleType);
    map['window_type'] = Variable<String>(windowType);
    map['window_value'] = Variable<int>(windowValue);
    map['limit_value'] = Variable<double>(limitValue);
    map['limit_unit'] = Variable<String>(limitUnit);
    map['warn_yellow_before'] = Variable<double>(warnYellowBefore);
    map['warn_red_before'] = Variable<double>(warnRedBefore);
    map['warn_yellow_color'] = Variable<String>(warnYellowColor);
    map['warn_red_color'] = Variable<String>(warnRedColor);
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  LimitRulesCompanion toCompanion(bool nullToAbsent) {
    return LimitRulesCompanion(
      ruleId: Value(ruleId),
      ruleName: Value(ruleName),
      metric: Value(metric),
      ruleType: Value(ruleType),
      windowType: Value(windowType),
      windowValue: Value(windowValue),
      limitValue: Value(limitValue),
      limitUnit: Value(limitUnit),
      warnYellowBefore: Value(warnYellowBefore),
      warnRedBefore: Value(warnRedBefore),
      warnYellowColor: Value(warnYellowColor),
      warnRedColor: Value(warnRedColor),
      active: Value(active),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory LimitRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LimitRule(
      ruleId: serializer.fromJson<int>(json['ruleId']),
      ruleName: serializer.fromJson<String>(json['ruleName']),
      metric: serializer.fromJson<String>(json['metric']),
      ruleType: serializer.fromJson<String>(json['ruleType']),
      windowType: serializer.fromJson<String>(json['windowType']),
      windowValue: serializer.fromJson<int>(json['windowValue']),
      limitValue: serializer.fromJson<double>(json['limitValue']),
      limitUnit: serializer.fromJson<String>(json['limitUnit']),
      warnYellowBefore: serializer.fromJson<double>(json['warnYellowBefore']),
      warnRedBefore: serializer.fromJson<double>(json['warnRedBefore']),
      warnYellowColor: serializer.fromJson<String>(json['warnYellowColor']),
      warnRedColor: serializer.fromJson<String>(json['warnRedColor']),
      active: serializer.fromJson<bool>(json['active']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ruleId': serializer.toJson<int>(ruleId),
      'ruleName': serializer.toJson<String>(ruleName),
      'metric': serializer.toJson<String>(metric),
      'ruleType': serializer.toJson<String>(ruleType),
      'windowType': serializer.toJson<String>(windowType),
      'windowValue': serializer.toJson<int>(windowValue),
      'limitValue': serializer.toJson<double>(limitValue),
      'limitUnit': serializer.toJson<String>(limitUnit),
      'warnYellowBefore': serializer.toJson<double>(warnYellowBefore),
      'warnRedBefore': serializer.toJson<double>(warnRedBefore),
      'warnYellowColor': serializer.toJson<String>(warnYellowColor),
      'warnRedColor': serializer.toJson<String>(warnRedColor),
      'active': serializer.toJson<bool>(active),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  LimitRule copyWith({
    int? ruleId,
    String? ruleName,
    String? metric,
    String? ruleType,
    String? windowType,
    int? windowValue,
    double? limitValue,
    String? limitUnit,
    double? warnYellowBefore,
    double? warnRedBefore,
    String? warnYellowColor,
    String? warnRedColor,
    bool? active,
    Value<String?> notes = const Value.absent(),
  }) => LimitRule(
    ruleId: ruleId ?? this.ruleId,
    ruleName: ruleName ?? this.ruleName,
    metric: metric ?? this.metric,
    ruleType: ruleType ?? this.ruleType,
    windowType: windowType ?? this.windowType,
    windowValue: windowValue ?? this.windowValue,
    limitValue: limitValue ?? this.limitValue,
    limitUnit: limitUnit ?? this.limitUnit,
    warnYellowBefore: warnYellowBefore ?? this.warnYellowBefore,
    warnRedBefore: warnRedBefore ?? this.warnRedBefore,
    warnYellowColor: warnYellowColor ?? this.warnYellowColor,
    warnRedColor: warnRedColor ?? this.warnRedColor,
    active: active ?? this.active,
    notes: notes.present ? notes.value : this.notes,
  );
  LimitRule copyWithCompanion(LimitRulesCompanion data) {
    return LimitRule(
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      ruleName: data.ruleName.present ? data.ruleName.value : this.ruleName,
      metric: data.metric.present ? data.metric.value : this.metric,
      ruleType: data.ruleType.present ? data.ruleType.value : this.ruleType,
      windowType: data.windowType.present
          ? data.windowType.value
          : this.windowType,
      windowValue: data.windowValue.present
          ? data.windowValue.value
          : this.windowValue,
      limitValue: data.limitValue.present
          ? data.limitValue.value
          : this.limitValue,
      limitUnit: data.limitUnit.present ? data.limitUnit.value : this.limitUnit,
      warnYellowBefore: data.warnYellowBefore.present
          ? data.warnYellowBefore.value
          : this.warnYellowBefore,
      warnRedBefore: data.warnRedBefore.present
          ? data.warnRedBefore.value
          : this.warnRedBefore,
      warnYellowColor: data.warnYellowColor.present
          ? data.warnYellowColor.value
          : this.warnYellowColor,
      warnRedColor: data.warnRedColor.present
          ? data.warnRedColor.value
          : this.warnRedColor,
      active: data.active.present ? data.active.value : this.active,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LimitRule(')
          ..write('ruleId: $ruleId, ')
          ..write('ruleName: $ruleName, ')
          ..write('metric: $metric, ')
          ..write('ruleType: $ruleType, ')
          ..write('windowType: $windowType, ')
          ..write('windowValue: $windowValue, ')
          ..write('limitValue: $limitValue, ')
          ..write('limitUnit: $limitUnit, ')
          ..write('warnYellowBefore: $warnYellowBefore, ')
          ..write('warnRedBefore: $warnRedBefore, ')
          ..write('warnYellowColor: $warnYellowColor, ')
          ..write('warnRedColor: $warnRedColor, ')
          ..write('active: $active, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ruleId,
    ruleName,
    metric,
    ruleType,
    windowType,
    windowValue,
    limitValue,
    limitUnit,
    warnYellowBefore,
    warnRedBefore,
    warnYellowColor,
    warnRedColor,
    active,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LimitRule &&
          other.ruleId == this.ruleId &&
          other.ruleName == this.ruleName &&
          other.metric == this.metric &&
          other.ruleType == this.ruleType &&
          other.windowType == this.windowType &&
          other.windowValue == this.windowValue &&
          other.limitValue == this.limitValue &&
          other.limitUnit == this.limitUnit &&
          other.warnYellowBefore == this.warnYellowBefore &&
          other.warnRedBefore == this.warnRedBefore &&
          other.warnYellowColor == this.warnYellowColor &&
          other.warnRedColor == this.warnRedColor &&
          other.active == this.active &&
          other.notes == this.notes);
}

class LimitRulesCompanion extends UpdateCompanion<LimitRule> {
  final Value<int> ruleId;
  final Value<String> ruleName;
  final Value<String> metric;
  final Value<String> ruleType;
  final Value<String> windowType;
  final Value<int> windowValue;
  final Value<double> limitValue;
  final Value<String> limitUnit;
  final Value<double> warnYellowBefore;
  final Value<double> warnRedBefore;
  final Value<String> warnYellowColor;
  final Value<String> warnRedColor;
  final Value<bool> active;
  final Value<String?> notes;
  const LimitRulesCompanion({
    this.ruleId = const Value.absent(),
    this.ruleName = const Value.absent(),
    this.metric = const Value.absent(),
    this.ruleType = const Value.absent(),
    this.windowType = const Value.absent(),
    this.windowValue = const Value.absent(),
    this.limitValue = const Value.absent(),
    this.limitUnit = const Value.absent(),
    this.warnYellowBefore = const Value.absent(),
    this.warnRedBefore = const Value.absent(),
    this.warnYellowColor = const Value.absent(),
    this.warnRedColor = const Value.absent(),
    this.active = const Value.absent(),
    this.notes = const Value.absent(),
  });
  LimitRulesCompanion.insert({
    this.ruleId = const Value.absent(),
    required String ruleName,
    required String metric,
    required String ruleType,
    required String windowType,
    required int windowValue,
    required double limitValue,
    required String limitUnit,
    this.warnYellowBefore = const Value.absent(),
    this.warnRedBefore = const Value.absent(),
    this.warnYellowColor = const Value.absent(),
    this.warnRedColor = const Value.absent(),
    this.active = const Value.absent(),
    this.notes = const Value.absent(),
  }) : ruleName = Value(ruleName),
       metric = Value(metric),
       ruleType = Value(ruleType),
       windowType = Value(windowType),
       windowValue = Value(windowValue),
       limitValue = Value(limitValue),
       limitUnit = Value(limitUnit);
  static Insertable<LimitRule> custom({
    Expression<int>? ruleId,
    Expression<String>? ruleName,
    Expression<String>? metric,
    Expression<String>? ruleType,
    Expression<String>? windowType,
    Expression<int>? windowValue,
    Expression<double>? limitValue,
    Expression<String>? limitUnit,
    Expression<double>? warnYellowBefore,
    Expression<double>? warnRedBefore,
    Expression<String>? warnYellowColor,
    Expression<String>? warnRedColor,
    Expression<bool>? active,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (ruleId != null) 'rule_id': ruleId,
      if (ruleName != null) 'rule_name': ruleName,
      if (metric != null) 'metric': metric,
      if (ruleType != null) 'rule_type': ruleType,
      if (windowType != null) 'window_type': windowType,
      if (windowValue != null) 'window_value': windowValue,
      if (limitValue != null) 'limit_value': limitValue,
      if (limitUnit != null) 'limit_unit': limitUnit,
      if (warnYellowBefore != null) 'warn_yellow_before': warnYellowBefore,
      if (warnRedBefore != null) 'warn_red_before': warnRedBefore,
      if (warnYellowColor != null) 'warn_yellow_color': warnYellowColor,
      if (warnRedColor != null) 'warn_red_color': warnRedColor,
      if (active != null) 'active': active,
      if (notes != null) 'notes': notes,
    });
  }

  LimitRulesCompanion copyWith({
    Value<int>? ruleId,
    Value<String>? ruleName,
    Value<String>? metric,
    Value<String>? ruleType,
    Value<String>? windowType,
    Value<int>? windowValue,
    Value<double>? limitValue,
    Value<String>? limitUnit,
    Value<double>? warnYellowBefore,
    Value<double>? warnRedBefore,
    Value<String>? warnYellowColor,
    Value<String>? warnRedColor,
    Value<bool>? active,
    Value<String?>? notes,
  }) {
    return LimitRulesCompanion(
      ruleId: ruleId ?? this.ruleId,
      ruleName: ruleName ?? this.ruleName,
      metric: metric ?? this.metric,
      ruleType: ruleType ?? this.ruleType,
      windowType: windowType ?? this.windowType,
      windowValue: windowValue ?? this.windowValue,
      limitValue: limitValue ?? this.limitValue,
      limitUnit: limitUnit ?? this.limitUnit,
      warnYellowBefore: warnYellowBefore ?? this.warnYellowBefore,
      warnRedBefore: warnRedBefore ?? this.warnRedBefore,
      warnYellowColor: warnYellowColor ?? this.warnYellowColor,
      warnRedColor: warnRedColor ?? this.warnRedColor,
      active: active ?? this.active,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ruleId.present) {
      map['rule_id'] = Variable<int>(ruleId.value);
    }
    if (ruleName.present) {
      map['rule_name'] = Variable<String>(ruleName.value);
    }
    if (metric.present) {
      map['metric'] = Variable<String>(metric.value);
    }
    if (ruleType.present) {
      map['rule_type'] = Variable<String>(ruleType.value);
    }
    if (windowType.present) {
      map['window_type'] = Variable<String>(windowType.value);
    }
    if (windowValue.present) {
      map['window_value'] = Variable<int>(windowValue.value);
    }
    if (limitValue.present) {
      map['limit_value'] = Variable<double>(limitValue.value);
    }
    if (limitUnit.present) {
      map['limit_unit'] = Variable<String>(limitUnit.value);
    }
    if (warnYellowBefore.present) {
      map['warn_yellow_before'] = Variable<double>(warnYellowBefore.value);
    }
    if (warnRedBefore.present) {
      map['warn_red_before'] = Variable<double>(warnRedBefore.value);
    }
    if (warnYellowColor.present) {
      map['warn_yellow_color'] = Variable<String>(warnYellowColor.value);
    }
    if (warnRedColor.present) {
      map['warn_red_color'] = Variable<String>(warnRedColor.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LimitRulesCompanion(')
          ..write('ruleId: $ruleId, ')
          ..write('ruleName: $ruleName, ')
          ..write('metric: $metric, ')
          ..write('ruleType: $ruleType, ')
          ..write('windowType: $windowType, ')
          ..write('windowValue: $windowValue, ')
          ..write('limitValue: $limitValue, ')
          ..write('limitUnit: $limitUnit, ')
          ..write('warnYellowBefore: $warnYellowBefore, ')
          ..write('warnRedBefore: $warnRedBefore, ')
          ..write('warnYellowColor: $warnYellowColor, ')
          ..write('warnRedColor: $warnRedColor, ')
          ..write('active: $active, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $RuleSnapshotsTable extends RuleSnapshots
    with TableInfo<$RuleSnapshotsTable, RuleSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RuleSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _snapshotIdMeta = const VerificationMeta(
    'snapshotId',
  );
  @override
  late final GeneratedColumn<int> snapshotId = GeneratedColumn<int>(
    'snapshot_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<int> ruleId = GeneratedColumn<int>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES limit_rules (rule_id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _computedAtMeta = const VerificationMeta(
    'computedAt',
  );
  @override
  late final GeneratedColumn<DateTime> computedAt = GeneratedColumn<DateTime>(
    'computed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _currentValueMeta = const VerificationMeta(
    'currentValue',
  );
  @override
  late final GeneratedColumn<double> currentValue = GeneratedColumn<double>(
    'current_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    snapshotId,
    ruleId,
    computedAt,
    currentValue,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rule_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<RuleSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('snapshot_id')) {
      context.handle(
        _snapshotIdMeta,
        snapshotId.isAcceptableOrUnknown(data['snapshot_id']!, _snapshotIdMeta),
      );
    }
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('computed_at')) {
      context.handle(
        _computedAtMeta,
        computedAt.isAcceptableOrUnknown(data['computed_at']!, _computedAtMeta),
      );
    }
    if (data.containsKey('current_value')) {
      context.handle(
        _currentValueMeta,
        currentValue.isAcceptableOrUnknown(
          data['current_value']!,
          _currentValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentValueMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {snapshotId};
  @override
  RuleSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RuleSnapshot(
      snapshotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snapshot_id'],
      )!,
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rule_id'],
      )!,
      computedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}computed_at'],
      )!,
      currentValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_value'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $RuleSnapshotsTable createAlias(String alias) {
    return $RuleSnapshotsTable(attachedDatabase, alias);
  }
}

class RuleSnapshot extends DataClass implements Insertable<RuleSnapshot> {
  /// Primary key for a snapshot row.
  final int snapshotId;

  /// Foreign key to the rule that produced this snapshot.
  final int ruleId;

  /// UTC timestamp when this snapshot was computed.
  final DateTime computedAt;

  /// Numeric value measured for the rule at [computedAt].
  final double currentValue;

  /// Evaluation status persisted as text (for example pass or fail).
  final String status;
  const RuleSnapshot({
    required this.snapshotId,
    required this.ruleId,
    required this.computedAt,
    required this.currentValue,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['snapshot_id'] = Variable<int>(snapshotId);
    map['rule_id'] = Variable<int>(ruleId);
    map['computed_at'] = Variable<DateTime>(computedAt);
    map['current_value'] = Variable<double>(currentValue);
    map['status'] = Variable<String>(status);
    return map;
  }

  RuleSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return RuleSnapshotsCompanion(
      snapshotId: Value(snapshotId),
      ruleId: Value(ruleId),
      computedAt: Value(computedAt),
      currentValue: Value(currentValue),
      status: Value(status),
    );
  }

  factory RuleSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RuleSnapshot(
      snapshotId: serializer.fromJson<int>(json['snapshotId']),
      ruleId: serializer.fromJson<int>(json['ruleId']),
      computedAt: serializer.fromJson<DateTime>(json['computedAt']),
      currentValue: serializer.fromJson<double>(json['currentValue']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'snapshotId': serializer.toJson<int>(snapshotId),
      'ruleId': serializer.toJson<int>(ruleId),
      'computedAt': serializer.toJson<DateTime>(computedAt),
      'currentValue': serializer.toJson<double>(currentValue),
      'status': serializer.toJson<String>(status),
    };
  }

  RuleSnapshot copyWith({
    int? snapshotId,
    int? ruleId,
    DateTime? computedAt,
    double? currentValue,
    String? status,
  }) => RuleSnapshot(
    snapshotId: snapshotId ?? this.snapshotId,
    ruleId: ruleId ?? this.ruleId,
    computedAt: computedAt ?? this.computedAt,
    currentValue: currentValue ?? this.currentValue,
    status: status ?? this.status,
  );
  RuleSnapshot copyWithCompanion(RuleSnapshotsCompanion data) {
    return RuleSnapshot(
      snapshotId: data.snapshotId.present
          ? data.snapshotId.value
          : this.snapshotId,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      computedAt: data.computedAt.present
          ? data.computedAt.value
          : this.computedAt,
      currentValue: data.currentValue.present
          ? data.currentValue.value
          : this.currentValue,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RuleSnapshot(')
          ..write('snapshotId: $snapshotId, ')
          ..write('ruleId: $ruleId, ')
          ..write('computedAt: $computedAt, ')
          ..write('currentValue: $currentValue, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(snapshotId, ruleId, computedAt, currentValue, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RuleSnapshot &&
          other.snapshotId == this.snapshotId &&
          other.ruleId == this.ruleId &&
          other.computedAt == this.computedAt &&
          other.currentValue == this.currentValue &&
          other.status == this.status);
}

class RuleSnapshotsCompanion extends UpdateCompanion<RuleSnapshot> {
  final Value<int> snapshotId;
  final Value<int> ruleId;
  final Value<DateTime> computedAt;
  final Value<double> currentValue;
  final Value<String> status;
  const RuleSnapshotsCompanion({
    this.snapshotId = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.computedAt = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.status = const Value.absent(),
  });
  RuleSnapshotsCompanion.insert({
    this.snapshotId = const Value.absent(),
    required int ruleId,
    this.computedAt = const Value.absent(),
    required double currentValue,
    required String status,
  }) : ruleId = Value(ruleId),
       currentValue = Value(currentValue),
       status = Value(status);
  static Insertable<RuleSnapshot> custom({
    Expression<int>? snapshotId,
    Expression<int>? ruleId,
    Expression<DateTime>? computedAt,
    Expression<double>? currentValue,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (snapshotId != null) 'snapshot_id': snapshotId,
      if (ruleId != null) 'rule_id': ruleId,
      if (computedAt != null) 'computed_at': computedAt,
      if (currentValue != null) 'current_value': currentValue,
      if (status != null) 'status': status,
    });
  }

  RuleSnapshotsCompanion copyWith({
    Value<int>? snapshotId,
    Value<int>? ruleId,
    Value<DateTime>? computedAt,
    Value<double>? currentValue,
    Value<String>? status,
  }) {
    return RuleSnapshotsCompanion(
      snapshotId: snapshotId ?? this.snapshotId,
      ruleId: ruleId ?? this.ruleId,
      computedAt: computedAt ?? this.computedAt,
      currentValue: currentValue ?? this.currentValue,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (snapshotId.present) {
      map['snapshot_id'] = Variable<int>(snapshotId.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<int>(ruleId.value);
    }
    if (computedAt.present) {
      map['computed_at'] = Variable<DateTime>(computedAt.value);
    }
    if (currentValue.present) {
      map['current_value'] = Variable<double>(currentValue.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RuleSnapshotsCompanion(')
          ..write('snapshotId: $snapshotId, ')
          ..write('ruleId: $ruleId, ')
          ..write('computedAt: $computedAt, ')
          ..write('currentValue: $currentValue, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $PositioningsTable extends Positionings
    with TableInfo<$PositioningsTable, Positioning> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PositioningsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _departurePlaceIdMeta = const VerificationMeta(
    'departurePlaceId',
  );
  @override
  late final GeneratedColumn<int> departurePlaceId = GeneratedColumn<int>(
    'departure_place_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES airports (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _arrivalPlaceIdMeta = const VerificationMeta(
    'arrivalPlaceId',
  );
  @override
  late final GeneratedColumn<int> arrivalPlaceId = GeneratedColumn<int>(
    'arrival_place_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES airports (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _departureDateTimeIdMeta =
      const VerificationMeta('departureDateTimeId');
  @override
  late final GeneratedColumn<int> departureDateTimeId = GeneratedColumn<int>(
    'departure_date_time_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES time_lines (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _arrivalDateTimeMeta = const VerificationMeta(
    'arrivalDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> arrivalDateTime =
      GeneratedColumn<DateTime>(
        'arrival_date_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _timeTotalMinutesMeta = const VerificationMeta(
    'timeTotalMinutes',
  );
  @override
  late final GeneratedColumn<int> timeTotalMinutes = GeneratedColumn<int>(
    'time_total_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    departurePlaceId,
    arrivalPlaceId,
    departureDateTimeId,
    arrivalDateTime,
    timeTotalMinutes,
    notes,
    isLocked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'positionings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Positioning> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('departure_place_id')) {
      context.handle(
        _departurePlaceIdMeta,
        departurePlaceId.isAcceptableOrUnknown(
          data['departure_place_id']!,
          _departurePlaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departurePlaceIdMeta);
    }
    if (data.containsKey('arrival_place_id')) {
      context.handle(
        _arrivalPlaceIdMeta,
        arrivalPlaceId.isAcceptableOrUnknown(
          data['arrival_place_id']!,
          _arrivalPlaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_arrivalPlaceIdMeta);
    }
    if (data.containsKey('departure_date_time_id')) {
      context.handle(
        _departureDateTimeIdMeta,
        departureDateTimeId.isAcceptableOrUnknown(
          data['departure_date_time_id']!,
          _departureDateTimeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departureDateTimeIdMeta);
    }
    if (data.containsKey('arrival_date_time')) {
      context.handle(
        _arrivalDateTimeMeta,
        arrivalDateTime.isAcceptableOrUnknown(
          data['arrival_date_time']!,
          _arrivalDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('time_total_minutes')) {
      context.handle(
        _timeTotalMinutesMeta,
        timeTotalMinutes.isAcceptableOrUnknown(
          data['time_total_minutes']!,
          _timeTotalMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeTotalMinutesMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    } else if (isInserting) {
      context.missing(_isLockedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Positioning map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Positioning(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      departurePlaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}departure_place_id'],
      )!,
      arrivalPlaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}arrival_place_id'],
      )!,
      departureDateTimeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}departure_date_time_id'],
      )!,
      arrivalDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}arrival_date_time'],
      ),
      timeTotalMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_total_minutes'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
    );
  }

  @override
  $PositioningsTable createAlias(String alias) {
    return $PositioningsTable(attachedDatabase, alias);
  }
}

class Positioning extends DataClass implements Insertable<Positioning> {
  /// Surrogate primary key.
  final int id;

  /// Departure airport id.
  final int departurePlaceId;

  /// Arrival airport id.
  final int arrivalPlaceId;

  /// Timeline reference for departure datetime.
  final int departureDateTimeId;

  /// Optional arrival datetime.
  final DateTime? arrivalDateTime;

  /// Total positioning time in minutes.
  final int timeTotalMinutes;

  /// Optional notes.
  final String notes;

  /// Lock flag preventing edits.
  final bool isLocked;
  const Positioning({
    required this.id,
    required this.departurePlaceId,
    required this.arrivalPlaceId,
    required this.departureDateTimeId,
    this.arrivalDateTime,
    required this.timeTotalMinutes,
    required this.notes,
    required this.isLocked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['departure_place_id'] = Variable<int>(departurePlaceId);
    map['arrival_place_id'] = Variable<int>(arrivalPlaceId);
    map['departure_date_time_id'] = Variable<int>(departureDateTimeId);
    if (!nullToAbsent || arrivalDateTime != null) {
      map['arrival_date_time'] = Variable<DateTime>(arrivalDateTime);
    }
    map['time_total_minutes'] = Variable<int>(timeTotalMinutes);
    map['notes'] = Variable<String>(notes);
    map['is_locked'] = Variable<bool>(isLocked);
    return map;
  }

  PositioningsCompanion toCompanion(bool nullToAbsent) {
    return PositioningsCompanion(
      id: Value(id),
      departurePlaceId: Value(departurePlaceId),
      arrivalPlaceId: Value(arrivalPlaceId),
      departureDateTimeId: Value(departureDateTimeId),
      arrivalDateTime: arrivalDateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(arrivalDateTime),
      timeTotalMinutes: Value(timeTotalMinutes),
      notes: Value(notes),
      isLocked: Value(isLocked),
    );
  }

  factory Positioning.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Positioning(
      id: serializer.fromJson<int>(json['id']),
      departurePlaceId: serializer.fromJson<int>(json['departurePlaceId']),
      arrivalPlaceId: serializer.fromJson<int>(json['arrivalPlaceId']),
      departureDateTimeId: serializer.fromJson<int>(
        json['departureDateTimeId'],
      ),
      arrivalDateTime: serializer.fromJson<DateTime?>(json['arrivalDateTime']),
      timeTotalMinutes: serializer.fromJson<int>(json['timeTotalMinutes']),
      notes: serializer.fromJson<String>(json['notes']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'departurePlaceId': serializer.toJson<int>(departurePlaceId),
      'arrivalPlaceId': serializer.toJson<int>(arrivalPlaceId),
      'departureDateTimeId': serializer.toJson<int>(departureDateTimeId),
      'arrivalDateTime': serializer.toJson<DateTime?>(arrivalDateTime),
      'timeTotalMinutes': serializer.toJson<int>(timeTotalMinutes),
      'notes': serializer.toJson<String>(notes),
      'isLocked': serializer.toJson<bool>(isLocked),
    };
  }

  Positioning copyWith({
    int? id,
    int? departurePlaceId,
    int? arrivalPlaceId,
    int? departureDateTimeId,
    Value<DateTime?> arrivalDateTime = const Value.absent(),
    int? timeTotalMinutes,
    String? notes,
    bool? isLocked,
  }) => Positioning(
    id: id ?? this.id,
    departurePlaceId: departurePlaceId ?? this.departurePlaceId,
    arrivalPlaceId: arrivalPlaceId ?? this.arrivalPlaceId,
    departureDateTimeId: departureDateTimeId ?? this.departureDateTimeId,
    arrivalDateTime: arrivalDateTime.present
        ? arrivalDateTime.value
        : this.arrivalDateTime,
    timeTotalMinutes: timeTotalMinutes ?? this.timeTotalMinutes,
    notes: notes ?? this.notes,
    isLocked: isLocked ?? this.isLocked,
  );
  Positioning copyWithCompanion(PositioningsCompanion data) {
    return Positioning(
      id: data.id.present ? data.id.value : this.id,
      departurePlaceId: data.departurePlaceId.present
          ? data.departurePlaceId.value
          : this.departurePlaceId,
      arrivalPlaceId: data.arrivalPlaceId.present
          ? data.arrivalPlaceId.value
          : this.arrivalPlaceId,
      departureDateTimeId: data.departureDateTimeId.present
          ? data.departureDateTimeId.value
          : this.departureDateTimeId,
      arrivalDateTime: data.arrivalDateTime.present
          ? data.arrivalDateTime.value
          : this.arrivalDateTime,
      timeTotalMinutes: data.timeTotalMinutes.present
          ? data.timeTotalMinutes.value
          : this.timeTotalMinutes,
      notes: data.notes.present ? data.notes.value : this.notes,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Positioning(')
          ..write('id: $id, ')
          ..write('departurePlaceId: $departurePlaceId, ')
          ..write('arrivalPlaceId: $arrivalPlaceId, ')
          ..write('departureDateTimeId: $departureDateTimeId, ')
          ..write('arrivalDateTime: $arrivalDateTime, ')
          ..write('timeTotalMinutes: $timeTotalMinutes, ')
          ..write('notes: $notes, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    departurePlaceId,
    arrivalPlaceId,
    departureDateTimeId,
    arrivalDateTime,
    timeTotalMinutes,
    notes,
    isLocked,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Positioning &&
          other.id == this.id &&
          other.departurePlaceId == this.departurePlaceId &&
          other.arrivalPlaceId == this.arrivalPlaceId &&
          other.departureDateTimeId == this.departureDateTimeId &&
          other.arrivalDateTime == this.arrivalDateTime &&
          other.timeTotalMinutes == this.timeTotalMinutes &&
          other.notes == this.notes &&
          other.isLocked == this.isLocked);
}

class PositioningsCompanion extends UpdateCompanion<Positioning> {
  final Value<int> id;
  final Value<int> departurePlaceId;
  final Value<int> arrivalPlaceId;
  final Value<int> departureDateTimeId;
  final Value<DateTime?> arrivalDateTime;
  final Value<int> timeTotalMinutes;
  final Value<String> notes;
  final Value<bool> isLocked;
  const PositioningsCompanion({
    this.id = const Value.absent(),
    this.departurePlaceId = const Value.absent(),
    this.arrivalPlaceId = const Value.absent(),
    this.departureDateTimeId = const Value.absent(),
    this.arrivalDateTime = const Value.absent(),
    this.timeTotalMinutes = const Value.absent(),
    this.notes = const Value.absent(),
    this.isLocked = const Value.absent(),
  });
  PositioningsCompanion.insert({
    this.id = const Value.absent(),
    required int departurePlaceId,
    required int arrivalPlaceId,
    required int departureDateTimeId,
    this.arrivalDateTime = const Value.absent(),
    required int timeTotalMinutes,
    this.notes = const Value.absent(),
    required bool isLocked,
  }) : departurePlaceId = Value(departurePlaceId),
       arrivalPlaceId = Value(arrivalPlaceId),
       departureDateTimeId = Value(departureDateTimeId),
       timeTotalMinutes = Value(timeTotalMinutes),
       isLocked = Value(isLocked);
  static Insertable<Positioning> custom({
    Expression<int>? id,
    Expression<int>? departurePlaceId,
    Expression<int>? arrivalPlaceId,
    Expression<int>? departureDateTimeId,
    Expression<DateTime>? arrivalDateTime,
    Expression<int>? timeTotalMinutes,
    Expression<String>? notes,
    Expression<bool>? isLocked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (departurePlaceId != null) 'departure_place_id': departurePlaceId,
      if (arrivalPlaceId != null) 'arrival_place_id': arrivalPlaceId,
      if (departureDateTimeId != null)
        'departure_date_time_id': departureDateTimeId,
      if (arrivalDateTime != null) 'arrival_date_time': arrivalDateTime,
      if (timeTotalMinutes != null) 'time_total_minutes': timeTotalMinutes,
      if (notes != null) 'notes': notes,
      if (isLocked != null) 'is_locked': isLocked,
    });
  }

  PositioningsCompanion copyWith({
    Value<int>? id,
    Value<int>? departurePlaceId,
    Value<int>? arrivalPlaceId,
    Value<int>? departureDateTimeId,
    Value<DateTime?>? arrivalDateTime,
    Value<int>? timeTotalMinutes,
    Value<String>? notes,
    Value<bool>? isLocked,
  }) {
    return PositioningsCompanion(
      id: id ?? this.id,
      departurePlaceId: departurePlaceId ?? this.departurePlaceId,
      arrivalPlaceId: arrivalPlaceId ?? this.arrivalPlaceId,
      departureDateTimeId: departureDateTimeId ?? this.departureDateTimeId,
      arrivalDateTime: arrivalDateTime ?? this.arrivalDateTime,
      timeTotalMinutes: timeTotalMinutes ?? this.timeTotalMinutes,
      notes: notes ?? this.notes,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (departurePlaceId.present) {
      map['departure_place_id'] = Variable<int>(departurePlaceId.value);
    }
    if (arrivalPlaceId.present) {
      map['arrival_place_id'] = Variable<int>(arrivalPlaceId.value);
    }
    if (departureDateTimeId.present) {
      map['departure_date_time_id'] = Variable<int>(departureDateTimeId.value);
    }
    if (arrivalDateTime.present) {
      map['arrival_date_time'] = Variable<DateTime>(arrivalDateTime.value);
    }
    if (timeTotalMinutes.present) {
      map['time_total_minutes'] = Variable<int>(timeTotalMinutes.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PositioningsCompanion(')
          ..write('id: $id, ')
          ..write('departurePlaceId: $departurePlaceId, ')
          ..write('arrivalPlaceId: $arrivalPlaceId, ')
          ..write('departureDateTimeId: $departureDateTimeId, ')
          ..write('arrivalDateTime: $arrivalDateTime, ')
          ..write('timeTotalMinutes: $timeTotalMinutes, ')
          ..write('notes: $notes, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }
}

class $PreviousExperiencesTable extends PreviousExperiences
    with TableInfo<$PreviousExperiencesTable, PreviousExperience> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreviousExperiencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _aircraftTypeIdMeta = const VerificationMeta(
    'aircraftTypeId',
  );
  @override
  late final GeneratedColumn<int> aircraftTypeId = GeneratedColumn<int>(
    'aircraft_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES aircraft_types (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _dateTimeFirstFlightMeta =
      const VerificationMeta('dateTimeFirstFlight');
  @override
  late final GeneratedColumn<DateTime> dateTimeFirstFlight =
      GeneratedColumn<DateTime>(
        'date_time_first_flight',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dateTimeLastFlightMeta =
      const VerificationMeta('dateTimeLastFlight');
  @override
  late final GeneratedColumn<DateTime> dateTimeLastFlight =
      GeneratedColumn<DateTime>(
        'date_time_last_flight',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _timePICMinutesMeta = const VerificationMeta(
    'timePICMinutes',
  );
  @override
  late final GeneratedColumn<int> timePICMinutes = GeneratedColumn<int>(
    'time_p_i_c_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timePICUSMinutesMeta = const VerificationMeta(
    'timePICUSMinutes',
  );
  @override
  late final GeneratedColumn<int> timePICUSMinutes = GeneratedColumn<int>(
    'time_p_i_c_u_s_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeSICMinutesMeta = const VerificationMeta(
    'timeSICMinutes',
  );
  @override
  late final GeneratedColumn<int> timeSICMinutes = GeneratedColumn<int>(
    'time_s_i_c_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeDualMinutesMeta = const VerificationMeta(
    'timeDualMinutes',
  );
  @override
  late final GeneratedColumn<int> timeDualMinutes = GeneratedColumn<int>(
    'time_dual_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeInstructorMinutesMeta =
      const VerificationMeta('timeInstructorMinutes');
  @override
  late final GeneratedColumn<int> timeInstructorMinutes = GeneratedColumn<int>(
    'time_instructor_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeIFRMinutesMeta = const VerificationMeta(
    'timeIFRMinutes',
  );
  @override
  late final GeneratedColumn<int> timeIFRMinutes = GeneratedColumn<int>(
    'time_i_f_r_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeInstrumentMinutesMeta =
      const VerificationMeta('timeInstrumentMinutes');
  @override
  late final GeneratedColumn<int> timeInstrumentMinutes = GeneratedColumn<int>(
    'time_instrument_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeSimulatedInstrumentMinutesMeta =
      const VerificationMeta('timeSimulatedInstrumentMinutes');
  @override
  late final GeneratedColumn<int> timeSimulatedInstrumentMinutes =
      GeneratedColumn<int>(
        'time_simulated_instrument_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _timeNightMinutesMeta = const VerificationMeta(
    'timeNightMinutes',
  );
  @override
  late final GeneratedColumn<int> timeNightMinutes = GeneratedColumn<int>(
    'time_night_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeCrossCountryMinutesMeta =
      const VerificationMeta('timeCrossCountryMinutes');
  @override
  late final GeneratedColumn<int> timeCrossCountryMinutes =
      GeneratedColumn<int>(
        'time_cross_country_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _timeCustom1MinutesMeta =
      const VerificationMeta('timeCustom1Minutes');
  @override
  late final GeneratedColumn<int> timeCustom1Minutes = GeneratedColumn<int>(
    'time_custom1_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeCustom2MinutesMeta =
      const VerificationMeta('timeCustom2Minutes');
  @override
  late final GeneratedColumn<int> timeCustom2Minutes = GeneratedColumn<int>(
    'time_custom2_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeCustom3MinutesMeta =
      const VerificationMeta('timeCustom3Minutes');
  @override
  late final GeneratedColumn<int> timeCustom3Minutes = GeneratedColumn<int>(
    'time_custom3_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeCustom4MinutesMeta =
      const VerificationMeta('timeCustom4Minutes');
  @override
  late final GeneratedColumn<int> timeCustom4Minutes = GeneratedColumn<int>(
    'time_custom4_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeFlightMinutesMeta = const VerificationMeta(
    'timeFlightMinutes',
  );
  @override
  late final GeneratedColumn<int> timeFlightMinutes = GeneratedColumn<int>(
    'time_flight_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeBlockMinutesMeta = const VerificationMeta(
    'timeBlockMinutes',
  );
  @override
  late final GeneratedColumn<int> timeBlockMinutes = GeneratedColumn<int>(
    'time_block_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeSimulatorMinutesMeta =
      const VerificationMeta('timeSimulatorMinutes');
  @override
  late final GeneratedColumn<int> timeSimulatorMinutes = GeneratedColumn<int>(
    'time_simulator_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceNMMeta = const VerificationMeta(
    'distanceNM',
  );
  @override
  late final GeneratedColumn<int> distanceNM = GeneratedColumn<int>(
    'distance_n_m',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flightCountMeta = const VerificationMeta(
    'flightCount',
  );
  @override
  late final GeneratedColumn<int> flightCount = GeneratedColumn<int>(
    'flight_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ifrApproachesMeta = const VerificationMeta(
    'ifrApproaches',
  );
  @override
  late final GeneratedColumn<int> ifrApproaches = GeneratedColumn<int>(
    'ifr_approaches',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takeOffsDaysMeta = const VerificationMeta(
    'takeOffsDays',
  );
  @override
  late final GeneratedColumn<int> takeOffsDays = GeneratedColumn<int>(
    'take_offs_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takeOffsNightMeta = const VerificationMeta(
    'takeOffsNight',
  );
  @override
  late final GeneratedColumn<int> takeOffsNight = GeneratedColumn<int>(
    'take_offs_night',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _landingsDayMeta = const VerificationMeta(
    'landingsDay',
  );
  @override
  late final GeneratedColumn<int> landingsDay = GeneratedColumn<int>(
    'landings_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _landingsNightMeta = const VerificationMeta(
    'landingsNight',
  );
  @override
  late final GeneratedColumn<int> landingsNight = GeneratedColumn<int>(
    'landings_night',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    aircraftTypeId,
    dateTimeFirstFlight,
    dateTimeLastFlight,
    timePICMinutes,
    timePICUSMinutes,
    timeSICMinutes,
    timeDualMinutes,
    timeInstructorMinutes,
    timeIFRMinutes,
    timeInstrumentMinutes,
    timeSimulatedInstrumentMinutes,
    timeNightMinutes,
    timeCrossCountryMinutes,
    timeCustom1Minutes,
    timeCustom2Minutes,
    timeCustom3Minutes,
    timeCustom4Minutes,
    timeFlightMinutes,
    timeBlockMinutes,
    timeSimulatorMinutes,
    distanceNM,
    flightCount,
    ifrApproaches,
    takeOffsDays,
    takeOffsNight,
    landingsDay,
    landingsNight,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'previous_experiences';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreviousExperience> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('aircraft_type_id')) {
      context.handle(
        _aircraftTypeIdMeta,
        aircraftTypeId.isAcceptableOrUnknown(
          data['aircraft_type_id']!,
          _aircraftTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aircraftTypeIdMeta);
    }
    if (data.containsKey('date_time_first_flight')) {
      context.handle(
        _dateTimeFirstFlightMeta,
        dateTimeFirstFlight.isAcceptableOrUnknown(
          data['date_time_first_flight']!,
          _dateTimeFirstFlightMeta,
        ),
      );
    }
    if (data.containsKey('date_time_last_flight')) {
      context.handle(
        _dateTimeLastFlightMeta,
        dateTimeLastFlight.isAcceptableOrUnknown(
          data['date_time_last_flight']!,
          _dateTimeLastFlightMeta,
        ),
      );
    }
    if (data.containsKey('time_p_i_c_minutes')) {
      context.handle(
        _timePICMinutesMeta,
        timePICMinutes.isAcceptableOrUnknown(
          data['time_p_i_c_minutes']!,
          _timePICMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timePICMinutesMeta);
    }
    if (data.containsKey('time_p_i_c_u_s_minutes')) {
      context.handle(
        _timePICUSMinutesMeta,
        timePICUSMinutes.isAcceptableOrUnknown(
          data['time_p_i_c_u_s_minutes']!,
          _timePICUSMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timePICUSMinutesMeta);
    }
    if (data.containsKey('time_s_i_c_minutes')) {
      context.handle(
        _timeSICMinutesMeta,
        timeSICMinutes.isAcceptableOrUnknown(
          data['time_s_i_c_minutes']!,
          _timeSICMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeSICMinutesMeta);
    }
    if (data.containsKey('time_dual_minutes')) {
      context.handle(
        _timeDualMinutesMeta,
        timeDualMinutes.isAcceptableOrUnknown(
          data['time_dual_minutes']!,
          _timeDualMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeDualMinutesMeta);
    }
    if (data.containsKey('time_instructor_minutes')) {
      context.handle(
        _timeInstructorMinutesMeta,
        timeInstructorMinutes.isAcceptableOrUnknown(
          data['time_instructor_minutes']!,
          _timeInstructorMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeInstructorMinutesMeta);
    }
    if (data.containsKey('time_i_f_r_minutes')) {
      context.handle(
        _timeIFRMinutesMeta,
        timeIFRMinutes.isAcceptableOrUnknown(
          data['time_i_f_r_minutes']!,
          _timeIFRMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeIFRMinutesMeta);
    }
    if (data.containsKey('time_instrument_minutes')) {
      context.handle(
        _timeInstrumentMinutesMeta,
        timeInstrumentMinutes.isAcceptableOrUnknown(
          data['time_instrument_minutes']!,
          _timeInstrumentMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeInstrumentMinutesMeta);
    }
    if (data.containsKey('time_simulated_instrument_minutes')) {
      context.handle(
        _timeSimulatedInstrumentMinutesMeta,
        timeSimulatedInstrumentMinutes.isAcceptableOrUnknown(
          data['time_simulated_instrument_minutes']!,
          _timeSimulatedInstrumentMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeSimulatedInstrumentMinutesMeta);
    }
    if (data.containsKey('time_night_minutes')) {
      context.handle(
        _timeNightMinutesMeta,
        timeNightMinutes.isAcceptableOrUnknown(
          data['time_night_minutes']!,
          _timeNightMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeNightMinutesMeta);
    }
    if (data.containsKey('time_cross_country_minutes')) {
      context.handle(
        _timeCrossCountryMinutesMeta,
        timeCrossCountryMinutes.isAcceptableOrUnknown(
          data['time_cross_country_minutes']!,
          _timeCrossCountryMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeCrossCountryMinutesMeta);
    }
    if (data.containsKey('time_custom1_minutes')) {
      context.handle(
        _timeCustom1MinutesMeta,
        timeCustom1Minutes.isAcceptableOrUnknown(
          data['time_custom1_minutes']!,
          _timeCustom1MinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeCustom1MinutesMeta);
    }
    if (data.containsKey('time_custom2_minutes')) {
      context.handle(
        _timeCustom2MinutesMeta,
        timeCustom2Minutes.isAcceptableOrUnknown(
          data['time_custom2_minutes']!,
          _timeCustom2MinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeCustom2MinutesMeta);
    }
    if (data.containsKey('time_custom3_minutes')) {
      context.handle(
        _timeCustom3MinutesMeta,
        timeCustom3Minutes.isAcceptableOrUnknown(
          data['time_custom3_minutes']!,
          _timeCustom3MinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeCustom3MinutesMeta);
    }
    if (data.containsKey('time_custom4_minutes')) {
      context.handle(
        _timeCustom4MinutesMeta,
        timeCustom4Minutes.isAcceptableOrUnknown(
          data['time_custom4_minutes']!,
          _timeCustom4MinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeCustom4MinutesMeta);
    }
    if (data.containsKey('time_flight_minutes')) {
      context.handle(
        _timeFlightMinutesMeta,
        timeFlightMinutes.isAcceptableOrUnknown(
          data['time_flight_minutes']!,
          _timeFlightMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeFlightMinutesMeta);
    }
    if (data.containsKey('time_block_minutes')) {
      context.handle(
        _timeBlockMinutesMeta,
        timeBlockMinutes.isAcceptableOrUnknown(
          data['time_block_minutes']!,
          _timeBlockMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeBlockMinutesMeta);
    }
    if (data.containsKey('time_simulator_minutes')) {
      context.handle(
        _timeSimulatorMinutesMeta,
        timeSimulatorMinutes.isAcceptableOrUnknown(
          data['time_simulator_minutes']!,
          _timeSimulatorMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeSimulatorMinutesMeta);
    }
    if (data.containsKey('distance_n_m')) {
      context.handle(
        _distanceNMMeta,
        distanceNM.isAcceptableOrUnknown(
          data['distance_n_m']!,
          _distanceNMMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distanceNMMeta);
    }
    if (data.containsKey('flight_count')) {
      context.handle(
        _flightCountMeta,
        flightCount.isAcceptableOrUnknown(
          data['flight_count']!,
          _flightCountMeta,
        ),
      );
    }
    if (data.containsKey('ifr_approaches')) {
      context.handle(
        _ifrApproachesMeta,
        ifrApproaches.isAcceptableOrUnknown(
          data['ifr_approaches']!,
          _ifrApproachesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ifrApproachesMeta);
    }
    if (data.containsKey('take_offs_days')) {
      context.handle(
        _takeOffsDaysMeta,
        takeOffsDays.isAcceptableOrUnknown(
          data['take_offs_days']!,
          _takeOffsDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_takeOffsDaysMeta);
    }
    if (data.containsKey('take_offs_night')) {
      context.handle(
        _takeOffsNightMeta,
        takeOffsNight.isAcceptableOrUnknown(
          data['take_offs_night']!,
          _takeOffsNightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_takeOffsNightMeta);
    }
    if (data.containsKey('landings_day')) {
      context.handle(
        _landingsDayMeta,
        landingsDay.isAcceptableOrUnknown(
          data['landings_day']!,
          _landingsDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_landingsDayMeta);
    }
    if (data.containsKey('landings_night')) {
      context.handle(
        _landingsNightMeta,
        landingsNight.isAcceptableOrUnknown(
          data['landings_night']!,
          _landingsNightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_landingsNightMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreviousExperience map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreviousExperience(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      aircraftTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}aircraft_type_id'],
      )!,
      dateTimeFirstFlight: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_time_first_flight'],
      ),
      dateTimeLastFlight: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_time_last_flight'],
      ),
      timePICMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_p_i_c_minutes'],
      )!,
      timePICUSMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_p_i_c_u_s_minutes'],
      )!,
      timeSICMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_s_i_c_minutes'],
      )!,
      timeDualMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_dual_minutes'],
      )!,
      timeInstructorMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_instructor_minutes'],
      )!,
      timeIFRMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_i_f_r_minutes'],
      )!,
      timeInstrumentMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_instrument_minutes'],
      )!,
      timeSimulatedInstrumentMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_simulated_instrument_minutes'],
      )!,
      timeNightMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_night_minutes'],
      )!,
      timeCrossCountryMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_cross_country_minutes'],
      )!,
      timeCustom1Minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_custom1_minutes'],
      )!,
      timeCustom2Minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_custom2_minutes'],
      )!,
      timeCustom3Minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_custom3_minutes'],
      )!,
      timeCustom4Minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_custom4_minutes'],
      )!,
      timeFlightMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_flight_minutes'],
      )!,
      timeBlockMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_block_minutes'],
      )!,
      timeSimulatorMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_simulator_minutes'],
      )!,
      distanceNM: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance_n_m'],
      )!,
      flightCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flight_count'],
      )!,
      ifrApproaches: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ifr_approaches'],
      )!,
      takeOffsDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}take_offs_days'],
      )!,
      takeOffsNight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}take_offs_night'],
      )!,
      landingsDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}landings_day'],
      )!,
      landingsNight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}landings_night'],
      )!,
    );
  }

  @override
  $PreviousExperiencesTable createAlias(String alias) {
    return $PreviousExperiencesTable(attachedDatabase, alias);
  }
}

class PreviousExperience extends DataClass
    implements Insertable<PreviousExperience> {
  /// Surrogate primary key.
  final int id;

  /// Aircraft type these totals apply to.
  final int aircraftTypeId;

  /// Earliest known flight date for this experience bucket.
  final DateTime? dateTimeFirstFlight;

  /// Most recent known flight date for this experience bucket.
  final DateTime? dateTimeLastFlight;

  /// PIC minutes.
  final int timePICMinutes;

  /// PICUS minutes.
  final int timePICUSMinutes;

  /// SIC minutes.
  final int timeSICMinutes;

  /// Dual minutes.
  final int timeDualMinutes;

  /// Instructor minutes.
  final int timeInstructorMinutes;

  /// IFR minutes.
  final int timeIFRMinutes;

  /// Instrument minutes.
  final int timeInstrumentMinutes;

  /// Simulated instrument minutes.
  final int timeSimulatedInstrumentMinutes;

  /// Night minutes.
  final int timeNightMinutes;

  /// Cross-country minutes.
  final int timeCrossCountryMinutes;

  /// Custom time bucket 1 minutes.
  final int timeCustom1Minutes;

  /// Custom time bucket 2 minutes.
  final int timeCustom2Minutes;

  /// Custom time bucket 3 minutes.
  final int timeCustom3Minutes;

  /// Custom time bucket 4 minutes.
  final int timeCustom4Minutes;

  /// Flight minutes.
  final int timeFlightMinutes;

  /// Block minutes.
  final int timeBlockMinutes;

  /// Simulator minutes.
  final int timeSimulatorMinutes;

  /// Distance in nautical miles.
  final int distanceNM;

  /// Number of flights/sectors represented.
  final int flightCount;

  /// IFR approaches count.
  final int ifrApproaches;

  /// Day takeoffs count.
  final int takeOffsDays;

  /// Night takeoffs count.
  final int takeOffsNight;

  /// Day landings count.
  final int landingsDay;

  /// Night landings count.
  final int landingsNight;
  const PreviousExperience({
    required this.id,
    required this.aircraftTypeId,
    this.dateTimeFirstFlight,
    this.dateTimeLastFlight,
    required this.timePICMinutes,
    required this.timePICUSMinutes,
    required this.timeSICMinutes,
    required this.timeDualMinutes,
    required this.timeInstructorMinutes,
    required this.timeIFRMinutes,
    required this.timeInstrumentMinutes,
    required this.timeSimulatedInstrumentMinutes,
    required this.timeNightMinutes,
    required this.timeCrossCountryMinutes,
    required this.timeCustom1Minutes,
    required this.timeCustom2Minutes,
    required this.timeCustom3Minutes,
    required this.timeCustom4Minutes,
    required this.timeFlightMinutes,
    required this.timeBlockMinutes,
    required this.timeSimulatorMinutes,
    required this.distanceNM,
    required this.flightCount,
    required this.ifrApproaches,
    required this.takeOffsDays,
    required this.takeOffsNight,
    required this.landingsDay,
    required this.landingsNight,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['aircraft_type_id'] = Variable<int>(aircraftTypeId);
    if (!nullToAbsent || dateTimeFirstFlight != null) {
      map['date_time_first_flight'] = Variable<DateTime>(dateTimeFirstFlight);
    }
    if (!nullToAbsent || dateTimeLastFlight != null) {
      map['date_time_last_flight'] = Variable<DateTime>(dateTimeLastFlight);
    }
    map['time_p_i_c_minutes'] = Variable<int>(timePICMinutes);
    map['time_p_i_c_u_s_minutes'] = Variable<int>(timePICUSMinutes);
    map['time_s_i_c_minutes'] = Variable<int>(timeSICMinutes);
    map['time_dual_minutes'] = Variable<int>(timeDualMinutes);
    map['time_instructor_minutes'] = Variable<int>(timeInstructorMinutes);
    map['time_i_f_r_minutes'] = Variable<int>(timeIFRMinutes);
    map['time_instrument_minutes'] = Variable<int>(timeInstrumentMinutes);
    map['time_simulated_instrument_minutes'] = Variable<int>(
      timeSimulatedInstrumentMinutes,
    );
    map['time_night_minutes'] = Variable<int>(timeNightMinutes);
    map['time_cross_country_minutes'] = Variable<int>(timeCrossCountryMinutes);
    map['time_custom1_minutes'] = Variable<int>(timeCustom1Minutes);
    map['time_custom2_minutes'] = Variable<int>(timeCustom2Minutes);
    map['time_custom3_minutes'] = Variable<int>(timeCustom3Minutes);
    map['time_custom4_minutes'] = Variable<int>(timeCustom4Minutes);
    map['time_flight_minutes'] = Variable<int>(timeFlightMinutes);
    map['time_block_minutes'] = Variable<int>(timeBlockMinutes);
    map['time_simulator_minutes'] = Variable<int>(timeSimulatorMinutes);
    map['distance_n_m'] = Variable<int>(distanceNM);
    map['flight_count'] = Variable<int>(flightCount);
    map['ifr_approaches'] = Variable<int>(ifrApproaches);
    map['take_offs_days'] = Variable<int>(takeOffsDays);
    map['take_offs_night'] = Variable<int>(takeOffsNight);
    map['landings_day'] = Variable<int>(landingsDay);
    map['landings_night'] = Variable<int>(landingsNight);
    return map;
  }

  PreviousExperiencesCompanion toCompanion(bool nullToAbsent) {
    return PreviousExperiencesCompanion(
      id: Value(id),
      aircraftTypeId: Value(aircraftTypeId),
      dateTimeFirstFlight: dateTimeFirstFlight == null && nullToAbsent
          ? const Value.absent()
          : Value(dateTimeFirstFlight),
      dateTimeLastFlight: dateTimeLastFlight == null && nullToAbsent
          ? const Value.absent()
          : Value(dateTimeLastFlight),
      timePICMinutes: Value(timePICMinutes),
      timePICUSMinutes: Value(timePICUSMinutes),
      timeSICMinutes: Value(timeSICMinutes),
      timeDualMinutes: Value(timeDualMinutes),
      timeInstructorMinutes: Value(timeInstructorMinutes),
      timeIFRMinutes: Value(timeIFRMinutes),
      timeInstrumentMinutes: Value(timeInstrumentMinutes),
      timeSimulatedInstrumentMinutes: Value(timeSimulatedInstrumentMinutes),
      timeNightMinutes: Value(timeNightMinutes),
      timeCrossCountryMinutes: Value(timeCrossCountryMinutes),
      timeCustom1Minutes: Value(timeCustom1Minutes),
      timeCustom2Minutes: Value(timeCustom2Minutes),
      timeCustom3Minutes: Value(timeCustom3Minutes),
      timeCustom4Minutes: Value(timeCustom4Minutes),
      timeFlightMinutes: Value(timeFlightMinutes),
      timeBlockMinutes: Value(timeBlockMinutes),
      timeSimulatorMinutes: Value(timeSimulatorMinutes),
      distanceNM: Value(distanceNM),
      flightCount: Value(flightCount),
      ifrApproaches: Value(ifrApproaches),
      takeOffsDays: Value(takeOffsDays),
      takeOffsNight: Value(takeOffsNight),
      landingsDay: Value(landingsDay),
      landingsNight: Value(landingsNight),
    );
  }

  factory PreviousExperience.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreviousExperience(
      id: serializer.fromJson<int>(json['id']),
      aircraftTypeId: serializer.fromJson<int>(json['aircraftTypeId']),
      dateTimeFirstFlight: serializer.fromJson<DateTime?>(
        json['dateTimeFirstFlight'],
      ),
      dateTimeLastFlight: serializer.fromJson<DateTime?>(
        json['dateTimeLastFlight'],
      ),
      timePICMinutes: serializer.fromJson<int>(json['timePICMinutes']),
      timePICUSMinutes: serializer.fromJson<int>(json['timePICUSMinutes']),
      timeSICMinutes: serializer.fromJson<int>(json['timeSICMinutes']),
      timeDualMinutes: serializer.fromJson<int>(json['timeDualMinutes']),
      timeInstructorMinutes: serializer.fromJson<int>(
        json['timeInstructorMinutes'],
      ),
      timeIFRMinutes: serializer.fromJson<int>(json['timeIFRMinutes']),
      timeInstrumentMinutes: serializer.fromJson<int>(
        json['timeInstrumentMinutes'],
      ),
      timeSimulatedInstrumentMinutes: serializer.fromJson<int>(
        json['timeSimulatedInstrumentMinutes'],
      ),
      timeNightMinutes: serializer.fromJson<int>(json['timeNightMinutes']),
      timeCrossCountryMinutes: serializer.fromJson<int>(
        json['timeCrossCountryMinutes'],
      ),
      timeCustom1Minutes: serializer.fromJson<int>(json['timeCustom1Minutes']),
      timeCustom2Minutes: serializer.fromJson<int>(json['timeCustom2Minutes']),
      timeCustom3Minutes: serializer.fromJson<int>(json['timeCustom3Minutes']),
      timeCustom4Minutes: serializer.fromJson<int>(json['timeCustom4Minutes']),
      timeFlightMinutes: serializer.fromJson<int>(json['timeFlightMinutes']),
      timeBlockMinutes: serializer.fromJson<int>(json['timeBlockMinutes']),
      timeSimulatorMinutes: serializer.fromJson<int>(
        json['timeSimulatorMinutes'],
      ),
      distanceNM: serializer.fromJson<int>(json['distanceNM']),
      flightCount: serializer.fromJson<int>(json['flightCount']),
      ifrApproaches: serializer.fromJson<int>(json['ifrApproaches']),
      takeOffsDays: serializer.fromJson<int>(json['takeOffsDays']),
      takeOffsNight: serializer.fromJson<int>(json['takeOffsNight']),
      landingsDay: serializer.fromJson<int>(json['landingsDay']),
      landingsNight: serializer.fromJson<int>(json['landingsNight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'aircraftTypeId': serializer.toJson<int>(aircraftTypeId),
      'dateTimeFirstFlight': serializer.toJson<DateTime?>(dateTimeFirstFlight),
      'dateTimeLastFlight': serializer.toJson<DateTime?>(dateTimeLastFlight),
      'timePICMinutes': serializer.toJson<int>(timePICMinutes),
      'timePICUSMinutes': serializer.toJson<int>(timePICUSMinutes),
      'timeSICMinutes': serializer.toJson<int>(timeSICMinutes),
      'timeDualMinutes': serializer.toJson<int>(timeDualMinutes),
      'timeInstructorMinutes': serializer.toJson<int>(timeInstructorMinutes),
      'timeIFRMinutes': serializer.toJson<int>(timeIFRMinutes),
      'timeInstrumentMinutes': serializer.toJson<int>(timeInstrumentMinutes),
      'timeSimulatedInstrumentMinutes': serializer.toJson<int>(
        timeSimulatedInstrumentMinutes,
      ),
      'timeNightMinutes': serializer.toJson<int>(timeNightMinutes),
      'timeCrossCountryMinutes': serializer.toJson<int>(
        timeCrossCountryMinutes,
      ),
      'timeCustom1Minutes': serializer.toJson<int>(timeCustom1Minutes),
      'timeCustom2Minutes': serializer.toJson<int>(timeCustom2Minutes),
      'timeCustom3Minutes': serializer.toJson<int>(timeCustom3Minutes),
      'timeCustom4Minutes': serializer.toJson<int>(timeCustom4Minutes),
      'timeFlightMinutes': serializer.toJson<int>(timeFlightMinutes),
      'timeBlockMinutes': serializer.toJson<int>(timeBlockMinutes),
      'timeSimulatorMinutes': serializer.toJson<int>(timeSimulatorMinutes),
      'distanceNM': serializer.toJson<int>(distanceNM),
      'flightCount': serializer.toJson<int>(flightCount),
      'ifrApproaches': serializer.toJson<int>(ifrApproaches),
      'takeOffsDays': serializer.toJson<int>(takeOffsDays),
      'takeOffsNight': serializer.toJson<int>(takeOffsNight),
      'landingsDay': serializer.toJson<int>(landingsDay),
      'landingsNight': serializer.toJson<int>(landingsNight),
    };
  }

  PreviousExperience copyWith({
    int? id,
    int? aircraftTypeId,
    Value<DateTime?> dateTimeFirstFlight = const Value.absent(),
    Value<DateTime?> dateTimeLastFlight = const Value.absent(),
    int? timePICMinutes,
    int? timePICUSMinutes,
    int? timeSICMinutes,
    int? timeDualMinutes,
    int? timeInstructorMinutes,
    int? timeIFRMinutes,
    int? timeInstrumentMinutes,
    int? timeSimulatedInstrumentMinutes,
    int? timeNightMinutes,
    int? timeCrossCountryMinutes,
    int? timeCustom1Minutes,
    int? timeCustom2Minutes,
    int? timeCustom3Minutes,
    int? timeCustom4Minutes,
    int? timeFlightMinutes,
    int? timeBlockMinutes,
    int? timeSimulatorMinutes,
    int? distanceNM,
    int? flightCount,
    int? ifrApproaches,
    int? takeOffsDays,
    int? takeOffsNight,
    int? landingsDay,
    int? landingsNight,
  }) => PreviousExperience(
    id: id ?? this.id,
    aircraftTypeId: aircraftTypeId ?? this.aircraftTypeId,
    dateTimeFirstFlight: dateTimeFirstFlight.present
        ? dateTimeFirstFlight.value
        : this.dateTimeFirstFlight,
    dateTimeLastFlight: dateTimeLastFlight.present
        ? dateTimeLastFlight.value
        : this.dateTimeLastFlight,
    timePICMinutes: timePICMinutes ?? this.timePICMinutes,
    timePICUSMinutes: timePICUSMinutes ?? this.timePICUSMinutes,
    timeSICMinutes: timeSICMinutes ?? this.timeSICMinutes,
    timeDualMinutes: timeDualMinutes ?? this.timeDualMinutes,
    timeInstructorMinutes: timeInstructorMinutes ?? this.timeInstructorMinutes,
    timeIFRMinutes: timeIFRMinutes ?? this.timeIFRMinutes,
    timeInstrumentMinutes: timeInstrumentMinutes ?? this.timeInstrumentMinutes,
    timeSimulatedInstrumentMinutes:
        timeSimulatedInstrumentMinutes ?? this.timeSimulatedInstrumentMinutes,
    timeNightMinutes: timeNightMinutes ?? this.timeNightMinutes,
    timeCrossCountryMinutes:
        timeCrossCountryMinutes ?? this.timeCrossCountryMinutes,
    timeCustom1Minutes: timeCustom1Minutes ?? this.timeCustom1Minutes,
    timeCustom2Minutes: timeCustom2Minutes ?? this.timeCustom2Minutes,
    timeCustom3Minutes: timeCustom3Minutes ?? this.timeCustom3Minutes,
    timeCustom4Minutes: timeCustom4Minutes ?? this.timeCustom4Minutes,
    timeFlightMinutes: timeFlightMinutes ?? this.timeFlightMinutes,
    timeBlockMinutes: timeBlockMinutes ?? this.timeBlockMinutes,
    timeSimulatorMinutes: timeSimulatorMinutes ?? this.timeSimulatorMinutes,
    distanceNM: distanceNM ?? this.distanceNM,
    flightCount: flightCount ?? this.flightCount,
    ifrApproaches: ifrApproaches ?? this.ifrApproaches,
    takeOffsDays: takeOffsDays ?? this.takeOffsDays,
    takeOffsNight: takeOffsNight ?? this.takeOffsNight,
    landingsDay: landingsDay ?? this.landingsDay,
    landingsNight: landingsNight ?? this.landingsNight,
  );
  PreviousExperience copyWithCompanion(PreviousExperiencesCompanion data) {
    return PreviousExperience(
      id: data.id.present ? data.id.value : this.id,
      aircraftTypeId: data.aircraftTypeId.present
          ? data.aircraftTypeId.value
          : this.aircraftTypeId,
      dateTimeFirstFlight: data.dateTimeFirstFlight.present
          ? data.dateTimeFirstFlight.value
          : this.dateTimeFirstFlight,
      dateTimeLastFlight: data.dateTimeLastFlight.present
          ? data.dateTimeLastFlight.value
          : this.dateTimeLastFlight,
      timePICMinutes: data.timePICMinutes.present
          ? data.timePICMinutes.value
          : this.timePICMinutes,
      timePICUSMinutes: data.timePICUSMinutes.present
          ? data.timePICUSMinutes.value
          : this.timePICUSMinutes,
      timeSICMinutes: data.timeSICMinutes.present
          ? data.timeSICMinutes.value
          : this.timeSICMinutes,
      timeDualMinutes: data.timeDualMinutes.present
          ? data.timeDualMinutes.value
          : this.timeDualMinutes,
      timeInstructorMinutes: data.timeInstructorMinutes.present
          ? data.timeInstructorMinutes.value
          : this.timeInstructorMinutes,
      timeIFRMinutes: data.timeIFRMinutes.present
          ? data.timeIFRMinutes.value
          : this.timeIFRMinutes,
      timeInstrumentMinutes: data.timeInstrumentMinutes.present
          ? data.timeInstrumentMinutes.value
          : this.timeInstrumentMinutes,
      timeSimulatedInstrumentMinutes:
          data.timeSimulatedInstrumentMinutes.present
          ? data.timeSimulatedInstrumentMinutes.value
          : this.timeSimulatedInstrumentMinutes,
      timeNightMinutes: data.timeNightMinutes.present
          ? data.timeNightMinutes.value
          : this.timeNightMinutes,
      timeCrossCountryMinutes: data.timeCrossCountryMinutes.present
          ? data.timeCrossCountryMinutes.value
          : this.timeCrossCountryMinutes,
      timeCustom1Minutes: data.timeCustom1Minutes.present
          ? data.timeCustom1Minutes.value
          : this.timeCustom1Minutes,
      timeCustom2Minutes: data.timeCustom2Minutes.present
          ? data.timeCustom2Minutes.value
          : this.timeCustom2Minutes,
      timeCustom3Minutes: data.timeCustom3Minutes.present
          ? data.timeCustom3Minutes.value
          : this.timeCustom3Minutes,
      timeCustom4Minutes: data.timeCustom4Minutes.present
          ? data.timeCustom4Minutes.value
          : this.timeCustom4Minutes,
      timeFlightMinutes: data.timeFlightMinutes.present
          ? data.timeFlightMinutes.value
          : this.timeFlightMinutes,
      timeBlockMinutes: data.timeBlockMinutes.present
          ? data.timeBlockMinutes.value
          : this.timeBlockMinutes,
      timeSimulatorMinutes: data.timeSimulatorMinutes.present
          ? data.timeSimulatorMinutes.value
          : this.timeSimulatorMinutes,
      distanceNM: data.distanceNM.present
          ? data.distanceNM.value
          : this.distanceNM,
      flightCount: data.flightCount.present
          ? data.flightCount.value
          : this.flightCount,
      ifrApproaches: data.ifrApproaches.present
          ? data.ifrApproaches.value
          : this.ifrApproaches,
      takeOffsDays: data.takeOffsDays.present
          ? data.takeOffsDays.value
          : this.takeOffsDays,
      takeOffsNight: data.takeOffsNight.present
          ? data.takeOffsNight.value
          : this.takeOffsNight,
      landingsDay: data.landingsDay.present
          ? data.landingsDay.value
          : this.landingsDay,
      landingsNight: data.landingsNight.present
          ? data.landingsNight.value
          : this.landingsNight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreviousExperience(')
          ..write('id: $id, ')
          ..write('aircraftTypeId: $aircraftTypeId, ')
          ..write('dateTimeFirstFlight: $dateTimeFirstFlight, ')
          ..write('dateTimeLastFlight: $dateTimeLastFlight, ')
          ..write('timePICMinutes: $timePICMinutes, ')
          ..write('timePICUSMinutes: $timePICUSMinutes, ')
          ..write('timeSICMinutes: $timeSICMinutes, ')
          ..write('timeDualMinutes: $timeDualMinutes, ')
          ..write('timeInstructorMinutes: $timeInstructorMinutes, ')
          ..write('timeIFRMinutes: $timeIFRMinutes, ')
          ..write('timeInstrumentMinutes: $timeInstrumentMinutes, ')
          ..write(
            'timeSimulatedInstrumentMinutes: $timeSimulatedInstrumentMinutes, ',
          )
          ..write('timeNightMinutes: $timeNightMinutes, ')
          ..write('timeCrossCountryMinutes: $timeCrossCountryMinutes, ')
          ..write('timeCustom1Minutes: $timeCustom1Minutes, ')
          ..write('timeCustom2Minutes: $timeCustom2Minutes, ')
          ..write('timeCustom3Minutes: $timeCustom3Minutes, ')
          ..write('timeCustom4Minutes: $timeCustom4Minutes, ')
          ..write('timeFlightMinutes: $timeFlightMinutes, ')
          ..write('timeBlockMinutes: $timeBlockMinutes, ')
          ..write('timeSimulatorMinutes: $timeSimulatorMinutes, ')
          ..write('distanceNM: $distanceNM, ')
          ..write('flightCount: $flightCount, ')
          ..write('ifrApproaches: $ifrApproaches, ')
          ..write('takeOffsDays: $takeOffsDays, ')
          ..write('takeOffsNight: $takeOffsNight, ')
          ..write('landingsDay: $landingsDay, ')
          ..write('landingsNight: $landingsNight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    aircraftTypeId,
    dateTimeFirstFlight,
    dateTimeLastFlight,
    timePICMinutes,
    timePICUSMinutes,
    timeSICMinutes,
    timeDualMinutes,
    timeInstructorMinutes,
    timeIFRMinutes,
    timeInstrumentMinutes,
    timeSimulatedInstrumentMinutes,
    timeNightMinutes,
    timeCrossCountryMinutes,
    timeCustom1Minutes,
    timeCustom2Minutes,
    timeCustom3Minutes,
    timeCustom4Minutes,
    timeFlightMinutes,
    timeBlockMinutes,
    timeSimulatorMinutes,
    distanceNM,
    flightCount,
    ifrApproaches,
    takeOffsDays,
    takeOffsNight,
    landingsDay,
    landingsNight,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreviousExperience &&
          other.id == this.id &&
          other.aircraftTypeId == this.aircraftTypeId &&
          other.dateTimeFirstFlight == this.dateTimeFirstFlight &&
          other.dateTimeLastFlight == this.dateTimeLastFlight &&
          other.timePICMinutes == this.timePICMinutes &&
          other.timePICUSMinutes == this.timePICUSMinutes &&
          other.timeSICMinutes == this.timeSICMinutes &&
          other.timeDualMinutes == this.timeDualMinutes &&
          other.timeInstructorMinutes == this.timeInstructorMinutes &&
          other.timeIFRMinutes == this.timeIFRMinutes &&
          other.timeInstrumentMinutes == this.timeInstrumentMinutes &&
          other.timeSimulatedInstrumentMinutes ==
              this.timeSimulatedInstrumentMinutes &&
          other.timeNightMinutes == this.timeNightMinutes &&
          other.timeCrossCountryMinutes == this.timeCrossCountryMinutes &&
          other.timeCustom1Minutes == this.timeCustom1Minutes &&
          other.timeCustom2Minutes == this.timeCustom2Minutes &&
          other.timeCustom3Minutes == this.timeCustom3Minutes &&
          other.timeCustom4Minutes == this.timeCustom4Minutes &&
          other.timeFlightMinutes == this.timeFlightMinutes &&
          other.timeBlockMinutes == this.timeBlockMinutes &&
          other.timeSimulatorMinutes == this.timeSimulatorMinutes &&
          other.distanceNM == this.distanceNM &&
          other.flightCount == this.flightCount &&
          other.ifrApproaches == this.ifrApproaches &&
          other.takeOffsDays == this.takeOffsDays &&
          other.takeOffsNight == this.takeOffsNight &&
          other.landingsDay == this.landingsDay &&
          other.landingsNight == this.landingsNight);
}

class PreviousExperiencesCompanion extends UpdateCompanion<PreviousExperience> {
  final Value<int> id;
  final Value<int> aircraftTypeId;
  final Value<DateTime?> dateTimeFirstFlight;
  final Value<DateTime?> dateTimeLastFlight;
  final Value<int> timePICMinutes;
  final Value<int> timePICUSMinutes;
  final Value<int> timeSICMinutes;
  final Value<int> timeDualMinutes;
  final Value<int> timeInstructorMinutes;
  final Value<int> timeIFRMinutes;
  final Value<int> timeInstrumentMinutes;
  final Value<int> timeSimulatedInstrumentMinutes;
  final Value<int> timeNightMinutes;
  final Value<int> timeCrossCountryMinutes;
  final Value<int> timeCustom1Minutes;
  final Value<int> timeCustom2Minutes;
  final Value<int> timeCustom3Minutes;
  final Value<int> timeCustom4Minutes;
  final Value<int> timeFlightMinutes;
  final Value<int> timeBlockMinutes;
  final Value<int> timeSimulatorMinutes;
  final Value<int> distanceNM;
  final Value<int> flightCount;
  final Value<int> ifrApproaches;
  final Value<int> takeOffsDays;
  final Value<int> takeOffsNight;
  final Value<int> landingsDay;
  final Value<int> landingsNight;
  const PreviousExperiencesCompanion({
    this.id = const Value.absent(),
    this.aircraftTypeId = const Value.absent(),
    this.dateTimeFirstFlight = const Value.absent(),
    this.dateTimeLastFlight = const Value.absent(),
    this.timePICMinutes = const Value.absent(),
    this.timePICUSMinutes = const Value.absent(),
    this.timeSICMinutes = const Value.absent(),
    this.timeDualMinutes = const Value.absent(),
    this.timeInstructorMinutes = const Value.absent(),
    this.timeIFRMinutes = const Value.absent(),
    this.timeInstrumentMinutes = const Value.absent(),
    this.timeSimulatedInstrumentMinutes = const Value.absent(),
    this.timeNightMinutes = const Value.absent(),
    this.timeCrossCountryMinutes = const Value.absent(),
    this.timeCustom1Minutes = const Value.absent(),
    this.timeCustom2Minutes = const Value.absent(),
    this.timeCustom3Minutes = const Value.absent(),
    this.timeCustom4Minutes = const Value.absent(),
    this.timeFlightMinutes = const Value.absent(),
    this.timeBlockMinutes = const Value.absent(),
    this.timeSimulatorMinutes = const Value.absent(),
    this.distanceNM = const Value.absent(),
    this.flightCount = const Value.absent(),
    this.ifrApproaches = const Value.absent(),
    this.takeOffsDays = const Value.absent(),
    this.takeOffsNight = const Value.absent(),
    this.landingsDay = const Value.absent(),
    this.landingsNight = const Value.absent(),
  });
  PreviousExperiencesCompanion.insert({
    this.id = const Value.absent(),
    required int aircraftTypeId,
    this.dateTimeFirstFlight = const Value.absent(),
    this.dateTimeLastFlight = const Value.absent(),
    required int timePICMinutes,
    required int timePICUSMinutes,
    required int timeSICMinutes,
    required int timeDualMinutes,
    required int timeInstructorMinutes,
    required int timeIFRMinutes,
    required int timeInstrumentMinutes,
    required int timeSimulatedInstrumentMinutes,
    required int timeNightMinutes,
    required int timeCrossCountryMinutes,
    required int timeCustom1Minutes,
    required int timeCustom2Minutes,
    required int timeCustom3Minutes,
    required int timeCustom4Minutes,
    required int timeFlightMinutes,
    required int timeBlockMinutes,
    required int timeSimulatorMinutes,
    required int distanceNM,
    this.flightCount = const Value.absent(),
    required int ifrApproaches,
    required int takeOffsDays,
    required int takeOffsNight,
    required int landingsDay,
    required int landingsNight,
  }) : aircraftTypeId = Value(aircraftTypeId),
       timePICMinutes = Value(timePICMinutes),
       timePICUSMinutes = Value(timePICUSMinutes),
       timeSICMinutes = Value(timeSICMinutes),
       timeDualMinutes = Value(timeDualMinutes),
       timeInstructorMinutes = Value(timeInstructorMinutes),
       timeIFRMinutes = Value(timeIFRMinutes),
       timeInstrumentMinutes = Value(timeInstrumentMinutes),
       timeSimulatedInstrumentMinutes = Value(timeSimulatedInstrumentMinutes),
       timeNightMinutes = Value(timeNightMinutes),
       timeCrossCountryMinutes = Value(timeCrossCountryMinutes),
       timeCustom1Minutes = Value(timeCustom1Minutes),
       timeCustom2Minutes = Value(timeCustom2Minutes),
       timeCustom3Minutes = Value(timeCustom3Minutes),
       timeCustom4Minutes = Value(timeCustom4Minutes),
       timeFlightMinutes = Value(timeFlightMinutes),
       timeBlockMinutes = Value(timeBlockMinutes),
       timeSimulatorMinutes = Value(timeSimulatorMinutes),
       distanceNM = Value(distanceNM),
       ifrApproaches = Value(ifrApproaches),
       takeOffsDays = Value(takeOffsDays),
       takeOffsNight = Value(takeOffsNight),
       landingsDay = Value(landingsDay),
       landingsNight = Value(landingsNight);
  static Insertable<PreviousExperience> custom({
    Expression<int>? id,
    Expression<int>? aircraftTypeId,
    Expression<DateTime>? dateTimeFirstFlight,
    Expression<DateTime>? dateTimeLastFlight,
    Expression<int>? timePICMinutes,
    Expression<int>? timePICUSMinutes,
    Expression<int>? timeSICMinutes,
    Expression<int>? timeDualMinutes,
    Expression<int>? timeInstructorMinutes,
    Expression<int>? timeIFRMinutes,
    Expression<int>? timeInstrumentMinutes,
    Expression<int>? timeSimulatedInstrumentMinutes,
    Expression<int>? timeNightMinutes,
    Expression<int>? timeCrossCountryMinutes,
    Expression<int>? timeCustom1Minutes,
    Expression<int>? timeCustom2Minutes,
    Expression<int>? timeCustom3Minutes,
    Expression<int>? timeCustom4Minutes,
    Expression<int>? timeFlightMinutes,
    Expression<int>? timeBlockMinutes,
    Expression<int>? timeSimulatorMinutes,
    Expression<int>? distanceNM,
    Expression<int>? flightCount,
    Expression<int>? ifrApproaches,
    Expression<int>? takeOffsDays,
    Expression<int>? takeOffsNight,
    Expression<int>? landingsDay,
    Expression<int>? landingsNight,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (aircraftTypeId != null) 'aircraft_type_id': aircraftTypeId,
      if (dateTimeFirstFlight != null)
        'date_time_first_flight': dateTimeFirstFlight,
      if (dateTimeLastFlight != null)
        'date_time_last_flight': dateTimeLastFlight,
      if (timePICMinutes != null) 'time_p_i_c_minutes': timePICMinutes,
      if (timePICUSMinutes != null) 'time_p_i_c_u_s_minutes': timePICUSMinutes,
      if (timeSICMinutes != null) 'time_s_i_c_minutes': timeSICMinutes,
      if (timeDualMinutes != null) 'time_dual_minutes': timeDualMinutes,
      if (timeInstructorMinutes != null)
        'time_instructor_minutes': timeInstructorMinutes,
      if (timeIFRMinutes != null) 'time_i_f_r_minutes': timeIFRMinutes,
      if (timeInstrumentMinutes != null)
        'time_instrument_minutes': timeInstrumentMinutes,
      if (timeSimulatedInstrumentMinutes != null)
        'time_simulated_instrument_minutes': timeSimulatedInstrumentMinutes,
      if (timeNightMinutes != null) 'time_night_minutes': timeNightMinutes,
      if (timeCrossCountryMinutes != null)
        'time_cross_country_minutes': timeCrossCountryMinutes,
      if (timeCustom1Minutes != null)
        'time_custom1_minutes': timeCustom1Minutes,
      if (timeCustom2Minutes != null)
        'time_custom2_minutes': timeCustom2Minutes,
      if (timeCustom3Minutes != null)
        'time_custom3_minutes': timeCustom3Minutes,
      if (timeCustom4Minutes != null)
        'time_custom4_minutes': timeCustom4Minutes,
      if (timeFlightMinutes != null) 'time_flight_minutes': timeFlightMinutes,
      if (timeBlockMinutes != null) 'time_block_minutes': timeBlockMinutes,
      if (timeSimulatorMinutes != null)
        'time_simulator_minutes': timeSimulatorMinutes,
      if (distanceNM != null) 'distance_n_m': distanceNM,
      if (flightCount != null) 'flight_count': flightCount,
      if (ifrApproaches != null) 'ifr_approaches': ifrApproaches,
      if (takeOffsDays != null) 'take_offs_days': takeOffsDays,
      if (takeOffsNight != null) 'take_offs_night': takeOffsNight,
      if (landingsDay != null) 'landings_day': landingsDay,
      if (landingsNight != null) 'landings_night': landingsNight,
    });
  }

  PreviousExperiencesCompanion copyWith({
    Value<int>? id,
    Value<int>? aircraftTypeId,
    Value<DateTime?>? dateTimeFirstFlight,
    Value<DateTime?>? dateTimeLastFlight,
    Value<int>? timePICMinutes,
    Value<int>? timePICUSMinutes,
    Value<int>? timeSICMinutes,
    Value<int>? timeDualMinutes,
    Value<int>? timeInstructorMinutes,
    Value<int>? timeIFRMinutes,
    Value<int>? timeInstrumentMinutes,
    Value<int>? timeSimulatedInstrumentMinutes,
    Value<int>? timeNightMinutes,
    Value<int>? timeCrossCountryMinutes,
    Value<int>? timeCustom1Minutes,
    Value<int>? timeCustom2Minutes,
    Value<int>? timeCustom3Minutes,
    Value<int>? timeCustom4Minutes,
    Value<int>? timeFlightMinutes,
    Value<int>? timeBlockMinutes,
    Value<int>? timeSimulatorMinutes,
    Value<int>? distanceNM,
    Value<int>? flightCount,
    Value<int>? ifrApproaches,
    Value<int>? takeOffsDays,
    Value<int>? takeOffsNight,
    Value<int>? landingsDay,
    Value<int>? landingsNight,
  }) {
    return PreviousExperiencesCompanion(
      id: id ?? this.id,
      aircraftTypeId: aircraftTypeId ?? this.aircraftTypeId,
      dateTimeFirstFlight: dateTimeFirstFlight ?? this.dateTimeFirstFlight,
      dateTimeLastFlight: dateTimeLastFlight ?? this.dateTimeLastFlight,
      timePICMinutes: timePICMinutes ?? this.timePICMinutes,
      timePICUSMinutes: timePICUSMinutes ?? this.timePICUSMinutes,
      timeSICMinutes: timeSICMinutes ?? this.timeSICMinutes,
      timeDualMinutes: timeDualMinutes ?? this.timeDualMinutes,
      timeInstructorMinutes:
          timeInstructorMinutes ?? this.timeInstructorMinutes,
      timeIFRMinutes: timeIFRMinutes ?? this.timeIFRMinutes,
      timeInstrumentMinutes:
          timeInstrumentMinutes ?? this.timeInstrumentMinutes,
      timeSimulatedInstrumentMinutes:
          timeSimulatedInstrumentMinutes ?? this.timeSimulatedInstrumentMinutes,
      timeNightMinutes: timeNightMinutes ?? this.timeNightMinutes,
      timeCrossCountryMinutes:
          timeCrossCountryMinutes ?? this.timeCrossCountryMinutes,
      timeCustom1Minutes: timeCustom1Minutes ?? this.timeCustom1Minutes,
      timeCustom2Minutes: timeCustom2Minutes ?? this.timeCustom2Minutes,
      timeCustom3Minutes: timeCustom3Minutes ?? this.timeCustom3Minutes,
      timeCustom4Minutes: timeCustom4Minutes ?? this.timeCustom4Minutes,
      timeFlightMinutes: timeFlightMinutes ?? this.timeFlightMinutes,
      timeBlockMinutes: timeBlockMinutes ?? this.timeBlockMinutes,
      timeSimulatorMinutes: timeSimulatorMinutes ?? this.timeSimulatorMinutes,
      distanceNM: distanceNM ?? this.distanceNM,
      flightCount: flightCount ?? this.flightCount,
      ifrApproaches: ifrApproaches ?? this.ifrApproaches,
      takeOffsDays: takeOffsDays ?? this.takeOffsDays,
      takeOffsNight: takeOffsNight ?? this.takeOffsNight,
      landingsDay: landingsDay ?? this.landingsDay,
      landingsNight: landingsNight ?? this.landingsNight,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (aircraftTypeId.present) {
      map['aircraft_type_id'] = Variable<int>(aircraftTypeId.value);
    }
    if (dateTimeFirstFlight.present) {
      map['date_time_first_flight'] = Variable<DateTime>(
        dateTimeFirstFlight.value,
      );
    }
    if (dateTimeLastFlight.present) {
      map['date_time_last_flight'] = Variable<DateTime>(
        dateTimeLastFlight.value,
      );
    }
    if (timePICMinutes.present) {
      map['time_p_i_c_minutes'] = Variable<int>(timePICMinutes.value);
    }
    if (timePICUSMinutes.present) {
      map['time_p_i_c_u_s_minutes'] = Variable<int>(timePICUSMinutes.value);
    }
    if (timeSICMinutes.present) {
      map['time_s_i_c_minutes'] = Variable<int>(timeSICMinutes.value);
    }
    if (timeDualMinutes.present) {
      map['time_dual_minutes'] = Variable<int>(timeDualMinutes.value);
    }
    if (timeInstructorMinutes.present) {
      map['time_instructor_minutes'] = Variable<int>(
        timeInstructorMinutes.value,
      );
    }
    if (timeIFRMinutes.present) {
      map['time_i_f_r_minutes'] = Variable<int>(timeIFRMinutes.value);
    }
    if (timeInstrumentMinutes.present) {
      map['time_instrument_minutes'] = Variable<int>(
        timeInstrumentMinutes.value,
      );
    }
    if (timeSimulatedInstrumentMinutes.present) {
      map['time_simulated_instrument_minutes'] = Variable<int>(
        timeSimulatedInstrumentMinutes.value,
      );
    }
    if (timeNightMinutes.present) {
      map['time_night_minutes'] = Variable<int>(timeNightMinutes.value);
    }
    if (timeCrossCountryMinutes.present) {
      map['time_cross_country_minutes'] = Variable<int>(
        timeCrossCountryMinutes.value,
      );
    }
    if (timeCustom1Minutes.present) {
      map['time_custom1_minutes'] = Variable<int>(timeCustom1Minutes.value);
    }
    if (timeCustom2Minutes.present) {
      map['time_custom2_minutes'] = Variable<int>(timeCustom2Minutes.value);
    }
    if (timeCustom3Minutes.present) {
      map['time_custom3_minutes'] = Variable<int>(timeCustom3Minutes.value);
    }
    if (timeCustom4Minutes.present) {
      map['time_custom4_minutes'] = Variable<int>(timeCustom4Minutes.value);
    }
    if (timeFlightMinutes.present) {
      map['time_flight_minutes'] = Variable<int>(timeFlightMinutes.value);
    }
    if (timeBlockMinutes.present) {
      map['time_block_minutes'] = Variable<int>(timeBlockMinutes.value);
    }
    if (timeSimulatorMinutes.present) {
      map['time_simulator_minutes'] = Variable<int>(timeSimulatorMinutes.value);
    }
    if (distanceNM.present) {
      map['distance_n_m'] = Variable<int>(distanceNM.value);
    }
    if (flightCount.present) {
      map['flight_count'] = Variable<int>(flightCount.value);
    }
    if (ifrApproaches.present) {
      map['ifr_approaches'] = Variable<int>(ifrApproaches.value);
    }
    if (takeOffsDays.present) {
      map['take_offs_days'] = Variable<int>(takeOffsDays.value);
    }
    if (takeOffsNight.present) {
      map['take_offs_night'] = Variable<int>(takeOffsNight.value);
    }
    if (landingsDay.present) {
      map['landings_day'] = Variable<int>(landingsDay.value);
    }
    if (landingsNight.present) {
      map['landings_night'] = Variable<int>(landingsNight.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreviousExperiencesCompanion(')
          ..write('id: $id, ')
          ..write('aircraftTypeId: $aircraftTypeId, ')
          ..write('dateTimeFirstFlight: $dateTimeFirstFlight, ')
          ..write('dateTimeLastFlight: $dateTimeLastFlight, ')
          ..write('timePICMinutes: $timePICMinutes, ')
          ..write('timePICUSMinutes: $timePICUSMinutes, ')
          ..write('timeSICMinutes: $timeSICMinutes, ')
          ..write('timeDualMinutes: $timeDualMinutes, ')
          ..write('timeInstructorMinutes: $timeInstructorMinutes, ')
          ..write('timeIFRMinutes: $timeIFRMinutes, ')
          ..write('timeInstrumentMinutes: $timeInstrumentMinutes, ')
          ..write(
            'timeSimulatedInstrumentMinutes: $timeSimulatedInstrumentMinutes, ',
          )
          ..write('timeNightMinutes: $timeNightMinutes, ')
          ..write('timeCrossCountryMinutes: $timeCrossCountryMinutes, ')
          ..write('timeCustom1Minutes: $timeCustom1Minutes, ')
          ..write('timeCustom2Minutes: $timeCustom2Minutes, ')
          ..write('timeCustom3Minutes: $timeCustom3Minutes, ')
          ..write('timeCustom4Minutes: $timeCustom4Minutes, ')
          ..write('timeFlightMinutes: $timeFlightMinutes, ')
          ..write('timeBlockMinutes: $timeBlockMinutes, ')
          ..write('timeSimulatorMinutes: $timeSimulatorMinutes, ')
          ..write('distanceNM: $distanceNM, ')
          ..write('flightCount: $flightCount, ')
          ..write('ifrApproaches: $ifrApproaches, ')
          ..write('takeOffsDays: $takeOffsDays, ')
          ..write('takeOffsNight: $takeOffsNight, ')
          ..write('landingsDay: $landingsDay, ')
          ..write('landingsNight: $landingsNight')
          ..write(')'))
        .toString();
  }
}

class $ReportTemplatesTable extends ReportTemplates
    with TableInfo<$ReportTemplatesTable, ReportTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _templateNameMeta = const VerificationMeta(
    'templateName',
  );
  @override
  late final GeneratedColumn<String> templateName = GeneratedColumn<String>(
    'template_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateJsonMeta = const VerificationMeta(
    'templateJson',
  );
  @override
  late final GeneratedColumn<String> templateJson = GeneratedColumn<String>(
    'template_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, templateName, templateJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'report_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReportTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('template_name')) {
      context.handle(
        _templateNameMeta,
        templateName.isAcceptableOrUnknown(
          data['template_name']!,
          _templateNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_templateNameMeta);
    }
    if (data.containsKey('template_json')) {
      context.handle(
        _templateJsonMeta,
        templateJson.isAcceptableOrUnknown(
          data['template_json']!,
          _templateJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_templateJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {templateName},
  ];
  @override
  ReportTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReportTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      templateName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_name'],
      )!,
      templateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_json'],
      )!,
    );
  }

  @override
  $ReportTemplatesTable createAlias(String alias) {
    return $ReportTemplatesTable(attachedDatabase, alias);
  }
}

class ReportTemplate extends DataClass implements Insertable<ReportTemplate> {
  /// Surrogate primary key.
  final int id;

  /// Stable template identifier, e.g. `standard` or `easa`.
  final String templateName;

  /// Full template JSON payload.
  final String templateJson;
  const ReportTemplate({
    required this.id,
    required this.templateName,
    required this.templateJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['template_name'] = Variable<String>(templateName);
    map['template_json'] = Variable<String>(templateJson);
    return map;
  }

  ReportTemplatesCompanion toCompanion(bool nullToAbsent) {
    return ReportTemplatesCompanion(
      id: Value(id),
      templateName: Value(templateName),
      templateJson: Value(templateJson),
    );
  }

  factory ReportTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReportTemplate(
      id: serializer.fromJson<int>(json['id']),
      templateName: serializer.fromJson<String>(json['templateName']),
      templateJson: serializer.fromJson<String>(json['templateJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'templateName': serializer.toJson<String>(templateName),
      'templateJson': serializer.toJson<String>(templateJson),
    };
  }

  ReportTemplate copyWith({
    int? id,
    String? templateName,
    String? templateJson,
  }) => ReportTemplate(
    id: id ?? this.id,
    templateName: templateName ?? this.templateName,
    templateJson: templateJson ?? this.templateJson,
  );
  ReportTemplate copyWithCompanion(ReportTemplatesCompanion data) {
    return ReportTemplate(
      id: data.id.present ? data.id.value : this.id,
      templateName: data.templateName.present
          ? data.templateName.value
          : this.templateName,
      templateJson: data.templateJson.present
          ? data.templateJson.value
          : this.templateJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReportTemplate(')
          ..write('id: $id, ')
          ..write('templateName: $templateName, ')
          ..write('templateJson: $templateJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, templateName, templateJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReportTemplate &&
          other.id == this.id &&
          other.templateName == this.templateName &&
          other.templateJson == this.templateJson);
}

class ReportTemplatesCompanion extends UpdateCompanion<ReportTemplate> {
  final Value<int> id;
  final Value<String> templateName;
  final Value<String> templateJson;
  const ReportTemplatesCompanion({
    this.id = const Value.absent(),
    this.templateName = const Value.absent(),
    this.templateJson = const Value.absent(),
  });
  ReportTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required String templateName,
    required String templateJson,
  }) : templateName = Value(templateName),
       templateJson = Value(templateJson);
  static Insertable<ReportTemplate> custom({
    Expression<int>? id,
    Expression<String>? templateName,
    Expression<String>? templateJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateName != null) 'template_name': templateName,
      if (templateJson != null) 'template_json': templateJson,
    });
  }

  ReportTemplatesCompanion copyWith({
    Value<int>? id,
    Value<String>? templateName,
    Value<String>? templateJson,
  }) {
    return ReportTemplatesCompanion(
      id: id ?? this.id,
      templateName: templateName ?? this.templateName,
      templateJson: templateJson ?? this.templateJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (templateName.present) {
      map['template_name'] = Variable<String>(templateName.value);
    }
    if (templateJson.present) {
      map['template_json'] = Variable<String>(templateJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('templateName: $templateName, ')
          ..write('templateJson: $templateJson')
          ..write(')'))
        .toString();
  }
}

class $DutyPeriodsTable extends DutyPeriods
    with TableInfo<$DutyPeriodsTable, DutyPeriod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DutyPeriodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dutyStartTimeLineIdMeta =
      const VerificationMeta('dutyStartTimeLineId');
  @override
  late final GeneratedColumn<int> dutyStartTimeLineId = GeneratedColumn<int>(
    'duty_start_time_line_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES time_lines (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _dutyEndTimeLineIdMeta = const VerificationMeta(
    'dutyEndTimeLineId',
  );
  @override
  late final GeneratedColumn<int> dutyEndTimeLineId = GeneratedColumn<int>(
    'duty_end_time_line_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES time_lines (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _timeDutyMinutesMeta = const VerificationMeta(
    'timeDutyMinutes',
  );
  @override
  late final GeneratedColumn<int> timeDutyMinutes = GeneratedColumn<int>(
    'time_duty_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restBeforeMinutesMeta = const VerificationMeta(
    'restBeforeMinutes',
  );
  @override
  late final GeneratedColumn<int> restBeforeMinutes = GeneratedColumn<int>(
    'rest_before_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _timeFactoredDutyMinutesMeta =
      const VerificationMeta('timeFactoredDutyMinutes');
  @override
  late final GeneratedColumn<int> timeFactoredDutyMinutes =
      GeneratedColumn<int>(
        'time_factored_duty_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dutyStartTimeLineId,
    dutyEndTimeLineId,
    timeDutyMinutes,
    restBeforeMinutes,
    timeFactoredDutyMinutes,
    isLocked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'duty_periods';
  @override
  VerificationContext validateIntegrity(
    Insertable<DutyPeriod> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('duty_start_time_line_id')) {
      context.handle(
        _dutyStartTimeLineIdMeta,
        dutyStartTimeLineId.isAcceptableOrUnknown(
          data['duty_start_time_line_id']!,
          _dutyStartTimeLineIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dutyStartTimeLineIdMeta);
    }
    if (data.containsKey('duty_end_time_line_id')) {
      context.handle(
        _dutyEndTimeLineIdMeta,
        dutyEndTimeLineId.isAcceptableOrUnknown(
          data['duty_end_time_line_id']!,
          _dutyEndTimeLineIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dutyEndTimeLineIdMeta);
    }
    if (data.containsKey('time_duty_minutes')) {
      context.handle(
        _timeDutyMinutesMeta,
        timeDutyMinutes.isAcceptableOrUnknown(
          data['time_duty_minutes']!,
          _timeDutyMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeDutyMinutesMeta);
    }
    if (data.containsKey('rest_before_minutes')) {
      context.handle(
        _restBeforeMinutesMeta,
        restBeforeMinutes.isAcceptableOrUnknown(
          data['rest_before_minutes']!,
          _restBeforeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('time_factored_duty_minutes')) {
      context.handle(
        _timeFactoredDutyMinutesMeta,
        timeFactoredDutyMinutes.isAcceptableOrUnknown(
          data['time_factored_duty_minutes']!,
          _timeFactoredDutyMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeFactoredDutyMinutesMeta);
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    } else if (isInserting) {
      context.missing(_isLockedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DutyPeriod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DutyPeriod(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dutyStartTimeLineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duty_start_time_line_id'],
      )!,
      dutyEndTimeLineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duty_end_time_line_id'],
      )!,
      timeDutyMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_duty_minutes'],
      )!,
      restBeforeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_before_minutes'],
      )!,
      timeFactoredDutyMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_factored_duty_minutes'],
      )!,
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
    );
  }

  @override
  $DutyPeriodsTable createAlias(String alias) {
    return $DutyPeriodsTable(attachedDatabase, alias);
  }
}

class DutyPeriod extends DataClass implements Insertable<DutyPeriod> {
  /// Surrogate primary key.
  final int id;

  /// Timeline id for duty start.
  final int dutyStartTimeLineId;

  /// Timeline id for duty end.
  final int dutyEndTimeLineId;

  /// Total duty minutes.
  final int timeDutyMinutes;

  /// Rest before duty in minutes.
  final int restBeforeMinutes;

  /// Factored duty minutes.
  final int timeFactoredDutyMinutes;

  /// Lock flag preventing edits.
  final bool isLocked;
  const DutyPeriod({
    required this.id,
    required this.dutyStartTimeLineId,
    required this.dutyEndTimeLineId,
    required this.timeDutyMinutes,
    required this.restBeforeMinutes,
    required this.timeFactoredDutyMinutes,
    required this.isLocked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['duty_start_time_line_id'] = Variable<int>(dutyStartTimeLineId);
    map['duty_end_time_line_id'] = Variable<int>(dutyEndTimeLineId);
    map['time_duty_minutes'] = Variable<int>(timeDutyMinutes);
    map['rest_before_minutes'] = Variable<int>(restBeforeMinutes);
    map['time_factored_duty_minutes'] = Variable<int>(timeFactoredDutyMinutes);
    map['is_locked'] = Variable<bool>(isLocked);
    return map;
  }

  DutyPeriodsCompanion toCompanion(bool nullToAbsent) {
    return DutyPeriodsCompanion(
      id: Value(id),
      dutyStartTimeLineId: Value(dutyStartTimeLineId),
      dutyEndTimeLineId: Value(dutyEndTimeLineId),
      timeDutyMinutes: Value(timeDutyMinutes),
      restBeforeMinutes: Value(restBeforeMinutes),
      timeFactoredDutyMinutes: Value(timeFactoredDutyMinutes),
      isLocked: Value(isLocked),
    );
  }

  factory DutyPeriod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DutyPeriod(
      id: serializer.fromJson<int>(json['id']),
      dutyStartTimeLineId: serializer.fromJson<int>(
        json['dutyStartTimeLineId'],
      ),
      dutyEndTimeLineId: serializer.fromJson<int>(json['dutyEndTimeLineId']),
      timeDutyMinutes: serializer.fromJson<int>(json['timeDutyMinutes']),
      restBeforeMinutes: serializer.fromJson<int>(json['restBeforeMinutes']),
      timeFactoredDutyMinutes: serializer.fromJson<int>(
        json['timeFactoredDutyMinutes'],
      ),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dutyStartTimeLineId': serializer.toJson<int>(dutyStartTimeLineId),
      'dutyEndTimeLineId': serializer.toJson<int>(dutyEndTimeLineId),
      'timeDutyMinutes': serializer.toJson<int>(timeDutyMinutes),
      'restBeforeMinutes': serializer.toJson<int>(restBeforeMinutes),
      'timeFactoredDutyMinutes': serializer.toJson<int>(
        timeFactoredDutyMinutes,
      ),
      'isLocked': serializer.toJson<bool>(isLocked),
    };
  }

  DutyPeriod copyWith({
    int? id,
    int? dutyStartTimeLineId,
    int? dutyEndTimeLineId,
    int? timeDutyMinutes,
    int? restBeforeMinutes,
    int? timeFactoredDutyMinutes,
    bool? isLocked,
  }) => DutyPeriod(
    id: id ?? this.id,
    dutyStartTimeLineId: dutyStartTimeLineId ?? this.dutyStartTimeLineId,
    dutyEndTimeLineId: dutyEndTimeLineId ?? this.dutyEndTimeLineId,
    timeDutyMinutes: timeDutyMinutes ?? this.timeDutyMinutes,
    restBeforeMinutes: restBeforeMinutes ?? this.restBeforeMinutes,
    timeFactoredDutyMinutes:
        timeFactoredDutyMinutes ?? this.timeFactoredDutyMinutes,
    isLocked: isLocked ?? this.isLocked,
  );
  DutyPeriod copyWithCompanion(DutyPeriodsCompanion data) {
    return DutyPeriod(
      id: data.id.present ? data.id.value : this.id,
      dutyStartTimeLineId: data.dutyStartTimeLineId.present
          ? data.dutyStartTimeLineId.value
          : this.dutyStartTimeLineId,
      dutyEndTimeLineId: data.dutyEndTimeLineId.present
          ? data.dutyEndTimeLineId.value
          : this.dutyEndTimeLineId,
      timeDutyMinutes: data.timeDutyMinutes.present
          ? data.timeDutyMinutes.value
          : this.timeDutyMinutes,
      restBeforeMinutes: data.restBeforeMinutes.present
          ? data.restBeforeMinutes.value
          : this.restBeforeMinutes,
      timeFactoredDutyMinutes: data.timeFactoredDutyMinutes.present
          ? data.timeFactoredDutyMinutes.value
          : this.timeFactoredDutyMinutes,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DutyPeriod(')
          ..write('id: $id, ')
          ..write('dutyStartTimeLineId: $dutyStartTimeLineId, ')
          ..write('dutyEndTimeLineId: $dutyEndTimeLineId, ')
          ..write('timeDutyMinutes: $timeDutyMinutes, ')
          ..write('restBeforeMinutes: $restBeforeMinutes, ')
          ..write('timeFactoredDutyMinutes: $timeFactoredDutyMinutes, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dutyStartTimeLineId,
    dutyEndTimeLineId,
    timeDutyMinutes,
    restBeforeMinutes,
    timeFactoredDutyMinutes,
    isLocked,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DutyPeriod &&
          other.id == this.id &&
          other.dutyStartTimeLineId == this.dutyStartTimeLineId &&
          other.dutyEndTimeLineId == this.dutyEndTimeLineId &&
          other.timeDutyMinutes == this.timeDutyMinutes &&
          other.restBeforeMinutes == this.restBeforeMinutes &&
          other.timeFactoredDutyMinutes == this.timeFactoredDutyMinutes &&
          other.isLocked == this.isLocked);
}

class DutyPeriodsCompanion extends UpdateCompanion<DutyPeriod> {
  final Value<int> id;
  final Value<int> dutyStartTimeLineId;
  final Value<int> dutyEndTimeLineId;
  final Value<int> timeDutyMinutes;
  final Value<int> restBeforeMinutes;
  final Value<int> timeFactoredDutyMinutes;
  final Value<bool> isLocked;
  const DutyPeriodsCompanion({
    this.id = const Value.absent(),
    this.dutyStartTimeLineId = const Value.absent(),
    this.dutyEndTimeLineId = const Value.absent(),
    this.timeDutyMinutes = const Value.absent(),
    this.restBeforeMinutes = const Value.absent(),
    this.timeFactoredDutyMinutes = const Value.absent(),
    this.isLocked = const Value.absent(),
  });
  DutyPeriodsCompanion.insert({
    this.id = const Value.absent(),
    required int dutyStartTimeLineId,
    required int dutyEndTimeLineId,
    required int timeDutyMinutes,
    this.restBeforeMinutes = const Value.absent(),
    required int timeFactoredDutyMinutes,
    required bool isLocked,
  }) : dutyStartTimeLineId = Value(dutyStartTimeLineId),
       dutyEndTimeLineId = Value(dutyEndTimeLineId),
       timeDutyMinutes = Value(timeDutyMinutes),
       timeFactoredDutyMinutes = Value(timeFactoredDutyMinutes),
       isLocked = Value(isLocked);
  static Insertable<DutyPeriod> custom({
    Expression<int>? id,
    Expression<int>? dutyStartTimeLineId,
    Expression<int>? dutyEndTimeLineId,
    Expression<int>? timeDutyMinutes,
    Expression<int>? restBeforeMinutes,
    Expression<int>? timeFactoredDutyMinutes,
    Expression<bool>? isLocked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dutyStartTimeLineId != null)
        'duty_start_time_line_id': dutyStartTimeLineId,
      if (dutyEndTimeLineId != null) 'duty_end_time_line_id': dutyEndTimeLineId,
      if (timeDutyMinutes != null) 'time_duty_minutes': timeDutyMinutes,
      if (restBeforeMinutes != null) 'rest_before_minutes': restBeforeMinutes,
      if (timeFactoredDutyMinutes != null)
        'time_factored_duty_minutes': timeFactoredDutyMinutes,
      if (isLocked != null) 'is_locked': isLocked,
    });
  }

  DutyPeriodsCompanion copyWith({
    Value<int>? id,
    Value<int>? dutyStartTimeLineId,
    Value<int>? dutyEndTimeLineId,
    Value<int>? timeDutyMinutes,
    Value<int>? restBeforeMinutes,
    Value<int>? timeFactoredDutyMinutes,
    Value<bool>? isLocked,
  }) {
    return DutyPeriodsCompanion(
      id: id ?? this.id,
      dutyStartTimeLineId: dutyStartTimeLineId ?? this.dutyStartTimeLineId,
      dutyEndTimeLineId: dutyEndTimeLineId ?? this.dutyEndTimeLineId,
      timeDutyMinutes: timeDutyMinutes ?? this.timeDutyMinutes,
      restBeforeMinutes: restBeforeMinutes ?? this.restBeforeMinutes,
      timeFactoredDutyMinutes:
          timeFactoredDutyMinutes ?? this.timeFactoredDutyMinutes,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dutyStartTimeLineId.present) {
      map['duty_start_time_line_id'] = Variable<int>(dutyStartTimeLineId.value);
    }
    if (dutyEndTimeLineId.present) {
      map['duty_end_time_line_id'] = Variable<int>(dutyEndTimeLineId.value);
    }
    if (timeDutyMinutes.present) {
      map['time_duty_minutes'] = Variable<int>(timeDutyMinutes.value);
    }
    if (restBeforeMinutes.present) {
      map['rest_before_minutes'] = Variable<int>(restBeforeMinutes.value);
    }
    if (timeFactoredDutyMinutes.present) {
      map['time_factored_duty_minutes'] = Variable<int>(
        timeFactoredDutyMinutes.value,
      );
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DutyPeriodsCompanion(')
          ..write('id: $id, ')
          ..write('dutyStartTimeLineId: $dutyStartTimeLineId, ')
          ..write('dutyEndTimeLineId: $dutyEndTimeLineId, ')
          ..write('timeDutyMinutes: $timeDutyMinutes, ')
          ..write('restBeforeMinutes: $restBeforeMinutes, ')
          ..write('timeFactoredDutyMinutes: $timeFactoredDutyMinutes, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }
}

class $CrewTable extends Crew with TableInfo<$CrewTable, CrewData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CrewTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pictureMeta = const VerificationMeta(
    'picture',
  );
  @override
  late final GeneratedColumn<Uint8List> picture = GeneratedColumn<Uint8List>(
    'picture',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSelfMeta = const VerificationMeta('isSelf');
  @override
  late final GeneratedColumn<bool> isSelf = GeneratedColumn<bool>(
    'is_self',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_self" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    email,
    notes,
    phone,
    picture,
    isSelf,
    isFavorite,
    isLocked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crew';
  @override
  VerificationContext validateIntegrity(
    Insertable<CrewData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('picture')) {
      context.handle(
        _pictureMeta,
        picture.isAcceptableOrUnknown(data['picture']!, _pictureMeta),
      );
    }
    if (data.containsKey('is_self')) {
      context.handle(
        _isSelfMeta,
        isSelf.isAcceptableOrUnknown(data['is_self']!, _isSelfMeta),
      );
    } else if (isInserting) {
      context.missing(_isSelfMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    } else if (isInserting) {
      context.missing(_isFavoriteMeta);
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    } else if (isInserting) {
      context.missing(_isLockedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CrewData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CrewData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      picture: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}picture'],
      ),
      isSelf: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_self'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
    );
  }

  @override
  $CrewTable createAlias(String alias) {
    return $CrewTable(attachedDatabase, alias);
  }
}

class CrewData extends DataClass implements Insertable<CrewData> {
  /// Surrogate primary key.
  final int id;

  /// Crew display name.
  final String name;

  /// Optional email address.
  final String? email;

  /// Optional notes/comments.
  final String? notes;

  /// Optional phone number.
  final String? phone;

  /// Optional crew photo.
  final Uint8List? picture;

  /// Marks the profile representing the user.
  final bool isSelf;

  /// Favorite/pinned flag.
  final bool isFavorite;

  /// Lock flag preventing edits.
  final bool isLocked;
  const CrewData({
    required this.id,
    required this.name,
    this.email,
    this.notes,
    this.phone,
    this.picture,
    required this.isSelf,
    required this.isFavorite,
    required this.isLocked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || picture != null) {
      map['picture'] = Variable<Uint8List>(picture);
    }
    map['is_self'] = Variable<bool>(isSelf);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_locked'] = Variable<bool>(isLocked);
    return map;
  }

  CrewCompanion toCompanion(bool nullToAbsent) {
    return CrewCompanion(
      id: Value(id),
      name: Value(name),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      picture: picture == null && nullToAbsent
          ? const Value.absent()
          : Value(picture),
      isSelf: Value(isSelf),
      isFavorite: Value(isFavorite),
      isLocked: Value(isLocked),
    );
  }

  factory CrewData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CrewData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      notes: serializer.fromJson<String?>(json['notes']),
      phone: serializer.fromJson<String?>(json['phone']),
      picture: serializer.fromJson<Uint8List?>(json['picture']),
      isSelf: serializer.fromJson<bool>(json['isSelf']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String?>(email),
      'notes': serializer.toJson<String?>(notes),
      'phone': serializer.toJson<String?>(phone),
      'picture': serializer.toJson<Uint8List?>(picture),
      'isSelf': serializer.toJson<bool>(isSelf),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isLocked': serializer.toJson<bool>(isLocked),
    };
  }

  CrewData copyWith({
    int? id,
    String? name,
    Value<String?> email = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<Uint8List?> picture = const Value.absent(),
    bool? isSelf,
    bool? isFavorite,
    bool? isLocked,
  }) => CrewData(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email.present ? email.value : this.email,
    notes: notes.present ? notes.value : this.notes,
    phone: phone.present ? phone.value : this.phone,
    picture: picture.present ? picture.value : this.picture,
    isSelf: isSelf ?? this.isSelf,
    isFavorite: isFavorite ?? this.isFavorite,
    isLocked: isLocked ?? this.isLocked,
  );
  CrewData copyWithCompanion(CrewCompanion data) {
    return CrewData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      notes: data.notes.present ? data.notes.value : this.notes,
      phone: data.phone.present ? data.phone.value : this.phone,
      picture: data.picture.present ? data.picture.value : this.picture,
      isSelf: data.isSelf.present ? data.isSelf.value : this.isSelf,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CrewData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('notes: $notes, ')
          ..write('phone: $phone, ')
          ..write('picture: $picture, ')
          ..write('isSelf: $isSelf, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    email,
    notes,
    phone,
    $driftBlobEquality.hash(picture),
    isSelf,
    isFavorite,
    isLocked,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CrewData &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.notes == this.notes &&
          other.phone == this.phone &&
          $driftBlobEquality.equals(other.picture, this.picture) &&
          other.isSelf == this.isSelf &&
          other.isFavorite == this.isFavorite &&
          other.isLocked == this.isLocked);
}

class CrewCompanion extends UpdateCompanion<CrewData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> email;
  final Value<String?> notes;
  final Value<String?> phone;
  final Value<Uint8List?> picture;
  final Value<bool> isSelf;
  final Value<bool> isFavorite;
  final Value<bool> isLocked;
  const CrewCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    this.phone = const Value.absent(),
    this.picture = const Value.absent(),
    this.isSelf = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isLocked = const Value.absent(),
  });
  CrewCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    this.phone = const Value.absent(),
    this.picture = const Value.absent(),
    required bool isSelf,
    required bool isFavorite,
    required bool isLocked,
  }) : name = Value(name),
       isSelf = Value(isSelf),
       isFavorite = Value(isFavorite),
       isLocked = Value(isLocked);
  static Insertable<CrewData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? notes,
    Expression<String>? phone,
    Expression<Uint8List>? picture,
    Expression<bool>? isSelf,
    Expression<bool>? isFavorite,
    Expression<bool>? isLocked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (notes != null) 'notes': notes,
      if (phone != null) 'phone': phone,
      if (picture != null) 'picture': picture,
      if (isSelf != null) 'is_self': isSelf,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isLocked != null) 'is_locked': isLocked,
    });
  }

  CrewCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? email,
    Value<String?>? notes,
    Value<String?>? phone,
    Value<Uint8List?>? picture,
    Value<bool>? isSelf,
    Value<bool>? isFavorite,
    Value<bool>? isLocked,
  }) {
    return CrewCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      phone: phone ?? this.phone,
      picture: picture ?? this.picture,
      isSelf: isSelf ?? this.isSelf,
      isFavorite: isFavorite ?? this.isFavorite,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (picture.present) {
      map['picture'] = Variable<Uint8List>(picture.value);
    }
    if (isSelf.present) {
      map['is_self'] = Variable<bool>(isSelf.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CrewCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('notes: $notes, ')
          ..write('phone: $phone, ')
          ..write('picture: $picture, ')
          ..write('isSelf: $isSelf, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isLocked: $isLocked')
          ..write(')'))
        .toString();
  }
}

class $FlightCrewAssignmentsTable extends FlightCrewAssignments
    with TableInfo<$FlightCrewAssignmentsTable, FlightCrewAssignment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlightCrewAssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _flightIdMeta = const VerificationMeta(
    'flightId',
  );
  @override
  late final GeneratedColumn<int> flightId = GeneratedColumn<int>(
    'flight_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES flights (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _crewIdMeta = const VerificationMeta('crewId');
  @override
  late final GeneratedColumn<int> crewId = GeneratedColumn<int>(
    'crew_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES crew (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CrewPosition, String> position =
      GeneratedColumn<String>(
        'position',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CrewPosition>(
        $FlightCrewAssignmentsTable.$converterposition,
      );
  @override
  List<GeneratedColumn> get $columns => [id, flightId, crewId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flight_crew_assignments';
  @override
  VerificationContext validateIntegrity(
    Insertable<FlightCrewAssignment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('flight_id')) {
      context.handle(
        _flightIdMeta,
        flightId.isAcceptableOrUnknown(data['flight_id']!, _flightIdMeta),
      );
    } else if (isInserting) {
      context.missing(_flightIdMeta);
    }
    if (data.containsKey('crew_id')) {
      context.handle(
        _crewIdMeta,
        crewId.isAcceptableOrUnknown(data['crew_id']!, _crewIdMeta),
      );
    } else if (isInserting) {
      context.missing(_crewIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FlightCrewAssignment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlightCrewAssignment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      flightId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flight_id'],
      )!,
      crewId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}crew_id'],
      )!,
      position: $FlightCrewAssignmentsTable.$converterposition.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}position'],
        )!,
      ),
    );
  }

  @override
  $FlightCrewAssignmentsTable createAlias(String alias) {
    return $FlightCrewAssignmentsTable(attachedDatabase, alias);
  }

  static TypeConverter<CrewPosition, String> $converterposition =
      const CrewPositionConverter();
}

class FlightCrewAssignment extends DataClass
    implements Insertable<FlightCrewAssignment> {
  /// Primary key for the assignment row.
  final int id;

  /// Referenced flight.
  final int flightId;

  /// Referenced crew member.
  final int crewId;

  /// Crew role encoded using [CrewPositionConverter].
  final CrewPosition position;
  const FlightCrewAssignment({
    required this.id,
    required this.flightId,
    required this.crewId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['flight_id'] = Variable<int>(flightId);
    map['crew_id'] = Variable<int>(crewId);
    {
      map['position'] = Variable<String>(
        $FlightCrewAssignmentsTable.$converterposition.toSql(position),
      );
    }
    return map;
  }

  FlightCrewAssignmentsCompanion toCompanion(bool nullToAbsent) {
    return FlightCrewAssignmentsCompanion(
      id: Value(id),
      flightId: Value(flightId),
      crewId: Value(crewId),
      position: Value(position),
    );
  }

  factory FlightCrewAssignment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlightCrewAssignment(
      id: serializer.fromJson<int>(json['id']),
      flightId: serializer.fromJson<int>(json['flightId']),
      crewId: serializer.fromJson<int>(json['crewId']),
      position: serializer.fromJson<CrewPosition>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'flightId': serializer.toJson<int>(flightId),
      'crewId': serializer.toJson<int>(crewId),
      'position': serializer.toJson<CrewPosition>(position),
    };
  }

  FlightCrewAssignment copyWith({
    int? id,
    int? flightId,
    int? crewId,
    CrewPosition? position,
  }) => FlightCrewAssignment(
    id: id ?? this.id,
    flightId: flightId ?? this.flightId,
    crewId: crewId ?? this.crewId,
    position: position ?? this.position,
  );
  FlightCrewAssignment copyWithCompanion(FlightCrewAssignmentsCompanion data) {
    return FlightCrewAssignment(
      id: data.id.present ? data.id.value : this.id,
      flightId: data.flightId.present ? data.flightId.value : this.flightId,
      crewId: data.crewId.present ? data.crewId.value : this.crewId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlightCrewAssignment(')
          ..write('id: $id, ')
          ..write('flightId: $flightId, ')
          ..write('crewId: $crewId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, flightId, crewId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlightCrewAssignment &&
          other.id == this.id &&
          other.flightId == this.flightId &&
          other.crewId == this.crewId &&
          other.position == this.position);
}

class FlightCrewAssignmentsCompanion
    extends UpdateCompanion<FlightCrewAssignment> {
  final Value<int> id;
  final Value<int> flightId;
  final Value<int> crewId;
  final Value<CrewPosition> position;
  const FlightCrewAssignmentsCompanion({
    this.id = const Value.absent(),
    this.flightId = const Value.absent(),
    this.crewId = const Value.absent(),
    this.position = const Value.absent(),
  });
  FlightCrewAssignmentsCompanion.insert({
    this.id = const Value.absent(),
    required int flightId,
    required int crewId,
    required CrewPosition position,
  }) : flightId = Value(flightId),
       crewId = Value(crewId),
       position = Value(position);
  static Insertable<FlightCrewAssignment> custom({
    Expression<int>? id,
    Expression<int>? flightId,
    Expression<int>? crewId,
    Expression<String>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (flightId != null) 'flight_id': flightId,
      if (crewId != null) 'crew_id': crewId,
      if (position != null) 'position': position,
    });
  }

  FlightCrewAssignmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? flightId,
    Value<int>? crewId,
    Value<CrewPosition>? position,
  }) {
    return FlightCrewAssignmentsCompanion(
      id: id ?? this.id,
      flightId: flightId ?? this.flightId,
      crewId: crewId ?? this.crewId,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (flightId.present) {
      map['flight_id'] = Variable<int>(flightId.value);
    }
    if (crewId.present) {
      map['crew_id'] = Variable<int>(crewId.value);
    }
    if (position.present) {
      map['position'] = Variable<String>(
        $FlightCrewAssignmentsTable.$converterposition.toSql(position.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlightCrewAssignmentsCompanion(')
          ..write('id: $id, ')
          ..write('flightId: $flightId, ')
          ..write('crewId: $crewId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $SimulatorTrainingsTable extends SimulatorTrainings
    with TableInfo<$SimulatorTrainingsTable, SimulatorTraining> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SimulatorTrainingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _aircraftIdMeta = const VerificationMeta(
    'aircraftId',
  );
  @override
  late final GeneratedColumn<int> aircraftId = GeneratedColumn<int>(
    'aircraft_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES aircrafts (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _startTimeLineIdMeta = const VerificationMeta(
    'startTimeLineId',
  );
  @override
  late final GeneratedColumn<int> startTimeLineId = GeneratedColumn<int>(
    'start_time_line_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES time_lines (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _endDateTimeMeta = const VerificationMeta(
    'endDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> endDateTime = GeneratedColumn<DateTime>(
    'end_date_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeTotalMeta = const VerificationMeta(
    'timeTotal',
  );
  @override
  late final GeneratedColumn<int> timeTotal = GeneratedColumn<int>(
    'time_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLockedMeta = const VerificationMeta(
    'isLocked',
  );
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
    'is_locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_locked" IN (0, 1))',
    ),
  );
  static const VerificationMeta _signatureImageMeta = const VerificationMeta(
    'signatureImage',
  );
  @override
  late final GeneratedColumn<Uint8List> signatureImage =
      GeneratedColumn<Uint8List>(
        'signature_image',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _endorsementDataMeta = const VerificationMeta(
    'endorsementData',
  );
  @override
  late final GeneratedColumn<String> endorsementData = GeneratedColumn<String>(
    'endorsement_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endorsementHashMeta = const VerificationMeta(
    'endorsementHash',
  );
  @override
  late final GeneratedColumn<String> endorsementHash = GeneratedColumn<String>(
    'endorsement_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    aircraftId,
    startTimeLineId,
    endDateTime,
    timeTotal,
    remarks,
    notes,
    isLocked,
    signatureImage,
    endorsementData,
    endorsementHash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'simulator_trainings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SimulatorTraining> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('aircraft_id')) {
      context.handle(
        _aircraftIdMeta,
        aircraftId.isAcceptableOrUnknown(data['aircraft_id']!, _aircraftIdMeta),
      );
    } else if (isInserting) {
      context.missing(_aircraftIdMeta);
    }
    if (data.containsKey('start_time_line_id')) {
      context.handle(
        _startTimeLineIdMeta,
        startTimeLineId.isAcceptableOrUnknown(
          data['start_time_line_id']!,
          _startTimeLineIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startTimeLineIdMeta);
    }
    if (data.containsKey('end_date_time')) {
      context.handle(
        _endDateTimeMeta,
        endDateTime.isAcceptableOrUnknown(
          data['end_date_time']!,
          _endDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('time_total')) {
      context.handle(
        _timeTotalMeta,
        timeTotal.isAcceptableOrUnknown(data['time_total']!, _timeTotalMeta),
      );
    } else if (isInserting) {
      context.missing(_timeTotalMeta);
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    } else if (isInserting) {
      context.missing(_remarksMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('is_locked')) {
      context.handle(
        _isLockedMeta,
        isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta),
      );
    } else if (isInserting) {
      context.missing(_isLockedMeta);
    }
    if (data.containsKey('signature_image')) {
      context.handle(
        _signatureImageMeta,
        signatureImage.isAcceptableOrUnknown(
          data['signature_image']!,
          _signatureImageMeta,
        ),
      );
    }
    if (data.containsKey('endorsement_data')) {
      context.handle(
        _endorsementDataMeta,
        endorsementData.isAcceptableOrUnknown(
          data['endorsement_data']!,
          _endorsementDataMeta,
        ),
      );
    }
    if (data.containsKey('endorsement_hash')) {
      context.handle(
        _endorsementHashMeta,
        endorsementHash.isAcceptableOrUnknown(
          data['endorsement_hash']!,
          _endorsementHashMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SimulatorTraining map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SimulatorTraining(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      aircraftId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}aircraft_id'],
      )!,
      startTimeLineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time_line_id'],
      )!,
      endDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date_time'],
      ),
      timeTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_total'],
      )!,
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      isLocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_locked'],
      )!,
      signatureImage: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}signature_image'],
      ),
      endorsementData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endorsement_data'],
      ),
      endorsementHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}endorsement_hash'],
      ),
    );
  }

  @override
  $SimulatorTrainingsTable createAlias(String alias) {
    return $SimulatorTrainingsTable(attachedDatabase, alias);
  }
}

class SimulatorTraining extends DataClass
    implements Insertable<SimulatorTraining> {
  /// Surrogate primary key.
  final int id;

  /// Linked aircraft id (simulator-capable aircraft row).
  final int aircraftId;

  /// Start timeline reference.
  final int startTimeLineId;

  /// Optional end datetime.
  final DateTime? endDateTime;

  /// Session total in minutes.
  final int timeTotal;

  /// User remarks.
  final String remarks;

  /// Private notes.
  final String notes;

  /// Lock flag preventing edits.
  final bool isLocked;

  /// Optional endorsement signature image.
  final Uint8List? signatureImage;

  /// Optional serialized endorsement metadata.
  final String? endorsementData;

  /// Hash used to verify endorsement integrity.
  final String? endorsementHash;
  const SimulatorTraining({
    required this.id,
    required this.aircraftId,
    required this.startTimeLineId,
    this.endDateTime,
    required this.timeTotal,
    required this.remarks,
    required this.notes,
    required this.isLocked,
    this.signatureImage,
    this.endorsementData,
    this.endorsementHash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['aircraft_id'] = Variable<int>(aircraftId);
    map['start_time_line_id'] = Variable<int>(startTimeLineId);
    if (!nullToAbsent || endDateTime != null) {
      map['end_date_time'] = Variable<DateTime>(endDateTime);
    }
    map['time_total'] = Variable<int>(timeTotal);
    map['remarks'] = Variable<String>(remarks);
    map['notes'] = Variable<String>(notes);
    map['is_locked'] = Variable<bool>(isLocked);
    if (!nullToAbsent || signatureImage != null) {
      map['signature_image'] = Variable<Uint8List>(signatureImage);
    }
    if (!nullToAbsent || endorsementData != null) {
      map['endorsement_data'] = Variable<String>(endorsementData);
    }
    if (!nullToAbsent || endorsementHash != null) {
      map['endorsement_hash'] = Variable<String>(endorsementHash);
    }
    return map;
  }

  SimulatorTrainingsCompanion toCompanion(bool nullToAbsent) {
    return SimulatorTrainingsCompanion(
      id: Value(id),
      aircraftId: Value(aircraftId),
      startTimeLineId: Value(startTimeLineId),
      endDateTime: endDateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endDateTime),
      timeTotal: Value(timeTotal),
      remarks: Value(remarks),
      notes: Value(notes),
      isLocked: Value(isLocked),
      signatureImage: signatureImage == null && nullToAbsent
          ? const Value.absent()
          : Value(signatureImage),
      endorsementData: endorsementData == null && nullToAbsent
          ? const Value.absent()
          : Value(endorsementData),
      endorsementHash: endorsementHash == null && nullToAbsent
          ? const Value.absent()
          : Value(endorsementHash),
    );
  }

  factory SimulatorTraining.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SimulatorTraining(
      id: serializer.fromJson<int>(json['id']),
      aircraftId: serializer.fromJson<int>(json['aircraftId']),
      startTimeLineId: serializer.fromJson<int>(json['startTimeLineId']),
      endDateTime: serializer.fromJson<DateTime?>(json['endDateTime']),
      timeTotal: serializer.fromJson<int>(json['timeTotal']),
      remarks: serializer.fromJson<String>(json['remarks']),
      notes: serializer.fromJson<String>(json['notes']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
      signatureImage: serializer.fromJson<Uint8List?>(json['signatureImage']),
      endorsementData: serializer.fromJson<String?>(json['endorsementData']),
      endorsementHash: serializer.fromJson<String?>(json['endorsementHash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'aircraftId': serializer.toJson<int>(aircraftId),
      'startTimeLineId': serializer.toJson<int>(startTimeLineId),
      'endDateTime': serializer.toJson<DateTime?>(endDateTime),
      'timeTotal': serializer.toJson<int>(timeTotal),
      'remarks': serializer.toJson<String>(remarks),
      'notes': serializer.toJson<String>(notes),
      'isLocked': serializer.toJson<bool>(isLocked),
      'signatureImage': serializer.toJson<Uint8List?>(signatureImage),
      'endorsementData': serializer.toJson<String?>(endorsementData),
      'endorsementHash': serializer.toJson<String?>(endorsementHash),
    };
  }

  SimulatorTraining copyWith({
    int? id,
    int? aircraftId,
    int? startTimeLineId,
    Value<DateTime?> endDateTime = const Value.absent(),
    int? timeTotal,
    String? remarks,
    String? notes,
    bool? isLocked,
    Value<Uint8List?> signatureImage = const Value.absent(),
    Value<String?> endorsementData = const Value.absent(),
    Value<String?> endorsementHash = const Value.absent(),
  }) => SimulatorTraining(
    id: id ?? this.id,
    aircraftId: aircraftId ?? this.aircraftId,
    startTimeLineId: startTimeLineId ?? this.startTimeLineId,
    endDateTime: endDateTime.present ? endDateTime.value : this.endDateTime,
    timeTotal: timeTotal ?? this.timeTotal,
    remarks: remarks ?? this.remarks,
    notes: notes ?? this.notes,
    isLocked: isLocked ?? this.isLocked,
    signatureImage: signatureImage.present
        ? signatureImage.value
        : this.signatureImage,
    endorsementData: endorsementData.present
        ? endorsementData.value
        : this.endorsementData,
    endorsementHash: endorsementHash.present
        ? endorsementHash.value
        : this.endorsementHash,
  );
  SimulatorTraining copyWithCompanion(SimulatorTrainingsCompanion data) {
    return SimulatorTraining(
      id: data.id.present ? data.id.value : this.id,
      aircraftId: data.aircraftId.present
          ? data.aircraftId.value
          : this.aircraftId,
      startTimeLineId: data.startTimeLineId.present
          ? data.startTimeLineId.value
          : this.startTimeLineId,
      endDateTime: data.endDateTime.present
          ? data.endDateTime.value
          : this.endDateTime,
      timeTotal: data.timeTotal.present ? data.timeTotal.value : this.timeTotal,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      notes: data.notes.present ? data.notes.value : this.notes,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
      signatureImage: data.signatureImage.present
          ? data.signatureImage.value
          : this.signatureImage,
      endorsementData: data.endorsementData.present
          ? data.endorsementData.value
          : this.endorsementData,
      endorsementHash: data.endorsementHash.present
          ? data.endorsementHash.value
          : this.endorsementHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SimulatorTraining(')
          ..write('id: $id, ')
          ..write('aircraftId: $aircraftId, ')
          ..write('startTimeLineId: $startTimeLineId, ')
          ..write('endDateTime: $endDateTime, ')
          ..write('timeTotal: $timeTotal, ')
          ..write('remarks: $remarks, ')
          ..write('notes: $notes, ')
          ..write('isLocked: $isLocked, ')
          ..write('signatureImage: $signatureImage, ')
          ..write('endorsementData: $endorsementData, ')
          ..write('endorsementHash: $endorsementHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    aircraftId,
    startTimeLineId,
    endDateTime,
    timeTotal,
    remarks,
    notes,
    isLocked,
    $driftBlobEquality.hash(signatureImage),
    endorsementData,
    endorsementHash,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SimulatorTraining &&
          other.id == this.id &&
          other.aircraftId == this.aircraftId &&
          other.startTimeLineId == this.startTimeLineId &&
          other.endDateTime == this.endDateTime &&
          other.timeTotal == this.timeTotal &&
          other.remarks == this.remarks &&
          other.notes == this.notes &&
          other.isLocked == this.isLocked &&
          $driftBlobEquality.equals(
            other.signatureImage,
            this.signatureImage,
          ) &&
          other.endorsementData == this.endorsementData &&
          other.endorsementHash == this.endorsementHash);
}

class SimulatorTrainingsCompanion extends UpdateCompanion<SimulatorTraining> {
  final Value<int> id;
  final Value<int> aircraftId;
  final Value<int> startTimeLineId;
  final Value<DateTime?> endDateTime;
  final Value<int> timeTotal;
  final Value<String> remarks;
  final Value<String> notes;
  final Value<bool> isLocked;
  final Value<Uint8List?> signatureImage;
  final Value<String?> endorsementData;
  final Value<String?> endorsementHash;
  const SimulatorTrainingsCompanion({
    this.id = const Value.absent(),
    this.aircraftId = const Value.absent(),
    this.startTimeLineId = const Value.absent(),
    this.endDateTime = const Value.absent(),
    this.timeTotal = const Value.absent(),
    this.remarks = const Value.absent(),
    this.notes = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.signatureImage = const Value.absent(),
    this.endorsementData = const Value.absent(),
    this.endorsementHash = const Value.absent(),
  });
  SimulatorTrainingsCompanion.insert({
    this.id = const Value.absent(),
    required int aircraftId,
    required int startTimeLineId,
    this.endDateTime = const Value.absent(),
    required int timeTotal,
    required String remarks,
    required String notes,
    required bool isLocked,
    this.signatureImage = const Value.absent(),
    this.endorsementData = const Value.absent(),
    this.endorsementHash = const Value.absent(),
  }) : aircraftId = Value(aircraftId),
       startTimeLineId = Value(startTimeLineId),
       timeTotal = Value(timeTotal),
       remarks = Value(remarks),
       notes = Value(notes),
       isLocked = Value(isLocked);
  static Insertable<SimulatorTraining> custom({
    Expression<int>? id,
    Expression<int>? aircraftId,
    Expression<int>? startTimeLineId,
    Expression<DateTime>? endDateTime,
    Expression<int>? timeTotal,
    Expression<String>? remarks,
    Expression<String>? notes,
    Expression<bool>? isLocked,
    Expression<Uint8List>? signatureImage,
    Expression<String>? endorsementData,
    Expression<String>? endorsementHash,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (aircraftId != null) 'aircraft_id': aircraftId,
      if (startTimeLineId != null) 'start_time_line_id': startTimeLineId,
      if (endDateTime != null) 'end_date_time': endDateTime,
      if (timeTotal != null) 'time_total': timeTotal,
      if (remarks != null) 'remarks': remarks,
      if (notes != null) 'notes': notes,
      if (isLocked != null) 'is_locked': isLocked,
      if (signatureImage != null) 'signature_image': signatureImage,
      if (endorsementData != null) 'endorsement_data': endorsementData,
      if (endorsementHash != null) 'endorsement_hash': endorsementHash,
    });
  }

  SimulatorTrainingsCompanion copyWith({
    Value<int>? id,
    Value<int>? aircraftId,
    Value<int>? startTimeLineId,
    Value<DateTime?>? endDateTime,
    Value<int>? timeTotal,
    Value<String>? remarks,
    Value<String>? notes,
    Value<bool>? isLocked,
    Value<Uint8List?>? signatureImage,
    Value<String?>? endorsementData,
    Value<String?>? endorsementHash,
  }) {
    return SimulatorTrainingsCompanion(
      id: id ?? this.id,
      aircraftId: aircraftId ?? this.aircraftId,
      startTimeLineId: startTimeLineId ?? this.startTimeLineId,
      endDateTime: endDateTime ?? this.endDateTime,
      timeTotal: timeTotal ?? this.timeTotal,
      remarks: remarks ?? this.remarks,
      notes: notes ?? this.notes,
      isLocked: isLocked ?? this.isLocked,
      signatureImage: signatureImage ?? this.signatureImage,
      endorsementData: endorsementData ?? this.endorsementData,
      endorsementHash: endorsementHash ?? this.endorsementHash,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (aircraftId.present) {
      map['aircraft_id'] = Variable<int>(aircraftId.value);
    }
    if (startTimeLineId.present) {
      map['start_time_line_id'] = Variable<int>(startTimeLineId.value);
    }
    if (endDateTime.present) {
      map['end_date_time'] = Variable<DateTime>(endDateTime.value);
    }
    if (timeTotal.present) {
      map['time_total'] = Variable<int>(timeTotal.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (signatureImage.present) {
      map['signature_image'] = Variable<Uint8List>(signatureImage.value);
    }
    if (endorsementData.present) {
      map['endorsement_data'] = Variable<String>(endorsementData.value);
    }
    if (endorsementHash.present) {
      map['endorsement_hash'] = Variable<String>(endorsementHash.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SimulatorTrainingsCompanion(')
          ..write('id: $id, ')
          ..write('aircraftId: $aircraftId, ')
          ..write('startTimeLineId: $startTimeLineId, ')
          ..write('endDateTime: $endDateTime, ')
          ..write('timeTotal: $timeTotal, ')
          ..write('remarks: $remarks, ')
          ..write('notes: $notes, ')
          ..write('isLocked: $isLocked, ')
          ..write('signatureImage: $signatureImage, ')
          ..write('endorsementData: $endorsementData, ')
          ..write('endorsementHash: $endorsementHash')
          ..write(')'))
        .toString();
  }
}

class $SimulatorCrewAssignmentsTable extends SimulatorCrewAssignments
    with TableInfo<$SimulatorCrewAssignmentsTable, SimulatorCrewAssignment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SimulatorCrewAssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _simulatorIdMeta = const VerificationMeta(
    'simulatorId',
  );
  @override
  late final GeneratedColumn<int> simulatorId = GeneratedColumn<int>(
    'simulator_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES simulator_trainings (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _crewIdMeta = const VerificationMeta('crewId');
  @override
  late final GeneratedColumn<int> crewId = GeneratedColumn<int>(
    'crew_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES crew (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CrewPosition, String> position =
      GeneratedColumn<String>(
        'position',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CrewPosition>(
        $SimulatorCrewAssignmentsTable.$converterposition,
      );
  @override
  List<GeneratedColumn> get $columns => [id, simulatorId, crewId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'simulator_crew_assignments';
  @override
  VerificationContext validateIntegrity(
    Insertable<SimulatorCrewAssignment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('simulator_id')) {
      context.handle(
        _simulatorIdMeta,
        simulatorId.isAcceptableOrUnknown(
          data['simulator_id']!,
          _simulatorIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_simulatorIdMeta);
    }
    if (data.containsKey('crew_id')) {
      context.handle(
        _crewIdMeta,
        crewId.isAcceptableOrUnknown(data['crew_id']!, _crewIdMeta),
      );
    } else if (isInserting) {
      context.missing(_crewIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SimulatorCrewAssignment map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SimulatorCrewAssignment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      simulatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}simulator_id'],
      )!,
      crewId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}crew_id'],
      )!,
      position: $SimulatorCrewAssignmentsTable.$converterposition.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}position'],
        )!,
      ),
    );
  }

  @override
  $SimulatorCrewAssignmentsTable createAlias(String alias) {
    return $SimulatorCrewAssignmentsTable(attachedDatabase, alias);
  }

  static TypeConverter<CrewPosition, String> $converterposition =
      const CrewPositionConverter();
}

class SimulatorCrewAssignment extends DataClass
    implements Insertable<SimulatorCrewAssignment> {
  /// Primary key for the assignment row.
  final int id;

  /// Referenced simulator training session.
  final int simulatorId;

  /// Referenced crew member.
  final int crewId;

  /// Crew role encoded using [CrewPositionConverter].
  final CrewPosition position;
  const SimulatorCrewAssignment({
    required this.id,
    required this.simulatorId,
    required this.crewId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['simulator_id'] = Variable<int>(simulatorId);
    map['crew_id'] = Variable<int>(crewId);
    {
      map['position'] = Variable<String>(
        $SimulatorCrewAssignmentsTable.$converterposition.toSql(position),
      );
    }
    return map;
  }

  SimulatorCrewAssignmentsCompanion toCompanion(bool nullToAbsent) {
    return SimulatorCrewAssignmentsCompanion(
      id: Value(id),
      simulatorId: Value(simulatorId),
      crewId: Value(crewId),
      position: Value(position),
    );
  }

  factory SimulatorCrewAssignment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SimulatorCrewAssignment(
      id: serializer.fromJson<int>(json['id']),
      simulatorId: serializer.fromJson<int>(json['simulatorId']),
      crewId: serializer.fromJson<int>(json['crewId']),
      position: serializer.fromJson<CrewPosition>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'simulatorId': serializer.toJson<int>(simulatorId),
      'crewId': serializer.toJson<int>(crewId),
      'position': serializer.toJson<CrewPosition>(position),
    };
  }

  SimulatorCrewAssignment copyWith({
    int? id,
    int? simulatorId,
    int? crewId,
    CrewPosition? position,
  }) => SimulatorCrewAssignment(
    id: id ?? this.id,
    simulatorId: simulatorId ?? this.simulatorId,
    crewId: crewId ?? this.crewId,
    position: position ?? this.position,
  );
  SimulatorCrewAssignment copyWithCompanion(
    SimulatorCrewAssignmentsCompanion data,
  ) {
    return SimulatorCrewAssignment(
      id: data.id.present ? data.id.value : this.id,
      simulatorId: data.simulatorId.present
          ? data.simulatorId.value
          : this.simulatorId,
      crewId: data.crewId.present ? data.crewId.value : this.crewId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SimulatorCrewAssignment(')
          ..write('id: $id, ')
          ..write('simulatorId: $simulatorId, ')
          ..write('crewId: $crewId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, simulatorId, crewId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SimulatorCrewAssignment &&
          other.id == this.id &&
          other.simulatorId == this.simulatorId &&
          other.crewId == this.crewId &&
          other.position == this.position);
}

class SimulatorCrewAssignmentsCompanion
    extends UpdateCompanion<SimulatorCrewAssignment> {
  final Value<int> id;
  final Value<int> simulatorId;
  final Value<int> crewId;
  final Value<CrewPosition> position;
  const SimulatorCrewAssignmentsCompanion({
    this.id = const Value.absent(),
    this.simulatorId = const Value.absent(),
    this.crewId = const Value.absent(),
    this.position = const Value.absent(),
  });
  SimulatorCrewAssignmentsCompanion.insert({
    this.id = const Value.absent(),
    required int simulatorId,
    required int crewId,
    required CrewPosition position,
  }) : simulatorId = Value(simulatorId),
       crewId = Value(crewId),
       position = Value(position);
  static Insertable<SimulatorCrewAssignment> custom({
    Expression<int>? id,
    Expression<int>? simulatorId,
    Expression<int>? crewId,
    Expression<String>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (simulatorId != null) 'simulator_id': simulatorId,
      if (crewId != null) 'crew_id': crewId,
      if (position != null) 'position': position,
    });
  }

  SimulatorCrewAssignmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? simulatorId,
    Value<int>? crewId,
    Value<CrewPosition>? position,
  }) {
    return SimulatorCrewAssignmentsCompanion(
      id: id ?? this.id,
      simulatorId: simulatorId ?? this.simulatorId,
      crewId: crewId ?? this.crewId,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (simulatorId.present) {
      map['simulator_id'] = Variable<int>(simulatorId.value);
    }
    if (crewId.present) {
      map['crew_id'] = Variable<int>(crewId.value);
    }
    if (position.present) {
      map['position'] = Variable<String>(
        $SimulatorCrewAssignmentsTable.$converterposition.toSql(position.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SimulatorCrewAssignmentsCompanion(')
          ..write('id: $id, ')
          ..write('simulatorId: $simulatorId, ')
          ..write('crewId: $crewId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  settingsJson =
      GeneratedColumn<String>(
        'settings_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      ).withConverter<Map<String, dynamic>>(
        $UserProfilesTable.$convertersettingsJson,
      );
  static const VerificationMeta _signatureImageMeta = const VerificationMeta(
    'signatureImage',
  );
  @override
  late final GeneratedColumn<Uint8List> signatureImage =
      GeneratedColumn<Uint8List>(
        'signature_image',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [id, settingsJson, signatureImage];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('signature_image')) {
      context.handle(
        _signatureImageMeta,
        signatureImage.isAcceptableOrUnknown(
          data['signature_image']!,
          _signatureImageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      settingsJson: $UserProfilesTable.$convertersettingsJson.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}settings_json'],
        )!,
      ),
      signatureImage: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}signature_image'],
      ),
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, dynamic>, String> $convertersettingsJson =
      const JsonMapConverter();
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  /// Single-row identifier (always `1`).
  final int id;

  /// User profile and preferences serialized as JSON.
  final Map<String, dynamic> settingsJson;

  /// Drawn pilot signature image (PNG bytes).
  final Uint8List? signatureImage;
  const UserProfile({
    required this.id,
    required this.settingsJson,
    this.signatureImage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['settings_json'] = Variable<String>(
        $UserProfilesTable.$convertersettingsJson.toSql(settingsJson),
      );
    }
    if (!nullToAbsent || signatureImage != null) {
      map['signature_image'] = Variable<Uint8List>(signatureImage);
    }
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      settingsJson: Value(settingsJson),
      signatureImage: signatureImage == null && nullToAbsent
          ? const Value.absent()
          : Value(signatureImage),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<int>(json['id']),
      settingsJson: serializer.fromJson<Map<String, dynamic>>(
        json['settingsJson'],
      ),
      signatureImage: serializer.fromJson<Uint8List?>(json['signatureImage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'settingsJson': serializer.toJson<Map<String, dynamic>>(settingsJson),
      'signatureImage': serializer.toJson<Uint8List?>(signatureImage),
    };
  }

  UserProfile copyWith({
    int? id,
    Map<String, dynamic>? settingsJson,
    Value<Uint8List?> signatureImage = const Value.absent(),
  }) => UserProfile(
    id: id ?? this.id,
    settingsJson: settingsJson ?? this.settingsJson,
    signatureImage: signatureImage.present
        ? signatureImage.value
        : this.signatureImage,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      settingsJson: data.settingsJson.present
          ? data.settingsJson.value
          : this.settingsJson,
      signatureImage: data.signatureImage.present
          ? data.signatureImage.value
          : this.signatureImage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('signatureImage: $signatureImage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, settingsJson, $driftBlobEquality.hash(signatureImage));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.settingsJson == this.settingsJson &&
          $driftBlobEquality.equals(other.signatureImage, this.signatureImage));
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<Map<String, dynamic>> settingsJson;
  final Value<Uint8List?> signatureImage;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.signatureImage = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.signatureImage = const Value.absent(),
  });
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<String>? settingsJson,
    Expression<Uint8List>? signatureImage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (settingsJson != null) 'settings_json': settingsJson,
      if (signatureImage != null) 'signature_image': signatureImage,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<Map<String, dynamic>>? settingsJson,
    Value<Uint8List?>? signatureImage,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      settingsJson: settingsJson ?? this.settingsJson,
      signatureImage: signatureImage ?? this.signatureImage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (settingsJson.present) {
      map['settings_json'] = Variable<String>(
        $UserProfilesTable.$convertersettingsJson.toSql(settingsJson.value),
      );
    }
    if (signatureImage.present) {
      map['signature_image'] = Variable<Uint8List>(signatureImage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('signatureImage: $signatureImage')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AircraftTypesTable aircraftTypes = $AircraftTypesTable(this);
  late final $AircraftsTable aircrafts = $AircraftsTable(this);
  late final $AirportsTable airports = $AirportsTable(this);
  late final $TimeLinesTable timeLines = $TimeLinesTable(this);
  late final $FlightsTable flights = $FlightsTable(this);
  late final $LimitRulesTable limitRules = $LimitRulesTable(this);
  late final $RuleSnapshotsTable ruleSnapshots = $RuleSnapshotsTable(this);
  late final $PositioningsTable positionings = $PositioningsTable(this);
  late final $PreviousExperiencesTable previousExperiences =
      $PreviousExperiencesTable(this);
  late final $ReportTemplatesTable reportTemplates = $ReportTemplatesTable(
    this,
  );
  late final $DutyPeriodsTable dutyPeriods = $DutyPeriodsTable(this);
  late final $CrewTable crew = $CrewTable(this);
  late final $FlightCrewAssignmentsTable flightCrewAssignments =
      $FlightCrewAssignmentsTable(this);
  late final $SimulatorTrainingsTable simulatorTrainings =
      $SimulatorTrainingsTable(this);
  late final $SimulatorCrewAssignmentsTable simulatorCrewAssignments =
      $SimulatorCrewAssignmentsTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    aircraftTypes,
    aircrafts,
    airports,
    timeLines,
    flights,
    limitRules,
    ruleSnapshots,
    positionings,
    previousExperiences,
    reportTemplates,
    dutyPeriods,
    crew,
    flightCrewAssignments,
    simulatorTrainings,
    simulatorCrewAssignments,
    userProfiles,
  ];
}

typedef $$AircraftTypesTableCreateCompanionBuilder =
    AircraftTypesCompanion Function({
      Value<int> id,
      required String code,
      required String family,
      required String longName,
      Value<String?> manufacturer,
      required AircraftCategory category,
      required EngineType engineType,
      required int mtow,
      required int engineCount,
      required bool multiPilot,
      required bool complex,
      required bool efis,
      required bool highPerformance,
      required bool isLocked,
    });
typedef $$AircraftTypesTableUpdateCompanionBuilder =
    AircraftTypesCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<String> family,
      Value<String> longName,
      Value<String?> manufacturer,
      Value<AircraftCategory> category,
      Value<EngineType> engineType,
      Value<int> mtow,
      Value<int> engineCount,
      Value<bool> multiPilot,
      Value<bool> complex,
      Value<bool> efis,
      Value<bool> highPerformance,
      Value<bool> isLocked,
    });

final class $$AircraftTypesTableReferences
    extends BaseReferences<_$AppDatabase, $AircraftTypesTable, AircraftType> {
  $$AircraftTypesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$AircraftsTable, List<Aircraft>>
  _aircraftsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.aircrafts,
    aliasName: $_aliasNameGenerator(
      db.aircraftTypes.id,
      db.aircrafts.aircraftTypeId,
    ),
  );

  $$AircraftsTableProcessedTableManager get aircraftsRefs {
    final manager = $$AircraftsTableTableManager(
      $_db,
      $_db.aircrafts,
    ).filter((f) => f.aircraftTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_aircraftsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PreviousExperiencesTable,
    List<PreviousExperience>
  >
  _previousExperiencesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.previousExperiences,
        aliasName: $_aliasNameGenerator(
          db.aircraftTypes.id,
          db.previousExperiences.aircraftTypeId,
        ),
      );

  $$PreviousExperiencesTableProcessedTableManager get previousExperiencesRefs {
    final manager = $$PreviousExperiencesTableTableManager(
      $_db,
      $_db.previousExperiences,
    ).filter((f) => f.aircraftTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _previousExperiencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AircraftTypesTableFilterComposer
    extends Composer<_$AppDatabase, $AircraftTypesTable> {
  $$AircraftTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get longName => $composableBuilder(
    column: $table.longName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AircraftCategory, AircraftCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<EngineType, EngineType, String>
  get engineType => $composableBuilder(
    column: $table.engineType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get mtow => $composableBuilder(
    column: $table.mtow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get engineCount => $composableBuilder(
    column: $table.engineCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get multiPilot => $composableBuilder(
    column: $table.multiPilot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get complex => $composableBuilder(
    column: $table.complex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get efis => $composableBuilder(
    column: $table.efis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get highPerformance => $composableBuilder(
    column: $table.highPerformance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> aircraftsRefs(
    Expression<bool> Function($$AircraftsTableFilterComposer f) f,
  ) {
    final $$AircraftsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.aircrafts,
      getReferencedColumn: (t) => t.aircraftTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AircraftsTableFilterComposer(
            $db: $db,
            $table: $db.aircrafts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> previousExperiencesRefs(
    Expression<bool> Function($$PreviousExperiencesTableFilterComposer f) f,
  ) {
    final $$PreviousExperiencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.previousExperiences,
      getReferencedColumn: (t) => t.aircraftTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreviousExperiencesTableFilterComposer(
            $db: $db,
            $table: $db.previousExperiences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AircraftTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $AircraftTypesTable> {
  $$AircraftTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get longName => $composableBuilder(
    column: $table.longName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get engineType => $composableBuilder(
    column: $table.engineType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mtow => $composableBuilder(
    column: $table.mtow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get engineCount => $composableBuilder(
    column: $table.engineCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get multiPilot => $composableBuilder(
    column: $table.multiPilot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get complex => $composableBuilder(
    column: $table.complex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get efis => $composableBuilder(
    column: $table.efis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get highPerformance => $composableBuilder(
    column: $table.highPerformance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AircraftTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AircraftTypesTable> {
  $$AircraftTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get family =>
      $composableBuilder(column: $table.family, builder: (column) => column);

  GeneratedColumn<String> get longName =>
      $composableBuilder(column: $table.longName, builder: (column) => column);

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AircraftCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EngineType, String> get engineType =>
      $composableBuilder(
        column: $table.engineType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get mtow =>
      $composableBuilder(column: $table.mtow, builder: (column) => column);

  GeneratedColumn<int> get engineCount => $composableBuilder(
    column: $table.engineCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get multiPilot => $composableBuilder(
    column: $table.multiPilot,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get complex =>
      $composableBuilder(column: $table.complex, builder: (column) => column);

  GeneratedColumn<bool> get efis =>
      $composableBuilder(column: $table.efis, builder: (column) => column);

  GeneratedColumn<bool> get highPerformance => $composableBuilder(
    column: $table.highPerformance,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  Expression<T> aircraftsRefs<T extends Object>(
    Expression<T> Function($$AircraftsTableAnnotationComposer a) f,
  ) {
    final $$AircraftsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.aircrafts,
      getReferencedColumn: (t) => t.aircraftTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AircraftsTableAnnotationComposer(
            $db: $db,
            $table: $db.aircrafts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> previousExperiencesRefs<T extends Object>(
    Expression<T> Function($$PreviousExperiencesTableAnnotationComposer a) f,
  ) {
    final $$PreviousExperiencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.previousExperiences,
          getReferencedColumn: (t) => t.aircraftTypeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PreviousExperiencesTableAnnotationComposer(
                $db: $db,
                $table: $db.previousExperiences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AircraftTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AircraftTypesTable,
          AircraftType,
          $$AircraftTypesTableFilterComposer,
          $$AircraftTypesTableOrderingComposer,
          $$AircraftTypesTableAnnotationComposer,
          $$AircraftTypesTableCreateCompanionBuilder,
          $$AircraftTypesTableUpdateCompanionBuilder,
          (AircraftType, $$AircraftTypesTableReferences),
          AircraftType,
          PrefetchHooks Function({
            bool aircraftsRefs,
            bool previousExperiencesRefs,
          })
        > {
  $$AircraftTypesTableTableManager(_$AppDatabase db, $AircraftTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AircraftTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AircraftTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AircraftTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> family = const Value.absent(),
                Value<String> longName = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                Value<AircraftCategory> category = const Value.absent(),
                Value<EngineType> engineType = const Value.absent(),
                Value<int> mtow = const Value.absent(),
                Value<int> engineCount = const Value.absent(),
                Value<bool> multiPilot = const Value.absent(),
                Value<bool> complex = const Value.absent(),
                Value<bool> efis = const Value.absent(),
                Value<bool> highPerformance = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
              }) => AircraftTypesCompanion(
                id: id,
                code: code,
                family: family,
                longName: longName,
                manufacturer: manufacturer,
                category: category,
                engineType: engineType,
                mtow: mtow,
                engineCount: engineCount,
                multiPilot: multiPilot,
                complex: complex,
                efis: efis,
                highPerformance: highPerformance,
                isLocked: isLocked,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String code,
                required String family,
                required String longName,
                Value<String?> manufacturer = const Value.absent(),
                required AircraftCategory category,
                required EngineType engineType,
                required int mtow,
                required int engineCount,
                required bool multiPilot,
                required bool complex,
                required bool efis,
                required bool highPerformance,
                required bool isLocked,
              }) => AircraftTypesCompanion.insert(
                id: id,
                code: code,
                family: family,
                longName: longName,
                manufacturer: manufacturer,
                category: category,
                engineType: engineType,
                mtow: mtow,
                engineCount: engineCount,
                multiPilot: multiPilot,
                complex: complex,
                efis: efis,
                highPerformance: highPerformance,
                isLocked: isLocked,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AircraftTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({aircraftsRefs = false, previousExperiencesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (aircraftsRefs) db.aircrafts,
                    if (previousExperiencesRefs) db.previousExperiences,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (aircraftsRefs)
                        await $_getPrefetchedData<
                          AircraftType,
                          $AircraftTypesTable,
                          Aircraft
                        >(
                          currentTable: table,
                          referencedTable: $$AircraftTypesTableReferences
                              ._aircraftsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AircraftTypesTableReferences(
                                db,
                                table,
                                p0,
                              ).aircraftsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.aircraftTypeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (previousExperiencesRefs)
                        await $_getPrefetchedData<
                          AircraftType,
                          $AircraftTypesTable,
                          PreviousExperience
                        >(
                          currentTable: table,
                          referencedTable: $$AircraftTypesTableReferences
                              ._previousExperiencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AircraftTypesTableReferences(
                                db,
                                table,
                                p0,
                              ).previousExperiencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.aircraftTypeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AircraftTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AircraftTypesTable,
      AircraftType,
      $$AircraftTypesTableFilterComposer,
      $$AircraftTypesTableOrderingComposer,
      $$AircraftTypesTableAnnotationComposer,
      $$AircraftTypesTableCreateCompanionBuilder,
      $$AircraftTypesTableUpdateCompanionBuilder,
      (AircraftType, $$AircraftTypesTableReferences),
      AircraftType,
      PrefetchHooks Function({bool aircraftsRefs, bool previousExperiencesRefs})
    >;
typedef $$AircraftsTableCreateCompanionBuilder =
    AircraftsCompanion Function({
      Value<int> id,
      required int aircraftTypeId,
      required String registration,
      Value<int?> mtow,
      required bool isSimulator,
      required bool isFavorite,
      required bool isLocked,
      Value<String?> notes,
    });
typedef $$AircraftsTableUpdateCompanionBuilder =
    AircraftsCompanion Function({
      Value<int> id,
      Value<int> aircraftTypeId,
      Value<String> registration,
      Value<int?> mtow,
      Value<bool> isSimulator,
      Value<bool> isFavorite,
      Value<bool> isLocked,
      Value<String?> notes,
    });

final class $$AircraftsTableReferences
    extends BaseReferences<_$AppDatabase, $AircraftsTable, Aircraft> {
  $$AircraftsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AircraftTypesTable _aircraftTypeIdTable(_$AppDatabase db) =>
      db.aircraftTypes.createAlias(
        $_aliasNameGenerator(db.aircrafts.aircraftTypeId, db.aircraftTypes.id),
      );

  $$AircraftTypesTableProcessedTableManager get aircraftTypeId {
    final $_column = $_itemColumn<int>('aircraft_type_id')!;

    final manager = $$AircraftTypesTableTableManager(
      $_db,
      $_db.aircraftTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_aircraftTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FlightsTable, List<Flight>> _flightsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.flights,
    aliasName: $_aliasNameGenerator(db.aircrafts.id, db.flights.aircraftId),
  );

  $$FlightsTableProcessedTableManager get flightsRefs {
    final manager = $$FlightsTableTableManager(
      $_db,
      $_db.flights,
    ).filter((f) => f.aircraftId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_flightsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SimulatorTrainingsTable, List<SimulatorTraining>>
  _simulatorTrainingsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.simulatorTrainings,
        aliasName: $_aliasNameGenerator(
          db.aircrafts.id,
          db.simulatorTrainings.aircraftId,
        ),
      );

  $$SimulatorTrainingsTableProcessedTableManager get simulatorTrainingsRefs {
    final manager = $$SimulatorTrainingsTableTableManager(
      $_db,
      $_db.simulatorTrainings,
    ).filter((f) => f.aircraftId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _simulatorTrainingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AircraftsTableFilterComposer
    extends Composer<_$AppDatabase, $AircraftsTable> {
  $$AircraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registration => $composableBuilder(
    column: $table.registration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mtow => $composableBuilder(
    column: $table.mtow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSimulator => $composableBuilder(
    column: $table.isSimulator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$AircraftTypesTableFilterComposer get aircraftTypeId {
    final $$AircraftTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.aircraftTypeId,
      referencedTable: $db.aircraftTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AircraftTypesTableFilterComposer(
            $db: $db,
            $table: $db.aircraftTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> flightsRefs(
    Expression<bool> Function($$FlightsTableFilterComposer f) f,
  ) {
    final $$FlightsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flights,
      getReferencedColumn: (t) => t.aircraftId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlightsTableFilterComposer(
            $db: $db,
            $table: $db.flights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> simulatorTrainingsRefs(
    Expression<bool> Function($$SimulatorTrainingsTableFilterComposer f) f,
  ) {
    final $$SimulatorTrainingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.simulatorTrainings,
      getReferencedColumn: (t) => t.aircraftId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SimulatorTrainingsTableFilterComposer(
            $db: $db,
            $table: $db.simulatorTrainings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AircraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $AircraftsTable> {
  $$AircraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registration => $composableBuilder(
    column: $table.registration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mtow => $composableBuilder(
    column: $table.mtow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSimulator => $composableBuilder(
    column: $table.isSimulator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$AircraftTypesTableOrderingComposer get aircraftTypeId {
    final $$AircraftTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.aircraftTypeId,
      referencedTable: $db.aircraftTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AircraftTypesTableOrderingComposer(
            $db: $db,
            $table: $db.aircraftTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AircraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AircraftsTable> {
  $$AircraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get registration => $composableBuilder(
    column: $table.registration,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mtow =>
      $composableBuilder(column: $table.mtow, builder: (column) => column);

  GeneratedColumn<bool> get isSimulator => $composableBuilder(
    column: $table.isSimulator,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$AircraftTypesTableAnnotationComposer get aircraftTypeId {
    final $$AircraftTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.aircraftTypeId,
      referencedTable: $db.aircraftTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AircraftTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.aircraftTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> flightsRefs<T extends Object>(
    Expression<T> Function($$FlightsTableAnnotationComposer a) f,
  ) {
    final $$FlightsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flights,
      getReferencedColumn: (t) => t.aircraftId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlightsTableAnnotationComposer(
            $db: $db,
            $table: $db.flights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> simulatorTrainingsRefs<T extends Object>(
    Expression<T> Function($$SimulatorTrainingsTableAnnotationComposer a) f,
  ) {
    final $$SimulatorTrainingsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.simulatorTrainings,
          getReferencedColumn: (t) => t.aircraftId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SimulatorTrainingsTableAnnotationComposer(
                $db: $db,
                $table: $db.simulatorTrainings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AircraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AircraftsTable,
          Aircraft,
          $$AircraftsTableFilterComposer,
          $$AircraftsTableOrderingComposer,
          $$AircraftsTableAnnotationComposer,
          $$AircraftsTableCreateCompanionBuilder,
          $$AircraftsTableUpdateCompanionBuilder,
          (Aircraft, $$AircraftsTableReferences),
          Aircraft,
          PrefetchHooks Function({
            bool aircraftTypeId,
            bool flightsRefs,
            bool simulatorTrainingsRefs,
          })
        > {
  $$AircraftsTableTableManager(_$AppDatabase db, $AircraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AircraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AircraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AircraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> aircraftTypeId = const Value.absent(),
                Value<String> registration = const Value.absent(),
                Value<int?> mtow = const Value.absent(),
                Value<bool> isSimulator = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => AircraftsCompanion(
                id: id,
                aircraftTypeId: aircraftTypeId,
                registration: registration,
                mtow: mtow,
                isSimulator: isSimulator,
                isFavorite: isFavorite,
                isLocked: isLocked,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int aircraftTypeId,
                required String registration,
                Value<int?> mtow = const Value.absent(),
                required bool isSimulator,
                required bool isFavorite,
                required bool isLocked,
                Value<String?> notes = const Value.absent(),
              }) => AircraftsCompanion.insert(
                id: id,
                aircraftTypeId: aircraftTypeId,
                registration: registration,
                mtow: mtow,
                isSimulator: isSimulator,
                isFavorite: isFavorite,
                isLocked: isLocked,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AircraftsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                aircraftTypeId = false,
                flightsRefs = false,
                simulatorTrainingsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (flightsRefs) db.flights,
                    if (simulatorTrainingsRefs) db.simulatorTrainings,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (aircraftTypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.aircraftTypeId,
                                    referencedTable: $$AircraftsTableReferences
                                        ._aircraftTypeIdTable(db),
                                    referencedColumn: $$AircraftsTableReferences
                                        ._aircraftTypeIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (flightsRefs)
                        await $_getPrefetchedData<
                          Aircraft,
                          $AircraftsTable,
                          Flight
                        >(
                          currentTable: table,
                          referencedTable: $$AircraftsTableReferences
                              ._flightsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AircraftsTableReferences(
                                db,
                                table,
                                p0,
                              ).flightsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.aircraftId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (simulatorTrainingsRefs)
                        await $_getPrefetchedData<
                          Aircraft,
                          $AircraftsTable,
                          SimulatorTraining
                        >(
                          currentTable: table,
                          referencedTable: $$AircraftsTableReferences
                              ._simulatorTrainingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AircraftsTableReferences(
                                db,
                                table,
                                p0,
                              ).simulatorTrainingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.aircraftId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AircraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AircraftsTable,
      Aircraft,
      $$AircraftsTableFilterComposer,
      $$AircraftsTableOrderingComposer,
      $$AircraftsTableAnnotationComposer,
      $$AircraftsTableCreateCompanionBuilder,
      $$AircraftsTableUpdateCompanionBuilder,
      (Aircraft, $$AircraftsTableReferences),
      Aircraft,
      PrefetchHooks Function({
        bool aircraftTypeId,
        bool flightsRefs,
        bool simulatorTrainingsRefs,
      })
    >;
typedef $$AirportsTableCreateCompanionBuilder =
    AirportsCompanion Function({
      Value<int> id,
      required String icao,
      Value<String?> iata,
      Value<String?> name,
      Value<String?> city,
      Value<String?> country,
      required double latitude,
      required double longitude,
      required bool isFavorite,
      required bool isLocked,
    });
typedef $$AirportsTableUpdateCompanionBuilder =
    AirportsCompanion Function({
      Value<int> id,
      Value<String> icao,
      Value<String?> iata,
      Value<String?> name,
      Value<String?> city,
      Value<String?> country,
      Value<double> latitude,
      Value<double> longitude,
      Value<bool> isFavorite,
      Value<bool> isLocked,
    });

class $$AirportsTableFilterComposer
    extends Composer<_$AppDatabase, $AirportsTable> {
  $$AirportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icao => $composableBuilder(
    column: $table.icao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iata => $composableBuilder(
    column: $table.iata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AirportsTableOrderingComposer
    extends Composer<_$AppDatabase, $AirportsTable> {
  $$AirportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icao => $composableBuilder(
    column: $table.icao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iata => $composableBuilder(
    column: $table.iata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AirportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AirportsTable> {
  $$AirportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get icao =>
      $composableBuilder(column: $table.icao, builder: (column) => column);

  GeneratedColumn<String> get iata =>
      $composableBuilder(column: $table.iata, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);
}

class $$AirportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AirportsTable,
          Airport,
          $$AirportsTableFilterComposer,
          $$AirportsTableOrderingComposer,
          $$AirportsTableAnnotationComposer,
          $$AirportsTableCreateCompanionBuilder,
          $$AirportsTableUpdateCompanionBuilder,
          (Airport, BaseReferences<_$AppDatabase, $AirportsTable, Airport>),
          Airport,
          PrefetchHooks Function()
        > {
  $$AirportsTableTableManager(_$AppDatabase db, $AirportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AirportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AirportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AirportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> icao = const Value.absent(),
                Value<String?> iata = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
              }) => AirportsCompanion(
                id: id,
                icao: icao,
                iata: iata,
                name: name,
                city: city,
                country: country,
                latitude: latitude,
                longitude: longitude,
                isFavorite: isFavorite,
                isLocked: isLocked,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String icao,
                Value<String?> iata = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> country = const Value.absent(),
                required double latitude,
                required double longitude,
                required bool isFavorite,
                required bool isLocked,
              }) => AirportsCompanion.insert(
                id: id,
                icao: icao,
                iata: iata,
                name: name,
                city: city,
                country: country,
                latitude: latitude,
                longitude: longitude,
                isFavorite: isFavorite,
                isLocked: isLocked,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AirportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AirportsTable,
      Airport,
      $$AirportsTableFilterComposer,
      $$AirportsTableOrderingComposer,
      $$AirportsTableAnnotationComposer,
      $$AirportsTableCreateCompanionBuilder,
      $$AirportsTableUpdateCompanionBuilder,
      (Airport, BaseReferences<_$AppDatabase, $AirportsTable, Airport>),
      Airport,
      PrefetchHooks Function()
    >;
typedef $$TimeLinesTableCreateCompanionBuilder =
    TimeLinesCompanion Function({
      Value<int> id,
      required DateTime eventDateTime,
    });
typedef $$TimeLinesTableUpdateCompanionBuilder =
    TimeLinesCompanion Function({Value<int> id, Value<DateTime> eventDateTime});

final class $$TimeLinesTableReferences
    extends BaseReferences<_$AppDatabase, $TimeLinesTable, TimeLine> {
  $$TimeLinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FlightsTable, List<Flight>> _flightsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.flights,
    aliasName: $_aliasNameGenerator(
      db.timeLines.id,
      db.flights.departureDateTimeId,
    ),
  );

  $$FlightsTableProcessedTableManager get flightsRefs {
    final manager = $$FlightsTableTableManager($_db, $_db.flights).filter(
      (f) => f.departureDateTimeId.id.sqlEquals($_itemColumn<int>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_flightsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PositioningsTable, List<Positioning>>
  _positioningsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.positionings,
    aliasName: $_aliasNameGenerator(
      db.timeLines.id,
      db.positionings.departureDateTimeId,
    ),
  );

  $$PositioningsTableProcessedTableManager get positioningsRefs {
    final manager = $$PositioningsTableTableManager($_db, $_db.positionings)
        .filter(
          (f) => f.departureDateTimeId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_positioningsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SimulatorTrainingsTable, List<SimulatorTraining>>
  _simulatorTrainingsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.simulatorTrainings,
        aliasName: $_aliasNameGenerator(
          db.timeLines.id,
          db.simulatorTrainings.startTimeLineId,
        ),
      );

  $$SimulatorTrainingsTableProcessedTableManager get simulatorTrainingsRefs {
    final manager = $$SimulatorTrainingsTableTableManager(
      $_db,
      $_db.simulatorTrainings,
    ).filter((f) => f.startTimeLineId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _simulatorTrainingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TimeLinesTableFilterComposer
    extends Composer<_$AppDatabase, $TimeLinesTable> {
  $$TimeLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eventDateTime => $composableBuilder(
    column: $table.eventDateTime,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> flightsRefs(
    Expression<bool> Function($$FlightsTableFilterComposer f) f,
  ) {
    final $$FlightsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flights,
      getReferencedColumn: (t) => t.departureDateTimeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlightsTableFilterComposer(
            $db: $db,
            $table: $db.flights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> positioningsRefs(
    Expression<bool> Function($$PositioningsTableFilterComposer f) f,
  ) {
    final $$PositioningsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.positionings,
      getReferencedColumn: (t) => t.departureDateTimeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PositioningsTableFilterComposer(
            $db: $db,
            $table: $db.positionings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> simulatorTrainingsRefs(
    Expression<bool> Function($$SimulatorTrainingsTableFilterComposer f) f,
  ) {
    final $$SimulatorTrainingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.simulatorTrainings,
      getReferencedColumn: (t) => t.startTimeLineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SimulatorTrainingsTableFilterComposer(
            $db: $db,
            $table: $db.simulatorTrainings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TimeLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $TimeLinesTable> {
  $$TimeLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eventDateTime => $composableBuilder(
    column: $table.eventDateTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimeLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimeLinesTable> {
  $$TimeLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get eventDateTime => $composableBuilder(
    column: $table.eventDateTime,
    builder: (column) => column,
  );

  Expression<T> flightsRefs<T extends Object>(
    Expression<T> Function($$FlightsTableAnnotationComposer a) f,
  ) {
    final $$FlightsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flights,
      getReferencedColumn: (t) => t.departureDateTimeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlightsTableAnnotationComposer(
            $db: $db,
            $table: $db.flights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> positioningsRefs<T extends Object>(
    Expression<T> Function($$PositioningsTableAnnotationComposer a) f,
  ) {
    final $$PositioningsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.positionings,
      getReferencedColumn: (t) => t.departureDateTimeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PositioningsTableAnnotationComposer(
            $db: $db,
            $table: $db.positionings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> simulatorTrainingsRefs<T extends Object>(
    Expression<T> Function($$SimulatorTrainingsTableAnnotationComposer a) f,
  ) {
    final $$SimulatorTrainingsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.simulatorTrainings,
          getReferencedColumn: (t) => t.startTimeLineId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SimulatorTrainingsTableAnnotationComposer(
                $db: $db,
                $table: $db.simulatorTrainings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TimeLinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimeLinesTable,
          TimeLine,
          $$TimeLinesTableFilterComposer,
          $$TimeLinesTableOrderingComposer,
          $$TimeLinesTableAnnotationComposer,
          $$TimeLinesTableCreateCompanionBuilder,
          $$TimeLinesTableUpdateCompanionBuilder,
          (TimeLine, $$TimeLinesTableReferences),
          TimeLine,
          PrefetchHooks Function({
            bool flightsRefs,
            bool positioningsRefs,
            bool simulatorTrainingsRefs,
          })
        > {
  $$TimeLinesTableTableManager(_$AppDatabase db, $TimeLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimeLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimeLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimeLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> eventDateTime = const Value.absent(),
              }) => TimeLinesCompanion(id: id, eventDateTime: eventDateTime),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime eventDateTime,
              }) => TimeLinesCompanion.insert(
                id: id,
                eventDateTime: eventDateTime,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TimeLinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                flightsRefs = false,
                positioningsRefs = false,
                simulatorTrainingsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (flightsRefs) db.flights,
                    if (positioningsRefs) db.positionings,
                    if (simulatorTrainingsRefs) db.simulatorTrainings,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (flightsRefs)
                        await $_getPrefetchedData<
                          TimeLine,
                          $TimeLinesTable,
                          Flight
                        >(
                          currentTable: table,
                          referencedTable: $$TimeLinesTableReferences
                              ._flightsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TimeLinesTableReferences(
                                db,
                                table,
                                p0,
                              ).flightsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.departureDateTimeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (positioningsRefs)
                        await $_getPrefetchedData<
                          TimeLine,
                          $TimeLinesTable,
                          Positioning
                        >(
                          currentTable: table,
                          referencedTable: $$TimeLinesTableReferences
                              ._positioningsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TimeLinesTableReferences(
                                db,
                                table,
                                p0,
                              ).positioningsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.departureDateTimeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (simulatorTrainingsRefs)
                        await $_getPrefetchedData<
                          TimeLine,
                          $TimeLinesTable,
                          SimulatorTraining
                        >(
                          currentTable: table,
                          referencedTable: $$TimeLinesTableReferences
                              ._simulatorTrainingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TimeLinesTableReferences(
                                db,
                                table,
                                p0,
                              ).simulatorTrainingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.startTimeLineId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TimeLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimeLinesTable,
      TimeLine,
      $$TimeLinesTableFilterComposer,
      $$TimeLinesTableOrderingComposer,
      $$TimeLinesTableAnnotationComposer,
      $$TimeLinesTableCreateCompanionBuilder,
      $$TimeLinesTableUpdateCompanionBuilder,
      (TimeLine, $$TimeLinesTableReferences),
      TimeLine,
      PrefetchHooks Function({
        bool flightsRefs,
        bool positioningsRefs,
        bool simulatorTrainingsRefs,
      })
    >;
typedef $$FlightsTableCreateCompanionBuilder =
    FlightsCompanion Function({
      Value<int> id,
      required int aircraftId,
      required int departureAirportId,
      required int arrivalAirportId,
      required int departureDateTimeId,
      Value<DateTime?> takeOffDateTime,
      Value<DateTime?> landingDateTime,
      Value<DateTime?> arrivalDateTime,
      required int timePICMinutes,
      required int timePICUSMinutes,
      required int timeSICMinutes,
      required int timeDualMinutes,
      required int timeInstructorMinutes,
      required int timeIFRMinutes,
      required int timeInstrumentMinutes,
      required int timeSimulatedInstrumentMinutes,
      required int timeNightMinutes,
      required int timeCrossCountryMinutes,
      required int timeCustom1Minutes,
      required int timeCustom2Minutes,
      required int timeCustom3Minutes,
      required int timeCustom4Minutes,
      required int timeFlightMinutes,
      required int timeBlockMinutes,
      Value<int> timeTotalBlockMinutes,
      required int distanceNM,
      required int ifrApproaches,
      required int takeOffsDays,
      required int takeOffsNight,
      required int landingsDay,
      required int landingsNight,
      Value<PilotFunction> pilotFunction,
      required String approachType,
      required String remarks,
      required String notes,
      required bool isLocked,
      Value<Uint8List?> signatureImage,
      Value<String?> endorsementData,
      Value<String?> endorsementHash,
    });
typedef $$FlightsTableUpdateCompanionBuilder =
    FlightsCompanion Function({
      Value<int> id,
      Value<int> aircraftId,
      Value<int> departureAirportId,
      Value<int> arrivalAirportId,
      Value<int> departureDateTimeId,
      Value<DateTime?> takeOffDateTime,
      Value<DateTime?> landingDateTime,
      Value<DateTime?> arrivalDateTime,
      Value<int> timePICMinutes,
      Value<int> timePICUSMinutes,
      Value<int> timeSICMinutes,
      Value<int> timeDualMinutes,
      Value<int> timeInstructorMinutes,
      Value<int> timeIFRMinutes,
      Value<int> timeInstrumentMinutes,
      Value<int> timeSimulatedInstrumentMinutes,
      Value<int> timeNightMinutes,
      Value<int> timeCrossCountryMinutes,
      Value<int> timeCustom1Minutes,
      Value<int> timeCustom2Minutes,
      Value<int> timeCustom3Minutes,
      Value<int> timeCustom4Minutes,
      Value<int> timeFlightMinutes,
      Value<int> timeBlockMinutes,
      Value<int> timeTotalBlockMinutes,
      Value<int> distanceNM,
      Value<int> ifrApproaches,
      Value<int> takeOffsDays,
      Value<int> takeOffsNight,
      Value<int> landingsDay,
      Value<int> landingsNight,
      Value<PilotFunction> pilotFunction,
      Value<String> approachType,
      Value<String> remarks,
      Value<String> notes,
      Value<bool> isLocked,
      Value<Uint8List?> signatureImage,
      Value<String?> endorsementData,
      Value<String?> endorsementHash,
    });

final class $$FlightsTableReferences
    extends BaseReferences<_$AppDatabase, $FlightsTable, Flight> {
  $$FlightsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AircraftsTable _aircraftIdTable(_$AppDatabase db) =>
      db.aircrafts.createAlias(
        $_aliasNameGenerator(db.flights.aircraftId, db.aircrafts.id),
      );

  $$AircraftsTableProcessedTableManager get aircraftId {
    final $_column = $_itemColumn<int>('aircraft_id')!;

    final manager = $$AircraftsTableTableManager(
      $_db,
      $_db.aircrafts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_aircraftIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AirportsTable _departureAirportIdTable(_$AppDatabase db) =>
      db.airports.createAlias(
        $_aliasNameGenerator(db.flights.departureAirportId, db.airports.id),
      );

  $$AirportsTableProcessedTableManager get departureAirportId {
    final $_column = $_itemColumn<int>('departure_airport_id')!;

    final manager = $$AirportsTableTableManager(
      $_db,
      $_db.airports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_departureAirportIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AirportsTable _arrivalAirportIdTable(_$AppDatabase db) =>
      db.airports.createAlias(
        $_aliasNameGenerator(db.flights.arrivalAirportId, db.airports.id),
      );

  $$AirportsTableProcessedTableManager get arrivalAirportId {
    final $_column = $_itemColumn<int>('arrival_airport_id')!;

    final manager = $$AirportsTableTableManager(
      $_db,
      $_db.airports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_arrivalAirportIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TimeLinesTable _departureDateTimeIdTable(_$AppDatabase db) =>
      db.timeLines.createAlias(
        $_aliasNameGenerator(db.flights.departureDateTimeId, db.timeLines.id),
      );

  $$TimeLinesTableProcessedTableManager get departureDateTimeId {
    final $_column = $_itemColumn<int>('departure_date_time_id')!;

    final manager = $$TimeLinesTableTableManager(
      $_db,
      $_db.timeLines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_departureDateTimeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $FlightCrewAssignmentsTable,
    List<FlightCrewAssignment>
  >
  _flightCrewAssignmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.flightCrewAssignments,
        aliasName: $_aliasNameGenerator(
          db.flights.id,
          db.flightCrewAssignments.flightId,
        ),
      );

  $$FlightCrewAssignmentsTableProcessedTableManager
  get flightCrewAssignmentsRefs {
    final manager = $$FlightCrewAssignmentsTableTableManager(
      $_db,
      $_db.flightCrewAssignments,
    ).filter((f) => f.flightId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _flightCrewAssignmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FlightsTableFilterComposer
    extends Composer<_$AppDatabase, $FlightsTable> {
  $$FlightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takeOffDateTime => $composableBuilder(
    column: $table.takeOffDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get landingDateTime => $composableBuilder(
    column: $table.landingDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get arrivalDateTime => $composableBuilder(
    column: $table.arrivalDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timePICMinutes => $composableBuilder(
    column: $table.timePICMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timePICUSMinutes => $composableBuilder(
    column: $table.timePICUSMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeSICMinutes => $composableBuilder(
    column: $table.timeSICMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeDualMinutes => $composableBuilder(
    column: $table.timeDualMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeInstructorMinutes => $composableBuilder(
    column: $table.timeInstructorMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeIFRMinutes => $composableBuilder(
    column: $table.timeIFRMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeInstrumentMinutes => $composableBuilder(
    column: $table.timeInstrumentMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeSimulatedInstrumentMinutes => $composableBuilder(
    column: $table.timeSimulatedInstrumentMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeNightMinutes => $composableBuilder(
    column: $table.timeNightMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeCrossCountryMinutes => $composableBuilder(
    column: $table.timeCrossCountryMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeCustom1Minutes => $composableBuilder(
    column: $table.timeCustom1Minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeCustom2Minutes => $composableBuilder(
    column: $table.timeCustom2Minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeCustom3Minutes => $composableBuilder(
    column: $table.timeCustom3Minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeCustom4Minutes => $composableBuilder(
    column: $table.timeCustom4Minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeFlightMinutes => $composableBuilder(
    column: $table.timeFlightMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeBlockMinutes => $composableBuilder(
    column: $table.timeBlockMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeTotalBlockMinutes => $composableBuilder(
    column: $table.timeTotalBlockMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distanceNM => $composableBuilder(
    column: $table.distanceNM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ifrApproaches => $composableBuilder(
    column: $table.ifrApproaches,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get takeOffsDays => $composableBuilder(
    column: $table.takeOffsDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get takeOffsNight => $composableBuilder(
    column: $table.takeOffsNight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get landingsDay => $composableBuilder(
    column: $table.landingsDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get landingsNight => $composableBuilder(
    column: $table.landingsNight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PilotFunction, PilotFunction, String>
  get pilotFunction => $composableBuilder(
    column: $table.pilotFunction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get approachType => $composableBuilder(
    column: $table.approachType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get signatureImage => $composableBuilder(
    column: $table.signatureImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endorsementData => $composableBuilder(
    column: $table.endorsementData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endorsementHash => $composableBuilder(
    column: $table.endorsementHash,
    builder: (column) => ColumnFilters(column),
  );

  $$AircraftsTableFilterComposer get aircraftId {
    final $$AircraftsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.aircraftId,
      referencedTable: $db.aircrafts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AircraftsTableFilterComposer(
            $db: $db,
            $table: $db.aircrafts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AirportsTableFilterComposer get departureAirportId {
    final $$AirportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departureAirportId,
      referencedTable: $db.airports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AirportsTableFilterComposer(
            $db: $db,
            $table: $db.airports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AirportsTableFilterComposer get arrivalAirportId {
    final $$AirportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.arrivalAirportId,
      referencedTable: $db.airports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AirportsTableFilterComposer(
            $db: $db,
            $table: $db.airports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TimeLinesTableFilterComposer get departureDateTimeId {
    final $$TimeLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departureDateTimeId,
      referencedTable: $db.timeLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeLinesTableFilterComposer(
            $db: $db,
            $table: $db.timeLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> flightCrewAssignmentsRefs(
    Expression<bool> Function($$FlightCrewAssignmentsTableFilterComposer f) f,
  ) {
    final $$FlightCrewAssignmentsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.flightCrewAssignments,
          getReferencedColumn: (t) => t.flightId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FlightCrewAssignmentsTableFilterComposer(
                $db: $db,
                $table: $db.flightCrewAssignments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$FlightsTableOrderingComposer
    extends Composer<_$AppDatabase, $FlightsTable> {
  $$FlightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takeOffDateTime => $composableBuilder(
    column: $table.takeOffDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get landingDateTime => $composableBuilder(
    column: $table.landingDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get arrivalDateTime => $composableBuilder(
    column: $table.arrivalDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timePICMinutes => $composableBuilder(
    column: $table.timePICMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timePICUSMinutes => $composableBuilder(
    column: $table.timePICUSMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeSICMinutes => $composableBuilder(
    column: $table.timeSICMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeDualMinutes => $composableBuilder(
    column: $table.timeDualMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeInstructorMinutes => $composableBuilder(
    column: $table.timeInstructorMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeIFRMinutes => $composableBuilder(
    column: $table.timeIFRMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeInstrumentMinutes => $composableBuilder(
    column: $table.timeInstrumentMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeSimulatedInstrumentMinutes => $composableBuilder(
    column: $table.timeSimulatedInstrumentMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeNightMinutes => $composableBuilder(
    column: $table.timeNightMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeCrossCountryMinutes => $composableBuilder(
    column: $table.timeCrossCountryMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeCustom1Minutes => $composableBuilder(
    column: $table.timeCustom1Minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeCustom2Minutes => $composableBuilder(
    column: $table.timeCustom2Minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeCustom3Minutes => $composableBuilder(
    column: $table.timeCustom3Minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeCustom4Minutes => $composableBuilder(
    column: $table.timeCustom4Minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeFlightMinutes => $composableBuilder(
    column: $table.timeFlightMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeBlockMinutes => $composableBuilder(
    column: $table.timeBlockMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeTotalBlockMinutes => $composableBuilder(
    column: $table.timeTotalBlockMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distanceNM => $composableBuilder(
    column: $table.distanceNM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ifrApproaches => $composableBuilder(
    column: $table.ifrApproaches,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get takeOffsDays => $composableBuilder(
    column: $table.takeOffsDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get takeOffsNight => $composableBuilder(
    column: $table.takeOffsNight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get landingsDay => $composableBuilder(
    column: $table.landingsDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get landingsNight => $composableBuilder(
    column: $table.landingsNight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pilotFunction => $composableBuilder(
    column: $table.pilotFunction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get approachType => $composableBuilder(
    column: $table.approachType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get signatureImage => $composableBuilder(
    column: $table.signatureImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endorsementData => $composableBuilder(
    column: $table.endorsementData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endorsementHash => $composableBuilder(
    column: $table.endorsementHash,
    builder: (column) => ColumnOrderings(column),
  );

  $$AircraftsTableOrderingComposer get aircraftId {
    final $$AircraftsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.aircraftId,
      referencedTable: $db.aircrafts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AircraftsTableOrderingComposer(
            $db: $db,
            $table: $db.aircrafts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AirportsTableOrderingComposer get departureAirportId {
    final $$AirportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departureAirportId,
      referencedTable: $db.airports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AirportsTableOrderingComposer(
            $db: $db,
            $table: $db.airports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AirportsTableOrderingComposer get arrivalAirportId {
    final $$AirportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.arrivalAirportId,
      referencedTable: $db.airports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AirportsTableOrderingComposer(
            $db: $db,
            $table: $db.airports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TimeLinesTableOrderingComposer get departureDateTimeId {
    final $$TimeLinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departureDateTimeId,
      referencedTable: $db.timeLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeLinesTableOrderingComposer(
            $db: $db,
            $table: $db.timeLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlightsTable> {
  $$FlightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get takeOffDateTime => $composableBuilder(
    column: $table.takeOffDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get landingDateTime => $composableBuilder(
    column: $table.landingDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get arrivalDateTime => $composableBuilder(
    column: $table.arrivalDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timePICMinutes => $composableBuilder(
    column: $table.timePICMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timePICUSMinutes => $composableBuilder(
    column: $table.timePICUSMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeSICMinutes => $composableBuilder(
    column: $table.timeSICMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeDualMinutes => $composableBuilder(
    column: $table.timeDualMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeInstructorMinutes => $composableBuilder(
    column: $table.timeInstructorMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeIFRMinutes => $composableBuilder(
    column: $table.timeIFRMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeInstrumentMinutes => $composableBuilder(
    column: $table.timeInstrumentMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeSimulatedInstrumentMinutes => $composableBuilder(
    column: $table.timeSimulatedInstrumentMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeNightMinutes => $composableBuilder(
    column: $table.timeNightMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeCrossCountryMinutes => $composableBuilder(
    column: $table.timeCrossCountryMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeCustom1Minutes => $composableBuilder(
    column: $table.timeCustom1Minutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeCustom2Minutes => $composableBuilder(
    column: $table.timeCustom2Minutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeCustom3Minutes => $composableBuilder(
    column: $table.timeCustom3Minutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeCustom4Minutes => $composableBuilder(
    column: $table.timeCustom4Minutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeFlightMinutes => $composableBuilder(
    column: $table.timeFlightMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeBlockMinutes => $composableBuilder(
    column: $table.timeBlockMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeTotalBlockMinutes => $composableBuilder(
    column: $table.timeTotalBlockMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get distanceNM => $composableBuilder(
    column: $table.distanceNM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ifrApproaches => $composableBuilder(
    column: $table.ifrApproaches,
    builder: (column) => column,
  );

  GeneratedColumn<int> get takeOffsDays => $composableBuilder(
    column: $table.takeOffsDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get takeOffsNight => $composableBuilder(
    column: $table.takeOffsNight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get landingsDay => $composableBuilder(
    column: $table.landingsDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get landingsNight => $composableBuilder(
    column: $table.landingsNight,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PilotFunction, String> get pilotFunction =>
      $composableBuilder(
        column: $table.pilotFunction,
        builder: (column) => column,
      );

  GeneratedColumn<String> get approachType => $composableBuilder(
    column: $table.approachType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  GeneratedColumn<Uint8List> get signatureImage => $composableBuilder(
    column: $table.signatureImage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endorsementData => $composableBuilder(
    column: $table.endorsementData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endorsementHash => $composableBuilder(
    column: $table.endorsementHash,
    builder: (column) => column,
  );

  $$AircraftsTableAnnotationComposer get aircraftId {
    final $$AircraftsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.aircraftId,
      referencedTable: $db.aircrafts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AircraftsTableAnnotationComposer(
            $db: $db,
            $table: $db.aircrafts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AirportsTableAnnotationComposer get departureAirportId {
    final $$AirportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departureAirportId,
      referencedTable: $db.airports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AirportsTableAnnotationComposer(
            $db: $db,
            $table: $db.airports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AirportsTableAnnotationComposer get arrivalAirportId {
    final $$AirportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.arrivalAirportId,
      referencedTable: $db.airports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AirportsTableAnnotationComposer(
            $db: $db,
            $table: $db.airports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TimeLinesTableAnnotationComposer get departureDateTimeId {
    final $$TimeLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departureDateTimeId,
      referencedTable: $db.timeLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.timeLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> flightCrewAssignmentsRefs<T extends Object>(
    Expression<T> Function($$FlightCrewAssignmentsTableAnnotationComposer a) f,
  ) {
    final $$FlightCrewAssignmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.flightCrewAssignments,
          getReferencedColumn: (t) => t.flightId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FlightCrewAssignmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.flightCrewAssignments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$FlightsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FlightsTable,
          Flight,
          $$FlightsTableFilterComposer,
          $$FlightsTableOrderingComposer,
          $$FlightsTableAnnotationComposer,
          $$FlightsTableCreateCompanionBuilder,
          $$FlightsTableUpdateCompanionBuilder,
          (Flight, $$FlightsTableReferences),
          Flight,
          PrefetchHooks Function({
            bool aircraftId,
            bool departureAirportId,
            bool arrivalAirportId,
            bool departureDateTimeId,
            bool flightCrewAssignmentsRefs,
          })
        > {
  $$FlightsTableTableManager(_$AppDatabase db, $FlightsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> aircraftId = const Value.absent(),
                Value<int> departureAirportId = const Value.absent(),
                Value<int> arrivalAirportId = const Value.absent(),
                Value<int> departureDateTimeId = const Value.absent(),
                Value<DateTime?> takeOffDateTime = const Value.absent(),
                Value<DateTime?> landingDateTime = const Value.absent(),
                Value<DateTime?> arrivalDateTime = const Value.absent(),
                Value<int> timePICMinutes = const Value.absent(),
                Value<int> timePICUSMinutes = const Value.absent(),
                Value<int> timeSICMinutes = const Value.absent(),
                Value<int> timeDualMinutes = const Value.absent(),
                Value<int> timeInstructorMinutes = const Value.absent(),
                Value<int> timeIFRMinutes = const Value.absent(),
                Value<int> timeInstrumentMinutes = const Value.absent(),
                Value<int> timeSimulatedInstrumentMinutes =
                    const Value.absent(),
                Value<int> timeNightMinutes = const Value.absent(),
                Value<int> timeCrossCountryMinutes = const Value.absent(),
                Value<int> timeCustom1Minutes = const Value.absent(),
                Value<int> timeCustom2Minutes = const Value.absent(),
                Value<int> timeCustom3Minutes = const Value.absent(),
                Value<int> timeCustom4Minutes = const Value.absent(),
                Value<int> timeFlightMinutes = const Value.absent(),
                Value<int> timeBlockMinutes = const Value.absent(),
                Value<int> timeTotalBlockMinutes = const Value.absent(),
                Value<int> distanceNM = const Value.absent(),
                Value<int> ifrApproaches = const Value.absent(),
                Value<int> takeOffsDays = const Value.absent(),
                Value<int> takeOffsNight = const Value.absent(),
                Value<int> landingsDay = const Value.absent(),
                Value<int> landingsNight = const Value.absent(),
                Value<PilotFunction> pilotFunction = const Value.absent(),
                Value<String> approachType = const Value.absent(),
                Value<String> remarks = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
                Value<Uint8List?> signatureImage = const Value.absent(),
                Value<String?> endorsementData = const Value.absent(),
                Value<String?> endorsementHash = const Value.absent(),
              }) => FlightsCompanion(
                id: id,
                aircraftId: aircraftId,
                departureAirportId: departureAirportId,
                arrivalAirportId: arrivalAirportId,
                departureDateTimeId: departureDateTimeId,
                takeOffDateTime: takeOffDateTime,
                landingDateTime: landingDateTime,
                arrivalDateTime: arrivalDateTime,
                timePICMinutes: timePICMinutes,
                timePICUSMinutes: timePICUSMinutes,
                timeSICMinutes: timeSICMinutes,
                timeDualMinutes: timeDualMinutes,
                timeInstructorMinutes: timeInstructorMinutes,
                timeIFRMinutes: timeIFRMinutes,
                timeInstrumentMinutes: timeInstrumentMinutes,
                timeSimulatedInstrumentMinutes: timeSimulatedInstrumentMinutes,
                timeNightMinutes: timeNightMinutes,
                timeCrossCountryMinutes: timeCrossCountryMinutes,
                timeCustom1Minutes: timeCustom1Minutes,
                timeCustom2Minutes: timeCustom2Minutes,
                timeCustom3Minutes: timeCustom3Minutes,
                timeCustom4Minutes: timeCustom4Minutes,
                timeFlightMinutes: timeFlightMinutes,
                timeBlockMinutes: timeBlockMinutes,
                timeTotalBlockMinutes: timeTotalBlockMinutes,
                distanceNM: distanceNM,
                ifrApproaches: ifrApproaches,
                takeOffsDays: takeOffsDays,
                takeOffsNight: takeOffsNight,
                landingsDay: landingsDay,
                landingsNight: landingsNight,
                pilotFunction: pilotFunction,
                approachType: approachType,
                remarks: remarks,
                notes: notes,
                isLocked: isLocked,
                signatureImage: signatureImage,
                endorsementData: endorsementData,
                endorsementHash: endorsementHash,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int aircraftId,
                required int departureAirportId,
                required int arrivalAirportId,
                required int departureDateTimeId,
                Value<DateTime?> takeOffDateTime = const Value.absent(),
                Value<DateTime?> landingDateTime = const Value.absent(),
                Value<DateTime?> arrivalDateTime = const Value.absent(),
                required int timePICMinutes,
                required int timePICUSMinutes,
                required int timeSICMinutes,
                required int timeDualMinutes,
                required int timeInstructorMinutes,
                required int timeIFRMinutes,
                required int timeInstrumentMinutes,
                required int timeSimulatedInstrumentMinutes,
                required int timeNightMinutes,
                required int timeCrossCountryMinutes,
                required int timeCustom1Minutes,
                required int timeCustom2Minutes,
                required int timeCustom3Minutes,
                required int timeCustom4Minutes,
                required int timeFlightMinutes,
                required int timeBlockMinutes,
                Value<int> timeTotalBlockMinutes = const Value.absent(),
                required int distanceNM,
                required int ifrApproaches,
                required int takeOffsDays,
                required int takeOffsNight,
                required int landingsDay,
                required int landingsNight,
                Value<PilotFunction> pilotFunction = const Value.absent(),
                required String approachType,
                required String remarks,
                required String notes,
                required bool isLocked,
                Value<Uint8List?> signatureImage = const Value.absent(),
                Value<String?> endorsementData = const Value.absent(),
                Value<String?> endorsementHash = const Value.absent(),
              }) => FlightsCompanion.insert(
                id: id,
                aircraftId: aircraftId,
                departureAirportId: departureAirportId,
                arrivalAirportId: arrivalAirportId,
                departureDateTimeId: departureDateTimeId,
                takeOffDateTime: takeOffDateTime,
                landingDateTime: landingDateTime,
                arrivalDateTime: arrivalDateTime,
                timePICMinutes: timePICMinutes,
                timePICUSMinutes: timePICUSMinutes,
                timeSICMinutes: timeSICMinutes,
                timeDualMinutes: timeDualMinutes,
                timeInstructorMinutes: timeInstructorMinutes,
                timeIFRMinutes: timeIFRMinutes,
                timeInstrumentMinutes: timeInstrumentMinutes,
                timeSimulatedInstrumentMinutes: timeSimulatedInstrumentMinutes,
                timeNightMinutes: timeNightMinutes,
                timeCrossCountryMinutes: timeCrossCountryMinutes,
                timeCustom1Minutes: timeCustom1Minutes,
                timeCustom2Minutes: timeCustom2Minutes,
                timeCustom3Minutes: timeCustom3Minutes,
                timeCustom4Minutes: timeCustom4Minutes,
                timeFlightMinutes: timeFlightMinutes,
                timeBlockMinutes: timeBlockMinutes,
                timeTotalBlockMinutes: timeTotalBlockMinutes,
                distanceNM: distanceNM,
                ifrApproaches: ifrApproaches,
                takeOffsDays: takeOffsDays,
                takeOffsNight: takeOffsNight,
                landingsDay: landingsDay,
                landingsNight: landingsNight,
                pilotFunction: pilotFunction,
                approachType: approachType,
                remarks: remarks,
                notes: notes,
                isLocked: isLocked,
                signatureImage: signatureImage,
                endorsementData: endorsementData,
                endorsementHash: endorsementHash,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FlightsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                aircraftId = false,
                departureAirportId = false,
                arrivalAirportId = false,
                departureDateTimeId = false,
                flightCrewAssignmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (flightCrewAssignmentsRefs) db.flightCrewAssignments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (aircraftId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.aircraftId,
                                    referencedTable: $$FlightsTableReferences
                                        ._aircraftIdTable(db),
                                    referencedColumn: $$FlightsTableReferences
                                        ._aircraftIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (departureAirportId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.departureAirportId,
                                    referencedTable: $$FlightsTableReferences
                                        ._departureAirportIdTable(db),
                                    referencedColumn: $$FlightsTableReferences
                                        ._departureAirportIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (arrivalAirportId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.arrivalAirportId,
                                    referencedTable: $$FlightsTableReferences
                                        ._arrivalAirportIdTable(db),
                                    referencedColumn: $$FlightsTableReferences
                                        ._arrivalAirportIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (departureDateTimeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.departureDateTimeId,
                                    referencedTable: $$FlightsTableReferences
                                        ._departureDateTimeIdTable(db),
                                    referencedColumn: $$FlightsTableReferences
                                        ._departureDateTimeIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (flightCrewAssignmentsRefs)
                        await $_getPrefetchedData<
                          Flight,
                          $FlightsTable,
                          FlightCrewAssignment
                        >(
                          currentTable: table,
                          referencedTable: $$FlightsTableReferences
                              ._flightCrewAssignmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FlightsTableReferences(
                                db,
                                table,
                                p0,
                              ).flightCrewAssignmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.flightId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FlightsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FlightsTable,
      Flight,
      $$FlightsTableFilterComposer,
      $$FlightsTableOrderingComposer,
      $$FlightsTableAnnotationComposer,
      $$FlightsTableCreateCompanionBuilder,
      $$FlightsTableUpdateCompanionBuilder,
      (Flight, $$FlightsTableReferences),
      Flight,
      PrefetchHooks Function({
        bool aircraftId,
        bool departureAirportId,
        bool arrivalAirportId,
        bool departureDateTimeId,
        bool flightCrewAssignmentsRefs,
      })
    >;
typedef $$LimitRulesTableCreateCompanionBuilder =
    LimitRulesCompanion Function({
      Value<int> ruleId,
      required String ruleName,
      required String metric,
      required String ruleType,
      required String windowType,
      required int windowValue,
      required double limitValue,
      required String limitUnit,
      Value<double> warnYellowBefore,
      Value<double> warnRedBefore,
      Value<String> warnYellowColor,
      Value<String> warnRedColor,
      Value<bool> active,
      Value<String?> notes,
    });
typedef $$LimitRulesTableUpdateCompanionBuilder =
    LimitRulesCompanion Function({
      Value<int> ruleId,
      Value<String> ruleName,
      Value<String> metric,
      Value<String> ruleType,
      Value<String> windowType,
      Value<int> windowValue,
      Value<double> limitValue,
      Value<String> limitUnit,
      Value<double> warnYellowBefore,
      Value<double> warnRedBefore,
      Value<String> warnYellowColor,
      Value<String> warnRedColor,
      Value<bool> active,
      Value<String?> notes,
    });

final class $$LimitRulesTableReferences
    extends BaseReferences<_$AppDatabase, $LimitRulesTable, LimitRule> {
  $$LimitRulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RuleSnapshotsTable, List<RuleSnapshot>>
  _ruleSnapshotsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ruleSnapshots,
    aliasName: $_aliasNameGenerator(
      db.limitRules.ruleId,
      db.ruleSnapshots.ruleId,
    ),
  );

  $$RuleSnapshotsTableProcessedTableManager get ruleSnapshotsRefs {
    final manager = $$RuleSnapshotsTableTableManager(
      $_db,
      $_db.ruleSnapshots,
    ).filter((f) => f.ruleId.ruleId.sqlEquals($_itemColumn<int>('rule_id')!));

    final cache = $_typedResult.readTableOrNull(_ruleSnapshotsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LimitRulesTableFilterComposer
    extends Composer<_$AppDatabase, $LimitRulesTable> {
  $$LimitRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleName => $composableBuilder(
    column: $table.ruleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metric => $composableBuilder(
    column: $table.metric,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleType => $composableBuilder(
    column: $table.ruleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get windowType => $composableBuilder(
    column: $table.windowType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get windowValue => $composableBuilder(
    column: $table.windowValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get limitValue => $composableBuilder(
    column: $table.limitValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get limitUnit => $composableBuilder(
    column: $table.limitUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get warnYellowBefore => $composableBuilder(
    column: $table.warnYellowBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get warnRedBefore => $composableBuilder(
    column: $table.warnRedBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warnYellowColor => $composableBuilder(
    column: $table.warnYellowColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get warnRedColor => $composableBuilder(
    column: $table.warnRedColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ruleSnapshotsRefs(
    Expression<bool> Function($$RuleSnapshotsTableFilterComposer f) f,
  ) {
    final $$RuleSnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.ruleSnapshots,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RuleSnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.ruleSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LimitRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $LimitRulesTable> {
  $$LimitRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleName => $composableBuilder(
    column: $table.ruleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metric => $composableBuilder(
    column: $table.metric,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleType => $composableBuilder(
    column: $table.ruleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get windowType => $composableBuilder(
    column: $table.windowType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get windowValue => $composableBuilder(
    column: $table.windowValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get limitValue => $composableBuilder(
    column: $table.limitValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get limitUnit => $composableBuilder(
    column: $table.limitUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get warnYellowBefore => $composableBuilder(
    column: $table.warnYellowBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get warnRedBefore => $composableBuilder(
    column: $table.warnRedBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warnYellowColor => $composableBuilder(
    column: $table.warnYellowColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get warnRedColor => $composableBuilder(
    column: $table.warnRedColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LimitRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LimitRulesTable> {
  $$LimitRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get ruleId =>
      $composableBuilder(column: $table.ruleId, builder: (column) => column);

  GeneratedColumn<String> get ruleName =>
      $composableBuilder(column: $table.ruleName, builder: (column) => column);

  GeneratedColumn<String> get metric =>
      $composableBuilder(column: $table.metric, builder: (column) => column);

  GeneratedColumn<String> get ruleType =>
      $composableBuilder(column: $table.ruleType, builder: (column) => column);

  GeneratedColumn<String> get windowType => $composableBuilder(
    column: $table.windowType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get windowValue => $composableBuilder(
    column: $table.windowValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get limitValue => $composableBuilder(
    column: $table.limitValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get limitUnit =>
      $composableBuilder(column: $table.limitUnit, builder: (column) => column);

  GeneratedColumn<double> get warnYellowBefore => $composableBuilder(
    column: $table.warnYellowBefore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get warnRedBefore => $composableBuilder(
    column: $table.warnRedBefore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get warnYellowColor => $composableBuilder(
    column: $table.warnYellowColor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get warnRedColor => $composableBuilder(
    column: $table.warnRedColor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> ruleSnapshotsRefs<T extends Object>(
    Expression<T> Function($$RuleSnapshotsTableAnnotationComposer a) f,
  ) {
    final $$RuleSnapshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.ruleSnapshots,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RuleSnapshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.ruleSnapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LimitRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LimitRulesTable,
          LimitRule,
          $$LimitRulesTableFilterComposer,
          $$LimitRulesTableOrderingComposer,
          $$LimitRulesTableAnnotationComposer,
          $$LimitRulesTableCreateCompanionBuilder,
          $$LimitRulesTableUpdateCompanionBuilder,
          (LimitRule, $$LimitRulesTableReferences),
          LimitRule,
          PrefetchHooks Function({bool ruleSnapshotsRefs})
        > {
  $$LimitRulesTableTableManager(_$AppDatabase db, $LimitRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LimitRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LimitRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LimitRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> ruleId = const Value.absent(),
                Value<String> ruleName = const Value.absent(),
                Value<String> metric = const Value.absent(),
                Value<String> ruleType = const Value.absent(),
                Value<String> windowType = const Value.absent(),
                Value<int> windowValue = const Value.absent(),
                Value<double> limitValue = const Value.absent(),
                Value<String> limitUnit = const Value.absent(),
                Value<double> warnYellowBefore = const Value.absent(),
                Value<double> warnRedBefore = const Value.absent(),
                Value<String> warnYellowColor = const Value.absent(),
                Value<String> warnRedColor = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => LimitRulesCompanion(
                ruleId: ruleId,
                ruleName: ruleName,
                metric: metric,
                ruleType: ruleType,
                windowType: windowType,
                windowValue: windowValue,
                limitValue: limitValue,
                limitUnit: limitUnit,
                warnYellowBefore: warnYellowBefore,
                warnRedBefore: warnRedBefore,
                warnYellowColor: warnYellowColor,
                warnRedColor: warnRedColor,
                active: active,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> ruleId = const Value.absent(),
                required String ruleName,
                required String metric,
                required String ruleType,
                required String windowType,
                required int windowValue,
                required double limitValue,
                required String limitUnit,
                Value<double> warnYellowBefore = const Value.absent(),
                Value<double> warnRedBefore = const Value.absent(),
                Value<String> warnYellowColor = const Value.absent(),
                Value<String> warnRedColor = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => LimitRulesCompanion.insert(
                ruleId: ruleId,
                ruleName: ruleName,
                metric: metric,
                ruleType: ruleType,
                windowType: windowType,
                windowValue: windowValue,
                limitValue: limitValue,
                limitUnit: limitUnit,
                warnYellowBefore: warnYellowBefore,
                warnRedBefore: warnRedBefore,
                warnYellowColor: warnYellowColor,
                warnRedColor: warnRedColor,
                active: active,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LimitRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ruleSnapshotsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (ruleSnapshotsRefs) db.ruleSnapshots,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (ruleSnapshotsRefs)
                    await $_getPrefetchedData<
                      LimitRule,
                      $LimitRulesTable,
                      RuleSnapshot
                    >(
                      currentTable: table,
                      referencedTable: $$LimitRulesTableReferences
                          ._ruleSnapshotsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LimitRulesTableReferences(
                            db,
                            table,
                            p0,
                          ).ruleSnapshotsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.ruleId == item.ruleId),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LimitRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LimitRulesTable,
      LimitRule,
      $$LimitRulesTableFilterComposer,
      $$LimitRulesTableOrderingComposer,
      $$LimitRulesTableAnnotationComposer,
      $$LimitRulesTableCreateCompanionBuilder,
      $$LimitRulesTableUpdateCompanionBuilder,
      (LimitRule, $$LimitRulesTableReferences),
      LimitRule,
      PrefetchHooks Function({bool ruleSnapshotsRefs})
    >;
typedef $$RuleSnapshotsTableCreateCompanionBuilder =
    RuleSnapshotsCompanion Function({
      Value<int> snapshotId,
      required int ruleId,
      Value<DateTime> computedAt,
      required double currentValue,
      required String status,
    });
typedef $$RuleSnapshotsTableUpdateCompanionBuilder =
    RuleSnapshotsCompanion Function({
      Value<int> snapshotId,
      Value<int> ruleId,
      Value<DateTime> computedAt,
      Value<double> currentValue,
      Value<String> status,
    });

final class $$RuleSnapshotsTableReferences
    extends BaseReferences<_$AppDatabase, $RuleSnapshotsTable, RuleSnapshot> {
  $$RuleSnapshotsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LimitRulesTable _ruleIdTable(_$AppDatabase db) =>
      db.limitRules.createAlias(
        $_aliasNameGenerator(db.ruleSnapshots.ruleId, db.limitRules.ruleId),
      );

  $$LimitRulesTableProcessedTableManager get ruleId {
    final $_column = $_itemColumn<int>('rule_id')!;

    final manager = $$LimitRulesTableTableManager(
      $_db,
      $_db.limitRules,
    ).filter((f) => f.ruleId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ruleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RuleSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $RuleSnapshotsTable> {
  $$RuleSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get snapshotId => $composableBuilder(
    column: $table.snapshotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $$LimitRulesTableFilterComposer get ruleId {
    final $$LimitRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.limitRules,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LimitRulesTableFilterComposer(
            $db: $db,
            $table: $db.limitRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RuleSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $RuleSnapshotsTable> {
  $$RuleSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get snapshotId => $composableBuilder(
    column: $table.snapshotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$LimitRulesTableOrderingComposer get ruleId {
    final $$LimitRulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.limitRules,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LimitRulesTableOrderingComposer(
            $db: $db,
            $table: $db.limitRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RuleSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RuleSnapshotsTable> {
  $$RuleSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get snapshotId => $composableBuilder(
    column: $table.snapshotId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$LimitRulesTableAnnotationComposer get ruleId {
    final $$LimitRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.limitRules,
      getReferencedColumn: (t) => t.ruleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LimitRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.limitRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RuleSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RuleSnapshotsTable,
          RuleSnapshot,
          $$RuleSnapshotsTableFilterComposer,
          $$RuleSnapshotsTableOrderingComposer,
          $$RuleSnapshotsTableAnnotationComposer,
          $$RuleSnapshotsTableCreateCompanionBuilder,
          $$RuleSnapshotsTableUpdateCompanionBuilder,
          (RuleSnapshot, $$RuleSnapshotsTableReferences),
          RuleSnapshot,
          PrefetchHooks Function({bool ruleId})
        > {
  $$RuleSnapshotsTableTableManager(_$AppDatabase db, $RuleSnapshotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RuleSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RuleSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RuleSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> snapshotId = const Value.absent(),
                Value<int> ruleId = const Value.absent(),
                Value<DateTime> computedAt = const Value.absent(),
                Value<double> currentValue = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => RuleSnapshotsCompanion(
                snapshotId: snapshotId,
                ruleId: ruleId,
                computedAt: computedAt,
                currentValue: currentValue,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> snapshotId = const Value.absent(),
                required int ruleId,
                Value<DateTime> computedAt = const Value.absent(),
                required double currentValue,
                required String status,
              }) => RuleSnapshotsCompanion.insert(
                snapshotId: snapshotId,
                ruleId: ruleId,
                computedAt: computedAt,
                currentValue: currentValue,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RuleSnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ruleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ruleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ruleId,
                                referencedTable: $$RuleSnapshotsTableReferences
                                    ._ruleIdTable(db),
                                referencedColumn: $$RuleSnapshotsTableReferences
                                    ._ruleIdTable(db)
                                    .ruleId,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RuleSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RuleSnapshotsTable,
      RuleSnapshot,
      $$RuleSnapshotsTableFilterComposer,
      $$RuleSnapshotsTableOrderingComposer,
      $$RuleSnapshotsTableAnnotationComposer,
      $$RuleSnapshotsTableCreateCompanionBuilder,
      $$RuleSnapshotsTableUpdateCompanionBuilder,
      (RuleSnapshot, $$RuleSnapshotsTableReferences),
      RuleSnapshot,
      PrefetchHooks Function({bool ruleId})
    >;
typedef $$PositioningsTableCreateCompanionBuilder =
    PositioningsCompanion Function({
      Value<int> id,
      required int departurePlaceId,
      required int arrivalPlaceId,
      required int departureDateTimeId,
      Value<DateTime?> arrivalDateTime,
      required int timeTotalMinutes,
      Value<String> notes,
      required bool isLocked,
    });
typedef $$PositioningsTableUpdateCompanionBuilder =
    PositioningsCompanion Function({
      Value<int> id,
      Value<int> departurePlaceId,
      Value<int> arrivalPlaceId,
      Value<int> departureDateTimeId,
      Value<DateTime?> arrivalDateTime,
      Value<int> timeTotalMinutes,
      Value<String> notes,
      Value<bool> isLocked,
    });

final class $$PositioningsTableReferences
    extends BaseReferences<_$AppDatabase, $PositioningsTable, Positioning> {
  $$PositioningsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AirportsTable _departurePlaceIdTable(_$AppDatabase db) =>
      db.airports.createAlias(
        $_aliasNameGenerator(db.positionings.departurePlaceId, db.airports.id),
      );

  $$AirportsTableProcessedTableManager get departurePlaceId {
    final $_column = $_itemColumn<int>('departure_place_id')!;

    final manager = $$AirportsTableTableManager(
      $_db,
      $_db.airports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_departurePlaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AirportsTable _arrivalPlaceIdTable(_$AppDatabase db) =>
      db.airports.createAlias(
        $_aliasNameGenerator(db.positionings.arrivalPlaceId, db.airports.id),
      );

  $$AirportsTableProcessedTableManager get arrivalPlaceId {
    final $_column = $_itemColumn<int>('arrival_place_id')!;

    final manager = $$AirportsTableTableManager(
      $_db,
      $_db.airports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_arrivalPlaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TimeLinesTable _departureDateTimeIdTable(_$AppDatabase db) =>
      db.timeLines.createAlias(
        $_aliasNameGenerator(
          db.positionings.departureDateTimeId,
          db.timeLines.id,
        ),
      );

  $$TimeLinesTableProcessedTableManager get departureDateTimeId {
    final $_column = $_itemColumn<int>('departure_date_time_id')!;

    final manager = $$TimeLinesTableTableManager(
      $_db,
      $_db.timeLines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_departureDateTimeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PositioningsTableFilterComposer
    extends Composer<_$AppDatabase, $PositioningsTable> {
  $$PositioningsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get arrivalDateTime => $composableBuilder(
    column: $table.arrivalDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeTotalMinutes => $composableBuilder(
    column: $table.timeTotalMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );

  $$AirportsTableFilterComposer get departurePlaceId {
    final $$AirportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departurePlaceId,
      referencedTable: $db.airports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AirportsTableFilterComposer(
            $db: $db,
            $table: $db.airports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AirportsTableFilterComposer get arrivalPlaceId {
    final $$AirportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.arrivalPlaceId,
      referencedTable: $db.airports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AirportsTableFilterComposer(
            $db: $db,
            $table: $db.airports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TimeLinesTableFilterComposer get departureDateTimeId {
    final $$TimeLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departureDateTimeId,
      referencedTable: $db.timeLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeLinesTableFilterComposer(
            $db: $db,
            $table: $db.timeLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PositioningsTableOrderingComposer
    extends Composer<_$AppDatabase, $PositioningsTable> {
  $$PositioningsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get arrivalDateTime => $composableBuilder(
    column: $table.arrivalDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeTotalMinutes => $composableBuilder(
    column: $table.timeTotalMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );

  $$AirportsTableOrderingComposer get departurePlaceId {
    final $$AirportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departurePlaceId,
      referencedTable: $db.airports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AirportsTableOrderingComposer(
            $db: $db,
            $table: $db.airports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AirportsTableOrderingComposer get arrivalPlaceId {
    final $$AirportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.arrivalPlaceId,
      referencedTable: $db.airports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AirportsTableOrderingComposer(
            $db: $db,
            $table: $db.airports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TimeLinesTableOrderingComposer get departureDateTimeId {
    final $$TimeLinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departureDateTimeId,
      referencedTable: $db.timeLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeLinesTableOrderingComposer(
            $db: $db,
            $table: $db.timeLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PositioningsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PositioningsTable> {
  $$PositioningsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get arrivalDateTime => $composableBuilder(
    column: $table.arrivalDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeTotalMinutes => $composableBuilder(
    column: $table.timeTotalMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  $$AirportsTableAnnotationComposer get departurePlaceId {
    final $$AirportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departurePlaceId,
      referencedTable: $db.airports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AirportsTableAnnotationComposer(
            $db: $db,
            $table: $db.airports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AirportsTableAnnotationComposer get arrivalPlaceId {
    final $$AirportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.arrivalPlaceId,
      referencedTable: $db.airports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AirportsTableAnnotationComposer(
            $db: $db,
            $table: $db.airports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TimeLinesTableAnnotationComposer get departureDateTimeId {
    final $$TimeLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departureDateTimeId,
      referencedTable: $db.timeLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.timeLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PositioningsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PositioningsTable,
          Positioning,
          $$PositioningsTableFilterComposer,
          $$PositioningsTableOrderingComposer,
          $$PositioningsTableAnnotationComposer,
          $$PositioningsTableCreateCompanionBuilder,
          $$PositioningsTableUpdateCompanionBuilder,
          (Positioning, $$PositioningsTableReferences),
          Positioning,
          PrefetchHooks Function({
            bool departurePlaceId,
            bool arrivalPlaceId,
            bool departureDateTimeId,
          })
        > {
  $$PositioningsTableTableManager(_$AppDatabase db, $PositioningsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PositioningsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PositioningsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PositioningsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> departurePlaceId = const Value.absent(),
                Value<int> arrivalPlaceId = const Value.absent(),
                Value<int> departureDateTimeId = const Value.absent(),
                Value<DateTime?> arrivalDateTime = const Value.absent(),
                Value<int> timeTotalMinutes = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
              }) => PositioningsCompanion(
                id: id,
                departurePlaceId: departurePlaceId,
                arrivalPlaceId: arrivalPlaceId,
                departureDateTimeId: departureDateTimeId,
                arrivalDateTime: arrivalDateTime,
                timeTotalMinutes: timeTotalMinutes,
                notes: notes,
                isLocked: isLocked,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int departurePlaceId,
                required int arrivalPlaceId,
                required int departureDateTimeId,
                Value<DateTime?> arrivalDateTime = const Value.absent(),
                required int timeTotalMinutes,
                Value<String> notes = const Value.absent(),
                required bool isLocked,
              }) => PositioningsCompanion.insert(
                id: id,
                departurePlaceId: departurePlaceId,
                arrivalPlaceId: arrivalPlaceId,
                departureDateTimeId: departureDateTimeId,
                arrivalDateTime: arrivalDateTime,
                timeTotalMinutes: timeTotalMinutes,
                notes: notes,
                isLocked: isLocked,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PositioningsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                departurePlaceId = false,
                arrivalPlaceId = false,
                departureDateTimeId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (departurePlaceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.departurePlaceId,
                                    referencedTable:
                                        $$PositioningsTableReferences
                                            ._departurePlaceIdTable(db),
                                    referencedColumn:
                                        $$PositioningsTableReferences
                                            ._departurePlaceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (arrivalPlaceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.arrivalPlaceId,
                                    referencedTable:
                                        $$PositioningsTableReferences
                                            ._arrivalPlaceIdTable(db),
                                    referencedColumn:
                                        $$PositioningsTableReferences
                                            ._arrivalPlaceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (departureDateTimeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.departureDateTimeId,
                                    referencedTable:
                                        $$PositioningsTableReferences
                                            ._departureDateTimeIdTable(db),
                                    referencedColumn:
                                        $$PositioningsTableReferences
                                            ._departureDateTimeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$PositioningsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PositioningsTable,
      Positioning,
      $$PositioningsTableFilterComposer,
      $$PositioningsTableOrderingComposer,
      $$PositioningsTableAnnotationComposer,
      $$PositioningsTableCreateCompanionBuilder,
      $$PositioningsTableUpdateCompanionBuilder,
      (Positioning, $$PositioningsTableReferences),
      Positioning,
      PrefetchHooks Function({
        bool departurePlaceId,
        bool arrivalPlaceId,
        bool departureDateTimeId,
      })
    >;
typedef $$PreviousExperiencesTableCreateCompanionBuilder =
    PreviousExperiencesCompanion Function({
      Value<int> id,
      required int aircraftTypeId,
      Value<DateTime?> dateTimeFirstFlight,
      Value<DateTime?> dateTimeLastFlight,
      required int timePICMinutes,
      required int timePICUSMinutes,
      required int timeSICMinutes,
      required int timeDualMinutes,
      required int timeInstructorMinutes,
      required int timeIFRMinutes,
      required int timeInstrumentMinutes,
      required int timeSimulatedInstrumentMinutes,
      required int timeNightMinutes,
      required int timeCrossCountryMinutes,
      required int timeCustom1Minutes,
      required int timeCustom2Minutes,
      required int timeCustom3Minutes,
      required int timeCustom4Minutes,
      required int timeFlightMinutes,
      required int timeBlockMinutes,
      required int timeSimulatorMinutes,
      required int distanceNM,
      Value<int> flightCount,
      required int ifrApproaches,
      required int takeOffsDays,
      required int takeOffsNight,
      required int landingsDay,
      required int landingsNight,
    });
typedef $$PreviousExperiencesTableUpdateCompanionBuilder =
    PreviousExperiencesCompanion Function({
      Value<int> id,
      Value<int> aircraftTypeId,
      Value<DateTime?> dateTimeFirstFlight,
      Value<DateTime?> dateTimeLastFlight,
      Value<int> timePICMinutes,
      Value<int> timePICUSMinutes,
      Value<int> timeSICMinutes,
      Value<int> timeDualMinutes,
      Value<int> timeInstructorMinutes,
      Value<int> timeIFRMinutes,
      Value<int> timeInstrumentMinutes,
      Value<int> timeSimulatedInstrumentMinutes,
      Value<int> timeNightMinutes,
      Value<int> timeCrossCountryMinutes,
      Value<int> timeCustom1Minutes,
      Value<int> timeCustom2Minutes,
      Value<int> timeCustom3Minutes,
      Value<int> timeCustom4Minutes,
      Value<int> timeFlightMinutes,
      Value<int> timeBlockMinutes,
      Value<int> timeSimulatorMinutes,
      Value<int> distanceNM,
      Value<int> flightCount,
      Value<int> ifrApproaches,
      Value<int> takeOffsDays,
      Value<int> takeOffsNight,
      Value<int> landingsDay,
      Value<int> landingsNight,
    });

final class $$PreviousExperiencesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PreviousExperiencesTable,
          PreviousExperience
        > {
  $$PreviousExperiencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AircraftTypesTable _aircraftTypeIdTable(_$AppDatabase db) =>
      db.aircraftTypes.createAlias(
        $_aliasNameGenerator(
          db.previousExperiences.aircraftTypeId,
          db.aircraftTypes.id,
        ),
      );

  $$AircraftTypesTableProcessedTableManager get aircraftTypeId {
    final $_column = $_itemColumn<int>('aircraft_type_id')!;

    final manager = $$AircraftTypesTableTableManager(
      $_db,
      $_db.aircraftTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_aircraftTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PreviousExperiencesTableFilterComposer
    extends Composer<_$AppDatabase, $PreviousExperiencesTable> {
  $$PreviousExperiencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateTimeFirstFlight => $composableBuilder(
    column: $table.dateTimeFirstFlight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateTimeLastFlight => $composableBuilder(
    column: $table.dateTimeLastFlight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timePICMinutes => $composableBuilder(
    column: $table.timePICMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timePICUSMinutes => $composableBuilder(
    column: $table.timePICUSMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeSICMinutes => $composableBuilder(
    column: $table.timeSICMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeDualMinutes => $composableBuilder(
    column: $table.timeDualMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeInstructorMinutes => $composableBuilder(
    column: $table.timeInstructorMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeIFRMinutes => $composableBuilder(
    column: $table.timeIFRMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeInstrumentMinutes => $composableBuilder(
    column: $table.timeInstrumentMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeSimulatedInstrumentMinutes => $composableBuilder(
    column: $table.timeSimulatedInstrumentMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeNightMinutes => $composableBuilder(
    column: $table.timeNightMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeCrossCountryMinutes => $composableBuilder(
    column: $table.timeCrossCountryMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeCustom1Minutes => $composableBuilder(
    column: $table.timeCustom1Minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeCustom2Minutes => $composableBuilder(
    column: $table.timeCustom2Minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeCustom3Minutes => $composableBuilder(
    column: $table.timeCustom3Minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeCustom4Minutes => $composableBuilder(
    column: $table.timeCustom4Minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeFlightMinutes => $composableBuilder(
    column: $table.timeFlightMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeBlockMinutes => $composableBuilder(
    column: $table.timeBlockMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeSimulatorMinutes => $composableBuilder(
    column: $table.timeSimulatorMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distanceNM => $composableBuilder(
    column: $table.distanceNM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flightCount => $composableBuilder(
    column: $table.flightCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ifrApproaches => $composableBuilder(
    column: $table.ifrApproaches,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get takeOffsDays => $composableBuilder(
    column: $table.takeOffsDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get takeOffsNight => $composableBuilder(
    column: $table.takeOffsNight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get landingsDay => $composableBuilder(
    column: $table.landingsDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get landingsNight => $composableBuilder(
    column: $table.landingsNight,
    builder: (column) => ColumnFilters(column),
  );

  $$AircraftTypesTableFilterComposer get aircraftTypeId {
    final $$AircraftTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.aircraftTypeId,
      referencedTable: $db.aircraftTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AircraftTypesTableFilterComposer(
            $db: $db,
            $table: $db.aircraftTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreviousExperiencesTableOrderingComposer
    extends Composer<_$AppDatabase, $PreviousExperiencesTable> {
  $$PreviousExperiencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateTimeFirstFlight => $composableBuilder(
    column: $table.dateTimeFirstFlight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateTimeLastFlight => $composableBuilder(
    column: $table.dateTimeLastFlight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timePICMinutes => $composableBuilder(
    column: $table.timePICMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timePICUSMinutes => $composableBuilder(
    column: $table.timePICUSMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeSICMinutes => $composableBuilder(
    column: $table.timeSICMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeDualMinutes => $composableBuilder(
    column: $table.timeDualMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeInstructorMinutes => $composableBuilder(
    column: $table.timeInstructorMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeIFRMinutes => $composableBuilder(
    column: $table.timeIFRMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeInstrumentMinutes => $composableBuilder(
    column: $table.timeInstrumentMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeSimulatedInstrumentMinutes => $composableBuilder(
    column: $table.timeSimulatedInstrumentMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeNightMinutes => $composableBuilder(
    column: $table.timeNightMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeCrossCountryMinutes => $composableBuilder(
    column: $table.timeCrossCountryMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeCustom1Minutes => $composableBuilder(
    column: $table.timeCustom1Minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeCustom2Minutes => $composableBuilder(
    column: $table.timeCustom2Minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeCustom3Minutes => $composableBuilder(
    column: $table.timeCustom3Minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeCustom4Minutes => $composableBuilder(
    column: $table.timeCustom4Minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeFlightMinutes => $composableBuilder(
    column: $table.timeFlightMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeBlockMinutes => $composableBuilder(
    column: $table.timeBlockMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeSimulatorMinutes => $composableBuilder(
    column: $table.timeSimulatorMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distanceNM => $composableBuilder(
    column: $table.distanceNM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flightCount => $composableBuilder(
    column: $table.flightCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ifrApproaches => $composableBuilder(
    column: $table.ifrApproaches,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get takeOffsDays => $composableBuilder(
    column: $table.takeOffsDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get takeOffsNight => $composableBuilder(
    column: $table.takeOffsNight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get landingsDay => $composableBuilder(
    column: $table.landingsDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get landingsNight => $composableBuilder(
    column: $table.landingsNight,
    builder: (column) => ColumnOrderings(column),
  );

  $$AircraftTypesTableOrderingComposer get aircraftTypeId {
    final $$AircraftTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.aircraftTypeId,
      referencedTable: $db.aircraftTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AircraftTypesTableOrderingComposer(
            $db: $db,
            $table: $db.aircraftTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreviousExperiencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreviousExperiencesTable> {
  $$PreviousExperiencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get dateTimeFirstFlight => $composableBuilder(
    column: $table.dateTimeFirstFlight,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateTimeLastFlight => $composableBuilder(
    column: $table.dateTimeLastFlight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timePICMinutes => $composableBuilder(
    column: $table.timePICMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timePICUSMinutes => $composableBuilder(
    column: $table.timePICUSMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeSICMinutes => $composableBuilder(
    column: $table.timeSICMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeDualMinutes => $composableBuilder(
    column: $table.timeDualMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeInstructorMinutes => $composableBuilder(
    column: $table.timeInstructorMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeIFRMinutes => $composableBuilder(
    column: $table.timeIFRMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeInstrumentMinutes => $composableBuilder(
    column: $table.timeInstrumentMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeSimulatedInstrumentMinutes => $composableBuilder(
    column: $table.timeSimulatedInstrumentMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeNightMinutes => $composableBuilder(
    column: $table.timeNightMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeCrossCountryMinutes => $composableBuilder(
    column: $table.timeCrossCountryMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeCustom1Minutes => $composableBuilder(
    column: $table.timeCustom1Minutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeCustom2Minutes => $composableBuilder(
    column: $table.timeCustom2Minutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeCustom3Minutes => $composableBuilder(
    column: $table.timeCustom3Minutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeCustom4Minutes => $composableBuilder(
    column: $table.timeCustom4Minutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeFlightMinutes => $composableBuilder(
    column: $table.timeFlightMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeBlockMinutes => $composableBuilder(
    column: $table.timeBlockMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeSimulatorMinutes => $composableBuilder(
    column: $table.timeSimulatorMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get distanceNM => $composableBuilder(
    column: $table.distanceNM,
    builder: (column) => column,
  );

  GeneratedColumn<int> get flightCount => $composableBuilder(
    column: $table.flightCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ifrApproaches => $composableBuilder(
    column: $table.ifrApproaches,
    builder: (column) => column,
  );

  GeneratedColumn<int> get takeOffsDays => $composableBuilder(
    column: $table.takeOffsDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get takeOffsNight => $composableBuilder(
    column: $table.takeOffsNight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get landingsDay => $composableBuilder(
    column: $table.landingsDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get landingsNight => $composableBuilder(
    column: $table.landingsNight,
    builder: (column) => column,
  );

  $$AircraftTypesTableAnnotationComposer get aircraftTypeId {
    final $$AircraftTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.aircraftTypeId,
      referencedTable: $db.aircraftTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AircraftTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.aircraftTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreviousExperiencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreviousExperiencesTable,
          PreviousExperience,
          $$PreviousExperiencesTableFilterComposer,
          $$PreviousExperiencesTableOrderingComposer,
          $$PreviousExperiencesTableAnnotationComposer,
          $$PreviousExperiencesTableCreateCompanionBuilder,
          $$PreviousExperiencesTableUpdateCompanionBuilder,
          (PreviousExperience, $$PreviousExperiencesTableReferences),
          PreviousExperience,
          PrefetchHooks Function({bool aircraftTypeId})
        > {
  $$PreviousExperiencesTableTableManager(
    _$AppDatabase db,
    $PreviousExperiencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreviousExperiencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreviousExperiencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PreviousExperiencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> aircraftTypeId = const Value.absent(),
                Value<DateTime?> dateTimeFirstFlight = const Value.absent(),
                Value<DateTime?> dateTimeLastFlight = const Value.absent(),
                Value<int> timePICMinutes = const Value.absent(),
                Value<int> timePICUSMinutes = const Value.absent(),
                Value<int> timeSICMinutes = const Value.absent(),
                Value<int> timeDualMinutes = const Value.absent(),
                Value<int> timeInstructorMinutes = const Value.absent(),
                Value<int> timeIFRMinutes = const Value.absent(),
                Value<int> timeInstrumentMinutes = const Value.absent(),
                Value<int> timeSimulatedInstrumentMinutes =
                    const Value.absent(),
                Value<int> timeNightMinutes = const Value.absent(),
                Value<int> timeCrossCountryMinutes = const Value.absent(),
                Value<int> timeCustom1Minutes = const Value.absent(),
                Value<int> timeCustom2Minutes = const Value.absent(),
                Value<int> timeCustom3Minutes = const Value.absent(),
                Value<int> timeCustom4Minutes = const Value.absent(),
                Value<int> timeFlightMinutes = const Value.absent(),
                Value<int> timeBlockMinutes = const Value.absent(),
                Value<int> timeSimulatorMinutes = const Value.absent(),
                Value<int> distanceNM = const Value.absent(),
                Value<int> flightCount = const Value.absent(),
                Value<int> ifrApproaches = const Value.absent(),
                Value<int> takeOffsDays = const Value.absent(),
                Value<int> takeOffsNight = const Value.absent(),
                Value<int> landingsDay = const Value.absent(),
                Value<int> landingsNight = const Value.absent(),
              }) => PreviousExperiencesCompanion(
                id: id,
                aircraftTypeId: aircraftTypeId,
                dateTimeFirstFlight: dateTimeFirstFlight,
                dateTimeLastFlight: dateTimeLastFlight,
                timePICMinutes: timePICMinutes,
                timePICUSMinutes: timePICUSMinutes,
                timeSICMinutes: timeSICMinutes,
                timeDualMinutes: timeDualMinutes,
                timeInstructorMinutes: timeInstructorMinutes,
                timeIFRMinutes: timeIFRMinutes,
                timeInstrumentMinutes: timeInstrumentMinutes,
                timeSimulatedInstrumentMinutes: timeSimulatedInstrumentMinutes,
                timeNightMinutes: timeNightMinutes,
                timeCrossCountryMinutes: timeCrossCountryMinutes,
                timeCustom1Minutes: timeCustom1Minutes,
                timeCustom2Minutes: timeCustom2Minutes,
                timeCustom3Minutes: timeCustom3Minutes,
                timeCustom4Minutes: timeCustom4Minutes,
                timeFlightMinutes: timeFlightMinutes,
                timeBlockMinutes: timeBlockMinutes,
                timeSimulatorMinutes: timeSimulatorMinutes,
                distanceNM: distanceNM,
                flightCount: flightCount,
                ifrApproaches: ifrApproaches,
                takeOffsDays: takeOffsDays,
                takeOffsNight: takeOffsNight,
                landingsDay: landingsDay,
                landingsNight: landingsNight,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int aircraftTypeId,
                Value<DateTime?> dateTimeFirstFlight = const Value.absent(),
                Value<DateTime?> dateTimeLastFlight = const Value.absent(),
                required int timePICMinutes,
                required int timePICUSMinutes,
                required int timeSICMinutes,
                required int timeDualMinutes,
                required int timeInstructorMinutes,
                required int timeIFRMinutes,
                required int timeInstrumentMinutes,
                required int timeSimulatedInstrumentMinutes,
                required int timeNightMinutes,
                required int timeCrossCountryMinutes,
                required int timeCustom1Minutes,
                required int timeCustom2Minutes,
                required int timeCustom3Minutes,
                required int timeCustom4Minutes,
                required int timeFlightMinutes,
                required int timeBlockMinutes,
                required int timeSimulatorMinutes,
                required int distanceNM,
                Value<int> flightCount = const Value.absent(),
                required int ifrApproaches,
                required int takeOffsDays,
                required int takeOffsNight,
                required int landingsDay,
                required int landingsNight,
              }) => PreviousExperiencesCompanion.insert(
                id: id,
                aircraftTypeId: aircraftTypeId,
                dateTimeFirstFlight: dateTimeFirstFlight,
                dateTimeLastFlight: dateTimeLastFlight,
                timePICMinutes: timePICMinutes,
                timePICUSMinutes: timePICUSMinutes,
                timeSICMinutes: timeSICMinutes,
                timeDualMinutes: timeDualMinutes,
                timeInstructorMinutes: timeInstructorMinutes,
                timeIFRMinutes: timeIFRMinutes,
                timeInstrumentMinutes: timeInstrumentMinutes,
                timeSimulatedInstrumentMinutes: timeSimulatedInstrumentMinutes,
                timeNightMinutes: timeNightMinutes,
                timeCrossCountryMinutes: timeCrossCountryMinutes,
                timeCustom1Minutes: timeCustom1Minutes,
                timeCustom2Minutes: timeCustom2Minutes,
                timeCustom3Minutes: timeCustom3Minutes,
                timeCustom4Minutes: timeCustom4Minutes,
                timeFlightMinutes: timeFlightMinutes,
                timeBlockMinutes: timeBlockMinutes,
                timeSimulatorMinutes: timeSimulatorMinutes,
                distanceNM: distanceNM,
                flightCount: flightCount,
                ifrApproaches: ifrApproaches,
                takeOffsDays: takeOffsDays,
                takeOffsNight: takeOffsNight,
                landingsDay: landingsDay,
                landingsNight: landingsNight,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PreviousExperiencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({aircraftTypeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (aircraftTypeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.aircraftTypeId,
                                referencedTable:
                                    $$PreviousExperiencesTableReferences
                                        ._aircraftTypeIdTable(db),
                                referencedColumn:
                                    $$PreviousExperiencesTableReferences
                                        ._aircraftTypeIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PreviousExperiencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreviousExperiencesTable,
      PreviousExperience,
      $$PreviousExperiencesTableFilterComposer,
      $$PreviousExperiencesTableOrderingComposer,
      $$PreviousExperiencesTableAnnotationComposer,
      $$PreviousExperiencesTableCreateCompanionBuilder,
      $$PreviousExperiencesTableUpdateCompanionBuilder,
      (PreviousExperience, $$PreviousExperiencesTableReferences),
      PreviousExperience,
      PrefetchHooks Function({bool aircraftTypeId})
    >;
typedef $$ReportTemplatesTableCreateCompanionBuilder =
    ReportTemplatesCompanion Function({
      Value<int> id,
      required String templateName,
      required String templateJson,
    });
typedef $$ReportTemplatesTableUpdateCompanionBuilder =
    ReportTemplatesCompanion Function({
      Value<int> id,
      Value<String> templateName,
      Value<String> templateJson,
    });

class $$ReportTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $ReportTemplatesTable> {
  $$ReportTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateName => $composableBuilder(
    column: $table.templateName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateJson => $composableBuilder(
    column: $table.templateJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReportTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReportTemplatesTable> {
  $$ReportTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateName => $composableBuilder(
    column: $table.templateName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateJson => $composableBuilder(
    column: $table.templateJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReportTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReportTemplatesTable> {
  $$ReportTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get templateName => $composableBuilder(
    column: $table.templateName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get templateJson => $composableBuilder(
    column: $table.templateJson,
    builder: (column) => column,
  );
}

class $$ReportTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReportTemplatesTable,
          ReportTemplate,
          $$ReportTemplatesTableFilterComposer,
          $$ReportTemplatesTableOrderingComposer,
          $$ReportTemplatesTableAnnotationComposer,
          $$ReportTemplatesTableCreateCompanionBuilder,
          $$ReportTemplatesTableUpdateCompanionBuilder,
          (
            ReportTemplate,
            BaseReferences<
              _$AppDatabase,
              $ReportTemplatesTable,
              ReportTemplate
            >,
          ),
          ReportTemplate,
          PrefetchHooks Function()
        > {
  $$ReportTemplatesTableTableManager(
    _$AppDatabase db,
    $ReportTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> templateName = const Value.absent(),
                Value<String> templateJson = const Value.absent(),
              }) => ReportTemplatesCompanion(
                id: id,
                templateName: templateName,
                templateJson: templateJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String templateName,
                required String templateJson,
              }) => ReportTemplatesCompanion.insert(
                id: id,
                templateName: templateName,
                templateJson: templateJson,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReportTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReportTemplatesTable,
      ReportTemplate,
      $$ReportTemplatesTableFilterComposer,
      $$ReportTemplatesTableOrderingComposer,
      $$ReportTemplatesTableAnnotationComposer,
      $$ReportTemplatesTableCreateCompanionBuilder,
      $$ReportTemplatesTableUpdateCompanionBuilder,
      (
        ReportTemplate,
        BaseReferences<_$AppDatabase, $ReportTemplatesTable, ReportTemplate>,
      ),
      ReportTemplate,
      PrefetchHooks Function()
    >;
typedef $$DutyPeriodsTableCreateCompanionBuilder =
    DutyPeriodsCompanion Function({
      Value<int> id,
      required int dutyStartTimeLineId,
      required int dutyEndTimeLineId,
      required int timeDutyMinutes,
      Value<int> restBeforeMinutes,
      required int timeFactoredDutyMinutes,
      required bool isLocked,
    });
typedef $$DutyPeriodsTableUpdateCompanionBuilder =
    DutyPeriodsCompanion Function({
      Value<int> id,
      Value<int> dutyStartTimeLineId,
      Value<int> dutyEndTimeLineId,
      Value<int> timeDutyMinutes,
      Value<int> restBeforeMinutes,
      Value<int> timeFactoredDutyMinutes,
      Value<bool> isLocked,
    });

final class $$DutyPeriodsTableReferences
    extends BaseReferences<_$AppDatabase, $DutyPeriodsTable, DutyPeriod> {
  $$DutyPeriodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TimeLinesTable _dutyStartTimeLineIdTable(_$AppDatabase db) =>
      db.timeLines.createAlias(
        $_aliasNameGenerator(
          db.dutyPeriods.dutyStartTimeLineId,
          db.timeLines.id,
        ),
      );

  $$TimeLinesTableProcessedTableManager get dutyStartTimeLineId {
    final $_column = $_itemColumn<int>('duty_start_time_line_id')!;

    final manager = $$TimeLinesTableTableManager(
      $_db,
      $_db.timeLines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dutyStartTimeLineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TimeLinesTable _dutyEndTimeLineIdTable(_$AppDatabase db) =>
      db.timeLines.createAlias(
        $_aliasNameGenerator(db.dutyPeriods.dutyEndTimeLineId, db.timeLines.id),
      );

  $$TimeLinesTableProcessedTableManager get dutyEndTimeLineId {
    final $_column = $_itemColumn<int>('duty_end_time_line_id')!;

    final manager = $$TimeLinesTableTableManager(
      $_db,
      $_db.timeLines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dutyEndTimeLineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DutyPeriodsTableFilterComposer
    extends Composer<_$AppDatabase, $DutyPeriodsTable> {
  $$DutyPeriodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeDutyMinutes => $composableBuilder(
    column: $table.timeDutyMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restBeforeMinutes => $composableBuilder(
    column: $table.restBeforeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeFactoredDutyMinutes => $composableBuilder(
    column: $table.timeFactoredDutyMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );

  $$TimeLinesTableFilterComposer get dutyStartTimeLineId {
    final $$TimeLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dutyStartTimeLineId,
      referencedTable: $db.timeLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeLinesTableFilterComposer(
            $db: $db,
            $table: $db.timeLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TimeLinesTableFilterComposer get dutyEndTimeLineId {
    final $$TimeLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dutyEndTimeLineId,
      referencedTable: $db.timeLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeLinesTableFilterComposer(
            $db: $db,
            $table: $db.timeLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DutyPeriodsTableOrderingComposer
    extends Composer<_$AppDatabase, $DutyPeriodsTable> {
  $$DutyPeriodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeDutyMinutes => $composableBuilder(
    column: $table.timeDutyMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restBeforeMinutes => $composableBuilder(
    column: $table.restBeforeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeFactoredDutyMinutes => $composableBuilder(
    column: $table.timeFactoredDutyMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );

  $$TimeLinesTableOrderingComposer get dutyStartTimeLineId {
    final $$TimeLinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dutyStartTimeLineId,
      referencedTable: $db.timeLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeLinesTableOrderingComposer(
            $db: $db,
            $table: $db.timeLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TimeLinesTableOrderingComposer get dutyEndTimeLineId {
    final $$TimeLinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dutyEndTimeLineId,
      referencedTable: $db.timeLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeLinesTableOrderingComposer(
            $db: $db,
            $table: $db.timeLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DutyPeriodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DutyPeriodsTable> {
  $$DutyPeriodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get timeDutyMinutes => $composableBuilder(
    column: $table.timeDutyMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get restBeforeMinutes => $composableBuilder(
    column: $table.restBeforeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeFactoredDutyMinutes => $composableBuilder(
    column: $table.timeFactoredDutyMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  $$TimeLinesTableAnnotationComposer get dutyStartTimeLineId {
    final $$TimeLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dutyStartTimeLineId,
      referencedTable: $db.timeLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.timeLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TimeLinesTableAnnotationComposer get dutyEndTimeLineId {
    final $$TimeLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dutyEndTimeLineId,
      referencedTable: $db.timeLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.timeLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DutyPeriodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DutyPeriodsTable,
          DutyPeriod,
          $$DutyPeriodsTableFilterComposer,
          $$DutyPeriodsTableOrderingComposer,
          $$DutyPeriodsTableAnnotationComposer,
          $$DutyPeriodsTableCreateCompanionBuilder,
          $$DutyPeriodsTableUpdateCompanionBuilder,
          (DutyPeriod, $$DutyPeriodsTableReferences),
          DutyPeriod,
          PrefetchHooks Function({
            bool dutyStartTimeLineId,
            bool dutyEndTimeLineId,
          })
        > {
  $$DutyPeriodsTableTableManager(_$AppDatabase db, $DutyPeriodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DutyPeriodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DutyPeriodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DutyPeriodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dutyStartTimeLineId = const Value.absent(),
                Value<int> dutyEndTimeLineId = const Value.absent(),
                Value<int> timeDutyMinutes = const Value.absent(),
                Value<int> restBeforeMinutes = const Value.absent(),
                Value<int> timeFactoredDutyMinutes = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
              }) => DutyPeriodsCompanion(
                id: id,
                dutyStartTimeLineId: dutyStartTimeLineId,
                dutyEndTimeLineId: dutyEndTimeLineId,
                timeDutyMinutes: timeDutyMinutes,
                restBeforeMinutes: restBeforeMinutes,
                timeFactoredDutyMinutes: timeFactoredDutyMinutes,
                isLocked: isLocked,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int dutyStartTimeLineId,
                required int dutyEndTimeLineId,
                required int timeDutyMinutes,
                Value<int> restBeforeMinutes = const Value.absent(),
                required int timeFactoredDutyMinutes,
                required bool isLocked,
              }) => DutyPeriodsCompanion.insert(
                id: id,
                dutyStartTimeLineId: dutyStartTimeLineId,
                dutyEndTimeLineId: dutyEndTimeLineId,
                timeDutyMinutes: timeDutyMinutes,
                restBeforeMinutes: restBeforeMinutes,
                timeFactoredDutyMinutes: timeFactoredDutyMinutes,
                isLocked: isLocked,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DutyPeriodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({dutyStartTimeLineId = false, dutyEndTimeLineId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (dutyStartTimeLineId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.dutyStartTimeLineId,
                                    referencedTable:
                                        $$DutyPeriodsTableReferences
                                            ._dutyStartTimeLineIdTable(db),
                                    referencedColumn:
                                        $$DutyPeriodsTableReferences
                                            ._dutyStartTimeLineIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (dutyEndTimeLineId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.dutyEndTimeLineId,
                                    referencedTable:
                                        $$DutyPeriodsTableReferences
                                            ._dutyEndTimeLineIdTable(db),
                                    referencedColumn:
                                        $$DutyPeriodsTableReferences
                                            ._dutyEndTimeLineIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$DutyPeriodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DutyPeriodsTable,
      DutyPeriod,
      $$DutyPeriodsTableFilterComposer,
      $$DutyPeriodsTableOrderingComposer,
      $$DutyPeriodsTableAnnotationComposer,
      $$DutyPeriodsTableCreateCompanionBuilder,
      $$DutyPeriodsTableUpdateCompanionBuilder,
      (DutyPeriod, $$DutyPeriodsTableReferences),
      DutyPeriod,
      PrefetchHooks Function({bool dutyStartTimeLineId, bool dutyEndTimeLineId})
    >;
typedef $$CrewTableCreateCompanionBuilder =
    CrewCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> email,
      Value<String?> notes,
      Value<String?> phone,
      Value<Uint8List?> picture,
      required bool isSelf,
      required bool isFavorite,
      required bool isLocked,
    });
typedef $$CrewTableUpdateCompanionBuilder =
    CrewCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> email,
      Value<String?> notes,
      Value<String?> phone,
      Value<Uint8List?> picture,
      Value<bool> isSelf,
      Value<bool> isFavorite,
      Value<bool> isLocked,
    });

final class $$CrewTableReferences
    extends BaseReferences<_$AppDatabase, $CrewTable, CrewData> {
  $$CrewTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $FlightCrewAssignmentsTable,
    List<FlightCrewAssignment>
  >
  _flightCrewAssignmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.flightCrewAssignments,
        aliasName: $_aliasNameGenerator(
          db.crew.id,
          db.flightCrewAssignments.crewId,
        ),
      );

  $$FlightCrewAssignmentsTableProcessedTableManager
  get flightCrewAssignmentsRefs {
    final manager = $$FlightCrewAssignmentsTableTableManager(
      $_db,
      $_db.flightCrewAssignments,
    ).filter((f) => f.crewId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _flightCrewAssignmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SimulatorCrewAssignmentsTable,
    List<SimulatorCrewAssignment>
  >
  _simulatorCrewAssignmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.simulatorCrewAssignments,
        aliasName: $_aliasNameGenerator(
          db.crew.id,
          db.simulatorCrewAssignments.crewId,
        ),
      );

  $$SimulatorCrewAssignmentsTableProcessedTableManager
  get simulatorCrewAssignmentsRefs {
    final manager = $$SimulatorCrewAssignmentsTableTableManager(
      $_db,
      $_db.simulatorCrewAssignments,
    ).filter((f) => f.crewId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _simulatorCrewAssignmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CrewTableFilterComposer extends Composer<_$AppDatabase, $CrewTable> {
  $$CrewTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get picture => $composableBuilder(
    column: $table.picture,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSelf => $composableBuilder(
    column: $table.isSelf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> flightCrewAssignmentsRefs(
    Expression<bool> Function($$FlightCrewAssignmentsTableFilterComposer f) f,
  ) {
    final $$FlightCrewAssignmentsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.flightCrewAssignments,
          getReferencedColumn: (t) => t.crewId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FlightCrewAssignmentsTableFilterComposer(
                $db: $db,
                $table: $db.flightCrewAssignments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> simulatorCrewAssignmentsRefs(
    Expression<bool> Function($$SimulatorCrewAssignmentsTableFilterComposer f)
    f,
  ) {
    final $$SimulatorCrewAssignmentsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.simulatorCrewAssignments,
          getReferencedColumn: (t) => t.crewId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SimulatorCrewAssignmentsTableFilterComposer(
                $db: $db,
                $table: $db.simulatorCrewAssignments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CrewTableOrderingComposer extends Composer<_$AppDatabase, $CrewTable> {
  $$CrewTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get picture => $composableBuilder(
    column: $table.picture,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSelf => $composableBuilder(
    column: $table.isSelf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CrewTableAnnotationComposer
    extends Composer<_$AppDatabase, $CrewTable> {
  $$CrewTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<Uint8List> get picture =>
      $composableBuilder(column: $table.picture, builder: (column) => column);

  GeneratedColumn<bool> get isSelf =>
      $composableBuilder(column: $table.isSelf, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  Expression<T> flightCrewAssignmentsRefs<T extends Object>(
    Expression<T> Function($$FlightCrewAssignmentsTableAnnotationComposer a) f,
  ) {
    final $$FlightCrewAssignmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.flightCrewAssignments,
          getReferencedColumn: (t) => t.crewId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$FlightCrewAssignmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.flightCrewAssignments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> simulatorCrewAssignmentsRefs<T extends Object>(
    Expression<T> Function($$SimulatorCrewAssignmentsTableAnnotationComposer a)
    f,
  ) {
    final $$SimulatorCrewAssignmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.simulatorCrewAssignments,
          getReferencedColumn: (t) => t.crewId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SimulatorCrewAssignmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.simulatorCrewAssignments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CrewTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CrewTable,
          CrewData,
          $$CrewTableFilterComposer,
          $$CrewTableOrderingComposer,
          $$CrewTableAnnotationComposer,
          $$CrewTableCreateCompanionBuilder,
          $$CrewTableUpdateCompanionBuilder,
          (CrewData, $$CrewTableReferences),
          CrewData,
          PrefetchHooks Function({
            bool flightCrewAssignmentsRefs,
            bool simulatorCrewAssignmentsRefs,
          })
        > {
  $$CrewTableTableManager(_$AppDatabase db, $CrewTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CrewTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CrewTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CrewTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<Uint8List?> picture = const Value.absent(),
                Value<bool> isSelf = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
              }) => CrewCompanion(
                id: id,
                name: name,
                email: email,
                notes: notes,
                phone: phone,
                picture: picture,
                isSelf: isSelf,
                isFavorite: isFavorite,
                isLocked: isLocked,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> email = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<Uint8List?> picture = const Value.absent(),
                required bool isSelf,
                required bool isFavorite,
                required bool isLocked,
              }) => CrewCompanion.insert(
                id: id,
                name: name,
                email: email,
                notes: notes,
                phone: phone,
                picture: picture,
                isSelf: isSelf,
                isFavorite: isFavorite,
                isLocked: isLocked,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$CrewTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                flightCrewAssignmentsRefs = false,
                simulatorCrewAssignmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (flightCrewAssignmentsRefs) db.flightCrewAssignments,
                    if (simulatorCrewAssignmentsRefs)
                      db.simulatorCrewAssignments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (flightCrewAssignmentsRefs)
                        await $_getPrefetchedData<
                          CrewData,
                          $CrewTable,
                          FlightCrewAssignment
                        >(
                          currentTable: table,
                          referencedTable: $$CrewTableReferences
                              ._flightCrewAssignmentsRefsTable(db),
                          managerFromTypedResult: (p0) => $$CrewTableReferences(
                            db,
                            table,
                            p0,
                          ).flightCrewAssignmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.crewId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (simulatorCrewAssignmentsRefs)
                        await $_getPrefetchedData<
                          CrewData,
                          $CrewTable,
                          SimulatorCrewAssignment
                        >(
                          currentTable: table,
                          referencedTable: $$CrewTableReferences
                              ._simulatorCrewAssignmentsRefsTable(db),
                          managerFromTypedResult: (p0) => $$CrewTableReferences(
                            db,
                            table,
                            p0,
                          ).simulatorCrewAssignmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.crewId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CrewTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CrewTable,
      CrewData,
      $$CrewTableFilterComposer,
      $$CrewTableOrderingComposer,
      $$CrewTableAnnotationComposer,
      $$CrewTableCreateCompanionBuilder,
      $$CrewTableUpdateCompanionBuilder,
      (CrewData, $$CrewTableReferences),
      CrewData,
      PrefetchHooks Function({
        bool flightCrewAssignmentsRefs,
        bool simulatorCrewAssignmentsRefs,
      })
    >;
typedef $$FlightCrewAssignmentsTableCreateCompanionBuilder =
    FlightCrewAssignmentsCompanion Function({
      Value<int> id,
      required int flightId,
      required int crewId,
      required CrewPosition position,
    });
typedef $$FlightCrewAssignmentsTableUpdateCompanionBuilder =
    FlightCrewAssignmentsCompanion Function({
      Value<int> id,
      Value<int> flightId,
      Value<int> crewId,
      Value<CrewPosition> position,
    });

final class $$FlightCrewAssignmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $FlightCrewAssignmentsTable,
          FlightCrewAssignment
        > {
  $$FlightCrewAssignmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FlightsTable _flightIdTable(_$AppDatabase db) =>
      db.flights.createAlias(
        $_aliasNameGenerator(db.flightCrewAssignments.flightId, db.flights.id),
      );

  $$FlightsTableProcessedTableManager get flightId {
    final $_column = $_itemColumn<int>('flight_id')!;

    final manager = $$FlightsTableTableManager(
      $_db,
      $_db.flights,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_flightIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CrewTable _crewIdTable(_$AppDatabase db) => db.crew.createAlias(
    $_aliasNameGenerator(db.flightCrewAssignments.crewId, db.crew.id),
  );

  $$CrewTableProcessedTableManager get crewId {
    final $_column = $_itemColumn<int>('crew_id')!;

    final manager = $$CrewTableTableManager(
      $_db,
      $_db.crew,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_crewIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FlightCrewAssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $FlightCrewAssignmentsTable> {
  $$FlightCrewAssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CrewPosition, CrewPosition, String>
  get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$FlightsTableFilterComposer get flightId {
    final $$FlightsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flightId,
      referencedTable: $db.flights,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlightsTableFilterComposer(
            $db: $db,
            $table: $db.flights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CrewTableFilterComposer get crewId {
    final $$CrewTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.crewId,
      referencedTable: $db.crew,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CrewTableFilterComposer(
            $db: $db,
            $table: $db.crew,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlightCrewAssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $FlightCrewAssignmentsTable> {
  $$FlightCrewAssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$FlightsTableOrderingComposer get flightId {
    final $$FlightsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flightId,
      referencedTable: $db.flights,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlightsTableOrderingComposer(
            $db: $db,
            $table: $db.flights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CrewTableOrderingComposer get crewId {
    final $$CrewTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.crewId,
      referencedTable: $db.crew,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CrewTableOrderingComposer(
            $db: $db,
            $table: $db.crew,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlightCrewAssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlightCrewAssignmentsTable> {
  $$FlightCrewAssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CrewPosition, String> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$FlightsTableAnnotationComposer get flightId {
    final $$FlightsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flightId,
      referencedTable: $db.flights,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlightsTableAnnotationComposer(
            $db: $db,
            $table: $db.flights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CrewTableAnnotationComposer get crewId {
    final $$CrewTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.crewId,
      referencedTable: $db.crew,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CrewTableAnnotationComposer(
            $db: $db,
            $table: $db.crew,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlightCrewAssignmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FlightCrewAssignmentsTable,
          FlightCrewAssignment,
          $$FlightCrewAssignmentsTableFilterComposer,
          $$FlightCrewAssignmentsTableOrderingComposer,
          $$FlightCrewAssignmentsTableAnnotationComposer,
          $$FlightCrewAssignmentsTableCreateCompanionBuilder,
          $$FlightCrewAssignmentsTableUpdateCompanionBuilder,
          (FlightCrewAssignment, $$FlightCrewAssignmentsTableReferences),
          FlightCrewAssignment,
          PrefetchHooks Function({bool flightId, bool crewId})
        > {
  $$FlightCrewAssignmentsTableTableManager(
    _$AppDatabase db,
    $FlightCrewAssignmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlightCrewAssignmentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$FlightCrewAssignmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FlightCrewAssignmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> flightId = const Value.absent(),
                Value<int> crewId = const Value.absent(),
                Value<CrewPosition> position = const Value.absent(),
              }) => FlightCrewAssignmentsCompanion(
                id: id,
                flightId: flightId,
                crewId: crewId,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int flightId,
                required int crewId,
                required CrewPosition position,
              }) => FlightCrewAssignmentsCompanion.insert(
                id: id,
                flightId: flightId,
                crewId: crewId,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FlightCrewAssignmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({flightId = false, crewId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (flightId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.flightId,
                                referencedTable:
                                    $$FlightCrewAssignmentsTableReferences
                                        ._flightIdTable(db),
                                referencedColumn:
                                    $$FlightCrewAssignmentsTableReferences
                                        ._flightIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (crewId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.crewId,
                                referencedTable:
                                    $$FlightCrewAssignmentsTableReferences
                                        ._crewIdTable(db),
                                referencedColumn:
                                    $$FlightCrewAssignmentsTableReferences
                                        ._crewIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FlightCrewAssignmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FlightCrewAssignmentsTable,
      FlightCrewAssignment,
      $$FlightCrewAssignmentsTableFilterComposer,
      $$FlightCrewAssignmentsTableOrderingComposer,
      $$FlightCrewAssignmentsTableAnnotationComposer,
      $$FlightCrewAssignmentsTableCreateCompanionBuilder,
      $$FlightCrewAssignmentsTableUpdateCompanionBuilder,
      (FlightCrewAssignment, $$FlightCrewAssignmentsTableReferences),
      FlightCrewAssignment,
      PrefetchHooks Function({bool flightId, bool crewId})
    >;
typedef $$SimulatorTrainingsTableCreateCompanionBuilder =
    SimulatorTrainingsCompanion Function({
      Value<int> id,
      required int aircraftId,
      required int startTimeLineId,
      Value<DateTime?> endDateTime,
      required int timeTotal,
      required String remarks,
      required String notes,
      required bool isLocked,
      Value<Uint8List?> signatureImage,
      Value<String?> endorsementData,
      Value<String?> endorsementHash,
    });
typedef $$SimulatorTrainingsTableUpdateCompanionBuilder =
    SimulatorTrainingsCompanion Function({
      Value<int> id,
      Value<int> aircraftId,
      Value<int> startTimeLineId,
      Value<DateTime?> endDateTime,
      Value<int> timeTotal,
      Value<String> remarks,
      Value<String> notes,
      Value<bool> isLocked,
      Value<Uint8List?> signatureImage,
      Value<String?> endorsementData,
      Value<String?> endorsementHash,
    });

final class $$SimulatorTrainingsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SimulatorTrainingsTable,
          SimulatorTraining
        > {
  $$SimulatorTrainingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AircraftsTable _aircraftIdTable(_$AppDatabase db) =>
      db.aircrafts.createAlias(
        $_aliasNameGenerator(db.simulatorTrainings.aircraftId, db.aircrafts.id),
      );

  $$AircraftsTableProcessedTableManager get aircraftId {
    final $_column = $_itemColumn<int>('aircraft_id')!;

    final manager = $$AircraftsTableTableManager(
      $_db,
      $_db.aircrafts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_aircraftIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TimeLinesTable _startTimeLineIdTable(_$AppDatabase db) =>
      db.timeLines.createAlias(
        $_aliasNameGenerator(
          db.simulatorTrainings.startTimeLineId,
          db.timeLines.id,
        ),
      );

  $$TimeLinesTableProcessedTableManager get startTimeLineId {
    final $_column = $_itemColumn<int>('start_time_line_id')!;

    final manager = $$TimeLinesTableTableManager(
      $_db,
      $_db.timeLines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_startTimeLineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $SimulatorCrewAssignmentsTable,
    List<SimulatorCrewAssignment>
  >
  _simulatorCrewAssignmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.simulatorCrewAssignments,
        aliasName: $_aliasNameGenerator(
          db.simulatorTrainings.id,
          db.simulatorCrewAssignments.simulatorId,
        ),
      );

  $$SimulatorCrewAssignmentsTableProcessedTableManager
  get simulatorCrewAssignmentsRefs {
    final manager = $$SimulatorCrewAssignmentsTableTableManager(
      $_db,
      $_db.simulatorCrewAssignments,
    ).filter((f) => f.simulatorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _simulatorCrewAssignmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SimulatorTrainingsTableFilterComposer
    extends Composer<_$AppDatabase, $SimulatorTrainingsTable> {
  $$SimulatorTrainingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDateTime => $composableBuilder(
    column: $table.endDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeTotal => $composableBuilder(
    column: $table.timeTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get signatureImage => $composableBuilder(
    column: $table.signatureImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endorsementData => $composableBuilder(
    column: $table.endorsementData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endorsementHash => $composableBuilder(
    column: $table.endorsementHash,
    builder: (column) => ColumnFilters(column),
  );

  $$AircraftsTableFilterComposer get aircraftId {
    final $$AircraftsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.aircraftId,
      referencedTable: $db.aircrafts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AircraftsTableFilterComposer(
            $db: $db,
            $table: $db.aircrafts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TimeLinesTableFilterComposer get startTimeLineId {
    final $$TimeLinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.startTimeLineId,
      referencedTable: $db.timeLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeLinesTableFilterComposer(
            $db: $db,
            $table: $db.timeLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> simulatorCrewAssignmentsRefs(
    Expression<bool> Function($$SimulatorCrewAssignmentsTableFilterComposer f)
    f,
  ) {
    final $$SimulatorCrewAssignmentsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.simulatorCrewAssignments,
          getReferencedColumn: (t) => t.simulatorId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SimulatorCrewAssignmentsTableFilterComposer(
                $db: $db,
                $table: $db.simulatorCrewAssignments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SimulatorTrainingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SimulatorTrainingsTable> {
  $$SimulatorTrainingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDateTime => $composableBuilder(
    column: $table.endDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeTotal => $composableBuilder(
    column: $table.timeTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocked => $composableBuilder(
    column: $table.isLocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get signatureImage => $composableBuilder(
    column: $table.signatureImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endorsementData => $composableBuilder(
    column: $table.endorsementData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endorsementHash => $composableBuilder(
    column: $table.endorsementHash,
    builder: (column) => ColumnOrderings(column),
  );

  $$AircraftsTableOrderingComposer get aircraftId {
    final $$AircraftsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.aircraftId,
      referencedTable: $db.aircrafts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AircraftsTableOrderingComposer(
            $db: $db,
            $table: $db.aircrafts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TimeLinesTableOrderingComposer get startTimeLineId {
    final $$TimeLinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.startTimeLineId,
      referencedTable: $db.timeLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeLinesTableOrderingComposer(
            $db: $db,
            $table: $db.timeLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SimulatorTrainingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SimulatorTrainingsTable> {
  $$SimulatorTrainingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get endDateTime => $composableBuilder(
    column: $table.endDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeTotal =>
      $composableBuilder(column: $table.timeTotal, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  GeneratedColumn<Uint8List> get signatureImage => $composableBuilder(
    column: $table.signatureImage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endorsementData => $composableBuilder(
    column: $table.endorsementData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endorsementHash => $composableBuilder(
    column: $table.endorsementHash,
    builder: (column) => column,
  );

  $$AircraftsTableAnnotationComposer get aircraftId {
    final $$AircraftsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.aircraftId,
      referencedTable: $db.aircrafts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AircraftsTableAnnotationComposer(
            $db: $db,
            $table: $db.aircrafts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TimeLinesTableAnnotationComposer get startTimeLineId {
    final $$TimeLinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.startTimeLineId,
      referencedTable: $db.timeLines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeLinesTableAnnotationComposer(
            $db: $db,
            $table: $db.timeLines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> simulatorCrewAssignmentsRefs<T extends Object>(
    Expression<T> Function($$SimulatorCrewAssignmentsTableAnnotationComposer a)
    f,
  ) {
    final $$SimulatorCrewAssignmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.simulatorCrewAssignments,
          getReferencedColumn: (t) => t.simulatorId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SimulatorCrewAssignmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.simulatorCrewAssignments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SimulatorTrainingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SimulatorTrainingsTable,
          SimulatorTraining,
          $$SimulatorTrainingsTableFilterComposer,
          $$SimulatorTrainingsTableOrderingComposer,
          $$SimulatorTrainingsTableAnnotationComposer,
          $$SimulatorTrainingsTableCreateCompanionBuilder,
          $$SimulatorTrainingsTableUpdateCompanionBuilder,
          (SimulatorTraining, $$SimulatorTrainingsTableReferences),
          SimulatorTraining,
          PrefetchHooks Function({
            bool aircraftId,
            bool startTimeLineId,
            bool simulatorCrewAssignmentsRefs,
          })
        > {
  $$SimulatorTrainingsTableTableManager(
    _$AppDatabase db,
    $SimulatorTrainingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SimulatorTrainingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SimulatorTrainingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SimulatorTrainingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> aircraftId = const Value.absent(),
                Value<int> startTimeLineId = const Value.absent(),
                Value<DateTime?> endDateTime = const Value.absent(),
                Value<int> timeTotal = const Value.absent(),
                Value<String> remarks = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> isLocked = const Value.absent(),
                Value<Uint8List?> signatureImage = const Value.absent(),
                Value<String?> endorsementData = const Value.absent(),
                Value<String?> endorsementHash = const Value.absent(),
              }) => SimulatorTrainingsCompanion(
                id: id,
                aircraftId: aircraftId,
                startTimeLineId: startTimeLineId,
                endDateTime: endDateTime,
                timeTotal: timeTotal,
                remarks: remarks,
                notes: notes,
                isLocked: isLocked,
                signatureImage: signatureImage,
                endorsementData: endorsementData,
                endorsementHash: endorsementHash,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int aircraftId,
                required int startTimeLineId,
                Value<DateTime?> endDateTime = const Value.absent(),
                required int timeTotal,
                required String remarks,
                required String notes,
                required bool isLocked,
                Value<Uint8List?> signatureImage = const Value.absent(),
                Value<String?> endorsementData = const Value.absent(),
                Value<String?> endorsementHash = const Value.absent(),
              }) => SimulatorTrainingsCompanion.insert(
                id: id,
                aircraftId: aircraftId,
                startTimeLineId: startTimeLineId,
                endDateTime: endDateTime,
                timeTotal: timeTotal,
                remarks: remarks,
                notes: notes,
                isLocked: isLocked,
                signatureImage: signatureImage,
                endorsementData: endorsementData,
                endorsementHash: endorsementHash,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SimulatorTrainingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                aircraftId = false,
                startTimeLineId = false,
                simulatorCrewAssignmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (simulatorCrewAssignmentsRefs)
                      db.simulatorCrewAssignments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (aircraftId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.aircraftId,
                                    referencedTable:
                                        $$SimulatorTrainingsTableReferences
                                            ._aircraftIdTable(db),
                                    referencedColumn:
                                        $$SimulatorTrainingsTableReferences
                                            ._aircraftIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (startTimeLineId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.startTimeLineId,
                                    referencedTable:
                                        $$SimulatorTrainingsTableReferences
                                            ._startTimeLineIdTable(db),
                                    referencedColumn:
                                        $$SimulatorTrainingsTableReferences
                                            ._startTimeLineIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (simulatorCrewAssignmentsRefs)
                        await $_getPrefetchedData<
                          SimulatorTraining,
                          $SimulatorTrainingsTable,
                          SimulatorCrewAssignment
                        >(
                          currentTable: table,
                          referencedTable: $$SimulatorTrainingsTableReferences
                              ._simulatorCrewAssignmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SimulatorTrainingsTableReferences(
                                db,
                                table,
                                p0,
                              ).simulatorCrewAssignmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.simulatorId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SimulatorTrainingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SimulatorTrainingsTable,
      SimulatorTraining,
      $$SimulatorTrainingsTableFilterComposer,
      $$SimulatorTrainingsTableOrderingComposer,
      $$SimulatorTrainingsTableAnnotationComposer,
      $$SimulatorTrainingsTableCreateCompanionBuilder,
      $$SimulatorTrainingsTableUpdateCompanionBuilder,
      (SimulatorTraining, $$SimulatorTrainingsTableReferences),
      SimulatorTraining,
      PrefetchHooks Function({
        bool aircraftId,
        bool startTimeLineId,
        bool simulatorCrewAssignmentsRefs,
      })
    >;
typedef $$SimulatorCrewAssignmentsTableCreateCompanionBuilder =
    SimulatorCrewAssignmentsCompanion Function({
      Value<int> id,
      required int simulatorId,
      required int crewId,
      required CrewPosition position,
    });
typedef $$SimulatorCrewAssignmentsTableUpdateCompanionBuilder =
    SimulatorCrewAssignmentsCompanion Function({
      Value<int> id,
      Value<int> simulatorId,
      Value<int> crewId,
      Value<CrewPosition> position,
    });

final class $$SimulatorCrewAssignmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SimulatorCrewAssignmentsTable,
          SimulatorCrewAssignment
        > {
  $$SimulatorCrewAssignmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SimulatorTrainingsTable _simulatorIdTable(_$AppDatabase db) =>
      db.simulatorTrainings.createAlias(
        $_aliasNameGenerator(
          db.simulatorCrewAssignments.simulatorId,
          db.simulatorTrainings.id,
        ),
      );

  $$SimulatorTrainingsTableProcessedTableManager get simulatorId {
    final $_column = $_itemColumn<int>('simulator_id')!;

    final manager = $$SimulatorTrainingsTableTableManager(
      $_db,
      $_db.simulatorTrainings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_simulatorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CrewTable _crewIdTable(_$AppDatabase db) => db.crew.createAlias(
    $_aliasNameGenerator(db.simulatorCrewAssignments.crewId, db.crew.id),
  );

  $$CrewTableProcessedTableManager get crewId {
    final $_column = $_itemColumn<int>('crew_id')!;

    final manager = $$CrewTableTableManager(
      $_db,
      $_db.crew,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_crewIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SimulatorCrewAssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $SimulatorCrewAssignmentsTable> {
  $$SimulatorCrewAssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CrewPosition, CrewPosition, String>
  get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$SimulatorTrainingsTableFilterComposer get simulatorId {
    final $$SimulatorTrainingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.simulatorId,
      referencedTable: $db.simulatorTrainings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SimulatorTrainingsTableFilterComposer(
            $db: $db,
            $table: $db.simulatorTrainings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CrewTableFilterComposer get crewId {
    final $$CrewTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.crewId,
      referencedTable: $db.crew,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CrewTableFilterComposer(
            $db: $db,
            $table: $db.crew,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SimulatorCrewAssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SimulatorCrewAssignmentsTable> {
  $$SimulatorCrewAssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$SimulatorTrainingsTableOrderingComposer get simulatorId {
    final $$SimulatorTrainingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.simulatorId,
      referencedTable: $db.simulatorTrainings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SimulatorTrainingsTableOrderingComposer(
            $db: $db,
            $table: $db.simulatorTrainings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CrewTableOrderingComposer get crewId {
    final $$CrewTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.crewId,
      referencedTable: $db.crew,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CrewTableOrderingComposer(
            $db: $db,
            $table: $db.crew,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SimulatorCrewAssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SimulatorCrewAssignmentsTable> {
  $$SimulatorCrewAssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CrewPosition, String> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$SimulatorTrainingsTableAnnotationComposer get simulatorId {
    final $$SimulatorTrainingsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.simulatorId,
          referencedTable: $db.simulatorTrainings,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SimulatorTrainingsTableAnnotationComposer(
                $db: $db,
                $table: $db.simulatorTrainings,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CrewTableAnnotationComposer get crewId {
    final $$CrewTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.crewId,
      referencedTable: $db.crew,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CrewTableAnnotationComposer(
            $db: $db,
            $table: $db.crew,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SimulatorCrewAssignmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SimulatorCrewAssignmentsTable,
          SimulatorCrewAssignment,
          $$SimulatorCrewAssignmentsTableFilterComposer,
          $$SimulatorCrewAssignmentsTableOrderingComposer,
          $$SimulatorCrewAssignmentsTableAnnotationComposer,
          $$SimulatorCrewAssignmentsTableCreateCompanionBuilder,
          $$SimulatorCrewAssignmentsTableUpdateCompanionBuilder,
          (SimulatorCrewAssignment, $$SimulatorCrewAssignmentsTableReferences),
          SimulatorCrewAssignment,
          PrefetchHooks Function({bool simulatorId, bool crewId})
        > {
  $$SimulatorCrewAssignmentsTableTableManager(
    _$AppDatabase db,
    $SimulatorCrewAssignmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SimulatorCrewAssignmentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SimulatorCrewAssignmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SimulatorCrewAssignmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> simulatorId = const Value.absent(),
                Value<int> crewId = const Value.absent(),
                Value<CrewPosition> position = const Value.absent(),
              }) => SimulatorCrewAssignmentsCompanion(
                id: id,
                simulatorId: simulatorId,
                crewId: crewId,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int simulatorId,
                required int crewId,
                required CrewPosition position,
              }) => SimulatorCrewAssignmentsCompanion.insert(
                id: id,
                simulatorId: simulatorId,
                crewId: crewId,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SimulatorCrewAssignmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({simulatorId = false, crewId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (simulatorId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.simulatorId,
                                referencedTable:
                                    $$SimulatorCrewAssignmentsTableReferences
                                        ._simulatorIdTable(db),
                                referencedColumn:
                                    $$SimulatorCrewAssignmentsTableReferences
                                        ._simulatorIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (crewId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.crewId,
                                referencedTable:
                                    $$SimulatorCrewAssignmentsTableReferences
                                        ._crewIdTable(db),
                                referencedColumn:
                                    $$SimulatorCrewAssignmentsTableReferences
                                        ._crewIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SimulatorCrewAssignmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SimulatorCrewAssignmentsTable,
      SimulatorCrewAssignment,
      $$SimulatorCrewAssignmentsTableFilterComposer,
      $$SimulatorCrewAssignmentsTableOrderingComposer,
      $$SimulatorCrewAssignmentsTableAnnotationComposer,
      $$SimulatorCrewAssignmentsTableCreateCompanionBuilder,
      $$SimulatorCrewAssignmentsTableUpdateCompanionBuilder,
      (SimulatorCrewAssignment, $$SimulatorCrewAssignmentsTableReferences),
      SimulatorCrewAssignment,
      PrefetchHooks Function({bool simulatorId, bool crewId})
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<Map<String, dynamic>> settingsJson,
      Value<Uint8List?> signatureImage,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<Map<String, dynamic>> settingsJson,
      Value<Uint8List?> signatureImage,
    });

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, dynamic>,
    Map<String, dynamic>,
    String
  >
  get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<Uint8List> get signatureImage => $composableBuilder(
    column: $table.signatureImage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get signatureImage => $composableBuilder(
    column: $table.signatureImage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, dynamic>, String>
  get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get signatureImage => $composableBuilder(
    column: $table.signatureImage,
    builder: (column) => column,
  );
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (
            UserProfile,
            BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
          ),
          UserProfile,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<Map<String, dynamic>> settingsJson = const Value.absent(),
                Value<Uint8List?> signatureImage = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                settingsJson: settingsJson,
                signatureImage: signatureImage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<Map<String, dynamic>> settingsJson = const Value.absent(),
                Value<Uint8List?> signatureImage = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                settingsJson: settingsJson,
                signatureImage: signatureImage,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (
        UserProfile,
        BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>,
      ),
      UserProfile,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AircraftTypesTableTableManager get aircraftTypes =>
      $$AircraftTypesTableTableManager(_db, _db.aircraftTypes);
  $$AircraftsTableTableManager get aircrafts =>
      $$AircraftsTableTableManager(_db, _db.aircrafts);
  $$AirportsTableTableManager get airports =>
      $$AirportsTableTableManager(_db, _db.airports);
  $$TimeLinesTableTableManager get timeLines =>
      $$TimeLinesTableTableManager(_db, _db.timeLines);
  $$FlightsTableTableManager get flights =>
      $$FlightsTableTableManager(_db, _db.flights);
  $$LimitRulesTableTableManager get limitRules =>
      $$LimitRulesTableTableManager(_db, _db.limitRules);
  $$RuleSnapshotsTableTableManager get ruleSnapshots =>
      $$RuleSnapshotsTableTableManager(_db, _db.ruleSnapshots);
  $$PositioningsTableTableManager get positionings =>
      $$PositioningsTableTableManager(_db, _db.positionings);
  $$PreviousExperiencesTableTableManager get previousExperiences =>
      $$PreviousExperiencesTableTableManager(_db, _db.previousExperiences);
  $$ReportTemplatesTableTableManager get reportTemplates =>
      $$ReportTemplatesTableTableManager(_db, _db.reportTemplates);
  $$DutyPeriodsTableTableManager get dutyPeriods =>
      $$DutyPeriodsTableTableManager(_db, _db.dutyPeriods);
  $$CrewTableTableManager get crew => $$CrewTableTableManager(_db, _db.crew);
  $$FlightCrewAssignmentsTableTableManager get flightCrewAssignments =>
      $$FlightCrewAssignmentsTableTableManager(_db, _db.flightCrewAssignments);
  $$SimulatorTrainingsTableTableManager get simulatorTrainings =>
      $$SimulatorTrainingsTableTableManager(_db, _db.simulatorTrainings);
  $$SimulatorCrewAssignmentsTableTableManager get simulatorCrewAssignments =>
      $$SimulatorCrewAssignmentsTableTableManager(
        _db,
        _db.simulatorCrewAssignments,
      );
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
}
