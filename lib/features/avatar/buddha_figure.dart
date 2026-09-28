import 'package:flutter/material.dart';

import 'avatar_equip.dart';

/// 내 부처님.
///
/// 스프라이트 11장은 전부 1024×1024 같은 좌표계로 그려져 있어서,
/// 같은 사각형에 [BoxFit.contain]으로 겹치기만 하면 정렬이 맞는다.
/// **레이어별 위치 보정을 넣지 말 것** — 넣는 순간 어긋난다.
///
/// 쌓는 순서는 [AvatarSlot]의 선언 순서를 그대로 따른다:
/// 후광 → 대좌 → 몸(가사) → 머리 → 악세서리
class BuddhaFigure extends StatelessWidget {
  const BuddhaFigure({
    super.key,
    this.equip = kDefaultEquip,
    this.size = 220,
    this.breathing = false,
  });

  final AvatarEquip equip;

  /// 정사각 변 길이. 스프라이트가 정사각이라 세로도 같다.
  final double size;

  /// 가만히 있을 때 아주 느리게 오르내린다.
  final bool breathing;

  /// 실제로 그릴 레이어 경로들. 그리는 순서대로.
  ///
  /// - 선택되지 않은 슬롯은 건너뛴다.
  /// - 민머리처럼 겹칠 그림이 없는 아이템도 건너뛴다.
  /// - 가사가 비어 있으면 기본 몸을 쓴다. 몸이 없으면 아무것도 안 보인다.
  static List<String> layersOf(AvatarEquip equip) {
    final paths = <String>[];
    for (final slot in AvatarSlot.values) {
      final id = equip.of(slot) ??
          (slot == AvatarSlot.robe ? kDefaultEquip.of(AvatarSlot.robe) : null);
      final path = wardrobeItem(id)?.assetPath;
      if (path != null) paths.add(path);
    }
    return paths;
  }

  @override
  Widget build(BuildContext context) {
    final figure = SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (final path in layersOf(equip))
            Image.asset(
              path,
              key: ValueKey(path),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
            ),
        ],
      ),
    );

    return Semantics(
      label: '내 부처님',
      image: true,
      child: breathing ? _Breathe(child: figure) : figure,
    );
  }
}

class _Breathe extends StatefulWidget {
  const _Breathe({required this.child});
  final Widget child;

  @override
  State<_Breathe> createState() => _BreatheState();
}

class _BreatheState extends State<_Breathe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -3 * Curves.easeInOut.transform(_c.value)),
          child: child,
        ),
        child: widget.child,
      );
}
