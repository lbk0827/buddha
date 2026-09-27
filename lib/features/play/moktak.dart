import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// 목탁. 두드리면 살짝 눌리고 파문이 퍼진다.
class MoktakPainter extends CustomPainter {
  MoktakPainter({required this.pulse, required this.isDark});

  final double pulse;
  final bool isDark;

  Color get _body => isDark ? const Color(0xFF5A452F) : const Color(0xFF8B5E3C);
  Color get _shade =>
      isDark ? const Color(0xFF43331F) : const Color(0xFF6B4527);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width * 0.30;

    // 퍼지는 파문
    if (pulse > 0 && pulse < 1) {
      canvas.drawCircle(
        center,
        r + pulse * r * 0.8,
        Paint()
          ..color = Tokens.saffron.withValues(alpha: (1 - pulse) * 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    // 바닥 그림자
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + r + 12),
        width: r * 1.9,
        height: 14,
      ),
      Paint()
        ..color = Tokens.ink.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    // 두드리는 순간 눌린다
    canvas.scale(1 + pulse * 0.03, 1 - pulse * 0.05);

    // 손잡이 — 몸통 뒤로 비스듬히
    canvas.save();
    canvas.rotate(-math.pi / 4.4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-r * 0.13, -r * 1.75, r * 0.26, r * 0.85),
        Radius.circular(r * 0.13),
      ),
      Paint()..color = _shade,
    );
    canvas.restore();

    // 몸통
    canvas.drawCircle(Offset.zero, r, Paint()..color = _body);

    // 위쪽 광
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-r * 0.28, -r * 0.42),
        width: r * 0.7,
        height: r * 0.4,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.16)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.12),
    );

    // 울림통 틈 — 아래쪽을 가로지르는 좁은 렌즈.
    // 호를 크게 그리면 웃는 입이 되어 얼굴로 읽힌다.
    final slit = Path()
      ..moveTo(-r * 0.62, r * 0.46)
      ..quadraticBezierTo(0, r * 0.30, r * 0.62, r * 0.46)
      ..quadraticBezierTo(0, r * 0.62, -r * 0.62, r * 0.46)
      ..close();
    canvas.drawPath(slit, Paint()..color = const Color(0xFF2A1C10));

    // 틈 아래로 말려 올라간 아가리
    canvas.drawPath(
      Path()
        ..moveTo(-r * 0.62, r * 0.46)
        ..quadraticBezierTo(-r * 0.78, r * 0.20, -r * 0.60, r * 0.02),
      Paint()
        ..color = _shade
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.09
        ..strokeCap = StrokeCap.round,
    );

    // 나뭇결 한 줄
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, r * 0.05), radius: r * 0.74),
      math.pi * 1.12,
      math.pi * 0.42,
      false,
      Paint()
        ..color = _shade.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.05
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(MoktakPainter old) =>
      old.pulse != pulse || old.isDark != isDark;
}
