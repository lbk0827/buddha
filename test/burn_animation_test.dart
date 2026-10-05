import 'package:bucheo_handsome/features/worry/burn_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lantern finishes once after the note has burned', (
    tester,
  ) async {
    var completed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: BurnOverlay(text: '내일의 걱정을 내려놓는다', onDone: () => completed++),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    expect(completed, 0);
    await tester.pump(const Duration(milliseconds: 2500));
    expect(completed, 0);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 750));
    expect(completed, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(completed, 1);
  });

  testWidgets('leaving early does not complete the burn', (tester) async {
    var completed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: BurnOverlay(text: '걱정', onDone: () => completed++),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
    expect(completed, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long note fits on a small screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: BurnOverlay(text: '아주 긴 걱정이 마음에 남아 있습니다. ' * 20, onDone: () {}),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
