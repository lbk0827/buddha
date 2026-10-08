"""Cut keycap (mechanical keyboard) press/release candidates from CC0 Freesound recordings.

For the 키캡 play mode. Only CC0 sources are used (licensing rule: docs/사운드_출처.md).
Original WAV downloads need a Freesound login, so the public HQ preview MP3s are used;
converting to WAV does not restore what the MP3 encoder removed.
Requires `miniaudio`; everything else is pure Python (no numpy).

Every source page and HQ preview URL is listed in SOURCES below (all CC0 1.0, license
checked on each page on 2026-10-08), e.g.
  https://freesound.org/people/Reina0613/sounds/709460/
  https://cdn.freesound.org/previews/709/709460_13652097-hq.mp3

Reproduce:
  python tools/prepare_keycap_sounds.py fetch           # pages + HQ MP3s -> build/keycap_sources/
  python tools/prepare_keycap_sounds.py analyze 709460  # print detected keystrokes of one source
  python tools/prepare_keycap_sounds.py build           # write candidates for every source
  python tools/prepare_keycap_sounds.py build 709460    # or only some

Output (gitignored build dir):
  build/keycap_sources/<id>.mp3, build/keycap_sources/pages/<id>.html
  build/keycap_sources/candidates/<id>_<author>/down_N.wav, up_N.wav, preview.wav, info.txt
  build/keycap_sources/candidates/summary.json
All WAVs are 44.1 kHz mono 16-bit (keyboard transients need the high band).

How strokes are found: a 1 ms peak envelope (held over 5 ms) is scanned for sharp rises
(>= 18 dB above the noise floor and >= 12 dB above the previous 15 ms). Onsets closer than
250 ms form one keystroke. Inside a keystroke, rises within 60 ms of the first belong to the
press (e.g. a blue switch's click then bottom-out); the first rise 60-250 ms later is the
release. A keystroke is used only if it has exactly one release, nothing else before the next
keystroke, no clipping, a press >= 35 dB above the floor and a release >= 2 dB quieter.
Clips: 2 ms pre-roll with linear fade-in, end where the envelope stays 48 dB under the clip
peak (or 3 ms before the next event, max 250 ms), cosine fade over the last 40 %.
One gain per set puts the loudest press at peak 0.5; releases keep their recorded level.
"""

import array
import json
import math
from pathlib import Path
import re
import sys
import urllib.request
import wave

import miniaudio

SR = 44100
HOP = 44  # ~1 ms envelope hop
ROOT = Path(__file__).resolve().parent.parent
SRC_DIR = ROOT / 'build' / 'keycap_sources'
OUT_DIR = SRC_DIR / 'candidates'

SOURCES = {}


def source(sid, author, title, preview, note, span=None, strokes=None, n_down=6, n_up=4):
    """span: (start, end) seconds to search; strokes: explicit keystroke onsets (s),
    otherwise the cleanest keystrokes (highest press SNR) are picked automatically."""
    SOURCES[sid] = dict(id=sid, author=author, title=title, preview=preview, note=note,
                        url=f'https://freesound.org/people/{author}/sounds/{sid}/',
                        span=span, strokes=strokes, n_down=n_down, n_up=n_up)


source('709460', 'Reina0613', 'Mechanical keyboard typing sounds',
       'https://cdn.freesound.org/previews/709/709460_13652097-hq.mp3',
       'ikki68 Aurora custom, hand-lubed WS Brown tactile switches, Zoom H8. '
       'First ~15 s are slow single keystrokes, then continuous typing (not used).',
       span=(0, 15.5))
source('660387', 'Xemptful', 'Single Key Presses on Mechanical Keyboard',
       'https://cdn.freesound.org/previews/660/660387_3531538-hq.mp3',
       'Switch type not stated. "Cleaned and mastered in Adobe Audition" (gaps are digital '
       'silence, i.e. noise-gated).')
source('643559', 'el_boss', 'Gateron Black Switches Sound',
       'https://cdn.freesound.org/previews/643/643559_9129912-hq.mp3',
       'Gateron Black (heavy linear) switches. A few keystrokes, several with rattle.')
source('609534', '5ro4', 'Keyboard single key presses.wav',
       'https://cdn.freesound.org/previews/609/609534_1629501-hq.mp3',
       'Mars Gaming MKREVO keyboard, Blue Yeti. ~1 keystroke per second.')
source('546165', 'grcekh', 'Keyboard Typing 8 (HHKB, Topre)',
       'https://cdn.freesound.org/previews/546/546165_12206738-hq.mp3',
       'Title says HHKB/Topre, description is copied from the WhiteFox recording. '
       'Yeti Nano. Only the last ~20 s have separated keystrokes.', span=(126, 150))
source('665075', 'zrrion', 'Keyboard typing sounds: Unidentified Technics keyboard',
       'https://cdn.freesound.org/previews/665/665075_2686637-hq.mp3',
       'Gateron yellow linear bottoms with MX tops, sliders wax-lubed and Krytox 205g0. '
       'Continuous typing; strokes come from the few pauses, so a "release" may be another key.')
source('638035', 'simeonradivoev', 'Mechanical Keyboard Typing Cherry Blue Switches',
       'https://cdn.freesound.org/previews/638/638035_2278166-hq.mp3',
       'HyperX FPS, Cherry MX Blue (clicky). Lapel microphone into a phone.')
source('412926', 'humi74', 'Mechanical keyboard clicking. Different keys (4)',
       'https://cdn.freesound.org/previews/412/412926_6895079-hq.mp3',
       'Cherry MX Clear (stiff tactile, non-clicky).')


# ---------------------------------------------------------------- audio io

def load(path):
    d = miniaudio.decode_file(str(path), output_format=miniaudio.SampleFormat.FLOAT32,
                              nchannels=1, sample_rate=SR)
    return list(d.samples)


def write_wav(path, samples):
    pcm = array.array('h', (max(-32767, min(32767, round(v * 32767))) for v in samples))
    if sys.byteorder != 'little':
        pcm.byteswap()
    with wave.open(str(path), 'wb') as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(SR)
        out.writeframes(pcm.tobytes())


# ---------------------------------------------------------------- analysis

def db(v):
    return 20 * math.log10(max(v, 1e-9))


def envelope(x, hold=5):
    """1 ms hops; each value is the peak over the last `hold` ms so low-frequency ringing
    (a 100 Hz wave crosses zero every 5 ms) does not look like a gap."""
    raw = [max(abs(v) for v in x[i:i + HOP]) for i in range(0, len(x) - HOP, HOP)]
    return [max(raw[max(0, i - hold + 1):i + 1]) for i in range(len(raw))]


def detect(x, rise_db=18, jump_db=12, min_gap_ms=30):
    """Return (events, floor). Event = dict(on, peak, end) in samples."""
    e = envelope(x)
    pk = max(e)
    s = sorted(e)
    fl = max(s[len(s) * 3 // 10], pk * 10 ** (-65 / 20), 1e-5)
    on_t = fl * 10 ** (rise_db / 20)
    off_t = fl * 10 ** (8 / 20)
    jump = 10 ** (jump_db / 20)
    ons = []
    for i in range(15, len(e)):
        if e[i] < on_t or (ons and i - ons[-1] < min_gap_ms):
            continue
        if e[i] >= jump * max(min(e[i - 15:i]), fl):
            j = i
            while j > i - 4 and e[j - 1] > max(off_t, e[i] / 8):
                j -= 1
            ons.append(j)
    ev = []
    for n, j in enumerate(ons):
        stop = ons[n + 1] if n + 1 < len(ons) else len(e)
        peak, below, end = 0.0, 0, stop
        for i in range(j, stop):
            peak = max(peak, e[i])
            below = below + 1 if e[i] < off_t else 0
            if below >= 8:
                end = i - 7
                break
        ev.append(dict(on=j * HOP, peak=peak, end=end * HOP))
    return ev, fl


def groups(ev, gap_s=0.25):
    out = []
    for e in ev:  # measured from the group's first onset, so groups do not chain
        if out and e['on'] - out[-1][0]['on'] < gap_s * SR:
            out[-1].append(e)
        else:
            out.append([e])
    return out


def keystrokes(x, ev, fl):
    """Split each group into press / release and judge the two halves separately.

    down usable: press >= 35 dB over the floor, a release follows (so the press clip ends
    before it) and is not louder than the press, no clipping.
    up usable: release >= 2 dB quieter than its press, >= 30 dB over the floor and nothing
    else within 120 ms after it (rattle or the next key would leak into the clip).
    """
    gs = groups(ev)
    out = []
    for n, g in enumerate(gs):
        t0 = g[0]['on']
        press = [e for e in g if e['on'] - t0 < 0.06 * SR]
        rest = [e for e in g if e['on'] - t0 >= 0.06 * SR]
        rel = rest[0] if rest else None
        nxt = gs[n + 1][0]['on'] if n + 1 < len(gs) else len(x)
        after_rel = rest[1]['on'] if len(rest) > 1 else nxt
        ppk = max(e['peak'] for e in press)
        k = dict(on=t0, press_peak=ppk, release=rel, next=nxt, after_rel=after_rel,
                 snr=db(ppk / fl), down=[], up=[])
        if k['snr'] < 35:
            k['down'].append(f"low SNR ({k['snr']:.0f} dB)")
        if rel is None:
            k['down'].append('no release')
            k['up'].append('no release')
        else:
            k['rel_db'] = db(rel['peak'] / ppk)
            if k['rel_db'] > 0:
                k['down'].append(f"release louder ({k['rel_db']:+.0f} dB)")
            if k['rel_db'] > -2:
                k['up'].append(f"release not quieter ({k['rel_db']:+.0f} dB)")
            if db(rel['peak'] / fl) < 30:
                k['up'].append('release low SNR')
            if after_rel - rel['on'] < 0.12 * SR:
                k['up'].append('another event within 120 ms of release')
            if max(abs(v) for v in x[rel['on']:after_rel]) > 0.985:
                k['up'].append('clipped')
        if max(abs(v) for v in x[t0:rel['on'] if rel else nxt]) > 0.985:
            k['down'].append('clipped')
        out.append(k)
    return out


def spectrum_stats(clip, n_ms=60):
    """Naive DFT on the first n_ms (Hann): centroid Hz, share < 1 kHz, share > 10 kHz."""
    seg = clip[:int(SR * n_ms / 1000)]
    n = len(seg)
    w = [seg[i] * (0.5 - 0.5 * math.cos(2 * math.pi * i / (n - 1))) for i in range(n)]
    num = den = low = high = 0.0
    f = 50.0
    while f <= 20000:
        step = 50 if f < 2000 else 250
        k = 2 * math.pi * f / SR
        cr, sr_ = math.cos(k), math.sin(k)
        cc, ss, c, s = 1.0, 0.0, 0.0, 0.0
        for v in w:  # cos/sin by recurrence: fast enough in pure Python
            c += v * cc
            s += v * ss
            cc, ss = cc * cr - ss * sr_, cc * sr_ + ss * cr
        p = (c * c + s * s) * step  # weight by the band each bin stands for
        num += f * p
        den += p
        if f < 1000:
            low += p
        if f >= 10000:
            high += p
        f += step
    den = den or 1.0
    return num / den, low / den, high / den


def measure(clip):
    pk = max(abs(v) for v in clip)
    rms = math.sqrt(sum(v * v for v in clip) / len(clip))
    zc = sum(1 for a, b in zip(clip, clip[1:]) if (a < 0) != (b < 0))
    c, low, high = spectrum_stats(clip)
    return dict(dur=len(clip) / SR, peak=pk, rms=rms, centroid=c, low=low, high=high,
                zcr=zc / 2 / (len(clip) / SR))


# ---------------------------------------------------------------- cutting

def cut(x, onset, stop, floor, max_len=0.25, min_len=0.05):
    pre = int(0.002 * SR)
    a = max(0, onset - pre)
    seg = list(x[a:min(len(x), onset + int(max_len * SR), stop - int(0.003 * SR))])
    if len(seg) < int(min_len * SR):
        return None, 'too short'
    pk = max(abs(v) for v in seg)
    thr = max(floor * 2.5, pk * 10 ** (-48 / 20))
    e = envelope(seg)
    end, run = len(seg), 0
    for i in range(int(0.02 * SR) // HOP, len(e)):
        run = run + 1 if e[i] < thr else 0
        if run >= 10:
            end = (i + 1) * HOP
            break
    seg = seg[:max(end, int(min_len * SR))]
    tail = db(max(abs(v) for v in seg[-int(0.01 * SR):]) / pk)
    for i in range(pre):
        seg[i] *= i / pre
    fade = min(max(int(0.4 * len(seg)), int(0.02 * SR)), len(seg) - pre)
    for i in range(fade):
        seg[len(seg) - fade + i] *= 0.5 * (1 + math.cos(math.pi * i / (fade - 1)))
    seg[-1] = 0.0
    return seg, f'tail {tail:.0f} dB before fade'


# ---------------------------------------------------------------- commands

def fetch(ids):
    (SRC_DIR / 'pages').mkdir(parents=True, exist_ok=True)
    for sid in ids:
        s = SOURCES[sid]
        page, mp3 = SRC_DIR / 'pages' / f'{sid}.html', SRC_DIR / f'{sid}.mp3'
        for url, path in ((s['url'], page), (s['preview'], mp3)):
            if not path.exists() or path.stat().st_size == 0:
                req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
                path.write_bytes(urllib.request.urlopen(req, timeout=300).read())
        lic = re.search(r'title="Go to the full license text" href="([^"]+)"[^>]*>([^<]+)<',
                        page.read_text(encoding='utf8'))
        print(sid, s['author'], lic.group(2) if lic else 'LICENSE NOT FOUND', lic and lic.group(1))


def analyze(sid):
    x = load(SRC_DIR / f'{sid}.mp3')
    ev, fl = detect(x)
    ks = keystrokes(x, ev, fl)
    print(f'{sid}: {len(x)/SR:.2f}s floor {db(fl):.1f} dBFS, {len(ev)} events, {len(ks)} keystrokes, '
          f'usable down {sum(not k["down"] for k in ks)}, up {sum(not k["up"] for k in ks)}')
    for k in ks:
        rel = k['release']
        r = f"release +{(rel['on']-k['on'])/SR*1000:.0f}ms {k['rel_db']:+.0f}dB" if rel else 'no release'
        print(f"  t={k['on']/SR:7.3f} press {db(k['press_peak']):5.1f}dBFS snr {k['snr']:3.0f}  "
              f"{r:24s} down:{'OK' if not k['down'] else ','.join(k['down'])}  "
              f"up:{'OK' if not k['up'] else ','.join(k['up'])}")


def build_preview(downs, ups, gaps=(0.45, 0.55, 0.38, 0.6, 0.5, 0.42, 0.58)):
    """~4 s: press, ~120 ms later its release, 380-600 ms between keys, rotating variants."""
    total = int(4.2 * SR)
    buf = [0.0] * total
    t, k = 0.15, 0
    while True:
        d = downs[k % len(downs)]
        s = int(t * SR)
        if s + len(d) >= total:
            break
        for i, v in enumerate(d):
            buf[s + i] += v
        if ups:
            u = ups[k % len(ups)]
            s2 = int((t + 0.11 + 0.015 * (k % 3)) * SR)
            if s2 + len(u) < total:
                for i, v in enumerate(u):
                    buf[s2 + i] += v
        t += gaps[k % len(gaps)]
        k += 1
    pk = max(abs(v) for v in buf)
    return [v * 0.95 / pk for v in buf] if pk > 0.95 else buf


def build(ids):
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    summary = {}
    for sid in ids:
        s = SOURCES[sid]
        x = load(SRC_DIR / f'{sid}.mp3')
        ev, fl = detect(x)
        ks = keystrokes(x, ev, fl)
        if s['strokes']:
            ks = [min(ks, key=lambda k: abs(k['on'] - t * SR)) for t in s['strokes']]
        else:  # cleanest first: highest press SNR
            if s['span']:
                ks = [k for k in ks if s['span'][0] * SR <= k['on'] < s['span'][1] * SR]
            ks = sorted(ks, key=lambda k: -k['snr'])
        downs, ups = [], []
        for k in ks:
            rel = k['release']
            if len(downs) < s['n_down'] and not k['down']:
                c, why = cut(x, k['on'], rel['on'], fl)
                if c:
                    downs.append((k['on'] / SR, c, why))
            if len(ups) < s['n_up'] and not k['up']:
                c, why = cut(x, rel['on'], k['after_rel'], fl)
                if c:
                    ups.append((rel['on'] / SR, c, f"{why}; {k['rel_db']:+.0f} dB vs its press"))
        d = OUT_DIR / f"{sid}_{s['author']}"
        d.mkdir(exist_ok=True)
        for f in d.glob('*.wav'):
            f.unlink()
        if not downs:
            print(sid, 'no usable keystrokes')
            continue
        downs.sort()
        ups.sort()
        gain = 0.5 / max(max(abs(v) for v in c) for _, c, _ in downs)
        lines = [f"{s['title']} by {s['author']} - CC0 1.0 - {s['url']}",
                 f"preview MP3: {s['preview']}", s['note'],
                 f"noise floor {db(fl):.1f} dBFS in the MP3; set gain {db(gain):+.1f} dB", '',
                 'file    src_t     ms  peak   rms_dB  centroid  <1kHz  >10kHz  zcr_Hz  note']
        rows, dclips, uclips = [], [], []
        for kind, clips, store in (('down', downs, dclips), ('up', ups, uclips)):
            for n, (t, clip, why) in enumerate(clips, 1):
                clip = [v * gain for v in clip]
                store.append(clip)
                write_wav(d / f'{kind}_{n}.wav', clip)
                m = measure(clip)
                rows.append(dict(file=f'{kind}_{n}.wav', src_t=round(t, 3), note=why,
                                 **{k: round(v, 4) for k, v in m.items()}))
                lines.append(f"{kind}_{n:<3} {t:7.3f}  {m['dur']*1000:4.0f}  {m['peak']:.3f}  "
                             f"{db(m['rms']):6.1f}  {m['centroid']:6.0f}Hz  {m['low']*100:4.0f}%  "
                             f"{m['high']*100:5.1f}%  {m['zcr']:6.0f}  {why}")
        write_wav(d / 'preview.wav', build_preview(dclips, uclips))
        (d / 'info.txt').write_text('\n'.join(lines) + '\n', encoding='utf8')
        summary[sid] = dict(author=s['author'], title=s['title'], url=s['url'],
                            floor_dbfs=round(db(fl), 1), gain_db=round(db(gain), 1), clips=rows)
        print('\n'.join(lines), '\n')
    path = OUT_DIR / 'summary.json'
    old = json.loads(path.read_text(encoding='utf8')) if path.exists() else {}
    old.update(summary)
    path.write_text(json.dumps(old, indent=1, ensure_ascii=False), encoding='utf8')


if __name__ == '__main__':
    cmd = sys.argv[1] if len(sys.argv) > 1 else 'build'
    ids = sys.argv[2:] or list(SOURCES)
    if cmd == 'fetch':
        fetch(ids)
    elif cmd == 'analyze':
        for sid in ids:
            analyze(sid)
    else:
        build(ids)
