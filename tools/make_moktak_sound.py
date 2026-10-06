"""목탁 소리를 만든다.

원본은 공유마당의 CC BY 녹음 김용배 「목탁소리(이미지)」다. 원본 WAV 를 받아
이 스크립트로 두 번째 타 하나만 자른다. 원본은 저장소에 넣지 않는다.
출처는 docs/사운드_출처.md.

    원본: https://gongu.copyright.or.kr/gongu/wrt/wrt/view.do?wrtSn=13253418&menuNo=200020
    python tools/make_moktak_sound.py "목탁소리(이미지).wav"

원본에는 소리가 둘 있다. 0.12초의 첫 소리는 여러 번 이어 친 것이라 쓰지 않고,
1.248초에 시작하는 두 번째 타를 쓴다.
"""

import array
import math
import sys
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "sounds" / "moktak.wav"

# 두 번째 타가 1.248초에 시작한다. 2ms 앞에서 잘라 짧게 키워 딸깍 소리를 막는다.
START = 1.246
FADE_IN = 0.002
# 2.6초쯤이면 거의 안 들린다. 끝 0.4초를 서서히 줄인다.
END = 2.7
FADE_OUT = 0.4


def main(src: str) -> None:
    with wave.open(src) as w:
        assert w.getsampwidth() == 2, "16bit WAV 만 받는다"
        channels = w.getnchannels()
        sr = w.getframerate()
        w.setpos(round(START * sr))
        frames = round((END - START) * sr)
        samples = array.array("h", w.readframes(frames))

    fade_in = round(FADE_IN * sr)
    fade_out = round(FADE_OUT * sr)
    for i in range(frames):
        if i < fade_in:
            gain = i / fade_in
        elif i >= frames - fade_out:
            gain = 0.5 * (1 + math.cos(math.pi * (i - (frames - fade_out)) / fade_out))
        else:
            continue
        for c in range(channels):
            k = i * channels + c
            samples[k] = round(samples[k] * gain)

    with wave.open(str(OUT), "wb") as w:
        w.setnchannels(channels)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes(samples.tobytes())
    print(f"{OUT.name}: {frames / sr:.3f}s, {sr}Hz, {channels}ch, {OUT.stat().st_size} bytes")


if __name__ == "__main__":
    main(sys.argv[1])
