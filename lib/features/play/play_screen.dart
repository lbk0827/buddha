import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../home/home_controller.dart';
import '../shell/app_shell.dart';
import '../shell/tab_top_bar.dart';
import 'moktak.dart';
import 'moktak_sound.dart';
import 'play_instrument.dart';
import 'play_stage.dart';
import 'prayer_beads.dart';
import 'singing_bowl.dart';
import 'singing_bowl_sound.dart';

/// 「놀이」 — 목탁이나 싱잉볼이 주인공이다.
/// 별도 화면을 두지 않고 탭에서 바로 두드린다. 아래 전환 버튼으로 악기를 바꾼다.
class PlayScreen extends ConsumerStatefulWidget {
  const PlayScreen({super.key});

  @override
  ConsumerState<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends ConsumerState<PlayScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  /// 싱잉볼 파문은 더 길게 퍼진다.
  late final AnimationController _bowlRing = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  /// 채를 휘두르는 동작. 값은 [StrikeTiming.swingAt]으로 채 위치가 된다.
  late final AnimationController _moktakSwing = AnimationController(
    vsync: this,
    duration: StrikeTiming.total,
  );
  late final AnimationController _bowlSwing = AnimationController(
    vsync: this,
    duration: StrikeTiming.total,
  );

  /// 소리와 닿는 순간을 맞추는 예약. 화면을 떠나면 취소한다.
  final _timers = <Timer>{};

  /// 문지르는 동안과 울림이 잦아드는 동안만 돈다.
  late final Ticker _rubTicker = createTicker(_onRubTick);
  final _rub = RubMeter();
  final _bowlStageKey = GlobalKey();
  final _moveClock = Stopwatch();
  Duration _lastTick = Duration.zero;

  late final MoktakSound _moktakSound;
  late final SingingBowlSound _bowlSound;

  int _knocks = 0;
  int _strikes = 0;
  double _rubSeconds = 0;

  /// 오늘 넘긴 염주. 저장소가 돌려준 값만 쓴다.
  BeadCount _beads = BeadCount.zero;

  /// 저장을 한 줄로 세운다. 늦게 온 결과가 앞선 결과를 덮지 않게.
  Future<void> _beadQueue = Future.value();

  /// 울리는 동안 쌓인 시간. [PrayerBeads.rubSecondsPerBead]마다 한 알.
  double _rubBeadClock = 0;

  /// 방금 한 바퀴를 돌아 받은 공덕. 잠깐 보여주고 지운다.
  int? _justGained;

  @override
  void initState() {
    super.initState();
    // dispose 에서는 ref 를 쓸 수 없어 미리 잡아 둔다.
    _moktakSound = ref.read(moktakSoundProvider)..warmUp();
    _bowlSound = ref.read(singingBowlSoundProvider)..warmUp();
    _enqueueBeads(() => ref.read(playRepositoryProvider).today());
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _bowlSound.rub(0);
    _rubTicker.dispose();
    _ring.dispose();
    _bowlRing.dispose();
    _moktakSwing.dispose();
    _bowlSwing.dispose();
    super.dispose();
  }

  void _after(Duration delay, VoidCallback action) {
    late final Timer timer;
    timer = Timer(delay, () {
      _timers.remove(timer);
      if (mounted) action();
    });
    _timers.add(timer);
  }

  /// 염주 [beads]알을 넘긴다. 바퀴를 다 돌면 공덕이 붙는다.
  void _addBeads(int beads) {
    final repo = ref.read(playRepositoryProvider);
    _enqueueBeads(() => repo.addBeads(beads));
  }

  void _enqueueBeads(Future<BeadCount> Function() step) {
    _beadQueue = _beadQueue.then((_) async {
      final beads = await step();
      if (!mounted) return;
      setState(() => _beads = beads);
      if (beads.meritGained > 0) _celebrate(beads.meritGained);
    }).catchError((Object e) {
      // 못 남겨도 놀이는 된다.
      debugPrint('염주를 못 남겼다: $e');
    });
  }

  void _celebrate(int merit) {
    ref.invalidate(homeStateProvider); // 위 공덕 알약을 새로 읽는다
    setState(() => _justGained = merit);
    _after(const Duration(milliseconds: 2400), () {
      setState(() => _justGained = null);
    });
  }

  /// 채를 휘두른다. 소리는 닿는 순간 들리도록 미리, 파문·진동은 닿는 순간.
  void _swing(
    AnimationController swing, {
    required Duration soundOnset,
    required VoidCallback sound,
    required VoidCallback impact,
  }) {
    if (!kShowMallets) {
      // 채가 안 보이면 늦출 이유가 없다. 탭하는 즉시.
      sound();
      impact();
      return;
    }
    swing.forward(from: 0);
    _after(StrikeTiming.soundDelay(soundOnset), sound);
    _after(StrikeTiming.swingDown, impact);
  }

  void _knock() {
    setState(() => _knocks++);
    _addBeads(1);
    _swing(
      _moktakSwing,
      soundOnset: Duration.zero, // moktak.mp3 는 0ms 부터 소리가 난다
      sound: _moktakSound.knock,
      impact: () {
        HapticFeedback.mediumImpact();
        _ring.forward(from: 0);
      },
    );
  }

  void _strike() {
    setState(() => _strikes++);
    _addBeads(1);
    _swing(
      _bowlSwing,
      // 합성 타격음은 파일 시작점에서 바로 소리가 난다.
      soundOnset: Duration.zero,
      sound: _bowlSound.strike,
      impact: () {
        HapticFeedback.lightImpact();
        _bowlRing.forward(from: 0);
      },
    );
  }

  /// 손가락 위치를 입구 타원을 원으로 편 좌표로. 그래야 테두리를 따라 돈 만큼
  /// 각도가 고르게 늘어난다.
  Offset? _onRim(Offset global) {
    final box = _bowlStageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return SingingBowlLayout.toRimCircle(box.globalToLocal(global));
  }

  void _rubStart(DragStartDetails d) {
    _moveClock
      ..reset()
      ..start();
    final offset = _onRim(d.globalPosition);
    if (offset != null) _rub.move(offset, 0);
    if (!_rubTicker.isActive) {
      _lastTick = Duration.zero;
      _rubTicker.start();
    }
  }

  void _rubUpdate(DragUpdateDetails d) {
    final dt = _moveClock.elapsedMicroseconds / 1e6;
    _moveClock
      ..reset()
      ..start();
    final offset = _onRim(d.globalPosition);
    if (offset != null) _rub.move(offset, dt);
  }

  void _rubEnd() {
    _moveClock.stop();
    _rub.lift();
  }

  void _onRubTick(Duration elapsed) {
    final dt = ((elapsed - _lastTick).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _lastTick = elapsed;
    _rub.tick(dt);
    _bowlSound.rub(_rub.level);
    final sounding = _rub.level > 0.25;
    setState(() {
      if (sounding) _rubSeconds += dt;
    });
    if (sounding) {
      _rubBeadClock += dt;
      final beads = _rubBeadClock ~/ PrayerBeads.rubSecondsPerBead;
      if (beads > 0) {
        _rubBeadClock -= beads * PrayerBeads.rubSecondsPerBead;
        _addBeads(beads);
      }
    }
    if (_rub.isSilent && !_moveClock.isRunning) _rubTicker.stop();
  }

  void _select(PlayInstrument instrument) {
    if (instrument != PlayInstrument.singingBowl) {
      _rubEnd();
      _rubTicker.stop();
      _bowlSound.rub(0);
    }
    ref.read(playInstrumentProvider.notifier).select(instrument);
  }

  String get _bowlCaption {
    final parts = [
      if (_strikes > 0) '$_strikes번 쳤다',
      if (_rubSeconds >= 1) '${_rubSeconds.floor()}초 울렸다',
    ];
    return parts.isEmpty ? '치거나, 테두리를 천천히 돌려라.' : '${parts.join(' · ')}.';
  }

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeStateProvider).value;
    final instrument = ref.watch(playInstrumentProvider);
    final text = Theme.of(context).textTheme;
    final fg = Theme.of(context).colorScheme.onSurface;
    final bowl = instrument == PlayInstrument.singingBowl;

    final Widget figure = bowl
        ? AnimatedBuilder(
            animation: Listenable.merge([_bowlRing, _bowlSwing]),
            builder: (context, _) => SizedBox.fromSize(
              key: _bowlStageKey,
              size: kPlayStage,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: SingingBowlUnderPainter(pulse: _bowlRing.value),
                    ),
                  ),
                  PlaySprite(
                    asset: SingingBowlLayout.bowlAsset,
                    placement: SingingBowlLayout.bowl,
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: RimGlowPainter(
                        level: _rub.level,
                        angle: _rub.angle,
                        direction: _rub.direction,
                      ),
                    ),
                  ),
                  if (kShowMallets)
                    SwingingMallet(
                      rig: SingingBowlLayout.mallet,
                      swing: StrikeTiming.swingAt(_bowlSwing.value),
                    ),
                ],
              ),
            ),
          )
        : AnimatedBuilder(
            animation: Listenable.merge([_ring, _moktakSwing]),
            builder: (context, _) => SizedBox.fromSize(
              size: kPlayStage,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: MoktakUnderPainter(pulse: _ring.value),
                    ),
                  ),
                  PlaySprite(
                    asset: MoktakLayout.bodyAsset,
                    placement: MoktakLayout.body,
                    child: (image) => Transform(
                      transform: moktakSquash(_ring.value),
                      origin: MoktakLayout.bottom - MoktakLayout.body.origin,
                      child: image,
                    ),
                  ),
                  if (kShowMallets)
                    SwingingMallet(
                      rig: MoktakLayout.mallet,
                      swing: StrikeTiming.swingAt(_moktakSwing.value),
                    ),
                ],
              ),
            ),
          );

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const TabTopBar(),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: bowl ? _strike : _knock,
              onPanStart: bowl ? _rubStart : null,
              onPanUpdate: bowl ? _rubUpdate : null,
              onPanEnd: bowl ? (_) => _rubEnd() : null,
              onPanCancel: bowl ? _rubEnd : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  figure,
                  const SizedBox(height: 20),
                  Text(
                    bowl ? '싱잉볼을 울려라.' : '목탁을 두드려라.',
                    style: text.displayMedium?.copyWith(fontSize: 30),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    bowl
                        ? _bowlCaption
                        : _knocks == 0
                        ? '세는 것 말고는 아무 일도 안 일어난다.'
                        : '$_knocks번 두드렸다.',
                    style: text.bodyMedium?.copyWith(
                      color: fg.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 14),
                  BeadLine(beads: _beads, justGained: _justGained),
                  const Spacer(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SegmentedButton<PlayInstrument>(
              segments: [
                for (final i in PlayInstrument.values)
                  ButtonSegment(value: i, label: Text(i.label)),
              ],
              selected: {instrument},
              showSelectedIcon: false,
              onSelectionChanged: (s) => _select(s.single),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Tokens.gutter,
              0,
              Tokens.gutter,
              kHudClearance,
            ),
            child: TabCard(
              label: '번뇌 태우기',
              body: home == null
                  ? '한 줄 적으면 선사가 죽비를 준다.'
                  : '태운 번뇌 ${home.burnedCount} / 108',
              onTap: () => context.push(Routes.burn),
            ),
          ),
        ],
      ),
    );
  }
}

/// 염주 한 줄 — 「염주 37 / 108 · 오늘 2바퀴」.
class BeadLine extends StatelessWidget {
  const BeadLine({super.key, required this.beads, this.justGained});

  final BeadCount beads;
  final int? justGained;

  String get _label {
    final gained = justGained;
    if (gained != null) return '한 바퀴 돌았다. 공덕 +$gained';
    final progress = '염주 ${beads.inRound} / ${PrayerBeads.perRound}';
    if (beads.meritDoneToday) return '$progress · 오늘 공덕은 다 받았다';
    if (beads.roundsToday > 0) return '$progress · 오늘 ${beads.roundsToday}바퀴';
    return '$progress · 한 바퀴에 공덕 ${PrayerBeads.meritPerRound}';
  }

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final highlight = justGained != null;
    return Semantics(
      liveRegion: highlight,
      child: Text(
        _label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: highlight ? Tokens.saffron : fg.withValues(alpha: 0.45),
          fontWeight: highlight ? FontWeight.w700 : null,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
