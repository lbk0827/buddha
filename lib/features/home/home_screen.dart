import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/text_utils.dart';
import '../avatar/buddha_figure.dart';
import '../session/session_controller.dart';
import '../shell/app_shell.dart';
import '../shell/tab_top_bar.dart';
import 'buddha_words.dart';
import 'home_controller.dart';

/// 「절」 — 내 부처님이 있는 곳.
///
/// 레퍼런스 앱의 레이아웃 문법을 따른다: 상단 재화 한 줄 · 가운데 큰
/// 캐릭터 하나 · 맨 아래 카드 하나. 카드 위 왼쪽에 명상·달력, 오른쪽에 공덕.
/// 명상 버튼은 폰 엎기(3분·10분)로 들어간다. 앱이 사용자를 놓아주는 유일한 입구다.
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
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: _Stage(state: state)),
                  // 아래 말씀 카드 바로 위.
                  Positioned(
                    left: Tokens.gutter,
                    bottom: 12,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CornerButton(
                          label: '명상',
                          onTap: () {
                            ref.read(analyticsProvider).log(
                                'home_entry_selected', {'entry': 'practice'});
                            context.push(Routes.sessionSetup);
                          },
                          // 향 한 대와 연기 — 세로로 긴 그림이다.
                          // docs/명상버튼_아이콘_발주서.md
                          child: Image.asset(
                            'assets/home/icon_meditation.webp',
                            width: 44,
                            height: 44,
                            excludeFromSemantics: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CornerButton(
                          label: '달력',
                          onTap: () => context.push(Routes.calendar),
                          child: const Icon(
                              Icons.calendar_month_outlined, size: 28),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: Tokens.gutter,
                    bottom: 12,
                    child: CornerButton(
                      label: '공덕',
                      onTap: () => context.push(Routes.meritShop),
                      child: const Icon(
                        Icons.brightness_7,
                        size: 28,
                        color: Tokens.saffron,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _Bottom(state: state),
          ],
        ),
      ),
    );
  }
}

/// 그림만 있는 네모 버튼 — 부처님 왼쪽 아래 명상·달력, 오른쪽 아래 공덕.
class CornerButton extends StatelessWidget {
  const CornerButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.child,
  });

  /// 스크린 리더가 읽는 이름. 화면에는 글자가 없다.
  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = Theme.of(context).colorScheme.onSurface;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: isDark ? const Color(0xFF221F1A) : Colors.white,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: fg.withValues(alpha: 0.08)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: SizedBox(width: 60, height: 60, child: Center(child: child)),
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

/// 하단 — 부처님 말씀 카드 하나.
class _Bottom extends ConsumerWidget {
  const _Bottom({required this.state});
  final TempleHomeState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final word = ref.watch(todaysBuddhaWordProvider).value;
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (word != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: fg.withValues(alpha: 0.07)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 연꽃 — 부처님이 선 연꽃 대좌와 같은 꽃이다. 이모지만 하게,
                  // 카드 위쪽에 붙인다. docs/GPT요청_부처님말씀_아이콘.md
                  Image.asset(
                    'assets/home/icon_lotus.webp',
                    width: 20,
                    height: 20,
                    excludeFromSemantics: true,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '부처님 말씀',
                          style: TextStyle(
                            fontSize: 11,
                            color: fg.withValues(alpha: 0.45),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          keepAll(word.text),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
