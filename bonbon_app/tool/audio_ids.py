#!/usr/bin/env python3
"""Build the canonical audio clip list for Bonbon.

Run:  python3 bonbon_app/tool/audio_ids.py

Three naming schemes exist in this repo (see audio_reconcile.py). This makes
one canonical list out of them, keyed by the Pack 4 ID grammar, and writes:

    bonbon_app/tool/audio-plan.json    every clip to produce, with its ID
    bonbon_app/tool/audio-plan.csv     the same, for eyeballing in a sheet

Nothing is generated or deleted here. The plan is the input to the generator.

WHY IDs AND NOT TEXT
    The prototype keys clips by the French text itself, which is simple but
    cannot express the one distinction the whole method rests on: a letter's
    NAME (« té ») and its SOUND (« t ») are different recordings, and the
    sound has no text to key on. 31 other texts also map to more than one
    clip. So: IDs are canonical, and the manifest carries the text alongside
    so `Speech.say("bonjour")` keeps working untouched.

Standard library only.
"""
import csv
import json
import os
import re
import sys
import unicodedata
from collections import Counter

HERE = os.path.dirname(os.path.abspath(__file__))
APP = os.path.dirname(HERE)
ROOT = os.path.dirname(APP)

PACK4 = os.path.join(ROOT, 'content', 'audio', 'script', 'recording-script.json')
UTTER = os.path.join(HERE, 'utterances.json')
CONTENT = os.path.join(APP, 'assets', 'content')
OUT_JSON = os.path.join(HERE, 'audio-plan.json')
OUT_CSV = os.path.join(HERE, 'audio-plan.csv')

GRAMMAR = re.compile(
    r'^(letter|syll|blend|word|sent|text|digit|prompt|fb|cue|ui|vo|q)\.[A-Za-z0-9_.-]+$')

# Vowel keys from audio-id-grammar.json: diacritics are transliterated,
# never embedded, because an ID becomes a filename.
VOWEL_KEY = {'é': 'e_acute', 'è': 'e_grave', 'ê': 'e_circ',
             'à': 'a_grave', 'â': 'a_circ', 'ô': 'o_circ',
             'î': 'i_circ', 'ï': 'i_trema', 'û': 'u_circ', 'ù': 'u_grave'}

DIGIT_WORD = {'zero': 0, 'un': 1, 'deux': 2, 'trois': 3, 'quatre': 4,
              'cinq': 5, 'six': 6, 'sept': 7, 'huit': 8, 'neuf': 9}

# French phoneme for each letter's SOUND, in eSpeak/IPA notation.
# Piper accepts these inline as [[ ... ]], which is the only reliable way to
# get a bare consonant instead of the letter name. Marked `verify: true`
# throughout — an isolated plosive is hard for any synthesiser and a French
# speaker has to confirm each one by ear before it ships.
LETTER_SOUND = {
    'a': 'a', 'e': 'ə', 'i': 'i', 'o': 'o', 'u': 'y', 'y': 'i',
    'é': 'e', 'è': 'ɛ', 'ê': 'ɛ',
    'b': 'b', 'c': 'k', 'd': 'd', 'f': 'f', 'g': 'ɡ', 'h': '',
    'j': 'ʒ', 'k': 'k', 'l': 'l', 'm': 'm', 'n': 'n', 'p': 'p',
    'q': 'k', 'r': 'ʁ', 's': 's', 't': 't', 'v': 'v', 'w': 'w',
    'x': 'ks', 'z': 'z',
}


def slug(text):
    """NFD, strip diacritics, lowercase, non-alphanumerics to '_'."""
    s = unicodedata.normalize('NFD', text)
    s = ''.join(c for c in s if unicodedata.category(c) != 'Mn')
    s = s.lower()
    s = re.sub(r'[^a-z0-9]+', '_', s).strip('_')
    return s or 'x'


def letter_key(ch):
    """'t' -> 't'   'é' -> 'e_acute'.  Without this, e/é/è/ê collide."""
    ch = ch.strip().lower()
    if ch in VOWEL_KEY:
        return VOWEL_KEY[ch]
    return slug(ch)


def vowel_suffix(ch):
    return VOWEL_KEY.get(ch, slug(ch))


def syllable_id(text):
    """'té' -> syll.te_acute   'ti' -> syll.ti"""
    t = text.strip().lower()
    if not t:
        return None
    last = t[-1]
    if last in VOWEL_KEY:
        return f'syll.{slug(t[:-1])}{VOWEL_KEY[last]}'
    return f'syll.{slug(t)}'


def norm(s):
    """Speech.norm() in app_state.dart."""
    return re.sub(r'\s+', ' ', s.strip()).lower()


def walk_content():
    rows = []

    def visit(node, fname):
        if isinstance(node, dict):
            if 'key' in node and 'fallbackText' in node:
                rows.append({'key': node['key'], 'text': node['fallbackText'],
                             'file': fname})
            for v in node.values():
                visit(v, fname)
        elif isinstance(node, list):
            for v in node:
                visit(v, fname)

    for dirpath, _, names in os.walk(CONTENT):
        for n in sorted(names):
            if n.endswith('.json'):
                p = os.path.join(dirpath, n)
                try:
                    with open(p, encoding='utf-8') as f:
                        visit(json.load(f), n)
                except (OSError, json.JSONDecodeError):
                    pass
    return rows


def map_content_key(key, text):
    """Translate one `fr:kind:slug-hash` key into Pack 4 IDs.

    Returns a list, because a grapheme is TWO clips: the name and the sound.
    """
    parts = key.split(':')
    if len(parts) < 3:
        return []
    kind, tail = parts[1], parts[2]
    t = text.strip()

    if kind == 'grapheme':
        ch = t.lower()
        out = [{'id': f'letter.{letter_key(ch)}.name', 'text': t, 'kind': 'letter-name',
                'note': 'the letter as it is NAMED'}]
        ph = LETTER_SOUND.get(ch)
        if ph is not None:
            out.append({
                'id': f'letter.{letter_key(ch)}.sound',
                'text': t,
                'kind': 'letter-sound',
                'phonemes': ph,
                'verify': True,
                'note': 'the SOUND alone, never the name. Generated from the '
                        'phoneme, not from the text.',
            })
        elif len(ch) > 1:
            # multigraphs like 'an', 'ou', 'ch' — a grapheme, not a letter
            out = [{'id': f'letter.{letter_key(ch)}.sound', 'text': t,
                    'kind': 'grapheme-sound', 'verify': True,
                    'note': 'multigraph; phoneme needs a French speaker'}]
        return out

    if kind == 'syllable':
        sid = syllable_id(t)
        if not sid:
            return []
        return [
            {'id': sid, 'text': t, 'kind': 'syllable'},
            {'id': sid.replace('syll.', 'blend.', 1),
             'text': ' … '.join(list(t)) + f' … {t}',
             'kind': 'fusion',
             'note': 'the two sounds separated, then fused — the arrow the '
                     'book draws, performed aloud'},
        ]

    if kind == 'word':
        return [{'id': f'word.{slug(t)}', 'text': t, 'kind': 'word'}]

    if kind == 'phrase':
        return [{'id': f'word.{slug(t)}', 'text': t, 'kind': 'phrase'}]

    if kind == 'number':
        n = DIGIT_WORD.get(slug(tail))
        if n is None:
            n = DIGIT_WORD.get(slug(t))
        return [{'id': f'digit.{n}.name' if n is not None else f'word.{slug(t)}',
                 'text': t, 'kind': 'digit'}]

    m = re.fullmatch(r'lesson-(\d+)', kind)
    if m:
        lesson = f'L{int(m.group(1)):02d}'
        idx = re.search(r'item-(\d+)', tail)
        n = int(idx.group(1)) if idx else 1
        return [{'id': f'sent.{lesson}.{n:02d}', 'text': t, 'kind': 'sentence',
                 'lesson': lesson}]

    return []


def main():
    plan = {}          # id -> row
    sources = Counter()

    def add(row, source):
        rid = row['id']
        if rid in plan:
            plan[rid].setdefault('sources', []).append(source)
            # keep the richer text (a fusion/phoneme row must not be clobbered)
            if not plan[rid].get('text') and row.get('text'):
                plan[rid]['text'] = row['text']
            return
        row['sources'] = [source]
        plan[rid] = row
        sources[source] += 1

    # 1. Pack 4 — the authored spec. Highest authority on IDs.
    try:
        with open(PACK4, encoding='utf-8') as f:
            for r in json.load(f).get('rows', []):
                add({'id': r['id'], 'text': r.get('text') or '',
                     'kind': r.get('kind') or '', 'session': r.get('session')},
                    'pack4')
    except (OSError, json.JSONDecodeError):
        print('  ! Pack 4 recording script not readable; continuing without it')

    # 2. The app's own lesson content, translated into the same grammar.
    for e in walk_content():
        for row in map_content_key(e['key'], e['text']):
            row.setdefault('origin', e['key'])
            add(row, 'content')

    # 3. Prototype utterances not covered by either of the above.
    #    These are mostly interface sentences; they keep a ui.* ID.
    try:
        with open(UTTER, encoding='utf-8') as f:
            known = {norm(r.get('text') or '') for r in plan.values()}
            for u in json.load(f):
                t = (u.get('text') or '').strip()
                if not t or norm(t) in known:
                    continue
                where = (u.get('where') or '').strip()
                m = re.fullmatch(r'Leçon\s+(\d+)', where)
                if m:
                    rid = f'sent.L{int(m.group(1)):02d}.{slug(t)[:28]}'
                else:
                    rid = f'ui.app.{slug(t)[:40]}'
                add({'id': rid, 'text': t, 'kind': 'interface',
                     'where': where}, 'prototype')
                known.add(norm(t))
    except (OSError, json.JSONDecodeError):
        print('  ! utterances.json not readable; continuing without it')

    rows = [plan[k] for k in sorted(plan)]

    bad = [r['id'] for r in rows if not GRAMMAR.match(r['id'])]
    text_only = [r for r in rows if not r.get('text') and not r.get('phonemes')]
    needs_check = [r for r in rows if r.get('verify')]

    out = {
        'generatedBy': 'bonbon_app/tool/audio_ids.py',
        'total': len(rows),
        'bySource': dict(sources),
        'byKind': dict(Counter(r.get('kind') or '?' for r in rows)),
        'malformedIds': bad,
        'needsFrenchReview': len(needs_check),
        'rows': rows,
    }
    with open(OUT_JSON, 'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, indent=2)
        f.write('\n')

    with open(OUT_CSV, 'w', newline='', encoding='utf-8-sig') as f:
        w = csv.writer(f)
        w.writerow(['id', 'kind', 'text', 'phonemes', 'verify', 'sources'])
        for r in rows:
            w.writerow([r['id'], r.get('kind', ''), r.get('text', ''),
                        r.get('phonemes', ''), 'yes' if r.get('verify') else '',
                        ' '.join(r.get('sources', []))])

    print(f'canonical clips      {len(rows):>5}')
    for k, v in sources.most_common():
        print(f'  from {k:<12} {v:>5}')
    print()
    for k, v in Counter(r.get("kind") or "?" for r in rows).most_common(12):
        print(f'  {k:<16} {v:>5}')
    print()
    print(f'malformed IDs        {len(bad):>5}' + (f'  {bad[:5]}' if bad else '  (none)'))
    print(f'need French review   {len(needs_check):>5}   '
          f'(letter sounds and multigraphs)')
    print(f'no text, no phoneme  {len(text_only):>5}')
    print(f'\nwrote {os.path.relpath(OUT_JSON, ROOT)}')
    print(f'      {os.path.relpath(OUT_CSV, ROOT)}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
