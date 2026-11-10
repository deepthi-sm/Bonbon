#!/usr/bin/env python3
"""Bonbon voice recordings: recording script and manifest.

The team records every sentence in a human voice; the clips are bundled
inside the app, so it needs no internet. Two steps:

1. Make the recording script (what to say, and the file name for each line):

     flutter test test/export_utterances_test.dart     # refresh the list of sentences
     python tool/audio.py script

   This writes tool/recording-script.csv (open in Excel/Sheets), in lesson order:
       lesson, file, text, recorded
   Record each line and save it under the name in "file", with any of these
   extensions: .mp3 .m4a .aac .wav .ogg (mono, 44.1 or 22 kHz is plenty).

2. Put the clips in assets/audio/ (all in that one folder, no subfolders), then:

     python tool/audio.py manifest

   This writes assets/audio/manifest.json, which the app reads at startup,
   and prints how many lines are still missing. Rebuild the app afterwards.

File names come from the sentence itself (accent-free slug + short code), so
they stay the same when lessons or phrases are added later. Standard library only.
"""
import csv
import hashlib
import json
import os
import re
import sys
import unicodedata

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
UTTERANCES = os.path.join(ROOT, 'tool', 'utterances.json')
SCRIPT = os.path.join(ROOT, 'tool', 'recording-script.csv')
AUDIO_DIR = os.path.join(ROOT, 'assets', 'audio')
MANIFEST = os.path.join(AUDIO_DIR, 'manifest.json')
EXTS = ('.mp3', '.m4a', '.aac', '.wav', '.ogg')


def norm(s):
    """Same key as Speech.norm in lib/state/app_state.dart."""
    return re.sub(r'\s+', ' ', s.strip()).lower()


def stem(text):
    """Stable, readable file name (without extension) for a sentence."""
    ascii_ = unicodedata.normalize('NFKD', text).encode('ascii', 'ignore').decode()
    slug = re.sub(r'[^a-z0-9]+', '-', ascii_.lower()).strip('-')[:40].strip('-') or 'clip'
    code = hashlib.md5(norm(text).encode('utf-8')).hexdigest()[:5]
    return f'{slug}_{code}'


def load_utterances():
    if not os.path.exists(UTTERANCES):
        sys.exit('Missing tool/utterances.json - run: flutter test test/export_utterances_test.dart')
    return json.load(open(UTTERANCES, encoding='utf-8'))


def recorded_files():
    if not os.path.isdir(AUDIO_DIR):
        return {}
    return {os.path.splitext(f)[0]: f for f in os.listdir(AUDIO_DIR) if f.lower().endswith(EXTS)}


def cmd_script():
    items = load_utterances()
    have = recorded_files()
    with open(SCRIPT, 'w', newline='', encoding='utf-8-sig') as f:  # BOM so Excel shows accents
        w = csv.writer(f)
        w.writerow(['lesson', 'file', 'text', 'recorded'])
        for it in items:
            st = stem(it['text'])
            w.writerow([it['where'], st, it['text'], 'yes' if st in have else ''])
    done = sum(1 for it in items if stem(it['text']) in have)
    print(f'{len(items)} lines -> {os.path.relpath(SCRIPT, ROOT)} ({done} already recorded)')


def cmd_manifest():
    items = load_utterances()
    have = recorded_files()
    manifest, missing = {}, []
    for it in items:
        st = stem(it['text'])
        if st in have:
            manifest[norm(it['text'])] = have[st]
        else:
            missing.append(it)
    os.makedirs(AUDIO_DIR, exist_ok=True)
    with open(MANIFEST, 'w', encoding='utf-8') as f:
        json.dump(manifest, f, ensure_ascii=False, indent=0, sort_keys=True)
    known = {stem(it['text']) for it in items}
    unused = sorted(s for s in have if s not in known)
    print(f'{len(manifest)} of {len(items)} lines recorded -> {os.path.relpath(MANIFEST, ROOT)}')
    if missing:
        by_lesson = {}
        for it in missing:
            by_lesson[it['where']] = by_lesson.get(it['where'], 0) + 1
        print('still missing: ' + ', '.join(f'{k} ({v})' for k, v in list(by_lesson.items())[:12])
              + (' ...' if len(by_lesson) > 12 else ''))
    if unused:
        print(f'{len(unused)} file(s) in assets/audio match no sentence (misnamed?): ' + ', '.join(unused[:10]))


if __name__ == '__main__':
    if len(sys.argv) != 2 or sys.argv[1] not in ('script', 'manifest'):
        sys.exit(__doc__)
    {'script': cmd_script, 'manifest': cmd_manifest}[sys.argv[1]]()
