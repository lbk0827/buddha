import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../test_controller.dart';

/// 문항 화면. 진행 표시는 염주, 심화는 점선 염주 (라우트 표).
class TestQuestionScreen extends ConsumerWidget {
  const TestQuestionScreen({super.key, required this.index});
  final int index;

  void _go(BuildContext context, WidgetRef ref) {
    final next = ref.read(testControllerProvider.notifier).advanceFrom(index);
    if (next == null) {
      context.pushReplacement(Routes.testResult);
    } else {
      context.pushReplacement(Routes.question(next));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(testControllerProvider);
    final text = Theme.of(context).textTheme;

    if (index >= flow.asked.length) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => context.pushReplacement(Routes.testResult));
      return const Scaffold(body: SizedBox.shrink());
    }

    final q = flow.asked[index];
    final selected = flow.answers[q.id];

    return Scaffold(
      appBar: AppBar(
        title: _Beads(
          total: flow.asked.length,
          current: index,
          deepFrom: flow.asked.indexWhere((e) => e.deep),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (q.deep)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('조금 더 물어도 되겠나',
                      style: text.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.55))),
                ),
              const SizedBox(height: 8),
              Text(q.text, style: text.headlineMedium),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    for (final o in q.options)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: OutlinedButton(
                          onPressed: () {
                            ref
                                .read(testControllerProvider.notifier)
                                .answer(q.id, o.dir);
                            _go(context, ref);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            backgroundColor: selected == o.dir
                                ? Tokens.saffron.withValues(alpha: 0.16)
                                : null,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(o.text,
                                style: text.bodyLarge, textAlign: TextAlign.left),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () {
                    ref
                        .read(testControllerProvider.notifier)
                        .answer(q.id, null);
                    _go(context, ref);
                  },
                  child: const Text('건너뛰기'),
                ),
              ),
              if (q.deep)
                Center(
                  child: TextButton(
                    onPressed: () {
                      ref.read(testControllerProvider.notifier).declineDeep();
                      context.pushReplacement(Routes.testResult);
                    },
                    child: const Text('여기까지 할게요'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 염주 진행 표시. 심화 구간은 점선으로 구분한다.
class _Beads extends StatelessWidget {
  const _Beads({
    required this.total,
    required this.current,
    required this.deepFrom,
  });

  final int total;
  final int current;
  final int deepFrom;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        for (var i = 0; i < total; i++)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i <= current
                  ? (deepFrom >= 0 && i >= deepFrom
                      ? Colors.transparent
                      : Tokens.saffron)
                  : fg.withValues(alpha: 0.16),
              border: deepFrom >= 0 && i >= deepFrom
                  ? Border.all(color: Tokens.saffron, width: 1.2)
                  : null,
            ),
          ),
      ],
    );
  }
}
