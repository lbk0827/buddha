import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme.dart';
import '../avatar/buddha_figure.dart';
import '../session/session_controller.dart';
import '../shell/app_shell.dart';
import '../shell/tab_top_bar.dart';
import 'home_controller.dart';

/// 「절」 — 내 부처님이 있는 곳.
///
/// 레퍼런스 앱의 레이아웃 문법을 따른다: 상단 재화 한 줄 · 가운데 큰
/// 캐릭터 하나 · 아래 카드 하나. 폰 엎기는 걷어냈다
/// (docs/기획_폰엎기.md 에 기획만 남겨 둠).
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
            const TabTopBar(),
            Expanded(child: _Stage(state: state)),
            _Bottom(state: state),
          ],
        ),
      ),
    );
  }
}

/// 부처님을 가운데에. 누르면 꾸미기로 간다.
class _Stage extends StatelessWidget {
  const _Stage({required this.state});
  final TempleHomeState state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.go(Routes.wardrobe),
        child: BuddhaFigure(
          equip: state.equip,
          size: 240,
          breathing: true,
          motion: AvatarMotion.loop,
        ),
      ),
    );
  }
}

/// 하단 — 부처님의 한마디 카드 하나.
class _Bottom extends StatelessWidget {
  const _Bottom({required this.state});
  final TempleHomeState state;

  @override
  Widget build(BuildContext context) {
    final card = state.dailyCard;
    if (card == null) return const SizedBox(height: kHudClearance);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF221F1A) : Colors.white;
    final fg = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Tokens.gutter,
        0,
        Tokens.gutter,
        kHudClearance,
      ),
      child: InkWell(
        onTap: () => context.go(Routes.seonsa),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: fg.withValues(alpha: 0.07)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '부처님의 한마디',
                style: TextStyle(
                  fontSize: 11,
                  color: fg.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                card.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
