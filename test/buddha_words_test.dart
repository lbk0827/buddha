import 'package:bucheo_handsome/features/home/buddha_words.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<BuddhaWord> words;
  setUpAll(() async {
    words = parseBuddhaWords(await rootBundle.loadString(kBuddhaWordsAsset));
  });

  group('부처님 말씀 데이터', () {
    test('구절이 30개 넘게 있고 id가 겹치지 않는다', () {
      expect(words.length, greaterThanOrEqualTo(30));
      expect(words.map((w) => w.id).toSet().length, words.length);
    });

    test('모든 구절에 경전 이름·위치·원문·원문 링크가 있다 — 출처 없는 말씀은 없다', () {
      for (final w in words) {
        expect(w.text.trim(), isNotEmpty, reason: w.id);
        expect(w.scripture.trim(), isNotEmpty, reason: w.id);
        expect(w.ref.trim(), isNotEmpty, reason: w.id);
        expect(w.english.trim().length, greaterThan(20), reason: w.id);
        expect(
          w.sourceUrl,
          startsWith('https://suttacentral.net/'),
          reason: w.id,
        );
      }
    });

    // 360dp 화면 카드 폭(약 258dp)에 15sp 한글이 한 줄 17자 남짓 들어간다.
    // 띄어쓰기에서만 줄을 바꾸므로 두 줄에 안전한 길이는 33자 안팎이다.
    test('카드 두 줄에 들어갈 길이다 (33자 이하)', () {
      for (final w in words) {
        expect(
          w.text.length,
          lessThanOrEqualTo(33),
          reason: '${w.id} ${w.text}',
        );
      }
    });

    test('출처 한 줄은 「경전 위치」', () {
      final w = words.firstWhere((w) => w.scripture == '법구경');
      expect(w.citation, startsWith('법구경 '));
      expect(w.citation, endsWith('게'));
    });
  });

  group('하루 한 구절', () {
    test('같은 날에는 언제 열어도 같은 구절', () {
      expect(
        wordOfDay(words, DateTime(2026, 10, 6, 8)).id,
        wordOfDay(words, DateTime(2026, 10, 6, 23, 59)).id,
      );
    });

    test('모든 구절을 한 번씩 돌기 전에는 다시 나오지 않는다', () {
      final start = DateTime(2026, 10, 6);
      final seen = {
        for (var i = 0; i < words.length; i++)
          wordOfDay(words, start.add(Duration(days: i))).id,
      };
      expect(seen.length, words.length);
    });

    test('한 바퀴 돌면 같은 순서로 다시 시작한다', () {
      final day = DateTime(2026, 10, 6);
      expect(
        wordOfDay(words, day.add(Duration(days: words.length))).id,
        wordOfDay(words, day).id,
      );
    });
  });
}
