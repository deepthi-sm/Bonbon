#!/usr/bin/env python3
"""Generate the Bonbon audio corpus locally with Piper.

    # try 20 clips first, listen, then do the rest
    python3 bonbon_app/tool/audio_gen.py --limit 20
    python3 bonbon_app/tool/audio_gen.py

Reads  bonbon_app/tool/audio-plan.json   (built by audio_ids.py)
Writes bonbon_app/assets/audio/<id>.m4a
       bonbon_app/assets/audio/manifest.json       text  -> file   (Speech reads this)
       bonbon_app/assets/audio/manifest-ids.json   id    -> file   (the canonical index)

Two manifests on purpose. `Speech` in lib/state/app_state.dart looks a clip up
by its normalised French text, and nothing in the app has to change for this to
work. But text cannot name a clip that has no text — a letter's bare SOUND is
the whole point of a syllabaire and has no spelling — so the ID index is the
canonical one and the text map is a convenience built from it.

Needs: piper (pip install piper-tts), a voice model, and ffmpeg.
Everything runs offline. Nothing is uploaded anywhere.
"""
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
APP = os.path.dirname(HERE)
PLAN = os.path.join(HERE, 'audio-plan.json')
OUT_DIR = os.path.join(APP, 'assets', 'audio')
MANIFEST = os.path.join(OUT_DIR, 'manifest.json')
MANIFEST_IDS = os.path.join(OUT_DIR, 'manifest-ids.json')

DEFAULT_VOICE = os.path.expanduser('~/piper-voices/fr_FR-siwis-medium.onnx')


def norm(s):
    """Speech.norm() in app_state.dart — the lookup key, byte for byte."""
    return re.sub(r'\s+', ' ', s.strip()).lower()


def have(cmd):
    return shutil.which(cmd) is not None


def piper_cmd(voice):
    """Piper ships as `piper`; some installs only expose `python -m piper`."""
    if have('piper'):
        return ['piper', '-m', voice]
    return [sys.executable, '-m', 'piper', '-m', voice]


def synth(text, voice, wav_path):
    """One clip, text (or [[phonemes]]) in, wav out."""
    p = subprocess.run(
        piper_cmd(voice) + ['-f', wav_path],
        input=text.encode('utf-8'),
        stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    if p.returncode != 0:
        return p.stderr.decode('utf-8', 'replace').strip()[:200]
    if not os.path.exists(wav_path) or os.path.getsize(wav_path) < 1000:
        return 'piper produced no audio'
    return None


RATE = 22050


def silence(seconds, rate, path):
    subprocess.run(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-y',
                    '-f', 'lavfi', '-i',
                    f'anullsrc=r={rate}:cl=mono', '-t', str(seconds),
                    '-c:a', 'pcm_s16le', path],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def rate_of(path):
    p = subprocess.run(['ffprobe', '-v', 'error', '-select_streams', 'a:0',
                        '-show_entries', 'stream=sample_rate',
                        '-of', 'csv=p=0', path], capture_output=True)
    try:
        return int(p.stdout.decode().strip())
    except ValueError:
        return 22050


def synth_parts(parts, voice, out_wav, tmp, gap=0.5):
    """A fusion clip: « t … a … ta », with an exact half-second between parts.

    Piper treats an ellipsis as ordinary punctuation and races past it, so the
    gap is cut in, not spoken. The regularity is the point — every fusion clip
    has the identical rhythm, which is what makes the pattern learnable, and
    docs/audio-production.md fixes it at 500 ms.
    """
    pieces = []
    for i, part in enumerate(parts):
        w = os.path.join(tmp, f'p{i}.wav')
        if part.get('use'):
            # A recorded clip — a plosive, which no synthesiser can produce in
            # isolation. Decoded to the same wav format as the synthesised
            # parts so the concat demuxer can stitch them without re-encoding.
            src = os.path.join(OUT_DIR, f"{part['use']}.m4a")
            if not os.path.exists(src):
                return f"missing recorded clip {part['use']}"
            r = subprocess.run(['ffmpeg', '-hide_banner', '-loglevel', 'error',
                                '-y', '-i', src, '-ar', str(RATE), '-ac', '1',
                                '-c:a', 'pcm_s16le', w],
                               stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
            if r.returncode != 0:
                return r.stderr.decode('utf-8', 'replace')[:200]
            pieces.append(w)
            continue
        payload = (f"[[ {part['phonemes']} ]]" if part.get('phonemes')
                   else (part.get('text') or '').strip())
        if not payload:
            continue
        err = synth(payload, voice, w)
        if err:
            return err
        norm_w = w + '.r.wav'
        subprocess.run(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-y',
                        '-i', w, '-ar', str(RATE), '-ac', '1',
                        '-c:a', 'pcm_s16le', norm_w],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        pieces.append(norm_w if os.path.exists(norm_w) else w)
    if not pieces:
        return 'no parts produced audio'

    sil = os.path.join(tmp, 'sil.wav')
    silence(gap, RATE, sil)

    listing = os.path.join(tmp, 'concat.txt')
    with open(listing, 'w', encoding='utf-8') as f:
        for i, w in enumerate(pieces):
            if i:
                f.write(f"file '{sil}'\n")
            f.write(f"file '{w}'\n")
    r = subprocess.run(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-y',
                        '-f', 'concat', '-safe', '0', '-i', listing,
                        '-c', 'copy', out_wav],
                       stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    if r.returncode != 0:
        return r.stderr.decode('utf-8', 'replace').strip()[:200]
    return None


def encode(wav_path, out_path):
    """Normalise and encode to the spec in docs/audio-production.md.

    Mono, 44.1 kHz, AAC 64 kbps, -16 LUFS, true peak <= -1 dBTP. Two-pass
    loudnorm is not used here because these clips are short and uniform
    coming out of one synthesiser; the studio path in tools/audio-pipeline
    does use two passes, where the input varies take to take.
    """
    p = subprocess.run([
        'ffmpeg', '-hide_banner', '-loglevel', 'error', '-y',
        '-i', wav_path,
        '-af', 'loudnorm=I=-16:TP=-1.0:LRA=7,'
               'silenceremove=start_periods=1:start_silence=0.08:start_threshold=-50dB,'
               'apad=pad_dur=0.2',
        '-ar', '44100', '-ac', '1', '-c:a', 'aac', '-b:a', '64k',
        out_path,
    ], stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    if p.returncode != 0:
        return p.stderr.decode('utf-8', 'replace').strip()[:200]
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--voice', default=DEFAULT_VOICE, help='path to a .onnx voice')
    ap.add_argument('--limit', type=int, default=0, help='stop after N clips')
    ap.add_argument('--only', default='', help='regex: generate matching IDs only')
    ap.add_argument('--force', action='store_true', help='regenerate existing clips')
    ap.add_argument('--manifest-only', action='store_true',
                    help='rebuild the manifests from what is already on disk')
    args = ap.parse_args()

    if not os.path.exists(PLAN):
        sys.exit('no audio-plan.json — run audio_ids.py first')
    with open(PLAN, encoding='utf-8') as f:
        rows = json.load(f)['rows']

    os.makedirs(OUT_DIR, exist_ok=True)

    if not args.manifest_only:
        if not os.path.exists(args.voice):
            sys.exit(f'voice model not found: {args.voice}\n'
                     f'pass --voice /path/to/model.onnx')
        if not have('ffmpeg'):
            sys.exit('ffmpeg not found — brew install ffmpeg')

    human = set()
    hp = os.path.join(OUT_DIR, 'human-recorded.txt')
    if os.path.exists(hp):
        with open(hp, encoding='utf-8') as f:
            human = {l.strip() for l in f
                     if l.strip() and not l.startswith('#')}

    sel = re.compile(args.only) if args.only else None
    todo = [r for r in rows if not sel or sel.search(r['id'])]
    if args.limit:
        todo = todo[:args.limit]

    print(f'{len(todo)} clips to do (voice: {os.path.basename(args.voice)})',
          flush=True)
    made = skipped = failed = 0
    errors = []
    tmp = tempfile.mkdtemp(prefix='bonbon-audio-')
    try:
        for i, r in enumerate(todo, 1):
            rid = r['id']
            out = os.path.join(OUT_DIR, f'{rid}.m4a')

            if args.manifest_only:
                continue
            if rid in human:
                skipped += 1      # recorded by a person; --force must not touch it
                continue
            if os.path.exists(out) and not args.force:
                skipped += 1
                continue

            # A letter's SOUND is synthesised from its phoneme, never from
            # its spelling: fed the text "t", any synthesiser says the letter
            # NAME. Piper takes eSpeak phonemes inline in [[ ]].
            wav = os.path.join(tmp, 'c.wav')

            if r.get('parts'):
                err = synth_parts(r['parts'], args.voice, wav, tmp)
            else:
                if r.get('phonemes'):
                    payload = f"[[ {r['phonemes']} ]]"
                elif r.get('speakText') is False:
                    payload = ''
                else:
                    payload = (r.get('text') or '').strip()
                if not payload:
                    failed += 1
                    errors.append((rid, 'nothing to say'))
                    continue
                err = synth(payload, args.voice, wav)
            if err is None:
                err = encode(wav, out)
            if err:
                failed += 1
                errors.append((rid, err))
            else:
                made += 1

            step = 50 if len(todo) > 300 else 10
            if i % step == 0 or i == len(todo):
                print(f'  {i}/{len(todo)}  made {made}  skipped {skipped}  failed {failed}',
                      flush=True)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

    # ---- manifests, rebuilt from what is actually on disk ----------------
    by_id, by_text, clashes = {}, {}, []
    for r in rows:
        rid = r['id']
        fname = f'{rid}.m4a'
        if not os.path.exists(os.path.join(OUT_DIR, fname)):
            continue
        by_id[rid] = fname
        t = norm(r.get('text') or '')
        if not t:
            continue                      # a sound with no spelling: ID only
        if t in by_text and by_text[t] != fname:
            clashes.append((t, by_text[t], fname))
            continue                      # first ID wins; ID lookup still exact
        by_text[t] = fname

    for path, data in ((MANIFEST, by_text), (MANIFEST_IDS, by_id)):
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2, sort_keys=True)
            f.write('\n')

    print()
    print(f'generated   {made}')
    print(f'skipped     {skipped}   (already on disk; --force to redo)')
    print(f'failed      {failed}')
    print(f'clips total {len(by_id)} of {len(rows)} planned')
    print(f'text keys   {len(by_text)}   ({len(clashes)} texts shared an ID, ID lookup unaffected)')
    if errors:
        print('\nfirst failures:')
        for rid, e in errors[:8]:
            print(f'  {rid}: {e}')
    print(f'\nwrote {os.path.relpath(MANIFEST, APP)}')
    print(f'      {os.path.relpath(MANIFEST_IDS, APP)}')
    return 1 if failed and not made else 0


if __name__ == '__main__':
    sys.exit(main())
