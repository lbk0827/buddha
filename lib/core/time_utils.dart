import 'package:intl/intl.dart';

import '../l10n/l10n.dart';

/// 한글 받침에 따라 조사를 고른다. "지안으로" / "무념으로" / "보월로".
String withParticle(String word, String afterConsonant, String afterVowel) {
  if (word.isEmpty) return word + afterVowel;
  final code = word.codeUnitAt(word.length - 1);
  // 한글 음절 영역이 아니면 받침 없는 쪽으로 둔다.
  if (code < 0xAC00 || code > 0xD7A3) return word + afterVowel;
  final hasFinal = (code - 0xAC00) % 28 != 0;
  return word + (hasFinal ? afterConsonant : afterVowel);
}

/// "~으로 / ~로". 단, ㄹ 받침은 "로"를 쓴다.
String withRo(String word) {
  if (word.isEmpty) return word;
  final code = word.codeUnitAt(word.length - 1);
  if (code < 0xAC00 || code > 0xD7A3) return '$word로';
  final finalIndex = (code - 0xAC00) % 28;
  // 8 = ㄹ
  return '$word${finalIndex == 0 || finalIndex == 8 ? '로' : '으로'}';
}

/// [withParticle] 에서 조사만. 문자열 테이블 문장에 조사를 따로 넘길 때 쓴다
/// (예: `"{name}{particle} 부를게요"`). 다른 언어 번역은 이 값을 안 써도 된다.
String particleOf(String word, String afterConsonant, String afterVowel) =>
    withParticle(word, afterConsonant, afterVowel).substring(word.length);

/// [withRo] 에서 조사만 ("으로" / "로").
String roOf(String word) => withRo(word).substring(word.length);

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
  final l = L.current;
  if (seconds < 60) return l.coreDurationSeconds(seconds);
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return s == 0 ? l.coreDurationMinutes(m) : l.coreDurationMinutesSeconds(m, s);
}

/// 기록 화면 누적 시간. "12시간 30분".
String formatCumulative(int seconds) {
  final l = L.current;
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  if (h == 0) return l.coreCumulativeMinutes(m);
  return m == 0 ? l.coreCumulativeHours(h) : l.coreCumulativeHoursMinutes(h, m);
}

/// 요일 약칭 "월" … "일". [weekday] 는 [DateTime.weekday] (월=1 … 일=7).
String weekdayShort(AppLocalizations l, int weekday) => switch (weekday) {
      DateTime.monday => l.coreWeekdayShortMonday,
      DateTime.tuesday => l.coreWeekdayShortTuesday,
      DateTime.wednesday => l.coreWeekdayShortWednesday,
      DateTime.thursday => l.coreWeekdayShortThursday,
      DateTime.friday => l.coreWeekdayShortFriday,
      DateTime.saturday => l.coreWeekdayShortSaturday,
      _ => l.coreWeekdayShortSunday,
    };

/// 요일 이름 "월요일" … "일요일". [weekday] 는 [DateTime.weekday].
String weekdayLong(AppLocalizations l, int weekday) => switch (weekday) {
      DateTime.monday => l.coreWeekdayLongMonday,
      DateTime.tuesday => l.coreWeekdayLongTuesday,
      DateTime.wednesday => l.coreWeekdayLongWednesday,
      DateTime.thursday => l.coreWeekdayLongThursday,
      DateTime.friday => l.coreWeekdayLongFriday,
      DateTime.saturday => l.coreWeekdayLongSaturday,
      _ => l.coreWeekdayLongSunday,
    };
