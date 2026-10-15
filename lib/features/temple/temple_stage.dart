import '../../l10n/l10n.dart';

/// 절 성장. 인정일에만 반응하고, 미접속으로 차감되지 않는다 (FR-4.2).
class TempleStage {
  final int index;
  final int requiredCreditedDays;

  const TempleStage({
    required this.index,
    required this.requiredCreditedDays,
  });

  /// 건물 이름 (등 · 나무 · …).
  String get name => switch (index) {
        1 => L.current.templeStageNameLantern,
        2 => L.current.templeStageNameTree,
        3 => L.current.templeStageNameWall,
        4 => L.current.templeStageNameBell,
        5 => L.current.templeStageNameRoof,
        _ => L.current.templeStageNameGate,
      };

  /// 그 단계가 생길 때 나오는 한 줄.
  String get arrivalLine => switch (index) {
        1 => L.current.templeStageArrivalLantern,
        2 => L.current.templeStageArrivalTree,
        3 => L.current.templeStageArrivalWall,
        4 => L.current.templeStageArrivalBell,
        5 => L.current.templeStageArrivalRoof,
        _ => L.current.templeStageArrivalGate,
      };
}

const List<TempleStage> kTempleStages = [
  TempleStage(index: 1, requiredCreditedDays: 1),
  TempleStage(index: 2, requiredCreditedDays: 2),
  TempleStage(index: 3, requiredCreditedDays: 5),
  TempleStage(index: 4, requiredCreditedDays: 10),
  TempleStage(index: 5, requiredCreditedDays: 20),
  TempleStage(index: 6, requiredCreditedDays: 40),
];

/// 인정일 누적 → 단계 (0 = 아직 아무것도 없는 빈 마당).
int stageForCreditedDays(int creditedDays) {
  var stage = 0;
  for (final s in kTempleStages) {
    if (creditedDays >= s.requiredCreditedDays) {
      stage = s.index;
    }
  }
  return stage;
}

TempleStage? stageAt(int index) {
  if (index < 1 || index > kTempleStages.length) return null;
  return kTempleStages[index - 1];
}

/// 「다음 변화 보기」 (FR-4.5). 기본 화면에는 카운트다운을 두지 않는다.
TempleStage? nextStageAfter(int creditedDays) {
  for (final s in kTempleStages) {
    if (creditedDays < s.requiredCreditedDays) return s;
  }
  return null;
}

/// 미접속 2일 이상이면 마당에 낙엽 (FR-4.4).
/// 결석 일수·이유는 표시하지 않으므로 bool만 돌려준다.
bool shouldShowFallenLeaves({
  required DateTime? lastVisitAt,
  required DateTime now,
}) {
  if (lastVisitAt == null) return false;
  return now.difference(lastVisitAt).inDays >= 2;
}

/// 법명 뒷 글자 (FR-4.8). 3단계 이상은 플래그 뒤.
/// 법명을 이루는 저장값이라 한국어 그대로 둔다. 화면 표기는 [dharmaSyllableLabel].
String? dharmaLastSyllable(int creditedDays) {
  if (creditedDays >= 7) return '사';
  if (creditedDays >= 1) return '견';
  return null;
}

/// 법명 글자(저장값) → 화면 표기.
String dharmaSyllableLabel(String stored) => switch (stored) {
      '관' => L.current.templeDharmaSyllableGwan,
      '지' => L.current.templeDharmaSyllableJi,
      '문' => L.current.templeDharmaSyllableMun,
      '미' => L.current.templeDharmaSyllableMi,
      '사' => L.current.templeDharmaSyllableSa,
      '견' => L.current.templeDharmaSyllableGyeon,
      _ => stored,
    };

/// 앞 글자 + 뒷 글자 법명의 화면 표기 (저장값을 받는다).
String dharmaComposedName(String first, String last) =>
    L.current.templeDharmaComposedName(
        dharmaSyllableLabel(first), dharmaSyllableLabel(last));

/// 법명 앞 글자 → 그 유래. 키는 프로필(dharmaFirst)에 저장되는 값이라 그대로 두고,
/// 유래 설명만 문자열 테이블에서 온다.
Map<String, String> get kDharmaFirstSyllables => {
      '관': L.current.templeDharmaFirstGwan,
      '지': L.current.templeDharmaFirstJi,
      '문': L.current.templeDharmaFirstMun,
      '미': L.current.templeDharmaFirstMi,
    };
