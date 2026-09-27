import 'package:bucheo_handsome/app/theme.dart';
import 'package:bucheo_handsome/features/avatar/avatar_equip.dart';
import 'package:bucheo_handsome/features/avatar/monk_figure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AvatarEquip', () {
    test('입고 벗기', () {
      const e = AvatarEquip();
      expect(e.isEmpty, isTrue);

      final worn = e.wear(AvatarSlot.top, 'robe_saffron');
      expect(worn.of(AvatarSlot.top), 'robe_saffron');
      expect(e.of(AvatarSlot.top), isNull, reason: '원본은 그대로여야 한다');

      expect(worn.takeOff(AvatarSlot.top).of(AvatarSlot.top), isNull);
    });

    test('같은 슬롯은 덮어쓴다', () {
      final e = const AvatarEquip()
          .wear(AvatarSlot.top, 'robe_temple')
          .wear(AvatarSlot.top, 'robe_ash');
      expect(e.items.length, 1);
      expect(e.of(AvatarSlot.top), 'robe_ash');
    });

    test('직렬화 왕복', () {
      final e = const AvatarEquip()
          .wear(AvatarSlot.top, 'robe_ash')
          .wear(AvatarSlot.head, 'head_nabal')
          .wear(AvatarSlot.accessory, 'acc_beads');
      final back = AvatarEquip.decode(e.encode());
      expect(back.of(AvatarSlot.top), 'robe_ash');
      expect(back.of(AvatarSlot.head), 'head_nabal');
      expect(back.of(AvatarSlot.accessory), 'acc_beads');
    });

    test('깨진 값이나 빈 값이면 빈 착용으로 돌아온다', () {
      expect(AvatarEquip.decode(null).isEmpty, isTrue);
      expect(AvatarEquip.decode('').isEmpty, isTrue);
      expect(AvatarEquip.decode('{}').isEmpty, isTrue);
      expect(AvatarEquip.decode('not json').isEmpty, isTrue);
      expect(AvatarEquip.decode('[1,2,3]').isEmpty, isTrue);
    });

    test('모르는 슬롯 이름은 버린다', () {
      final e = AvatarEquip.decode('{"top":"robe_ash","wings":"x"}');
      expect(e.items.length, 1);
      expect(e.of(AvatarSlot.top), 'robe_ash');
    });
  });

  group('옷장', () {
    test('아이템 ID가 중복되지 않는다', () {
      final ids = kWardrobe.map((i) => i.id).toList();
      expect(ids.length, ids.toSet().length);
    });

    test('기본 착용은 공덕 0인 아이템만 쓴다', () {
      for (final id in kDefaultEquip.items.values) {
        final item = wardrobeItem(id);
        expect(item, isNotNull, reason: id);
        expect(item!.meritCost, 0, reason: id);
      }
    });

    test('슬롯별 조회', () {
      expect(wardrobeFor(AvatarSlot.top), isNotEmpty);
      expect(
        wardrobeFor(AvatarSlot.head).every((i) => i.slot == AvatarSlot.head),
        isTrue,
      );
      expect(wardrobeFor(AvatarSlot.body), isEmpty);
    });

    test('없는 ID는 null', () {
      expect(wardrobeItem('없음'), isNull);
      expect(wardrobeItem(null), isNull);
    });
  });

  group('MonkFigure', () {
    Widget wrap(Widget child, {Brightness b = Brightness.light}) => MaterialApp(
          theme: b == Brightness.light ? AppTheme.light() : AppTheme.dark(),
          home: Scaffold(body: Center(child: child)),
        );

    testWidgets('기본 착용으로 그려진다', (tester) async {
      await tester.pumpWidget(wrap(const MonkFigure()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('모든 가사·머리 조합이 예외 없이 그려진다', (tester) async {
      for (final top in wardrobeFor(AvatarSlot.top)) {
        for (final head in wardrobeFor(AvatarSlot.head)) {
          final equip = const AvatarEquip()
              .wear(AvatarSlot.top, top.id)
              .wear(AvatarSlot.head, head.id);
          await tester.pumpWidget(wrap(MonkFigure(equip: equip)));
          expect(tester.takeException(), isNull,
              reason: '${top.id} + ${head.id}');
        }
      }
    });

    testWidgets('단주를 걸어도 문제없다', (tester) async {
      final equip =
          kDefaultEquip.wear(AvatarSlot.accessory, 'acc_beads');
      for (final pose in MonkPose.values) {
        await tester.pumpWidget(wrap(MonkFigure(equip: equip, pose: pose)));
        expect(tester.takeException(), isNull, reason: pose.name);
      }
    });

    testWidgets('절하는 자세도 그려진다', (tester) async {
      await tester
          .pumpWidget(wrap(const MonkFigure(pose: MonkPose.bowing)));
      expect(tester.takeException(), isNull);
    });

    testWidgets('아무것도 안 입어도 그려진다', (tester) async {
      await tester.pumpWidget(wrap(const MonkFigure(equip: AvatarEquip())));
      expect(tester.takeException(), isNull);
    });

    testWidgets('다크 모드', (tester) async {
      await tester
          .pumpWidget(wrap(const MonkFigure(), b: Brightness.dark));
      expect(tester.takeException(), isNull);
    });

    testWidgets('숨쉬기 애니메이션이 프레임을 넘겨도 죽지 않는다', (tester) async {
      await tester.pumpWidget(wrap(const MonkFigure(breathing: true)));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('스크린 리더 라벨이 자세에 따라 붙는다', (tester) async {
      await tester.pumpWidget(wrap(const MonkFigure()));
      expect(find.bySemanticsLabel('서 있는 스님'), findsOneWidget);

      await tester
          .pumpWidget(wrap(const MonkFigure(pose: MonkPose.bowing)));
      expect(find.bySemanticsLabel('절하는 스님'), findsOneWidget);
    });
  });
}
