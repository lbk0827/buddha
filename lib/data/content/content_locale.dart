import 'package:flutter/services.dart';

import '../../l10n/l10n.dart';

/// 언어별 콘텐츠 JSON 은 assets/content/<언어>/<파일> 에 있다.
/// 고른 언어에 그 파일이 없으면 한국어 원본(assets/content/ko/)을 쓴다.
String contentAssetPath(String file, [String languageCode = 'ko']) =>
    'assets/content/$languageCode/$file';

Future<String> loadContentString(
  AssetBundle bundle,
  String file, {
  String? languageCode,
}) async {
  final lang = languageCode ?? L.current.localeName.split('_').first;
  if (lang != L.fallbackLocale.languageCode) {
    try {
      return await bundle.loadString(contentAssetPath(file, lang));
    } catch (_) {
      // 아직 번역되지 않은 파일 — 원본으로 간다.
    }
  }
  return bundle.loadString(contentAssetPath(file));
}
