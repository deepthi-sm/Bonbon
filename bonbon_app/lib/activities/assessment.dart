/// The Bilan and the six checkpoints (plan §U.5, task B11): short mixed
/// checks built from the same generators. Deliberately NOT a gate — a score
/// below the threshold schedules review, it never locks the next lesson
/// (bilan-blueprints.json, checkpoints.json). Pure Dart.
library;

import '../data/content.dart';
import '../data/phrases.dart';
import 'contract.dart';
import 'generators.dart';
import 'ledger.dart';
import 'seed.dart';

/// Both blueprints: ≥ 0.7 is « bien lu » / a celebration; below, review.
const assessmentPass = 0.7;

/// The generators' tier for assessments (bilan-blueprints.json, rule 1).
const assessmentTier = 2;

enum Archetype { vowel, consonant, grapheme, numeral }

Archetype archetypeOf(Lesson l) => switch (l.unit) {
      UnitKind.vowels => Archetype.vowel,
      UnitKind.consonants => Archetype.consonant,
      UnitKind.graphemes => Archetype.grapheme,
      UnitKind.digits => Archetype.numeral,
    };

/// One part of a blueprint: how many items of which activity type. The
/// type is a key from the JSON packs; « comprehension » has no generator
/// yet (its questions are Batonga's to write), so that part is left out —
/// « the blueprint shortens » (bilan-blueprints.json, rule 5).
typedef Part = (String type, int count);

/// bilan-blueprints.json, byArchetype.
const bilanBlueprints = <Archetype, List<Part>>{
  Archetype.vowel: [('tap-identify', 2), ('listen-choose', 1), ('trace', 1)],
  Archetype.consonant: [('listen-choose', 2), ('syllable-build', 2), ('missing-letter', 1)],
  Archetype.grapheme: [('listen-choose', 2), ('missing-letter', 2), ('comprehension', 1)],
  Archetype.numeral: [('tap-identify', 1), ('listen-choose', 2), ('trace', 1)],
};

class Checkpoint {
  final String id;
  final String firstLesson, afterLesson; // the lessons it covers, as Lesson.key
  final int itemCount;
  final List<Part> mix;

  /// The written celebration (checkpoints.json), and the recorded sentence
  /// to speak with it when the team's bank has one close enough.
  final String celebration;
  final String? spoken;

  const Checkpoint(this.id, this.firstLesson, this.afterLesson, this.itemCount, this.mix, this.celebration, [this.spoken]);
}

/// checkpoints.json. CP4's « D9 » is the app's N9.
const checkpoints = [
  Checkpoint('CP1', 'L01', 'L07', 10, [('tap-identify', 3), ('listen-choose', 4), ('trace', 3)],
      'Unité 1 terminée : tu connais toutes les voyelles.', 'Unité terminée. Tu connais maintenant toutes les voyelles.'),
  Checkpoint('CP2', 'L08', 'L24', 14, [('listen-choose', 5), ('syllable-build', 5), ('missing-letter', 3), ('trace', 1)],
      'Unité 2 terminée : tu peux lire des syllabes et des phrases courtes.',
      'Unité terminée. Tu peux lire des syllabes et des phrases courtes.'),
  Checkpoint('CP3a', 'L25', 'L32', 10, [('listen-choose', 5), ('missing-letter', 4), ('comprehension', 1)],
      'Bloc 1 des diphtongues terminé.'),
  Checkpoint('CP3b', 'L33', 'L40', 10, [('listen-choose', 5), ('missing-letter', 4), ('comprehension', 1)], 'Bloc 2 terminé.'),
  Checkpoint('CP3c', 'L41', 'L48', 10, [('listen-choose', 6), ('missing-letter', 3), ('comprehension', 1)],
      'Bloc 3 terminé : tu sais qu\'une lettre peut avoir deux sons.'),
  Checkpoint('CP3d', 'L49', 'L56', 12, [('listen-choose', 4), ('missing-letter', 4), ('comprehension', 4)],
      'Unité 3 terminée : tu lis des textes.'),
  Checkpoint('CP4', 'N0', 'N9', 10, [('tap-identify', 3), ('listen-choose', 4), ('trace', 3)],
      'Tu connais les chiffres de zéro à neuf.', 'Tu connais les chiffres de zéro à neuf.'),
];

/// A Bilan or a checkpoint: activities played one after the other.
class Assessment {
  final String id; // « L08:bilan », « CP2 »
  final String lessonKey; // the lesson it follows
  final List<ActivitySpec> parts;
  final String? celebration, spoken;
  const Assessment(this.id, this.lessonKey, this.parts, {this.celebration, this.spoken});

  bool get isCheckpoint => !id.endsWith(':bilan');
  int get itemCount => parts.fold(0, (n, p) => n + p.items.length);
}

/// What an assessment hands back. Never blocks anything.
class AssessmentResult {
  final Assessment assessment;
  final List<ActivityResult> parts;
  const AssessmentResult(this.assessment, this.parts);

  /// Mean credit over every planned item; a skipped part's items count 0.
  double get score {
    final total = assessment.itemCount;
    if (total == 0) return 0;
    var sum = 0.0;
    for (final r in parts) {
      for (final i in r.items) {
        sum += i.credit(r.spec.type);
      }
    }
    return sum / total;
  }

  bool get passed => score >= assessmentPass;

  /// Targets for the review queue. Always those the app answered for her;
  /// below the threshold, also every item below its type's own pass mark and
  /// every item of a skipped part (« les cibles faibles alimentent la file
  /// de révision »).
  List<String> get reviewTargets {
    final out = <String>{};
    for (final r in parts) {
      out.addAll(r.reviewTargets);
      if (passed) continue;
      if (r.skipped != null) out.addAll(r.spec.items.map((i) => i.target));
      for (final i in r.items) {
        if (i.credit(r.spec.type) < r.spec.type.pass) out.add(i.target);
      }
    }
    return out.toList();
  }

  Map<String, Object?> toJson() => {
        'assessment': assessment.id,
        'lesson': assessment.lessonKey,
        'score': score,
        'passed': passed,
        'review': reviewTargets,
        'parts': [for (final r in parts) r.toJson()],
      };
}

/// What [l] introduces: its ledger additions, or its digit.
Set<String> introducedBy(Lesson l) => l.isDigit ? {'${l.number}'} : {...?ledgerAdds[l.key]};

/// The activity of [typeKey] for [l] at the assessment tier, drawn with
/// [salt] so its items are not the ones she just practised.
ActivitySpec? _draw(String typeKey, Lesson l, ContentRepo repo, String salt, HasAudio? hasAudio) {
  const t = assessmentTier;
  return switch ((ActivityType.fromKey(typeKey), archetypeOf(l))) {
    (ActivityType.tapIdentify, Archetype.numeral) => digitTapIdentify(l, repo, tier: t, salt: salt),
    (ActivityType.tapIdentify, _) => tapIdentify(l, tier: t, salt: salt),
    (ActivityType.listenChoose, Archetype.numeral) => digitListen(l, repo, tier: t, hasAudio: hasAudio, salt: salt),
    (ActivityType.listenChoose, Archetype.grapheme) => graphemeSounds(l, tier: t, hasAudio: hasAudio, salt: salt),
    (ActivityType.listenChoose, Archetype.consonant) =>
      listenChoose(l, P.promptSyllable, l.syllables, variant: 'syllable', tier: t, hasAudio: hasAudio, salt: salt),
    (ActivityType.listenChoose, Archetype.vowel) =>
      listenChoose(l, P.promptWord, l.words, variant: 'word', tier: t, hasAudio: hasAudio, salt: salt),
    (ActivityType.syllableBuild, _) => syllableBuild(l, tier: t, hasAudio: hasAudio, salt: salt),
    (ActivityType.missingLetter, _) => missingLetter(l, tier: t, hasAudio: hasAudio, salt: salt),
    (ActivityType.trace, _) => trace(l, l.blocks.where((b) => b.type == 'writing_practice').toList(), tier: t),
    (null, _) => null, // comprehension: no questions yet
  };
}

/// Items of [s] that target something [l] introduced (bilan-blueprints.json,
/// rule 2): the letter, grapheme, syllable or word holds it.
List<ActivityItem> _ownItems(ActivitySpec? s, Lesson l) {
  if (s == null) return const [];
  final own = introducedBy(l);
  return [for (final i in s.items) if (own.any(i.target.toLowerCase().contains)) i];
}

ActivitySpec _part(String lessonKey, ActivityType type, String variant, List<ActivityItem> items) => ActivitySpec(
      lessonKey: lessonKey,
      type: type,
      tier: assessmentTier,
      variant: variant,
      items: [for (final (k, i) in items.indexed) i.at(k)],
    );

/// The Bilan for [l]: its archetype's mix, drawn fresh at tier 2, only on
/// what this lesson introduced. Shorter when a part has fewer items (L01
/// has no tap-identify yet); null when nothing can be drawn.
Assessment? bilanFor(Lesson l, ContentRepo repo, {HasAudio? hasAudio}) {
  final parts = <ActivitySpec>[];
  for (final (key, n) in bilanBlueprints[archetypeOf(l)]!) {
    final type = ActivityType.fromKey(key);
    final items = _ownItems(_draw(key, l, repo, 'bilan', hasAudio), l).take(n).toList();
    if (type != null && items.isNotEmpty) parts.add(_part(l.key, type, 'bilan', items));
  }
  return parts.isEmpty ? null : Assessment('${l.key}:bilan', l.key, parts);
}

/// The checkpoint that follows [l], if one does: each part draws from every
/// lesson it covers, spread evenly (round-robin, lessons in seeded order).
Assessment? checkpointAfter(Lesson l, ContentRepo repo, {HasAudio? hasAudio}) {
  final cp = checkpoints.where((c) => c.afterLesson == l.key).firstOrNull;
  if (cp == null) return null;
  final keys = [for (final x in repo.lessons) x.key];
  final covered = repo.lessons.sublist(keys.indexOf(cp.firstLesson), keys.indexOf(cp.afterLesson) + 1);
  final parts = <ActivitySpec>[];
  for (final (key, n) in cp.mix) {
    final type = ActivityType.fromKey(key);
    if (type == null) continue;
    final rng = SeededRng(fnv1a('${cp.id}:$key'));
    final perLesson = [
      for (final x in rng.shuffled(covered)) _ownItems(_draw(key, x, repo, cp.id, hasAudio), x),
    ].where((items) => items.isNotEmpty).toList();
    final picked = <ActivityItem>[];
    for (var round = 0; picked.length < n && perLesson.any((items) => items.length > round); round++) {
      for (final items in perLesson) {
        if (picked.length < n && items.length > round) picked.add(items[round]);
      }
    }
    if (picked.isNotEmpty) parts.add(_part(cp.afterLesson, type, cp.id, picked));
  }
  return parts.isEmpty ? null : Assessment(cp.id, cp.afterLesson, parts, celebration: cp.celebration, spoken: cp.spoken);
}
