/// The repair ladder (plan §U.4, repair-ladder.json, task B10): what happens
/// after each wrong answer. Four rungs, then always forward — there is no
/// failure state. Pure logic; every activity's screen uses it the same way.
///
/// Never: buzzer, red cross, lives, timer, negative score, a message naming
/// failure, or blocking the next lesson.
library;

import 'contract.dart';
import 'seed.dart';

enum RepairAction {
  replayTarget, // rung 1: play the target again, do NOT show the answer
  narrow, // rung 2: fade options out until two remain
  model, // rung 3: light up the answer and play it
  giveAndGo, // rung 4: answer for her and move on; target goes to review
}

class RepairRung {
  final int attempt;
  final RepairAction action;
  final double hintCost;

  /// Fixed sentences only, so each one can be recorded. Rung 3 says the
  /// answer between them: see [RepairLadder.spokenFor].
  final List<String> spoken;

  const RepairRung(this.attempt, this.action, this.hintCost, this.spoken);
}

class RepairLadder {
  /// repair-ladder.json says « Écoute encore. »; this is the recorded line
  /// from the team's repair bank (fb.repair.01, also P.repair[0]).
  static const sayListenAgain = 'Pas encore. Écoute encore.';
  static const sayOneOfTwo = 'Écoute bien. C\'est l\'un des deux.';
  static const sayLook = 'Regarde, c\'est :';
  static const sayListen = 'Écoute :'; // same sentence as P.listenAgain
  static const sayMoveOn = 'On continue. Tu la reverras.';

  static const rungs = [
    RepairRung(1, RepairAction.replayTarget, 0, [sayListenAgain]),
    RepairRung(2, RepairAction.narrow, 0.25, [sayOneOfTwo]),
    RepairRung(3, RepairAction.model, 0.5, [sayLook, sayListen]),
    RepairRung(4, RepairAction.giveAndGo, 1.0, [sayMoveOn]),
  ];

  /// Every sentence the ladder speaks, for the recording script.
  static const sentences = [sayListenAgain, sayOneOfTwo, sayLook, sayListen, sayMoveOn];

  /// The rung after [wrongAttempts] wrong answers (1-based; stays on rung 4).
  static RepairRung rungFor(int wrongAttempts) {
    if (wrongAttempts < 1) throw ArgumentError.value(wrongAttempts, 'wrongAttempts', 'must be ≥ 1');
    return rungs[(wrongAttempts > rungs.length ? rungs.length : wrongAttempts) - 1];
  }

  /// What to say on [rung] for an item whose answer is spoken as [answer].
  /// Every rung plays the right answer (repair-ladder.json: « On joue
  /// TOUJOURS la bonne réponse »), rung 4 too, as it fills it in for her.
  static List<String> spokenFor(RepairRung rung, String answer) => switch (rung.action) {
        RepairAction.replayTarget => [sayListenAgain, answer],
        RepairAction.narrow => [sayOneOfTwo, answer],
        RepairAction.model => [sayLook, answer, sayListen, answer],
        RepairAction.giveAndGo => [answer, sayMoveOn],
      };

  /// Rung 2: the options still shown — the answer and one other, chosen
  /// reproducibly from [seed]. Options already shown wrong are faded first.
  static Set<Choice> narrow(ActivityItem item, int seed, {Set<Choice> alreadyWrong = const {}}) {
    final others = item.options.where((o) => !item.isCorrect(o)).toSet().toList();
    if (others.isEmpty) return {item.answer};
    final fresh = others.where((o) => !alreadyWrong.contains(o)).toList();
    final pool = fresh.isEmpty ? others : fresh;
    return {item.answer, SeededRng(seed).pick(pool)};
  }
}
