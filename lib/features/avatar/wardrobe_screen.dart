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
      WardrobeItem item, int merit, TempleHomeState state) async {
    final enough = merit >= item.meritCost;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.name),
        content: Text(
          enough
              ? '공덕 ${item.meritCost}을 치른다. 지금 공덕은 $merit.'
              : '공덕이 모자란다. ${item.meritCost} 필요한데 지금 $merit뿐이다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('아니'),
          ),
          if (enough)
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('연다'),
            ),
        ],
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
      child: BuddhaFigure(equip: equip, size: 190),
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
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: fg.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Tokens.gutter),
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
            child: _Grid(
              items: items,
              equip: equip,
              ownedOnly: ownedOnly,
              onTap: onTapItem,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Tokens.gutter,
              8,
              Tokens.gutter,
              20,
            ),
            child: SizedBox(
              height: 52,
              width: double.infinity,
              child: FilledButton(
                onPressed: dirty && !saving ? onSave : null,
                child: Text(dirty ? '이대로 입는다' : '바뀐 게 없다'),
              ),
            ),
          ),
        ],
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
      // 아래 버튼에 가려 이름이 잘리지 않도록 여유를 준다.
      padding: const EdgeInsets.fromLTRB(Tokens.gutter, 0, Tokens.gutter, 16),
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

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Tokens.ink : Colors.transparent,
            border: Border.all(
              color: selected ? Tokens.ink : fg.withValues(alpha: 0.18),
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: selected ? Tokens.ivory : fg,
              fontWeight: selected ? FontWeight.w700 : null,
            ),
          ),
        ),
      ),
    );
  }
}
