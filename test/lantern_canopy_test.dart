import 'dart:ui' as ui;

import 'package:bucheo_handsome/features/wishes/lantern_canopy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final reducedMotion in [false, true]) {
    testWidgets('종이 움직임과 움직임 줄이기: $reducedMotion', (tester) async {
      final key = GlobalKey();
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reducedMotion),
            child: Scaffold(
              body: Center(
                child: RepaintBoundary(
                  key: key,
                  child: SizedBox(
                    width: 360,
                    child: LanternCanopy(onTap: () => taps++),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      Future<List<int>> pixels() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        image.dispose();
        return bytes!.buffer.asUint8List().toList();
      }

      final first = await tester.runAsync(pixels);
      await tester.pump(const Duration(seconds: 2));
      final next = await tester.runAsync(pixels);
      expect(next, reducedMotion ? equals(first) : isNot(equals(first)));
      await tester.tap(find.byType(LanternCanopy));
      expect(taps, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
