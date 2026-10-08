import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 놀이 탭에서 두드릴 악기.
enum PlayInstrument {
  moktak('목탁', '화면을 톡 치면 목탁을 두드린다.'),
  singingBowl('싱잉볼', '톡 치거나, 테두리를 따라 빙글빙글 문지른다.'),
  keycap('키캡', '키캡을 꾹 눌렀다 떼면 도각 소리가 난다.');

  const PlayInstrument(this.label, this.howTo);
  final String label;

  /// 놀이 방법 한 줄.
  final String howTo;
}

/// 마지막에 고른 악기. 다음에 놀이 탭을 열면 그 악기로 시작한다.
/// 기억은 기기 설정(shared_preferences)에 둔다. 못 읽거나 못 써도 놀이는 된다.
class PlayInstrumentNotifier extends Notifier<PlayInstrument> {
  static const key = 'play.instrument';

  /// 저장된 값을 읽어 오기 전에 사용자가 고르면, 늦게 온 저장값으로 덮지 않는다.
  var _chosen = false;

  @override
  PlayInstrument build() {
    _restore();
    return PlayInstrument.moktak;
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = PlayInstrument.values.asNameMap()[prefs.getString(key)];
      if (saved != null && !_chosen && ref.mounted) state = saved;
    } catch (e) {
      debugPrint('놀이 악기를 못 읽었다: $e');
    }
  }

  Future<void> select(PlayInstrument instrument) async {
    _chosen = true;
    state = instrument;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, instrument.name);
    } catch (e) {
      debugPrint('놀이 악기를 못 남겼다: $e');
    }
  }
}

final playInstrumentProvider =
    NotifierProvider<PlayInstrumentNotifier, PlayInstrument>(
      PlayInstrumentNotifier.new,
    );
