import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../data/content/models.dart';

/// 말씀의 뿌리 3단 펼치기 (FR-5.2).
/// reviewStatus == public 항목만 여기까지 온다 (FR-5.1).
/// 읽기·펼침은 인정일·성장에 영향을 주지 않는다 (FR-5.4).
class RootScreen extends ConsumerStatefulWidget {
  const RootScreen({super.key, required this.rootId});
  final String rootId;

  @override
  ConsumerState<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends ConsumerState<RootScreen> {
  /// 1 = 한마디, 2 = 해설, 3 = 말씀.
  int _depth = 1;

  void _expand() {
    if (_depth >= 3) return;
    setState(() => _depth++);
    ref.read(analyticsProvider).log('root_open', {
      'rootId': widget.rootId,
      'depth': _depth,
    });
  }

  @override
  Widget build(BuildContext context) {
    final bundle = ref.watch(contentProvider).value;
    final root = bundle?.rootById(widget.rootId);
    final text = Theme.of(context).textTheme;

    if (bundle == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (root == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('말씀의 뿌리')),
        body: const Center(child: Text('아직 열리지 않은 말이다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('말씀의 뿌리')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Tokens.gutter),
          children: [
            Text(root.seonsaLine, style: text.displayMedium),
            const SizedBox(height: 24),

            if (_depth == 1)
              OutlinedButton(onPressed: _expand, child: const Text('왜 그런데')),

            if (_depth >= 2) ...[
              Text(root.plainExplanation,
                  style: text.bodyLarge?.copyWith(height: 1.7)),
              const SizedBox(height: 24),
              if (_depth == 2)
                OutlinedButton(
                    onPressed: _expand, child: const Text('어디서 나온 말인데')),
            ],

            if (_depth >= 3) _ScriptureBlock(root: root),

            if (_depth >= 2) ...[
              const SizedBox(height: 32),
              if (root.smallAction != null)
                FilledButton(
                  onPressed: () {
                    ref.read(analyticsProvider).log(
                        'root_ack', {'rootId': root.id, 'ack': 'yes'});
                    context.push(_linkToRoute(root.smallAction!.link));
                  },
                  child: Text(root.smallAction!.text),
                ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () =>
                    context.push('${Routes.sessionSetup}?prefillWorry=1&len=180'),
                child: const Text('한 줄 적고 3분'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// roots.json의 link는 "session_setup?..." 형태다.
  String _linkToRoute(String link) {
    if (link.startsWith('session_setup')) {
      final q = link.contains('?') ? link.substring(link.indexOf('?')) : '';
      return '${Routes.sessionSetup}$q';
    }
    return Routes.sessionSetup;
  }
}

class _ScriptureBlock extends StatelessWidget {
  const _ScriptureBlock({required this.root});
  final RootItem root;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final fg = Theme.of(context).colorScheme.onSurface;
    final s = root.scripture;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: fg.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: fg.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.paraphraseKo,
                  style: text.headlineMedium?.copyWith(height: 1.6)),
              const SizedBox(height: 14),
              Text('${s.name} ${s.ref}',
                  style: text.bodyMedium
                      ?.copyWith(color: fg.withValues(alpha: 0.7))),
              const SizedBox(height: 4),
              // 의역임을 숨기지 않는다 (FR-5.2).
              Text('현대어로 풀었다',
                  style: text.bodySmall
                      ?.copyWith(color: fg.withValues(alpha: 0.5))),
            ],
          ),
        ),
        if (root.originalContext != null) ...[
          const SizedBox(height: 20),
          Text('맥락', style: text.titleLarge),
          const SizedBox(height: 6),
          Text(root.originalContext!, style: text.bodyLarge),
        ],
        if (root.traditionNote != null) ...[
          const SizedBox(height: 20),
          Text('전통 노트', style: text.titleLarge),
          const SizedBox(height: 6),
          Text(root.traditionNote!, style: text.bodyLarge),
        ],
        if (s.sourceUrl != null) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () async {
              final uri = Uri.parse(s.sourceUrl!);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('원문 보기'),
          ),
          if (s.sourceNote != null)
            Text(s.sourceNote!,
                style: text.bodySmall
                    ?.copyWith(color: fg.withValues(alpha: 0.5))),
        ],
      ],
    );
  }
}
