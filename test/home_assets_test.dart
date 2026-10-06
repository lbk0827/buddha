import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('「부처님 말씀」 카드의 연꽃 아이콘이 앱 번들에 있다', () async {
    final data = await rootBundle.load('assets/home/icon_lotus.webp');
    expect(data.lengthInBytes, greaterThan(1000));
  });
}
