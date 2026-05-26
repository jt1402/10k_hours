// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PursuitsTable extends Pursuits
    with TableInfo<$PursuitsTable, PursuitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PursuitsTable(this.attachedDatabase, [this._alias]);
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accentColorMeta = const VerificationMeta(
    'accentColor',
  );
  @override
  late final GeneratedColumn<int> accentColor = GeneratedColumn<int>(
    'accent_color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetHoursMeta = const VerificationMeta(
    'targetHours',
  );
  @override
  late final GeneratedColumn<int> targetHours = GeneratedColumn<int>(
    'target_hours',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10000),
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
    name,
    accentColor,
    targetHours,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pursuits';
  @override
  VerificationContext validateIntegrity(
    Insertable<PursuitRow> instance, {
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
    if (data.containsKey('accent_color')) {
      context.handle(
        _accentColorMeta,
        accentColor.isAcceptableOrUnknown(
          data['accent_color']!,
          _accentColorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accentColorMeta);
    }
    if (data.containsKey('target_hours')) {
      context.handle(
        _targetHoursMeta,
        targetHours.isAcceptableOrUnknown(
          data['target_hours']!,
          _targetHoursMeta,
        ),
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
  PursuitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PursuitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      accentColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accent_color'],
      )!,
      targetHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_hours'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PursuitsTable createAlias(String alias) {
    return $PursuitsTable(attachedDatabase, alias);
  }
}

class PursuitRow extends DataClass implements Insertable<PursuitRow> {
  final int id;
  final String name;
  final int accentColor;
  final int targetHours;
  final DateTime createdAt;
  const PursuitRow({
    required this.id,
    required this.name,
    required this.accentColor,
    required this.targetHours,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['accent_color'] = Variable<int>(accentColor);
    map['target_hours'] = Variable<int>(targetHours);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PursuitsCompanion toCompanion(bool nullToAbsent) {
    return PursuitsCompanion(
      id: Value(id),
      name: Value(name),
      accentColor: Value(accentColor),
      targetHours: Value(targetHours),
      createdAt: Value(createdAt),
    );
  }

  factory PursuitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PursuitRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      accentColor: serializer.fromJson<int>(json['accentColor']),
      targetHours: serializer.fromJson<int>(json['targetHours']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'accentColor': serializer.toJson<int>(accentColor),
      'targetHours': serializer.toJson<int>(targetHours),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PursuitRow copyWith({
    int? id,
    String? name,
    int? accentColor,
    int? targetHours,
    DateTime? createdAt,
  }) => PursuitRow(
    id: id ?? this.id,
    name: name ?? this.name,
    accentColor: accentColor ?? this.accentColor,
    targetHours: targetHours ?? this.targetHours,
    createdAt: createdAt ?? this.createdAt,
  );
  PursuitRow copyWithCompanion(PursuitsCompanion data) {
    return PursuitRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      accentColor: data.accentColor.present
          ? data.accentColor.value
          : this.accentColor,
      targetHours: data.targetHours.present
          ? data.targetHours.value
          : this.targetHours,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PursuitRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accentColor: $accentColor, ')
          ..write('targetHours: $targetHours, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, accentColor, targetHours, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PursuitRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.accentColor == this.accentColor &&
          other.targetHours == this.targetHours &&
          other.createdAt == this.createdAt);
}

class PursuitsCompanion extends UpdateCompanion<PursuitRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> accentColor;
  final Value<int> targetHours;
  final Value<DateTime> createdAt;
  const PursuitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.accentColor = const Value.absent(),
    this.targetHours = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PursuitsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int accentColor,
    this.targetHours = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       accentColor = Value(accentColor),
       createdAt = Value(createdAt);
  static Insertable<PursuitRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? accentColor,
    Expression<int>? targetHours,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (accentColor != null) 'accent_color': accentColor,
      if (targetHours != null) 'target_hours': targetHours,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PursuitsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? accentColor,
    Value<int>? targetHours,
    Value<DateTime>? createdAt,
  }) {
    return PursuitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      accentColor: accentColor ?? this.accentColor,
      targetHours: targetHours ?? this.targetHours,
      createdAt: createdAt ?? this.createdAt,
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
    if (accentColor.present) {
      map['accent_color'] = Variable<int>(accentColor.value);
    }
    if (targetHours.present) {
      map['target_hours'] = Variable<int>(targetHours.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PursuitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('accentColor: $accentColor, ')
          ..write('targetHours: $targetHours, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _pursuitIdMeta = const VerificationMeta(
    'pursuitId',
  );
  @override
  late final GeneratedColumn<int> pursuitId = GeneratedColumn<int>(
    'pursuit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pursuits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pursuitId,
    startedAt,
    endedAt,
    durationMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pursuit_id')) {
      context.handle(
        _pursuitIdMeta,
        pursuitId.isAcceptableOrUnknown(data['pursuit_id']!, _pursuitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pursuitIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pursuitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pursuit_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final int id;
  final int pursuitId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationMs;
  const SessionRow({
    required this.id,
    required this.pursuitId,
    required this.startedAt,
    required this.endedAt,
    required this.durationMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pursuit_id'] = Variable<int>(pursuitId);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['ended_at'] = Variable<DateTime>(endedAt);
    map['duration_ms'] = Variable<int>(durationMs);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      pursuitId: Value(pursuitId),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
      durationMs: Value(durationMs),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<int>(json['id']),
      pursuitId: serializer.fromJson<int>(json['pursuitId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime>(json['endedAt']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pursuitId': serializer.toJson<int>(pursuitId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime>(endedAt),
      'durationMs': serializer.toJson<int>(durationMs),
    };
  }

  SessionRow copyWith({
    int? id,
    int? pursuitId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationMs,
  }) => SessionRow(
    id: id ?? this.id,
    pursuitId: pursuitId ?? this.pursuitId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    durationMs: durationMs ?? this.durationMs,
  );
  SessionRow copyWithCompanion(SessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      pursuitId: data.pursuitId.present ? data.pursuitId.value : this.pursuitId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('pursuitId: $pursuitId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMs: $durationMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, pursuitId, startedAt, endedAt, durationMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.pursuitId == this.pursuitId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationMs == this.durationMs);
}

class SessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<int> id;
  final Value<int> pursuitId;
  final Value<DateTime> startedAt;
  final Value<DateTime> endedAt;
  final Value<int> durationMs;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.pursuitId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required int pursuitId,
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationMs,
  }) : pursuitId = Value(pursuitId),
       startedAt = Value(startedAt),
       endedAt = Value(endedAt),
       durationMs = Value(durationMs);
  static Insertable<SessionRow> custom({
    Expression<int>? id,
    Expression<int>? pursuitId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? durationMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pursuitId != null) 'pursuit_id': pursuitId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationMs != null) 'duration_ms': durationMs,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? pursuitId,
    Value<DateTime>? startedAt,
    Value<DateTime>? endedAt,
    Value<int>? durationMs,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      pursuitId: pursuitId ?? this.pursuitId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMs: durationMs ?? this.durationMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pursuitId.present) {
      map['pursuit_id'] = Variable<int>(pursuitId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('pursuitId: $pursuitId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMs: $durationMs')
          ..write(')'))
        .toString();
  }
}

class $ActiveSessionTable extends ActiveSession
    with TableInfo<$ActiveSessionTable, ActiveSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActiveSessionTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _pursuitIdMeta = const VerificationMeta(
    'pursuitId',
  );
  @override
  late final GeneratedColumn<int> pursuitId = GeneratedColumn<int>(
    'pursuit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pursuits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pausedTotalMsMeta = const VerificationMeta(
    'pausedTotalMs',
  );
  @override
  late final GeneratedColumn<int> pausedTotalMs = GeneratedColumn<int>(
    'paused_total_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pauseStartedAtMeta = const VerificationMeta(
    'pauseStartedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pauseStartedAt =
      GeneratedColumn<DateTime>(
        'pause_started_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pursuitId,
    startedAt,
    pausedTotalMs,
    pauseStartedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'active_session';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActiveSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pursuit_id')) {
      context.handle(
        _pursuitIdMeta,
        pursuitId.isAcceptableOrUnknown(data['pursuit_id']!, _pursuitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pursuitIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('paused_total_ms')) {
      context.handle(
        _pausedTotalMsMeta,
        pausedTotalMs.isAcceptableOrUnknown(
          data['paused_total_ms']!,
          _pausedTotalMsMeta,
        ),
      );
    }
    if (data.containsKey('pause_started_at')) {
      context.handle(
        _pauseStartedAtMeta,
        pauseStartedAt.isAcceptableOrUnknown(
          data['pause_started_at']!,
          _pauseStartedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActiveSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActiveSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pursuitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pursuit_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      pausedTotalMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paused_total_ms'],
      )!,
      pauseStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pause_started_at'],
      ),
    );
  }

  @override
  $ActiveSessionTable createAlias(String alias) {
    return $ActiveSessionTable(attachedDatabase, alias);
  }
}

class ActiveSessionRow extends DataClass
    implements Insertable<ActiveSessionRow> {
  final int id;
  final int pursuitId;
  final DateTime startedAt;
  final int pausedTotalMs;
  final DateTime? pauseStartedAt;
  const ActiveSessionRow({
    required this.id,
    required this.pursuitId,
    required this.startedAt,
    required this.pausedTotalMs,
    this.pauseStartedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pursuit_id'] = Variable<int>(pursuitId);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['paused_total_ms'] = Variable<int>(pausedTotalMs);
    if (!nullToAbsent || pauseStartedAt != null) {
      map['pause_started_at'] = Variable<DateTime>(pauseStartedAt);
    }
    return map;
  }

  ActiveSessionCompanion toCompanion(bool nullToAbsent) {
    return ActiveSessionCompanion(
      id: Value(id),
      pursuitId: Value(pursuitId),
      startedAt: Value(startedAt),
      pausedTotalMs: Value(pausedTotalMs),
      pauseStartedAt: pauseStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pauseStartedAt),
    );
  }

  factory ActiveSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActiveSessionRow(
      id: serializer.fromJson<int>(json['id']),
      pursuitId: serializer.fromJson<int>(json['pursuitId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      pausedTotalMs: serializer.fromJson<int>(json['pausedTotalMs']),
      pauseStartedAt: serializer.fromJson<DateTime?>(json['pauseStartedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pursuitId': serializer.toJson<int>(pursuitId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'pausedTotalMs': serializer.toJson<int>(pausedTotalMs),
      'pauseStartedAt': serializer.toJson<DateTime?>(pauseStartedAt),
    };
  }

  ActiveSessionRow copyWith({
    int? id,
    int? pursuitId,
    DateTime? startedAt,
    int? pausedTotalMs,
    Value<DateTime?> pauseStartedAt = const Value.absent(),
  }) => ActiveSessionRow(
    id: id ?? this.id,
    pursuitId: pursuitId ?? this.pursuitId,
    startedAt: startedAt ?? this.startedAt,
    pausedTotalMs: pausedTotalMs ?? this.pausedTotalMs,
    pauseStartedAt: pauseStartedAt.present
        ? pauseStartedAt.value
        : this.pauseStartedAt,
  );
  ActiveSessionRow copyWithCompanion(ActiveSessionCompanion data) {
    return ActiveSessionRow(
      id: data.id.present ? data.id.value : this.id,
      pursuitId: data.pursuitId.present ? data.pursuitId.value : this.pursuitId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      pausedTotalMs: data.pausedTotalMs.present
          ? data.pausedTotalMs.value
          : this.pausedTotalMs,
      pauseStartedAt: data.pauseStartedAt.present
          ? data.pauseStartedAt.value
          : this.pauseStartedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActiveSessionRow(')
          ..write('id: $id, ')
          ..write('pursuitId: $pursuitId, ')
          ..write('startedAt: $startedAt, ')
          ..write('pausedTotalMs: $pausedTotalMs, ')
          ..write('pauseStartedAt: $pauseStartedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, pursuitId, startedAt, pausedTotalMs, pauseStartedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActiveSessionRow &&
          other.id == this.id &&
          other.pursuitId == this.pursuitId &&
          other.startedAt == this.startedAt &&
          other.pausedTotalMs == this.pausedTotalMs &&
          other.pauseStartedAt == this.pauseStartedAt);
}

class ActiveSessionCompanion extends UpdateCompanion<ActiveSessionRow> {
  final Value<int> id;
  final Value<int> pursuitId;
  final Value<DateTime> startedAt;
  final Value<int> pausedTotalMs;
  final Value<DateTime?> pauseStartedAt;
  const ActiveSessionCompanion({
    this.id = const Value.absent(),
    this.pursuitId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.pausedTotalMs = const Value.absent(),
    this.pauseStartedAt = const Value.absent(),
  });
  ActiveSessionCompanion.insert({
    this.id = const Value.absent(),
    required int pursuitId,
    required DateTime startedAt,
    this.pausedTotalMs = const Value.absent(),
    this.pauseStartedAt = const Value.absent(),
  }) : pursuitId = Value(pursuitId),
       startedAt = Value(startedAt);
  static Insertable<ActiveSessionRow> custom({
    Expression<int>? id,
    Expression<int>? pursuitId,
    Expression<DateTime>? startedAt,
    Expression<int>? pausedTotalMs,
    Expression<DateTime>? pauseStartedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pursuitId != null) 'pursuit_id': pursuitId,
      if (startedAt != null) 'started_at': startedAt,
      if (pausedTotalMs != null) 'paused_total_ms': pausedTotalMs,
      if (pauseStartedAt != null) 'pause_started_at': pauseStartedAt,
    });
  }

  ActiveSessionCompanion copyWith({
    Value<int>? id,
    Value<int>? pursuitId,
    Value<DateTime>? startedAt,
    Value<int>? pausedTotalMs,
    Value<DateTime?>? pauseStartedAt,
  }) {
    return ActiveSessionCompanion(
      id: id ?? this.id,
      pursuitId: pursuitId ?? this.pursuitId,
      startedAt: startedAt ?? this.startedAt,
      pausedTotalMs: pausedTotalMs ?? this.pausedTotalMs,
      pauseStartedAt: pauseStartedAt ?? this.pauseStartedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pursuitId.present) {
      map['pursuit_id'] = Variable<int>(pursuitId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (pausedTotalMs.present) {
      map['paused_total_ms'] = Variable<int>(pausedTotalMs.value);
    }
    if (pauseStartedAt.present) {
      map['pause_started_at'] = Variable<DateTime>(pauseStartedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActiveSessionCompanion(')
          ..write('id: $id, ')
          ..write('pursuitId: $pursuitId, ')
          ..write('startedAt: $startedAt, ')
          ..write('pausedTotalMs: $pausedTotalMs, ')
          ..write('pauseStartedAt: $pauseStartedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PursuitsTable pursuits = $PursuitsTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $ActiveSessionTable activeSession = $ActiveSessionTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pursuits,
    sessions,
    activeSession,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pursuits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sessions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pursuits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('active_session', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PursuitsTableCreateCompanionBuilder =
    PursuitsCompanion Function({
      Value<int> id,
      required String name,
      required int accentColor,
      Value<int> targetHours,
      required DateTime createdAt,
    });
typedef $$PursuitsTableUpdateCompanionBuilder =
    PursuitsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> accentColor,
      Value<int> targetHours,
      Value<DateTime> createdAt,
    });

final class $$PursuitsTableReferences
    extends BaseReferences<_$AppDatabase, $PursuitsTable, PursuitRow> {
  $$PursuitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionsTable, List<SessionRow>>
  _sessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: $_aliasNameGenerator(db.pursuits.id, db.sessions.pursuitId),
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.pursuitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ActiveSessionTable, List<ActiveSessionRow>>
  _activeSessionRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activeSession,
    aliasName: $_aliasNameGenerator(db.pursuits.id, db.activeSession.pursuitId),
  );

  $$ActiveSessionTableProcessedTableManager get activeSessionRefs {
    final manager = $$ActiveSessionTableTableManager(
      $_db,
      $_db.activeSession,
    ).filter((f) => f.pursuitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_activeSessionRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PursuitsTableFilterComposer
    extends Composer<_$AppDatabase, $PursuitsTable> {
  $$PursuitsTableFilterComposer({
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

  ColumnFilters<int> get accentColor => $composableBuilder(
    column: $table.accentColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetHours => $composableBuilder(
    column: $table.targetHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.pursuitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> activeSessionRefs(
    Expression<bool> Function($$ActiveSessionTableFilterComposer f) f,
  ) {
    final $$ActiveSessionTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activeSession,
      getReferencedColumn: (t) => t.pursuitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActiveSessionTableFilterComposer(
            $db: $db,
            $table: $db.activeSession,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PursuitsTableOrderingComposer
    extends Composer<_$AppDatabase, $PursuitsTable> {
  $$PursuitsTableOrderingComposer({
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

  ColumnOrderings<int> get accentColor => $composableBuilder(
    column: $table.accentColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetHours => $composableBuilder(
    column: $table.targetHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PursuitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PursuitsTable> {
  $$PursuitsTableAnnotationComposer({
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

  GeneratedColumn<int> get accentColor => $composableBuilder(
    column: $table.accentColor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetHours => $composableBuilder(
    column: $table.targetHours,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.pursuitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> activeSessionRefs<T extends Object>(
    Expression<T> Function($$ActiveSessionTableAnnotationComposer a) f,
  ) {
    final $$ActiveSessionTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activeSession,
      getReferencedColumn: (t) => t.pursuitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActiveSessionTableAnnotationComposer(
            $db: $db,
            $table: $db.activeSession,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PursuitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PursuitsTable,
          PursuitRow,
          $$PursuitsTableFilterComposer,
          $$PursuitsTableOrderingComposer,
          $$PursuitsTableAnnotationComposer,
          $$PursuitsTableCreateCompanionBuilder,
          $$PursuitsTableUpdateCompanionBuilder,
          (PursuitRow, $$PursuitsTableReferences),
          PursuitRow,
          PrefetchHooks Function({bool sessionsRefs, bool activeSessionRefs})
        > {
  $$PursuitsTableTableManager(_$AppDatabase db, $PursuitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PursuitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PursuitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PursuitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> accentColor = const Value.absent(),
                Value<int> targetHours = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PursuitsCompanion(
                id: id,
                name: name,
                accentColor: accentColor,
                targetHours: targetHours,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int accentColor,
                Value<int> targetHours = const Value.absent(),
                required DateTime createdAt,
              }) => PursuitsCompanion.insert(
                id: id,
                name: name,
                accentColor: accentColor,
                targetHours: targetHours,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PursuitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionsRefs = false, activeSessionRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sessionsRefs) db.sessions,
                    if (activeSessionRefs) db.activeSession,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sessionsRefs)
                        await $_getPrefetchedData<
                          PursuitRow,
                          $PursuitsTable,
                          SessionRow
                        >(
                          currentTable: table,
                          referencedTable: $$PursuitsTableReferences
                              ._sessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PursuitsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pursuitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (activeSessionRefs)
                        await $_getPrefetchedData<
                          PursuitRow,
                          $PursuitsTable,
                          ActiveSessionRow
                        >(
                          currentTable: table,
                          referencedTable: $$PursuitsTableReferences
                              ._activeSessionRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PursuitsTableReferences(
                                db,
                                table,
                                p0,
                              ).activeSessionRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pursuitId == item.id,
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

typedef $$PursuitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PursuitsTable,
      PursuitRow,
      $$PursuitsTableFilterComposer,
      $$PursuitsTableOrderingComposer,
      $$PursuitsTableAnnotationComposer,
      $$PursuitsTableCreateCompanionBuilder,
      $$PursuitsTableUpdateCompanionBuilder,
      (PursuitRow, $$PursuitsTableReferences),
      PursuitRow,
      PrefetchHooks Function({bool sessionsRefs, bool activeSessionRefs})
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      required int pursuitId,
      required DateTime startedAt,
      required DateTime endedAt,
      required int durationMs,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<int> pursuitId,
      Value<DateTime> startedAt,
      Value<DateTime> endedAt,
      Value<int> durationMs,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, SessionRow> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PursuitsTable _pursuitIdTable(_$AppDatabase db) => db.pursuits
      .createAlias($_aliasNameGenerator(db.sessions.pursuitId, db.pursuits.id));

  $$PursuitsTableProcessedTableManager get pursuitId {
    final $_column = $_itemColumn<int>('pursuit_id')!;

    final manager = $$PursuitsTableTableManager(
      $_db,
      $_db.pursuits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pursuitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  $$PursuitsTableFilterComposer get pursuitId {
    final $$PursuitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pursuitId,
      referencedTable: $db.pursuits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PursuitsTableFilterComposer(
            $db: $db,
            $table: $db.pursuits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$PursuitsTableOrderingComposer get pursuitId {
    final $$PursuitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pursuitId,
      referencedTable: $db.pursuits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PursuitsTableOrderingComposer(
            $db: $db,
            $table: $db.pursuits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  $$PursuitsTableAnnotationComposer get pursuitId {
    final $$PursuitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pursuitId,
      referencedTable: $db.pursuits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PursuitsTableAnnotationComposer(
            $db: $db,
            $table: $db.pursuits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          SessionRow,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (SessionRow, $$SessionsTableReferences),
          SessionRow,
          PrefetchHooks Function({bool pursuitId})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pursuitId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> endedAt = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                pursuitId: pursuitId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMs: durationMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pursuitId,
                required DateTime startedAt,
                required DateTime endedAt,
                required int durationMs,
              }) => SessionsCompanion.insert(
                id: id,
                pursuitId: pursuitId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMs: durationMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pursuitId = false}) {
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
                    if (pursuitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pursuitId,
                                referencedTable: $$SessionsTableReferences
                                    ._pursuitIdTable(db),
                                referencedColumn: $$SessionsTableReferences
                                    ._pursuitIdTable(db)
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

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      SessionRow,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (SessionRow, $$SessionsTableReferences),
      SessionRow,
      PrefetchHooks Function({bool pursuitId})
    >;
typedef $$ActiveSessionTableCreateCompanionBuilder =
    ActiveSessionCompanion Function({
      Value<int> id,
      required int pursuitId,
      required DateTime startedAt,
      Value<int> pausedTotalMs,
      Value<DateTime?> pauseStartedAt,
    });
typedef $$ActiveSessionTableUpdateCompanionBuilder =
    ActiveSessionCompanion Function({
      Value<int> id,
      Value<int> pursuitId,
      Value<DateTime> startedAt,
      Value<int> pausedTotalMs,
      Value<DateTime?> pauseStartedAt,
    });

final class $$ActiveSessionTableReferences
    extends
        BaseReferences<_$AppDatabase, $ActiveSessionTable, ActiveSessionRow> {
  $$ActiveSessionTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PursuitsTable _pursuitIdTable(_$AppDatabase db) =>
      db.pursuits.createAlias(
        $_aliasNameGenerator(db.activeSession.pursuitId, db.pursuits.id),
      );

  $$PursuitsTableProcessedTableManager get pursuitId {
    final $_column = $_itemColumn<int>('pursuit_id')!;

    final manager = $$PursuitsTableTableManager(
      $_db,
      $_db.pursuits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pursuitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActiveSessionTableFilterComposer
    extends Composer<_$AppDatabase, $ActiveSessionTable> {
  $$ActiveSessionTableFilterComposer({
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pausedTotalMs => $composableBuilder(
    column: $table.pausedTotalMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pauseStartedAt => $composableBuilder(
    column: $table.pauseStartedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PursuitsTableFilterComposer get pursuitId {
    final $$PursuitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pursuitId,
      referencedTable: $db.pursuits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PursuitsTableFilterComposer(
            $db: $db,
            $table: $db.pursuits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActiveSessionTableOrderingComposer
    extends Composer<_$AppDatabase, $ActiveSessionTable> {
  $$ActiveSessionTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pausedTotalMs => $composableBuilder(
    column: $table.pausedTotalMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pauseStartedAt => $composableBuilder(
    column: $table.pauseStartedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PursuitsTableOrderingComposer get pursuitId {
    final $$PursuitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pursuitId,
      referencedTable: $db.pursuits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PursuitsTableOrderingComposer(
            $db: $db,
            $table: $db.pursuits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActiveSessionTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActiveSessionTable> {
  $$ActiveSessionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get pausedTotalMs => $composableBuilder(
    column: $table.pausedTotalMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pauseStartedAt => $composableBuilder(
    column: $table.pauseStartedAt,
    builder: (column) => column,
  );

  $$PursuitsTableAnnotationComposer get pursuitId {
    final $$PursuitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pursuitId,
      referencedTable: $db.pursuits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PursuitsTableAnnotationComposer(
            $db: $db,
            $table: $db.pursuits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActiveSessionTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActiveSessionTable,
          ActiveSessionRow,
          $$ActiveSessionTableFilterComposer,
          $$ActiveSessionTableOrderingComposer,
          $$ActiveSessionTableAnnotationComposer,
          $$ActiveSessionTableCreateCompanionBuilder,
          $$ActiveSessionTableUpdateCompanionBuilder,
          (ActiveSessionRow, $$ActiveSessionTableReferences),
          ActiveSessionRow,
          PrefetchHooks Function({bool pursuitId})
        > {
  $$ActiveSessionTableTableManager(_$AppDatabase db, $ActiveSessionTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActiveSessionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActiveSessionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActiveSessionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pursuitId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<int> pausedTotalMs = const Value.absent(),
                Value<DateTime?> pauseStartedAt = const Value.absent(),
              }) => ActiveSessionCompanion(
                id: id,
                pursuitId: pursuitId,
                startedAt: startedAt,
                pausedTotalMs: pausedTotalMs,
                pauseStartedAt: pauseStartedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pursuitId,
                required DateTime startedAt,
                Value<int> pausedTotalMs = const Value.absent(),
                Value<DateTime?> pauseStartedAt = const Value.absent(),
              }) => ActiveSessionCompanion.insert(
                id: id,
                pursuitId: pursuitId,
                startedAt: startedAt,
                pausedTotalMs: pausedTotalMs,
                pauseStartedAt: pauseStartedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActiveSessionTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pursuitId = false}) {
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
                    if (pursuitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pursuitId,
                                referencedTable: $$ActiveSessionTableReferences
                                    ._pursuitIdTable(db),
                                referencedColumn: $$ActiveSessionTableReferences
                                    ._pursuitIdTable(db)
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

typedef $$ActiveSessionTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActiveSessionTable,
      ActiveSessionRow,
      $$ActiveSessionTableFilterComposer,
      $$ActiveSessionTableOrderingComposer,
      $$ActiveSessionTableAnnotationComposer,
      $$ActiveSessionTableCreateCompanionBuilder,
      $$ActiveSessionTableUpdateCompanionBuilder,
      (ActiveSessionRow, $$ActiveSessionTableReferences),
      ActiveSessionRow,
      PrefetchHooks Function({bool pursuitId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PursuitsTableTableManager get pursuits =>
      $$PursuitsTableTableManager(_db, _db.pursuits);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$ActiveSessionTableTableManager get activeSession =>
      $$ActiveSessionTableTableManager(_db, _db.activeSession);
}
