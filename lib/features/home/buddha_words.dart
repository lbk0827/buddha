import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 부처님 말씀 한 구절 — 초기 경전을 현대 한국어로 풀어 쓴 것.
///
/// 영어 대조문은 Bhikkhu Sujato 역(SuttaCentral, CC0). 한국어 풀이는 이 앱이
/// 썼고 외부 감수 전이다. 출처와 고른 기준은 docs/부처님_말씀_출처.md.
@immutable
class BuddhaWord {
  const BuddhaWord({
    required this.id,
    required this.text,
    required this.scripture,
    required this.ref,
    required this.sourceUrl,
    required this.english,
  });

  factory BuddhaWord.fromJson(Map<String, dynamic> j) => BuddhaWord(
    id: j['id'] as String,
    text: j['text'] as String,
    scripture: j['scripture'] as String,
    ref: j['ref'] as String,
    sourceUrl: j['sourceUrl'] as String,
    english: j['english'] as String,
  );

  final String id;
  final String text;

  /// 경전 이름 (법구경, 상윳따 니까야 …)
  final String scripture;

  /// 경전 안 위치 (50게, 36.6 화살경 …)
  final String ref;

  final String sourceUrl;

  /// 대조용 영어 원문. 화면에는 보이지 않고 감수·출처 확인에 쓴다.
  final String english;

  /// 카드 아래 출처 한 줄.
  String get citation => '$scripture $ref';
}

const kBuddhaWordsAsset = 'assets/content/buddha_words.json';

List<BuddhaWord> parseBuddhaWords(String raw) {
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return [
    for (final item in json['items'] as List)
      BuddhaWord.fromJson(item as Map<String, dynamic>),
  ];
}

final buddhaWordsProvider = FutureProvider<List<BuddhaWord>>(
  (ref) async =>
      parseBuddhaWords(await rootBundle.loadString(kBuddhaWordsAsset)),
);

/// 하루 한 구절. 모든 구절을 한 번씩 돈 뒤에야 다시 나온다.
///
/// 구절 순서를 고정된 씨앗으로 한 번 섞어 두고 날짜마다 하나씩 넘긴다.
/// 같은 날에는 언제 열어도 같은 구절이다. 기록을 남기지 않는다.
BuddhaWord wordOfDay(List<BuddhaWord> words, DateTime day) {
  final order = List<int>.generate(words.length, (i) => i)
    ..shuffle(Random(108));
  final days = DateTime.utc(
    day.year,
    day.month,
    day.day,
  ).difference(DateTime.utc(2026, 1, 1)).inDays;
  return words[order[days % words.length]];
}

final todaysBuddhaWordProvider = FutureProvider<BuddhaWord?>((ref) async {
  final words = await ref.watch(buddhaWordsProvider.future);
  if (words.isEmpty) return null;
  return wordOfDay(words, DateTime.now());
});
