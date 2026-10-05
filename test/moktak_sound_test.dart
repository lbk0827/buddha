import 'package:bucheo_handsome/features/play/moktak_sound.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('목탁 소리 파일이 앱 번들에 있다', () async {
    final data = await rootBundle.load('assets/${AudioMoktakSound.asset}');
    expect(data.lengthInBytes, greaterThan(1000));
  });

  test('소리를 못 내는 환경에서도 두드리기는 멈추지 않는다', () async {
    // 테스트에는 오디오 플러그인이 없다. 기기에서 오디오가 고장 난 경우와 같다.
    final sound = AudioMoktakSound();
    await sound.warmUp();
    for (var i = 0; i < 10; i++) {
      sound.knock();
    }
    await Future<void>.delayed(Duration.zero);
    await sound.dispose();
  });

  test('연타가 겹치도록 여러 소리를 돌려 쓴다', () {
    expect(AudioMoktakSound.voices, greaterThanOrEqualTo(3));
  });
}
