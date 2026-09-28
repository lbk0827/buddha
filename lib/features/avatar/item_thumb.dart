import 'package:flutter/material.dart';

import 'avatar_equip.dart';

/// 옷장 칸에 들어가는 아이템 그림.
/// 원본 스프라이트에서 아이템 영역만 잘라낸 것을 쓴다
/// (tools/make_avatar_thumbs.py 로 생성).
class ItemThumb extends StatelessWidget {
  const ItemThumb({
    super.key,
    required this.item,
    this.dim = false,
    this.size = 54,
  });

  final WardrobeItem item;

  /// 아직 안 가진 아이템은 흐리게.
  final bool dim;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
        label: item.name,
        image: true,
        child: Opacity(
          opacity: dim ? 0.5 : 1,
          child: Image.asset(
            item.thumbPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
        ),
      );
}
