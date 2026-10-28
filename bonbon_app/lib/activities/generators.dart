/// Builds activity specs from a lesson (plan §U.1, §U.3, task B8). Same
/// choices as the prototype in lib/screens/activities.dart — only the
/// lesson's own items, plus letters already taught — but reproducible: every
/// item draws from [SeededRng] seeded with [itemSeed], never math.Random().
///
/// Tier 1 only for now. Tiers 2–3 need the confusion matrix (task B9).
library;

import 'dart:math' as math;

import '../data/content.dart';
import '../data/phrases.dart';
import 'contract.dart';
import 'seed.dart';

/// Optional recording check (plan §U.3: a listening item with no clip is
/// dropped). Pass `app.speech.has`; null keeps every item, as the prototype
/// does while the recordings are being made.
typedef HasAudio = bool Function(String text);

/// The activities to play after a lesson step of kind [stepKind] made of
/// [blocks] — the same mapping as the switch in buildSteps
/// (lib/screens/lesson_player.dart), plus syllable-build.
///
/// A lesson may have several syllable drills (L08 has two). Listen-choose
/// follows the first and syllable-build the last, so the same exercise never
/// plays twice in a lesson; with one drill, both follow it.
List<ActivitySpec> specsAfter(String stepKind, List<Block> blocks, Lesson lesson, ContentRepo repo, {HasAudio? hasAudio}) {
  final drills = lesson.blocks.where((b) => b.type == 'syllable_drill');
  final specs = switch (stepKind) {
    'grapheme' => [
        lesson.unit == UnitKind.graphemes ? graphemeSounds(lesson, repo, hasAudio: hasAudio) : tapIdentify(lesson, repo),
      ],
    'numeral_display' => [digitListen(lesson, repo, hasAudio: hasAudio)],
    'syllable_drill' => [
        if (blocks.contains(drills.first))
          listenChoose(lesson, P.promptSyllable, [for (final b in blocks) ...b.items()], variant: 'syllable', hasAudio: hasAudio),
        if (blocks.contains(drills.last)) syllableBuild(lesson, repo, hasAudio: hasAudio),
      ],
    'word_list' => [
        listenChoose(lesson, P.promptWord, [for (final b in blocks) ...b.items()], variant: 'word', hasAudio: hasAudio),
      ],
    _ => const <ActivitySpec?>[],
  };
  return specs.nonNulls.toList();
}

/// Every activity generated for [lesson], in lesson order: what [specsAfter]
/// gives for each run of same-kind blocks, as buildSteps groups them.
List<ActivitySpec> specsFor(Lesson lesson, ContentRepo repo, {HasAudio? hasAudio}) {
  final out = <ActivitySpec>[];
  final seen = <String>{};
  final blocks = lesson.blocks;
  for (var i = 0; i < blocks.length;) {
    var j = i + 1;
    while (j < blocks.length && blocks[j].type == blocks[i].type) {
      j++;
    }
    for (final s in specsAfter(blocks[i].type, blocks.sublist(i, j), lesson, repo, hasAudio: hasAudio)) {
      if (seen.add(s.id)) out.add(s);
    }
    i = j;
  }
  return out;
}

String _seedKey(ActivityType t, String? variant) => variant == null ? t.key : '${t.key}/$variant';

/// listen-choose: hear an item, pick it among 3 (tier 1) or 4 written options
/// from the same block. Up to [count] items; null when the block has fewer than 3.
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
  for (final a in heard.take(count)) {
    final i = items.length;
    final rng = SeededRng(itemSeed(lesson.key, key, i));
    final others = rng.shuffled(pool.where((x) => x != a));
    final options = rng.shuffled([a, ...others.take(width - 1)]);
    items.add(ActivityItem(index: i, prompt: prompt, target: a.show, answer: a, options: options));
  }
  if (items.isEmpty) return null;
  return ActivitySpec(lessonKey: lesson.key, type: type, items: items, tier: tier, variant: variant);
}

/// Letters shown as extra shapes in the first lessons, where fewer than four
/// letters are taught yet. Same list as the prototype. Plan §U.2 says
/// distractors come only from taught letters — to settle with the team.
const earlyShapes = ['a', 'o', 'u', 'e', 'i', 'é', 'y'];

/// Distractor letters allowed at [lesson]: taught letters, then [earlyShapes].
List<String> distractorLetters(Lesson lesson, ContentRepo repo) {
  final taught = repo.lettersTaughtThrough(lesson).where((x) => !lesson.targets.contains(x)).toSet().toList();
  return [...taught, ...earlyShapes.where((f) => !taught.contains(f) && !lesson.targets.contains(f))];
}

/// tap-identify for letter lessons, tier 1: a 6-cell grid holding the target
/// twice (generators.json), in print, capital, then cursive. Up to 4 items.
ActivitySpec? tapIdentify(Lesson lesson, ContentRepo repo, {int count = 4}) {
  if (lesson.isDigit || lesson.unit == UnitKind.graphemes) return null;
  const type = ActivityType.tapIdentify;
  const gridSize = 6, targetCount = 2;
  final pool = distractorLetters(lesson, repo);
  if (pool.isEmpty) return null;

  final items = <ActivityItem>[];
  for (final t in lesson.targets) {
    for (final mode in const ['print', 'upper', 'cursive']) {
      if (items.length == count) break;
      final i = items.length;
      final rng = SeededRng(itemSeed(lesson.key, type.key, i));
      final cursive = mode == 'cursive';
      String shown(String s) => mode == 'upper' ? s.toUpperCase() : s;
      Choice c(String s) => Choice(shown(s), s, cursive: cursive);

      final shuffled = rng.shuffled(pool);
      final distractors = [
        for (var k = 0; k < gridSize - targetCount; k++) shuffled[k % shuffled.length],
      ];
      final cells = rng.shuffled([for (var k = 0; k < targetCount; k++) c(t), ...distractors.map(c)]);
      items.add(ActivityItem(
        index: i,
        prompt: cursive ? P.promptCursive(t) : mode == 'upper' ? P.promptUpper(t) : P.promptLetter(t),
        target: t,
        answer: c(t),
        options: cells,
        listen: false,
      ));
    }
  }
  return items.isEmpty ? null : ActivitySpec(lessonKey: lesson.key, type: type, items: items);
}

/// listen-choose on the lesson's graphemes: hear « an », pick it among this
/// lesson's and earlier lessons' graphemes. Same pool as the prototype.
ActivitySpec? graphemeSounds(Lesson lesson, ContentRepo repo, {HasAudio? hasAudio}) {
  const type = ActivityType.listenChoose;
  const variant = 'sound';
  final mine = lesson.targets.where((t) => !t.contains('=')).toList();
  final earlier = [
    for (final x in repo.lessons)
      if (x.unit == UnitKind.graphemes && x.number < lesson.number) ...x.targets.where((t) => !t.contains('=')),
  ];
  final items = <ActivityItem>[];
  for (final t in mine.take(3)) {
    if (hasAudio != null && !hasAudio(t)) continue;
    final i = items.length;
    final rng = SeededRng(itemSeed(lesson.key, _seedKey(type, variant), i));
    final others = rng.shuffled({...mine, ...earlier}.where((x) => x != t));
    if (others.length < 2) continue;
    final options = rng.shuffled([t, ...others.take(2)].map((x) => Choice(x, x)));
    items.add(ActivityItem(index: i, prompt: P.promptSound, target: t, answer: Choice(t, t), options: options));
  }
  return items.isEmpty ? null : ActivitySpec(lessonKey: lesson.key, type: type, items: items, variant: variant);
}

/// The blend spoken after a built syllable: « t … a … ta », as recorded.
String blendOf(String consonant, String vowel) => '$consonant … $vowel … $consonant$vowel';

/// syllable-build for consonant lessons (L08–L24): hear « ta », join t with
/// the right vowel tile. Tier 1: 4 rounds, 4 vowel tiles. The tiles are the
/// vowels of this lesson's own syllables, so a tile never builds a syllable
/// the lesson doesn't teach (L21 has ga go gu, never gi). With [hasAudio], a
/// syllable with no recording is left out and a missing blend falls back to
/// the syllable alone.
ActivitySpec? syllableBuild(Lesson lesson, ContentRepo repo, {int rounds = 4, int tiles = 4, HasAudio? hasAudio}) {
  if (lesson.unit != UnitKind.consonants) return null;
  const type = ActivityType.syllableBuild;
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
  for (final s in heard.take(rounds)) {
    final i = items.length;
    final rng = SeededRng(itemSeed(lesson.key, type.key, i));
    final v = s.text.substring(c.length);
    final others = rng.shuffled(vowels.where((x) => x != v));
    final blend = blendOf(c, v);
    items.add(ActivityItem(
      index: i,
      prompt: P.promptSyllable,
      target: s.text,
      word: s.speech,
      fixed: c,
      blend: hasAudio == null || hasAudio(blend) ? blend : null,
      answer: Choice(v, v),
      options: rng.shuffled([v, ...others.take(tiles - 1)].map((x) => Choice(x, x))),
    ));
  }
  return items.isEmpty ? null : ActivitySpec(lessonKey: lesson.key, type: type, items: items);
}

/// listen-choose on digits: hear « sept », pick 7 among four digits. Digits
/// are a closed set of ten, so every digit may be a distractor.
ActivitySpec? digitListen(Lesson lesson, ContentRepo repo, {int count = 2, HasAudio? hasAudio}) {
  if (!lesson.isDigit) return null;
  const type = ActivityType.listenChoose;
  const variant = 'digit';
  final words = {for (final x in repo.units.last.lessons) x.number: x.targets[1]};
  final d = lesson.number;
  if (hasAudio != null && !hasAudio(words[d]!)) return null;
  Choice c(int n) => Choice('$n', words[n]!);
  final items = <ActivityItem>[];
  for (var i = 0; i < count; i++) {
    final rng = SeededRng(itemSeed(lesson.key, _seedKey(type, variant), i));
    final others = rng.shuffled([for (var n = 0; n <= 9; n++) if (n != d) n]);
    final options = rng.shuffled([d, ...others.take(3)].map(c));
    items.add(ActivityItem(index: i, prompt: P.promptDigit, target: '$d', answer: c(d), options: options));
  }
  return ActivitySpec(lessonKey: lesson.key, type: type, items: items, variant: variant);
}
