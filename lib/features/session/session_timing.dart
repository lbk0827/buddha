import 'dart:convert';

/// 수행 시간에서 빼는 구간. 일시정지(오디오 중단), 30초 유예,
/// 중단 선택 화면 체류가 모두 여기에 들어간다 (FR-2.5, FR-2.6).
class ExcludedInterval {
  final DateTime from;

  /// null이면 아직 열려 있는 구간.
  final DateTime? to;
  final String reason;

  const ExcludedInterval({
    required this.from,
    this.to,
    required this.reason,
  });

  bool get isOpen => to == null;

  ExcludedInterval close(DateTime at) =>
      ExcludedInterval(from: from, to: at, reason: reason);

  /// [start, now] 구간과 겹치는 초. 열린 구간은 now까지로 본다.
  int overlapSeconds(DateTime start, DateTime now) {
    final end = to ?? now;
    final lo = from.isAfter(start) ? from : start;
    final hi = end.isBefore(now) ? end : now;
    final diff = hi.difference(lo).inSeconds;
    return diff > 0 ? diff : 0;
  }

  Map<String, dynamic> toJson() => {
        'from': from.toIso8601String(),
        'to': to?.toIso8601String(),
        'reason': reason,
      };

  factory ExcludedInterval.fromJson(Map<String, dynamic> m) => ExcludedInterval(
        from: DateTime.parse(m['from'] as String),
        to: m['to'] == null ? null : DateTime.parse(m['to'] as String),
        reason: m['reason']?.toString() ?? 'pause',
      );
}

String encodeExcluded(List<ExcludedInterval> list) =>
    jsonEncode(list.map((e) => e.toJson()).toList());

List<ExcludedInterval> decodeExcluded(String raw) {
  if (raw.trim().isEmpty) return [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .map((e) => ExcludedInterval.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  } catch (_) {
    return [];
  }
}

/// 틱을 세지 않는다. 시각을 기록한다 (PRD 세션 타이머 설계).
/// 백그라운드에서 Dart 타이머가 멈춰도, 앱이 강제 종료됐다 돌아와도
/// 결과가 같아야 한다.
int practicedSeconds({
  required DateTime startedAt,
  required DateTime now,
  required List<ExcludedInterval> excluded,
}) {
  final elapsed = now.difference(startedAt).inSeconds;
  if (elapsed <= 0) return 0;
  var off = 0;
  for (final e in excluded) {
    off += e.overlapSeconds(startedAt, now);
  }
  final practiced = elapsed - off;
  return practiced > 0 ? practiced : 0;
}

/// 완주 예정 시각. 제외 구간이 늘어나면 뒤로 밀린다 → 알림 재예약 근거.
DateTime scheduledEndAt({
  required DateTime startedAt,
  required int targetSec,
  required List<ExcludedInterval> excluded,
  required DateTime now,
}) {
  var off = 0;
  for (final e in excluded) {
    off += e.overlapSeconds(startedAt, now);
  }
  return startedAt.add(Duration(seconds: targetSec + off));
}

/// 유효 세션 = 수행 시간 60초 이상 (FR-4.1).
const int kValidSessionSec = 60;

bool isValidSession(int practicedSec) => practicedSec >= kValidSessionSec;

/// 중단 10분 초과 시 종료 (FR-2.6).
const Duration kMaxInterruptionBeforeEnd = Duration(minutes: 10);

/// 오디오 중단 해제 후 유예 (FR-2.6).
const Duration kAudioResumeGrace = Duration(seconds: 30);

/// 준비 상태 확인 타임아웃 (FR-2.2).
const Duration kReadyTimeout = Duration(seconds: 60);

/// 중단 선택 화면 무응답 타임아웃 (FR-2.5).
const Duration kInterruptChoiceTimeout = Duration(seconds: 60);
