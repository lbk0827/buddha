import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';

class HudTab {
  /// 탭 이름을 문자열 테이블에서 고른다.
  final String Function(AppLocalizations) labelOf;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  const HudTab({
    required this.labelOf,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });

  String get label => labelOf(L.current);
}

String _templeLabel(AppLocalizations l) => l.shellTabTemple;
String _wardrobeLabel(AppLocalizations l) => l.shellTabWardrobe;
String _playLabel(AppLocalizations l) => l.shellTabPlay;
String _seonsaLabel(AppLocalizations l) => l.shellTabSeonsa;
String _wishesLabel(AppLocalizations l) => l.shellTabWishes;

const List<HudTab> kHudTabs = [
  HudTab(
    labelOf: _templeLabel,
    icon: Icons.temple_buddhist_outlined,
    activeIcon: Icons.temple_buddhist,
    route: '/',
  ),
  HudTab(
    labelOf: _wardrobeLabel,
    icon: Icons.checkroom_outlined,
    activeIcon: Icons.checkroom,
    route: '/wardrobe',
  ),
  HudTab(
    labelOf: _playLabel,
    icon: Icons.local_fire_department_outlined,
    activeIcon: Icons.local_fire_department,
    route: '/play',
  ),
  HudTab(
    labelOf: _seonsaLabel,
    icon: Icons.chat_bubble_outline,
    activeIcon: Icons.chat_bubble,
    route: '/seonsa',
  ),
  HudTab(
    labelOf: _wishesLabel,
    icon: Icons.volunteer_activism_outlined,
    activeIcon: Icons.volunteer_activism,
    route: '/wishes',
  ),
];

/// 하단 HUD. 화면 좌우 끝까지 붙고 아이콘만 쓴다.
class BottomHud extends StatelessWidget {
  const BottomHud({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF221F1A) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          top: BorderSide(color: scheme.onSurface.withValues(alpha: 0.08)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              for (var i = 0; i < kHudTabs.length; i++)
                Expanded(
                  child: _HudItem(
                    tab: kHudTabs[i],
                    selected: i == currentIndex,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HudItem extends StatelessWidget {
  const _HudItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final HudTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;

    return Semantics(
      selected: selected,
      button: true,
      label: tab.labelOf(context.l10n),
      child: InkResponse(
        onTap: onTap,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        child: Center(
          child: AnimatedScale(
            scale: selected ? 1.08 : 1,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: Icon(
              selected ? tab.activeIcon : tab.icon,
              size: 26,
              color: selected ? Tokens.temple : fg.withValues(alpha: 0.35),
            ),
          ),
        ),
      ),
    );
  }
}
