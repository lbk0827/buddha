import 'dart:math';

import '../../data/content/models.dart';

/// 대사 선택기 입력. 순수 함수로 유지해 단위 테스트한다
/// (PRD 기술 아키텍처 · 대사 선택기).
class DialogueContext {
  /// 'work' | 'people' | 'money' | 'family' | 'body' | 'etc' | 'heavy'
  final String? chip;

  /// 위기 신호 감지 세션 (SA-1).
  final bool safetyFlagged;
  final bool firstSession;
  final int creditedDays;
  final int? practicedSec;

  /// 이번 세션에서 이미 노출한 대사들.
  final List<ExposureRecord> sessionExposures;

  /// 오늘 노출한 대사들 (하루 제한 계산용).
  final List<ExposureRecord> todayExposures;

  /// 최근 노출 이력 (repeatDays 계산용). shownAt 포함.
  final List<ExposureRecord> recentExposures;

  final DateTime now;

  const DialogueContext({
    this.chip,
    this.safetyFlagged = false,
    this.firstSession = false,
    this.creditedDays = 0,
    this.practicedSec,
    this.sessionExposures = const [],
    this.todayExposures = const [],
    this.recentExposures = const [],
    required this.now,
  });

  bool get isHeavy => chip == 'heavy';

  /// 유머 역할 대사를 전부 막는 상태 (FR-3.8, SA-1).
  bool get suppressesHumor => isHeavy || safetyFlagged;
}

class ExposureRecord {
  final String dialogueId;
  final DateTime shownAt;
  final DialogueRole role;
  final DialogueIntensity intensity;

  const ExposureRecord({
    required this.dialogueId,
    required this.shownAt,
    required this.role,
    required this.intensity,
  });
}

/// 세션당 강도 "중" 1개 (FR-3.6).
const int kMaxMidIntensityPerSession = 1;

/// 하루 관찰·질문 2개 (FR-3.6).
const int kMaxObserveQuestionPerDay = 2;

/// 위기 상태·많이 힘듦에서 허용되는 역할.
const Set<DialogueRole> kSafeRoles = {DialogueRole.ack, DialogueRole.guide};

class DialogueSelector {
  const DialogueSelector();

  /// [candidates]에서 규칙을 통과하는 대사 하나. 없으면 [fallbacks]에서,
  /// 그래도 없으면 null.
  DialogueItem? select({
    required List<DialogueItem> candidates,
    required DialogueContext ctx,
    List<DialogueItem> fallbacks = const [],
    Random? rng,
  }) {
    final eligible = filter(candidates, ctx);
    if (eligible.isNotEmpty) {
      return eligible[(rng ?? Random()).nextInt(eligible.length)];
    }
    // 폴백(D-)은 반복·강도 제한을 적용하지 않는다. 안 그러면 할 말이 없어진다.
    final safeFallbacks =
        fallbacks.where((d) => _passesSafety(d, ctx)).toList();
    if (safeFallbacks.isEmpty) return null;
    return safeFallbacks[(rng ?? Random()).nextInt(safeFallbacks.length)];
  }

  /// 규칙 통과 목록. 순서: forbidWhen → 안전 → requires → 반복 → 강도 → 하루 제한.
  List<DialogueItem> filter(List<DialogueItem> items, DialogueContext ctx) {
    final midUsed = ctx.sessionExposures
        .where((e) => e.intensity == DialogueIntensity.mid)
        .length;
    final observeQuestionUsed = ctx.todayExposures
        .where((e) =>
            e.role == DialogueRole.observe || e.role == DialogueRole.question)
        .length;

    return items.where((d) {
      if (!_passesForbidWhen(d, ctx)) return false;
      if (!_passesSafety(d, ctx)) return false;
      if (!_passesRequires(d, ctx)) return false;
      if (!_passesRepeat(d, ctx)) return false;

      if (d.intensity == DialogueIntensity.mid &&
          midUsed >= kMaxMidIntensityPerSession) {
        return false;
      }
      if ((d.role == DialogueRole.observe ||
              d.role == DialogueRole.question) &&
          observeQuestionUsed >= kMaxObserveQuestionPerDay) {
        return false;
      }
      return true;
    }).toList();
  }

  bool _passesForbidWhen(DialogueItem d, DialogueContext ctx) {
    for (final rule in d.forbidWhen) {
      if (rule == 'safety' && ctx.safetyFlagged) return false;
      if (rule.startsWith('chip:') && ctx.chip == rule.substring(5)) {
        return false;
      }
      if (rule == 'firstSession' && ctx.firstSession) return false;
    }
    return true;
  }

  /// 칩 "많이 힘듦"과 위기 상태에서는 인정·안내만 (FR-3.8, SA-1, SA-3).
  bool _passesSafety(DialogueItem d, DialogueContext ctx) {
    if (!ctx.suppressesHumor) return true;
    return kSafeRoles.contains(d.role);
  }

  bool _passesRequires(DialogueItem d, DialogueContext ctx) {
    for (final key in d.requires) {
      switch (key) {
        case 'practicedSec':
          if (ctx.practicedSec == null) return false;
        case 'firstSession':
          if (!ctx.firstSession) return false;
        case 'creditedDays':
          if (ctx.creditedDays <= 0) return false;
        case 'chip':
          if (ctx.chip == null) return false;
      }
    }
    return true;
  }

  /// 같은 ID는 repeatDays 안에 다시 나오지 않는다 (FR-3.5).
  bool _passesRepeat(DialogueItem d, DialogueContext ctx) {
    if (d.repeatDays <= 0) return true;
    final cutoff = ctx.now.subtract(Duration(days: d.repeatDays));
    for (final e in ctx.recentExposures) {
      if (e.dialogueId == d.id && e.shownAt.isAfter(cutoff)) return false;
    }
    return true;
  }
}

/// {time} 치환. 유일한 플레이스홀더다.
String renderDialogue(String text, {String? time}) {
  if (time == null) return text;
  return text.replaceAll('{time}', time);
}
