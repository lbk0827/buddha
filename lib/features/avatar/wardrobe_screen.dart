import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../home/home_controller.dart';
import '../shell/tab_top_bar.dart';
import 'avatar_equip.dart';
import 'buddha_figure.dart';
import 'item_thumb.dart';

/// 꾸미기 탭. 위 절반은 내 부처님, 아래는 옷장 시트.
/// 고른 즉시 입혀 보고, 저장해야 남는다.
class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  /// 미리보기 중인 한 벌. null이면 아직 저장본 그대로다.
  AvatarEquip? _draft;

  /// null = 전체
  AvatarSlot? _slot;

  /// 가진 것만 보기
  bool _ownedOnly = false;

  bool _saving = false;

  AvatarEquip _equipOf(TempleHomeState state) => _draft ?? state.equip;
  bool get _dirty => _draft != null;

  Future<void> _tapItem(WardrobeItem item, TempleHomeState state) async {
    final repo = ref.read(profileRepositoryProvider);
    final profile = await repo.ensure();
    final purchased = repo.ownedItemsOf(profile);

    if (!ownsItem(item, purchased)) {
      await _confirmBuy(item, profile.merit, state);
      return;
    }

    setState(() {
      final current = _equipOf(state);
      _draft = kOptionalSlots.contains(item.slot)
          ? current.toggle(item.slot, item.id)
          : current.wear(item.slot, item.id);
    });
  }

  Future<void> _confirmBuy(
    WardrobeItem item,
    int merit,
    TempleHomeState state,
  ) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      // 기본 높이 제한(화면의 9/16)에 걸려 작은 화면에서 아래가 잘리지 않게.
      isScrollControlled: true,
      builder: (ctx) => _BuySheet(
        item: item,
        preview: _buyPreview(item, _equipOf(state)),
        merit: merit,
      ),
    );
    if (ok != true || !mounted) return;

    final bought = await ref.read(profileRepositoryProvider).buyItem(item);
    if (!mounted) return;
    if (!bought) return;

    ref.invalidate(homeStateProvider);
    setState(() {
      // 기본 착용이 아니라 지금 입어 보던 것 위에 입힌다. 산 걸 입어 보다가
      // 입던 모자·가사가 사라지면 안 된다.
      _draft = _equipOf(state).wear(item.slot, item.id);
    });
  }

  /// 구매 시트에 보여 줄 모습. 지금 부처 재질만 남기고 나머지는 기본 차림
  /// (기본 가사·민머리)으로 되돌린 뒤 이 아이템 하나만 입힌다. 다른 소품이
  /// 겹쳐 있으면 무엇을 사는지 잘 안 보인다.
  static AvatarEquip _buyPreview(WardrobeItem item, AvatarEquip current) {
    final skin = current.wornIn(AvatarSlot.buddha);
    final base = skin == null
        ? kDefaultEquip
        : kDefaultEquip.wear(AvatarSlot.buddha, skin);
    return base.wear(item.slot, item.id);
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null || _saving) return;
    setState(() => _saving = true);
    await ref.read(profileRepositoryProvider).setEquip(draft);
    ref.invalidate(homeStateProvider);
    if (!mounted) return;
    setState(() {
      _draft = null;
      _saving = false;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('갈아입었다.')));
  }

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeStateProvider);

    return home.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (state) => SafeArea(
        bottom: false,
        child: Column(
          children: [
            const TabTopBar(),
            _Stage(equip: _equipOf(state)),
            Expanded(
              child: _Sheet(
                equip: _equipOf(state),
                slot: _slot,
                ownedOnly: _ownedOnly,
                dirty: _dirty,
                saving: _saving,
                onSlot: (s) => setState(() => _slot = s),
                onOwnedOnly: (v) => setState(() => _ownedOnly = v),
                onRevert: () => setState(() => _draft = null),
                onSave: _save,
                onTapItem: (i) => _tapItem(i, state),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 위 절반 — 입혀 보는 자리.
class _Stage extends StatelessWidget {
  const _Stage({required this.equip});

  final AvatarEquip equip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 272,
      width: double.infinity,
      color: isDark
          ? Tokens.temple.withValues(alpha: 0.18)
          : const Color(0xFFEDE5D6),
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 8),
      child: BuddhaFigure(equip: equip, size: 190, motion: AvatarMotion.once),
    );
  }
}

/// 아래 시트 — 슬롯 탭과 아이템 그리드.
class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.equip,
    required this.slot,
    required this.ownedOnly,
    required this.dirty,
    required this.saving,
    required this.onSlot,
    required this.onOwnedOnly,
    required this.onRevert,
    required this.onSave,
    required this.onTapItem,
  });

  final AvatarEquip equip;
  final AvatarSlot? slot;
  final bool ownedOnly;
  final bool dirty;
  final bool saving;
  final ValueChanged<AvatarSlot?> onSlot;
  final ValueChanged<bool> onOwnedOnly;
  final VoidCallback onRevert;
  final VoidCallback onSave;
  final void Function(WardrobeItem) onTapItem;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = slot == null
        ? kWardrobe
        : kWardrobe.where((i) => i.slot == slot).toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1915) : Tokens.ivory,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      // 안드로이드 기본 스트레치 효과는 끝까지 당기면 썸네일과 이름을 늘려
      // 보여 준다. 시트 안 스크롤은 늘어나지 않고 그냥 멈춘다.
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: Column(
          children: [
            const SizedBox(height: 14),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                // 첫 글자가 아래 그리드 왼쪽 끝과 줄이 맞도록 탭 여백만큼 당긴다.
                padding: const EdgeInsets.symmetric(
                  horizontal: Tokens.gutter - _SlotChip.hPad,
                ),
                children: [
                  _SlotChip(
                    label: '전체',
                    selected: slot == null,
                    onTap: () => onSlot(null),
                  ),
                  for (final entry in kSlotNames.entries)
                    _SlotChip(
                      label: entry.value,
                      selected: slot == entry.key,
                      onTap: () => onSlot(entry.key),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Tokens.gutter),
              child: Row(
                children: [
                  Text(
                    '가진 것만',
                    style: TextStyle(
                      fontSize: 13,
                      color: fg.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Switch(value: ownedOnly, onChanged: onOwnedOnly),
                  const Spacer(),
                  if (dirty)
                    TextButton(onPressed: onRevert, child: const Text('되돌리기')),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _Grid(
                      items: items,
                      equip: equip,
                      ownedOnly: ownedOnly,
                      onTap: onTapItem,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 16,
                    child: Center(
                      child: _WearButton(
                        onPressed: dirty && !saving ? onSave : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Grid extends ConsumerWidget {
  const _Grid({
    required this.items,
    required this.equip,
    required this.ownedOnly,
    required this.onTap,
  });

  final List<WardrobeItem> items;
  final AvatarEquip equip;
  final bool ownedOnly;
  final void Function(WardrobeItem) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(profileRepositoryProvider);
    final profile = ref.watch(profileProvider).value;
    final purchased = profile == null ? <String>{} : repo.ownedItemsOf(profile);

    final visible = ownedOnly
        ? items.where((i) => ownsItem(i, purchased)).toList()
        : items;

    if (visible.isEmpty) {
      return Center(
        child: Text(
          '여기엔 가진 게 없다.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      // 떠 있는 입기 버튼에 마지막 줄 이름이 가리지 않도록 여유를 준다.
      padding: const EdgeInsets.fromLTRB(Tokens.gutter, 0, Tokens.gutter, 80),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.78,
      children: [
        for (final item in visible)
          _ItemTile(
            item: item,
            owned: ownsItem(item, purchased),
            worn: equip.wornIn(item.slot) == item.id,
            onTap: () => onTap(item),
          ),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.owned,
    required this.worn,
    required this.onTap,
  });

  final WardrobeItem item;
  final bool owned;
  final bool worn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF221F1A) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: worn ? Tokens.saffron : fg.withValues(alpha: 0.08),
                  width: worn ? 2 : 1,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: ItemThumb(item: item, dim: !owned),
                  ),
                  if (!owned)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Icon(
                        Icons.lock_outline,
                        size: 15,
                        color: fg.withValues(alpha: 0.45),
                      ),
                    ),
                  if (worn)
                    const Positioned(
                      right: 6,
                      top: 6,
                      child: Icon(
                        Icons.check_circle,
                        size: 17,
                        color: Tokens.saffron,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 1),
          Text(
            owned ? '가짐' : '공덕 ${item.meritCost}',
            style: TextStyle(
              fontSize: 11,
              color: owned
                  ? fg.withValues(alpha: 0.4)
                  : Tokens.saffron.withValues(alpha: 0.95),
              fontWeight: owned ? null : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// 그리드 위에 늘 떠 있는 작은 알약 버튼.
/// 바뀐 게 없을 때도 불투명하게 칠한다. 기본 비활성 색은 반투명이라
/// 뒤의 썸네일이 비쳐 고장 난 것처럼 보인다.
class _WearButton extends StatelessWidget {
  const _WearButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(132, 46),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        shape: const StadiumBorder(),
        disabledBackgroundColor: const Color(0xFFDCD4C6),
        disabledForegroundColor: const Color(0xFF8C8478),
        elevation: 3,
        shadowColor: Colors.black38,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
      child: const Text('입는다!'),
    );
  }
}

/// 안 가진 아이템을 눌렀을 때 아래에서 올라오는 구매 시트.
/// 걸친 모습 → 아이템 한 줄(썸네일·이름·슬롯·값) → 값이 적힌 알약 버튼.
class _BuySheet extends StatelessWidget {
  const _BuySheet({
    required this.item,
    required this.preview,
    required this.merit,
  });

  final WardrobeItem item;
  final AvatarEquip preview;
  final int merit;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enough = merit >= item.meritCost;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1915) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        Tokens.gutter,
        24,
        Tokens.gutter,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '지를까?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          BuddhaFigure(equip: preview, size: 170),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF221F1A) : Tokens.ivory,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ItemThumb(item: item, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        kSlotNames[item.slot] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: fg.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
                _MeritPrice(cost: item.meritCost),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (enough)
            OutlinedButton(
              onPressed: () => Navigator.pop(context, true),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(180, 52),
                padding: const EdgeInsets.symmetric(horizontal: 36),
                shape: const StadiumBorder(),
                side: BorderSide(color: fg, width: 2),
                foregroundColor: fg,
              ),
              child: _MeritPrice(cost: item.meritCost, size: 18),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                '공덕이 ${item.meritCost - merit} 모자란다.',
                style: TextStyle(
                  fontSize: 14,
                  color: fg.withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 공덕 아이콘과 값. 상단바 공덕 표시와 같은 아이콘을 쓴다.
class _MeritPrice extends StatelessWidget {
  const _MeritPrice({required this.cost, this.size = 16});

  final int cost;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '공덕 $cost',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.brightness_7, size: size, color: Tokens.saffron),
          const SizedBox(width: 6),
          Text(
            '$cost',
            style: TextStyle(fontSize: size, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// 카테고리 탭. 테두리 없이 글자만 두고, 고른 탭은 굵게 쓰고 밑줄을 긋는다.
class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// 글자 양옆 여백. 탭 사이 간격은 이것의 두 배가 된다.
  static const hPad = 9.0;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: hPad),
          // 밑줄이 글자 폭만큼 그어지도록 글자 폭에 맞춘다.
          child: IntrinsicWidth(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: selected ? fg : fg.withValues(alpha: 0.35),
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                // 고르지 않은 탭도 같은 높이의 투명한 줄을 둬서 글자가 들썩이지 않게.
                Container(
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: selected ? fg : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
