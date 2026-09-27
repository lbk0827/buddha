import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../data/content/models.dart';
import '../session/session_controller.dart';
import '../temple/temple_yard.dart';
import 'home_controller.dart';

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
      // 앱 강제 종료 후 남은 세션 복원 (QA 체크리스트).
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

    return Scaffold(
      body: SafeArea(
        child: home.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorBody(message: '$e'),
          data: (state) => _HomeBody(state: state),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(Tokens.gutter),
        child: Center(child: Text('지금은 마당이 안 열린다.\n\n$message')),
      );
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.state});
  final HomeState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        const _TopMenu(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                Tokens.gutter, 8, Tokens.gutter, 16),
            children: [
              Text(state.greeting, style: text.displayMedium),
              const SizedBox(height: 20),
              if (state.dailyCard != null)
                DailyCard(item: state.dailyCard!, root: state.dailyCardRoot),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => context.push(Routes.temple),
                child: TempleYard(
                  stage: state.stage,
                  lanternBright: state.lanternBright,
                  fallenLeaves: state.fallenLeaves,
                ),
              ),
              if (state.fallenLeaves) const _LeavesPrompt(),
            ],
          ),
        ),
        const _HomeActions(),
      ],
    );
  }
}

class _TopMenu extends StatelessWidget {
  const _TopMenu();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              tooltip: '절',
              onPressed: () => context.push(Routes.temple),
              icon: const Icon(Icons.temple_buddhist_outlined),
            ),
            IconButton(
              tooltip: '기록',
              onPressed: () => context.push(Routes.records),
              icon: const Icon(Icons.article_outlined),
            ),
            IconButton(
              tooltip: '설정',
              onPressed: () => context.push(Routes.settings),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
      );
}

/// 미접속 2일 이상 복귀 (FR-4.4). 결석 일수·이유는 말하지 않는다.
class _LeavesPrompt extends ConsumerWidget {
  const _LeavesPrompt();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('낙엽이 좀 쌓였다.',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => sweepLeaves(ref),
                    child: const Text('1분 쓸기'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () => sweepLeaves(ref),
                    child: const Text('그냥 들어가기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

/// 대표 버튼은 하단 고정, 보조 버튼보다 면적 2배 이상 (FR-1.1).
class _HomeActions extends ConsumerWidget {
  const _HomeActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Tokens.gutter, 8, Tokens.gutter, Tokens.gutter),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 68,
            child: FilledButton(
              onPressed: () {
                ref.read(analyticsProvider).log(
                    'home_entry_selected', {'entry': 'practice'});
                context.push(Routes.sessionSetup);
              },
              child: const Text('마음 내려놓기 · 3분',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 6),
          // 보조 버튼. 최소 탭 영역 44는 지키되 대표 버튼보다 훨씬 작게 둔다 (FR-1.1).
          TextButton(
            onPressed: () {
              ref.read(analyticsProvider).log(
                  'home_entry_selected', {'entry': 'test'});
              context.push(Routes.test);
            },
            style: TextButton.styleFrom(
              minimumSize: const Size(0, Tokens.minTap),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('내 마음 알아보기'),
          ),
        ],
      ),
    );
  }
}

/// 오늘의 한마디 카드 (FR-3.5, FR-3.7).
class DailyCard extends ConsumerStatefulWidget {
  const DailyCard({super.key, required this.item, this.root});

  final DialogueItem item;
  final RootItem? root;

  @override
  ConsumerState<DailyCard> createState() => _DailyCardState();
}

class _DailyCardState extends ConsumerState<DailyCard> {
  bool _reacted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: fg.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('오늘의 한마디',
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: fg.withValues(alpha: 0.55))),
          const SizedBox(height: 10),
          Text(widget.item.text, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  ref.read(analyticsProvider).log(
                      'home_entry_selected', {'entry': 'card'});
                  context.push('${Routes.sessionSetup}?len=180');
                },
                // 카드 안 버튼은 대표 버튼과 경쟁하지 않도록 인라인 크기로 둔다.
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, Tokens.minTap),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                ),
                child: const Text('3분'),
              ),
              if (widget.root != null)
                TextButton(
                  onPressed: () => context.push(Routes.root(widget.root!.id)),
                  child: const Text('이 말의 뿌리'),
                ),
              if (!_reacted)
                TextButton(
                  onPressed: () {
                    ref.read(analyticsProvider).log(
                        'card_reaction', {'reaction': 'laugh'});
                    setState(() => _reacted = true);
                  },
                  child: const Text('피식'),
                ),
              // 오늘의 체크인은 홈 카드에서 들어간다 (FR-6.6).
              TextButton(
                onPressed: () => context.push(Routes.checkin),
                child: const Text('오늘은 어떤가'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
