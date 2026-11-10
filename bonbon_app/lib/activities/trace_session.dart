/// The rules of a trace activity, without the screen: how many attempts,
/// what to say after each, when a letter is done and what it scores. The
/// widget (trace_activity.dart) draws and measures; this decides. Pure Dart.
///
/// An attempt arrives as a [TraceCheck]: from the stroke-path scoring
/// (stroke_score.dart, when the glyph has a GlyphSpec) or, until Dev A's
/// stroke data exists, from the prototype's coverage scoring
/// (lib/screens/trace_score.dart).
library;

import '../data/phrases.dart';
import '../screens/trace_score.dart';
import 'contract.dart';
import 'repair_ladder.dart';
import 'stroke_score.dart';
import 'trace_rubric.dart';

/// One checked attempt, whichever scoring measured it.
class TraceCheck {
  final int stars; // 1..3
  final double quality; // 0..1, the item's credit when it is kept
  final String cue; // said after a low attempt
  final String praise; // said after a good one
  const TraceCheck(this.stars, this.quality, {required this.cue, required this.praise});

  /// The prototype's coverage scoring: no stroke data needed.
  factory TraceCheck.coverage(TraceResult r) =>
      TraceCheck(r.stars, r.stars / 3, cue: TraceSession.cueFor(r), praise: r.stars == 3 ? P.trace[3] : P.trace[2]);

  /// The rubric's stroke-path scoring, with the cue for what went wrong (B15).
  factory TraceCheck.strokes(StrokeScore s, TraceRubric rubric) => TraceCheck(
        s.stars,
        s.total.clamp(0, 1).toDouble(),
        cue: rubric.cues[s.cueKey == 'good' ? 'missedCheckpoint' : s.cueKey]!,
        praise: s.stars == 3 ? rubric.cues['good']! : P.trace[2],
      );
}

class TraceOutcome {
  /// The letter is finished; call [TraceSession.next] when she continues.
  final bool itemDone;

  /// The app lit up the model and moved on for her.
  final bool modelShown;

  final List<String> say;
  const TraceOutcome({required this.itemDone, this.modelShown = false, required this.say});
}

class TraceSession {
  /// trace-rubric.json, hardRule: after three attempts, show the model and move on.
  static const maxAttempts = 3;

  /// Spoken cues (trace-rubric.json, spokenCues), each matched to what went wrong.
  static const cueStrokeMissing = 'Il manque un trait.';
  static const cueTooFast = 'Doucement, suis le trait.';

  final ActivitySpec spec;
  TraceSession(this.spec) : assert(spec.items.isNotEmpty);

  int _index = 0;
  int _failed = 0;
  bool _itemDone = false;
  bool modelShown = false;
  int? stars; // of the last attempt
  final List<ItemResult> _results = [];

  int get index => _index;
  int get total => spec.items.length;
  bool get finished => _index >= total;
  ActivityItem get item => spec.items[_index];
  int get attempt => _failed + 1;
  bool get itemDone => _itemDone;
  List<ItemResult> get results => List.unmodifiable(_results);
  ActivityResult get result => ActivityResult(spec, _results);

  List<String> get askParts => [item.prompt, item.heard];

  /// The cue for an attempt that scored too low, from what it missed.
  static String cueFor(TraceResult r) {
    if (r.coverage >= 0.5 && r.worstShape < 0.5) return cueStrokeMissing; // the dot of i, an accent
    if (r.precision < 0.75) return cueTooFast; // drifted off the model
    return P.trace[0]; // « Pas encore. Commence en haut et suis le modèle. »
  }

  /// Records one checked attempt. Null when the letter is already done.
  TraceOutcome? check(TraceCheck c) {
    if (finished || _itemDone) return null;
    stars = c.stars;
    if (c.stars >= 2) {
      _finish(quality: c.quality);
      return TraceOutcome(itemDone: true, say: [c.praise]);
    }
    _failed++;
    if (_failed < maxAttempts) return TraceOutcome(itemDone: false, say: [c.cue]);
    modelShown = true;
    _finish(givenByApp: true);
    return TraceOutcome(itemDone: true, modelShown: true, say: [item.heard, RepairLadder.sayMoveOn]);
  }

  /// She cleared the pad to draw again.
  void clear() => stars = null;

  void _finish({double? quality, bool? givenByApp}) {
    _results.add(ItemResult(
      itemIndex: item.index,
      target: item.target,
      wrongAttempts: _failed,
      quality: quality,
      givenByApp: givenByApp,
    ));
    _itemDone = true;
  }

  void next() {
    if (!_itemDone) return;
    _index++;
    _failed = 0;
    _itemDone = false;
    modelShown = false;
    stars = null;
  }
}
