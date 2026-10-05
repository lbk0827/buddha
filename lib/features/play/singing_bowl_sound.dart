import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'effect_audio.dart';

/// 싱잉볼 소리. 치는 소리와, 테두리를 문지르는 동안 이어지는 울림.
///
/// 두 소리 모두 같은 공명 주파수를 사용해 직접 합성했다.
/// 생성 방법은 tools/synthesize_singing_bowl.py, 기록은 docs/사운드_출처.md.
abstract class SingingBowlSound {
  /// 채로 한 번 친다.
  void strike();

  /// 문지르는 울림 0~1. 0이면 멈춘다.
  void rub(double level);

  Future<void> warmUp();

  Future<void> dispose();
}

final singingBowlSoundProvider = Provider<SingingBowlSound>((ref) {
  final sound = AudioSingingBowlSound();
  ref.onDispose(sound.dispose);
  return sound;
});

class AudioSingingBowlSound implements SingingBowlSound {
  static const strikeAsset = 'sounds/singing_bowl_strike_v3.wav';
  static const rubAsset = 'sounds/singing_bowl_rub_v3.wav';

  /// 치는 소리는 8초를 울린다. 연달아 치면 앞 울림 위에 겹친다.
  static const voices = 3;

  /// 이보다 작게 바뀌면 플레이어에 다시 보내지 않는다. 손가락이 움직일
  /// 때마다 보내면 플랫폼 채널이 붐빈다.
  static const volumeStep = 0.02;

  final List<AudioPlayer> _strikes = [];
  AudioPlayer? _rub;
  Future<void>? _ready;
  var _next = 0;
  var _broken = false;
  var _rubbing = false;
  var _sentVolume = -1.0;

  Future<void> _prepare() => _ready ??= _load();

  Future<void> _load() async {
    try {
      for (var i = 0; i < voices; i++) {
        _strikes.add(await effectPlayer(strikeAsset));
      }
      _rub = await effectPlayer(rubAsset, loop: true);
    } catch (e) {
      _broken = true;
      debugPrint('싱잉볼 소리를 못 불러왔다: $e');
    }
  }

  @override
  Future<void> warmUp() => _prepare();

  @override
  void strike() {
    _strike();
  }

  Future<void> _strike() async {
    await _prepare();
    if (_broken || _strikes.isEmpty) return;
    final player = _strikes[_next];
    _next = (_next + 1) % _strikes.length;
    try {
      await player.stop();
      await player.resume();
    } catch (e) {
      debugPrint('싱잉볼 소리를 못 냈다: $e');
    }
  }

  /// 울림 크기를 소리 크기로. 귀는 작은 소리 차이에 민감해서 곡선을 준다.
  static double volumeFor(double level) =>
      math.pow(level.clamp(0.0, 1.0), 1.6).toDouble();

  @override
  void rub(double level) {
    _setRub(level);
  }

  Future<void> _setRub(double level) async {
    await _prepare();
    final player = _rub;
    if (_broken || player == null) return;
    final volume = volumeFor(level);
    try {
      if (volume <= 0.001) {
        if (_rubbing) {
          _rubbing = false;
          _sentVolume = -1;
          await player.pause();
        }
        return;
      }
      if ((volume - _sentVolume).abs() >= volumeStep) {
        _sentVolume = volume;
        await player.setVolume(volume);
      }
      if (!_rubbing) {
        _rubbing = true;
        await player.resume();
      }
    } catch (e) {
      debugPrint('싱잉볼 울림을 못 냈다: $e');
    }
  }

  @override
  Future<void> dispose() async {
    for (final player in [..._strikes, ?_rub]) {
      await player.dispose();
    }
    _strikes.clear();
    _rub = null;
  }
}
