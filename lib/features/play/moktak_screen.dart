import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';

/// 목탁. 백탭은 OS가 내주지 않아 앱 안에서 두드린다.
/// 세는 것 말고는 아무 일도 일어나지 않는다 — 그게 전부다.
class MoktakScreen extends StatefulWidget {
  const MoktakScreen({super.key});

  @override
  State<MoktakScreen> createState() => _MoktakScreenState();
}

class _MoktakScreenState extends State<MoktakScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  int _count = 0;

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  void _tap() {
    HapticFeedback.mediumImpact();
    setState(() => _count++);
    _ring.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('목탁')),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _tap,
          child: Column(
            children: [
              const Spacer(),
              Text(
                '$_count',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 72,
                      height: 1,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _count == 0 ? '아무 데나 두드려라' : '두드린 횟수',
                style: TextStyle(
                    fontSize: 13, color: fg.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _ring,
                builder: (context, _) => SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(
                    painter: _MoktakPainter(
                      pulse: _ring.value,
                      isDark: Theme.of(context).brightness == Brightness.dark,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    Tokens.gutter, 0, Tokens.gutter, Tokens.gutter),
                child: Text(
                  '세는 것 말고는 아무 일도 안 일어난다.\n그게 전부다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: fg.withValues(alpha: 0.45)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoktakPainter extends CustomPainter {
  _MoktakPainter({required this.pulse, required this.isDark});

  final double pulse;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    // 두드릴 때 퍼지는 파문
    if (pulse > 0 && pulse < 1) {
      canvas.drawCircle(
        center,
        70 + pulse * 40,
        Paint()
          ..color = Tokens.saffron.withValues(alpha: (1 - pulse) * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    final squash = 1 - pulse * 0.06;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1, squash);

    final body = Paint()
      ..color = isDark ? const Color(0xFF4A3B2A) : const Color(0xFF8B5E3C);
    canvas.drawCircle(Offset.zero, 62, body);
    // 목탁의 입
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, 14), radius: 44),
      0.35,
      2.44,
      false,
      Paint()
        ..color = Tokens.ink.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
    // 손잡이
    canvas.save();
    canvas.rotate(-math.pi / 5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8, -92, 16, 40),
        const Radius.circular(8),
      ),
      body,
    );
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MoktakPainter old) =>
      old.pulse != pulse || old.isDark != isDark;
}
