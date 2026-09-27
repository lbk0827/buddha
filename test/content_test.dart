import 'package:bucheo_handsome/data/content/content_repository.dart';
import 'package:bucheo_handsome/data/content/models.dart';
import 'package:bucheo_handsome/features/dialogue/dialogue_selector.dart';
import 'package:bucheo_handsome/features/safety/safety_detector.dart';
import 'package:bucheo_handsome/features/test/scorer.dart';
import 'package:flutter_test/flutter_test.dart';

/// 실제 번들 JSON을 읽어 검증한다. 콘텐츠가 바뀌어도 규칙은 지켜져야 한다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ContentBundle bundle;

  setUpAll(() async {
    bundle = await ContentRepository().load();
  });

  group('로딩', () {
    test('네 파일이 전부 스키마 검증을 통과한다', () {
      expect(bundle.loadErrors, isEmpty,
          reason: bundle.loadErrors.join('\n'));
    });

    test('대사·문항·뿌리가 비어 있지 않다', () {
      expect(bundle.dialogues, isNotEmpty);
      expect(bundle.roots, isNotEmpty);
      expect(bundle.test, isNotNull);
    });

    test('대사 ID가 중복되지 않는다', () {
      final ids = bundle.dialogues.map((d) => d.id).toList();
      expect(ids.length, ids.toSet().length);
    });
  });

  group('말씀의 뿌리 (FR-5.1, FR-5.5)', () {
    test('감수 전이므로 공개 항목이 없다', () {
      expect(bundle.publicRoots, isEmpty);
    });

    test('공개 5건 미만이라 뿌리 링크가 비활성이다', () {
      expect(bundle.rootsLinkEnabled, isFalse);
    });

    test('비공개 항목은 ID로도 꺼내지지 않는다', () {
      for (final r in bundle.roots) {
        expect(bundle.rootById(r.id), isNull, reason: r.id);
      }
    });
  });

  group('대사 안전 규칙', () {
    const selector = DialogueSelector();
    final now = DateTime(2026, 3, 10);

    test('칩 "많이 힘듦"에서는 어떤 화면에서도 유머가 안 나온다 (FR-3.8)', () {
      final screens = bundle.dialogues.map((d) => d.screen).toSet();
      for (final screen in screens) {
        final allowed = selector.filter(
          bundle.forScreen(screen),
          DialogueContext(chip: 'heavy', now: now),
        );
        expect(allowed.where((d) => d.role == DialogueRole.humor), isEmpty,
            reason: screen);
      }
    });

    test('위기 상태에서는 인정·안내만 남는다 (SA-1)', () {
      final screens = bundle.dialogues.map((d) => d.screen).toSet();
      for (final screen in screens) {
        final allowed = selector.filter(
          bundle.forScreen(screen),
          DialogueContext(safetyFlagged: true, now: now),
        );
        for (final d in allowed) {
          expect(kSafeRoles.contains(d.role), isTrue,
              reason: '${d.id} (${d.role.name}) on $screen');
        }
      }
    });

    test('heavy 칩에도 건넬 말이 남아 있다 — 침묵하지 않는다', () {
      final pool = bundle.forPool('after_worry:heavy');
      expect(pool, isNotEmpty);
      final allowed = selector.filter(
        pool,
        DialogueContext(chip: 'heavy', now: now),
      );
      expect(allowed, isNotEmpty);
    });

    test('폴백 대사가 있다 — 풀이 마르면 여기로 온다', () {
      expect(bundle.forScreen('fallback'), isNotEmpty);
    });
  });

  group('오늘의 한마디 풀 (FR-3.5)', () {
    test('14일 반복 제한을 견딜 만큼 있다', () {
      final daily = bundle.forPool('daily');
      expect(daily.length, greaterThanOrEqualTo(15));
    });

    test('daily 풀은 전부 repeatDays 14다', () {
      for (final d in bundle.forPool('daily')) {
        expect(d.repeatDays, 14, reason: d.id);
      }
    });

    test('뿌리를 가리키는 대사의 rootId가 실재한다', () {
      final rootIds = bundle.roots.map((r) => r.id).toSet();
      for (final d in bundle.dialogues) {
        if (d.rootId == null) continue;
        expect(rootIds.contains(d.rootId), isTrue,
            reason: '${d.id} → ${d.rootId}');
      }
    });
  });

  group('유형 테스트 콘텐츠 (FR-6.1)', () {
    test('기본 16문항 — G6·A6·C4', () {
      final base = bundle.test!.baseQuestions;
      expect(base.length, 16);
      expect(base.where((q) => q.element == 'G').length, 6);
      expect(base.where((q) => q.element == 'A').length, 6);
      expect(base.where((q) => q.element == 'C').length, 4);
    });

    test('심화 풀 — SG3·SA3', () {
      final deep = bundle.test!.deepQuestions;
      expect(deep.length, 6);
      expect(deep.where((q) => q.element == 'G').length, 3);
      expect(deep.where((q) => q.element == 'A').length, 3);
    });

    test('모든 문항이 소속 요소의 네 방향을 정확히 한 번씩 담는다', () {
      final content = bundle.test!;
      for (final q in content.questions) {
        final dirs = q.options.map((o) => o.dir).toList();
        expect(dirs.length, 4, reason: q.id);
        expect(dirs.toSet(), content.elements[q.element]!.toSet(),
            reason: q.id);
      }
    });

    test('모든 문항을 건너뛸 수 있다', () {
      expect(bundle.test!.questions.every((q) => q.skippable), isTrue);
    });

    test('12방향 해설이 모두 있다', () {
      final content = bundle.test!;
      final all = content.elements.values.expand((e) => e);
      for (final dir in all) {
        expect(content.directions[dir], isNotNull, reason: dir);
      }
    });

    test('네 유형 결과 문구가 모두 있다', () {
      for (final id in ['kwan', 'ji', 'mun', 'mi']) {
        expect(bundle.test!.typeResults[id], isNotNull, reason: id);
      }
    });

    test('유형 쌍이 G방향 하나 + A방향 하나로 이뤄진다', () {
      final content = bundle.test!;
      for (final entry in content.types.entries) {
        expect(entry.value.length, 2, reason: entry.key);
        final elements =
            entry.value.map(content.elementOfDirection).toSet();
        expect(elements, {'G', 'A'}, reason: entry.key);
      }
    });

    test('실제 문항으로 채점하면 대표 유형이 나온다', () {
      final content = bundle.test!;
      final scorer = TestScorer(content);
      // 관세음형(R+F)으로만 답한 경우.
      final answers = <String, String?>{};
      for (final q in content.baseQuestions) {
        if (q.element == 'G') answers[q.id] = 'R';
        if (q.element == 'A') answers[q.id] = 'F';
      }
      final out = scorer.score(answers);
      expect(out.state, TestState.representative);
      expect(out.typeId, 'kwan');
    });
  });

  group('안전 콘텐츠 (SA-1, SA-4)', () {
    test('키워드와 연락처가 있다', () {
      expect(bundle.safety.keywords, isNotEmpty);
      expect(bundle.safety.contacts, isNotEmpty);
    });

    test('정규식이 전부 컴파일된다', () {
      // 깨진 정규식은 로더가 버리므로, 개수로 유실을 잡는다.
      expect(bundle.safety.patterns, isNotEmpty);
    });

    test('자살예방상담전화 109가 들어 있다', () {
      expect(
        bundle.safety.contacts.any((c) => c.number.contains('109')),
        isTrue,
      );
    });

    test('평범한 번뇌는 위기로 잡지 않는다 — 오탐 확인', () {
      final detector = SafetyDetector(bundle.safety);
      const ordinary = [
        '내일 회의가 싫다',
        '요즘 잠이 안 온다',
        '돈이 부족해서 답답하다',
        '엄마랑 또 싸웠다',
        '허리가 아프다',
        '그냥 좀 지친다',
        '팀장이 자꾸 트집 잡는다',
      ];
      for (final t in ordinary) {
        expect(detector.isFlagged(t), isFalse, reason: t);
      }
    });

    test('빈 입력은 위기가 아니다', () {
      final detector = SafetyDetector(bundle.safety);
      expect(detector.isFlagged(null), isFalse);
      expect(detector.isFlagged(''), isFalse);
      expect(detector.isFlagged('   '), isFalse);
    });

    test('키워드가 들어가면 잡는다', () {
      final detector = SafetyDetector(bundle.safety);
      final keyword = bundle.safety.keywords.first;
      expect(detector.isFlagged('그래서 $keyword'), isTrue);
    });
  });
}
