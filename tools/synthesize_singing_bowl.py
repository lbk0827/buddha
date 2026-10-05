"""Create a matched singing-bowl strike and seamless rubbing loop.

The waveforms are synthesized here; they do not contain recorded samples.
Run from the repository root with ``python tools/synthesize_singing_bowl.py``.
"""

from __future__ import annotations

import array
import math
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "sounds"
RATE = 22_050
TAU = 2 * math.pi
STRIKE_SECONDS = 8.0
RUB_SECONDS = 6.0

# Slightly inharmonic resonances of one imagined medium-sized brass bowl.
# The close pair at the bottom gives the gentle wavering heard in a bowl.
MODES = (
    (293.667, 1.00, 3.65, 0.08),
    (296.333, 0.40, 3.05, 1.38),
    (506.500, 0.25, 2.75, 0.45),
    (762.167, 0.16, 2.05, 2.12),
    (1068.833, 0.08, 1.25, 0.73),
    (1431.500, 0.03, 0.75, 2.66),
)


def smooth_attack(t: float, seconds: float) -> float:
    return 1.0 - math.exp(-t / seconds)


def strike() -> list[float]:
    result = []
    for i in range(round(STRIKE_SECONDS * RATE)):
        t = i / RATE
        tone = 0.0
        for frequency, strength, decay, phase in MODES:
            # Higher resonances die away first; a quiet fundamental persists.
            envelope = smooth_attack(t, 0.008) * math.exp(-t / decay)
            tone += strength * envelope * math.sin(TAU * frequency * t + phase)

        # A soft low-frequency thump replaces the noisy mallet transient.
        contact = (
            0.07
            * smooth_attack(t, 0.002)
            * math.exp(-t / 0.018)
            * math.sin(TAU * 126.0 * t)
        )
        sound = tone + contact
        # Extra final taper keeps the end inaudible even at high volume.
        if t > 6.5:
            tail = (STRIKE_SECONDS - t) / 1.5
            sound *= max(0.0, tail) ** 2
        result.append(sound)
    return result


def rubbing() -> list[float]:
    """Use only whole cycles in six seconds so the loop has no seam."""
    result = []
    total = round(RUB_SECONDS * RATE)
    # All frequencies, amplitude motions, and phase motions complete an
    # integer number of cycles over RUB_SECONDS.
    strengths = (0.64, 0.24, 0.14, 0.09, 0.035, 0.012)
    for i in range(total):
        t = i / RATE
        # A small rolling swell mimics steady suede contact at the rim.
        swell = 0.84 + 0.09 * math.sin(TAU * 2.0 * t + 0.35)
        swell += 0.035 * math.sin(TAU * 5.0 * t + 1.20)
        tone = 0.0
        for (frequency, _, _, phase), strength in zip(MODES, strengths):
            cycles = round(frequency * RUB_SECONDS)
            tone += strength * math.sin(TAU * cycles * i / total + phase)

        result.append(swell * tone)
    # Put the loop boundary at a quiet, near-zero point of the periodic wave.
    # This also makes the first playback start gently.
    cut = min(
        range(1, len(result)),
        key=lambda i: abs(result[i] - result[i - 1])
        + 0.05 * (abs(result[i]) + abs(result[i - 1])),
    )
    return result[cut:] + result[:cut]


def save(path: Path, samples: list[float], peak_db: float) -> None:
    peak = max(abs(sample) for sample in samples)
    gain = 10 ** (peak_db / 20) / peak
    pcm = array.array(
        "h",
        (max(-32767, min(32767, round(sample * gain * 32767))) for sample in samples),
    )
    with wave.open(str(path), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(RATE)
        output.writeframes(pcm.tobytes())
    print(f"{path.name}: {len(samples) / RATE:.1f}s, {path.stat().st_size:,} bytes")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    # Three strikes and one rubbing voice can overlap in the app.
    # Their worst-case sample peaks stay below full scale.
    save(OUT / "singing_bowl_strike_v3.wav", strike(), -12.0)
    save(OUT / "singing_bowl_rub_v3.wav", rubbing(), -14.0)


if __name__ == "__main__":
    main()
