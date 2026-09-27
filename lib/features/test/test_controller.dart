import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/content/models.dart';
import '../../data/db/database.dart';
import 'scorer.dart';

class TestFlowState {
  /// 문항 ID → 방향, 또는 null(건너뜀).
  final Map<String, String?> answers;

  /// 노출한 순서대로의 문항 (기본 16 + 심화).
  final List<TestQuestion> asked;

  /// 심화 단계에 들어갔는가 (진행 표시를 점선 염주로 바꾼다).
  final bool inDeep;
  final bool finished;

  const TestFlowState({
    this.answers = const {},
    this.asked = const [],
    this.inDeep = false,
    this.finished = false,
  });

  TestFlowState copyWith({
    Map<String, String?>? answers,
    List<TestQuestion>? asked,
    bool? inDeep,
    bool? finished,
  }) =>
      TestFlowState(
        answers: answers ?? this.answers,
        asked: asked ?? this.asked,
        inDeep: inDeep ?? this.inDeep,
        finished: finished ?? this.finished,
      );

  List<String> get shownDeepIds =>
      asked.where((q) => q.deep).map((q) => q.id).toList();
}

class TestController extends Notifier<TestFlowState> {
  @override
  TestFlowState build() => const TestFlowState();

  TestContent? get _content => ref.read(contentProvider).value?.test;

  /// 기본 16문항을 순서대로 깔고 시작한다 (FR-6.1).
  void start() {
    final content = _content;
    if (content == null) return;
    state = TestFlowState(asked: content.baseQuestions);
  }

  void answer(String questionId, String? direction) {
    state = state.copyWith(
      answers: {...state.answers, questionId: direction},
    );
  }

  /// 다음 문항 인덱스. 더 없으면 null (결과로 간다).
  /// 기본 문항이 끝나면 심화 제안 여부를 판단한다 (FR-6.3).
  int? advanceFrom(int index) {
    final content = _content;
    if (content == null) return null;

    final nextIndex = index + 1;
    if (nextIndex < state.asked.length) return nextIndex;

    final outcome = TestScorer(content).score(state.answers);
    // 심화는 경향·유보에서만 제안한다.
    if (!outcome.suggestsDeep) return null;

    final next = DeepFlow(content).next(
      answers: state.answers,
      shownDeepIds: state.shownDeepIds,
    );
    if (next == null) return null;

    state = state.copyWith(asked: [...state.asked, next], inDeep: true);
    return nextIndex;
  }

  /// 심화 거절 (FR-6.3 종료 조건).
  void declineDeep() => state = state.copyWith(finished: true);

  TestOutcome? currentOutcome() {
    final content = _content;
    if (content == null) return null;
    return TestScorer(content).score(state.answers);
  }

  /// 결과를 저장한다. 프로필 적용은 사용자가 따로 고른다 (FR-6.7).
  Future<void> save(TestOutcome outcome) async {
    final db = ref.read(databaseProvider);
    await db.into(db.testResults).insert(
          TestResultsCompanion.insert(
            takenAt: DateTime.now(),
            answersJson: jsonEncode(state.answers),
            state: outcome.state.name,
            typeId: Value(outcome.typeId),
            gTop: Value(outcome.gTop),
            aTop: Value(outcome.aTop),
            auxiliaryJson: Value(jsonEncode(outcome.auxiliary)),
            recoveryJson: Value(jsonEncode(outcome.recovery)),
          ),
        );
    await ref.read(analyticsProvider).log('test_complete', {
      'state': outcome.state.name,
      'deepAnswered':
          state.shownDeepIds.where((id) => state.answers[id] != null).length,
      'skipped': outcome.skippedCount,
    });
  }

  /// 프로필 적용 — 기록·절·법명 뒷 글자는 유지된다 (FR-6.7).
  Future<void> applyToProfile(TestOutcome outcome, {String? recoveryChoice}) async {
    final repo = ref.read(profileRepositoryProvider);
    final recovery = recoveryChoice ??
        (outcome.recovery.length == 1 ? outcome.recovery.first : null);
    await repo.setRecoveryPref(recovery);
    if (outcome.typeId != null) {
      await repo.setCharacter(outcome.typeId!);
    }
  }

  void reset() => state = const TestFlowState();
}

final testControllerProvider =
    NotifierProvider<TestController, TestFlowState>(TestController.new);
