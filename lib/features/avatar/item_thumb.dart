import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'avatar_equip.dart';

/// 옷장 칸에 들어가는 아이템 그림.
/// 아이템 아트가 생기면 이 페인터 대신 Image를 쓰면 된다.
class ItemThumbPainter extends CustomPainter {
  ItemThumbPainter({required this.item, required this.dim});

  final WardrobeItem item;
  final bool dim;

  double get _alpha => dim ? 0.3 : 1;

  Paint _fill(Color c) => Paint()..color = c.withValues(alpha: _alpha);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    final r = size.width / 2;

    switch (item.id) {
      case 'head_shaved':
        _scalp(canvas, r);
      case 'head_nabal':
        _nabal(canvas, r);
      case 'head_bamboo':
        _bambooHat(canvas, r);
      case 'head_straw':
        _strawHat(canvas, r);
      case 'acc_beads':
        _beads(canvas, r);
      case 'acc_glasses':
        _glasses(canvas, r);
      case 'seat_lotus':
        _lotus(canvas, r);
      case 'halo_ring':
        _halo(canvas, r);
      default:
        _robe(canvas, r);
    }
  }

  Color get _robeColor => switch (item.id) {
        'robe_saffron' => const Color(0xFFC98A3C),
        'robe_ash' => const Color(0xFF8A8F7A),
        'robe_crimson' => const Color(0xFF9B3B3B),
        _ => Tokens.temple,
      };

  void _robe(Canvas canvas, double r) {
    final body = Path()
      ..moveTo(-r * 0.52, r * 0.78)
      ..lineTo(-r * 0.38, -r * 0.52)
      ..quadraticBezierTo(0, -r * 0.78, r * 0.38, -r * 0.52)
      ..lineTo(r * 0.52, r * 0.78)
      ..quadraticBezierTo(0, r * 0.94, -r * 0.52, r * 0.78)
      ..close();
    canvas.drawPath(body, _fill(_robeColor));
    canvas.save();
    canvas.clipPath(body);
    canvas.drawPath(
      Path()
        ..moveTo(-r * 0.38, -r * 0.44)
        ..lineTo(r * 0.52, r * 0.18)
        ..lineTo(r * 0.52, r * 0.46)
        ..lineTo(-r * 0.42, -r * 0.16)
        ..close(),
      _fill(Color.lerp(_robeColor, Tokens.ink, 0.24)!),
    );
    canvas.restore();
  }

  void _scalp(Canvas canvas, double r) {
    canvas.drawCircle(Offset.zero, r * 0.62, _fill(const Color(0xFFF1C9A0)));
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(-r * 0.16, -r * 0.24),
          width: r * 0.42,
          height: r * 0.22),
      _fill(Colors.white)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  void _nabal(Canvas canvas, double r) {
    canvas.drawCircle(Offset.zero, r * 0.62, _fill(const Color(0xFFF1C9A0)));
    final dot = _fill(const Color(0xFF241F1B));
    final bump = r * 0.09;
    for (var row = 0; row < 3; row++) {
      final ry = -r * (0.48 - row * 0.17);
      final span = math.sqrt(math.max(0.0, 0.62 * 0.62 * r * r - ry * ry)) * 0.92;
      final count = (span * 2 / (bump * 1.9)).floor();
      for (var i = 0; i <= count; i++) {
        final x = -span + (2 * span) * (count == 0 ? 0.5 : i / count);
        canvas.drawCircle(Offset(x, ry), bump, dot);
      }
    }
    canvas.drawCircle(Offset(0, -r * 0.66), bump * 1.5, dot);
  }

  void _bambooHat(Canvas canvas, double r) {
    canvas.drawPath(
      Path()
        ..moveTo(0, -r * 0.72)
        ..quadraticBezierTo(r * 0.62, r * 0.08, r * 0.86, r * 0.26)
        ..quadraticBezierTo(0, r * 0.56, -r * 0.86, r * 0.26)
        ..quadraticBezierTo(-r * 0.62, r * 0.08, 0, -r * 0.72)
        ..close(),
      _fill(const Color(0xFFC8A36A)),
    );
  }

  void _strawHat(Canvas canvas, double r) {
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(0, r * 0.22), width: r * 1.7, height: r * 0.42),
      _fill(const Color(0xFFE3C177)),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-r * 0.46, r * 0.22)
        ..quadraticBezierTo(-r * 0.4, -r * 0.62, 0, -r * 0.64)
        ..quadraticBezierTo(r * 0.4, -r * 0.62, r * 0.46, r * 0.22)
        ..close(),
      _fill(const Color(0xFFD4AE5E)),
    );
  }

  void _beads(Canvas canvas, double r) {
    final paint = _fill(const Color(0xFF6B4A2F));
    for (var i = 0; i < 14; i++) {
      final a = (i / 14) * 2 * math.pi;
      canvas.drawCircle(
        Offset(r * 0.58 * math.cos(a), r * 0.58 * math.sin(a)),
        r * 0.11,
        paint,
      );
    }
  }

  void _glasses(Canvas canvas, double r) {
    final frame = _fill(const Color(0xFF3A342E))
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.1;
    for (final dx in [-r * 0.36, r * 0.36]) {
      canvas.drawCircle(Offset(dx, 0), r * 0.28, frame);
    }
    canvas.drawLine(Offset(-r * 0.08, 0), Offset(r * 0.08, 0), frame);
  }

  void _lotus(Canvas canvas, double r) {
    final back = _fill(const Color(0xFFCE93A4));
    final front = _fill(const Color(0xFFE8B7C4));
    for (var i = -2; i <= 2; i++) {
      final dx = i * r * 0.3;
      canvas.drawPath(
        Path()
          ..moveTo(dx, 0)
          ..quadraticBezierTo(dx - r * 0.22, r * 0.14, dx, r * 0.5)
          ..quadraticBezierTo(dx + r * 0.22, r * 0.14, dx, 0)
          ..close(),
        back,
      );
    }
    for (var i = -1; i <= 1; i++) {
      final dx = i * r * 0.34;
      canvas.drawPath(
        Path()
          ..moveTo(dx, -r * 0.16)
          ..quadraticBezierTo(dx - r * 0.26, r * 0.04, dx, r * 0.4)
          ..quadraticBezierTo(dx + r * 0.26, r * 0.04, dx, -r * 0.16)
          ..close(),
        front,
      );
    }
  }

  void _halo(Canvas canvas, double r) {
    canvas.drawCircle(
      Offset.zero,
      r * 0.7,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Tokens.saffron.withValues(alpha: 0.5 * _alpha),
            Tokens.saffron.withValues(alpha: 0),
          ],
          stops: const [0.7, 1],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r * 0.7)),
    );
    canvas.drawCircle(
      Offset.zero,
      r * 0.64,
      _fill(Tokens.saffron)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.08,
    );
  }

  @override
  bool shouldRepaint(ItemThumbPainter old) =>
      old.item.id != item.id || old.dim != dim;
}
