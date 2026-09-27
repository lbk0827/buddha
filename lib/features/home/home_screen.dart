import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../avatar/buddha_figure.dart';
import '../session/session_controller.dart';
import 'home_controller.dart';

/// 「절」 — 폰을 엎어라.
///
/// 레퍼런스 앱의 레이아웃 문법을 따른다:
/// 상단 재화 한 줄 · 중앙에 만질 수 있는 큰 대상 하나 · 그 아래 한 줄 ·
/// 카드 하나 · 하단 전체 폭 버튼 하나. 그 외는 전부 다른 탭으로 뺐다.
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
        child: Center(child: Text('지금은 절 문이 안 열린다.\n\n$e')),
      ),
      data: (state) => SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(state: state),
            Expanded(child: _Stage(state: state)),
            _Bottom(state: state),
          ],
        ),
      ),
    );
  }
}

/// 좌: 공덕 / 우: 프로필. 상단에는 이것만 둔다.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.state});
  final TempleHomeState state;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF221F1A) : Colors.white;
    final fg = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(Tokens.gutter, 8, Tokens.gutter, 0),
      child: Row(
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: fg.withValues(alpha: 0.07)),
            ),
            child: Row(
              children: [
                const Icon(Icons.brightness_7, size: 16, color: Tokens.saffron),
                const SizedBox(width: 7),
                Text(
                  '${state.merit}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const Spacer(),
          _RoundButton(
            icon: Icons.checkroom_outlined,
            surface: surface,
            tooltip: '꾸미기',
            onTap: () => context.push(Routes.wardrobe),
          ),
          const SizedBox(width: 8),
          _RoundButton(
            icon: Icons.person_outline,
            surface: surface,
            tooltip: '프로필',
            onTap: () => context.push(Routes.profile),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.surface,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color surface;
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
            color: surface,
            shape: BoxShape.circle,
            border: Border.all(color: fg.withValues(alpha: 0.07)),
          ),
          child: Icon(icon, size: 21, color: fg.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}

/// 중앙 — 캐릭터 하나와 한 줄. 나머지는 여백이다.
class _Stage extends ConsumerWidget {
  const _Stage({required this.state});
  final TempleHomeState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final fg = Theme.of(context).colorScheme.onSurface;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        GestureDetector(
          onTap: () => context.push(Routes.wardrobe),
          child: BuddhaFigure(
            equip: state.equip,
            size: 200,
            breathing: true,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '폰을 엎어라.',
          style: text.displayMedium?.copyWith(fontSize: 30),
        ),
        const SizedBox(height: 6),
        Text(
          '엎어둔 동안이 절이다.',
          style: text.bodyMedium?.copyWith(color: fg.withValues(alpha: 0.55)),
        ),
        const SizedBox(height: 14),
        _GatePill(state: state),
        const Spacer(),
      ],
    );
  }
}

/// 절 문 — 작은 알약 하나로만 알린다.
class _GatePill extends StatelessWidget {
  const _GatePill({required this.state});
  final TempleHomeState state;

  @override
  Widget build(BuildContext context) {
    final visited = state.gate.visitedToday;
    final urgent = state.gate.closingSoon;
    final color = visited
        ? Tokens.temple
        : (urgent ? Tokens.seal : Theme.of(context).colorScheme.onSurface);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        state.gate.headline,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

/// 하단 — 말씀 카드 하나와 버튼 하나.
class _Bottom extends ConsumerWidget {
  const _Bottom({required this.state});
  final TempleHomeState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF221F1A) : Colors.white;
    final fg = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(Tokens.gutter, 0, Tokens.gutter, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.dailyCard != null)
            InkWell(
              onTap: () => context.go(Routes.seonsa),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: fg.withValues(alpha: 0.07)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('선사 한마디',
                        style: TextStyle(
                            fontSize: 11,
                            color: fg.withValues(alpha: 0.45))),
                    const SizedBox(height: 4),
                    Text(
                      state.dailyCard!.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 56,
            child: FilledButton(
              onPressed: () {
                ref
                    .read(analyticsProvider)
                    .log('home_entry_selected', {'entry': 'practice'});
                context.push(Routes.sessionSetup);
              },
              child: const Text('지금 엎어두기',
                  style:
                      TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
