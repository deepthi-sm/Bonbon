# Activity catalogue — Dev B (`dev/activities`)

Plan references: `BUILD_PLAN_v2.md` §J, §R.2, §U; specs in
`docs/batonga-addon-packs/batonga-addon-packs/02-exercices/`.

## Code layout (new, Dev B only)

| File | What |
|---|---|
| `bonbon_app/lib/activities/contract.dart` | `ActivityType`, `ActivitySpec`, `ActivityItem`, `Choice`, `ItemResult`, `ActivityResult` — pure Dart |
| `bonbon_app/lib/activities/seed.dart` | `fnv1a`, `itemSeed(lesson, type, index)`, `SeededRng` (same on VM and web) |
| `bonbon_app/lib/activities/repair_ladder.dart` | the four rungs, hint costs, spoken sentences, rung-2 narrowing |
| `bonbon_app/lib/activities/activity_host.dart` | `activityRegistry` (append-only, alphabetical) + `ActivityHost` |
| `bonbon_app/lib/activities/fixtures.dart` | one hand-made spec per MVP type |
| `bonbon_app/lib/activities/generators.dart` | seeded specs from a lesson; `specsAfter()` mirrors the switch in `buildSteps` |
| `bonbon_app/lib/activities/confusion.dart` | the confusion matrix's visual and auditory tables (copy of the JSON pack, checked by `confusion_test.dart`) |
| `bonbon_app/lib/activities/ledger.dart` | the decodability ledger: letters and graphemes met by each lesson (copy of the JSON pack, checked by `ledger_test.dart`) |
| `bonbon_app/lib/activities/choice_session.dart` | rules of tap-identify / listen-choose / syllable-build / missing-letter with the repair ladder — pure Dart |
| `bonbon_app/lib/activities/choice_activity.dart` | the screen for those four types |
| `bonbon_app/lib/activities/feedback.dart` | the feedback layer (B7): `Mark` (right, tried, model, faded, idle), its colour + icon, and `Marked`, which adds the motion — used by every activity |
| `bonbon_app/lib/activities/assessment.dart` | Bilan + checkpoints: blueprints, builders, result (B11) — pure Dart |
| `bonbon_app/lib/activities/assessment_host.dart` | the screen that plays one, never a gate |
| `bonbon_app/lib/activities/comprehension.dart` | comprehension system (B13): texts, question shape, validator, export — pure Dart |
| `docs/textes-a-questionner.md`, `docs/comprehension/questions.json`, `docs/comprehension-signoff.md` | the export for Batonga, their questions file, the sign-off table |
| `bonbon_app/lib/activities/placement.dart` | the placement ladder (B12) — pure Dart |
| `bonbon_app/lib/activities/placement_host.dart` | its screen: offer, ladder, « Tu peux commencer ici » |
| `bonbon_app/lib/activities/trace_session.dart` | rules of trace: attempts, cues, never blocked — pure Dart |
| `bonbon_app/lib/activities/trace_pad.dart` | the tracing canvas: with stroke data, the glyph's strokes, start dots and checkpoints; without, the prototype's font ghost |
| `bonbon_app/lib/activities/glyph_spec.dart` | `GlyphSpec` (plan §H.7), loaded from `assets/images/glyphs/glyph-specs.json` once Dev A adds it |
| `bonbon_app/lib/activities/trace_rubric.dart` | the rubric read at runtime from `assets/content/trace-rubric.json` (B14) |
| `bonbon_app/lib/activities/stroke_score.dart` | stroke-path scoring and its cue (B6, B15) — pure logic |
| `bonbon_app/lib/activities/trace_activity.dart` | the screen for trace |
| `bonbon_app/lib/activities/gallery_main.dart` | dev gallery: `flutter run -t lib/activities/gallery_main.dart -d chrome` |
| `bonbon_app/test/activity_*_test.dart`, `choice_session_test.dart` | tests |

The existing prototype (`lib/screens/activities.dart`, `atelier.dart`, `trace_score.dart`) is
unchanged. Switching the lesson player over is a few lines in `buildSteps` /
`_LessonPlayerState._body` (Dev A's file), to agree first:

```dart
// buildSteps: instead of the switch on Activity.recognise / Activity.listenChoose
for (final spec in specsAfter(s.kind, s.blocks, lesson, repo)) out.add(/* a step holding spec */);
// _body: instead of ActivityView
ActivityHost(spec: spec, onComplete: (r) => ..._correct += r.firstTryCount..., onSkip: (_) => _go(_i + 1))
```

## Types

| Type | Pass | Partial credit | Status |
|---|---|---|---|
| `tap-identify` | 0.80 | yes | **built**: letter lessons with at least one other letter taught (not L01); target among taught letters; repair ladder |
| `listen-choose` | 0.75 | no | **built**: syllables, words, graphemes, digits; repair ladder |
| `syllable-build` | 0.60 | yes | **built**: L08–L24; drag or tap a vowel next to the consonant; success plays the recorded blend « t … a … ta »; a wrong vowel first plays the syllable it built; repair ladder |
| `missing-letter` | 0.70 | no | **built**: L03–L24 (lessons whose word list has a word with the focus letter, once 3 letters are taught); distractors from the confusion matrix, then taught letters; a wrong letter plays the wrong word when it is recorded, then the right one; repair ladder |
| `trace` | 0.55 | yes | **built**: vowel, consonant and digit lessons, the single glyphs of the writing practice (print, and cursive where the book asks). With a glyph's stroke data: the rubric's five measures (start point, checkpoints in order, direction, deviation, stroke count) and the matching spoken cue; without it, the prototype's coverage scoring. 2★ or more finishes the letter; after 3 low attempts the model draws itself and she moves on |

### Tiers (generators.json difficulty ladders, task B9)

`specsFor(lesson, repo, tier: 1..3)`. Which tier a learner gets is for the progress side
(Dev D) to decide; the gallery has a tier switch.

| Type | Tier 1 | Tier 2 | Tier 3 |
|---|---|---|---|
| tap-identify | 6 cells, target ×2, random taught letters | 9 cells, ×3, visual neighbours first (b among d p) | 12 cells, ×3, visual neighbours, print and cursive mixed in one grid |
| listen-choose | 3 options, random | 4 options, sound-alikes first (« te » among « té tê ») | words only: the syllable drill has none |
| syllable-build | 4 rounds, 4 tiles, written model | 5 rounds, 6 tiles, sound-alike vowels first, no model | 6 rounds, 8 tiles, instruction spoken only |
| missing-letter | 3 candidates, focus letter, word shown first | 4 candidates, word not shown first | 4 candidates, blank on any letter she has met |
| trace | ghost, tolerance ×1.4 | ghost, ×1.0 | no ghost (free), ×0.8 |

Distractors come only from the decodability ledger (`ledger.dart`, a copy of
`01-corpus/decodability.json` checked by `ledger_test.dart`) or from the lesson's own
syllables and words. A test checks it for every lesson × tier × type. Two items in a row
never share a distractor set when another set exists.

Item credit: with partial credit, `1 − hintCost` of the highest repair rung reached; without
it, 1 only for a first-try answer. trace instead counts its measured quality (stars / 3).
An item answered by the app (rung 4, or trace's third low attempt) scores 0 and its target
goes to review. A result never blocks the next lesson.

Every activity shows « Passer » beside its progress bar (plan §J.3 rule 4, `allowSkip`); it
calls `onSkip(SkipReason.user)`. `test/activity_screens_test.dart` opens every screen on a
phone-sized surface and plays it through — taps, the drag, a trace, skips, a Bilan, a
checkpoint, the placement test and the gallery.

## Bilan and checkpoints (plan §U.5, task B11)

`assessment.dart` (pure Dart) + `assessment_host.dart` (screen). Blueprints copied from
`bilan-blueprints.json` / `checkpoints.json`, checked by `assessment_test.dart`.

- `bilanFor(lesson, repo)`: the archetype's mix (vowel 2 tap + 1 listen + 1 trace;
  consonant 2 listen + 2 syllable-build + 1 missing-letter; grapheme 2 listen + 2
  missing-letter + 1 comprehension; numeral 1 tap + 2 listen + 1 trace), drawn at tier 2
  with a fresh seed, only items on what this lesson introduces (its ledger additions).
  A part with fewer items shortens the Bilan; L43 and L47 introduce nothing new, so no Bilan.
- `checkpointAfter(lesson, repo)`: CP1 after L07, CP2 after L24, CP3a–d after L32/40/48/56,
  CP4 after N9. Each part spreads its items over every lesson covered.
- `AssessmentResult`: score over every planned item (a skipped part counts 0). ≥ 0.7 →
  « Bien lu » or the checkpoint's celebration; below, the weak targets go to review and
  « Revoir maintenant » is offered beside « Continuer ». It never blocks anything.
- For Dev A: the prototype's `BilanStep` can show `AssessmentHost(assessment: bilanFor(...))`;
  for Dev D: `AssessmentResult.toJson()` and `reviewTargets`.

Also added for these: tap-identify on digits (hear « trois », touch every 3) and
missing-letter on graphemes (« dem_ » = ain), blanking a grapheme only where it stands on its
own (never « in » inside « pain », never « oi » inside « noix »).

## Placement test (plan §U.5, task B12)

`placement.dart` (pure Dart) + `placement_host.dart` (screen), from `placement-test.json`
(checked by `placement_test.dart`). Three listening rungs — vowels, syllables, graphemes —
4 items each, ≥ 3/4 to go on; a rung stops as soon as its outcome is known, so at most
12 items. A miss starts her at L01, L08 or L15; passing all three at L25.

The three guardrails:
- **Fully spoken**: the offer, every item, the result and the lesson name are recorded
  (the team's onboarding lines); « é » alone is not, so rung 1 asks the other vowels.
- **No score, no level**: answers show no judgement (a neutral teal « got it »);
  the end says « Tu peux commencer ici. » and the lesson, nothing else.
  `PlacementResult.toJson()` holds only `startAt`.
- **Never locks**: « Commencer au début » is on every screen; leaving gives L01 with no
  word about the test. For Dev D: `openBefore(startAt, repo)` lists the lessons to mark
  `available`, never `completed`.
- For Dev A: `PlacementHost(onPlaced: ...)` is onboarding step 5.

## Comprehension (plan §U.6, task B13)

The system ships, the questions are Batonga's. `comprehension.dart` (pure Dart):

- `readingTexts(repo)`: the book's texts with ids from the audio grammar — `T27`, segments
  `T27.s01`… (a dialogue's turns are segments of their own).
- `validateComprehension(sets, repo)`: every hard rule of comprehension.json — kinds and
  their order, ≤ 3 per text, answer modes by lesson, option counts, phrase-pick options
  taken from the same text, a replay segment for every scored question, `audioId` =
  `q.<id>`, no question about moral/author/title, and **decodability**: a word passes if the
  book has already shown it by that lesson, otherwise every grapheme must be in the ledger.
  Findings are `error` (fails the test) or `pending` (not recorded, not signed off, a picture
  to draw — the list for Dev A's illustration backlog).
- `exportForBatonga(repo)` → `docs/textes-a-questionner.md` (workflow step 1): every text,
  its segment ids, the modes its lesson allows, and the JSON shape to fill. A test fails if
  it is out of date; `BONBON_EXPORT=1 flutter test test/comprehension_test.dart` regenerates it.
- Batonga's questions go in `docs/comprehension/questions.json` (empty for now); the test
  is the CI gate. Sign-offs in `docs/comprehension-signoff.md`.

## Feedback (plan §J.3, task B7)

Every judgement is shown by `Marked` (feedback.dart) and spoken by the session's `say`, at
the same moment:

| Mark | Colour | Icon | Motion | Voice (e.g.) |
|---|---|---|---|---|
| right | green | check | small pop | praise, then the item / blend |
| tried | grey (never red) | ear | gentle nudge | the wrong word built, then the repair rung |
| model | gold | pointing hand | slow pulse | « … c'est : ta. Écoute : ta. » |
| faded | see-through | — | fade | (rung 2) |

There is no sound effect file, so the sound is the voice — no buzzer, ever. With the phone's
"reduce motion" setting, nothing moves; the icon and the voice still carry the judgement.

## For Dev D (progress)

`ActivityResult.toJson()` is the record to store. `firstTryCount` matches what
`AppState.completeLesson(correct:)` counts today; `reviewTargets` feeds the review queue
(strength 0.15).

## Open points

- **Decided for B9: taught letters only.** The prototype borrowed `earlyShapes`
  (a o u e i é y) in the first lessons; plan §U.2 and the ledger forbid it, and B9's test
  can't pass with it. So L01 (only i taught) has no tap-identify and no missing-letter, and
  L02 no missing-letter. To revisit with the team if the first lessons feel too thin.
- Tier 3 interpretations: syllable-build's « audioOnly » is taken as the instruction
  spoken, not written; listen-choose's « targetUnit word » as words only.
- The matrix has no auditory neighbours for digits, so digit listening is random at every tier.

- New spoken sentences (`RepairLadder.sentences`) need adding to the recording script.
- syllable-build reuses the recorded prompt « Écoute et touche la syllabe ». A dedicated
  « Écoute et construis la syllabe » would read better once recorded.
- In a lesson with two syllable drills (e.g. L08), listen-choose follows the first and
  syllable-build the last, so neither plays twice. Word lists work the same way with
  missing-letter.
- missing-letter's instruction « Quelle lettre manque ? » (ui-strings.fr.json) is **not
  recorded yet**; until it is, the activity speaks only the word.
- Only about 4% of the wrong words missing-letter can build are recorded (« tu » → « nu »);
  the others play no wrong word, just the repair ladder. Recording them all is ~2 000 clips —
  to decide with whoever owns the audio.
- Every rung of the repair ladder now plays the right answer, rung 4 included
  (repair-ladder.json: « On joue TOUJOURS la bonne réponse »).
- Comprehension (grapheme Bilan, CP3a–d) has no questions until Batonga writes them
  (comprehension.json); those parts are left out, as the blueprint allows.
- Celebrations: CP1, CP2 and CP4 speak the team's recorded lines (worded slightly
  differently from checkpoints.json); CP3a–d's lines and « Bien lu » are written only, not
  recorded.
- Lessons whose target is a rule (« qu = k = c », « ph = f », « tion = sion ») have no
  sound listening: « qu », « ph », « th », « sion », « ç » alone are not recorded.
- missing-letter now also takes short phrases (« un poiss_ »), not only single words.
- The missing-letter prompt « Quelle lettre manque ? » is also used when a grapheme is
  missing; « Quel son manque ? » would fit better, once written and recorded.
- Which Bilan items count toward « weak »: below their activity type's own pass mark.
- Placement: « J'en connais déjà » (the button) is not recorded; the recorded offer
  sentence asks the same question aloud. Placement answers get no right/wrong feedback
  at all, by design — it is a probe, not a lesson.
- Placement shortens a rung by the 3/4 share when a probe has no clip (rounded up).
- Comprehension: the content has **26** reading texts, not the plan's 28 (L34 and L40 have
  none). The plan's own worked example (T27) breaks its rules: `image-3` before lesson 30,
  no replay segment on q2, and q3 uses « oi », « qu », « ch » not yet taught — to tell
  Batonga before they copy it.
- Comprehension questions are not in the app yet: shipping them needs an asset folder in
  `pubspec.yaml` (Dev A's file) and a player screen, behind `features.comprehension` (off).
- « Runs in CI »: the checks run in `flutter test`; the repo's CI only checks audio today.
  Adding a `flutter test` job to `.github/workflows` is for whoever owns CI.
- Not recorded: « Écoute bien. C'est l'un des deux. » and « Regarde, c'est : » (repair ladder
  rungs 2–3; a test lists them). Rung 1 uses the recorded « Pas encore. Écoute encore. » from
  the team's repair bank instead of the JSON's « Écoute encore. ». « On continue. Tu la
  reverras. » and the trace cues are recorded.
- trace: the rubric's « On réessaiera plus tard. » is not recorded, so after three attempts
  the app says the letter and « On continue. Tu la reverras. » (recorded) instead.
- trace: the canvas is a copy of the prototype's `TraceCanvas` (Dev A's `atelier.dart`,
  untouched), because that one does not report its result. Once agreed, the atelier can
  use `TracePad` and the copy goes.
- trace: words of the writing practice (tête, mil) are not traced yet, only single glyphs.
- A consonant lesson now has up to six activities (L08: tap-identify, listen-choose ×2,
  syllable-build, missing-letter, trace) — check with the team that this isn't too long.
- **Trace stroke data is Dev A's** (plan §H.7: « A produces the data; B owns all scoring »). Until
  `assets/images/glyphs/glyph-specs.json` exists, trace uses the prototype's coverage scoring;
  the stroke scoring, rubric and cues are built and tested on test-only glyphs (i, t, é).
- The rubric lives at `assets/content/trace-rubric.json` (a folder the app already bundles, so
  no `pubspec.yaml` change); a test keeps it identical to the JSON pack.
- With the rubric's weights as written, a perfect `i` without its dot scores 0.69 = 2★, which
  finishes the letter (and says « Il manque un trait » only below 2★). To tune with field data.
- The rubric gives no checkpoint radius: half the spacing between checkpoints (never more
  than the start threshold), so order is real; a dot accepts a tap anywhere near it.
- « Descends, ne monte pas » only plays for a stroke that goes down; a wrong-way bar or
  curve gets « Passe bien par le point. » instead.
- B15 asks for the cues to be checked on a physical device — not done (no device here).
- Cursive tracing stays V2 (plan §J.4): stroke scoring is print only.
