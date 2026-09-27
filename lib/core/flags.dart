/// Build-time feature flags. Remote flags are P2 (PRD 기술 아키텍처 · 패키지 선정).
class Flags {
  /// 방식 A: 전면 유지 + 가속도·근접 센서 판정. H1 미검증이라 기본 꺼짐 (FR-2.9).
  static const bool enableSensorA = false;

  /// 방식 C: 음원 재생 중 센서 스트림 구독. H1 미검증 (FR-2.10).
  static const bool enableAudioC = false;

  /// 말씀의 뿌리 링크. 공개 콘텐츠가 [rootsMinPublic]건 미만이면 런타임에 다시 꺼진다 (FR-5.5).
  static const bool rootsEnabled = true;
  static const int rootsMinPublic = 5;

  /// 법명 3~8단계는 P2 (FR-4.8).
  static const int dharmaMaxStage = 2;

  /// 음원 에셋이 아직 없다 (PRD 미결: 음원 1종 저작권 확인).
  static const bool audioAssetAvailable = false;

  static bool get sensorSelectable => enableSensorA || enableAudioC;
}
