import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/time_utils.dart';
import '../../data/content/content_repository.dart';
import '../../data/content/models.dart';
import '../../data/repositories/dialogue_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../gate/temple_gate.dart';
import '../ordination/dharma_rank.dart';
import '../tokens/token_catalog.dart';

/// v3 「절」 탭이 한 번에 필요한 것들.
class TempleHomeState {
  final String greeting;
  final DialogueItem? dailyCard;

  /// 법명 전체 (예: 무념대사). 출가 전이면 null.
  final String? dharmaName;
  final String station;
  final bool ordained;

  final GateState gate;

  /// 오늘 엎어둔 시간(초).
  final int faceDownTodaySec;
  final int bowCount;
  final int burnedCount;
  final int burnedToday;
  final int merit;

  final PracticeStats stats;
  final Set<String> unlockedTokens;
  final TokenDef? nextToken;

  const TempleHomeState({
    required this.greeting,
    required this.dailyCard,
    required this.dharmaName,
    required this.station,
    required this.ordained,
    required this.gate,
    required this.faceDownTodaySec,
    required this.bowCount,
    required this.burnedCount,
    required this.burnedToday,
    required this.merit,
    required this.stats,
    required this.unlockedTokens,
    required this.nextToken,
  });

  /// 108배 진행. 108을 넘기면 다시 0부터 센다.
  int get bowsInCycle => bowCount % 108;
}

final homeStateProvider = FutureProvider<TempleHomeState>((ref) async {
  final content = await ref.watch(contentProvider.future);
  final profileRepo = ref.watch(profileRepositoryProvider);
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final worryRepo = ref.watch(worryRepositoryProvider);
  final tokenRepo = ref.watch(tokenRepositoryProvider);

  final profile = await profileRepo.ensure();
  final now = DateTime.now();
  final firstVisit = profile.lastVisitAt == null;

  final creditedKeys = await sessionRepo.creditedDateKeys();
  final gate = GateState(
    visitedToday: creditedKeys.contains(todayKey()),
    remaining: untilGateCloses(now),
    streakDays: gateStreak(
      creditedDateKeys: creditedKeys,
      now: now,
      keyOf: localDateKey,
    ),
  );

  final stats = PracticeStats(
    burnedCount: profile.burnedCount,
    bowCount: profile.bowCount,
    creditedDays: gate.streakDays,
    merit: profile.merit,
    faceDownSec: profile.faceDownSec,
  );

  final unlocked = await tokenRepo.unlockedIds();
  // 조건을 채운 증표는 조용히 열어둔다. 연출은 증표 탭에서 한다.
  for (final t in newlyUnlocked(stats, unlocked)) {
    await tokenRepo.unlock(t.id);
    unlocked.add(t.id);
  }

  final rank = rankForBows(profile.bowCount);
  final base = profile.dharmaName;

  final state = TempleHomeState(
    greeting: _pickGreeting(content, firstVisit),
    dailyCard: await _pickDailyCard(content, ref.watch(dialogueRepositoryProvider)),
    dharmaName: base == null ? null : rank.nameFor(base),
    station: rank.station,
    ordained: profile.ordainedAt != null,
    gate: gate,
    faceDownTodaySec: await sessionRepo.faceDownSecondsOn(todayKey()),
    bowCount: profile.bowCount,
    burnedCount: profile.burnedCount,
    burnedToday: await worryRepo.burnedToday(),
    merit: profile.merit,
    stats: stats,
    unlockedTokens: unlocked,
    nextToken: nextToUnlock(stats, unlocked),
  );

  // 방문 기록은 위 판정이 모두 끝난 뒤에 쓴다.
  await profileRepo.touchVisit(now);
  return state;
});

String _pickGreeting(ContentBundle content, bool firstVisit) {
  final items = content.forScreen('home_greeting');
  if (items.isEmpty) {
    return firstVisit ? '왔네. 천천히 봐라. 급한 건 없다.' : '왔네.';
  }
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
  DialogueRepository repo,
) async {
  final pool = content.forPool('daily');
  if (pool.isEmpty) return null;

  final existingId = await repo.todaysIdAmong(pool.map((d) => d.id).toSet());
  if (existingId != null) {
    for (final d in pool) {
      if (d.id == existingId) return d;
    }
  }
  final picked = pool[Random().nextInt(pool.length)];
  await repo.record(picked);
  return picked;
}

/// 재방문 알림 예약 — 별도 동의 후 다음 날 1회 (FR-7.2).
Future<void> scheduleRevisitIfConsented(WidgetRef ref) async {
  final repo = ref.read(profileRepositoryProvider);
  if (!await repo.hasConsent(ConsentKeys.notifications)) return;
  final profile = await repo.ensure();
  if (repo.settingsOf(profile)[SettingKeys.revisitNotifications] == false) {
    return;
  }
  final tomorrow = DateTime.now().add(const Duration(days: 1));
  final at = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 20);
  await ref
      .read(notificationServiceProvider)
      .scheduleRevisit(at, '어제 등, 아직 켜져 있다.');
}
