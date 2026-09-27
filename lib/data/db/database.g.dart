// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetSecMeta = const VerificationMeta(
    'targetSec',
  );
  @override
  late final GeneratedColumn<int> targetSec = GeneratedColumn<int>(
    'target_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _practicedSecMeta = const VerificationMeta(
    'practicedSec',
  );
  @override
  late final GeneratedColumn<int> practicedSec = GeneratedColumn<int>(
    'practiced_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detectionMeta = const VerificationMeta(
    'detection',
  );
  @override
  late final GeneratedColumn<String> detection = GeneratedColumn<String>(
    'detection',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('timer'),
  );
  static const VerificationMeta _audioOnMeta = const VerificationMeta(
    'audioOn',
  );
  @override
  late final GeneratedColumn<bool> audioOn = GeneratedColumn<bool>(
    'audio_on',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("audio_on" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _worryTextMeta = const VerificationMeta(
    'worryText',
  );
  @override
  late final GeneratedColumn<String> worryText = GeneratedColumn<String>(
    'worry_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _worryChipMeta = const VerificationMeta(
    'worryChip',
  );
  @override
  late final GeneratedColumn<String> worryChip = GeneratedColumn<String>(
    'worry_chip',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repeatFlagMeta = const VerificationMeta(
    'repeatFlag',
  );
  @override
  late final GeneratedColumn<bool> repeatFlag = GeneratedColumn<bool>(
    'repeat_flag',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("repeat_flag" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _safetyFlaggedMeta = const VerificationMeta(
    'safetyFlagged',
  );
  @override
  late final GeneratedColumn<bool> safetyFlagged = GeneratedColumn<bool>(
    'safety_flagged',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("safety_flagged" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _excludedJsonMeta = const VerificationMeta(
    'excludedJson',
  );
  @override
  late final GeneratedColumn<String> excludedJson = GeneratedColumn<String>(
    'excluded_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    endedAt,
    targetSec,
    practicedSec,
    outcome,
    detection,
    audioOn,
    worryText,
    worryChip,
    repeatFlag,
    safetyFlagged,
    localDate,
    isActive,
    excludedJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    }
    if (data.containsKey('target_sec')) {
      context.handle(
        _targetSecMeta,
        targetSec.isAcceptableOrUnknown(data['target_sec']!, _targetSecMeta),
      );
    } else if (isInserting) {
      context.missing(_targetSecMeta);
    }
    if (data.containsKey('practiced_sec')) {
      context.handle(
        _practicedSecMeta,
        practicedSec.isAcceptableOrUnknown(
          data['practiced_sec']!,
          _practicedSecMeta,
        ),
      );
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    }
    if (data.containsKey('detection')) {
      context.handle(
        _detectionMeta,
        detection.isAcceptableOrUnknown(data['detection']!, _detectionMeta),
      );
    }
    if (data.containsKey('audio_on')) {
      context.handle(
        _audioOnMeta,
        audioOn.isAcceptableOrUnknown(data['audio_on']!, _audioOnMeta),
      );
    }
    if (data.containsKey('worry_text')) {
      context.handle(
        _worryTextMeta,
        worryText.isAcceptableOrUnknown(data['worry_text']!, _worryTextMeta),
      );
    }
    if (data.containsKey('worry_chip')) {
      context.handle(
        _worryChipMeta,
        worryChip.isAcceptableOrUnknown(data['worry_chip']!, _worryChipMeta),
      );
    }
    if (data.containsKey('repeat_flag')) {
      context.handle(
        _repeatFlagMeta,
        repeatFlag.isAcceptableOrUnknown(data['repeat_flag']!, _repeatFlagMeta),
      );
    }
    if (data.containsKey('safety_flagged')) {
      context.handle(
        _safetyFlaggedMeta,
        safetyFlagged.isAcceptableOrUnknown(
          data['safety_flagged']!,
          _safetyFlaggedMeta,
        ),
      );
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('excluded_json')) {
      context.handle(
        _excludedJsonMeta,
        excludedJson.isAcceptableOrUnknown(
          data['excluded_json']!,
          _excludedJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      targetSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_sec'],
      )!,
      practicedSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}practiced_sec'],
      )!,
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      ),
      detection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detection'],
      )!,
      audioOn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}audio_on'],
      )!,
      worryText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}worry_text'],
      ),
      worryChip: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}worry_chip'],
      ),
      repeatFlag: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}repeat_flag'],
      )!,
      safetyFlagged: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}safety_flagged'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      excludedJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}excluded_json'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int targetSec;
  final int practicedSec;

  /// 'completed' | 'interrupted'. 진행 중이면 null.
  final String? outcome;

  /// 'timer' | 'sensorA' | 'sensorC'. 실제로 사용된 전략을 쓴다.
  final String detection;
  final bool audioOn;
  final String? worryText;
  final String? worryChip;
  final bool repeatFlag;
  final bool safetyFlagged;

  /// yyyy-MM-dd, startedAt 기준. 인정일 집계 키.
  final String localDate;

  /// 프로세스 강제 종료 대비. 매 전이마다 저장된다 (PRD 세션 타이머 설계).
  final bool isActive;

  /// 제외 구간(일시정지·유예·중단선택 체류) JSON 배열.
  final String excludedJson;
  const Session({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.targetSec,
    required this.practicedSec,
    this.outcome,
    required this.detection,
    required this.audioOn,
    this.worryText,
    this.worryChip,
    required this.repeatFlag,
    required this.safetyFlagged,
    required this.localDate,
    required this.isActive,
    required this.excludedJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['target_sec'] = Variable<int>(targetSec);
    map['practiced_sec'] = Variable<int>(practicedSec);
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<String>(outcome);
    }
    map['detection'] = Variable<String>(detection);
    map['audio_on'] = Variable<bool>(audioOn);
    if (!nullToAbsent || worryText != null) {
      map['worry_text'] = Variable<String>(worryText);
    }
    if (!nullToAbsent || worryChip != null) {
      map['worry_chip'] = Variable<String>(worryChip);
    }
    map['repeat_flag'] = Variable<bool>(repeatFlag);
    map['safety_flagged'] = Variable<bool>(safetyFlagged);
    map['local_date'] = Variable<String>(localDate);
    map['is_active'] = Variable<bool>(isActive);
    map['excluded_json'] = Variable<String>(excludedJson);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      targetSec: Value(targetSec),
      practicedSec: Value(practicedSec),
      outcome: outcome == null && nullToAbsent
          ? const Value.absent()
          : Value(outcome),
      detection: Value(detection),
      audioOn: Value(audioOn),
      worryText: worryText == null && nullToAbsent
          ? const Value.absent()
          : Value(worryText),
      worryChip: worryChip == null && nullToAbsent
          ? const Value.absent()
          : Value(worryChip),
      repeatFlag: Value(repeatFlag),
      safetyFlagged: Value(safetyFlagged),
      localDate: Value(localDate),
      isActive: Value(isActive),
      excludedJson: Value(excludedJson),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      targetSec: serializer.fromJson<int>(json['targetSec']),
      practicedSec: serializer.fromJson<int>(json['practicedSec']),
      outcome: serializer.fromJson<String?>(json['outcome']),
      detection: serializer.fromJson<String>(json['detection']),
      audioOn: serializer.fromJson<bool>(json['audioOn']),
      worryText: serializer.fromJson<String?>(json['worryText']),
      worryChip: serializer.fromJson<String?>(json['worryChip']),
      repeatFlag: serializer.fromJson<bool>(json['repeatFlag']),
      safetyFlagged: serializer.fromJson<bool>(json['safetyFlagged']),
      localDate: serializer.fromJson<String>(json['localDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      excludedJson: serializer.fromJson<String>(json['excludedJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'targetSec': serializer.toJson<int>(targetSec),
      'practicedSec': serializer.toJson<int>(practicedSec),
      'outcome': serializer.toJson<String?>(outcome),
      'detection': serializer.toJson<String>(detection),
      'audioOn': serializer.toJson<bool>(audioOn),
      'worryText': serializer.toJson<String?>(worryText),
      'worryChip': serializer.toJson<String?>(worryChip),
      'repeatFlag': serializer.toJson<bool>(repeatFlag),
      'safetyFlagged': serializer.toJson<bool>(safetyFlagged),
      'localDate': serializer.toJson<String>(localDate),
      'isActive': serializer.toJson<bool>(isActive),
      'excludedJson': serializer.toJson<String>(excludedJson),
    };
  }

  Session copyWith({
    int? id,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? targetSec,
    int? practicedSec,
    Value<String?> outcome = const Value.absent(),
    String? detection,
    bool? audioOn,
    Value<String?> worryText = const Value.absent(),
    Value<String?> worryChip = const Value.absent(),
    bool? repeatFlag,
    bool? safetyFlagged,
    String? localDate,
    bool? isActive,
    String? excludedJson,
  }) => Session(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    targetSec: targetSec ?? this.targetSec,
    practicedSec: practicedSec ?? this.practicedSec,
    outcome: outcome.present ? outcome.value : this.outcome,
    detection: detection ?? this.detection,
    audioOn: audioOn ?? this.audioOn,
    worryText: worryText.present ? worryText.value : this.worryText,
    worryChip: worryChip.present ? worryChip.value : this.worryChip,
    repeatFlag: repeatFlag ?? this.repeatFlag,
    safetyFlagged: safetyFlagged ?? this.safetyFlagged,
    localDate: localDate ?? this.localDate,
    isActive: isActive ?? this.isActive,
    excludedJson: excludedJson ?? this.excludedJson,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      targetSec: data.targetSec.present ? data.targetSec.value : this.targetSec,
      practicedSec: data.practicedSec.present
          ? data.practicedSec.value
          : this.practicedSec,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      detection: data.detection.present ? data.detection.value : this.detection,
      audioOn: data.audioOn.present ? data.audioOn.value : this.audioOn,
      worryText: data.worryText.present ? data.worryText.value : this.worryText,
      worryChip: data.worryChip.present ? data.worryChip.value : this.worryChip,
      repeatFlag: data.repeatFlag.present
          ? data.repeatFlag.value
          : this.repeatFlag,
      safetyFlagged: data.safetyFlagged.present
          ? data.safetyFlagged.value
          : this.safetyFlagged,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      excludedJson: data.excludedJson.present
          ? data.excludedJson.value
          : this.excludedJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('targetSec: $targetSec, ')
          ..write('practicedSec: $practicedSec, ')
          ..write('outcome: $outcome, ')
          ..write('detection: $detection, ')
          ..write('audioOn: $audioOn, ')
          ..write('worryText: $worryText, ')
          ..write('worryChip: $worryChip, ')
          ..write('repeatFlag: $repeatFlag, ')
          ..write('safetyFlagged: $safetyFlagged, ')
          ..write('localDate: $localDate, ')
          ..write('isActive: $isActive, ')
          ..write('excludedJson: $excludedJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    endedAt,
    targetSec,
    practicedSec,
    outcome,
    detection,
    audioOn,
    worryText,
    worryChip,
    repeatFlag,
    safetyFlagged,
    localDate,
    isActive,
    excludedJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.targetSec == this.targetSec &&
          other.practicedSec == this.practicedSec &&
          other.outcome == this.outcome &&
          other.detection == this.detection &&
          other.audioOn == this.audioOn &&
          other.worryText == this.worryText &&
          other.worryChip == this.worryChip &&
          other.repeatFlag == this.repeatFlag &&
          other.safetyFlagged == this.safetyFlagged &&
          other.localDate == this.localDate &&
          other.isActive == this.isActive &&
          other.excludedJson == this.excludedJson);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> targetSec;
  final Value<int> practicedSec;
  final Value<String?> outcome;
  final Value<String> detection;
  final Value<bool> audioOn;
  final Value<String?> worryText;
  final Value<String?> worryChip;
  final Value<bool> repeatFlag;
  final Value<bool> safetyFlagged;
  final Value<String> localDate;
  final Value<bool> isActive;
  final Value<String> excludedJson;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.targetSec = const Value.absent(),
    this.practicedSec = const Value.absent(),
    this.outcome = const Value.absent(),
    this.detection = const Value.absent(),
    this.audioOn = const Value.absent(),
    this.worryText = const Value.absent(),
    this.worryChip = const Value.absent(),
    this.repeatFlag = const Value.absent(),
    this.safetyFlagged = const Value.absent(),
    this.localDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.excludedJson = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    required int targetSec,
    this.practicedSec = const Value.absent(),
    this.outcome = const Value.absent(),
    this.detection = const Value.absent(),
    this.audioOn = const Value.absent(),
    this.worryText = const Value.absent(),
    this.worryChip = const Value.absent(),
    this.repeatFlag = const Value.absent(),
    this.safetyFlagged = const Value.absent(),
    required String localDate,
    this.isActive = const Value.absent(),
    this.excludedJson = const Value.absent(),
  }) : startedAt = Value(startedAt),
       targetSec = Value(targetSec),
       localDate = Value(localDate);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? targetSec,
    Expression<int>? practicedSec,
    Expression<String>? outcome,
    Expression<String>? detection,
    Expression<bool>? audioOn,
    Expression<String>? worryText,
    Expression<String>? worryChip,
    Expression<bool>? repeatFlag,
    Expression<bool>? safetyFlagged,
    Expression<String>? localDate,
    Expression<bool>? isActive,
    Expression<String>? excludedJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (targetSec != null) 'target_sec': targetSec,
      if (practicedSec != null) 'practiced_sec': practicedSec,
      if (outcome != null) 'outcome': outcome,
      if (detection != null) 'detection': detection,
      if (audioOn != null) 'audio_on': audioOn,
      if (worryText != null) 'worry_text': worryText,
      if (worryChip != null) 'worry_chip': worryChip,
      if (repeatFlag != null) 'repeat_flag': repeatFlag,
      if (safetyFlagged != null) 'safety_flagged': safetyFlagged,
      if (localDate != null) 'local_date': localDate,
      if (isActive != null) 'is_active': isActive,
      if (excludedJson != null) 'excluded_json': excludedJson,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? targetSec,
    Value<int>? practicedSec,
    Value<String?>? outcome,
    Value<String>? detection,
    Value<bool>? audioOn,
    Value<String?>? worryText,
    Value<String?>? worryChip,
    Value<bool>? repeatFlag,
    Value<bool>? safetyFlagged,
    Value<String>? localDate,
    Value<bool>? isActive,
    Value<String>? excludedJson,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      targetSec: targetSec ?? this.targetSec,
      practicedSec: practicedSec ?? this.practicedSec,
      outcome: outcome ?? this.outcome,
      detection: detection ?? this.detection,
      audioOn: audioOn ?? this.audioOn,
      worryText: worryText ?? this.worryText,
      worryChip: worryChip ?? this.worryChip,
      repeatFlag: repeatFlag ?? this.repeatFlag,
      safetyFlagged: safetyFlagged ?? this.safetyFlagged,
      localDate: localDate ?? this.localDate,
      isActive: isActive ?? this.isActive,
      excludedJson: excludedJson ?? this.excludedJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (targetSec.present) {
      map['target_sec'] = Variable<int>(targetSec.value);
    }
    if (practicedSec.present) {
      map['practiced_sec'] = Variable<int>(practicedSec.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (detection.present) {
      map['detection'] = Variable<String>(detection.value);
    }
    if (audioOn.present) {
      map['audio_on'] = Variable<bool>(audioOn.value);
    }
    if (worryText.present) {
      map['worry_text'] = Variable<String>(worryText.value);
    }
    if (worryChip.present) {
      map['worry_chip'] = Variable<String>(worryChip.value);
    }
    if (repeatFlag.present) {
      map['repeat_flag'] = Variable<bool>(repeatFlag.value);
    }
    if (safetyFlagged.present) {
      map['safety_flagged'] = Variable<bool>(safetyFlagged.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (excludedJson.present) {
      map['excluded_json'] = Variable<String>(excludedJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('targetSec: $targetSec, ')
          ..write('practicedSec: $practicedSec, ')
          ..write('outcome: $outcome, ')
          ..write('detection: $detection, ')
          ..write('audioOn: $audioOn, ')
          ..write('worryText: $worryText, ')
          ..write('worryChip: $worryChip, ')
          ..write('repeatFlag: $repeatFlag, ')
          ..write('safetyFlagged: $safetyFlagged, ')
          ..write('localDate: $localDate, ')
          ..write('isActive: $isActive, ')
          ..write('excludedJson: $excludedJson')
          ..write(')'))
        .toString();
  }
}

class $DayRecordsTable extends DayRecords
    with TableInfo<$DayRecordsTable, DayRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _validSessionCountMeta = const VerificationMeta(
    'validSessionCount',
  );
  @override
  late final GeneratedColumn<int> validSessionCount = GeneratedColumn<int>(
    'valid_session_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _firstValidAtMeta = const VerificationMeta(
    'firstValidAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstValidAt = GeneratedColumn<DateTime>(
    'first_valid_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creditedMeta = const VerificationMeta(
    'credited',
  );
  @override
  late final GeneratedColumn<bool> credited = GeneratedColumn<bool>(
    'credited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("credited" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localDate,
    validSessionCount,
    firstValidAt,
    credited,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('valid_session_count')) {
      context.handle(
        _validSessionCountMeta,
        validSessionCount.isAcceptableOrUnknown(
          data['valid_session_count']!,
          _validSessionCountMeta,
        ),
      );
    }
    if (data.containsKey('first_valid_at')) {
      context.handle(
        _firstValidAtMeta,
        firstValidAt.isAcceptableOrUnknown(
          data['first_valid_at']!,
          _firstValidAtMeta,
        ),
      );
    }
    if (data.containsKey('credited')) {
      context.handle(
        _creditedMeta,
        credited.isAcceptableOrUnknown(data['credited']!, _creditedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localDate};
  @override
  DayRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayRecord(
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      validSessionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valid_session_count'],
      )!,
      firstValidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_valid_at'],
      ),
      credited: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}credited'],
      )!,
    );
  }

  @override
  $DayRecordsTable createAlias(String alias) {
    return $DayRecordsTable(attachedDatabase, alias);
  }
}

class DayRecord extends DataClass implements Insertable<DayRecord> {
  final String localDate;
  final int validSessionCount;
  final DateTime? firstValidAt;
  final bool credited;
  const DayRecord({
    required this.localDate,
    required this.validSessionCount,
    this.firstValidAt,
    required this.credited,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_date'] = Variable<String>(localDate);
    map['valid_session_count'] = Variable<int>(validSessionCount);
    if (!nullToAbsent || firstValidAt != null) {
      map['first_valid_at'] = Variable<DateTime>(firstValidAt);
    }
    map['credited'] = Variable<bool>(credited);
    return map;
  }

  DayRecordsCompanion toCompanion(bool nullToAbsent) {
    return DayRecordsCompanion(
      localDate: Value(localDate),
      validSessionCount: Value(validSessionCount),
      firstValidAt: firstValidAt == null && nullToAbsent
          ? const Value.absent()
          : Value(firstValidAt),
      credited: Value(credited),
    );
  }

  factory DayRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayRecord(
      localDate: serializer.fromJson<String>(json['localDate']),
      validSessionCount: serializer.fromJson<int>(json['validSessionCount']),
      firstValidAt: serializer.fromJson<DateTime?>(json['firstValidAt']),
      credited: serializer.fromJson<bool>(json['credited']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localDate': serializer.toJson<String>(localDate),
      'validSessionCount': serializer.toJson<int>(validSessionCount),
      'firstValidAt': serializer.toJson<DateTime?>(firstValidAt),
      'credited': serializer.toJson<bool>(credited),
    };
  }

  DayRecord copyWith({
    String? localDate,
    int? validSessionCount,
    Value<DateTime?> firstValidAt = const Value.absent(),
    bool? credited,
  }) => DayRecord(
    localDate: localDate ?? this.localDate,
    validSessionCount: validSessionCount ?? this.validSessionCount,
    firstValidAt: firstValidAt.present ? firstValidAt.value : this.firstValidAt,
    credited: credited ?? this.credited,
  );
  DayRecord copyWithCompanion(DayRecordsCompanion data) {
    return DayRecord(
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      validSessionCount: data.validSessionCount.present
          ? data.validSessionCount.value
          : this.validSessionCount,
      firstValidAt: data.firstValidAt.present
          ? data.firstValidAt.value
          : this.firstValidAt,
      credited: data.credited.present ? data.credited.value : this.credited,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayRecord(')
          ..write('localDate: $localDate, ')
          ..write('validSessionCount: $validSessionCount, ')
          ..write('firstValidAt: $firstValidAt, ')
          ..write('credited: $credited')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(localDate, validSessionCount, firstValidAt, credited);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayRecord &&
          other.localDate == this.localDate &&
          other.validSessionCount == this.validSessionCount &&
          other.firstValidAt == this.firstValidAt &&
          other.credited == this.credited);
}

class DayRecordsCompanion extends UpdateCompanion<DayRecord> {
  final Value<String> localDate;
  final Value<int> validSessionCount;
  final Value<DateTime?> firstValidAt;
  final Value<bool> credited;
  final Value<int> rowid;
  const DayRecordsCompanion({
    this.localDate = const Value.absent(),
    this.validSessionCount = const Value.absent(),
    this.firstValidAt = const Value.absent(),
    this.credited = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayRecordsCompanion.insert({
    required String localDate,
    this.validSessionCount = const Value.absent(),
    this.firstValidAt = const Value.absent(),
    this.credited = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localDate = Value(localDate);
  static Insertable<DayRecord> custom({
    Expression<String>? localDate,
    Expression<int>? validSessionCount,
    Expression<DateTime>? firstValidAt,
    Expression<bool>? credited,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localDate != null) 'local_date': localDate,
      if (validSessionCount != null) 'valid_session_count': validSessionCount,
      if (firstValidAt != null) 'first_valid_at': firstValidAt,
      if (credited != null) 'credited': credited,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayRecordsCompanion copyWith({
    Value<String>? localDate,
    Value<int>? validSessionCount,
    Value<DateTime?>? firstValidAt,
    Value<bool>? credited,
    Value<int>? rowid,
  }) {
    return DayRecordsCompanion(
      localDate: localDate ?? this.localDate,
      validSessionCount: validSessionCount ?? this.validSessionCount,
      firstValidAt: firstValidAt ?? this.firstValidAt,
      credited: credited ?? this.credited,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (validSessionCount.present) {
      map['valid_session_count'] = Variable<int>(validSessionCount.value);
    }
    if (firstValidAt.present) {
      map['first_valid_at'] = Variable<DateTime>(firstValidAt.value);
    }
    if (credited.present) {
      map['credited'] = Variable<bool>(credited.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayRecordsCompanion(')
          ..write('localDate: $localDate, ')
          ..write('validSessionCount: $validSessionCount, ')
          ..write('firstValidAt: $firstValidAt, ')
          ..write('credited: $credited, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _creditedDaysMeta = const VerificationMeta(
    'creditedDays',
  );
  @override
  late final GeneratedColumn<int> creditedDays = GeneratedColumn<int>(
    'credited_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _templeStageMeta = const VerificationMeta(
    'templeStage',
  );
  @override
  late final GeneratedColumn<int> templeStage = GeneratedColumn<int>(
    'temple_stage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dharmaFirstMeta = const VerificationMeta(
    'dharmaFirst',
  );
  @override
  late final GeneratedColumn<String> dharmaFirst = GeneratedColumn<String>(
    'dharma_first',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dharmaStageMeta = const VerificationMeta(
    'dharmaStage',
  );
  @override
  late final GeneratedColumn<int> dharmaStage = GeneratedColumn<int>(
    'dharma_stage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _characterMeta = const VerificationMeta(
    'character',
  );
  @override
  late final GeneratedColumn<String> character = GeneratedColumn<String>(
    'character',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('default'),
  );
  static const VerificationMeta _recoveryPrefMeta = const VerificationMeta(
    'recoveryPref',
  );
  @override
  late final GeneratedColumn<String> recoveryPref = GeneratedColumn<String>(
    'recovery_pref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultsAppliedCountMeta =
      const VerificationMeta('defaultsAppliedCount');
  @override
  late final GeneratedColumn<int> defaultsAppliedCount = GeneratedColumn<int>(
    'defaults_applied_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _settingsJsonMeta = const VerificationMeta(
    'settingsJson',
  );
  @override
  late final GeneratedColumn<String> settingsJson = GeneratedColumn<String>(
    'settings_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _consentsJsonMeta = const VerificationMeta(
    'consentsJson',
  );
  @override
  late final GeneratedColumn<String> consentsJson = GeneratedColumn<String>(
    'consents_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _firstLaunchAtMeta = const VerificationMeta(
    'firstLaunchAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstLaunchAt =
      GeneratedColumn<DateTime>(
        'first_launch_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastVisitAtMeta = const VerificationMeta(
    'lastVisitAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastVisitAt = GeneratedColumn<DateTime>(
    'last_visit_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _characterOnboardShownMeta =
      const VerificationMeta('characterOnboardShown');
  @override
  late final GeneratedColumn<bool> characterOnboardShown =
      GeneratedColumn<bool>(
        'character_onboard_shown',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("character_onboard_shown" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _leavesClearedDateMeta = const VerificationMeta(
    'leavesClearedDate',
  );
  @override
  late final GeneratedColumn<String> leavesClearedDate =
      GeneratedColumn<String>(
        'leaves_cleared_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dharmaNameMeta = const VerificationMeta(
    'dharmaName',
  );
  @override
  late final GeneratedColumn<String> dharmaName = GeneratedColumn<String>(
    'dharma_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dharmaRankMeta = const VerificationMeta(
    'dharmaRank',
  );
  @override
  late final GeneratedColumn<int> dharmaRank = GeneratedColumn<int>(
    'dharma_rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ordainedAtMeta = const VerificationMeta(
    'ordainedAt',
  );
  @override
  late final GeneratedColumn<DateTime> ordainedAt = GeneratedColumn<DateTime>(
    'ordained_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _meritMeta = const VerificationMeta('merit');
  @override
  late final GeneratedColumn<int> merit = GeneratedColumn<int>(
    'merit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _burnedCountMeta = const VerificationMeta(
    'burnedCount',
  );
  @override
  late final GeneratedColumn<int> burnedCount = GeneratedColumn<int>(
    'burned_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bowCountMeta = const VerificationMeta(
    'bowCount',
  );
  @override
  late final GeneratedColumn<int> bowCount = GeneratedColumn<int>(
    'bow_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _faceDownSecMeta = const VerificationMeta(
    'faceDownSec',
  );
  @override
  late final GeneratedColumn<int> faceDownSec = GeneratedColumn<int>(
    'face_down_sec',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _equipJsonMeta = const VerificationMeta(
    'equipJson',
  );
  @override
  late final GeneratedColumn<String> equipJson = GeneratedColumn<String>(
    'equip_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _ownedItemsJsonMeta = const VerificationMeta(
    'ownedItemsJson',
  );
  @override
  late final GeneratedColumn<String> ownedItemsJson = GeneratedColumn<String>(
    'owned_items_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    creditedDays,
    templeStage,
    dharmaFirst,
    dharmaStage,
    character,
    recoveryPref,
    defaultsAppliedCount,
    settingsJson,
    consentsJson,
    firstLaunchAt,
    lastVisitAt,
    characterOnboardShown,
    leavesClearedDate,
    dharmaName,
    dharmaRank,
    avatarPath,
    ordainedAt,
    merit,
    burnedCount,
    bowCount,
    faceDownSec,
    equipJson,
    ownedItemsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('credited_days')) {
      context.handle(
        _creditedDaysMeta,
        creditedDays.isAcceptableOrUnknown(
          data['credited_days']!,
          _creditedDaysMeta,
        ),
      );
    }
    if (data.containsKey('temple_stage')) {
      context.handle(
        _templeStageMeta,
        templeStage.isAcceptableOrUnknown(
          data['temple_stage']!,
          _templeStageMeta,
        ),
      );
    }
    if (data.containsKey('dharma_first')) {
      context.handle(
        _dharmaFirstMeta,
        dharmaFirst.isAcceptableOrUnknown(
          data['dharma_first']!,
          _dharmaFirstMeta,
        ),
      );
    }
    if (data.containsKey('dharma_stage')) {
      context.handle(
        _dharmaStageMeta,
        dharmaStage.isAcceptableOrUnknown(
          data['dharma_stage']!,
          _dharmaStageMeta,
        ),
      );
    }
    if (data.containsKey('character')) {
      context.handle(
        _characterMeta,
        character.isAcceptableOrUnknown(data['character']!, _characterMeta),
      );
    }
    if (data.containsKey('recovery_pref')) {
      context.handle(
        _recoveryPrefMeta,
        recoveryPref.isAcceptableOrUnknown(
          data['recovery_pref']!,
          _recoveryPrefMeta,
        ),
      );
    }
    if (data.containsKey('defaults_applied_count')) {
      context.handle(
        _defaultsAppliedCountMeta,
        defaultsAppliedCount.isAcceptableOrUnknown(
          data['defaults_applied_count']!,
          _defaultsAppliedCountMeta,
        ),
      );
    }
    if (data.containsKey('settings_json')) {
      context.handle(
        _settingsJsonMeta,
        settingsJson.isAcceptableOrUnknown(
          data['settings_json']!,
          _settingsJsonMeta,
        ),
      );
    }
    if (data.containsKey('consents_json')) {
      context.handle(
        _consentsJsonMeta,
        consentsJson.isAcceptableOrUnknown(
          data['consents_json']!,
          _consentsJsonMeta,
        ),
      );
    }
    if (data.containsKey('first_launch_at')) {
      context.handle(
        _firstLaunchAtMeta,
        firstLaunchAt.isAcceptableOrUnknown(
          data['first_launch_at']!,
          _firstLaunchAtMeta,
        ),
      );
    }
    if (data.containsKey('last_visit_at')) {
      context.handle(
        _lastVisitAtMeta,
        lastVisitAt.isAcceptableOrUnknown(
          data['last_visit_at']!,
          _lastVisitAtMeta,
        ),
      );
    }
    if (data.containsKey('character_onboard_shown')) {
      context.handle(
        _characterOnboardShownMeta,
        characterOnboardShown.isAcceptableOrUnknown(
          data['character_onboard_shown']!,
          _characterOnboardShownMeta,
        ),
      );
    }
    if (data.containsKey('leaves_cleared_date')) {
      context.handle(
        _leavesClearedDateMeta,
        leavesClearedDate.isAcceptableOrUnknown(
          data['leaves_cleared_date']!,
          _leavesClearedDateMeta,
        ),
      );
    }
    if (data.containsKey('dharma_name')) {
      context.handle(
        _dharmaNameMeta,
        dharmaName.isAcceptableOrUnknown(data['dharma_name']!, _dharmaNameMeta),
      );
    }
    if (data.containsKey('dharma_rank')) {
      context.handle(
        _dharmaRankMeta,
        dharmaRank.isAcceptableOrUnknown(data['dharma_rank']!, _dharmaRankMeta),
      );
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    if (data.containsKey('ordained_at')) {
      context.handle(
        _ordainedAtMeta,
        ordainedAt.isAcceptableOrUnknown(data['ordained_at']!, _ordainedAtMeta),
      );
    }
    if (data.containsKey('merit')) {
      context.handle(
        _meritMeta,
        merit.isAcceptableOrUnknown(data['merit']!, _meritMeta),
      );
    }
    if (data.containsKey('burned_count')) {
      context.handle(
        _burnedCountMeta,
        burnedCount.isAcceptableOrUnknown(
          data['burned_count']!,
          _burnedCountMeta,
        ),
      );
    }
    if (data.containsKey('bow_count')) {
      context.handle(
        _bowCountMeta,
        bowCount.isAcceptableOrUnknown(data['bow_count']!, _bowCountMeta),
      );
    }
    if (data.containsKey('face_down_sec')) {
      context.handle(
        _faceDownSecMeta,
        faceDownSec.isAcceptableOrUnknown(
          data['face_down_sec']!,
          _faceDownSecMeta,
        ),
      );
    }
    if (data.containsKey('equip_json')) {
      context.handle(
        _equipJsonMeta,
        equipJson.isAcceptableOrUnknown(data['equip_json']!, _equipJsonMeta),
      );
    }
    if (data.containsKey('owned_items_json')) {
      context.handle(
        _ownedItemsJsonMeta,
        ownedItemsJson.isAcceptableOrUnknown(
          data['owned_items_json']!,
          _ownedItemsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      creditedDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credited_days'],
      )!,
      templeStage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}temple_stage'],
      )!,
      dharmaFirst: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dharma_first'],
      ),
      dharmaStage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dharma_stage'],
      )!,
      character: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}character'],
      )!,
      recoveryPref: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recovery_pref'],
      ),
      defaultsAppliedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}defaults_applied_count'],
      )!,
      settingsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings_json'],
      )!,
      consentsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consents_json'],
      )!,
      firstLaunchAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_launch_at'],
      ),
      lastVisitAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_visit_at'],
      ),
      characterOnboardShown: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}character_onboard_shown'],
      )!,
      leavesClearedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}leaves_cleared_date'],
      ),
      dharmaName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dharma_name'],
      ),
      dharmaRank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dharma_rank'],
      )!,
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
      ordainedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ordained_at'],
      ),
      merit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}merit'],
      )!,
      burnedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}burned_count'],
      )!,
      bowCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bow_count'],
      )!,
      faceDownSec: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}face_down_sec'],
      )!,
      equipJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equip_json'],
      )!,
      ownedItemsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owned_items_json'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final int creditedDays;
  final int templeStage;

  /// 관/지/문/미
  final String? dharmaFirst;
  final int dharmaStage;
  final String character;

  /// 회복 최고 방향 X/O/M/Q
  final String? recoveryPref;

  /// 회복 기본값 적용 횟수. 3회 후 중단 (FR-6.5).
  final int defaultsAppliedCount;
  final String settingsJson;
  final String consentsJson;
  final DateTime? firstLaunchAt;
  final DateTime? lastVisitAt;
  final bool characterOnboardShown;

  /// 낙엽 연출을 이미 처리한 복귀 날짜 (FR-4.4).
  final String? leavesClearedDate;

  /// 법명 전체. 출가할 때 받는다 (예: 무념).
  final String? dharmaName;

  /// 법명 진화 단계. 0 사미 → 1 대사 → 2 선사 → 3 (미정).
  final int dharmaRank;

  /// 출가 셀카. 기기 안에만 둔다. 서버로 보내지 않는다.
  final String? avatarPath;
  final DateTime? ordainedAt;

  /// 공덕. 번뇌를 태우거나 엎어둘 때 쌓인다.
  final int merit;

  /// 태운 번뇌 누적. 108개가 「108번뇌 완파」 조건이다.
  final int burnedCount;

  /// 엎어둔 횟수 누적(108배).
  final int bowCount;

  /// 엎어둔 시간 누적(초).
  final int faceDownSec;

  /// 아바타 착용 상태. 슬롯 → 아이템 ID JSON.
  final String equipJson;

  /// 공덕으로 연 옷장 아이템 ID 목록 JSON.
  final String ownedItemsJson;
  const Profile({
    required this.id,
    required this.creditedDays,
    required this.templeStage,
    this.dharmaFirst,
    required this.dharmaStage,
    required this.character,
    this.recoveryPref,
    required this.defaultsAppliedCount,
    required this.settingsJson,
    required this.consentsJson,
    this.firstLaunchAt,
    this.lastVisitAt,
    required this.characterOnboardShown,
    this.leavesClearedDate,
    this.dharmaName,
    required this.dharmaRank,
    this.avatarPath,
    this.ordainedAt,
    required this.merit,
    required this.burnedCount,
    required this.bowCount,
    required this.faceDownSec,
    required this.equipJson,
    required this.ownedItemsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['credited_days'] = Variable<int>(creditedDays);
    map['temple_stage'] = Variable<int>(templeStage);
    if (!nullToAbsent || dharmaFirst != null) {
      map['dharma_first'] = Variable<String>(dharmaFirst);
    }
    map['dharma_stage'] = Variable<int>(dharmaStage);
    map['character'] = Variable<String>(character);
    if (!nullToAbsent || recoveryPref != null) {
      map['recovery_pref'] = Variable<String>(recoveryPref);
    }
    map['defaults_applied_count'] = Variable<int>(defaultsAppliedCount);
    map['settings_json'] = Variable<String>(settingsJson);
    map['consents_json'] = Variable<String>(consentsJson);
    if (!nullToAbsent || firstLaunchAt != null) {
      map['first_launch_at'] = Variable<DateTime>(firstLaunchAt);
    }
    if (!nullToAbsent || lastVisitAt != null) {
      map['last_visit_at'] = Variable<DateTime>(lastVisitAt);
    }
    map['character_onboard_shown'] = Variable<bool>(characterOnboardShown);
    if (!nullToAbsent || leavesClearedDate != null) {
      map['leaves_cleared_date'] = Variable<String>(leavesClearedDate);
    }
    if (!nullToAbsent || dharmaName != null) {
      map['dharma_name'] = Variable<String>(dharmaName);
    }
    map['dharma_rank'] = Variable<int>(dharmaRank);
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    if (!nullToAbsent || ordainedAt != null) {
      map['ordained_at'] = Variable<DateTime>(ordainedAt);
    }
    map['merit'] = Variable<int>(merit);
    map['burned_count'] = Variable<int>(burnedCount);
    map['bow_count'] = Variable<int>(bowCount);
    map['face_down_sec'] = Variable<int>(faceDownSec);
    map['equip_json'] = Variable<String>(equipJson);
    map['owned_items_json'] = Variable<String>(ownedItemsJson);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      creditedDays: Value(creditedDays),
      templeStage: Value(templeStage),
      dharmaFirst: dharmaFirst == null && nullToAbsent
          ? const Value.absent()
          : Value(dharmaFirst),
      dharmaStage: Value(dharmaStage),
      character: Value(character),
      recoveryPref: recoveryPref == null && nullToAbsent
          ? const Value.absent()
          : Value(recoveryPref),
      defaultsAppliedCount: Value(defaultsAppliedCount),
      settingsJson: Value(settingsJson),
      consentsJson: Value(consentsJson),
      firstLaunchAt: firstLaunchAt == null && nullToAbsent
          ? const Value.absent()
          : Value(firstLaunchAt),
      lastVisitAt: lastVisitAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVisitAt),
      characterOnboardShown: Value(characterOnboardShown),
      leavesClearedDate: leavesClearedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(leavesClearedDate),
      dharmaName: dharmaName == null && nullToAbsent
          ? const Value.absent()
          : Value(dharmaName),
      dharmaRank: Value(dharmaRank),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      ordainedAt: ordainedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(ordainedAt),
      merit: Value(merit),
      burnedCount: Value(burnedCount),
      bowCount: Value(bowCount),
      faceDownSec: Value(faceDownSec),
      equipJson: Value(equipJson),
      ownedItemsJson: Value(ownedItemsJson),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      creditedDays: serializer.fromJson<int>(json['creditedDays']),
      templeStage: serializer.fromJson<int>(json['templeStage']),
      dharmaFirst: serializer.fromJson<String?>(json['dharmaFirst']),
      dharmaStage: serializer.fromJson<int>(json['dharmaStage']),
      character: serializer.fromJson<String>(json['character']),
      recoveryPref: serializer.fromJson<String?>(json['recoveryPref']),
      defaultsAppliedCount: serializer.fromJson<int>(
        json['defaultsAppliedCount'],
      ),
      settingsJson: serializer.fromJson<String>(json['settingsJson']),
      consentsJson: serializer.fromJson<String>(json['consentsJson']),
      firstLaunchAt: serializer.fromJson<DateTime?>(json['firstLaunchAt']),
      lastVisitAt: serializer.fromJson<DateTime?>(json['lastVisitAt']),
      characterOnboardShown: serializer.fromJson<bool>(
        json['characterOnboardShown'],
      ),
      leavesClearedDate: serializer.fromJson<String?>(
        json['leavesClearedDate'],
      ),
      dharmaName: serializer.fromJson<String?>(json['dharmaName']),
      dharmaRank: serializer.fromJson<int>(json['dharmaRank']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      ordainedAt: serializer.fromJson<DateTime?>(json['ordainedAt']),
      merit: serializer.fromJson<int>(json['merit']),
      burnedCount: serializer.fromJson<int>(json['burnedCount']),
      bowCount: serializer.fromJson<int>(json['bowCount']),
      faceDownSec: serializer.fromJson<int>(json['faceDownSec']),
      equipJson: serializer.fromJson<String>(json['equipJson']),
      ownedItemsJson: serializer.fromJson<String>(json['ownedItemsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'creditedDays': serializer.toJson<int>(creditedDays),
      'templeStage': serializer.toJson<int>(templeStage),
      'dharmaFirst': serializer.toJson<String?>(dharmaFirst),
      'dharmaStage': serializer.toJson<int>(dharmaStage),
      'character': serializer.toJson<String>(character),
      'recoveryPref': serializer.toJson<String?>(recoveryPref),
      'defaultsAppliedCount': serializer.toJson<int>(defaultsAppliedCount),
      'settingsJson': serializer.toJson<String>(settingsJson),
      'consentsJson': serializer.toJson<String>(consentsJson),
      'firstLaunchAt': serializer.toJson<DateTime?>(firstLaunchAt),
      'lastVisitAt': serializer.toJson<DateTime?>(lastVisitAt),
      'characterOnboardShown': serializer.toJson<bool>(characterOnboardShown),
      'leavesClearedDate': serializer.toJson<String?>(leavesClearedDate),
      'dharmaName': serializer.toJson<String?>(dharmaName),
      'dharmaRank': serializer.toJson<int>(dharmaRank),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'ordainedAt': serializer.toJson<DateTime?>(ordainedAt),
      'merit': serializer.toJson<int>(merit),
      'burnedCount': serializer.toJson<int>(burnedCount),
      'bowCount': serializer.toJson<int>(bowCount),
      'faceDownSec': serializer.toJson<int>(faceDownSec),
      'equipJson': serializer.toJson<String>(equipJson),
      'ownedItemsJson': serializer.toJson<String>(ownedItemsJson),
    };
  }

  Profile copyWith({
    int? id,
    int? creditedDays,
    int? templeStage,
    Value<String?> dharmaFirst = const Value.absent(),
    int? dharmaStage,
    String? character,
    Value<String?> recoveryPref = const Value.absent(),
    int? defaultsAppliedCount,
    String? settingsJson,
    String? consentsJson,
    Value<DateTime?> firstLaunchAt = const Value.absent(),
    Value<DateTime?> lastVisitAt = const Value.absent(),
    bool? characterOnboardShown,
    Value<String?> leavesClearedDate = const Value.absent(),
    Value<String?> dharmaName = const Value.absent(),
    int? dharmaRank,
    Value<String?> avatarPath = const Value.absent(),
    Value<DateTime?> ordainedAt = const Value.absent(),
    int? merit,
    int? burnedCount,
    int? bowCount,
    int? faceDownSec,
    String? equipJson,
    String? ownedItemsJson,
  }) => Profile(
    id: id ?? this.id,
    creditedDays: creditedDays ?? this.creditedDays,
    templeStage: templeStage ?? this.templeStage,
    dharmaFirst: dharmaFirst.present ? dharmaFirst.value : this.dharmaFirst,
    dharmaStage: dharmaStage ?? this.dharmaStage,
    character: character ?? this.character,
    recoveryPref: recoveryPref.present ? recoveryPref.value : this.recoveryPref,
    defaultsAppliedCount: defaultsAppliedCount ?? this.defaultsAppliedCount,
    settingsJson: settingsJson ?? this.settingsJson,
    consentsJson: consentsJson ?? this.consentsJson,
    firstLaunchAt: firstLaunchAt.present
        ? firstLaunchAt.value
        : this.firstLaunchAt,
    lastVisitAt: lastVisitAt.present ? lastVisitAt.value : this.lastVisitAt,
    characterOnboardShown: characterOnboardShown ?? this.characterOnboardShown,
    leavesClearedDate: leavesClearedDate.present
        ? leavesClearedDate.value
        : this.leavesClearedDate,
    dharmaName: dharmaName.present ? dharmaName.value : this.dharmaName,
    dharmaRank: dharmaRank ?? this.dharmaRank,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
    ordainedAt: ordainedAt.present ? ordainedAt.value : this.ordainedAt,
    merit: merit ?? this.merit,
    burnedCount: burnedCount ?? this.burnedCount,
    bowCount: bowCount ?? this.bowCount,
    faceDownSec: faceDownSec ?? this.faceDownSec,
    equipJson: equipJson ?? this.equipJson,
    ownedItemsJson: ownedItemsJson ?? this.ownedItemsJson,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      creditedDays: data.creditedDays.present
          ? data.creditedDays.value
          : this.creditedDays,
      templeStage: data.templeStage.present
          ? data.templeStage.value
          : this.templeStage,
      dharmaFirst: data.dharmaFirst.present
          ? data.dharmaFirst.value
          : this.dharmaFirst,
      dharmaStage: data.dharmaStage.present
          ? data.dharmaStage.value
          : this.dharmaStage,
      character: data.character.present ? data.character.value : this.character,
      recoveryPref: data.recoveryPref.present
          ? data.recoveryPref.value
          : this.recoveryPref,
      defaultsAppliedCount: data.defaultsAppliedCount.present
          ? data.defaultsAppliedCount.value
          : this.defaultsAppliedCount,
      settingsJson: data.settingsJson.present
          ? data.settingsJson.value
          : this.settingsJson,
      consentsJson: data.consentsJson.present
          ? data.consentsJson.value
          : this.consentsJson,
      firstLaunchAt: data.firstLaunchAt.present
          ? data.firstLaunchAt.value
          : this.firstLaunchAt,
      lastVisitAt: data.lastVisitAt.present
          ? data.lastVisitAt.value
          : this.lastVisitAt,
      characterOnboardShown: data.characterOnboardShown.present
          ? data.characterOnboardShown.value
          : this.characterOnboardShown,
      leavesClearedDate: data.leavesClearedDate.present
          ? data.leavesClearedDate.value
          : this.leavesClearedDate,
      dharmaName: data.dharmaName.present
          ? data.dharmaName.value
          : this.dharmaName,
      dharmaRank: data.dharmaRank.present
          ? data.dharmaRank.value
          : this.dharmaRank,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
      ordainedAt: data.ordainedAt.present
          ? data.ordainedAt.value
          : this.ordainedAt,
      merit: data.merit.present ? data.merit.value : this.merit,
      burnedCount: data.burnedCount.present
          ? data.burnedCount.value
          : this.burnedCount,
      bowCount: data.bowCount.present ? data.bowCount.value : this.bowCount,
      faceDownSec: data.faceDownSec.present
          ? data.faceDownSec.value
          : this.faceDownSec,
      equipJson: data.equipJson.present ? data.equipJson.value : this.equipJson,
      ownedItemsJson: data.ownedItemsJson.present
          ? data.ownedItemsJson.value
          : this.ownedItemsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('creditedDays: $creditedDays, ')
          ..write('templeStage: $templeStage, ')
          ..write('dharmaFirst: $dharmaFirst, ')
          ..write('dharmaStage: $dharmaStage, ')
          ..write('character: $character, ')
          ..write('recoveryPref: $recoveryPref, ')
          ..write('defaultsAppliedCount: $defaultsAppliedCount, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('consentsJson: $consentsJson, ')
          ..write('firstLaunchAt: $firstLaunchAt, ')
          ..write('lastVisitAt: $lastVisitAt, ')
          ..write('characterOnboardShown: $characterOnboardShown, ')
          ..write('leavesClearedDate: $leavesClearedDate, ')
          ..write('dharmaName: $dharmaName, ')
          ..write('dharmaRank: $dharmaRank, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('ordainedAt: $ordainedAt, ')
          ..write('merit: $merit, ')
          ..write('burnedCount: $burnedCount, ')
          ..write('bowCount: $bowCount, ')
          ..write('faceDownSec: $faceDownSec, ')
          ..write('equipJson: $equipJson, ')
          ..write('ownedItemsJson: $ownedItemsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    creditedDays,
    templeStage,
    dharmaFirst,
    dharmaStage,
    character,
    recoveryPref,
    defaultsAppliedCount,
    settingsJson,
    consentsJson,
    firstLaunchAt,
    lastVisitAt,
    characterOnboardShown,
    leavesClearedDate,
    dharmaName,
    dharmaRank,
    avatarPath,
    ordainedAt,
    merit,
    burnedCount,
    bowCount,
    faceDownSec,
    equipJson,
    ownedItemsJson,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.creditedDays == this.creditedDays &&
          other.templeStage == this.templeStage &&
          other.dharmaFirst == this.dharmaFirst &&
          other.dharmaStage == this.dharmaStage &&
          other.character == this.character &&
          other.recoveryPref == this.recoveryPref &&
          other.defaultsAppliedCount == this.defaultsAppliedCount &&
          other.settingsJson == this.settingsJson &&
          other.consentsJson == this.consentsJson &&
          other.firstLaunchAt == this.firstLaunchAt &&
          other.lastVisitAt == this.lastVisitAt &&
          other.characterOnboardShown == this.characterOnboardShown &&
          other.leavesClearedDate == this.leavesClearedDate &&
          other.dharmaName == this.dharmaName &&
          other.dharmaRank == this.dharmaRank &&
          other.avatarPath == this.avatarPath &&
          other.ordainedAt == this.ordainedAt &&
          other.merit == this.merit &&
          other.burnedCount == this.burnedCount &&
          other.bowCount == this.bowCount &&
          other.faceDownSec == this.faceDownSec &&
          other.equipJson == this.equipJson &&
          other.ownedItemsJson == this.ownedItemsJson);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<int> creditedDays;
  final Value<int> templeStage;
  final Value<String?> dharmaFirst;
  final Value<int> dharmaStage;
  final Value<String> character;
  final Value<String?> recoveryPref;
  final Value<int> defaultsAppliedCount;
  final Value<String> settingsJson;
  final Value<String> consentsJson;
  final Value<DateTime?> firstLaunchAt;
  final Value<DateTime?> lastVisitAt;
  final Value<bool> characterOnboardShown;
  final Value<String?> leavesClearedDate;
  final Value<String?> dharmaName;
  final Value<int> dharmaRank;
  final Value<String?> avatarPath;
  final Value<DateTime?> ordainedAt;
  final Value<int> merit;
  final Value<int> burnedCount;
  final Value<int> bowCount;
  final Value<int> faceDownSec;
  final Value<String> equipJson;
  final Value<String> ownedItemsJson;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.creditedDays = const Value.absent(),
    this.templeStage = const Value.absent(),
    this.dharmaFirst = const Value.absent(),
    this.dharmaStage = const Value.absent(),
    this.character = const Value.absent(),
    this.recoveryPref = const Value.absent(),
    this.defaultsAppliedCount = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.consentsJson = const Value.absent(),
    this.firstLaunchAt = const Value.absent(),
    this.lastVisitAt = const Value.absent(),
    this.characterOnboardShown = const Value.absent(),
    this.leavesClearedDate = const Value.absent(),
    this.dharmaName = const Value.absent(),
    this.dharmaRank = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.ordainedAt = const Value.absent(),
    this.merit = const Value.absent(),
    this.burnedCount = const Value.absent(),
    this.bowCount = const Value.absent(),
    this.faceDownSec = const Value.absent(),
    this.equipJson = const Value.absent(),
    this.ownedItemsJson = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.creditedDays = const Value.absent(),
    this.templeStage = const Value.absent(),
    this.dharmaFirst = const Value.absent(),
    this.dharmaStage = const Value.absent(),
    this.character = const Value.absent(),
    this.recoveryPref = const Value.absent(),
    this.defaultsAppliedCount = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.consentsJson = const Value.absent(),
    this.firstLaunchAt = const Value.absent(),
    this.lastVisitAt = const Value.absent(),
    this.characterOnboardShown = const Value.absent(),
    this.leavesClearedDate = const Value.absent(),
    this.dharmaName = const Value.absent(),
    this.dharmaRank = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.ordainedAt = const Value.absent(),
    this.merit = const Value.absent(),
    this.burnedCount = const Value.absent(),
    this.bowCount = const Value.absent(),
    this.faceDownSec = const Value.absent(),
    this.equipJson = const Value.absent(),
    this.ownedItemsJson = const Value.absent(),
  });
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<int>? creditedDays,
    Expression<int>? templeStage,
    Expression<String>? dharmaFirst,
    Expression<int>? dharmaStage,
    Expression<String>? character,
    Expression<String>? recoveryPref,
    Expression<int>? defaultsAppliedCount,
    Expression<String>? settingsJson,
    Expression<String>? consentsJson,
    Expression<DateTime>? firstLaunchAt,
    Expression<DateTime>? lastVisitAt,
    Expression<bool>? characterOnboardShown,
    Expression<String>? leavesClearedDate,
    Expression<String>? dharmaName,
    Expression<int>? dharmaRank,
    Expression<String>? avatarPath,
    Expression<DateTime>? ordainedAt,
    Expression<int>? merit,
    Expression<int>? burnedCount,
    Expression<int>? bowCount,
    Expression<int>? faceDownSec,
    Expression<String>? equipJson,
    Expression<String>? ownedItemsJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (creditedDays != null) 'credited_days': creditedDays,
      if (templeStage != null) 'temple_stage': templeStage,
      if (dharmaFirst != null) 'dharma_first': dharmaFirst,
      if (dharmaStage != null) 'dharma_stage': dharmaStage,
      if (character != null) 'character': character,
      if (recoveryPref != null) 'recovery_pref': recoveryPref,
      if (defaultsAppliedCount != null)
        'defaults_applied_count': defaultsAppliedCount,
      if (settingsJson != null) 'settings_json': settingsJson,
      if (consentsJson != null) 'consents_json': consentsJson,
      if (firstLaunchAt != null) 'first_launch_at': firstLaunchAt,
      if (lastVisitAt != null) 'last_visit_at': lastVisitAt,
      if (characterOnboardShown != null)
        'character_onboard_shown': characterOnboardShown,
      if (leavesClearedDate != null) 'leaves_cleared_date': leavesClearedDate,
      if (dharmaName != null) 'dharma_name': dharmaName,
      if (dharmaRank != null) 'dharma_rank': dharmaRank,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (ordainedAt != null) 'ordained_at': ordainedAt,
      if (merit != null) 'merit': merit,
      if (burnedCount != null) 'burned_count': burnedCount,
      if (bowCount != null) 'bow_count': bowCount,
      if (faceDownSec != null) 'face_down_sec': faceDownSec,
      if (equipJson != null) 'equip_json': equipJson,
      if (ownedItemsJson != null) 'owned_items_json': ownedItemsJson,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<int>? creditedDays,
    Value<int>? templeStage,
    Value<String?>? dharmaFirst,
    Value<int>? dharmaStage,
    Value<String>? character,
    Value<String?>? recoveryPref,
    Value<int>? defaultsAppliedCount,
    Value<String>? settingsJson,
    Value<String>? consentsJson,
    Value<DateTime?>? firstLaunchAt,
    Value<DateTime?>? lastVisitAt,
    Value<bool>? characterOnboardShown,
    Value<String?>? leavesClearedDate,
    Value<String?>? dharmaName,
    Value<int>? dharmaRank,
    Value<String?>? avatarPath,
    Value<DateTime?>? ordainedAt,
    Value<int>? merit,
    Value<int>? burnedCount,
    Value<int>? bowCount,
    Value<int>? faceDownSec,
    Value<String>? equipJson,
    Value<String>? ownedItemsJson,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      creditedDays: creditedDays ?? this.creditedDays,
      templeStage: templeStage ?? this.templeStage,
      dharmaFirst: dharmaFirst ?? this.dharmaFirst,
      dharmaStage: dharmaStage ?? this.dharmaStage,
      character: character ?? this.character,
      recoveryPref: recoveryPref ?? this.recoveryPref,
      defaultsAppliedCount: defaultsAppliedCount ?? this.defaultsAppliedCount,
      settingsJson: settingsJson ?? this.settingsJson,
      consentsJson: consentsJson ?? this.consentsJson,
      firstLaunchAt: firstLaunchAt ?? this.firstLaunchAt,
      lastVisitAt: lastVisitAt ?? this.lastVisitAt,
      characterOnboardShown:
          characterOnboardShown ?? this.characterOnboardShown,
      leavesClearedDate: leavesClearedDate ?? this.leavesClearedDate,
      dharmaName: dharmaName ?? this.dharmaName,
      dharmaRank: dharmaRank ?? this.dharmaRank,
      avatarPath: avatarPath ?? this.avatarPath,
      ordainedAt: ordainedAt ?? this.ordainedAt,
      merit: merit ?? this.merit,
      burnedCount: burnedCount ?? this.burnedCount,
      bowCount: bowCount ?? this.bowCount,
      faceDownSec: faceDownSec ?? this.faceDownSec,
      equipJson: equipJson ?? this.equipJson,
      ownedItemsJson: ownedItemsJson ?? this.ownedItemsJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (creditedDays.present) {
      map['credited_days'] = Variable<int>(creditedDays.value);
    }
    if (templeStage.present) {
      map['temple_stage'] = Variable<int>(templeStage.value);
    }
    if (dharmaFirst.present) {
      map['dharma_first'] = Variable<String>(dharmaFirst.value);
    }
    if (dharmaStage.present) {
      map['dharma_stage'] = Variable<int>(dharmaStage.value);
    }
    if (character.present) {
      map['character'] = Variable<String>(character.value);
    }
    if (recoveryPref.present) {
      map['recovery_pref'] = Variable<String>(recoveryPref.value);
    }
    if (defaultsAppliedCount.present) {
      map['defaults_applied_count'] = Variable<int>(defaultsAppliedCount.value);
    }
    if (settingsJson.present) {
      map['settings_json'] = Variable<String>(settingsJson.value);
    }
    if (consentsJson.present) {
      map['consents_json'] = Variable<String>(consentsJson.value);
    }
    if (firstLaunchAt.present) {
      map['first_launch_at'] = Variable<DateTime>(firstLaunchAt.value);
    }
    if (lastVisitAt.present) {
      map['last_visit_at'] = Variable<DateTime>(lastVisitAt.value);
    }
    if (characterOnboardShown.present) {
      map['character_onboard_shown'] = Variable<bool>(
        characterOnboardShown.value,
      );
    }
    if (leavesClearedDate.present) {
      map['leaves_cleared_date'] = Variable<String>(leavesClearedDate.value);
    }
    if (dharmaName.present) {
      map['dharma_name'] = Variable<String>(dharmaName.value);
    }
    if (dharmaRank.present) {
      map['dharma_rank'] = Variable<int>(dharmaRank.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (ordainedAt.present) {
      map['ordained_at'] = Variable<DateTime>(ordainedAt.value);
    }
    if (merit.present) {
      map['merit'] = Variable<int>(merit.value);
    }
    if (burnedCount.present) {
      map['burned_count'] = Variable<int>(burnedCount.value);
    }
    if (bowCount.present) {
      map['bow_count'] = Variable<int>(bowCount.value);
    }
    if (faceDownSec.present) {
      map['face_down_sec'] = Variable<int>(faceDownSec.value);
    }
    if (equipJson.present) {
      map['equip_json'] = Variable<String>(equipJson.value);
    }
    if (ownedItemsJson.present) {
      map['owned_items_json'] = Variable<String>(ownedItemsJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('creditedDays: $creditedDays, ')
          ..write('templeStage: $templeStage, ')
          ..write('dharmaFirst: $dharmaFirst, ')
          ..write('dharmaStage: $dharmaStage, ')
          ..write('character: $character, ')
          ..write('recoveryPref: $recoveryPref, ')
          ..write('defaultsAppliedCount: $defaultsAppliedCount, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('consentsJson: $consentsJson, ')
          ..write('firstLaunchAt: $firstLaunchAt, ')
          ..write('lastVisitAt: $lastVisitAt, ')
          ..write('characterOnboardShown: $characterOnboardShown, ')
          ..write('leavesClearedDate: $leavesClearedDate, ')
          ..write('dharmaName: $dharmaName, ')
          ..write('dharmaRank: $dharmaRank, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('ordainedAt: $ordainedAt, ')
          ..write('merit: $merit, ')
          ..write('burnedCount: $burnedCount, ')
          ..write('bowCount: $bowCount, ')
          ..write('faceDownSec: $faceDownSec, ')
          ..write('equipJson: $equipJson, ')
          ..write('ownedItemsJson: $ownedItemsJson')
          ..write(')'))
        .toString();
  }
}

class $TestResultsTable extends TestResults
    with TableInfo<$TestResultsTable, TestResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestResultsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answersJsonMeta = const VerificationMeta(
    'answersJson',
  );
  @override
  late final GeneratedColumn<String> answersJson = GeneratedColumn<String>(
    'answers_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeIdMeta = const VerificationMeta('typeId');
  @override
  late final GeneratedColumn<String> typeId = GeneratedColumn<String>(
    'type_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gTopMeta = const VerificationMeta('gTop');
  @override
  late final GeneratedColumn<String> gTop = GeneratedColumn<String>(
    'g_top',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aTopMeta = const VerificationMeta('aTop');
  @override
  late final GeneratedColumn<String> aTop = GeneratedColumn<String>(
    'a_top',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _auxiliaryJsonMeta = const VerificationMeta(
    'auxiliaryJson',
  );
  @override
  late final GeneratedColumn<String> auxiliaryJson = GeneratedColumn<String>(
    'auxiliary_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _recoveryJsonMeta = const VerificationMeta(
    'recoveryJson',
  );
  @override
  late final GeneratedColumn<String> recoveryJson = GeneratedColumn<String>(
    'recovery_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _appliedToProfileMeta = const VerificationMeta(
    'appliedToProfile',
  );
  @override
  late final GeneratedColumn<bool> appliedToProfile = GeneratedColumn<bool>(
    'applied_to_profile',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("applied_to_profile" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    takenAt,
    answersJson,
    state,
    typeId,
    gTop,
    aTop,
    auxiliaryJson,
    recoveryJson,
    appliedToProfile,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<TestResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('answers_json')) {
      context.handle(
        _answersJsonMeta,
        answersJson.isAcceptableOrUnknown(
          data['answers_json']!,
          _answersJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_answersJsonMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('type_id')) {
      context.handle(
        _typeIdMeta,
        typeId.isAcceptableOrUnknown(data['type_id']!, _typeIdMeta),
      );
    }
    if (data.containsKey('g_top')) {
      context.handle(
        _gTopMeta,
        gTop.isAcceptableOrUnknown(data['g_top']!, _gTopMeta),
      );
    }
    if (data.containsKey('a_top')) {
      context.handle(
        _aTopMeta,
        aTop.isAcceptableOrUnknown(data['a_top']!, _aTopMeta),
      );
    }
    if (data.containsKey('auxiliary_json')) {
      context.handle(
        _auxiliaryJsonMeta,
        auxiliaryJson.isAcceptableOrUnknown(
          data['auxiliary_json']!,
          _auxiliaryJsonMeta,
        ),
      );
    }
    if (data.containsKey('recovery_json')) {
      context.handle(
        _recoveryJsonMeta,
        recoveryJson.isAcceptableOrUnknown(
          data['recovery_json']!,
          _recoveryJsonMeta,
        ),
      );
    }
    if (data.containsKey('applied_to_profile')) {
      context.handle(
        _appliedToProfileMeta,
        appliedToProfile.isAcceptableOrUnknown(
          data['applied_to_profile']!,
          _appliedToProfileMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestResult(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
      answersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answers_json'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      typeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_id'],
      ),
      gTop: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}g_top'],
      ),
      aTop: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}a_top'],
      ),
      auxiliaryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auxiliary_json'],
      )!,
      recoveryJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recovery_json'],
      )!,
      appliedToProfile: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}applied_to_profile'],
      )!,
    );
  }

  @override
  $TestResultsTable createAlias(String alias) {
    return $TestResultsTable(attachedDatabase, alias);
  }
}

class TestResult extends DataClass implements Insertable<TestResult> {
  final int id;
  final DateTime takenAt;

  /// 문항 ID → 방향 또는 null(건너뜀). 심화 포함.
  final String answersJson;

  /// representative | mixed | tendency | reservedInsufficient | reservedScattered
  final String state;
  final String? typeId;
  final String? gTop;
  final String? aTop;
  final String auxiliaryJson;
  final String recoveryJson;
  final bool appliedToProfile;
  const TestResult({
    required this.id,
    required this.takenAt,
    required this.answersJson,
    required this.state,
    this.typeId,
    this.gTop,
    this.aTop,
    required this.auxiliaryJson,
    required this.recoveryJson,
    required this.appliedToProfile,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['taken_at'] = Variable<DateTime>(takenAt);
    map['answers_json'] = Variable<String>(answersJson);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || typeId != null) {
      map['type_id'] = Variable<String>(typeId);
    }
    if (!nullToAbsent || gTop != null) {
      map['g_top'] = Variable<String>(gTop);
    }
    if (!nullToAbsent || aTop != null) {
      map['a_top'] = Variable<String>(aTop);
    }
    map['auxiliary_json'] = Variable<String>(auxiliaryJson);
    map['recovery_json'] = Variable<String>(recoveryJson);
    map['applied_to_profile'] = Variable<bool>(appliedToProfile);
    return map;
  }

  TestResultsCompanion toCompanion(bool nullToAbsent) {
    return TestResultsCompanion(
      id: Value(id),
      takenAt: Value(takenAt),
      answersJson: Value(answersJson),
      state: Value(state),
      typeId: typeId == null && nullToAbsent
          ? const Value.absent()
          : Value(typeId),
      gTop: gTop == null && nullToAbsent ? const Value.absent() : Value(gTop),
      aTop: aTop == null && nullToAbsent ? const Value.absent() : Value(aTop),
      auxiliaryJson: Value(auxiliaryJson),
      recoveryJson: Value(recoveryJson),
      appliedToProfile: Value(appliedToProfile),
    );
  }

  factory TestResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestResult(
      id: serializer.fromJson<int>(json['id']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      answersJson: serializer.fromJson<String>(json['answersJson']),
      state: serializer.fromJson<String>(json['state']),
      typeId: serializer.fromJson<String?>(json['typeId']),
      gTop: serializer.fromJson<String?>(json['gTop']),
      aTop: serializer.fromJson<String?>(json['aTop']),
      auxiliaryJson: serializer.fromJson<String>(json['auxiliaryJson']),
      recoveryJson: serializer.fromJson<String>(json['recoveryJson']),
      appliedToProfile: serializer.fromJson<bool>(json['appliedToProfile']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'answersJson': serializer.toJson<String>(answersJson),
      'state': serializer.toJson<String>(state),
      'typeId': serializer.toJson<String?>(typeId),
      'gTop': serializer.toJson<String?>(gTop),
      'aTop': serializer.toJson<String?>(aTop),
      'auxiliaryJson': serializer.toJson<String>(auxiliaryJson),
      'recoveryJson': serializer.toJson<String>(recoveryJson),
      'appliedToProfile': serializer.toJson<bool>(appliedToProfile),
    };
  }

  TestResult copyWith({
    int? id,
    DateTime? takenAt,
    String? answersJson,
    String? state,
    Value<String?> typeId = const Value.absent(),
    Value<String?> gTop = const Value.absent(),
    Value<String?> aTop = const Value.absent(),
    String? auxiliaryJson,
    String? recoveryJson,
    bool? appliedToProfile,
  }) => TestResult(
    id: id ?? this.id,
    takenAt: takenAt ?? this.takenAt,
    answersJson: answersJson ?? this.answersJson,
    state: state ?? this.state,
    typeId: typeId.present ? typeId.value : this.typeId,
    gTop: gTop.present ? gTop.value : this.gTop,
    aTop: aTop.present ? aTop.value : this.aTop,
    auxiliaryJson: auxiliaryJson ?? this.auxiliaryJson,
    recoveryJson: recoveryJson ?? this.recoveryJson,
    appliedToProfile: appliedToProfile ?? this.appliedToProfile,
  );
  TestResult copyWithCompanion(TestResultsCompanion data) {
    return TestResult(
      id: data.id.present ? data.id.value : this.id,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      answersJson: data.answersJson.present
          ? data.answersJson.value
          : this.answersJson,
      state: data.state.present ? data.state.value : this.state,
      typeId: data.typeId.present ? data.typeId.value : this.typeId,
      gTop: data.gTop.present ? data.gTop.value : this.gTop,
      aTop: data.aTop.present ? data.aTop.value : this.aTop,
      auxiliaryJson: data.auxiliaryJson.present
          ? data.auxiliaryJson.value
          : this.auxiliaryJson,
      recoveryJson: data.recoveryJson.present
          ? data.recoveryJson.value
          : this.recoveryJson,
      appliedToProfile: data.appliedToProfile.present
          ? data.appliedToProfile.value
          : this.appliedToProfile,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestResult(')
          ..write('id: $id, ')
          ..write('takenAt: $takenAt, ')
          ..write('answersJson: $answersJson, ')
          ..write('state: $state, ')
          ..write('typeId: $typeId, ')
          ..write('gTop: $gTop, ')
          ..write('aTop: $aTop, ')
          ..write('auxiliaryJson: $auxiliaryJson, ')
          ..write('recoveryJson: $recoveryJson, ')
          ..write('appliedToProfile: $appliedToProfile')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    takenAt,
    answersJson,
    state,
    typeId,
    gTop,
    aTop,
    auxiliaryJson,
    recoveryJson,
    appliedToProfile,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestResult &&
          other.id == this.id &&
          other.takenAt == this.takenAt &&
          other.answersJson == this.answersJson &&
          other.state == this.state &&
          other.typeId == this.typeId &&
          other.gTop == this.gTop &&
          other.aTop == this.aTop &&
          other.auxiliaryJson == this.auxiliaryJson &&
          other.recoveryJson == this.recoveryJson &&
          other.appliedToProfile == this.appliedToProfile);
}

class TestResultsCompanion extends UpdateCompanion<TestResult> {
  final Value<int> id;
  final Value<DateTime> takenAt;
  final Value<String> answersJson;
  final Value<String> state;
  final Value<String?> typeId;
  final Value<String?> gTop;
  final Value<String?> aTop;
  final Value<String> auxiliaryJson;
  final Value<String> recoveryJson;
  final Value<bool> appliedToProfile;
  const TestResultsCompanion({
    this.id = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.answersJson = const Value.absent(),
    this.state = const Value.absent(),
    this.typeId = const Value.absent(),
    this.gTop = const Value.absent(),
    this.aTop = const Value.absent(),
    this.auxiliaryJson = const Value.absent(),
    this.recoveryJson = const Value.absent(),
    this.appliedToProfile = const Value.absent(),
  });
  TestResultsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime takenAt,
    required String answersJson,
    required String state,
    this.typeId = const Value.absent(),
    this.gTop = const Value.absent(),
    this.aTop = const Value.absent(),
    this.auxiliaryJson = const Value.absent(),
    this.recoveryJson = const Value.absent(),
    this.appliedToProfile = const Value.absent(),
  }) : takenAt = Value(takenAt),
       answersJson = Value(answersJson),
       state = Value(state);
  static Insertable<TestResult> custom({
    Expression<int>? id,
    Expression<DateTime>? takenAt,
    Expression<String>? answersJson,
    Expression<String>? state,
    Expression<String>? typeId,
    Expression<String>? gTop,
    Expression<String>? aTop,
    Expression<String>? auxiliaryJson,
    Expression<String>? recoveryJson,
    Expression<bool>? appliedToProfile,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (takenAt != null) 'taken_at': takenAt,
      if (answersJson != null) 'answers_json': answersJson,
      if (state != null) 'state': state,
      if (typeId != null) 'type_id': typeId,
      if (gTop != null) 'g_top': gTop,
      if (aTop != null) 'a_top': aTop,
      if (auxiliaryJson != null) 'auxiliary_json': auxiliaryJson,
      if (recoveryJson != null) 'recovery_json': recoveryJson,
      if (appliedToProfile != null) 'applied_to_profile': appliedToProfile,
    });
  }

  TestResultsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? takenAt,
    Value<String>? answersJson,
    Value<String>? state,
    Value<String?>? typeId,
    Value<String?>? gTop,
    Value<String?>? aTop,
    Value<String>? auxiliaryJson,
    Value<String>? recoveryJson,
    Value<bool>? appliedToProfile,
  }) {
    return TestResultsCompanion(
      id: id ?? this.id,
      takenAt: takenAt ?? this.takenAt,
      answersJson: answersJson ?? this.answersJson,
      state: state ?? this.state,
      typeId: typeId ?? this.typeId,
      gTop: gTop ?? this.gTop,
      aTop: aTop ?? this.aTop,
      auxiliaryJson: auxiliaryJson ?? this.auxiliaryJson,
      recoveryJson: recoveryJson ?? this.recoveryJson,
      appliedToProfile: appliedToProfile ?? this.appliedToProfile,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (answersJson.present) {
      map['answers_json'] = Variable<String>(answersJson.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (typeId.present) {
      map['type_id'] = Variable<String>(typeId.value);
    }
    if (gTop.present) {
      map['g_top'] = Variable<String>(gTop.value);
    }
    if (aTop.present) {
      map['a_top'] = Variable<String>(aTop.value);
    }
    if (auxiliaryJson.present) {
      map['auxiliary_json'] = Variable<String>(auxiliaryJson.value);
    }
    if (recoveryJson.present) {
      map['recovery_json'] = Variable<String>(recoveryJson.value);
    }
    if (appliedToProfile.present) {
      map['applied_to_profile'] = Variable<bool>(appliedToProfile.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestResultsCompanion(')
          ..write('id: $id, ')
          ..write('takenAt: $takenAt, ')
          ..write('answersJson: $answersJson, ')
          ..write('state: $state, ')
          ..write('typeId: $typeId, ')
          ..write('gTop: $gTop, ')
          ..write('aTop: $aTop, ')
          ..write('auxiliaryJson: $auxiliaryJson, ')
          ..write('recoveryJson: $recoveryJson, ')
          ..write('appliedToProfile: $appliedToProfile')
          ..write(')'))
        .toString();
  }
}

class $DialogueExposuresTable extends DialogueExposures
    with TableInfo<$DialogueExposuresTable, DialogueExposure> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DialogueExposuresTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dialogueIdMeta = const VerificationMeta(
    'dialogueId',
  );
  @override
  late final GeneratedColumn<String> dialogueId = GeneratedColumn<String>(
    'dialogue_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shownAtMeta = const VerificationMeta(
    'shownAt',
  );
  @override
  late final GeneratedColumn<DateTime> shownAt = GeneratedColumn<DateTime>(
    'shown_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intensityMeta = const VerificationMeta(
    'intensity',
  );
  @override
  late final GeneratedColumn<String> intensity = GeneratedColumn<String>(
    'intensity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dialogueId,
    shownAt,
    role,
    intensity,
    sessionId,
    localDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dialogue_exposures';
  @override
  VerificationContext validateIntegrity(
    Insertable<DialogueExposure> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('dialogue_id')) {
      context.handle(
        _dialogueIdMeta,
        dialogueId.isAcceptableOrUnknown(data['dialogue_id']!, _dialogueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dialogueIdMeta);
    }
    if (data.containsKey('shown_at')) {
      context.handle(
        _shownAtMeta,
        shownAt.isAcceptableOrUnknown(data['shown_at']!, _shownAtMeta),
      );
    } else if (isInserting) {
      context.missing(_shownAtMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('intensity')) {
      context.handle(
        _intensityMeta,
        intensity.isAcceptableOrUnknown(data['intensity']!, _intensityMeta),
      );
    } else if (isInserting) {
      context.missing(_intensityMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DialogueExposure map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DialogueExposure(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dialogueId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dialogue_id'],
      )!,
      shownAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}shown_at'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      intensity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intensity'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
    );
  }

  @override
  $DialogueExposuresTable createAlias(String alias) {
    return $DialogueExposuresTable(attachedDatabase, alias);
  }
}

class DialogueExposure extends DataClass
    implements Insertable<DialogueExposure> {
  final int id;
  final String dialogueId;
  final DateTime shownAt;
  final String role;
  final String intensity;
  final int? sessionId;

  /// 하루 단위 제한 계산 키.
  final String localDate;
  const DialogueExposure({
    required this.id,
    required this.dialogueId,
    required this.shownAt,
    required this.role,
    required this.intensity,
    this.sessionId,
    required this.localDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['dialogue_id'] = Variable<String>(dialogueId);
    map['shown_at'] = Variable<DateTime>(shownAt);
    map['role'] = Variable<String>(role);
    map['intensity'] = Variable<String>(intensity);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    map['local_date'] = Variable<String>(localDate);
    return map;
  }

  DialogueExposuresCompanion toCompanion(bool nullToAbsent) {
    return DialogueExposuresCompanion(
      id: Value(id),
      dialogueId: Value(dialogueId),
      shownAt: Value(shownAt),
      role: Value(role),
      intensity: Value(intensity),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      localDate: Value(localDate),
    );
  }

  factory DialogueExposure.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DialogueExposure(
      id: serializer.fromJson<int>(json['id']),
      dialogueId: serializer.fromJson<String>(json['dialogueId']),
      shownAt: serializer.fromJson<DateTime>(json['shownAt']),
      role: serializer.fromJson<String>(json['role']),
      intensity: serializer.fromJson<String>(json['intensity']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      localDate: serializer.fromJson<String>(json['localDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dialogueId': serializer.toJson<String>(dialogueId),
      'shownAt': serializer.toJson<DateTime>(shownAt),
      'role': serializer.toJson<String>(role),
      'intensity': serializer.toJson<String>(intensity),
      'sessionId': serializer.toJson<int?>(sessionId),
      'localDate': serializer.toJson<String>(localDate),
    };
  }

  DialogueExposure copyWith({
    int? id,
    String? dialogueId,
    DateTime? shownAt,
    String? role,
    String? intensity,
    Value<int?> sessionId = const Value.absent(),
    String? localDate,
  }) => DialogueExposure(
    id: id ?? this.id,
    dialogueId: dialogueId ?? this.dialogueId,
    shownAt: shownAt ?? this.shownAt,
    role: role ?? this.role,
    intensity: intensity ?? this.intensity,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    localDate: localDate ?? this.localDate,
  );
  DialogueExposure copyWithCompanion(DialogueExposuresCompanion data) {
    return DialogueExposure(
      id: data.id.present ? data.id.value : this.id,
      dialogueId: data.dialogueId.present
          ? data.dialogueId.value
          : this.dialogueId,
      shownAt: data.shownAt.present ? data.shownAt.value : this.shownAt,
      role: data.role.present ? data.role.value : this.role,
      intensity: data.intensity.present ? data.intensity.value : this.intensity,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DialogueExposure(')
          ..write('id: $id, ')
          ..write('dialogueId: $dialogueId, ')
          ..write('shownAt: $shownAt, ')
          ..write('role: $role, ')
          ..write('intensity: $intensity, ')
          ..write('sessionId: $sessionId, ')
          ..write('localDate: $localDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dialogueId,
    shownAt,
    role,
    intensity,
    sessionId,
    localDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DialogueExposure &&
          other.id == this.id &&
          other.dialogueId == this.dialogueId &&
          other.shownAt == this.shownAt &&
          other.role == this.role &&
          other.intensity == this.intensity &&
          other.sessionId == this.sessionId &&
          other.localDate == this.localDate);
}

class DialogueExposuresCompanion extends UpdateCompanion<DialogueExposure> {
  final Value<int> id;
  final Value<String> dialogueId;
  final Value<DateTime> shownAt;
  final Value<String> role;
  final Value<String> intensity;
  final Value<int?> sessionId;
  final Value<String> localDate;
  const DialogueExposuresCompanion({
    this.id = const Value.absent(),
    this.dialogueId = const Value.absent(),
    this.shownAt = const Value.absent(),
    this.role = const Value.absent(),
    this.intensity = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.localDate = const Value.absent(),
  });
  DialogueExposuresCompanion.insert({
    this.id = const Value.absent(),
    required String dialogueId,
    required DateTime shownAt,
    required String role,
    required String intensity,
    this.sessionId = const Value.absent(),
    required String localDate,
  }) : dialogueId = Value(dialogueId),
       shownAt = Value(shownAt),
       role = Value(role),
       intensity = Value(intensity),
       localDate = Value(localDate);
  static Insertable<DialogueExposure> custom({
    Expression<int>? id,
    Expression<String>? dialogueId,
    Expression<DateTime>? shownAt,
    Expression<String>? role,
    Expression<String>? intensity,
    Expression<int>? sessionId,
    Expression<String>? localDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dialogueId != null) 'dialogue_id': dialogueId,
      if (shownAt != null) 'shown_at': shownAt,
      if (role != null) 'role': role,
      if (intensity != null) 'intensity': intensity,
      if (sessionId != null) 'session_id': sessionId,
      if (localDate != null) 'local_date': localDate,
    });
  }

  DialogueExposuresCompanion copyWith({
    Value<int>? id,
    Value<String>? dialogueId,
    Value<DateTime>? shownAt,
    Value<String>? role,
    Value<String>? intensity,
    Value<int?>? sessionId,
    Value<String>? localDate,
  }) {
    return DialogueExposuresCompanion(
      id: id ?? this.id,
      dialogueId: dialogueId ?? this.dialogueId,
      shownAt: shownAt ?? this.shownAt,
      role: role ?? this.role,
      intensity: intensity ?? this.intensity,
      sessionId: sessionId ?? this.sessionId,
      localDate: localDate ?? this.localDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dialogueId.present) {
      map['dialogue_id'] = Variable<String>(dialogueId.value);
    }
    if (shownAt.present) {
      map['shown_at'] = Variable<DateTime>(shownAt.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (intensity.present) {
      map['intensity'] = Variable<String>(intensity.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DialogueExposuresCompanion(')
          ..write('id: $id, ')
          ..write('dialogueId: $dialogueId, ')
          ..write('shownAt: $shownAt, ')
          ..write('role: $role, ')
          ..write('intensity: $intensity, ')
          ..write('sessionId: $sessionId, ')
          ..write('localDate: $localDate')
          ..write(')'))
        .toString();
  }
}

class $AnalyticsEventsTable extends AnalyticsEvents
    with TableInfo<$AnalyticsEventsTable, AnalyticsEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnalyticsEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _paramsJsonMeta = const VerificationMeta(
    'paramsJson',
  );
  @override
  late final GeneratedColumn<String> paramsJson = GeneratedColumn<String>(
    'params_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, paramsJson, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'analytics_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnalyticsEvent> instance, {
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
    if (data.containsKey('params_json')) {
      context.handle(
        _paramsJsonMeta,
        paramsJson.isAcceptableOrUnknown(data['params_json']!, _paramsJsonMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnalyticsEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnalyticsEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      paramsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}params_json'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $AnalyticsEventsTable createAlias(String alias) {
    return $AnalyticsEventsTable(attachedDatabase, alias);
  }
}

class AnalyticsEvent extends DataClass implements Insertable<AnalyticsEvent> {
  final int id;
  final String name;
  final String paramsJson;
  final DateTime at;
  const AnalyticsEvent({
    required this.id,
    required this.name,
    required this.paramsJson,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['params_json'] = Variable<String>(paramsJson);
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  AnalyticsEventsCompanion toCompanion(bool nullToAbsent) {
    return AnalyticsEventsCompanion(
      id: Value(id),
      name: Value(name),
      paramsJson: Value(paramsJson),
      at: Value(at),
    );
  }

  factory AnalyticsEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnalyticsEvent(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      paramsJson: serializer.fromJson<String>(json['paramsJson']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'paramsJson': serializer.toJson<String>(paramsJson),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  AnalyticsEvent copyWith({
    int? id,
    String? name,
    String? paramsJson,
    DateTime? at,
  }) => AnalyticsEvent(
    id: id ?? this.id,
    name: name ?? this.name,
    paramsJson: paramsJson ?? this.paramsJson,
    at: at ?? this.at,
  );
  AnalyticsEvent copyWithCompanion(AnalyticsEventsCompanion data) {
    return AnalyticsEvent(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      paramsJson: data.paramsJson.present
          ? data.paramsJson.value
          : this.paramsJson,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnalyticsEvent(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('paramsJson: $paramsJson, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, paramsJson, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnalyticsEvent &&
          other.id == this.id &&
          other.name == this.name &&
          other.paramsJson == this.paramsJson &&
          other.at == this.at);
}

class AnalyticsEventsCompanion extends UpdateCompanion<AnalyticsEvent> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> paramsJson;
  final Value<DateTime> at;
  const AnalyticsEventsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.paramsJson = const Value.absent(),
    this.at = const Value.absent(),
  });
  AnalyticsEventsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.paramsJson = const Value.absent(),
    required DateTime at,
  }) : name = Value(name),
       at = Value(at);
  static Insertable<AnalyticsEvent> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? paramsJson,
    Expression<DateTime>? at,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (paramsJson != null) 'params_json': paramsJson,
      if (at != null) 'at': at,
    });
  }

  AnalyticsEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? paramsJson,
    Value<DateTime>? at,
  }) {
    return AnalyticsEventsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      paramsJson: paramsJson ?? this.paramsJson,
      at: at ?? this.at,
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
    if (paramsJson.present) {
      map['params_json'] = Variable<String>(paramsJson.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnalyticsEventsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('paramsJson: $paramsJson, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }
}

class $WorriesTable extends Worries with TableInfo<$WorriesTable, Worry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _burnedAtMeta = const VerificationMeta(
    'burnedAt',
  );
  @override
  late final GeneratedColumn<DateTime> burnedAt = GeneratedColumn<DateTime>(
    'burned_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seonsaLineMeta = const VerificationMeta(
    'seonsaLine',
  );
  @override
  late final GeneratedColumn<String> seonsaLine = GeneratedColumn<String>(
    'seonsa_line',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _acceptedMeta = const VerificationMeta(
    'accepted',
  );
  @override
  late final GeneratedColumn<bool> accepted = GeneratedColumn<bool>(
    'accepted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("accepted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rebuttalCountMeta = const VerificationMeta(
    'rebuttalCount',
  );
  @override
  late final GeneratedColumn<int> rebuttalCount = GeneratedColumn<int>(
    'rebuttal_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _safetyFlaggedMeta = const VerificationMeta(
    'safetyFlagged',
  );
  @override
  late final GeneratedColumn<bool> safetyFlagged = GeneratedColumn<bool>(
    'safety_flagged',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("safety_flagged" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    body,
    kind,
    createdAt,
    burnedAt,
    seonsaLine,
    accepted,
    rebuttalCount,
    safetyFlagged,
    localDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'worries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Worry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
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
    if (data.containsKey('burned_at')) {
      context.handle(
        _burnedAtMeta,
        burnedAt.isAcceptableOrUnknown(data['burned_at']!, _burnedAtMeta),
      );
    }
    if (data.containsKey('seonsa_line')) {
      context.handle(
        _seonsaLineMeta,
        seonsaLine.isAcceptableOrUnknown(data['seonsa_line']!, _seonsaLineMeta),
      );
    }
    if (data.containsKey('accepted')) {
      context.handle(
        _acceptedMeta,
        accepted.isAcceptableOrUnknown(data['accepted']!, _acceptedMeta),
      );
    }
    if (data.containsKey('rebuttal_count')) {
      context.handle(
        _rebuttalCountMeta,
        rebuttalCount.isAcceptableOrUnknown(
          data['rebuttal_count']!,
          _rebuttalCountMeta,
        ),
      );
    }
    if (data.containsKey('safety_flagged')) {
      context.handle(
        _safetyFlaggedMeta,
        safetyFlagged.isAcceptableOrUnknown(
          data['safety_flagged']!,
          _safetyFlaggedMeta,
        ),
      );
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Worry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Worry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      burnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}burned_at'],
      ),
      seonsaLine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seonsa_line'],
      ),
      accepted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}accepted'],
      )!,
      rebuttalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rebuttal_count'],
      )!,
      safetyFlagged: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}safety_flagged'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
    );
  }

  @override
  $WorriesTable createAlias(String alias) {
    return $WorriesTable(attachedDatabase, alias);
  }
}

class Worry extends DataClass implements Insertable<Worry> {
  final int id;

  /// 번뇌 한 줄. Drift의 Table.text와 이름이 겹쳐 body로 둔다.
  final String body;

  /// 탐(貪) / 진(嗔) / 치(癡). 강제하지 않는다.
  final String? kind;
  final DateTime createdAt;
  final DateTime? burnedAt;

  /// 죽비 — 선사가 돌려준 한마디.
  final String? seonsaLine;

  /// 「인정. 태운다」를 눌렀는가. 반박하면 죽비가 한 번 더 온다.
  final bool accepted;
  final int rebuttalCount;

  /// 위기 신호 감지 여부. 감지되면 선사 대사 없이 안내만 간다 (SA-1).
  final bool safetyFlagged;
  final String localDate;
  const Worry({
    required this.id,
    required this.body,
    this.kind,
    required this.createdAt,
    this.burnedAt,
    this.seonsaLine,
    required this.accepted,
    required this.rebuttalCount,
    required this.safetyFlagged,
    required this.localDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || kind != null) {
      map['kind'] = Variable<String>(kind);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || burnedAt != null) {
      map['burned_at'] = Variable<DateTime>(burnedAt);
    }
    if (!nullToAbsent || seonsaLine != null) {
      map['seonsa_line'] = Variable<String>(seonsaLine);
    }
    map['accepted'] = Variable<bool>(accepted);
    map['rebuttal_count'] = Variable<int>(rebuttalCount);
    map['safety_flagged'] = Variable<bool>(safetyFlagged);
    map['local_date'] = Variable<String>(localDate);
    return map;
  }

  WorriesCompanion toCompanion(bool nullToAbsent) {
    return WorriesCompanion(
      id: Value(id),
      body: Value(body),
      kind: kind == null && nullToAbsent ? const Value.absent() : Value(kind),
      createdAt: Value(createdAt),
      burnedAt: burnedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(burnedAt),
      seonsaLine: seonsaLine == null && nullToAbsent
          ? const Value.absent()
          : Value(seonsaLine),
      accepted: Value(accepted),
      rebuttalCount: Value(rebuttalCount),
      safetyFlagged: Value(safetyFlagged),
      localDate: Value(localDate),
    );
  }

  factory Worry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Worry(
      id: serializer.fromJson<int>(json['id']),
      body: serializer.fromJson<String>(json['body']),
      kind: serializer.fromJson<String?>(json['kind']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      burnedAt: serializer.fromJson<DateTime?>(json['burnedAt']),
      seonsaLine: serializer.fromJson<String?>(json['seonsaLine']),
      accepted: serializer.fromJson<bool>(json['accepted']),
      rebuttalCount: serializer.fromJson<int>(json['rebuttalCount']),
      safetyFlagged: serializer.fromJson<bool>(json['safetyFlagged']),
      localDate: serializer.fromJson<String>(json['localDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'body': serializer.toJson<String>(body),
      'kind': serializer.toJson<String?>(kind),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'burnedAt': serializer.toJson<DateTime?>(burnedAt),
      'seonsaLine': serializer.toJson<String?>(seonsaLine),
      'accepted': serializer.toJson<bool>(accepted),
      'rebuttalCount': serializer.toJson<int>(rebuttalCount),
      'safetyFlagged': serializer.toJson<bool>(safetyFlagged),
      'localDate': serializer.toJson<String>(localDate),
    };
  }

  Worry copyWith({
    int? id,
    String? body,
    Value<String?> kind = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> burnedAt = const Value.absent(),
    Value<String?> seonsaLine = const Value.absent(),
    bool? accepted,
    int? rebuttalCount,
    bool? safetyFlagged,
    String? localDate,
  }) => Worry(
    id: id ?? this.id,
    body: body ?? this.body,
    kind: kind.present ? kind.value : this.kind,
    createdAt: createdAt ?? this.createdAt,
    burnedAt: burnedAt.present ? burnedAt.value : this.burnedAt,
    seonsaLine: seonsaLine.present ? seonsaLine.value : this.seonsaLine,
    accepted: accepted ?? this.accepted,
    rebuttalCount: rebuttalCount ?? this.rebuttalCount,
    safetyFlagged: safetyFlagged ?? this.safetyFlagged,
    localDate: localDate ?? this.localDate,
  );
  Worry copyWithCompanion(WorriesCompanion data) {
    return Worry(
      id: data.id.present ? data.id.value : this.id,
      body: data.body.present ? data.body.value : this.body,
      kind: data.kind.present ? data.kind.value : this.kind,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      burnedAt: data.burnedAt.present ? data.burnedAt.value : this.burnedAt,
      seonsaLine: data.seonsaLine.present
          ? data.seonsaLine.value
          : this.seonsaLine,
      accepted: data.accepted.present ? data.accepted.value : this.accepted,
      rebuttalCount: data.rebuttalCount.present
          ? data.rebuttalCount.value
          : this.rebuttalCount,
      safetyFlagged: data.safetyFlagged.present
          ? data.safetyFlagged.value
          : this.safetyFlagged,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Worry(')
          ..write('id: $id, ')
          ..write('body: $body, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt, ')
          ..write('burnedAt: $burnedAt, ')
          ..write('seonsaLine: $seonsaLine, ')
          ..write('accepted: $accepted, ')
          ..write('rebuttalCount: $rebuttalCount, ')
          ..write('safetyFlagged: $safetyFlagged, ')
          ..write('localDate: $localDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    body,
    kind,
    createdAt,
    burnedAt,
    seonsaLine,
    accepted,
    rebuttalCount,
    safetyFlagged,
    localDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Worry &&
          other.id == this.id &&
          other.body == this.body &&
          other.kind == this.kind &&
          other.createdAt == this.createdAt &&
          other.burnedAt == this.burnedAt &&
          other.seonsaLine == this.seonsaLine &&
          other.accepted == this.accepted &&
          other.rebuttalCount == this.rebuttalCount &&
          other.safetyFlagged == this.safetyFlagged &&
          other.localDate == this.localDate);
}

class WorriesCompanion extends UpdateCompanion<Worry> {
  final Value<int> id;
  final Value<String> body;
  final Value<String?> kind;
  final Value<DateTime> createdAt;
  final Value<DateTime?> burnedAt;
  final Value<String?> seonsaLine;
  final Value<bool> accepted;
  final Value<int> rebuttalCount;
  final Value<bool> safetyFlagged;
  final Value<String> localDate;
  const WorriesCompanion({
    this.id = const Value.absent(),
    this.body = const Value.absent(),
    this.kind = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.burnedAt = const Value.absent(),
    this.seonsaLine = const Value.absent(),
    this.accepted = const Value.absent(),
    this.rebuttalCount = const Value.absent(),
    this.safetyFlagged = const Value.absent(),
    this.localDate = const Value.absent(),
  });
  WorriesCompanion.insert({
    this.id = const Value.absent(),
    required String body,
    this.kind = const Value.absent(),
    required DateTime createdAt,
    this.burnedAt = const Value.absent(),
    this.seonsaLine = const Value.absent(),
    this.accepted = const Value.absent(),
    this.rebuttalCount = const Value.absent(),
    this.safetyFlagged = const Value.absent(),
    required String localDate,
  }) : body = Value(body),
       createdAt = Value(createdAt),
       localDate = Value(localDate);
  static Insertable<Worry> custom({
    Expression<int>? id,
    Expression<String>? body,
    Expression<String>? kind,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? burnedAt,
    Expression<String>? seonsaLine,
    Expression<bool>? accepted,
    Expression<int>? rebuttalCount,
    Expression<bool>? safetyFlagged,
    Expression<String>? localDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (body != null) 'body': body,
      if (kind != null) 'kind': kind,
      if (createdAt != null) 'created_at': createdAt,
      if (burnedAt != null) 'burned_at': burnedAt,
      if (seonsaLine != null) 'seonsa_line': seonsaLine,
      if (accepted != null) 'accepted': accepted,
      if (rebuttalCount != null) 'rebuttal_count': rebuttalCount,
      if (safetyFlagged != null) 'safety_flagged': safetyFlagged,
      if (localDate != null) 'local_date': localDate,
    });
  }

  WorriesCompanion copyWith({
    Value<int>? id,
    Value<String>? body,
    Value<String?>? kind,
    Value<DateTime>? createdAt,
    Value<DateTime?>? burnedAt,
    Value<String?>? seonsaLine,
    Value<bool>? accepted,
    Value<int>? rebuttalCount,
    Value<bool>? safetyFlagged,
    Value<String>? localDate,
  }) {
    return WorriesCompanion(
      id: id ?? this.id,
      body: body ?? this.body,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
      burnedAt: burnedAt ?? this.burnedAt,
      seonsaLine: seonsaLine ?? this.seonsaLine,
      accepted: accepted ?? this.accepted,
      rebuttalCount: rebuttalCount ?? this.rebuttalCount,
      safetyFlagged: safetyFlagged ?? this.safetyFlagged,
      localDate: localDate ?? this.localDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (burnedAt.present) {
      map['burned_at'] = Variable<DateTime>(burnedAt.value);
    }
    if (seonsaLine.present) {
      map['seonsa_line'] = Variable<String>(seonsaLine.value);
    }
    if (accepted.present) {
      map['accepted'] = Variable<bool>(accepted.value);
    }
    if (rebuttalCount.present) {
      map['rebuttal_count'] = Variable<int>(rebuttalCount.value);
    }
    if (safetyFlagged.present) {
      map['safety_flagged'] = Variable<bool>(safetyFlagged.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorriesCompanion(')
          ..write('id: $id, ')
          ..write('body: $body, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt, ')
          ..write('burnedAt: $burnedAt, ')
          ..write('seonsaLine: $seonsaLine, ')
          ..write('accepted: $accepted, ')
          ..write('rebuttalCount: $rebuttalCount, ')
          ..write('safetyFlagged: $safetyFlagged, ')
          ..write('localDate: $localDate')
          ..write(')'))
        .toString();
  }
}

class $TokenUnlocksTable extends TokenUnlocks
    with TableInfo<$TokenUnlocksTable, TokenUnlock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TokenUnlocksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _tokenIdMeta = const VerificationMeta(
    'tokenId',
  );
  @override
  late final GeneratedColumn<String> tokenId = GeneratedColumn<String>(
    'token_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seenMeta = const VerificationMeta('seen');
  @override
  late final GeneratedColumn<bool> seen = GeneratedColumn<bool>(
    'seen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("seen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, tokenId, unlockedAt, seen];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'token_unlocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TokenUnlock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('token_id')) {
      context.handle(
        _tokenIdMeta,
        tokenId.isAcceptableOrUnknown(data['token_id']!, _tokenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenIdMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    if (data.containsKey('seen')) {
      context.handle(
        _seenMeta,
        seen.isAcceptableOrUnknown(data['seen']!, _seenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TokenUnlock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TokenUnlock(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tokenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_id'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
      seen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}seen'],
      )!,
    );
  }

  @override
  $TokenUnlocksTable createAlias(String alias) {
    return $TokenUnlocksTable(attachedDatabase, alias);
  }
}

class TokenUnlock extends DataClass implements Insertable<TokenUnlock> {
  final int id;
  final String tokenId;
  final DateTime unlockedAt;

  /// 해제 연출을 이미 보여줬는가.
  final bool seen;
  const TokenUnlock({
    required this.id,
    required this.tokenId,
    required this.unlockedAt,
    required this.seen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['token_id'] = Variable<String>(tokenId);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    map['seen'] = Variable<bool>(seen);
    return map;
  }

  TokenUnlocksCompanion toCompanion(bool nullToAbsent) {
    return TokenUnlocksCompanion(
      id: Value(id),
      tokenId: Value(tokenId),
      unlockedAt: Value(unlockedAt),
      seen: Value(seen),
    );
  }

  factory TokenUnlock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TokenUnlock(
      id: serializer.fromJson<int>(json['id']),
      tokenId: serializer.fromJson<String>(json['tokenId']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
      seen: serializer.fromJson<bool>(json['seen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tokenId': serializer.toJson<String>(tokenId),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
      'seen': serializer.toJson<bool>(seen),
    };
  }

  TokenUnlock copyWith({
    int? id,
    String? tokenId,
    DateTime? unlockedAt,
    bool? seen,
  }) => TokenUnlock(
    id: id ?? this.id,
    tokenId: tokenId ?? this.tokenId,
    unlockedAt: unlockedAt ?? this.unlockedAt,
    seen: seen ?? this.seen,
  );
  TokenUnlock copyWithCompanion(TokenUnlocksCompanion data) {
    return TokenUnlock(
      id: data.id.present ? data.id.value : this.id,
      tokenId: data.tokenId.present ? data.tokenId.value : this.tokenId,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
      seen: data.seen.present ? data.seen.value : this.seen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TokenUnlock(')
          ..write('id: $id, ')
          ..write('tokenId: $tokenId, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('seen: $seen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tokenId, unlockedAt, seen);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TokenUnlock &&
          other.id == this.id &&
          other.tokenId == this.tokenId &&
          other.unlockedAt == this.unlockedAt &&
          other.seen == this.seen);
}

class TokenUnlocksCompanion extends UpdateCompanion<TokenUnlock> {
  final Value<int> id;
  final Value<String> tokenId;
  final Value<DateTime> unlockedAt;
  final Value<bool> seen;
  const TokenUnlocksCompanion({
    this.id = const Value.absent(),
    this.tokenId = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.seen = const Value.absent(),
  });
  TokenUnlocksCompanion.insert({
    this.id = const Value.absent(),
    required String tokenId,
    required DateTime unlockedAt,
    this.seen = const Value.absent(),
  }) : tokenId = Value(tokenId),
       unlockedAt = Value(unlockedAt);
  static Insertable<TokenUnlock> custom({
    Expression<int>? id,
    Expression<String>? tokenId,
    Expression<DateTime>? unlockedAt,
    Expression<bool>? seen,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tokenId != null) 'token_id': tokenId,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (seen != null) 'seen': seen,
    });
  }

  TokenUnlocksCompanion copyWith({
    Value<int>? id,
    Value<String>? tokenId,
    Value<DateTime>? unlockedAt,
    Value<bool>? seen,
  }) {
    return TokenUnlocksCompanion(
      id: id ?? this.id,
      tokenId: tokenId ?? this.tokenId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      seen: seen ?? this.seen,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tokenId.present) {
      map['token_id'] = Variable<String>(tokenId.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (seen.present) {
      map['seen'] = Variable<bool>(seen.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TokenUnlocksCompanion(')
          ..write('id: $id, ')
          ..write('tokenId: $tokenId, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('seen: $seen')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $DayRecordsTable dayRecords = $DayRecordsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $TestResultsTable testResults = $TestResultsTable(this);
  late final $DialogueExposuresTable dialogueExposures =
      $DialogueExposuresTable(this);
  late final $AnalyticsEventsTable analyticsEvents = $AnalyticsEventsTable(
    this,
  );
  late final $WorriesTable worries = $WorriesTable(this);
  late final $TokenUnlocksTable tokenUnlocks = $TokenUnlocksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sessions,
    dayRecords,
    profiles,
    testResults,
    dialogueExposures,
    analyticsEvents,
    worries,
    tokenUnlocks,
  ];
}

typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  required int targetSec,
  Value<int> practicedSec,
  Value<String?> outcome,
  Value<String> detection,
  Value<bool> audioOn,
  Value<String?> worryText,
  Value<String?> worryChip,
  Value<bool> repeatFlag,
  Value<bool> safetyFlagged,
  required String localDate,
  Value<bool> isActive,
  Value<String> excludedJson,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<int> targetSec,
  Value<int> practicedSec,
  Value<String?> outcome,
  Value<String> detection,
  Value<bool> audioOn,
  Value<String?> worryText,
  Value<String?> worryChip,
  Value<bool> repeatFlag,
  Value<bool> safetyFlagged,
  Value<String> localDate,
  Value<bool> isActive,
  Value<String> excludedJson,
});

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

  ColumnFilters<int> get targetSec => $composableBuilder(
    column: $table.targetSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get practicedSec => $composableBuilder(
    column: $table.practicedSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detection => $composableBuilder(
    column: $table.detection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get audioOn => $composableBuilder(
    column: $table.audioOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get worryText => $composableBuilder(
    column: $table.worryText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get worryChip => $composableBuilder(
    column: $table.worryChip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get repeatFlag => $composableBuilder(
    column: $table.repeatFlag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get safetyFlagged => $composableBuilder(
    column: $table.safetyFlagged,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get excludedJson => $composableBuilder(
    column: $table.excludedJson,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<int> get targetSec => $composableBuilder(
    column: $table.targetSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get practicedSec => $composableBuilder(
    column: $table.practicedSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detection => $composableBuilder(
    column: $table.detection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get audioOn => $composableBuilder(
    column: $table.audioOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get worryText => $composableBuilder(
    column: $table.worryText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get worryChip => $composableBuilder(
    column: $table.worryChip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get repeatFlag => $composableBuilder(
    column: $table.repeatFlag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get safetyFlagged => $composableBuilder(
    column: $table.safetyFlagged,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get excludedJson => $composableBuilder(
    column: $table.excludedJson,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<int> get targetSec =>
      $composableBuilder(column: $table.targetSec, builder: (column) => column);

  GeneratedColumn<int> get practicedSec => $composableBuilder(
    column: $table.practicedSec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get detection =>
      $composableBuilder(column: $table.detection, builder: (column) => column);

  GeneratedColumn<bool> get audioOn =>
      $composableBuilder(column: $table.audioOn, builder: (column) => column);

  GeneratedColumn<String> get worryText =>
      $composableBuilder(column: $table.worryText, builder: (column) => column);

  GeneratedColumn<String> get worryChip =>
      $composableBuilder(column: $table.worryChip, builder: (column) => column);

  GeneratedColumn<bool> get repeatFlag => $composableBuilder(
    column: $table.repeatFlag,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get safetyFlagged => $composableBuilder(
    column: $table.safetyFlagged,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get excludedJson => $composableBuilder(
    column: $table.excludedJson,
    builder: (column) => column,
  );
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
          Session,
          PrefetchHooks Function()
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
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> targetSec = const Value.absent(),
                Value<int> practicedSec = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                Value<String> detection = const Value.absent(),
                Value<bool> audioOn = const Value.absent(),
                Value<String?> worryText = const Value.absent(),
                Value<String?> worryChip = const Value.absent(),
                Value<bool> repeatFlag = const Value.absent(),
                Value<bool> safetyFlagged = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> excludedJson = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                targetSec: targetSec,
                practicedSec: practicedSec,
                outcome: outcome,
                detection: detection,
                audioOn: audioOn,
                worryText: worryText,
                worryChip: worryChip,
                repeatFlag: repeatFlag,
                safetyFlagged: safetyFlagged,
                localDate: localDate,
                isActive: isActive,
                excludedJson: excludedJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                required int targetSec,
                Value<int> practicedSec = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                Value<String> detection = const Value.absent(),
                Value<bool> audioOn = const Value.absent(),
                Value<String?> worryText = const Value.absent(),
                Value<String?> worryChip = const Value.absent(),
                Value<bool> repeatFlag = const Value.absent(),
                Value<bool> safetyFlagged = const Value.absent(),
                required String localDate,
                Value<bool> isActive = const Value.absent(),
                Value<String> excludedJson = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                targetSec: targetSec,
                practicedSec: practicedSec,
                outcome: outcome,
                detection: detection,
                audioOn: audioOn,
                worryText: worryText,
                worryChip: worryChip,
                repeatFlag: repeatFlag,
                safetyFlagged: safetyFlagged,
                localDate: localDate,
                isActive: isActive,
                excludedJson: excludedJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, Session>(table),
                  BaseReferences<_$AppDatabase, $SessionsTable, Session>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
      Session,
      PrefetchHooks Function()
    >;
typedef $$DayRecordsTableCreateCompanionBuilder = DayRecordsCompanion Function({
  required String localDate,
  Value<int> validSessionCount,
  Value<DateTime?> firstValidAt,
  Value<bool> credited,
  Value<int> rowid,
});
typedef $$DayRecordsTableUpdateCompanionBuilder = DayRecordsCompanion Function({
  Value<String> localDate,
  Value<int> validSessionCount,
  Value<DateTime?> firstValidAt,
  Value<bool> credited,
  Value<int> rowid,
});

class $$DayRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $DayRecordsTable> {
  $$DayRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get validSessionCount => $composableBuilder(
    column: $table.validSessionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstValidAt => $composableBuilder(
    column: $table.firstValidAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get credited => $composableBuilder(
    column: $table.credited,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $DayRecordsTable> {
  $$DayRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get validSessionCount => $composableBuilder(
    column: $table.validSessionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstValidAt => $composableBuilder(
    column: $table.firstValidAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get credited => $composableBuilder(
    column: $table.credited,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayRecordsTable> {
  $$DayRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<int> get validSessionCount => $composableBuilder(
    column: $table.validSessionCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstValidAt => $composableBuilder(
    column: $table.firstValidAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get credited =>
      $composableBuilder(column: $table.credited, builder: (column) => column);
}

class $$DayRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DayRecordsTable,
          DayRecord,
          $$DayRecordsTableFilterComposer,
          $$DayRecordsTableOrderingComposer,
          $$DayRecordsTableAnnotationComposer,
          $$DayRecordsTableCreateCompanionBuilder,
          $$DayRecordsTableUpdateCompanionBuilder,
          (
            DayRecord,
            BaseReferences<_$AppDatabase, $DayRecordsTable, DayRecord>,
          ),
          DayRecord,
          PrefetchHooks Function()
        > {
  $$DayRecordsTableTableManager(_$AppDatabase db, $DayRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localDate = const Value.absent(),
                Value<int> validSessionCount = const Value.absent(),
                Value<DateTime?> firstValidAt = const Value.absent(),
                Value<bool> credited = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayRecordsCompanion(
                localDate: localDate,
                validSessionCount: validSessionCount,
                firstValidAt: firstValidAt,
                credited: credited,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localDate,
                Value<int> validSessionCount = const Value.absent(),
                Value<DateTime?> firstValidAt = const Value.absent(),
                Value<bool> credited = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayRecordsCompanion.insert(
                localDate: localDate,
                validSessionCount: validSessionCount,
                firstValidAt: firstValidAt,
                credited: credited,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DayRecordsTable, DayRecord>(table),
                  BaseReferences<_$AppDatabase, $DayRecordsTable, DayRecord>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DayRecordsTable,
      DayRecord,
      $$DayRecordsTableFilterComposer,
      $$DayRecordsTableOrderingComposer,
      $$DayRecordsTableAnnotationComposer,
      $$DayRecordsTableCreateCompanionBuilder,
      $$DayRecordsTableUpdateCompanionBuilder,
      (DayRecord, BaseReferences<_$AppDatabase, $DayRecordsTable, DayRecord>),
      DayRecord,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<int> creditedDays,
  Value<int> templeStage,
  Value<String?> dharmaFirst,
  Value<int> dharmaStage,
  Value<String> character,
  Value<String?> recoveryPref,
  Value<int> defaultsAppliedCount,
  Value<String> settingsJson,
  Value<String> consentsJson,
  Value<DateTime?> firstLaunchAt,
  Value<DateTime?> lastVisitAt,
  Value<bool> characterOnboardShown,
  Value<String?> leavesClearedDate,
  Value<String?> dharmaName,
  Value<int> dharmaRank,
  Value<String?> avatarPath,
  Value<DateTime?> ordainedAt,
  Value<int> merit,
  Value<int> burnedCount,
  Value<int> bowCount,
  Value<int> faceDownSec,
  Value<String> equipJson,
  Value<String> ownedItemsJson,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<int> creditedDays,
  Value<int> templeStage,
  Value<String?> dharmaFirst,
  Value<int> dharmaStage,
  Value<String> character,
  Value<String?> recoveryPref,
  Value<int> defaultsAppliedCount,
  Value<String> settingsJson,
  Value<String> consentsJson,
  Value<DateTime?> firstLaunchAt,
  Value<DateTime?> lastVisitAt,
  Value<bool> characterOnboardShown,
  Value<String?> leavesClearedDate,
  Value<String?> dharmaName,
  Value<int> dharmaRank,
  Value<String?> avatarPath,
  Value<DateTime?> ordainedAt,
  Value<int> merit,
  Value<int> burnedCount,
  Value<int> bowCount,
  Value<int> faceDownSec,
  Value<String> equipJson,
  Value<String> ownedItemsJson,
});

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
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

  ColumnFilters<int> get creditedDays => $composableBuilder(
    column: $table.creditedDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get templeStage => $composableBuilder(
    column: $table.templeStage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dharmaFirst => $composableBuilder(
    column: $table.dharmaFirst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dharmaStage => $composableBuilder(
    column: $table.dharmaStage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recoveryPref => $composableBuilder(
    column: $table.recoveryPref,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultsAppliedCount => $composableBuilder(
    column: $table.defaultsAppliedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consentsJson => $composableBuilder(
    column: $table.consentsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstLaunchAt => $composableBuilder(
    column: $table.firstLaunchAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastVisitAt => $composableBuilder(
    column: $table.lastVisitAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get characterOnboardShown => $composableBuilder(
    column: $table.characterOnboardShown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leavesClearedDate => $composableBuilder(
    column: $table.leavesClearedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dharmaName => $composableBuilder(
    column: $table.dharmaName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dharmaRank => $composableBuilder(
    column: $table.dharmaRank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ordainedAt => $composableBuilder(
    column: $table.ordainedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get merit => $composableBuilder(
    column: $table.merit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get burnedCount => $composableBuilder(
    column: $table.burnedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bowCount => $composableBuilder(
    column: $table.bowCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get faceDownSec => $composableBuilder(
    column: $table.faceDownSec,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipJson => $composableBuilder(
    column: $table.equipJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownedItemsJson => $composableBuilder(
    column: $table.ownedItemsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
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

  ColumnOrderings<int> get creditedDays => $composableBuilder(
    column: $table.creditedDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get templeStage => $composableBuilder(
    column: $table.templeStage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dharmaFirst => $composableBuilder(
    column: $table.dharmaFirst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dharmaStage => $composableBuilder(
    column: $table.dharmaStage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get character => $composableBuilder(
    column: $table.character,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recoveryPref => $composableBuilder(
    column: $table.recoveryPref,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultsAppliedCount => $composableBuilder(
    column: $table.defaultsAppliedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consentsJson => $composableBuilder(
    column: $table.consentsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstLaunchAt => $composableBuilder(
    column: $table.firstLaunchAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastVisitAt => $composableBuilder(
    column: $table.lastVisitAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get characterOnboardShown => $composableBuilder(
    column: $table.characterOnboardShown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leavesClearedDate => $composableBuilder(
    column: $table.leavesClearedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dharmaName => $composableBuilder(
    column: $table.dharmaName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dharmaRank => $composableBuilder(
    column: $table.dharmaRank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ordainedAt => $composableBuilder(
    column: $table.ordainedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get merit => $composableBuilder(
    column: $table.merit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get burnedCount => $composableBuilder(
    column: $table.burnedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bowCount => $composableBuilder(
    column: $table.bowCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get faceDownSec => $composableBuilder(
    column: $table.faceDownSec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipJson => $composableBuilder(
    column: $table.equipJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownedItemsJson => $composableBuilder(
    column: $table.ownedItemsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get creditedDays => $composableBuilder(
    column: $table.creditedDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get templeStage => $composableBuilder(
    column: $table.templeStage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dharmaFirst => $composableBuilder(
    column: $table.dharmaFirst,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dharmaStage => $composableBuilder(
    column: $table.dharmaStage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get character =>
      $composableBuilder(column: $table.character, builder: (column) => column);

  GeneratedColumn<String> get recoveryPref => $composableBuilder(
    column: $table.recoveryPref,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultsAppliedCount => $composableBuilder(
    column: $table.defaultsAppliedCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get consentsJson => $composableBuilder(
    column: $table.consentsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstLaunchAt => $composableBuilder(
    column: $table.firstLaunchAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastVisitAt => $composableBuilder(
    column: $table.lastVisitAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get characterOnboardShown => $composableBuilder(
    column: $table.characterOnboardShown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get leavesClearedDate => $composableBuilder(
    column: $table.leavesClearedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dharmaName => $composableBuilder(
    column: $table.dharmaName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dharmaRank => $composableBuilder(
    column: $table.dharmaRank,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get ordainedAt => $composableBuilder(
    column: $table.ordainedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get merit =>
      $composableBuilder(column: $table.merit, builder: (column) => column);

  GeneratedColumn<int> get burnedCount => $composableBuilder(
    column: $table.burnedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bowCount =>
      $composableBuilder(column: $table.bowCount, builder: (column) => column);

  GeneratedColumn<int> get faceDownSec => $composableBuilder(
    column: $table.faceDownSec,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equipJson =>
      $composableBuilder(column: $table.equipJson, builder: (column) => column);

  GeneratedColumn<String> get ownedItemsJson => $composableBuilder(
    column: $table.ownedItemsJson,
    builder: (column) => column,
  );
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> creditedDays = const Value.absent(),
                Value<int> templeStage = const Value.absent(),
                Value<String?> dharmaFirst = const Value.absent(),
                Value<int> dharmaStage = const Value.absent(),
                Value<String> character = const Value.absent(),
                Value<String?> recoveryPref = const Value.absent(),
                Value<int> defaultsAppliedCount = const Value.absent(),
                Value<String> settingsJson = const Value.absent(),
                Value<String> consentsJson = const Value.absent(),
                Value<DateTime?> firstLaunchAt = const Value.absent(),
                Value<DateTime?> lastVisitAt = const Value.absent(),
                Value<bool> characterOnboardShown = const Value.absent(),
                Value<String?> leavesClearedDate = const Value.absent(),
                Value<String?> dharmaName = const Value.absent(),
                Value<int> dharmaRank = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<DateTime?> ordainedAt = const Value.absent(),
                Value<int> merit = const Value.absent(),
                Value<int> burnedCount = const Value.absent(),
                Value<int> bowCount = const Value.absent(),
                Value<int> faceDownSec = const Value.absent(),
                Value<String> equipJson = const Value.absent(),
                Value<String> ownedItemsJson = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                creditedDays: creditedDays,
                templeStage: templeStage,
                dharmaFirst: dharmaFirst,
                dharmaStage: dharmaStage,
                character: character,
                recoveryPref: recoveryPref,
                defaultsAppliedCount: defaultsAppliedCount,
                settingsJson: settingsJson,
                consentsJson: consentsJson,
                firstLaunchAt: firstLaunchAt,
                lastVisitAt: lastVisitAt,
                characterOnboardShown: characterOnboardShown,
                leavesClearedDate: leavesClearedDate,
                dharmaName: dharmaName,
                dharmaRank: dharmaRank,
                avatarPath: avatarPath,
                ordainedAt: ordainedAt,
                merit: merit,
                burnedCount: burnedCount,
                bowCount: bowCount,
                faceDownSec: faceDownSec,
                equipJson: equipJson,
                ownedItemsJson: ownedItemsJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> creditedDays = const Value.absent(),
                Value<int> templeStage = const Value.absent(),
                Value<String?> dharmaFirst = const Value.absent(),
                Value<int> dharmaStage = const Value.absent(),
                Value<String> character = const Value.absent(),
                Value<String?> recoveryPref = const Value.absent(),
                Value<int> defaultsAppliedCount = const Value.absent(),
                Value<String> settingsJson = const Value.absent(),
                Value<String> consentsJson = const Value.absent(),
                Value<DateTime?> firstLaunchAt = const Value.absent(),
                Value<DateTime?> lastVisitAt = const Value.absent(),
                Value<bool> characterOnboardShown = const Value.absent(),
                Value<String?> leavesClearedDate = const Value.absent(),
                Value<String?> dharmaName = const Value.absent(),
                Value<int> dharmaRank = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<DateTime?> ordainedAt = const Value.absent(),
                Value<int> merit = const Value.absent(),
                Value<int> burnedCount = const Value.absent(),
                Value<int> bowCount = const Value.absent(),
                Value<int> faceDownSec = const Value.absent(),
                Value<String> equipJson = const Value.absent(),
                Value<String> ownedItemsJson = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                creditedDays: creditedDays,
                templeStage: templeStage,
                dharmaFirst: dharmaFirst,
                dharmaStage: dharmaStage,
                character: character,
                recoveryPref: recoveryPref,
                defaultsAppliedCount: defaultsAppliedCount,
                settingsJson: settingsJson,
                consentsJson: consentsJson,
                firstLaunchAt: firstLaunchAt,
                lastVisitAt: lastVisitAt,
                characterOnboardShown: characterOnboardShown,
                leavesClearedDate: leavesClearedDate,
                dharmaName: dharmaName,
                dharmaRank: dharmaRank,
                avatarPath: avatarPath,
                ordainedAt: ordainedAt,
                merit: merit,
                burnedCount: burnedCount,
                bowCount: bowCount,
                faceDownSec: faceDownSec,
                equipJson: equipJson,
                ownedItemsJson: ownedItemsJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, Profile>(table),
                  BaseReferences<_$AppDatabase, $ProfilesTable, Profile>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$TestResultsTableCreateCompanionBuilder =
    TestResultsCompanion Function({
      Value<int> id,
      required DateTime takenAt,
      required String answersJson,
      required String state,
      Value<String?> typeId,
      Value<String?> gTop,
      Value<String?> aTop,
      Value<String> auxiliaryJson,
      Value<String> recoveryJson,
      Value<bool> appliedToProfile,
    });
typedef $$TestResultsTableUpdateCompanionBuilder =
    TestResultsCompanion Function({
      Value<int> id,
      Value<DateTime> takenAt,
      Value<String> answersJson,
      Value<String> state,
      Value<String?> typeId,
      Value<String?> gTop,
      Value<String?> aTop,
      Value<String> auxiliaryJson,
      Value<String> recoveryJson,
      Value<bool> appliedToProfile,
    });

class $$TestResultsTableFilterComposer
    extends Composer<_$AppDatabase, $TestResultsTable> {
  $$TestResultsTableFilterComposer({
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

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answersJson => $composableBuilder(
    column: $table.answersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeId => $composableBuilder(
    column: $table.typeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gTop => $composableBuilder(
    column: $table.gTop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aTop => $composableBuilder(
    column: $table.aTop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get auxiliaryJson => $composableBuilder(
    column: $table.auxiliaryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recoveryJson => $composableBuilder(
    column: $table.recoveryJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get appliedToProfile => $composableBuilder(
    column: $table.appliedToProfile,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TestResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $TestResultsTable> {
  $$TestResultsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answersJson => $composableBuilder(
    column: $table.answersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeId => $composableBuilder(
    column: $table.typeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gTop => $composableBuilder(
    column: $table.gTop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aTop => $composableBuilder(
    column: $table.aTop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get auxiliaryJson => $composableBuilder(
    column: $table.auxiliaryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recoveryJson => $composableBuilder(
    column: $table.recoveryJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get appliedToProfile => $composableBuilder(
    column: $table.appliedToProfile,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TestResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestResultsTable> {
  $$TestResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<String> get answersJson => $composableBuilder(
    column: $table.answersJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get typeId =>
      $composableBuilder(column: $table.typeId, builder: (column) => column);

  GeneratedColumn<String> get gTop =>
      $composableBuilder(column: $table.gTop, builder: (column) => column);

  GeneratedColumn<String> get aTop =>
      $composableBuilder(column: $table.aTop, builder: (column) => column);

  GeneratedColumn<String> get auxiliaryJson => $composableBuilder(
    column: $table.auxiliaryJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recoveryJson => $composableBuilder(
    column: $table.recoveryJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get appliedToProfile => $composableBuilder(
    column: $table.appliedToProfile,
    builder: (column) => column,
  );
}

class $$TestResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TestResultsTable,
          TestResult,
          $$TestResultsTableFilterComposer,
          $$TestResultsTableOrderingComposer,
          $$TestResultsTableAnnotationComposer,
          $$TestResultsTableCreateCompanionBuilder,
          $$TestResultsTableUpdateCompanionBuilder,
          (
            TestResult,
            BaseReferences<_$AppDatabase, $TestResultsTable, TestResult>,
          ),
          TestResult,
          PrefetchHooks Function()
        > {
  $$TestResultsTableTableManager(_$AppDatabase db, $TestResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<String> answersJson = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> typeId = const Value.absent(),
                Value<String?> gTop = const Value.absent(),
                Value<String?> aTop = const Value.absent(),
                Value<String> auxiliaryJson = const Value.absent(),
                Value<String> recoveryJson = const Value.absent(),
                Value<bool> appliedToProfile = const Value.absent(),
              }) => TestResultsCompanion(
                id: id,
                takenAt: takenAt,
                answersJson: answersJson,
                state: state,
                typeId: typeId,
                gTop: gTop,
                aTop: aTop,
                auxiliaryJson: auxiliaryJson,
                recoveryJson: recoveryJson,
                appliedToProfile: appliedToProfile,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime takenAt,
                required String answersJson,
                required String state,
                Value<String?> typeId = const Value.absent(),
                Value<String?> gTop = const Value.absent(),
                Value<String?> aTop = const Value.absent(),
                Value<String> auxiliaryJson = const Value.absent(),
                Value<String> recoveryJson = const Value.absent(),
                Value<bool> appliedToProfile = const Value.absent(),
              }) => TestResultsCompanion.insert(
                id: id,
                takenAt: takenAt,
                answersJson: answersJson,
                state: state,
                typeId: typeId,
                gTop: gTop,
                aTop: aTop,
                auxiliaryJson: auxiliaryJson,
                recoveryJson: recoveryJson,
                appliedToProfile: appliedToProfile,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TestResultsTable, TestResult>(table),
                  BaseReferences<_$AppDatabase, $TestResultsTable, TestResult>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TestResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TestResultsTable,
      TestResult,
      $$TestResultsTableFilterComposer,
      $$TestResultsTableOrderingComposer,
      $$TestResultsTableAnnotationComposer,
      $$TestResultsTableCreateCompanionBuilder,
      $$TestResultsTableUpdateCompanionBuilder,
      (
        TestResult,
        BaseReferences<_$AppDatabase, $TestResultsTable, TestResult>,
      ),
      TestResult,
      PrefetchHooks Function()
    >;
typedef $$DialogueExposuresTableCreateCompanionBuilder =
    DialogueExposuresCompanion Function({
      Value<int> id,
      required String dialogueId,
      required DateTime shownAt,
      required String role,
      required String intensity,
      Value<int?> sessionId,
      required String localDate,
    });
typedef $$DialogueExposuresTableUpdateCompanionBuilder =
    DialogueExposuresCompanion Function({
      Value<int> id,
      Value<String> dialogueId,
      Value<DateTime> shownAt,
      Value<String> role,
      Value<String> intensity,
      Value<int?> sessionId,
      Value<String> localDate,
    });

class $$DialogueExposuresTableFilterComposer
    extends Composer<_$AppDatabase, $DialogueExposuresTable> {
  $$DialogueExposuresTableFilterComposer({
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

  ColumnFilters<String> get dialogueId => $composableBuilder(
    column: $table.dialogueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get shownAt => $composableBuilder(
    column: $table.shownAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DialogueExposuresTableOrderingComposer
    extends Composer<_$AppDatabase, $DialogueExposuresTable> {
  $$DialogueExposuresTableOrderingComposer({
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

  ColumnOrderings<String> get dialogueId => $composableBuilder(
    column: $table.dialogueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get shownAt => $composableBuilder(
    column: $table.shownAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DialogueExposuresTableAnnotationComposer
    extends Composer<_$AppDatabase, $DialogueExposuresTable> {
  $$DialogueExposuresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dialogueId => $composableBuilder(
    column: $table.dialogueId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get shownAt =>
      $composableBuilder(column: $table.shownAt, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get intensity =>
      $composableBuilder(column: $table.intensity, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);
}

class $$DialogueExposuresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DialogueExposuresTable,
          DialogueExposure,
          $$DialogueExposuresTableFilterComposer,
          $$DialogueExposuresTableOrderingComposer,
          $$DialogueExposuresTableAnnotationComposer,
          $$DialogueExposuresTableCreateCompanionBuilder,
          $$DialogueExposuresTableUpdateCompanionBuilder,
          (
            DialogueExposure,
            BaseReferences<
              _$AppDatabase,
              $DialogueExposuresTable,
              DialogueExposure
            >,
          ),
          DialogueExposure,
          PrefetchHooks Function()
        > {
  $$DialogueExposuresTableTableManager(
    _$AppDatabase db,
    $DialogueExposuresTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DialogueExposuresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DialogueExposuresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DialogueExposuresTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> dialogueId = const Value.absent(),
                Value<DateTime> shownAt = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> intensity = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<String> localDate = const Value.absent(),
              }) => DialogueExposuresCompanion(
                id: id,
                dialogueId: dialogueId,
                shownAt: shownAt,
                role: role,
                intensity: intensity,
                sessionId: sessionId,
                localDate: localDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String dialogueId,
                required DateTime shownAt,
                required String role,
                required String intensity,
                Value<int?> sessionId = const Value.absent(),
                required String localDate,
              }) => DialogueExposuresCompanion.insert(
                id: id,
                dialogueId: dialogueId,
                shownAt: shownAt,
                role: role,
                intensity: intensity,
                sessionId: sessionId,
                localDate: localDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DialogueExposuresTable, DialogueExposure>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DialogueExposuresTable,
                    DialogueExposure
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DialogueExposuresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DialogueExposuresTable,
      DialogueExposure,
      $$DialogueExposuresTableFilterComposer,
      $$DialogueExposuresTableOrderingComposer,
      $$DialogueExposuresTableAnnotationComposer,
      $$DialogueExposuresTableCreateCompanionBuilder,
      $$DialogueExposuresTableUpdateCompanionBuilder,
      (
        DialogueExposure,
        BaseReferences<
          _$AppDatabase,
          $DialogueExposuresTable,
          DialogueExposure
        >,
      ),
      DialogueExposure,
      PrefetchHooks Function()
    >;
typedef $$AnalyticsEventsTableCreateCompanionBuilder =
    AnalyticsEventsCompanion Function({
      Value<int> id,
      required String name,
      Value<String> paramsJson,
      required DateTime at,
    });
typedef $$AnalyticsEventsTableUpdateCompanionBuilder =
    AnalyticsEventsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> paramsJson,
      Value<DateTime> at,
    });

class $$AnalyticsEventsTableFilterComposer
    extends Composer<_$AppDatabase, $AnalyticsEventsTable> {
  $$AnalyticsEventsTableFilterComposer({
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

  ColumnFilters<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AnalyticsEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnalyticsEventsTable> {
  $$AnalyticsEventsTableOrderingComposer({
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

  ColumnOrderings<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AnalyticsEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnalyticsEventsTable> {
  $$AnalyticsEventsTableAnnotationComposer({
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

  GeneratedColumn<String> get paramsJson => $composableBuilder(
    column: $table.paramsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$AnalyticsEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnalyticsEventsTable,
          AnalyticsEvent,
          $$AnalyticsEventsTableFilterComposer,
          $$AnalyticsEventsTableOrderingComposer,
          $$AnalyticsEventsTableAnnotationComposer,
          $$AnalyticsEventsTableCreateCompanionBuilder,
          $$AnalyticsEventsTableUpdateCompanionBuilder,
          (
            AnalyticsEvent,
            BaseReferences<
              _$AppDatabase,
              $AnalyticsEventsTable,
              AnalyticsEvent
            >,
          ),
          AnalyticsEvent,
          PrefetchHooks Function()
        > {
  $$AnalyticsEventsTableTableManager(
    _$AppDatabase db,
    $AnalyticsEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnalyticsEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnalyticsEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnalyticsEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> paramsJson = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
              }) => AnalyticsEventsCompanion(
                id: id,
                name: name,
                paramsJson: paramsJson,
                at: at,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> paramsJson = const Value.absent(),
                required DateTime at,
              }) => AnalyticsEventsCompanion.insert(
                id: id,
                name: name,
                paramsJson: paramsJson,
                at: at,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AnalyticsEventsTable, AnalyticsEvent>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AnalyticsEventsTable,
                    AnalyticsEvent
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AnalyticsEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnalyticsEventsTable,
      AnalyticsEvent,
      $$AnalyticsEventsTableFilterComposer,
      $$AnalyticsEventsTableOrderingComposer,
      $$AnalyticsEventsTableAnnotationComposer,
      $$AnalyticsEventsTableCreateCompanionBuilder,
      $$AnalyticsEventsTableUpdateCompanionBuilder,
      (
        AnalyticsEvent,
        BaseReferences<_$AppDatabase, $AnalyticsEventsTable, AnalyticsEvent>,
      ),
      AnalyticsEvent,
      PrefetchHooks Function()
    >;
typedef $$WorriesTableCreateCompanionBuilder = WorriesCompanion Function({
  Value<int> id,
  required String body,
  Value<String?> kind,
  required DateTime createdAt,
  Value<DateTime?> burnedAt,
  Value<String?> seonsaLine,
  Value<bool> accepted,
  Value<int> rebuttalCount,
  Value<bool> safetyFlagged,
  required String localDate,
});
typedef $$WorriesTableUpdateCompanionBuilder = WorriesCompanion Function({
  Value<int> id,
  Value<String> body,
  Value<String?> kind,
  Value<DateTime> createdAt,
  Value<DateTime?> burnedAt,
  Value<String?> seonsaLine,
  Value<bool> accepted,
  Value<int> rebuttalCount,
  Value<bool> safetyFlagged,
  Value<String> localDate,
});

class $$WorriesTableFilterComposer
    extends Composer<_$AppDatabase, $WorriesTable> {
  $$WorriesTableFilterComposer({
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

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get burnedAt => $composableBuilder(
    column: $table.burnedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seonsaLine => $composableBuilder(
    column: $table.seonsaLine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get accepted => $composableBuilder(
    column: $table.accepted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rebuttalCount => $composableBuilder(
    column: $table.rebuttalCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get safetyFlagged => $composableBuilder(
    column: $table.safetyFlagged,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorriesTable> {
  $$WorriesTableOrderingComposer({
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

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get burnedAt => $composableBuilder(
    column: $table.burnedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seonsaLine => $composableBuilder(
    column: $table.seonsaLine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get accepted => $composableBuilder(
    column: $table.accepted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rebuttalCount => $composableBuilder(
    column: $table.rebuttalCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get safetyFlagged => $composableBuilder(
    column: $table.safetyFlagged,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorriesTable> {
  $$WorriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get burnedAt =>
      $composableBuilder(column: $table.burnedAt, builder: (column) => column);

  GeneratedColumn<String> get seonsaLine => $composableBuilder(
    column: $table.seonsaLine,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get accepted =>
      $composableBuilder(column: $table.accepted, builder: (column) => column);

  GeneratedColumn<int> get rebuttalCount => $composableBuilder(
    column: $table.rebuttalCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get safetyFlagged => $composableBuilder(
    column: $table.safetyFlagged,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);
}

class $$WorriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorriesTable,
          Worry,
          $$WorriesTableFilterComposer,
          $$WorriesTableOrderingComposer,
          $$WorriesTableAnnotationComposer,
          $$WorriesTableCreateCompanionBuilder,
          $$WorriesTableUpdateCompanionBuilder,
          (Worry, BaseReferences<_$AppDatabase, $WorriesTable, Worry>),
          Worry,
          PrefetchHooks Function()
        > {
  $$WorriesTableTableManager(_$AppDatabase db, $WorriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> kind = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> burnedAt = const Value.absent(),
                Value<String?> seonsaLine = const Value.absent(),
                Value<bool> accepted = const Value.absent(),
                Value<int> rebuttalCount = const Value.absent(),
                Value<bool> safetyFlagged = const Value.absent(),
                Value<String> localDate = const Value.absent(),
              }) => WorriesCompanion(
                id: id,
                body: body,
                kind: kind,
                createdAt: createdAt,
                burnedAt: burnedAt,
                seonsaLine: seonsaLine,
                accepted: accepted,
                rebuttalCount: rebuttalCount,
                safetyFlagged: safetyFlagged,
                localDate: localDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String body,
                Value<String?> kind = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> burnedAt = const Value.absent(),
                Value<String?> seonsaLine = const Value.absent(),
                Value<bool> accepted = const Value.absent(),
                Value<int> rebuttalCount = const Value.absent(),
                Value<bool> safetyFlagged = const Value.absent(),
                required String localDate,
              }) => WorriesCompanion.insert(
                id: id,
                body: body,
                kind: kind,
                createdAt: createdAt,
                burnedAt: burnedAt,
                seonsaLine: seonsaLine,
                accepted: accepted,
                rebuttalCount: rebuttalCount,
                safetyFlagged: safetyFlagged,
                localDate: localDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorriesTable, Worry>(table),
                  BaseReferences<_$AppDatabase, $WorriesTable, Worry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorriesTable,
      Worry,
      $$WorriesTableFilterComposer,
      $$WorriesTableOrderingComposer,
      $$WorriesTableAnnotationComposer,
      $$WorriesTableCreateCompanionBuilder,
      $$WorriesTableUpdateCompanionBuilder,
      (Worry, BaseReferences<_$AppDatabase, $WorriesTable, Worry>),
      Worry,
      PrefetchHooks Function()
    >;
typedef $$TokenUnlocksTableCreateCompanionBuilder =
    TokenUnlocksCompanion Function({
      Value<int> id,
      required String tokenId,
      required DateTime unlockedAt,
      Value<bool> seen,
    });
typedef $$TokenUnlocksTableUpdateCompanionBuilder =
    TokenUnlocksCompanion Function({
      Value<int> id,
      Value<String> tokenId,
      Value<DateTime> unlockedAt,
      Value<bool> seen,
    });

class $$TokenUnlocksTableFilterComposer
    extends Composer<_$AppDatabase, $TokenUnlocksTable> {
  $$TokenUnlocksTableFilterComposer({
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

  ColumnFilters<String> get tokenId => $composableBuilder(
    column: $table.tokenId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get seen => $composableBuilder(
    column: $table.seen,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TokenUnlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $TokenUnlocksTable> {
  $$TokenUnlocksTableOrderingComposer({
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

  ColumnOrderings<String> get tokenId => $composableBuilder(
    column: $table.tokenId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get seen => $composableBuilder(
    column: $table.seen,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TokenUnlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TokenUnlocksTable> {
  $$TokenUnlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tokenId =>
      $composableBuilder(column: $table.tokenId, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get seen =>
      $composableBuilder(column: $table.seen, builder: (column) => column);
}

class $$TokenUnlocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TokenUnlocksTable,
          TokenUnlock,
          $$TokenUnlocksTableFilterComposer,
          $$TokenUnlocksTableOrderingComposer,
          $$TokenUnlocksTableAnnotationComposer,
          $$TokenUnlocksTableCreateCompanionBuilder,
          $$TokenUnlocksTableUpdateCompanionBuilder,
          (
            TokenUnlock,
            BaseReferences<_$AppDatabase, $TokenUnlocksTable, TokenUnlock>,
          ),
          TokenUnlock,
          PrefetchHooks Function()
        > {
  $$TokenUnlocksTableTableManager(_$AppDatabase db, $TokenUnlocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TokenUnlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TokenUnlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TokenUnlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tokenId = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
                Value<bool> seen = const Value.absent(),
              }) => TokenUnlocksCompanion(
                id: id,
                tokenId: tokenId,
                unlockedAt: unlockedAt,
                seen: seen,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tokenId,
                required DateTime unlockedAt,
                Value<bool> seen = const Value.absent(),
              }) => TokenUnlocksCompanion.insert(
                id: id,
                tokenId: tokenId,
                unlockedAt: unlockedAt,
                seen: seen,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TokenUnlocksTable, TokenUnlock>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TokenUnlocksTable,
                    TokenUnlock
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TokenUnlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TokenUnlocksTable,
      TokenUnlock,
      $$TokenUnlocksTableFilterComposer,
      $$TokenUnlocksTableOrderingComposer,
      $$TokenUnlocksTableAnnotationComposer,
      $$TokenUnlocksTableCreateCompanionBuilder,
      $$TokenUnlocksTableUpdateCompanionBuilder,
      (
        TokenUnlock,
        BaseReferences<_$AppDatabase, $TokenUnlocksTable, TokenUnlock>,
      ),
      TokenUnlock,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$DayRecordsTableTableManager get dayRecords =>
      $$DayRecordsTableTableManager(_db, _db.dayRecords);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$TestResultsTableTableManager get testResults =>
      $$TestResultsTableTableManager(_db, _db.testResults);
  $$DialogueExposuresTableTableManager get dialogueExposures =>
      $$DialogueExposuresTableTableManager(_db, _db.dialogueExposures);
  $$AnalyticsEventsTableTableManager get analyticsEvents =>
      $$AnalyticsEventsTableTableManager(_db, _db.analyticsEvents);
  $$WorriesTableTableManager get worries =>
      $$WorriesTableTableManager(_db, _db.worries);
  $$TokenUnlocksTableTableManager get tokenUnlocks =>
      $$TokenUnlocksTableTableManager(_db, _db.tokenUnlocks);
}
