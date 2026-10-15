import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';

/// 오늘의 체크인 1문항 (FR-6.6).
/// 오늘 기본값만 바꾼다. 유형·법명은 건드리지 않는다.
class CheckinScreen extends ConsumerWidget {
  const CheckinScreen({super.key});

  static List<(String, String, int)> _options(AppLocalizations l10n) => [
        ('X', l10n.testCheckinOptionShort, 180),
        ('O', l10n.testCheckinOptionCompany, 180),
        ('M', l10n.testCheckinOptionMove, 180),
        ('Q', l10n.testCheckinOptionLong, 600),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.testCheckinTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(l10n.testCheckinQuestion, style: text.displayMedium),
              const SizedBox(height: 24),
              for (final (dir, label, len) in _options(l10n))
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
                  child: Text(l10n.testCheckinSkip),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
