import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
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
      appBar: AppBar(title: const Text('절')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Tokens.gutter),
          children: [
            TempleYard(stage: stage, height: 240),
            const SizedBox(height: 24),
            if (stage == 0)
              Text('아직 아무것도 없다. 한 번 앉으면 등이 하나 켜진다.',
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
                child: const Text('다음 변화 보기'),
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
  static const Map<String, String> _symbols = {
    '등': '어두운 데서 먼저 켜는 것. 밝히려는 마음이다.',
    '나무': '심은 사람은 그늘을 못 본다. 그래도 심는다.',
    '돌담': '막으려는 게 아니라, 안쪽을 만들려는 것이다.',
    '종': '스스로 울지 않는다. 쳐야 운다.',
    '지붕': '비를 없애는 게 아니라, 비 아래 앉을 자리를 만드는 것이다.',
    '일주문': '기둥이 한 줄이다. 들어올 때 마음도 한 줄이라는 뜻이다.',
  };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(stage.name,
          style: Theme.of(context).textTheme.titleLarge),
      subtitle: Text(_symbols[stage.name] ?? ''),
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
              Text(_symbols[stage.name] ?? '',
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
            Text('다음은 ${next.name}',
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 12),
            Text(next.arrivalLine,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text('인정일 ${next.requiredCreditedDays}',
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
