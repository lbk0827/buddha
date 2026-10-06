import 'dart:convert';
import 'dart:io';

import 'package:bucheo_handsome/features/avatar/bubble_gum_motion.dart';
import 'package:flutter_test/flutter_test.dart';

/// 앱이 직접 쓰는 기준점은 에셋 도구의 앵커(tools/characters/*.json)와
/// 같은 자리여야 한다. 그림을 다시 받아 앵커가 바뀌면 여기서 걸린다.
void main() {
  final dongja = jsonDecode(
          File('tools/characters/dongja.json').readAsStringSync())
      as Map<String, dynamic>;
  final anchors = dongja['anchors'] as Map<String, dynamic>;

  test('풍선껌이 부푸는 자리가 동자 부처의 입 앵커와 같다', () {
    final mouth = anchors['mouth'] as Map<String, dynamic>;
    final x = (kMouthAnchor.x + 1) * 512;
    final y = (kMouthAnchor.y + 1) * 512;
    expect(x, closeTo((mouth['x'] as num).toDouble(), 1.5));
    expect(y, closeTo((mouth['y'] as num).toDouble(), 1.5));
  });

  test('앵커 여섯 개가 다 있고 단위 길이가 양수다', () {
    for (final name in ['eyes', 'mouth', 'head', 'neck', 'feet', 'body']) {
      final a = anchors[name] as Map<String, dynamic>?;
      expect(a, isNotNull, reason: name);
      expect((a!['unit'] as num) > 0, isTrue, reason: name);
    }
  });
}
