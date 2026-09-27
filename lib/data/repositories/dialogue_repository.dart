import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/time_utils.dart';
import '../../data/content/models.dart';
import '../../features/dialogue/dialogue_selector.dart';
import '../db/database.dart';

class DialogueRepository {
  DialogueRepository(this._db);

  final AppDatabase _db;

  /// repeatDays 계산은 최대 14일까지만 본다 (현재 최장 규칙).
  Future<List<ExposureRecord>> recent({int days = 14}) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final rows = await (_db.select(_db.dialogueExposures)
          ..where((t) => t.shownAt.isBiggerThanValue(cutoff)))
        .get();
    return rows.map(_toRecord).toList();
  }

  Future<List<ExposureRecord>> today() async {
    final rows = await (_db.select(_db.dialogueExposures)
          ..where((t) => t.localDate.equals(todayKey())))
        .get();
    return rows.map(_toRecord).toList();
  }

  Future<List<ExposureRecord>> forSession(int sessionId) async {
    final rows = await (_db.select(_db.dialogueExposures)
          ..where((t) => t.sessionId.equals(sessionId)))
        .get();
    return rows.map(_toRecord).toList();
  }

  ExposureRecord _toRecord(DialogueExposure e) => ExposureRecord(
        dialogueId: e.dialogueId,
        shownAt: e.shownAt,
        role: DialogueRole.values.firstWhere(
          (r) => r.name == e.role,
          orElse: () => DialogueRole.guide,
        ),
        intensity: DialogueIntensity.values.firstWhere(
          (i) => i.name == e.intensity,
          orElse: () => DialogueIntensity.low,
        ),
      );

  Future<void> record(DialogueItem item, {int? sessionId}) async {
    final now = DateTime.now();
    await _db.into(_db.dialogueExposures).insert(
          DialogueExposuresCompanion.insert(
            dialogueId: item.id,
            shownAt: now,
            role: item.role.name,
            intensity: item.intensity.name,
            sessionId: Value(sessionId),
            localDate: localDateKey(now),
          ),
        );
  }

  /// 오늘의 한마디는 하루에 하나로 고정된다 (FR-3.5).
  /// 어떤 ID가 daily 풀인지는 호출부가 안다.
  Future<String?> todaysIdAmong(Set<String> poolIds) async {
    final rows = await (_db.select(_db.dialogueExposures)
          ..where((t) => t.localDate.equals(todayKey()))
          ..orderBy([(t) => OrderingTerm.asc(t.shownAt)]))
        .get();
    for (final r in rows) {
      if (poolIds.contains(r.dialogueId)) return r.dialogueId;
    }
    return null;
  }
}

/// 로컬 이벤트 로그. 원문 텍스트는 절대 넣지 않는다 (PRD 분석 이벤트).
class AnalyticsLog {
  AnalyticsLog(this._db);

  final AppDatabase _db;

  Future<void> log(String name, [Map<String, Object?> params = const {}]) async {
    await _db.into(_db.analyticsEvents).insert(
          AnalyticsEventsCompanion.insert(
            name: name,
            paramsJson: Value(jsonEncode(params)),
            at: DateTime.now(),
          ),
        );
  }
}
