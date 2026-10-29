import 'package:bonbon/activities/contract.dart';
import 'package:bonbon/activities/confusion.dart';
import 'package:bonbon/activities/generators.dart';
import 'package:bonbon/activities/ledger.dart';
import 'package:bonbon/activities/repair_ladder.dart';
import 'package:bonbon/data/content.dart';
import 'package:bonbon/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ContentRepo repo;
  setUpAll(() async => repo = await ContentRepo.load());

  String dump(ActivitySpec s) => [
        s.id,
        for (final i in s.items) '${i.target}|${i.answer.show}|${i.options.map((o) => o.show).join(',')}',
      ].join('\n');

  test('same lesson gives identical items every time', () {
    for (final l in repo.lessons) {
      expect(specsFor(l, repo).map(dump).toList(), specsFor(l, repo).map(dump).toList(), reason: l.key);
    }
  });

  test('every lesson gets at least one activity, and ids are unique within it', () {
    for (final l in repo.lessons) {
      final specs = specsFor(l, repo);
      expect(specs, isNotEmpty, reason: l.key);
      expect(specs.map((s) => s.id).toSet().length, specs.length, reason: l.key);
    }
  });

  test('every item has its answer among the options, and listen-choose options are distinct', () {
    for (final l in repo.lessons) {
      for (final s in specsFor(l, repo).where((s) => s.type != ActivityType.trace)) {
        for (final i in s.items) {
          final hits = i.options.where(i.isCorrect).length;
          if (s.type == ActivityType.tapIdentify) {
            expect(i.options, hasLength(6), reason: s.id);
            expect(hits, 2, reason: '${s.id}: tier 1 grid holds the target twice');
          } else {
            expect(hits, 1, reason: s.id);
            expect(i.options.map((o) => o.show).toSet().length, i.options.length, reason: '${s.id}: duplicates');
            expect(i.options.length, inInclusiveRange(3, 4), reason: s.id);
          }
        }
      }
    }
  });

  test('listen-choose on syllables and words only uses the lesson\'s own items', () {
    for (final l in repo.lessons) {
      final own = {...l.syllables.map((x) => x.text), ...l.words.map((x) => x.text)};
      for (final s in specsFor(l, repo).where((s) => s.variant == 'syllable' || s.variant == 'word')) {
        for (final i in s.items) {
          expect(own, containsAll(i.options.map((o) => o.show)), reason: s.id);
        }
      }
    }
  });

  // Task B9's acceptance test: no generated item ever uses an out-of-ledger
  // symbol, across every lesson, every tier and every activity type.
  test('no item ever shows a symbol she has not been taught: all lessons × tiers × types', () {
    var checked = 0;
    for (final l in repo.lessons) {
      final ledger = ledgerAt(l.key);
      final own = {...l.syllables.map((x) => x.text), ...l.words.map((x) => x.text)};
      for (var tier = 1; tier <= 3; tier++) {
        for (final s in specsFor(l, repo, tier: tier)) {
          expect(s.tier, tier, reason: s.id);
          for (final i in s.items) {
            final why = '${s.id} tier $tier « ${i.target} »';
            final shown = switch ((s.type, s.variant)) {
              (ActivityType.tapIdentify, _) => i.options.map((o) => o.speech),
              (ActivityType.listenChoose, 'syllable' || 'word') => const <String>[], // checked against `own` below
              (ActivityType.trace, _) => [i.answer.show.toLowerCase()],
              _ => i.options.map((o) => o.show),
            };
            expect(ledger, containsAll(shown.toSet()), reason: why);
            if (s.variant == 'syllable' || s.variant == 'word') expect(own, containsAll(i.options.map((o) => o.show)), reason: why);
            if (s.type == ActivityType.syllableBuild) {
              expect(own, containsAll(i.options.map((o) => '${i.fixed}${o.show}')), reason: why);
            }
            // confusion-matrix.json: at most one grapheme-length distractor per item in units 1–2.
            if (l.unit == UnitKind.vowels || l.unit == UnitKind.consonants) {
              expect(i.options.where((o) => !i.isCorrect(o) && o.show.length > 1 && s.variant == null), hasLength(lessThanOrEqualTo(1)), reason: why);
            }
            checked++;
          }
        }
      }
    }
    expect(checked, greaterThan(1000));
  });

  test('tier parameters follow generators.json', () {
    final l16 = repo.byKey('L16')!; // b
    for (final (tier, grid, targets) in [(1, 6, 2), (2, 9, 3), (3, 12, 3)]) {
      for (final i in tapIdentify(l16, tier: tier)!.items) {
        expect(i.options, hasLength(grid), reason: 'tier $tier');
        expect(i.options.where(i.isCorrect), hasLength(targets), reason: 'tier $tier');
      }
    }
    final l08 = repo.byKey('L08')!;
    for (final (tier, rounds, tiles) in [(1, 4, 4), (2, 5, 6), (3, 6, 8)]) {
      final s = syllableBuild(l08, tier: tier)!;
      expect(s.items, hasLength(rounds), reason: 'tier $tier');
      expect(s.items.first.options, hasLength(tiles), reason: 'tier $tier');
    }
    for (final (tier, n) in [(1, 3), (2, 4), (3, 4)]) {
      expect(missingLetter(repo.byKey('L11')!, tier: tier)!.items.first.options, hasLength(n), reason: 'tier $tier');
    }
    expect([for (var t = 1; t <= 3; t++) traceTolerance(t)], [1.4, 1.0, 0.8]);
    expect([for (var t = 1; t <= 3; t++) traceGhost(t)], [true, true, false]);
  });

  test('tier 3 mixes print and cursive in one tap-identify grid', () {
    final items = tapIdentify(repo.byKey('L16')!, tier: 3)!.items;
    expect(items.any((i) => i.options.map((o) => o.cursive).toSet().length == 2), isTrue);
  });

  test('from tier 2, a taught confusion-matrix neighbour is always offered', () {
    for (final l in repo.lessons.where((l) => l.unit == UnitKind.consonants)) {
      for (final i in tapIdentify(l, tier: 2)?.items ?? const <ActivityItem>[]) {
        final near = (visualConfusion[i.target] ?? const []).where(distractorLetters(l).contains);
        if (near.isEmpty) continue;
        expect(i.options.map((o) => o.speech), contains(isIn(near)), reason: '${l.key} ${i.target}');
      }
      final drill = l.syllables.map((x) => x.text).toSet();
      final syl = specsFor(l, repo, tier: 2).where((s) => s.variant == 'syllable').firstOrNull;
      for (final i in syl?.items ?? const <ActivityItem>[]) {
        if (!drill.any((x) => soundsNear(i.target, x))) continue;
        expect(i.options.any((o) => soundsNear(i.target, o.show)), isTrue, reason: '${l.key} « ${i.target} »');
      }
    }
  });

  test('tier 3 listen-choose asks words, not syllables', () {
    final l08 = repo.byKey('L08')!;
    final variants = specsFor(l08, repo, tier: 3).where((s) => s.type == ActivityType.listenChoose).map((s) => s.variant);
    expect(variants, ['word']);
  });

  test('items with no recording are dropped when a check is given', () {
    final l08 = repo.byKey('L08')!;
    final drills = l08.blocks.where((b) => b.type == 'syllable_drill').toList();
    final none = specsAfter('syllable_drill', drills, l08, repo, hasAudio: (_) => false);
    expect(none, isEmpty, reason: 'a silent listening exercise is worse than a missing one');
    final some = specsAfter('syllable_drill', drills, l08, repo, hasAudio: (t) => t != 'ta');
    for (final s in some) {
      expect(s.items.map((i) => i.target), isNot(contains('ta')), reason: s.id);
    }
  });

  test('repair ladder: which sentences are recorded', () async {
    final speech = await Speech.load();
    final missing = RepairLadder.sentences.where((s) => !speech.has(s)).toList();
    // Rungs 2 and 3 still need recording (docs/activity-catalogue.md, open points).
    expect(missing, unorderedEquals([RepairLadder.sayOneOfTwo, RepairLadder.sayLook]));
  });

  group('trace', () {
    ActivitySpec? of(Lesson l) => specsFor(l, repo).where((s) => s.type == ActivityType.trace).firstOrNull;

    test('every vowel, consonant and digit lesson gets one, grapheme lessons don\'t', () {
      for (final l in repo.lessons) {
        expect(of(l) != null, l.unit != UnitKind.graphemes, reason: l.key);
      }
    });

    test('only single glyphs, from the lesson\'s own writing practice, in the book\'s order', () {
      for (final l in repo.lessons.where((l) => l.unit != UnitKind.graphemes)) {
        final practised = {
          for (final b in l.blocks)
            if (b.type == 'writing_practice') ...b.items().map((i) => i.text),
        };
        for (final i in of(l)!.items) {
          expect(i.target.length, 1, reason: '${l.key} ${i.target}');
          expect(practised, contains(i.target), reason: l.key);
        }
      }
      expect(of(repo.byKey('L01')!)!.items.map((i) => '${i.target}${i.answer.cursive ? '~' : ''}'), ['i', 'i~', 'I', 'I~']);
    });
  });

  group('missing-letter', () {
    late Speech speech;
    setUpAll(() async => speech = await Speech.load());

    Iterable<Lesson> letterLessons() => repo.lessons.where((l) => l.unit == UnitKind.vowels || l.unit == UnitKind.consonants);
    ActivitySpec? of(Lesson l, {HasAudio? hasAudio}) =>
        specsFor(l, repo, hasAudio: hasAudio).where((s) => s.type == ActivityType.missingLetter).firstOrNull;
    bool hasFocusWord(Lesson l) => l.words.any((w) => !w.text.contains(' ') && l.targets.any(w.text.contains));

    test('every letter lesson with a word holding its letter gets one, once 3 letters are taught', () {
      for (final l in repo.lessons) {
        final enough = ledgerAt(l.key).where((x) => x.length == 1).length >= 3; // the answer + 2 candidates
        final expected = l.unit != UnitKind.graphemes && !l.isDigit && hasFocusWord(l) && enough;
        expect(of(l) != null, expected, reason: l.key);
      }
      expect(of(repo.byKey('L02')!), isNull, reason: 'only i and u are taught: no second candidate');
    });

    test('the blank is on the focus letter, and the answer is the letter under it', () {
      for (final l in letterLessons()) {
        for (final i in of(l)?.items ?? const <ActivityItem>[]) {
          expect(i.target[i.blankAt!], i.answer.show, reason: '${l.key} ${i.target}');
          expect(l.targets, contains(i.answer.show), reason: '${l.key} ${i.target}');
          expect(i.options, hasLength(3), reason: 'tier 1: 3 candidates');
        }
      }
    });

    test('tier 3 may blank any letter she has met, not only the focus', () {
      final blanks = {
        for (final l in letterLessons())
          for (final i in missingLetter(l, tier: 3)?.items ?? const <ActivityItem>[])
            if (!l.targets.contains(i.answer.show)) i.answer.show,
      };
      expect(blanks, isNotEmpty);
    });

    test('two items in a row never offer the same set of wrong letters, at any tier', () {
      for (final l in letterLessons()) {
        for (var tier = 1; tier <= 3; tier++) {
          final items = missingLetter(l, tier: tier)?.items ?? const <ActivityItem>[];
          final letters = ledgerAt(l.key).where((x) => x.length == 1).toSet();
          for (var k = 1; k < items.length; k++) {
            Set<String> wrong(ActivityItem i) => {for (final o in i.options) if (!i.isCorrect(o)) o.show};
            // With exactly enough letters (L03: only i and u besides o) there is no other set.
            if (letters.length - 1 <= wrong(items[k]).length) continue;
            expect(wrong(items[k]), isNot(wrong(items[k - 1])), reason: '${l.key} tier $tier items ${k - 1}, $k');
          }
        }
      }
    });

    test('a confusion-matrix neighbour is preferred when one has been taught', () {
      // L11 (m): n (L10) is m's visual neighbour and is taught by then.
      for (final i in of(repo.byKey('L11')!)!.items) {
        expect(i.options.map((o) => o.show), contains('n'), reason: i.target);
      }
    });

    test('a wrong word is only spoken when it is recorded', () {
      var spoken = 0;
      for (final l in letterLessons()) {
        for (final i in of(l, hasAudio: speech.has)?.items ?? const <ActivityItem>[]) {
          expect(speech.has(i.heard), isTrue, reason: '${l.key} « ${i.heard} »');
          for (final e in i.wrongSay.entries) {
            expect(speech.has(e.value), isTrue, reason: '${l.key} « ${e.value} »');
            expect(e.value, i.target.replaceRange(i.blankAt!, i.blankAt! + 1, e.key));
            spoken++;
          }
        }
      }
      expect(spoken, greaterThan(0), reason: 'some wrong words are recorded, e.g. tu → nu');
    });
  });

  group('syllable-build', () {
    late Speech speech;
    setUpAll(() async => speech = await Speech.load());

    ActivitySpec? buildOf(Lesson l) => specsFor(l, repo).where((s) => s.type == ActivityType.syllableBuild).firstOrNull;

    test('a wrong vowel says the syllable it built, which is always recorded', () {
      for (final l in repo.lessons.where((l) => l.unit == UnitKind.consonants)) {
        for (final i in buildOf(l)!.items) {
          expect(i.wrongSay.keys.toSet(), {for (final o in i.options) if (!i.isCorrect(o)) o.show}, reason: '${l.key} ${i.target}');
          for (final s in i.wrongSay.values) {
            expect(speech.has(s), isTrue, reason: '${l.key} « $s »');
          }
        }
      }
    });

    test('every consonant lesson gets one, and no other lesson does', () {
      for (final l in repo.lessons) {
        expect(buildOf(l) != null, l.unit == UnitKind.consonants, reason: l.key);
      }
    });

    test('consonant + answer is the target, and every tile builds one of the lesson\'s own syllables', () {
      for (final l in repo.lessons.where((l) => l.unit == UnitKind.consonants)) {
        final own = l.syllables.map((s) => s.text).toSet();
        final s = buildOf(l)!;
        expect(s.items, hasLength(own.length < 4 ? own.length : 4), reason: '${l.key}: 4 rounds, or one per syllable');
        for (final i in s.items) {
          expect('${i.fixed}${i.answer.show}', i.target, reason: s.id);
          for (final o in i.options) {
            expect(own, contains('${i.fixed}${o.show}'), reason: '${s.id}: ${i.fixed}+${o.show}');
          }
        }
      }
    });

    test('L21 (g) never offers a vowel that would build gi or ge', () {
      for (final i in buildOf(repo.byKey('L21')!)!.items) {
        expect(i.options.map((o) => o.show), everyElement(isIn(['a', 'o', 'u'])));
      }
    });

    test('every blend sentence and every syllable has a recording', () {
      for (final l in repo.lessons.where((l) => l.unit == UnitKind.consonants)) {
        for (final i in buildOf(l)!.items) {
          expect(speech.has(i.blend!), isTrue, reason: '${l.key}: « ${i.blend} »');
          expect(speech.has(i.heard), isTrue, reason: '${l.key}: « ${i.heard} »');
        }
      }
    });

    test('a missing blend falls back to the syllable alone', () {
      final s = syllableBuild(repo.byKey('L08')!, hasAudio: (t) => !t.contains('…'))!;
      expect(s.items.map((i) => i.blend), everyElement(isNull));
    });

    test('with two syllable drills, listen-choose follows the first and syllable-build the last', () {
      final l08 = repo.byKey('L08')!;
      final drills = l08.blocks.where((b) => b.type == 'syllable_drill').toList();
      expect(drills, hasLength(2));
      expect(specsAfter('syllable_drill', [drills.first], l08, repo).map((s) => s.type), [ActivityType.listenChoose]);
      expect(specsAfter('syllable_drill', [drills.last], l08, repo).map((s) => s.type), [ActivityType.syllableBuild]);
    });
  });
}
