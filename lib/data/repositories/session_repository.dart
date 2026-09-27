import 'package:drift/drift.dart';

import '../../core/time_utils.dart';
import '../../features/session/session_timing.dart';
import '../../features/temple/temple_stage.dart';
import '../db/database.dart';

/// 세션 종료 결과. 완료 화면 연출에 필요한 것만 담는다.
class SessionFinishResult {
  final Session session;
  final bool isValid;

  /// 이 세션으로 인정일이 +1 됐는가 (FR-4.1).
  final bool creditedToday;
  final int creditedDays;

  /// 이 세션으로 새로 도달한 절 단계. 없으면 null (FR-4.2).
  final TempleStage? newStage;

  /// 같은 날 반복 세션 — 등이 밝아지는 효과 (FR-4.3).
  final bool isRepeatToday;

  const SessionFinishResult({
    required this.session,
    required this.isValid,
    required this.creditedToday,
    required this.creditedDays,
    required this.newStage,
    required this.isRepeatToday,
  });
}

class SessionRepository {
  SessionRepository(this._db);

  final AppDatabase _db;

  /// 진행 중인 세션. 앱 강제 종료 후 재실행 시 복원한다 (QA 체크리스트).
  Future<Session?> activeSession() =>
      (_db.select(_db.sessions)..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<Session> start({
    required DateTime startedAt,
    required int targetSec,
    required String detection,
    required bool audioOn,
    String? worryText,
    String? worryChip,
    bool repeatFlag = false,
    bool safetyFlagged = false,
  }) async {
    // 이전에 남은 활성 세션이 있으면 닫고 시작한다.
    await _db.update(_db.sessions).write(
          const SessionsCompanion(isActive: Value(false)),
        );
    final id = await _db.into(_db.sessions).insert(
          SessionsCompanion.insert(
            startedAt: startedAt,
            targetSec: targetSec,
            detection: Value(detection),
            audioOn: Value(audioOn),
            worryText: Value(worryText),
            worryChip: Value(worryChip),
            repeatFlag: Value(repeatFlag),
            safetyFlagged: Value(safetyFlagged),
            localDate: localDateKey(startedAt),
            isActive: const Value(true),
          ),
        );
    return (_db.select(_db.sessions)..where((t) => t.id.equals(id)))
        .getSingle();
  }

  /// 매 전이마다 제외 구간을 저장한다 (프로세스 종료 대비).
  Future<void> saveExcluded(int sessionId, List<ExcludedInterval> excluded) =>
      (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId)))
          .write(SessionsCompanion(excludedJson: Value(encodeExcluded(excluded))));

  Future<SessionFinishResult> finish({
    required int sessionId,
    required DateTime endedAt,
    required int practicedSec,
    required bool completed,
  }) async {
    return _db.transaction(() async {
      await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId)))
          .write(SessionsCompanion(
        endedAt: Value(endedAt),
        practicedSec: Value(practicedSec),
        outcome: Value(completed ? 'completed' : 'interrupted'),
        isActive: const Value(false),
      ));

      final session =
          await (_db.select(_db.sessions)..where((t) => t.id.equals(sessionId)))
              .getSingle();

      final valid = isValidSession(practicedSec);
      final dateKey = session.localDate;

      final existing = await (_db.select(_db.dayRecords)
            ..where((t) => t.localDate.equals(dateKey)))
          .getSingleOrNull();

      var creditedToday = false;
      var isRepeatToday = false;

      if (valid) {
        if (existing == null) {
          // 그날 첫 유효 세션 → 인정일 +1.
          await _db.into(_db.dayRecords).insert(DayRecordsCompanion.insert(
                localDate: dateKey,
                validSessionCount: const Value(1),
                firstValidAt: Value(session.startedAt),
                credited: const Value(true),
              ));
          creditedToday = true;
        } else {
          isRepeatToday = existing.credited;
          await (_db.update(_db.dayRecords)
                ..where((t) => t.localDate.equals(dateKey)))
              .write(DayRecordsCompanion(
            validSessionCount: Value(existing.validSessionCount + 1),
            firstValidAt: Value(existing.firstValidAt ?? session.startedAt),
            credited: const Value(true),
          ));
          // 이미 인정된 날이면 하루 최대 1이라 추가 인정은 없다.
          creditedToday = !existing.credited;
        }
      }

      final profile = await _requireProfile();
      var creditedDays = profile.creditedDays;
      TempleStage? newStage;

      if (creditedToday) {
        final before = stageForCreditedDays(creditedDays);
        creditedDays += 1;
        final after = stageForCreditedDays(creditedDays);
        if (after > before) newStage = stageAt(after);

        await (_db.update(_db.profiles)..where((t) => t.id.equals(1)))
            .write(ProfilesCompanion(
          creditedDays: Value(creditedDays),
          templeStage: Value(after),
          dharmaStage: Value(dharmaLastSyllable(creditedDays) == null ? 0 : 1),
        ));
      }

      return SessionFinishResult(
        session: session,
        isValid: valid,
        creditedToday: creditedToday,
        creditedDays: creditedDays,
        newStage: newStage,
        isRepeatToday: isRepeatToday,
      );
    });
  }

  /// 기록 저장 동의를 거부했을 때 (FR-1.5).
  /// 세션 행과 그날 집계·인정일을 되돌린다.
  Future<void> discard(int sessionId) async {
    await _db.transaction(() async {
      final session = await (_db.select(_db.sessions)
            ..where((t) => t.id.equals(sessionId)))
          .getSingleOrNull();
      if (session == null) return;

      await (_db.delete(_db.sessions)..where((t) => t.id.equals(sessionId)))
          .go();

      if (!isValidSession(session.practicedSec)) return;

      final day = await (_db.select(_db.dayRecords)
            ..where((t) => t.localDate.equals(session.localDate)))
          .getSingleOrNull();
      if (day == null) return;

      final remaining = day.validSessionCount - 1;
      if (remaining > 0) {
        await (_db.update(_db.dayRecords)
              ..where((t) => t.localDate.equals(session.localDate)))
            .write(DayRecordsCompanion(validSessionCount: Value(remaining)));
        return;
      }

      // 그날 마지막 유효 세션이었다면 인정일도 함께 거둔다.
      await (_db.delete(_db.dayRecords)
            ..where((t) => t.localDate.equals(session.localDate)))
          .go();
      final profile = await _requireProfile();
      final days = (profile.creditedDays - (day.credited ? 1 : 0))
          .clamp(0, 1 << 30);
      await (_db.update(_db.profiles)..where((t) => t.id.equals(1)))
          .write(ProfilesCompanion(
        creditedDays: Value(days),
        templeStage: Value(stageForCreditedDays(days)),
      ));
    });
  }

  Future<Profile> _requireProfile() async {
    final existing = await (_db.select(_db.profiles)
          ..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    if (existing != null) return existing;
    await _db.into(_db.profiles).insert(
          ProfilesCompanion.insert(firstLaunchAt: Value(DateTime.now())),
        );
    return (_db.select(_db.profiles)..where((t) => t.id.equals(1))).getSingle();
  }

  /// 기록 화면 (FR-4.7).
  Future<List<Session>> recentSessions({int limit = 200}) =>
      (_db.select(_db.sessions)
            ..where((t) => t.outcome.isNotNull())
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
            ..limit(limit))
          .get();

  Future<int> totalPracticedSeconds() async {
    final sum = _db.sessions.practicedSec.sum();
    final row = await (_db.selectOnly(_db.sessions)
          ..addColumns([sum])
          ..where(_db.sessions.outcome.isNotNull()))
        .getSingle();
    return row.read(sum) ?? 0;
  }

  Future<int> creditedDayCount() async {
    final count = _db.dayRecords.localDate.count();
    final row = await (_db.selectOnly(_db.dayRecords)
          ..addColumns([count])
          ..where(_db.dayRecords.credited.equals(true)))
        .getSingle();
    return row.read(count) ?? 0;
  }

  /// 완주 후 "지난번 그 얘기" 화면용 (FR-3.2).
  Future<List<Session>> previousWorries({int limit = 4}) =>
      (_db.select(_db.sessions)
            ..where((t) => t.worryText.isNotNull() & t.outcome.isNotNull())
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
            ..limit(limit))
          .get();
}
