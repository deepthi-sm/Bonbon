import 'package:bonbon/activities/contract.dart';
import 'package:bonbon/activities/fixtures.dart';
import 'package:bonbon/activities/repair_ladder.dart';
import 'package:bonbon/activities/seed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('seed', () {
    test('fnv1a matches the published 32-bit test vectors', () {
      expect(fnv1a(''), 0x811c9dc5);
      expect(fnv1a('a'), 0xe40c292c);
      expect(fnv1a('foobar'), 0xbf9cf968);
    });

    test('same lesson, type and index give the same seed', () {
      expect(itemSeed('L08', 'tap-identify', 0), itemSeed('L08', 'tap-identify', 0));
      expect(itemSeed('L08', 'tap-identify', 0), isNot(itemSeed('L08', 'tap-identify', 1)));
      expect(itemSeed('L08', 'tap-identify', 0), isNot(itemSeed('L09', 'tap-identify', 0)));
    });

    test('same seed gives the same shuffle', () {
      List<int> run() {
        final l = [for (var i = 0; i < 12; i++) i];
        SeededRng(itemSeed('L12', 'listen-choose', 3)).shuffle(l);
        return l;
      }

      expect(run(), run());
      expect(run(), isNot([for (var i = 0; i < 12; i++) i]));
    });

    test('nextInt stays in range', () {
      final rng = SeededRng(0); // zero seed is replaced, never stuck at 0
      for (var i = 0; i < 1000; i++) {
        expect(rng.nextInt(7), inInclusiveRange(0, 6));
      }
    });
  });

  group('repair ladder', () {
    test('four rungs with the hint costs of repair-ladder.json', () {
      expect([for (final r in RepairLadder.rungs) r.hintCost], [0, 0.25, 0.5, 1.0]);
      expect(RepairLadder.rungFor(1).action, RepairAction.replayTarget);
      expect(RepairLadder.rungFor(4).action, RepairAction.giveAndGo);
      expect(RepairLadder.rungFor(9).action, RepairAction.giveAndGo, reason: 'never a dead end');
    });

    test('rung 3 says the answer between fixed sentences', () {
      expect(RepairLadder.spokenFor(RepairLadder.rungFor(3), 'ta'),
          [RepairLadder.sayLook, 'ta', RepairLadder.sayListen, 'ta']);
    });

    test('narrowing keeps the answer and one other option, reproducibly', () {
      final item = listenChooseL08.items.first;
      final kept = RepairLadder.narrow(item, 42);
      expect(kept, hasLength(2));
      expect(kept, contains(item.answer));
      expect(RepairLadder.narrow(item, 42), kept);
    });

    test('narrowing prefers to fade options already tapped wrong', () {
      final item = listenChooseL08.items.first; // to, ta, ti
      for (var seed = 0; seed < 20; seed++) {
        final kept = RepairLadder.narrow(item, seed, alreadyWrong: {const Choice('to', 'to')});
        expect(kept, {const Choice('ta', 'ta'), const Choice('ti', 'ti')});
      }
    });
  });

  group('result', () {
    test('first-try answers pass', () {
      final r = ActivityResult(listenChooseL08, const [
        ItemResult(itemIndex: 0, target: 'ta', wrongAttempts: 0),
        ItemResult(itemIndex: 1, target: 'tu', wrongAttempts: 0),
      ]);
      expect(r.score, 1);
      expect(r.passed, isTrue);
      expect(r.firstTryCount, 2);
      expect(r.reviewTargets, isEmpty);
    });

    test('without partial credit only first tries count', () {
      final r = ActivityResult(listenChooseL08, const [
        ItemResult(itemIndex: 0, target: 'ta', wrongAttempts: 0),
        ItemResult(itemIndex: 1, target: 'tu', wrongAttempts: 1),
      ]);
      expect(r.score, 0.5);
      expect(r.passed, isFalse);
    });

    test('with partial credit hints cost what the ladder says', () {
      final r = ActivityResult(syllableBuildL08, const [ItemResult(itemIndex: 0, target: 'ta', wrongAttempts: 2)]);
      expect(r.score, 0.75);
      expect(r.passed, isTrue, reason: 'syllable-build passes at 0.60');
    });

    test('an answer given by the app sends the target to review', () {
      final r = ActivityResult(tapIdentifyL08, const [ItemResult(itemIndex: 0, target: 't', wrongAttempts: 4)]);
      expect(r.score, 0);
      expect(r.reviewTargets, ['t']);
    });

    test('a skipped activity never passes and is reported as skipped', () {
      final r = ActivityResult.skippedBy(traceL01, SkipReason.user);
      expect(r.passed, isFalse);
      expect(r.toJson()['skipped'], 'user');
    });
  });

  group('fixtures', () {
    test('one fixture per MVP type', () {
      expect({for (final f in allFixtures) f.type}, ActivityType.values.toSet());
    });

    test('every choice item has its answer among the options', () {
      for (final spec in allFixtures) {
        for (final item in spec.items) {
          if (spec.type == ActivityType.trace) continue;
          expect(item.options.where(item.isCorrect), isNotEmpty, reason: '${spec.id} item ${item.index}');
        }
      }
    });

    test('type keys round-trip', () {
      for (final t in ActivityType.values) {
        expect(ActivityType.fromKey(t.key), t);
      }
    });
  });
}
