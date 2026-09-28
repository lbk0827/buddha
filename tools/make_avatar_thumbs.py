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

# 가사는 몸 전체가 아니라 천이 보이는 구간만 보여준다.
ROBE_CROP = (300, 440, 725, 870)

# 민머리는 겹칠 레이어가 없다(베이스 그대로). 썸네일만 베이스 머리에서 딴다.
HEAD_CROP = (320, 110, 705, 430)

ROBES = ["base_saffron", "base_temple", "base_ash", "base_crimson"]
ITEMS = [
    "head_nabal",
    "head_bamboo",
    "head_straw",
    "acc_beads",
    "acc_glasses",
    "seat_lotus",
    "halo_ring",
]


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
    square_fit(saffron.crop(HEAD_CROP)).save(OUT / "head_shaved.png", optimize=True)
    print("head_shaved (베이스 머리)")

    for name in ROBES:
        image = Image.open(SRC / f"{name}.png").convert("RGBA")
        square_fit(image.crop(ROBE_CROP)).save(OUT / f"{name}.png", optimize=True)
        print(f"{name} (가사 구간)")

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
