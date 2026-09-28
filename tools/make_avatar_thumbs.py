"""옷장 칸에 쓸 썸네일을 만든다.

assets/avatar/*.png (1024×1024 원본)에서 아이템 영역만 잘라
assets/avatar/thumbs/*.png (192×192)로 저장한다.

원본은 읽기만 한다. 아이템이 바뀌면 이 스크립트를 다시 돌리면 된다.

    python tools/make_avatar_thumbs.py
"""

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets" / "avatar"
OUT = SRC / "thumbs"

THUMB = 192
PAD = 0.06  # 잘라낸 영역 둘레 여백 비율

# 머리 아이템은 「머리에 씌운 모습」으로 보여준다.
# 모자만 따로 띄우면 민머리와 종류가 달라 보이고, 어느 쪽이 위인지도 안 읽힌다.
# 네 개를 같은 창으로 잘라야 크기·위치가 서로 맞는다.
HEAD_WINDOW = (250, 40, 775, 470)

ROBES = ["base_saffron", "base_temple", "base_ash", "base_crimson"]

# 머리에 씌워서 보여줄 것들. head_shaved 는 아무것도 안 씌운 상태다.
HEADS = ["head_shaved", "head_nabal", "head_bamboo", "head_straw"]

# 물건 자체를 보여주는 것들.
ITEMS = ["acc_beads", "acc_glasses", "seat_lotus", "halo_ring"]


def alpha_bbox(image: Image.Image, threshold: int = 4):
    alpha = image.getchannel("A")
    return alpha.point(lambda v: 255 if v >= threshold else 0).getbbox()


def square_fit(subject: Image.Image, size: int = THUMB) -> Image.Image:
    """비율을 유지한 채 정사각 캔버스 가운데에 놓는다."""
    w, h = subject.size
    scale = size / max(w, h)
    resized = subject.resize(
        (max(1, round(w * scale)), max(1, round(h * scale))),
        Image.Resampling.LANCZOS,
    )
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    canvas.alpha_composite(
        resized, ((size - resized.width) // 2, (size - resized.height) // 2)
    )
    return canvas


def pad_box(box, width, height):
    x0, y0, x1, y1 = box
    dx = round((x1 - x0) * PAD)
    dy = round((y1 - y0) * PAD)
    return (
        max(0, x0 - dx),
        max(0, y0 - dy),
        min(width, x1 + dx),
        min(height, y1 + dy),
    )


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    saffron = Image.open(SRC / "base_saffron.png").convert("RGBA")

    # 가사는 겹치는 옷이 아니라 몸 그림 자체다. 일부만 자르면 목 잘린 몸이 된다.
    for name in ROBES:
        image = Image.open(SRC / f"{name}.png").convert("RGBA")
        box = pad_box(alpha_bbox(image), *image.size)
        square_fit(image.crop(box)).save(OUT / f"{name}.png", optimize=True)
        print(f"{name} (전신)")

    for name in HEADS:
        worn = saffron.copy()
        if name != "head_shaved":
            worn.alpha_composite(Image.open(SRC / f"{name}.png").convert("RGBA"))
        square_fit(worn.crop(HEAD_WINDOW)).save(OUT / f"{name}.png", optimize=True)
        print(f"{name} (머리에 씌운 모습)")

    for name in ITEMS:
        image = Image.open(SRC / f"{name}.png").convert("RGBA")
        box = alpha_bbox(image)
        if box is None:
            raise SystemExit(f"{name}: 불투명 영역이 없다")
        box = pad_box(box, *image.size)
        square_fit(image.crop(box)).save(OUT / f"{name}.png", optimize=True)
        print(f"{name} {box}")


if __name__ == "__main__":
    main()
