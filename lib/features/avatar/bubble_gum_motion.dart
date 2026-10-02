import 'package:flutter/material.dart';

/// 부처님이 움직이는 정도.
enum AvatarMotion {
  /// 멈춘 그림. 옷장 썸네일, 공유 카드.
  still,

  /// 한 바퀴 돌고 다 부푼 풍선에서 멈춘다. 꾸미기에서 입혀 볼 때.
  once,

  /// 쉬었다가 계속 반복한다. 절 화면.
  loop,
}

/// 풍선껌 한 바퀴의 길이. 쉬는 시간까지 포함한다.
const Duration kBubbleGumCycle = Duration(seconds: 7);

/// 풍선이 부풀고 붙은 껌이 빨려 들어가는 기준점 — 입 (510, 396) / 1024.
/// 레이어 사각형은 다른 레이어와 같고, 그 안에서 이 점을 중심으로 크기만
/// 바뀐다. 레이어 자리를 옮기는 게 아니라 정렬은 그대로다.
const Alignment kMouthAnchor = Alignment(510 / 512 - 1, 396 / 512 - 1);

/// 한 순간의 풍선과 붙은 껌. 크기 1·불투명 1이 원래 그림이다.
@immutable
class BubbleGumFrame {
  const BubbleGumFrame({
    this.bubbleScale = 0,
    this.bubbleOpacity = 0,
    this.poppedScale = 0,
    this.poppedOpacity = 0,
  });

  final double bubbleScale;
  final double bubbleOpacity;
  final double poppedScale;
  final double poppedOpacity;

  /// 다 부푼 풍선. 멈춘 화면이 이것이다.
  static const full = BubbleGumFrame(bubbleScale: 1, bubbleOpacity: 1);

  bool get showsBubble => bubbleScale > 0 && bubbleOpacity > 0;
  bool get showsPopped => poppedScale > 0 && poppedOpacity > 0;

  // 한 바퀴를 0~1로 놓고 구간을 나눈다. 7초 기준 초는 괄호 안.
  static const double _inflateEnd = 0.30; // 부풀기 (0 ~ 2.1)
  static const double _popEnd = 0.32; // 터짐 (2.1 ~ 2.24)
  static const double _stuckIn = 0.31; // 붙은 껌이 나타나기 시작
  static const double _stuckFull = 0.33;
  static const double _suckStart = 0.55; // 빨아들임 (3.85 ~ 4.34)
  static const double _suckEnd = 0.62;
  static const double _reinflateEnd = 0.92; // once: 다시 부풀어 멈춤

  static const double _smallest = 0.15;
  static const double _popGrow = 0.15;

  /// [t]는 한 바퀴 안의 위치(0~1).
  /// [once]면 빨아들인 뒤 다시 부풀어 다 부푼 풍선으로 끝난다.
  /// 아니면 빨아들인 뒤 비워 두고 쉰다.
  static BubbleGumFrame at(double t, {bool once = false}) {
    t = t.clamp(0.0, 1.0);
    var bubbleScale = 0.0, bubbleOpacity = 0.0;
    var poppedScale = 0.0, poppedOpacity = 0.0;

    if (t < _inflateEnd) {
      final u = Curves.easeOutCubic.transform(t / _inflateEnd);
      bubbleScale = _smallest + (1 - _smallest) * u;
      bubbleOpacity = 1;
    } else if (t < _popEnd) {
      final u = (t - _inflateEnd) / (_popEnd - _inflateEnd);
      bubbleScale = 1 + _popGrow * u;
      bubbleOpacity = 1 - u;
    }

    if (t >= _stuckIn && t < _suckEnd) {
      if (t < _stuckFull) {
        poppedScale = 1;
        poppedOpacity = (t - _stuckIn) / (_stuckFull - _stuckIn);
      } else if (t < _suckStart) {
        poppedScale = 1;
        poppedOpacity = 1;
      } else {
        final u = Curves.easeIn.transform(
          (t - _suckStart) / (_suckEnd - _suckStart),
        );
        poppedScale = 1 - 0.8 * u;
        poppedOpacity = 1 - u;
      }
    }

    if (once && t >= _suckEnd) {
      final u = Curves.easeOutCubic.transform(
        ((t - _suckEnd) / (_reinflateEnd - _suckEnd)).clamp(0.0, 1.0),
      );
      bubbleScale = _smallest + (1 - _smallest) * u;
      bubbleOpacity = 1;
    }

    return BubbleGumFrame(
      bubbleScale: bubbleScale,
      bubbleOpacity: bubbleOpacity,
      poppedScale: poppedScale,
      poppedOpacity: poppedOpacity,
    );
  }
}

/// 풍선이 부풀었다 터져 입에 붙고, 빨려 들어간다.
///
/// 풍선과 붙은 껌 두 장을 입을 중심으로 키우고 줄이기만 한다. 크기별로
/// 그림을 여러 장 받으면 GPT가 장마다 모양을 다르게 그려 깜빡인다.
class BubbleGumMotion extends StatefulWidget {
  const BubbleGumMotion({
    super.key,
    required this.bubble,
    required this.popped,
    required this.layer,
    this.once = false,
  });

  final String bubble;
  final String popped;

  /// 경로로 레이어 한 장을 그리는 방법. 다른 레이어와 같은 설정을 쓴다.
  final Widget Function(String path) layer;

  final bool once;

  @override
  State<BubbleGumMotion> createState() => _BubbleGumMotionState();
}

class _BubbleGumMotionState extends State<BubbleGumMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: kBubbleGumCycle,
  );

  @override
  void initState() {
    super.initState();
    widget.once ? _c.forward() : _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _scaled(String path, double scale, double opacity) {
    if (scale <= 0 || opacity <= 0) return const SizedBox.expand();
    Widget child = widget.layer(path);
    if (opacity < 1) child = Opacity(opacity: opacity, child: child);
    return Transform.scale(scale: scale, alignment: kMouthAnchor, child: child);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (context, _) {
      final f = BubbleGumFrame.at(_c.value, once: widget.once);
      return Stack(
        fit: StackFit.expand,
        children: [
          _scaled(widget.popped, f.poppedScale, f.poppedOpacity),
          _scaled(widget.bubble, f.bubbleScale, f.bubbleOpacity),
        ],
      );
    },
  );
}
