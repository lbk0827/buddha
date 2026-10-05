import 'package:drift/drift.dart';

import '../../core/time_utils.dart';
import '../db/database.dart';

/// 번뇌 태우기 (v3 놀이). 태우면 공덕이 오른다.
class WorryRepository {
  WorryRepository(this._db);

  final AppDatabase _db;

  /// 태우면 붙는 공덕.
  static const int meritPerBurn = 15;

  /// 공덕이 붙는 건 하루 이만큼까지. 그 뒤로도 태우는 건 된다.
  /// 한 글자씩 적어 태우는 게 가장 좋은 벌이가 되지 않게 한다.
  static const int meritBurnsPerDay = 3;

  /// 오늘 이미 [burnedBefore]개 태웠을 때 하나 더 태우면 붙는 공덕.
  static int meritForBurn(int burnedBefore) =>
      burnedBefore < meritBurnsPerDay ? meritPerBurn : 0;

  Future<Worry> create({
    required String body,
    String? kind,
    bool safetyFlagged = false,
  }) async {
    final now = DateTime.now();
    final id = await _db.into(_db.worries).insert(
          WorriesCompanion.insert(
            body: body,
            kind: Value(kind),
            createdAt: now,
            safetyFlagged: Value(safetyFlagged),
            localDate: localDateKey(now),
          ),
        );
    return (_db.select(_db.worries)..where((t) => t.id.equals(id))).getSingle();
  }

  /// 죽비 — 선사가 돌려준 한마디를 붙인다.
  Future<void> attachSeonsaLine(int worryId, String line) =>
      (_db.update(_db.worries)..where((t) => t.id.equals(worryId)))
          .write(WorriesCompanion(seonsaLine: Value(line)));

  /// 「반박」. 죽비가 한 번 더 온다.
  Future<int> rebut(int worryId) async {
    final w = await (_db.select(_db.worries)
          ..where((t) => t.id.equals(worryId)))
        .getSingle();
    final next = w.rebuttalCount + 1;
    await (_db.update(_db.worries)..where((t) => t.id.equals(worryId)))
        .write(WorriesCompanion(rebuttalCount: Value(next)));
    return next;
  }

  /// 「인정. 태운다」. 번뇌를 닫고 공덕과 누적을 올린다.
  Future<int> burn(int worryId, {bool accepted = true}) async {
    return _db.transaction(() async {
      final merit = meritForBurn(await burnedToday());
      await (_db.update(_db.worries)..where((t) => t.id.equals(worryId)))
          .write(WorriesCompanion(
        burnedAt: Value(DateTime.now()),
        accepted: Value(accepted),
      ));

      final profile = await (_db.select(_db.profiles)
            ..where((t) => t.id.equals(1)))
          .getSingle();
      final burned = profile.burnedCount + 1;
      await (_db.update(_db.profiles)..where((t) => t.id.equals(1)))
          .write(ProfilesCompanion(
        burnedCount: Value(burned),
        merit: Value(profile.merit + merit),
      ));
      return burned;
    });
  }

  Future<int> burnedToday() async {
    final count = _db.worries.id.count();
    final row = await (_db.selectOnly(_db.worries)
          ..addColumns([count])
          ..where(_db.worries.localDate.equals(todayKey()) &
              _db.worries.burnedAt.isNotNull()))
        .getSingle();
    return row.read(count) ?? 0;
  }

  /// 아직 태우지 않고 남겨둔 번뇌.
  Future<Worry?> pending() => (_db.select(_db.worries)
        ..where((t) => t.burnedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
        ..limit(1))
      .getSingleOrNull();

  Future<List<Worry>> recent({int limit = 50}) => (_db.select(_db.worries)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
        ..limit(limit))
      .get();
}

/// 해제된 증표.
class TokenRepository {
  TokenRepository(this._db);

  final AppDatabase _db;

  Future<Set<String>> unlockedIds() async {
    final rows = await _db.select(_db.tokenUnlocks).get();
    return rows.map((r) => r.tokenId).toSet();
  }

  Future<void> unlock(String tokenId) async {
    await _db.into(_db.tokenUnlocks).insertOnConflictUpdate(
          TokenUnlocksCompanion.insert(
            tokenId: tokenId,
            unlockedAt: DateTime.now(),
          ),
        );
  }

  /// 해제 연출을 아직 안 본 증표.
  Future<List<TokenUnlock>> unseen() => (_db.select(_db.tokenUnlocks)
        ..where((t) => t.seen.equals(false)))
      .get();

  Future<void> markSeen(String tokenId) =>
      (_db.update(_db.tokenUnlocks)..where((t) => t.tokenId.equals(tokenId)))
          .write(const TokenUnlocksCompanion(seen: Value(true)));
}
