import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

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

  // --- v3 「가상 출가」와 놀이 경제 ---

  /// 법명 전체. 출가할 때 받는다 (예: 무념).
  TextColumn get dharmaName => text().nullable()();

  /// 법명 진화 단계. 0 사미 → 1 대사 → 2 선사 → 3 (미정).
  IntColumn get dharmaRank => integer().withDefault(const Constant(0))();

  /// 출가 셀카. 기기 안에만 둔다. 서버로 보내지 않는다.
  TextColumn get avatarPath => text().nullable()();
  DateTimeColumn get ordainedAt => dateTime().nullable()();

  /// 공덕. 번뇌를 태우거나 놀이에서 염주 한 바퀴를 돌면 쌓인다.
  /// (엎어두기도 쌓지만 지금은 진입 버튼이 없다.)
  IntColumn get merit => integer().withDefault(const Constant(0))();

  /// 태운 번뇌 누적. 108개가 「108번뇌 완파」 조건이다.
  IntColumn get burnedCount => integer().withDefault(const Constant(0))();

  /// 엎어둔 횟수 누적(108배).
  IntColumn get bowCount => integer().withDefault(const Constant(0))();

  /// 엎어둔 시간 누적(초).
  IntColumn get faceDownSec => integer().withDefault(const Constant(0))();

  /// 아바타 착용 상태. 슬롯 → 아이템 ID JSON.
  TextColumn get equipJson => text().withDefault(const Constant('{}'))();

  /// 공덕으로 연 옷장 아이템 ID 목록 JSON.
  TextColumn get ownedItemsJson => text().withDefault(const Constant('[]'))();

  // --- 놀이 염주 (목탁·싱잉볼) ---

  /// [playBeadsToday]가 센 날 (yyyy-MM-dd). 날이 바뀌면 0부터 다시 센다.
  TextColumn get playDate => text().nullable()();

  /// 그날 넘긴 염주 알. 108알이 한 바퀴다.
  IntColumn get playBeadsToday => integer().withDefault(const Constant(0))();

  /// 지금까지 돈 바퀴. 공덕 상한과 상관없이 다 센다.
  IntColumn get beadRounds => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// 번뇌 한 건. 세션과 별개로 「놀이 · 번뇌 태우기」에서 쌓인다.
/// 텍스트는 기기 안에만 남고 사용자만 열람한다 (FR-3.3, SA-4).
class Worries extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 번뇌 한 줄. Drift의 Table.text와 이름이 겹쳐 body로 둔다.
  TextColumn get body => text()();

  /// 탐(貪) / 진(嗔) / 치(癡). 강제하지 않는다.
  TextColumn get kind => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get burnedAt => dateTime().nullable()();

  /// 죽비 — 선사가 돌려준 한마디.
  TextColumn get seonsaLine => text().nullable()();

  /// 「인정. 태운다」를 눌렀는가. 반박하면 죽비가 한 번 더 온다.
  BoolColumn get accepted => boolean().withDefault(const Constant(false))();
  IntColumn get rebuttalCount => integer().withDefault(const Constant(0))();

  /// 위기 신호 감지 여부. 감지되면 선사 대사 없이 안내만 간다 (SA-1).
  BoolColumn get safetyFlagged => boolean().withDefault(const Constant(false))();

  TextColumn get localDate => text()();
}

/// 해제된 증표. 수행 이력이 열쇠다.
class TokenUnlocks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tokenId => text().unique()();
  DateTimeColumn get unlockedAt => dateTime()();

  /// 해제 연출을 이미 보여줬는가.
  BoolColumn get seen => boolean().withDefault(const Constant(false))();
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

/// 디버그 빌드에서만 주는 시작 공덕.
/// 옷장을 바로 눌러볼 수 있어야 테스트가 된다. 릴리스에서는 0이다.
const int kDebugStartingMerit = 99999;

/// 새 프로필 한 줄. 만드는 곳이 여러 군데라 여기로 모았다.
ProfilesCompanion newProfileRow() => ProfilesCompanion.insert(
      firstLaunchAt: Value(DateTime.now()),
      merit: Value(kDebugMode ? kDebugStartingMerit : 0),
    );

@DriftDatabase(tables: [
  Sessions,
  DayRecords,
  Profiles,
  TestResults,
  DialogueExposures,
  AnalyticsEvents,
  Worries,
  TokenUnlocks,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'bucheo_handsome'));

  /// 3 — 아바타 옷장(착용 상태·보유 아이템) 추가.
  /// 4 — 놀이 염주(오늘 넘긴 알·누적 바퀴) 추가.
  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(profiles, profiles.dharmaName);
            await m.addColumn(profiles, profiles.dharmaRank);
            await m.addColumn(profiles, profiles.avatarPath);
            await m.addColumn(profiles, profiles.ordainedAt);
            await m.addColumn(profiles, profiles.merit);
            await m.addColumn(profiles, profiles.burnedCount);
            await m.addColumn(profiles, profiles.bowCount);
            await m.addColumn(profiles, profiles.faceDownSec);
            await m.createTable(worries);
            await m.createTable(tokenUnlocks);
          }
          if (from < 3) {
            await m.addColumn(profiles, profiles.equipJson);
            await m.addColumn(profiles, profiles.ownedItemsJson);
          }
          if (from < 4) {
            await m.addColumn(profiles, profiles.playDate);
            await m.addColumn(profiles, profiles.playBeadsToday);
            await m.addColumn(profiles, profiles.beadRounds);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          if (details.wasCreated) {
            await into(profiles).insert(
              newProfileRow(),
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
        newProfileRow(),
      );
    });
  }
}
