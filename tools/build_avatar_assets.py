"""납품받은 스프라이트를 앱 에셋으로 굽는다.

Imgs/ (납품 원본) → assets/avatar/ (앱에 나가는 것)

하는 일은 검증과 복사뿐이다. 캔버스 크기와 알파 채널만 확인한다.
**위치나 크기를 여기서 보정하지 않는다.** 아이템이 어긋나 보이면 그건
생성 단계에서 잡아야 한다 (docs/부처님_머리_재작업요청서.md 참고).
여기서 손으로 맞추기 시작하면 아이템마다 숫자를 붙들고 있어야 한다.

    python tools/build_avatar_assets.py
    python tools/make_avatar_thumbs.py    # 썸네일은 이 결과에서 다시 뽑는다
"""

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "Imgs"
OUT = ROOT / "assets" / "avatar"

CANVAS = 1024

NAMES = [
    "base_saffron",
    "base_temple",
    "base_ash",
    "base_crimson",
    "head_nabal",
    "head_bamboo",
    "head_straw",
    "acc_beads",
    "acc_glasses",
    "seat_lotus",
    "halo_ring",
]


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)

    for name in NAMES:
        source = SRC / f"{name}.png"
        if not source.exists():
            raise SystemExit(f"{source} 가 없다")

        image = Image.open(source)
        if image.size != (CANVAS, CANVAS):
            raise SystemExit(f"{name}: {image.size} — {CANVAS} 정사각이어야 한다")
        if image.mode != "RGBA":
            raise SystemExit(f"{name}: {image.mode} — 알파 채널이 있어야 한다")
        if image.getchannel("A").getbbox() is None:
            raise SystemExit(f"{name}: 전부 투명하다")

        image.save(OUT / f"{name}.png", optimize=True)
        print(name)


if __name__ == "__main__":
    main()
