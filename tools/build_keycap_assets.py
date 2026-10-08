"""놀이 탭 키캡 그림을 앱 에셋으로 굽는다.

Imgs/keycap/icon_<id>.png (1024 캔버스) → assets/keycap/icon_<id>.webp (192×192)
Imgs/keycap/keyring.png   (가로로 긴 캔버스) → assets/keycap/keyring.webp (높이 320)

아이콘은 키캡 윗면에 약 34dp 로 찍힌다. 그림 영역만 정사각으로 잘라 줄인다.
쇠붙이는 오른쪽 끝 작은 고리가 판 왼쪽 가운데 구멍에 걸리도록, 그 고리의
세로 가운데가 그림 세로 가운데에 오게 자른다(앱은 그림을 세로 가운데 정렬,
오른쪽 끝 정렬로 놓는다). 발주서는 docs/키캡_리소스_발주서.md.

    python tools/build_keycap_assets.py
"""

import sys
from pathlib import Path

from PIL import Image

from build_avatar_assets import save_layer

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "Imgs" / "keycap"
OUT = ROOT / "assets" / "keycap"

# lib/features/play/keycap.dart 의 kKeycapRings 에서 그림을 쓰는 키.
ICONS = [
    "nirvana", "bulb",
    "clock", "tomorrow", "meeting", "battery",
    "campfire", "breeze", "lotus", "cloud",
    "rocket", "rebirth", "gassho", "wallet",
]

ICON_SIZE = 192
RING_HEIGHT = 320

# 아이콘 둘레 여백(긴 변 대비). 키캡 윗면 가장자리에 붙지 않게.
PAD = 0.03

# 오른쪽 끝에서 이만큼(그림 폭 대비) 안쪽까지를 「걸리는 고리」로 본다.
HOOK_SPAN = 0.06


def opaque_box(image: Image.Image, name: str) -> tuple[int, int, int, int]:
    box = image.getchannel("A").point(lambda a: 255 if a > 8 else 0).getbbox()
    if box is None:
        raise SystemExit(f"{name}: 전부 투명하다")
    return box


def square_icon(path: Path) -> Image.Image:
    image = Image.open(path).convert("RGBA")
    x0, y0, x1, y1 = box = opaque_box(image, path.name)
    w, h = x1 - x0, y1 - y0
    side = round(max(w, h) * (1 + 2 * PAD))
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    canvas.alpha_composite(image.crop(box), ((side - w) // 2, (side - h) // 2))
    return canvas.resize((ICON_SIZE, ICON_SIZE), Image.Resampling.LANCZOS)


def keyring(path: Path) -> Image.Image:
    image = Image.open(path).convert("RGBA")
    x0, y0, x1, y1 = opaque_box(image, path.name)
    # 오른쪽 끝 고리의 세로 가운데.
    hook_left = x1 - max(4, round((x1 - x0) * HOOK_SPAN))
    hook = image.crop((hook_left, 0, x1, image.height))
    _, hy0, _, hy1 = opaque_box(hook, f"{path.name} 오른쪽 고리")
    hook_y = (hy0 + hy1) / 2
    half = max(hook_y - y0, y1 - hook_y)
    top = round(hook_y - half)
    height = round(2 * half)
    canvas = Image.new("RGBA", (x1 - x0, height), (0, 0, 0, 0))
    canvas.alpha_composite(
        image.crop((x0, max(0, top), x1, min(image.height, top + height))),
        (0, max(0, -top)),
    )
    width = round(canvas.width * RING_HEIGHT / canvas.height)
    print(f"  고리 y {hook_y:.0f} (그림 {y0}–{y1}), 잘라 낸 {canvas.size}")
    return canvas.resize((width, RING_HEIGHT), Image.Resampling.LANCZOS)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    missing = []
    for name in ICONS:
        src = SRC / f"icon_{name}.png"
        if not src.exists():
            missing.append(src.name)
            continue
        save_layer(square_icon(src), OUT, f"icon_{name}")
        size = (OUT / f"icon_{name}.webp").stat().st_size
        print(f"icon_{name}.webp  {ICON_SIZE}×{ICON_SIZE}  {size / 1024:.1f}KB")

    src = SRC / "keyring.png"
    if src.exists():
        image = keyring(src)
        save_layer(image, OUT, "keyring")
        size = (OUT / "keyring.webp").stat().st_size
        print(f"keyring.webp  {image.width}×{image.height}  {size / 1024:.1f}KB")
    else:
        missing.append(src.name)

    if missing:
        print(f"아직 없는 그림 {len(missing)}개: {', '.join(missing)}")


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    main()
