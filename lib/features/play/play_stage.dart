import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// 놀이 탭 그림의 원본 캔버스 한 변(px). assets/play/*.webp 가 모두 이 크기다.
/// 기준점들은 이 원본 좌표로 적고, 화면에서는 [SpritePlacement]로 옮긴다.
const double kPlayCanvas = 1254;

/// 악기와 채가 놓이는 무대(dp). 목탁·싱잉볼이 같은 자리를 쓴다.
/// 폭 320dp 화면에도 들어가도록 300 으로 잡았다.
const Size kPlayStage = Size(300, 240);

/// 채를 보여 줄지. 지금은 숨긴다(2026-10-05 결정). 숨긴 동안에는 소리·파문·
/// 진동을 탭하는 즉시 낸다. 다시 켜면 채가 휘둘러 닿는 순간에 맞춰 낸다
/// ([StrikeTiming]). 채 그림과 배치값([MalletRig])은 그대로 남겨 둔다.
const bool kShowMallets = false;

/// 물체 폭이 [width]일 때 무대 가로 가운데에 오는 왼쪽 위치.
double centeredLeft(double width) => (kPlayStage.width - width) / 2;

/// 물체 높이가 [height]일 때 무대 세로 가운데에 오는 위쪽 위치.
/// 바닥 그림자 자리를 조금 남긴다.
double centeredTop(double height, {double shadow = 10}) =>
    (kPlayStage.height - height - shadow) / 2;

/// 원본 캔버스를 무대 위에 놓는 방법 — 배율과, 캔버스 (0,0)이 오는 무대 위치.
///
/// 정사각 캔버스를 같은 배율로 줄이기만 하므로 그림 비율이 찌그러지지 않는다.
@immutable
class SpritePlacement {
  const SpritePlacement(this.scale, this.origin);

  /// 원본에서 실제 물체 영역 [box]를 무대의 [left], [top]에 폭 [width]로 놓는다.
  /// 투명한 캔버스 전체가 아니라 물체 크기를 기준으로 맞춘다.
  factory SpritePlacement.box(
    Rect box, {
    required double left,
    required double top,
    required double width,
  }) {
    final scale = width / box.width;
    return SpritePlacement(scale, Offset(left, top) - box.topLeft * scale);
  }

  final double scale;
  final Offset origin;

  Offset toStage(Offset source) => origin + source * scale;

  double length(double source) => source * scale;

  /// 무대 위 캔버스 전체 자리.
  Rect get canvas => origin & Size.square(kPlayCanvas * scale);
}

/// 채 한 자루. 손잡이 끝을 축으로 돌아 [target]을 친다.
@immutable
class MalletRig {
  const MalletRig({
    required this.asset,
    required this.grip,
    required this.tip,
    required this.scale,
    required this.target,
    required this.hitDegrees,
    this.liftDegrees = 35,
  });

  /// assets/ 를 포함한 경로.
  final String asset;

  /// 원본: 손잡이 끝. 회전축이다.
  final Offset grip;

  /// 원본: 머리 끝. 이 점이 [target]에 닿는다.
  final Offset tip;

  /// 원본 → 무대 배율.
  final double scale;

  /// 무대: 칠 자리.
  final Offset target;

  /// 칠 때 손잡이 → 머리 방향(도). 화면 좌표라 시계 방향이 +다.
  final double hitDegrees;

  /// 쉬고 있을 때 칠 때보다 반시계로 들려 있는 각도.
  final double liftDegrees;

  static double _rad(double deg) => deg * math.pi / 180;

  /// 무대 위 채 길이(손잡이 끝 ~ 머리 끝).
  double get length => (tip - grip).distance * scale;

  /// 원본 그림에서 손잡이 → 머리 방향.
  double get _natural => math.atan2(tip.dy - grip.dy, tip.dx - grip.dx);

  double _direction(double swing) =>
      _rad(hitDegrees - liftDegrees * (1 - swing.clamp(0.0, 1.0)));

  /// 무대: 회전축(손잡이 끝)이 놓이는 자리. 칠 때 머리 끝이 [target]에 닿게 정한다.
  Offset get pivot => target - Offset.fromDirection(_rad(hitDegrees), length);

  /// [swing] 0 = 쉼, 1 = 친 순간. 그림을 돌릴 각도(라디안).
  double rotationAt(double swing) => _direction(swing) - _natural;

  /// [swing]일 때 머리 끝의 무대 위치.
  Offset tipAt(double swing) =>
      pivot + Offset.fromDirection(_direction(swing), length);

  /// 무대 위 캔버스 자리. 손잡이 끝이 [pivot]에 온다.
  SpritePlacement get placement => SpritePlacement(scale, pivot - grip * scale);
}

/// 치는 동작의 시간표.
///
/// 들린 채가 [swingDown] 만에 내려와 닿고, 나머지 시간에 천천히 돌아간다.
/// 소리는 「닿는 순간 귀에 들리도록」 미리 낸다 — 소리 파일 안에서 소리가
/// 시작되는 지점과 기기 오디오 지연만큼 당긴다.
abstract final class StrikeTiming {
  static const swingDown = Duration(milliseconds: 100);
  static const total = Duration(milliseconds: 460);

  /// 저지연 플레이어의 출력 지연 어림값. 안드로이드 SoundPool 30~50ms.
  static const audioLatency = Duration(milliseconds: 40);

  /// 탭한 뒤 소리를 낼 때까지. [onset]은 소리 파일에서 소리가 시작되는 지점.
  static Duration soundDelay(Duration onset) {
    final d = swingDown - onset - audioLatency;
    return d.isNegative ? Duration.zero : d;
  }

  static double get _impact => swingDown.inMicroseconds / total.inMicroseconds;

  /// 컨트롤러 값(0~1) → 채 위치(0 = 쉼, 1 = 닿음).
  static double swingAt(double t) {
    if (t <= 0 || t >= 1) return 0;
    if (t < _impact) return Curves.easeInQuad.transform(t / _impact);
    return 1 - Curves.easeOutCubic.transform((t - _impact) / (1 - _impact));
  }
}

/// 원본 캔버스 한 장을 [placement] 자리에 그린다. 디코딩은 화면 크기만큼만.
class PlaySprite extends StatelessWidget {
  const PlaySprite({
    super.key,
    required this.asset,
    required this.placement,
    this.child,
  });

  final String asset;
  final SpritePlacement placement;

  /// 그림 대신 감싸서 쓸 위젯(돌리기·누르기). null 이면 그림만.
  final Widget Function(Widget image)? child;

  @override
  Widget build(BuildContext context) {
    final rect = placement.canvas;
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2;
    final image = Image.asset(
      asset,
      width: rect.width,
      height: rect.height,
      fit: BoxFit.fill, // 정사각 → 정사각이라 비율은 그대로다
      cacheWidth: (rect.width * dpr).round(),
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
    );
    return Positioned.fromRect(rect: rect, child: child?.call(image) ?? image);
  }
}

/// 채. 손잡이 끝을 축으로 [swing]만큼 돌아 있다.
class SwingingMallet extends StatelessWidget {
  const SwingingMallet({super.key, required this.rig, required this.swing});

  final MalletRig rig;
  final double swing;

  @override
  Widget build(BuildContext context) => PlaySprite(
    asset: rig.asset,
    placement: rig.placement,
    child: (image) => Transform.rotate(
      angle: rig.rotationAt(swing),
      alignment: Alignment.topLeft,
      origin: rig.grip * rig.scale,
      child: image,
    ),
  );
}
