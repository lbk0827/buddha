import '../../data/content/models.dart';

/// 위기 신호 감지. 전부 로컬에서 돈다. 텍스트는 기기 밖으로 나가지 않는다 (SA-4).
class SafetyDetector {
  const SafetyDetector(this.content);

  final SafetyContent content;

  /// 번뇌 한 줄·반복 고민 응답에 쓴다 (SA-1).
  bool isFlagged(String? text) {
    if (text == null) return false;
    final normalized = _normalize(text);
    if (normalized.isEmpty) return false;

    for (final k in content.keywords) {
      final nk = _normalize(k);
      if (nk.isNotEmpty && normalized.contains(nk)) return true;
    }
    for (final p in content.patterns) {
      if (p.hasMatch(text)) return true;
    }
    return false;
  }

  /// 공백·구두점을 지워 "죽 고 싶 다" 같은 회피를 어느 정도 흡수한다.
  String _normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[\s\p{P}\p{S}]+', unicode: true), '');
}
