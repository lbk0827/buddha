import 'dart:convert';

/// 내 부처님의 레이어. 나열 순서가 그대로 그리는 순서다.
/// 후광 → 대좌 → 몸(가사) → 발 → 머리 → 얼굴 → 목 → 입
///
/// 발은 몸 바로 다음이다. 몸 위에 재질 입힌 살이 한 번 더 겹치므로, 그보다
/// 뒤에 그려야 신발이 맨발(과 물든 발)을 덮는다.
///
/// 입은 맨 마지막이다. 풍선껌 풍선은 입에서 앞으로 부풀어 안경 아래 테나
/// 헤드폰보다 앞에 있다.
///
/// 「부처」는 겹칠 그림이 없다. 몸과 머리의 살에 재질을 입힐 뿐이라
/// 그리는 순서와 상관없이 맨 앞에 둔다.
enum AvatarSlot { buddha, halo, seat, robe, feet, head, face, neck, mouth }

/// 옷장 탭에 나오는 순서.
const Map<AvatarSlot, String> kSlotNames = {
  AvatarSlot.buddha: '부처',
  AvatarSlot.head: '머리',
  AvatarSlot.robe: '가사',
  AvatarSlot.face: '얼굴',
  AvatarSlot.mouth: '입',
  AvatarSlot.neck: '목',
  AvatarSlot.feet: '발',
  AvatarSlot.seat: '대좌',
  AvatarSlot.halo: '후광',
};

/// 한 벌. 슬롯마다 아이템 하나.
class AvatarEquip {
  final Map<AvatarSlot, String> items;

  const AvatarEquip([this.items = const {}]);

  String? of(AvatarSlot slot) => items[slot];

  /// 실제로 입고 있는 것. 비울 수 없는 슬롯이 비어 있으면 기본값을 입은 것으로 본다.
  /// 예전 저장본에는 없던 슬롯(부처)이 있어서다.
  String? wornIn(AvatarSlot slot) =>
      items[slot] ??
      (kOptionalSlots.contains(slot) ? null : kDefaultEquip.items[slot]);

  AvatarEquip wear(AvatarSlot slot, String itemId) =>
      AvatarEquip({...items, slot: itemId});

  AvatarEquip takeOff(AvatarSlot slot) => AvatarEquip({...items}..remove(slot));

  /// 이미 입고 있으면 벗고, 아니면 입는다. 비울 수 있는 슬롯에만 쓴다.
  AvatarEquip toggle(AvatarSlot slot, String itemId) =>
      of(slot) == itemId ? takeOff(slot) : wear(slot, itemId);

  bool get isEmpty => items.isEmpty;

  String encode() => jsonEncode(items.map((k, v) => MapEntry(k.name, v)));

  static AvatarEquip decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const AvatarEquip();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const AvatarEquip();
      final out = <AvatarSlot, String>{};
      for (final value in decoded.values) {
        // 슬롯은 저장된 키가 아니라 아이템이 정한다. 슬롯이 나뉘거나
        // 이름이 바뀌어도(악세서리 → 얼굴·목) 예전 저장본이 제자리를 찾는다.
        // 모르는 아이템은 버린다. 카탈로그가 바뀌어도 앱이 깨지지 않는다.
        final item = wardrobeItem(value);
        if (item != null) out[item.slot] = item.id;
      }
      return AvatarEquip(out);
    } catch (_) {
      return const AvatarEquip();
    }
  }

  @override
  bool operator ==(Object other) =>
      other is AvatarEquip && other.encode() == encode();

  @override
  int get hashCode => encode().hashCode;
}

/// 「부처」 아이템이 살에 입히는 재질.
///
/// 살의 밝기를 [dark] → [light] 사이로 옮긴다. 음영은 밝기에 남아 있어서
/// 입체감은 그대로다. [light]를 255보다 크게 잡으면 그 채널이 밝은 곳에서
/// 먼저 하얗게 차서, 금처럼 번쩍이는 하이라이트가 된다.
class SkinTint {
  /// 살 그림의 밝기 범위. 실측하면 살은 대부분 119~224 사이에 몰려 있다.
  /// 이 범위를 색 끝에서 끝까지 늘려 쓴다.
  static const double _lo = 90;
  static const double _hi = 235;

  final List<int> dark;
  final List<int> light;

  const SkinTint({required this.dark, required this.light});

  /// [ColorFilter.matrix]에 그대로 넣는 값.
  List<double> get matrix {
    final rows = <double>[];
    for (var c = 0; c < 3; c++) {
      final k = (light[c] - dark[c]) / (_hi - _lo);
      rows.addAll([k * 0.2126, k * 0.7152, k * 0.0722, 0, dark[c] - k * _lo]);
    }
    return [...rows, 0, 0, 0, 1, 0];
  }
}

class WardrobeItem {
  final String id;
  final String name;
  final AvatarSlot slot;

  /// 공덕으로 연다. 0이면 처음부터 가지고 있다.
  final int meritCost;

  /// 파일명이 id와 다를 때만 쓴다. 가사는 몸 전체라 base_* 로, 부처는
  /// 옷장 칸에 민머리 썸네일을 물들여 쓰므로 head_shaved 로 저장돼 있다.
  final String? file;

  /// 겹칠 그림이 없는 아이템. 민머리는 베이스 그대로, 부처는 재질뿐이라 레이어가 없다.
  final bool hasLayer;

  /// 이 레이어에서 살만 남긴 그림의 파일명. 재질을 입힐 때 레이어 바로 위에 겹친다.
  /// tools/make_avatar_skins.py 가 만든다.
  final String? skin;

  /// 「부처」 아이템의 재질. null이면 원래 살빛.
  final SkinTint? tint;

  /// 움직이는 아이템의 두 번째 그림. 풍선껌은 풍선이 터진 뒤 입에 붙은 껌.
  /// 옷장 칸과 멈춘 화면에는 [assetPath]만 쓴다.
  final String? popped;

  const WardrobeItem({
    required this.id,
    required this.name,
    required this.slot,
    this.meritCost = 0,
    this.file,
    this.hasLayer = true,
    this.skin,
    this.tint,
    this.popped,
  });

  String get _base => file ?? id;

  /// 캐릭터에 겹치는 1024×1024 레이어. 레이어가 없으면 null.
  String? get assetPath => hasLayer ? 'assets/avatar/$_base.webp' : null;

  /// 재질을 입힐 살 레이어. 살이 없는 아이템이면 null.
  String? get skinPath => skin == null ? null : 'assets/avatar/$skin.webp';

  /// 풍선껌 연출의 터진 껌 레이어. 움직이지 않는 아이템이면 null.
  String? get poppedPath =>
      popped == null ? null : 'assets/avatar/$popped.webp';

  /// 옷장 칸에 쓰는, 아이템만 잘라낸 그림.
  String get thumbPath => 'assets/avatar/thumbs/$_base.webp';

  bool get isFree => meritCost == 0;
}

const List<WardrobeItem> kWardrobe = [
  // 부처 — 몸과 얼굴의 살에 재질을 입힌다. 모자·가사·소품은 제 색 그대로다.
  WardrobeItem(
    id: 'buddha_flesh',
    name: '살빛 부처',
    slot: AvatarSlot.buddha,
    file: 'head_shaved',
    hasLayer: false,
  ),
  WardrobeItem(
    id: 'buddha_stone',
    name: '돌부처',
    slot: AvatarSlot.buddha,
    meritCost: 500,
    file: 'head_shaved',
    hasLayer: false,
    tint: SkinTint(dark: [64, 62, 58], light: [236, 232, 222]),
  ),
  // 청동은 넣지 않았다. 금속은 번쩍이는 하이라이트로 읽히는데, 밝기를
  // 색으로 옮기는 것만으로는 그게 안 나와서 갈색 피부처럼 보인다.
  WardrobeItem(
    id: 'buddha_porcelain',
    name: '백자부처',
    slot: AvatarSlot.buddha,
    meritCost: 800,
    file: 'head_shaved',
    hasLayer: false,
    tint: SkinTint(dark: [92, 104, 126], light: [272, 274, 282]),
  ),
  WardrobeItem(
    id: 'buddha_jade',
    name: '옥부처',
    slot: AvatarSlot.buddha,
    meritCost: 1100,
    file: 'head_shaved',
    hasLayer: false,
    tint: SkinTint(dark: [18, 84, 60], light: [206, 255, 222]),
  ),
  // 핑꾸 — 형광 핫핑크. 전시장에 서 있던 벨벳 핑크 불상에서 왔다.
  WardrobeItem(
    id: 'buddha_pink',
    name: '핑꾸부처',
    slot: AvatarSlot.buddha,
    meritCost: 1300,
    file: 'head_shaved',
    hasLayer: false,
    tint: SkinTint(dark: [128, 0, 58], light: [330, 66, 186]),
  ),
  WardrobeItem(
    id: 'buddha_gold',
    name: '황금부처',
    slot: AvatarSlot.buddha,
    meritCost: 1500,
    file: 'head_shaved',
    hasLayer: false,
    tint: SkinTint(dark: [112, 52, 0], light: [330, 226, 64]),
  ),

  // 머리 — 민머리는 베이스 그대로라 겹칠 그림이 없다.
  WardrobeItem(
    id: 'head_shaved',
    name: '민머리',
    slot: AvatarSlot.head,
    hasLayer: false,
  ),
  WardrobeItem(
    id: 'head_nabal',
    name: '나발',
    slot: AvatarSlot.head,
    meritCost: 300,
    skin: 'skin_head_nabal',
  ),
  WardrobeItem(
    id: 'head_bamboo',
    name: '삿갓',
    slot: AvatarSlot.head,
    meritCost: 500,
    skin: 'skin_head_bamboo',
  ),
  WardrobeItem(
    id: 'head_straw',
    name: '밀짚모자',
    slot: AvatarSlot.head,
    meritCost: 700,
    skin: 'skin_head_straw',
  ),
  WardrobeItem(
    id: 'head_beanie',
    name: '비니',
    slot: AvatarSlot.head,
    meritCost: 400,
    skin: 'skin_head_beanie',
  ),
  WardrobeItem(
    id: 'head_bucket',
    name: '버킷햇',
    slot: AvatarSlot.head,
    meritCost: 500,
    skin: 'skin_head_bucket',
  ),

  // 가사 — 겹치는 레이어가 아니라 몸 그림 자체를 바꾼다.
  // 살은 가사가 달라도 같은 픽셀이라 살 레이어 한 장을 같이 쓴다.
  WardrobeItem(
    id: 'robe_saffron',
    name: '황토 가사',
    slot: AvatarSlot.robe,
    file: 'base_saffron',
    skin: 'skin_body',
  ),
  WardrobeItem(
    id: 'robe_temple',
    name: '먹물 가사',
    slot: AvatarSlot.robe,
    meritCost: 200,
    file: 'base_temple',
    skin: 'skin_body',
  ),
  WardrobeItem(
    id: 'robe_ash',
    name: '잿빛 가사',
    slot: AvatarSlot.robe,
    meritCost: 400,
    file: 'base_ash',
    skin: 'skin_body',
  ),
  WardrobeItem(
    id: 'robe_crimson',
    name: '홍가사',
    slot: AvatarSlot.robe,
    meritCost: 900,
    file: 'base_crimson',
    skin: 'skin_body',
  ),
  WardrobeItem(
    id: 'robe_lavender',
    name: '라벤더 가사',
    slot: AvatarSlot.robe,
    meritCost: 600,
    file: 'base_lavender',
    skin: 'skin_body',
  ),

  // 얼굴
  WardrobeItem(
    id: 'acc_glasses',
    name: '안경',
    slot: AvatarSlot.face,
    meritCost: 600,
  ),
  WardrobeItem(
    id: 'acc_sunglasses',
    name: '동그란 선글라스',
    slot: AvatarSlot.face,
    meritCost: 700,
  ),
  WardrobeItem(
    id: 'acc_pinkshades',
    name: '핑크 선글라스',
    slot: AvatarSlot.face,
    meritCost: 900,
  ),

  // 목
  WardrobeItem(
    id: 'acc_beads',
    name: '단주',
    slot: AvatarSlot.neck,
    meritCost: 150,
  ),
  WardrobeItem(
    id: 'acc_neckphones',
    name: '목에 건 헤드폰',
    slot: AvatarSlot.neck,
    meritCost: 900,
  ),
  WardrobeItem(
    id: 'acc_goldbeads',
    name: '금빛 단주',
    slot: AvatarSlot.neck,
    meritCost: 1300,
  ),

  // 입 — 풍선껌은 절 화면에서 부풀었다 터져 입에 붙는다 (BubbleGumMotion).
  WardrobeItem(
    id: 'mouth_bubblegum',
    name: '풍선껌',
    slot: AvatarSlot.mouth,
    meritCost: 800,
    popped: 'mouth_bubblegum_popped',
  ),

  // 발
  WardrobeItem(
    id: 'feet_sneakers',
    name: '흰 운동화',
    slot: AvatarSlot.feet,
    meritCost: 600,
  ),

  // 대좌
  WardrobeItem(
    id: 'seat_lotus',
    name: '연꽃 대좌',
    slot: AvatarSlot.seat,
    meritCost: 1200,
  ),

  // 후광
  WardrobeItem(
    id: 'halo_ring',
    name: '후광',
    slot: AvatarSlot.halo,
    meritCost: 1000,
  ),
];

/// 출가하면 이것부터 입는다. 전부 공덕 0짜리다.
const AvatarEquip kDefaultEquip = AvatarEquip({
  AvatarSlot.buddha: 'buddha_flesh',
  AvatarSlot.robe: 'robe_saffron',
  AvatarSlot.head: 'head_shaved',
});

/// 비워둘 수 있는 슬롯. 부처·머리·가사는 항상 뭔가 입고 있어야 한다.
const Set<AvatarSlot> kOptionalSlots = {
  AvatarSlot.feet,
  AvatarSlot.face,
  AvatarSlot.mouth,
  AvatarSlot.neck,
  AvatarSlot.seat,
  AvatarSlot.halo,
};

WardrobeItem? wardrobeItem(Object? id) {
  if (id is! String) return null;
  for (final i in kWardrobe) {
    if (i.id == id) return i;
  }
  return null;
}

List<WardrobeItem> wardrobeFor(AvatarSlot slot) =>
    kWardrobe.where((i) => i.slot == slot).toList(growable: false);

/// 공덕 0짜리는 처음부터 가진 것으로 친다.
bool ownsItem(WardrobeItem item, Set<String> purchased) =>
    item.isFree || purchased.contains(item.id);
