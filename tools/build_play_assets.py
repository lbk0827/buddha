"""놀이 탭 그림(목탁·싱잉볼)을 앱 에셋으로 굽는다.

Imgs/*.png (납품 원본) → assets/play/*.webp
                       → assets/play/thumb_*.webp (놀이 고르는 동그란 버튼, 192×192)

캔버스(1254×1254)를 자르거나 줄이지 않는다. 앱 코드의 기준점(채 손잡이
끝, 싱잉볼 입구 타원 등)이 이 원본 좌표로 적혀 있어서다. 화면 크기는
앱이 물체 영역(bbox) 기준으로 맞춘다.

    python tools/build_play_assets.py
"""

import sys
from pathlib import Path

from PIL import Image

from build_avatar_assets import save_layer

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "Imgs"
OUT = ROOT / "assets" / "play"

CANVAS = 1254
NAMES = ["singing_bowl", "singing_bowl_mallet", "moktak_body", "moktak_mallet"]

# 놀이 고르는 버튼 그림. 원본에서 물체 영역만 정사각으로 잘라 줄인다.
# 키캡 버튼은 앱이 키캡을 직접 그린다.
THUMBS = {"moktak_body": "thumb_moktak", "singing_bowl": "thumb_singing_bowl"}
THUMB_SIZE = 192
THUMB_PAD = 0.04


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for name in NAMES:
        image = Image.open(SRC / f"{name}.png")
        if image.size != (CANVAS, CANVAS) or image.mode != "RGBA":
            raise SystemExit(f"{name}: {image.size} {image.mode} — {CANVAS} RGBA 여야 한다")
        save_layer(image, OUT, name)
        size = (OUT / f"{name}.webp").stat().st_size
        print(f"{name}.webp  {CANVAS}×{CANVAS}  {size / 1024:.1f}KB")

    for name, thumb in THUMBS.items():
        save_layer(square_thumb(Image.open(SRC / f"{name}.png")), OUT, thumb)
        size = (OUT / f"{thumb}.webp").stat().st_size
        print(f"{thumb}.webp  {THUMB_SIZE}×{THUMB_SIZE}  {size / 1024:.1f}KB")


def square_thumb(image: Image.Image) -> Image.Image:
    box = image.getchannel("A").point(lambda a: 255 if a > 8 else 0).getbbox()
    x0, y0, x1, y1 = box
    w, h = x1 - x0, y1 - y0
    side = round(max(w, h) * (1 + 2 * THUMB_PAD))
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    canvas.alpha_composite(image.crop(box), ((side - w) // 2, (side - h) // 2))
    return canvas.resize((THUMB_SIZE, THUMB_SIZE), Image.Resampling.LANCZOS)


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    main()
