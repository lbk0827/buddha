import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const exampleWishes = [
  '우리 가족이 건강하고 평안하기를 바랍니다.',
  '새로운 시작 앞에서 용기를 잃지 않게 해 주세요.',
  '오늘도 누군가에게 다정한 사람이 되고 싶어요.',
  '마음이 지친 모든 이에게 편안한 밤이 오기를.',
  '오래 준비한 일이 좋은 결실을 맺기를 바랍니다.',
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
