/// 절 문 (v3 메인 상단). 하루가 끝나면 닫힌다.
/// 오늘 한 번이라도 엎어두면 그날 문은 지킨 것이다.
library;

class GateState {
  final bool visitedToday;
  final Duration remaining;

  /// 연속으로 문을 지킨 날. 「무결」 증표가 이걸 읽는다.
  final int streakDays;

  const GateState({
    required this.visitedToday,
    required this.remaining,
    required this.streakDays,
  });

  bool get closingSoon => !visitedToday && remaining < const Duration(hours: 2);

  /// "5:42" — 닫힐 때까지 남은 시:분.
  String get remainingLabel {
    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    return '$h:${m.toString().padLeft(2, '0')}';
  }

  String get headline {
    if (visitedToday) return '오늘 절 다녀왔다';
    if (closingSoon) return '절 문 곧 닫힌다';
    return '절 문 · $remainingLabel 남음';
  }
}

/// 문은 자정에 닫힌다. 남은 시간은 로컬 자정까지다.
Duration untilGateCloses(DateTime now) {
  final midnight = DateTime(now.year, now.month, now.day).add(
    const Duration(days: 1),
  );
  final left = midnight.difference(now);
  return left.isNegative ? Duration.zero : left;
}

/// 인정일 키 목록에서 오늘부터 거꾸로 이어진 날 수를 센다.
/// 오늘 아직 안 왔으면 어제까지의 연속을 돌려준다 — 하루가 끝나기 전에
/// 연속을 깎지 않는다.
int gateStreak({
  required Set<String> creditedDateKeys,
  required DateTime now,
  required String Function(DateTime) keyOf,
}) {
  final today = DateTime(now.year, now.month, now.day);
  var cursor = today;
  if (!creditedDateKeys.contains(keyOf(today))) {
    cursor = today.subtract(const Duration(days: 1));
  }
  var streak = 0;
  while (creditedDateKeys.contains(keyOf(cursor))) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}
