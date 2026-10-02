import 'package:flutter/material.dart';

import 'avatar_equip.dart';
import 'bubble_gum_motion.dart';

export 'bubble_gum_motion.dart' show AvatarMotion;

/// 내 부처님.
///
/// 스프라이트는 전부 1024×1024 같은 좌표계로 그려져 있어서,
/// 같은 사각형에 [BoxFit.contain]으로 겹치기만 하면 정렬이 맞는다.
/// **레이어별 위치 보정을 넣지 말 것** — 넣는 순간 어긋난다.
///
/// 쌓는 순서는 [AvatarSlot]의 선언 순서를 그대로 따른다:
/// 후광 → 대좌 → 몸(가사) → 발 → 머리 → 얼굴 → 목 → 입
///
/// 움직이는 아이템(풍선껌)은 [motion]에 따라 그 레이어만 입을 중심으로
/// 커졌다 작아진다. 기기에서 「동작 줄이기」를 켜면 멈춘 그림이다.
class BuddhaFigure extends StatelessWidget {
  const BuddhaFigure({
    super.key,
    this.equip = kDefaultEquip,
    this.size = 220,
    this.breathing = false,
    this.motion = AvatarMotion.still,
  });

  final AvatarEquip equip;

  /// 정사각 변 길이. 스프라이트가 정사각이라 세로도 같다.
  final double size;

  /// 가만히 있을 때 아주 느리게 오르내린다.
  final bool breathing;

  /// 풍선껌 같은 움직이는 아이템을 어떻게 보여줄지.
  final AvatarMotion motion;

  /// 실제로 그릴 레이어들. 그리는 순서대로.
  ///
  /// - 선택되지 않은 슬롯은 건너뛴다.
  /// - 민머리·부처처럼 겹칠 그림이 없는 아이템도 건너뛴다.
  /// - 가사가 비어 있으면 기본 몸을 쓴다. 몸이 없으면 아무것도 안 보인다.
  /// - 재질을 입었으면 살이 있는 레이어 바로 위에 그 살만 물들여 한 번 더
  ///   겹친다. 모자·가사는 아래 원래 레이어가 그대로 보인다.
  static List<AvatarLayer> layersOf(AvatarEquip equip) {
    final tint = wardrobeItem(equip.wornIn(AvatarSlot.buddha))?.tint;
    final layers = <AvatarLayer>[];
    for (final slot in AvatarSlot.values) {
      final item = wardrobeItem(equip.wornIn(slot));
      final path = item?.assetPath;
      if (item == null || path == null) continue;
      layers.add(AvatarLayer(path, null, item.poppedPath));
      final skin = item.skinPath;
      if (tint != null && skin != null) layers.add(AvatarLayer(skin, tint));
    }
    return layers;
  }

  static Widget _image(String path) => Image.asset(
    path,
    key: ValueKey(path),
    fit: BoxFit.contain,
    filterQuality: FilterQuality.medium,
    gaplessPlayback: true,
  );

  @override
  Widget build(BuildContext context) {
    final animate =
        motion != AvatarMotion.still &&
        !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);

    final figure = SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (final layer in layersOf(equip))
            if (animate && layer.popped != null)
              BubbleGumMotion(
                key: ValueKey('motion:${layer.path}'),
                bubble: layer.path,
                popped: layer.popped!,
                layer: _image,
                once: motion == AvatarMotion.once,
              )
            else
              tintedBy(layer.tint, _image(layer.path)),
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

/// 겹칠 그림 한 장. [tint]가 있으면 그 재질로 물들여 그린다.
/// [popped]가 있으면 움직이는 아이템이다 (풍선껌의 터진 껌).
@immutable
class AvatarLayer {
  const AvatarLayer(this.path, [this.tint, this.popped]);

  final String path;
  final SkinTint? tint;
  final String? popped;

  @override
  bool operator ==(Object other) =>
      other is AvatarLayer &&
      other.path == path &&
      other.tint == tint &&
      other.popped == popped;

  @override
  int get hashCode => Object.hash(path, tint, popped);

  @override
  String toString() => tint == null ? path : '$path (재질)';
}

/// 재질이 있으면 물들이고, 없으면 그대로.
Widget tintedBy(SkinTint? tint, Widget child) => tint == null
    ? child
    : ColorFiltered(colorFilter: ColorFilter.matrix(tint.matrix), child: child);

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
