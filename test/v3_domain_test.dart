import 'package:bucheo_handsome/core/time_utils.dart';
import 'package:bucheo_handsome/features/gate/temple_gate.dart';
import 'package:bucheo_handsome/features/ordination/dharma_rank.dart';
import 'package:bucheo_handsome/features/tokens/token_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('절 문 (v3)', () {
    test('자정까지 남은 시간을 센다', () {
      final at = DateTime(2026, 3, 10, 18, 18);
      expect(untilGateCloses(at), const Duration(hours: 5, minutes: 42));
    });

    test('자정 직전에도 음수가 되지 않는다', () {
      final at = DateTime(2026, 3, 10, 23, 59, 59);
      expect(untilGateCloses(at).isNegative, isFalse);
    });

    test('"5:42" 형식으로 표기한다', () {
      const s = GateState(
        visitedToday: false,
        remaining: Duration(hours: 5, minutes: 42),
        streakDays: 0,
      );
      expect(s.remainingLabel, '5:42');
      expect(s.headline, '절 문 · 5:42 남음');
    });

    test('한 자리 분도 0을 채운다', () {
      const s = GateState(
        visitedToday: false,
        remaining: Duration(hours: 2, minutes: 5),
        streakDays: 0,
      );
      expect(s.remainingLabel, '2:05');
    });

    test('오늘 다녀왔으면 문구가 바뀌고 급하지 않다', () {
      const s = GateState(
        visitedToday: true,
        remaining: Duration(minutes: 30),
        streakDays: 3,
      );
      expect(s.headline, '오늘 절 다녀왔다');
      expect(s.closingSoon, isFalse);
    });

    test('2시간 미만으로 남고 아직 안 왔으면 급하다', () {
      const s = GateState(
        visitedToday: false,
        remaining: Duration(hours: 1, minutes: 30),
        streakDays: 0,
      );
      expect(s.closingSoon, isTrue);
      expect(s.headline, '절 문 곧 닫힌다');
    });
  });

  group('절 문 연속', () {
    final now = DateTime(2026, 3, 10, 14);

    int streak(List<String> keys) => gateStreak(
          creditedDateKeys: keys.toSet(),
          now: now,
          keyOf: localDateKey,
        );

    test('오늘 포함 연속이면 오늘까지 센다', () {
      expect(streak(['2026-03-10', '2026-03-09', '2026-03-08']), 3);
    });

    test('오늘 아직 안 왔으면 어제까지의 연속을 준다', () {
      // 하루가 끝나기 전에 연속을 깎지 않는다.
      expect(streak(['2026-03-09', '2026-03-08']), 2);
    });

    test('중간에 끊기면 거기서 멈춘다', () {
      expect(streak(['2026-03-10', '2026-03-09', '2026-03-07']), 2);
    });

    test('기록이 없으면 0', () {
      expect(streak([]), 0);
    });

    test('아주 오래된 기록만 있으면 0', () {
      expect(streak(['2026-01-01']), 0);
    });
  });

  group('법명 진화', () {
    test('엎기 횟수로 단계가 오른다', () {
      expect(rankForBows(0).station, '사미');
      expect(rankForBows(29).station, '사미');
      expect(rankForBows(30).station, '대사');
      expect(rankForBows(107).station, '대사');
      expect(rankForBows(108).station, '선사');
      expect(rankForBows(500).station, '조사');
    });

    test('법명에 단계가 붙는다', () {
      expect(rankForBows(0).nameFor('무념'), '무념');
      expect(rankForBows(30).nameFor('무념'), '무념대사');
      expect(rankForBows(108).nameFor('무념'), '무념선사');
    });

    test('다음 단계를 알려주고 마지막에선 없다', () {
      expect(nextRankAfter(0)!.requiredBows, 30);
      expect(nextRankAfter(30)!.requiredBows, 108);
      expect(nextRankAfter(500), isNull);
    });

    test('법명 후보에 모두 뜻이 달려 있다', () {
      for (final n in kDharmaNames) {
        expect(kDharmaMeanings[n], isNotNull, reason: n);
      }
    });
  });

  group('증표 해제', () {
    const empty = PracticeStats();

    test('아무것도 안 했으면 조건 없는 시즌 증표만 열린다', () {
      final open = kTokenCatalog.where((t) => t.isUnlocked(empty)).toList();
      expect(open.length, 1);
      expect(open.single.group, TokenGroup.season);
    });

    test('한 번 엎으면 「첫 엎기」가 열린다', () {
      const s = PracticeStats(bowCount: 1);
      final first = kTokenCatalog.firstWhere((t) => t.id == 'first');
      expect(first.isUnlocked(s), isTrue);
    });

    test('108개 태우면 완파가 열린다', () {
      final t = kTokenCatalog.firstWhere((t) => t.id == 'burn108');
      expect(t.isUnlocked(const PracticeStats(burnedCount: 107)), isFalse);
      expect(t.isUnlocked(const PracticeStats(burnedCount: 108)), isTrue);
    });

    test('진척 비율은 0~1을 넘지 않는다', () {
      final t = kTokenCatalog.firstWhere((t) => t.id == 'bow100');
      expect(t.ratio(const PracticeStats(bowCount: 0)), 0);
      expect(t.ratio(const PracticeStats(bowCount: 50)), 0.5);
      expect(t.ratio(const PracticeStats(bowCount: 999)), 1);
    });

    test('진척 문구', () {
      final t = kTokenCatalog.firstWhere((t) => t.id == 'bow100');
      expect(t.progressLabel(const PracticeStats(bowCount: 62)), '62 / 100');
      final season = kTokenCatalog.firstWhere((t) => t.id == 'winter');
      expect(season.progressLabel(empty), '조건 없음');
    });

    test('newlyUnlocked는 이미 해제된 건 빼고 준다', () {
      const s = PracticeStats(bowCount: 1);
      final fresh = newlyUnlocked(s, {});
      expect(fresh.map((t) => t.id), containsAll(['first', 'winter']));

      final again = newlyUnlocked(s, {'first', 'winter'});
      expect(again, isEmpty);
    });

    test('nextToUnlock은 가장 가까운 잠긴 증표를 고른다', () {
      // 엎기 90/100 이 번뇌 10/108 보다 가깝다.
      const s = PracticeStats(bowCount: 90, burnedCount: 10);
      final next = nextToUnlock(s, {'first', 'winter'});
      expect(next!.id, 'bow100');
    });

    test('nextToUnlock은 조건 없는 증표를 고르지 않는다', () {
      final next = nextToUnlock(empty, {});
      expect(next, isNotNull);
      expect(next!.goal, greaterThan(0));
    });

    test('전부 해제되면 null', () {
      final all = kTokenCatalog.map((t) => t.id).toSet();
      expect(nextToUnlock(empty, all), isNull);
    });

    test('증표 ID가 중복되지 않는다', () {
      final ids = kTokenCatalog.map((t) => t.id).toList();
      expect(ids.length, ids.toSet().length);
    });
  });
}
