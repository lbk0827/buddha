"""납품받은 스프라이트를 앱 에셋으로 굽는다.

Imgs/*.png (납품 원본) → assets/avatar/*.webp (앱에 나가는 것)

원본은 무손실 PNG 로 두고, 앱에는 WebP(품질 90)로 굽는다. 1024 캔버스
레이어 한 장이 PNG 로 300~400KB, WebP 로 50KB 안팎이다.

머리 아이템은 「모자 쓴 얼굴」을 통째로 받는다. 받는 형태는 두 가지다.

- head_*_face.png — 얼굴만 그린 그림. 캔버스도 배율도 베이스와 다르므로
  베이스 얼굴에 포개지게 옮겨 놓는다 (FACE_FIT). 모자만 따로 그려 얹으면
  모자가 머리를 덮지 못하고 뚜껑처럼 올라앉는다. 그래서 얼굴째 받는다.
- head_*_full.png — 베이스를 편집한 전신. 좌표가 같으니 목 위만 자른다.

얼굴·목·발 소품은 「물건만」 크게 그려 받는다. 베이스에 대 보며 정한
크기·자리(PLACED)로 1024 캔버스에 옮겨 놓고, 몸 뒤로 가야 하는 부분
(합장한 손 뒤, 목 뒤, 가사 밑단 안)은 지운다.

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
# --measure 로 잰다. 두 눈의 가운데를 베이스 눈 가운데에 맞추고, 배율은
# 귀 끝에서 귀 끝까지의 폭에서 출발해 베이스 머리가 가장 덜 비치는 값을
# 고른다. 눈 사이로 재면 GPT 얼굴의 귀가 상대적으로 작아져서 뒤의 베이스
# 귀·민머리가 비친다.
FACE_FIT = {
    "head_bamboo": (0.614, 126, -90),
    "head_straw": (0.626, 119, -76),
    "head_nabal": (0.625, 121, -116),
}

# 앱에 굽는 WebP 품질. 알파는 무손실로 남는다.
WEBP_QUALITY = 90

# 옮긴 얼굴 뒤로 베이스 민머리가 이만큼 넘게 비치면 정합이 틀린 것이다.
MAX_PEEK = 400

BASES = ["base_saffron", "base_temple", "base_ash", "base_crimson",
         "base_lavender"]
HEADS = ["head_nabal", "head_bamboo", "head_straw"]
OVERLAYS = ["acc_beads", "acc_glasses", "seat_lotus", "halo_ring"]

# 물건만 그려 받은 소품을 베이스에 놓는 값.
#   (배율, 원본 기준점, 베이스 기준점, 몸 뒤로 숨길 곳)
# 원본 기준점이 베이스 기준점에 오도록 배율대로 줄여 놓는다. 베이스 기준점은
# 베이스를 재서 얻었다 — 감은 두 눈 가운데 (510, 356), 목 y 478,
# 합장한 손끝 y 520, 두 발 중심 x 457·565 · 발바닥 y 918.
#   선글라스  두 렌즈 중심 간격을 두 눈 간격(156)에 맞춘다. 동그란 것은 아래
#             테가 입꼬리에 닿아 6% 줄였다
#   헤드폰    두 컵이 쇄골 앞 양옆, 밴드는 목 뒤(BAND 를 지운다), 컵은 손 뒤
#   금빛 단주 손끝이 목 바로 아래라 U 를 손 위에 둘 자리가 없다. 손 뒤로
#             지나 손 아래에서 U 가 보이게 한다
#   운동화    두 짝 간격을 두 발 간격보다 조금 넓게(128) 잡아 발가락까지
#             덮고, 가사 밑단 안쪽은 지운다
PLACED = {
    "acc_sunglasses": (156 / 452 * 0.94, (512, 515), (510, 356), ()),
    "acc_pinkshades": (156 / 462, (512, 512), (510, 356), ()),
    "acc_neckphones": (0.34, (512, 477), (512, 470), ("band", "hands")),
    "acc_goldbeads": (170 / 685, (512, 99), (512, 466), ("hands",)),
    "feet_sneakers": (128 / 336, (511, 776), (511, 936), ("robe",)),
}

# 헤드폰 원본에서 목 뒤로 넘어가는 밴드. 양쪽 경첩 사이, 쿠션 위쪽의 띠다.
BAND = [(325, 500), (420, 512), (512, 520), (604, 512), (700, 500),
        (692, 546), (632, 562), (606, 586), (512, 600), (418, 586),
        (392, 562), (332, 546)]

# 베이스에서 합장한 두 손의 윤곽. 맨살인 왼쪽 가슴과 붙어 있어서 살만으로는
# 가를 수 없다.
HAND_OUTLINE = [(503, 514), (522, 514), (542, 530), (558, 578), (568, 646),
                (456, 646), (462, 588), (482, 530)]

# 원본 둘레에 투명도 1~15 짜리 흐린 점이 수천 개 흩어져 있다. 지운다.
ALPHA_FLOOR = 16

# 운동화 두 짝 사이 위쪽은 발목이 가늘어져 발이 비친다. 가사 밑단 아래
# 그림자처럼 어두운 중간색으로 메운다. 가사 색을 따면 다른 가사에서 어긋난다.
SHOE_GAP_SHADOW = (72, 62, 56)


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


EDGE = 8


def _is_dark(p) -> bool:
    return p[3] > 200 and max(p[:3]) < 45


def _is_skin(p) -> bool:
    r, g, b, a = p
    return a > 200 and r > 190 and g > 140 and r > b + 25


def find_eyes(image: Image.Image):
    """감은 두 눈의 가운데 좌표와 그 높이의 귀 끝~귀 끝 폭을 잰다.

    눈은 위아래가 살색인 새까만 가로선이다. 나발처럼 어두운 머리칼은
    위아래가 살색이 아니라서 빠진다. 입도 같은 조건에 걸리므로 가운데
    3분의 1은 버리고 양쪽만 쓴다.
    """
    px = image.load()
    width, height = image.size
    marks = []
    for y in range(1, height - 1):
        for x in range(width):
            if not _is_dark(px[x, y]):
                continue
            up = y
            while up > 0 and _is_dark(px[x, up]):
                up -= 1
            down = y
            while down < height - 1 and _is_dark(px[x, down]):
                down += 1
            # 선 가장자리는 흐려서 중간색이다. 몇 픽셀 건너서 살색을 본다.
            above, below = max(0, up - EDGE), min(height - 1, down + EDGE)
            if down - up < 60 and _is_skin(px[x, above]) and _is_skin(px[x, below]):
                marks.append((x, y))
    if not marks:
        raise SystemExit("눈을 못 찾았다 — 감은 눈이 새까만 선인지 확인")

    xs = [x for x, _ in marks]
    left_edge, right_edge = min(xs), max(xs)
    third = (right_edge - left_edge) / 3
    left = [(x, y) for x, y in marks if x < left_edge + third]
    right = [(x, y) for x, y in marks if x > right_edge - third]
    if not left or not right:
        raise SystemExit("두 눈이 갈라지지 않는다")

    mean = lambda pts: (sum(p[0] for p in pts) / len(pts),
                        sum(p[1] for p in pts) / len(pts))
    (lx, ly), (rx, ry) = mean(left), mean(right)
    eye_x, eye_y = (lx + rx) / 2, (ly + ry) / 2

    row = [x for x in range(width) if px[x, round(eye_y)][3] > 128]
    return (eye_x, eye_y), row[-1] - row[0]


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
    face = Image.open(SRC / f"{name}_face.png").convert("RGBA")
    base = load("base_saffron")

    (bx, by), base_span = find_eyes(base)
    (fx, fy), face_span = find_eyes(face)
    start = base_span / face_span
    print(f"베이스 눈 ({bx:.0f}, {by:.0f}) 귀폭 {base_span}")
    print(f"{name} 눈 ({fx:.0f}, {fy:.0f}) 귀폭 {face_span} → 배율 {start:.3f}")

    under = base.getchannel("A").point(lambda v: 255 if v > 128 else 0)
    under.paste(0, (0, NECK_Y - 8, CANVAS, CANVAS))

    tried = []
    for step in range(-4, 5):
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


def body_masks():
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
    ImageDraw.Draw(outline).polygon(HAND_OUTLINE, fill=255)
    hands = ImageChops.multiply(skin.filter(ImageFilter.MaxFilter(3)), outline)
    hands = hands.filter(ImageFilter.GaussianBlur(0.8))
    return {"robe": robe, "hands": hands, "skin": skin}


def hide(layer: Image.Image, mask: Image.Image) -> Image.Image:
    out = layer.copy()
    out.putalpha(ImageChops.multiply(layer.getchannel("A"), ImageChops.invert(mask)))
    return out


def place_item(name: str, masks) -> Image.Image:
    """물건 원본을 PLACED 값대로 베이스 캔버스에 옮기고, 몸 뒤를 지운다."""
    scale, (sx, sy), (dx, dy), behind = PLACED[name]
    item = load(name)
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
        feet = masks["skin"].copy()
        feet.paste(0, (0, 0, CANVAS, 840))
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

    for name in BASES + OVERLAYS:
        save_layer(load(name), OUT, name)
        print(name)

    masks = body_masks()
    for name in PLACED:
        save_layer(place_item(name, masks), OUT, name)
        print(f"{name}  (물건 원본을 베이스에 놓음)")

    base = load("base_saffron")

    for name in HEADS:
        face = SRC / f"{name}_face.png"
        full = SRC / f"{name}_full.png"
        if face.exists():
            image = Image.open(face).convert("RGBA")
            head, peek = fit_face(image, FACE_FIT[name], base)
            save_layer(head, OUT, name)
            print(f"{name}  (모자 쓴 얼굴을 베이스에 포갬, 비침 {peek}px)")
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
