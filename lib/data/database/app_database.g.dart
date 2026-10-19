// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TripsTableTable extends TripsTable
    with TableInfo<$TripsTableTable, TripsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _treasurerIdMeta = const VerificationMeta(
    'treasurerId',
  );
  @override
  late final GeneratedColumn<String> treasurerId = GeneratedColumn<String>(
    'treasurer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeScenarioIdMeta = const VerificationMeta(
    'activeScenarioId',
  );
  @override
  late final GeneratedColumn<String> activeScenarioId = GeneratedColumn<String>(
    'active_scenario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLedgerInitializedMeta =
      const VerificationMeta('isLedgerInitialized');
  @override
  late final GeneratedColumn<bool> isLedgerInitialized = GeneratedColumn<bool>(
    'is_ledger_initialized',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_ledger_initialized" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ledgerScenarioIdMeta = const VerificationMeta(
    'ledgerScenarioId',
  );
  @override
  late final GeneratedColumn<String> ledgerScenarioId = GeneratedColumn<String>(
    'ledger_scenario_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    treasurerId,
    activeScenarioId,
    isLedgerInitialized,
    ledgerScenarioId,
    revision,
    metadataJson,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('treasurer_id')) {
      context.handle(
        _treasurerIdMeta,
        treasurerId.isAcceptableOrUnknown(
          data['treasurer_id']!,
          _treasurerIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_treasurerIdMeta);
    }
    if (data.containsKey('active_scenario_id')) {
      context.handle(
        _activeScenarioIdMeta,
        activeScenarioId.isAcceptableOrUnknown(
          data['active_scenario_id']!,
          _activeScenarioIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activeScenarioIdMeta);
    }
    if (data.containsKey('is_ledger_initialized')) {
      context.handle(
        _isLedgerInitializedMeta,
        isLedgerInitialized.isAcceptableOrUnknown(
          data['is_ledger_initialized']!,
          _isLedgerInitializedMeta,
        ),
      );
    }
    if (data.containsKey('ledger_scenario_id')) {
      context.handle(
        _ledgerScenarioIdMeta,
        ledgerScenarioId.isAcceptableOrUnknown(
          data['ledger_scenario_id']!,
          _ledgerScenarioIdMeta,
        ),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      treasurerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}treasurer_id'],
      )!,
      activeScenarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_scenario_id'],
      )!,
      isLedgerInitialized: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_ledger_initialized'],
      )!,
      ledgerScenarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ledger_scenario_id'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TripsTableTable createAlias(String alias) {
    return $TripsTableTable(attachedDatabase, alias);
  }
}

class TripsTableData extends DataClass implements Insertable<TripsTableData> {
  final String id;
  final String name;
  final String? description;
  final String treasurerId;
  final String activeScenarioId;
  final bool isLedgerInitialized;
  final String? ledgerScenarioId;
  final int revision;
  final String metadataJson;
  final DateTime updatedAt;
  const TripsTableData({
    required this.id,
    required this.name,
    this.description,
    required this.treasurerId,
    required this.activeScenarioId,
    required this.isLedgerInitialized,
    this.ledgerScenarioId,
    required this.revision,
    required this.metadataJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['treasurer_id'] = Variable<String>(treasurerId);
    map['active_scenario_id'] = Variable<String>(activeScenarioId);
    map['is_ledger_initialized'] = Variable<bool>(isLedgerInitialized);
    if (!nullToAbsent || ledgerScenarioId != null) {
      map['ledger_scenario_id'] = Variable<String>(ledgerScenarioId);
    }
    map['revision'] = Variable<int>(revision);
    map['metadata_json'] = Variable<String>(metadataJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TripsTableCompanion toCompanion(bool nullToAbsent) {
    return TripsTableCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      treasurerId: Value(treasurerId),
      activeScenarioId: Value(activeScenarioId),
      isLedgerInitialized: Value(isLedgerInitialized),
      ledgerScenarioId: ledgerScenarioId == null && nullToAbsent
          ? const Value.absent()
          : Value(ledgerScenarioId),
      revision: Value(revision),
      metadataJson: Value(metadataJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory TripsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      treasurerId: serializer.fromJson<String>(json['treasurerId']),
      activeScenarioId: serializer.fromJson<String>(json['activeScenarioId']),
      isLedgerInitialized: serializer.fromJson<bool>(
        json['isLedgerInitialized'],
      ),
      ledgerScenarioId: serializer.fromJson<String?>(json['ledgerScenarioId']),
      revision: serializer.fromJson<int>(json['revision']),
      metadataJson: serializer.fromJson<String>(json['metadataJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'treasurerId': serializer.toJson<String>(treasurerId),
      'activeScenarioId': serializer.toJson<String>(activeScenarioId),
      'isLedgerInitialized': serializer.toJson<bool>(isLedgerInitialized),
      'ledgerScenarioId': serializer.toJson<String?>(ledgerScenarioId),
      'revision': serializer.toJson<int>(revision),
      'metadataJson': serializer.toJson<String>(metadataJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TripsTableData copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    String? treasurerId,
    String? activeScenarioId,
    bool? isLedgerInitialized,
    Value<String?> ledgerScenarioId = const Value.absent(),
    int? revision,
    String? metadataJson,
    DateTime? updatedAt,
  }) => TripsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    treasurerId: treasurerId ?? this.treasurerId,
    activeScenarioId: activeScenarioId ?? this.activeScenarioId,
    isLedgerInitialized: isLedgerInitialized ?? this.isLedgerInitialized,
    ledgerScenarioId: ledgerScenarioId.present
        ? ledgerScenarioId.value
        : this.ledgerScenarioId,
    revision: revision ?? this.revision,
    metadataJson: metadataJson ?? this.metadataJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TripsTableData copyWithCompanion(TripsTableCompanion data) {
    return TripsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      treasurerId: data.treasurerId.present
          ? data.treasurerId.value
          : this.treasurerId,
      activeScenarioId: data.activeScenarioId.present
          ? data.activeScenarioId.value
          : this.activeScenarioId,
      isLedgerInitialized: data.isLedgerInitialized.present
          ? data.isLedgerInitialized.value
          : this.isLedgerInitialized,
      ledgerScenarioId: data.ledgerScenarioId.present
          ? data.ledgerScenarioId.value
          : this.ledgerScenarioId,
      revision: data.revision.present ? data.revision.value : this.revision,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('treasurerId: $treasurerId, ')
          ..write('activeScenarioId: $activeScenarioId, ')
          ..write('isLedgerInitialized: $isLedgerInitialized, ')
          ..write('ledgerScenarioId: $ledgerScenarioId, ')
          ..write('revision: $revision, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    treasurerId,
    activeScenarioId,
    isLedgerInitialized,
    ledgerScenarioId,
    revision,
    metadataJson,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.treasurerId == this.treasurerId &&
          other.activeScenarioId == this.activeScenarioId &&
          other.isLedgerInitialized == this.isLedgerInitialized &&
          other.ledgerScenarioId == this.ledgerScenarioId &&
          other.revision == this.revision &&
          other.metadataJson == this.metadataJson &&
          other.updatedAt == this.updatedAt);
}

class TripsTableCompanion extends UpdateCompanion<TripsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> treasurerId;
  final Value<String> activeScenarioId;
  final Value<bool> isLedgerInitialized;
  final Value<String?> ledgerScenarioId;
  final Value<int> revision;
  final Value<String> metadataJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TripsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.treasurerId = const Value.absent(),
    this.activeScenarioId = const Value.absent(),
    this.isLedgerInitialized = const Value.absent(),
    this.ledgerScenarioId = const Value.absent(),
    this.revision = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsTableCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String treasurerId,
    required String activeScenarioId,
    this.isLedgerInitialized = const Value.absent(),
    this.ledgerScenarioId = const Value.absent(),
    this.revision = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       treasurerId = Value(treasurerId),
       activeScenarioId = Value(activeScenarioId);
  static Insertable<TripsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? treasurerId,
    Expression<String>? activeScenarioId,
    Expression<bool>? isLedgerInitialized,
    Expression<String>? ledgerScenarioId,
    Expression<int>? revision,
    Expression<String>? metadataJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (treasurerId != null) 'treasurer_id': treasurerId,
      if (activeScenarioId != null) 'active_scenario_id': activeScenarioId,
      if (isLedgerInitialized != null)
        'is_ledger_initialized': isLedgerInitialized,
      if (ledgerScenarioId != null) 'ledger_scenario_id': ledgerScenarioId,
      if (revision != null) 'revision': revision,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? treasurerId,
    Value<String>? activeScenarioId,
    Value<bool>? isLedgerInitialized,
    Value<String?>? ledgerScenarioId,
    Value<int>? revision,
    Value<String>? metadataJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TripsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      treasurerId: treasurerId ?? this.treasurerId,
      activeScenarioId: activeScenarioId ?? this.activeScenarioId,
      isLedgerInitialized: isLedgerInitialized ?? this.isLedgerInitialized,
      ledgerScenarioId: ledgerScenarioId ?? this.ledgerScenarioId,
      revision: revision ?? this.revision,
      metadataJson: metadataJson ?? this.metadataJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (treasurerId.present) {
      map['treasurer_id'] = Variable<String>(treasurerId.value);
    }
    if (activeScenarioId.present) {
      map['active_scenario_id'] = Variable<String>(activeScenarioId.value);
    }
    if (isLedgerInitialized.present) {
      map['is_ledger_initialized'] = Variable<bool>(isLedgerInitialized.value);
    }
    if (ledgerScenarioId.present) {
      map['ledger_scenario_id'] = Variable<String>(ledgerScenarioId.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('treasurerId: $treasurerId, ')
          ..write('activeScenarioId: $activeScenarioId, ')
          ..write('isLedgerInitialized: $isLedgerInitialized, ')
          ..write('ledgerScenarioId: $ledgerScenarioId, ')
          ..write('revision: $revision, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MembersTableTable extends MembersTable
    with TableInfo<$MembersTableTable, MembersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _isTreasurerMeta = const VerificationMeta(
    'isTreasurer',
  );
  @override
  late final GeneratedColumn<bool> isTreasurer = GeneratedColumn<bool>(
    'is_treasurer',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_treasurer" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    name,
    isTreasurer,
    isActive,
    orderIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'members_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MembersTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_treasurer')) {
      context.handle(
        _isTreasurerMeta,
        isTreasurer.isAcceptableOrUnknown(
          data['is_treasurer']!,
          _isTreasurerMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MembersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MembersTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isTreasurer: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_treasurer'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $MembersTableTable createAlias(String alias) {
    return $MembersTableTable(attachedDatabase, alias);
  }
}

class MembersTableData extends DataClass
    implements Insertable<MembersTableData> {
  final String id;
  final String tripId;
  final String name;
  final bool isTreasurer;
  final bool isActive;
  final int orderIndex;
  const MembersTableData({
    required this.id,
    required this.tripId,
    required this.name,
    required this.isTreasurer,
    required this.isActive,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['name'] = Variable<String>(name);
    map['is_treasurer'] = Variable<bool>(isTreasurer);
    map['is_active'] = Variable<bool>(isActive);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  MembersTableCompanion toCompanion(bool nullToAbsent) {
    return MembersTableCompanion(
      id: Value(id),
      tripId: Value(tripId),
      name: Value(name),
      isTreasurer: Value(isTreasurer),
      isActive: Value(isActive),
      orderIndex: Value(orderIndex),
    );
  }

  factory MembersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MembersTableData(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      name: serializer.fromJson<String>(json['name']),
      isTreasurer: serializer.fromJson<bool>(json['isTreasurer']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'name': serializer.toJson<String>(name),
      'isTreasurer': serializer.toJson<bool>(isTreasurer),
      'isActive': serializer.toJson<bool>(isActive),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  MembersTableData copyWith({
    String? id,
    String? tripId,
    String? name,
    bool? isTreasurer,
    bool? isActive,
    int? orderIndex,
  }) => MembersTableData(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    name: name ?? this.name,
    isTreasurer: isTreasurer ?? this.isTreasurer,
    isActive: isActive ?? this.isActive,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  MembersTableData copyWithCompanion(MembersTableCompanion data) {
    return MembersTableData(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      name: data.name.present ? data.name.value : this.name,
      isTreasurer: data.isTreasurer.present
          ? data.isTreasurer.value
          : this.isTreasurer,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MembersTableData(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('name: $name, ')
          ..write('isTreasurer: $isTreasurer, ')
          ..write('isActive: $isActive, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, tripId, name, isTreasurer, isActive, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MembersTableData &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.name == this.name &&
          other.isTreasurer == this.isTreasurer &&
          other.isActive == this.isActive &&
          other.orderIndex == this.orderIndex);
}

class MembersTableCompanion extends UpdateCompanion<MembersTableData> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> name;
  final Value<bool> isTreasurer;
  final Value<bool> isActive;
  final Value<int> orderIndex;
  final Value<int> rowid;
  const MembersTableCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.name = const Value.absent(),
    this.isTreasurer = const Value.absent(),
    this.isActive = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembersTableCompanion.insert({
    required String id,
    required String tripId,
    required String name,
    this.isTreasurer = const Value.absent(),
    this.isActive = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       name = Value(name);
  static Insertable<MembersTableData> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? name,
    Expression<bool>? isTreasurer,
    Expression<bool>? isActive,
    Expression<int>? orderIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (name != null) 'name': name,
      if (isTreasurer != null) 'is_treasurer': isTreasurer,
      if (isActive != null) 'is_active': isActive,
      if (orderIndex != null) 'order_index': orderIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembersTableCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? name,
    Value<bool>? isTreasurer,
    Value<bool>? isActive,
    Value<int>? orderIndex,
    Value<int>? rowid,
  }) {
    return MembersTableCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      isTreasurer: isTreasurer ?? this.isTreasurer,
      isActive: isActive ?? this.isActive,
      orderIndex: orderIndex ?? this.orderIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isTreasurer.present) {
      map['is_treasurer'] = Variable<bool>(isTreasurer.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembersTableCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('name: $name, ')
          ..write('isTreasurer: $isTreasurer, ')
          ..write('isActive: $isActive, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StagesTableTable extends StagesTable
    with TableInfo<$StagesTableTable, StagesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StagesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    name,
    orderIndex,
    description,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stages_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<StagesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StagesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StagesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
    );
  }

  @override
  $StagesTableTable createAlias(String alias) {
    return $StagesTableTable(attachedDatabase, alias);
  }
}

class StagesTableData extends DataClass implements Insertable<StagesTableData> {
  final String id;
  final String tripId;
  final String name;
  final int orderIndex;
  final String? description;
  const StagesTableData({
    required this.id,
    required this.tripId,
    required this.name,
    required this.orderIndex,
    this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['name'] = Variable<String>(name);
    map['order_index'] = Variable<int>(orderIndex);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  StagesTableCompanion toCompanion(bool nullToAbsent) {
    return StagesTableCompanion(
      id: Value(id),
      tripId: Value(tripId),
      name: Value(name),
      orderIndex: Value(orderIndex),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory StagesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StagesTableData(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      name: serializer.fromJson<String>(json['name']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'name': serializer.toJson<String>(name),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'description': serializer.toJson<String?>(description),
    };
  }

  StagesTableData copyWith({
    String? id,
    String? tripId,
    String? name,
    int? orderIndex,
    Value<String?> description = const Value.absent(),
  }) => StagesTableData(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    name: name ?? this.name,
    orderIndex: orderIndex ?? this.orderIndex,
    description: description.present ? description.value : this.description,
  );
  StagesTableData copyWithCompanion(StagesTableCompanion data) {
    return StagesTableData(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      name: data.name.present ? data.name.value : this.name,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StagesTableData(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('name: $name, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tripId, name, orderIndex, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StagesTableData &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.name == this.name &&
          other.orderIndex == this.orderIndex &&
          other.description == this.description);
}

class StagesTableCompanion extends UpdateCompanion<StagesTableData> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> name;
  final Value<int> orderIndex;
  final Value<String?> description;
  final Value<int> rowid;
  const StagesTableCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.name = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StagesTableCompanion.insert({
    required String id,
    required String tripId,
    required String name,
    required int orderIndex,
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       name = Value(name),
       orderIndex = Value(orderIndex);
  static Insertable<StagesTableData> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? name,
    Expression<int>? orderIndex,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (name != null) 'name': name,
      if (orderIndex != null) 'order_index': orderIndex,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StagesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? name,
    Value<int>? orderIndex,
    Value<String?>? description,
    Value<int>? rowid,
  }) {
    return StagesTableCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      orderIndex: orderIndex ?? this.orderIndex,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StagesTableCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('name: $name, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTableTable extends ExpensesTable
    with TableInfo<$ExpensesTableTable, ExpensesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stageIdMeta = const VerificationMeta(
    'stageId',
  );
  @override
  late final GeneratedColumn<String> stageId = GeneratedColumn<String>(
    'stage_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stageIdsJsonMeta = const VerificationMeta(
    'stageIdsJson',
  );
  @override
  late final GeneratedColumn<String> stageIdsJson = GeneratedColumn<String>(
    'stage_ids_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _calcModeMeta = const VerificationMeta(
    'calcMode',
  );
  @override
  late final GeneratedColumn<String> calcMode = GeneratedColumn<String>(
    'calc_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedTotalMeta = const VerificationMeta(
    'estimatedTotal',
  );
  @override
  late final GeneratedColumn<int> estimatedTotal = GeneratedColumn<int>(
    'estimated_total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<int> unitPrice = GeneratedColumn<int>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lineItemsJsonMeta = const VerificationMeta(
    'lineItemsJson',
  );
  @override
  late final GeneratedColumn<String> lineItemsJson = GeneratedColumn<String>(
    'line_items_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _shippingFeeMeta = const VerificationMeta(
    'shippingFee',
  );
  @override
  late final GeneratedColumn<int> shippingFee = GeneratedColumn<int>(
    'shipping_fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _discountFeeMeta = const VerificationMeta(
    'discountFee',
  );
  @override
  late final GeneratedColumn<int> discountFee = GeneratedColumn<int>(
    'discount_fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _shippingRuleMeta = const VerificationMeta(
    'shippingRule',
  );
  @override
  late final GeneratedColumn<String> shippingRule = GeneratedColumn<String>(
    'shipping_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('equalSplit'),
  );
  static const VerificationMeta _discountRuleMeta = const VerificationMeta(
    'discountRule',
  );
  @override
  late final GeneratedColumn<String> discountRule = GeneratedColumn<String>(
    'discount_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('proportionalToSubtotal'),
  );
  static const VerificationMeta _isCommittedMeta = const VerificationMeta(
    'isCommitted',
  );
  @override
  late final GeneratedColumn<bool> isCommitted = GeneratedColumn<bool>(
    'is_committed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_committed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _costBearersJsonMeta = const VerificationMeta(
    'costBearersJson',
  );
  @override
  late final GeneratedColumn<String> costBearersJson = GeneratedColumn<String>(
    'cost_bearers_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _actualPriceMeta = const VerificationMeta(
    'actualPrice',
  );
  @override
  late final GeneratedColumn<int> actualPrice = GeneratedColumn<int>(
    'actual_price',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    stageId,
    stageIdsJson,
    title,
    description,
    calcMode,
    estimatedTotal,
    unitPrice,
    lineItemsJson,
    shippingFee,
    discountFee,
    shippingRule,
    discountRule,
    isCommitted,
    costBearersJson,
    actualPrice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpensesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('stage_id')) {
      context.handle(
        _stageIdMeta,
        stageId.isAcceptableOrUnknown(data['stage_id']!, _stageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stageIdMeta);
    }
    if (data.containsKey('stage_ids_json')) {
      context.handle(
        _stageIdsJsonMeta,
        stageIdsJson.isAcceptableOrUnknown(
          data['stage_ids_json']!,
          _stageIdsJsonMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('calc_mode')) {
      context.handle(
        _calcModeMeta,
        calcMode.isAcceptableOrUnknown(data['calc_mode']!, _calcModeMeta),
      );
    } else if (isInserting) {
      context.missing(_calcModeMeta);
    }
    if (data.containsKey('estimated_total')) {
      context.handle(
        _estimatedTotalMeta,
        estimatedTotal.isAcceptableOrUnknown(
          data['estimated_total']!,
          _estimatedTotalMeta,
        ),
      );
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    }
    if (data.containsKey('line_items_json')) {
      context.handle(
        _lineItemsJsonMeta,
        lineItemsJson.isAcceptableOrUnknown(
          data['line_items_json']!,
          _lineItemsJsonMeta,
        ),
      );
    }
    if (data.containsKey('shipping_fee')) {
      context.handle(
        _shippingFeeMeta,
        shippingFee.isAcceptableOrUnknown(
          data['shipping_fee']!,
          _shippingFeeMeta,
        ),
      );
    }
    if (data.containsKey('discount_fee')) {
      context.handle(
        _discountFeeMeta,
        discountFee.isAcceptableOrUnknown(
          data['discount_fee']!,
          _discountFeeMeta,
        ),
      );
    }
    if (data.containsKey('shipping_rule')) {
      context.handle(
        _shippingRuleMeta,
        shippingRule.isAcceptableOrUnknown(
          data['shipping_rule']!,
          _shippingRuleMeta,
        ),
      );
    }
    if (data.containsKey('discount_rule')) {
      context.handle(
        _discountRuleMeta,
        discountRule.isAcceptableOrUnknown(
          data['discount_rule']!,
          _discountRuleMeta,
        ),
      );
    }
    if (data.containsKey('is_committed')) {
      context.handle(
        _isCommittedMeta,
        isCommitted.isAcceptableOrUnknown(
          data['is_committed']!,
          _isCommittedMeta,
        ),
      );
    }
    if (data.containsKey('cost_bearers_json')) {
      context.handle(
        _costBearersJsonMeta,
        costBearersJson.isAcceptableOrUnknown(
          data['cost_bearers_json']!,
          _costBearersJsonMeta,
        ),
      );
    }
    if (data.containsKey('actual_price')) {
      context.handle(
        _actualPriceMeta,
        actualPrice.isAcceptableOrUnknown(
          data['actual_price']!,
          _actualPriceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpensesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpensesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      stageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage_id'],
      )!,
      stageIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage_ids_json'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      calcMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calc_mode'],
      )!,
      estimatedTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_total'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price'],
      )!,
      lineItemsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}line_items_json'],
      )!,
      shippingFee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shipping_fee'],
      )!,
      discountFee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_fee'],
      )!,
      shippingRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shipping_rule'],
      )!,
      discountRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_rule'],
      )!,
      isCommitted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_committed'],
      )!,
      costBearersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cost_bearers_json'],
      )!,
      actualPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_price'],
      ),
    );
  }

  @override
  $ExpensesTableTable createAlias(String alias) {
    return $ExpensesTableTable(attachedDatabase, alias);
  }
}

class ExpensesTableData extends DataClass
    implements Insertable<ExpensesTableData> {
  final String id;
  final String tripId;
  final String stageId;
  final String stageIdsJson;
  final String title;
  final String? description;
  final String calcMode;
  final int estimatedTotal;
  final int unitPrice;
  final String lineItemsJson;
  final int shippingFee;
  final int discountFee;
  final String shippingRule;
  final String discountRule;
  final bool isCommitted;
  final String costBearersJson;
  final int? actualPrice;
  const ExpensesTableData({
    required this.id,
    required this.tripId,
    required this.stageId,
    required this.stageIdsJson,
    required this.title,
    this.description,
    required this.calcMode,
    required this.estimatedTotal,
    required this.unitPrice,
    required this.lineItemsJson,
    required this.shippingFee,
    required this.discountFee,
    required this.shippingRule,
    required this.discountRule,
    required this.isCommitted,
    required this.costBearersJson,
    this.actualPrice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['stage_id'] = Variable<String>(stageId);
    map['stage_ids_json'] = Variable<String>(stageIdsJson);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['calc_mode'] = Variable<String>(calcMode);
    map['estimated_total'] = Variable<int>(estimatedTotal);
    map['unit_price'] = Variable<int>(unitPrice);
    map['line_items_json'] = Variable<String>(lineItemsJson);
    map['shipping_fee'] = Variable<int>(shippingFee);
    map['discount_fee'] = Variable<int>(discountFee);
    map['shipping_rule'] = Variable<String>(shippingRule);
    map['discount_rule'] = Variable<String>(discountRule);
    map['is_committed'] = Variable<bool>(isCommitted);
    map['cost_bearers_json'] = Variable<String>(costBearersJson);
    if (!nullToAbsent || actualPrice != null) {
      map['actual_price'] = Variable<int>(actualPrice);
    }
    return map;
  }

  ExpensesTableCompanion toCompanion(bool nullToAbsent) {
    return ExpensesTableCompanion(
      id: Value(id),
      tripId: Value(tripId),
      stageId: Value(stageId),
      stageIdsJson: Value(stageIdsJson),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      calcMode: Value(calcMode),
      estimatedTotal: Value(estimatedTotal),
      unitPrice: Value(unitPrice),
      lineItemsJson: Value(lineItemsJson),
      shippingFee: Value(shippingFee),
      discountFee: Value(discountFee),
      shippingRule: Value(shippingRule),
      discountRule: Value(discountRule),
      isCommitted: Value(isCommitted),
      costBearersJson: Value(costBearersJson),
      actualPrice: actualPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(actualPrice),
    );
  }

  factory ExpensesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpensesTableData(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      stageId: serializer.fromJson<String>(json['stageId']),
      stageIdsJson: serializer.fromJson<String>(json['stageIdsJson']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      calcMode: serializer.fromJson<String>(json['calcMode']),
      estimatedTotal: serializer.fromJson<int>(json['estimatedTotal']),
      unitPrice: serializer.fromJson<int>(json['unitPrice']),
      lineItemsJson: serializer.fromJson<String>(json['lineItemsJson']),
      shippingFee: serializer.fromJson<int>(json['shippingFee']),
      discountFee: serializer.fromJson<int>(json['discountFee']),
      shippingRule: serializer.fromJson<String>(json['shippingRule']),
      discountRule: serializer.fromJson<String>(json['discountRule']),
      isCommitted: serializer.fromJson<bool>(json['isCommitted']),
      costBearersJson: serializer.fromJson<String>(json['costBearersJson']),
      actualPrice: serializer.fromJson<int?>(json['actualPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'stageId': serializer.toJson<String>(stageId),
      'stageIdsJson': serializer.toJson<String>(stageIdsJson),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'calcMode': serializer.toJson<String>(calcMode),
      'estimatedTotal': serializer.toJson<int>(estimatedTotal),
      'unitPrice': serializer.toJson<int>(unitPrice),
      'lineItemsJson': serializer.toJson<String>(lineItemsJson),
      'shippingFee': serializer.toJson<int>(shippingFee),
      'discountFee': serializer.toJson<int>(discountFee),
      'shippingRule': serializer.toJson<String>(shippingRule),
      'discountRule': serializer.toJson<String>(discountRule),
      'isCommitted': serializer.toJson<bool>(isCommitted),
      'costBearersJson': serializer.toJson<String>(costBearersJson),
      'actualPrice': serializer.toJson<int?>(actualPrice),
    };
  }

  ExpensesTableData copyWith({
    String? id,
    String? tripId,
    String? stageId,
    String? stageIdsJson,
    String? title,
    Value<String?> description = const Value.absent(),
    String? calcMode,
    int? estimatedTotal,
    int? unitPrice,
    String? lineItemsJson,
    int? shippingFee,
    int? discountFee,
    String? shippingRule,
    String? discountRule,
    bool? isCommitted,
    String? costBearersJson,
    Value<int?> actualPrice = const Value.absent(),
  }) => ExpensesTableData(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    stageId: stageId ?? this.stageId,
    stageIdsJson: stageIdsJson ?? this.stageIdsJson,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    calcMode: calcMode ?? this.calcMode,
    estimatedTotal: estimatedTotal ?? this.estimatedTotal,
    unitPrice: unitPrice ?? this.unitPrice,
    lineItemsJson: lineItemsJson ?? this.lineItemsJson,
    shippingFee: shippingFee ?? this.shippingFee,
    discountFee: discountFee ?? this.discountFee,
    shippingRule: shippingRule ?? this.shippingRule,
    discountRule: discountRule ?? this.discountRule,
    isCommitted: isCommitted ?? this.isCommitted,
    costBearersJson: costBearersJson ?? this.costBearersJson,
    actualPrice: actualPrice.present ? actualPrice.value : this.actualPrice,
  );
  ExpensesTableData copyWithCompanion(ExpensesTableCompanion data) {
    return ExpensesTableData(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      stageId: data.stageId.present ? data.stageId.value : this.stageId,
      stageIdsJson: data.stageIdsJson.present
          ? data.stageIdsJson.value
          : this.stageIdsJson,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      calcMode: data.calcMode.present ? data.calcMode.value : this.calcMode,
      estimatedTotal: data.estimatedTotal.present
          ? data.estimatedTotal.value
          : this.estimatedTotal,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      lineItemsJson: data.lineItemsJson.present
          ? data.lineItemsJson.value
          : this.lineItemsJson,
      shippingFee: data.shippingFee.present
          ? data.shippingFee.value
          : this.shippingFee,
      discountFee: data.discountFee.present
          ? data.discountFee.value
          : this.discountFee,
      shippingRule: data.shippingRule.present
          ? data.shippingRule.value
          : this.shippingRule,
      discountRule: data.discountRule.present
          ? data.discountRule.value
          : this.discountRule,
      isCommitted: data.isCommitted.present
          ? data.isCommitted.value
          : this.isCommitted,
      costBearersJson: data.costBearersJson.present
          ? data.costBearersJson.value
          : this.costBearersJson,
      actualPrice: data.actualPrice.present
          ? data.actualPrice.value
          : this.actualPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesTableData(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('stageId: $stageId, ')
          ..write('stageIdsJson: $stageIdsJson, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('calcMode: $calcMode, ')
          ..write('estimatedTotal: $estimatedTotal, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('lineItemsJson: $lineItemsJson, ')
          ..write('shippingFee: $shippingFee, ')
          ..write('discountFee: $discountFee, ')
          ..write('shippingRule: $shippingRule, ')
          ..write('discountRule: $discountRule, ')
          ..write('isCommitted: $isCommitted, ')
          ..write('costBearersJson: $costBearersJson, ')
          ..write('actualPrice: $actualPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    stageId,
    stageIdsJson,
    title,
    description,
    calcMode,
    estimatedTotal,
    unitPrice,
    lineItemsJson,
    shippingFee,
    discountFee,
    shippingRule,
    discountRule,
    isCommitted,
    costBearersJson,
    actualPrice,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpensesTableData &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.stageId == this.stageId &&
          other.stageIdsJson == this.stageIdsJson &&
          other.title == this.title &&
          other.description == this.description &&
          other.calcMode == this.calcMode &&
          other.estimatedTotal == this.estimatedTotal &&
          other.unitPrice == this.unitPrice &&
          other.lineItemsJson == this.lineItemsJson &&
          other.shippingFee == this.shippingFee &&
          other.discountFee == this.discountFee &&
          other.shippingRule == this.shippingRule &&
          other.discountRule == this.discountRule &&
          other.isCommitted == this.isCommitted &&
          other.costBearersJson == this.costBearersJson &&
          other.actualPrice == this.actualPrice);
}

class ExpensesTableCompanion extends UpdateCompanion<ExpensesTableData> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> stageId;
  final Value<String> stageIdsJson;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> calcMode;
  final Value<int> estimatedTotal;
  final Value<int> unitPrice;
  final Value<String> lineItemsJson;
  final Value<int> shippingFee;
  final Value<int> discountFee;
  final Value<String> shippingRule;
  final Value<String> discountRule;
  final Value<bool> isCommitted;
  final Value<String> costBearersJson;
  final Value<int?> actualPrice;
  final Value<int> rowid;
  const ExpensesTableCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.stageId = const Value.absent(),
    this.stageIdsJson = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.calcMode = const Value.absent(),
    this.estimatedTotal = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.lineItemsJson = const Value.absent(),
    this.shippingFee = const Value.absent(),
    this.discountFee = const Value.absent(),
    this.shippingRule = const Value.absent(),
    this.discountRule = const Value.absent(),
    this.isCommitted = const Value.absent(),
    this.costBearersJson = const Value.absent(),
    this.actualPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesTableCompanion.insert({
    required String id,
    required String tripId,
    required String stageId,
    this.stageIdsJson = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required String calcMode,
    this.estimatedTotal = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.lineItemsJson = const Value.absent(),
    this.shippingFee = const Value.absent(),
    this.discountFee = const Value.absent(),
    this.shippingRule = const Value.absent(),
    this.discountRule = const Value.absent(),
    this.isCommitted = const Value.absent(),
    this.costBearersJson = const Value.absent(),
    this.actualPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       stageId = Value(stageId),
       title = Value(title),
       calcMode = Value(calcMode);
  static Insertable<ExpensesTableData> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? stageId,
    Expression<String>? stageIdsJson,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? calcMode,
    Expression<int>? estimatedTotal,
    Expression<int>? unitPrice,
    Expression<String>? lineItemsJson,
    Expression<int>? shippingFee,
    Expression<int>? discountFee,
    Expression<String>? shippingRule,
    Expression<String>? discountRule,
    Expression<bool>? isCommitted,
    Expression<String>? costBearersJson,
    Expression<int>? actualPrice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (stageId != null) 'stage_id': stageId,
      if (stageIdsJson != null) 'stage_ids_json': stageIdsJson,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (calcMode != null) 'calc_mode': calcMode,
      if (estimatedTotal != null) 'estimated_total': estimatedTotal,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (lineItemsJson != null) 'line_items_json': lineItemsJson,
      if (shippingFee != null) 'shipping_fee': shippingFee,
      if (discountFee != null) 'discount_fee': discountFee,
      if (shippingRule != null) 'shipping_rule': shippingRule,
      if (discountRule != null) 'discount_rule': discountRule,
      if (isCommitted != null) 'is_committed': isCommitted,
      if (costBearersJson != null) 'cost_bearers_json': costBearersJson,
      if (actualPrice != null) 'actual_price': actualPrice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? stageId,
    Value<String>? stageIdsJson,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? calcMode,
    Value<int>? estimatedTotal,
    Value<int>? unitPrice,
    Value<String>? lineItemsJson,
    Value<int>? shippingFee,
    Value<int>? discountFee,
    Value<String>? shippingRule,
    Value<String>? discountRule,
    Value<bool>? isCommitted,
    Value<String>? costBearersJson,
    Value<int?>? actualPrice,
    Value<int>? rowid,
  }) {
    return ExpensesTableCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      stageId: stageId ?? this.stageId,
      stageIdsJson: stageIdsJson ?? this.stageIdsJson,
      title: title ?? this.title,
      description: description ?? this.description,
      calcMode: calcMode ?? this.calcMode,
      estimatedTotal: estimatedTotal ?? this.estimatedTotal,
      unitPrice: unitPrice ?? this.unitPrice,
      lineItemsJson: lineItemsJson ?? this.lineItemsJson,
      shippingFee: shippingFee ?? this.shippingFee,
      discountFee: discountFee ?? this.discountFee,
      shippingRule: shippingRule ?? this.shippingRule,
      discountRule: discountRule ?? this.discountRule,
      isCommitted: isCommitted ?? this.isCommitted,
      costBearersJson: costBearersJson ?? this.costBearersJson,
      actualPrice: actualPrice ?? this.actualPrice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (stageId.present) {
      map['stage_id'] = Variable<String>(stageId.value);
    }
    if (stageIdsJson.present) {
      map['stage_ids_json'] = Variable<String>(stageIdsJson.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (calcMode.present) {
      map['calc_mode'] = Variable<String>(calcMode.value);
    }
    if (estimatedTotal.present) {
      map['estimated_total'] = Variable<int>(estimatedTotal.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<int>(unitPrice.value);
    }
    if (lineItemsJson.present) {
      map['line_items_json'] = Variable<String>(lineItemsJson.value);
    }
    if (shippingFee.present) {
      map['shipping_fee'] = Variable<int>(shippingFee.value);
    }
    if (discountFee.present) {
      map['discount_fee'] = Variable<int>(discountFee.value);
    }
    if (shippingRule.present) {
      map['shipping_rule'] = Variable<String>(shippingRule.value);
    }
    if (discountRule.present) {
      map['discount_rule'] = Variable<String>(discountRule.value);
    }
    if (isCommitted.present) {
      map['is_committed'] = Variable<bool>(isCommitted.value);
    }
    if (costBearersJson.present) {
      map['cost_bearers_json'] = Variable<String>(costBearersJson.value);
    }
    if (actualPrice.present) {
      map['actual_price'] = Variable<int>(actualPrice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesTableCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('stageId: $stageId, ')
          ..write('stageIdsJson: $stageIdsJson, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('calcMode: $calcMode, ')
          ..write('estimatedTotal: $estimatedTotal, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('lineItemsJson: $lineItemsJson, ')
          ..write('shippingFee: $shippingFee, ')
          ..write('discountFee: $discountFee, ')
          ..write('shippingRule: $shippingRule, ')
          ..write('discountRule: $discountRule, ')
          ..write('isCommitted: $isCommitted, ')
          ..write('costBearersJson: $costBearersJson, ')
          ..write('actualPrice: $actualPrice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScenariosTableTable extends ScenariosTable
    with TableInfo<$ScenariosTableTable, ScenariosTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScenariosTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isBaselineMeta = const VerificationMeta(
    'isBaseline',
  );
  @override
  late final GeneratedColumn<bool> isBaseline = GeneratedColumn<bool>(
    'is_baseline',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_baseline" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _stageAttendancesJsonMeta =
      const VerificationMeta('stageAttendancesJson');
  @override
  late final GeneratedColumn<String> stageAttendancesJson =
      GeneratedColumn<String>(
        'stage_attendances_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _costBearerOverridesJsonMeta =
      const VerificationMeta('costBearerOverridesJson');
  @override
  late final GeneratedColumn<String> costBearerOverridesJson =
      GeneratedColumn<String>(
        'cost_bearer_overrides_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _expenseAmountOverridesJsonMeta =
      const VerificationMeta('expenseAmountOverridesJson');
  @override
  late final GeneratedColumn<String> expenseAmountOverridesJson =
      GeneratedColumn<String>(
        'expense_amount_overrides_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _isStaleMeta = const VerificationMeta(
    'isStale',
  );
  @override
  late final GeneratedColumn<bool> isStale = GeneratedColumn<bool>(
    'is_stale',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_stale" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    name,
    description,
    isBaseline,
    stageAttendancesJson,
    costBearerOverridesJson,
    expenseAmountOverridesJson,
    isStale,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scenarios_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScenariosTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_baseline')) {
      context.handle(
        _isBaselineMeta,
        isBaseline.isAcceptableOrUnknown(data['is_baseline']!, _isBaselineMeta),
      );
    }
    if (data.containsKey('stage_attendances_json')) {
      context.handle(
        _stageAttendancesJsonMeta,
        stageAttendancesJson.isAcceptableOrUnknown(
          data['stage_attendances_json']!,
          _stageAttendancesJsonMeta,
        ),
      );
    }
    if (data.containsKey('cost_bearer_overrides_json')) {
      context.handle(
        _costBearerOverridesJsonMeta,
        costBearerOverridesJson.isAcceptableOrUnknown(
          data['cost_bearer_overrides_json']!,
          _costBearerOverridesJsonMeta,
        ),
      );
    }
    if (data.containsKey('expense_amount_overrides_json')) {
      context.handle(
        _expenseAmountOverridesJsonMeta,
        expenseAmountOverridesJson.isAcceptableOrUnknown(
          data['expense_amount_overrides_json']!,
          _expenseAmountOverridesJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_stale')) {
      context.handle(
        _isStaleMeta,
        isStale.isAcceptableOrUnknown(data['is_stale']!, _isStaleMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScenariosTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScenariosTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isBaseline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_baseline'],
      )!,
      stageAttendancesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage_attendances_json'],
      )!,
      costBearerOverridesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cost_bearer_overrides_json'],
      )!,
      expenseAmountOverridesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_amount_overrides_json'],
      )!,
      isStale: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_stale'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $ScenariosTableTable createAlias(String alias) {
    return $ScenariosTableTable(attachedDatabase, alias);
  }
}

class ScenariosTableData extends DataClass
    implements Insertable<ScenariosTableData> {
  final String id;
  final String tripId;
  final String name;
  final String? description;
  final bool isBaseline;
  final String stageAttendancesJson;
  final String costBearerOverridesJson;
  final String expenseAmountOverridesJson;
  final bool isStale;
  final int revision;
  const ScenariosTableData({
    required this.id,
    required this.tripId,
    required this.name,
    this.description,
    required this.isBaseline,
    required this.stageAttendancesJson,
    required this.costBearerOverridesJson,
    required this.expenseAmountOverridesJson,
    required this.isStale,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_baseline'] = Variable<bool>(isBaseline);
    map['stage_attendances_json'] = Variable<String>(stageAttendancesJson);
    map['cost_bearer_overrides_json'] = Variable<String>(
      costBearerOverridesJson,
    );
    map['expense_amount_overrides_json'] = Variable<String>(
      expenseAmountOverridesJson,
    );
    map['is_stale'] = Variable<bool>(isStale);
    map['revision'] = Variable<int>(revision);
    return map;
  }

  ScenariosTableCompanion toCompanion(bool nullToAbsent) {
    return ScenariosTableCompanion(
      id: Value(id),
      tripId: Value(tripId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isBaseline: Value(isBaseline),
      stageAttendancesJson: Value(stageAttendancesJson),
      costBearerOverridesJson: Value(costBearerOverridesJson),
      expenseAmountOverridesJson: Value(expenseAmountOverridesJson),
      isStale: Value(isStale),
      revision: Value(revision),
    );
  }

  factory ScenariosTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScenariosTableData(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      isBaseline: serializer.fromJson<bool>(json['isBaseline']),
      stageAttendancesJson: serializer.fromJson<String>(
        json['stageAttendancesJson'],
      ),
      costBearerOverridesJson: serializer.fromJson<String>(
        json['costBearerOverridesJson'],
      ),
      expenseAmountOverridesJson: serializer.fromJson<String>(
        json['expenseAmountOverridesJson'],
      ),
      isStale: serializer.fromJson<bool>(json['isStale']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'isBaseline': serializer.toJson<bool>(isBaseline),
      'stageAttendancesJson': serializer.toJson<String>(stageAttendancesJson),
      'costBearerOverridesJson': serializer.toJson<String>(
        costBearerOverridesJson,
      ),
      'expenseAmountOverridesJson': serializer.toJson<String>(
        expenseAmountOverridesJson,
      ),
      'isStale': serializer.toJson<bool>(isStale),
      'revision': serializer.toJson<int>(revision),
    };
  }

  ScenariosTableData copyWith({
    String? id,
    String? tripId,
    String? name,
    Value<String?> description = const Value.absent(),
    bool? isBaseline,
    String? stageAttendancesJson,
    String? costBearerOverridesJson,
    String? expenseAmountOverridesJson,
    bool? isStale,
    int? revision,
  }) => ScenariosTableData(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    isBaseline: isBaseline ?? this.isBaseline,
    stageAttendancesJson: stageAttendancesJson ?? this.stageAttendancesJson,
    costBearerOverridesJson:
        costBearerOverridesJson ?? this.costBearerOverridesJson,
    expenseAmountOverridesJson:
        expenseAmountOverridesJson ?? this.expenseAmountOverridesJson,
    isStale: isStale ?? this.isStale,
    revision: revision ?? this.revision,
  );
  ScenariosTableData copyWithCompanion(ScenariosTableCompanion data) {
    return ScenariosTableData(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      isBaseline: data.isBaseline.present
          ? data.isBaseline.value
          : this.isBaseline,
      stageAttendancesJson: data.stageAttendancesJson.present
          ? data.stageAttendancesJson.value
          : this.stageAttendancesJson,
      costBearerOverridesJson: data.costBearerOverridesJson.present
          ? data.costBearerOverridesJson.value
          : this.costBearerOverridesJson,
      expenseAmountOverridesJson: data.expenseAmountOverridesJson.present
          ? data.expenseAmountOverridesJson.value
          : this.expenseAmountOverridesJson,
      isStale: data.isStale.present ? data.isStale.value : this.isStale,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScenariosTableData(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isBaseline: $isBaseline, ')
          ..write('stageAttendancesJson: $stageAttendancesJson, ')
          ..write('costBearerOverridesJson: $costBearerOverridesJson, ')
          ..write('expenseAmountOverridesJson: $expenseAmountOverridesJson, ')
          ..write('isStale: $isStale, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    name,
    description,
    isBaseline,
    stageAttendancesJson,
    costBearerOverridesJson,
    expenseAmountOverridesJson,
    isStale,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScenariosTableData &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.name == this.name &&
          other.description == this.description &&
          other.isBaseline == this.isBaseline &&
          other.stageAttendancesJson == this.stageAttendancesJson &&
          other.costBearerOverridesJson == this.costBearerOverridesJson &&
          other.expenseAmountOverridesJson == this.expenseAmountOverridesJson &&
          other.isStale == this.isStale &&
          other.revision == this.revision);
}

class ScenariosTableCompanion extends UpdateCompanion<ScenariosTableData> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> name;
  final Value<String?> description;
  final Value<bool> isBaseline;
  final Value<String> stageAttendancesJson;
  final Value<String> costBearerOverridesJson;
  final Value<String> expenseAmountOverridesJson;
  final Value<bool> isStale;
  final Value<int> revision;
  final Value<int> rowid;
  const ScenariosTableCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.isBaseline = const Value.absent(),
    this.stageAttendancesJson = const Value.absent(),
    this.costBearerOverridesJson = const Value.absent(),
    this.expenseAmountOverridesJson = const Value.absent(),
    this.isStale = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScenariosTableCompanion.insert({
    required String id,
    required String tripId,
    required String name,
    this.description = const Value.absent(),
    this.isBaseline = const Value.absent(),
    this.stageAttendancesJson = const Value.absent(),
    this.costBearerOverridesJson = const Value.absent(),
    this.expenseAmountOverridesJson = const Value.absent(),
    this.isStale = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       name = Value(name);
  static Insertable<ScenariosTableData> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<bool>? isBaseline,
    Expression<String>? stageAttendancesJson,
    Expression<String>? costBearerOverridesJson,
    Expression<String>? expenseAmountOverridesJson,
    Expression<bool>? isStale,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isBaseline != null) 'is_baseline': isBaseline,
      if (stageAttendancesJson != null)
        'stage_attendances_json': stageAttendancesJson,
      if (costBearerOverridesJson != null)
        'cost_bearer_overrides_json': costBearerOverridesJson,
      if (expenseAmountOverridesJson != null)
        'expense_amount_overrides_json': expenseAmountOverridesJson,
      if (isStale != null) 'is_stale': isStale,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScenariosTableCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? name,
    Value<String?>? description,
    Value<bool>? isBaseline,
    Value<String>? stageAttendancesJson,
    Value<String>? costBearerOverridesJson,
    Value<String>? expenseAmountOverridesJson,
    Value<bool>? isStale,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return ScenariosTableCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      description: description ?? this.description,
      isBaseline: isBaseline ?? this.isBaseline,
      stageAttendancesJson: stageAttendancesJson ?? this.stageAttendancesJson,
      costBearerOverridesJson:
          costBearerOverridesJson ?? this.costBearerOverridesJson,
      expenseAmountOverridesJson:
          expenseAmountOverridesJson ?? this.expenseAmountOverridesJson,
      isStale: isStale ?? this.isStale,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isBaseline.present) {
      map['is_baseline'] = Variable<bool>(isBaseline.value);
    }
    if (stageAttendancesJson.present) {
      map['stage_attendances_json'] = Variable<String>(
        stageAttendancesJson.value,
      );
    }
    if (costBearerOverridesJson.present) {
      map['cost_bearer_overrides_json'] = Variable<String>(
        costBearerOverridesJson.value,
      );
    }
    if (expenseAmountOverridesJson.present) {
      map['expense_amount_overrides_json'] = Variable<String>(
        expenseAmountOverridesJson.value,
      );
    }
    if (isStale.present) {
      map['is_stale'] = Variable<bool>(isStale.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScenariosTableCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isBaseline: $isBaseline, ')
          ..write('stageAttendancesJson: $stageAttendancesJson, ')
          ..write('costBearerOverridesJson: $costBearerOverridesJson, ')
          ..write('expenseAmountOverridesJson: $expenseAmountOverridesJson, ')
          ..write('isStale: $isStale, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashTransactionsTableTable extends CashTransactionsTable
    with TableInfo<$CashTransactionsTableTable, CashTransactionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashTransactionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expenseIdMeta = const VerificationMeta(
    'expenseId',
  );
  @override
  late final GeneratedColumn<String> expenseId = GeneratedColumn<String>(
    'expense_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payerMemberIdMeta = const VerificationMeta(
    'payerMemberId',
  );
  @override
  late final GeneratedColumn<String> payerMemberId = GeneratedColumn<String>(
    'payer_member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipientMeta = const VerificationMeta(
    'recipient',
  );
  @override
  late final GeneratedColumn<String> recipient = GeneratedColumn<String>(
    'recipient',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessKeyMeta = const VerificationMeta(
    'businessKey',
  );
  @override
  late final GeneratedColumn<String> businessKey = GeneratedColumn<String>(
    'business_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    expenseId,
    type,
    payerMemberId,
    recipient,
    amount,
    note,
    timestamp,
    businessKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_transactions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashTransactionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('expense_id')) {
      context.handle(
        _expenseIdMeta,
        expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('payer_member_id')) {
      context.handle(
        _payerMemberIdMeta,
        payerMemberId.isAcceptableOrUnknown(
          data['payer_member_id']!,
          _payerMemberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payerMemberIdMeta);
    }
    if (data.containsKey('recipient')) {
      context.handle(
        _recipientMeta,
        recipient.isAcceptableOrUnknown(data['recipient']!, _recipientMeta),
      );
    } else if (isInserting) {
      context.missing(_recipientMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('business_key')) {
      context.handle(
        _businessKeyMeta,
        businessKey.isAcceptableOrUnknown(
          data['business_key']!,
          _businessKeyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashTransactionsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashTransactionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      expenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      payerMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payer_member_id'],
      )!,
      recipient: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipient'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      businessKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}business_key'],
      ),
    );
  }

  @override
  $CashTransactionsTableTable createAlias(String alias) {
    return $CashTransactionsTableTable(attachedDatabase, alias);
  }
}

class CashTransactionsTableData extends DataClass
    implements Insertable<CashTransactionsTableData> {
  final String id;
  final String tripId;
  final String? expenseId;
  final String type;
  final String payerMemberId;
  final String recipient;
  final int amount;
  final String note;
  final DateTime timestamp;
  final String? businessKey;
  const CashTransactionsTableData({
    required this.id,
    required this.tripId,
    this.expenseId,
    required this.type,
    required this.payerMemberId,
    required this.recipient,
    required this.amount,
    required this.note,
    required this.timestamp,
    this.businessKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    if (!nullToAbsent || expenseId != null) {
      map['expense_id'] = Variable<String>(expenseId);
    }
    map['type'] = Variable<String>(type);
    map['payer_member_id'] = Variable<String>(payerMemberId);
    map['recipient'] = Variable<String>(recipient);
    map['amount'] = Variable<int>(amount);
    map['note'] = Variable<String>(note);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || businessKey != null) {
      map['business_key'] = Variable<String>(businessKey);
    }
    return map;
  }

  CashTransactionsTableCompanion toCompanion(bool nullToAbsent) {
    return CashTransactionsTableCompanion(
      id: Value(id),
      tripId: Value(tripId),
      expenseId: expenseId == null && nullToAbsent
          ? const Value.absent()
          : Value(expenseId),
      type: Value(type),
      payerMemberId: Value(payerMemberId),
      recipient: Value(recipient),
      amount: Value(amount),
      note: Value(note),
      timestamp: Value(timestamp),
      businessKey: businessKey == null && nullToAbsent
          ? const Value.absent()
          : Value(businessKey),
    );
  }

  factory CashTransactionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashTransactionsTableData(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      expenseId: serializer.fromJson<String?>(json['expenseId']),
      type: serializer.fromJson<String>(json['type']),
      payerMemberId: serializer.fromJson<String>(json['payerMemberId']),
      recipient: serializer.fromJson<String>(json['recipient']),
      amount: serializer.fromJson<int>(json['amount']),
      note: serializer.fromJson<String>(json['note']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      businessKey: serializer.fromJson<String?>(json['businessKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'expenseId': serializer.toJson<String?>(expenseId),
      'type': serializer.toJson<String>(type),
      'payerMemberId': serializer.toJson<String>(payerMemberId),
      'recipient': serializer.toJson<String>(recipient),
      'amount': serializer.toJson<int>(amount),
      'note': serializer.toJson<String>(note),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'businessKey': serializer.toJson<String?>(businessKey),
    };
  }

  CashTransactionsTableData copyWith({
    String? id,
    String? tripId,
    Value<String?> expenseId = const Value.absent(),
    String? type,
    String? payerMemberId,
    String? recipient,
    int? amount,
    String? note,
    DateTime? timestamp,
    Value<String?> businessKey = const Value.absent(),
  }) => CashTransactionsTableData(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    expenseId: expenseId.present ? expenseId.value : this.expenseId,
    type: type ?? this.type,
    payerMemberId: payerMemberId ?? this.payerMemberId,
    recipient: recipient ?? this.recipient,
    amount: amount ?? this.amount,
    note: note ?? this.note,
    timestamp: timestamp ?? this.timestamp,
    businessKey: businessKey.present ? businessKey.value : this.businessKey,
  );
  CashTransactionsTableData copyWithCompanion(
    CashTransactionsTableCompanion data,
  ) {
    return CashTransactionsTableData(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
      type: data.type.present ? data.type.value : this.type,
      payerMemberId: data.payerMemberId.present
          ? data.payerMemberId.value
          : this.payerMemberId,
      recipient: data.recipient.present ? data.recipient.value : this.recipient,
      amount: data.amount.present ? data.amount.value : this.amount,
      note: data.note.present ? data.note.value : this.note,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      businessKey: data.businessKey.present
          ? data.businessKey.value
          : this.businessKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashTransactionsTableData(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('expenseId: $expenseId, ')
          ..write('type: $type, ')
          ..write('payerMemberId: $payerMemberId, ')
          ..write('recipient: $recipient, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('timestamp: $timestamp, ')
          ..write('businessKey: $businessKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    expenseId,
    type,
    payerMemberId,
    recipient,
    amount,
    note,
    timestamp,
    businessKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashTransactionsTableData &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.expenseId == this.expenseId &&
          other.type == this.type &&
          other.payerMemberId == this.payerMemberId &&
          other.recipient == this.recipient &&
          other.amount == this.amount &&
          other.note == this.note &&
          other.timestamp == this.timestamp &&
          other.businessKey == this.businessKey);
}

class CashTransactionsTableCompanion
    extends UpdateCompanion<CashTransactionsTableData> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String?> expenseId;
  final Value<String> type;
  final Value<String> payerMemberId;
  final Value<String> recipient;
  final Value<int> amount;
  final Value<String> note;
  final Value<DateTime> timestamp;
  final Value<String?> businessKey;
  final Value<int> rowid;
  const CashTransactionsTableCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.type = const Value.absent(),
    this.payerMemberId = const Value.absent(),
    this.recipient = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.businessKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashTransactionsTableCompanion.insert({
    required String id,
    required String tripId,
    this.expenseId = const Value.absent(),
    required String type,
    required String payerMemberId,
    required String recipient,
    required int amount,
    this.note = const Value.absent(),
    required DateTime timestamp,
    this.businessKey = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       type = Value(type),
       payerMemberId = Value(payerMemberId),
       recipient = Value(recipient),
       amount = Value(amount),
       timestamp = Value(timestamp);
  static Insertable<CashTransactionsTableData> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? expenseId,
    Expression<String>? type,
    Expression<String>? payerMemberId,
    Expression<String>? recipient,
    Expression<int>? amount,
    Expression<String>? note,
    Expression<DateTime>? timestamp,
    Expression<String>? businessKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (expenseId != null) 'expense_id': expenseId,
      if (type != null) 'type': type,
      if (payerMemberId != null) 'payer_member_id': payerMemberId,
      if (recipient != null) 'recipient': recipient,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (timestamp != null) 'timestamp': timestamp,
      if (businessKey != null) 'business_key': businessKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashTransactionsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String?>? expenseId,
    Value<String>? type,
    Value<String>? payerMemberId,
    Value<String>? recipient,
    Value<int>? amount,
    Value<String>? note,
    Value<DateTime>? timestamp,
    Value<String?>? businessKey,
    Value<int>? rowid,
  }) {
    return CashTransactionsTableCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      expenseId: expenseId ?? this.expenseId,
      type: type ?? this.type,
      payerMemberId: payerMemberId ?? this.payerMemberId,
      recipient: recipient ?? this.recipient,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
      businessKey: businessKey ?? this.businessKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (expenseId.present) {
      map['expense_id'] = Variable<String>(expenseId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (payerMemberId.present) {
      map['payer_member_id'] = Variable<String>(payerMemberId.value);
    }
    if (recipient.present) {
      map['recipient'] = Variable<String>(recipient.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (businessKey.present) {
      map['business_key'] = Variable<String>(businessKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashTransactionsTableCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('expenseId: $expenseId, ')
          ..write('type: $type, ')
          ..write('payerMemberId: $payerMemberId, ')
          ..write('recipient: $recipient, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('timestamp: $timestamp, ')
          ..write('businessKey: $businessKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActualBooksTableTable extends ActualBooksTable
    with TableInfo<$ActualBooksTableTable, ActualBooksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActualBooksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceScenarioIdMeta = const VerificationMeta(
    'sourceScenarioId',
  );
  @override
  late final GeneratedColumn<String> sourceScenarioId = GeneratedColumn<String>(
    'source_scenario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snapshotJsonMeta = const VerificationMeta(
    'snapshotJson',
  );
  @override
  late final GeneratedColumn<String> snapshotJson = GeneratedColumn<String>(
    'snapshot_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSettledMeta = const VerificationMeta(
    'isSettled',
  );
  @override
  late final GeneratedColumn<bool> isSettled = GeneratedColumn<bool>(
    'is_settled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_settled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    sourceScenarioId,
    snapshotJson,
    isSettled,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'actual_books_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActualBooksTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('source_scenario_id')) {
      context.handle(
        _sourceScenarioIdMeta,
        sourceScenarioId.isAcceptableOrUnknown(
          data['source_scenario_id']!,
          _sourceScenarioIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceScenarioIdMeta);
    }
    if (data.containsKey('snapshot_json')) {
      context.handle(
        _snapshotJsonMeta,
        snapshotJson.isAcceptableOrUnknown(
          data['snapshot_json']!,
          _snapshotJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_snapshotJsonMeta);
    }
    if (data.containsKey('is_settled')) {
      context.handle(
        _isSettledMeta,
        isSettled.isAcceptableOrUnknown(data['is_settled']!, _isSettledMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActualBooksTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActualBooksTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      sourceScenarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_scenario_id'],
      )!,
      snapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot_json'],
      )!,
      isSettled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_settled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ActualBooksTableTable createAlias(String alias) {
    return $ActualBooksTableTable(attachedDatabase, alias);
  }
}

class ActualBooksTableData extends DataClass
    implements Insertable<ActualBooksTableData> {
  final String id;
  final String tripId;
  final String sourceScenarioId;
  final String snapshotJson;
  final bool isSettled;
  final DateTime createdAt;
  const ActualBooksTableData({
    required this.id,
    required this.tripId,
    required this.sourceScenarioId,
    required this.snapshotJson,
    required this.isSettled,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['source_scenario_id'] = Variable<String>(sourceScenarioId);
    map['snapshot_json'] = Variable<String>(snapshotJson);
    map['is_settled'] = Variable<bool>(isSettled);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ActualBooksTableCompanion toCompanion(bool nullToAbsent) {
    return ActualBooksTableCompanion(
      id: Value(id),
      tripId: Value(tripId),
      sourceScenarioId: Value(sourceScenarioId),
      snapshotJson: Value(snapshotJson),
      isSettled: Value(isSettled),
      createdAt: Value(createdAt),
    );
  }

  factory ActualBooksTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActualBooksTableData(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      sourceScenarioId: serializer.fromJson<String>(json['sourceScenarioId']),
      snapshotJson: serializer.fromJson<String>(json['snapshotJson']),
      isSettled: serializer.fromJson<bool>(json['isSettled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'sourceScenarioId': serializer.toJson<String>(sourceScenarioId),
      'snapshotJson': serializer.toJson<String>(snapshotJson),
      'isSettled': serializer.toJson<bool>(isSettled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ActualBooksTableData copyWith({
    String? id,
    String? tripId,
    String? sourceScenarioId,
    String? snapshotJson,
    bool? isSettled,
    DateTime? createdAt,
  }) => ActualBooksTableData(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    sourceScenarioId: sourceScenarioId ?? this.sourceScenarioId,
    snapshotJson: snapshotJson ?? this.snapshotJson,
    isSettled: isSettled ?? this.isSettled,
    createdAt: createdAt ?? this.createdAt,
  );
  ActualBooksTableData copyWithCompanion(ActualBooksTableCompanion data) {
    return ActualBooksTableData(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      sourceScenarioId: data.sourceScenarioId.present
          ? data.sourceScenarioId.value
          : this.sourceScenarioId,
      snapshotJson: data.snapshotJson.present
          ? data.snapshotJson.value
          : this.snapshotJson,
      isSettled: data.isSettled.present ? data.isSettled.value : this.isSettled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActualBooksTableData(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('sourceScenarioId: $sourceScenarioId, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('isSettled: $isSettled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    sourceScenarioId,
    snapshotJson,
    isSettled,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActualBooksTableData &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.sourceScenarioId == this.sourceScenarioId &&
          other.snapshotJson == this.snapshotJson &&
          other.isSettled == this.isSettled &&
          other.createdAt == this.createdAt);
}

class ActualBooksTableCompanion extends UpdateCompanion<ActualBooksTableData> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> sourceScenarioId;
  final Value<String> snapshotJson;
  final Value<bool> isSettled;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ActualBooksTableCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.sourceScenarioId = const Value.absent(),
    this.snapshotJson = const Value.absent(),
    this.isSettled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActualBooksTableCompanion.insert({
    required String id,
    required String tripId,
    required String sourceScenarioId,
    required String snapshotJson,
    this.isSettled = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       sourceScenarioId = Value(sourceScenarioId),
       snapshotJson = Value(snapshotJson),
       createdAt = Value(createdAt);
  static Insertable<ActualBooksTableData> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? sourceScenarioId,
    Expression<String>? snapshotJson,
    Expression<bool>? isSettled,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (sourceScenarioId != null) 'source_scenario_id': sourceScenarioId,
      if (snapshotJson != null) 'snapshot_json': snapshotJson,
      if (isSettled != null) 'is_settled': isSettled,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActualBooksTableCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? sourceScenarioId,
    Value<String>? snapshotJson,
    Value<bool>? isSettled,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ActualBooksTableCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      sourceScenarioId: sourceScenarioId ?? this.sourceScenarioId,
      snapshotJson: snapshotJson ?? this.snapshotJson,
      isSettled: isSettled ?? this.isSettled,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (sourceScenarioId.present) {
      map['source_scenario_id'] = Variable<String>(sourceScenarioId.value);
    }
    if (snapshotJson.present) {
      map['snapshot_json'] = Variable<String>(snapshotJson.value);
    }
    if (isSettled.present) {
      map['is_settled'] = Variable<bool>(isSettled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActualBooksTableCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('sourceScenarioId: $sourceScenarioId, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('isSettled: $isSettled, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TripsTableTable tripsTable = $TripsTableTable(this);
  late final $MembersTableTable membersTable = $MembersTableTable(this);
  late final $StagesTableTable stagesTable = $StagesTableTable(this);
  late final $ExpensesTableTable expensesTable = $ExpensesTableTable(this);
  late final $ScenariosTableTable scenariosTable = $ScenariosTableTable(this);
  late final $CashTransactionsTableTable cashTransactionsTable =
      $CashTransactionsTableTable(this);
  late final $ActualBooksTableTable actualBooksTable = $ActualBooksTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tripsTable,
    membersTable,
    stagesTable,
    expensesTable,
    scenariosTable,
    cashTransactionsTable,
    actualBooksTable,
  ];
}

typedef $$TripsTableTableCreateCompanionBuilder = TripsTableCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  required String treasurerId,
  required String activeScenarioId,
  Value<bool> isLedgerInitialized,
  Value<String?> ledgerScenarioId,
  Value<int> revision,
  Value<String> metadataJson,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$TripsTableTableUpdateCompanionBuilder = TripsTableCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String> treasurerId,
  Value<String> activeScenarioId,
  Value<bool> isLedgerInitialized,
  Value<String?> ledgerScenarioId,
  Value<int> revision,
  Value<String> metadataJson,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$TripsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TripsTableTable> {
  $$TripsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get treasurerId => $composableBuilder(
    column: $table.treasurerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeScenarioId => $composableBuilder(
    column: $table.activeScenarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLedgerInitialized => $composableBuilder(
    column: $table.isLedgerInitialized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ledgerScenarioId => $composableBuilder(
    column: $table.ledgerScenarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TripsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTableTable> {
  $$TripsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get treasurerId => $composableBuilder(
    column: $table.treasurerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeScenarioId => $composableBuilder(
    column: $table.activeScenarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLedgerInitialized => $composableBuilder(
    column: $table.isLedgerInitialized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ledgerScenarioId => $composableBuilder(
    column: $table.ledgerScenarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTableTable> {
  $$TripsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get treasurerId => $composableBuilder(
    column: $table.treasurerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeScenarioId => $composableBuilder(
    column: $table.activeScenarioId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isLedgerInitialized => $composableBuilder(
    column: $table.isLedgerInitialized,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ledgerScenarioId => $composableBuilder(
    column: $table.ledgerScenarioId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TripsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripsTableTable,
          TripsTableData,
          $$TripsTableTableFilterComposer,
          $$TripsTableTableOrderingComposer,
          $$TripsTableTableAnnotationComposer,
          $$TripsTableTableCreateCompanionBuilder,
          $$TripsTableTableUpdateCompanionBuilder,
          (
            TripsTableData,
            BaseReferences<_$AppDatabase, $TripsTableTable, TripsTableData>,
          ),
          TripsTableData,
          PrefetchHooks Function()
        > {
  $$TripsTableTableTableManager(_$AppDatabase db, $TripsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> treasurerId = const Value.absent(),
                Value<String> activeScenarioId = const Value.absent(),
                Value<bool> isLedgerInitialized = const Value.absent(),
                Value<String?> ledgerScenarioId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsTableCompanion(
                id: id,
                name: name,
                description: description,
                treasurerId: treasurerId,
                activeScenarioId: activeScenarioId,
                isLedgerInitialized: isLedgerInitialized,
                ledgerScenarioId: ledgerScenarioId,
                revision: revision,
                metadataJson: metadataJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                required String treasurerId,
                required String activeScenarioId,
                Value<bool> isLedgerInitialized = const Value.absent(),
                Value<String?> ledgerScenarioId = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> metadataJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsTableCompanion.insert(
                id: id,
                name: name,
                description: description,
                treasurerId: treasurerId,
                activeScenarioId: activeScenarioId,
                isLedgerInitialized: isLedgerInitialized,
                ledgerScenarioId: ledgerScenarioId,
                revision: revision,
                metadataJson: metadataJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TripsTableTable, TripsTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TripsTableTable,
                    TripsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TripsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripsTableTable,
      TripsTableData,
      $$TripsTableTableFilterComposer,
      $$TripsTableTableOrderingComposer,
      $$TripsTableTableAnnotationComposer,
      $$TripsTableTableCreateCompanionBuilder,
      $$TripsTableTableUpdateCompanionBuilder,
      (
        TripsTableData,
        BaseReferences<_$AppDatabase, $TripsTableTable, TripsTableData>,
      ),
      TripsTableData,
      PrefetchHooks Function()
    >;
typedef $$MembersTableTableCreateCompanionBuilder =
    MembersTableCompanion Function({
      required String id,
      required String tripId,
      required String name,
      Value<bool> isTreasurer,
      Value<bool> isActive,
      Value<int> orderIndex,
      Value<int> rowid,
    });
typedef $$MembersTableTableUpdateCompanionBuilder =
    MembersTableCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String> name,
      Value<bool> isTreasurer,
      Value<bool> isActive,
      Value<int> orderIndex,
      Value<int> rowid,
    });

class $$MembersTableTableFilterComposer
    extends Composer<_$AppDatabase, $MembersTableTable> {
  $$MembersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTreasurer => $composableBuilder(
    column: $table.isTreasurer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MembersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MembersTableTable> {
  $$MembersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTreasurer => $composableBuilder(
    column: $table.isTreasurer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MembersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembersTableTable> {
  $$MembersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isTreasurer => $composableBuilder(
    column: $table.isTreasurer,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );
}

class $$MembersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MembersTableTable,
          MembersTableData,
          $$MembersTableTableFilterComposer,
          $$MembersTableTableOrderingComposer,
          $$MembersTableTableAnnotationComposer,
          $$MembersTableTableCreateCompanionBuilder,
          $$MembersTableTableUpdateCompanionBuilder,
          (
            MembersTableData,
            BaseReferences<_$AppDatabase, $MembersTableTable, MembersTableData>,
          ),
          MembersTableData,
          PrefetchHooks Function()
        > {
  $$MembersTableTableTableManager(_$AppDatabase db, $MembersTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isTreasurer = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembersTableCompanion(
                id: id,
                tripId: tripId,
                name: name,
                isTreasurer: isTreasurer,
                isActive: isActive,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String name,
                Value<bool> isTreasurer = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembersTableCompanion.insert(
                id: id,
                tripId: tripId,
                name: name,
                isTreasurer: isTreasurer,
                isActive: isActive,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MembersTableTable, MembersTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MembersTableTable,
                    MembersTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MembersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MembersTableTable,
      MembersTableData,
      $$MembersTableTableFilterComposer,
      $$MembersTableTableOrderingComposer,
      $$MembersTableTableAnnotationComposer,
      $$MembersTableTableCreateCompanionBuilder,
      $$MembersTableTableUpdateCompanionBuilder,
      (
        MembersTableData,
        BaseReferences<_$AppDatabase, $MembersTableTable, MembersTableData>,
      ),
      MembersTableData,
      PrefetchHooks Function()
    >;
typedef $$StagesTableTableCreateCompanionBuilder =
    StagesTableCompanion Function({
      required String id,
      required String tripId,
      required String name,
      required int orderIndex,
      Value<String?> description,
      Value<int> rowid,
    });
typedef $$StagesTableTableUpdateCompanionBuilder =
    StagesTableCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String> name,
      Value<int> orderIndex,
      Value<String?> description,
      Value<int> rowid,
    });

class $$StagesTableTableFilterComposer
    extends Composer<_$AppDatabase, $StagesTableTable> {
  $$StagesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StagesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StagesTableTable> {
  $$StagesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StagesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StagesTableTable> {
  $$StagesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );
}

class $$StagesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StagesTableTable,
          StagesTableData,
          $$StagesTableTableFilterComposer,
          $$StagesTableTableOrderingComposer,
          $$StagesTableTableAnnotationComposer,
          $$StagesTableTableCreateCompanionBuilder,
          $$StagesTableTableUpdateCompanionBuilder,
          (
            StagesTableData,
            BaseReferences<_$AppDatabase, $StagesTableTable, StagesTableData>,
          ),
          StagesTableData,
          PrefetchHooks Function()
        > {
  $$StagesTableTableTableManager(_$AppDatabase db, $StagesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StagesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StagesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StagesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StagesTableCompanion(
                id: id,
                tripId: tripId,
                name: name,
                orderIndex: orderIndex,
                description: description,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String name,
                required int orderIndex,
                Value<String?> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StagesTableCompanion.insert(
                id: id,
                tripId: tripId,
                name: name,
                orderIndex: orderIndex,
                description: description,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StagesTableTable, StagesTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $StagesTableTable,
                    StagesTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StagesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StagesTableTable,
      StagesTableData,
      $$StagesTableTableFilterComposer,
      $$StagesTableTableOrderingComposer,
      $$StagesTableTableAnnotationComposer,
      $$StagesTableTableCreateCompanionBuilder,
      $$StagesTableTableUpdateCompanionBuilder,
      (
        StagesTableData,
        BaseReferences<_$AppDatabase, $StagesTableTable, StagesTableData>,
      ),
      StagesTableData,
      PrefetchHooks Function()
    >;
typedef $$ExpensesTableTableCreateCompanionBuilder =
    ExpensesTableCompanion Function({
      required String id,
      required String tripId,
      required String stageId,
      Value<String> stageIdsJson,
      required String title,
      Value<String?> description,
      required String calcMode,
      Value<int> estimatedTotal,
      Value<int> unitPrice,
      Value<String> lineItemsJson,
      Value<int> shippingFee,
      Value<int> discountFee,
      Value<String> shippingRule,
      Value<String> discountRule,
      Value<bool> isCommitted,
      Value<String> costBearersJson,
      Value<int?> actualPrice,
      Value<int> rowid,
    });
typedef $$ExpensesTableTableUpdateCompanionBuilder =
    ExpensesTableCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String> stageId,
      Value<String> stageIdsJson,
      Value<String> title,
      Value<String?> description,
      Value<String> calcMode,
      Value<int> estimatedTotal,
      Value<int> unitPrice,
      Value<String> lineItemsJson,
      Value<int> shippingFee,
      Value<int> discountFee,
      Value<String> shippingRule,
      Value<String> discountRule,
      Value<bool> isCommitted,
      Value<String> costBearersJson,
      Value<int?> actualPrice,
      Value<int> rowid,
    });

class $$ExpensesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stageId => $composableBuilder(
    column: $table.stageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stageIdsJson => $composableBuilder(
    column: $table.stageIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calcMode => $composableBuilder(
    column: $table.calcMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedTotal => $composableBuilder(
    column: $table.estimatedTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lineItemsJson => $composableBuilder(
    column: $table.lineItemsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shippingFee => $composableBuilder(
    column: $table.shippingFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountFee => $composableBuilder(
    column: $table.discountFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shippingRule => $composableBuilder(
    column: $table.shippingRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discountRule => $composableBuilder(
    column: $table.discountRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCommitted => $composableBuilder(
    column: $table.isCommitted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get costBearersJson => $composableBuilder(
    column: $table.costBearersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualPrice => $composableBuilder(
    column: $table.actualPrice,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpensesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stageId => $composableBuilder(
    column: $table.stageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stageIdsJson => $composableBuilder(
    column: $table.stageIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calcMode => $composableBuilder(
    column: $table.calcMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedTotal => $composableBuilder(
    column: $table.estimatedTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lineItemsJson => $composableBuilder(
    column: $table.lineItemsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shippingFee => $composableBuilder(
    column: $table.shippingFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountFee => $composableBuilder(
    column: $table.discountFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shippingRule => $composableBuilder(
    column: $table.shippingRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discountRule => $composableBuilder(
    column: $table.discountRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCommitted => $composableBuilder(
    column: $table.isCommitted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get costBearersJson => $composableBuilder(
    column: $table.costBearersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualPrice => $composableBuilder(
    column: $table.actualPrice,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpensesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get stageId =>
      $composableBuilder(column: $table.stageId, builder: (column) => column);

  GeneratedColumn<String> get stageIdsJson => $composableBuilder(
    column: $table.stageIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calcMode =>
      $composableBuilder(column: $table.calcMode, builder: (column) => column);

  GeneratedColumn<int> get estimatedTotal => $composableBuilder(
    column: $table.estimatedTotal,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<String> get lineItemsJson => $composableBuilder(
    column: $table.lineItemsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get shippingFee => $composableBuilder(
    column: $table.shippingFee,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountFee => $composableBuilder(
    column: $table.discountFee,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shippingRule => $composableBuilder(
    column: $table.shippingRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discountRule => $composableBuilder(
    column: $table.discountRule,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCommitted => $composableBuilder(
    column: $table.isCommitted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get costBearersJson => $composableBuilder(
    column: $table.costBearersJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualPrice => $composableBuilder(
    column: $table.actualPrice,
    builder: (column) => column,
  );
}

class $$ExpensesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTableTable,
          ExpensesTableData,
          $$ExpensesTableTableFilterComposer,
          $$ExpensesTableTableOrderingComposer,
          $$ExpensesTableTableAnnotationComposer,
          $$ExpensesTableTableCreateCompanionBuilder,
          $$ExpensesTableTableUpdateCompanionBuilder,
          (
            ExpensesTableData,
            BaseReferences<
              _$AppDatabase,
              $ExpensesTableTable,
              ExpensesTableData
            >,
          ),
          ExpensesTableData,
          PrefetchHooks Function()
        > {
  $$ExpensesTableTableTableManager(_$AppDatabase db, $ExpensesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> stageId = const Value.absent(),
                Value<String> stageIdsJson = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> calcMode = const Value.absent(),
                Value<int> estimatedTotal = const Value.absent(),
                Value<int> unitPrice = const Value.absent(),
                Value<String> lineItemsJson = const Value.absent(),
                Value<int> shippingFee = const Value.absent(),
                Value<int> discountFee = const Value.absent(),
                Value<String> shippingRule = const Value.absent(),
                Value<String> discountRule = const Value.absent(),
                Value<bool> isCommitted = const Value.absent(),
                Value<String> costBearersJson = const Value.absent(),
                Value<int?> actualPrice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesTableCompanion(
                id: id,
                tripId: tripId,
                stageId: stageId,
                stageIdsJson: stageIdsJson,
                title: title,
                description: description,
                calcMode: calcMode,
                estimatedTotal: estimatedTotal,
                unitPrice: unitPrice,
                lineItemsJson: lineItemsJson,
                shippingFee: shippingFee,
                discountFee: discountFee,
                shippingRule: shippingRule,
                discountRule: discountRule,
                isCommitted: isCommitted,
                costBearersJson: costBearersJson,
                actualPrice: actualPrice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String stageId,
                Value<String> stageIdsJson = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required String calcMode,
                Value<int> estimatedTotal = const Value.absent(),
                Value<int> unitPrice = const Value.absent(),
                Value<String> lineItemsJson = const Value.absent(),
                Value<int> shippingFee = const Value.absent(),
                Value<int> discountFee = const Value.absent(),
                Value<String> shippingRule = const Value.absent(),
                Value<String> discountRule = const Value.absent(),
                Value<bool> isCommitted = const Value.absent(),
                Value<String> costBearersJson = const Value.absent(),
                Value<int?> actualPrice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesTableCompanion.insert(
                id: id,
                tripId: tripId,
                stageId: stageId,
                stageIdsJson: stageIdsJson,
                title: title,
                description: description,
                calcMode: calcMode,
                estimatedTotal: estimatedTotal,
                unitPrice: unitPrice,
                lineItemsJson: lineItemsJson,
                shippingFee: shippingFee,
                discountFee: discountFee,
                shippingRule: shippingRule,
                discountRule: discountRule,
                isCommitted: isCommitted,
                costBearersJson: costBearersJson,
                actualPrice: actualPrice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpensesTableTable, ExpensesTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ExpensesTableTable,
                    ExpensesTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpensesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTableTable,
      ExpensesTableData,
      $$ExpensesTableTableFilterComposer,
      $$ExpensesTableTableOrderingComposer,
      $$ExpensesTableTableAnnotationComposer,
      $$ExpensesTableTableCreateCompanionBuilder,
      $$ExpensesTableTableUpdateCompanionBuilder,
      (
        ExpensesTableData,
        BaseReferences<_$AppDatabase, $ExpensesTableTable, ExpensesTableData>,
      ),
      ExpensesTableData,
      PrefetchHooks Function()
    >;
typedef $$ScenariosTableTableCreateCompanionBuilder =
    ScenariosTableCompanion Function({
      required String id,
      required String tripId,
      required String name,
      Value<String?> description,
      Value<bool> isBaseline,
      Value<String> stageAttendancesJson,
      Value<String> costBearerOverridesJson,
      Value<String> expenseAmountOverridesJson,
      Value<bool> isStale,
      Value<int> revision,
      Value<int> rowid,
    });
typedef $$ScenariosTableTableUpdateCompanionBuilder =
    ScenariosTableCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String> name,
      Value<String?> description,
      Value<bool> isBaseline,
      Value<String> stageAttendancesJson,
      Value<String> costBearerOverridesJson,
      Value<String> expenseAmountOverridesJson,
      Value<bool> isStale,
      Value<int> revision,
      Value<int> rowid,
    });

class $$ScenariosTableTableFilterComposer
    extends Composer<_$AppDatabase, $ScenariosTableTable> {
  $$ScenariosTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBaseline => $composableBuilder(
    column: $table.isBaseline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stageAttendancesJson => $composableBuilder(
    column: $table.stageAttendancesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get costBearerOverridesJson => $composableBuilder(
    column: $table.costBearerOverridesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expenseAmountOverridesJson => $composableBuilder(
    column: $table.expenseAmountOverridesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStale => $composableBuilder(
    column: $table.isStale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScenariosTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ScenariosTableTable> {
  $$ScenariosTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBaseline => $composableBuilder(
    column: $table.isBaseline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stageAttendancesJson => $composableBuilder(
    column: $table.stageAttendancesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get costBearerOverridesJson => $composableBuilder(
    column: $table.costBearerOverridesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expenseAmountOverridesJson => $composableBuilder(
    column: $table.expenseAmountOverridesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStale => $composableBuilder(
    column: $table.isStale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScenariosTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScenariosTableTable> {
  $$ScenariosTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBaseline => $composableBuilder(
    column: $table.isBaseline,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stageAttendancesJson => $composableBuilder(
    column: $table.stageAttendancesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get costBearerOverridesJson => $composableBuilder(
    column: $table.costBearerOverridesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get expenseAmountOverridesJson => $composableBuilder(
    column: $table.expenseAmountOverridesJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isStale =>
      $composableBuilder(column: $table.isStale, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$ScenariosTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScenariosTableTable,
          ScenariosTableData,
          $$ScenariosTableTableFilterComposer,
          $$ScenariosTableTableOrderingComposer,
          $$ScenariosTableTableAnnotationComposer,
          $$ScenariosTableTableCreateCompanionBuilder,
          $$ScenariosTableTableUpdateCompanionBuilder,
          (
            ScenariosTableData,
            BaseReferences<
              _$AppDatabase,
              $ScenariosTableTable,
              ScenariosTableData
            >,
          ),
          ScenariosTableData,
          PrefetchHooks Function()
        > {
  $$ScenariosTableTableTableManager(
    _$AppDatabase db,
    $ScenariosTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScenariosTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScenariosTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScenariosTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isBaseline = const Value.absent(),
                Value<String> stageAttendancesJson = const Value.absent(),
                Value<String> costBearerOverridesJson = const Value.absent(),
                Value<String> expenseAmountOverridesJson = const Value.absent(),
                Value<bool> isStale = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScenariosTableCompanion(
                id: id,
                tripId: tripId,
                name: name,
                description: description,
                isBaseline: isBaseline,
                stageAttendancesJson: stageAttendancesJson,
                costBearerOverridesJson: costBearerOverridesJson,
                expenseAmountOverridesJson: expenseAmountOverridesJson,
                isStale: isStale,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<bool> isBaseline = const Value.absent(),
                Value<String> stageAttendancesJson = const Value.absent(),
                Value<String> costBearerOverridesJson = const Value.absent(),
                Value<String> expenseAmountOverridesJson = const Value.absent(),
                Value<bool> isStale = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScenariosTableCompanion.insert(
                id: id,
                tripId: tripId,
                name: name,
                description: description,
                isBaseline: isBaseline,
                stageAttendancesJson: stageAttendancesJson,
                costBearerOverridesJson: costBearerOverridesJson,
                expenseAmountOverridesJson: expenseAmountOverridesJson,
                isStale: isStale,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScenariosTableTable, ScenariosTableData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ScenariosTableTable,
                    ScenariosTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScenariosTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScenariosTableTable,
      ScenariosTableData,
      $$ScenariosTableTableFilterComposer,
      $$ScenariosTableTableOrderingComposer,
      $$ScenariosTableTableAnnotationComposer,
      $$ScenariosTableTableCreateCompanionBuilder,
      $$ScenariosTableTableUpdateCompanionBuilder,
      (
        ScenariosTableData,
        BaseReferences<_$AppDatabase, $ScenariosTableTable, ScenariosTableData>,
      ),
      ScenariosTableData,
      PrefetchHooks Function()
    >;
typedef $$CashTransactionsTableTableCreateCompanionBuilder =
    CashTransactionsTableCompanion Function({
      required String id,
      required String tripId,
      Value<String?> expenseId,
      required String type,
      required String payerMemberId,
      required String recipient,
      required int amount,
      Value<String> note,
      required DateTime timestamp,
      Value<String?> businessKey,
      Value<int> rowid,
    });
typedef $$CashTransactionsTableTableUpdateCompanionBuilder =
    CashTransactionsTableCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String?> expenseId,
      Value<String> type,
      Value<String> payerMemberId,
      Value<String> recipient,
      Value<int> amount,
      Value<String> note,
      Value<DateTime> timestamp,
      Value<String?> businessKey,
      Value<int> rowid,
    });

class $$CashTransactionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CashTransactionsTableTable> {
  $$CashTransactionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expenseId => $composableBuilder(
    column: $table.expenseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payerMemberId => $composableBuilder(
    column: $table.payerMemberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipient => $composableBuilder(
    column: $table.recipient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get businessKey => $composableBuilder(
    column: $table.businessKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashTransactionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CashTransactionsTableTable> {
  $$CashTransactionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expenseId => $composableBuilder(
    column: $table.expenseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payerMemberId => $composableBuilder(
    column: $table.payerMemberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipient => $composableBuilder(
    column: $table.recipient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get businessKey => $composableBuilder(
    column: $table.businessKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashTransactionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashTransactionsTableTable> {
  $$CashTransactionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get expenseId =>
      $composableBuilder(column: $table.expenseId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get payerMemberId => $composableBuilder(
    column: $table.payerMemberId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recipient =>
      $composableBuilder(column: $table.recipient, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get businessKey => $composableBuilder(
    column: $table.businessKey,
    builder: (column) => column,
  );
}

class $$CashTransactionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashTransactionsTableTable,
          CashTransactionsTableData,
          $$CashTransactionsTableTableFilterComposer,
          $$CashTransactionsTableTableOrderingComposer,
          $$CashTransactionsTableTableAnnotationComposer,
          $$CashTransactionsTableTableCreateCompanionBuilder,
          $$CashTransactionsTableTableUpdateCompanionBuilder,
          (
            CashTransactionsTableData,
            BaseReferences<
              _$AppDatabase,
              $CashTransactionsTableTable,
              CashTransactionsTableData
            >,
          ),
          CashTransactionsTableData,
          PrefetchHooks Function()
        > {
  $$CashTransactionsTableTableTableManager(
    _$AppDatabase db,
    $CashTransactionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashTransactionsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CashTransactionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CashTransactionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String?> expenseId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> payerMemberId = const Value.absent(),
                Value<String> recipient = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> businessKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashTransactionsTableCompanion(
                id: id,
                tripId: tripId,
                expenseId: expenseId,
                type: type,
                payerMemberId: payerMemberId,
                recipient: recipient,
                amount: amount,
                note: note,
                timestamp: timestamp,
                businessKey: businessKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                Value<String?> expenseId = const Value.absent(),
                required String type,
                required String payerMemberId,
                required String recipient,
                required int amount,
                Value<String> note = const Value.absent(),
                required DateTime timestamp,
                Value<String?> businessKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashTransactionsTableCompanion.insert(
                id: id,
                tripId: tripId,
                expenseId: expenseId,
                type: type,
                payerMemberId: payerMemberId,
                recipient: recipient,
                amount: amount,
                note: note,
                timestamp: timestamp,
                businessKey: businessKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $CashTransactionsTableTable,
                    CashTransactionsTableData
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CashTransactionsTableTable,
                    CashTransactionsTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CashTransactionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashTransactionsTableTable,
      CashTransactionsTableData,
      $$CashTransactionsTableTableFilterComposer,
      $$CashTransactionsTableTableOrderingComposer,
      $$CashTransactionsTableTableAnnotationComposer,
      $$CashTransactionsTableTableCreateCompanionBuilder,
      $$CashTransactionsTableTableUpdateCompanionBuilder,
      (
        CashTransactionsTableData,
        BaseReferences<
          _$AppDatabase,
          $CashTransactionsTableTable,
          CashTransactionsTableData
        >,
      ),
      CashTransactionsTableData,
      PrefetchHooks Function()
    >;
typedef $$ActualBooksTableTableCreateCompanionBuilder =
    ActualBooksTableCompanion Function({
      required String id,
      required String tripId,
      required String sourceScenarioId,
      required String snapshotJson,
      Value<bool> isSettled,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ActualBooksTableTableUpdateCompanionBuilder =
    ActualBooksTableCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String> sourceScenarioId,
      Value<String> snapshotJson,
      Value<bool> isSettled,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ActualBooksTableTableFilterComposer
    extends Composer<_$AppDatabase, $ActualBooksTableTable> {
  $$ActualBooksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceScenarioId => $composableBuilder(
    column: $table.sourceScenarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSettled => $composableBuilder(
    column: $table.isSettled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActualBooksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ActualBooksTableTable> {
  $$ActualBooksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceScenarioId => $composableBuilder(
    column: $table.sourceScenarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSettled => $composableBuilder(
    column: $table.isSettled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActualBooksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActualBooksTableTable> {
  $$ActualBooksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get sourceScenarioId => $composableBuilder(
    column: $table.sourceScenarioId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSettled =>
      $composableBuilder(column: $table.isSettled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ActualBooksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActualBooksTableTable,
          ActualBooksTableData,
          $$ActualBooksTableTableFilterComposer,
          $$ActualBooksTableTableOrderingComposer,
          $$ActualBooksTableTableAnnotationComposer,
          $$ActualBooksTableTableCreateCompanionBuilder,
          $$ActualBooksTableTableUpdateCompanionBuilder,
          (
            ActualBooksTableData,
            BaseReferences<
              _$AppDatabase,
              $ActualBooksTableTable,
              ActualBooksTableData
            >,
          ),
          ActualBooksTableData,
          PrefetchHooks Function()
        > {
  $$ActualBooksTableTableTableManager(
    _$AppDatabase db,
    $ActualBooksTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActualBooksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActualBooksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActualBooksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> sourceScenarioId = const Value.absent(),
                Value<String> snapshotJson = const Value.absent(),
                Value<bool> isSettled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActualBooksTableCompanion(
                id: id,
                tripId: tripId,
                sourceScenarioId: sourceScenarioId,
                snapshotJson: snapshotJson,
                isSettled: isSettled,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String sourceScenarioId,
                required String snapshotJson,
                Value<bool> isSettled = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ActualBooksTableCompanion.insert(
                id: id,
                tripId: tripId,
                sourceScenarioId: sourceScenarioId,
                snapshotJson: snapshotJson,
                isSettled: isSettled,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActualBooksTableTable, ActualBooksTableData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $ActualBooksTableTable,
                    ActualBooksTableData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActualBooksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActualBooksTableTable,
      ActualBooksTableData,
      $$ActualBooksTableTableFilterComposer,
      $$ActualBooksTableTableOrderingComposer,
      $$ActualBooksTableTableAnnotationComposer,
      $$ActualBooksTableTableCreateCompanionBuilder,
      $$ActualBooksTableTableUpdateCompanionBuilder,
      (
        ActualBooksTableData,
        BaseReferences<
          _$AppDatabase,
          $ActualBooksTableTable,
          ActualBooksTableData
        >,
      ),
      ActualBooksTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TripsTableTableTableManager get tripsTable =>
      $$TripsTableTableTableManager(_db, _db.tripsTable);
  $$MembersTableTableTableManager get membersTable =>
      $$MembersTableTableTableManager(_db, _db.membersTable);
  $$StagesTableTableTableManager get stagesTable =>
      $$StagesTableTableTableManager(_db, _db.stagesTable);
  $$ExpensesTableTableTableManager get expensesTable =>
      $$ExpensesTableTableTableManager(_db, _db.expensesTable);
  $$ScenariosTableTableTableManager get scenariosTable =>
      $$ScenariosTableTableTableManager(_db, _db.scenariosTable);
  $$CashTransactionsTableTableTableManager get cashTransactionsTable =>
      $$CashTransactionsTableTableTableManager(_db, _db.cashTransactionsTable);
  $$ActualBooksTableTableTableManager get actualBooksTable =>
      $$ActualBooksTableTableTableManager(_db, _db.actualBooksTable);
}
