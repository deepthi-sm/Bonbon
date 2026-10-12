#!/usr/bin/env python3
"""Reconcile the three audio key schemes now present in this repository.

Run:  python3 bonbon_app/tool/audio_reconcile.py

After the Flutter prototype landed on main, three incompatible ways of naming
an audio clip coexist:

  A. content/audio/script/recording-script.json  (Pack 4, BUILD_PLAN_v2 W.1)
     IDs like `letter.t.sound`, `syll.ta`, `blend.ta`. 584 clips.
     Enforced by a regex; distinguishes a letter's NAME from its SOUND.

  B. bonbon_app/tool/utterances.json + Speech.norm()  (the prototype)
     Keyed by the normalised French TEXT itself. 1951 utterances.
     Simple for callers, but a key can only exist if there is text for it.

  C. bonbon_app/assets/content/**/*.json
     `audio.key` strings like `fr:grapheme:t-e3b98a4d`, each with a
     `fallbackText`. The key is never used for lookup today — Speech reads
     the text — so it is a third namespace that resolves to nothing.

Nothing can be generated until one of these is canonical. This script does not
choose; it measures, so the choice is made on numbers rather than preference.

Standard library only. Read-only: writes one report file and nothing else.
"""
import json
import os
import re
import sys
import unicodedata
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
APP = os.path.dirname(HERE)                 # bonbon_app/
ROOT = os.path.dirname(APP)                 # repo root

PACK4 = os.path.join(ROOT, 'content', 'audio', 'script', 'recording-script.json')
UTTER = os.path.join(HERE, 'utterances.json')
CONTENT = os.path.join(APP, 'assets', 'content')
OUT = os.path.join(HERE, 'audio-reconcile-report.json')


def norm(s):
    """Speech.norm() in lib/state/app_state.dart, reproduced exactly."""
    return re.sub(r'\s+', ' ', s.strip()).lower()


def load(path, what):
    try:
        with open(path, encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f'  ! {what} not found at {path}')
        return None
    except json.JSONDecodeError as e:
        print(f'  ! {what} is not valid JSON: {e}')
        return None


def walk_content():
    """Every audio.key / fallbackText pair in the app's own lesson JSON."""
    found = []
    if not os.path.isdir(CONTENT):
        return found

    def visit(node, path):
        if isinstance(node, dict):
            if 'key' in node and 'fallbackText' in node:
                found.append({
                    'key': node['key'],
                    'text': node['fallbackText'],
                    'file': path,
                })
            for v in node.values():
                visit(v, path)
        elif isinstance(node, list):
            for v in node:
                visit(v, path)

    for dirpath, _, names in os.walk(CONTENT):
        for n in sorted(names):
            if not n.endswith('.json'):
                continue
            p = os.path.join(dirpath, n)
            try:
                with open(p, encoding='utf-8') as f:
                    visit(json.load(f), os.path.relpath(p, APP))
            except (json.JSONDecodeError, OSError):
                continue
    return found


def main():
    print('Audio key reconciliation\n' + '=' * 60)

    pack4 = load(PACK4, 'Pack 4 recording script')
    utter = load(UTTER, 'prototype utterances')
    content = walk_content()

    report = {}

    # ---- A. Pack 4 -------------------------------------------------------
    a_rows = {r['id']: r for r in (pack4 or {}).get('rows', [])}
    a_texts = {norm(r.get('text') or ''): i for i, r in a_rows.items()}
    print(f'\nA. Pack 4 IDs                 {len(a_rows):>5} clips')
    ns = Counter(i.split('.')[0] for i in a_rows)
    print('   ' + '  '.join(f'{k}:{v}' for k, v in ns.most_common()))
    report['pack4'] = {'clips': len(a_rows), 'byNamespace': dict(ns)}

    # ---- B. prototype utterances ----------------------------------------
    b_list = utter or []
    b_texts = {}
    for u in b_list:
        t = u.get('text') if isinstance(u, dict) else u
        if t:
            b_texts.setdefault(norm(t), []).append(u.get('where') if isinstance(u, dict) else None)
    print(f'\nB. Prototype utterances       {len(b_list):>5} rows, {len(b_texts)} distinct texts')
    where = Counter(
        (u.get('where') or '?') for u in b_list if isinstance(u, dict))
    print('   ' + '  '.join(f'{k}:{v}' for k, v in where.most_common(6)))
    report['prototype'] = {'rows': len(b_list), 'distinctTexts': len(b_texts),
                           'byWhere': dict(where)}

    # ---- C. lesson-JSON keys --------------------------------------------
    c_keys = {}
    for e in content:
        c_keys.setdefault(e['key'], []).append(e)
    print(f'\nC. audio.key in lesson JSON   {len(content):>5} references, '
          f'{len(c_keys)} distinct keys')
    cns = Counter(k.split(':')[1] if ':' in k else '?' for k in c_keys)
    print('   ' + '  '.join(f'{k}:{v}' for k, v in cns.most_common()))
    report['lessonKeys'] = {'references': len(content), 'distinct': len(c_keys),
                            'byKind': dict(cns)}

    # ---- overlap ---------------------------------------------------------
    print('\n' + '-' * 60)
    shared = set(a_texts) & set(b_texts)
    print(f'Texts present in BOTH A and B        {len(shared):>5}')
    print(f'In Pack 4 only (no prototype text)   {len(set(a_texts) - set(b_texts)):>5}')
    print(f'In prototype only (not in Pack 4)    {len(set(b_texts) - set(a_texts)):>5}')
    report['overlap'] = {
        'both': len(shared),
        'pack4Only': len(set(a_texts) - set(b_texts)),
        'prototypeOnly': len(set(b_texts) - set(a_texts)),
    }

    # ---- the finding that matters ---------------------------------------
    # A letter's NAME and its SOUND are different clips (BUILD_PLAN_v2 W.2).
    # A text-keyed manifest cannot hold both, because the sound has no text.
    print('\n' + '-' * 60)
    print('LETTER NAME vs LETTER SOUND')
    name_ids = sorted(i for i in a_rows if re.fullmatch(r'letter\.[^.]+\.name', i))
    sound_ids = sorted(i for i in a_rows if re.fullmatch(r'letter\.[^.]+\.sound', i))
    print(f'  Pack 4 carries {len(name_ids)} name clips and {len(sound_ids)} sound clips '
          f'as separate recordings.')

    # In the lesson JSON, what text does a grapheme target offer?
    graph = [e for e in content if ':grapheme:' in e['key']]
    bare = [e for e in graph if len(e['text'].strip()) <= 2]
    print(f'  Lesson JSON has {len(graph)} grapheme references; {len(bare)} of them '
          f'give a bare letter as fallbackText.')
    if bare:
        sample = ', '.join(sorted({e["text"] for e in bare})[:12])
        print(f'    e.g. {sample}')
    print('  A bare letter sent to any TTS is read as the letter NAME.')
    print('  So every one of those teaches « té » where the method needs « t ».')
    report['letterSoundGap'] = {
        'pack4NameClips': len(name_ids),
        'pack4SoundClips': len(sound_ids),
        'graphemeRefs': len(graph),
        'bareLetterFallbacks': len(bare),
        'bareLetterSamples': sorted({e['text'] for e in bare})[:20],
    }

    # ---- collisions under text keying ------------------------------------
    print('\n' + '-' * 60)
    print('COLLISIONS IF TEXT IS THE KEY')
    collide = {t: ids for t, ids in defaultdict(list).items()}
    by_text = defaultdict(list)
    for i, r in a_rows.items():
        by_text[norm(r.get('text') or '')].append(i)
    collide = {t: ids for t, ids in by_text.items() if len(ids) > 1 and t}
    print(f'  {len(collide)} Pack 4 texts map to more than one ID:')
    for t, ids in sorted(collide.items())[:10]:
        print(f'    "{t}"  ->  {", ".join(sorted(ids))}')
    empty = by_text.get('', [])
    if empty:
        print(f'  {len(empty)} Pack 4 clips have no text at all and cannot be '
              f'keyed by text under any scheme.')
    report['textKeyCollisions'] = {
        'count': len(collide),
        'examples': {t: sorted(ids) for t, ids in sorted(collide.items())[:20]},
        'noTextAtAll': len(empty),
    }

    with open(OUT, 'w', encoding='utf-8') as f:
        json.dump(report, f, ensure_ascii=False, indent=2)
        f.write('\n')
    print(f'\nWrote {os.path.relpath(OUT, ROOT)}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
