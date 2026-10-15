import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/l10n.dart';

/// 앱에 사용한 외부 저작물. CC0도 제작자에게 감사를 전하기 위해 싣는다.
class Credit {
  const Credit({required this.use, required this.notice, required this.source});

  /// 앱 어디에 쓰였나.
  final String use;

  /// 저작물이 요구하는 출처 표시 문구. 안내받은 그대로 둔다.
  final String notice;

  /// 원본이 있는 곳.
  final String source;
}

/// 소리를 새로 넣으면 docs/사운드_출처.md, 글꼴은 docs/폰트_출처.md 에도
/// 한 줄 추가한다.
///
/// CC BY 4.0 은 만든 사람·작품명·라이선스 링크·원본 링크·손댄 것을
/// 밝혀야 한다. OFL 글꼴은 저작권 문구와 라이선스 전문을 함께 내보내야
/// 한다 — 전문은 assets/google_fonts/OFL_*.txt 로 앱에 같이 나가고,
/// 「오픈소스 라이선스」 화면에서 볼 수 있다(lib/main.dart).
///
/// 설명문은 문자열 테이블에서 오고, 저작자·작품명·URL·저작권 문구는
/// 원문 그대로 코드에 둔다.
List<Credit> creditsOf(AppLocalizations l10n) => [
      Credit(
        use: l10n.settingsCreditMoktakUse,
        notice: l10n.settingsCreditMoktakNotice,
        source: '${l10n.settingsCreditMoktakChanges}\n'
            '${l10n.settingsCreditGonguSite} · '
            'gongu.copyright.or.kr/gongu/wrt/wrt/view.do?wrtSn=13253418\n'
            'creativecommons.org/licenses/by/4.0/deed.ko',
      ),
      Credit(
        use: l10n.settingsCreditBowlUse,
        notice: '${l10n.settingsCreditBowlNotice('dersinnsspace', 'Tibetan bowl_center hit.wav', 'Tibetan bowl_rubbing rim.wav')}\n'
            '${l10n.settingsCreditBowlChanges}',
        source:
            'Freesound · freesound.org/s/421829/ · freesound.org/s/417115/\n'
            'creativecommons.org/publicdomain/zero/1.0/',
      ),
      Credit(
        use: l10n.settingsCreditKeycapUse,
        notice: '${l10n.settingsCreditKeycapNotice('Reina0613', 'Mechanical keyboard typing sounds')}\n'
            '${l10n.settingsCreditKeycapChanges}',
        source: 'Freesound · freesound.org/s/709460/\n'
            'creativecommons.org/publicdomain/zero/1.0/',
      ),
      Credit(
        use: l10n.settingsCreditFontUse('Noto Sans KR'),
        notice: 'Copyright 2014-2021 Adobe (http://www.adobe.com/), '
            "with Reserved Font Name 'Source'.\n"
            '${l10n.settingsCreditFontOflNote}',
        source: 'Google Fonts · fonts.google.com/specimen/Noto+Sans+KR',
      ),
      Credit(
        use: l10n.settingsCreditFontUse(l10n.settingsCreditFontGowunBatang),
        notice: 'Copyright 2021 The Gowun Batang Project Authors '
            '(https://github.com/yangheeryu/Gowun-Batang).\n'
            '${l10n.settingsCreditFontOflNote}',
        source: 'Google Fonts · fonts.google.com/specimen/Gowun+Batang',
      ),
    ];

/// 컨텍스트가 없는 곳(테스트 등)에서 쓰는 지금 언어의 출처 목록.
List<Credit> get kCredits => creditsOf(L.current);

/// 출처 — 설정에서 연다.
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsCreditsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Tokens.gutter),
          children: [
            for (final credit in creditsOf(context.l10n))
              ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                title: Text(credit.use),
                subtitle: Text(
                  '${credit.notice}\n${credit.source}',
                  style: const TextStyle(height: 1.5),
                ),
              ),
            // 글꼴 라이선스 전문과, 앱에 들어간 패키지들의 라이선스.
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              title: Text(context.l10n.settingsOpenSourceLicenses),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  showLicensePage(
                      context: context,
                      applicationName: context.l10n.appTitle),
            ),
          ],
        ),
      ),
    );
  }
}
