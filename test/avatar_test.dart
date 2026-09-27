import 'package:bucheo_handsome/app/theme.dart';
import 'package:bucheo_handsome/features/avatar/avatar_equip.dart';
import 'package:bucheo_handsome/features/avatar/buddha_figure.dart';
import 'package:bucheo_handsome/features/avatar/item_thumb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AvatarEquip', () {
    test('입고 벗기', () {
      const e = AvatarEquip();
      expect(e.isEmpty, isTrue);

      final worn = e.wear(AvatarSlot.robe, 'robe_saffron');
      expect(worn.of(AvatarSlot.robe), 'robe_saffron');
      expect(e.of(AvatarSlot.robe), isNull, reason: '원본은 그대로여야 한다');
      expect(worn.takeOff(AvatarSlot.robe).of(AvatarSlot.robe), isNull);
    });

    test('같은 슬롯은 덮어쓴다', () {
      final e = const AvatarEquip()
          .wear(AvatarSlot.robe, 'robe_temple')
          .wear(AvatarSlot.robe, 'robe_ash');
      expect(e.items.length, 1);
      expect(e.of(AvatarSlot.robe), 'robe_ash');
    });

    test('toggle — 같은 걸 다시 누르면 벗는다', () {
      final on = const AvatarEquip().toggle(AvatarSlot.accessory, 'acc_beads');
      expect(on.of(AvatarSlot.accessory), 'acc_beads');
      expect(on.toggle(AvatarSlot.accessory, 'acc_beads').of(AvatarSlot.accessory),
          isNull);
      // 다른 걸 누르면 갈아 낀다.
      expect(
        on.toggle(AvatarSlot.accessory, 'acc_glasses').of(AvatarSlot.accessory),
        'acc_glasses',
      );
    });

    test('직렬화 왕복', () {
      final e = const AvatarEquip()
          .wear(AvatarSlot.robe, 'robe_ash')
          .wear(AvatarSlot.head, 'head_nabal')
          .wear(AvatarSlot.accessory, 'acc_beads')
          .wear(AvatarSlot.halo, 'halo_ring')
          .wear(AvatarSlot.seat, 'seat_lotus');
      final back = AvatarEquip.decode(e.encode());
      expect(back, e);
      expect(back.of(AvatarSlot.seat), 'seat_lotus');
    });

    test('깨진 값이나 빈 값이면 빈 착용으로 돌아온다', () {
      expect(AvatarEquip.decode(null).isEmpty, isTrue);
      expect(AvatarEquip.decode('').isEmpty, isTrue);
      expect(AvatarEquip.decode('{}').isEmpty, isTrue);
      expect(AvatarEquip.decode('not json').isEmpty, isTrue);
      expect(AvatarEquip.decode('[1,2,3]').isEmpty, isTrue);
    });

    test('모르는 슬롯과 사라진 아이템은 버린다', () {
      // 카탈로그가 바뀌어도 앱이 깨지지 않아야 한다.
      final e = AvatarEquip.decode(
          '{"robe":"robe_ash","wings":"x","head":"없어진아이템"}');
      expect(e.items.length, 1);
      expect(e.of(AvatarSlot.robe), 'robe_ash');
    });

    test('같은 구성이면 같다고 본다', () {
      final a = const AvatarEquip().wear(AvatarSlot.robe, 'robe_ash');
      final b = const AvatarEquip().wear(AvatarSlot.robe, 'robe_ash');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('옷장', () {
    test('아이템 ID가 중복되지 않는다', () {
      final ids = kWardrobe.map((i) => i.id).toList();
      expect(ids.length, ids.toSet().length);
    });

    test('기본 착용은 공덕 0짜리만 쓴다', () {
      for (final id in kDefaultEquip.items.values) {
        final item = wardrobeItem(id);
        expect(item, isNotNull, reason: id);
        expect(item!.isFree, isTrue, reason: id);
      }
    });

    test('머리와 가사는 공짜 기본값이 하나씩 있다', () {
      for (final slot in [AvatarSlot.head, AvatarSlot.robe]) {
        expect(wardrobeFor(slot).where((i) => i.isFree), isNotEmpty,
            reason: slot.name);
      }
    });

    test('비울 수 있는 슬롯에는 공짜 아이템이 없어도 된다', () {
      expect(kOptionalSlots.contains(AvatarSlot.accessory), isTrue);
      expect(kOptionalSlots.contains(AvatarSlot.head), isFalse);
      expect(kOptionalSlots.contains(AvatarSlot.robe), isFalse);
    });

    test('슬롯별 조회', () {
      expect(wardrobeFor(AvatarSlot.head), isNotEmpty);
      expect(
        wardrobeFor(AvatarSlot.robe).every((i) => i.slot == AvatarSlot.robe),
        isTrue,
      );
    });

    test('모든 슬롯에 이름이 있다', () {
      for (final s in AvatarSlot.values) {
        expect(kSlotNames[s], isNotNull, reason: s.name);
      }
    });

    test('없는 ID는 null', () {
      expect(wardrobeItem('없음'), isNull);
      expect(wardrobeItem(null), isNull);
      expect(wardrobeItem(42), isNull);
    });

    test('ownsItem — 공짜는 처음부터 가진 것', () {
      final free = kWardrobe.firstWhere((i) => i.isFree);
      final paid = kWardrobe.firstWhere((i) => !i.isFree);
      expect(ownsItem(free, {}), isTrue);
      expect(ownsItem(paid, {}), isFalse);
      expect(ownsItem(paid, {paid.id}), isTrue);
    });
  });

  group('BuddhaFigure', () {
    Widget wrap(Widget child, {Brightness b = Brightness.light}) => MaterialApp(
          theme: b == Brightness.light ? AppTheme.light() : AppTheme.dark(),
          home: Scaffold(body: Center(child: child)),
        );

    testWidgets('기본 착용으로 그려진다', (tester) async {
      await tester.pumpWidget(wrap(const BuddhaFigure()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('모든 아이템을 하나씩 입혀도 예외가 없다', (tester) async {
      for (final item in kWardrobe) {
        final equip = kDefaultEquip.wear(item.slot, item.id);
        for (final pose in BuddhaPose.values) {
          await tester
              .pumpWidget(wrap(BuddhaFigure(equip: equip, pose: pose)));
          expect(tester.takeException(), isNull,
              reason: '${item.id} / ${pose.name}');
        }
      }
    });

    testWidgets('전부 껴입어도 그려진다', (tester) async {
      var equip = kDefaultEquip;
      for (final slot in AvatarSlot.values) {
        final items = wardrobeFor(slot);
        if (items.isNotEmpty) equip = equip.wear(slot, items.last.id);
      }
      await tester.pumpWidget(wrap(BuddhaFigure(equip: equip)));
      expect(tester.takeException(), isNull);
    });

    testWidgets('아무것도 안 입어도 그려진다', (tester) async {
      await tester.pumpWidget(wrap(const BuddhaFigure(equip: AvatarEquip())));
      expect(tester.takeException(), isNull);
    });

    testWidgets('다크 모드', (tester) async {
      await tester.pumpWidget(wrap(const BuddhaFigure(), b: Brightness.dark));
      expect(tester.takeException(), isNull);
    });

    testWidgets('숨쉬기 애니메이션이 프레임을 넘겨도 죽지 않는다', (tester) async {
      await tester.pumpWidget(wrap(const BuddhaFigure(breathing: true)));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('스크린 리더 라벨이 자세에 따라 붙는다', (tester) async {
      await tester.pumpWidget(wrap(const BuddhaFigure()));
      expect(find.bySemanticsLabel('내 부처님'), findsOneWidget);

      await tester
          .pumpWidget(wrap(const BuddhaFigure(pose: BuddhaPose.bowing)));
      expect(find.bySemanticsLabel('절하는 부처님'), findsOneWidget);
    });
  });

  group('ItemThumbPainter', () {
    testWidgets('옷장의 모든 아이템 그림이 그려진다', (tester) async {
      for (final item in kWardrobe) {
        for (final dim in [true, false]) {
          await tester.pumpWidget(MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: Center(
                child: CustomPaint(
                  size: const Size(54, 54),
                  painter: ItemThumbPainter(item: item, dim: dim),
                ),
              ),
            ),
          ));
          expect(tester.takeException(), isNull,
              reason: '${item.id} dim=$dim');
        }
      }
    });
  });
}
