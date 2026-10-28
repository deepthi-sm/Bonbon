import 'package:bonbon/activities/choice_session.dart';
import 'package:bonbon/activities/contract.dart';
import 'package:bonbon/activities/fixtures.dart';
import 'package:bonbon/activities/repair_ladder.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cell indexes of the item's correct and wrong options.
List<int> rightCells(ChoiceSession s) => [for (var c = 0; c < s.item.options.length; c++) if (s.item.isCorrect(s.item.options[c])) c];
List<int> wrongCells(ChoiceSession s) => [for (var c = 0; c < s.item.options.length; c++) if (!s.item.isCorrect(s.item.options[c])) c];

/// A wrong cell that can still be tapped.
int nextWrong(ChoiceSession s) => wrongCells(s).firstWhere(s.canTap);

void main() {
  test('right first time: item done, praised, scored on the first try', () {
    final s = ChoiceSession(listenChooseL08);
    final out = s.tap(rightCells(s).single)!;
    expect(out.correct, isTrue);
    expect(out.itemDone, isTrue);
    expect(out.say.last, 'ta');
    s.next();
    expect(s.index, 1);
    expect(s.results.single.firstTry, isTrue);
  });

  test('wrong once: replays the target, does not show the answer', () {
    final s = ChoiceSession(listenChooseL08);
    final out = s.tap(nextWrong(s))!;
    expect(out.rung!.action, RepairAction.replayTarget);
    expect(out.say, [RepairLadder.sayListenAgain, 'ta']);
    expect(s.modelShown, isFalse);
    expect(s.faded, isEmpty);
  });

  test('wrong twice: options narrow to the answer and one other', () {
    final s = ChoiceSession(tapIdentifyL08); // 6 cells, 2 targets
    s.tap(nextWrong(s));
    final out = s.tap(nextWrong(s))!;
    expect(out.rung!.action, RepairAction.narrow);
    final open = {for (var c = 0; c < 6; c++) if (s.canTap(c)) s.item.options[c].show};
    expect(open, hasLength(2));
    expect(open, contains('t'));
  });

  test('wrong three times: the answer is lit up', () {
    final s = ChoiceSession(tapIdentifyL08);
    for (var k = 0; k < 3; k++) {
      s.tap(nextWrong(s));
    }
    expect(s.modelShown, isTrue);
  });

  test('a tapped or faded cell is ignored', () {
    final s = ChoiceSession(listenChooseL08);
    final c = nextWrong(s);
    s.tap(c);
    expect(s.tap(c), isNull);
  });

  test('tap-identify needs every target found, partial credit after hints', () {
    final s = ChoiceSession(tapIdentifyL08);
    s.tap(nextWrong(s));
    s.tap(nextWrong(s)); // rung 2: hint cost 0.25
    final [a, b] = rightCells(s);
    expect(s.tap(a)!.itemDone, isFalse);
    expect(s.tap(b)!.itemDone, isTrue);
    s.next();
    expect(s.finished, isTrue);
    expect(s.result.score, 0.75);
    expect(s.result.passed, isFalse, reason: 'tap-identify passes at 0.80');
    expect(s.result.reviewTargets, isEmpty);
  });

  test('with narrowing, the third wrong tap is the last one possible', () {
    // A grid with enough wrong cells to reach rung 4.
    const spec = ActivitySpec(lessonKey: 'L08', type: ActivityType.tapIdentify, items: [
      ActivityItem(
        index: 0,
        prompt: 'Touche la lettre t',
        target: 't',
        answer: Choice('t', 't'),
        listen: false,
        options: [Choice('t', 't'), Choice('i', 'i'), Choice('o', 'o'), Choice('a', 'a'), Choice('u', 'u'), Choice('e', 'e')],
      ),
    ]);
    final s = ChoiceSession(spec);
    TapOutcome? last;
    // Rung 2 fades all but one wrong cell, so tap whatever wrong cell is left each time.
    for (var k = 0; k < 4 && !s.finished; k++) {
      final open = wrongCells(s).where(s.canTap).toList();
      if (open.isEmpty) break;
      last = s.tap(open.first);
    }
    // With rung 2 narrowing to 2 cells, rung 3 is the last wrong tap possible.
    expect(last!.rung!.action, RepairAction.model);
    expect(s.tap(rightCells(s).single)!.itemDone, isTrue);
    s.next();
    expect(s.result.items.single.wrongAttempts, 3);
    expect(s.result.score, 0.5);
  });

  test('rung 4 is reached when wrong cells stay open, and never dead-ends', () {
    final s = ChoiceSession(listenChooseL08);
    // Force four wrong attempts by clearing fades, as a learner with a
    // different screen state could: the ladder must still end the item.
    for (var k = 0; k < 4; k++) {
      s.faded.clear();
      s.wrongCells.clear();
      final out = s.tap(wrongCells(s).first)!;
      if (k == 3) {
        expect(out.rung!.action, RepairAction.giveAndGo);
        expect(out.itemDone, isTrue);
        expect(out.say, [RepairLadder.sayMoveOn]);
      }
    }
    s.next();
    expect(s.results.single.givenByApp, isTrue);
  });

  test('finishing every item gives a full result', () {
    final s = ChoiceSession(listenChooseL08);
    while (!s.finished) {
      s.tap(rightCells(s).single);
      s.next();
    }
    expect(s.result.score, 1);
    expect(s.result.passed, isTrue);
    expect(s.result.firstTryCount, 2);
  });
}
