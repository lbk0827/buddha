import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../test_controller.dart';

/// 테스트 소개. 응답 기준을 첫 화면에 명시한다 (FR-6.1).
class TestIntroScreen extends ConsumerWidget {
  const TestIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('내 마음의 보살 찾기')),
      body: SafeArea(
        child: content.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (bundle) {
            final test = bundle.test;
            if (test == null) {
              return const Center(child: Text('아직 문항이 없다.'));
            }
            return Padding(
              padding: const EdgeInsets.all(Tokens.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text('맞히는 게 아니다.\n요즘의 너를 보는 거다.',
                      style: text.displayMedium),
                  const SizedBox(height: 20),
                  Text('기준은 "${test.basis}".',
                      style: text.bodyLarge),
                  const SizedBox(height: 8),
                  Text('${test.baseQuestions.length}문항. 답하기 싫은 건 건너뛰어도 된다.',
                      style: text.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.55))),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      ref.read(analyticsProvider).log('test_start');
                      ref.read(testControllerProvider.notifier)
                        ..reset()
                        ..start();
                      context.push(Routes.question(0));
                    },
                    child: const Text('시작'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
