import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../home/home_controller.dart';
import '../shell/app_shell.dart';

/// 「놀이」 탭. 화면을 켠 김에 30초씩 하는 것들.
class PlayScreen extends ConsumerWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeStateProvider).value;
    final text = Theme.of(context).textTheme;
    final fg = Theme.of(context).colorScheme.onSurface;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            Tokens.gutter, 24, Tokens.gutter, kHudClearance),
        children: [
          Text('놀이', style: text.displayMedium),
          const SizedBox(height: 6),
          Text(
            '어차피 켰으면, 30초만 쓰고 놔라.',
            style: text.bodyMedium?.copyWith(color: fg.withValues(alpha: 0.55)),
          ),
          const SizedBox(height: 24),
          _PlayCard(
            title: '번뇌 태우기',
            body: '한 줄 적으면 선사가 죽비를 준다. 인정하면 태워진다.',
            trailing: home == null ? '' : '${home.burnedCount} / 108',
            icon: Icons.local_fire_department_outlined,
            color: const Color(0xFFB8701F),
            onTap: () => context.push(Routes.burn),
          ),
          const SizedBox(height: 12),
          _PlayCard(
            title: '목탁 두드리기',
            body: '세는 것 말고는 아무 일도 안 일어난다. 그게 전부다.',
            trailing: home == null ? '' : '오늘 ${home.burnedToday}회',
            icon: Icons.notifications_none,
            color: Tokens.temple,
            onTap: () => context.push(Routes.moktak),
          ),
          const SizedBox(height: 12),
          _PlayCard(
            title: '내 마음 알아보기',
            body: '16문항. 맞히는 게 아니라 요즘의 너를 보는 거다.',
            trailing: '2분',
            icon: Icons.self_improvement_outlined,
            color: Tokens.temple,
            onTap: () => context.push(Routes.test),
          ),
        ],
      ),
    );
  }
}

class _PlayCard extends StatelessWidget {
  const _PlayCard({
    required this.title,
    required this.body,
    required this.trailing,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String body;
  final String trailing;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF221F1A) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: fg.withValues(alpha: 0.07)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: fg.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              trailing,
              style: TextStyle(
                  fontSize: 12, color: fg.withValues(alpha: 0.45)),
            ),
          ],
        ),
      ),
    );
  }
}
