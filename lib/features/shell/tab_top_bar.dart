import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../home/home_controller.dart';

/// 탭들이 공유하는 상단바. 좌: 공덕 / 우: 원형 버튼.
/// 레퍼런스처럼 상단에는 이것 말고 아무것도 두지 않는다.
class TabTopBar extends ConsumerWidget {
  const TabTopBar({super.key, this.trailing});

  /// 프로필 버튼 왼쪽에 하나 더 놓을 때.
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final merit = ref.watch(homeStateProvider).value?.merit ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(Tokens.gutter, 8, Tokens.gutter, 0),
      child: Row(
        children: [
          MeritPill(merit: merit),
          const Spacer(),
          if (trailing != null) ...[trailing!, const SizedBox(width: 8)],
          RoundIconButton(
            icon: Icons.person_outline,
            tooltip: '프로필',
            onTap: () => context.push(Routes.profile),
          ),
        ],
      ),
    );
  }
}

Color _surfaceOf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF221F1A)
        : Colors.white;

class MeritPill extends StatelessWidget {
  const MeritPill({super.key, required this.merit});
  final int merit;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Semantics(
      label: '공덕 $merit',
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: _surfaceOf(context),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: fg.withValues(alpha: 0.07)),
        ),
        child: Row(
          children: [
            const Icon(Icons.brightness_7, size: 16, color: Tokens.saffron),
            const SizedBox(width: 7),
            Text('$merit',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 26,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _surfaceOf(context),
            shape: BoxShape.circle,
            border: Border.all(color: fg.withValues(alpha: 0.07)),
          ),
          child: Icon(icon, size: 21, color: fg.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}

/// 본문 아래에 붙는 카드 하나. 탭마다 같은 생김새를 쓴다.
class TabCard extends StatelessWidget {
  const TabCard({
    super.key,
    required this.label,
    required this.body,
    this.onTap,
  });

  final String label;
  final String body;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _surfaceOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: fg.withValues(alpha: 0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    TextStyle(fontSize: 11, color: fg.withValues(alpha: 0.45))),
            const SizedBox(height: 4),
            Text(body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, height: 1.45)),
          ],
        ),
      ),
    );
  }
}
