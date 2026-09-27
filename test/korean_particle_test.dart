import 'package:bucheo_handsome/core/time_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('withRo — ~으로 / ~로', () {
    test('받침이 없으면 로', () {
      expect(withRo('무니'), '무니로');
      expect(withRo('보리'), '보리로');
    });

    test('받침이 있으면 으로', () {
      expect(withRo('지안'), '지안으로');
      expect(withRo('무념'), '무념으로');
      expect(withRo('적조'), '적조로');
      expect(withRo('해안'), '해안으로');
    });

    test('ㄹ 받침은 로', () {
      expect(withRo('보월'), '보월로');
      expect(withRo('일현'), '일현으로');
    });

    test('한글이 아니면 로', () {
      expect(withRo('Zen'), 'Zen로');
      expect(withRo(''), '');
    });
  });

  group('withParticle', () {
    test('은/는', () {
      expect(withParticle('무념', '은', '는'), '무념은');
      expect(withParticle('적조', '은', '는'), '적조는');
    });

    test('이/가', () {
      expect(withParticle('지안', '이', '가'), '지안이');
      expect(withParticle('보리', '이', '가'), '보리가');
    });

    test('빈 문자열과 비한글', () {
      expect(withParticle('', '은', '는'), '는');
      expect(withParticle('Zen', '은', '는'), 'Zen는');
    });
  });
}
