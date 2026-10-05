import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'effect_audio.dart';

/// 목탁 소리.
///
/// 소리: Freesound 「Mokugyo.wav」(jonopodmore, CC0 1.0). 일본 고야산의 작은
/// 목어를 원래 천 감은 채로 친 녹음이다. 출처는 docs/사운드_출처.md.
abstract class MoktakSound {
  /// 한 번 친다. 소리를 못 내도 조용히 넘어간다 — 소리 때문에 두드리기가
  /// 막히면 안 된다.
  void knock();

  /// 화면에 들어올 때 미리 불러 두면 첫 타가 늦지 않는다.
  Future<void> warmUp();

  Future<void> dispose();
}

final moktakSoundProvider = Provider<MoktakSound>((ref) {
  final sound = AudioMoktakSound();
  ref.onDispose(sound.dispose);
  return sound;
});

class AudioMoktakSound implements MoktakSound {
  /// audioplayers 는 assets/ 를 앞에 붙여 찾는다.
  static const asset = 'sounds/moktak.mp3';

  /// 연타하면 앞 소리가 울리는 중에 다음 소리가 겹친다. 한 플레이어로는
  /// 앞 소리를 끊어야 해서, 여러 개를 돌려 쓴다.
  static const voices = 4;

  final List<AudioPlayer> _players = [];
  Future<void>? _ready;
  var _next = 0;
  var _broken = false;

  Future<void> _prepare() => _ready ??= _load();

  Future<void> _load() async {
    try {
      for (var i = 0; i < voices; i++) {
        _players.add(await effectPlayer(asset));
      }
    } catch (e) {
      // 플러그인이 없는 환경(테스트)이나 기기 오디오 문제. 소리만 포기한다.
      _broken = true;
      debugPrint('목탁 소리를 못 불러왔다: $e');
    }
  }

  @override
  Future<void> warmUp() => _prepare();

  @override
  void knock() {
    _knock();
  }

  Future<void> _knock() async {
    await _prepare();
    if (_broken || _players.isEmpty) return;
    final player = _players[_next];
    _next = (_next + 1) % _players.length;
    try {
      await player.stop();
      await player.resume();
    } catch (e) {
      debugPrint('목탁 소리를 못 냈다: $e');
    }
  }

  @override
  Future<void> dispose() async {
    for (final player in _players) {
      await player.dispose();
    }
    _players.clear();
  }
}
