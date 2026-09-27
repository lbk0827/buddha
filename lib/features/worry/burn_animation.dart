import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// 태우기 (FR-3.3). 종이가 재가 되는 1~2초.
/// 텍스트 자체는 기록에 남는다 — 화면에서만 사라진다.
class BurnAway extends StatefulWidget {
  const BurnAway({super.key, required this.text, required this.onDone});

  final String text;
  final VoidCallback onDone;

  @override
  State<BurnAway> createState() => _BurnAwayState();
}

class _BurnAwayState extends State<BurnAway>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_c.value);
        return Stack(
          alignment: Alignment.center,
          children: [
            // 종이 — 아래에서 위로 타 올라간다.
            ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [
                  (t - 0.08).clamp(0.0, 1.0),
                  t.clamp(0.0, 1.0),
                ],
                colors: const [Colors.transparent, Colors.white],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: Container(
                width: 280,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Tokens.ivory,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Tokens.ink,
                    fontSize: 17,
                    height: 1.6,
                  ),
                ),
              ),
            ),
            // 타는 선과 재.
            IgnorePointer(
              child: CustomPaint(
                size: const Size(300, 220),
                painter: _EmberPainter(progress: t),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmberPainter extends CustomPainter {
  _EmberPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final rnd = math.Random(3);
    final edgeY = size.height * (1 - progress);

    // 타는 가장자리.
    final glow = Paint()
      ..color = Tokens.saffron.withValues(alpha: 0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final path = Path()..moveTo(size.width * 0.1, edgeY);
    for (var x = size.width * 0.1; x <= size.width * 0.9; x += 14) {
      path.lineTo(x, edgeY + rnd.nextDouble() * 8 - 4);
    }
    canvas.drawPath(
      path,
      glow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // 떠오르는 재.
    final ash = Paint()..color = Tokens.ink.withValues(alpha: 0.35);
    for (var i = 0; i < 14; i++) {
      final x = size.width * (0.15 + rnd.nextDouble() * 0.7);
      final drift = math.sin((progress * 6) + i) * 10;
      final y = edgeY - rnd.nextDouble() * 70 * progress;
      canvas.drawCircle(Offset(x + drift, y), 1.6, ash);
    }
  }

  @override
  bool shouldRepaint(_EmberPainter old) => old.progress != progress;
}

/// 태우기 전체 화면. 번뇌를 적었을 때만 거친다.
class BurnOverlay extends StatelessWidget {
  const BurnOverlay({super.key, required this.text, required this.onDone});

  final String text;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: BurnAway(text: text, onDone: onDone)),
      );
}
