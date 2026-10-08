import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/time_utils.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/steps/step_source.dart';

/// 하루 걸음 목표. 달력 막대가 가득 차는 기준이다.
const int kDailyStepGoal = 10000;

/// 달력 한 칸.
class CalendarDay {
  const CalendarDay({
    required this.date,
    required this.steps,
    required this.practicedSec,
    required this.credited,
  });

  final DateTime date;

  /// 걸음 수를 못 읽었으면 null.
  final int? steps;
  final int practicedSec;

  /// 인정일 — 그날 명상을 1분 넘게 했다.
  final bool credited;

  double get stepRatio =>
      steps == null ? 0 : (steps! / kDailyStepGoal).clamp(0.0, 1.0);
}

class CalendarMonth {
  const CalendarMonth({
    required this.month,
    required this.days,
    required this.stepsLinked,
  });

  /// 그 달 1일.
  final DateTime month;
  final List<CalendarDay> days;
  final bool stepsLinked;

  int get totalSteps => days.fold(0, (a, d) => a + (d.steps ?? 0));
  int get totalPracticedSec => days.fold(0, (a, d) => a + d.practicedSec);
}

/// 걸음 수 읽기를 허락받았는가.
final stepsLinkedProvider = Provider<bool>((ref) {
  final profile = ref.watch(profileProvider).value;
  if (profile == null) return false;
  return ref.watch(profileRepositoryProvider).settingsOf(profile)[
          SettingKeys.stepsLinked] ==
      true;
});

/// 걸음 수 연결. Health Connect 가 없으면 설치 화면을 연다.
/// 허락받으면 true.
Future<bool> linkSteps(WidgetRef ref) async {
  final source = ref.read(stepSourceProvider);
  final availability = await source.availability();
  if (availability == StepAvailability.needsInstall &&
      source is HealthStepSource) {
    await source.installHealthConnect();
    return false;
  }
  if (availability != StepAvailability.available) return false;
  final granted = await source.requestAccess();
  if (granted) {
    await ref
        .read(profileRepositoryProvider)
        .setSetting(SettingKeys.stepsLinked, true);
    ref.invalidate(calendarMonthProvider);
    ref.invalidate(todayStepsProvider);
  }
  return granted;
}

/// [month] 는 그 달 1일.
final calendarMonthProvider =
    FutureProvider.autoDispose.family<CalendarMonth, DateTime>((ref, month) async {
  final linked = ref.watch(stepsLinkedProvider);
  final sessions = ref.watch(sessionRepositoryProvider);

  final first = DateTime(month.year, month.month);
  final last = DateTime(month.year, month.month + 1, 0);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  // 앞날 걸음은 읽지 않는다.
  final stepsTo = last.isAfter(today) ? today : last;

  final practiced = await sessions.practicedSecondsByDay(
      localDateKey(first), localDateKey(last));
  final credited = await sessions.creditedDateKeys();
  final steps = linked && !first.isAfter(stepsTo)
      ? await ref.watch(stepSourceProvider).dailySteps(first, stepsTo)
      : const <String, int>{};

  return CalendarMonth(
    month: first,
    stepsLinked: linked,
    days: [
      for (var d = 1; d <= last.day; d++)
        () {
          final date = DateTime(month.year, month.month, d);
          final key = localDateKey(date);
          return CalendarDay(
            date: date,
            steps: steps[key],
            practicedSec: practiced[key] ?? 0,
            credited: credited.contains(key),
          );
        }(),
    ],
  );
});

/// 오늘 걸음 수. 연결 안 했거나 못 읽으면 null.
final todayStepsProvider = FutureProvider.autoDispose<int?>((ref) async {
  if (!ref.watch(stepsLinkedProvider)) return null;
  final now = DateTime.now();
  final steps = await ref.watch(stepSourceProvider).dailySteps(now, now);
  return steps[localDateKey(now)];
});
