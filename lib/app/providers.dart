import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/content/content_repository.dart';
import '../data/db/database.dart';
import '../data/repositories/dialogue_repository.dart';
import '../data/repositories/play_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/session_repository.dart';
import '../data/repositories/worry_repository.dart';
import '../features/safety/safety_detector.dart';
import '../services/notification_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final contentRepositoryProvider =
    Provider<ContentRepository>((ref) => ContentRepository());

/// 콘텐츠는 앱 시작 시 한 번 읽고 캐시한다.
final contentProvider = FutureProvider<ContentBundle>(
    (ref) => ref.watch(contentRepositoryProvider).load());

final sessionRepositoryProvider =
    Provider<SessionRepository>((ref) => SessionRepository(ref.watch(databaseProvider)));

final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => ProfileRepository(ref.watch(databaseProvider)));

final dialogueRepositoryProvider = Provider<DialogueRepository>(
    (ref) => DialogueRepository(ref.watch(databaseProvider)));

final worryRepositoryProvider =
    Provider<WorryRepository>((ref) => WorryRepository(ref.watch(databaseProvider)));

final playRepositoryProvider =
    Provider<PlayRepository>((ref) => PlayRepository(ref.watch(databaseProvider)));

final tokenRepositoryProvider =
    Provider<TokenRepository>((ref) => TokenRepository(ref.watch(databaseProvider)));

final analyticsProvider =
    Provider<AnalyticsLog>((ref) => AnalyticsLog(ref.watch(databaseProvider)));

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final s = NotificationService();
  s.init();
  return s;
});

final profileProvider =
    StreamProvider<Profile>((ref) => ref.watch(profileRepositoryProvider).watch());

final safetyDetectorProvider = Provider<SafetyDetector?>((ref) {
  final content = ref.watch(contentProvider).value;
  if (content == null) return null;
  return SafetyDetector(content.safety);
});

/// 기록 화면·홈에 쓰는 누적 값.
final creditedDaysProvider = FutureProvider<int>(
    (ref) => ref.watch(sessionRepositoryProvider).creditedDayCount());

final totalPracticedProvider = FutureProvider<int>(
    (ref) => ref.watch(sessionRepositoryProvider).totalPracticedSeconds());

final recentSessionsProvider = FutureProvider<List<Session>>(
    (ref) => ref.watch(sessionRepositoryProvider).recentSessions());
