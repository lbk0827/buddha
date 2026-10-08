import 'package:bucheo_handsome/app/theme.dart';
import 'package:bucheo_handsome/features/settings/credits_screen.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('목탁 소리는 공유마당이 안내한 문구 그대로 출처를 밝힌다', () {
    expect(
      kCredits.map((c) => c.notice),
      contains("김용배의 '목탁소리(이미지)'은 CC BY 라이선스로 제공됩니다."),
    );
  });

  testWidgets('출처 화면에 모든 출처 문구가 보인다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const CreditsScreen()),
    );
    for (final credit in kCredits) {
      expect(find.text(credit.use), findsOneWidget);
      expect(find.textContaining(credit.notice), findsOneWidget);
    }
  });

  test('앱에 넣은 글꼴마다 OFL 전문이 함께 들어간다', () {
    final dir = Directory('assets/google_fonts');
    final fonts = dir.listSync().map((f) => f.uri.pathSegments.last);
    for (final family in ['NotoSansKR', 'GowunBatang']) {
      expect(fonts.any((f) => f.startsWith('$family-')), isTrue);
      final ofl = File('assets/google_fonts/OFL_$family.txt');
      expect(ofl.readAsStringSync(), contains('SIL OPEN FONT LICENSE'));
    }
  });

  testWidgets('출처 화면에서 오픈소스 라이선스를 열 수 있다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const CreditsScreen()),
    );
    await tester.scrollUntilVisible(find.text('오픈소스 라이선스'), 200);
    expect(find.text('오픈소스 라이선스'), findsOneWidget);
  });
}
