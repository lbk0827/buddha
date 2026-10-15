import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../session_controller.dart';

/// 반복 고민 (FR-3.2). 「지난번 그 얘기」 토글이 켜졌을 때만 들어온다.
/// 자동 키워드 매칭은 하지 않는다 — 사용자가 직접 고른다.
class SessionRepeatScreen extends ConsumerStatefulWidget {
  const SessionRepeatScreen({super.key});

  @override
  ConsumerState<SessionRepeatScreen> createState() =>
      _SessionRepeatScreenState();
}

class _SessionRepeatScreenState extends ConsumerState<SessionRepeatScreen> {
  /// 고른 답은 저장하지 않는다. 화면 안에서만 쓰니 순서(번호)로 기억한다.
  static List<String> _choices(AppLocalizations l) => [
        l.sessionRepeatChoiceSame,
        l.sessionRepeatChoiceBetter,
        l.sessionRepeatChoiceOther,
        l.sessionRepeatChoicePrivate,
      ];

  int? _picked;

  @override
  Widget build(BuildContext context) {
    final previous = ref.watch(_previousWorriesProvider);
    final text = Theme.of(context).textTheme;
    // 이전 번뇌가 없으면 물을 대상이 없다. 선택지를 숨기고 바로 나가게 한다.
    final hasPrevious = previous.value?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.sessionRepeatTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              previous.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (list) => list.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 28),
                        child: Text(
                          context.l10n.sessionRepeatEmpty,
                          style: text.bodyLarge?.copyWith(height: 1.5),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.l10n.sessionRepeatPreviousLabel,
                              style: text.bodyMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.55))),
                          const SizedBox(height: 6),
                          Text(list.first, style: text.headlineMedium),
                          const SizedBox(height: 28),
                        ],
                      ),
              ),
              if (hasPrevious) ...[
                Text(context.l10n.sessionRepeatQuestion,
                    style: text.titleLarge),
                const SizedBox(height: 12),
                for (final (i, c) in _choices(context.l10n).indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton(
                      onPressed: () => setState(() => _picked = i),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _picked == i
                            ? Tokens.saffron.withValues(alpha: 0.16)
                            : null,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(c),
                      ),
                    ),
                  ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: hasPrevious && _picked == null
                    ? null
                    : () => context.go(Routes.home),
                child: Text(context.l10n.sessionRepeatDoneButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 방금 끝낸 세션을 뺀 이전 번뇌들, 최근 것부터.
final _previousWorriesProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final current = ref.read(sessionControllerProvider);
  final sessions = await ref.watch(sessionRepositoryProvider).previousWorries(
        limit: 4,
        excludeId: current.result?.session.id ?? current.sessionId,
      );
  return sessions
      .map((s) => s.worryText)
      .whereType<String>()
      .toList(growable: false);
});
