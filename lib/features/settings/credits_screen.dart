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

/// 새로 넣으면 docs/사운드_출처.md 에도 한 줄 추가한다.
const kCredits = [
  Credit(
    use: '목탁 소리',
    notice: "김용배의 '목탁소리(이미지)'은 CC BY 라이선스로 제공됩니다.",
    source: '한국저작권위원회 공유마당 · gongu.copyright.or.kr',
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
          ],
        ),
      ),
    );
  }
}
