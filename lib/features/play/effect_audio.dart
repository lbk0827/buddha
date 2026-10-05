import 'package:audioplayers/audioplayers.dart';

/// 놀이 탭 효과음 설정. 다른 앱 음악을 끊지 않는다.
/// iOS ambient — 무음 스위치를 따르고 다른 소리와 섞인다.
/// 안드로이드 — 게임 효과음, 오디오 포커스를 가져가지 않는다.
final AudioContext effectAudioContext = AudioContext(
  iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
  android: const AudioContextAndroid(
    contentType: AndroidContentType.sonification,
    usageType: AndroidUsageType.game,
    audioFocus: AndroidAudioFocus.none,
  ),
);

/// 효과음 플레이어 하나. [asset]은 assets/ 를 뺀 경로.
Future<AudioPlayer> effectPlayer(String asset, {bool loop = false}) async {
  final player = AudioPlayer();
  // 오디오 설정을 먼저 넣어야 저지연 플레이어가 그 설정으로 만들어진다.
  await player.setAudioContext(effectAudioContext);
  await player.setPlayerMode(PlayerMode.lowLatency);
  await player.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
  await player.setSource(AssetSource(asset));
  return player;
}
