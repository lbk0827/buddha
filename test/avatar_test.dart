import 'package:bucheo_handsome/app/theme.dart';
import 'package:bucheo_handsome/features/avatar/avatar_equip.dart';
import 'package:bucheo_handsome/features/avatar/bubble_gum_motion.dart';
import 'package:bucheo_handsome/features/avatar/buddha_figure.dart';
import 'package:bucheo_handsome/features/avatar/halo_spin.dart';
import 'package:bucheo_handsome/features/avatar/item_thumb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {Brightness b = Brightness.light}) => MaterialApp(
  theme: b == Brightness.light ? AppTheme.light() : AppTheme.dark(),
  home: Scaffold(body: Center(child: child)),
);

/// Image.asset이 실제로 가리키는 경로. cacheWidth를 주면 ResizeImage로 감싸진다.
String _assetName(ImageProvider image) => switch (image) {
  ResizeImage(:final imageProvider) => _assetName(imageProvider),
  _ => (image as AssetImage).assetName,
};

List<String> _assetPaths(WidgetTester tester) => tester
    .widgetList<Image>(find.byType(Image))
    .map((w) => _assetName(w.image))
    .toList();

Finder _imageOf(String path) => find.byWidgetPredicate(
  (w) => w is Image && _assetName(w.image) == path,
);

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
      final on = const AvatarEquip().toggle(AvatarSlot.neck, 'acc_beads');
      expect(on.of(AvatarSlot.neck), 'acc_beads');
      expect(
        on.toggle(AvatarSlot.neck, 'acc_beads').of(AvatarSlot.neck),
        isNull,
      );
    });

    test('안경과 단주를 같이 쓴다', () {
      final e = const AvatarEquip()
          .toggle(AvatarSlot.face, 'acc_glasses')
          .toggle(AvatarSlot.neck, 'acc_beads');
      expect(e.of(AvatarSlot.face), 'acc_glasses');
      expect(e.of(AvatarSlot.neck), 'acc_beads');
    });

    test('직렬화 왕복', () {
      final e = const AvatarEquip()
          .wear(AvatarSlot.buddha, 'buddha_gold')
          .wear(AvatarSlot.robe, 'robe_ash')
          .wear(AvatarSlot.head, 'head_nabal')
          .wear(AvatarSlot.face, 'acc_glasses')
          .wear(AvatarSlot.neck, 'acc_beads')
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
        '{"robe":"robe_ash","wings":"x","head":"없어진아이템"}',
      );
      expect(e.items.length, 1);
      expect(e.of(AvatarSlot.robe), 'robe_ash');
    });

    test('악세서리 슬롯에 저장한 예전 값이 얼굴·목으로 옮겨진다', () {
      final glasses = AvatarEquip.decode('{"accessory":"acc_glasses"}');
      expect(glasses.of(AvatarSlot.face), 'acc_glasses');
      final beads = AvatarEquip.decode('{"accessory":"acc_beads"}');
      expect(beads.of(AvatarSlot.neck), 'acc_beads');
    });

    test('예전 저장본에 부처가 없으면 살빛 부처를 입은 것으로 본다', () {
      final e = AvatarEquip.decode('{"robe":"robe_ash","head":"head_nabal"}');
      expect(e.of(AvatarSlot.buddha), isNull);
      expect(e.wornIn(AvatarSlot.buddha), 'buddha_flesh');
      expect(e.wornIn(AvatarSlot.robe), 'robe_ash');
      expect(e.wornIn(AvatarSlot.halo), isNull, reason: '선택형은 비어 있으면 빈 채로');
    });

    test('신발 슬롯이 없던 예전 저장본은 맨발로 복원된다', () {
      final e = AvatarEquip.decode(
        '{"buddha":"buddha_jade","robe":"robe_ash","head":"head_nabal",'
        '"face":"acc_glasses","neck":"acc_beads"}',
      );
      expect(e.of(AvatarSlot.feet), isNull);
      expect(e.wornIn(AvatarSlot.feet), isNull, reason: '선택형이라 기본값을 채우지 않는다');
      expect(e.items.length, 5, reason: '기존 착용은 하나도 빠지지 않는다');
    });

    test('새 아이템은 저장된 키가 달라도 아이템 id로 제 슬롯을 찾는다', () {
      final e = AvatarEquip.decode(
        '{"accessory":"acc_neckphones","x":"feet_sneakers",'
        '"face":"acc_pinkshades","robe":"robe_lavender"}',
      );
      expect(e.of(AvatarSlot.neck), 'acc_neckphones');
      expect(e.of(AvatarSlot.feet), 'feet_sneakers');
      expect(e.of(AvatarSlot.face), 'acc_pinkshades');
      expect(e.of(AvatarSlot.robe), 'robe_lavender');
    });

    test('신발까지 입은 한 벌도 직렬화 왕복', () {
      final e = kDefaultEquip
          .wear(AvatarSlot.feet, 'feet_sneakers')
          .wear(AvatarSlot.neck, 'acc_goldbeads')
          .wear(AvatarSlot.face, 'acc_sunglasses');
      expect(AvatarEquip.decode(e.encode()), e);
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

    test('부처·머리·가사는 공짜 기본값이 하나씩 있다', () {
      for (final slot in [
        AvatarSlot.buddha,
        AvatarSlot.head,
        AvatarSlot.robe,
      ]) {
        expect(
          wardrobeFor(slot).where((i) => i.isFree),
          isNotEmpty,
          reason: slot.name,
        );
      }
    });

    test('비울 수 있는 슬롯 구분', () {
      expect(
        kOptionalSlots.contains(AvatarSlot.feet),
        isTrue,
        reason: '맨발이 기본이다',
      );
      expect(kOptionalSlots.contains(AvatarSlot.face), isTrue);
      expect(kOptionalSlots.contains(AvatarSlot.neck), isTrue);
      expect(kOptionalSlots.contains(AvatarSlot.buddha), isFalse);
      expect(kOptionalSlots.contains(AvatarSlot.head), isFalse);
      expect(kOptionalSlots.contains(AvatarSlot.robe), isFalse);
    });

    test('비울 수 없는 슬롯은 기본 착용에 다 들어 있다', () {
      for (final s in AvatarSlot.values) {
        if (kOptionalSlots.contains(s)) continue;
        expect(kDefaultEquip.of(s), isNotNull, reason: s.name);
      }
    });

    test('모든 슬롯에 아이템이 있다', () {
      for (final s in AvatarSlot.values) {
        expect(wardrobeFor(s), isNotEmpty, reason: s.name);
      }
    });

    test('모든 슬롯에 이름이 있다', () {
      for (final s in AvatarSlot.values) {
        expect(kSlotNames[s], isNotNull, reason: s.name);
      }
    });

    test('비니·버킷햇·풍선껌이 제 슬롯과 공덕으로 들어 있다', () {
      final beanie = wardrobeItem('head_beanie')!;
      final bucket = wardrobeItem('head_bucket')!;
      final gum = wardrobeItem('mouth_bubblegum')!;
      expect((beanie.slot, beanie.meritCost), (AvatarSlot.head, 400));
      expect((bucket.slot, bucket.meritCost), (AvatarSlot.head, 500));
      expect((gum.slot, gum.meritCost), (AvatarSlot.mouth, 800));
      expect(beanie.skinPath, 'assets/avatar/skin_head_beanie.webp');
      expect(bucket.skinPath, 'assets/avatar/skin_head_bucket.webp');
      expect(gum.poppedPath, 'assets/avatar/mouth_bubblegum_popped.webp');
      expect(gum.skinPath, isNull, reason: '껌에는 살이 없다');
      expect(kOptionalSlots.contains(AvatarSlot.mouth), isTrue);
    });

    test('움직이는 아이템은 풍선껌뿐이다', () {
      expect(kWardrobe.where((i) => i.poppedPath != null).map((i) => i.id), [
        'mouth_bubblegum',
      ]);
    });

    test('입 슬롯이 없던 예전 저장본도 그대로, 풍선껌 저장본은 제자리로', () {
      final old = AvatarEquip.decode(
        '{"robe":"robe_ash","face":"acc_glasses"}',
      );
      expect(old.wornIn(AvatarSlot.mouth), isNull);
      final gum = AvatarEquip.decode(
        '{"face":"acc_pinkshades","x":"mouth_bubblegum"}',
      );
      expect(gum.of(AvatarSlot.mouth), 'mouth_bubblegum');
      expect(gum.of(AvatarSlot.face), 'acc_pinkshades', reason: '선글라스와 같이 쓴다');
    });

    test('신규 소품·가사 6종이 제 슬롯과 공덕으로 들어 있다', () {
      const expected = {
        'acc_sunglasses': (AvatarSlot.face, 700),
        'acc_pinkshades': (AvatarSlot.face, 900),
        'acc_neckphones': (AvatarSlot.neck, 900),
        'acc_goldbeads': (AvatarSlot.neck, 1300),
        'feet_sneakers': (AvatarSlot.feet, 600),
        'robe_lavender': (AvatarSlot.robe, 600),
      };
      for (final MapEntry(key: id, value: (slot, cost)) in expected.entries) {
        final item = wardrobeItem(id);
        expect(item, isNotNull, reason: id);
        expect(item!.slot, slot, reason: id);
        expect(item.meritCost, cost, reason: id);
        expect(item.hasLayer, isTrue, reason: id);
      }
      expect(
        wardrobeItem('robe_lavender')!.skinPath,
        'assets/avatar/skin_body.webp',
      );
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

    test('레이어가 없는 건 민머리와 부처뿐', () {
      for (final item in kWardrobe.where((i) => !i.hasLayer)) {
        expect(
          item.id == 'head_shaved' || item.slot == AvatarSlot.buddha,
          isTrue,
          reason: item.id,
        );
      }
    });

    test('살이 그려진 레이어는 살 레이어를 알고 있다', () {
      // 빠뜨리면 그 옷을 입은 돌부처는 얼굴만 살빛으로 남는다.
      for (final item in kWardrobe) {
        final hasSkin =
            item.hasLayer &&
            (item.slot == AvatarSlot.robe || item.slot == AvatarSlot.head);
        expect(item.skinPath != null, hasSkin, reason: item.id);
      }
    });

    test('살빛 부처만 재질이 없다', () {
      for (final item in wardrobeFor(AvatarSlot.buddha)) {
        expect(item.tint == null, item.id == 'buddha_flesh', reason: item.id);
      }
    });

    test('재질 행렬 — 살 밝기 범위가 어두운 색에서 밝은 색으로 간다', () {
      const t = SkinTint(dark: [10, 20, 30], light: [200, 210, 220]);
      final m = t.matrix;
      expect(m.length, 20);
      expect(m.sublist(15), [0, 0, 0, 1, 0], reason: '알파는 건드리지 않는다');

      double apply(int row, double gray) =>
          m[row * 5] * gray +
          m[row * 5 + 1] * gray +
          m[row * 5 + 2] * gray +
          m[row * 5 + 4];
      // 회색은 휘도가 곧 그 값이다.
      expect(apply(0, 90), closeTo(10, 1e-9));
      expect(apply(0, 235), closeTo(200, 1e-9));
      expect(apply(2, 235), closeTo(220, 1e-9));
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

    test('모든 살 레이어 파일이 있다', () async {
      for (final item in kWardrobe) {
        final path = item.skinPath;
        if (path == null) continue;
        expect(await exists(path), isTrue, reason: path);
      }
    });

    test('움직이는 아이템의 두 번째 그림이 있다', () async {
      for (final item in kWardrobe) {
        final path = item.poppedPath;
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
    List<String> paths(AvatarEquip e) =>
        BuddhaFigure.layersOf(e).map((l) => l.path).toList();

    test('그리는 순서가 후광 → 대좌 → 몸 → 발 → 머리 → 얼굴 → 목 → 입', () {
      var equip = kDefaultEquip;
      for (final slot in AvatarSlot.values) {
        final items = wardrobeFor(slot).where((i) => i.hasLayer);
        if (items.isNotEmpty) equip = equip.wear(slot, items.first.id);
      }
      expect(paths(equip), [
        'assets/avatar/halo_ring.webp',
        'assets/avatar/seat_lotus.webp',
        'assets/avatar/base_saffron.webp',
        'assets/avatar/feet_sneakers.webp',
        'assets/avatar/head_nabal.webp',
        'assets/avatar/acc_glasses.webp',
        'assets/avatar/acc_beads.webp',
        'assets/avatar/mouth_bubblegum.webp',
      ]);
    });

    test('기본 착용은 몸 한 장뿐 — 민머리·살빛 부처는 레이어가 없다', () {
      expect(paths(kDefaultEquip), ['assets/avatar/base_saffron.webp']);
    });

    test('고르지 않은 선택형 아이템은 그리지 않는다', () {
      final layers = paths(kDefaultEquip);
      expect(layers.any((p) => p.contains('halo')), isFalse);
      expect(layers.any((p) => p.contains('seat')), isFalse);
      expect(layers.any((p) => p.contains('acc_')), isFalse);
    });

    test('가사가 비어 있어도 몸은 나온다', () {
      // 저장본이 깨져 가사가 빠져도 투명 인간이 되면 안 된다.
      expect(paths(const AvatarEquip()), ['assets/avatar/base_saffron.webp']);
    });

    test('가사를 바꾸면 몸 그림이 바뀐다', () {
      final ash = kDefaultEquip.wear(AvatarSlot.robe, 'robe_ash');
      expect(paths(ash), ['assets/avatar/base_ash.webp']);
    });

    test('풍선껌 레이어는 터진 껌 경로를 같이 들고 맨 위에 온다', () {
      final equip = kDefaultEquip
          .wear(AvatarSlot.face, 'acc_pinkshades')
          .wear(AvatarSlot.mouth, 'mouth_bubblegum');
      expect(
        BuddhaFigure.layersOf(equip).last,
        const AvatarLayer(
          'assets/avatar/mouth_bubblegum.webp',
          null,
          'assets/avatar/mouth_bubblegum_popped.webp',
        ),
      );
    });

    test('재질을 입으면 살이 있는 레이어 바로 위에 물든 살이 겹친다', () {
      final gold = wardrobeItem('buddha_gold')!.tint;
      final equip = kDefaultEquip
          .wear(AvatarSlot.buddha, 'buddha_gold')
          .wear(AvatarSlot.head, 'head_nabal')
          .wear(AvatarSlot.neck, 'acc_beads');
      expect(BuddhaFigure.layersOf(equip), [
        const AvatarLayer('assets/avatar/base_saffron.webp'),
        AvatarLayer('assets/avatar/skin_body.webp', gold),
        const AvatarLayer('assets/avatar/head_nabal.webp'),
        AvatarLayer('assets/avatar/skin_head_nabal.webp', gold),
        const AvatarLayer('assets/avatar/acc_beads.webp'),
      ]);
    });

    test('물건 레이어는 재질이 있어도 물들지 않는다', () {
      var equip = kDefaultEquip.wear(AvatarSlot.buddha, 'buddha_stone');
      for (final slot in AvatarSlot.values) {
        final items = wardrobeFor(slot).where((i) => i.hasLayer);
        if (items.isNotEmpty) equip = equip.wear(slot, items.last.id);
      }
      for (final layer in BuddhaFigure.layersOf(equip)) {
        expect(
          layer.tint != null,
          layer.path.contains('/skin_'),
          reason: layer.path,
        );
      }
    });

    test('신발은 물든 살 위에 온다 — 재질 입은 맨발이 비치지 않게', () {
      final stone = wardrobeItem('buddha_stone')!.tint;
      final equip = kDefaultEquip
          .wear(AvatarSlot.buddha, 'buddha_stone')
          .wear(AvatarSlot.feet, 'feet_sneakers');
      expect(BuddhaFigure.layersOf(equip), [
        const AvatarLayer('assets/avatar/base_saffron.webp'),
        AvatarLayer('assets/avatar/skin_body.webp', stone),
        const AvatarLayer('assets/avatar/feet_sneakers.webp'),
      ]);
    });

    test('라벤더 가사도 몸의 살 레이어를 같이 쓴다', () {
      final equip = kDefaultEquip
          .wear(AvatarSlot.buddha, 'buddha_pink')
          .wear(AvatarSlot.robe, 'robe_lavender');
      expect(paths(equip), [
        'assets/avatar/base_lavender.webp',
        'assets/avatar/skin_body.webp',
      ]);
    });

    test('민머리 돌부처는 몸의 살만 물든다', () {
      final equip = kDefaultEquip.wear(AvatarSlot.buddha, 'buddha_stone');
      expect(paths(equip), [
        'assets/avatar/base_saffron.webp',
        'assets/avatar/skin_body.webp',
      ]);
    });

    test('예전 저장본(부처 없음)도 살빛으로 그려진다', () {
      final old = AvatarEquip.decode('{"robe":"robe_ash","head":"head_nabal"}');
      expect(BuddhaFigure.layersOf(old).every((l) => l.tint == null), isTrue);
    });
  });

  group('BuddhaFigure — 위젯', () {
    testWidgets('LP·로딩 후광만 돌고, 멈춘 화면에서는 돌지 않는다', (tester) async {
      for (final id in ['halo_lp', 'halo_loading']) {
        final equip = kDefaultEquip.wear(AvatarSlot.halo, id);
        await tester.pumpWidget(
          _wrap(BuddhaFigure(equip: equip, motion: AvatarMotion.loop)),
        );
        expect(find.byType(HaloSpin), findsOneWidget, reason: id);
        await tester.pumpWidget(_wrap(BuddhaFigure(equip: equip)));
        expect(find.byType(HaloSpin), findsNothing, reason: id);
      }
      final ring = kDefaultEquip.wear(AvatarSlot.halo, 'halo_ring');
      await tester.pumpWidget(
        _wrap(BuddhaFigure(equip: ring, motion: AvatarMotion.loop)),
      );
      expect(find.byType(HaloSpin), findsNothing);
    });

    testWidgets('기본 착용으로 그려진다', (tester) async {
      await tester.pumpWidget(_wrap(const BuddhaFigure()));
      expect(tester.takeException(), isNull);
      expect(_assetPaths(tester), ['assets/avatar/base_saffron.webp']);
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
        'assets/avatar/halo_neon.webp',
        'assets/avatar/seat_kickboard.webp',
        'assets/avatar/base_lavender.webp',
        'assets/avatar/feet_platformboots.webp',
        'assets/avatar/head_bucket.webp',
        'assets/avatar/acc_cybervisor.webp',
        'assets/avatar/acc_neckphones_mint.webp',
        'assets/avatar/mouth_grillz.webp',
      ]);
    });

    testWidgets('재질은 살 레이어에만 색 필터로 입힌다', (tester) async {
      final equip = kDefaultEquip
          .wear(AvatarSlot.buddha, 'buddha_jade')
          .wear(AvatarSlot.head, 'head_straw');
      await tester.pumpWidget(_wrap(BuddhaFigure(equip: equip)));
      expect(tester.takeException(), isNull);

      final filtered = tester
          .widgetList<Image>(
            find.descendant(
              of: find.byType(ColorFiltered),
              matching: find.byType(Image),
            ),
          )
          .map((w) => _assetName(w.image));
      expect(filtered, [
        'assets/avatar/skin_body.webp',
        'assets/avatar/skin_head_straw.webp',
      ]);
    });

    testWidgets('모든 아이템을 하나씩 입혀도 예외가 없다', (tester) async {
      for (final item in kWardrobe) {
        await tester.pumpWidget(
          _wrap(BuddhaFigure(equip: kDefaultEquip.wear(item.slot, item.id))),
        );
        expect(tester.takeException(), isNull, reason: item.id);
      }
    });

    testWidgets('레이어가 전부 같은 사각형을 쓴다 — 위치 보정 없음', (tester) async {
      // 물든 살 레이어도 같은 사각형이어야 한다.
      var equip = kDefaultEquip.wear(AvatarSlot.buddha, 'buddha_gold');
      for (final slot in AvatarSlot.values) {
        final items = wardrobeFor(slot).where((i) => i.hasLayer);
        if (items.isNotEmpty) equip = equip.wear(slot, items.first.id);
      }
      await tester.pumpWidget(_wrap(BuddhaFigure(equip: equip, size: 200)));

      final boxes = tester
          .widgetList<Image>(find.byType(Image))
          .map((w) => tester.getRect(find.byWidget(w)))
          .toList();
      // 후광·대좌·몸·물든 몸·발·머리·물든 머리·얼굴·목·입
      expect(boxes.length, 10);
      // 후광(맨 앞)만 일부러 키우고 올린다(HaloFrame). 나머지는 모두 같아야 한다.
      final body = boxes[1];
      for (final r in boxes.skip(1)) {
        expect(r, body, reason: '레이어마다 사각형이 달라지면 정렬이 깨진다');
      }
      // 정사각이어야 contain 결과가 모든 레이어에서 같다.
      expect(body.width, body.height);

      // 후광은 링 중심을 축으로 kHaloScale 배, kHaloLift 만큼 위.
      final halo = boxes.first;
      expect(halo.width, closeTo(body.width * kHaloScale, 0.01));
      final cx = body.left + (kHaloCenter.x + 1) / 2 * body.width;
      final cy = body.top + (kHaloCenter.y + 1) / 2 * body.height;
      final lift = kHaloLift / 1024 * body.height;
      expect(halo.left, closeTo(cx - (cx - body.left) * kHaloScale, 0.01));
      expect(halo.top, closeTo(cy - (cy - body.top) * kHaloScale - lift, 0.01));
    });

    testWidgets('모든 레이어가 BoxFit.contain', (tester) async {
      await tester.pumpWidget(
        _wrap(
          BuddhaFigure(equip: kDefaultEquip.wear(AvatarSlot.halo, 'halo_ring')),
        ),
      );
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

  group('풍선껌 연출 — 타임라인', () {
    test('처음에는 작은 풍선', () {
      final f = BubbleGumFrame.at(0);
      expect(f.bubbleScale, closeTo(0.15, 1e-9));
      expect(f.showsPopped, isFalse);
    });

    test('부풀기 끝에서 다 부푼다', () {
      expect(BubbleGumFrame.at(0.2999).bubbleScale, closeTo(1, 0.01));
    });

    test('터지면 풍선이 사라지고 붙은 껌이 남는다', () {
      final f = BubbleGumFrame.at(0.45);
      expect(f.showsBubble, isFalse);
      expect(f.poppedScale, 1);
      expect(f.poppedOpacity, 1);
    });

    test('터지는 순간 풍선은 살짝 커지며 흐려진다', () {
      final f = BubbleGumFrame.at(0.31);
      expect(f.bubbleScale, greaterThan(1));
      expect(f.bubbleOpacity, lessThan(1));
    });

    test('붙은 껌은 입 쪽으로 작아지며 빨려 들어간다', () {
      final a = BubbleGumFrame.at(0.57), b = BubbleGumFrame.at(0.61);
      expect(b.poppedScale, lessThan(a.poppedScale));
      expect(b.poppedOpacity, lessThan(a.poppedOpacity));
    });

    test('반복할 때는 빨아들인 뒤 비워 두고 쉰다', () {
      final f = BubbleGumFrame.at(0.8);
      expect(f.showsBubble || f.showsPopped, isFalse);
    });

    test('한 번만 돌 때는 다시 부풀어 다 부푼 풍선으로 끝난다', () {
      final f = BubbleGumFrame.at(1, once: true);
      expect(f.bubbleScale, closeTo(1, 1e-9));
      expect(f.bubbleOpacity, 1);
      expect(f.showsPopped, isFalse);
    });

    test('범위를 벗어난 값은 잘라 쓴다', () {
      expect(
        BubbleGumFrame.at(-1).bubbleScale,
        BubbleGumFrame.at(0).bubbleScale,
      );
      expect(
        BubbleGumFrame.at(2).showsBubble,
        BubbleGumFrame.at(1).showsBubble,
      );
    });

    test('기준점은 입 (510, 396)', () {
      expect((kMouthAnchor.x + 1) * 512, closeTo(510, 1e-9));
      expect((kMouthAnchor.y + 1) * 512, closeTo(396, 1e-9));
    });
  });

  group('풍선껌 연출 — 위젯', () {
    final gum = kDefaultEquip.wear(AvatarSlot.mouth, 'mouth_bubblegum');
    const bubble = 'assets/avatar/mouth_bubblegum.webp';
    const popped = 'assets/avatar/mouth_bubblegum_popped.webp';

    testWidgets('멈춘 그림은 풍선 한 장', (tester) async {
      await tester.pumpWidget(_wrap(BuddhaFigure(equip: gum)));
      expect(find.byType(BubbleGumMotion), findsNothing);
      expect(_assetPaths(tester).last, bubble);
      expect(_assetPaths(tester).contains(popped), isFalse);
    });

    testWidgets('반복하면 터진 껌이 나왔다가 사라진다', (tester) async {
      await tester.pumpWidget(
        _wrap(BuddhaFigure(equip: gum, motion: AvatarMotion.loop)),
      );
      expect(find.byType(BubbleGumMotion), findsOneWidget);
      expect(_assetPaths(tester).contains(bubble), isTrue);

      await tester.pump(const Duration(milliseconds: 3000)); // 0.43
      expect(_assetPaths(tester).contains(popped), isTrue);
      expect(_assetPaths(tester).contains(bubble), isFalse);

      await tester.pump(const Duration(milliseconds: 2600)); // 0.8 — 쉼
      expect(_assetPaths(tester).contains(popped), isFalse);
      expect(_assetPaths(tester).contains(bubble), isFalse);

      await tester.pump(const Duration(milliseconds: 1600)); // 다음 바퀴
      expect(_assetPaths(tester).contains(bubble), isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('한 번만 돌면 다 부푼 풍선에서 멈춘다', (tester) async {
      await tester.pumpWidget(
        _wrap(BuddhaFigure(equip: gum, motion: AvatarMotion.once)),
      );
      await tester.pumpAndSettle();
      final scale = tester.widget<Transform>(
        find
            .ancestor(
              of: _imageOf(bubble),
              matching: find.byType(Transform),
            )
            .first,
      );
      expect(scale.transform.getMaxScaleOnAxis(), closeTo(1, 1e-6));
      expect(_assetPaths(tester).contains(popped), isFalse);
    });

    testWidgets('동작 줄이기를 켜면 움직이지 않는다', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _wrap(BuddhaFigure(equip: gum, motion: AvatarMotion.loop)),
        ),
      );
      expect(find.byType(BubbleGumMotion), findsNothing);
      expect(_assetPaths(tester).last, bubble);
    });

    testWidgets('풍선껌이 없으면 연출도 없다', (tester) async {
      await tester.pumpWidget(
        _wrap(const BuddhaFigure(motion: AvatarMotion.loop)),
      );
      expect(find.byType(BubbleGumMotion), findsNothing);
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
