import 'package:bucheo_handsome/features/session/session_timing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final t0 = DateTime(2026, 3, 1, 9, 0, 0);

  group('practicedSeconds', () {
    test('제외 구간이 없으면 경과 시간 그대로', () {
      expect(
        practicedSeconds(
            startedAt: t0, now: t0.add(const Duration(seconds: 180)), excluded: []),
        180,
      );
    });

    test('닫힌 제외 구간만큼 빠진다', () {
      final excluded = [
        ExcludedInterval(
          from: t0.add(const Duration(seconds: 30)),
          to: t0.add(const Duration(seconds: 50)),
          reason: 'audio',
        ),
      ];
      expect(
        practicedSeconds(
            startedAt: t0,
            now: t0.add(const Duration(seconds: 180)),
            excluded: excluded),
        160,
      );
    });

    test('열린 제외 구간은 now까지 빠진다', () {
      final excluded = [
        ExcludedInterval(from: t0.add(const Duration(seconds: 60)), reason: 'interruptChoice'),
      ];
      expect(
        practicedSeconds(
            startedAt: t0,
            now: t0.add(const Duration(seconds: 100)),
            excluded: excluded),
        60,
      );
    });

    test('중단 선택 화면 체류는 수행 시간에서 제외된다 (FR-2.5)', () {
      // 60초 수행 → 선택 화면 40초 → 이어가기 → 60초 더.
      final excluded = [
        ExcludedInterval(
          from: t0.add(const Duration(seconds: 60)),
          to: t0.add(const Duration(seconds: 100)),
          reason: 'interruptChoice',
        ),
      ];
      expect(
        practicedSeconds(
            startedAt: t0,
            now: t0.add(const Duration(seconds: 160)),
            excluded: excluded),
        120,
      );
    });

    test('여러 구간이 누적된다', () {
      final excluded = [
        ExcludedInterval(
            from: t0.add(const Duration(seconds: 10)),
            to: t0.add(const Duration(seconds: 20)),
            reason: 'audio'),
        ExcludedInterval(
            from: t0.add(const Duration(seconds: 40)),
            to: t0.add(const Duration(seconds: 70)),
            reason: 'interruptChoice'),
      ];
      expect(
        practicedSeconds(
            startedAt: t0,
            now: t0.add(const Duration(seconds: 200)),
            excluded: excluded),
        160,
      );
    });

    test('음수가 되지 않는다', () {
      expect(practicedSeconds(startedAt: t0, now: t0, excluded: []), 0);
      expect(
        practicedSeconds(
            startedAt: t0, now: t0.subtract(const Duration(seconds: 5)), excluded: []),
        0,
      );
    });
  });

  group('scheduledEndAt', () {
    test('제외 구간만큼 종료 예정 시각이 밀린다', () {
      final excluded = [
        ExcludedInterval(
            from: t0.add(const Duration(seconds: 10)),
            to: t0.add(const Duration(seconds: 40)),
            reason: 'audio'),
      ];
      final at = scheduledEndAt(
        startedAt: t0,
        targetSec: 180,
        excluded: excluded,
        now: t0.add(const Duration(seconds: 60)),
      );
      expect(at, t0.add(const Duration(seconds: 210)));
    });
  });

  group('isValidSession', () {
    test('60초 미만은 유효하지 않다 (FR-4.1)', () {
      expect(isValidSession(59), isFalse);
      expect(isValidSession(60), isTrue);
      expect(isValidSession(61), isTrue);
    });
  });

  group('제외 구간 직렬화', () {
    test('왕복해도 값이 유지된다 (프로세스 종료 대비)', () {
      final list = [
        ExcludedInterval(
            from: t0, to: t0.add(const Duration(seconds: 10)), reason: 'audio'),
        ExcludedInterval(from: t0.add(const Duration(seconds: 30)), reason: 'interruptChoice'),
      ];
      final decoded = decodeExcluded(encodeExcluded(list));
      expect(decoded.length, 2);
      expect(decoded[0].to, t0.add(const Duration(seconds: 10)));
      expect(decoded[1].isOpen, isTrue);
      expect(decoded[1].reason, 'interruptChoice');
    });

    test('깨진 JSON이어도 앱이 죽지 않는다', () {
      expect(decodeExcluded('not json'), isEmpty);
      expect(decodeExcluded(''), isEmpty);
    });
  });
}
