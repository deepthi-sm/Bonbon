# Batonga Syllabaire — Add-on packs (Part Two)

Machine-readable content for the four add-on packs described in §S–§X of
`BUILD_PLAN_v2.md`. Copy each directory into the repository:

    01-corpus/          -> content/corpus/            ◆ Dev A   dev/content-engine
    02-exercices/       -> content/exercices/         ◆ Dev B   dev/activities
    03-interface/       -> content/interface/         ◆ Dev C   dev/shell-ux
    04-audio-maitrise/  -> content/audio/script/      ◆ Dev D   dev/data-audio

Then split `03-interface/ui-strings.fr.json` into `src/i18n/fr/<namespace>.json`
(one file per namespace, per §O.4) and hand `04-audio-maitrise/recording-script.csv`
to the studio.

## Read the $comment first

Every file opens with a `$comment` stating what it is, which provenance tag it
carries, and the reasoning behind the choices inside it. Several fields look
like oversights and are not:

- Lesson 08's syllable tree has seven branches above an eight-syllable strip.
  That is what the printed page does. Both states are recorded.
- Six syllables carry `verifyAgainstSource: true`. Dev A must check those
  against pp. 42–47 before writing L19 and L20.
- Six UI strings are deliberately empty. Their `ctx` explains why.
- Lesson 24 has no sentence block.

## The generators are the authority

`gen_corpus.py`, `gen_exercices.py`, `gen_interface.py` and `gen_audio.py`
produce every JSON file here, in that order. If a generator and its output
disagree, someone hand-edited a file they should not have.

    python3 gen_corpus.py && python3 gen_exercices.py \
      && python3 gen_interface.py && python3 gen_audio.py

Port them to `tools/*.ts` in Sprint 1 (tasks A9, D11) and wire them into CI so
a drifted file fails the build.
