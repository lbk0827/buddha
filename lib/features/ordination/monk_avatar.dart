import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// 출가한 모습. 목업의 SVG를 그대로 옮겼다.
/// 셀카 변환은 아직 없어서 기본 얼굴 하나로 간다.
class MonkAvatar extends StatelessWidget {
  const MonkAvatar({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '출가한 모습',
        child: ClipOval(
          child: Container(
            width: size,
            height: size,
            color: Tokens.temple,
            child: CustomPaint(
              painter: _MonkPainter(),
              size: Size(size, size),
            ),
          ),
        ),
      );
}

class _MonkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 목업이 120×120 좌표계로 그려져 있어 그 비율로 맞춘다.
    final s = size.width / 120;
    canvas.scale(s, s);

    // 가사
    final robe = Path()
      ..moveTo(20, 124)
      ..cubicTo(18, 84, 30, 66, 60, 62)
      ..cubicTo(90, 66, 102, 84, 100, 124)
      ..close();
    canvas.drawPath(robe, Paint()..color = const Color(0xFF8A8F7A));

    // 얼굴
    canvas.drawCircle(
        const Offset(60, 50), 30, Paint()..color = const Color(0xFFF1C9A0));

    // 민머리 그늘
    final scalp = Path()
      ..moveTo(32, 44)
      ..cubicTo(34, 24, 86, 24, 88, 44)
      ..cubicTo(80, 36, 40, 36, 32, 44)
      ..close();
    canvas.drawPath(scalp, Paint()..color = const Color(0xFFE3B58C));

    // 백호
    canvas.drawCircle(const Offset(60, 40), 2, Paint()..color = Tokens.saffron);

    final line = Paint()
      ..color = Tokens.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // 반쯤 감은 눈
    canvas.drawPath(
      Path()
        ..moveTo(46, 54)
        ..quadraticBezierTo(52, 58, 58, 54),
      line,
    );
    canvas.drawPath(
      Path()
        ..moveTo(62, 54)
        ..quadraticBezierTo(68, 58, 74, 54),
      line,
    );
    // 입
    canvas.drawPath(
      Path()
        ..moveTo(52, 66)
        ..quadraticBezierTo(60, 71, 68, 66),
      line,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
