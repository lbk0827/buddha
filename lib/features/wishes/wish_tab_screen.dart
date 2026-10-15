import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import '../avatar/avatar_equip.dart';
import '../avatar/buddha_figure.dart';
import '../home/home_controller.dart';
import '../shell/app_shell.dart';
import '../shell/tab_top_bar.dart';
import 'wish_store.dart';
import 'wish_widgets.dart';

/// 「소원」 탭 — 연등에 소원을 단다.
///
/// 연등 그림이 상단바 밑까지 깔리고 상단바는 그 위에 떠 있다. 연등 아래에
/// 내 부처님이 작게 서 있고, 맨 아래 카드 하나에 소원 수와 「소원 빌기」가 있다.
/// 연등을 누르면 소원을 읽고, 버튼을 누르면 소원을 적는다.
class WishTabScreen extends ConsumerWidget {
  const WishTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equip = ref.watch(homeStateProvider).value?.equip ?? kDefaultEquip;
    final top = MediaQuery.paddingOf(context).top;

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (_, constraints) {
              final h = constraints.maxHeight;
              // 연등은 위쪽에만 — 상태바를 뺀 높이의 절반쯤.
              final canopy = top + (h - top) * .42;
              // 홈(240)보다 작게 — 연등 아래 서 있는 느낌.
              final figure = (h * .40).clamp(140.0, 220.0);
              return Stack(
                children: [
                  // 첫 줄 연등이 상단바 알약 사이로 살짝 보이도록 조금 내린다.
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: WishLanterns(height: canopy, topInset: top + 20),
                  ),
                  // 연등을 눌러도 부처님 자리에서 읽기가 열리게 터치는 통과시킨다.
                  // 연등 아래 남은 자리 한가운데.
                  Positioned(
                    top: canopy - 16,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Center(
                        child: BuddhaFigure(
                          equip: equip,
                          size: figure,
                          breathing: true,
                          motion: AvatarMotion.loop,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(bottom: false, child: TabTopBar()),
                  ),
                ],
              );
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(
            Tokens.gutter,
            8,
            Tokens.gutter,
            kHudClearance,
          ),
          child: _WishCard(),
        ),
      ],
    );
  }
}

/// 아래 카드 — 왼쪽에 소원 수와 안내, 오른쪽에 작은 「소원 빌기」.
class _WishCard extends ConsumerWidget {
  const _WishCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(wishCountProvider);
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = Theme.of(context).colorScheme.onSurface;
    final n = count.value ?? 0;

    final headline = count.when(
      data: (n) => n == 0 ? l10n.wishesTabTapHint : l10n.wishesTabMyCount(n),
      loading: () => l10n.wishesTabLoading,
      error: (_, _) => l10n.wishesTabLoadError,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF221F1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fg.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/wishes/lantern.svg',
            height: 34,
            excludeFromSemantics: true,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 소원이 있으면 안내는 작은 윗줄로 물러나고 소원 수가 큰 줄이 된다.
                if (count.hasValue && n > 0) ...[
                  Text(
                    l10n.wishesTabTapHint,
                    style: TextStyle(
                      fontSize: 11,
                      color: fg.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  headline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: () => context.push(Routes.wish),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 42),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.volunteer_activism_outlined, size: 18),
            label: Text(
              l10n.wishesTabWriteButton,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
