import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/time_utils.dart';
import '../../data/db/database.dart';
import '../../data/repositories/profile_repository.dart';
import '../../l10n/l10n.dart';
import '../session/screens/session_setup_screen.dart';

/// 기록 화면 (FR-4.7). \[숫자 가리기\] 토글이 있다.
class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(recentSessionsProvider);
    final profile = ref.watch(profileProvider).value;
    final repo = ref.watch(profileRepositoryProvider);
    final hideNumbers =
        profile == null ? false : repo.settingsOf(profile)[SettingKeys.hideNumbers] == true;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.recordsTitle),
        actions: [
          TextButton(
            onPressed: () =>
                repo.setSetting(SettingKeys.hideNumbers, !hideNumbers),
            child: Text(hideNumbers
                ? context.l10n.recordsShowNumbers
                : context.l10n.recordsHideNumbers),
          ),
        ],
      ),
      body: SafeArea(
        child: sessions.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (list) => ListView(
            padding: const EdgeInsets.all(Tokens.gutter),
            children: [
              if (!hideNumbers) const _Totals(),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(context.l10n.recordsEmpty,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              for (final entry in _groupByDate(list).entries) ...[
                const SizedBox(height: 20),
                Text(entry.key,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                for (final s in entry.value) _SessionTile(session: s),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Map<String, List<Session>> _groupByDate(List<Session> list) {
    final map = <String, List<Session>>{};
    for (final s in list) {
      map.putIfAbsent(s.localDate, () => []).add(s);
    }
    return map;
  }
}

class _Totals extends ConsumerWidget {
  const _Totals();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(creditedDaysProvider).value ?? 0;
    final total = ref.watch(totalPracticedProvider).value ?? 0;

    return Row(
      children: [
        Expanded(
            child: _Stat(
                label: context.l10n.recordsStatCreditedDays, value: '$days')),
        Expanded(
            child: _Stat(
                label: context.l10n.recordsStatCumulative,
                value: formatCumulative(total))),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: fg.withValues(alpha: 0.55))),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.displayMedium),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});
  final Session session;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final label = [
      formatDuration(session.practicedSec),
      session.outcome == 'completed'
          ? context.l10n.recordsOutcomeCompleted
          : context.l10n.recordsOutcomeInterrupted,
      session.detection == 'timer'
          ? context.l10n.recordsDetectionTimer
          : context.l10n.recordsDetectionFlip,
      if (session.worryChip != null) kWorryChips[session.worryChip] ?? '',
    ].where((e) => e.isNotEmpty).join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: fg.withValues(alpha: 0.6))),
          // 번뇌 원문은 사용자만 본다 (FR-3.3).
          if (session.worryText != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(session.worryText!,
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
        ],
      ),
    );
  }
}
