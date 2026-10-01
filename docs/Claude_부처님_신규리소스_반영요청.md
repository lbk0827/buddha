# Claude 전달용 — 부처님 신규 리소스 반영 요청

아래 코드 블록 전체를 Claude의 새 대화에 붙여 넣는다.

````markdown
`C:\src\bucheo_handsome` 저장소에서 부처님 꾸미기 신규 리소스 8종을 앱에 반영해 주세요. 이미지 재생성은 필요하지 않습니다. 현재 작업 트리는 수정 중이므로 기존 변경을 되돌리거나 덮어쓰지 말고, 먼저 아래 문서를 읽고 현재 코드와 에셋 상태를 확인한 뒤 이어서 작업해 주세요.

- `docs/부처님_리소스_파이프라인.md`
- `docs/부처님_아이템_컨셉.md`
- `docs/부처님_머리_재작업요청서.md`

## 반드시 보존할 현재 작업

- `tools/make_avatar_skins.py`의 모자별 `HAT_ERODE`, `FOREHEAD_SEAM`, 대나무 삿갓 색상 마스크 수정
- `assets/avatar/skin_head_nabal.webp`
- `assets/avatar/skin_head_bamboo.webp`
- `assets/avatar/skin_head_straw.webp`

특히 `head_bamboo`는 챙 중앙 바로 아래에 남던 얇은 살색 띠를 정교하게 제거한 상태입니다. 이 변경을 이전 로직이나 생성물로 되돌리지 마세요.

## 반영할 원본 8종

원본은 모두 `Imgs/`에 있습니다. `Imgs/` 파일은 정본이므로 덮어쓰지 마세요.

| 원본 | id | 이름 | 슬롯 | 공덕 |
|---|---|---|---|---:|
| `head_beanie_face.png` | `head_beanie` | 비니 | `head` | 400 |
| `head_bucket_face.png` | `head_bucket` | 버킷햇 | `head` | 500 |
| `acc_sunglasses.png` | `acc_sunglasses` | 동그란 선글라스 | `face` | 700 |
| `acc_pinkshades.png` | `acc_pinkshades` | 핑크 선글라스 | `face` | 900(제안값) |
| `acc_neckphones.png` | `acc_neckphones` | 목에 건 헤드폰 | `neck` | 900 |
| `acc_goldbeads.png` | `acc_goldbeads` | 금빛 단주 | `neck` | 1300 |
| `feet_sneakers.png` | `feet_sneakers` | 흰 운동화 | 새 `feet` 슬롯 | 600 |
| `base_lavender.png` | `robe_lavender` | 라벤더 가사 | `robe` | 600 |

`acc_pinkshades`만 기획 문서에 공덕 값이 없습니다. 우선 900으로 반영하되, 다른 가격을 택한다면 이유를 결과에 적어 주세요.

## 구현 요구사항

1. 현재 스크립트와 Dart 모델을 먼저 읽고 기존 방식에 맞춰 반영합니다. 하드코딩된 목록(`BASES`, `HEADS`, `OVERLAYS`, 썸네일 목록, `kWardrobe`)을 모두 빠짐없이 갱신합니다.
2. `head_beanie_face.png`와 `head_bucket_face.png`는 이미 1024×1024 베이스 좌표에 맞춘 얼굴 포함 레이어입니다. 눈·귀 자동 측정으로 다시 확대·축소하기 전에 실제 알파 경계와 베이스 합성을 확인하세요. 정합되어 있으면 `(1.0, 0, 0)` 경로 또는 동등한 무변형 처리를 사용합니다.
3. 얼굴·목 소품과 운동화 원본은 정사각형 중앙에 크게 생성된 ‘물건 원본’일 수 있습니다. 그대로 전체 크기로 복사하지 말고 `base_saffron.png` 위에 미리보기 합성하면서 실제 착용 크기와 좌표를 정한 뒤, 1024×1024 투명 레이어로 배치합니다.
   - 선글라스: 감은 두 눈 중심에 정면 배치
   - 헤드폰: 두 이어컵이 쇄골 앞 양옆에 오고 밴드는 목 뒤로
   - 단주: 목에서 합장한 손 바로 위까지 U자
   - 운동화: 두 발을 완전히 덮되 과도하게 크지 않게
4. `AvatarSlot.feet`를 추가합니다. 저장된 예전 장착 상태가 깨지지 않도록 아이템 id 기반 복원 동작을 확인하고, `kSlotNames`, 선택 해제 가능 슬롯, 렌더링을 함께 갱신합니다. 레이어는 최소한 가사보다 위에 있어 기존 발을 완전히 덮어야 합니다. 현재 구조에 맞는 순서를 택하고 테스트로 고정하세요.
5. `base_lavender.png`는 얼굴·피부·자세·알파와 캔버스 위치를 바꾸지 않고 라벤더 가사만 사용해야 합니다. `base_lavender.webp`, 가사 썸네일, `robe_lavender` 등록까지 연결하고 `skin_body`가 정상 유지되는지 확인합니다.
6. 새 머리 두 종에는 `skin_head_beanie.webp`, `skin_head_bucket.webp`를 만들고 `kWardrobe`의 `skin`에 연결합니다. 자동 생성 결과를 신뢰하지 말고 아래 시각 검수를 수행하세요. 문제가 있으면 `make_avatar_skins.py`에 모자별 경계만 추가하고 다른 모자 값을 전역으로 바꾸지 마세요.
7. 모든 신규 아이템의 192×192 옷장 썸네일을 만들고, 썸네일에 불필요한 얼굴·몸이 섞이지 않았는지 확인합니다.
8. `Imgs/`는 앱 번들에 넣지 말고, 앱에는 `assets/avatar/`의 WebP만 포함되게 유지합니다. 생성된 PNG나 임시 미리보기를 `assets/avatar/`에 남기지 마세요.

## 필수 시각 검수

- 새 머리와 기존 `head_nabal`, `head_bamboo`, `head_straw`를 각각 핑꾸·돌·옥부처에 합성합니다.
- 3~4배 확대해 챙 중앙 아래, 양쪽 관자놀이, 귀 위, 모자 외곽을 봅니다.
- 합격 기준은 피부 영역에 원래 살색 띠가 없고, 모자는 재질색에 물들지 않으며, 백호와 두 귀가 온전히 보이는 것입니다.
- 소품은 살 재질이 바뀌어도 자기 색을 유지해야 합니다.
- 흰 운동화 아래로 발가락이나 원래 발 피부가 비치면 안 됩니다.
- 라벤더 가사는 가사 외 픽셀이 기준 이미지와 동일해야 합니다.

검수 이미지는 저장소 밖 임시 폴더에 만들거나, 꼭 남겨야 한다면 별도의 명확한 QA 폴더에 두세요. 원본을 덮어쓰지 마세요.

## 실행 및 검증

필요한 코드를 고친 뒤 다음 순서로 생성물을 다시 만드세요.

```powershell
python tools/build_avatar_assets.py
python tools/make_avatar_skins.py
python tools/make_avatar_thumbs.py
```

그다음 최소한 아래를 실행하고 실패하면 원인을 고친 뒤 다시 확인하세요.

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

기존 avatar 테스트에는 신규 8종 등록, `feet` 슬롯, 각 머리의 skin 연결, 에셋 존재 여부, 옛 저장 데이터 복원을 검증하는 항목을 추가해 주세요.

## 완료 보고 형식

- 반영한 8종과 실제 공덕 값
- 수정한 코드/스크립트 목록
- 모자 피부 경계 시각 검수 결과
- analyze/test/build 결과
- 남은 문제 또는 사람이 확인해야 할 항목

작업 중 현재 변경과 충돌하거나 요구사항이 모호하면 임의로 되돌리지 말고, 충돌 지점과 선택지를 먼저 알려 주세요.
````
