import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'effect_audio.dart';

/// 키캡 소리 — 누를 때 「도각」, 뗄 때 「각」.
///
/// 같은 소리가 되풀이되면 금방 기계처럼 들린다. 실제 키보드 녹음에서 잘라 낸
/// 여러 타를 번갈아 쓴다. 출처는 docs/사운드_출처.md.
abstract class KeycapSound {
  /// 바닥에 닿는 소리. 못 내도 조용히 넘어간다.
  void press();

  /// 떼서 올라오는 소리. 누르는 소리보다 작고 가볍다.
  void release();

  Future<void> warmUp();

  Future<void> dispose();
}

final keycapSoundProvider = Provider<KeycapSound>((ref) {
  final sound = AudioKeycapSound();
  ref.onDispose(sound.dispose);
  return sound;
});

class AudioKeycapSound implements KeycapSound {
  AudioKeycapSound({Random? random}) : _random = random ?? Random();

  /// audioplayers 는 assets/ 를 앞에 붙여 찾는다.
  static const pressAssets = [
    'sounds/keycap/down_1.wav',
    'sounds/keycap/down_2.wav',
    'sounds/keycap/down_3.wav',
    'sounds/keycap/down_4.wav',
    'sounds/keycap/down_5.wav',
    'sounds/keycap/down_6.wav',
  ];
  static const releaseAssets = [
    'sounds/keycap/up_1.wav',
    'sounds/keycap/up_2.wav',
    'sounds/keycap/up_3.wav',
    'sounds/keycap/up_4.wav',
  ];

  /// 한 파일에 플레이어 하나. 방금 낸 타는 바로 다시 고르지 않으니, 빠르게
  /// 쳐도 다른 파일이 겹쳐 울린다. 플레이어를 늘리면 처음 불러오는 데 그만큼
  /// 오래 걸린다.
  static const voicesPerFile = 1;

  final Random _random;
  final _press = _VariantBank('누르는');
  final _release = _VariantBank('떼는');
  Future<void>? _ready;

  Future<void> _prepare() => _ready ??= Future.wait([
    _press.load(pressAssets),
    _release.load(releaseAssets),
  ]);

  @override
  Future<void> warmUp() => _prepare();

  @override
  void press() => _play(_press);

  @override
  void release() => _play(_release);

  Future<void> _play(_VariantBank bank) async {
    final asked = DateTime.now();
    await _prepare();
    // 준비가 늦어 탭한 지 한참 뒤라면 내지 않는다.
    if (DateTime.now().difference(asked) > kLateSoundLimit) return;
    await bank.play(_random);
  }

  @override
  Future<void> dispose() async {
    await _press.dispose();
    await _release.dispose();
  }
}

/// 한 종류 소리의 여러 타. 방금 낸 타는 바로 다시 고르지 않는다.
class _VariantBank {
  _VariantBank(this.name);

  final String name;

  /// [variant][voice].
  final List<List<AudioPlayer>> _players = [];
  final List<int> _nextVoice = [];
  var _last = -1;

  Future<void> load(List<String> assets) async {
    for (final asset in assets) {
      try {
        final voices = <AudioPlayer>[];
        for (var v = 0; v < AudioKeycapSound.voicesPerFile; v++) {
          voices.add(await effectPlayer(asset));
        }
        _players.add(voices);
        _nextVoice.add(0);
      } catch (e) {
        // 파일 하나를 못 읽어도 나머지로 소리를 낸다.
        debugPrint('키캡 $name 소리를 못 불러왔다($asset): $e');
      }
    }
  }

  Future<void> play(Random random) async {
    final n = _players.length;
    if (n == 0) return;
    var pick = random.nextInt(n);
    if (n > 1 && pick == _last) pick = (pick + 1 + random.nextInt(n - 1)) % n;
    _last = pick;
    final voice = _nextVoice[pick];
    _nextVoice[pick] = (voice + 1) % _players[pick].length;
    final player = _players[pick][voice];
    try {
      await player.stop();
      await player.resume();
    } catch (e) {
      debugPrint('키캡 $name 소리를 못 냈다: $e');
    }
  }

  Future<void> dispose() async {
    for (final voices in _players) {
      for (final player in voices) {
        await player.dispose();
      }
    }
    _players.clear();
  }
}
