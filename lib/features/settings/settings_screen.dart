import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/database.dart';
import '../home/home_controller.dart';
import '../../l10n/l10n.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/flags.dart';
import '../../data/repositories/profile_repository.dart';

/// 설정 (FR-8.3).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    final repo = ref.watch(profileRepositoryProvider);

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final settings = repo.settingsOf(profile);
    final consents = repo.consentsOf(profile);
    final voice = settings[SettingKeys.voice] as String? ?? 'none';
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Tokens.gutter),
          children: [
            _SectionLabel(l10n.settingsSectionVoice),
            // 키는 저장되는 설정값이라 그대로 둔다.
            for (final entry in {
              'none': l10n.settingsVoiceNone,
              'minimal': l10n.settingsVoiceMinimal,
              'default': l10n.settingsVoiceDefault,
            }.entries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(entry.value),
                trailing: voice == entry.key
                    ? const Icon(Icons.check, color: Tokens.saffron)
                    : null,
                onTap: () => repo.setSetting(SettingKeys.voice, entry.key),
              ),

            _SectionLabel(l10n.settingsSectionNotifications),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsRevisitTitle),
              subtitle: Text(l10n.settingsRevisitSubtitle),
              value: consents[ConsentKeys.notifications] != null,
              onChanged: (v) async {
                if (v) {
                  await ref.read(notificationServiceProvider).requestPermission();
                }
                await repo.setConsent(ConsentKeys.notifications, v);
                if (!v) await ref.read(notificationServiceProvider).cancelRevisit();
              },
            ),

            _SectionLabel(l10n.settingsSectionPractice),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsSambaeTitle),
              value: settings[SettingKeys.sambaeRitual] == true,
              onChanged: (v) => repo.setSetting(SettingKeys.sambaeRitual, v),
            ),
            if (Flags.sensorSelectable)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.settingsDetectionTitle),
                subtitle: Text(
                    settings[SettingKeys.detection] as String? ?? 'timer'),
              ),

            _SectionLabel(l10n.settingsSectionRecords),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsHideNumbersTitle),
              subtitle: Text(l10n.settingsHideNumbersSubtitle),
              value: settings[SettingKeys.hideNumbers] == true,
              onChanged: (v) => repo.setSetting(SettingKeys.hideNumbers, v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsStoreRecordsTitle),
              subtitle: Text(l10n.settingsStoreRecordsSubtitle),
              value: consents[ConsentKeys.recordStorage] != null,
              onChanged: (v) => repo.setConsent(ConsentKeys.recordStorage, v),
            ),

            _SectionLabel(l10n.settingsSectionMore),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsProfileItem),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.profile),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsTokensItem),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.tokens),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsCreditsItem),
              subtitle: Text(l10n.settingsCreditsItemSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.credits),
            ),

            // 디버그 빌드에서만 보인다. 옷장을 눌러보려면 공덕이 필요하다.
            if (kDebugMode) ...[
              _SectionLabel(context.l10n.settingsDebugSection),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.settingsDebugAddMerit(kDebugStartingMerit)),
                subtitle: Text(context.l10n.settingsDebugCurrentMerit(profile.merit)),
                trailing: const Icon(Icons.add),
                onTap: () async {
                  final db = ref.read(databaseProvider);
                  await (db.update(db.profiles)..where((t) => t.id.equals(1)))
                      .write(ProfilesCompanion(
                    merit: Value(profile.merit + kDebugStartingMerit),
                  ));
                  ref.invalidate(homeStateProvider);
                },
              ),
            ],

            _SectionLabel(l10n.settingsSectionData),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsWipeTitle,
                  style: const TextStyle(color: Tokens.seal)),
              subtitle: Text(l10n.settingsWipeSubtitle),
              onTap: () => _confirmWipe(context, ref),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmWipe(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsWipeDialogTitle),
        content: Text(l10n.settingsWipeDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.settingsWipeCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.settingsWipeConfirm,
                style: const TextStyle(color: Tokens.seal)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await ref.read(databaseProvider).wipeAll();
    await ref.read(notificationServiceProvider).cancelAll();
    ref
      ..invalidate(creditedDaysProvider)
      ..invalidate(totalPracticedProvider)
      ..invalidate(recentSessionsProvider);

    if (!context.mounted) return;
    context.go(Routes.home);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 28, bottom: 4),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
        ),
      );
}
