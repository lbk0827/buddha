import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../dialogue/share_card.dart';
import '../home/home_controller.dart';
import '../shell/app_shell.dart';

/// 「선사」 탭. 답은 하루 한 번. 위로는 없다.
/// 자유 대화는 P2라 여기서는 하루치 법문 카드만 건넨다.
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
        data: (state) => ListView(
          padding: const EdgeInsets.fromLTRB(
              Tokens.gutter, 24, Tokens.gutter, kHudClearance),
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  color: Tokens.seal,
                  child: const Text('喝',
                      style: TextStyle(
                          color: Tokens.ivory,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('선사', style: text.titleLarge),
                      Text('답은 하루 한 번. 위로는 없다.',
                          style: text.bodySmall
                              ?.copyWith(color: fg.withValues(alpha: 0.55))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            if (state.dailyCard == null)
              Text('오늘은 할 말이 없다. 그런 날도 있다.', style: text.headlineMedium)
            else ...[
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Tokens.ink,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('오늘의 한마디',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFFA39B90))),
                    const SizedBox(height: 12),
                    Text(
                      state.dailyCard!.text,
                      style: text.displayMedium
                          ?.copyWith(color: Tokens.ivory, fontSize: 26),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ref
                          .read(analyticsProvider)
                          .log('share_sheet_open', {'source': 'card'});
                      shareDialogueCard(context, state.dailyCard!.text);
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, Tokens.minTap),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                    ),
                    icon: const Icon(Icons.ios_share, size: 18),
                    label: const Text('나누기'),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () => ref
                        .read(analyticsProvider)
                        .log('card_reaction', {'reaction': 'laugh'}),
                    child: const Text('피식'),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),
            Text('번뇌가 있으면 죽비를 받아라', style: text.titleLarge),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => context.push(Routes.burn),
              child: const Text('번뇌 한 줄 적기'),
            ),

            const SizedBox(height: 32),
            Divider(color: fg.withValues(alpha: 0.1)),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('기록'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.records),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('설정'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.settings),
            ),
          ],
        ),
      ),
    );
  }
}
