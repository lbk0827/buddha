import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme.dart';

/// 공유 카드 (FR-3.7, FR-6.4).
/// 번뇌 원문은 절대 들어가지 않는다. 한마디 + 앱명만 담는다.
class ShareCard extends StatelessWidget {
  const ShareCard({super.key, required this.line, this.caption});

  final String line;

  /// 유형 결과 공유에서만 쓰는 부제. 유형명은 여기 들어가지 않는다.
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 720,
      height: 900,
      padding: const EdgeInsets.all(64),
      color: Tokens.ivory,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (caption != null)
            Text(
              caption!,
              style: const TextStyle(
                fontSize: 26,
                color: Tokens.temple,
                fontWeight: FontWeight.w600,
              ),
            ),
          const Spacer(),
          Text(
            line,
            style: const TextStyle(
              fontSize: 44,
              height: 1.45,
              color: Tokens.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Tokens.saffron,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '부처핸섬',
                style: TextStyle(
                  fontSize: 26,
                  color: Tokens.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 위젯을 이미지로 구워 OS 공유 시트를 연다.
Future<void> shareDialogueCard(
  BuildContext context,
  String line, {
  String? caption,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final bytes = await ScreenshotController().captureFromWidget(
      ShareCard(line: line, caption: caption),
      pixelRatio: 2,
      targetSize: const Size(720, 900),
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(bytes, mimeType: 'image/png', name: 'bucheo.png'),
        ],
      ),
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('나누기에 실패했다. $e')));
  }
}
