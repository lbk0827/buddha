"""캐릭터 앵커 — 소품이 따라붙는 몸의 기준점.

메이플스토리가 몸 그림마다 「목은 여기, 눈썹은 여기」를 두고 아이템을
그 점에 붙이듯, 캐릭터마다 몇 개의 앵커를 둔다. 소품은 한 번만
그려 기준 캐릭터(동자 부처)에 맞춰 놓고, 다른 캐릭터에는 두 캐릭터의
앵커를 따라 옮기고 키워서 굽는다.

    기준 캐릭터에서의 자리 ── 앵커 차이만큼 ──▶ 새 캐릭터에서의 자리

앵커 하나는 점(x, y)과 단위 길이(unit)다. 새 캐릭터의 단위가 기준의 1.2배면
그 앵커에 붙는 소품도 1.2배가 되고, 앵커에서 떨어진 거리도 1.2배가 된다.

| 앵커 | 점 | 단위 | 붙는 것 |
|---|---|---|---|
| eyes  | 감은 두 눈의 가운데 | 두 눈 사이 거리 | 안경, 선글라스 |
| mouth | 입(검은 곡선)의 가운데 | 두 눈 사이 거리 | 풍선껌 |
| head  | 감은 두 눈의 가운데 | 귓불 높이의 귀 끝~귀 끝 폭 | 후광 |
| neck  | 목이 가장 좁은 줄, 얼굴 가운데 선 위 | 그 줄의 폭 | 단주, 헤드폰 |
| feet  | 두 발 가운데, 발바닥 | 두 발 중심 사이 거리 | 신발 |
| body  | 몸 가운데, 맨 아래 | 몸 전체 폭 | 대좌 |

앵커는 전부 몸 그림(base_*.png)에서 자동으로 잰다. 사람이 고칠 일은
측정이 틀렸을 때뿐이다. 값은 tools/characters/<id>.json 에 둔다.

    python tools/avatar_anchors.py              # 기준 캐릭터를 다시 재서 JSON 과 비교
    python tools/avatar_anchors.py adult        # 다른 캐릭터

모자와 가사는 앵커로 옮기지 않는다. 모자는 머리 모양을 감싸야 하고
가사는 몸 그림 자체라서, 캐릭터마다 새로 받는다.
"""

import json
import sys
from dataclasses import dataclass
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "Imgs"
CHARACTERS = Path(__file__).resolve().parent / "characters"

# 소품 자리를 정한 기준 캐릭터. 이 캐릭터에서는 옮기지 않는다.
REFERENCE_ID = "dongja"

ANCHOR_NAMES = ("eyes", "mouth", "head", "neck", "feet", "body")

# 재 본 값이 JSON 과 이만큼 넘게 다르면 알린다.
TOLERANCE_PX = 3
TOLERANCE_UNIT = 0.02


@dataclass(frozen=True)
class Anchor:
    x: float
    y: float
    unit: float


@dataclass(frozen=True)
class Character:
    id: str
    name: str
    # 앵커를 재는 몸 그림. Imgs/ 기준 경로, 확장자 없이.
    base: str
    # 머리 레이어를 자르는 높이. 목이 가장 좁은 곳 근처에서, 잘린 면이
    # 가장 작고 이음매가 안 보이는 줄을 사람이 골랐다.
    neck_cut_y: int
    # 합장한 두 손의 윤곽. 맨살인 가슴과 붙어 있어 살만으로는 못 가른다.
    # 소품을 손 뒤로 숨길 때 쓴다.
    hand_outline: tuple
    anchors: dict


def load_character(character_id: str) -> Character:
    path = CHARACTERS / f"{character_id}.json"
    if not path.exists():
        raise SystemExit(f"{path} 가 없다")
    data = json.loads(path.read_text(encoding="utf-8"))
    anchors = {name: Anchor(**data["anchors"][name]) for name in ANCHOR_NAMES}
    return Character(
        id=character_id,
        name=data["name"],
        base=data["base"],
        neck_cut_y=data["neck_cut_y"],
        hand_outline=tuple(tuple(p) for p in data["hand_outline"]),
        anchors=anchors,
    )


REFERENCE = load_character(REFERENCE_ID)


def map_placement(anchor: str, scale: float, point, target: Character):
    """기준 캐릭터에서 정한 (배율, 자리)를 target 캐릭터로 옮긴다.

    기준 캐릭터 자신이면 값을 그대로 돌려준다. 부동소수 계산을 거치지
    않아야 이미 구워 둔 결과가 한 픽셀도 바뀌지 않는다.
    """
    if target.id == REFERENCE.id:
        return scale, point
    a = REFERENCE.anchors[anchor]
    b = target.anchors[anchor]
    ratio = b.unit / a.unit
    x, y = point
    return scale * ratio, (b.x + (x - a.x) * ratio, b.y + (y - a.y) * ratio)


# ── 재기 ────────────────────────────────────────────────────────────

EDGE = 8

# 귀 폭을 재는 높이: 눈에서 눈 간격의 이만큼 아래.
EAR_BELOW_EYES = 0.3

# 입을 찾는 상자: 눈 가운데에서 눈 간격 기준으로.
MOUTH_HALF_WIDTH = 0.3
MOUTH_TOP = 0.1
MOUTH_BOTTOM = 0.45

# 목을 찾는 범위: 눈에서 눈 간격의 이만큼 아래 사이에서 가장 좁은 줄.
NECK_FROM = 0.6
NECK_TO = 1.0

# 두 발을 가르는 높이: 발바닥에서 이만큼 위.
FEET_ABOVE_SOLE = 12

OPAQUE = 128


def _is_dark(p) -> bool:
    return p[3] > 200 and max(p[:3]) < 45


def _is_skin(p) -> bool:
    r, g, b, a = p
    return a > 200 and r > 190 and g > 140 and r > b + 25


def _eye_marks(image: Image.Image):
    """감은 두 눈의 (왼쪽 가운데, 오른쪽 가운데)."""
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
    return mean(left), mean(right)


def _ear_span(image: Image.Image, eye_y: float, gap: float) -> int:
    """귀 끝에서 귀 끝까지의 폭.

    눈보다 조금 아래(귓불 쪽)에서 잰다. 눈 높이에서 재면 버킷햇처럼
    아래로 처진 챙이 같이 잡혀 폭이 부풀고 배율이 작게 나온다. 눈 간격에
    비례한 거리라 그림 크기와 상관없이 같은 자리다.
    """
    px = image.load()
    ear_y = round(eye_y + gap * EAR_BELOW_EYES)
    row = [x for x in range(image.width) if px[x, ear_y][3] > OPAQUE]
    return row[-1] - row[0]


def find_eyes(image: Image.Image):
    """감은 두 눈의 가운데 좌표와 귀 끝~귀 끝 폭. 머리 정합(--measure)이 쓴다."""
    (lx, ly), (rx, ry) = _eye_marks(image)
    eye_x, eye_y = (lx + rx) / 2, (ly + ry) / 2
    return (eye_x, eye_y), _ear_span(image, eye_y, rx - lx)


def _row_extent(px, width, y):
    xs = [x for x in range(width) if px[x, y][3] > OPAQUE]
    return (xs[0], xs[-1]) if xs else None


def _runs(px, width, y):
    runs, start = [], None
    for x in range(width):
        solid = px[x, y][3] > OPAQUE
        if solid and start is None:
            start = x
        elif not solid and start is not None:
            runs.append((start, x - 1))
            start = None
    if start is not None:
        runs.append((start, width - 1))
    return runs


def measure_anchors(image: Image.Image) -> dict:
    """몸 그림 한 장에서 앵커를 전부 잰다."""
    px = image.load()
    width, height = image.size

    (lx, ly), (rx, ry) = _eye_marks(image)
    eye_x, eye_y = (lx + rx) / 2, (ly + ry) / 2
    gap = rx - lx

    # 입 — 눈 아래 가운데의 검은 곡선. 볼 홍조는 검지 않아 안 걸린다.
    x0 = round(eye_x - gap * MOUTH_HALF_WIDTH)
    x1 = round(eye_x + gap * MOUTH_HALF_WIDTH)
    y0 = round(eye_y + gap * MOUTH_TOP)
    y1 = round(eye_y + gap * MOUTH_BOTTOM)
    mouth = [(x, y) for y in range(y0, y1) for x in range(x0, x1)
             if _is_dark(px[x, y])]
    if not mouth:
        raise SystemExit("입을 못 찾았다 — 눈 아래 가운데에 검은 선이 있는지 확인")
    mouth_x = sum(p[0] for p in mouth) / len(mouth)
    mouth_y = sum(p[1] for p in mouth) / len(mouth)

    # 목 — 귀가 끝나고 어깨가 시작하기 전, 가장 좁은 줄. 가로 자리는 얼굴
    # 가운데 선을 쓴다. 가사가 한쪽 어깨에만 걸쳐 있어 그 줄의 가운데는
    # 한쪽으로 치우친다.
    narrowest = None
    for y in range(round(eye_y + gap * NECK_FROM), round(eye_y + gap * NECK_TO)):
        extent = _row_extent(px, width, y)
        if extent is None:
            continue
        span = extent[1] - extent[0]
        if narrowest is None or span < narrowest[1]:
            narrowest = (y, span)
    if narrowest is None:
        raise SystemExit("목을 못 찾았다")
    neck_y, neck_width = narrowest

    # 몸 — 불투명한 부분 전체.
    solid = image.getchannel("A").point(lambda v: 255 if v > OPAQUE else 0)
    left, top, right, bottom = solid.getbbox()
    sole = bottom - 1

    # 발 — 발바닥 조금 위에서 두 덩어리로 갈라진다.
    feet = _runs(px, width, sole - FEET_ABOVE_SOLE)
    if len(feet) != 2:
        raise SystemExit(f"발이 두 덩어리로 안 갈라진다 ({len(feet)}개) — "
                         "FEET_ABOVE_SOLE 을 확인")
    centers = [(a + b) / 2 for a, b in feet]

    r = lambda v: round(v, 1)
    return {
        "eyes": {"x": r(eye_x), "y": r(eye_y), "unit": r(gap)},
        "mouth": {"x": r(mouth_x), "y": r(mouth_y), "unit": r(gap)},
        "head": {"x": r(eye_x), "y": r(eye_y),
                 "unit": _ear_span(image, eye_y, gap)},
        "neck": {"x": r(eye_x), "y": neck_y, "unit": neck_width},
        "feet": {"x": r(sum(centers) / 2), "y": sole,
                 "unit": r(centers[1] - centers[0])},
        "body": {"x": r((left + right - 1) / 2), "y": sole,
                 "unit": right - left},
    }


def check(character_id: str) -> bool:
    """몸 그림을 다시 재서 JSON 값과 비교한다. 다르면 False."""
    path = CHARACTERS / f"{character_id}.json"
    data = json.loads(path.read_text(encoding="utf-8")) if path.exists() else None
    base = data["base"] if data else "base_saffron"
    image = Image.open(SRC / f"{base}.png").convert("RGBA")
    measured = measure_anchors(image)

    print(f"{character_id} — {base}.png")
    ok = True
    for name in ANCHOR_NAMES:
        m = measured[name]
        line = f"  {name:6} ({m['x']:6.1f}, {m['y']:6.1f})  단위 {m['unit']:6.1f}"
        if data:
            s = data["anchors"][name]
            off = max(abs(m["x"] - s["x"]), abs(m["y"] - s["y"]))
            unit_off = abs(m["unit"] - s["unit"]) / s["unit"]
            if off > TOLERANCE_PX or unit_off > TOLERANCE_UNIT:
                ok = False
                line += (f"   ← JSON ({s['x']}, {s['y']}) 단위 {s['unit']} 와 "
                         f"{off:.1f}px · {unit_off:.1%} 차이")
        print(line)

    print()
    print('"anchors" 에 넣을 값:')
    print(json.dumps(measured, ensure_ascii=False, indent=2))
    return ok


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")
    target = sys.argv[1] if len(sys.argv) > 1 else REFERENCE_ID
    if not check(target):
        raise SystemExit("앵커가 JSON 과 다르다 — 그림이 바뀌었으면 JSON 을 고친다")
