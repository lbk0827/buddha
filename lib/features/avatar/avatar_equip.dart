import 'dart:convert';

/// 내 부처님의 레이어. 나열 순서가 그대로 그리는 순서다.
/// 후광 → 대좌 → 몸(가사) → 머리 → 악세서리
enum AvatarSlot { halo, seat, robe, head, accessory }

const Map<AvatarSlot, String> kSlotNames = {
  AvatarSlot.head: '머리',
  AvatarSlot.robe: '가사',
  AvatarSlot.accessory: '악세서리',
  AvatarSlot.seat: '대좌',
  AvatarSlot.halo: '후광',
};

/// 한 벌. 슬롯마다 아이템 하나.
class AvatarEquip {
  final Map<AvatarSlot, String> items;

  const AvatarEquip([this.items = const {}]);

  String? of(AvatarSlot slot) => items[slot];

  AvatarEquip wear(AvatarSlot slot, String itemId) =>
      AvatarEquip({...items, slot: itemId});

  AvatarEquip takeOff(AvatarSlot slot) =>
      AvatarEquip({...items}..remove(slot));

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
      final byName = {for (final s in AvatarSlot.values) s.name: s};
      final out = <AvatarSlot, String>{};
      for (final e in decoded.entries) {
        final slot = byName[e.key];
        // 모르는 슬롯·아이템은 버린다. 카탈로그가 바뀌어도 앱이 깨지지 않는다.
        if (slot != null && e.value is String && wardrobeItem(e.value) != null) {
          out[slot] = e.value as String;
        }
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

class WardrobeItem {
  final String id;
  final String name;
  final AvatarSlot slot;

  /// 공덕으로 연다. 0이면 처음부터 가지고 있다.
  final int meritCost;

  /// 파일명이 id와 다를 때만 쓴다 (가사는 몸 전체라 base_* 로 저장돼 있다).
  final String? file;

  /// 겹칠 그림이 없는 아이템. 민머리는 베이스 그대로라 레이어가 없다.
  final bool hasLayer;

  const WardrobeItem({
    required this.id,
    required this.name,
    required this.slot,
    this.meritCost = 0,
    this.file,
    this.hasLayer = true,
  });

  String get _base => file ?? id;

  /// 캐릭터에 겹치는 1024×1024 레이어. 레이어가 없으면 null.
  String? get assetPath => hasLayer ? 'assets/avatar/$_base.png' : null;

  /// 옷장 칸에 쓰는, 아이템만 잘라낸 그림.
  String get thumbPath => 'assets/avatar/thumbs/$_base.png';

  bool get isFree => meritCost == 0;
}

const List<WardrobeItem> kWardrobe = [
  // 머리 — 민머리는 베이스 그대로라 겹칠 그림이 없다.
  WardrobeItem(
      id: 'head_shaved', name: '민머리', slot: AvatarSlot.head, hasLayer: false),
  WardrobeItem(
      id: 'head_nabal', name: '나발', slot: AvatarSlot.head, meritCost: 300),
  WardrobeItem(
      id: 'head_bamboo', name: '삿갓', slot: AvatarSlot.head, meritCost: 500),
  WardrobeItem(
      id: 'head_straw', name: '밀짚모자', slot: AvatarSlot.head, meritCost: 700),

  // 가사 — 겹치는 레이어가 아니라 몸 그림 자체를 바꾼다.
  WardrobeItem(
      id: 'robe_saffron',
      name: '황토 가사',
      slot: AvatarSlot.robe,
      file: 'base_saffron'),
  WardrobeItem(
      id: 'robe_temple',
      name: '먹물 가사',
      slot: AvatarSlot.robe,
      meritCost: 200,
      file: 'base_temple'),
  WardrobeItem(
      id: 'robe_ash',
      name: '잿빛 가사',
      slot: AvatarSlot.robe,
      meritCost: 400,
      file: 'base_ash'),
  WardrobeItem(
      id: 'robe_crimson',
      name: '홍가사',
      slot: AvatarSlot.robe,
      meritCost: 900,
      file: 'base_crimson'),

  // 악세서리
  WardrobeItem(
      id: 'acc_beads', name: '단주', slot: AvatarSlot.accessory, meritCost: 150),
  WardrobeItem(
      id: 'acc_glasses',
      name: '안경',
      slot: AvatarSlot.accessory,
      meritCost: 600),

  // 대좌
  WardrobeItem(
      id: 'seat_lotus', name: '연꽃 대좌', slot: AvatarSlot.seat, meritCost: 1200),

  // 후광
  WardrobeItem(
      id: 'halo_ring', name: '후광', slot: AvatarSlot.halo, meritCost: 1000),
];

/// 출가하면 이것부터 입는다. 전부 공덕 0짜리다.
const AvatarEquip kDefaultEquip = AvatarEquip({
  AvatarSlot.robe: 'robe_saffron',
  AvatarSlot.head: 'head_shaved',
});

/// 비워둘 수 있는 슬롯. 머리와 가사는 항상 뭔가 입고 있어야 한다.
const Set<AvatarSlot> kOptionalSlots = {
  AvatarSlot.accessory,
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
