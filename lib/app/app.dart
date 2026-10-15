import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import 'router.dart';
import 'theme.dart';

class BucheoApp extends ConsumerWidget {
  const BucheoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
      builder: (context, child) {
        // 컨텍스트 없는 코드(L.current)도 앱이 고른 언어를 따른다.
        L.use(Localizations.localeOf(context));
        // 시스템 글자 200%에서도 레이아웃이 깨지지 않아야 한다 (비기능 · 접근성).
        final scale = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 2.0);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scale),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
