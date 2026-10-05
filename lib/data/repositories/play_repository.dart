import 'package:drift/drift.dart';

import '../../core/time_utils.dart';
import '../../features/play/prayer_beads.dart';
import '../db/database.dart';

/// 놀이 염주. 넘긴 알과 그로 붙는 공덕을 남긴다.
class PlayRepository {
  PlayRepository(this._db);

  final AppDatabase _db;

  /// 오늘 넘긴 알. 다른 날 센 값이면 0이다.
  Future<BeadCount> today() async {
    final p = await _profile();
    return BeadCount(today: _beadsOn(p, todayKey()));
  }

  /// 염주 [beads]알을 넘긴다. 바퀴를 다 돌면 공덕을 올린다.
  Future<BeadCount> addBeads(int beads) {
    return _db.transaction(() async {
      final p = await _profile();
      final day = todayKey();
      final before = _beadsOn(p, day);
      final after = before + beads;
      final merit = PrayerBeads.meritBetween(before, after);

      await (_db.update(_db.profiles)..where((t) => t.id.equals(1)))
          .write(ProfilesCompanion(
        playDate: Value(day),
        playBeadsToday: Value(after),
        beadRounds:
            Value(p.beadRounds + PrayerBeads.roundsBetween(before, after)),
        merit: Value(p.merit + merit),
      ));
      return BeadCount(today: after, meritGained: merit);
    });
  }

  int _beadsOn(Profile p, String day) =>
      p.playDate == day ? p.playBeadsToday : 0;

  Future<Profile> _profile() =>
      (_db.select(_db.profiles)..where((t) => t.id.equals(1))).getSingle();
}
