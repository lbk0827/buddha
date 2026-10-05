import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/time_utils.dart';
import '../../../data/content/models.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../dialogue/dialogue_service.dart';
import '../../home/home_controller.dart';
import '../../dialogue/share_card.dart';
import '../../temple/temple_stage.dart';
import '../../temple/temple_yard.dart';
import '../session_controller.dart';

/// 기록 저장 동의를 이미 물어봤다는 표시. 거부해도 다시 묻지 않게 설정에 남긴다.
const recordConsentAskedKey = '${ConsentKeys.recordStorage}_asked';

/// 완주·중단 공통 종료 화면 (FR-2.8).
/// 깨달음을 요구하거나 평가하는 문구는 두지 않는다.
class SessionDoneScreen extends ConsumerStatefulWidget {
  const SessionDoneScreen({super.key});

  @override
  ConsumerState<SessionDoneScreen> createState() => _SessionDoneScreenState();
}

class _SessionDoneScreenState extends ConsumerState<SessionDoneScreen> {
  DialogueItem? _seonsaLine;
  bool _loadingLine = false;
  bool _lineRequested = false;
  bool _discarded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _askRecordConsent());
  }

  /// 기록 저장 동의는 첫 세션 종료 직전 1회 (FR-1.5).
  /// 거부하면 그 세션은 기록 없이 끝난다.
  Future<void> _askRecordConsent() async {
    final repo = ref.read(profileRepositoryProvider);
    final profile = await repo.ensure();
    // 이미 한 번 물었으면 다시 묻지 않는다. 물어봤다는 표시는 설정 쪽에 남는다.
    if (repo.consentsOf(profile).containsKey(ConsentKeys.recordStorage) ||
        repo.settingsOf(profile)[recordConsentAskedKey] == true) {
      return;
    }
    if (!mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('기록을 기기에 저장해도 되나'),
        content: const Text('여기 남기는 건 이 폰 안에만 있다. 서버로 보내지 않는다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('아니'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('그래'),
          ),
        ],
      ),
    );

    await repo.setConsent(ConsentKeys.recordStorage, ok == true);
    // 거부해도 다시 묻지 않도록 물어봤다는 사실만 남긴다.
    await repo.setSetting(recordConsentAskedKey, true);

    if (ok == true) return;

    // 거부 — 이 세션은 기록 없이 종료한다.
    final sessionId = ref.read(sessionControllerProvider).sessionId;
    if (sessionId != null) {
      await ref.read(sessionRepositoryProvider).discard(sessionId);
    }
    if (!mounted) return;
    setState(() => _discarded = true);
  }

  /// \[선사 한마디 보기\]를 눌렀을 때만 노출한다. 세션당 1개 (FR-3.4).
  Future<void> _revealLine() async {
    final state = ref.read(sessionControllerProvider);
    setState(() {
      _lineRequested = true;
      _loadingLine = true;
    });

    // 칩을 안 골랐으면 "그냥" 풀을 쓴다. 그래야 폴백 세 줄만 돌지 않는다.
    final chip = state.setup.worryChip;
    final item = await ref.read(dialogueServiceProvider).pick(
          pool: 'after_worry:${chip ?? 'etc'}',
          chip: chip,
          safetyFlagged: state.safetyFlagged,
          practicedSec: state.result?.session.practicedSec,
          sessionId: state.sessionId,
        );

    if (!mounted) return;
    setState(() {
      _seonsaLine = item;
      _loadingLine = false;
    });
  }

  Future<void> _leave() async {
    final state = ref.read(sessionControllerProvider);
    final profileRepo = ref.read(profileRepositoryProvider);
    final profile = await profileRepo.ensure();

    ref.read(sessionControllerProvider.notifier).reset();
    // 동의했을 때만, 다음 날 1회 (FR-7.2).
    await scheduleRevisitIfConsented(ref);
    // 마당·등·인정일이 방금 바뀌었으니 홈을 다시 그리게 한다.
    ref.invalidate(homeStateProvider);
    if (!mounted) return;

    // 첫 완주 후 캐릭터·법명 제안 1회 (FR-1.3).
    // 기록을 남기지 않기로 했으면 법명도 권하지 않는다.
    if (!_discarded &&
        state.result?.isValid == true &&
        !profile.characterOnboardShown) {
      context.pushReplacement(Routes.characterOnboard);
      return;
    }
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionControllerProvider);
    final result = state.result;
    final text = Theme.of(context).textTheme;

    if (result == null) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => context.go(Routes.home),
            child: const Text('돌아가기'),
          ),
        ),
      );
    }

    final heavy = state.setup.worryChip == 'heavy';
    final practiced = result.session.practicedSec;
    final minimalCelebration = heavy || state.safetyFlagged;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                      Tokens.gutter, 32, Tokens.gutter, 16),
                  children: [
                    Text(
                      completionLine(
                          practicedSec: practiced, heavyChip: heavy),
                      style: text.displayMedium,
                    ),
                    const SizedBox(height: 28),

                    // 절 변화 연출 — 위기 세션에서는 축하만 유예한다 (SA-2).
                    if (result.newStage != null && !minimalCelebration) ...[
                      TempleYard(stage: result.newStage!.index, height: 170),
                      const SizedBox(height: 8),
                      Text(result.newStage!.arrivalLine,
                          style: text.headlineMedium),
                      const SizedBox(height: 24),
                    ] else if (result.isRepeatToday && !minimalCelebration) ...[
                      // 당일 반복 — 단계는 그대로, 등만 밝아진다 (FR-4.3).
                      TempleYard(
                        stage: stageForCreditedDays(result.creditedDays),
                        lanternBright: true,
                        height: 150,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // 기록 1줄 (FR-2.8). 저장을 거부했으면 남은 게 없다.
                    if (_discarded)
                      Text('기록은 남기지 않았다.',
                          style: text.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.55)))
                    else
                      _RecordLine(
                        practicedSec: practiced,
                        completed: result.session.outcome == 'completed',
                        valid: result.isValid,
                      ),
                    // 엎어둔 1분에 공덕 10. 기록을 안 남겨도 공덕은 남는다.
                    if (result.isValid) ...[
                      const SizedBox(height: 6),
                      Text(
                        '+${meritForSession(practiced)} 공덕',
                        style: text.bodyMedium?.copyWith(
                          color: Tokens.saffron,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // 위기 감지 세션에서는 한마디 카드·공유를 유예한다 (SA-2).
                    if (!state.safetyFlagged) ...[
                      if (!_lineRequested)
                        OutlinedButton(
                          onPressed: _revealLine,
                          child: const Text('선사 한마디 보기'),
                        )
                      else if (_loadingLine)
                        const Center(child: CircularProgressIndicator())
                      else if (_seonsaLine != null)
                        _SeonsaLine(item: _seonsaLine!),
                    ],

                    if (state.setup.repeatFlag && result.isValid) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context.push(Routes.sessionRepeat),
                        child: const Text('지난번 그 얘기'),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    Tokens.gutter, 0, Tokens.gutter, Tokens.gutter),
                child: FilledButton(
                  onPressed: _leave,
                  child: const Text('나가기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _RecordLine extends StatelessWidget {
  const _RecordLine({
    required this.practicedSec,
    required this.completed,
    required this.valid,
  });

  final int practicedSec;
  final bool completed;
  final bool valid;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final label = [
      formatDuration(practicedSec),
      completed ? '완주' : '중단',
      if (!valid) '기록만',
    ].join(' · ');

    return Text(
      label,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: fg.withValues(alpha: 0.55)),
    );
  }
}

class _SeonsaLine extends StatelessWidget {
  const _SeonsaLine({required this.item});
  final DialogueItem item;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: fg.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: fg.withValues(alpha: 0.12)),
          ),
          child: Text(item.text,
              style: Theme.of(context).textTheme.headlineMedium),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => shareDialogueCard(context, item.text),
          icon: const Icon(Icons.ios_share, size: 18),
          label: const Text('나누기'),
        ),
      ],
    );
  }
}
