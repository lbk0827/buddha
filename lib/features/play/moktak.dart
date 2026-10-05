import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'play_stage.dart';

/// 목탁 그림과 채를 무대([kPlayStage])에 놓는 값.
///
/// 원본: assets/play/moktak_body.webp, moktak_mallet.webp (1254 캔버스).
/// 기준점은 원본 좌표로 적고 [body] 배율로 무대에 옮긴다.
abstract final class MoktakLayout {
  static const bodyAsset = 'assets/play/moktak_body.webp';
  static const malletAsset = 'assets/play/moktak_mallet.webp';

  /// 원본에서 목탁(손잡이 포함)이 실제로 차지하는 영역.
  static const bodyBox = Rect.fromLTRB(418, 400, 839, 873);

  /// 원본: 둥근 몸통. 가장 넓은 행(y 712)의 폭 332 → 반지름 166.
  static const ballCenterSource = Offset(672, 712);
  static const ballRadiusSource = 166.0;

  /// 원본: 채가 칠 자리 — 몸통 오른쪽 위, 가운데에서 -20° 방향 겉면.
  static final strikeSource =
      ballCenterSource +
      Offset.fromDirection(-20 * math.pi / 180, ballRadiusSource);

  /// 목탁은 높이 190dp. 채가 오른쪽에서 내려오도록 무대 왼쪽에 둔다.
  static final body = SpritePlacement.box(
    bodyBox,
    left: centeredLeft(190 * bodyBox.width / bodyBox.height),
    top: centeredTop(190),
    width: 190 * bodyBox.width / bodyBox.height,
  );

  /// 무대: 둥근 몸통.
  static Offset get ballCenter => body.toStage(ballCenterSource);
  static double get ballRadius => body.length(ballRadiusSource);

  /// 무대: 목탁 바닥 가운데. 두드릴 때 여기를 기준으로 눌린다.
  static Offset get bottom =>
      body.toStage(Offset(ballCenterSource.dx, bodyBox.bottom));

  /// 채. 원본 손잡이 끝 (869, 434), 머리 끝 (425, 864).
  /// 칠 때 130° 방향으로 몸통 오른쪽 위를 치고, 쉴 때는 35° 들려 목탁 오른쪽에 선다.
  static final mallet = MalletRig(
    asset: malletAsset,
    grip: const Offset(869, 434),
    tip: const Offset(425, 864),
    scale: 0.25,
    target: body.toStage(strikeSource),
    hitDegrees: 130,
  );
}

/// 목탁 뒤에 그리는 것 — 바닥 그림자와 퍼지는 파문.
class MoktakUnderPainter extends CustomPainter {
  MoktakUnderPainter({required this.pulse});

  /// 친 뒤 0 → 1.
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final c = MoktakLayout.ballCenter;
    final r = MoktakLayout.ballRadius;

    canvas.drawOval(
      Rect.fromCenter(
        center: MoktakLayout.bottom + const Offset(0, 6),
        width: r * 1.8,
        height: 14,
      ),
      Paint()
        ..color = Tokens.ink.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    if (pulse <= 0 || pulse >= 1) return;
    canvas.drawCircle(
      c,
      r + pulse * r * 0.8,
      Paint()
        ..color = Tokens.saffron.withValues(alpha: (1 - pulse) * 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(MoktakUnderPainter old) => old.pulse != pulse;
}

/// 두드린 순간 목탁이 바닥을 기준으로 살짝 눌렸다 돌아온다. [pulse] 0 → 1.
Matrix4 moktakSquash(double pulse) {
  final k = pulse <= 0 || pulse >= 1 ? 0.0 : math.sin(math.pi * pulse);
  return Matrix4.diagonal3Values(1 + k * 0.03, 1 - k * 0.05, 1);
}
