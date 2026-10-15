import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/l10n.dart';

List<String> get exampleWishes => [
      L.current.wishesExampleFamily,
      L.current.wishesExampleCourage,
      L.current.wishesExampleKindness,
      L.current.wishesExampleRestfulNight,
      L.current.wishesExampleFruition,
    ];

class WishStore {
  WishStore(this.preferences);
  final SharedPreferences preferences;
  static const key = 'wishes.local.v1';
  List<String> get wishes => preferences.getStringList(key) ?? [];

  Future<void> add(String text) async {
    final value = text.trim();
    if (value.isEmpty || value.runes.length > 120) {
      throw ArgumentError('소원은 1~120자로 적어 주세요.');
    }
    if (!await preferences.setStringList(key, [...wishes, value])) {
      throw StateError('소원을 저장하지 못했습니다.');
    }
  }
}

final wishStoreProvider = FutureProvider<WishStore>(
  (ref) async => WishStore(await SharedPreferences.getInstance()),
);
final wishCountProvider = FutureProvider<int>(
  (ref) async => (await ref.watch(wishStoreProvider.future)).wishes.length,
);

/// 같은 소원이 연속해서 나오지 않도록 이전 항목을 제외한다.
String pickWish(List<String> wishes, String? previous, Random random) {
  final candidates = wishes.where((wish) => wish != previous).toList();
  final pool = candidates.isEmpty ? wishes : candidates;
  return pool[random.nextInt(pool.length)];
}
