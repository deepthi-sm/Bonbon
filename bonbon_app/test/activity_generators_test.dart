import 'package:bonbon/activities/contract.dart';
import 'package:bonbon/activities/generators.dart';
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
      for (final s in specsFor(l, repo)) {
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

  test('tap-identify never shows a letter from a later lesson', () {
    for (final l in repo.lessons.where((l) => !l.isDigit && l.unit != UnitKind.graphemes)) {
      final allowed = {...repo.lettersTaughtThrough(l), ...earlyShapes};
      for (final s in specsFor(l, repo).where((s) => s.type == ActivityType.tapIdentify)) {
        for (final i in s.items) {
          expect(allowed, containsAll(i.options.map((o) => o.speech).toSet()), reason: s.id);
        }
      }
    }
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

  group('syllable-build', () {
    late Speech speech;
    setUpAll(() async => speech = await Speech.load());

    ActivitySpec? buildOf(Lesson l) => specsFor(l, repo).where((s) => s.type == ActivityType.syllableBuild).firstOrNull;

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
      final s = syllableBuild(repo.byKey('L08')!, repo, hasAudio: (t) => !t.contains('…'))!;
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
