import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/time_utils.dart';
import 'calendar_data.dart';

final _count = NumberFormat.decimalPattern();

const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

/// 달력 — 하루에 얼마나 걸었고 명상했는지 보는 기록.
///
/// 칸 막대는 걸음 수(만 보면 가득), 날짜 자리의 연꽃은 그날 명상한 날이다.
/// 절 탭 왼쪽 아래 버튼으로 연다.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  bool get _isThisMonth {
    final now = DateTime.now();
    return _month.year == now.year && _month.month == now.month;
  }

  void _shift(int months) =>
      setState(() => _month = DateTime(_month.year, _month.month + months));

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(calendarMonthProvider(_month));

    return Scaffold(
      appBar: AppBar(title: const Text('달력')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Tokens.gutter - 8, 4, Tokens.gutter, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _shift(-1),
                    icon: const Icon(Icons.chevron_left),
                    tooltip: '지난달',
                  ),
                  Text(
                    '${_month.year}년 ${_month.month}월',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    onPressed: _isThisMonth ? null : () => _shift(1),
                    icon: const Icon(Icons.chevron_right),
                    tooltip: '다음 달',
                  ),
                  const Spacer(),
                  if (data.value case final m?) _MonthTotals(month: m),
                ],
              ),
            ),
            const _WeekdayHeader(),
            Expanded(
              child: data.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('달력을 못 열었다.\n\n$e')),
                data: (m) => ListView(
                  padding: const EdgeInsets.fromLTRB(
                      Tokens.gutter, 16, Tokens.gutter, 24),
                  children: [
                    _MonthGrid(month: m),
                    if (!m.stepsLinked) ...[
                      const SizedBox(height: 20),
                      const _LinkStepsCard(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthTotals extends StatelessWidget {
  const _MonthTotals({required this.month});
  final CalendarMonth month;

  @override
  Widget build(BuildContext context) {
    final muted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    final meditation = month.totalPracticedSec == 0
        ? '명상 없음'
        : '명상 ${formatDuration(month.totalPracticedSec)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (month.stepsLinked)
          Text.rich(TextSpan(children: [
            TextSpan(
              text: _count.format(month.totalSteps),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            TextSpan(
                text: ' 보', style: TextStyle(fontSize: 14, color: muted)),
          ])),
        Text(meditation, style: TextStyle(fontSize: 13, color: muted)),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Container(
      color: fg.withValues(alpha: 0.04),
      padding: const EdgeInsets.symmetric(
          horizontal: Tokens.gutter, vertical: 10),
      child: Row(
        children: [
          for (final w in const ['일', '월', '화', '수', '목', '금', '토'])
            Expanded(
              child: Text(
                w,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: fg.withValues(alpha: 0.55)),
              ),
            ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.month});
  final CalendarMonth month;

  @override
  Widget build(BuildContext context) {
    // 일요일 시작. DateTime.weekday 는 월=1 … 일=7.
    final lead = month.month.weekday % 7;
    final cells = <CalendarDay?>[
      for (var i = 0; i < lead; i++) null,
      ...month.days,
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return Column(
      children: [
        for (var row = 0; row < cells.length; row += 7)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                for (final c in cells.sublist(row, row + 7))
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: c == null
                          ? const SizedBox.shrink()
                          : _DayCell(day: c, showSteps: month.stepsLinked),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.showSteps});
  final CalendarDay day;
  final bool showSteps;

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final now = DateTime.now();
    final isToday = day.date.year == now.year &&
        day.date.month == now.month &&
        day.date.day == now.day;
    final isFuture = day.date.isAfter(now);

    return Semantics(
      button: true,
      label: _label(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isFuture ? null : () => _showDetail(context),
        child: ExcludeSemantics(
          child: Column(
            children: [
              SizedBox(
                height: 24,
                child: Center(
                  child: day.credited
                      // 명상한 날은 숫자 자리에 연꽃을 둔다.
                      ? Image.asset('assets/home/icon_lotus.webp',
                          width: 22, height: 22)
                      : Text(
                          '${day.date.day}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                isToday ? FontWeight.w800 : FontWeight.w400,
                            color: fg.withValues(
                                alpha: isToday ? 1 : (isFuture ? 0.3 : 0.55)),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 72,
                  color: fg.withValues(alpha: 0.04),
                  alignment: Alignment.bottomCenter,
                  child: showSteps
                      ? FractionallySizedBox(
                          heightFactor: day.stepRatio,
                          widthFactor: 1,
                          child: Container(
                            color: Tokens.saffron.withValues(
                                alpha: day.stepRatio >= 1 ? 0.85 : 0.45),
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _label() {
    final parts = ['${day.date.month}월 ${day.date.day}일'];
    if (day.steps != null) parts.add('${_count.format(day.steps)}보');
    if (day.practicedSec > 0) {
      parts.add('명상 ${formatDuration(day.practicedSec)}');
    }
    return parts.join(', ');
  }

  void _showDetail(BuildContext context) {
    final text = Theme.of(context).textTheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Tokens.gutter, 0, Tokens.gutter, Tokens.gutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${day.date.month}월 ${day.date.day}일 '
                '${_weekdays[day.date.weekday - 1]}요일',
                style: text.titleLarge,
              ),
              const SizedBox(height: 16),
              _DetailRow(
                label: '걸음',
                value: !showSteps
                    ? '연결 안 함'
                    : day.steps == null
                        ? '기록 없음'
                        : '${_count.format(day.steps)}보',
              ),
              _DetailRow(
                label: '명상',
                value: day.practicedSec == 0
                    ? '안 했다'
                    : formatDuration(day.practicedSec),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final muted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
              width: 56,
              child: Text(label, style: TextStyle(fontSize: 15, color: muted))),
          Text(value,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// 걸음 수를 아직 연결하지 않았을 때.
class _LinkStepsCard extends ConsumerStatefulWidget {
  const _LinkStepsCard();

  @override
  ConsumerState<_LinkStepsCard> createState() => _LinkStepsCardState();
}

class _LinkStepsCardState extends ConsumerState<_LinkStepsCard> {
  bool _busy = false;

  Future<void> _link() async {
    setState(() => _busy = true);
    final ok = await linkSteps(ref);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('걸음 수를 못 읽었다. 건강 앱에서 허락하면 보인다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fg.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('걸음 수도 함께 볼까?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            '건강 앱의 걸음 수를 읽기만 한다. 어디로도 보내지 않는다.',
            style: TextStyle(fontSize: 14, color: fg.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : _link,
            child: const Text('걸음 수 연결'),
          ),
        ],
      ),
    );
  }
}
