import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'play_stage.dart';

/// 싱잉볼 테두리를 문지르는 정도.
///
/// 손가락이 그릇 가운데를 중심으로 도는 각속도를 울림의 크기(0~1)로 바꾼다.
/// 진짜 싱잉볼처럼 계속 돌려야 천천히 차오르고, 손을 떼면 천천히 잦아든다.
class RubMeter {
  /// 이만큼 빠르게 돌리면(rad/s) 다 울린다. 1.3초에 한 바퀴쯤.
  static const double fullSpeed = 2 * math.pi / 1.3;

  /// 다 차오르는 데 걸리는 시간(초). 짧으면 버튼처럼 느껴진다.
  static const double attack = 1.6;

  /// 손을 뗀 뒤 잦아드는 시간(초).
  static const double release = 2.8;

  /// 손가락이 가운데에 너무 가까우면 각도가 튄다. 그보다 안쪽은 무시한다.
  static const double minRadius = 24;

  double _level = 0;
  double _target = 0;
  double? _lastAngle;
  int _direction = 1;

  /// 아직 바퀴로 세지 않은, 손가락이 테두리를 따라 돈 각도(라디안).
  double _turned = 0;

  /// 지금 울림. 0이면 소리 없음.
  double get level => _level;

  /// 손가락이 있는 각도(라디안, 화면 좌표라 시계 방향 +). 손을 떼면 null.
  double? get angle => _lastAngle;

  /// 마지막으로 돌린 방향. 1 = 시계, -1 = 반시계.
  int get direction => _direction;

  bool get isSilent => _level < 0.002 && _target == 0;

  /// 손가락이 [offset](그릇 가운데 기준)에 있다. [dt]초 만에 여기로 왔다.
  void move(Offset offset, double dt) {
    if (offset.distance < minRadius || dt <= 0) {
      _lastAngle = null;
      return;
    }
    final angle = math.atan2(offset.dy, offset.dx);
    final last = _lastAngle;
    _lastAngle = angle;
    if (last == null) return;
    var delta = angle - last;
    // -π~π 경계를 넘으면 한 바퀴를 보정한다. 어느 방향으로 돌려도 된다.
    if (delta > math.pi) delta -= 2 * math.pi;
    if (delta < -math.pi) delta += 2 * math.pi;
    if (delta != 0) _direction = delta > 0 ? 1 : -1;
    _turned += delta.abs();
    _target = (delta.abs() / dt / fullSpeed).clamp(0.0, 1.0);
  }

  /// 지난번 이후 테두리를 다 돈 바퀴 수. 센 만큼 덜어 낸다.
  ///
  /// 문지르기는 시간이 아니라 돈 바퀴로 센다. 손을 멈추고 울림만 남아 있는
  /// 동안에는 늘지 않는다. 방향을 바꿔도 돈 만큼 다 센다.
  int takeTurns() {
    final turns = _turned ~/ (2 * math.pi);
    _turned -= turns * 2 * math.pi;
    return turns;
  }

  /// 손가락을 뗐다.
  void lift() {
    _lastAngle = null;
    _target = 0;
  }

  /// 시간이 [dt]초 흘렀다. 울림이 목표 쪽으로 천천히 따라간다.
  void tick(double dt) {
    final span = _target > _level ? attack : release;
    final step = dt / span;
    if (_target > _level) {
      _level = math.min(_target, _level + step);
    } else {
      _level = math.max(_target, _level - step);
    }
    // 움직이지 않고 손가락만 대고 있으면 목표도 서서히 내려간다.
    _target = math.max(0, _target - dt / release);
  }
}

/// 싱잉볼 그림과 채를 무대([kPlayStage])에 놓는 값.
///
/// 원본: assets/play/singing_bowl.webp, singing_bowl_mallet.webp (1254 캔버스).
/// 기준점은 원본 좌표로 적고 [bowl] 배율로 무대에 옮긴다.
abstract final class SingingBowlLayout {
  static const bowlAsset = 'assets/play/singing_bowl.webp';
  static const malletAsset = 'assets/play/singing_bowl_mallet.webp';

  /// 원본에서 그릇이 실제로 차지하는 영역.
  static const bowlBox = Rect.fromLTRB(186, 324, 1070, 952);

  /// 원본: 입구 타원. 가운데 (628, 472), 가로 반지름 414, 세로 반지름 147.
  static const rimCenterSource = Offset(628, 472);
  static const rimRadiiSource = Size(414, 147);

  /// 원본: 채가 칠 자리 — 오른쪽 바깥 벽, 테두리 바로 아래.
  /// 그릇은 y 600 근처에서 가장 불룩하다(x 1068).
  static const strikeSource = Offset(1062, 560);

  /// 그릇은 폭 200dp. 채가 오른쪽에서 내려오도록 무대 왼쪽에 둔다.
  static final bowl = SpritePlacement.box(
    bowlBox,
    left: centeredLeft(200),
    top: centeredTop(200 * bowlBox.height / bowlBox.width),
    width: 200,
  );

  /// 무대: 입구 타원.
  static Rect get rim => Rect.fromCenter(
    center: bowl.toStage(rimCenterSource),
    width: bowl.length(rimRadiiSource.width) * 2,
    height: bowl.length(rimRadiiSource.height) * 2,
  );

  /// 무대: 그릇 바닥 가운데.
  static Offset get bottom =>
      bowl.toStage(Offset(bowlBox.center.dx, bowlBox.bottom));

  /// 채. 원본 손잡이 끝 (942, 404), 가죽 끝 (386, 880).
  /// 칠 때 120° 방향으로 테두리 아래 벽을 치고, 쉴 때는 35° 들려 그릇 오른쪽에 선다.
  static final mallet = MalletRig(
    asset: malletAsset,
    grip: const Offset(942, 404),
    tip: const Offset(386, 880),
    scale: 0.17,
    target: bowl.toStage(strikeSource),
    hitDegrees: 120,
  );

  /// 무대 위 한 점을 입구 타원 위의 각도로. 타원을 원으로 펴서 잰다.
  /// 반환값의 길이는 가로 반지름 단위(dp)라 [RubMeter.minRadius]와 견줄 수 있다.
  static Offset toRimCircle(Offset stagePoint) {
    final r = rim;
    final d = stagePoint - r.center;
    return Offset(d.dx, d.dy * r.width / r.height);
  }
}

/// 그릇 뒤에 그리는 것 — 바닥 그림자와 퍼지는 파문.
/// 파문은 입구 타원에서 시작해 바깥으로 퍼진다. 그릇 안쪽은 그릇 그림에 가린다.
class SingingBowlUnderPainter extends CustomPainter {
  SingingBowlUnderPainter({required this.pulse});

  /// 친 뒤 0 → 1.
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final rim = SingingBowlLayout.rim;
    final bottom = SingingBowlLayout.bottom;

    canvas.drawOval(
      Rect.fromCenter(
        center: bottom + const Offset(0, 4),
        width: rim.width * 0.78,
        height: 14,
      ),
      Paint()
        ..color = Tokens.ink.withValues(alpha: 0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    if (pulse <= 0 || pulse >= 1) return;
    for (final lag in const [0.0, 0.18]) {
      final p = (pulse - lag).clamp(0.0, 1.0);
      if (p <= 0) continue;
      canvas.drawOval(
        Rect.fromCenter(
          center: rim.center,
          width: rim.width * (1 + p * 0.7),
          height: rim.height * (1 + p * 0.7),
        ),
        Paint()
          ..color = Tokens.saffron.withValues(alpha: (1 - p) * 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(SingingBowlUnderPainter old) => old.pulse != pulse;
}

/// 문지를 때 입구 테두리를 따라 도는 빛. 그릇 그림 위에 그린다.
///
/// 그릇의 금속 광을 덮지 않도록 흐린 외곽광을 screen 으로 더한다.
/// 손가락이 있는 자리는 더 밝고, 지나온 쪽으로 꼬리가 남는다.
class RimGlowPainter extends CustomPainter {
  RimGlowPainter({required this.level, this.angle, this.direction = 1});

  /// 울림 0~1.
  final double level;

  /// 손가락이 있는 입구 타원 위 각도. 손을 떼면 null — 테두리 전체만 은은히.
  final double? angle;

  /// 1 = 시계, -1 = 반시계. 꼬리는 반대쪽으로 남는다.
  final int direction;

  static const _light = Color(0xFFFFD98A);

  @override
  void paint(Canvas canvas, Size size) {
    if (level <= 0.01) return;
    final rim = SingingBowlLayout.rim;

    // 바깥으로 번지는 따뜻한 외곽광. 밝은 배경에서는 screen 빛만으로는 안 보인다.
    canvas.drawOval(
      rim.inflate(2),
      Paint()
        ..color = Tokens.saffron.withValues(alpha: 0.38 * level)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6 + 6 * level
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + 8 * level),
    );

    canvas.drawOval(
      rim,
      Paint()
        ..color = _light.withValues(alpha: 0.5 * level)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 + 5 * level
        ..blendMode = BlendMode.screen
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + 6 * level),
    );

    final a = angle;
    if (a == null) return;
    canvas.drawArc(
      rim,
      a,
      -direction * 1.1,
      false,
      Paint()
        ..color = _light.withValues(alpha: 0.85 * level)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 + 3 * level
        ..strokeCap = StrokeCap.round
        ..blendMode = BlendMode.screen
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 + 3 * level),
    );
  }

  @override
  bool shouldRepaint(RimGlowPainter old) =>
      old.level != level || old.angle != angle || old.direction != direction;
}
