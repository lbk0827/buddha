import 'package:bucheo_handsome/app/providers.dart';
import 'package:bucheo_handsome/data/db/database.dart';
import 'package:bucheo_handsome/data/repositories/session_repository.dart';
import 'package:bucheo_handsome/features/session/session_controller.dart';
import 'package:bucheo_handsome/features/session/session_timing.dart';
import 'package:bucheo_handsome/services/notification_service.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 플랫폼 채널을 타지 않는 알림 대역.
class _FakeNotifications implements NotificationService {
  DateTime? scheduledEnd;
  int buzzCount = 0;
  bool cancelled = false;

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> scheduleSessionEnd(DateTime at, {String? body}) async {
    scheduledEnd = at;
  }

  @override
  Future<void> cancelSessionEnd() async {
    cancelled = true;
  }

  @override
  Future<void> scheduleRevisit(DateTime at, String body) async {}

  @override
  Future<void> cancelRevisit() async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> buzz() async {
    buzzCount++;
  }
}

void main() {
  late AppDatabase db;
  late _FakeNotifications notifications;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    notifications = _FakeNotifications();
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      notificationServiceProvider.overrideWithValue(notifications),
    ]);
    await container.read(profileRepositoryProvider).ensure();
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  SessionController controller() =>
      container.read(sessionControllerProvider.notifier);
  SessionState state() => container.read(sessionControllerProvider);

  group('시작 (FR-2.3)', () {
    test('엎음 확인이 진동·타임스탬프·알림 예약을 모두 일으킨다', () async {
      controller().updateSetup(const SessionSetup(targetSec: 180));
      await controller().confirmLayDown();

      expect(state().phase, SessionPhase.running);
      expect(state().sessionId, isNotNull);
      expect(state().startedAt, isNotNull);
      expect(notifications.buzzCount, 1);
      expect(notifications.scheduledEnd, isNotNull);

      // 종료 예정 시각은 시작 + 목표.
      final expected = state().startedAt!.add(const Duration(seconds: 180));
      expect(
        notifications.scheduledEnd!.difference(expected).inSeconds.abs(),
        lessThanOrEqualTo(1),
      );
    });

    test('설정값이 세션 행에 그대로 들어간다', () async {
      controller().updateSetup(const SessionSetup(
        targetSec: 600,
        worryText: '회의가 싫다',
        worryChip: 'work',
        repeatFlag: true,
      ));
      await controller().confirmLayDown();

      final row = await SessionRepository(db).activeSession();
      expect(row!.targetSec, 600);
      expect(row.worryText, '회의가 싫다');
      expect(row.worryChip, 'work');
      expect(row.repeatFlag, isTrue);
      expect(row.detection, 'timer');
    });

    test('위기 플래그가 세션에 기록된다 (SA-2)', () async {
      controller()
        ..updateSetup(const SessionSetup())
        ..setSafetyFlag(true);
      await controller().confirmLayDown();

      final row = await SessionRepository(db).activeSession();
      expect(row!.safetyFlagged, isTrue);
    });
  });

  group('중단 선택 (FR-2.5)', () {
    test('선택 화면에 들어가면 제외 구간이 열리고 DB에 저장된다', () async {
      controller().updateSetup(const SessionSetup());
      await controller().confirmLayDown();
      await controller().enterInterruptChoice();

      expect(state().phase, SessionPhase.interruptChoice);
      expect(state().excluded.length, 1);
      expect(state().excluded.first.isOpen, isTrue);
      expect(state().excluded.first.reason, 'interruptChoice');

      // 프로세스가 죽어도 복원되도록 저장돼 있어야 한다.
      final row = await SessionRepository(db).activeSession();
      expect(decodeExcluded(row!.excludedJson).length, 1);
    });

    test('이어가기가 구간을 닫고 수행중으로 되돌린다', () async {
      controller().updateSetup(const SessionSetup());
      await controller().confirmLayDown();
      await controller().enterInterruptChoice();
      await controller().resumeFromInterrupt();

      expect(state().phase, SessionPhase.running);
      expect(state().excluded.single.isOpen, isFalse);
    });

    test('구간을 두 번 열지 않는다', () async {
      controller().updateSetup(const SessionSetup());
      await controller().confirmLayDown();
      await controller().enterInterruptChoice();
      await controller().enterInterruptChoice();
      expect(state().excluded.length, 1);
    });

    test('「오늘은 여기까지」는 중단으로 끝낸다', () async {
      controller().updateSetup(const SessionSetup());
      await controller().confirmLayDown();
      await controller().stopHere();

      expect(state().phase, SessionPhase.done);
      expect(state().result!.session.outcome, 'interrupted');
      expect(notifications.cancelled, isTrue);
      // 1초도 안 됐으니 유효 세션이 아니다.
      expect(state().result!.isValid, isFalse);
      expect(state().result!.creditedToday, isFalse);
    });
  });

  group('일시정지 (FR-2.6)', () {
    test('오디오 중단이 일시정지 구간을 만든다', () async {
      controller().updateSetup(const SessionSetup(audioOn: true));
      await controller().confirmLayDown();
      await controller().pauseForAudioInterruption();

      expect(state().phase, SessionPhase.paused);
      expect(state().excluded.single.reason, 'audio');
    });

    test('재개하면 종료 알림이 다시 예약된다', () async {
      controller().updateSetup(const SessionSetup(audioOn: true));
      await controller().confirmLayDown();
      final firstSchedule = notifications.scheduledEnd;

      await controller().pauseForAudioInterruption();
      await controller().resumeFromPause();

      expect(state().phase, SessionPhase.running);
      expect(notifications.scheduledEnd, isNotNull);
      // 제외 구간만큼 뒤로 밀렸거나 같다.
      expect(
        notifications.scheduledEnd!.isBefore(firstSchedule!),
        isFalse,
      );
    });
  });

  group('완주', () {
    test('완주는 목표 시간을 넘겨 기록하지 않는다', () async {
      controller().updateSetup(const SessionSetup(targetSec: 180));
      await controller().confirmLayDown();
      await controller().complete();

      expect(state().result!.session.outcome, 'completed');
      expect(state().result!.session.practicedSec, lessThanOrEqualTo(180));
      // 종료 시에도 진동 1회 (시작 1 + 종료 1).
      expect(notifications.buzzCount, 2);
    });
  });

  group('강제 종료 후 복원 (QA 체크리스트)', () {
    /// 과거에 시작된 활성 세션을 DB에 직접 심는다.
    Future<void> seedActive({
      required Duration ago,
      int targetSec = 180,
    }) async {
      final startedAt = DateTime.now().subtract(ago);
      await db.into(db.sessions).insert(SessionsCompanion.insert(
            startedAt: startedAt,
            targetSec: targetSec,
            localDate:
                '${startedAt.year.toString().padLeft(4, '0')}-${startedAt.month.toString().padLeft(2, '0')}-${startedAt.day.toString().padLeft(2, '0')}',
            isActive: const Value(true),
          ));
    }

    test('목표를 이미 넘긴 세션은 완주로 확정된다', () async {
      await seedActive(ago: const Duration(minutes: 4));
      await controller().restoreIfAny();

      expect(state().phase, SessionPhase.done);
      expect(state().result!.session.outcome, 'completed');
      expect(state().result!.isValid, isTrue);
      expect(state().result!.creditedToday, isTrue);
    });

    test('10분 넘게 방치된 세션은 중단으로 닫힌다', () async {
      await seedActive(ago: const Duration(minutes: 30), targetSec: 3600);
      await controller().restoreIfAny();

      expect(state().phase, SessionPhase.done);
      expect(state().result!.session.outcome, 'interrupted');
    });

    test('아직 진행 중인 세션은 중단 선택 화면으로 간다', () async {
      await seedActive(ago: const Duration(seconds: 30), targetSec: 600);
      await controller().restoreIfAny();

      expect(state().phase, SessionPhase.interruptChoice);
      expect(state().setup.targetSec, 600);
    });

    test('활성 세션이 없으면 아무 일도 없다', () async {
      await controller().restoreIfAny();
      expect(state().phase, SessionPhase.idle);
    });
  });

  group('완료 문구 (FR-2.8)', () {
    test('평소에는 "오늘은 여기까지"', () {
      expect(completionLine(practicedSec: 180, heavyChip: false),
          '3분 뒀다. 오늘은 여기까지.');
    });

    test('칩 "많이 힘듦"에서는 유머 없이 "그거면 됐다"', () {
      expect(completionLine(practicedSec: 180, heavyChip: true),
          '3분 뒀다. 그거면 됐다.');
    });
  });
}
