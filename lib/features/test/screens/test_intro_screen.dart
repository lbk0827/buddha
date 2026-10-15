import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../test_controller.dart';

/// 테스트 소개. 응답 기준을 첫 화면에 명시한다 (FR-6.1).
class TestIntroScreen extends ConsumerWidget {
  const TestIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.testIntroTitle)),
      body: SafeArea(
        child: content.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (bundle) {
            final test = bundle.test;
            if (test == null) {
              return Center(child: Text(l10n.testIntroEmpty));
            }
            return Padding(
              padding: const EdgeInsets.all(Tokens.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(l10n.testIntroHeadline,
                      style: text.displayMedium),
                  const SizedBox(height: 20),
                  Text(l10n.testIntroBasis(test.basis),
                      style: text.bodyLarge),
                  const SizedBox(height: 8),
                  Text(l10n.testIntroQuestionCount(test.baseQuestions.length),
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
                    child: Text(l10n.testIntroStart),
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
