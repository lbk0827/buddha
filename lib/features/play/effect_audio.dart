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

/// 탭한 뒤 이보다 늦게 준비된 소리는 내지 않는다. 몇 초 뒤에 몰아서 울리면
/// 고장 난 것처럼 들린다.
const kLateSoundLimit = Duration(milliseconds: 250);

Future<void>? _globalContext;

/// 앱 전체 오디오 설정을 한 번만 바꾼다. 앱 소리는 모두 효과음이라 이걸로 충분하다.
///
/// 플레이어마다 설정을 보내면, 안드로이드에서는 플레이어가 기본 설정(포커스
/// 잡기)으로 만들어졌다가 바뀌면서 포커스 반납·오디오 모드 변경을 매번 다시
/// 한다. 플레이어가 수십 개면 그동안 플랫폼 채널이 막혀 첫 소리가 몇 초씩
/// 늦고 화면도 버벅인다(2026-10-09).
Future<void> _ensureContext() =>
    _globalContext ??= AudioPlayer.global.setAudioContext(effectAudioContext);

/// 효과음 플레이어 하나. [asset]은 assets/ 를 뺀 경로.
Future<AudioPlayer> effectPlayer(String asset, {bool loop = false}) async {
  await _ensureContext();
  // 전체 설정을 먼저 바꿔 두면 새 플레이어는 처음부터 그 설정으로 만들어진다.
  final player = AudioPlayer();
  await player.setPlayerMode(PlayerMode.lowLatency);
  await player.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
  await player.setSource(AssetSource(asset));
  return player;
}
