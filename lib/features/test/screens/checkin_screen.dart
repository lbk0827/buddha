import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';

/// 오늘의 체크인 1문항 (FR-6.6).
/// 오늘 기본값만 바꾼다. 유형·법명은 건드리지 않는다.
class CheckinScreen extends ConsumerWidget {
  const CheckinScreen({super.key});

  static const _options = [
    ('X', '짧게 끊고 싶다', 180),
    ('O', '누구 옆에 있고 싶다', 180),
    ('M', '몸을 움직이고 싶다', 180),
    ('Q', '조용히 오래 있고 싶다', 600),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 체크인')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text('오늘은 어느 쪽이냐', style: text.displayMedium),
              const SizedBox(height: 24),
              for (final (dir, label, len) in _options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(analyticsProvider).log(
                          'checkin_selected', {'dir': dir});
                      context.pushReplacement(
                          '${Routes.sessionSetup}?len=$len');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(label, style: text.bodyLarge),
                    ),
                  ),
                ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () => context.go(Routes.home),
                  child: const Text('건너뛰기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
