import 'dart:math';

import 'package:bucheo_handsome/data/content/models.dart';
import 'package:bucheo_handsome/features/dialogue/dialogue_selector.dart';
import 'package:flutter_test/flutter_test.dart';

DialogueItem item(
  String id, {
  DialogueRole role = DialogueRole.ack,
  DialogueIntensity intensity = DialogueIntensity.low,
  List<String> forbidWhen = const [],
  List<String> requires = const [],
  int repeatDays = 0,
  String screen = 'session_done',
  String? pool,
}) =>
    DialogueItem(
      id: id,
      text: '$id 본문',
      screen: screen,
      role: role,
      intensity: intensity,
      origin: role == DialogueRole.humor ? 'humor' : 'guide',
      rootId: null,
      requires: requires,
      forbidWhen: forbidWhen,
      repeatDays: repeatDays,
      pool: pool,
      buttons: const [],
    );

ExposureRecord seen(
  String id,
  DateTime at, {
  DialogueRole role = DialogueRole.ack,
  DialogueIntensity intensity = DialogueIntensity.low,
}) =>
    ExposureRecord(
        dialogueId: id, shownAt: at, role: role, intensity: intensity);

void main() {
  const selector = DialogueSelector();
  final now = DateTime(2026, 3, 10, 12);
  final rng = Random(42);

  group('forbidWhen', () {
    test('chip이 맞으면 제외된다', () {
      final items = [
        item('A', forbidWhen: ['chip:heavy']),
        item('B'),
      ];
      final out = selector
          .filter(items, DialogueContext(chip: 'heavy', now: now))
          .map((e) => e.id);
      expect(out, ['B']);
    });

    test('safety 플래그에서 제외된다', () {
      final items = [
        item('A', forbidWhen: ['safety']),
        item('B'),
      ];
      final out = selector
          .filter(items, DialogueContext(safetyFlagged: true, now: now))
          .map((e) => e.id);
      expect(out, ['B']);
    });
  });

  group('안전 규칙 (FR-3.8, SA-1)', () {
    test('칩 "많이 힘듦"에서 유머 노출 0', () {
      final items = [
        item('H1', role: DialogueRole.humor),
        item('H2', role: DialogueRole.humor),
        item('K', role: DialogueRole.ack),
      ];
      final ctx = DialogueContext(chip: 'heavy', now: now);
      expect(selector.filter(items, ctx).map((e) => e.id), ['K']);

      // 100번 뽑아도 유머는 나오지 않는다.
      for (var i = 0; i < 100; i++) {
        final picked = selector.select(
            candidates: items, ctx: ctx, rng: Random(i));
        expect(picked?.role, isNot(DialogueRole.humor));
      }
    });

    test('위기 상태에서는 인정·안내만 (관찰·질문도 막힌다)', () {
      final items = [
        item('O', role: DialogueRole.observe),
        item('Q', role: DialogueRole.question),
        item('H', role: DialogueRole.humor),
        item('G', role: DialogueRole.guide),
        item('K', role: DialogueRole.ack),
      ];
      final out = selector
          .filter(items, DialogueContext(safetyFlagged: true, now: now))
          .map((e) => e.id)
          .toSet();
      expect(out, {'G', 'K'});
    });

    test('폴백도 안전 규칙을 지킨다', () {
      final picked = selector.select(
        candidates: const [],
        ctx: DialogueContext(chip: 'heavy', now: now),
        fallbacks: [
          item('D-humor', role: DialogueRole.humor),
          item('D-ack', role: DialogueRole.ack),
        ],
        rng: rng,
      );
      expect(picked!.id, 'D-ack');
    });
  });

  group('반복 제한 (FR-3.5)', () {
    test('14일 안에 같은 ID는 다시 안 나온다', () {
      final items = [item('X', repeatDays: 14), item('Y', repeatDays: 14)];
      final ctx = DialogueContext(
        now: now,
        recentExposures: [seen('X', now.subtract(const Duration(days: 13)))],
      );
      expect(selector.filter(items, ctx).map((e) => e.id), ['Y']);
    });

    test('14일이 지나면 다시 나온다', () {
      final items = [item('X', repeatDays: 14)];
      final ctx = DialogueContext(
        now: now,
        recentExposures: [seen('X', now.subtract(const Duration(days: 15)))],
      );
      expect(selector.filter(items, ctx).map((e) => e.id), ['X']);
    });

    test('repeatDays 0이면 제한 없음', () {
      final items = [item('X', repeatDays: 0)];
      final ctx = DialogueContext(
        now: now,
        recentExposures: [seen('X', now.subtract(const Duration(minutes: 1)))],
      );
      expect(selector.filter(items, ctx).map((e) => e.id), ['X']);
    });
  });

  group('노출 강도·빈도 규칙 (FR-3.6)', () {
    test('세션당 강도 중은 1개', () {
      final items = [item('M', intensity: DialogueIntensity.mid), item('L')];
      final ctx = DialogueContext(
        now: now,
        sessionExposures: [
          seen('prev', now, intensity: DialogueIntensity.mid),
        ],
      );
      expect(selector.filter(items, ctx).map((e) => e.id), ['L']);
    });

    test('아직 중을 안 썼으면 통과', () {
      final items = [item('M', intensity: DialogueIntensity.mid)];
      expect(
        selector.filter(items, DialogueContext(now: now)).map((e) => e.id),
        ['M'],
      );
    });

    test('하루 관찰·질문 2개 초과 시 제외', () {
      final items = [
        item('O', role: DialogueRole.observe),
        item('Q', role: DialogueRole.question),
        item('K', role: DialogueRole.ack),
      ];
      final ctx = DialogueContext(
        now: now,
        todayExposures: [
          seen('a', now, role: DialogueRole.observe),
          seen('b', now, role: DialogueRole.question),
        ],
      );
      expect(selector.filter(items, ctx).map((e) => e.id), ['K']);
    });

    test('하루 1개만 썼으면 아직 통과', () {
      final items = [item('O', role: DialogueRole.observe)];
      final ctx = DialogueContext(
        now: now,
        todayExposures: [seen('a', now, role: DialogueRole.observe)],
      );
      expect(selector.filter(items, ctx).map((e) => e.id), ['O']);
    });
  });

  group('requires', () {
    test('practicedSec이 없으면 제외', () {
      final items = [item('P', requires: ['practicedSec']), item('N')];
      expect(
        selector.filter(items, DialogueContext(now: now)).map((e) => e.id),
        ['N'],
      );
      expect(
        selector
            .filter(items, DialogueContext(now: now, practicedSec: 180))
            .map((e) => e.id),
        ['P', 'N'],
      );
    });
  });

  group('select', () {
    test('후보가 없고 폴백도 없으면 null', () {
      expect(
        selector.select(candidates: const [], ctx: DialogueContext(now: now)),
        isNull,
      );
    });

    test('후보가 있으면 폴백을 쓰지 않는다', () {
      final picked = selector.select(
        candidates: [item('A')],
        ctx: DialogueContext(now: now),
        fallbacks: [item('D-01')],
        rng: rng,
      );
      expect(picked!.id, 'A');
    });

    test('후보가 규칙에 다 막히면 폴백', () {
      final picked = selector.select(
        candidates: [item('A', forbidWhen: ['safety'])],
        ctx: DialogueContext(safetyFlagged: true, now: now),
        fallbacks: [item('D-01')],
        rng: rng,
      );
      expect(picked!.id, 'D-01');
    });
  });

  group('renderDialogue', () {
    test('{time}을 치환한다', () {
      expect(renderDialogue('{time} 뒀다.', time: '3분'), '3분 뒀다.');
    });

    test('time이 없으면 원문 그대로', () {
      expect(renderDialogue('왔네.'), '왔네.');
    });
  });
}
