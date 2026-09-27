import 'package:bucheo_handsome/data/content/models.dart';
import 'package:bucheo_handsome/features/test/scorer.dart';
import 'package:flutter_test/flutter_test.dart';

/// 실제 test.json에 기대는 구조를 그대로 흉내 낸 최소 콘텐츠.
TestContent buildContent() => TestContent.fromJson({
      'schemaVersion': 1,
      'basis': '최근 한 달의 나',
      'elements': {
        'G': ['R', 'E', 'U', 'D'],
        'A': ['F', 'T', 'N', 'W'],
        'C': ['X', 'O', 'M', 'Q'],
      },
      'types': {
        'kwan': ['R', 'F'],
        'ji': ['D', 'T'],
        'mun': ['U', 'N'],
        'mi': ['E', 'W'],
      },
      'questions': [
        for (var i = 1; i <= 6; i++)
          {
            'id': 'G$i',
            'element': 'G',
            'context': 'x',
            'text': 'G$i',
            'options': [
              {'text': 'a', 'dir': 'R'},
              {'text': 'b', 'dir': 'E'},
              {'text': 'c', 'dir': 'U'},
              {'text': 'd', 'dir': 'D'},
            ],
            'skippable': true,
            'deep': false,
          },
        for (var i = 1; i <= 6; i++)
          {
            'id': 'A$i',
            'element': 'A',
            'context': 'x',
            'text': 'A$i',
            'options': [
              {'text': 'a', 'dir': 'F'},
              {'text': 'b', 'dir': 'T'},
              {'text': 'c', 'dir': 'N'},
              {'text': 'd', 'dir': 'W'},
            ],
            'skippable': true,
            'deep': false,
          },
        for (var i = 1; i <= 4; i++)
          {
            'id': 'C$i',
            'element': 'C',
            'context': 'x',
            'text': 'C$i',
            'options': [
              {'text': 'a', 'dir': 'X'},
              {'text': 'b', 'dir': 'O'},
              {'text': 'c', 'dir': 'M'},
              {'text': 'd', 'dir': 'Q'},
            ],
            'skippable': true,
            'deep': false,
          },
        for (var i = 1; i <= 3; i++)
          {
            'id': 'SG$i',
            'element': 'G',
            'context': 'x',
            'text': 'SG$i',
            'options': [
              {'text': 'a', 'dir': 'R'},
              {'text': 'b', 'dir': 'E'},
              {'text': 'c', 'dir': 'U'},
              {'text': 'd', 'dir': 'D'},
            ],
            'skippable': true,
            'deep': true,
          },
        for (var i = 1; i <= 3; i++)
          {
            'id': 'SA$i',
            'element': 'A',
            'context': 'x',
            'text': 'SA$i',
            'options': [
              {'text': 'a', 'dir': 'F'},
              {'text': 'b', 'dir': 'T'},
              {'text': 'c', 'dir': 'N'},
              {'text': 'd', 'dir': 'W'},
            ],
            'skippable': true,
            'deep': true,
          },
      ],
      'results': {
        'kwan': {'name': '관세음형', 'line': 'l'},
        'ji': {'name': '지장형', 'line': 'l'},
        'mun': {'name': '문수형', 'line': 'l'},
        'mi': {'name': '미륵형', 'line': 'l'},
        'directions': {
          for (final d in ['R', 'E', 'U', 'D', 'F', 'T', 'N', 'W', 'X', 'O', 'M', 'Q'])
            d: {'interp': 'i', 'strength': 's', 'action': 'a'},
        },
      },
      'scoring': {
        'minAnswers': 3,
        'topRule': 'top*2>=n && top-second>=1',
        'deepMaxAnswered': 3,
        'deepMaxShown': 5,
      },
    });

void main() {
  final content = buildContent();
  final scorer = TestScorer(content);

  group('두드러짐 조건 (FR-6.2)', () {
    test('응답 3, 최고 3 → 두드러짐', () {
      final tally = ElementTally(
        element: 'G',
        counts: const {'R': 3, 'E': 0, 'U': 0, 'D': 0},
        answered: 3,
        skipped: 0,
      );
      expect(tally.isProminent(3), isTrue);
    });

    test('B1 — 응답 2는 최소 응답 미달', () {
      final tally = ElementTally(
        element: 'G',
        counts: const {'R': 2, 'E': 0, 'U': 0, 'D': 0},
        answered: 2,
        skipped: 0,
      );
      expect(tally.isProminent(3), isFalse);
    });

    test('B2 — 최고×2 == 응답 (경계, 통과)', () {
      // 응답 6, 최고 3 → 3*2 >= 6 참, 차이 3-2=1 >= 1 참.
      final tally = ElementTally(
        element: 'G',
        counts: const {'R': 3, 'E': 2, 'U': 1, 'D': 0},
        answered: 6,
        skipped: 0,
      );
      expect(tally.isProminent(3), isTrue);
    });

    test('B3 — 최고×2 < 응답 (탈락)', () {
      // 응답 7, 최고 3 → 6 < 7.
      final tally = ElementTally(
        element: 'G',
        counts: const {'R': 3, 'E': 2, 'U': 1, 'D': 1},
        answered: 7,
        skipped: 0,
      );
      expect(tally.isProminent(3), isFalse);
    });

    test('B4 — 1위 동점이면 차이 0이라 탈락', () {
      final tally = ElementTally(
        element: 'G',
        counts: const {'R': 3, 'E': 3, 'U': 0, 'D': 0},
        answered: 6,
        skipped: 0,
      );
      expect(tally.isProminent(3), isFalse);
    });

    test('B5 — 차이 정확히 1이면 통과', () {
      final tally = ElementTally(
        element: 'G',
        counts: const {'R': 3, 'E': 2, 'U': 0, 'D': 0},
        answered: 5,
        skipped: 0,
      );
      expect(tally.isProminent(3), isTrue);
    });

    test('B6 — 0응답', () {
      final tally = ElementTally(
        element: 'G',
        counts: const {'R': 0, 'E': 0, 'U': 0, 'D': 0},
        answered: 0,
        skipped: 6,
      );
      expect(tally.isProminent(3), isFalse);
    });
  });

  group('판정 5단계 (FR-6.2)', () {
    test('대표 — G·A 모두 두드러지고 유형 쌍과 맞는다', () {
      final out = scorer.score({
        'G1': 'R', 'G2': 'R', 'G3': 'R', 'G4': 'E',
        'A1': 'F', 'A2': 'F', 'A3': 'F', 'A4': 'T',
        'C1': 'X', 'C2': 'X', 'C3': 'O',
      });
      expect(out.state, TestState.representative);
      expect(out.typeId, 'kwan');
      expect(out.gTop, 'R');
      expect(out.aTop, 'F');
      expect(out.recovery, ['X']);
    });

    test('혼합 — 둘 다 두드러지지만 유형 쌍이 아니다', () {
      // R(G) + T(A) 는 어떤 types 항목과도 맞지 않는다.
      final out = scorer.score({
        'G1': 'R', 'G2': 'R', 'G3': 'R', 'G4': 'E',
        'A1': 'T', 'A2': 'T', 'A3': 'T', 'A4': 'F',
      });
      expect(out.state, TestState.mixed);
      expect(out.typeId, isNull);
      expect(out.gTop, 'R');
      expect(out.aTop, 'T');
    });

    test('경향 — 한쪽만 두드러진다', () {
      final out = scorer.score({
        'G1': 'R', 'G2': 'R', 'G3': 'R',
        'A1': 'F', 'A2': 'T', 'A3': 'N', 'A4': 'W',
      });
      expect(out.state, TestState.tendency);
      expect(out.gTop, 'R');
      expect(out.aTop, isNull);
    });

    test('유보 정보부족 — 응답 자체가 모자라다', () {
      final out = scorer.score({'G1': 'R', 'A1': 'F'});
      expect(out.state, TestState.reservedInsufficient);
      expect(out.gTop, isNull);
      expect(out.aTop, isNull);
    });

    test('유보 정보부족 — 전부 건너뛰었다', () {
      final out = scorer.score({
        'G1': null, 'G2': null, 'G3': null,
        'A1': null, 'A2': null, 'A3': null,
      });
      expect(out.state, TestState.reservedInsufficient);
      expect(out.answeredCount, 0);
      expect(out.skippedCount, 6);
    });

    test('유보 분산 — 충분히 답했는데 고르게 갈렸다', () {
      final out = scorer.score({
        'G1': 'R', 'G2': 'E', 'G3': 'U', 'G4': 'D',
        'A1': 'F', 'A2': 'T', 'A3': 'N', 'A4': 'W',
      });
      expect(out.state, TestState.reservedScattered);
      expect(out.gTop, isNull);
      expect(out.aTop, isNull);
    });
  });

  group('유형 쌍 매칭', () {
    test('네 유형이 모두 맞는다', () {
      final cases = {
        'kwan': ['R', 'F'],
        'ji': ['D', 'T'],
        'mun': ['U', 'N'],
        'mi': ['E', 'W'],
      };
      for (final entry in cases.entries) {
        final g = entry.value[0];
        final a = entry.value[1];
        final out = scorer.score({
          'G1': g, 'G2': g, 'G3': g,
          'A1': a, 'A2': a, 'A3': a,
        });
        expect(out.state, TestState.representative, reason: entry.key);
        expect(out.typeId, entry.key);
      }
    });
  });

  group('회복 방향 (FR-6.5)', () {
    test('동점이면 복수로 돌려준다 — 사용자가 고른다', () {
      final out = scorer.score({'C1': 'X', 'C2': 'O'});
      expect(out.recovery.toSet(), {'X', 'O'});
    });

    test('C 응답이 없으면 비어 있다', () {
      final out = scorer.score({'G1': 'R'});
      expect(out.recovery, isEmpty);
    });

    test('회복은 두드러짐 조건을 적용하지 않는다', () {
      // 응답 2건뿐이라 두드러짐 조건은 못 넘지만 회복은 잡힌다.
      final out = scorer.score({'C1': 'M', 'C2': 'M'});
      expect(out.recovery, ['M']);
    });
  });

  group('건너뜀 집계 (FR-6.4 "응답 N / 건너뜀 M")', () {
    test('null은 건너뜀으로 센다', () {
      final out = scorer.score({
        'G1': 'R', 'G2': null, 'G3': 'R',
        'A1': null, 'A2': 'F',
      });
      expect(out.answeredCount, 3);
      expect(out.skippedCount, 2);
    });
  });

  group('심화 흐름 (FR-6.3)', () {
    final flow = DeepFlow(content);

    test('두 요소가 모두 두드러지면 더 묻지 않는다', () {
      final next = flow.next(
        answers: {
          'G1': 'R', 'G2': 'R', 'G3': 'R',
          'A1': 'F', 'A2': 'F', 'A3': 'F',
        },
        shownDeepIds: const [],
      );
      expect(next, isNull);
    });

    test('응답 적은 요소부터 낸다', () {
      // G는 4개 답했고 A는 1개뿐 → A 쪽 심화부터.
      final next = flow.next(
        answers: {
          'G1': 'R', 'G2': 'E', 'G3': 'U', 'G4': 'D',
          'A1': 'F',
        },
        shownDeepIds: const [],
      );
      expect(next!.element, 'A');
      expect(next.deep, isTrue);
    });

    test('이미 낸 문항은 다시 내지 않는다', () {
      final next = flow.next(
        answers: {'G1': 'R', 'A1': 'F'},
        shownDeepIds: const ['SG1', 'SA1'],
      );
      expect(next, isNotNull);
      expect(['SG1', 'SA1'].contains(next!.id), isFalse);
    });

    test('심화 응답 3개면 종료', () {
      final next = flow.next(
        answers: {
          'G1': 'R', 'A1': 'F',
          'SG1': 'R', 'SG2': 'E', 'SA1': 'F',
        },
        shownDeepIds: const ['SG1', 'SG2', 'SA1'],
      );
      expect(next, isNull);
    });

    test('노출 5개면 종료 (건너뛴 것 포함)', () {
      final next = flow.next(
        answers: {
          'G1': 'R', 'A1': 'F',
          'SG1': null, 'SG2': null, 'SG3': null, 'SA1': null, 'SA2': null,
        },
        shownDeepIds: const ['SG1', 'SG2', 'SG3', 'SA1', 'SA2'],
      );
      expect(next, isNull);
    });

    test('건너뛴 문항은 응답으로 세지 않아 대체 문항이 나온다', () {
      final next = flow.next(
        answers: {'G1': 'R', 'A1': 'F', 'SG1': null, 'SA1': null},
        shownDeepIds: const ['SG1', 'SA1'],
      );
      expect(next, isNotNull);
    });
  });
}
