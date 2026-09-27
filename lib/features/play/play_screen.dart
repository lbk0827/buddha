import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../home/home_controller.dart';
import '../shell/app_shell.dart';
import '../shell/tab_top_bar.dart';
import 'moktak.dart';

/// 「놀이」 — 목탁이 주인공이다.
/// 별도 목탁 화면을 두지 않고 탭에서 바로 두드린다.
class PlayScreen extends ConsumerStatefulWidget {
  const PlayScreen({super.key});

  @override
  ConsumerState<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends ConsumerState<PlayScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  int _count = 0;

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  void _tap() {
    HapticFeedback.mediumImpact();
    setState(() => _count++);
    _ring.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeStateProvider).value;
    final text = Theme.of(context).textTheme;
    final fg = Theme.of(context).colorScheme.onSurface;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const TabTopBar(),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _tap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _ring,
                    builder: (context, _) => SizedBox(
                      width: 220,
                      height: 220,
                      child: CustomPaint(
                        painter: MoktakPainter(
                          pulse: _ring.value,
                          isDark: Theme.of(context).brightness ==
                              Brightness.dark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('목탁을 두드려라.',
                      style: text.displayMedium?.copyWith(fontSize: 30)),
                  const SizedBox(height: 6),
                  Text(
                    _count == 0
                        ? '세는 것 말고는 아무 일도 안 일어난다.'
                        : '$_count번 두드렸다.',
                    style: text.bodyMedium
                        ?.copyWith(color: fg.withValues(alpha: 0.55)),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Tokens.gutter, 0, Tokens.gutter, kHudClearance),
            child: TabCard(
              label: '번뇌 태우기',
              body: home == null
                  ? '한 줄 적으면 선사가 죽비를 준다.'
                  : '태운 번뇌 ${home.burnedCount} / 108',
              onTap: () => context.push(Routes.burn),
            ),
          ),
        ],
      ),
    );
  }
}
