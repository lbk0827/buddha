import 'package:bucheo_handsome/core/time_utils.dart';
import 'package:bucheo_handsome/data/db/database.dart';
import 'package:bucheo_handsome/data/repositories/session_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SessionRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = SessionRepository(db);
    await db.into(db.profiles).insert(
          ProfilesCompanion.insert(firstLaunchAt: Value(DateTime(2026, 3, 1))),
        );
  });

  tearDown(() => db.close());

  /// 세션 하나를 시작해서 바로 끝낸다.
  Future<SessionFinishResult> run({
    required DateTime startedAt,
    required int practicedSec,
    bool completed = true,
    int targetSec = 180,
  }) async {
    final s = await repo.start(
      startedAt: startedAt,
      targetSec: targetSec,
      detection: 'timer',
      audioOn: false,
    );
    return repo.finish(
      sessionId: s.id,
      endedAt: startedAt.add(Duration(seconds: practicedSec)),
      practicedSec: practicedSec,
      completed: completed,
    );
  }

  group('인정일 (FR-4.1)', () {
    test('60초 이상 첫 세션이 인정일 +1', () async {
      final r = await run(startedAt: DateTime(2026, 3, 1, 9), practicedSec: 180);
      expect(r.isValid, isTrue);
      expect(r.creditedToday, isTrue);
      expect(r.creditedDays, 1);
    });

    test('60초 미만은 기록되지만 인정일이 오르지 않는다', () async {
      final r = await run(
          startedAt: DateTime(2026, 3, 1, 9), practicedSec: 40, completed: false);
      expect(r.isValid, isFalse);
      expect(r.creditedToday, isFalse);
      expect(r.creditedDays, 0);

      // 기록 자체는 남는다.
      final sessions = await repo.recentSessions();
      expect(sessions.length, 1);
      expect(sessions.first.practicedSec, 40);
    });

    test('같은 날 3세션이어도 인정일은 +1 (QA 체크리스트)', () async {
      final day = DateTime(2026, 3, 1);
      await run(startedAt: day.add(const Duration(hours: 9)), practicedSec: 180);
      await run(startedAt: day.add(const Duration(hours: 13)), practicedSec: 180);
      final third =
          await run(startedAt: day.add(const Duration(hours: 20)), practicedSec: 180);

      expect(third.creditedDays, 1);
      expect(await repo.creditedDayCount(), 1);
      // 2·3번째는 당일 반복으로 잡힌다 (FR-4.3).
      expect(third.isRepeatToday, isTrue);
      expect(third.newStage, isNull);
    });

    test('다른 날이면 각각 +1', () async {
      await run(startedAt: DateTime(2026, 3, 1, 9), practicedSec: 180);
      final second =
          await run(startedAt: DateTime(2026, 3, 2, 9), practicedSec: 180);
      expect(second.creditedDays, 2);
      expect(await repo.creditedDayCount(), 2);
    });

    test('자정을 넘긴 세션은 시작일에 귀속된다 (QA 체크리스트)', () async {
      final r = await run(
        startedAt: DateTime(2026, 3, 1, 23, 58),
        practicedSec: 600,
        targetSec: 600,
      );
      expect(r.session.localDate, '2026-03-01');
      expect(r.creditedDays, 1);
    });

    test('중단된 세션도 60초를 넘겼으면 인정일에 든다', () async {
      final r = await run(
        startedAt: DateTime(2026, 3, 1, 9),
        practicedSec: 95,
        completed: false,
      );
      expect(r.session.outcome, 'interrupted');
      expect(r.creditedToday, isTrue);
    });
  });

  group('절 단계 (FR-4.2)', () {
    test('인정일 1에 1단계 도달 연출', () async {
      final r = await run(startedAt: DateTime(2026, 3, 1, 9), practicedSec: 180);
      expect(r.newStage, isNotNull);
      expect(r.newStage!.index, 1);
      expect(r.newStage!.name, '등');
    });

    test('인정일 2에 2단계, 3·4일째엔 단계 변화 없음', () async {
      final days = [1, 2, 3, 4];
      final stages = <int?>[];
      for (final d in days) {
        final r =
            await run(startedAt: DateTime(2026, 3, d, 9), practicedSec: 180);
        stages.add(r.newStage?.index);
      }
      expect(stages, [1, 2, null, null]);
    });

    test('5일째에 3단계', () async {
      for (final d in [1, 2, 3, 4]) {
        await run(startedAt: DateTime(2026, 3, d, 9), practicedSec: 180);
      }
      final fifth =
          await run(startedAt: DateTime(2026, 3, 5, 9), practicedSec: 180);
      expect(fifth.creditedDays, 5);
      expect(fifth.newStage!.index, 3);
    });

    test('프로필의 templeStage가 인정일과 함께 갱신된다', () async {
      for (final d in [1, 2, 3, 4, 5]) {
        await run(startedAt: DateTime(2026, 3, d, 9), practicedSec: 180);
      }
      final profile = await (db.select(db.profiles)
            ..where((t) => t.id.equals(1)))
          .getSingle();
      expect(profile.creditedDays, 5);
      expect(profile.templeStage, 3);
    });
  });

  group('진행 중 세션 복원', () {
    test('시작만 하고 끝내지 않으면 활성 세션으로 남는다', () async {
      await repo.start(
        startedAt: DateTime(2026, 3, 1, 9),
        targetSec: 180,
        detection: 'timer',
        audioOn: false,
      );
      final active = await repo.activeSession();
      expect(active, isNotNull);
      expect(active!.isActive, isTrue);
    });

    test('새 세션을 시작하면 이전 활성 세션은 닫힌다', () async {
      await repo.start(
        startedAt: DateTime(2026, 3, 1, 9),
        targetSec: 180,
        detection: 'timer',
        audioOn: false,
      );
      final second = await repo.start(
        startedAt: DateTime(2026, 3, 1, 10),
        targetSec: 180,
        detection: 'timer',
        audioOn: false,
      );
      final active = await repo.activeSession();
      expect(active!.id, second.id);
    });

    test('종료하면 활성 플래그가 내려간다', () async {
      await run(startedAt: DateTime(2026, 3, 1, 9), practicedSec: 180);
      expect(await repo.activeSession(), isNull);
    });
  });

  group('집계', () {
    test('누적 시간은 종료된 세션만 더한다', () async {
      await run(startedAt: DateTime(2026, 3, 1, 9), practicedSec: 180);
      await run(startedAt: DateTime(2026, 3, 2, 9), practicedSec: 120);
      await repo.start(
        startedAt: DateTime(2026, 3, 3, 9),
        targetSec: 600,
        detection: 'timer',
        audioOn: false,
      );
      expect(await repo.totalPracticedSeconds(), 300);
    });
  });

  group('기록 저장 거부 (FR-1.5)', () {
    test('세션이 지워지고 인정일도 되돌아간다', () async {
      final r = await run(startedAt: DateTime(2026, 3, 1, 9), practicedSec: 180);
      expect(r.creditedDays, 1);

      await repo.discard(r.session.id);

      expect(await repo.recentSessions(), isEmpty);
      expect(await repo.creditedDayCount(), 0);
      final profile = await (db.select(db.profiles)
            ..where((t) => t.id.equals(1)))
          .getSingle();
      expect(profile.creditedDays, 0);
      expect(profile.templeStage, 0);
    });

    test('같은 날 다른 유효 세션이 남아 있으면 인정일은 유지된다', () async {
      final day = DateTime(2026, 3, 1);
      final first =
          await run(startedAt: day.add(const Duration(hours: 9)), practicedSec: 180);
      await run(startedAt: day.add(const Duration(hours: 14)), practicedSec: 180);

      await repo.discard(first.session.id);

      expect((await repo.recentSessions()).length, 1);
      expect(await repo.creditedDayCount(), 1);
    });

    test('유효하지 않은 세션을 지워도 인정일에 영향이 없다', () async {
      await run(startedAt: DateTime(2026, 3, 1, 9), practicedSec: 180);
      final short = await run(
          startedAt: DateTime(2026, 3, 1, 15), practicedSec: 30, completed: false);

      await repo.discard(short.session.id);

      expect(await repo.creditedDayCount(), 1);
      expect((await repo.recentSessions()).length, 1);
    });
  });

  group('데이터 삭제 (FR-8.3)', () {
    test('전부 지우면 인정일도 0으로 돌아간다', () async {
      await run(startedAt: DateTime(2026, 3, 1, 9), practicedSec: 180);
      await db.wipeAll();

      expect(await repo.creditedDayCount(), 0);
      expect(await repo.recentSessions(), isEmpty);
      final profile = await (db.select(db.profiles)
            ..where((t) => t.id.equals(1)))
          .getSingle();
      expect(profile.creditedDays, 0);
    });
  });

  group('번뇌 기록', () {
    test('번뇌 텍스트와 칩이 세션에 남는다 (FR-3.3)', () async {
      final s = await repo.start(
        startedAt: DateTime(2026, 3, 1, 9),
        targetSec: 180,
        detection: 'timer',
        audioOn: false,
        worryText: '내일 회의가 싫다',
        worryChip: 'work',
      );
      await repo.finish(
        sessionId: s.id,
        endedAt: DateTime(2026, 3, 1, 9, 3),
        practicedSec: 180,
        completed: true,
      );
      final saved = (await repo.recentSessions()).first;
      expect(saved.worryText, '내일 회의가 싫다');
      expect(saved.worryChip, 'work');
      expect(localDateKey(saved.startedAt), '2026-03-01');
    });
  });
}
