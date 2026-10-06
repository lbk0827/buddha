import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/flags.dart';
import '../../safety/safety_detector.dart';
import '../../worry/burn_animation.dart';
import '../session_controller.dart';

/// 주제 칩 (FR-2.1).
const Map<String, String> kWorryChips = {
  'work': '일',
  'people': '사람',
  'money': '돈',
  'family': '가족',
  'body': '몸',
  'etc': '그냥',
  'heavy': '많이 힘듦',
};

const int kWorryMaxLength = 80;

class SessionSetupScreen extends ConsumerStatefulWidget {
  const SessionSetupScreen({
    super.key,
    this.prefillWorry = false,
    this.forcedLengthSec,
    this.forceAudio = false,
  });

  /// 말씀의 뿌리 「작은 행동」에서 넘어온 경우 번뇌 입력을 열어 둔다 (FR-5.2).
  final bool prefillWorry;
  final int? forcedLengthSec;
  final bool forceAudio;

  @override
  ConsumerState<SessionSetupScreen> createState() => _SessionSetupScreenState();
}

class _SessionSetupScreenState extends ConsumerState<SessionSetupScreen> {
  final _worryController = TextEditingController();
  late int _targetSec;
  String? _chip;
  bool _repeatFlag = false;
  bool _audioOn = false;

  /// null이 아니면 태우기 화면을 덮어 보여준다.
  String? _burning;

  @override
  void initState() {
    super.initState();
    _targetSec = widget.forcedLengthSec ?? 180;
    _audioOn = widget.forceAudio && Flags.audioAssetAvailable;
    // 회복 선호 기본값은 프로필에서 읽어 첫 3회만 적용한다 (FR-6.5).
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyRecoveryDefaults());
  }

  Future<void> _applyRecoveryDefaults() async {
    if (widget.forcedLengthSec != null) return;
    final repo = ref.read(profileRepositoryProvider);
    final profile = await repo.ensure();
    if (profile.recoveryPref == null) return;
    if (profile.defaultsAppliedCount >= 3) return;
    if (!mounted) return;

    setState(() {
      switch (profile.recoveryPref) {
        case 'Q': // 조용히 오래
          _targetSec = 600;
        case 'X': // 짧게 끊고
          _targetSec = 180;
      }
    });
    await repo.bumpDefaultsApplied();
  }

  @override
  void dispose() {
    _worryController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final worry = _worryController.text.trim();
    // 위기 신호는 입력 시점에 판정한다 (SA-1).
    // 콘텐츠 로딩 경합으로 감지를 건너뛰면 안 되므로 여기서 기다린다.
    final content = await ref.read(contentProvider.future);
    final flagged = SafetyDetector(content.safety).isFlagged(worry);
    if (!mounted) return;

    ref.read(sessionControllerProvider.notifier)
      ..updateSetup(SessionSetup(
        targetSec: _targetSec,
        worryText: worry.isEmpty ? null : worry,
        worryChip: _chip,
        repeatFlag: _repeatFlag,
        audioOn: _audioOn,
      ))
      ..setSafetyFlag(flagged);

    if (flagged) {
      await ref.read(analyticsProvider).log('safety_shown');
      if (!mounted) return;
      context.push(Routes.safety);
      return;
    }

    ref.read(sessionControllerProvider.notifier).enterReady();
    if (!mounted) return;

    // 적었으면 태우고 간다 (FR-3.3). 텍스트는 기록에 남는다.
    if (worry.isNotEmpty) {
      setState(() => _burning = worry);
      return;
    }
    context.push(Routes.sessionReady);
  }

  void _afterBurn() {
    if (!mounted) return;
    setState(() => _burning = null);
    context.push(Routes.sessionReady);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    if (_burning != null) {
      return BurnOverlay(text: _burning!, onDone: _afterBurn);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('마음 비우기')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    Tokens.gutter, 8, Tokens.gutter, 16),
                children: [
                  Text('얼마나 오래 마음을 내려놓을까?', style: text.titleLarge),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _LengthChoice(
                          label: '3분',
                          selected: _targetSec == 180,
                          onTap: () => setState(() => _targetSec = 180),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LengthChoice(
                          label: '10분',
                          selected: _targetSec == 600,
                          onTap: () => setState(() => _targetSec = 600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text('태우고 싶은 번뇌 작성하기', style: text.titleLarge),
                  const SizedBox(height: 4),
                  Text('안 써도 된다.',
                      style: text.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.55))),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _worryController,
                    maxLength: kWorryMaxLength,
                    maxLines: 2,
                    autofocus: widget.prefillWorry,
                    decoration: const InputDecoration(
                      hintText: '한 줄이면 충분하다',
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('무엇이 그댈 괴롭히는가?', style: text.titleLarge),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final entry in kWorryChips.entries)
                        ChoiceChip(
                          label: Text(entry.value),
                          selected: _chip == entry.key,
                          onSelected: (v) =>
                              setState(() => _chip = v ? entry.key : null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('지난번 그 얘기'),
                    subtitle: const Text('끄면 선사가 이전 번뇌를 꺼내지 않는다.'),
                    value: _repeatFlag,
                    onChanged: (v) => setState(() => _repeatFlag = v),
                  ),
                  if (Flags.audioAssetAvailable)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('음원'),
                      value: _audioOn,
                      onChanged: (v) => setState(() => _audioOn = v),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Tokens.gutter, 0, Tokens.gutter, Tokens.gutter),
              child: Row(
                children: [
                  // 건너뛰기는 입력칸과 같은 무게로 둔다 (FR-3.1).
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _worryController.clear();
                        _start();
                      },
                      child: const Text('그냥 시작'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _start,
                      child: const Text('시작'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LengthChoice extends StatelessWidget {
  const _LengthChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? Tokens.saffron.withValues(alpha: 0.18)
              : scheme.onSurface.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? Tokens.saffron
                : scheme.onSurface.withValues(alpha: 0.18),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Text(label,
            style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}
