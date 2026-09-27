import 'package:intl/intl.dart';

final _dateKeyFormat = DateFormat('yyyy-MM-dd');

/// 인정일 집계 키. 세션은 시작 시각의 로컬 날짜에 귀속된다 (FR-4.1).
/// 자정을 넘긴 세션도 시작일로 계산된다.
String localDateKey(DateTime t) => _dateKeyFormat.format(t.toLocal());

DateTime parseDateKey(String key) => _dateKeyFormat.parseStrict(key);

String todayKey() => localDateKey(DateTime.now());

/// 두 날짜 키 사이의 일수. b - a.
int daysBetweenKeys(String a, String b) =>
    parseDateKey(b).difference(parseDateKey(a)).inDays;

/// 세션 시간 표기. "3분", "1분 40초", "40초".
String formatDuration(int seconds) {
  if (seconds < 60) return '$seconds초';
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return s == 0 ? '$m분' : '$m분 $s초';
}

/// 기록 화면 누적 시간. "12시간 30분".
String formatCumulative(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  if (h == 0) return '$m분';
  return m == 0 ? '$h시간' : '$h시간 $m분';
}
