import 'package:bucheo_handsome/app/theme.dart';
import 'package:bucheo_handsome/features/avatar/avatar_equip.dart';
import 'package:bucheo_handsome/features/avatar/buddha_figure.dart';
import 'package:bucheo_handsome/features/avatar/item_thumb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {Brightness b = Brightness.light}) => MaterialApp(
      theme: b == Brightness.light ? AppTheme.light() : AppTheme.dark(),
      home: Scaffold(body: Center(child: child)),
    );

/// Image.asset이 실제로 가리키는 경로.
List<String> _assetPaths(WidgetTester tester) => tester
    .widgetList<Image>(find.byType(Image))
    .map((w) => (w.image as AssetImage).assetName)
    .toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AvatarEquip', () {
    test('입고 벗기', () {
      const e = AvatarEquip();
      expect(e.isEmpty, isTrue);

      final worn = e.wear(AvatarSlot.robe, 'robe_ash');
      expect(worn.of(AvatarSlot.robe), 'robe_ash');
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
      expect(
        on.toggle(AvatarSlot.accessory, 'acc_beads').of(AvatarSlot.accessory),
        isNull,
      );
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
      expect(AvatarEquip.decode(e.encode()), e);
    });

    test('깨진 값이나 빈 값이면 빈 착용으로 돌아온다', () {
      expect(AvatarEquip.decode(null).isEmpty, isTrue);
      expect(AvatarEquip.decode('').isEmpty, isTrue);
      expect(AvatarEquip.decode('{}').isEmpty, isTrue);
      expect(AvatarEquip.decode('not json').isEmpty, isTrue);
      expect(AvatarEquip.decode('[1,2,3]').isEmpty, isTrue);
    });

    test('모르는 슬롯과 사라진 아이템은 버린다', () {
      final e = AvatarEquip.decode(
          '{"robe":"robe_ash","wings":"x","head":"없어진아이템"}');
      expect(e.items.length, 1);
      expect(e.of(AvatarSlot.robe), 'robe_ash');
    });

    test('예전에 저장한 기본 가사 ID가 그대로 살아 있다', () {
      // robe_temple 은 기본값에서 해금 아이템으로 바뀌었을 뿐 사라지지 않았다.
      final e = AvatarEquip.decode('{"robe":"robe_temple"}');
      expect(e.of(AvatarSlot.robe), 'robe_temple');
    });
  });

  group('옷장 카탈로그', () {
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

    test('비울 수 있는 슬롯 구분', () {
      expect(kOptionalSlots.contains(AvatarSlot.accessory), isTrue);
      expect(kOptionalSlots.contains(AvatarSlot.head), isFalse);
      expect(kOptionalSlots.contains(AvatarSlot.robe), isFalse);
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

    test('민머리만 레이어가 없다', () {
      final noLayer = kWardrobe.where((i) => !i.hasLayer).map((i) => i.id);
      expect(noLayer, ['head_shaved']);
    });
  });

  group('에셋 실재 여부', () {
    /// 선언된 경로에 파일이 실제로 있는지 번들에서 확인한다.
    Future<bool> exists(String path) async {
      try {
        await rootBundle.load(path);
        return true;
      } catch (_) {
        return false;
      }
    }

    test('모든 아이템의 레이어 파일이 있다', () async {
      for (final item in kWardrobe) {
        final path = item.assetPath;
        if (path == null) continue;
        expect(await exists(path), isTrue, reason: path);
      }
    });

    test('모든 아이템의 썸네일 파일이 있다', () async {
      for (final item in kWardrobe) {
        expect(await exists(item.thumbPath), isTrue, reason: item.thumbPath);
      }
    });
  });

  group('BuddhaFigure — 레이어 구성', () {
    test('그리는 순서가 후광 → 대좌 → 몸 → 머리 → 악세서리', () {
      var equip = kDefaultEquip;
      for (final slot in AvatarSlot.values) {
        final items = wardrobeFor(slot).where((i) => i.hasLayer);
        if (items.isNotEmpty) equip = equip.wear(slot, items.first.id);
      }
      expect(BuddhaFigure.layersOf(equip), [
        'assets/avatar/halo_ring.png',
        'assets/avatar/seat_lotus.png',
        'assets/avatar/base_saffron.png',
        'assets/avatar/head_nabal.png',
        'assets/avatar/acc_beads.png',
      ]);
    });

    test('기본 착용은 몸 한 장뿐 — 민머리는 레이어가 없다', () {
      expect(BuddhaFigure.layersOf(kDefaultEquip),
          ['assets/avatar/base_saffron.png']);
    });

    test('고르지 않은 선택형 아이템은 그리지 않는다', () {
      final layers = BuddhaFigure.layersOf(kDefaultEquip);
      expect(layers.any((p) => p.contains('halo')), isFalse);
      expect(layers.any((p) => p.contains('seat')), isFalse);
      expect(layers.any((p) => p.contains('acc_')), isFalse);
    });

    test('가사가 비어 있어도 몸은 나온다', () {
      // 저장본이 깨져 가사가 빠져도 투명 인간이 되면 안 된다.
      expect(BuddhaFigure.layersOf(const AvatarEquip()),
          ['assets/avatar/base_saffron.png']);
    });

    test('가사를 바꾸면 몸 그림이 바뀐다', () {
      final ash = kDefaultEquip.wear(AvatarSlot.robe, 'robe_ash');
      expect(BuddhaFigure.layersOf(ash), ['assets/avatar/base_ash.png']);
    });
  });

  group('BuddhaFigure — 위젯', () {
    testWidgets('기본 착용으로 그려진다', (tester) async {
      await tester.pumpWidget(_wrap(const BuddhaFigure()));
      expect(tester.takeException(), isNull);
      expect(_assetPaths(tester), ['assets/avatar/base_saffron.png']);
    });

    testWidgets('전부 껴입으면 레이어가 순서대로 쌓인다', (tester) async {
      var equip = kDefaultEquip;
      for (final slot in AvatarSlot.values) {
        final items = wardrobeFor(slot).where((i) => i.hasLayer);
        if (items.isNotEmpty) equip = equip.wear(slot, items.last.id);
      }
      await tester.pumpWidget(_wrap(BuddhaFigure(equip: equip)));
      expect(tester.takeException(), isNull);

      // Stack 자식 순서가 곧 그리는 순서다.
      expect(_assetPaths(tester), [
        'assets/avatar/halo_ring.png',
        'assets/avatar/seat_lotus.png',
        'assets/avatar/base_crimson.png',
        'assets/avatar/head_straw.png',
        'assets/avatar/acc_glasses.png',
      ]);
    });

    testWidgets('모든 아이템을 하나씩 입혀도 예외가 없다', (tester) async {
      for (final item in kWardrobe) {
        await tester.pumpWidget(
            _wrap(BuddhaFigure(equip: kDefaultEquip.wear(item.slot, item.id))));
        expect(tester.takeException(), isNull, reason: item.id);
      }
    });

    testWidgets('레이어가 전부 같은 사각형을 쓴다 — 위치 보정 없음', (tester) async {
      var equip = kDefaultEquip;
      for (final slot in AvatarSlot.values) {
        final items = wardrobeFor(slot).where((i) => i.hasLayer);
        if (items.isNotEmpty) equip = equip.wear(slot, items.first.id);
      }
      await tester.pumpWidget(_wrap(BuddhaFigure(equip: equip, size: 200)));

      final boxes = tester
          .widgetList<Image>(find.byType(Image))
          .map((w) => tester.getRect(find.byWidget(w)))
          .toList();
      expect(boxes.length, 5);
      for (final r in boxes) {
        expect(r, boxes.first, reason: '레이어마다 사각형이 달라지면 정렬이 깨진다');
      }
      // 정사각이어야 contain 결과가 모든 레이어에서 같다.
      expect(boxes.first.width, boxes.first.height);
    });

    testWidgets('모든 레이어가 BoxFit.contain', (tester) async {
      await tester.pumpWidget(_wrap(
          BuddhaFigure(equip: kDefaultEquip.wear(AvatarSlot.halo, 'halo_ring'))));
      for (final image in tester.widgetList<Image>(find.byType(Image))) {
        expect(image.fit, BoxFit.contain);
      }
    });

    testWidgets('다크 모드', (tester) async {
      await tester.pumpWidget(_wrap(const BuddhaFigure(), b: Brightness.dark));
      expect(tester.takeException(), isNull);
    });

    testWidgets('숨쉬기 애니메이션이 프레임을 넘겨도 죽지 않는다', (tester) async {
      await tester.pumpWidget(_wrap(const BuddhaFigure(breathing: true)));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('스크린 리더 라벨', (tester) async {
      await tester.pumpWidget(_wrap(const BuddhaFigure()));
      expect(find.bySemanticsLabel('내 부처님'), findsOneWidget);
    });
  });

  group('ItemThumb', () {
    testWidgets('옷장의 모든 아이템 썸네일이 그려진다', (tester) async {
      for (final item in kWardrobe) {
        for (final dim in [true, false]) {
          await tester.pumpWidget(_wrap(ItemThumb(item: item, dim: dim)));
          expect(tester.takeException(), isNull, reason: '${item.id} dim=$dim');
          expect(_assetPaths(tester), [item.thumbPath]);
        }
      }
    });

    testWidgets('안 가진 아이템은 흐리게', (tester) async {
      final item = kWardrobe.firstWhere((i) => !i.isFree);
      await tester.pumpWidget(_wrap(ItemThumb(item: item, dim: true)));
      final opacity = tester.widget<Opacity>(
        find.ancestor(of: find.byType(Image), matching: find.byType(Opacity)),
      );
      expect(opacity.opacity, lessThan(1));
    });
  });
}
