import 'package:flutter/material.dart';

import '../../app/theme.dart';

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
const kCredits = [
  Credit(
    use: '목탁 소리',
    notice: "김용배의 '목탁소리(이미지)'은 CC BY 라이선스로 제공됩니다.",
    source:
        '두 번째 타 하나만 잘라 끝을 부드럽게 줄임.\n'
        '한국저작권위원회 공유마당 · '
        'gongu.copyright.or.kr/gongu/wrt/wrt/view.do?wrtSn=13253418\n'
        'creativecommons.org/licenses/by/4.0/deed.ko',
  ),
  Credit(
    use: '싱잉볼 소리',
    notice:
        'dersinnsspace의 “Tibetan bowl_center hit.wav”와 '
        '“Tibetan bowl_rubbing rim.wav” · CC0 1.0.\n'
        '앱에 맞게 음량 조정, 모노 변환 및 반복 구간 편집.',
    source:
        'Freesound · freesound.org/s/421829/ · freesound.org/s/417115/\n'
        'creativecommons.org/publicdomain/zero/1.0/',
  ),
  Credit(
    use: '키캡 소리',
    notice:
        'Reina0613의 “Mechanical keyboard typing sounds” · CC0 1.0.\n'
        '누름·뗌 소리를 한 타씩 잘라 음량 조정.',
    source:
        'Freesound · freesound.org/s/709460/\n'
        'creativecommons.org/publicdomain/zero/1.0/',
  ),
  Credit(
    use: '글꼴 — Noto Sans KR',
    notice:
        'Copyright 2014-2021 Adobe (http://www.adobe.com/), '
        "with Reserved Font Name 'Source'.\n"
        'SIL Open Font License 1.1. 앱에 쓰는 글자만 남겨 용량을 줄임.',
    source: 'Google Fonts · fonts.google.com/specimen/Noto+Sans+KR',
  ),
  Credit(
    use: '글꼴 — 고운바탕',
    notice:
        'Copyright 2021 The Gowun Batang Project Authors '
        '(https://github.com/yangheeryu/Gowun-Batang).\n'
        'SIL Open Font License 1.1. 앱에 쓰는 글자만 남겨 용량을 줄임.',
    source: 'Google Fonts · fonts.google.com/specimen/Gowun+Batang',
  ),
];

/// 출처 — 설정에서 연다.
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('출처')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Tokens.gutter),
          children: [
            for (final credit in kCredits)
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
              title: const Text('오픈소스 라이선스'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  showLicensePage(context: context, applicationName: '부처핸섬'),
            ),
          ],
        ),
      ),
    );
  }
}
