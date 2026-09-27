import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../data/content/models.dart';
import '../session/session_controller.dart';

/// 위기 안내 E-10 (SA-1). 평문이고, 선사 캐릭터는 등장하지 않는다.
class SafetyScreen extends ConsumerStatefulWidget {
  const SafetyScreen({super.key});

  @override
  ConsumerState<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends ConsumerState<SafetyScreen> {
  bool _showContacts = false;

  /// 「아니에요, 계속할게요」 — 일반 흐름 복귀.
  /// 그 세션은 인정·안내 대사만 나온다 (SA-3).
  Future<void> _continue() async {
    await ref.read(analyticsProvider).log('safety_continue');
    ref.read(sessionControllerProvider.notifier).enterReady();
    if (!mounted) return;
    context.pushReplacement(Routes.sessionReady);
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider).value;
    final safety = content?.safety ?? SafetyContent.fallback();
    final text = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Tokens.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(safety.screen.title, style: text.displayMedium),
                const SizedBox(height: 16),
                Text(safety.screen.body,
                    style: text.bodyLarge?.copyWith(height: 1.6)),
                const SizedBox(height: 24),
                if (_showContacts)
                  Expanded(
                    child: ListView(
                      children: [
                        for (final c in safety.contacts)
                          _ContactTile(contact: c),
                      ],
                    ),
                  )
                else
                  const Spacer(),
                if (!_showContacts)
                  FilledButton(
                    onPressed: () => setState(() => _showContacts = true),
                    child: Text(safety.screen.primaryButton),
                  ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _continue,
                  child: Text(safety.screen.secondaryButton),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref.read(sessionControllerProvider.notifier).reset();
                    context.go(Routes.home);
                  },
                  child: const Text('홈으로'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.contact});
  final SafetyContact contact;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      contact.number,
      if (contact.hours != null) contact.hours,
      if (contact.note != null) contact.note,
    ].whereType<String>().join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
      child: ListTile(
        title: Text(contact.name),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.call_outlined),
        onTap: () async {
          final uri = Uri(
            scheme: 'tel',
            path: contact.number.replaceAll(RegExp(r'[^0-9+]'), ''),
          );
          if (await canLaunchUrl(uri)) await launchUrl(uri);
        },
      ),
    );
  }
}
