import 'package:bucheo_handsome/core/time_utils.dart';
import 'package:bucheo_handsome/features/temple/temple_stage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('stageForCreditedDays (FR-4.2)', () {
    test('인정일 1·2·5·10·20·40에 단계가 오른다', () {
      expect(stageForCreditedDays(0), 0);
      expect(stageForCreditedDays(1), 1);
      expect(stageForCreditedDays(2), 2);
      expect(stageForCreditedDays(4), 2);
      expect(stageForCreditedDays(5), 3);
      expect(stageForCreditedDays(9), 3);
      expect(stageForCreditedDays(10), 4);
      expect(stageForCreditedDays(20), 5);
      expect(stageForCreditedDays(39), 5);
      expect(stageForCreditedDays(40), 6);
      expect(stageForCreditedDays(400), 6);
    });

    test('단계 이름이 기획과 맞는다', () {
      expect(stageAt(1)!.name, '등');
      expect(stageAt(2)!.name, '나무');
      expect(stageAt(3)!.name, '돌담');
      expect(stageAt(4)!.name, '종');
      expect(stageAt(5)!.name, '지붕');
      expect(stageAt(6)!.name, '일주문');
      expect(stageAt(7), isNull);
      expect(stageAt(0), isNull);
    });
  });

  group('nextStageAfter (FR-4.5)', () {
    test('다음 단계와 조건을 알려준다', () {
      expect(nextStageAfter(0)!.requiredCreditedDays, 1);
      expect(nextStageAfter(2)!.requiredCreditedDays, 5);
      expect(nextStageAfter(20)!.requiredCreditedDays, 40);
    });

    test('마지막 단계 뒤에는 없다', () {
      expect(nextStageAfter(40), isNull);
    });
  });

  group('shouldShowFallenLeaves (FR-4.4)', () {
    final now = DateTime(2026, 3, 10, 12);

    test('미접속 2일 이상이면 낙엽', () {
      expect(
        shouldShowFallenLeaves(
            lastVisitAt: now.subtract(const Duration(days: 2)), now: now),
        isTrue,
      );
      expect(
        shouldShowFallenLeaves(
            lastVisitAt: now.subtract(const Duration(days: 5)), now: now),
        isTrue,
      );
    });

    test('하루 만에 오면 낙엽 없음', () {
      expect(
        shouldShowFallenLeaves(
            lastVisitAt: now.subtract(const Duration(hours: 30)), now: now),
        isFalse,
      );
    });

    test('첫 방문은 낙엽 없음', () {
      expect(shouldShowFallenLeaves(lastVisitAt: null, now: now), isFalse);
    });
  });

  group('법명 (FR-4.8)', () {
    test('인정일 1에 견, 7에 사', () {
      expect(dharmaLastSyllable(0), isNull);
      expect(dharmaLastSyllable(1), '견');
      expect(dharmaLastSyllable(6), '견');
      expect(dharmaLastSyllable(7), '사');
      expect(dharmaLastSyllable(100), '사');
    });
  });

  group('localDateKey (FR-4.1)', () {
    test('자정을 넘긴 세션도 시작일에 귀속된다', () {
      final start = DateTime(2026, 3, 1, 23, 59, 30);
      expect(localDateKey(start), '2026-03-01');
    });

    test('날짜 키 왕복', () {
      expect(localDateKey(parseDateKey('2026-12-31')), '2026-12-31');
    });
  });

  group('시간 표기', () {
    test('formatDuration', () {
      expect(formatDuration(40), '40초');
      expect(formatDuration(60), '1분');
      expect(formatDuration(100), '1분 40초');
      expect(formatDuration(180), '3분');
    });

    test('formatCumulative', () {
      expect(formatCumulative(600), '10분');
      expect(formatCumulative(3600), '1시간');
      expect(formatCumulative(5400), '1시간 30분');
    });
  });
}
