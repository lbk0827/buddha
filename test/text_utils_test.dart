import 'package:bucheo_handsome/core/text_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keepAll — 띄어쓰기는 그대로, 단어 안 글자 사이에만 줄바꿈 금지 문자', () {
    final s = keepAll('저녁만 망친다.');
    expect(s.replaceAll('\u2060', ''), '저녁만 망친다.');
    expect(s.split(' '), ['저\u2060녁\u2060만', '망\u2060친\u2060다\u2060.']);
  });

  test('keepAll — 빈 문자열과 한 글자', () {
    expect(keepAll(''), '');
    expect(keepAll('가'), '가');
  });
}
