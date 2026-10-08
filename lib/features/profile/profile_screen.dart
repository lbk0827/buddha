import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../avatar/avatar_equip.dart';
import '../avatar/buddha_figure.dart';
import '../avatar/halo_spin.dart';
import '../home/home_controller.dart';
import '../ordination/dharma_rank.dart';

/// 프로필. 탭에서 뺀 것들이 여기로 모인다 — 기록·설정·테스트.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeStateProvider).value;
    final text = Theme.of(context).textTheme;
    final fg = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              Tokens.gutter, 8, Tokens.gutter, Tokens.gutter),
          children: [
            Center(
              child: Column(
                children: [
                  // 후광이 그림 위로 넘치는데 목록은 넘친 부분을 자른다.
                  const SizedBox(height: 130 * kHaloOverflow),
                  BuddhaFigure(equip: home?.equip ?? kDefaultEquip, size: 130),
                  const SizedBox(height: 10),
                  Text(home?.dharmaName ?? '법명 없음',
                      style: text.displayMedium?.copyWith(fontSize: 26)),
                  const SizedBox(height: 2),
                  Text(
                    home == null
                        ? ''
                        : '${home.station} · 엎기 ${home.bowCount}회',
                    style: text.bodyMedium
                        ?.copyWith(color: fg.withValues(alpha: 0.55)),
                  ),
                  if (home != null) ...[
                    const SizedBox(height: 10),
                    _NextRank(bowCount: home.bowCount),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),
            _Row(
              title: '내 마음 알아보기',
              subtitle: '16문항 · 2분',
              onTap: () => context.push(Routes.test),
            ),
            _Row(
              title: '기록',
              subtitle: '엎어둔 날들',
              onTap: () => context.push(Routes.records),
            ),
            _Row(
              title: '설정',
              subtitle: '알림 · 기록 저장 · 데이터 삭제',
              onTap: () => context.push(Routes.settings),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextRank extends StatelessWidget {
  const _NextRank({required this.bowCount});
  final int bowCount;

  @override
  Widget build(BuildContext context) {
    final next = nextRankAfter(bowCount);
    if (next == null) return const SizedBox.shrink();
    final left = next.requiredBows - bowCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Tokens.temple.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '${next.station}까지 $left회',
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: Tokens.temple),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF221F1A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: fg.withValues(alpha: 0.07)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12,
                            color: fg.withValues(alpha: 0.5))),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: fg.withValues(alpha: 0.35)),
            ],
          ),
        ),
      ),
    );
  }
}
