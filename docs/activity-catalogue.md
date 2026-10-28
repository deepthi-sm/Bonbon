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
| `bonbon_app/lib/activities/choice_session.dart` | rules of tap-identify / listen-choose / syllable-build / missing-letter with the repair ladder — pure Dart |
| `bonbon_app/lib/activities/choice_activity.dart` | the screen for those four types |
| `bonbon_app/lib/activities/feedback.dart` | the feedback layer (B7): `Mark` (right, tried, model, faded, idle), its colour + icon, and `Marked`, which adds the motion — used by every activity |
| `bonbon_app/lib/activities/trace_session.dart` | rules of trace: attempts, cues, never blocked — pure Dart |
| `bonbon_app/lib/activities/trace_pad.dart` | the tracing canvas, measuring with the prototype's `scoreTrace` |
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
| `tap-identify` | 0.80 | yes | **built** on the contract: tier 1, 6-cell grid, target ×2, repair ladder |
| `listen-choose` | 0.75 | no | **built** on the contract: syllables, words, graphemes, digits; tier 1; repair ladder |
| `syllable-build` | 0.60 | yes | **built**: L08–L24, tier 1 (4 rounds, 4 vowel tiles, written model); drag or tap a vowel next to the consonant; success plays the recorded blend « t … a … ta »; a wrong vowel first plays the syllable it built; repair ladder |
| `missing-letter` | 0.70 | no | **built**: L01–L24 (lessons whose word list has a word with the focus letter), tier 1 (3 candidates, blank on the focus letter, whole word shown first); distractors from the confusion matrix, then taught letters; a wrong letter plays the wrong word when it is recorded, then the right one; repair ladder |
| `trace` | 0.55 | yes | **built** on the contract: vowel, consonant and digit lessons, the single glyphs of the writing practice (print, and cursive where the book asks), tier 1 (ghost). Prototype scoring (precision + coverage); 2★ or more finishes the letter; a low attempt gets a cue matched to what went wrong; after 3, the model lights up and she moves on. No start point / direction / stroke order yet |

Item credit: with partial credit, `1 − hintCost` of the highest repair rung reached; without
it, 1 only for a first-try answer. trace instead counts its measured quality (stars / 3).
An item answered by the app (rung 4, or trace's third low attempt) scores 0 and its target
goes to review. A result never blocks the next lesson.

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

- The first lessons have too few taught letters for a grid, so tap-identify borrows
  `earlyShapes` (a o u e i é y), as the prototype did. Plan §U.2 says taught letters only —
  decide with the team.
- Tiers 2–3 (confusion-matrix distractors) are not built yet (task B9).

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
- missing-letter for grapheme lessons (L25+, blanking « ain » in « pain ») is not built yet.
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
- Trace direction/order needs per-glyph stroke paths (`GlyphSpec`, plan §H.7) from Dev A.
