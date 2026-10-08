/// 공덕 상점에서 받거나 사는 것들. 숫자는 여기서만 바꾼다.
///
/// 비교: 놀이(목탁·싱잉볼·키캡)마다 염주 한 바퀴에 10, 하루 최대 30. 꾸미기 아이템 150~1,500.
library;

/// 하루 한 번 받는 보상.
class DailyMeritReward {
  const DailyMeritReward({
    required this.id,
    required this.title,
    required this.description,
    required this.merit,
    this.minSteps,
  });

  final String id;
  final String title;
  final String description;
  final int merit;

  /// 이만큼 걸은 날에만 받는다. null 이면 조건 없음.
  final int? minSteps;
}

const kDailyMerit = DailyMeritReward(
  id: 'daily',
  title: '오늘의 공덕',
  description: '하루 한 번, 절에 들르면 받는다.',
  merit: 30,
);

const kStepRewards = [
  DailyMeritReward(
    id: 'steps5k',
    title: '오천 보 공덕',
    description: '오늘 5,000보 넘게 걸으면 받는다.',
    merit: 50,
    minSteps: 5000,
  ),
  DailyMeritReward(
    id: 'steps10k',
    title: '만 보 공덕',
    description: '오늘 10,000보 넘게 걸으면 받는다.',
    merit: 100,
    minSteps: 10000,
  ),
];

/// 광고를 보고 받는 공덕. 광고 연동 전이라 아직 받을 수 없다.
const int kAdMerit = 10;
const int kAdViewsPerDay = 10;

/// 공덕 묶음. 가격은 결제 연동 때 스토어 상품 가격으로 바뀐다.
class MeritBundle {
  const MeritBundle({required this.merit, required this.priceLabel});
  final int merit;
  final String priceLabel;
}

const kMeritBundles = [
  MeritBundle(merit: 1000, priceLabel: '₩1,900'),
  MeritBundle(merit: 3000, priceLabel: '₩4,900'),
  MeritBundle(merit: 5000, priceLabel: '₩7,900'),
];
