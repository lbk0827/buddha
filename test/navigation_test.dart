import 'dart:async';

import 'package:bucheo_handsome/app/router.dart';
import 'package:bucheo_handsome/app/theme.dart';
import 'package:bucheo_handsome/features/home/home_controller.dart';
import 'package:bucheo_handsome/features/shell/bottom_hud.dart';
import 'package:bucheo_handsome/features/shell/tab_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('하단 HUD는 절 · 꾸미기 · 놀이 · 선사 · 소원', () {
    expect(kHudTabs.map((t) => t.label), ['절', '꾸미기', '놀이', '선사', '소원']);
    expect(kHudTabs.last.route, Routes.wishes);
  });

  test('증표는 HUD 탭이 아니다', () {
    expect(kHudTabs.any((t) => t.route == Routes.tokens), isFalse);
    expect(kHudTabs.any((t) => t.label == '증표'), isFalse);
  });

  testWidgets('상단바의 증표 버튼은 증표 화면을 연다', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: SafeArea(child: TabTopBar())),
        ),
        GoRoute(
          path: Routes.tokens,
          builder: (_, _) => const Scaffold(body: Text('증표 화면')),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeStateProvider.overrideWith(
            (ref) => Completer<TempleHomeState>().future,
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    );
    expect(find.byTooltip('증표'), findsOneWidget);
    expect(find.byTooltip('프로필'), findsOneWidget);

    await tester.tap(find.byTooltip('증표'));
    await tester.pumpAndSettle();
    expect(find.text('증표 화면'), findsOneWidget);
    // push 로 열어서 뒤로 돌아올 수 있다.
    expect(router.canPop(), isTrue);
  });
}
