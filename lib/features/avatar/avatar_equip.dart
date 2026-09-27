import 'dart:convert';

/// 아바타 레이어. 그리는 순서가 그대로 겹치는 순서다.
/// 레퍼런스 앱도 실시간 3D가 아니라 이런 레이어 합성이다.
enum AvatarSlot { body, bottom, top, head, accessory }

/// 옷장 한 벌. 슬롯마다 아이템 ID 하나.
class AvatarEquip {
  final Map<AvatarSlot, String> items;

  const AvatarEquip([this.items = const {}]);

  String? of(AvatarSlot slot) => items[slot];

  AvatarEquip wear(AvatarSlot slot, String itemId) =>
      AvatarEquip({...items, slot: itemId});

  AvatarEquip takeOff(AvatarSlot slot) =>
      AvatarEquip({...items}..remove(slot));

  bool get isEmpty => items.isEmpty;

  String encode() =>
      jsonEncode(items.map((k, v) => MapEntry(k.name, v)));

  static AvatarEquip decode(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const AvatarEquip();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const AvatarEquip();
      final byName = {for (final s in AvatarSlot.values) s.name: s};
      final out = <AvatarSlot, String>{};
      for (final e in decoded.entries) {
        final slot = byName[e.key];
        if (slot != null && e.value is String) out[slot] = e.value as String;
      }
      return AvatarEquip(out);
    } catch (_) {
      return const AvatarEquip();
    }
  }
}

/// 옷장 아이템 하나. 지금은 그리기로 대신하고, 에셋이 생기면
/// assetPath만 채우면 된다.
class WardrobeItem {
  final String id;
  final String name;
  final AvatarSlot slot;

  /// 공덕으로 연다. 0이면 기본 지급.
  final int meritCost;

  /// 나중에 채울 PNG 경로. null이면 내장 그리기를 쓴다.
  final String? assetPath;

  const WardrobeItem({
    required this.id,
    required this.name,
    required this.slot,
    this.meritCost = 0,
    this.assetPath,
  });
}

/// 기본 옷장. 아이템 아트가 나오기 전까지 색·형태만 바꾸는 최소 구성.
const List<WardrobeItem> kWardrobe = [
  WardrobeItem(id: 'robe_temple', name: '먹물 가사', slot: AvatarSlot.top),
  WardrobeItem(
      id: 'robe_saffron', name: '황토 가사', slot: AvatarSlot.top, meritCost: 300),
  WardrobeItem(
      id: 'robe_ash', name: '잿빛 가사', slot: AvatarSlot.top, meritCost: 500),
  WardrobeItem(id: 'head_shaved', name: '민머리', slot: AvatarSlot.head),
  WardrobeItem(
      id: 'head_nabal', name: '나발 머리', slot: AvatarSlot.head, meritCost: 800),
  WardrobeItem(
      id: 'acc_beads', name: '단주', slot: AvatarSlot.accessory, meritCost: 200),
];

/// 아무것도 안 골랐을 때 입는 것.
const AvatarEquip kDefaultEquip = AvatarEquip({
  AvatarSlot.top: 'robe_temple',
  AvatarSlot.head: 'head_shaved',
});

WardrobeItem? wardrobeItem(String? id) {
  if (id == null) return null;
  for (final i in kWardrobe) {
    if (i.id == id) return i;
  }
  return null;
}

List<WardrobeItem> wardrobeFor(AvatarSlot slot) =>
    kWardrobe.where((i) => i.slot == slot).toList(growable: false);
