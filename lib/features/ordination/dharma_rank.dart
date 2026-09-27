/// 가상 출가와 법명 진화 (v3 온보딩).
/// 법명은 수행하면 진화한다: 무념 → 무념대사 → 무념선사 → ?
library;

class DharmaRank {
  final int index;

  /// 법명 뒤에 붙는 말. 0단계는 아무것도 안 붙는다.
  final String suffix;

  /// 옆에 적히는 신분.
  final String station;
  final int requiredBows;

  const DharmaRank({
    required this.index,
    required this.suffix,
    required this.station,
    required this.requiredBows,
  });

  String nameFor(String base) => '$base$suffix';
}

const List<DharmaRank> kDharmaRanks = [
  DharmaRank(index: 0, suffix: '', station: '사미', requiredBows: 0),
  DharmaRank(index: 1, suffix: '대사', station: '대사', requiredBows: 30),
  DharmaRank(index: 2, suffix: '선사', station: '선사', requiredBows: 108),
  DharmaRank(index: 3, suffix: '조사', station: '조사', requiredBows: 500),
];

DharmaRank rankForBows(int bowCount) {
  var rank = kDharmaRanks.first;
  for (final r in kDharmaRanks) {
    if (bowCount >= r.requiredBows) rank = r;
  }
  return rank;
}

DharmaRank? nextRankAfter(int bowCount) {
  for (final r in kDharmaRanks) {
    if (bowCount < r.requiredBows) return r;
  }
  return null;
}

/// 출가할 때 주는 법명 후보. 사용자가 고르지 않으면 무작위로 하나 준다.
const List<String> kDharmaNames = [
  '무념',
  '무심',
  '적조',
  '일현',
  '해안',
  '청안',
  '보월',
  '지안',
  '현우',
  '법운',
];

/// 법명의 뜻. 출가 화면에서 한 줄로 보여준다.
const Map<String, String> kDharmaMeanings = {
  '무념': '생각이 없는 게 아니라, 생각에 끌려가지 않는다는 뜻',
  '무심': '마음을 없앤 게 아니라, 마음에 머물지 않는다는 뜻',
  '적조': '고요히 비춘다. 가만히 있어도 보인다는 뜻',
  '일현': '하나가 드러난다. 여럿을 좇지 않는다는 뜻',
  '해안': '바다의 언덕. 파도를 보되 휩쓸리지 않는다는 뜻',
  '청안': '맑은 눈. 흐려도 다시 맑아진다는 뜻',
  '보월': '보배로운 달. 이지러져도 다시 찬다는 뜻',
  '지안': '지혜의 언덕. 몰라도 딛고 선다는 뜻',
  '현우': '드러난 벗. 혼자가 아니라는 뜻',
  '법운': '법의 구름. 형체 없이 덮는다는 뜻',
};
