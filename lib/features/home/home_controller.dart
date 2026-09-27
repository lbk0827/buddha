import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/time_utils.dart';
import '../../data/content/content_repository.dart';
import '../../data/content/models.dart';
import '../../data/repositories/dialogue_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../dialogue/dialogue_selector.dart';
import '../temple/temple_stage.dart';

class HomeState {
  final String greeting;
  final DialogueItem? dailyCard;
  final RootItem? dailyCardRoot;
  final int stage;
  final int creditedDays;
  final bool lanternBright;
  final bool fallenLeaves;
  final bool firstVisit;
  final bool rootsEnabled;

  const HomeState({
    required this.greeting,
    required this.dailyCard,
    required this.dailyCardRoot,
    required this.stage,
    required this.creditedDays,
    required this.lanternBright,
    required this.fallenLeaves,
    required this.firstVisit,
    required this.rootsEnabled,
  });
}

/// 홈 진입 시 인사·오늘의 한마디·마당 상태를 한 번에 만든다 (FR-1.1, FR-1.2, FR-3.5).
final homeStateProvider = FutureProvider<HomeState>((ref) async {
  final content = await ref.watch(contentProvider.future);
  final profileRepo = ref.watch(profileRepositoryProvider);
  final dialogueRepo = ref.watch(dialogueRepositoryProvider);
  final profile = await profileRepo.ensure();

  final now = DateTime.now();
  final firstVisit = profile.lastVisitAt == null;

  final leaves = shouldShowFallenLeaves(
        lastVisitAt: profile.lastVisitAt,
        now: now,
      ) &&
      profile.leavesClearedDate != todayKey();

  // 당일 유효 세션이 이미 있으면 등이 밝다 (FR-4.3).
  final sessions = await ref.watch(sessionRepositoryProvider).recentSessions(limit: 20);
  final lanternBright = sessions.any((s) =>
      s.localDate == todayKey() && s.practicedSec >= 60);

  final greeting = _pickGreeting(content, firstVisit);
  final card = await _pickDailyCard(content, dialogueRepo);

  // 방문 기록은 위 판정이 모두 끝난 뒤에 쓴다.
  // 먼저 쓰면 첫 방문 인사와 낙엽 판정이 자기 자신에 의해 지워진다.
  await profileRepo.touchVisit(now);

  return HomeState(
    greeting: greeting,
    dailyCard: card,
    dailyCardRoot:
        content.rootsLinkEnabled ? content.rootById(card?.rootId) : null,
    stage: stageForCreditedDays(profile.creditedDays),
    creditedDays: profile.creditedDays,
    lanternBright: lanternBright,
    fallenLeaves: leaves,
    firstVisit: firstVisit,
    rootsEnabled: content.rootsLinkEnabled,
  );
});

String _pickGreeting(ContentBundle content, bool firstVisit) {
  final items = content.forScreen('home_greeting');
  if (items.isEmpty) {
    return firstVisit ? '왔네. 천천히 봐라. 급한 건 없다.' : '왔네.';
  }
  // 첫 방문 전용 문구가 있으면 그것, 아니면 나머지에서 고른다 (FR-1.2).
  final firstOnly =
      items.where((d) => d.requires.contains('firstSession')).toList();
  final pool = firstVisit
      ? (firstOnly.isNotEmpty ? firstOnly : items)
      : items.where((d) => !d.requires.contains('firstSession')).toList();
  if (pool.isEmpty) return firstVisit ? '왔네. 천천히 봐라. 급한 건 없다.' : '왔네.';
  return pool[Random().nextInt(pool.length)].text;
}

/// 하루 1개. 이미 오늘 뽑았으면 같은 것을 유지한다 (FR-3.5).
Future<DialogueItem?> _pickDailyCard(
  ContentBundle content,
  DialogueRepository dialogueRepo,
) async {
  final pool = content.forPool('daily');
  if (pool.isEmpty) return null;

  final poolIds = pool.map((d) => d.id).toSet();
  final existingId = await dialogueRepo.todaysIdAmong(poolIds);
  if (existingId != null) {
    for (final d in pool) {
      if (d.id == existingId) return d;
    }
  }

  const selector = DialogueSelector();
  final picked = selector.select(
    candidates: pool,
    ctx: DialogueContext(
      now: DateTime.now(),
      recentExposures: await dialogueRepo.recent(),
      todayExposures: await dialogueRepo.today(),
    ),
    fallbacks: content.forScreen('fallback'),
  );
  if (picked != null) await dialogueRepo.record(picked);
  return picked;
}

/// 「1분 쓸기」 (FR-4.4).
Future<void> sweepLeaves(WidgetRef ref) async {
  await ref.read(profileRepositoryProvider).clearLeaves(todayKey());
  ref.invalidate(homeStateProvider);
}

/// 재방문 알림 예약 — 별도 동의 후 다음 날 1회 (FR-7.2).
Future<void> scheduleRevisitIfConsented(WidgetRef ref) async {
  final repo = ref.read(profileRepositoryProvider);
  if (!await repo.hasConsent(ConsentKeys.notifications)) return;
  final profile = await repo.ensure();
  final settings = repo.settingsOf(profile);
  if (settings[SettingKeys.revisitNotifications] == false) return;

  final tomorrow = DateTime.now().add(const Duration(days: 1));
  final at = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 20);
  await ref
      .read(notificationServiceProvider)
      .scheduleRevisit(at, '어제 등, 아직 켜져 있다.');
}
