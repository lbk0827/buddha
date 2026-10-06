"""Prepare the CC0 dersinnsspace recordings selected for the app.

Requires miniaudio. Usage:
  python tools/prepare_dersinnsspace_bowl.py strike.mp3 rub.mp3
Public HQ previews (original WAV downloads require a Freesound login):
  https://cdn.freesound.org/previews/421/421829_8224400-hq.mp3
  https://cdn.freesound.org/previews/417/417115_8224400-hq.mp3
Source pages and processing notes: docs/사운드_출처.md.
"""

import array
import math
from pathlib import Path
import sys
import wave

import miniaudio

SR = 22050
OUT = Path(__file__).resolve().parent.parent / 'assets' / 'sounds'


def load(path):
    return list(miniaudio.decode_file(
        path, output_format=miniaudio.SampleFormat.FLOAT32,
        nchannels=1, sample_rate=SR,
    ).samples)


def save(name, samples):
    # Three simultaneous strikes plus the rim stay below full scale (4 * .22).
    gain = 0.22 / max(abs(v) for v in samples)
    samples = [v * gain for v in samples]
    pcm = array.array('h', (round(v * 32767) for v in samples))
    if sys.byteorder != 'little':
        pcm.byteswap()
    with wave.open(str(OUT / name), 'wb') as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(SR)
        out.writeframes(pcm.tobytes())
    print(f'{name}: {len(samples)/SR:.3f}s, {len(pcm)*2+44} bytes, peak .22')
    return samples


def prepare(strike_path, rub_path):
    strike = load(strike_path)
    threshold = max(abs(v) for v in strike) * 0.05
    onset = next(i for i, v in enumerate(strike) if abs(v) >= threshold)
    start = max(0, onset - int(.005 * SR))
    strike = strike[start:]
    # Keep the natural decay; only soften the final half-second and first 2ms.
    for i in range(int(.002 * SR)):
        strike[i] *= i / int(.002 * SR)
    fade = int(.5 * SR)
    for i in range(fade):
        strike[-fade+i] *= .5 * (1 + math.cos(math.pi*i/(fade-1)))
    print(f'Strike: removed {start/SR:.3f}s leading silence')
    save('singing_bowl_strike_recorded.wav', strike)

    rub = load(rub_path)
    n, fade = 6 * SR, SR
    # Only consider active rubbing, excluding the quiet intro and decay.
    def variation(start):
        block = SR // 10
        rms = [math.sqrt(sum(v*v for v in rub[i:i+block])/block)
               for i in range(start, start+n+fade, block)]
        mean = sum(rms)/len(rms)
        return sum((v-mean)**2 for v in rms)/len(rms)/mean**2

    start = min(range(9*SR, 11*SR+1, SR//10), key=variation)
    segment = rub[start:start+n+fade]
    loop = segment[:n]
    # The extra tail meets the beginning at the wrap, then blends into it.
    for i in range(fade):
        t = .5 - .5 * math.cos(math.pi*i/(fade-1))
        loop[i] = segment[n+i]*(1-t) + segment[i]*t
    print(f'Rim: source {start/SR:.2f}-{(start+n+fade)/SR:.2f}s; 1s crossfade')
    loop = save('singing_bowl_rub_recorded.wav', loop)
    seam = abs(loop[-1]-loop[0])
    steps = sorted(abs(a-b) for a,b in zip(loop, loop[1:]))
    assert seam <= steps[int(len(steps)*.99)], 'Loop boundary is discontinuous'
    print(f'Loop boundary step: {seam:.6f}; p99 ordinary step: {steps[int(len(steps)*.99)]:.6f}')


if __name__ == '__main__':
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    prepare(*sys.argv[1:])
