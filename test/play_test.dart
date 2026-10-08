import 'dart:async';
import 'dart:math' as math;

import 'package:bucheo_handsome/app/providers.dart';
import 'package:bucheo_handsome/app/theme.dart';
import 'package:bucheo_handsome/data/repositories/play_repository.dart';
import 'package:bucheo_handsome/features/home/home_controller.dart';
import 'package:bucheo_handsome/features/play/keycap.dart';
import 'package:bucheo_handsome/features/play/keycap_sound.dart';
import 'package:bucheo_handsome/features/play/moktak.dart';
import 'package:bucheo_handsome/features/play/moktak_sound.dart';
import 'package:bucheo_handsome/features/play/play_instrument.dart';
import 'package:bucheo_handsome/features/play/play_screen.dart';
import 'package:bucheo_handsome/features/play/play_stage.dart';
import 'package:bucheo_handsome/features/play/prayer_beads.dart';
import 'package:bucheo_handsome/features/play/singing_bowl.dart';
import 'package:bucheo_handsome/features/play/singing_bowl_sound.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePlay implements PlayRepository {
  _FakePlay([Map<PlayInstrument, int> start = const {}])
    : beads = {for (final i in PlayInstrument.values) i: start[i] ?? 0};
  final Map<PlayInstrument, int> beads;
  int merit = 0;

  @override
  Future<Map<PlayInstrument, BeadCount>> today() async => {
    for (final e in beads.entries) e.key: BeadCount(today: e.value),
  };

  @override
  Future<BeadCount> addBeads(PlayInstrument instrument, int n) async {
    final before = beads[instrument]!;
    final after = before + n;
    beads[instrument] = after;
    final gained = PrayerBeads.meritBetween(before, after);
    merit += gained;
    return BeadCount(today: after, meritGained: gained);
  }
}

class _FakeMoktak implements MoktakSound {
  int knocks = 0;
  @override
  void knock() => knocks++;
  @override
  Future<void> warmUp() async {}
  @override
  Future<void> dispose() async {}
}

class _FakeBowl implements SingingBowlSound {
  int strikes = 0;
  final levels = <double>[];
  @override
  void strike() => strikes++;
  @override
  void rub(double level) => levels.add(level);
  @override
  Future<void> warmUp() async {}
  @override
  Future<void> dispose() async {}
}

class _FakeKeycap implements KeycapSound {
  int presses = 0;
  int releases = 0;
  @override
  void press() => presses++;
  @override
  void release() => releases++;
  @override
  Future<void> warmUp() async {}
  @override
  Future<void> dispose() async {}
}

/// 반지름 [r] 원을 [speed] rad/s 로 [seconds] 동안 돌린다. 60fps.
void _circle(
  RubMeter m, {
  double r = 80,
  double speed = RubMeter.fullSpeed,
  double seconds = 3,
}) {
  const dt = 1 / 60;
  var a = 0.0;
  for (var t = 0.0; t < seconds; t += dt) {
    a += speed * dt;
    m.move(Offset(math.cos(a), math.sin(a)) * r, dt);
    m.tick(dt);
  }
}

/// 싱잉볼 무대. 테두리 빛 페인터가 무대 전체를 덮는다.
final _bowlStage = find.byWidgetPredicate(
  (w) => w is CustomPaint && w.painter is RimGlowPainter,
);

/// 입구 타원 위 [angle] 자리의 화면 좌표.
Offset _onRim(WidgetTester tester, double angle) {
  final rim = SingingBowlLayout.rim;
  return tester.getTopLeft(_bowlStage) +
      rim.center +
      Offset(rim.width / 2 * math.cos(angle), rim.height / 2 * math.sin(angle));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RubMeter — 문지르기', () {
    test('처음엔 조용하다', () {
      final m = RubMeter();
      expect(m.level, 0);
      expect(m.isSilent, isTrue);
    });

    test('테두리를 계속 돌리면 천천히 차오른다', () {
      final m = RubMeter();
      _circle(m, seconds: 0.5);
      final early = m.level;
      expect(early, greaterThan(0));
      expect(early, lessThan(0.5), reason: '버튼처럼 바로 울리면 안 된다');
      _circle(m, seconds: 2.5);
      expect(m.level, greaterThan(0.9));
    });

    test('천천히 돌리면 작게 울린다', () {
      final m = RubMeter();
      _circle(m, speed: RubMeter.fullSpeed * 0.4, seconds: 4);
      expect(m.level, closeTo(0.4, 0.08));
    });

    test('어느 방향으로 돌려도 된다', () {
      final m = RubMeter();
      _circle(m, speed: -RubMeter.fullSpeed, seconds: 3);
      expect(m.level, greaterThan(0.9));
    });

    test('손을 떼면 천천히 잦아든다', () {
      final m = RubMeter();
      _circle(m, seconds: 3);
      m.lift();
      m.tick(1.0);
      expect(m.level, greaterThan(0.4), reason: '뚝 끊기면 안 된다');
      for (var i = 0; i < 60 * 3; i++) {
        m.tick(1 / 60);
      }
      expect(m.isSilent, isTrue);
    });

    test('돌지 않고 한 방향으로 문지르면 울지 않는다', () {
      final m = RubMeter();
      for (var i = 0; i < 120; i++) {
        m.move(Offset(30.0 + i, 0), 1 / 60); // 가운데에서 바깥으로 곧게
        m.tick(1 / 60);
      }
      expect(m.level, lessThan(0.01));
    });

    test('가운데에 너무 가까운 손가락은 무시한다', () {
      final m = RubMeter();
      _circle(m, r: RubMeter.minRadius - 4, seconds: 2);
      expect(m.level, 0);
    });

    test('손가락 각도와 도는 방향을 알려 준다 — 빛이 손가락을 따라간다', () {
      final m = RubMeter();
      _circle(m, seconds: 0.5);
      expect(m.angle, isNotNull);
      expect(m.direction, 1);
      _circle(m, speed: -RubMeter.fullSpeed, seconds: 0.5);
      expect(m.direction, -1);
      m.lift();
      expect(m.angle, isNull);
    });

    test('-π~π 경계를 넘어도 한 바퀴 튀지 않는다', () {
      final m = RubMeter();
      m.move(Offset.fromDirection(math.pi - 0.01, 80), 1 / 60);
      m.move(Offset.fromDirection(-math.pi + 0.01, 80), 1 / 60);
      m.tick(1 / 60);
      // 0.02 rad 를 1/60초에 = 1.2 rad/s. 한 바퀴(2π)로 착각하면 단번에 1이 된다.
      expect(m.level, lessThan(0.05));
    });
  });

  group('무대 배치 — 그림과 채', () {
    final stage = Offset.zero & kPlayStage;

    for (final (name, rig, body) in [
      (
        '싱잉볼',
        SingingBowlLayout.mallet,
        SingingBowlLayout.bowl.toStage(SingingBowlLayout.bowlBox.topLeft) &
            (SingingBowlLayout.bowlBox.size * SingingBowlLayout.bowl.scale),
      ),
      (
        '목탁',
        MoktakLayout.mallet,
        MoktakLayout.body.toStage(MoktakLayout.bodyBox.topLeft) &
            (MoktakLayout.bodyBox.size * MoktakLayout.body.scale),
      ),
    ]) {
      test('$name 채 — 칠 때 머리 끝이 칠 자리에 정확히 닿는다', () {
        expect((rig.tipAt(1) - rig.target).distance, lessThan(0.001));
      });

      test('$name 채 — 손잡이 끝이 회전축이라 휘둘러도 제자리다', () {
        final p = rig.placement.toStage(rig.grip);
        expect((p - rig.pivot).distance, lessThan(0.001));
      });

      test('$name 채 — 쉴 때는 악기 오른쪽에 떨어져 있고, 치면서 악기 쪽으로 온다', () {
        final rest = rig.tipAt(0), hit = rig.tipAt(1);
        expect(rest.dx, greaterThan(body.right), reason: '쉬는 채가 악기와 겹치면 안 된다');
        expect(hit.dx, lessThan(rest.dx));
      });

      test('$name 채 — 회전축과 머리가 무대 안에 있다', () {
        for (final pt in [rig.pivot, rig.tipAt(0), rig.tipAt(1)]) {
          expect(stage.inflate(1).contains(pt), isTrue, reason: '$pt');
        }
      }, skip: kShowMallets ? false : '채를 숨긴 동안은 확인하지 않는다 (kShowMallets)');

      test('$name — 물체가 무대 안에 다 들어온다', () {
        expect(stage.inflate(0.5).contains(body.topLeft), isTrue);
        expect(stage.inflate(0.5).contains(body.bottomRight), isTrue);
      });
    }

    test('목탁과 싱잉볼은 무대 가운데에 놓인다', () {
      for (final (p, box) in [
        (SingingBowlLayout.bowl, SingingBowlLayout.bowlBox),
        (MoktakLayout.body, MoktakLayout.bodyBox),
      ]) {
        final r = p.toStage(box.topLeft) & (box.size * p.scale);
        expect(r.center.dx, closeTo(kPlayStage.width / 2, 1e-9));
        expect(r.top, greaterThan(0));
        expect(r.bottom, lessThan(kPlayStage.height));
      }
    });

    test('그림은 정사각 캔버스를 같은 배율로 줄인다 — 비율이 그대로다', () {
      for (final p in [
        SingingBowlLayout.bowl,
        MoktakLayout.body,
        SingingBowlLayout.mallet.placement,
        MoktakLayout.mallet.placement,
      ]) {
        expect(p.canvas.width, closeTo(p.canvas.height, 1e-9));
      }
    });

    test('싱잉볼은 물체 폭 200dp — 투명 캔버스가 아니라 그릇 크기로 맞춘다', () {
      final b = SingingBowlLayout.bowl;
      expect(b.length(SingingBowlLayout.bowlBox.width), closeTo(200, 1e-9));
    });

    test('입구 타원은 원본 좌표를 같은 배율로 옮긴 것이다', () {
      final rim = SingingBowlLayout.rim, b = SingingBowlLayout.bowl;
      expect(rim.center, b.toStage(const Offset(628, 472)));
      expect(rim.width / 2, closeTo(414 * b.scale, 1e-9));
      expect(rim.height / 2, closeTo(147 * b.scale, 1e-9));
    });

    test('타원 위의 점은 원으로 펴면 같은 각도, 같은 반지름이다', () {
      final rim = SingingBowlLayout.rim;
      for (var a = -3.0; a <= 3.0; a += 0.5) {
        final pt =
            rim.center +
            Offset(rim.width / 2 * math.cos(a), rim.height / 2 * math.sin(a));
        final c = SingingBowlLayout.toRimCircle(pt);
        expect(c.direction, closeTo(a, 1e-9));
        expect(c.distance, closeTo(rim.width / 2, 1e-9));
      }
    });
  });

  group('치는 시간표', () {
    test('채는 쉼 → 닿음 → 쉼', () {
      expect(StrikeTiming.swingAt(0), 0);
      final impact =
          StrikeTiming.swingDown.inMicroseconds /
          StrikeTiming.total.inMicroseconds;
      expect(StrikeTiming.swingAt(impact), closeTo(1, 1e-9));
      expect(StrikeTiming.swingAt(1), 0);
    });

    test('소리는 닿는 순간 들리도록 파일 시작 지점과 기기 지연만큼 당긴다', () {
      expect(
        StrikeTiming.soundDelay(Duration.zero),
        const Duration(milliseconds: 60),
      );
      expect(
        StrikeTiming.soundDelay(const Duration(milliseconds: 15)),
        const Duration(milliseconds: 45),
      );
      expect(
        StrikeTiming.soundDelay(const Duration(seconds: 1)),
        Duration.zero,
      );
    });
  });

  group('싱잉볼 소리', () {
    test('소리 파일이 앱 번들에 있다', () async {
      for (final a in [
        AudioSingingBowlSound.strikeAsset,
        AudioSingingBowlSound.rubAsset,
      ]) {
        final data = await rootBundle.load('assets/$a');
        expect(data.lengthInBytes, greaterThan(10000), reason: a);
      }
    });

    test('키캡 그림과 소리가 앱 번들에 있다', () async {
      final assets = [
        KeycapBoard.hardwareAsset,
        for (final ring in kKeycapRings)
          for (final key in ring.keys)
            if (key.big == null) key.icon,
        for (final a in [
          ...AudioKeycapSound.pressAssets,
          ...AudioKeycapSound.releaseAssets,
        ])
          'assets/$a',
      ];
      for (final a in assets) {
        final data = await rootBundle.load(a);
        expect(data.lengthInBytes, greaterThan(1000), reason: a);
      }
    });

    test('목탁·싱잉볼 그림이 앱 번들에 있다', () async {
      for (final a in [
        SingingBowlLayout.bowlAsset,
        SingingBowlLayout.malletAsset,
        MoktakLayout.bodyAsset,
        MoktakLayout.malletAsset,
      ]) {
        final data = await rootBundle.load(a);
        expect(data.lengthInBytes, greaterThan(10000), reason: a);
      }
    });

    test('소리 크기 곡선 — 0은 무음, 1은 최대, 사이는 커지기만 한다', () {
      expect(AudioSingingBowlSound.volumeFor(0), 0);
      expect(AudioSingingBowlSound.volumeFor(1), 1);
      var last = 0.0;
      for (var i = 1; i <= 10; i++) {
        final v = AudioSingingBowlSound.volumeFor(i / 10);
        expect(v, greaterThan(last));
        last = v;
      }
    });

    test('소리를 못 내는 환경에서도 치기·문지르기는 멈추지 않는다', () async {
      final sound = AudioSingingBowlSound();
      await sound.warmUp();
      sound.strike();
      sound.rub(0.8);
      sound.rub(0);
      await Future<void>.delayed(Duration.zero);
      await sound.dispose();
    });
  });

  group('악기 고르기', () {
    test('처음엔 목탁', () {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(playInstrumentProvider), PlayInstrument.moktak);
    });

    test('고른 악기를 기억한다', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);
      await c
          .read(playInstrumentProvider.notifier)
          .select(PlayInstrument.singingBowl);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(PlayInstrumentNotifier.key), 'singingBowl');
    });

    test('다음에 열면 기억한 악기로 시작한다', () async {
      SharedPreferences.setMockInitialValues({
        PlayInstrumentNotifier.key: 'singingBowl',
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(playInstrumentProvider);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(playInstrumentProvider), PlayInstrument.singingBowl);
    });

    test('모르는 값이 저장돼 있으면 목탁', () async {
      SharedPreferences.setMockInitialValues({
        PlayInstrumentNotifier.key: 'gong',
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(playInstrumentProvider);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(playInstrumentProvider), PlayInstrument.moktak);
    });
  });

  group('놀이 화면', () {
    late _FakeMoktak moktak;
    late _FakeBowl bowl;
    late _FakeKeycap keys;
    late _FakePlay play;

    Future<void> pumpPlay(
      WidgetTester tester, {
      Map<PlayInstrument, int> beads = const {},
    }) async {
      SharedPreferences.setMockInitialValues({});
      moktak = _FakeMoktak();
      bowl = _FakeBowl();
      keys = _FakeKeycap();
      play = _FakePlay(beads);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            moktakSoundProvider.overrideWithValue(moktak),
            singingBowlSoundProvider.overrideWithValue(bowl),
            keycapSoundProvider.overrideWithValue(keys),
            playRepositoryProvider.overrideWithValue(play),
            homeStateProvider.overrideWith(
              (ref) => Completer<TempleHomeState>().future,
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(body: PlayScreen()),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('처음엔 목탁이고, 두드리면 목탁 소리', (tester) async {
      await pumpPlay(tester);
      expect(find.text(PlayInstrument.moktak.howTo), findsOneWidget);
      await tester.tap(find.text(PlayInstrument.moktak.howTo));
      await tester.pump(const Duration(milliseconds: 500));
      expect(moktak.knocks, 1);
      expect(bowl.strikes, 0);
      expect(play.beads[PlayInstrument.moktak], 1);
    });

    testWidgets('싱잉볼로 바꾸면 치기가 싱잉볼 소리가 된다', (tester) async {
      await pumpPlay(tester);
      await tester.tap(find.text('싱잉볼'));
      await tester.pumpAndSettle();
      expect(find.text(PlayInstrument.singingBowl.howTo), findsOneWidget);

      await tester.tap(find.text(PlayInstrument.singingBowl.howTo));
      await tester.pump(const Duration(milliseconds: 1500));
      expect(bowl.strikes, 1);
      expect(moktak.knocks, 0);
      expect(play.beads[PlayInstrument.singingBowl], 1);
      expect(play.beads[PlayInstrument.moktak], 0, reason: '놀이마다 따로 센다');
    });

    testWidgets('싱잉볼을 치면 채가 휘두르고, 소리는 닿기 직전·파문은 닿는 순간', (tester) async {
      await pumpPlay(tester);
      await tester.tap(find.text('싱잉볼'));
      await tester.pumpAndSettle();

      double malletAngle() => tester
          .widget<Transform>(
            find.descendant(
              of: find.byType(SwingingMallet),
              matching: find.byType(Transform),
            ),
          )
          .transform
          .getRotation()
          .entry(1, 0);
      final rest = malletAngle();

      await tester.tap(find.text(PlayInstrument.singingBowl.howTo));
      await tester.pump(const Duration(milliseconds: 30));
      expect(bowl.strikes, 0, reason: '탭하자마자 소리가 나면 채보다 먼저 울린다');
      await tester.pump(const Duration(milliseconds: 20)); // 50ms
      expect(bowl.strikes, 1);
      await tester.pump(const Duration(milliseconds: 50)); // 100ms — 닿는 순간
      expect(
        malletAngle(),
        isNot(closeTo(rest, 1e-3)),
        reason: '채가 돌아가 있어야 한다',
      );
      await tester.pump(const Duration(seconds: 2));
      expect(malletAngle(), closeTo(rest, 1e-6), reason: '다시 쉬는 자리로');
    }, skip: !kShowMallets); // 채를 숨긴 동안은 확인하지 않는다

    testWidgets('목탁도 채가 휘두르고 닿기 직전에 소리가 난다', (tester) async {
      await pumpPlay(tester);
      expect(find.byType(SwingingMallet), findsOneWidget);
      await tester.tap(find.text(PlayInstrument.moktak.howTo));
      await tester.pump(const Duration(milliseconds: 50));
      expect(moktak.knocks, 0);
      await tester.pump(const Duration(milliseconds: 20)); // 70ms
      expect(moktak.knocks, 1);
      await tester.pump(const Duration(seconds: 1));
    }, skip: !kShowMallets); // 채를 숨긴 동안은 확인하지 않는다

    testWidgets('채를 숨긴 동안은 채가 없고, 탭하는 즉시 소리가 난다', (tester) async {
      await pumpPlay(tester);
      expect(
        find.byType(SwingingMallet),
        kShowMallets ? findsOneWidget : findsNothing,
      );
      await tester.tap(find.text(PlayInstrument.moktak.howTo));
      await tester.pump();
      expect(moktak.knocks, kShowMallets ? 0 : 1);

      await tester.tap(find.text('싱잉볼'));
      await tester.pumpAndSettle();
      expect(
        find.byType(SwingingMallet),
        kShowMallets ? findsOneWidget : findsNothing,
      );
      await tester.tap(find.text(PlayInstrument.singingBowl.howTo));
      await tester.pump();
      expect(bowl.strikes, kShowMallets ? 0 : 1);
      await tester.pump(const Duration(seconds: 2));
    }, skip: kShowMallets); // 채를 보여 줄 때는 위 휘두르기 테스트가 확인한다

    testWidgets('싱잉볼 둘레를 돌리면 울림이 차오르고, 떼면 잦아든다', (tester) async {
      await pumpPlay(tester);
      await tester.tap(find.text('싱잉볼'));
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(_onRim(tester, 0));
      const steps = 180; // 3초
      for (var i = 1; i <= steps; i++) {
        final a = i / 60 * RubMeter.fullSpeed;
        await gesture.moveTo(_onRim(tester, a));
        await tester.pump(const Duration(milliseconds: 16));
      }
      final peak = bowl.levels.reduce(math.max);
      expect(peak, greaterThan(0.8));
      expect(bowl.strikes, 0, reason: '문지르기는 치기가 아니다');

      await gesture.up();
      // 기기처럼 프레임을 나눠 4초를 흘린다. 한 프레임은 0.1초까지만 센다.
      for (var i = 0; i < 80; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(bowl.levels.last, lessThan(0.01));
    });

    Future<void> openKeycaps(WidgetTester tester) async {
      await tester.tap(find.text('키캡'));
      await tester.pumpAndSettle();
      expect(find.text(PlayInstrument.keycap.howTo), findsOneWidget);
    }

    testWidgets('키캡은 닿는 순간 눌리는 소리, 떼는 순간 올라오는 소리', (tester) async {
      await pumpPlay(tester);
      await openKeycaps(tester);
      final key = find.byKey(KeycapBoard.keyFor(0));
      final gesture = await tester.startGesture(tester.getCenter(key));
      await tester.pump();
      expect(keys.presses, 1, reason: '탭 판정을 기다리지 않는다');
      expect(keys.releases, 0);
      expect(play.beads[PlayInstrument.keycap], 1);
      await tester.pump(const Duration(milliseconds: 300));
      expect(keys.releases, 0, reason: '누르고 있는 동안은 올라오지 않는다');
      await gesture.up();
      await tester.pump();
      expect(keys.releases, 1);
      await tester.pumpAndSettle();
      expect(find.text('염주 1 / 108 · 다 돌면 공덕 10'), findsOneWidget);
      expect(moktak.knocks, 0);
    });

    testWidgets('톡 치고 바로 떼도 떼는 소리는 조금 뒤에 난다', (tester) async {
      await pumpPlay(tester);
      await openKeycaps(tester);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(KeycapBoard.keyFor(0))),
      );
      await tester.pump(const Duration(milliseconds: 5));
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 5));
      expect(keys.releases, 0, reason: '두 소리가 뭉치지 않게');
      await tester.pump(const Duration(milliseconds: 100));
      expect(keys.releases, 1);
      await tester.pumpAndSettle();
    });

    testWidgets('두 손가락으로 같은 키를 누르면 둘 다 떼야 올라온다', (tester) async {
      await pumpPlay(tester);
      await openKeycaps(tester);
      final center = tester.getCenter(find.byKey(KeycapBoard.keyFor(0)));
      final a = await tester.startGesture(center, pointer: 1);
      final b = await tester.startGesture(center + const Offset(4, 0), pointer: 2);
      await tester.pump(const Duration(milliseconds: 100));
      expect(keys.presses, 1);
      await a.up();
      await tester.pump(const Duration(milliseconds: 100));
      expect(keys.releases, 0);
      await b.up();
      await tester.pump(const Duration(milliseconds: 100));
      expect(keys.releases, 1);
      await tester.pumpAndSettle();
    });

    testWidgets('키링을 바꾸면 다른 키캡이 나온다', (tester) async {
      await pumpPlay(tester);
      await openKeycaps(tester);
      expect(find.text('해탈'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('키링 ${kKeycapRings[3].name}'));
      await tester.pumpAndSettle();
      expect(find.text('해탈'), findsNothing);
      expect(find.text(kKeycapRings[3].keys.first.label), findsOneWidget);
    });

    testWidgets('두드릴 때마다 염주 한 알, 108알을 채우면 공덕 10', (tester) async {
      await pumpPlay(tester, beads: {PlayInstrument.moktak: 106});
      expect(find.text('염주 106 / 108 · 다 돌면 공덕 10'), findsOneWidget);

      await tester.tap(find.text(PlayInstrument.moktak.howTo));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('염주 107 / 108 · 다 돌면 공덕 10'), findsOneWidget);

      await tester.tap(find.text(PlayInstrument.moktak.howTo));
      await tester.pump(const Duration(milliseconds: 500));
      expect(play.merit, 10);
      expect(find.text('염주 한 바퀴를 돌았다. 공덕 +10'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      expect(find.text('오늘 108알 · 오늘 공덕은 받았다'), findsOneWidget);

      // 그 뒤로도 두드리기는 되고 알도 센다. 공덕만 멈춘다.
      await tester.tap(find.text(PlayInstrument.moktak.howTo));
      await tester.pump(const Duration(milliseconds: 500));
      expect(moktak.knocks, 3);
      expect(play.merit, 10);
      expect(find.text('오늘 109알 · 오늘 공덕은 받았다'), findsOneWidget);
    });

    testWidgets('놀이마다 따로 세고, 다른 놀이의 공덕은 따로 받는다', (tester) async {
      await pumpPlay(
        tester,
        beads: {PlayInstrument.moktak: 200, PlayInstrument.keycap: 107},
      );
      expect(find.text('오늘 200알 · 오늘 공덕은 받았다'), findsOneWidget);
      await openKeycaps(tester);
      expect(find.text('염주 107 / 108 · 다 돌면 공덕 10'), findsOneWidget);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(KeycapBoard.keyFor(1))),
      );
      await tester.pump();
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 200));
      expect(play.merit, 10, reason: '목탁 공덕을 받았어도 키캡은 따로');
      expect(find.text('염주 한 바퀴를 돌았다. 공덕 +10'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('싱잉볼을 울리는 동안에도 염주가 넘어간다', (tester) async {
      await pumpPlay(tester);
      await tester.tap(find.text('싱잉볼'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(PlayInstrument.singingBowl.howTo));
      await tester.pump(const Duration(milliseconds: 1500));
      expect(play.beads[PlayInstrument.singingBowl], 1, reason: '치기는 한 알');

      final gesture = await tester.startGesture(_onRim(tester, 0));
      for (var i = 1; i <= 180; i++) {
        await gesture.moveTo(_onRim(tester, i / 60 * RubMeter.fullSpeed));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      for (var i = 0; i < 80; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      // 3초 동안 1.3초에 한 바퀴 빠르기로 돌렸다 — 두 바퀴.
      expect(
        play.beads[PlayInstrument.singingBowl],
        3,
        reason: '테두리를 한 바퀴 돌 때마다 한 알, 울림만 남은 동안은 세지 않는다',
      );
    });

    testWidgets('하루 공덕을 다 받으면 그렇다고 알려 준다', (tester) async {
      await pumpPlay(
        tester,
        beads: {PlayInstrument.moktak: PrayerBeads.perRound + 3},
      );
      expect(find.text('오늘 111알 · 오늘 공덕은 받았다'), findsOneWidget);
    });

    testWidgets('문지르다가 목탁으로 바꾸면 울림이 멈춘다', (tester) async {
      await pumpPlay(tester);
      await tester.tap(find.text('싱잉볼'));
      await tester.pumpAndSettle();
      final gesture = await tester.startGesture(_onRim(tester, 0));
      for (var i = 1; i <= 60; i++) {
        await gesture.moveTo(_onRim(tester, i / 60 * 5));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.tap(find.text('목탁'));
      await tester.pump();
      expect(bowl.levels.last, 0);
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
