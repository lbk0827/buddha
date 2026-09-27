import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';

/// 단주 소개 (FR-8.1). 앱 내 결제는 없고 관심 등록은 외부 폼으로 나간다.
/// 실물 구매와 앱 기능 해제는 연동하지 않는다 (Apple 3.1.4).
class GoodsScreen extends ConsumerWidget {
  const GoodsScreen({super.key});

  /// 외부 관심 등록 폼. 실제 URL은 폼 개설 후 교체한다.
  static const _interestFormUrl = 'https://forms.gle/';
  static const _price = 38000;

  static const _colors = [
    ('먹', '검게 물들인 보리수'),
    ('밤', '그을린 대추나무'),
    ('재', '연한 회색 오석'),
    ('흙', '유약 없는 분청'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final fg = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('단주')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Tokens.gutter),
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                decoration: BoxDecoration(
                  color: fg.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(child: _BeadsPreview()),
              ),
            ),
            const SizedBox(height: 24),
            Text('21알', style: text.displayMedium),
            const SizedBox(height: 12),
            Text(
              '손목에 한 바퀴. 한 알에 숨 하나 세면 스물한 번이다.\n'
              '다 세고 나면 대개 그 생각은 지나가 있다.',
              style: text.bodyLarge?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 24),
            Text('색', style: text.titleLarge),
            const SizedBox(height: 8),
            for (final (name, desc) in _colors)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('$name · $desc',
                    style: text.bodyMedium
                        ?.copyWith(color: fg.withValues(alpha: 0.7))),
              ),
            const SizedBox(height: 24),
            Text('$_price원', style: text.headlineMedium),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                await ref
                    .read(analyticsProvider)
                    .log('goods_interest', {'price': _price});
                final uri = Uri.parse(_interestFormUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text('관심 등록'),
            ),
            const SizedBox(height: 8),
            Text(
              '앱 밖에서 따로 안내한다. 사도 앱에서 열리는 건 없다.',
              style: text.bodySmall?.copyWith(color: fg.withValues(alpha: 0.5)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BeadsPreview extends StatelessWidget {
  const _BeadsPreview();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 140,
        height: 140,
        child: CustomPaint(painter: _BeadsPainter()),
      );
}

class _BeadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 8;
    final paint = Paint()..color = Tokens.temple;
    for (var i = 0; i < 21; i++) {
      final angle = (i / 21) * 2 * math.pi - math.pi / 2;
      final p = center +
          Offset(radius * math.cos(angle), radius * math.sin(angle));
      // 첫 알(모주)만 조금 크게.
      canvas.drawCircle(p, i == 0 ? 7 : 5, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
