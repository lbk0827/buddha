"""「부처」 재질을 입힐 살 레이어를 만든다.

assets/avatar/ 의 몸·머리 레이어에서 살만 남긴 그림을
assets/avatar/skin_*.webp 로 저장한다. 앱은 원래 레이어 바로 위에 이것을
재질 색으로 한 번 더 겹친다. 그래서 가사·모자는 원래 색 그대로 남는다.

- skin_body — 몸. 가사 4종은 가사만 다르고 얼굴·손·발은 같은 픽셀이다.
  네 장이 서로 같은 곳이 곧 살이다. 가사가 몇 벌이 되든 한 장이면 된다.
- skin_head_* — 머리. 머리 레이어에서 모자(나발)를 뺀 나머지가 얼굴이다.
  모자를 떼어 내는 건 옷장 썸네일과 같은 방식(extract_item)이다.

build_avatar_assets.py 다음, make_avatar_thumbs.py 와 순서는 상관없다.

    python tools/build_avatar_assets.py
    python tools/make_avatar_skins.py
    python tools/make_avatar_thumbs.py
"""

import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter

from build_avatar_assets import BASES, HEADS, save_layer
from make_avatar_thumbs import NECK_Y, extract_item

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets" / "avatar"

# 가사끼리 이만큼 이하로 다르면 같은 살로 본다. WebP 손실 압축 탓에 같은 살도
# 몇 단계씩 흔들린다. SAME 에서 DIFFERENT 사이는 점점 흐려서 가사와의 경계가
# 계단지지 않게 한다.
SAME = 10
DIFFERENT = 40

# 가사 4종이 같은 몸을 공유하는지 확인하는 하한. 지금 살은 15만 px 남짓이다.
# 새 가사를 받으면서 얼굴·손까지 새로 그려졌다면 살이 확 줄어든다.
MIN_BODY_SKIN = 120_000

# 떼어 낸 모자 마스크를 안쪽으로 줄여 챙 아래에 원래 살색이 띠처럼
# 남지 않게 한다. Pillow 필터 크기라 홀수여야 한다. 넓은 챙은 생성된
# 얼굴과 맞닿는 부분이 두꺼워 나발보다 더 깊게 덮어야 한다.
HAT_ERODE = {
    "head_nabal": 7,
    "head_bamboo": 15,
    "head_straw": 15,
}
HAT_FEATHER = 1

# 모자 마스크를 줄인 영역이 모자 바깥 윤곽까지 번지면 모자 가장자리가
# 재질색으로 물든다. 베이스 머리 실루엣을 반경 5px 넓힌 범위 안에서만
# 피부 보정을 허용해 얼굴 정합 오차는 받아들이고 모자는 보호한다.
HEAD_LIMIT_DILATE = 5
HEAD_LIMIT_FEATHER = 0.7

# 챙 아래에 그려진 베이지색 이마의 위쪽 경계. 모자와 얼굴이 비슷한 색이라
# 색 차이만으로는 이 경계를 안정적으로 찾을 수 없다. 각 모자에서 눈으로
# 확인한 챙 안쪽 곡선을 따라 피부 마스크를 채운다.
FOREHEAD_SEAM = {
    "head_bamboo": [
        (315, 290), (327, 240), (350, 196), (390, 188),
        (450, 181), (512, 180), (574, 181), (634, 190),
        (674, 195), (697, 240), (709, 290),
    ],
    "head_straw": [
        (315, 288), (329, 252), (354, 227), (397, 208),
        (452, 198), (512, 196), (572, 198), (627, 208),
        (670, 227), (695, 252), (709, 288),
    ],
}


def load(name: str) -> Image.Image:
    return Image.open(SRC / f"{name}.webp").convert("RGBA")


def channel_max_diff(a: Image.Image, b: Image.Image) -> Image.Image:
    r, g, b_ = ImageChops.difference(a.convert("RGB"), b.convert("RGB")).split()
    return ImageChops.lighter(ImageChops.lighter(r, g), b_)


def keep_only(layer: Image.Image, mask: Image.Image) -> Image.Image:
    out = layer.copy()
    out.putalpha(ImageChops.multiply(layer.getchannel("A"), mask))
    return out


def body_skin() -> tuple[Image.Image, int]:
    bases = [load(name) for name in BASES]
    first = bases[0]

    diff = Image.new("L", first.size, 0)
    for other in bases[1:]:
        diff = ImageChops.lighter(diff, channel_max_diff(first, other))

    span = DIFFERENT - SAME
    mask = diff.point(
        lambda v: 255 if v <= SAME
        else 0 if v >= DIFFERENT
        else round(255 * (DIFFERENT - v) / span))
    # 가사 주름 속에 우연히 색이 같은 점들이 남는다. 작은 점만 지운다.
    mask = mask.filter(ImageFilter.MedianFilter(3))

    skin = keep_only(first, mask)
    solid = skin.getchannel("A").point(lambda v: 255 if v > 200 else 0)
    return skin, solid.histogram()[255]


def head_skin(name: str, bare_head: Image.Image) -> Image.Image:
    layer = load(name)
    hat = extract_item(layer, bare_head).getchannel("A")
    hat = hat.point(lambda v: 255 if v else 0)
    hat = hat.filter(ImageFilter.MinFilter(HAT_ERODE.get(name, 7)))
    hat = hat.filter(ImageFilter.GaussianBlur(HAT_FEATHER))

    # 피부 마스크는 모자 아래쪽으로 조금 파고들어야 살색 틈을 덮는다.
    # 다만 그 마스크를 모자 바깥 윤곽까지 허용하면 재질색 테두리가 생기므로
    # 원래 민머리 실루엣 부근으로 제한한다.
    head_limit = bare_head.getchannel("A").point(lambda v: 255 if v else 0)
    head_limit = head_limit.filter(ImageFilter.MaxFilter(HEAD_LIMIT_DILATE))
    head_limit = head_limit.filter(ImageFilter.GaussianBlur(HEAD_LIMIT_FEATHER))
    skin_mask = ImageChops.multiply(ImageChops.invert(hat), head_limit)

    if name in FOREHEAD_SEAM:
        points = FOREHEAD_SEAM[name]
        forehead = Image.new("L", layer.size, 0)
        ImageDraw.Draw(forehead).polygon(
            points + [(points[-1][0], NECK_Y), (points[0][0], NECK_Y)],
            fill=255,
        )
        forehead = forehead.filter(ImageFilter.GaussianBlur(1))
        if name == "head_bamboo":
            # 삿갓은 밝은 황토색 챙과 피부색이 비슷하다. 얼굴의 바깥쪽
            # 픽셀을 제외하고 피부의 주황색 계열만 보정해, 챙 밑 삼각형은
            # 덮되 모자 테두리와 귀 옆 모자 안쪽은 물들이지 않는다.
            hue = layer.convert("HSV").getchannel("H")
            skin_hue = hue.point(
                lambda value: 255 if value <= 20
                else 0 if value >= 25
                else round(255 * (25 - value) / 5))
            forehead = ImageChops.multiply(forehead, head_limit)
            forehead = ImageChops.multiply(forehead, skin_hue)

        skin_mask = ImageChops.lighter(skin_mask, forehead)

    return keep_only(layer, skin_mask)


def main() -> None:
    if len(BASES) < 2:
        raise SystemExit("가사가 두 벌 이상 있어야 살과 가사를 가를 수 있다")

    skin, count = body_skin()
    if count < MIN_BODY_SKIN:
        raise SystemExit(
            f"가사끼리 같은 살이 {count}px 뿐이다 — 새 가사의 얼굴·손이 "
            "원본과 달라졌는지 확인")
    save_layer(skin, SRC, "skin_body")
    print(f"skin_body  (가사 {len(BASES)}벌이 같은 살 {count}px)")

    # 머리 레이어에서 모자를 떼어 낼 때 비교 대상이 되는 맨머리.
    saffron = load("base_saffron")
    bare_head = saffron.copy()
    bare_alpha = saffron.getchannel("A").copy()
    bare_alpha.paste(0, (0, NECK_Y, 1024, 1024))
    bare_head.putalpha(bare_alpha)

    for name in HEADS:
        save_layer(head_skin(name, bare_head), SRC, f"skin_{name}")
        print(f"skin_{name}")


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    main()
