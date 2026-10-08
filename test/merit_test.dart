import 'package:bucheo_handsome/core/time_utils.dart';
import 'package:bucheo_handsome/data/db/database.dart';
import 'package:bucheo_handsome/data/repositories/play_repository.dart';
import 'package:bucheo_handsome/data/repositories/profile_repository.dart';
import 'package:bucheo_handsome/data/repositories/worry_repository.dart';
import 'package:bucheo_handsome/features/play/play_instrument.dart';
import 'package:bucheo_handsome/features/play/prayer_beads.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('염주 계산', () {
    const per = PrayerBeads.perRound;
    const cap = PrayerBeads.roundsPerDay;

    test('108알을 채우는 순간에만 공덕이 붙는다', () {
      expect(PrayerBeads.meritBetween(0, per - 1), 0);
      expect(PrayerBeads.meritBetween(per - 1, per), PrayerBeads.meritPerRound);
      expect(PrayerBeads.meritBetween(per, per + 1), 0);
    });

    test('놀이마다 하루 공덕은 한 바퀴분(10)뿐이다', () {
      expect(PrayerBeads.meritPerRound, 10);
      expect(PrayerBeads.roundsPerDay, 1);
      expect(PrayerBeads.meritBetween(0, per * 3), 10);
    });

    test('하루 상한을 넘으면 공덕은 멈추고 바퀴는 계속 센다', () {
      expect(PrayerBeads.meritRounds(per * (cap + 3)), cap);
      expect(PrayerBeads.meritBetween(per * cap, per * (cap + 1)), 0);
      expect(PrayerBeads.roundsBetween(per * cap, per * (cap + 1)), 1);
    });

    test('BeadCount 는 지금 바퀴에서 넘긴 알과 오늘 바퀴를 알려준다', () {
      const b = BeadCount(today: per * 2 + 5);
      expect(b.inRound, 5);
      expect(b.roundsToday, 2);
      expect(b.meritDoneToday, isTrue);
      expect(const BeadCount(today: per * cap - 1).meritDoneToday, isFalse);
      expect(const BeadCount(today: per * cap).meritDoneToday, isTrue);
    });
  });

  group('DB', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      await ProfileRepository(db).ensure();
      // 디버그 빌드는 시작 공덕을 듬뿍 준다. 셈을 보려면 0에서 시작한다.
      await db.update(db.profiles).write(const ProfilesCompanion(merit: Value(0)));
    });

    tearDown(() => db.close());

    Future<Profile> profile() => ProfileRepository(db).ensure();

    group('놀이 염주', () {
      test('넘긴 알이 남고, 한 바퀴를 돌면 공덕과 바퀴가 오른다', () async {
        final repo = PlayRepository(db);
        await repo.addBeads(PlayInstrument.moktak, 100);
        final b = await repo.addBeads(PlayInstrument.moktak, 10);
        expect(b.today, 110);
        expect(b.meritGained, PrayerBeads.meritPerRound);

        final p = await profile();
        expect(p.merit, PrayerBeads.meritPerRound);
        expect(p.beadRounds, 1);
        expect((await repo.today())[PlayInstrument.moktak]!.today, 110);
      });

      test('놀이마다 따로 세고, 공덕도 놀이마다 하루 한 번', () async {
        final repo = PlayRepository(db);
        for (final i in PlayInstrument.values) {
          final b = await repo.addBeads(i, PrayerBeads.perRound);
          expect(b.today, PrayerBeads.perRound, reason: '$i');
          expect(b.meritGained, 10, reason: '$i');
        }
        // 한 바퀴 더 돌아도 더는 붙지 않는다.
        final again = await repo.addBeads(PlayInstrument.keycap, 200);
        expect(again.meritGained, 0);
        expect(again.today, PrayerBeads.perRound + 200);

        final today = await repo.today();
        expect(today[PlayInstrument.moktak]!.today, PrayerBeads.perRound);
        expect(today[PlayInstrument.singingBowl]!.today, PrayerBeads.perRound);
        final p = await profile();
        expect(p.merit, 30);
        expect(p.beadRounds, 3 + 1, reason: '바퀴는 공덕과 상관없이 다 센다(키캡 308알 = 2바퀴)');
      });

      test('날이 바뀌면 오늘 알은 0부터, 누적 바퀴는 그대로', () async {
        final repo = PlayRepository(db);
        await db.update(db.profiles).write(const ProfilesCompanion(
              playDate: Value('2000-01-01'),
              playMoktakToday: Value(PrayerBeads.perRound * 5),
              beadRounds: Value(5),
            ));
        expect((await repo.today())[PlayInstrument.moktak]!.today, 0);

        final b = await repo.addBeads(PlayInstrument.moktak, PrayerBeads.perRound);
        expect(b.meritGained, PrayerBeads.meritPerRound,
            reason: '어제 상한을 채웠어도 오늘은 새로 받는다');
        final p = await profile();
        expect(p.playDate, todayKey());
        expect(p.beadRounds, 6);
      });

      test('하루 상한을 넘기면 공덕은 더 붙지 않는다', () async {
        final repo = PlayRepository(db);
        const cap = PrayerBeads.perRound * PrayerBeads.roundsPerDay;
        await repo.addBeads(PlayInstrument.singingBowl, cap);
        final b = await repo.addBeads(PlayInstrument.singingBowl, PrayerBeads.perRound);
        expect(b.meritGained, 0);
        final p = await profile();
        expect(p.merit, PrayerBeads.meritPerRound * PrayerBeads.roundsPerDay);
        expect(p.beadRounds, PrayerBeads.roundsPerDay + 1);
      });
    });

    group('번뇌 태우기', () {
      test('공덕은 하루 세 번까지, 태운 개수는 다 센다', () async {
        final repo = WorryRepository(db);
        for (var i = 0; i < 5; i++) {
          final w = await repo.create(body: '번뇌 $i');
          await repo.burn(w.id);
        }
        final p = await profile();
        expect(p.burnedCount, 5);
        expect(p.merit,
            WorryRepository.meritPerBurn * WorryRepository.meritBurnsPerDay);
      });

      test('meritForBurn', () {
        expect(WorryRepository.meritForBurn(0), WorryRepository.meritPerBurn);
        expect(WorryRepository.meritForBurn(2), WorryRepository.meritPerBurn);
        expect(WorryRepository.meritForBurn(3), 0);
      });
    });
  });
}
