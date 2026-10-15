import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

/// 화면 문자열 테이블(lib/l10n/app_<언어>.arb)에 닿는 입구.
///
/// - 위젯 안: `context.l10n.appTitle`
/// - BuildContext 가 없는 곳(카탈로그 · 알림 · 컨트롤러): `L.current.appTitle`
///
/// [L.current] 는 앱이 고른 언어로 [BucheoApp] 이 맞춰 둔다. 앱 밖(단위 테스트,
/// 백그라운드 알림)에서는 원본 언어인 한국어다.
abstract final class L {
  static const Locale fallbackLocale = Locale('ko');

  static AppLocalizations current = lookupAppLocalizations(fallbackLocale);

  /// 앱이 고른 언어를 [current] 에 맞춘다.
  static void use(Locale locale) {
    if (current.localeName == locale.toString()) return;
    current = lookupAppLocalizations(
      AppLocalizations.supportedLocales.contains(locale)
          ? locale
          : fallbackLocale,
    );
  }
}

extension L10nContext on BuildContext {
  /// 위젯 트리에 Localizations 가 없으면(MaterialApp 만 감싼 위젯 테스트)
  /// [L.current] 로 대신한다.
  AppLocalizations get l10n => AppLocalizations.of(this) ?? L.current;
}
