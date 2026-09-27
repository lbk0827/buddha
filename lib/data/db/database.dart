import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// 세션 1건. PRD 「로컬 DB · Session」.
/// practicedSec은 정지·유예·중단선택 체류를 제외한 실제 수행 초 (FR-2.7).
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get targetSec => integer()();
  IntColumn get practicedSec => integer().withDefault(const Constant(0))();

  /// 'completed' | 'interrupted'. 진행 중이면 null.
  TextColumn get outcome => text().nullable()();

  /// 'timer' | 'sensorA' | 'sensorC'. 실제로 사용된 전략을 쓴다.
  TextColumn get detection => text().withDefault(const Constant('timer'))();
  BoolColumn get audioOn => boolean().withDefault(const Constant(false))();

  TextColumn get worryText => text().nullable()();
  TextColumn get worryChip => text().nullable()();
  BoolColumn get repeatFlag => boolean().withDefault(const Constant(false))();
  BoolColumn get safetyFlagged => boolean().withDefault(const Constant(false))();

  /// yyyy-MM-dd, startedAt 기준. 인정일 집계 키.
  TextColumn get localDate => text()();

  /// 프로세스 강제 종료 대비. 매 전이마다 저장된다 (PRD 세션 타이머 설계).
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();

  /// 제외 구간(일시정지·유예·중단선택 체류) JSON 배열.
  TextColumn get excludedJson => text().withDefault(const Constant('[]'))();
}

/// localDate 기준 집계. 세션 종료 시 갱신 (FR-4.1).
class DayRecords extends Table {
  TextColumn get localDate => text()();
  IntColumn get validSessionCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get firstValidAt => dateTime().nullable()();
  BoolColumn get credited => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {localDate};
}

/// 단일 레코드 (id = 1).
class Profiles extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get creditedDays => integer().withDefault(const Constant(0))();
  IntColumn get templeStage => integer().withDefault(const Constant(0))();

  /// 관/지/문/미
  TextColumn get dharmaFirst => text().nullable()();
  IntColumn get dharmaStage => integer().withDefault(const Constant(0))();
  TextColumn get character => text().withDefault(const Constant('default'))();

  /// 회복 최고 방향 X/O/M/Q
  TextColumn get recoveryPref => text().nullable()();

  /// 회복 기본값 적용 횟수. 3회 후 중단 (FR-6.5).
  IntColumn get defaultsAppliedCount => integer().withDefault(const Constant(0))();

  TextColumn get settingsJson => text().withDefault(const Constant('{}'))();
  TextColumn get consentsJson => text().withDefault(const Constant('{}'))();

  DateTimeColumn get firstLaunchAt => dateTime().nullable()();
  DateTimeColumn get lastVisitAt => dateTime().nullable()();
  BoolColumn get characterOnboardShown =>
      boolean().withDefault(const Constant(false))();

  /// 낙엽 연출을 이미 처리한 복귀 날짜 (FR-4.4).
  TextColumn get leavesClearedDate => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TestResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get takenAt => dateTime()();

  /// 문항 ID → 방향 또는 null(건너뜀). 심화 포함.
  TextColumn get answersJson => text()();

  /// representative | mixed | tendency | reservedInsufficient | reservedScattered
  TextColumn get state => text()();
  TextColumn get typeId => text().nullable()();
  TextColumn get gTop => text().nullable()();
  TextColumn get aTop => text().nullable()();
  TextColumn get auxiliaryJson => text().withDefault(const Constant('[]'))();
  TextColumn get recoveryJson => text().withDefault(const Constant('[]'))();
  BoolColumn get appliedToProfile => boolean().withDefault(const Constant(false))();
}

/// 14일 반복 제한 계산용 (FR-3.5, FR-3.6).
class DialogueExposures extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get dialogueId => text()();
  DateTimeColumn get shownAt => dateTime()();
  TextColumn get role => text()();
  TextColumn get intensity => text()();
  IntColumn get sessionId => integer().nullable()();

  /// 하루 단위 제한 계산 키.
  TextColumn get localDate => text()();
}

/// 로컬 이벤트 로그. 동의 없이는 기기 밖으로 나가지 않는다.
/// 텍스트·답변 원문은 어떤 이벤트에도 넣지 않는다 (PRD 분석 이벤트).
class AnalyticsEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get paramsJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get at => dateTime()();
}

@DriftDatabase(tables: [
  Sessions,
  DayRecords,
  Profiles,
  TestResults,
  DialogueExposures,
  AnalyticsEvents,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'bucheo_handsome'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          if (details.wasCreated) {
            await into(profiles).insert(
              ProfilesCompanion.insert(firstLaunchAt: Value(DateTime.now())),
            );
          }
        },
      );

  /// 설정 「데이터 삭제」 — 로컬 전부 삭제 (FR-8.3).
  Future<void> wipeAll() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
      await into(profiles).insert(
        ProfilesCompanion.insert(firstLaunchAt: Value(DateTime.now())),
      );
    });
  }
}
