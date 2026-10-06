import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A single ticker and canvas for the whole canopy, including hanging papers.
class LanternCanopy extends StatefulWidget {
  const LanternCanopy({super.key, required this.onTap, this.height = 340});
  final VoidCallback onTap;
  final double height;

  @override
  State<LanternCanopy> createState() => _LanternCanopyState();
}

class _LanternCanopyState extends State<LanternCanopy>
    with SingleTickerProviderStateMixin {
  late final AnimationController wind = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      wind.stop();
      wind.value = 0;
    } else if (!wind.isAnimating) {
      wind.repeat();
    }
  }

  @override
  void dispose() {
    wind.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '연등에 달린 소원 보기',
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: RepaintBoundary(
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: CustomPaint(
            painter: _CanopyPainter(
              wind,
              dark: Theme.of(context).brightness == Brightness.dark,
            ),
          ),
        ),
      ),
    ),
  );
}

class _CanopyPainter extends CustomPainter {
  _CanopyPainter(this.wind, {required this.dark}) : super(repaint: wind);
  final Animation<double> wind;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final glow = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      glow,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -.25),
          radius: .85,
          colors: dark
              ? [const Color(0xFF633349), const Color(0x00633349)]
              : [const Color(0x55F5CED9), const Color(0x00F5CED9)],
        ).createShader(glow),
    );

    // Draw the farthest rows first. The vanishing point sits low in the scene.
    for (var row = 6; row >= 0; row--) {
      final depth = row / 6;
      final scale = math.pow(.80, row).toDouble();
      final width = size.width / 4.5 * scale;
      final y =
          size.height * .73 * (1 - scale) / (1 - math.pow(.80, 6)) -
          width * .42;
      for (var column = 0; column < 7; column++) {
        final x = size.width / 2 + (column - 3) * width * 1.13;
        final phase = row * 1.73 + column * .91;
        final time = wind.value * math.pi * 2;
        final sway = math.sin(time + phase) * .024;
        canvas.save();
        canvas.translate(x, y + (column.isEven ? 0 : width * .10));
        canvas.rotate(sway);
        _lantern(canvas, width, (column + row).isEven, depth);
        _paper(canvas, width, time, phase, depth);
        canvas.restore();
      }
    }
    canvas.restore();
  }

  void _lantern(Canvas canvas, double w, bool pink, double depth) {
    final body = Rect.fromLTWH(-w / 2, 0, w, w * .91);
    final rib = pink ? const Color(0xFFB84E7C) : const Color(0xFFA59A70);
    final metal = Paint()..color = const Color(0xFF645846);
    final line = Paint()
      ..color = const Color(0x886C6256)
      ..strokeWidth = math.max(.6, w * .012);
    canvas.drawLine(Offset(0, -w * .32), Offset(0, -w * .015), line);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-w * .17, -w * .018, w * .34, w * .07),
        Radius.circular(w * .025),
      ),
      metal,
    );
    canvas.drawOval(
      body.shift(Offset(w * .035, w * .035)),
      Paint()
        ..color = const Color(0x183A172B)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * .045),
    );
    canvas.drawOval(
      body,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.26, -.18),
          radius: .77,
          colors: pink
              ? [
                  const Color(0xFFFFF0BB),
                  const Color(0xFFFBAFCB),
                  const Color(0xFFE787B0),
                  const Color(0xFFAE4E7A),
                ]
              : [
                  const Color(0xFFFFF4AD),
                  const Color(0xFFFFF9DC),
                  const Color(0xFFE6DEBC),
                  const Color(0xFFAFA38B),
                ],
          stops: const [0, .28, .68, 1],
        ).createShader(body),
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(body));
    // Closely spaced hoops and curved vertical ribs give the paper volume.
    final hoop = Paint()
      ..color = rib.withValues(alpha: .19)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(.45, w * .006);
    for (var i = 1; i < 24; i++) {
      final y = w * .91 * i / 24;
      canvas.drawPath(
        Path()
          ..moveTo(-w * .5, y)
          ..quadraticBezierTo(0, y + w * .045, w * .5, y),
        hoop,
      );
    }
    final seam = Paint()
      ..color = rib.withValues(alpha: .25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(.6, w * .009);
    for (final curve in [-.85, -.55, -.28, 0.0, .28, .55, .85]) {
      canvas.drawPath(
        Path()
          ..moveTo(0, -w * .02)
          ..cubicTo(
            w * curve * .72,
            w * .15,
            w * curve * .72,
            w * .77,
            0,
            w * .94,
          ),
        seam,
      );
    }
    canvas.drawOval(
      Rect.fromLTWH(-w * .34, w * .09, w * .36, w * .60),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: .22),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(body),
    );
    canvas.restore();
    final rim = Rect.fromLTWH(-w * .18, w * .88, w * .36, w * .055);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rim, Radius.circular(w * .018)),
      metal,
    );
    canvas.drawLine(Offset(-w * .13, w * .90), Offset(w * .13, w * .90), line);
    if (depth > 0) {
      canvas.drawOval(
        body,
        Paint()
          ..color = (dark ? const Color(0xFF28201E) : const Color(0xFFF5EFE3))
              .withValues(alpha: depth * .27),
      );
    }
  }

  void _paper(
    Canvas canvas,
    double w,
    double time,
    double phase,
    double depth,
  ) {
    canvas.save();
    // Pivot at the attachment, with a slower swing and a smaller flutter.
    canvas.translate(0, w * .935);
    canvas.rotate(
      math.sin(time + phase) * .085 + math.sin(time * 2 + phase * 1.4) * .025,
    );
    canvas.drawLine(
      Offset.zero,
      Offset(0, w * .12),
      Paint()
        ..color = const Color(0xFF8F7962)
        ..strokeWidth = math.max(.5, w * .008),
    );
    canvas.translate(0, w * .12);
    final pw = w * .19;
    final ph = w * .77;
    final bend = math.sin(time * 2 + phase) * pw * .18;
    canvas.scale(.94 + math.sin(time + phase) * .06, 1);
    final paper = Path()
      ..moveTo(-pw / 2, 0)
      ..lineTo(pw / 2, 0)
      ..cubicTo(
        pw / 2 - bend,
        ph * .35,
        pw / 2 + bend,
        ph * .7,
        pw / 2 + bend,
        ph,
      )
      ..lineTo(-pw / 2 + bend, ph - w * .018)
      ..cubicTo(-pw / 2 + bend, ph * .7, -pw / 2 - bend, ph * .35, -pw / 2, 0)
      ..close();
    canvas.drawPath(
      paper.shift(Offset(w * .022, w * .025)),
      Paint()
        ..color = const Color(0x153E2B24)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * .018),
    );
    canvas.drawPath(
      paper,
      Paint()
        ..shader = LinearGradient(
          colors: const [
            Color(0xFFE3DAC8),
            Color(0xFFFFFEF5),
            Color(0xFFF4ECD9),
          ],
          stops: const [0, .32, 1],
        ).createShader(Rect.fromLTWH(-pw / 2, 0, pw, ph)),
    );
    canvas.drawPath(
      paper,
      Paint()
        ..color = const Color(0x55C8BCA5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .5,
    );
    // Tiny vertical ink marks suggest wishes without inventing legible text.
    final ink = Paint()
      ..color = const Color(0xFF948575).withValues(alpha: .28 - depth * .1)
      ..strokeWidth = math.max(.45, w * .008);
    for (var i = 0; i < 6; i++) {
      final y = ph * .18 + i * ph * .065;
      canvas.drawLine(Offset(-pw * .10, y), Offset(pw * .10, y), ink);
      canvas.drawLine(Offset(0, y - ph * .015), Offset(0, y + ph * .018), ink);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CanopyPainter oldDelegate) => oldDelegate.dark != dark;
}
