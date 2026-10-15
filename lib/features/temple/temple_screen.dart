import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../l10n/l10n.dart';
import 'temple_stage.dart';
import 'temple_yard.dart';

/// 절 화면. 건물 탭 → 상징 한 줄 (FR-4.6), 「다음 변화 보기」 (FR-4.5).
class TempleScreen extends ConsumerWidget {
  const TempleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final creditedDays = profile?.creditedDays ?? 0;
    final stage = stageForCreditedDays(creditedDays);
    final next = nextStageAfter(creditedDays);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.templeScreenTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Tokens.gutter),
          children: [
            TempleYard(stage: stage, height: 240),
            const SizedBox(height: 24),
            if (stage == 0)
              Text(context.l10n.templeEmptyYardLine,
                  style: Theme.of(context).textTheme.titleLarge)
            else
              for (final s in kTempleStages.take(stage))
                _StageTile(stage: s),
            const SizedBox(height: 24),
            if (next != null)
              OutlinedButton(
                onPressed: () {
                  ref.read(analyticsProvider).log(
                      'next_change_open', {'stage': stage});
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (_) => _NextChangeSheet(next: next),
                  );
                },
                child: Text(context.l10n.templeNextChangeButton),
              ),
          ],
        ),
      ),
    );
  }
}

class _StageTile extends StatelessWidget {
  const _StageTile({required this.stage});
  final TempleStage stage;

  /// 상징 한 줄 — 이름의 뜻·도상 라벨 (FR-4.6).
  static String _symbolOf(AppLocalizations l10n, int index) => switch (index) {
        1 => l10n.templeStageSymbolLantern,
        2 => l10n.templeStageSymbolTree,
        3 => l10n.templeStageSymbolWall,
        4 => l10n.templeStageSymbolBell,
        5 => l10n.templeStageSymbolRoof,
        6 => l10n.templeStageSymbolGate,
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final symbol = _symbolOf(context.l10n, stage.index);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(stage.name,
          style: Theme.of(context).textTheme.titleLarge),
      subtitle: Text(symbol),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(Tokens.gutter * 1.4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stage.name,
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 12),
              Text(symbol,
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextChangeSheet extends StatelessWidget {
  const _NextChangeSheet({required this.next});
  final TempleStage next;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(Tokens.gutter * 1.4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.templeNextStageTitle(next.name),
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 12),
            Text(next.arrivalLine,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text(context.l10n.templeNextStageRequirement(next.requiredCreditedDays),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55))),
            const SizedBox(height: 24),
          ],
        ),
      );
}
