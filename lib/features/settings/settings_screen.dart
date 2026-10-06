import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/database.dart';
import '../home/home_controller.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: Tokens.gutter),
          children: [
            const _SectionLabel('음성 안내'),
            for (final entry in const {
              'none': '없음',
              'minimal': '최소',
              'default': '기본',
            }.entries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(entry.value),
                trailing: voice == entry.key
                    ? const Icon(Icons.check, color: Tokens.saffron)
                    : null,
                onTap: () => repo.setSetting(SettingKeys.voice, entry.key),
              ),

            const _SectionLabel('알림'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('다시 오라는 알림'),
              subtitle: const Text('동의하면 다음 날 1회, 이후 주 1회 이하.'),
              value: consents[ConsentKeys.notifications] != null,
              onChanged: (v) async {
                if (v) {
                  await ref.read(notificationServiceProvider).requestPermission();
                }
                await repo.setConsent(ConsentKeys.notifications, v);
                if (!v) await ref.read(notificationServiceProvider).cancelRevisit();
              },
            ),

            const _SectionLabel('수행'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('삼배 의식'),
              value: settings[SettingKeys.sambaeRitual] == true,
              onChanged: (v) => repo.setSetting(SettingKeys.sambaeRitual, v),
            ),
            if (Flags.sensorSelectable)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('감지 방식'),
                subtitle: Text(
                    settings[SettingKeys.detection] as String? ?? 'timer'),
              ),

            const _SectionLabel('기록'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('숫자 가리기'),
              subtitle: const Text('인정일·연속 숫자를 감춘다.'),
              value: settings[SettingKeys.hideNumbers] == true,
              onChanged: (v) => repo.setSetting(SettingKeys.hideNumbers, v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('기록을 기기에 저장'),
              subtitle: const Text('서버로 보내지 않는다.'),
              value: consents[ConsentKeys.recordStorage] != null,
              onChanged: (v) => repo.setConsent(ConsentKeys.recordStorage, v),
            ),

            const _SectionLabel('그 밖에'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('프로필'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.profile),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('증표'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.tokens),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('출처'),
              subtitle: const Text('앱에 쓴 소리·그림을 만든 사람들.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.credits),
            ),

            // 디버그 빌드에서만 보인다. 옷장을 눌러보려면 공덕이 필요하다.
            if (kDebugMode) ...[
              const _SectionLabel('디버그'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('공덕 $kDebugStartingMerit 더 받기'),
                subtitle: Text('지금 공덕 ${profile.merit}'),
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

            const _SectionLabel('데이터'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('데이터 삭제',
                  style: TextStyle(color: Tokens.seal)),
              subtitle: const Text('기기에 있는 전부. 되돌릴 수 없다.'),
              onTap: () => _confirmWipe(context, ref),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmWipe(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('전부 지울까'),
        content: const Text('기록·번뇌·테스트 결과·절이 모두 사라진다. 되돌릴 수 없다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('아니'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('지운다',
                style: TextStyle(color: Tokens.seal)),
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
