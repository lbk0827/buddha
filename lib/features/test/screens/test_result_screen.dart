import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../data/content/models.dart';
import '../../dialogue/share_card.dart';
import '../scorer.dart';
import '../test_controller.dart';

/// 결과 화면 3층 (FR-6.4).
/// 점수·상태명은 보여주지 않는다. 두드러지지 않은 방향의 문장은 렌더하지 않는다.
class TestResultScreen extends ConsumerStatefulWidget {
  const TestResultScreen({super.key});

  @override
  ConsumerState<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends ConsumerState<TestResultScreen> {
  bool _saved = false;
  String? _recoveryChoice;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final outcome = ref.read(testControllerProvider.notifier).currentOutcome();
      if (outcome == null || _saved) return;
      _saved = true;
      await ref.read(testControllerProvider.notifier).save(outcome);
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider).value?.test;
    final outcome = ref.watch(testControllerProvider.notifier).currentOutcome();
    final text = Theme.of(context).textTheme;

    if (content == null || outcome == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final typeResult =
        outcome.typeId == null ? null : content.typeResults[outcome.typeId];
    final headline = _headline(outcome, typeResult);

    return Scaffold(
      appBar: AppBar(title: const Text('결과')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Tokens.gutter),
          children: [
            // 1층 — 결과명·한마디·공유
            Text(headline.title, style: text.displayMedium),
            if (headline.line != null) ...[
              const SizedBox(height: 12),
              Text(headline.line!, style: text.headlineMedium),
            ],
            const SizedBox(height: 8),
            Text('응답 ${outcome.answeredCount} / 건너뜀 ${outcome.skippedCount}',
                style: text.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5))),
            const SizedBox(height: 12),
            if (headline.line != null)
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(analyticsProvider).log(
                      'share_sheet_open', {'source': 'test'});
                  // 카드에는 유형명을 넣지 않는다 (FR-3.7).
                  shareDialogueCard(context, headline.line!);
                },
                icon: const Icon(Icons.ios_share, size: 18),
                label: const Text('나누기'),
              ),

            const Divider(height: 48),

            // 2층 — 관찰·해석·제안. 두드러진 방향만 (FR-6.4).
            for (final dir in [outcome.gTop, outcome.aTop].whereType<String>())
              _DirectionBlock(
                  direction: dir, content: content.directions[dir]),

            if (outcome.recovery.isNotEmpty) ...[
              Text('회복은 이렇게', style: text.titleLarge),
              const SizedBox(height: 8),
              if (outcome.recovery.length == 1)
                _DirectionBlock(
                  direction: outcome.recovery.first,
                  content: content.directions[outcome.recovery.first],
                )
              else ...[
                // 동점이면 사용자가 고른다 (FR-6.5).
                Text('둘 다 비슷하게 나왔다. 어느 쪽이 더 너 같냐.',
                    style: text.bodyLarge),
                const SizedBox(height: 8),
                RadioGroup<String>(
                  groupValue: _recoveryChoice,
                  onChanged: (v) => setState(() => _recoveryChoice = v),
                  child: Column(
                    children: [
                      for (final r in outcome.recovery)
                        RadioListTile<String>(
                          contentPadding: EdgeInsets.zero,
                          value: r,
                          title: Text(content.directions[r]?.strength ?? r),
                        ),
                    ],
                  ),
                ),
              ],
            ],

            // 3층 — 상징. 대표·혼합에서만, 접힌 채로.
            if (typeResult?.symbol != null)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('상징'),
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(typeResult!.symbol!.meaning),
                    subtitle: Text(typeResult.symbol!.iconography),
                  ),
                ],
              ),

            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                final len = _lengthForRecovery(
                    _recoveryChoice ??
                        (outcome.recovery.length == 1
                            ? outcome.recovery.first
                            : null));
                context.push('${Routes.sessionSetup}?len=$len');
              },
              child: const Text('3분 시작'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () async {
                await ref
                    .read(testControllerProvider.notifier)
                    .applyToProfile(outcome, recoveryChoice: _recoveryChoice);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('프로필에 넣었다.')));
              },
              child: const Text('프로필에 적용'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                ref.read(testControllerProvider.notifier).reset();
                context.go(Routes.test);
              },
              child: const Text('다시 하기'),
            ),
            const SizedBox(height: 10),
            _FeelRating(
              onRate: (score) => ref
                  .read(analyticsProvider)
                  .log('test_feel', {'score': score}),
            ),
          ],
        ),
      ),
    );
  }

  int _lengthForRecovery(String? dir) => dir == 'Q' ? 600 : 180;

  _Headline _headline(TestOutcome outcome, TypeResultContent? type) {
    switch (outcome.state) {
      case TestState.representative:
        return _Headline(type?.name ?? '결과', type?.line);
      case TestState.mixed:
        return const _Headline('두 쪽이 섞여 있다', '하나로 안 묶인다. 그게 틀린 건 아니다.');
      case TestState.tendency:
        return const _Headline('한쪽으로 기운다', '아직 한 방향만 뚜렷하다.');
      case TestState.reservedInsufficient:
        return const _Headline('아직 모르겠다', '답이 모자란다. 더 답하면 보인다.');
      case TestState.reservedScattered:
        return const _Headline('고르게 흩어져 있다', '한쪽으로 안 쏠린다. 요즘이 그런 때다.');
    }
  }
}

class _Headline {
  final String title;
  final String? line;
  const _Headline(this.title, this.line);
}

class _DirectionBlock extends StatelessWidget {
  const _DirectionBlock({required this.direction, required this.content});

  final String direction;
  final DirectionContent? content;

  @override
  Widget build(BuildContext context) {
    if (content == null) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content!.interp, style: text.titleLarge),
          const SizedBox(height: 6),
          Text(content!.strength, style: text.bodyLarge),
          const SizedBox(height: 6),
          Text(content!.action,
              style: text.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}

/// "나 같냐" 지표 (PRD 분석 이벤트 test_feel).
class _FeelRating extends StatefulWidget {
  const _FeelRating({required this.onRate});
  final void Function(int score) onRate;

  @override
  State<_FeelRating> createState() => _FeelRatingState();
}

class _FeelRatingState extends State<_FeelRating> {
  int? _score;

  @override
  Widget build(BuildContext context) {
    if (_score != null) {
      return Center(
        child: Text('그래. 참고하겠다.',
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }
    return Column(
      children: [
        Text('나 같냐?', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= 5; i++)
              IconButton(
                onPressed: () {
                  setState(() => _score = i);
                  widget.onRate(i);
                },
                icon: Icon(Icons.circle_outlined, size: 18 + i.toDouble()),
              ),
          ],
        ),
      ],
    );
  }
}
