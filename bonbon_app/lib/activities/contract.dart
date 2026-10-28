/// The activity contract (plan §R.2 task B1, §H.2): what the lesson hands to
/// an activity ([ActivitySpec]) and what the activity hands back for progress
/// ([ActivityResult]). Pure Dart — no Flutter import — so it can be tested
/// without a screen and shared with Dev A (lessons) and Dev D (progress).
library;

import 'repair_ladder.dart';

/// The five MVP activity types (plan §J.2). Pass thresholds and partial
/// credit come from docs/batonga-addon-packs/.../02-exercices/generators.json.
enum ActivityType {
  tapIdentify('tap-identify', pass: 0.80, partialCredit: true),
  listenChoose('listen-choose', pass: 0.75, partialCredit: false),
  syllableBuild('syllable-build', pass: 0.60, partialCredit: true),
  missingLetter('missing-letter', pass: 0.70, partialCredit: false),
  trace('trace', pass: 0.55, partialCredit: true);

  /// The key used in the JSON packs and in the item seed.
  final String key;
  final double pass;
  final bool partialCredit;
  const ActivityType(this.key, {required this.pass, required this.partialCredit});

  static ActivityType? fromKey(String key) => values.where((t) => t.key == key).firstOrNull;
}

/// One thing the learner can tap or hear: what is shown and what is spoken.
class Choice {
  final String show, speech;
  final bool cursive;
  const Choice(this.show, this.speech, {this.cursive = false});

  @override
  bool operator ==(Object other) =>
      other is Choice && other.show == show && other.speech == speech && other.cursive == cursive;

  @override
  int get hashCode => Object.hash(show, speech, cursive);

  Map<String, Object?> toJson() => {'show': show, 'speech': speech, if (cursive) 'cursive': true};
}

/// One question inside an activity.
class ActivityItem {
  final int index;

  /// Spoken + written instruction. Must be a fixed sentence or content text,
  /// so it has a recording (see lib/data/phrases.dart).
  final String prompt;

  /// What this item gives mastery evidence for: a letter, syllable or word.
  final String target;

  /// The correct choice. In tap-identify it may appear several times in [options].
  final Choice answer;
  final List<Choice> options;

  /// true: the learner hears [answer] and picks it; false: she reads the prompt.
  final bool listen;

  /// missing-letter: the full word and the index of the blank.
  /// syllable-build: the syllable to build, and [fixed] is the consonant tile.
  final String? word;
  final int? blankAt;
  final String? fixed;

  const ActivityItem({
    required this.index,
    required this.prompt,
    required this.target,
    required this.answer,
    this.options = const [],
    this.listen = true,
    this.word,
    this.blankAt,
    this.fixed,
  });

  bool isCorrect(Choice c) => c.show == answer.show;
}

/// Everything an activity needs to run, with no reference to the rest of the app.
class ActivitySpec {
  final String lessonKey; // "L08" or "N3", as in Lesson.key
  final ActivityType type;
  final int tier; // 1..3, the difficulty ladder in generators.json
  final List<ActivityItem> items;

  /// Tells apart two activities of the same type in one lesson, e.g.
  /// listen-choose on syllables and on words ("syllable", "word").
  final String? variant;

  /// Always true in the MVP (plan §J.3 rule 4): she can always move on.
  final bool allowSkip;

  const ActivitySpec({
    required this.lessonKey,
    required this.type,
    required this.items,
    this.tier = 1,
    this.variant,
    this.allowSkip = true,
  }) : assert(tier >= 1 && tier <= 3);

  String get id => variant == null ? '$lessonKey:${type.key}' : '$lessonKey:${type.key}/$variant';
}

/// How one item went. Built by the activity as the learner answers.
class ItemResult {
  final int itemIndex;
  final String target;

  /// Wrong answers before the right one (0 = right on the first try).
  final int wrongAttempts;

  const ItemResult({required this.itemIndex, required this.target, required this.wrongAttempts})
      : assert(wrongAttempts >= 0);

  bool get firstTry => wrongAttempts == 0;

  /// The app answered for her (repair ladder rung 4).
  bool get givenByApp => wrongAttempts >= RepairLadder.rungs.length;

  /// Hint cost of the highest rung reached (repair-ladder.json).
  double get hintCost => wrongAttempts == 0 ? 0 : RepairLadder.rungFor(wrongAttempts).hintCost;

  /// 0..1. With partial credit, hints cost what the ladder says; without it,
  /// only a first-try answer counts.
  double credit(ActivityType type) => type.partialCredit ? 1 - hintCost : (firstTry ? 1 : 0);

  Map<String, Object?> toJson() => {'item': itemIndex, 'target': target, 'wrong': wrongAttempts};
}

enum SkipReason { user, timeout }

/// What an activity hands back. Dev D's progress code records it; nothing
/// here ever blocks the next lesson (plan §U.4, §U.5).
class ActivityResult {
  final ActivitySpec spec;
  final List<ItemResult> items;
  final SkipReason? skipped;

  const ActivityResult(this.spec, this.items, {this.skipped});

  ActivityResult.skippedBy(this.spec, SkipReason reason)
      : items = const [],
        skipped = reason;

  /// Mean credit over the answered items; 0 when nothing was answered.
  double get score =>
      items.isEmpty ? 0 : items.map((i) => i.credit(spec.type)).reduce((a, b) => a + b) / items.length;

  bool get passed => skipped == null && score >= spec.type.pass;

  /// Right on the first try — what the current AppState.completeLesson(correct:) counts.
  int get firstTryCount => items.where((i) => i.firstTry).length;

  /// Targets the app had to answer for her. They go to the review queue at
  /// strength 0.15 (repair-ladder.json, rung 4).
  List<String> get reviewTargets => [for (final i in items) if (i.givenByApp) i.target];

  Map<String, Object?> toJson() => {
        'activity': spec.id,
        'lesson': spec.lessonKey,
        'type': spec.type.key,
        'tier': spec.tier,
        'score': score,
        'passed': passed,
        if (skipped != null) 'skipped': skipped!.name,
        'items': [for (final i in items) i.toJson()],
      };
}
