/// 가상 출가와 법명 진화 (v3 온보딩).
/// 법명은 수행하면 진화한다: 무념 → 무념대사 → 무념선사 → ?
library;

import '../../l10n/l10n.dart';

class DharmaRank {
  final int index;
  final int requiredBows;

  const DharmaRank({required this.index, required this.requiredBows});

  /// 옆에 적히는 신분.
  String get station => switch (index) {
    1 => L.current.ordinationStationDaesa,
    2 => L.current.ordinationStationSeonsa,
    3 => L.current.ordinationStationJosa,
    _ => L.current.ordinationStationSami,
  };

  /// 단계에 맞춘 법명. 0단계는 법명 그대로다.
  /// [base] 는 저장된 법명이고, 화면 표기는 [dharmaNameLabel] 로 바꾼다.
  String nameFor(String base) {
    final name = dharmaNameLabel(base);
    return switch (index) {
      1 => L.current.ordinationRankNameDaesa(name),
      2 => L.current.ordinationRankNameSeonsa(name),
      3 => L.current.ordinationRankNameJosa(name),
      _ => name,
    };
  }
}

const List<DharmaRank> kDharmaRanks = [
  DharmaRank(index: 0, requiredBows: 0),
  DharmaRank(index: 1, requiredBows: 30),
  DharmaRank(index: 2, requiredBows: 108),
  DharmaRank(index: 3, requiredBows: 500),
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
/// 고른 값이 프로필(dharmaName)에 그대로 저장되고 [kDharmaMeanings] 의 키라서
/// 한국어 그대로 둔다. 화면에는 [dharmaNameLabel] 을 거쳐 보인다.
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

/// 저장된 법명 → 화면 표기. 저장값은 언어와 상관없이 한국어로 둔다.
String dharmaNameLabel(String stored) => switch (stored) {
  '무념' => L.current.ordinationNameMunyeom,
  '무심' => L.current.ordinationNameMusim,
  '적조' => L.current.ordinationNameJeokjo,
  '일현' => L.current.ordinationNameIlhyeon,
  '해안' => L.current.ordinationNameHaean,
  '청안' => L.current.ordinationNameCheongan,
  '보월' => L.current.ordinationNameBowol,
  '지안' => L.current.ordinationNameJian,
  '현우' => L.current.ordinationNameHyeonu,
  '법운' => L.current.ordinationNameBeopun,
  _ => stored,
};

/// 법명의 뜻. 출가 화면에서 한 줄로 보여준다.
/// 키는 저장되는 법명([kDharmaNames])이라 그대로 두고, 뜻만 문자열 테이블에서 온다.
Map<String, String> get kDharmaMeanings => {
  '무념': L.current.ordinationMeaningMunyeom,
  '무심': L.current.ordinationMeaningMusim,
  '적조': L.current.ordinationMeaningJeokjo,
  '일현': L.current.ordinationMeaningIlhyeon,
  '해안': L.current.ordinationMeaningHaean,
  '청안': L.current.ordinationMeaningCheongan,
  '보월': L.current.ordinationMeaningBowol,
  '지안': L.current.ordinationMeaningJian,
  '현우': L.current.ordinationMeaningHyeonu,
  '법운': L.current.ordinationMeaningBeopun,
};
