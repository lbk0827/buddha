"""google_fonts 가 쓰는 폰트를 앱에 넣을 크기로 줄인다.

fonts.gstatic.com 원본 → assets/google_fonts/*.ttf (앱에 나가는 것)

google_fonts 는 실행 중에 폰트를 내려받는데, 한글 폰트는 굵기마다 6MB 라
첫 실행이 느리고 오프라인이면 못 받는다. 그래서 앱에 넣고 내려받기를 끈다
(lib/main.dart). 원본 그대로면 여섯 개 31MB 라, 한글 완성형 11,172자 전부와
자모·라틴·문장부호, 그리고 lib/·assets/content/ 에 실제로 나오는 글자(한자
등)만 남긴다. 사용자가 치는 한글은 빠짐없이 나온다.

lib/ 나 assets/content/ 에 새 한자·기호를 넣었으면 다시 돌린다.
쓰는 굵기를 바꿨으면 FONTS 를 고친다 — 없는 굵기는 글꼴 없이 그려진다.

    python tools/subset_fonts.py

fontTools 가 필요하다 (pip install fonttools).
"""

import hashlib
import tempfile
import urllib.request
from pathlib import Path

from fontTools import subset

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "google_fonts"

# 파일 이름은 google_fonts 가 찾는 이름 그대로. 해시는 google_fonts 패키지의
# part_n.dart / part_g.dart 에 적힌 값이다.
FONTS = {
    "NotoSansKR-Regular": "65f278fc677a3a0128c733af662c3eb31b910c9bce81e046ccc3c6d3ede879e2",
    "NotoSansKR-Medium": "edcac553518d3030cbdc6ad00261bef84f988cf099dce567523c719c2082c743",
    "NotoSansKR-SemiBold": "21ec9ca6ade00303740d965d4953af2af81a7ae1316d61de16ceded863394d7c",
    "NotoSansKR-Bold": "45f69f3abd7e355bcd9f754261c5090ab3b7e1b526c6af60a71fe7d999b35073",
    "NotoSansKR-Black": "d02b6beb93927ff6501698fa8c24a5f03ddf5f2fd796a0bfaa2426001acdbc2f",
    "GowunBatang-Bold": "acca988be385cf6546f0e7f7da97925e99fa47e7862819a2a724aa1c2a660ee5",
}

UNICODES = (
    "U+0000-024F,U+02B0-02FF,U+0370-03FF,U+1100-11FF,U+2000-206F,"
    "U+20A0-20CF,U+2100-22FF,U+2460-27BF,U+3000-303F,U+3130-318F,"
    "U+3200-32FF,U+A960-A97F,U+AC00-D7A3,U+D7B0-D7FF,U+FF00-FFEF"
)


def used_text() -> str:
    files = list((ROOT / "lib").rglob("*.dart"))
    files += [p for p in (ROOT / "assets" / "content").rglob("*") if p.is_file()]
    chars = set()
    for p in files:
        chars |= set(p.read_text(encoding="utf-8"))
    return "".join(sorted(chars))


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        text = Path(tmp) / "used.txt"
        text.write_text(used_text(), encoding="utf-8")
        for name, sha in FONTS.items():
            src = Path(tmp) / f"{name}.ttf"
            url = f"https://fonts.gstatic.com/s/a/{sha}.ttf"
            data = urllib.request.urlopen(url).read()
            if hashlib.sha256(data).hexdigest() != sha:
                raise SystemExit(f"{name}: 해시가 맞지 않는다")
            src.write_bytes(data)
            dst = OUT / f"{name}.ttf"
            subset.main([
                str(src),
                f"--unicodes={UNICODES}",
                f"--text-file={text}",
                "--layout-features=*",
                "--no-hinting",
                "--desubroutinize",
                f"--output-file={dst}",
            ])
            print(f"{name}: {len(data) // 1024}KB → {dst.stat().st_size // 1024}KB")


if __name__ == "__main__":
    main()
