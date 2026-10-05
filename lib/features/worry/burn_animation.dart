import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// 연등에 매단 쪽지를 태운다. 원문은 기록에 남고 화면에서만 사라진다.
class BurnAway extends StatefulWidget {
  const BurnAway({super.key, required this.text, required this.onDone});

  final String text;
  final VoidCallback onDone;

  @override
  State<BurnAway> createState() => _BurnAwayState();
}

class _BurnAwayState extends State<BurnAway>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_onStatus);
    _controller.forward();
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) widget.onDone();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: '번뇌를 적은 쪽지가 연등 아래에서 타오릅니다',
    child: ExcludeSemantics(
      child: SizedBox(
        width: 340,
        height: 440,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _LanternPainter(
              progress: _controller.value,
              text: widget.text,
              textDirection: Directionality.of(context),
              textStyle: Theme.of(context).textTheme.bodyMedium!,
            ),
          ),
        ),
      ),
    ),
  );
}

class _LanternPainter extends CustomPainter {
  const _LanternPainter({
    required this.progress,
    required this.text,
    required this.textDirection,
    required this.textStyle,
  });

  final double progress;
  final String text;
  final TextDirection textDirection;
  final TextStyle textStyle;

  double get burn => ((progress - 0.25) / 0.58).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 340, size.height / 440);
    canvas.save();
    canvas.translate(
      (size.width - 340 * scale) / 2,
      (size.height - 440 * scale) / 2,
    );
    canvas.scale(scale);
    final sway = math.sin(progress * math.pi * 3) * 0.025;
    canvas.translate(170, 38);
    canvas.rotate(sway);
    canvas.translate(-170, -38);

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          Tokens.saffron.withValues(alpha: 0.22 + burn * 0.12),
          Tokens.saffron.withValues(alpha: 0),
        ],
      ).createShader(const Rect.fromLTWH(40, 10, 260, 260));
    canvas.drawCircle(const Offset(170, 140), 130, glow);
    canvas.drawLine(
      const Offset(170, 0),
      const Offset(170, 76),
      Paint()
        ..color = const Color(0xFFB89661)
        ..strokeWidth = 1.5,
    );

    // 겹겹의 연꽃잎과 중앙의 따뜻한 불빛.
    for (final side in [-1.0, 1.0]) {
      final petal = Path()
        ..moveTo(170, 196)
        ..cubicTo(
          170 + side * 105,
          190,
          170 + side * 116,
          124,
          170 + side * 91,
          90,
        )
        ..cubicTo(170 + side * 35, 108, 170 + side * 19, 148, 170, 196);
      canvas.drawPath(
        petal,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFED9B94), Color(0xFFA93E52)],
          ).createShader(const Rect.fromLTWH(60, 90, 220, 110)),
      );
    }
    for (final side in [-1.0, 1.0]) {
      final petal = Path()
        ..moveTo(170, 197)
        ..cubicTo(
          170 + side * 72,
          177,
          170 + side * 73,
          102,
          170 + side * 44,
          70,
        )
        ..cubicTo(170 + side * 3, 107, 170 - side * 10, 166, 170, 197);
      canvas.drawPath(petal, Paint()..color = const Color(0xFFDC7580));
    }
    final center = Path()
      ..moveTo(170, 62)
      ..cubicTo(113, 120, 130, 177, 170, 199)
      ..cubicTo(210, 177, 227, 120, 170, 62);
    canvas.drawPath(
      center,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFCEAC), Color(0xFFFFE9B0), Color(0xFFD96D73)],
        ).createShader(const Rect.fromLTWH(130, 62, 80, 137)),
    );
    canvas.drawOval(
      const Rect.fromLTWH(143, 190, 54, 12),
      Paint()..color = const Color(0xFF65806A),
    );

    if (burn < 1) {
      canvas.drawLine(
        const Offset(170, 200),
        const Offset(170, 232),
        Paint()
          ..color = const Color(0xFFB89661)
          ..strokeWidth = 1.5,
      );
      const paper = Rect.fromLTWH(78, 232, 184, 140);
      final edge = paper.bottom - paper.height * burn;
      // 같은 경계를 종이, 글씨, 불꽃에 사용해 실제로 타 들어가게 한다.
      final boundary = Path()
        ..moveTo(paper.left, paper.top)
        ..lineTo(paper.right, paper.top);
      for (double x = paper.right; x >= paper.left; x -= 2) {
        boundary.lineTo(
          x,
          edge + (burn > 0 ? math.sin(x * 0.18 + progress * 28) * 3 : 0),
        );
      }
      boundary.close();
      canvas.save();
      canvas.clipPath(boundary);
      canvas.drawRRect(
        RRect.fromRectAndRadius(paper, const Radius.circular(3)),
        Paint()..color = const Color(0xFFF8EACD),
      );
      canvas.drawLine(
        const Offset(91, 242),
        const Offset(91, 361),
        Paint()..color = Tokens.seal.withValues(alpha: 0.25),
      );
      final writing = TextPainter(
        text: TextSpan(
          text: text,
          style: textStyle.copyWith(
            color: Tokens.ink,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        textDirection: textDirection,
        textAlign: TextAlign.center,
        maxLines: 5,
        ellipsis: '…',
      )..layout(maxWidth: 148);
      writing.paint(
        canvas,
        Offset(96, 249 + math.max(0, (104 - writing.height) / 2)),
      );
      canvas.restore();

      if (burn > 0) {
        final fire = Paint()
          ..color = const Color(0xFFFFA331)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawLine(
          Offset(80, edge),
          Offset(260, edge),
          fire..strokeWidth = 7,
        );
        for (var i = 0; i < 16; i++) {
          final x = 81 + i * 11.7;
          final h = 9 + (math.sin(i * 2.7 + progress * 85) + 1) * 10;
          final flame = Path()
            ..moveTo(x - 5, edge + 2)
            ..quadraticBezierTo(x - 7, edge - h * 0.4, x + 2, edge - h)
            ..quadraticBezierTo(x + 7, edge - h * 0.3, x + 5, edge + 2)
            ..close();
          canvas.drawPath(flame, Paint()..color = const Color(0xFFFFC15C));
        }
      }
    }

    // 고정된 궤적으로 재가 프레임마다 튀지 않고 흩어진다.
    final random = math.Random(19);
    final fade = ((1 - progress) / 0.17).clamp(0.0, 1.0);
    if (burn > 0) {
      for (var i = 0; i < 30; i++) {
        final startX = 80 + random.nextDouble() * 180;
        final speed = 50 + random.nextDouble() * 90;
        final phase = (burn * 2 + i / 30) % 1;
        final y = 372 - 140 * burn - phase * speed;
        final x = startX + math.sin(phase * 5 + i) * 15;
        canvas.drawCircle(
          Offset(x, y),
          1 + random.nextDouble(),
          Paint()
            ..color = (i.isEven ? Tokens.saffron : const Color(0xFF9A8976))
                .withValues(alpha: (1 - phase) * fade * 0.7),
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LanternPainter old) =>
      old.progress != progress ||
      old.text != text ||
      old.textStyle != textStyle ||
      old.textDirection != textDirection;
}

class BurnOverlay extends StatelessWidget {
  const BurnOverlay({super.key, required this.text, required this.onDone});

  final String text;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '연등에 번뇌를 내려놓습니다',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Center(
                child: BurnAway(text: text, onDone: onDone),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '쪽지는 재가 되고, 마음에는 빛이 남기를.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    ),
  );
}
