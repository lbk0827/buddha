# 부처핸섬 PRD — Flutter MVP

기준 문서: 「부처핸섬 앱 기획서 v4」(2026-09-24). 이 PRD는 v4의 결정을 Flutter 구현 단위의 요구사항·수용 기준·기술 설계로 옮긴 것이다. 기획의 근거와 대사 원문은 v4를, 무엇을 만드는지는 이 문서를 본다.

## 제품 개요

부처핸섬은 "불교를 몰라도 웃으며 들어와, 내 마음을 알아차리고, 조금 가벼워져 나가는 내 손안의 작은 절"이다. 하루 3분, 폰을 내려놓는 짧은 수행이 절이라는 공간의 변화로 남고, 선사가 경전에 뿌리를 둔 한마디를 건넨다.

| 항목 | 내용 |
| --- | --- |
| 플랫폼 | Flutter (iOS 먼저, Android 후속). 단일 코드베이스 |
| 형태 | 오프라인 우선 모바일 앱. 서버 없음(MVP). 콘텐츠는 앱 번들 JSON |
| 수익 | MVP에서는 실물 단주 외부 링크 수요 검증만. IAP 없음 |
| 개발 | 1인, VS Code + Flutter SDK, 주 15시간 가정 |

## 목표

| 목표 | 측정 (가설값) |
| --- | --- |
| 설치 후 부담 없이 첫 수행에 도달 | 마음 내려놓기 경로 첫 세션 시작까지 중앙값 90초 이하, 첫 세션 1분 이상 완료율 60% |
| 다시 하고 싶어짐 | 설치 후 7일째 세션 15%, 알림 없는 자발 재수행 30% |
| 선사 한마디가 웃기거나 공감됨 | 카드 1탭 "피식" 40% |
| 유형 결과가 내 얘기 같음 | "나 같냐" 3.5/5 |
| 단주 수요 확인 | 가격 화면 도달 대비 관심 등록 10% |

비목표: 다운로드 수·체류시간 극대화, 힐링 효과 입증, 커뮤니티, AI 대화.

## 사용자

종교를 묻지 않는다. 세 사용자가 같은 앱에서 깊이만 다르게 쓴다.

| 사용자 | 주 입구 | 필요한 것 |
| --- | --- | --- |
| 지친 직장인 | 마음 내려놓기 | 5초 안에 큰 버튼, 3분, 강요 없음 |
| 재미로 온 사람 | 내 마음 알아보기 | 2분 테스트, 공유 카드, 캐릭터 |
| 불교에 관심 있는 사람 | 오늘의 한마디 | 정확한 출처, 왜곡 없는 의역, 펼쳐보기 |

## MVP 범위

| In (P0·P1) | Out (P2 확장) |
| --- | --- |
| 첫 화면 세 입구 | AI 셀카 출가 |
| 3분·10분 수행 — 방식 B(확인 버튼 + 타이머) 기본. 방식 A·C는 플래그 뒤 | 30·60분, 108배, 위젯, 백탭 |
| 번뇌 한 줄·주제 칩·태우기·건너뛰기 | 탐·진·치 분류·선사 반박 |
| 선사 한마디 (풀 약 50 + 번뇌 뒤 풀 + 안내) | 자유 대화형 차담 |
| 말씀의 뿌리 3단 펼치기 — 외부 감수 완료 콘텐츠만. 5건 미만이면 링크 비활성 플래그 | 뿌리 30건+, 저장함 |
| 절 변화 6단계 + 다음 변화 보기 | 천왕문·대웅전, 카드, 꾸미기 |
| 기록·인정일·법명 1\~2단계 | 법명 3\~8단계 |
| 선택형 유형 테스트 16문항 + 심화 + 오늘의 체크인 | 유형별 문구 풀 확대 |
| 알림 (동의 후 다음 날 1회 → 주 1회 이하) | 화면 시간 리포트, 알림 차단 |
| 단주 1종 소개 + 관심 등록 (외부 링크) | 상점, 기도 접수, 소셜, GPS, 안거 |
| 위기 신호 안내 화면 (평문) | — |

## 제약

- 앱 유지 목적의 무음·극저음 오디오 재생 금지 (App Review 2.5.4·2.4.2)
- 화면 시간(Screen Time API)을 보상 조건으로 쓰지 않음 (4.10)
- 실물 구매와 앱 기능 해제 연동 없음 (3.1.4)
- 센서 로그·기록 저장 전 명시적 동의 (2.5.14). 서버 전송 없음
- 백그라운드 센서 수신은 실기기 검증 전 가정하지 않음. 타이머는 타임스탬프 기반
- 콘텐츠(경전 의역·선사 대사·위기 문구)는 외부 감수 전 공개 불가. 감수 상태 플래그로 노출 제어

---

# 기능 요구사항

표기: FR-번호. 우선순위 P0(MVP 필수) / P1(MVP 포함, 단순화 가능) / P2(확장). 수용 기준은 QA가 그대로 확인할 수 있는 문장으로 썼다.

## FR-1 첫 화면·온보딩 (P0)

| ID | 요구사항 | 수용 기준 |
| --- | --- | --- |
| FR-1.1 | 첫 화면은 인사 · 오늘의 한마디 카드 · 마당 · 대표 버튼 "마음 내려놓기 · 3분" · 보조 버튼 "내 마음 알아보기"로 구성 | 첫 실행 시 로그인·회원가입·튜토리얼 없이 이 화면이 뜬다. 대표 버튼이 화면 하단 고정, 보조 버튼보다 면적 2배 이상 |
| FR-1.2 | 첫 방문 인사 "왔네. 천천히 봐라. 급한 건 없다." 재방문 "왔네." + 마당 상태 | 두 번째 실행부터 재방문 문구 |
| FR-1.3 | 캐릭터·법명 선택은 첫 수행 완료 후 1회 제안, 건너뛰기 가능. 설정에서 언제든 | 첫 수행 전 어떤 선택도 요구하지 않음. 기본 캐릭터 1종, 법명 없음으로 모든 기능 동작 |
| FR-1.4 | 한마디만 보고 앱을 닫아도 붙잡는 문구·팝업 없음 | 종료 시 다이얼로그 0 |
| FR-1.5 | 기록 저장·알림에 대한 동의는 각 기능 첫 사용 시점에 1회 요청 | 첫 세션 종료 직전 "기록을 기기에 저장해도 되나" 1회. 거부 시 세션은 기록 없이 종료 |

## FR-2 수행 세션 (P0)

상태: 대기 → 준비 → 수행중 → (중단 선택 / 일시정지 → 유예) → 종료. 시간 계산은 타임스탬프 기반(5번 탭).

| ID | 요구사항 | 수용 기준 |
| --- | --- | --- |
| FR-2.1 | 시작 화면에서 길이(3·10분), 번뇌 한 줄(선택), 주제 칩(일·사람·돈·가족·몸·그냥·많이 힘듦, 선택), 음원 켬/끔 확정 | 길이 기본값은 회복 선호 또는 3분. 모두 선택 없이 시작 가능 |
| FR-2.2 | 준비 상태에서 엎음 확인. 방식 B: \[엎었다\] 버튼. 방식 A·C(플래그): 센서 판정, 실패 시 5초 후 버튼 자동 표시 | 60초 안에 확인 없으면 대기로 복귀 + 안내 |
| FR-2.3 | 확인 즉시 진동 1회, 시작 타임스탬프 저장, 종료 예정 시각으로 로컬 알림 예약 | 앱이 백그라운드·종료돼도 종료 시각에 알림(진동) |
| FR-2.4 | 수행중 화면은 검은 화면 + 최소 정보. 음성 안내 기본 없음, 설정에서 최소·기본 | 기본 설정에서 3분 동안 소리·진동 없음 |
| FR-2.5 | 앱 전면 복귀(resumed) 시 경과 시간 계산 → 목표 미달이면 "중단 선택" 화면: 경과 시간 + \[이어가기\] \[오늘은 여기까지\]. 60초 무응답이면 중단 종료 | 선택 화면 체류 시간은 수행 시간에서 제외 |
| FR-2.6 | 음원 켠 세션에서 오디오 세션 중단(전화·알람) → 일시정지. 해제 후 30초 유예. 유예 중 음원 재생 안 함. 30초 안에 재개(A·C: 엎음 확인, B: 앱 복귀 후 이어가기) 없으면 중단 종료. 중단 10분 초과 시 종료 | 무음 세션은 일시정지 상태 없음 (전화 후 앱 복귀 → 중단 선택) |
| FR-2.7 | 종료 시 기록: 시작·종료 시각, 수행 시간(정지·유예 제외), 완주/중단, 감지 라벨(타이머/엎음 감지), 번뇌 텍스트·칩, 음원 여부 | 1분 미만 세션도 기록되나 "유효" 아님 |
| FR-2.8 | 완주 화면: "{시간} 뒀다. 오늘은 여기까지." → 절 변화(해당 시) → 기록 1줄. 칩 "많이 힘듦"이면 유머 없이 "{시간} 뒀다. 그거면 됐다." | 깨달음 요구·평가 문구 없음 |
| FR-2.9 | 방식 A(전면 유지): wakelock으로 화면 유지, 화면 밝기 최소, 가속도·근접으로 엎음·들음 로그 | 플래그 뒤. 프로토타입 판정 전 기본 꺼짐 |
| FR-2.10 | 방식 C(음원 + 센서): 음원 재생 중 센서 스트림 구독 시도, 수신 여부 로그 | 플래그 뒤. H1 미검증 |

## FR-3 번뇌·선사 한마디 (P0)

| ID | 요구사항 | 수용 기준 |
| --- | --- | --- |
| FR-3.1 | 번뇌 한 줄 입력(최대 80자), 건너뛰기 버튼이 입력칸과 같은 크기. 분류 강제 없음 | 빈 채로 시작 가능 |
| FR-3.2 | "지난번 그 얘기" 토글. 켜면 완주 후 반복 고민 화면(4개 선택지). 자동 키워드 매칭 없음 | 토글 꺼져 있으면 선사가 이전 번뇌를 언급하지 않음 |
| FR-3.3 | 태우기: 종이가 재가 되는 애니메이션 1\~2초. 텍스트는 기록에 남음(사용자만 열람) | — |
| FR-3.4 | 완주 후 \[선사 한마디 보기\] 버튼. 눌렀을 때만 주제 칩 풀에서 1개. 세션당 1개 | 안 누르면 노출 0 |
| FR-3.5 | 오늘의 한마디 카드: 하루 1개, 한마디 풀에서 최근 14일 노출 제외 후 무작위. 뿌리 있는 대사면 \[이 말의 뿌리\] 링크 | 같은 ID 14일 내 재노출 0. 풀 부족 시 D-01 |
| FR-3.6 | 노출 규칙: 세션당 강도 "중" 1개, 하루 관찰·질문 2개, 초과 시 인정·안내만 | 규칙 위반 노출 0 (단위 테스트) |
| FR-3.7 | 캡처·공유: 카드 이미지 생성(유형명 없이 한마디 + 앱명) → OS 공유 시트 | 번뇌 원문은 카드에 포함 안 됨 |
| FR-3.8 | 칩 "많이 힘듦": 유머 역할 대사 전부 비노출, 인정·안내만 | — |

## FR-4 기록·인정일·절 성장 (P0)

| ID | 요구사항 | 수용 기준 |
| --- | --- | --- |
| FR-4.1 | 유효 세션 = 수행 시간 ≥ 60초. 인정일 = 그날(로컬 자정 기준, 시작 시각 귀속) 첫 유효 세션에 +1, 하루 최대 1 | 같은 날 세션 3개 → 인정일 +1 |
| FR-4.2 | 절 단계: 인정일 1·2·5·10·20·40에 등·나무·돌담·종·지붕·일주문. 단계 도달은 종료 화면에서 연출 | 도달 조건 만족 시 즉시 표시, 미접속 차감 없음 |
| FR-4.3 | 당일 반복 세션: 등이 밝아지는 효과(자정까지), 단계 무관 | — |
| FR-4.4 | 미접속 2일 이상: 마당에 낙엽. 복귀 화면 \[1분 쓸기\] \[그냥 들어가기\]. 결석 일수·이유 표시 없음 | 낙엽은 다음 유효 세션 또는 1분 쓸기로 사라짐 |
| FR-4.5 | 다음 변화 보기: 상단 메뉴·절 화면 링크. 누르면 다음 단계 문구 + 조건(인정일 N). 기본 화면에 카운트다운 없음 | — |
| FR-4.6 | 건물·소품 탭 → 상징 한 줄(이름의 뜻·도상 라벨). 뿌리 링크는 공개 콘텐츠일 때만 | — |
| FR-4.7 | 기록 화면: 날짜별 세션(시간, 완주/중단, 라벨, 번뇌), 누적 시간, 인정일 수. \[숫자 가리기\] 토글 | 가리기 시 인정일·연속 숫자 비표시 |
| FR-4.8 | 법명: 앞 글자(관·지·문·미, 사용자 선택) + 뒷 글자(인정일 1 견, 7 사). 3단계 이상은 플래그 뒤 | 재검사·앞 글자 변경 시 뒷 글자 유지 |

## FR-5 말씀의 뿌리 (P1)

| ID | 요구사항 | 수용 기준 |
| --- | --- | --- |
| FR-5.1 | 뿌리 콘텐츠는 roots.json에서 review\_status = public인 것만 로드 | 비공개 항목은 앱에서 접근 불가 |
| FR-5.2 | 3단 펼치기: 한마디 → 해설(한 화면) → 말씀(의역 · 경전명·장절 · "현대어로 풀었다" 라벨 · 맥락 · 전통 노트 · 원문 링크) → \[작은 행동\] → 번뇌 한 줄 또는 3분 | 각 단 펼치기는 탭 1회. 뒤로 가기 시 이전 단 |
| FR-5.3 | 하루 1건. 어제 것은 기록에서 열람 | 무한 스크롤·피드 없음 |
| FR-5.4 | 읽기·펼침은 인정일·성장에 영향 없음 | 단위 테스트 |
| FR-5.5 | 공개 콘텐츠 5건 미만이면 뿌리 링크 전체 비활성(원격 플래그 또는 빌드 플래그) | — |

## FR-6 유형 테스트 「내 마음의 보살 찾기」 (P1)

| ID | 요구사항 | 수용 기준 |
| --- | --- | --- |
| FR-6.1 | 16문항(G6·A6·C4) + 심화 풀(SG3·SA3), 각 문항 건너뛰기. 응답 기준 "최근 한 달" 첫 화면 명시 | 문항·선택지는 test.json |
| FR-6.2 | 채점: 요소별 선택 수, 두드러짐 조건(응답 ≥ 3, 최고×2 ≥ 응답, 차이 ≥ 1). 판정 5단계(대표/혼합/경향/유보 정보부족/유보 분산). 유형 점수는 판정 미사용 | v4 부록 C 사례 18건을 단위 테스트로 재현, 전부 통과 |
| FR-6.3 | 심화: 경향·유보에서만 제안. 응답 적은 요소부터 한 문항씩 재계산. 응답 3 / 두 요소 두드러짐 / 거절에서 종료. 건너뛴 문항은 대체(노출 최대 5) | — |
| FR-6.4 | 결과 화면 3층: 결과명·한마디·공유 카드 / 관찰·해석·제안(두드러진 방향만) / 상징(접힘, 대표·혼합만). 점수·상태명 비표시. "응답 N / 건너뜀 M" 표시 | 두드러지지 않은 방향의 문장 노출 0 |
| FR-6.5 | 회복 최고 방향 → 세션 기본값(길이·번뇌 입력·음원) 첫 3회 적용 | 동점이면 사용자 선택 |
| FR-6.6 | 오늘의 체크인(1문항)은 오늘 기본값만 변경. 유형·법명 불변 | — |
| FR-6.7 | 재검사 언제든. 기록·절·법명 뒷 글자 유지. 프로필 적용 선택 | — |
| FR-6.8 | 딥링크로 유형·회복 방향 수신(웹 → 앱). 실패 시 일반 흐름 | 파라미터 없는 실행도 정상 |

## FR-7 알림 (P1)

| ID | 요구사항 | 수용 기준 |
| --- | --- | --- |
| FR-7.1 | 세션 종료 알림(로컬, 예약)은 동의 없이 세션 시작 시 예약. 사용자가 시스템 권한 거부 시 앱 내 진동만 | — |
| FR-7.2 | 재방문 알림은 별도 동의. 다음 날 1회("어제 등, 아직 켜져 있다."), 이후 주 1회 이하. 설정에서 해제 | 동의 전 재방문 알림 0 |
| FR-7.3 | 미접속 2일 낙엽 알림은 주 1회 이하 풀에 포함 | — |

## FR-8 굿즈·기타 (P1)

| ID | 요구사항 | 수용 기준 |
| --- | --- | --- |
| FR-8.1 | 단주 소개 화면: 사진·소재·21알의 뜻·색 4종·가격 → \[관심 등록\](외부 폼 링크). 앱 내 결제 없음 | 관심 등록 클릭 이벤트 기록 |
| FR-8.2 | 한정판 안내는 인정일 21·108 도달 시 1회 "열렸다"만 | 희소성·마감 문구 없음 |
| FR-8.3 | 설정: 음성 안내(없음/최소/기본), 알림, 삼배 의식(끔/켬), 감지 방식(플래그 노출 시), 숫자 가리기, 데이터 삭제 | 데이터 삭제 시 로컬 전부 삭제 |

## 안전 (P0)

| ID | 요구사항 | 수용 기준 |
| --- | --- | --- |
| SA-1 | 번뇌 입력·고민 응답 텍스트에서 검수된 키워드·패턴 감지 시: 선사 대사 전부 비노출 → 평문 안내 화면 E-10(연락처, \[상담 연락처 보기\] \[아니에요, 계속할게요\]) | 키워드 목록·문구·연락처는 전문가 검수 후 content/safety.json으로 교체 가능 |
| SA-2 | 해당 세션의 기록·인정일·단계 도달은 보존. 축하 연출·한마디 카드·공유 버튼만 유예. 다음 방문 "어제 등 하나 켜졌다." | 인정일 감소 0 |
| SA-3 | "아니에요" 선택 시 일반 흐름 복귀, 그 세션은 인정·안내 대사만 | — |
| SA-4 | 감지 로직은 로컬. 텍스트는 기기 밖으로 나가지 않음 | 네트워크 요청 0 |

---

# 화면·네비게이션

## 화면 목록 (go\_router 라우트)

| 라우트 | 화면 | 구성 요소 | 상태·조건 |
| --- | --- | --- | --- |
| / | 홈 | 인사, 한마디 카드, 마당(절 위젯), 대표 버튼, 보조 버튼, 상단 메뉴 | 낙엽(미접속 2일+), 당일 반복 밝기 |
| /session/setup | 세션 설정 | 길이 토글, 번뇌 입력, 칩, "지난번 그 얘기" 토글, 음원 토글, 시작 | 기본값 = 회복 선호 |
| /session/ready | 준비 | "3분이면 된다. 엎어라. 진동 오면 시작이다.", \[엎었다\] | 60초 타임아웃 |
| /session/running | 수행중 | 검은 화면, 남은 시간(옵션), 일시정지 버튼 | 화면 밝기 최소 |
| /session/interrupt | 중단 선택 | 경과 시간, \[이어가기\] \[오늘은 여기까지\] | 60초 무응답 → 종료 |
| /session/done | 완료 | 인정 문구, 절 변화 연출, \[선사 한마디 보기\], 기록 1줄 | 칩 "많이 힘듦" 시 연출 최소 |
| /session/repeat | 반복 고민 | 192s + 선택지 4 | "지난번 그 얘기" 토글 시 |
| /safety | 위기 안내 | 평문 E-10, 연락처, \[계속할게요\] | 캐릭터 없음 |
| /roots/:id | 말씀의 뿌리 | 3단 펼치기, 작은 행동 버튼 | public만 |
| /temple | 절 | 마당 확대, 건물 탭 → 상징 시트, \[다음 변화 보기\] | — |
| /records | 기록 | 세션 목록, 누적 시간, 인정일, 숫자 가리기 | — |
| /test | 테스트 소개 | 응답 기준, \[시작\] | — |
| /test/q/:n | 문항 | 질문, 선택지 4, 건너뛰기, 진행 표시(염주) | 심화는 점선 염주 |
| /test/result | 결과 | 3층, 공유, \[3분 시작\], 프로필 적용, 재검사 | 상태명 비표시 |
| /checkin | 오늘의 체크인 | 1문항 | 홈 카드에서 진입 |
| /profile | 프로필 | 캐릭터, 법명(앞·뒤), 유형 표시(선택) | — |
| /goods | 단주 | 사진, 뜻, 색 4, 가격, \[관심 등록\] | 외부 링크 |
| /settings | 설정 | 음성, 알림, 삼배, 감지 방식(플래그), 숫자 가리기, 데이터 삭제 | — |
| /onboard/character | 캐릭터·법명 | 3종 캐릭터, 앞 글자 후보, 건너뛰기 | 첫 완주 후 1회 |

## 네비게이션 흐름

| 출발 | 동작 | 도착 |
| --- | --- | --- |
| 홈 | 대표 버튼 | /session/setup |
| 홈 | 보조 버튼 | /test |
| 홈 | 한마디 카드의 뿌리 링크 | /roots/:id |
| 홈 | 한마디 카드의 \[3분\] | /session/setup (길이 3분 고정) |
| /session/setup | 시작 | /session/ready |
| /session/ready | 엎음 확인 | /session/running |
| /session/running | 앱 복귀(미달) | /session/interrupt |
| /session/running | 타이머 만료 | /session/done |
| /session/interrupt | 이어가기 | /session/running |
| /session/interrupt | 여기까지 / 타임아웃 | /session/done |
| /session/done | 첫 완주 | /onboard/character (1회) → 홈 |
| /session/done | 한마디 보기 | 같은 화면 확장 |
| /session/done | 위기 감지(입력 시점에 이미 판정) | /safety → 홈 |
| /test/result | 3분 시작 | /session/setup (기본값 적용) |
| /roots/:id | 작은 행동 | /session/setup (번뇌 입력 프리필) |
| 어디서든 | 뒤로 | 홈 (세션 중엔 /session/interrupt) |

## 디자인 토큰 (기존 목업 계승)

| 토큰 | 값 |
| --- | --- |
| 바탕 | #F5EFE3 (아이보리), 다크 #15130F |
| 먹 | #1F1B17 |
| 절 | #2E3B33 (temple green) |
| 주황 | #D98B2B (saffron, 대표 버튼·강조) |
| 도장 | #9B2226 (seal red, 위기·경고 아님. 상징·도장) |
| 제목 서체 | Gowun Batang (google\_fonts) |
| 본문 서체 | Noto Sans KR |
| 최소 탭 영역 | 44×44 |
| 수행중 화면 | 배경 #000, 텍스트 #F5EFE3 30% |

캐릭터: 기본 1종(후드 동자승) + 유형 아바타 4종(관세음·지장·문수·미륵) SVG. 기존 웹 SVG 중 관세음·지장·문수는 재사용, 미륵은 신규(반가사유 자세).

---

# 데이터·콘텐츠 스키마

## 로컬 DB (Isar 또는 Drift, 기기 내 저장, 서버 없음)

### Session

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| id | int (auto) |  |
| startedAt | DateTime (로컬) | 시작 타임스탬프. 날짜 귀속 기준 |
| endedAt | DateTime | 종료 |
| targetSec | int | 180 / 600 |
| practicedSec | int | 정지·유예·선택 화면 제외 실제 수행 초 |
| outcome | enum | completed / interrupted |
| detection | enum | timer / sensorA / sensorC |
| audioOn | bool |  |
| worryText | String? | 최대 80자 |
| worryChip | enum? | work/people/money/family/body/etc/heavy |
| repeatFlag | bool | "지난번 그 얘기" |
| safetyFlagged | bool | 위기 신호 감지 여부(연출 유예용) |
| isValid | bool (계산) | practicedSec ≥ 60 |
| localDate | String | yyyy-MM-dd, startedAt 기준. 인정일 집계 키 |

### DayRecord (localDate 기준 집계, 세션 종료 시 갱신)

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| localDate | String (PK) |  |
| validSessionCount | int |  |
| firstValidAt | DateTime? | 인정일 성립 시각 |
| credited | bool | 인정일 +1 여부 (하루 1) |

### Profile (단일 레코드)

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| creditedDays | int | 인정일 누적 (DayRecord.credited 합과 일치해야 함) |
| templeStage | int | 1\~6 (creditedDays로 계산, 캐시) |
| dharmaFirst | String? | 관/지/문/미 |
| dharmaStage | int | 1\~2 (MVP) |
| character | String | default / kwan / ji / mun / mi |
| typeResult | TestResult? | 최신 |
| recoveryPref | enum? | X/O/M/Q (복수면 사용자 선택값) |
| defaultsAppliedCount | int | 회복 기본값 적용 횟수 (3회 후 중단) |
| settings | Map | 음성, 알림 동의, 삼배, 감지 방식, 숫자 가리기 |
| consents | Map | recordStorage, notifications (동의 시각) |

### TestResult

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| takenAt | DateTime |  |
| answers | Map\<String, String?> | 문항 ID → 방향 또는 null(건너뜀). 심화 포함 |
| state | enum | representative / mixed / tendency / reservedInsufficient / reservedScattered |
| typeId | String? | kwan/ji/mun/mi (대표만) |
| gTop, aTop | String? | 두드러진 방향 |
| auxiliary | List\<String> | 보조 방향 |
| recovery | List\<String> | 회복 최고(복수 가능) |
| appliedToProfile | bool |  |

### DialogueExposure

| 필드 | 타입 | 설명 |
| --- | --- | --- |
| dialogueId | String |  |
| shownAt | DateTime | 14일 반복 제한 계산용 |
| role | enum | guide/observe/humor/ack/question/choice |
| intensity | enum | low/mid |

## 콘텐츠 JSON (assets/content/, 빌드 시 번들, schemaVersion 필드)

### dialogues.json

```json
{
  "schemaVersion": 1,
  "items": [
    {
      "id": "N-02",
      "text": "{time} 뒀다. 오늘은 여기까지.",
      "screen": "session_done",
      "role": "ack",
      "intensity": "low",
      "origin": "guide",
      "rootId": null,
      "requires": ["practicedSec"],
      "forbidWhen": [],
      "repeatDays": 0,
      "pool": null,
      "buttons": []
    },
    {
      "id": "44s",
      "text": "옳은 건 옳은 거다. 그래서 오늘 뭐가 달라졌냐.",
      "screen": "daily_card",
      "role": "observe",
      "intensity": "mid",
      "origin": "creative",
      "rootId": "R-05",
      "requires": [],
      "forbidWhen": ["chip:heavy", "safety"],
      "repeatDays": 14,
      "pool": "daily",
      "buttons": []
    }
  ]
}
```

origin ∈ guide(안내) / humor / creative(창작) / paraphrase(의역, roots 안에서만). screen ∈ home\_greeting, daily\_card, session\_ready, session\_running, session\_done, session\_interrupt, return, records, after\_worry, repeat, notification, fallback, plain(평문 E-). pool ∈ daily / after\_worry:{chip} / notification / null.

### roots.json

```json
{
  "schemaVersion": 1,
  "items": [
    {
      "id": "R-03",
      "kind": "paraphrase",
      "topic": "anger",
      "seonsaLine": "화를 화로 끄려고 하냐. 그건 불에 기름이다.",
      "plainExplanation": "받아치면 잠깐 시원하다. 그 다음이 있다. ...",
      "scripture": {"name": "법구경", "ref": "5", "paraphraseKo": "원한은 원한으로 결코 가라앉지 않는다. ...", "sourceNote": "Dhammapada 5, Müller 1881 (public domain)", "sourceUrl": "https://gutenberg.org/ebooks/2017"},
      "sourceStatus": "verified",
      "originalContext": "쌍의 장 ...",
      "traditionNote": null,
      "smallAction": {"text": "받아치고 싶었던 말 한 줄 적고 태우기", "link": "session_setup?prefillWorry=1&len=180"},
      "doNotUse": ["chip:heavy", "safety"],
      "reviewStatus": "edited"
    }
  ]
}
```

sourceStatus ∈ verified / partial / unverified. reviewStatus ∈ draft / edited / reviewed / public. 앱은 reviewStatus == public만 로드한다. 현재 public은 0건이며, 감수 후 값만 바꿔 배포한다.

### test.json

```json
{
  "schemaVersion": 1,
  "basis": "최근 한 달의 나",
  "elements": {"G": ["R","E","U","D"], "A": ["F","T","N","W"], "C": ["X","O","M","Q"]},
  "types": {"kwan": ["R","F"], "ji": ["D","T"], "mun": ["U","N"], "mi": ["E","W"]},
  "questions": [
    {"id": "G1", "element": "G", "context": "relationship", "text": "친구의 긴 하소연을 듣고 집에 왔다. 가장 오래 남는 생각은?",
     "options": [{"text": "...", "dir": "R"}, {"text": "...", "dir": "E"}, {"text": "...", "dir": "U"}, {"text": "...", "dir": "D"}], "skippable": true, "deep": false}
  ],
  "results": {
    "kwan": {"name": "관세음형", "line": "남의 마음은 잘 듣는데, 네 마음은 읽씹 중이다.", "symbol": {...}},
    "directions": {"R": {"interp": "...", "strength": "...", "action": "...", "actionLink": "..."}}
  },
  "scoring": {"minAnswers": 3, "topRule": "top*2>=n && top-second>=1", "deepMaxAnswered": 3, "deepMaxShown": 5}
}
```

### safety.json

키워드·패턴 목록, E-10 문구, 연락처. 전문가 검수 후 교체. 앱은 파일이 없으면 안전 화면을 비활성하지 않고 기본 연락처(추후 지정)로 동작.

## 버전 관리

- 콘텐츠 JSON은 앱 번들에 포함. schemaVersion 불일치 시 앱이 시작 시 오류 화면 대신 마지막 정상 로드본 사용
- 원격 교체는 P2 (Firebase Remote Config 또는 정적 호스팅 JSON). MVP는 앱 업데이트로만 콘텐츠 갱신
- 로컬 DB 마이그레이션은 Isar/Drift 스키마 버전으로. 삭제는 설정 "데이터 삭제"에서만

---

# 기술 아키텍처 (Flutter)

## 프로젝트 구조 (feature-first)

```
lib/
  main.dart
  app/            # MaterialApp, GoRouter, theme, l10n
  core/           # 공통: 시간 유틸(로컬 날짜), 결과 타입, 로깅, 플래그
  data/
    db/           # Isar 컬렉션, DAO, 마이그레이션
    content/      # JSON 로더(dialogues/roots/test/safety), 스키마 검증
  features/
    home/         # 홈, 한마디 카드, 마당 위젯
    session/      # 세션 상태 머신, 타이머, 감지(A/B/C 전략), 화면들
    worry/        # 번뇌 입력·태우기·반복 고민
    dialogue/     # 선사 대사 선택기(노출·반복 규칙), 공유 카드 렌더러
    temple/       # 성장 계산(인정일→단계), 절 화면, 다음 변화
    records/      # 기록
    roots/        # 말씀의 뿌리
    test/         # 문항, 채점기, 결과, 심화
    safety/       # 위기 감지·안내
    goods/        # 단주 소개
    settings/
    onboarding/
  assets/content/*.json, assets/svg/*.svg, assets/audio/*
test/             # 단위: scorer, dialogue selector, credit-day, session timer
integration_test/ # 세션 흐름, 앱 복귀
```

## 패키지 선정

| 용도 | 패키지 | 이유·비고 |
| --- | --- | --- |
| 상태관리·DI | flutter\_riverpod (+ riverpod\_generator) | 세션 상태 머신을 StateNotifier로, 테스트 용이 |
| 라우팅 | go\_router | 딥링크 파라미터 처리, 세션 중 뒤로 가기 가드 |
| 불변 모델 | freezed + json\_serializable | 콘텐츠 JSON·DB 모델 |
| 로컬 DB | isar | 오프라인, 빠른 집계. 대안 drift(SQL 필요 시) |
| 설정 | shared\_preferences | 동의·플래그 |
| 로컬 알림 | flutter\_local\_notifications | 세션 종료 알림 예약, 재방문 알림 |
| 진동 | HapticFeedback (flutter/services) 또는 vibration | 시작·종료 1회 |
| 센서 (A·C) | sensors\_plus (가속도·중력) + proximity\_sensor | 플래그 뒤. 백그라운드 수신은 검증 항목 |
| 화면 유지 (A) | wakelock\_plus | 방식 A만 |
| 오디오 | just\_audio + audio\_session (+ audio\_service, 백그라운드 재생 시) | 사용자가 켠 음원만. 무음 재생 금지 |
| 딥링크 | app\_links | 웹 테스트 → 앱 |
| 공유 | share\_plus + screenshot(위젯→이미지) | 카드 공유 |
| 서체·SVG | google\_fonts, flutter\_svg |  |
| 외부 링크 | url\_launcher | 관심 등록 폼, 원문 링크 |
| 분석 | firebase\_analytics (선택) 또는 로컬 CSV | MVP는 로컬 이벤트 로그 + 선택적 전송. 동의 전 전송 없음 |
| 플래그 | 코드 상수 (`kEnableSensorA`, `kEnableAudioC`, `kRootsEnabled`) | 원격 플래그는 P2 |

## 세션 타이머 설계 (핵심)

원칙: 틱을 세지 않는다. 시각을 기록한다. iOS·Android 모두 백그라운드에서 Dart 타이머가 멈출 수 있으므로, 세션은 타임스탬프의 합으로 계산한다.

| 이벤트 | 저장 | 계산 |
| --- | --- | --- |
| 시작 (엎음 확인) | startedAt, targetSec; 로컬 알림 startedAt+targetSec 예약 | — |
| 일시정지 (오디오 중단) | pausedAt 추가 | — |
| 재개 | resumedAt 추가; 재개 지연분만큼 알림 재예약 | practiced = Σ(구간) |
| 앱 복귀 (resumed 라이프사이클) | now 계산 | now − startedAt − Σ정지 ≥ targetSec → 완주 처리 / 미만 → 중단 선택 화면 (진입 시각 저장, 체류 제외) |
| 종료 | endedAt, practicedSec | 완주·중단 판정 |
| 앱 강제 종료 후 재실행 | 마지막 저장된 상태 복원 | startedAt 기준으로 완주 여부 판정, 기록 저장 (H8 검증) |

세션 상태는 매 전이마다 DB에 저장한다(프로세스 종료 대비). 알림은 종료 예정 시각에 진동으로만 울리고, 앱을 열면 위 계산으로 확정한다.

## 감지 전략 (전략 패턴)

```
abstract class LayDownDetector {
  Future<bool> confirmLayDown({Duration timeout});   // 준비 단계
  Stream<LiftEvent> liftEvents();                    // 수행중 로그(A·C)
}
class ButtonDetector implements LayDownDetector {...}    // B: 항상 사용 가능
class ForegroundSensorDetector ... {...}                 // A: sensors_plus + proximity, wakelock
class AudioSessionSensorDetector ... {...}               // C: 음원 재생 중 센서 구독 시도, 수신 여부 로그
```

B가 기본. A·C는 플래그로 켜고, 실패 시 5초 후 B로 폴백한다. 기록의 detection 라벨은 실제로 사용된 전략을 쓴다.

## 대사 선택기

입력: screen, context(chip, safetyFlag, firstSession, creditedDays 등), DialogueExposure 이력. 규칙: forbidWhen 필터 → 14일 반복 제외 → 세션당 intensity mid 1개 제한 → 하루 observe/question 2개 제한 → 풀에서 무작위 → 없으면 fallback(D-). 순수 함수로 구현해 단위 테스트.

## 채점기

v4 부록 C 의사코드 그대로 Dart로 이식. 입력: 문항 ID→방향/null 맵. 출력: TestResult. 사례 18건(대표·혼합·경향·유보, 경계값 B1\~B6, 0응답, 심화 단계별)을 test/scorer\_test.dart에 고정.

## 플랫폼 설정

| 항목 | iOS | Android |
| --- | --- | --- |
| 알림 | UNUserNotificationCenter 권한. 세션 종료 알림은 권한 거부 시 앱 내 진동만 | POST\_NOTIFICATIONS(13+), exact alarm은 사용하지 않음(알림 지연 허용) |
| 오디오 (C) | UIBackgroundModes audio — 사용자가 켠 음원 재생 시에만 활성. 무음 재생 없음 | 포그라운드 서비스(mediaPlayback 타입) — 음원 재생 시에만 |
| 센서 (A) | 전면에서만. NSMotionUsageDescription 불필요(가속도). 근접: UIDevice.proximityMonitoringEnabled | 전면에서만. 권한 불필요 |
| 딥링크 | Universal Links (apple-app-site-association) | App Links (assetlinks.json) — 웹 도메인 필요 |
| 최소 버전 | iOS 15 | Android 8 (API 26) |
| 화면 유지 (A) | wakelock | wakelock |

## 구현 순서 (프로토타입 → MVP)

1. 세션 코어: 타임스탬프 타이머 + ButtonDetector + 로컬 알림 + DB 저장·복원. 화면은 기본 위젯. (기술 프로토타입 = 여기 + 감지 A·C 스위치 + CSV 로그)
2. 인정일·절 단계 계산 + 홈·완료 화면
3. 대사 선택기 + dialogues.json + 한마디 카드 + 번뇌 입력·태우기 + 안전 화면
4. 테스트 채점기(단위 테스트 먼저) + 문항 화면 + 결과 3층 + 공유 카드
5. 기록·설정·온보딩·굿즈·뿌리(플래그)
6. 감지 A·C 실기기 테스트 → 채택 여부 → 플래그 결정

---

# 비기능·지표·릴리스

## 비기능 요구사항

| 영역 | 요구 | 기준 |
| --- | --- | --- |
| 시작 성능 | 콜드 스타트 → 홈 인터랙션 가능 | 2초 이내 (중급 기기) |
| 세션 정확도 | 타임스탬프 계산 오차 | ±1초 |
| 배터리 | 방식 B 3분 세션 | 측정 가능한 소모 없음. A·C는 실측 후 허용 범위 결정 |
| 오프라인 | 모든 P0 기능 | 네트워크 없이 동작. 네트워크 요청은 외부 링크·선택적 분석 전송뿐 |
| 개인정보 | 번뇌 텍스트·기록·테스트 답변 | 기기 내 저장. 서버 전송 없음. 분석 이벤트에 텍스트 포함 금지 |
| 동의 | 기록 저장·알림·분석 | 각각 별도 동의, 설정에서 철회 |
| 접근성 | 텍스트 스케일 | 시스템 글자 크기 200%에서 레이아웃 깨짐 없음. 탭 영역 44pt. 색 대비 4.5:1 |
| 다크 모드 | 지원 | 토큰 다크 값 |
| 정책 | Apple 2.5.4·2.4.2·4.10·3.1.4·2.5.14·4.5.4 | 1번 탭 제약 준수. 심사 노트에 음원 재생 목적 명시 |
| 데이터 삭제 | 설정에서 전체 삭제 | 즉시, 복구 불가 안내 |

## 분석 이벤트 (로컬 로그, 동의 시 전송)

| 이벤트 | 파라미터 | 지표 |
| --- | --- | --- |
| home\_entry\_selected | entry: practice/test/card | 입구 선택 30초 |
| session\_start | targetSec, detection, audioOn, chip | 첫 수행까지 시간 (설치 시각 대비) |
| session\_end | practicedSec, outcome, detection | 완료율, 중단 사유 |
| interrupt\_choice | resume/stop/timeout |  |
| card\_reaction | reaction: laugh/neutral/no | "피식" |
| root\_open | rootId, depth 1/2/3 | 펼침률 |
| root\_ack | rootId, ack: yes/no | 납득 |
| test\_start / test\_complete | state, deepAnswered, skipped | 완료율, 상태 분포 |
| test\_feel | score 1-5 | "나 같냐" |
| share\_sheet\_open | source: card/test | 공유 실행 |
| next\_change\_open | stage | 기대 |
| goods\_interest | price | 관심 등록 |
| notification\_open | kind | 알림 유입 vs 자발 구분 |
| safety\_shown / safety\_continue | — | 오탐 비율 |

텍스트·답변 원문은 어떤 이벤트에도 넣지 않는다.

## 릴리스 단계

| 단계 | 내용 | 완료 조건 |
| --- | --- | --- |
| 0. 기술 프로토타입 | 세션 코어 + 감지 A/B/C 스위치 + CSV 로그. BK 7일 | 감지 방식 결정, 배터리 실측 |
| 1. 내부 알파 | P0 전부, 콘텐츠는 초안 상태로 로드(뿌리 비활성) | 세션 흐름·인정일·안전 화면 통과 |
| 2. TestFlight 베타 | P1 포함, 감수 완료 콘텐츠만 public | 5명 관찰 + 인터뷰 |
| 3. 스토어 출시 (iOS) | 심사 노트: 음원 재생 목적, 센서 사용 범위, 알림 정책 | 심사 통과 |
| 4. Android | 동일 기능, 포그라운드 서비스 검증 후 | H7 통과 |

## QA 체크리스트 (핵심)

- 앱 강제 종료 후 재실행 시 진행 중 세션이 복원되고 완주·중단이 올바르게 판정된다
- 자정을 넘는 세션이 시작일에 귀속된다
- 같은 날 3세션 → 인정일 +1, 절 단계는 인정일 기준으로만 변한다
- 미접속 2일 후 복귀 시 낙엽만, 단계·인정일 변화 없음
- 칩 "많이 힘듦"에서 유머 대사 노출 0
- 위기 키워드 입력 시 안전 화면 → 세션 기록·인정일 보존, 카드·공유 비노출 | 14일 안에 같은 대사 ID 재노출 0 (DialogueExposure 검사)
- 테스트 사례 18건 단위 테스트 통과, 결과 화면에 두드러지지 않은 방향의 문장 0
- roots reviewStatus != public 항목이 어떤 경로로도 렌더되지 않음
- 무음 세션에서 전화 수신 → 앱 복귀 시 중단 선택 화면
- 알림 권한 거부 시에도 세션 종료가 앱 내에서 정상 처리
- 시스템 글자 200%에서 홈·세션·결과 화면 레이아웃 정상

## 미결 (개발 시작 전 결정)

- 로컬 DB: isar vs drift (집계 쿼리 복잡도로 판단)
- 분석: firebase\_analytics 도입 여부 (도입 시 동의 흐름·개인정보 처리방침 필요)
- 웹 테스트 도메인 확보 (Universal Links·App Links용)
- 음원 1종 확보 (저작권 확인) — 없으면 방식 C 검증 불가
- 위기 키워드·연락처(safety.json) 전문가 검수 일정
- 감수 완료 콘텐츠 5건 미달 시 뿌리 없이 출시할지 출시를 미룰지
