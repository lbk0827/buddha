import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../dialogue/share_card.dart';
import '../home/home_controller.dart';
import '../shell/app_shell.dart';
import '../shell/tab_top_bar.dart';

/// 「선사」 — 답은 하루 한 번. 위로는 없다.
/// 한마디 자체가 화면의 주인공이라 카드에 가두지 않는다.
class SeonsaScreen extends ConsumerWidget {
  const SeonsaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeStateProvider);
    final text = Theme.of(context).textTheme;
    final fg = Theme.of(context).colorScheme.onSurface;

    return SafeArea(
      bottom: false,
      child: home.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (state) => Column(
          children: [
            const TabTopBar(),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: Tokens.gutter),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    const _SeonsaSeal(),
                    const SizedBox(height: 24),
                    Text(
                      state.dailyCard?.text ?? '오늘은 할 말이 없다. 그런 날도 있다.',
                      style: text.displayMedium?.copyWith(height: 1.45),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '하루 한 번',
                      style: text.bodySmall
                          ?.copyWith(color: fg.withValues(alpha: 0.45)),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Tokens.gutter, 0, Tokens.gutter, kHudClearance),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: () => context.push(Routes.burn),
                        child: const Text('번뇌 한 줄 적기'),
                      ),
                    ),
                  ),
                  if (state.dailyCard != null) ...[
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          ref
                              .read(analyticsProvider)
                              .log('share_sheet_open', {'source': 'card'});
                          shareDialogueCard(context, state.dailyCard!.text);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(52, 52),
                        ),
                        child: const Icon(Icons.ios_share, size: 20),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 선사의 낙관. 喝 — 선사가 내지르는 할.
class _SeonsaSeal extends StatelessWidget {
  const _SeonsaSeal();

  @override
  Widget build(BuildContext context) => Semantics(
        label: '선사',
        child: Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Tokens.seal,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            '喝',
            style: TextStyle(
              color: Tokens.ivory,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      );
}
