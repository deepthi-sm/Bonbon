/// Builds activity specs from a lesson (plan §U.1, §U.3, tasks B8, B9).
/// Reproducible: every item draws from [SeededRng] seeded with [itemSeed],
/// never math.Random().
///
/// Distractors come only from the decodability ledger ([ledgerAt]) or from
/// the lesson's own syllables and words, so an item never shows a symbol
/// she has not been taught. From tier 2, the confusion matrix
/// ([visualConfusion], [auditoryConfusion]) puts the most-confused
/// neighbours first. Tiers follow the difficulty ladders of generators.json;
/// which tier a learner gets is the progress side's choice.
library;

import 'dart:math' as math;

import '../data/content.dart';
import '../data/phrases.dart';
import 'confusion.dart';
import 'contract.dart';
import 'ledger.dart';
import 'seed.dart';

/// Optional recording check (plan §U.3: a listening item with no clip is
/// dropped). Pass `app.speech.has`; null keeps every item, as the prototype
/// does while the recordings are being made.
typedef HasAudio = bool Function(String text);

/// The activities to play after a lesson step of kind [stepKind] made of
/// [blocks] — the same mapping as the switch in buildSteps
/// (lib/screens/lesson_player.dart), plus the new types.
///
/// A lesson may have several syllable drills or word lists (L08 has two
/// drills). Listen-choose follows the first, and syllable-build or
/// missing-letter the last, so the same exercise never plays twice in a
/// lesson; with one, both follow it. At tier 3 listen-choose asks words
/// only (generators.json: targetUnit word), so the syllable drill has none.
List<ActivitySpec> specsAfter(String stepKind, List<Block> blocks, Lesson lesson, ContentRepo repo,
    {int tier = 1, HasAudio? hasAudio}) {
  final ofKind = lesson.blocks.where((b) => stepKindOf(b.type) == stepKind);
  final first = ofKind.isNotEmpty && blocks.contains(ofKind.first);
  final last = ofKind.isNotEmpty && blocks.contains(ofKind.last);
  final specs = switch (stepKind) {
    'grapheme' => [
        lesson.unit == UnitKind.graphemes
            ? graphemeSounds(lesson, tier: tier, hasAudio: hasAudio)
            : tapIdentify(lesson, tier: tier),
      ],
    'numeral_display' => [digitListen(lesson, repo, tier: tier, hasAudio: hasAudio)],
    'syllable_drill' => [
        if (first && tier < 3)
          listenChoose(lesson, P.promptSyllable, [for (final b in blocks) ...b.items()],
              variant: 'syllable', tier: tier, hasAudio: hasAudio),
        if (last) syllableBuild(lesson, tier: tier, hasAudio: hasAudio),
      ],
    'word_list' => [
        if (first)
          listenChoose(lesson, P.promptWord, [for (final b in blocks) ...b.items()],
              variant: 'word', tier: tier, hasAudio: hasAudio),
        if (last) missingLetter(lesson, tier: tier, hasAudio: hasAudio),
      ],
    'writing' => [trace(lesson, blocks, tier: tier)],
    _ => const <ActivitySpec?>[],
  };
  return specs.nonNulls.toList();
}

/// The step kind of a block, as buildSteps groups them: the handwriting demo
/// and writing practice make one « writing » step.
String stepKindOf(String blockType) =>
    blockType == 'handwriting_demo' || blockType == 'writing_practice' ? 'writing' : blockType;

/// Every activity generated for [lesson], in lesson order: what [specsAfter]
/// gives for each run of same-kind blocks, as buildSteps groups them.
List<ActivitySpec> specsFor(Lesson lesson, ContentRepo repo, {int tier = 1, HasAudio? hasAudio}) {
  final out = <ActivitySpec>[];
  final seen = <String>{};
  final blocks = lesson.blocks;
  for (var i = 0; i < blocks.length;) {
    final kind = stepKindOf(blocks[i].type);
    var j = i + 1;
    while (j < blocks.length && stepKindOf(blocks[j].type) == kind) {
      j++;
    }
    for (final s in specsAfter(kind, blocks.sublist(i, j), lesson, repo, tier: tier, hasAudio: hasAudio)) {
      if (seen.add(s.id)) out.add(s);
    }
    i = j;
  }
  return out;
}

String _seedKey(ActivityType t, String? variant) => variant == null ? t.key : '${t.key}/$variant';

/// [pool] with the confusion-matrix neighbours of [answer] first when
/// [near], each group shuffled by [rng]; never [answer] itself.
List<T> rankDistractors<T>(T answer, Iterable<T> pool, SeededRng rng, {required bool near, required bool Function(T) isNear}) {
  final others = pool.where((x) => x != answer).toSet().toList();
  if (!near) return rng.shuffled(others);
  final close = rng.shuffled(others.where(isNear));
  final rest = rng.shuffled(others.where((x) => !isNear(x)));
  return [...close, ...rest];
}

/// The first [n] of [ranked], swapping the last for the next candidate when
/// the set is the same as [previous] (confusion-matrix.json: two
/// consecutive items may not share a distractor set).
List<T> pickDistractors<T>(List<T> ranked, int n, Set<T> previous) {
  var pick = ranked.take(n).toList();
  if (n > 0 && previous.isNotEmpty && pick.toSet().containsAll(previous) && ranked.length > n) {
    pick = [...pick.take(n - 1), ranked[n]];
  }
  return pick;
}

/// Same length, one position differs, and there the two letters are
/// auditory neighbours: « ta » / « té », « po » / « bo ».
bool soundsNear(String a, String b) {
  if (a.length != b.length || a == b) return false;
  final diff = [for (var k = 0; k < a.length; k++) if (a[k] != b[k]) k];
  return diff.length == 1 && (auditoryConfusion[a[diff.single]]?.contains(b[diff.single]) ?? false);
}

/// listen-choose: hear an item, pick it among 3 (tier 1) or 4 written options
/// from the same block; from tier 2 the options that sound nearest come
/// first. Up to [count] items; null when the block has fewer than 3.
ActivitySpec? listenChoose(Lesson lesson, String prompt, List<TextItem> source,
    {String? variant, int tier = 1, int count = 4, HasAudio? hasAudio}) {
  const type = ActivityType.listenChoose;
  final seen = <String>{};
  final pool = [
    for (final i in source)
      if (seen.add(i.text)) Choice(i.text, i.speech),
  ];
  if (pool.length < 3) return null;
  final width = math.min(tier == 1 ? 3 : 4, pool.length);
  final key = _seedKey(type, variant);

  // Which items are asked, and in what order.
  final targets = SeededRng(fnv1a('${lesson.key}:$key:order')).shuffled(pool);
  final heard = hasAudio == null ? targets : targets.where((c) => hasAudio(c.speech)).toList();

  final items = <ActivityItem>[];
  Set<Choice> previous = {};
  for (final a in heard.take(count)) {
    final i = items.length;
    final rng = SeededRng(itemSeed(lesson.key, key, i));
    final ranked = rankDistractors(a, pool, rng, near: tier >= 2, isNear: (x) => soundsNear(a.show, x.show));
    final others = pickDistractors(ranked, width - 1, previous);
    previous = others.toSet();
    items.add(ActivityItem(index: i, prompt: prompt, target: a.show, answer: a, options: rng.shuffled([a, ...others])));
  }
  if (items.isEmpty) return null;
  return ActivitySpec(lessonKey: lesson.key, type: type, items: items, tier: tier, variant: variant);
}

/// Single letters she has met by [lesson], other than the lesson's own.
List<String> distractorLetters(Lesson lesson) =>
    [for (final x in ledgerAt(lesson.key)) if (x.length == 1 && !lesson.targets.contains(x)) x];

/// tap-identify for letter lessons: a grid holding the target several
/// times among other taught letters, in print, capital, then cursive. Up to
/// 4 items. Tier 1: 6 cells, target ×2, random letters; tier 2: 9 cells,
/// ×3, visual neighbours first (b among d p q); tier 3: 12 cells, ×3,
/// print and cursive mixed in one grid. Null when nothing else is taught
/// yet (L01).
ActivitySpec? tapIdentify(Lesson lesson, {int tier = 1, int count = 4}) {
  if (lesson.isDigit || lesson.unit == UnitKind.graphemes) return null;
  const type = ActivityType.tapIdentify;
  final gridSize = const {1: 6, 2: 9, 3: 12}[tier]!;
  final targetCount = tier == 1 ? 2 : 3;
  final pool = distractorLetters(lesson);
  if (pool.isEmpty) return null;

  final items = <ActivityItem>[];
  Set<String> previous = {};
  for (final t in lesson.targets) {
    for (final mode in const ['print', 'upper', 'cursive']) {
      if (items.length == count) break;
      final i = items.length;
      final rng = SeededRng(itemSeed(lesson.key, type.key, i));
      final cursive = mode == 'cursive';
      String shown(String s) => mode == 'upper' ? s.toUpperCase() : s;
      // Tier 3 mixes scripts cell by cell, the target included.
      Choice c(String s) => Choice(shown(s), s, cursive: tier == 3 ? rng.nextInt(2) == 1 : cursive);

      final ranked = rankDistractors(t, pool, rng, near: tier >= 2, isNear: (x) => visualConfusion[t]?.contains(x) ?? false);
      final kinds = pickDistractors(ranked, math.min(ranked.length, gridSize - targetCount), previous);
      previous = kinds.toSet();
      final cells = rng.shuffled([
        for (var k = 0; k < targetCount; k++) c(t),
        for (var k = 0; k < gridSize - targetCount; k++) c(kinds[k % kinds.length]),
      ]);
      items.add(ActivityItem(
        index: i,
        prompt: cursive ? P.promptCursive(t) : mode == 'upper' ? P.promptUpper(t) : P.promptLetter(t),
        target: t,
        answer: Choice(shown(t), t, cursive: cursive),
        options: cells,
        listen: false,
      ));
    }
  }
  return items.isEmpty ? null : ActivitySpec(lessonKey: lesson.key, type: type, items: items, tier: tier);
}

/// listen-choose on the lesson's graphemes: hear « an », pick it among the
/// graphemes she has met (the ledger's multi-letter entries); from tier 2,
/// its auditory neighbours first (an among on in en). 3 options, then 4.
ActivitySpec? graphemeSounds(Lesson lesson, {int tier = 1, HasAudio? hasAudio}) {
  const type = ActivityType.listenChoose;
  const variant = 'sound';
  final mine = lesson.targets.where((t) => !t.contains('=')).toList();
  final met = [for (final x in ledgerAt(lesson.key)) if (x.length > 1) x];
  final width = tier == 1 ? 3 : 4;
  final items = <ActivityItem>[];
  Set<String> previous = {};
  for (final t in mine.take(3)) {
    if (hasAudio != null && !hasAudio(t)) continue;
    final i = items.length;
    final rng = SeededRng(itemSeed(lesson.key, _seedKey(type, variant), i));
    final ranked = rankDistractors(t, met, rng, near: tier >= 2, isNear: (x) => auditoryConfusion[t]?.contains(x) ?? false);
    if (ranked.length < width - 1) continue;
    final others = pickDistractors(ranked, width - 1, previous);
    previous = others.toSet();
    final options = rng.shuffled([t, ...others].map((x) => Choice(x, x)));
    items.add(ActivityItem(index: i, prompt: P.promptSound, target: t, answer: Choice(t, t), options: options));
  }
  return items.isEmpty ? null : ActivitySpec(lessonKey: lesson.key, type: type, items: items, tier: tier, variant: variant);
}

/// The blend spoken after a built syllable: « t … a … ta », as recorded.
String blendOf(String consonant, String vowel) => '$consonant … $vowel … $consonant$vowel';

/// syllable-build for consonant lessons (L08–L24): hear « ta », join t with
/// the right vowel tile. The tiles are the vowels of this lesson's own
/// syllables, so a tile never builds a syllable the lesson doesn't teach
/// (L21 has ga go gu, never gi). Tier 1: 4 rounds, 4 tiles, written model;
/// tier 2: 5 rounds, 6 tiles, sound-alike vowels first (é among è e);
/// tier 3: 6 rounds, 8 tiles, the instruction spoken only (audioOnly). With
/// [hasAudio], a syllable with no recording is left out and a missing blend
/// falls back to the syllable alone.
ActivitySpec? syllableBuild(Lesson lesson, {int tier = 1, HasAudio? hasAudio}) {
  if (lesson.unit != UnitKind.consonants) return null;
  const type = ActivityType.syllableBuild;
  final rounds = 3 + tier;
  final tiles = 2 + 2 * tier;
  final c = lesson.targets.first;
  final seen = <String>{};
  final pool = [
    for (final s in lesson.syllables)
      if (s.text.length > c.length && s.text.startsWith(c) && seen.add(s.text)) s,
  ];
  final vowels = [for (final s in pool) s.text.substring(c.length)];
  if (vowels.length < 2) return null;

  final order = SeededRng(fnv1a('${lesson.key}:${type.key}:order')).shuffled(pool);
  final heard = hasAudio == null ? order : order.where((s) => hasAudio(s.speech)).toList();
  final items = <ActivityItem>[];
  Set<String> previous = {};
  for (final s in heard.take(rounds)) {
    final i = items.length;
    final rng = SeededRng(itemSeed(lesson.key, type.key, i));
    final v = s.text.substring(c.length);
    final ranked = rankDistractors(v, vowels, rng, near: tier >= 2, isNear: (x) => auditoryConfusion[v]?.contains(x) ?? false);
    final others = pickDistractors(ranked, math.min(ranked.length, tiles - 1), previous);
    previous = others.toSet();
    final blend = blendOf(c, v);
    items.add(ActivityItem(
      index: i,
      prompt: P.promptSyllable,
      target: s.text,
      word: s.speech,
      fixed: c,
      blend: hasAudio == null || hasAudio(blend) ? blend : null,
      answer: Choice(v, v),
      options: rng.shuffled([v, ...others].map((x) => Choice(x, x))),
      // Every tile builds one of the lesson's own syllables, so it is recorded.
      wrongSay: {
        for (final x in others)
          if (hasAudio == null || hasAudio(pool[vowels.indexOf(x)].speech)) x: pool[vowels.indexOf(x)].speech,
      },
    ));
  }
  return items.isEmpty ? null : ActivitySpec(lessonKey: lesson.key, type: type, items: items, tier: tier);
}

/// The missing-letter instruction (ui-strings.fr.json, missingLetter.prompt).
/// Not recorded yet: add it to the recording script.
const promptMissingLetter = 'Quelle lettre manque ?';

/// missing-letter for vowel and consonant lessons (L01–L24): a word from
/// this lesson's word list with one letter blanked. Up to [count] items.
/// Tier 1: 3 candidates, the blank on the focus letter, the whole word
/// shown first; tier 2: 4 candidates; tier 3: 4 candidates, the blank on
/// any letter she has met.
///
/// Distractors are the letter's visual then auditory neighbours, then other
/// letters she has met, and two items in a row never offer the same set. A
/// wrong letter builds a wrong word, spoken before the right one when it is
/// recorded: [hasAudio] decides, or with no check, the lesson's own words
/// and syllables.
ActivitySpec? missingLetter(Lesson lesson, {int tier = 1, int count = 4, HasAudio? hasAudio}) {
  if (lesson.isDigit || lesson.unit == UnitKind.graphemes) return null;
  const type = ActivityType.missingLetter;
  final candidates = tier == 1 ? 3 : 4;
  final letters = [for (final x in ledgerAt(lesson.key)) if (x.length == 1) x];
  // Tier 3 may blank any letter she has met, tiers 1–2 only the lesson's own.
  final blankable = tier == 3 ? letters.toSet() : lesson.targets.where((t) => t.length == 1).toSet();
  final seen = <String>{};
  final words = [
    for (final w in lesson.words)
      if (!w.text.contains(' ') && lesson.targets.any(w.text.contains) && seen.add(w.text)) w,
  ];
  final own = {for (final x in [...lesson.words, ...lesson.syllables]) x.text.toLowerCase()};
  bool recorded(String text) => hasAudio?.call(text) ?? own.contains(text.toLowerCase());

  final order = SeededRng(fnv1a('${lesson.key}:${type.key}:order')).shuffled(words);
  final items = <ActivityItem>[];
  Set<String> previous = {};
  for (final w in order) {
    if (items.length == count) break;
    if (hasAudio != null && !hasAudio(w.speech)) continue;
    final i = items.length;
    final rng = SeededRng(itemSeed(lesson.key, type.key, i));
    final spots = [for (var k = 0; k < w.text.length; k++) if (blankable.contains(w.text[k])) k];
    if (spots.isEmpty) continue;
    final at = rng.pick(spots);
    final a = w.text[at];
    final near = {...?visualConfusion[a], ...?auditoryConfusion[a]};
    final ranked = rankDistractors(a, letters, rng, near: true, isNear: near.contains);
    if (ranked.length < candidates - 1) continue;
    final pick = pickDistractors(ranked, candidates - 1, previous);
    previous = pick.toSet();

    String built(String x) => w.text.replaceRange(at, at + 1, x);
    items.add(ActivityItem(
      index: i,
      prompt: promptMissingLetter,
      target: w.text,
      word: w.speech,
      blankAt: at,
      answer: Choice(a, a),
      options: rng.shuffled([a, ...pick].map((x) => Choice(x, x))),
      wrongSay: {for (final x in pick) if (recorded(built(x))) x: built(x)},
    ));
  }
  return items.isEmpty ? null : ActivitySpec(lessonKey: lesson.key, type: type, items: items, tier: tier);
}

/// trace for vowel, consonant and digit lessons: the single glyphs of the
/// writing practice (i, I, 3…), in the book's order, each in print and, when
/// the book asks for it, in cursive. Up to [count] items; words (tête, mil)
/// are not traced yet. The tier sets the guide and tolerance
/// ([traceGhost], [traceTolerance]).
ActivitySpec? trace(Lesson lesson, List<Block> writing, {int tier = 1, int count = 4}) {
  if (lesson.unit == UnitKind.graphemes) return null;
  const type = ActivityType.trace;
  // An item without its own representations takes its block's (L01);
  // TextItem would default it to print only, so read the source.
  List<String> reps(Block b, int k) {
    final own = ((b.raw['items'] as List)[k] as Map)['representations'] as List?;
    return [...?(own ?? b.raw['representations'] as List?)?.cast<String>()];
  }

  final glyphs = [
    for (final b in writing)
      if (b.type == 'writing_practice')
        for (final (k, it) in b.items().indexed)
          if (it.text.length == 1) ...[
            if (reps(b, k).contains('print') || reps(b, k).isEmpty) Choice(it.text, it.speech),
            if (reps(b, k).contains('cursive')) Choice(it.text, it.speech, cursive: true),
          ],
  ];
  final seen = <Choice>{};
  final items = <ActivityItem>[
    for (final g in glyphs)
      if (seen.length < count && seen.add(g))
        ActivityItem(index: seen.length - 1, prompt: P.traceEmpty, target: g.show, answer: g, listen: false),
  ];
  return items.isEmpty ? null : ActivitySpec(lessonKey: lesson.key, type: type, items: items, tier: tier);
}

/// trace's guide by tier (generators.json): ghost model on tiers 1–2, free on 3.
/// (Tier 1's start dots need stroke paths, task B6.)
bool traceGhost(int tier) => tier < 3;

/// trace's tolerance multiplier by tier (generators.json): 1.4, 1.0, 0.8.
double traceTolerance(int tier) => const {1: 1.4, 2: 1.0, 3: 0.8}[tier]!;

/// listen-choose on digits: hear « sept », pick 7 among four digits. Digits
/// are a closed set of ten, so every digit may be a distractor. The matrix
/// has no auditory neighbours for digits, so every tier draws at random.
ActivitySpec? digitListen(Lesson lesson, ContentRepo repo, {int tier = 1, int count = 2, HasAudio? hasAudio}) {
  if (!lesson.isDigit) return null;
  const type = ActivityType.listenChoose;
  const variant = 'digit';
  final words = {for (final x in repo.units.last.lessons) x.number: x.targets[1]};
  final d = lesson.number;
  if (hasAudio != null && !hasAudio(words[d]!)) return null;
  Choice c(int n) => Choice('$n', words[n]!);
  final items = <ActivityItem>[];
  Set<int> previous = {};
  for (var i = 0; i < count; i++) {
    final rng = SeededRng(itemSeed(lesson.key, _seedKey(type, variant), i));
    final ranked = rankDistractors(d, [for (var n = 0; n <= 9; n++) n], rng, near: false, isNear: (_) => false);
    final others = pickDistractors(ranked, 3, previous);
    previous = others.toSet();
    items.add(ActivityItem(index: i, prompt: P.promptDigit, target: '$d', answer: c(d), options: rng.shuffled([d, ...others].map(c))));
  }
  return ActivitySpec(lessonKey: lesson.key, type: type, items: items, tier: tier, variant: variant);
}
