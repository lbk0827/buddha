"""납품받은 스프라이트를 앱 에셋으로 굽는다.

Imgs/ (납품 원본) → assets/avatar/ (앱에 나가는 것)

머리 아이템은 「전신 + 모자」로 받아서 여기서 목 위만 잘라낸다.
GPT에게 목 아래를 지우라고 시키면 잘 못하는데, 베이스와 같은 좌표계라
우리가 자르는 건 정확하다. 자세한 건 docs/부처님_머리_재작업요청서.md.

**위치나 크기를 여기서 보정하지 않는다.** 아이템이 어긋나 보이면 그건
생성 단계에서 잡아야 한다. 여기서 손으로 맞추기 시작하면 아이템마다
숫자를 붙들고 있어야 한다.

    python tools/build_avatar_assets.py
    python tools/make_avatar_thumbs.py    # 썸네일은 이 결과에서 다시 뽑는다
"""

from pathlib import Path

from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "Imgs"
OUT = ROOT / "assets" / "avatar"

CANVAS = 1024

# 베이스 실루엣을 재보면 귀가 세로 320~470 까지 내려오고, 목은 478 에서
# 가장 좁아진다(폭 142). 여기서 자르면 잘린 면이 제일 작고, 그 아래는
# 베이스와 같은 픽셀이라 이음매가 보이지 않는다.
NECK_Y = 478

# 잘린 끝을 몇 픽셀 흐리게 해서 경계선이 서지 않게 한다.
NECK_FEATHER = 6

BASES = ["base_saffron", "base_temple", "base_ash", "base_crimson"]
HEADS = ["head_nabal", "head_bamboo", "head_straw"]
OVERLAYS = ["acc_beads", "acc_glasses", "seat_lotus", "halo_ring"]


def load(name: str) -> Image.Image:
    path = SRC / f"{name}.png"
    if not path.exists():
        raise SystemExit(f"{path} 가 없다")
    image = Image.open(path)
    if image.size != (CANVAS, CANVAS):
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


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    for name in BASES + OVERLAYS:
        load(name).save(OUT / f"{name}.png", optimize=True)
        print(name)

    for name in HEADS:
        full = SRC / f"{name}_full.png"
        if full.exists():
            # 새 방식: 전신을 받아 목 위만 잘라낸다.
            cut_head(load(f"{name}_full")).save(
                OUT / f"{name}.png", optimize=True)
            print(f"{name}  (전신에서 목 위만)")
        else:
            # 아직 재작업 전. 예전 「모자만」 그림을 그대로 쓴다.
            load(name).save(OUT / f"{name}.png", optimize=True)
            print(f"{name}  (구버전 — {name}_full.png 를 기다리는 중)")


if __name__ == "__main__":
    main()
