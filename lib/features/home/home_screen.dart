import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/time_utils.dart';
import '../session/session_controller.dart';
import '../shell/app_shell.dart';
import 'home_controller.dart';

/// v3 「절」 — 폰을 엎어라.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 출가 전이면 먼저 이름부터 받는다 (v3 온보딩).
      final home = await ref.read(homeStateProvider.future);
      if (!mounted) return;
      if (!home.ordained) {
        context.go(Routes.ordination);
        return;
      }

      await ref.read(sessionControllerProvider.notifier).restoreIfAny();
      if (!mounted) return;
      final phase = ref.read(sessionControllerProvider).phase;
      if (phase == SessionPhase.interruptChoice) {
        context.push(Routes.sessionInterrupt);
      } else if (phase == SessionPhase.done) {
        context.push(Routes.sessionDone);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeStateProvider);

    return home.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(Tokens.gutter),
        child: Center(child: Text('지금은 마당이 안 열린다.\n\n$e')),
      ),
      data: (state) => SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Tokens.gutter,
            16,
            Tokens.gutter,
            kHudClearance,
          ),
          children: [
            _Header(state: state),
            const SizedBox(height: 18),
            _FaceDownCard(state: state),
            const SizedBox(height: 24),
            _PlayRow(state: state),
            const SizedBox(height: 14),
            if (state.nextToken != null) _TokenBanner(state: state),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state});
  final TempleHomeState state;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final fg = Theme.of(context).colorScheme.onSurface;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.dharmaName == null
                    ? '아직 이름이 없다'
                    : '${state.dharmaName} · ${state.station}',
                style: text.bodySmall?.copyWith(
                  color: fg.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                state.faceDownTodaySec > 0
                    ? '오늘 ${formatDuration(state.faceDownTodaySec)} 엎어뒀다.'
                    : state.greeting,
                style: text.headlineMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _GateChip(state: state),
      ],
    );
  }
}

/// 절 문 · 남은 시간. 오늘 다녀왔으면 문구가 바뀐다.
class _GateChip extends StatelessWidget {
  const _GateChip({required this.state});
  final TempleHomeState state;

  @override
  Widget build(BuildContext context) {
    final visited = state.gate.visitedToday;
    final urgent = state.gate.closingSoon;
    final bg = visited ? Tokens.temple : (urgent ? Tokens.seal : Tokens.ink);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        state.gate.headline,
        style: const TextStyle(
          color: Tokens.ivory,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// v3의 심장. 「폰을 엎어라」.
class _FaceDownCard extends ConsumerWidget {
  const _FaceDownCard({required this.state});
  final TempleHomeState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Tokens.temple,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '폰을 엎어라.',
            style: Theme.of(context).textTheme.displayMedium
                ?.copyWith(color: Tokens.ivory, fontSize: 34, height: 1.15),
          ),
          const SizedBox(height: 6),
          const Text(
            '엎어둔 동안이 절이다.\n화면을 보는 순간 끊긴다.',
            style: TextStyle(
              color: Color(0xFFA9C2B1),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${state.bowsInCycle}',
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  color: Tokens.ivory,
                                  fontSize: 44,
                                  height: 1,
                                ),
                          ),
                          const TextSpan(
                            text: ' / 108배',
                            style: TextStyle(
                              color: Color(0xFFA9C2B1),
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '공덕 ${state.merit}',
                      style: const TextStyle(
                        color: Color(0xFFA9C2B1),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const _FaceDownPhoneIcon(),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: () {
                ref.read(analyticsProvider).log('home_entry_selected', {
                  'entry': 'practice',
                });
                context.push(Routes.sessionSetup);
              },
              child: const Text('지금 엎어두기'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaceDownPhoneIcon extends StatelessWidget {
  const _FaceDownPhoneIcon();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 64,
    height: 64,
    child: CustomPaint(painter: _PhonePainter()),
  );
}

class _PhonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 엎어둔 폰. 위로 소리 세 줄.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 20, 44, 28),
        const Radius.circular(5),
      ),
      Paint()..color = Tokens.ink,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(15, 24, 34, 20),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF3F5246),
    );
    final stroke = Paint()
      ..color = Tokens.saffron
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(32, 14), const Offset(32, 6), stroke);
    canvas.drawLine(const Offset(20, 12), const Offset(17, 6), stroke);
    canvas.drawLine(const Offset(44, 12), const Offset(47, 6), stroke);
  }

  @override
  bool shouldRepaint(_) => false;
}

/// 「화면 켠 김에, 놀이」 3칸.
class _PlayRow extends StatelessWidget {
  const _PlayRow({required this.state});
  final TempleHomeState state;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final fg = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(child: Text('화면 켠 김에, 놀이', style: text.titleLarge)),
            Text(
              '각 30초',
              style: text.bodySmall?.copyWith(color: fg.withValues(alpha: 0.5)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 세 칸의 높이를 맞춘다. stretch만 쓰면 ListView 안에서 높이가
        // 무제한이라 레이아웃이 잡히지 않는다.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _PlayTile(
                  icon: Icons.local_fire_department_outlined,
                  iconColor: const Color(0xFFB8701F),
                  title: '번뇌\n태우기',
                  sub: '${state.burnedCount} / 108',
                  route: Routes.burn,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PlayTile(
                  icon: Icons.notifications_none,
                  iconColor: Tokens.temple,
                  title: '목탁\n두드리기',
                  sub: '오늘 ${state.burnedToday}회',
                  route: Routes.moktak,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PlayTile(
                  icon: Icons.chat_bubble_outline,
                  iconColor: Tokens.temple,
                  title: '선사\n한마디',
                  sub: '새 법문',
                  subHighlighted: true,
                  route: Routes.seonsa,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlayTile extends StatelessWidget {
  const _PlayTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.sub,
    required this.route,
    this.subHighlighted = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String sub;
  final String route;
  final bool subHighlighted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 104),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF221F1A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: fg.withValues(alpha: 0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: TextStyle(
                fontSize: 11,
                color: subHighlighted
                    ? Tokens.saffron
                    : fg.withValues(alpha: 0.5),
                fontWeight: subHighlighted ? FontWeight.w700 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 다음 증표까지 얼마 남았는지.
class _TokenBanner extends StatelessWidget {
  const _TokenBanner({required this.state});
  final TempleHomeState state;

  @override
  Widget build(BuildContext context) {
    final token = state.nextToken!;
    final left = token.goal - token.progressOf(state.stats);

    return InkWell(
      onTap: () => context.go(Routes.tokens),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFBE4C8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, size: 20, color: Color(0xFFB8701F)),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Tokens.ink,
                  ),
                  children: [
                    TextSpan(
                      text: token.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: '까지 $left 남음'),
                  ],
                ),
              ),
            ),
            const Text(
              '증표',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFB8701F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
