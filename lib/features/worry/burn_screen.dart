import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../data/db/database.dart';
import '../../data/repositories/worry_repository.dart';
import '../dialogue/dialogue_service.dart';
import '../../l10n/l10n.dart';
import '../home/home_controller.dart';
import '../safety/safety_detector.dart';
import 'burn_animation.dart';

/// 탐·진·치 (v3 죽비). 강제하지 않는다.
/// 키는 DB 에 저장되는 값이라 그대로 두고, 표시 이름만 문자열 테이블에서 온다.
Map<String, String> get kWorryKinds => {
      'greed': L.current.worryKindGreed,
      'anger': L.current.worryKindAnger,
      'delusion': L.current.worryKindDelusion,
    };

enum _Step { write, zukbi, burning }

/// 번뇌 태우기 → 죽비 → 태우기 (v3 놀이).
class BurnScreen extends ConsumerStatefulWidget {
  const BurnScreen({super.key});

  @override
  ConsumerState<BurnScreen> createState() => _BurnScreenState();
}

class _BurnScreenState extends ConsumerState<BurnScreen> {
  final _controller = TextEditingController();
  _Step _step = _Step.write;
  String? _kind;
  Worry? _worry;
  String? _seonsaLine;
  bool _busy = false;
  int _rebuttals = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 「죽비 받기」 — 번뇌를 저장하고 선사의 한마디를 받는다.
  Future<void> _submit() async {
    final body = _controller.text.trim();
    if (body.isEmpty || _busy) return;
    final l10n = context.l10n;
    setState(() => _busy = true);

    // 위기 신호는 입력 시점에 판정한다 (SA-1).
    final content = await ref.read(contentProvider.future);
    final flagged = SafetyDetector(content.safety).isFlagged(body);

    final worry = await ref.read(worryRepositoryProvider).create(
          body: body,
          kind: _kind,
          safetyFlagged: flagged,
        );

    if (flagged) {
      await ref.read(analyticsProvider).log('safety_shown');
      if (!mounted) return;
      setState(() => _busy = false);
      context.push(Routes.safety);
      return;
    }

    final line = await ref.read(dialogueServiceProvider).pick(
          pool: 'after_worry:${_poolFor(_kind)}',
          chip: _kind,
        );
    final text = line?.text ?? l10n.worryZukbiFallback;
    await ref.read(worryRepositoryProvider).attachSeonsaLine(worry.id, text);

    if (!mounted) return;
    setState(() {
      _worry = worry;
      _seonsaLine = text;
      _step = _Step.zukbi;
      _busy = false;
    });
  }

  String _poolFor(String? kind) => switch (kind) {
        'anger' => 'people',
        'greed' => 'money',
        'delusion' => 'etc',
        _ => 'etc',
      };

  /// 「반박」 — 죽비가 한 번 더 온다.
  Future<void> _rebut() async {
    final worry = _worry;
    if (worry == null || _busy) return;
    final l10n = context.l10n;
    setState(() => _busy = true);

    final count = await ref.read(worryRepositoryProvider).rebut(worry.id);
    final line = await ref.read(dialogueServiceProvider).pick(
          pool: 'after_worry:${_poolFor(_kind)}',
          chip: _kind,
        );

    if (!mounted) return;
    setState(() {
      _rebuttals = count;
      _seonsaLine = line?.text ?? l10n.worryRebuttalFallback;
      _busy = false;
    });
  }

  /// 「인정. 태운다」
  Future<void> _burn() async {
    final worry = _worry;
    if (worry == null || _busy) return;
    setState(() {
      _busy = true;
      _step = _Step.burning;
    });
    await ref.read(worryRepositoryProvider).burn(worry.id);
  }

  void _afterBurn() {
    ref.invalidate(homeStateProvider);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_step == _Step.burning) {
      return BurnOverlay(text: _controller.text.trim(), onDone: _afterBurn);
    }

    return Scaffold(
      backgroundColor: Tokens.ink,
      appBar: AppBar(
        backgroundColor: Tokens.ink,
        foregroundColor: Tokens.ivory,
        title: _BurnCount(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Tokens.gutter, 8, Tokens.gutter, Tokens.gutter),
          child: _step == _Step.write ? _buildWrite() : _buildZukbi(),
        ),
      ),
    );
  }

  Widget _buildWrite() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.worryWriteTitle,
          style: Theme.of(context)
              .textTheme
              .displayMedium
              ?.copyWith(color: Tokens.ivory, height: 1.3),
        ),
        const SizedBox(height: 6),
        Text(l10n.worryWriteSubtitle,
            style: const TextStyle(color: Color(0xFFA39B90), fontSize: 14)),
        const SizedBox(height: 28),

        // 종이 쪽지
        Transform.rotate(
          angle: -0.035,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            decoration: BoxDecoration(
              color: Tokens.ivory,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.worryNoteLabel,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF6B5F52))),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  maxLength: 80,
                  maxLines: 2,
                  minLines: 1,
                  autofocus: true,
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Tokens.ink,
                      height: 1.4),
                  decoration: InputDecoration(
                    isDense: true,
                    counterText: '',
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: l10n.worryNoteHint,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final e in kWorryKinds.entries)
              _KindChip(
                label: e.value,
                selected: _kind == e.key,
                onTap: () =>
                    setState(() => _kind = _kind == e.key ? null : e.key),
              ),
          ],
        ),

        const Spacer(),
        _MeritHint(),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: _busy ? null : _submit,
            child: Text(l10n.worrySubmitButton),
          ),
        ),
      ],
    );
  }

  Widget _buildZukbi() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF2B2622),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _controller.text.trim(),
            style: const TextStyle(
                color: Color(0xFFD9D0C3), fontSize: 15, height: 1.5),
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              color: Tokens.seal,
              child: const Text('喝',
                  style: TextStyle(
                      color: Tokens.ivory,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Text(
              _rebuttals == 0
                  ? l10n.worrySeonsaJustNow
                  : l10n.worrySeonsaZukbiCount(_rebuttals + 1),
              style: const TextStyle(color: Color(0xFFA39B90), fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          color: Tokens.ivory,
          child: Text(
            _seonsaLine ?? '',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Tokens.ink,
                  height: 1.5,
                ),
          ),
        ),
        const Spacer(),
        Text(
          l10n.worryZukbiHint,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFA39B90), fontSize: 12),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _busy ? null : _burn,
                  child: Text(l10n.worryBurnButton),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 110,
              height: 56,
              child: OutlinedButton(
                onPressed: _busy ? null : _rebut,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Tokens.ivory,
                  side: const BorderSide(color: Color(0xFF4A423B)),
                ),
                child: Text(l10n.worryRebutButton),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BurnCount extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeStateProvider).value;
    return Text(
      home == null
          ? ''
          : context.l10n.worryBurnCount(home.burnedToday, home.burnedCount),
      style: const TextStyle(color: Color(0xFFA39B90), fontSize: 13),
    );
  }
}

class _MeritHint extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final burnedToday = ref.watch(homeStateProvider).value?.burnedToday ?? 0;
    final merit = WorryRepository.meritForBurn(burnedToday);
    final l10n = context.l10n;
    const base = TextStyle(fontSize: 13, color: Color(0xFFD9D0C3), height: 1.4);
    const strong = TextStyle(color: Tokens.ivory, fontWeight: FontWeight.w700);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2622),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department_outlined,
              size: 18, color: Tokens.saffron),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: base,
                children: merit > 0
                    ? _spansAround(
                        l10n.worryMeritHint(_mark),
                        TextSpan(
                            text: l10n.worryMeritAmount(merit), style: strong),
                      )
                    : [
                        TextSpan(text: '${l10n.worryMeritDoneLead} '),
                        TextSpan(text: l10n.worryMeritDoneTail, style: strong),
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 문장 안 강조 조각 자리를 표시하는 글자. 번역문 어디에 와도 그 자리에 끼운다.
const _mark = '\u0001';

/// [template] 의 [_mark] 자리에 [strong] 을 끼워 한 문장을 이룬다.
List<InlineSpan> _spansAround(String template, TextSpan strong) {
  final i = template.indexOf(_mark);
  if (i < 0) return [TextSpan(text: template)];
  return [
    if (i > 0) TextSpan(text: template.substring(0, i)),
    strong,
    if (i + _mark.length < template.length)
      TextSpan(text: template.substring(i + _mark.length)),
  ];
}

class _KindChip extends StatelessWidget {
  const _KindChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: Tokens.minTap,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Tokens.saffron : Colors.transparent,
            border: Border.all(
                color: selected ? Tokens.saffron : const Color(0xFF4A423B)),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: selected ? Tokens.ink : Tokens.ivory,
              fontWeight: selected ? FontWeight.w700 : null,
            ),
          ),
        ),
      );
}
