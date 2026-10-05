import 'dart:math';

/// 놀이의 공덕 — 염주 한 바퀴.
///
/// 목탁을 두드리거나 싱잉볼을 칠 때마다 염주 한 알을 넘긴다. 싱잉볼을 문질러
/// 울리는 동안에는 [rubSecondsPerBead]마다 한 알. 108알이 한 바퀴고, 한 바퀴를
/// 돌면 공덕 [meritPerRound]이 붙는다.
///
/// 공덕은 하루 [roundsPerDay]바퀴까지만 붙는다. 그 뒤로도 두드리는 건 그대로
/// 되고 바퀴도 센다. 막지 않고 공덕만 멈춘다 — 반복이 가장 좋은 벌이가 되지
/// 않게, 처벌 없이 (기획서 v3 「성장·기록 규칙」).
class PrayerBeads {
  static const int perRound = 108;
  static const int meritPerRound = 20;
  static const int roundsPerDay = 5;

  /// 싱잉볼이 이만큼 울리면 한 알. 1분 남짓 울리면 한 바퀴다.
  static const double rubSecondsPerBead = 0.5;

  /// 그날 [beads]알 넘겼을 때 공덕이 붙은 바퀴 수.
  static int meritRounds(int beads) => min(beads ~/ perRound, roundsPerDay);

  /// 그날 [before]알에서 [after]알이 되는 동안 붙는 공덕.
  static int meritBetween(int before, int after) =>
      (meritRounds(after) - meritRounds(before)) * meritPerRound;

  /// 그날 [before]알에서 [after]알이 되는 동안 돈 바퀴. 상한 없이 센다.
  static int roundsBetween(int before, int after) =>
      after ~/ perRound - before ~/ perRound;
}

/// 염주를 넘긴 뒤의 오늘 상태.
class BeadCount {
  const BeadCount({required this.today, this.meritGained = 0});

  /// 오늘 넘긴 알.
  final int today;

  /// 방금 넘긴 알로 붙은 공덕. 바퀴를 막 다 돌았을 때만 0보다 크다.
  final int meritGained;

  static const zero = BeadCount(today: 0);

  /// 지금 돌고 있는 바퀴에서 넘긴 알 (0 ~ 107).
  int get inRound => today % PrayerBeads.perRound;

  int get roundsToday => today ~/ PrayerBeads.perRound;

  /// 오늘 받을 공덕을 다 받았는가.
  bool get meritDoneToday => roundsToday >= PrayerBeads.roundsPerDay;
}
