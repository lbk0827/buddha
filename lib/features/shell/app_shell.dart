import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'bottom_hud.dart';

/// 네 탭의 공통 껍데기.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  int get _index {
    for (var i = kHudTabs.length - 1; i >= 0; i--) {
      final route = kHudTabs[i].route;
      if (route == '/' ? location == '/' : location.startsWith(route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomHud(
        currentIndex: _index,
        onSelect: (i) => context.go(kHudTabs[i].route),
      ),
    );
  }
}

/// 본문 리스트가 하단 바에 딱 붙지 않도록 두는 여백.
const double kHudClearance = 28;
