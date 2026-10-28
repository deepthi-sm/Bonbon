import 'package:bonbon/activities/contract.dart';
import 'package:bonbon/activities/generators.dart';
import 'package:bonbon/data/content.dart';
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
    final none = specAfter('syllable_drill', l08.blocks.where((b) => b.type == 'syllable_drill').toList(), l08, repo,
        hasAudio: (_) => false);
    expect(none, isNull, reason: 'a silent listening exercise is worse than a missing one');
    final some = specAfter('syllable_drill', l08.blocks.where((b) => b.type == 'syllable_drill').toList(), l08, repo,
        hasAudio: (t) => t != 'ta');
    expect(some!.items.map((i) => i.target), isNot(contains('ta')));
  });
}
