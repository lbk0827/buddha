import '../../data/content/models.dart';

/// 판정 5단계 (FR-6.2).
enum TestState {
  representative,
  mixed,
  tendency,
  reservedInsufficient,
  reservedScattered,
}

/// 한 요소(G/A/C)의 집계.
class ElementTally {
  final String element;

  /// 방향 → 선택 수.
  final Map<String, int> counts;

  /// 건너뛰지 않은 응답 수.
  final int answered;
  final int skipped;

  const ElementTally({
    required this.element,
    required this.counts,
    required this.answered,
    required this.skipped,
  });

  /// 선택 수 내림차순 방향. 동점이면 요소 정의 순서를 따른다(결정적).
  List<String> get ranked {
    final keys = counts.keys.toList();
    keys.sort((a, b) {
      final byCount = (counts[b] ?? 0).compareTo(counts[a] ?? 0);
      return byCount;
    });
    return keys;
  }

  String? get top => ranked.isEmpty ? null : ranked.first;
  int get topCount => top == null ? 0 : (counts[top] ?? 0);
  int get secondCount => ranked.length < 2 ? 0 : (counts[ranked[1]] ?? 0);

  /// 최고와 같은 선택 수를 가진 방향들 (동점 판정용).
  List<String> get tiedTops =>
      counts.entries.where((e) => e.value == topCount && topCount > 0)
          .map((e) => e.key)
          .toList();

  /// 두드러짐: 응답 ≥ minAnswers, 최고×2 ≥ 응답, 차이 ≥ 1 (FR-6.2).
  bool isProminent(int minAnswers) =>
      answered >= minAnswers &&
      topCount * 2 >= answered &&
      topCount - secondCount >= 1;
}

class TestOutcome {
  final TestState state;

  /// 대표 유형일 때만 채워진다.
  final String? typeId;

  /// 두드러진 경우에만 채워진다. 결과 화면은 이것만 문장으로 푼다 (FR-6.4).
  final String? gTop;
  final String? aTop;

  /// 보조 방향. 문장으로 풀지 않는다.
  final List<String> auxiliary;

  /// 회복 최고 방향. 동점이면 복수 (FR-6.5).
  final List<String> recovery;

  final int answeredCount;
  final int skippedCount;
  final Map<String, ElementTally> tallies;

  const TestOutcome({
    required this.state,
    required this.typeId,
    required this.gTop,
    required this.aTop,
    required this.auxiliary,
    required this.recovery,
    required this.answeredCount,
    required this.skippedCount,
    required this.tallies,
  });

  bool get isProminentG => gTop != null;
  bool get isProminentA => aTop != null;

  /// 심화를 제안하는 상태 (FR-6.3).
  bool get suggestsDeep =>
      state == TestState.tendency ||
      state == TestState.reservedInsufficient ||
      state == TestState.reservedScattered;
}

class TestScorer {
  const TestScorer(this.content);

  final TestContent content;

  /// [answers]: 문항 ID → 방향, 또는 null(건너뜀). 심화 문항 포함.
  /// 답하지 않은(아직 노출 안 된) 문항은 키 자체가 없어야 한다.
  TestOutcome score(Map<String, String?> answers) {
    final byId = {for (final q in content.questions) q.id: q};
    final tallies = <String, ElementTally>{};

    for (final entry in content.elements.entries) {
      final element = entry.key;
      final counts = {for (final dir in entry.value) dir: 0};
      var answered = 0;
      var skipped = 0;

      for (final a in answers.entries) {
        final q = byId[a.key];
        if (q == null || q.element != element) continue;
        final dir = a.value;
        if (dir == null) {
          skipped++;
          continue;
        }
        if (!counts.containsKey(dir)) continue;
        counts[dir] = counts[dir]! + 1;
        answered++;
      }

      tallies[element] = ElementTally(
        element: element,
        counts: counts,
        answered: answered,
        skipped: skipped,
      );
    }

    final min = content.scoring.minAnswers;
    final g = tallies['G'];
    final a = tallies['A'];
    final c = tallies['C'];

    final gProminent = g?.isProminent(min) ?? false;
    final aProminent = a?.isProminent(min) ?? false;
    final gTop = gProminent ? g!.top : null;
    final aTop = aProminent ? a!.top : null;

    String? typeId;
    TestState state;

    if (gProminent && aProminent) {
      typeId = _matchType(gTop!, aTop!);
      state = typeId != null ? TestState.representative : TestState.mixed;
    } else if (gProminent || aProminent) {
      state = TestState.tendency;
    } else {
      final gAnswered = g?.answered ?? 0;
      final aAnswered = a?.answered ?? 0;
      // 응답 자체가 모자라면 "정보부족", 충분히 답했는데도 갈렸으면 "분산".
      state = (gAnswered < min || aAnswered < min)
          ? TestState.reservedInsufficient
          : TestState.reservedScattered;
    }

    final auxiliary = <String>[];
    for (final t in [g, a]) {
      if (t == null) continue;
      final ranked = t.ranked;
      if (ranked.length >= 2 && (t.counts[ranked[1]] ?? 0) > 0) {
        auxiliary.add(ranked[1]);
      }
    }

    // 회복(C)은 두드러짐 조건을 적용하지 않는다. 최고 방향(동점 포함)을 쓴다.
    final recovery = (c == null || c.answered == 0) ? <String>[] : c.tiedTops;

    var answeredTotal = 0;
    var skippedTotal = 0;
    for (final t in tallies.values) {
      answeredTotal += t.answered;
      skippedTotal += t.skipped;
    }

    return TestOutcome(
      state: state,
      typeId: typeId,
      gTop: gTop,
      aTop: aTop,
      auxiliary: auxiliary,
      recovery: recovery,
      answeredCount: answeredTotal,
      skippedCount: skippedTotal,
      tallies: tallies,
    );
  }

  /// types: kwan [R,F] 처럼 G방향·A방향 쌍. 순서는 무시하고 집합으로 맞춘다.
  String? _matchType(String gTop, String aTop) {
    for (final entry in content.types.entries) {
      final pair = entry.value.toSet();
      if (pair.length == 2 && pair.contains(gTop) && pair.contains(aTop)) {
        return entry.key;
      }
    }
    return null;
  }
}

/// 심화 진행 판단 (FR-6.3).
/// 응답 적은 요소부터 한 문항씩, 재계산하며 진행한다.
class DeepFlow {
  const DeepFlow(this.content);

  final TestContent content;

  /// 다음에 낼 심화 문항. 종료 조건이면 null.
  /// [shownDeepIds]는 이미 노출한 심화 문항(건너뛴 것 포함).
  TestQuestion? next({
    required Map<String, String?> answers,
    required List<String> shownDeepIds,
  }) {
    final rules = content.scoring;
    if (shownDeepIds.length >= rules.deepMaxShown) return null;

    final deepAnswered = shownDeepIds
        .where((id) => answers[id] != null)
        .length;
    if (deepAnswered >= rules.deepMaxAnswered) return null;

    final outcome = TestScorer(content).score(answers);
    // 두 요소가 모두 두드러지면 더 물을 필요가 없다.
    if (outcome.isProminentG && outcome.isProminentA) return null;

    // 응답이 적은 요소부터.
    final g = outcome.tallies['G']?.answered ?? 0;
    final a = outcome.tallies['A']?.answered ?? 0;
    final order = g <= a ? ['G', 'A'] : ['A', 'G'];

    for (final element in order) {
      for (final q in content.deepQuestions) {
        if (q.element != element) continue;
        if (shownDeepIds.contains(q.id)) continue;
        return q;
      }
    }
    return null;
  }
}
