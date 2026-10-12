#!/usr/bin/env python3
"""Remove clips no synthesiser can make, and list them for a human.

    python3 bonbon_app/tool/audio_human.py          # show what would go
    python3 bonbon_app/tool/audio_human.py --apply  # remove them, rebuild manifests

A plosive — p t k b d g — is a silence followed by a burst of about twenty
milliseconds. It cannot be held. Asked for a quarter-second of /t/, a neural
vocoder fills the gap with aspiration noise, which is what we got. Continuants
(f s v z m n l r) and vowels can be sustained and synthesise correctly.

So a small set of clips has to come from a person. Rather than ship noise, we
delete them: Speech.has() returns false, no speaker icon renders, and the
learner sees a simpler app rather than a broken one. Drop the recordings in
assets/audio/ under the listed IDs and rerun audio_gen.py --manifest-only.

This is the case docs/audio-production.md makes for having someone trained in
literacy work in the room for the consonants. Eight sounds, not two thousand.
"""
import argparse
import json
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
APP = os.path.dirname(HERE)
PLAN = os.path.join(HERE, 'audio-plan.json')
AUDIO = os.path.join(APP, 'assets', 'audio')
OUT_CSV = os.path.join(HERE, 'needs-human-voice.csv')

# IPA for the French plosives. /h/ is here too: it is silent in French and
# there is nothing to synthesise.
PLOSIVES = {'p', 't', 'k', 'b', 'd', 'g', 'ɡ'}


def first_phoneme(row):
    if row.get('phonemes'):
        return row['phonemes'][:1]
    parts = row.get('parts') or []
    for p in parts:
        if p.get('phonemes'):
            return p['phonemes'][:1]
    return ''


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--apply', action='store_true', help='actually delete')
    args = ap.parse_args()

    with open(PLAN, encoding='utf-8') as f:
        rows = json.load(f)['rows']

    doomed = []
    for r in rows:
        rid = r['id']
        if not (rid.endswith('.sound') or rid.startswith('blend.')):
            continue
        if first_phoneme(r) not in PLOSIVES:
            continue
        path = os.path.join(AUDIO, f'{rid}.m4a')
        doomed.append((rid, r.get('text') or '', os.path.exists(path), path))

    present = [d for d in doomed if d[2]]
    letters = [d for d in doomed if d[0].startswith('letter.')]
    fusions = [d for d in doomed if d[0].startswith('blend.')]

    print(f'clips a human must record   {len(doomed)}')
    print(f'  letter sounds             {len(letters)}')
    print(f'  fusions starting plosive  {len(fusions)}')
    print(f'  currently on disk         {len(present)}')
    print()
    for rid, text, exists, _ in letters:
        print(f'  {rid:<24} {text}')

    with open(OUT_CSV, 'w', encoding='utf-8-sig') as f:
        f.write('id,what_to_say,note,recorded\n')
        for rid, text, _, _ in doomed:
            if rid.startswith('letter.'):
                ch = rid.split('.')[1]
                note = ('the SOUND of the letter alone, as briefly as '
                        'possible — never its name')
                say = ch
            else:
                syl = rid.split('.', 1)[1]
                note = ('the two sounds separated by half a second, then '
                        'fused: consonant, pause, vowel, pause, syllable')
                say = syl
            f.write(f'{rid},"{say}","{note}",\n')
    print(f'\nwrote {os.path.relpath(OUT_CSV, APP)}')

    if not args.apply:
        print('\n(dry run — pass --apply to delete)')
        return 0

    gone = 0
    for rid, _, exists, path in doomed:
        if exists:
            os.remove(path)
            gone += 1
    print(f'\ndeleted {gone} clips')

    r = subprocess.run([sys.executable, os.path.join(HERE, 'audio_gen.py'),
                        '--manifest-only'], cwd=os.path.dirname(APP))
    return r.returncode


if __name__ == '__main__':
    sys.exit(main())
