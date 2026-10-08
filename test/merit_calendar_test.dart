import 'package:bucheo_handsome/app/providers.dart';
import 'package:bucheo_handsome/data/db/database.dart';
import 'package:bucheo_handsome/data/repositories/profile_repository.dart';
import 'package:bucheo_handsome/data/repositories/session_repository.dart';
import 'package:bucheo_handsome/data/steps/step_source.dart';
import 'package:bucheo_handsome/features/calendar/calendar_data.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSteps implements StepSource {
  _FakeSteps(this.steps);
  final Map<String, int> steps;

  @override
  Future<StepAvailability> availability() async => StepAvailability.available;

  @override
  Future<bool> requestAccess() async => true;

  @override
  Future<Map<String, int>> dailySteps(DateTime from, DateTime to) async =>
      steps;
}

Future<void> _session(SessionRepository repo, DateTime at, int sec) async {
  final s = await repo.start(
    startedAt: at,
    targetSec: sec,
    detection: 'B',
    audioOn: false,
    worryText: null,
    repeatFlag: false,
  );
  await repo.finish(
    sessionId: s.id,
    endedAt: at.add(Duration(seconds: sec)),
    practicedSec: sec,
    completed: true,
  );
}

void main() {
  late AppDatabase db;
  late ProfileRepository profiles;
  late SessionRepository sessions;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    profiles = ProfileRepository(db);
    sessions = SessionRepository(db);
  });

  tearDown(() => db.close());

  group('공덕 하루 보상', () {
    test('같은 보상은 하루 한 번만 받는다', () async {
      final before = (await profiles.ensure()).merit;

      expect(await profiles.claimDailyMerit('daily', 30, '2026-10-07'), isTrue);
      expect(await profiles.claimDailyMerit('daily', 30, '2026-10-07'), isFalse);
      expect((await profiles.ensure()).merit, before + 30);
    });

    test('다른 보상은 같은 날에도 따로 받는다', () async {
      final before = (await profiles.ensure()).merit;
      await profiles.claimDailyMerit('daily', 30, '2026-10-07');
      await profiles.claimDailyMerit('steps5k', 50, '2026-10-07');

      final p = await profiles.ensure();
      expect(p.merit, before + 80);
      expect(profiles.claimedOn(p, '2026-10-07'), {'daily', 'steps5k'});
    });

    test('다음 날이면 다시 받는다', () async {
      final before = (await profiles.ensure()).merit;
      await profiles.claimDailyMerit('daily', 30, '2026-10-07');
      expect(await profiles.claimDailyMerit('daily', 30, '2026-10-08'), isTrue);

      final p = await profiles.ensure();
      expect(p.merit, before + 60);
      expect(profiles.claimedOn(p, '2026-10-07'), isEmpty);
    });
  });

  group('달력', () {
    test('날짜별 명상 시간을 더한다', () async {
      await _session(sessions, DateTime(2026, 10, 6, 9), 180);
      await _session(sessions, DateTime(2026, 10, 6, 21), 60);
      await _session(sessions, DateTime(2026, 10, 7, 9), 300);
      await _session(sessions, DateTime(2026, 11, 1, 9), 600);

      final byDay =
          await sessions.practicedSecondsByDay('2026-10-01', '2026-10-31');
      expect(byDay, {'2026-10-06': 240, '2026-10-07': 300});
    });

    test('한 달 칸에 걸음과 명상을 함께 싣는다', () async {
      await _session(sessions, DateTime(2026, 9, 3, 9), 180);

      final container = ProviderContainer(overrides: [
        databaseProvider.overrideWithValue(db),
        stepSourceProvider
            .overrideWithValue(_FakeSteps({'2026-09-03': 7094, '2026-09-04': 12000})),
        stepsLinkedProvider.overrideWithValue(true),
      ]);
      addTearDown(container.dispose);

      final m = await container
          .read(calendarMonthProvider(DateTime(2026, 9)).future);
      expect(m.days, hasLength(30));
      expect(m.stepsLinked, isTrue);
      expect(m.totalSteps, 19094);

      final d3 = m.days[2];
      expect(d3.steps, 7094);
      expect(d3.practicedSec, 180);
      expect(d3.credited, isTrue);
      expect(m.days[3].stepRatio, 1.0);
    });
  });
}
