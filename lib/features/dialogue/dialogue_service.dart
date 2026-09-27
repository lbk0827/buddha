import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/content/models.dart';
import 'dialogue_selector.dart';

/// 화면·풀에서 규칙을 지켜 대사 하나를 고르고 노출을 기록한다.
/// 규칙 판정은 [DialogueSelector]에 있고 여기서는 컨텍스트만 모은다.
class DialogueService {
  DialogueService(this._ref);

  final Ref _ref;
  static const _selector = DialogueSelector();

  Future<DialogueItem?> pick({
    String? screen,
    String? pool,
    String? chip,
    bool safetyFlagged = false,
    bool firstSession = false,
    int? practicedSec,
    int? sessionId,
    bool record = true,
  }) async {
    final content = await _ref.read(contentProvider.future);
    final repo = _ref.read(dialogueRepositoryProvider);

    final candidates = pool != null
        ? content.forPool(pool)
        : (screen != null ? content.forScreen(screen) : const <DialogueItem>[]);
    if (candidates.isEmpty && screen == null) return null;

    final profile = await _ref.read(profileRepositoryProvider).ensure();

    final ctx = DialogueContext(
      chip: chip,
      safetyFlagged: safetyFlagged,
      firstSession: firstSession,
      creditedDays: profile.creditedDays,
      practicedSec: practicedSec,
      sessionExposures:
          sessionId == null ? const [] : await repo.forSession(sessionId),
      todayExposures: await repo.today(),
      recentExposures: await repo.recent(),
      now: DateTime.now(),
    );

    final picked = _selector.select(
      candidates: candidates,
      ctx: ctx,
      fallbacks: content.forScreen('fallback'),
    );

    if (picked != null && record) {
      await repo.record(picked, sessionId: sessionId);
    }
    return picked;
  }
}

final dialogueServiceProvider =
    Provider<DialogueService>((ref) => DialogueService(ref));
