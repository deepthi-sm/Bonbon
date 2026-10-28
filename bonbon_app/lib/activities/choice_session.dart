/// The rules of a tap-identify / listen-choose / syllable-build activity
/// (all three are "pick the right option"), without the screen:
/// which cells are found, faded or highlighted, what to say, and when an
/// item is done. The widget (choice_activity.dart) only draws this state and
/// plays [TapOutcome.say]. Pure Dart, so every repair-ladder path is tested.
library;

import '../data/phrases.dart';
import 'contract.dart';
import 'repair_ladder.dart';
import 'seed.dart';

class TapOutcome {
  final bool correct;

  /// The repair rung reached by this wrong tap; null when [correct].
  final RepairRung? rung;

  /// The current item is finished; call [ChoiceSession.next] after speaking.
  final bool itemDone;

  /// Sentences to play, in order.
  final List<String> say;

  const TapOutcome({required this.correct, this.rung, this.itemDone = false, this.say = const []});
}

class ChoiceSession {
  final ActivitySpec spec;
  ChoiceSession(this.spec) : assert(spec.items.isNotEmpty);

  int _index = 0;
  int _wrong = 0;
  bool _itemDone = false;
  final List<ItemResult> _results = [];

  /// Cells (indexes into item.options) in each state, for the current item.
  final Set<int> found = {};
  final Set<int> wrongCells = {};
  final Set<int> faded = {};

  /// Rung 3: the remaining correct cells are lit up.
  bool modelShown = false;

  int get index => _index;
  int get total => spec.items.length;
  bool get finished => _index >= total;
  ActivityItem get item => spec.items[_index];
  List<ItemResult> get results => List.unmodifiable(_results);

  ActivityResult get result => ActivityResult(spec, _results);

  /// What to say when the item is asked (and when the prompt is tapped).
  List<String> get askParts => item.listen ? [item.prompt, item.heard] : [item.prompt];

  Iterable<int> get _correctCells => [
        for (var c = 0; c < item.options.length; c++)
          if (item.isCorrect(item.options[c])) c,
      ];

  bool canTap(int cell) =>
      !finished && !_itemDone && !found.contains(cell) && !wrongCells.contains(cell) && !faded.contains(cell);

  /// Null when the tap is ignored (cell already used, item waiting for [next]).
  TapOutcome? tap(int cell) {
    if (!canTap(cell)) return null;
    final it = item;
    if (it.isCorrect(it.options[cell])) {
      found.add(cell);
      if (found.length < _correctCells.length) return TapOutcome(correct: true, say: [it.answer.speech]);
      return TapOutcome(correct: true, itemDone: _finishItem(), say: [_praise(), it.blend ?? it.heard]);
    }

    _wrong++;
    wrongCells.add(cell);
    final rung = RepairLadder.rungFor(_wrong);
    switch (rung.action) {
      case RepairAction.replayTarget:
        break;
      case RepairAction.narrow:
        final keep = RepairLadder.narrow(
          it,
          itemSeed(spec.lessonKey, '${spec.type.key}/narrow', it.index),
          alreadyWrong: {for (final c in wrongCells) it.options[c]},
        );
        for (var c = 0; c < it.options.length; c++) {
          if (!keep.contains(it.options[c]) && !wrongCells.contains(c)) faded.add(c);
        }
      case RepairAction.model:
        modelShown = true;
      case RepairAction.giveAndGo:
        found.addAll(_correctCells);
        return TapOutcome(correct: false, rung: rung, itemDone: _finishItem(), say: RepairLadder.spokenFor(rung, it.heard));
    }
    return TapOutcome(correct: false, rung: rung, say: RepairLadder.spokenFor(rung, it.heard));
  }

  bool _finishItem() {
    _results.add(ItemResult(itemIndex: item.index, target: item.target, wrongAttempts: _wrong));
    _itemDone = true;
    return true;
  }

  /// Move to the next item once the current one is done.
  void next() {
    if (!_itemDone) return;
    _index++;
    _wrong = 0;
    _itemDone = false;
    modelShown = false;
    found.clear();
    wrongCells.clear();
    faded.clear();
  }

  String _praise() => P.praise[SeededRng(itemSeed(spec.lessonKey, '${spec.type.key}/praise', item.index)).nextInt(P.praise.length)];
}
