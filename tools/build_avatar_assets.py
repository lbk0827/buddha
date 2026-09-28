"""납품받은 스프라이트를 앱 에셋으로 굽는다.

Imgs/ (납품 원본) → assets/avatar/ (앱에 나가는 것)

머리 아이템은 「모자 쓴 얼굴」을 통째로 받는다. 받는 형태는 두 가지다.

- head_*_face.png — 얼굴만 그린 그림. 캔버스도 배율도 베이스와 다르므로
  베이스 얼굴에 포개지게 옮겨 놓는다 (FACE_FIT). 모자만 따로 그려 얹으면
  모자가 머리를 덮지 못하고 뚜껑처럼 올라앉는다. 그래서 얼굴째 받는다.
- head_*_full.png — 베이스를 편집한 전신. 좌표가 같으니 목 위만 자른다.

**아이템을 보기 좋게 옮기는 보정은 하지 않는다.** FACE_FIT 은 「얼굴을
베이스 얼굴에 겹치는」 정합일 뿐이고, 그 결과가 베이스 머리를 다 덮는지
여기서 검사한다. 모자가 크거나 낮아 보이면 그건 생성 단계에서 잡는다.

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

# head_*_face.png 를 베이스 좌표로 옮기는 값: (배율, 왼쪽, 위).
# 두 눈의 가운데를 베이스 눈 가운데(510, 356)에 맞추고, 배율은 귀 끝에서
# 귀 끝까지의 폭으로 정했다. 눈 사이로 재면 GPT 얼굴의 귀가 상대적으로
# 작아져서 뒤의 베이스 귀·민머리가 비친다. 세로는 베이스 머리가 가장 덜
# 비치는 자리로 몇 픽셀 올렸다.
FACE_FIT = {
    "head_bamboo": (0.62, 123, -96),
    "head_straw": (0.63, 116, -78),
    "head_nabal": (0.62, 123, -112),
}

# 옮긴 얼굴 뒤로 베이스 민머리가 이만큼 넘게 비치면 정합이 틀린 것이다.
MAX_PEEK = 400

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


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    for name in BASES + OVERLAYS:
        load(name).save(OUT / f"{name}.png", optimize=True)
        print(name)

    base = load("base_saffron")

    for name in HEADS:
        face = SRC / f"{name}_face.png"
        full = SRC / f"{name}_full.png"
        if face.exists():
            image = Image.open(face).convert("RGBA")
            head, peek = fit_face(image, FACE_FIT[name], base)
            head.save(OUT / f"{name}.png", optimize=True)
            print(f"{name}  (모자 쓴 얼굴을 베이스에 포갬, 비침 {peek}px)")
        elif full.exists():
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
