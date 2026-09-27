import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';

/// 반복 고민 (FR-3.2). 「지난번 그 얘기」 토글이 켜졌을 때만 들어온다.
/// 자동 키워드 매칭은 하지 않는다 — 사용자가 직접 고른다.
class SessionRepeatScreen extends ConsumerStatefulWidget {
  const SessionRepeatScreen({super.key});

  @override
  ConsumerState<SessionRepeatScreen> createState() =>
      _SessionRepeatScreenState();
}

class _SessionRepeatScreenState extends ConsumerState<SessionRepeatScreen> {
  static const _choices = [
    '아직 그대로다',
    '조금 나아졌다',
    '다른 게 더 크다',
    '말하고 싶지 않다',
  ];

  String? _picked;

  @override
  Widget build(BuildContext context) {
    final previous = ref.watch(_previousWorriesProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('지난번 그 얘기')),
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
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('지난번엔 이랬다.',
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
              Text('지금은 어떠냐', style: text.titleLarge),
              const SizedBox(height: 12),
              for (final c in _choices)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: () => setState(() => _picked = c),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _picked == c
                          ? Tokens.saffron.withValues(alpha: 0.16)
                          : null,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(c),
                    ),
                  ),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _picked == null ? null : () => context.go(Routes.home),
                child: const Text('됐다'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final _previousWorriesProvider = FutureProvider<List<String>>((ref) async {
  final sessions =
      await ref.watch(sessionRepositoryProvider).previousWorries(limit: 4);
  return sessions
      .map((s) => s.worryText)
      .whereType<String>()
      .toList(growable: false);
});
