import 'package:flutter/widgets.dart';

/// 도는 후광의 축 — 후광 링 중심, 감은 두 눈의 가운데(1024 좌표 510, 356).
/// 동자 부처의 head 앵커와 같다(test/avatar_anchor_test.dart).
/// 레이어 사각형은 그대로 두고 그 안에서 이 점을 축으로 돌리기만 한다.
const Alignment kHaloCenter = Alignment(510 / 512 - 1, 356 / 512 - 1);

/// 후광은 그린 자리보다 이만큼 크게, [kHaloLift]만큼 위로 그린다.
/// 머리가 커서 1024 캔버스 안의 후광은 머리에 많이 가리는데, 캔버스 안에서
/// 키우거나 올리면 위가 잘린다(링 위 끝이 이미 y 23~32). 그래서 앱에서
/// 후광 레이어만 그림 상자 위로 넘치게 그린다. 모든 후광에 똑같이 적용한다.
const double kHaloScale = 1.2;

/// 1024 좌표 기준으로 후광을 올리는 양.
const double kHaloLift = 60;

/// 후광 레이어가 그림 상자 위로 넘치는 높이, 상자 변에 대한 비율.
/// 스크롤 목록처럼 넘친 부분을 자르는 곳에서는 부처님 위에 이만큼 비워 둔다.
const double kHaloOverflow =
    ((kHaloScale - 1) * 356 + kHaloLift) / 1024;

/// 후광 레이어를 [kHaloScale]·[kHaloLift]만큼 키우고 올린다. [size]는 그림 상자 변.
/// 부모 Stack 은 넘친 부분을 자르지 않아야 한다(Clip.none).
class HaloFrame extends StatelessWidget {
  const HaloFrame({super.key, required this.size, required this.child});

  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: Offset(0, -kHaloLift / 1024 * size),
    child: Transform.scale(
      scale: kHaloScale,
      alignment: kHaloCenter,
      child: child,
    ),
  );
}

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
