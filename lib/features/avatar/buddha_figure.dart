import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'avatar_equip.dart';

enum BuddhaPose { standing, bowing }

/// 내 부처님. 슬롯 순서대로 레이어를 겹쳐 그린다.
/// 아이템 아트(PNG)가 나오면 [WardrobeItem.assetPath]만 채우면 된다.
class BuddhaFigure extends StatelessWidget {
  const BuddhaFigure({
    super.key,
    this.equip = kDefaultEquip,
    this.size = 220,
    this.pose = BuddhaPose.standing,
    this.breathing = false,
  });

  final AvatarEquip equip;
  final double size;
  final BuddhaPose pose;

  /// 가만히 있을 때 아주 느리게 오르내린다.
  final bool breathing;

  @override
  Widget build(BuildContext context) {
    final figure = SizedBox(
      width: size,
      height: size * 1.25,
      child: CustomPaint(painter: _FigurePainter(equip: equip, pose: pose)),
    );

    return Semantics(
      label: pose == BuddhaPose.bowing ? '절하는 부처님' : '내 부처님',
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
  final BuddhaPose pose;

  static const _skin = Color(0xFFF1C9A0);
  static const _skinShade = Color(0xFFE3B58C);

  Color get _robe => switch (equip.of(AvatarSlot.robe)) {
        'robe_saffron' => const Color(0xFFC98A3C),
        'robe_ash' => const Color(0xFF8A8F7A),
        'robe_crimson' => const Color(0xFF9B3B3B),
        _ => Tokens.temple,
      };

  Color get _robeShade => Color.lerp(_robe, Tokens.ink, 0.22) ?? _robe;

  @override
  void paint(Canvas canvas, Size size) {
    // 200×250 좌표계로 그리고 스케일만 맞춘다.
    canvas.scale(size.width / 200);

    if (equip.of(AvatarSlot.halo) == 'halo_ring') _halo(canvas);
    _groundShadow(canvas);
    if (equip.of(AvatarSlot.seat) == 'seat_lotus') _lotusSeat(canvas);

    if (pose == BuddhaPose.bowing) {
      _bowingBody(canvas);
    } else {
      _standingBody(canvas);
    }

    if (equip.of(AvatarSlot.accessory) == 'acc_beads') _beads(canvas);
  }

  Offset get _headCenter =>
      pose == BuddhaPose.bowing ? const Offset(78, 196) : const Offset(100, 90);
  double get _headRadius => pose == BuddhaPose.bowing ? 30 : 40;

  void _halo(Canvas canvas) {
    final c = _headCenter;
    final r = _headRadius * 1.6;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Tokens.saffron.withValues(alpha: 0.55),
            Tokens.saffron.withValues(alpha: 0.0),
          ],
          stops: const [0.72, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c,
      r * 0.92,
      Paint()
        ..color = Tokens.saffron.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }

  void _groundShadow(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(100, 236),
        width: pose == BuddhaPose.bowing ? 150 : 104,
        height: 16,
      ),
      Paint()
        ..color = Tokens.ink.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
  }

  /// 연꽃 대좌 — 발 아래 꽃잎을 두 겹으로 편다.
  void _lotusSeat(Canvas canvas) {
    const cy = 226.0;
    final petal = Paint()..color = const Color(0xFFE8B7C4);
    final petalBack = Paint()..color = const Color(0xFFCE93A4);

    for (var i = -3; i <= 3; i++) {
      final dx = i * 17.0;
      canvas.drawPath(
        Path()
          ..moveTo(100 + dx, cy)
          ..quadraticBezierTo(100 + dx - 13, cy + 4, 100 + dx, cy + 17)
          ..quadraticBezierTo(100 + dx + 13, cy + 4, 100 + dx, cy)
          ..close(),
        petalBack,
      );
    }
    for (var i = -2; i <= 2; i++) {
      final dx = i * 19.0;
      canvas.drawPath(
        Path()
          ..moveTo(100 + dx, cy - 6)
          ..quadraticBezierTo(100 + dx - 15, cy + 2, 100 + dx, cy + 14)
          ..quadraticBezierTo(100 + dx + 15, cy + 2, 100 + dx, cy - 6)
          ..close(),
        petal,
      );
    }
  }

  void _standingBody(Canvas canvas) {
    final robe = Paint()..color = _robe;
    final shade = Paint()..color = _robeShade;

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

    // 가사
    final body = Path()
      ..moveTo(78, 226)
      ..lineTo(83, 146)
      ..quadraticBezierTo(100, 136, 117, 146)
      ..lineTo(122, 226)
      ..quadraticBezierTo(100, 232, 78, 226)
      ..close();
    canvas.drawPath(body, robe);

    // 어깨를 가로지르는 띠. 이것만 있어도 승복으로 읽힌다.
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
    _head(canvas, _headCenter, _headRadius);
  }

  void _bowingBody(Canvas canvas) {
    final robe = Paint()..color = _robe;

    final back = Path()
      ..moveTo(58, 230)
      ..quadraticBezierTo(70, 176, 118, 178)
      ..lineTo(150, 186)
      ..quadraticBezierTo(158, 214, 148, 230)
      ..close();
    canvas.drawPath(back, robe);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(40, 216, 60, 14),
        const Radius.circular(7),
      ),
      robe,
    );

    _head(canvas, _headCenter, _headRadius, tilt: -0.25);
  }

  /// 합장한 손. 위로 모은 아몬드 모양이라야 손으로 읽힌다.
  void _claspedHands(Canvas canvas, Offset c) {
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - 17)
        ..quadraticBezierTo(c.dx + 10, c.dy - 6, c.dx + 8, c.dy + 9)
        ..quadraticBezierTo(c.dx, c.dy + 14, c.dx - 8, c.dy + 9)
        ..quadraticBezierTo(c.dx - 10, c.dy - 6, c.dx, c.dy - 17)
        ..close(),
      Paint()..color = _skin,
    );
    canvas.drawLine(
      Offset(c.dx, c.dy - 13),
      Offset(c.dx, c.dy + 10),
      Paint()
        ..color = _skinShade
        ..strokeWidth = 1.6,
    );
  }

  void _head(Canvas canvas, Offset center, double r, {double tilt = 0}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tilt);

    // 귀
    for (final dx in [-r + 2, r - 2]) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(dx, r * 0.18), width: 12, height: 22),
        Paint()..color = _skinShade,
      );
    }

    canvas.drawCircle(Offset.zero, r, Paint()..color = _skin);

    final head = equip.of(AvatarSlot.head);
    if (head == 'head_nabal') {
      _nabal(canvas, r);
    } else {
      // 민머리 — 정수리에 옅은 광만. 선을 그으면 가발이 된다.
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

    if (equip.of(AvatarSlot.accessory) == 'acc_glasses') _glasses(canvas, r);
    if (head == 'head_bamboo') _bambooHat(canvas, r);
    if (head == 'head_straw') _strawHat(canvas, r);

    canvas.restore();
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

  void _glasses(Canvas canvas, double r) {
    final frame = Paint()
      ..color = const Color(0xFF3A342E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.06;
    for (final dx in [-r * 0.36, r * 0.36]) {
      canvas.drawCircle(Offset(dx, r * 0.16), r * 0.26, frame);
    }
    canvas.drawLine(
        Offset(-r * 0.10, r * 0.16), Offset(r * 0.10, r * 0.16), frame);
  }

  /// 삿갓 — 넓은 원뿔.
  void _bambooHat(Canvas canvas, double r) {
    final brimY = -r * 0.34;
    canvas.drawPath(
      Path()
        ..moveTo(0, -r * 1.42)
        ..quadraticBezierTo(r * 1.05, brimY - r * 0.16, r * 1.30, brimY)
        ..quadraticBezierTo(0, brimY + r * 0.30, -r * 1.30, brimY)
        ..quadraticBezierTo(-r * 1.05, brimY - r * 0.16, 0, -r * 1.42)
        ..close(),
      Paint()..color = const Color(0xFFC8A36A),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, -r * 1.42)
        ..quadraticBezierTo(r * 0.5, -r * 0.9, r * 0.28, brimY + r * 0.12),
      Paint()
        ..color = const Color(0xFF9C7A45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.05,
    );
  }

  /// 밀짚모자 — 낮은 크라운에 챙.
  void _strawHat(Canvas canvas, double r) {
    final brimY = -r * 0.38;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(0, brimY), width: r * 2.7, height: r * 0.56),
      Paint()..color = const Color(0xFFE3C177),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-r * 0.72, brimY)
        ..quadraticBezierTo(-r * 0.62, -r * 1.16, 0, -r * 1.18)
        ..quadraticBezierTo(r * 0.62, -r * 1.16, r * 0.72, brimY)
        ..close(),
      Paint()..color = const Color(0xFFD4AE5E),
    );
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(0, brimY - r * 0.16), width: r * 1.4, height: r * 0.16),
      Paint()..color = Tokens.seal.withValues(alpha: 0.8),
    );
  }

  /// 목에 건 단주.
  void _beads(Canvas canvas) {
    final center = pose == BuddhaPose.bowing
        ? const Offset(96, 196)
        : const Offset(100, 140);
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

  @override
  bool shouldRepaint(_FigurePainter old) =>
      old.pose != pose || old.equip != equip;
}
