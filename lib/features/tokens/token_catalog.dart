/// 비움의 증표 (v3 상점). 돈으로 사는 게 아니라 수행 이력으로 열린다.
/// 실물 굿즈·가격·구매는 이번 범위에서 뺐다 — 해제 여부만 보여준다.
library;

/// 해제 조건이 읽는 누적값.
class PracticeStats {
  final int burnedCount;
  final int bowCount;
  final int creditedDays;
  final int merit;
  final int faceDownSec;

  const PracticeStats({
    this.burnedCount = 0,
    this.bowCount = 0,
    this.creditedDays = 0,
    this.merit = 0,
    this.faceDownSec = 0,
  });
}

enum TokenGroup { practice, season }

class TokenDef {
  final String id;
  final String name;

  /// 조건 문구. 잠겨 있을 때 그대로 보여준다.
  final String requirementLabel;
  final TokenGroup group;

  /// 현재 진척과 목표를 뽑는다. 목표가 0이면 조건 없는 증표.
  final int Function(PracticeStats) progressOf;
  final int goal;

  const TokenDef({
    required this.id,
    required this.name,
    required this.requirementLabel,
    required this.group,
    required this.progressOf,
    required this.goal,
  });

  bool isUnlocked(PracticeStats s) => goal == 0 || progressOf(s) >= goal;

  /// 0.0 ~ 1.0
  double ratio(PracticeStats s) {
    if (goal == 0) return 1;
    final p = progressOf(s) / goal;
    return p < 0 ? 0 : (p > 1 ? 1 : p);
  }

  String progressLabel(PracticeStats s) {
    if (goal == 0) return '조건 없음';
    return '${progressOf(s)} / $goal';
  }
}

const List<TokenDef> kTokenCatalog = [
  TokenDef(
    id: 'burn108',
    name: '108번뇌 완파',
    requirementLabel: '번뇌 108개 태움',
    group: TokenGroup.practice,
    progressOf: _burned,
    goal: 108,
  ),
  TokenDef(
    id: 'bow100',
    name: '엎기 100회',
    requirementLabel: '엎어두기 100회',
    group: TokenGroup.practice,
    progressOf: _bows,
    goal: 100,
  ),
  TokenDef(
    id: 'gate30',
    name: '무결(無缺)',
    requirementLabel: '절 문 30일 안 닫힘',
    group: TokenGroup.practice,
    progressOf: _days,
    goal: 30,
  ),
  TokenDef(
    id: 'first',
    name: '첫 엎기',
    requirementLabel: '한 번 엎어두면',
    group: TokenGroup.practice,
    progressOf: _bows,
    goal: 1,
  ),
  TokenDef(
    id: 'merit1000',
    name: '공덕 천',
    requirementLabel: '공덕 1,000',
    group: TokenGroup.practice,
    progressOf: _merit,
    goal: 1000,
  ),
  TokenDef(
    id: 'winter',
    name: '동지 한정 · 탱화',
    requirementLabel: '시즌 증표',
    group: TokenGroup.season,
    progressOf: _zero,
    goal: 0,
  ),
];

int _burned(PracticeStats s) => s.burnedCount;
int _bows(PracticeStats s) => s.bowCount;
int _days(PracticeStats s) => s.creditedDays;
int _merit(PracticeStats s) => s.merit;
int _zero(PracticeStats s) => 0;

/// 조건을 막 충족한 증표들. 해제 연출 대상이다.
List<TokenDef> newlyUnlocked(PracticeStats stats, Set<String> alreadyUnlocked) =>
    kTokenCatalog
        .where((t) => t.isUnlocked(stats) && !alreadyUnlocked.contains(t.id))
        .toList(growable: false);

/// 다음으로 가까운 잠긴 증표. 메인의 진척 배너가 쓴다.
/// 비율이 같으면 남은 개수가 적은 쪽을 고른다 — 아무것도 안 한 사람에게
/// "108 남음"보다 "1 남음"을 보여주는 게 맞다.
TokenDef? nextToUnlock(PracticeStats stats, Set<String> unlocked) {
  TokenDef? best;
  var bestRatio = -1.0;
  var bestLeft = 1 << 30;
  for (final t in kTokenCatalog) {
    if (t.goal == 0) continue;
    if (unlocked.contains(t.id) || t.isUnlocked(stats)) continue;
    final r = t.ratio(stats);
    final left = t.goal - t.progressOf(stats);
    if (r > bestRatio || (r == bestRatio && left < bestLeft)) {
      bestRatio = r;
      bestLeft = left;
      best = t;
    }
  }
  return best;
}
