/// 절 성장. 인정일에만 반응하고, 미접속으로 차감되지 않는다 (FR-4.2).
class TempleStage {
  final int index;
  final String name;
  final int requiredCreditedDays;
  final String arrivalLine;

  const TempleStage({
    required this.index,
    required this.name,
    required this.requiredCreditedDays,
    required this.arrivalLine,
  });
}

const List<TempleStage> kTempleStages = [
  TempleStage(
      index: 1,
      name: '등',
      requiredCreditedDays: 1,
      arrivalLine: '등 하나 켜졌다.'),
  TempleStage(
      index: 2,
      name: '나무',
      requiredCreditedDays: 2,
      arrivalLine: '마당에 나무 한 그루 섰다.'),
  TempleStage(
      index: 3,
      name: '돌담',
      requiredCreditedDays: 5,
      arrivalLine: '돌담이 둘러졌다. 바람이 좀 덜 든다.'),
  TempleStage(
      index: 4,
      name: '종',
      requiredCreditedDays: 10,
      arrivalLine: '종이 걸렸다. 아직 치지는 않았다.'),
  TempleStage(
      index: 5,
      name: '지붕',
      requiredCreditedDays: 20,
      arrivalLine: '지붕이 올라갔다. 비는 이제 안 맞는다.'),
  TempleStage(
      index: 6,
      name: '일주문',
      requiredCreditedDays: 40,
      arrivalLine: '일주문이 섰다. 여기부터 절이다.'),
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
String? dharmaLastSyllable(int creditedDays) {
  if (creditedDays >= 7) return '사';
  if (creditedDays >= 1) return '견';
  return null;
}

const Map<String, String> kDharmaFirstSyllables = {
  '관': '관세음 — 듣는 쪽',
  '지': '지장 — 버티는 쪽',
  '문': '문수 — 따지는 쪽',
  '미': '미륵 — 기다리는 쪽',
};
