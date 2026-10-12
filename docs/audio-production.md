# Audio Production — Batonga *Lire*

**Owner:** Dev D (`dev/data-audio`) · **Status:** Sprint 1 draft, §1 pending team ratification
**Governs:** `content/audio/**`, `tools/audio-pipeline/**`, and everything handed to the studio.
**Plan references:** BUILD_PLAN_v2 §C.1, §C.5, §E.4, §G.1 (`AudioAsset`), §H.6, §P.5, §W, §X.3.

This document is two things at once. Sections 1–3 are the **engineering contract** — the ID
grammar is the seam between Dev A's content and this stream, and it is enforced in CI, not by
agreement. Sections 4–9 are the **studio brief** — the document that goes to the voice talent
and the engineer, and that they work from without reading anything else.

---

## 0. Why this document exists before the code does

Audio is the longest-lead item on the schedule (risk **R-03**). Every other stream can be
written, reviewed and demoed without a single clip existing, because `audioService.has()`
hides the speaker icon for anything unrecorded (§H.6). Nothing is symmetric about that: the
studio cannot start until this document is finished, and session 1 is scheduled for **week 4**.

So this is written in Sprint 1, before the schema, before the service, before CI — because it
is the only Dev D deliverable that other people's calendars depend on.

---

## 1. The audio ID grammar — the A↔D seam

**The rule that makes the seam work: an ID is *derived* from content, never hand-assigned.**
Nobody types an ID into the manifest. The generator scans `content/` and `src/i18n/` and emits
every ID it finds. If the two streams ever have to hold a conversation to agree on an ID, the
seam has failed.

### 1.1 The regex

```
^(letter|syll|blend|word|sent|text|digit|prompt|fb|cue|ui|vo|q)\.[a-z0-9_.-]+$
```

Canonical copy: `content/audio/script/audio-id-grammar.json`. **That file is the authority; this
section is a readable restatement of it.** CI validates against the JSON, not against this prose.

### 1.2 Namespaces

| Namespace | Shape | Example | Source |
|---|---|---|---|
| `letter` | `letter.{glyph}.{name\|sound}` | `letter.t.name`, `letter.t.sound` | corpus — alphabet |
| `syll` | `syll.{consonant}{vowelkey}` | `syll.ta`, `syll.te_acute` | corpus — `syllabary.json` |
| `blend` | `blend.{consonant}{vowelkey}` | `blend.ta` | corpus — `syllabary.json` |
| `word` | `word.{ascii-slug}` | `word.fonio`, `word.tete` | A's lesson JSON |
| `sent` | `sent.{lessonId}.{nn}` | `sent.L08.01` | A's lesson JSON |
| `text` | `text.{textId}.{whole\|snn}` | `text.T27.whole`, `text.T27.s04` | A's lesson JSON |
| `digit` | `digit.{n}.name` | `digit.7.name` | corpus — `digits.json` |
| `prompt` | `prompt.{activityType}.{variant}` | `prompt.tap-identify.letter` | B's activity catalogue |
| `fb` | `fb.{tier}.{nn}` | `fb.micro.03` | C's encouragement bank |
| `cue` | `cue.{name}` | `cue.start` | B's trace rubric |
| `ui` | `ui.{namespace}.{key}` | `ui.common.listen` | C's `ui-strings.fr.json` |
| `vo` | `vo.{flow}.{nn}` | `vo.onb.01` | C's onboarding script |
| `q` | `q.{textId}.q{n}` | `q.T27.q1` | comprehension (Batonga, R-16) |

### 1.3 Transliteration

IDs are lowercase ASCII. **Diacritics are transliterated, never embedded** — an accented
character in a filename is a cross-platform hazard and a Git-on-macOS normalisation hazard.

Vowel keys, for `syll` and `blend`:

| Vowel | Key | | Vowel | Key |
|---|---|---|---|---|
| `a e i o u` | unchanged | | `é` | `e_acute` |
| | | | `è` | `e_grave` |
| | | | `ê` | `e_circ` |

Word slug: `NFD → strip combining marks → lowercase → non-alphanumerics to '_'`.
So *tête* → `word.tete`, *rivière* → `word.riviere`.

### 1.4 CI enforcement

| Condition | CI result |
|---|---|
| An ID in the manifest fails the regex | **fail** |
| Content references an ID the manifest does not hold | **fail** |
| The manifest holds an ID nothing references | **warn** |
| A clip file's basename ≠ its ID | **fail** |
| A committed clip fails the technical spec (§4) | **fail** |

Orphans are cheap; gaps are not. A warn-level orphan rule is deliberate — `blend.*` clips are
triggered by behaviour (a correct `syllable-build`, a long-press) rather than referenced by a
content field, so all 131 of them will read as orphans until B's activity layer is scanned too.

---

## 2. ⚠ Two defects in the generated script that must be resolved before session 1

Both were found by running the shipped `recording-script.json` against the shipped
`audio-id-grammar.json`. Reproduce with `node tools/audio-pipeline/verify-ids.mjs`.

**Neither is Dev D's call alone** — both change files owned by other streams. Both are cheap now
and expensive after the studio has recorded.

### 2.1 45 of 590 generated IDs fail the grammar regex

The regex permits `[a-z0-9_.-]` only. The `ui.*` and `cue.*` IDs are derived from Dev C's and
Dev B's **camelCase** JSON keys, so they carry capitals:

```
ui.common.listenAll        ui.progress.lettersKnown     cue.startWrong
ui.lesson.tapToHear        ui.activity.skipConfirm      cue.directionWrong
ui.writing.watchFirst      ui.facilitator.addLearner    cue.missedCheckpoint
… 40 in the ui namespace, 5 in cue
```

Implementing D12 as specified ("malformed ID fails CI") makes CI red against the data the plan
itself ships. Three ways out, in the order I'd rank them:

1. **Slugify in the generator.** `listenAll` → `listen_all`. Keeps the regex, keeps C's keys
   idiomatic for i18n, and the transformation is mechanical. Cost: the slug rule now has a
   camelCase clause, and `ui.a.bC` and `ui.a.b_c` would collide (they don't today — checked).
2. **Widen the regex** to `[A-Za-z0-9_.-]`. One-character change, zero other cost — but it
   weakens the "lowercase ASCII" rule that exists to protect *filenames*, and these IDs become
   filenames (§5). On a case-insensitive macOS volume `ui.common.listenall` and
   `ui.common.listenAll` are the same file. I do not recommend this.
3. **Require lower_snake keys from C.** Cleanest IDs, but it is a rename across
   `ui-strings.fr.json`, `icon-lexicon.json` and every `t()` call site, and it is Dev C's file.

**My recommendation: option 1.** It is a change to *my* generator, touches nobody else's files,
and preserves the filename-safety property the rule was written for.
**→ needs the team's decision, ideally at the day-1 sync (§X.5 puts this on day 1 for a reason).**

### 2.2 `letter.e.*` collides four ways — the studio would deliver four takes into two filenames

The `syll` and `blend` namespaces have a vowel-key scheme. The `letter` namespace does not. So:

| Recording script row | Text to record | Generated ID |
|---|---|---|
| 8 | « e » | `letter.e.name` |
| 10 | « e accent circonflexe » | `letter.e.name` ← |
| 12 | « e accent aigu » | `letter.e.name` ← |
| 14 | « e accent grave » | `letter.e.name` ← |

and identically for `letter.e.sound`, where the four clips are four **genuinely different
sounds**. Under §5's rule that a file is named exactly for its ID, four distinct takes overwrite
each other and the app plays whichever survived. This is a silent failure: the file exists,
`has()` returns true, and the learner is taught the wrong sound.

**Fix:** apply the existing vowel-key scheme to the `letter` namespace —
`letter.e_acute.name`, `letter.e_grave.sound`, `letter.e_circ.name`. No new mechanism, no regex
change; it is the rule that already governs `syll`.
**→ needs Dev A's agreement,** because A's lesson JSON references these IDs from `letter-forms`
and `keyword-illustration` blocks. Worth doing before L01–L07 are transcribed, since those are
exactly the vowel lessons.

### 2.3 Corrected counts

The plan quotes 590 derivable clips. After de-duplication the true figure is **584 distinct IDs**:

| | Rows | Distinct | Session |
|---|---|---|---|
| Session 1 — letters, syllables, fusions, digits | 327 | **321** | week 4 |
| Session 2 — interface, VO, encouragement, prompts | 241 | 241 | week 5 |
| Session 3 — trace cues (the generated part) | 22 | 22 | week 7 |
| **Total derivable today** | 590 | **584** | |

Pending Dev A's transcription: ≈ 420 words, ≈ 190 sentences, 28 whole texts + ≈ 250 segments,
≈ 70 comprehension questions. **Grand total ≈ 1 542.** Studio time is billed by the hour and by
the take, so quote from 584, not 590.

---

## 3. The recording script is generated, never hand-maintained

```
content/audio/script/recording-script.json     machine-readable, the app's input
content/audio/script/recording-script.csv      what the studio actually works from
```

Regenerate after **any** change to content or interface strings:

```bash
node tools/audio-pipeline/gen-script.mjs        # (Sprint 1: python3 gen_audio.py)
```

CI fails if the committed script differs from what the generator produces. Nobody edits the CSV
by hand — a hand-edit is discovered as a CI failure, not as a wrong clip in the field.

**CSV columns:** `session, id, text, kind, direction, note, prise_ok`.
`prise_ok` is left blank for the studio to tick. It is the only column they write.

The CSV is UTF-8 **with BOM** so that Excel on a Windows machine in a studio opens *tête*
correctly rather than as *tÃªte*. Do not "fix" this.

---

## 4. Technical specification

### 4.1 Capture

| | |
|---|---|
| Channels | **Mono.** Not a stereo file with identical channels — that doubles the bundle. |
| Sample rate | 48 kHz |
| Bit depth | 24-bit |
| Format | WAV, uncompressed |
| Room | Treated or heavily damped. Noise floor **≤ −60 dBFS**. |
| Mic | Large-diaphragm condenser, pop filter, consistent distance across all five sessions |

**The same microphone, room and distance for all five sessions.** The learner hears
`letter.t.sound` (session 1) and `word.tete` (session 3) two seconds apart; a timbre change
between them is audible and reads as a fault in the app.

### 4.2 Delivery to the repository

| | |
|---|---|
| Sample rate | 44.1 kHz |
| Codec | **AAC-LC, 64 kbps, mono**, `.m4a` container |
| Loudness | **−16 LUFS integrated** |
| True peak | **≤ −1.0 dBTP** |
| Head / tail silence | 120 ms / 200 ms, applied **in the edit, not in the take** |

Deliver the 24-bit WAV masters as well. They are archived outside the repo (they are far too
large for Git, LFS included); the `.m4a` is what ships. If a future edition needs different
processing, we re-encode from masters instead of re-booking a studio.

### 4.3 Why these numbers

−16 LUFS is the loudness a phone loudspeaker in a noisy room needs without the limiter
pumping; −1 dBTP leaves headroom for the AAC encoder's inter-sample peaks. 64 kbps mono AAC on
speech is transparent enough at phone-speaker bandwidth and holds ~1 550 clips inside the
§C.5 audio budget (≈ 20–26 MB) with the §C.1 install ceiling of 60 MB intact. Verified against
the real bundle at task **D19**.

---

## 5. Naming and delivery structure

**A clip's filename is exactly its ID.** `letter.t.sound` → `letter.t.sound.m4a`. No prefixes,
no take numbers, no session folders, no spaces, no capitals.

```
content/audio/
├── audio-manifest.json         ◆ generated — never hand-edited
├── clips/                      ◆ git-lfs
│   ├── blend.ta.m4a
│   ├── letter.t.sound.m4a
│   └── …
└── script/                     ◆ Pack 4 — the generated studio inputs
```

Studio delivers one flat folder of WAVs named for their IDs, plus the completed CSV. The ingest
pipeline (§8) does everything else.

---

## 6. Voice direction

### 6.1 Casting

**An adult francophone woman from Benin.** The learner should recognise a voice that speaks the
way the women around her speak. A neutral hexagonal French would teach a register nobody in her
market uses and would put distance between the page and the street.

**Tone: *accompagnatrice*, not *institutrice*.** Adult to adult. Avoid the storytelling lilt,
advertising emphasis, and the habit of accelerating into the end of a phrase.

A **second voice** is required for the four dialogue texts (Lessons 30, 35, 38, 42). Book it into
the same session — session 4, week 9.

> **Open — Batonga's call, not ours:** tutoiement or vouvoiement in the spoken interface
> (Appendix Q11). This is a cultural judgement. It must be answered **before session 2 in
> week 5**, because it is baked into 241 interface clips and re-recording them is a full session.

### 6.2 Method

- **Three takes of everything.** Best selected in the edit. Never keep a merely acceptable take
  of a clip that will be heard several hundred times.
- **Record by type, not by lesson.** All the letters, then all the syllables, then all the
  fusions. The register stays even and the performer stays in the gesture.
- **Bracketed templates get one take per value.** « Touche la lettre {lettre} » is recorded 26
  times. Concatenating a stem and a letter is audible, and the learner is a person for whom the
  audio *is* the interface.

### 6.3 The two-clips-per-letter rule

**`letter.t.name` is « té ». `letter.t.sound` is the sound `t` alone — not « teu ».**

This is the single most common error in phonics audio and it teaches the wrong thing outright.
A syllabaire fuses **sounds**, not names. A learner who has learned that the letter says « teu »
will read `ta` as « teu-a », and the whole method fails at Lesson 8.

**A person trained in literacy work must be in the room** checking each consonant live. Budget
two hours for it. It is a two-hour cost against a mistake discovered in the field test that
would require re-recording every consonant.

### 6.4 The fusion clips

For every syllable there is a second recording. `blend.ta` is « t … a … ta » — the two sounds
separated, then the syllable fused.

**This is the audio form of the arrow the book draws.** The syllable tree on page 20 is a picture
of fusion; on paper a facilitator performs it aloud. `blend.ta` is that performance, recorded
once.

**Mark the pause with a metronome at 500 ms** so that all 131 fusion clips are identical. The
regularity is not fussiness — it is what makes the pattern learnable.

---

## 7. Session plan

Five waves, in the order the code needs them. Nothing is blocked between sessions, because
`has()` hides what does not exist yet.

| # | Week | Content | Distinct clips | Studio | Unblocks |
|---|---|---|---|---|---|
| 1 | 4 | letters (name + sound), syllables, fusions, digits | **321** | 6–8 h | Units 1 and 2 become audible |
| 2 | 5 | every UI string, onboarding VO, encouragement, prompts | **241** | 4–5 h | the app becomes usable by a non-reader |
| 3 | 7 | the 56 word lists, trace cues | ≈ 440 | 5–6 h | `listen-choose` and `missing-letter` on real words |
| 4 | 9 | sentences, 28 texts whole + per-sentence, 4 dialogues | ≈ 470 | 7–9 h | Unit 3 in full |
| 5 | 12 | field-test fixes, Batonga-approved comprehension questions | ≈ 120 | 2–3 h | **always plan this session** |

**Budget:** 24–31 studio hours, ≈ 1.5× that in editing, plus a **10 % re-record reserve**.

### 7.1 Contingency

If the schedule slips, **ship v1 with sessions 1 and 2 only** — letters, syllables, digits,
interface. That is exactly the core of a syllabaire, so the app stays pedagogically coherent,
and words, sentences and texts arrive later by EAS Update without a store review.

Because `has()` hides the speaker icon for unrecorded clips, **the learner does not see a gap.
She sees a simpler app.**

---

## 8. Ingest pipeline

`tools/audio-pipeline/`. Runs on delivered WAVs; output is committed, input is archived.

```bash
# 1. validate what arrived before touching it
node tools/audio-pipeline/verify-delivery.mjs  ./delivery/session-01
#    → every filename matches the grammar; every ID is in the recording script;
#      every scripted ID for this session is present; no extras; no zero-length files

# 2. normalise + encode  (two-pass loudnorm; single-pass drifts on short clips)
ffmpeg -i in.wav -af loudnorm=I=-16:TP=-1.0:LRA=7:print_format=json -f null -
ffmpeg -i in.wav -af loudnorm=I=-16:TP=-1.0:LRA=7:measured_I=…:measured_TP=…:\
measured_LRA=…:measured_thresh=…:linear=true -ar 44100 -ac 1 \
       -c:a aac -b:a 64k content/audio/clips/<id>.m4a

# 3. measure what we produced, not what we asked for
node tools/audio-pipeline/verify-clips.mjs
#    → LUFS within ±0.5, true peak ≤ −1.0 dBTP, mono, 44.1 kHz, duration > 150 ms

# 4. regenerate the manifest and flip status
node tools/audio-pipeline/gen-manifest.mjs
```

**Two-pass `loudnorm` is not optional.** Single-pass on a 400 ms clip mis-measures badly, and a
letter sound that is 4 LU quieter than the syllable it fuses into is the kind of defect that
survives review and fails in the field.

Clips are stored with **git-lfs**. Confirm every developer has run `git lfs install` before the
first ingest — a clip committed without LFS is a 40 KB pointer-shaped hole in someone's clone.

---

## 9. Quality gate

Nothing is merged until all of these hold. This is §P.5 plus §X.3's additions.

- [ ] The ID matches the grammar regex, and the filename matches the ID exactly
- [ ] Mono, 44.1 kHz, AAC 64 kbps, −16 LUFS ±0.5, true peak ≤ −1.0 dBTP
- [ ] Manifest entry present with the correct `status`
- [ ] `audioService.has(id)` returns `true`
- [ ] **Consonant sounds verified blind by a third listener** — they hear the clip with no
      label and write down the letter. A wrong answer is a re-record, not a discussion.
- [ ] Fusion clips use the 500 ms metronome pause
- [ ] **Listened to on a phone loudspeaker, never on headphones.** That is how it will be heard:
      in a room with other people in it. Headphones hide exactly the faults that matter here —
      thin low end, mouth noise that the speaker turns into a click, and clips that are too
      quiet to survive ambient noise.

---

## 10. Manifest and the `status` lifecycle

`content/audio/audio-manifest.json` is generated (§3, §8). Each entry is an `AudioAsset`
(§G.1): `id`, `file`, `durationMs`, `speaker`, `recordedAt`, `status`.

```
missing  →  placeholder  →  recorded
```

| `status` | Meaning | `has()` |
|---|---|---|
| `missing` | The ID is derivable from content; no audio exists | **false** |
| `placeholder` | A stand-in exists (TTS or a scratch take) — dev builds only | **false** in release |
| `recorded` | A studio clip that passed §9 | **true** |

**`has()` is the whole degradation strategy** (§H.6). A component about to render a speaker icon
calls `has()` first; if it returns false the icon is not rendered. Not greyed out, not disabled —
**not rendered**. A disabled button asks a non-reader to interpret a state; an absent one asks
nothing. This is what lets A, B and C build every screen in weeks 1–8 while this stream is still
in the studio, and it is what makes the §7.1 contingency safe.

`placeholder` must resolve to **false** in release builds. A TTS clip of a Beninese French word
in a hexagonal French voice is worse than silence: it teaches a pronunciation the learner will
not hear anywhere else.

---

## 11. Open questions

| # | Question | Owner | Needed by |
|---|---|---|---|
| 1 | The 45 malformed `ui.*` / `cue.*` IDs — slugify, widen the regex, or rename C's keys? (§2.1) | team | day 1 |
| 2 | `letter.e.*` collision — adopt vowel keys in the `letter` namespace? (§2.2) | Dev A + D | before L01–L07 |
| 3 | Tutoiement or vouvoiement? (Appendix Q11) | **Batonga** | before session 2, week 5 |
| 4 | Voice talent booked, and a literacy specialist in the room for session 1 (R-03) | team | week 3 |
| 5 | Second voice for the four dialogue texts confirmed | team | week 8 |
| 6 | Studio's delivery format confirmed as 24-bit/48 kHz WAV masters + our encode, not their MP3 | Dev D | at booking |

---

*Sources: BUILD_PLAN_v2 §W (Pack 4) and `content/audio/script/*.json`, which are the machine-
readable authority for everything above. Where this document and those files disagree, the files
are right and this document has drifted — open an issue.*
