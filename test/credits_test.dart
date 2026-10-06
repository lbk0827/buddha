import 'package:bucheo_handsome/app/theme.dart';
import 'package:bucheo_handsome/features/settings/credits_screen.dart';
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
}
