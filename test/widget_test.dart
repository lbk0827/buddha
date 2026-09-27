import 'package:bucheo_handsome/app/theme.dart';
import 'package:bucheo_handsome/features/temple/temple_yard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {Brightness brightness = Brightness.light}) =>
    MaterialApp(
      theme: brightness == Brightness.light ? AppTheme.light() : AppTheme.dark(),
      home: Scaffold(body: child),
    );

void main() {
  group('TempleYard', () {
    testWidgets('빈 마당도 그려진다', (tester) async {
      await tester.pumpWidget(_wrap(const TempleYard(stage: 0)));
      expect(find.byType(TempleYard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('단계 0~6이 전부 예외 없이 그려진다', (tester) async {
      for (var stage = 0; stage <= 6; stage++) {
        await tester.pumpWidget(_wrap(TempleYard(stage: stage)));
        expect(tester.takeException(), isNull, reason: 'stage $stage');
      }
    });

    testWidgets('다크 모드에서도 그려진다', (tester) async {
      await tester.pumpWidget(
          _wrap(const TempleYard(stage: 6), brightness: Brightness.dark));
      expect(tester.takeException(), isNull);
    });

    testWidgets('낙엽과 밝은 등이 함께 켜져도 문제없다', (tester) async {
      await tester.pumpWidget(_wrap(
          const TempleYard(stage: 3, lanternBright: true, fallenLeaves: true)));
      expect(tester.takeException(), isNull);
    });

    testWidgets('스크린 리더용 라벨이 붙는다', (tester) async {
      await tester.pumpWidget(_wrap(const TempleYard(stage: 2)));
      expect(find.bySemanticsLabel(RegExp('등')), findsOneWidget);
    });
  });

  group('테마', () {
    testWidgets('라이트·다크 모두 배경색이 지정돼 있다', (tester) async {
      for (final theme in [AppTheme.light(), AppTheme.dark()]) {
        expect(theme.scaffoldBackgroundColor, isNotNull);
        expect(theme.colorScheme.primary, Tokens.saffron);
      }
    });
  });
}
