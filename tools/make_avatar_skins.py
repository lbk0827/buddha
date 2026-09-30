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

from PIL import Image, ImageChops, ImageFilter

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

# 떼어 낸 모자를 몇 픽셀 깎는다. 깎지 않으면 모자 둘레에 원래 살색이
# 띠처럼 남는다. 반대로 모자 가장자리가 살짝 물드는 건 눈에 띄지 않는다.
HAT_ERODE = 3
HAT_FEATHER = 1.5


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
    hat = hat.filter(ImageFilter.MinFilter(HAT_ERODE))
    hat = hat.filter(ImageFilter.GaussianBlur(HAT_FEATHER))
    return keep_only(layer, ImageChops.invert(hat))


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
