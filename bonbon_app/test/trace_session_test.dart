import 'package:bonbon/activities/fixtures.dart';
import 'package:bonbon/activities/repair_ladder.dart';
import 'package:bonbon/activities/trace_session.dart';
import 'package:bonbon/data/phrases.dart';
import 'package:bonbon/screens/trace_score.dart';
import 'package:flutter_test/flutter_test.dart';

const good = TraceResult(3, 0.95, 0.95, 0.9);
const almost = TraceResult(2, 0.8, 0.6, 0.5);
const offTrack = TraceResult(1, 0.4, 0.3, 0.2);
const noDot = TraceResult(1, 0.9, 0.85, 0.1); // the stem of i, but not its dot
const short = TraceResult(1, 0.8, 0.3, 0.2); // on the letter, but only a bit of it

void main() {
  test('asks with the instruction, then the letter', () {
    expect(TraceSession(traceL01).askParts, [P.traceEmpty, 'i']);
  });

  test('three stars on the first try: done, full credit, praised', () {
    final s = TraceSession(traceL01);
    final out = s.check(good)!;
    expect(out.itemDone, isTrue);
    expect(out.say, [P.trace[3]]);
    s.next();
    expect(s.finished, isTrue);
    expect(s.result.score, 1);
    expect(s.result.passed, isTrue);
    expect(s.result.firstTryCount, 1);
  });

  test('two stars is enough to go on, and passes (0.67 ≥ 0.55)', () {
    final s = TraceSession(traceL01);
    expect(s.check(almost)!.itemDone, isTrue);
    s.next();
    expect(s.result.score, closeTo(2 / 3, 1e-9));
    expect(s.result.passed, isTrue);
  });

  test('the cue matches what went wrong', () {
    expect(TraceSession.cueFor(noDot), TraceSession.cueStrokeMissing);
    expect(TraceSession.cueFor(offTrack), TraceSession.cueTooFast);
    expect(TraceSession.cueFor(short), P.trace[0]);
  });

  test('a low attempt gives a cue and another go', () {
    final s = TraceSession(traceL01);
    final out = s.check(noDot)!;
    expect(out.itemDone, isFalse);
    expect(out.say, [TraceSession.cueStrokeMissing]);
    expect(s.attempt, 2);
  });

  test('a good second attempt counts, but not as first try', () {
    final s = TraceSession(traceL01);
    s.check(offTrack);
    s.check(good);
    s.next();
    expect(s.result.score, 1, reason: 'the trace is measured, not hint-costed');
    expect(s.result.firstTryCount, 0);
    expect(s.result.items.single.wrongAttempts, 1);
  });

  test('after three low attempts the model lights up and she moves on: never blocked', () {
    final s = TraceSession(traceL01);
    s.check(offTrack);
    s.check(offTrack);
    final out = s.check(offTrack)!;
    expect(out.itemDone, isTrue);
    expect(out.modelShown, isTrue);
    expect(out.say, ['i', RepairLadder.sayMoveOn]);
    expect(s.check(good), isNull, reason: 'the letter is done');
    s.next();
    expect(s.finished, isTrue);
    expect(s.result.score, 0);
    expect(s.result.reviewTargets, ['i']);
  });
}
