"""절 탭 아이콘을 앱 에셋으로 굽는다.

Imgs/icon_lotus.png      (1024 캔버스) → assets/home/icon_lotus.webp      (192×192)
Imgs/icon_meditation.png (1024 캔버스) → assets/home/icon_meditation.webp (192×192)

연꽃은 「부처님 말씀」 카드, 향은 [명상] 버튼 글자 왼쪽에 놓이는 작은
그림이라, 그림 영역만 정사각으로 잘라 줄인다. 1024 캔버스를 그대로 쓰면
투명 여백 때문에 그림이 작아 보인다. 192px 은 40dp × 기기 배율 4 를 덮는다.

    python tools/build_home_assets.py
"""

import sys
from pathlib import Path

from PIL import Image

from build_avatar_assets import save_layer

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "Imgs"
OUT = ROOT / "assets" / "home"

SIZE = 192

# 잘라낸 꽃 둘레에 남길 여백(꽃 긴 변 대비). 카드 안에서 꽃이 테두리에 붙지 않게.
PAD = 0.04


def square_icon(path: Path) -> Image.Image:
    image = Image.open(path).convert("RGBA")
    box = image.getchannel("A").getbbox()
    if box is None:
        raise SystemExit(f"{path.name}: 전부 투명하다")
    x0, y0, x1, y1 = box
    w, h = x1 - x0, y1 - y0
    side = round(max(w, h) * (1 + 2 * PAD))
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    canvas.alpha_composite(image.crop(box), ((side - w) // 2, (side - h) // 2))
    return canvas.resize((SIZE, SIZE), Image.Resampling.LANCZOS)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for name in ("icon_lotus", "icon_meditation"):
        save_layer(square_icon(SRC / f"{name}.png"), OUT, name)
        size = (OUT / f"{name}.webp").stat().st_size
        print(f"{name}.webp  {SIZE}×{SIZE}  {size / 1024:.1f}KB")


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    main()
