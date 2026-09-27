import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'avatar_equip.dart';

enum MonkPose { standing, bowing }

/// 캐릭터 하나를 레이어로 겹쳐 그린다.
/// 지금은 각 레이어를 직접 그리지만, 아이템 아트(PNG)가 나오면
/// [WardrobeItem.assetPath]만 채워 Image로 갈아끼우면 된다.
class MonkFigure extends StatelessWidget {
  const MonkFigure({
    super.key,
    this.equip = kDefaultEquip,
    this.size = 220,
    this.pose = MonkPose.standing,
    this.breathing = false,
  });

  final AvatarEquip equip;
  final double size;
  final MonkPose pose;

  /// 가만히 있을 때 아주 느리게 오르내린다.
  final bool breathing;

  @override
  Widget build(BuildContext context) {
    final figure = SizedBox(
      width: size,
      height: size * 1.25,
      child: CustomPaint(
        painter: _FigurePainter(equip: equip, pose: pose),
      ),
    );

    return Semantics(
      label: pose == MonkPose.bowing ? '절하는 스님' : '서 있는 스님',
      child: breathing ? _Breathe(child: figure) : figure,
    );
  }
}

class _Breathe extends StatefulWidget {
  const _Breathe({required this.child});
  final Widget child;

  @override
  State<_Breathe> createState() => _BreatheState();
}

class _BreatheState extends State<_Breathe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -3 * Curves.easeInOut.transform(_c.value)),
          child: child,
        ),
        child: widget.child,
      );
}

class _FigurePainter extends CustomPainter {
  _FigurePainter({required this.equip, required this.pose});

  final AvatarEquip equip;
  final MonkPose pose;

  static const _skin = Color(0xFFF1C9A0);
  static const _skinShade = Color(0xFFE3B58C);

  Color get _robe => switch (equip.of(AvatarSlot.top)) {
        'robe_saffron' => const Color(0xFFC98A3C),
        'robe_ash' => const Color(0xFF8A8F7A),
        _ => Tokens.temple,
      };

  @override
  void paint(Canvas canvas, Size size) {
    // 200×250 좌표계로 그리고 스케일만 맞춘다.
    final s = size.width / 200;
    canvas.scale(s, s);

    _shadow(canvas);
    if (pose == MonkPose.bowing) {
      _bowingBody(canvas);
    } else {
      _standingBody(canvas);
    }
    if (equip.of(AvatarSlot.accessory) == 'acc_beads') _beads(canvas);
  }

  void _shadow(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(100, 236),
        width: pose == MonkPose.bowing ? 150 : 104,
        height: 16,
      ),
      Paint()
        ..color = Tokens.ink.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
  }

  void _standingBody(Canvas canvas) {
    final robe = Paint()..color = _robe;
    final shade = Paint()..color = _shadeOf(_robe);

    // 목 — 없으면 머리가 떠 보인다.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(90, 116, 20, 34),
        const Radius.circular(8),
      ),
      Paint()..color = _skinShade,
    );

    // 소매 — 몸통보다 먼저 깔아 어깨선에 묻히게 한다.
    canvas.drawPath(
      Path()
        ..moveTo(80, 142)
        ..quadraticBezierTo(66, 162, 74, 190)
        ..quadraticBezierTo(84, 194, 90, 184)
        ..quadraticBezierTo(84, 162, 92, 146)
        ..close(),
      shade,
    );
    canvas.drawPath(
      Path()
        ..moveTo(120, 142)
        ..quadraticBezierTo(134, 162, 126, 190)
        ..quadraticBezierTo(116, 194, 110, 184)
        ..quadraticBezierTo(116, 162, 108, 146)
        ..close(),
      shade,
    );

    // 가사 — 어깨에서 아래로 살짝 퍼지고 밑단은 둥글다.
    final body = Path()
      ..moveTo(78, 226)
      ..lineTo(83, 146)
      ..quadraticBezierTo(100, 136, 117, 146)
      ..lineTo(122, 226)
      ..quadraticBezierTo(100, 232, 78, 226)
      ..close();
    canvas.drawPath(body, robe);

    // 어깨를 가로지르는 가사 띠. 이것만 있어도 스님으로 읽힌다.
    canvas.save();
    canvas.clipPath(body);
    canvas.drawPath(
      Path()
        ..moveTo(83, 150)
        ..lineTo(122, 178)
        ..lineTo(122, 198)
        ..lineTo(80, 166)
        ..close(),
      shade,
    );
    canvas.restore();

    _claspedHands(canvas, const Offset(100, 172));
    _head(canvas, const Offset(100, 90), 40);
  }

  /// 합장한 손. 위로 모은 아몬드 모양이라야 손으로 읽힌다.
  void _claspedHands(Canvas canvas, Offset c) {
    final hands = Path()
      ..moveTo(c.dx, c.dy - 17)
      ..quadraticBezierTo(c.dx + 10, c.dy - 6, c.dx + 8, c.dy + 9)
      ..quadraticBezierTo(c.dx, c.dy + 14, c.dx - 8, c.dy + 9)
      ..quadraticBezierTo(c.dx - 10, c.dy - 6, c.dx, c.dy - 17)
      ..close();
    canvas.drawPath(hands, Paint()..color = _skin);
    canvas.drawLine(
      Offset(c.dx, c.dy - 13),
      Offset(c.dx, c.dy + 10),
      Paint()
        ..color = _skinShade
        ..strokeWidth = 1.6,
    );
  }

  Color _shadeOf(Color base) =>
      Color.lerp(base, Tokens.ink, 0.22) ?? base;

  void _bowingBody(Canvas canvas) {
    final robe = Paint()..color = _robe;

    // 엎드린 등
    final back = Path()
      ..moveTo(58, 230)
      ..quadraticBezierTo(70, 176, 118, 178)
      ..lineTo(150, 186)
      ..quadraticBezierTo(158, 214, 148, 230)
      ..close();
    canvas.drawPath(back, robe);

    // 앞으로 뻗은 팔
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(40, 216, 60, 14),
        const Radius.circular(7),
      ),
      robe,
    );

    _head(canvas, const Offset(78, 196), 30, tilt: -0.25);
  }

  void _head(Canvas canvas, Offset center, double r, {double tilt = 0}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tilt);

    // 귀
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-r + 2, r * 0.18), width: 12, height: 22),
      Paint()..color = _skinShade,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(r - 2, r * 0.18), width: 12, height: 22),
      Paint()..color = _skinShade,
    );

    // 얼굴
    canvas.drawCircle(Offset.zero, r, Paint()..color = _skin);

    // 머리 — 옷장 슬롯
    if (equip.of(AvatarSlot.head) == 'head_nabal') {
      _nabal(canvas, r);
    } else {
      // 민머리 — 정수리에 아주 옅은 광만 준다. 선을 그으면 가발이 된다.
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(-r * 0.22, -r * 0.44),
            width: r * 0.62,
            height: r * 0.34),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    // 백호
    canvas.drawCircle(
        Offset(0, -r * 0.3), r * 0.055, Paint()..color = Tokens.saffron);

    final line = Paint()
      ..color = Tokens.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.085
      ..strokeCap = StrokeCap.round;

    // 반쯤 감은 눈
    for (final dx in [-r * 0.36, r * 0.36]) {
      canvas.drawPath(
        Path()
          ..moveTo(dx - r * 0.19, r * 0.12)
          ..quadraticBezierTo(dx, r * 0.26, dx + r * 0.19, r * 0.12),
        line,
      );
    }
    // 입
    canvas.drawPath(
      Path()
        ..moveTo(-r * 0.22, r * 0.5)
        ..quadraticBezierTo(0, r * 0.66, r * 0.22, r * 0.5),
      line,
    );

    canvas.restore();
  }

  /// 목에 건 단주.
  void _beads(Canvas canvas) {
    final center =
        pose == MonkPose.bowing ? const Offset(96, 196) : const Offset(100, 140);
    final paint = Paint()..color = const Color(0xFF6B4A2F);
    for (var i = 0; i < 12; i++) {
      final a = math.pi * (0.12 + 0.76 * (i / 11));
      canvas.drawCircle(
        center + Offset(26 * math.cos(a), 20 * math.sin(a)),
        3,
        paint,
      );
    }
  }

  /// 나발 — 부처의 곱슬 머리. 소라 모양 점을 줄지어 얹는다.
  void _nabal(Canvas canvas, double r) {
    final dot = Paint()..color = const Color(0xFF241F1B);
    final bump = r * 0.13;
    for (var row = 0; row < 3; row++) {
      final ry = -r * (0.78 - row * 0.24);
      final span = math.sqrt(math.max(0.0, r * r - ry * ry)) * 0.94;
      final count = (span * 2 / (bump * 1.9)).floor();
      for (var i = 0; i <= count; i++) {
        final x = -span + (2 * span) * (count == 0 ? 0.5 : i / count);
        canvas.drawCircle(Offset(x, ry), bump, dot);
      }
    }
    // 육계
    canvas.drawCircle(Offset(0, -r * 1.02), bump * 1.5, dot);
  }

  @override
  bool shouldRepaint(_FigurePainter old) =>
      old.pose != pose || old.equip.encode() != equip.encode();
}
