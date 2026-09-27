import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../temple/temple_stage.dart';

/// 첫 완주 후 1회 제안. 건너뛰기 가능하고, 기본 캐릭터·법명 없음으로도
/// 모든 기능이 동작한다 (FR-1.3).
class CharacterOnboardScreen extends ConsumerStatefulWidget {
  const CharacterOnboardScreen({super.key});

  @override
  ConsumerState<CharacterOnboardScreen> createState() =>
      _CharacterOnboardScreenState();
}

class _CharacterOnboardScreenState
    extends ConsumerState<CharacterOnboardScreen> {
  String? _first;

  Future<void> _finish({bool skip = false}) async {
    final repo = ref.read(profileRepositoryProvider);
    if (!skip && _first != null) {
      await repo.setDharmaFirst(_first);
    }
    await repo.markCharacterOnboardShown();
    if (!mounted) return;
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).value;
    final last = dharmaLastSyllable(profile?.creditedDays ?? 1) ?? '견';
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text('이름 하나 줄까.', style: text.displayMedium),
              const SizedBox(height: 8),
              Text('안 받아도 된다. 나중에 설정에서 바꿔도 된다.',
                  style: text.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55))),
              const SizedBox(height: 28),
              for (final entry in kDharmaFirstSyllables.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: () => setState(() => _first = entry.key),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _first == entry.key
                          ? Tokens.saffron.withValues(alpha: 0.16)
                          : null,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('${entry.key}$last — ${entry.value}'),
                    ),
                  ),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _first == null ? null : () => _finish(),
                child: Text(_first == null ? '하나 골라라' : '$_first$last 로 하겠다'),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => _finish(skip: true),
                  child: const Text('건너뛰기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
