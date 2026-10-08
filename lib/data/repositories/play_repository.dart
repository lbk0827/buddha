import 'package:drift/drift.dart';

import '../../core/time_utils.dart';
import '../../features/play/play_instrument.dart';
import '../../features/play/prayer_beads.dart';
import '../db/database.dart';

/// 놀이 염주. 놀이마다 넘긴 알과 그로 붙는 공덕을 남긴다.
class PlayRepository {
  PlayRepository(this._db);

  final AppDatabase _db;

  /// 놀이마다 오늘 넘긴 알. 다른 날 센 값이면 0이다.
  Future<Map<PlayInstrument, BeadCount>> today() async {
    final p = await _profile();
    final day = todayKey();
    return {
      for (final i in PlayInstrument.values)
        i: BeadCount(today: _beadsOn(p, day, i)),
    };
  }

  /// [instrument]의 염주 [beads]알을 넘긴다. 그날 처음 한 바퀴를 다 돌면
  /// 공덕을 올린다.
  Future<BeadCount> addBeads(PlayInstrument instrument, int beads) {
    return _db.transaction(() async {
      final p = await _profile();
      final day = todayKey();
      final counts = {
        for (final i in PlayInstrument.values) i: _beadsOn(p, day, i),
      };
      final before = counts[instrument]!;
      final after = before + beads;
      counts[instrument] = after;
      final merit = PrayerBeads.meritBetween(before, after);

      await (_db.update(
        _db.profiles,
      )..where((t) => t.id.equals(1))).write(
        ProfilesCompanion(
          playDate: Value(day),
          playMoktakToday: Value(counts[PlayInstrument.moktak]!),
          playBowlToday: Value(counts[PlayInstrument.singingBowl]!),
          playKeycapToday: Value(counts[PlayInstrument.keycap]!),
          beadRounds: Value(
            p.beadRounds + PrayerBeads.roundsBetween(before, after),
          ),
          merit: Value(p.merit + merit),
        ),
      );
      return BeadCount(today: after, meritGained: merit);
    });
  }

  int _beadsOn(Profile p, String day, PlayInstrument instrument) {
    if (p.playDate != day) return 0;
    return switch (instrument) {
      PlayInstrument.moktak => p.playMoktakToday,
      PlayInstrument.singingBowl => p.playBowlToday,
      PlayInstrument.keycap => p.playKeycapToday,
    };
  }

  Future<Profile> _profile() =>
      (_db.select(_db.profiles)..where((t) => t.id.equals(1))).getSingle();
}
