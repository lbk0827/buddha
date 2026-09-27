import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/flags.dart';
import '../../core/time_utils.dart';
import '../../data/repositories/session_repository.dart';
import 'session_timing.dart';

/// 대기 → 준비 → 수행중 → (중단 선택 / 일시정지 → 유예) → 종료 (FR-2).
enum SessionPhase { idle, ready, running, paused, interruptChoice, done }

/// 세션 설정 화면에서 확정하는 값 (FR-2.1).
class SessionSetup {
  final int targetSec;
  final String? worryText;
  final String? worryChip;
  final bool repeatFlag;
  final bool audioOn;

  const SessionSetup({
    this.targetSec = 180,
    this.worryText,
    this.worryChip,
    this.repeatFlag = false,
    this.audioOn = false,
  });

  SessionSetup copyWith({
    int? targetSec,
    String? Function()? worryText,
    String? Function()? worryChip,
    bool? repeatFlag,
    bool? audioOn,
  }) =>
      SessionSetup(
        targetSec: targetSec ?? this.targetSec,
        worryText: worryText != null ? worryText() : this.worryText,
        worryChip: worryChip != null ? worryChip() : this.worryChip,
        repeatFlag: repeatFlag ?? this.repeatFlag,
        audioOn: audioOn ?? this.audioOn,
      );
}

class SessionState {
  final SessionPhase phase;
  final SessionSetup setup;
  final int? sessionId;
  final DateTime? startedAt;
  final List<ExcludedInterval> excluded;

  /// 위기 신호는 입력 시점에 판정한다 (SA-1).
  final bool safetyFlagged;

  /// 종료 후 완료 화면이 쓰는 결과.
  final SessionFinishResult? result;

  const SessionState({
    this.phase = SessionPhase.idle,
    this.setup = const SessionSetup(),
    this.sessionId,
    this.startedAt,
    this.excluded = const [],
    this.safetyFlagged = false,
    this.result,
  });

  SessionState copyWith({
    SessionPhase? phase,
    SessionSetup? setup,
    int? sessionId,
    DateTime? startedAt,
    List<ExcludedInterval>? excluded,
    bool? safetyFlagged,
    SessionFinishResult? result,
  }) =>
      SessionState(
        phase: phase ?? this.phase,
        setup: setup ?? this.setup,
        sessionId: sessionId ?? this.sessionId,
        startedAt: startedAt ?? this.startedAt,
        excluded: excluded ?? this.excluded,
        safetyFlagged: safetyFlagged ?? this.safetyFlagged,
        result: result ?? this.result,
      );

  int practicedAt(DateTime now) => startedAt == null
      ? 0
      : practicedSeconds(startedAt: startedAt!, now: now, excluded: excluded);

  int remainingAt(DateTime now) {
    final left = setup.targetSec - practicedAt(now);
    return left > 0 ? left : 0;
  }

  bool reachedTargetAt(DateTime now) => practicedAt(now) >= setup.targetSec;
}

class SessionController extends Notifier<SessionState> {
  Timer? _ticker;

  @override
  SessionState build() {
    ref.onDispose(() => _ticker?.cancel());
    return const SessionState();
  }

  void updateSetup(SessionSetup setup) =>
      state = state.copyWith(setup: setup, phase: SessionPhase.idle);

  void setSafetyFlag(bool flagged) =>
      state = state.copyWith(safetyFlagged: flagged);

  void enterReady() => state = state.copyWith(phase: SessionPhase.ready);

  /// 준비 화면에서 60초 안에 확인이 없으면 대기로 복귀한다 (FR-2.2).
  void abandonReady() => state = const SessionState();

  /// 엎음 확인. 진동 1회 → 시작 타임스탬프 → 종료 예정 시각 알림 예약 (FR-2.3).
  Future<void> confirmLayDown() async {
    if (state.phase == SessionPhase.running) return;
    final now = DateTime.now();
    final notifications = ref.read(notificationServiceProvider);
    await notifications.buzz();

    final detection = Flags.enableSensorA
        ? 'sensorA'
        : (Flags.enableAudioC && state.setup.audioOn ? 'sensorC' : 'timer');

    final session = await ref.read(sessionRepositoryProvider).start(
          startedAt: now,
          targetSec: state.setup.targetSec,
          detection: detection,
          audioOn: state.setup.audioOn,
          worryText: state.setup.worryText,
          worryChip: state.setup.worryChip,
          repeatFlag: state.setup.repeatFlag,
          safetyFlagged: state.safetyFlagged,
        );

    await notifications.scheduleSessionEnd(
      now.add(Duration(seconds: state.setup.targetSec)),
    );

    await ref.read(analyticsProvider).log('session_start', {
      'targetSec': state.setup.targetSec,
      'detection': detection,
      'audioOn': state.setup.audioOn,
      'chip': state.setup.worryChip,
    });

    state = state.copyWith(
      phase: SessionPhase.running,
      sessionId: session.id,
      startedAt: now,
      excluded: const [],
    );
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    // 화면 갱신용일 뿐이다. 시간 계산은 언제나 타임스탬프로 한다.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase != SessionPhase.running) return;
      if (state.reachedTargetAt(DateTime.now())) {
        complete();
      } else {
        state = state.copyWith();
      }
    });
  }

  /// 오디오 세션 중단 → 일시정지. 유예 중 음원은 재생하지 않는다 (FR-2.6).
  Future<void> pauseForAudioInterruption() async {
    if (state.phase != SessionPhase.running) return;
    await _openExcluded('audio');
    state = state.copyWith(phase: SessionPhase.paused);
  }

  Future<void> resumeFromPause() async {
    if (state.phase != SessionPhase.paused) return;
    await _closeExcluded();
    state = state.copyWith(phase: SessionPhase.running);
    await _rescheduleEnd();
  }

  /// 앱 전면 복귀 시 목표 미달이면 중단 선택 화면 (FR-2.5).
  /// 이 화면 체류 시간은 수행 시간에서 제외한다.
  Future<void> enterInterruptChoice() async {
    if (state.phase != SessionPhase.running) return;
    await _openExcluded('interruptChoice');
    state = state.copyWith(phase: SessionPhase.interruptChoice);
  }

  Future<void> resumeFromInterrupt() async {
    if (state.phase != SessionPhase.interruptChoice) return;
    await _closeExcluded();
    state = state.copyWith(phase: SessionPhase.running);
    await _rescheduleEnd();
    _startTicker();
  }

  Future<void> _openExcluded(String reason) async {
    if (state.excluded.any((e) => e.isOpen)) return;
    final next = [
      ...state.excluded,
      ExcludedInterval(from: DateTime.now(), reason: reason),
    ];
    state = state.copyWith(excluded: next);
    await _persistExcluded(next);
  }

  Future<void> _closeExcluded() async {
    final now = DateTime.now();
    final next = state.excluded
        .map((e) => e.isOpen ? e.close(now) : e)
        .toList(growable: false);
    state = state.copyWith(excluded: next);
    await _persistExcluded(next);
  }

  Future<void> _persistExcluded(List<ExcludedInterval> list) async {
    final id = state.sessionId;
    if (id == null) return;
    await ref.read(sessionRepositoryProvider).saveExcluded(id, list);
  }

  /// 제외 구간이 늘어난 만큼 종료 알림을 뒤로 민다.
  Future<void> _rescheduleEnd() async {
    if (state.startedAt == null) return;
    final at = scheduledEndAt(
      startedAt: state.startedAt!,
      targetSec: state.setup.targetSec,
      excluded: state.excluded,
      now: DateTime.now(),
    );
    await ref.read(notificationServiceProvider).scheduleSessionEnd(at);
  }

  Future<void> complete() => _finish(completed: true);

  /// 「오늘은 여기까지」 또는 60초 무응답 (FR-2.5).
  Future<void> stopHere() => _finish(completed: false);

  Future<void> _finish({required bool completed}) async {
    final id = state.sessionId;
    final startedAt = state.startedAt;
    if (id == null || startedAt == null) return;

    _ticker?.cancel();
    _ticker = null;

    final now = DateTime.now();
    final excluded =
        state.excluded.map((e) => e.isOpen ? e.close(now) : e).toList();
    var practiced =
        practicedSeconds(startedAt: startedAt, now: now, excluded: excluded);
    // 완주 판정이면 목표를 넘겨 기록하지 않는다.
    if (completed && practiced > state.setup.targetSec) {
      practiced = state.setup.targetSec;
    }

    final notifications = ref.read(notificationServiceProvider);
    await notifications.cancelSessionEnd();
    if (completed) await notifications.buzz();

    final result = await ref.read(sessionRepositoryProvider).finish(
          sessionId: id,
          endedAt: now,
          practicedSec: practiced,
          completed: completed,
        );

    await ref.read(analyticsProvider).log('session_end', {
      'practicedSec': practiced,
      'outcome': completed ? 'completed' : 'interrupted',
      'detection': result.session.detection,
    });

    _invalidateAggregates();

    state = state.copyWith(
      phase: SessionPhase.done,
      excluded: excluded,
      result: result,
    );
  }

  /// 앱 강제 종료 후 재실행 시 진행 중 세션 복원 (QA 체크리스트).
  Future<void> restoreIfAny() async {
    final repo = ref.read(sessionRepositoryProvider);
    final active = await repo.activeSession();
    if (active == null) return;

    final excluded = decodeExcluded(active.excludedJson);
    final now = DateTime.now();
    final practiced = practicedSeconds(
        startedAt: active.startedAt, now: now, excluded: excluded);

    state = SessionState(
      phase: SessionPhase.running,
      setup: SessionSetup(
        targetSec: active.targetSec,
        worryText: active.worryText,
        worryChip: active.worryChip,
        repeatFlag: active.repeatFlag,
        audioOn: active.audioOn,
      ),
      sessionId: active.id,
      startedAt: active.startedAt,
      excluded: excluded,
      safetyFlagged: active.safetyFlagged,
    );

    // 자리를 비운 사이 목표를 넘겼으면 완주로 확정한다.
    if (practiced >= active.targetSec) {
      await complete();
    } else if (now.difference(active.startedAt) > kMaxInterruptionBeforeEnd) {
      // 10분 넘게 방치된 세션은 중단으로 닫는다 (FR-2.6).
      await stopHere();
    } else {
      await enterInterruptChoice();
    }
  }

  void reset() {
    _ticker?.cancel();
    _ticker = null;
    state = const SessionState();
  }

  void _invalidateAggregates() {
    ref.invalidate(creditedDaysProvider);
    ref.invalidate(totalPracticedProvider);
    ref.invalidate(recentSessionsProvider);
  }
}

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

/// 완료 화면의 인정 문구 (FR-2.8).
String completionLine({required int practicedSec, required bool heavyChip}) {
  final t = formatDuration(practicedSec);
  // 칩 "많이 힘듦"에서는 유머 없이 (FR-3.8).
  return heavyChip ? '$t 뒀다. 그거면 됐다.' : '$t 뒀다. 오늘은 여기까지.';
}
