import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../temple/temple_stage.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final repo = ref.watch(profileRepositoryProvider);
    final text = Theme.of(context).textTheme;

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final last = dharmaLastSyllable(profile.creditedDays);
    final dharma = (profile.dharmaFirst != null && last != null)
        ? '${profile.dharmaFirst}$last'
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Tokens.gutter),
          children: [
            Text(dharma ?? '법명 없음', style: text.displayMedium),
            const SizedBox(height: 4),
            Text('인정일 ${profile.creditedDays}',
                style: text.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55))),
            const Divider(height: 40),
            Text('법명 앞 글자', style: text.titleLarge),
            const SizedBox(height: 4),
            Text('바꿔도 뒷 글자는 그대로다.',
                style: text.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55))),
            const SizedBox(height: 12),
            for (final entry in kDharmaFirstSyllables.entries)
              RadioGroupScope(
                selected: profile.dharmaFirst,
                onSelect: (v) => repo.setDharmaFirst(v),
                value: entry.key,
                label: '${entry.key}${last ?? ''} — ${entry.value}',
              ),
            const SizedBox(height: 12),
            if (profile.dharmaFirst != null)
              TextButton(
                onPressed: () => repo.setDharmaFirst(null),
                child: const Text('법명 없애기'),
              ),
          ],
        ),
      ),
    );
  }
}

/// 라디오 대신 쓰는 단순 선택 행. 탭 영역 44 이상을 보장한다.
class RadioGroupScope extends StatelessWidget {
  const RadioGroupScope({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.value,
    required this.label,
  });

  final String? selected;
  final ValueChanged<String> onSelect;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return InkWell(
      onTap: () => onSelect(value),
      child: Container(
        constraints: const BoxConstraints(minHeight: Tokens.minTap),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: isSelected
                  ? Tokens.saffron
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}
