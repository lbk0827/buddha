import 'package:flutter/widgets.dart';

/// 도는 후광의 축 — 후광 링 중심, 감은 두 눈의 가운데(1024 좌표 510, 356).
/// 동자 부처의 head 앵커와 같다(test/avatar_anchor_test.dart).
/// 레이어 사각형은 그대로 두고 그 안에서 이 점을 축으로 돌리기만 한다.
const Alignment kHaloCenter = Alignment(510 / 512 - 1, 356 / 512 - 1);

/// 후광 레이어 하나를 [kHaloCenter]를 축으로 [period]마다 한 바퀴 돌린다.
class HaloSpin extends StatefulWidget {
  const HaloSpin({super.key, required this.period, required this.child});

  final Duration period;
  final Widget child;

  @override
  State<HaloSpin> createState() => _HaloSpinState();
}

class _HaloSpinState extends State<HaloSpin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turns = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat();

  @override
  void didUpdateWidget(HaloSpin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _turns
        ..duration = widget.period
        ..repeat();
    }
  }

  @override
  void dispose() {
    _turns.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
    turns: _turns,
    alignment: kHaloCenter,
    child: widget.child,
  );
}
