"""납품받은 스프라이트를 앱 에셋으로 굽는다.

Imgs/*.png (납품 원본) → assets/avatar/*.webp (앱에 나가는 것)

원본은 무손실 PNG 로 두고, 앱에는 WebP(품질 90)로 굽는다. 1024 캔버스
레이어 한 장이 PNG 로 300~400KB, WebP 로 50KB 안팎이다.

머리 아이템은 「모자 쓴 얼굴」을 통째로 받는다. 받는 형태는 두 가지다.

- head_*_face.png — 얼굴만 그린 그림. 다시 받은 그림은 원본을 덮어쓰지
  않고 head_*_face_v2.png 처럼 번호를 붙이며, 가장 높은 번호를 쓴다. 캔버스도 배율도 베이스와 다르므로
  베이스 얼굴에 포개지게 옮겨 놓는다 (FACE_FIT). 모자만 따로 그려 얹으면
  모자가 머리를 덮지 못하고 뚜껑처럼 올라앉는다. 그래서 얼굴째 받는다.
- head_*_full.png — 베이스를 편집한 전신. 좌표가 같으니 목 위만 자른다.

얼굴·목·발 소품은 「물건만」 크게 그려 받는다. 베이스에 대 보며 정한
크기·자리(PLACED)로 1024 캔버스에 옮겨 놓고, 몸 뒤로 가야 하는 부분
(합장한 손 뒤, 목 뒤, 가사 밑단 안)은 지운다.

소품 자리는 기준 캐릭터(동자 부처) 위에서 정하고, 어느 앵커(눈·입·목·
발…)를 따라가는지 함께 적는다. 다른 캐릭터에는 두 캐릭터의 앵커를 따라
옮겨 굽는다(avatar_anchors.py). 기준 캐릭터에서는 옮기지 않는다.

**아이템을 보기 좋게 옮기는 보정은 하지 않는다.** FACE_FIT 은 「얼굴을
베이스 얼굴에 겹치는」 정합일 뿐이고, 그 결과가 베이스 머리를 다 덮는지
여기서 검사한다. 모자가 크거나 낮아 보이면 그건 생성 단계에서 잡는다.

    python tools/build_avatar_assets.py
    python tools/make_avatar_thumbs.py    # 썸네일은 이 결과에서 다시 뽑는다

새 얼굴이 들어오면 먼저 FACE_FIT 값을 잰다.

    python tools/build_avatar_assets.py --measure head_bamboo

전체 절차는 docs/부처님_리소스_파이프라인.md.
"""

import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter

from avatar_anchors import REFERENCE, Character, find_eyes, map_placement

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "Imgs"
OUT = ROOT / "assets" / "avatar"

CANVAS = 1024

# 베이스 실루엣을 재보면 귀가 세로 320~470 까지 내려오고, 목은 478 근처에서
# 가장 좁아진다. 여기서 자르면 잘린 면이 제일 작고, 그 아래는 베이스와 같은
# 픽셀이라 이음매가 보이지 않는다. 캐릭터마다 다르다(characters/*.json).
NECK_Y = REFERENCE.neck_cut_y

# 잘린 끝을 몇 픽셀 흐리게 해서 경계선이 서지 않게 한다.
NECK_FEATHER = 6

# head_*_face.png 를 베이스 좌표로 옮기는 값: (배율, 왼쪽, 위).
# --measure 로 잰다. 두 눈의 가운데를 베이스 눈 가운데에 맞추고, 배율은
# 귀 끝에서 귀 끝까지의 폭에서 출발해 베이스 머리가 가장 덜 비치는 값을
# 고른다. 눈 사이로 재면 GPT 얼굴의 귀가 상대적으로 작아져서 뒤의 베이스
# 귀·민머리가 비친다.
FACE_FIT = {
    "head_bamboo": (0.614, 126, -90),
    "head_straw": (0.626, 119, -76),
    "head_nabal": (0.625, 121, -116),
    "head_beanie": (0.5, 200, -13),
    "head_bucket": (0.544, 172, -47),
}

# 앱에 굽는 WebP 품질. 알파는 무손실로 남는다.
WEBP_QUALITY = 90

# 옮긴 얼굴 뒤로 베이스 민머리가 이만큼 넘게 비치면 정합이 틀린 것이다.
MAX_PEEK = 400

BASES = ["base_saffron", "base_temple", "base_ash", "base_crimson",
         "base_lavender"]
HEADS = ["head_nabal", "head_bamboo", "head_straw", "head_beanie", "head_bucket"]
# 1024 캔버스 제자리에 놓인 채로 받은 소품(예전 방식)과, 따라가는 앵커.
OVERLAYS = {
    "acc_beads": "neck",
    "acc_glasses": "eyes",
    "seat_lotus": "body",
}

# 물건만 그려 받은 소품을 베이스에 놓는 값.
#   (따라갈 앵커, 배율, 원본 기준점, 베이스 기준점, 몸 뒤로 숨길 곳)
# 원본 기준점이 베이스 기준점에 오도록 배율대로 줄여 놓는다. 베이스 기준점은
# 기준 캐릭터(동자 부처) 위의 자리다. 베이스를 대 보며 정했다 — 감은 두 눈
# 가운데 (510, 356), 목 y 478, 합장한 손끝 y 520, 두 발 중심 x 457·565 ·
# 발바닥 y 918. 다른 캐릭터에서는 앵커를 따라 옮겨진다.
#   선글라스  두 렌즈 중심 간격을 두 눈 간격(156)에 맞춘다. 동그란 것은 아래
#             테가 입꼬리에 닿아 6% 줄였다
#   신호등    두 신호등 알 중심 간격(239)을 눈 간격에 맞춘다. 원본에서 알을
#             상단에 모아, 오른쪽 기둥 끝이 축소 뒤 발바닥 아래(y≈965)에 닿는다
#   헤드폰    두 컵이 쇄골 앞 양옆, 밴드는 목 뒤(BAND 를 지운다), 컵은 손 뒤
#   금빛 단주 손끝이 목 바로 아래라 U 를 손 위에 둘 자리가 없다. 손 뒤로
#             지나 손 아래에서 U 가 보이게 한다
#   풍선껌    입(510, 396)을 덮도록 지름 105, 가운데를 입보다 조금 아래(412)에
#             둔다. 더 크면 안경과 턱을 다 가린다. 원본 풍선 지름 829
#   터진 껌   풍선이 터진 뒤 입 둘레에 붙은 껌. 폭 120, 풍선과 같은 자리.
#             옷장 아이템이 아니라 풍선껌 연출에서만 쓴다
#   운동화    두 짝 간격을 두 발 간격보다 조금 넓게(128) 잡아 발가락까지
#             덮고, 가사 밑단 안쪽은 지운다
#   과녁 안대 원본 과녁 중심과 지름(약 529)을 왼쪽 눈과 100px에 맞춘다
#   스노클    두 렌즈 중심 간격(408)을 눈 간격에 맞추면 아래 테가 입선을 덮어,
#             15% 줄이고 10px 올린다
#   VR 고글   앞판 폭(882)을 230px로 맞추면 아래 테가 입선을 덮어 입 아이템이 고글
#             위에 뜬다. 15% 줄이고 16px 올린다. 백호는 그대로 보인다
#   오이 팩   v1 은 두 조각 간격(585)이 지름(423)에 비해 좁아, 눈 간격에 맞추면
#             지름 114px로 입선에 닿고 지름에 맞추면 눈 끝이 삐져나왔다. v2 는
#             조각만 떼어 간격을 695 로 벌린 것. 눈 간격에 맞추면 지름 약 95px
#   스키 고글 렌즈 폭(703)을 250px로 맞추면 코 홈까지 입선을 덮어 입 아이템이 렌즈
#             위에 뜬다. 18% 줄이고 22px 올려 홈 사이로 입이 보이게 한다
#   하트 안경 눈 간격 배율은 아래 테가 입꼬리에 닿아 16% 줄이고 중심을 11px 낮춰 잡는다
#   별 안경   눈 간격 배율은 별 아래 테가 입꼬리에 닿아 20% 줄이고 중심을 14px 낮춰 잡는다
#   바이저    가운데가 아래로 휜 띠라 폭 300px 에서는 입선을 덮어, 270px 로
#             줄이고 14px 올린다. 눈썹은 띠 위로 보인다
#   후광      원본 링(중심 510.5, 298.5) 그대로는 테가 민머리 윤곽에 겹치고 비니·
#             모자에 다 덮인다. 1.4배로 키워 링 중심을 두 눈 가운데에 두면 테
#             안쪽 지름이 약 510px로 비니(폭 약 470)보다 넓어 머리 둘레로 드러난다.
#             위쪽 빛 번짐은 캔버스 위로 몇 px 잘리지만 거의 투명한 부분이다
#   쪽쪽이    흰 방패판 폭(822)을 80px로 맞춰 입선을 덮고, 안경 아래 테에
#             닿지 않게 입보다 9px 낮춘다
#   붕어빵    머리 끝에서 꼬리 끝까지(801)를 115px로. 150px 이면 볼과 턱 아래까지
#             덮었다. 문 머리가 입 가운데에 오게 14px 왼쪽으로
#   떡꼬치    꼬치 전체 폭(905)을 220px로 맞춰 눈 아래에서 가로로 문다
#   호루라기  무는 끝을 입에 맞추고 전체 폭(648)을 90px로 줄여 몸통이 턱 위에서 끝난다
#   콧수염    폭(824)을 130px로 맞추고 원본 기준점을 낮춰 아래 끝이 y=392에서 끝나게 한다
#   막대사탕  지름 110px면 눈에 닿아 90px로 줄이고 입보다 5px 낮춰 사탕 위가 y≈358에 온다
#   금니 웃음 전체 폭(776)을 70px로 맞춰 원래 입선을 빠짐없이 덮는다
#   턱받이    v2: 문구를 위쪽 띠로 올린 그림. 폭 200px, 문구가 손끝 위에 다 보이게
#             올리고, 턱 위로 올라온 뒤쪽 목둘레는 턱 뒤로 숨긴다("chin")
#   목베개    전체 폭(840)을 220px로 맞춰 턱 바로 밑(y 505)에 걸고 손 뒤로 숨긴다.
#             더 내리면 가슴에 떠서 손 앞을 가리고, 더 올리면 입선을 덮는다
#   꽃목걸이  전체 폭(684)을 215px로 맞춰 가슴까지 내리고 손 뒤로 숨긴다.
#             260px 은 어깨 밖으로 넘쳤다
#   금 체인   전체 폭(953)을 180px로 맞춰 목 밑동(기준점 y 460)에 건다. 더 올리면
#             턱 선에 걸치고, 펜던트는 이 자리에서도 손끝 위에 보인다
#   필름 카메라 작은 본체를 손 오른쪽에 두려고 끈 기준점을 13px 오른쪽으로 옮긴다
#   민트 헤드폰 원본과 모양·알파가 같아서 헤드폰의 위치와 BAND 가림 값을 그대로 쓴다
#   오리발    두 짝 간격(354.4)을 128px로 맞추고 날개 끝을 발바닥 아래 y=990에 둔다
#   슬리퍼    128px 간격에서는 발 가장자리가 비쳐 108px로 안쪽에 모으고 9px 내렸다
#   스니커즈  (빨간 하이탑. 발목은 가사에 덮여 앞코만 보인다) 간격 136px, 바닥 y 927.
#             더 올리면 밑창 아래로 발가락이 나와 SHOE_GAP_SHADOW 띠가 생기고,
#             더 내리면 발등이 비친다
#   통굽 부츠 128px 간격에서 발 15px가 비쳐 118px로 모으고 밑창 끝을 y=958에 둔다
#   스케이트보드 폭 380px, 윗면 가운데를 y=925에 두면 바퀴가 y=1008에서 끝난다
#   목욕탕 의자 폭 260px, 낮은 앉는 면을 y=925에 두면 다리가 y=1015에서 끝난다
#   로봇청소기 폭 320px, 윗면 가운데를 y=925에 두고 아래 끝을 y=1020 안에 둔다
#   킥보드    손잡이 폭 340px 은 끝이 허리 옆에 점처럼만 보여 킥보드로 안 읽혔다.
#             440px 로 키워 손잡이가 가슴 높이에서 몸 양옆으로 나오게 한다. 발판은 y=925
#   OPEN      폭 220px·높이 110px, 중심 (130, 120)으로 옮겨 모든 모자의 왼쪽에 보이게 한다
#   와이파이  폭 200px·높이 143px, 중심 (130, 130)으로 옮겨 세 줄과 점이 눌리지 않게 한다
#   로딩      바깥 지름 666px로 맞춰 비니 둘레에 12점이 드러나게 한다
#   LP        바깥 지름 666px, 중심을 눈 가운데에 두어 가장자리 홈과 스티커가 보이게 한다
#   디스코볼  머리 위 100px 에 넣으면 너무 작고 모자에 가렸다. 체인 위 끝을 캔버스
#             위(y 4)에 걸고 머리 오른쪽 위(x 860)에 높이 190px 로 매단다. 삿갓 챙(x 792)
#             밖이라 어느 모자에도 안 가린다
#   네온 링   바깥 지름 666px, 안쪽 약 512px로 비니 폭보다 넓게 남긴다
PLACED = {
    "acc_sunglasses": ("eyes", 156 / 452 * 0.94, (512, 515), (510, 356), ()),
    "acc_trafficlight": ("eyes", 156 / 239, (661, 289), (510, 356), ()),
    "acc_pinkshades": ("eyes", 156 / 462, (512, 512), (510, 356), ()),
    "acc_neckphones": ("neck", 0.34, (512, 477), (512, 470), ("band", "hands")),
    "acc_goldbeads": ("neck", 170 / 685, (512, 99), (512, 466), ("hands",)),
    "feet_sneakers": ("feet", 128 / 336, (511, 776), (511, 936), ("robe",)),
    "mouth_bubblegum": ("mouth", 105 / 829, (626.5, 621), (510, 412), ()),
    "mouth_bubblegum_popped": ("mouth", 120 / 940, (634, 646.5), (510, 410), ()),
    "acc_targetpatch": ("eyes", 100 / 529, (657, 667), (432, 356), ()),
    "acc_snorkel": ("eyes", 156 / 408 * 0.85, (626, 808), (510, 346), ()),
    "acc_vr": ("eyes", 230 / 882 * 0.85, (627, 637), (510, 340), ()),
    "acc_cucumber": ("eyes", 156 / 695, (642.5, 692), (510, 353), ()),
    "acc_skigoggles": ("eyes", 250 / 703 * 0.82, (611, 633), (510, 334), ()),
    "acc_heartshades": ("eyes", 156 / 436 * 0.84, (626, 650), (510, 356), ()),
    "acc_partystars": ("eyes", 156 / 489 * 0.80, (627, 655), (510, 356), ()),
    "acc_cybervisor": ("eyes", 300 / 908 * 0.9, (628, 637), (510, 342), ()),
    "halo_ring": ("head", 1.4, (510.5, 298.5), (510, 356), ()),
    "mouth_pacifier": ("mouth", 80 / 822, (627, 569), (510, 405), ()),
    "mouth_bungeoppang": ("mouth", 115 / 801, (258, 484), (496, 398), ()),
    "mouth_tteokkochi": ("mouth", 220 / 905, (629.5, 633), (510, 400), ()),
    "mouth_whistle": ("mouth", 90 / 648, (308, 486), (510, 400), ()),
    "mouth_mustache": ("mouth", 130 / 824, (627, 704), (510, 380), ()),
    "mouth_lollipop": ("mouth", 90 / 480, (164, 632), (510, 405), ()),
    "mouth_grillz": ("mouth", 70 / 776, (627, 667), (510, 400), ()),
    "acc_bib": ("neck", 200 / 962, (632, 544), (512, 484), ("hands", "chin")),
    "acc_neckpillow": ("neck", 220 / 840, (627, 700), (512, 505), ("hands",)),
    "acc_lei": ("neck", 215 / 684, (635, 205), (512, 472), ("hands",)),
    "acc_goldchain": ("neck", 180 / 953, (626.5, 488), (512, 460), ("hands",)),
    "acc_filmcamera": ("neck", 0.45, (434, 462), (525, 478), ("hands",)),
    "acc_neckphones_mint": ("neck", 0.34, (512, 477), (512, 470), ("band", "hands")),
    "feet_flippers": ("feet", 128 / 354.4, (626.7, 853), (511, 990), ("robe",)),
    "feet_slippers": ("feet", 108 / 389.9, (627, 982), (511, 945), ("robe",)),
    "feet_hightops": ("feet", 136 / 403.8, (626.5, 944), (511, 927), ("robe",)),
    "feet_platformboots": ("feet", 118 / 417.6, (627.5, 990), (511, 958), ("robe",)),
    "seat_skateboard": ("body", 380 / 1000, (627, 550), (512, 925), ()),
    "seat_bathstool": ("body", 260 / 922, (627, 504), (512, 925), ()),
    "seat_robovac": ("body", 320 / 899, (626.5, 602), (512, 925), ()),
    "seat_kickboard": ("body", 440 / 780, (627, 970), (512, 925), ()),
    "halo_open": ("head", 220 / 1000, (627, 627), (130, 120), ()),
    "halo_wifi": ("head", 200 / 1000, (627, 627), (130, 130), ()),
    "halo_loading": ("head", 666 / 890, (627, 627), (510, 356), ()),
    "halo_lp": ("head", 666 / 1000, (627, 627), (510, 356), ()),
    "halo_discoball": ("head", 190 / 586, (626.5, 334), (860, 4), ()),
    "halo_neon": ("head", 666 / 1000, (627, 627), (510, 356), ()),
}

# 옷장 아이템이 아니라 연출에만 쓰는 레이어. 썸네일을 만들지 않는다.
MOTION_ONLY = {"mouth_bubblegum_popped"}

# 헤드폰 원본에서 목 뒤로 넘어가는 밴드. 양쪽 경첩 사이, 쿠션 위쪽의 띠다.
BAND = [(325, 500), (420, 512), (512, 520), (604, 512), (700, 500),
        (692, 546), (632, 562), (606, 586), (512, 600), (418, 586),
        (392, 562), (332, 546)]


# 원본 둘레에 투명도 1~15 짜리 흐린 점이 수천 개 흩어져 있다. 지운다.
ALPHA_FLOOR = 16

# 운동화로 덮었는지 검사할 발의 윗선. 기준 캐릭터에서 가사 밑단 바로 아래다.
FEET_TOP_Y = 840

# 운동화 두 짝 사이 위쪽은 발목이 가늘어져 발이 비친다. 가사 밑단 아래
# 그림자처럼 어두운 중간색으로 메운다. 가사 색을 따면 다른 가사에서 어긋난다.
SHOE_GAP_SHADOW = (72, 62, 56)


def load(name: str, any_size: bool = False) -> Image.Image:
    """원본을 읽는다. 레이어는 1024 정사각이어야 한다.

    any_size — 물건만 그려 받은 소품. 배율로 줄여 놓으니 정사각이기만 하면 된다.
    """
    path = latest_source(name)
    if not path.exists():
        raise SystemExit(f"{path} 가 없다")
    image = Image.open(path)
    if any_size:
        if image.width != image.height:
            raise SystemExit(f"{name}: {image.size} — 정사각이어야 한다")
    elif image.size != (CANVAS, CANVAS):
        raise SystemExit(f"{name}: {image.size} — {CANVAS} 정사각이어야 한다")
    if image.mode != "RGBA":
        image = image.convert("RGBA")
    if image.getchannel("A").getbbox() is None:
        raise SystemExit(f"{name}: 전부 투명하다")
    return image


def cut_head(full: Image.Image) -> Image.Image:
    """전신에서 목 위만 남긴다."""
    keep = Image.new("L", full.size, 0)
    keep.paste(255, (0, 0, CANVAS, NECK_Y - NECK_FEATHER))

    # 자른 끝을 몇 줄에 걸쳐 흐리게 해서 경계선이 서지 않게 한다.
    span = NECK_FEATHER * 2
    for i in range(span):
        value = 255 - round(255 * i / (span - 1))
        y = NECK_Y - NECK_FEATHER + i
        keep.paste(value, (0, y, CANVAS, y + 1))

    head = full.copy()
    head.putalpha(ImageChops.multiply(full.getchannel("A"), keep))
    return head


def latest_source(stem: str) -> Path:
    """Imgs/ 원본. 원본은 덮어쓰지 않으므로 _v2, _v3 … 가 있으면 가장 높은 번호."""
    versions = []
    for path in SRC.glob(f"{stem}_v*.png"):
        suffix = path.stem.rsplit("_v", 1)[1]
        if suffix.isdigit():
            versions.append((int(suffix), path))
    if versions:
        return max(versions)[1]
    return SRC / f"{stem}.png"


def face_source(name: str) -> Path:
    """머리 아이템의 얼굴 원본."""
    return latest_source(f"{name}_face")


def fit_face(face: Image.Image, fit, base: Image.Image) -> Image.Image:
    """얼굴 그림을 베이스 캔버스로 옮기고 목 아래를 자른다."""
    scale, left, top = fit
    size = round(face.width * scale)
    moved = face.resize((size, size), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    canvas.paste(moved, (left, top))
    head = cut_head(canvas)

    # 뒤에 깔린 베이스 머리가 새 얼굴 밖으로 비치는지 센다.
    solid = lambda a: a.point(lambda v: 255 if v > 128 else 0)
    under = solid(base.getchannel("A"))
    under.paste(0, (0, NECK_Y - 8, CANVAS, CANVAS))
    peek = ImageChops.subtract(under, solid(head.getchannel("A"))).histogram()[255]
    if peek > MAX_PEEK:
        raise SystemExit(f"베이스 머리가 {peek}px 비친다 — FACE_FIT 을 다시 재야 한다")
    return head, peek


def peek_of(face: Image.Image, fit, under: Image.Image) -> int:
    scale, left, top = fit
    size = round(face.width * scale)
    alpha = face.getchannel("A").resize((size, size), Image.Resampling.BILINEAR)
    placed = Image.new("L", (CANVAS, CANVAS), 0)
    placed.paste(alpha, (left, top))
    placed = placed.point(lambda v: 255 if v > 128 else 0)
    return ImageChops.subtract(under, placed).histogram()[255]


def measure(name: str) -> None:
    """head_*_face.png 의 FACE_FIT 값을 잰다."""
    source = face_source(name)
    face = Image.open(source).convert("RGBA")
    base = load("base_saffron")
    print(f"원본 {source.name}")

    (bx, by), base_span = find_eyes(base)
    (fx, fy), face_span = find_eyes(face)
    start = base_span / face_span
    print(f"베이스 눈 ({bx:.0f}, {by:.0f}) 귀폭 {base_span}")
    print(f"{name} 눈 ({fx:.0f}, {fy:.0f}) 귀폭 {face_span} → 배율 {start:.3f}")

    under = base.getchannel("A").point(lambda v: 255 if v > 128 else 0)
    under.paste(0, (0, NECK_Y - 8, CANVAS, CANVAS))

    tried = []
    for step in range(-6, 7):
        scale = round(start + step * 0.005, 3)
        left = round(bx - fx * scale)
        for nudge in range(-16, 17, 2):
            top = round(by - fy * scale) + nudge
            fit = (scale, left, top)
            tried.append((peek_of(face, fit, under), fit))
    tried.sort()

    print("비침이 적은 순:")
    for peek, fit in tried[:3]:
        print(f"  {fit}  비침 {peek}px")
    best_peek, best = tried[0]
    if best_peek > MAX_PEEK:
        print("비침이 기준을 넘는다 — 얼굴이 베이스와 너무 다르다. 다시 받는다")
    print()
    print("FACE_FIT 에 넣을 값:")
    print(f'    "{name}": {best},')


def body_masks(character: Character = REFERENCE):
    """소품을 몸 뒤로 숨길 때 쓰는 가사·손 마스크를 원본 PNG 에서 만든다.

    가사 = 가사 원본끼리 다른 픽셀. 발가락 윤곽이나 밑단 아래 발등 그림자도
    가사마다 조금씩 달라 같이 잡히므로, 가는 선은 열림 연산으로 걸러 내고
    안쪽으로 몇 픽셀 더 깎는다. 소품이 가사 경계 밑으로 살짝 파고들어야
    아래 살이 비치지 않는다.
    """
    bases = [load(name) for name in BASES]
    first = bases[0]
    diff = Image.new("L", first.size, 0)
    for other in bases[1:]:
        r, g, b = ImageChops.difference(
            first.convert("RGB"), other.convert("RGB")).split()
        diff = ImageChops.lighter(diff, ImageChops.lighter(ImageChops.lighter(r, g), b))
    body = first.getchannel("A").point(lambda v: 255 if v > 128 else 0)
    robe = ImageChops.multiply(diff.point(lambda v: 255 if v > 40 else 0), body)
    skin = ImageChops.subtract(body, robe.filter(ImageFilter.MaxFilter(3)))
    robe = (robe.filter(ImageFilter.MinFilter(9)).filter(ImageFilter.MaxFilter(9))
            .filter(ImageFilter.MinFilter(7)).filter(ImageFilter.GaussianBlur(0.8)))

    outline = Image.new("L", first.size, 0)
    ImageDraw.Draw(outline).polygon(list(character.hand_outline), fill=255)
    hands = ImageChops.multiply(skin.filter(ImageFilter.MaxFilter(3)), outline)
    hands = hands.filter(ImageFilter.GaussianBlur(0.8))
    # 턱 = 목 자르는 줄보다 위의 살. 목에 두르는 것의 뒤쪽 목둘레는 턱 뒤로 간다.
    chin = skin.copy()
    chin.paste(0, (0, character.neck_cut_y, CANVAS, CANVAS))
    chin = chin.filter(ImageFilter.GaussianBlur(0.8))
    return {"robe": robe, "hands": hands, "skin": skin, "chin": chin}


def hide(layer: Image.Image, mask: Image.Image) -> Image.Image:
    out = layer.copy()
    out.putalpha(ImageChops.multiply(layer.getchannel("A"), ImageChops.invert(mask)))
    return out


def place_overlay(name: str, target: Character = REFERENCE) -> Image.Image:
    """제자리에 놓인 채로 받은 소품을 target 캐릭터로 옮긴다.

    기준 캐릭터면 원본 그대로다. 다른 캐릭터면 앵커를 축으로 통째로
    키우고 옮긴다.
    """
    layer = load(name)
    if target.id == REFERENCE.id:
        return layer
    anchor = REFERENCE.anchors[OVERLAYS[name]]
    scale, (x, y) = map_placement(OVERLAYS[name], 1.0, (anchor.x, anchor.y), target)
    size = round(CANVAS * scale)
    moved = layer.resize((size, size), Image.Resampling.LANCZOS)
    out = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    out.paste(moved, (round(x - anchor.x * scale), round(y - anchor.y * scale)), moved)
    return out


def place_item(name: str, masks, target: Character = REFERENCE) -> Image.Image:
    """물건 원본을 PLACED 값대로 target 캐릭터 캔버스에 옮기고, 몸 뒤를 지운다.

    masks 는 target 캐릭터의 몸으로 만든 것이어야 한다(body_masks).
    """
    anchor, scale, (sx, sy), dest, behind = PLACED[name]
    scale, (dx, dy) = map_placement(anchor, scale, dest, target)
    item = load(name, any_size=True)
    item.putalpha(item.getchannel("A").point(lambda v: 0 if v < ALPHA_FLOOR else v))

    if "band" in behind:
        band = Image.new("L", item.size, 0)
        ImageDraw.Draw(band).polygon(BAND, fill=255)
        item = hide(item, band.filter(ImageFilter.GaussianBlur(2)))

    size = round(item.width * scale)
    moved = item.resize((size, size), Image.Resampling.LANCZOS)
    layer = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    layer.paste(moved, (round(dx - sx * scale), round(dy - sy * scale)), moved)

    for part in behind:
        if part in masks:
            layer = hide(layer, masks[part])

    if name.startswith("feet_"):
        _, (_, feet_top) = map_placement("feet", 1.0, (0, FEET_TOP_Y), target)
        feet = masks["skin"].copy()
        feet.paste(0, (0, 0, CANVAS, round(feet_top)))
        solid = layer.getchannel("A").point(lambda v: 255 if v > 128 else 0)
        gap = ImageChops.subtract(feet, solid)
        gap = gap.filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.GaussianBlur(1))
        shadow = Image.new("RGBA", layer.size, SHOE_GAP_SHADOW + (255,))
        shadow.putalpha(gap)
        filled = Image.new("RGBA", layer.size, (0, 0, 0, 0))
        filled.alpha_composite(shadow)
        filled.alpha_composite(layer)
        layer = filled

        # 신발이 덜 덮은 발. 0 이어야 한다.
        weak = ImageChops.multiply(
            feet, layer.getchannel("A").point(lambda v: 255 if v < 250 else 0))
        bare = weak.histogram()[255]
        if bare > 10:
            raise SystemExit(f"{name}: 발이 {bare}px 비친다 — PLACED 값을 다시 잰다")
    return layer


def save_layer(image: Image.Image, directory: Path, name: str) -> None:
    """WebP 로 굽고, 같은 이름의 예전 PNG 는 지운다.

    pubspec 은 폴더째 등록돼 있어서 PNG 가 남으면 APK 에 같이 들어간다.
    """
    image.save(directory / f"{name}.webp", "WEBP",
               quality=WEBP_QUALITY, method=6)
    (directory / f"{name}.png").unlink(missing_ok=True)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    for name in BASES:
        save_layer(load(name), OUT, name)
        print(name)

    for name in OVERLAYS:
        save_layer(place_overlay(name), OUT, name)
        print(name)

    masks = body_masks()
    for name in PLACED:
        save_layer(place_item(name, masks), OUT, name)
        print(f"{name}  (물건 원본을 베이스에 놓음)")

    base = load("base_saffron")

    for name in HEADS:
        face = face_source(name)
        full = SRC / f"{name}_full.png"
        if face.exists():
            image = Image.open(face).convert("RGBA")
            head, peek = fit_face(image, FACE_FIT[name], base)
            save_layer(head, OUT, name)
            print(f"{name}  ({face.name} 를 베이스에 포갬, 비침 {peek}px)")
        elif full.exists():
            # 새 방식: 전신을 받아 목 위만 잘라낸다.
            save_layer(cut_head(load(f"{name}_full")), OUT, name)
            print(f"{name}  (전신에서 목 위만)")
        else:
            # 아직 재작업 전. 예전 「모자만」 그림을 그대로 쓴다.
            save_layer(load(name), OUT, name)
            print(f"{name}  (구버전 — {name}_full.png 를 기다리는 중)")


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    if len(sys.argv) == 3 and sys.argv[1] == "--measure":
        measure(sys.argv[2])
    else:
        main()
