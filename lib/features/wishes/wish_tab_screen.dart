import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../shell/app_shell.dart';
import '../shell/tab_top_bar.dart';
import 'wish_store.dart';
import 'wish_widgets.dart';

/// 「소원」 탭 — 연등에 소원을 단다.
///
/// 다른 탭과 같은 배치: 상단바 · 가운데 큰 대상(연등) · 한 줄 · 하단 전체 폭 버튼.
/// 연등을 누르면 소원을 읽고, 버튼을 누르면 소원을 적는다.
class WishTabScreen extends ConsumerWidget {
  const WishTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final fg = Theme.of(context).colorScheme.onSurface;
    final count = ref.watch(wishCountProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const TabTopBar(),
          Expanded(
            flex: 4,
            child: LayoutBuilder(
              builder: (_, constraints) =>
                  WishLanterns(height: constraints.maxHeight),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '연등에 소원을 달아라.',
            style: text.displayMedium?.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 6),
          Text(
            count.when(
              data: (n) => n == 0 ? '연등을 누르면 소원을 읽는다.' : '내가 단 소원 $n개',
              loading: () => '소원을 불러오는 중',
              error: (_, _) => '소원을 불러오지 못했어요',
            ),
            style: text.bodyMedium?.copyWith(color: fg.withValues(alpha: 0.55)),
          ),
          const Spacer(flex: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Tokens.gutter,
              0,
              Tokens.gutter,
              kHudClearance,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () => context.push(Routes.wish),
                icon: const Icon(Icons.volunteer_activism_outlined),
                label: const Text(
                  '소원 빌기',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
