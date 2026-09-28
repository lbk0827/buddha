import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/time_utils.dart';
import '../../data/db/database.dart';
import '../home/home_controller.dart';
import '../ordination/dharma_rank.dart';
import '../avatar/buddha_figure.dart';

/// v3 온보딩 — 가상 출가.
/// 안 믿어도 된다. 셀카 한 장이면 된다. 사진 없이도 출가할 수 있다.
class OrdinationScreen extends ConsumerStatefulWidget {
  const OrdinationScreen({super.key});

  @override
  ConsumerState<OrdinationScreen> createState() => _OrdinationScreenState();
}

class _OrdinationScreenState extends ConsumerState<OrdinationScreen> {
  late String _name = kDharmaNames[Random().nextInt(kDharmaNames.length)];
  bool _busy = false;

  void _reroll() {
    setState(() {
      String next;
      do {
        next = kDharmaNames[Random().nextInt(kDharmaNames.length)];
      } while (next == _name && kDharmaNames.length > 1);
      _name = next;
    });
  }

  Future<void> _ordain() async {
    if (_busy) return;
    setState(() => _busy = true);

    final db = ref.read(databaseProvider);
    await (db.update(db.profiles)..where((t) => t.id.equals(1))).write(
      ProfilesCompanion(
        dharmaName: Value(_name),
        ordainedAt: Value(DateTime.now()),
      ),
    );
    await ref.read(analyticsProvider).log('ordained');
    ref.invalidate(homeStateProvider);

    if (!mounted) return;
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final fg = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Tokens.gutter, 16, Tokens.gutter, Tokens.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        Container(
                          width: 24,
                          height: 4,
                          decoration: BoxDecoration(
                            color: i == 0
                                ? Tokens.ink
                                : fg.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ],
                  ),
                  Text('1 / 3 · 30초 컷',
                      style: text.bodySmall
                          ?.copyWith(color: fg.withValues(alpha: 0.55))),
                ],
              ),

              const SizedBox(height: 28),
              Text('일단 출가부터\n하고 시작하자.',
                  style: text.displayMedium?.copyWith(height: 1.25)),
              const SizedBox(height: 8),
              Text('안 믿어도 된다. 이름 하나 받고 가는 거다.',
                  style: text.bodyMedium
                      ?.copyWith(color: fg.withValues(alpha: 0.6))),

              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8DFD0),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFB8AD9C),
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignInside),
                        ),
                        child: Icon(Icons.person_outline,
                            size: 40, color: fg.withValues(alpha: 0.4)),
                      ),
                      const SizedBox(height: 8),
                      Text('중생 시절',
                          style: text.bodySmall
                              ?.copyWith(color: fg.withValues(alpha: 0.55))),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Icon(Icons.arrow_forward,
                        size: 26, color: Tokens.saffron),
                  ),
                  Column(
                    children: [
                      const BuddhaFigure(size: 128),
                      const SizedBox(height: 8),
                      Text('법명 · $_name',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Tokens.temple)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  onPressed: _reroll,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('다른 이름'),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  kDharmaMeanings[_name] ?? '',
                  textAlign: TextAlign.center,
                  style: text.bodySmall
                      ?.copyWith(color: fg.withValues(alpha: 0.55)),
                ),
              ),

              const SizedBox(height: 20),
              _RankLadder(name: _name),

              const Spacer(),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _busy ? null : _ordain,
                  child: Text('${withRo(_name)} 출가하기'),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '기록은 이 폰 안에만 남는다. 서버로 보내지 않는다.',
                  style: text.bodySmall
                      ?.copyWith(color: fg.withValues(alpha: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 법명은 수행하면 진화한다.
class _RankLadder extends StatelessWidget {
  const _RankLadder({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF221F1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fg.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('법명은 수행하면 진화한다',
              style: TextStyle(
                  fontSize: 12, color: fg.withValues(alpha: 0.55))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (var i = 0; i < kDharmaRanks.length; i++) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: i == 0
                        ? Tokens.ink
                        : fg.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    kDharmaRanks[i].nameFor(name),
                    style: TextStyle(
                      fontSize: 13,
                      color: i == 0 ? Tokens.ivory : fg,
                    ),
                  ),
                ),
                if (i < kDharmaRanks.length - 1)
                  Text('→',
                      style:
                          TextStyle(color: fg.withValues(alpha: 0.35))),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
