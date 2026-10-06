import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bucheo_handsome/features/wishes/wish_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('소원을 저장하고 새 저장소에서 다시 읽는다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await WishStore(preferences).add('  모두 건강하기를  ');
    expect(WishStore(preferences).wishes, ['모두 건강하기를']);
    await expectLater(WishStore(preferences).add('   '), throwsArgumentError);
    await expectLater(
      WishStore(preferences).add('가' * 121),
      throwsArgumentError,
    );
    expect(WishStore(preferences).wishes.length, 1);
  });
  test('랜덤 열람은 직전 소원을 제외하고 하나만 있어도 동작한다', () {
    final random = Random(1);
    for (var i = 0; i < 20; i++) {
      expect(pickWish(['첫째', '둘째', '셋째'], '첫째', random), isNot('첫째'));
    }
    expect(pickWish(['하나'], '하나', random), '하나');
  });
}
