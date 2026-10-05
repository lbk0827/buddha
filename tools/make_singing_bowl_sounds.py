"""싱잉볼 소리 두 개를 만든다.

원본은 Freesound 의 CC0 녹음이다. 미리듣기 MP3 를 받아 이 스크립트로 자른다.
원본은 저장소에 넣지 않는다(합쳐 4MB). 출처는 docs/사운드_출처.md.

    curl -sL -o strike.mp3 https://cdn.freesound.org/previews/449/449952_<id>-hq.mp3
    curl -sL -o rim.mp3    https://cdn.freesound.org/previews/573/573805_<id>-hq.mp3
    python tools/make_singing_bowl_sounds.py strike.mp3 rim.mp3

미리듣기 주소의 <id> 는 각 소리 페이지 HTML 에 있다.
디코딩에 miniaudio 가 필요하다 (pip install miniaudio).
"""

import array
import math
import sys
import wave
from pathlib import Path

import miniaudio

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "sounds"
OUT_SR = 22050

# 치기: 첫 타부터 이만큼, 끝은 서서히 줄인다.
STRIKE_SECONDS = 9.0
STRIKE_FADE = 3.0

# 문지르기: 기본음 547Hz 를 치는 소리의 기본음 582.5Hz 에 맞춘다.
RUB_RATIO = 582.5 / 547.0
RUB_LOOP = 6.0
RUB_CROSSFADE = 0.5
# 음량이 가장 고른 구간을 이 시점 뒤에서 찾는다. 처음엔 손이 자리를 잡는다.
RUB_SEARCH_FROM = 10.0


def load(path, sr=44100):
    d = miniaudio.decode_file(str(path), output_format=miniaudio.SampleFormat.SIGNED16,
                              nchannels=1, sample_rate=sr)
    return [v / 32768 for v in d.samples]


def save(path, x, peak_db=-1.0):
    pk = max(abs(v) for v in x)
    g = 10 ** (peak_db / 20) / pk
    data = array.array("h", (max(-32767, min(32767, round(v * g * 32767))) for v in x))
    with wave.open(str(path), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(OUT_SR)
        w.writeframes(data.tobytes())
    print(f"{path.name}: {len(x) / OUT_SR:.2f}초, {len(data) * 2 // 1024}KB")


def resample(src, src_sr, start_s, out_len_s, ratio):
    """src 의 start_s 부터 ratio 배 빠르게(=ratio 배 높게) 읽어 OUT_SR 로."""
    out = []
    for j in range(int(out_len_s * OUT_SR)):
        p = (start_s + j / OUT_SR * ratio) * src_sr
        i = int(p)
        f = p - i
        out.append(src[i] * (1 - f) + src[i + 1] * f)
    return out


def make_strike(path):
    strike = resample(load(path), 44100, 0.0, STRIKE_SECONDS, 1.0)
    fade = int(STRIKE_FADE * OUT_SR)
    for k in range(fade):
        strike[len(strike) - fade + k] *= math.cos(math.pi / 2 * k / fade) ** 2
    save(OUT / "singing_bowl_strike.wav", strike)


def make_rub(path):
    rim = load(path)
    win = int(0.1 * 44100)
    env = [math.sqrt(sum(v * v for v in rim[i:i + win]) / win)
           for i in range(0, len(rim) - win, win)]
    need = int((RUB_LOOP + RUB_CROSSFADE) * RUB_RATIO / 0.1) + 1
    best = None
    for s in range(int(RUB_SEARCH_FROM / 0.1), len(env) - need):
        seg = env[s:s + need]
        m = sum(seg) / len(seg)
        cv = math.sqrt(sum((v - m) ** 2 for v in seg) / len(seg)) / m
        if best is None or cv < best[0]:
            best = (cv, s * 0.1)
    cv, start = best
    print(f"문지르기 구간 {start:.1f}초부터, 음량 변동 {cv * 100:.1f}%")

    seg = resample(rim, 44100, start, RUB_LOOP + RUB_CROSSFADE, RUB_RATIO)
    n, x = int(RUB_LOOP * OUT_SR), int(RUB_CROSSFADE * OUT_SR)
    loop = seg[:n]
    # 끝 다음에 올 소리(seg[n:])를 처음에 겹쳐, 끝 → 처음이 이어지게 한다.
    for i in range(x):
        th = math.pi / 2 * i / x
        loop[i] = seg[i] * math.sin(th) + seg[n + i] * math.cos(th)
    step = sum(abs(loop[i + 1] - loop[i]) for i in range(n - 1)) / (n - 1)
    print(f"이음매 차이 {abs(loop[-1] - loop[0]):.4f} (이웃 샘플 평균 {step:.4f})")
    save(OUT / "singing_bowl_rub.wav", loop)


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    make_strike(sys.argv[1])
    make_rub(sys.argv[2])
