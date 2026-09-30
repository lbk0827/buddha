"""옷장 칸에 쓸 썸네일을 만든다.

assets/avatar/*.webp (1024×1024 레이어)에서 아이템 영역만 잘라
assets/avatar/thumbs/*.webp (192×192)로 저장한다.

원본은 읽기만 한다. 아이템이 바뀌면 이 스크립트를 다시 돌리면 된다.

    python tools/make_avatar_thumbs.py
"""

import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter

from build_avatar_assets import save_layer

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets" / "avatar"
OUT = SRC / "thumbs"

# 납품 원본. 옷장용 「물건만」 그림은 앱에 나가지 않고 여기서만 쓴다.
RAW = ROOT / "Imgs"

THUMB = 192
PAD = 0.06  # 잘라낸 영역 둘레 여백 비율

# 베이스 실루엣을 재보면 귀가 y 320~470 까지 내려오고 목은 y 480 에서 좁아진다.
# 이 두 숫자가 아래 두 창을 가른다.
NECK_Y = 478

# 머리 아이템은 「머리에 씌운 모습」으로 보여준다.
# 모자만 따로 띄우면 민머리와 종류가 달라 보이고, 어느 쪽이 위인지도 안 읽힌다.
# 네 개를 같은 창으로 잘라야 크기·위치가 서로 맞는다.
# 가로는 삿갓 챙(x 212~812)까지, 세로는 모자 꼭대기부터 턱 아래까지 담는다.
HEAD_WINDOW = (195, 0, 830, 515)

# 가사는 목 아래만 보여준다. 얼굴이 같이 나오면 옷이 아니라 캐릭터로 읽힌다.
# 목(478)에서 바로 자르면 살색 목 밑동이 한 줄 남아 어두운 가사에서 선처럼
# 도드라진다. 어깨가 천에 덮이는 500 부터 자른다.
ROBE_CROP = (270, 500, 755, 940)

# 민머리는 머리까지만. 어깨가 들어가면 혼자 작은 캐릭터처럼 보인다.
SHAVED_WINDOW = (255, 85, 770, 495)

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


def fill_holes(mask: Image.Image) -> Image.Image:
    """마스크 안쪽에 뚫린 구멍만 메운다.

    모자 색이 피부색과 비슷한 지점에서는 차이가 임계값에 못 미쳐 구멍이
    난다. 팽창·수축으로 메우면 윤곽이 뭉개지므로, 테두리에서 닿지 않는
    배경만 골라 채운다.
    """
    background = mask.point(lambda v: 0 if v else 255)
    ImageDraw.floodfill(background, (0, 0), 0)
    return ImageChops.lighter(mask, background)


def keep_top_blob(mask: Image.Image) -> Image.Image:
    """맨 위 픽셀과 이어진 덩어리만 남긴다.

    머리 레이어는 「모자 쓴 얼굴」을 따로 그려 받은 것이라 눈·백호·귀
    윤곽이 베이스와 몇 픽셀씩 어긋난다. 그 차이도 조각으로 남는데, 모자는
    늘 맨 위에서 시작하는 한 덩어리이니 거기 붙은 것만 고른다.
    """
    box = mask.getbbox()
    if box is None:
        return mask
    top = box[1]
    seed = next(x for x in range(mask.width) if mask.getpixel((x, top)))
    marked = mask.copy()
    ImageDraw.floodfill(marked, (seed, top), 128)
    return marked.point(lambda v: 255 if v == 128 else 0)


def extract_item(layer: Image.Image, bare_head: Image.Image,
                 threshold: int = 45) -> Image.Image:
    """머리 레이어에서 「베이스 얼굴과 달라진 부분」만 떼어낸다.

    머리 아이템은 「모자 쓴 얼굴」이라 맨머리와 비교하면 남는 게 곧
    물건이다. 얼굴도 따로 그린 것이라 살색이 조금씩 다르다. 기준을 낮추면
    챙 아래 이마가 띠처럼 딸려 나온다. 옷장 목록에 얼굴이 줄줄이 나오면
    답답해서 물건만 보여준다.
    """
    rgb = ImageChops.difference(layer.convert("RGB"), bare_head.convert("RGB"))
    r, g, b = rgb.split()
    diff = ImageChops.lighter(ImageChops.lighter(r, g), b)

    # 물건이 머리 밖으로 튀어나온 부분은 색이 아니라 알파가 달라진다.
    alpha_diff = ImageChops.difference(
        layer.getchannel("A"), bare_head.getchannel("A"))

    mask = ImageChops.lighter(diff, alpha_diff)
    mask = mask.point(lambda v: 255 if v >= threshold else 0)

    # 머리 레이어와 비교용 맨머리는 잘린 높이가 몇 줄 다를 수 있다. 그 차이가
    # 가로줄로 남으므로 목 근처는 아예 뺀다. 모자가 거기까지 올 일은 없다.
    mask.paste(0, (0, NECK_Y - 30, mask.width, mask.height))

    # 어긋난 얼굴 윤곽은 가는 선으로 남는다. 먼저 깎아 모자와 떼어 놓는다.
    mask = mask.filter(ImageFilter.MinFilter(7)).filter(ImageFilter.MaxFilter(7))
    mask = mask.filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.MinFilter(5))
    mask = keep_top_blob(mask)
    mask = fill_holes(mask)

    out = layer.copy()
    out.putalpha(ImageChops.multiply(layer.getchannel("A"), mask))
    return out


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

    saffron = Image.open(SRC / "base_saffron.webp").convert("RGBA")

    for name in ROBES:
        image = Image.open(SRC / f"{name}.webp").convert("RGBA")
        save_layer(square_fit(image.crop(ROBE_CROP)), OUT, name)
        print(f"{name} (목 아래)")

    # 머리 레이어에서 물건만 떼어낼 때 비교 대상이 되는 맨머리.
    bare_head = saffron.copy()
    bare_alpha = saffron.getchannel("A").copy()
    bare_alpha.paste(0, (0, NECK_Y, 1024, 1024))
    bare_head.putalpha(bare_alpha)

    for name in HEADS:
        # 민머리는 씌울 게 없다. 머리 자체가 아이템이라 머리를 보여준다.
        if name == "head_shaved":
            save_layer(square_fit(saffron.crop(SHAVED_WINDOW)), OUT, name)
            print(f"{name} (맨머리)")
            continue

        # 물건만 따로 받은 게 있으면 그걸 우선한다.
        standalone = RAW / f"{name}_item.png"
        if standalone.exists():
            image = Image.open(standalone).convert("RGBA")
            source = "따로 받은 그림"
        else:
            image = extract_item(
                Image.open(SRC / f"{name}.webp").convert("RGBA"), bare_head)
            source = "머리에서 떼어냄"

        box = alpha_bbox(image)
        if box is None:
            raise SystemExit(f"{name}: 남은 게 없다")
        save_layer(square_fit(image.crop(pad_box(box, *image.size))), OUT, name)
        print(f"{name} ({source})")

    for name in ITEMS:
        image = Image.open(SRC / f"{name}.webp").convert("RGBA")
        box = alpha_bbox(image)
        if box is None:
            raise SystemExit(f"{name}: 불투명 영역이 없다")
        box = pad_box(box, *image.size)
        save_layer(square_fit(image.crop(box)), OUT, name)
        print(f"{name} {box}")


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    main()
