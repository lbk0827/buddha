import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// 마당. 인정일로 계산된 단계까지의 요소만 그린다 (FR-4.2).
/// [lanternBright]는 당일 반복 세션 효과 (FR-4.3).
class TempleYard extends StatelessWidget {
  const TempleYard({
    super.key,
    required this.stage,
    this.lanternBright = false,
    this.fallenLeaves = false,
    this.height = 200,
  });

  final int stage;
  final bool lanternBright;
  final bool fallenLeaves;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _YardPainter(
          stage: stage,
          lanternBright: lanternBright,
          fallenLeaves: fallenLeaves,
          isDark: isDark,
        ),
        child: Semantics(
          label: _semanticLabel(),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  String _semanticLabel() {
    if (stage == 0) return '아직 빈 마당';
    final names = ['등', '나무', '돌담', '종', '지붕', '일주문'];
    return '마당에 ${names.take(stage).join(', ')}이 있다';
  }
}

class _YardPainter extends CustomPainter {
  _YardPainter({
    required this.stage,
    required this.lanternBright,
    required this.fallenLeaves,
    required this.isDark,
  });

  final int stage;
  final bool lanternBright;
  final bool fallenLeaves;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final groundY = h * 0.82;

    _ground(canvas, w, h, groundY);
    if (stage >= 6) _gate(canvas, w, groundY);
    if (stage >= 5) _roof(canvas, w, groundY);
    if (stage >= 3) _wall(canvas, w, groundY);
    if (stage >= 2) _tree(canvas, w, groundY);
    if (stage >= 4) _bell(canvas, w, groundY);
    if (stage >= 1) _lantern(canvas, w, groundY);
    if (fallenLeaves) _leaves(canvas, w, groundY);
  }

  Color get _line => isDark
      ? Tokens.ivory.withValues(alpha: 0.55)
      : Tokens.temple.withValues(alpha: 0.85);

  Color get _fill => isDark
      ? Tokens.temple.withValues(alpha: 0.45)
      : Tokens.temple.withValues(alpha: 0.12);

  Paint get _stroke => Paint()
    ..color = _line
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round;

  /// 땅은 네모난 띠가 아니라 완만한 둔덕으로 그린다.
  /// 빈 마당(단계 0)일 때도 회색 박스처럼 보이지 않아야 한다.
  void _ground(Canvas canvas, double w, double h, double groundY) {
    final mound = Path()
      ..moveTo(-w * 0.1, h)
      ..lineTo(-w * 0.1, groundY + 6)
      ..quadraticBezierTo(w * 0.5, groundY - 10, w * 1.1, groundY + 6)
      ..lineTo(w * 1.1, h)
      ..close();

    canvas.drawPath(
      mound,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _fill.withValues(alpha: isDark ? 0.4 : 0.22),
            _fill.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, groundY - 10, w, h - groundY + 10)),
    );

    // 지평선은 가장자리로 갈수록 흐려진다.
    final horizon = Paint()
      ..shader = LinearGradient(
        colors: [
          _line.withValues(alpha: 0),
          _line.withValues(alpha: 0.6),
          _line.withValues(alpha: 0),
        ],
        stops: const [0, 0.5, 1],
      ).createShader(Rect.fromLTWH(0, groundY - 2, w, 4))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final line = Path()
      ..moveTo(0, groundY + 5)
      ..quadraticBezierTo(w * 0.5, groundY - 9, w, groundY + 5);
    canvas.drawPath(line, horizon);
  }

  void _lantern(Canvas canvas, double w, double groundY) {
    final cx = w * 0.5;
    final cy = groundY - 34;
    final glowAlpha = lanternBright ? 0.45 : 0.22;

    canvas.drawCircle(
      Offset(cx, cy),
      lanternBright ? 34 : 26,
      Paint()
        ..color = Tokens.saffron.withValues(alpha: glowAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // 기둥
    canvas.drawLine(Offset(cx, cy + 12), Offset(cx, groundY), _stroke);
    // 몸통
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 20, height: 22),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      body,
      Paint()..color = Tokens.saffron.withValues(alpha: lanternBright ? 0.9 : 0.6),
    );
    canvas.drawRRect(body, _stroke);
    // 지붕
    final cap = Path()
      ..moveTo(cx - 16, cy - 11)
      ..lineTo(cx + 16, cy - 11)
      ..lineTo(cx + 10, cy - 18)
      ..lineTo(cx - 10, cy - 18)
      ..close();
    canvas.drawPath(cap, Paint()..color = _line);
  }

  void _tree(Canvas canvas, double w, double groundY) {
    final cx = w * 0.2;
    canvas.drawLine(Offset(cx, groundY), Offset(cx, groundY - 40), _stroke);
    final crown = Paint()..color = _line.withValues(alpha: isDark ? 0.5 : 0.3);
    canvas.drawCircle(Offset(cx, groundY - 52), 20, crown);
    canvas.drawCircle(Offset(cx - 13, groundY - 42), 13, crown);
    canvas.drawCircle(Offset(cx + 13, groundY - 44), 12, crown);
  }

  void _wall(Canvas canvas, double w, double groundY) {
    final y = groundY - 14;
    final rect = Rect.fromLTWH(w * 0.04, y, w * 0.92, 14);
    canvas.drawRect(rect, Paint()..color = _fill);
    canvas.drawRect(rect, _stroke);
    for (var x = w * 0.04; x < w * 0.96; x += 18) {
      canvas.drawLine(Offset(x, y), Offset(x, y + 14),
          _stroke..strokeWidth = 0.8);
    }
  }

  void _bell(Canvas canvas, double w, double groundY) {
    final cx = w * 0.79;
    final top = groundY - 62;
    // 종각 기둥
    canvas.drawLine(Offset(cx - 18, groundY), Offset(cx - 18, top), _stroke);
    canvas.drawLine(Offset(cx + 18, groundY), Offset(cx + 18, top), _stroke);
    canvas.drawLine(Offset(cx - 24, top), Offset(cx + 24, top), _stroke);
    // 종
    final bell = Path()
      ..moveTo(cx - 12, groundY - 22)
      ..quadraticBezierTo(cx - 13, top + 12, cx, top + 10)
      ..quadraticBezierTo(cx + 13, top + 12, cx + 12, groundY - 22)
      ..close();
    canvas.drawPath(bell, Paint()..color = _fill);
    canvas.drawPath(bell, _stroke);
  }

  void _roof(Canvas canvas, double w, double groundY) {
    final cx = w * 0.5;
    final baseY = groundY - 56;
    final roof = Path()
      ..moveTo(cx - 62, baseY)
      ..quadraticBezierTo(cx - 40, baseY - 26, cx, baseY - 30)
      ..quadraticBezierTo(cx + 40, baseY - 26, cx + 62, baseY)
      ..lineTo(cx + 52, baseY)
      ..quadraticBezierTo(cx, baseY - 20, cx - 52, baseY)
      ..close();
    canvas.drawPath(roof, Paint()..color = _line.withValues(alpha: 0.75));
  }

  void _gate(Canvas canvas, double w, double groundY) {
    final cx = w * 0.5;
    final top = groundY - 96;
    canvas.drawLine(Offset(cx - 44, groundY), Offset(cx - 44, top), _stroke);
    canvas.drawLine(Offset(cx + 44, groundY), Offset(cx + 44, top), _stroke);
    final lintel = Path()
      ..moveTo(cx - 58, top)
      ..quadraticBezierTo(cx, top - 14, cx + 58, top)
      ..lineTo(cx + 50, top + 8)
      ..quadraticBezierTo(cx, top - 4, cx - 50, top + 8)
      ..close();
    canvas.drawPath(lintel, Paint()..color = Tokens.seal.withValues(alpha: 0.75));
  }

  /// 미접속 2일 이상 (FR-4.4). 결석 일수는 드러내지 않는다.
  void _leaves(Canvas canvas, double w, double groundY) {
    final rnd = math.Random(7);
    final paint = Paint()..color = Tokens.saffron.withValues(alpha: 0.7);
    for (var i = 0; i < 12; i++) {
      final x = rnd.nextDouble() * w;
      final y = groundY + rnd.nextDouble() * 18;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rnd.nextDouble() * math.pi);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 9, height: 4),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_YardPainter old) =>
      old.stage != stage ||
      old.lanternBright != lanternBright ||
      old.fallenLeaves != fallenLeaves ||
      old.isDark != isDark;
}
