import 'dart:convert';
import 'dart:io';

import 'package:bonbon/activities/assessment.dart';
import 'package:bonbon/activities/contract.dart';
import 'package:bonbon/activities/generators.dart';
import 'package:bonbon/activities/ledger.dart';
import 'package:bonbon/data/content.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> pack(String name) =>
    jsonDecode(File('../docs/batonga-addon-packs/batonga-addon-packs/02-exercices/$name').readAsStringSync()) as Map<String, dynamic>;

List<Part> mixOf(List raw) => [for (final m in raw) ((m as List)[0] as String, m[1] as int)];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ContentRepo repo;
  setUpAll(() async => repo = await ContentRepo.load());

  group('blueprints match the JSON packs', () {
    test('bilan-blueprints.json', () {
      final by = pack('bilan-blueprints.json')['byArchetype'] as Map<String, dynamic>;
      for (final a in Archetype.values) {
        final j = by[a.name] as Map<String, dynamic>;
        expect(bilanBlueprints[a], mixOf(j['mix'] as List), reason: a.name);
        expect(bilanBlueprints[a]!.fold(0, (n, p) => n + p.$2), j['itemCount'], reason: a.name);
      }
    });

    test('checkpoints.json', () {
      final cps = pack('checkpoints.json')['checkpoints'] as List;
      expect(checkpoints.map((c) => c.id), [for (final c in cps) (c as Map)['id']]);
      for (final (k, raw) in cps.indexed) {
        final j = raw as Map<String, dynamic>, c = checkpoints[k];
        expect(c.afterLesson, (j['afterLesson'] as String).replaceFirst('D', 'N'), reason: c.id);
        expect(c.itemCount, j['itemCount'], reason: c.id);
        expect(c.mix, mixOf(j['mix'] as List), reason: c.id);
        expect(c.celebration, j['celebration'], reason: c.id);
      }
    });
  });

  group('Bilan', () {
    test('every lesson that introduces something gets one, at tier 2, within its blueprint', () {
      for (final l in repo.lessons) {
        final b = bilanFor(l, repo);
        if (introducedBy(l).isEmpty) {
          expect(b, isNull, reason: '${l.key} introduces nothing new (« g = j »)');
          continue;
        }
        expect(b, isNotNull, reason: l.key);
        final plan = {for (final (t, n) in bilanBlueprints[archetypeOf(l)]!) t: n};
        for (final p in b!.parts) {
          expect(p.tier, 2, reason: p.id);
          expect(p.items.length, lessThanOrEqualTo(plan[p.type.key]!), reason: p.id);
          expect(p.items.map((i) => i.index), [for (var k = 0; k < p.items.length; k++) k], reason: p.id);
        }
      }
    });

    test('every item targets something this lesson introduced', () {
      for (final l in repo.lessons) {
        final own = introducedBy(l);
        for (final p in bilanFor(l, repo)?.parts ?? const <ActivitySpec>[]) {
          for (final i in p.items) {
            expect(own.any(i.target.toLowerCase().contains), isTrue, reason: '${l.key} ${p.type.key} « ${i.target} »');
          }
        }
      }
    });

    test('a consonant Bilan is the full blueprint: 2 listen-choose, 2 syllable-build, 1 missing-letter', () {
      final b = bilanFor(repo.byKey('L08')!, repo)!;
      expect({for (final p in b.parts) p.type.key: p.items.length}, {'listen-choose': 2, 'syllable-build': 2, 'missing-letter': 1});
    });

    test('the grapheme Bilan shortens: comprehension has no questions yet', () {
      final b = bilanFor(repo.byKey('L30')!, repo)!;
      expect(b.parts.map((p) => p.type), isNot(contains(isNull)));
      expect(b.itemCount, lessThanOrEqualTo(4));
    });

    test('drawn fresh: not the same items as the lesson\'s own tier-2 activity', () {
      var differ = 0, n = 0;
      for (final l in repo.lessons.where((l) => l.unit == UnitKind.consonants)) {
        final lesson = syllableBuild(l, tier: 2)!.items.map((i) => '${i.target}${i.options.map((o) => o.show)}').toList();
        final bilan = bilanFor(l, repo)!.parts.firstWhere((p) => p.type == ActivityType.syllableBuild).items;
        n++;
        if (!bilan.every((i) => lesson.contains('${i.target}${i.options.map((o) => o.show)}'))) differ++;
      }
      expect(differ, greaterThan(n * 3 ~/ 4));
    });
  });

  group('checkpoints', () {
    test('each follows its lesson, nothing else does', () {
      for (final l in repo.lessons) {
        final cp = checkpointAfter(l, repo);
        expect(cp?.id, checkpoints.where((c) => c.afterLesson == l.key).firstOrNull?.id, reason: l.key);
      }
    });

    test('full size, except comprehension, and spread across the lessons covered', () {
      for (final c in checkpoints) {
        final a = checkpointAfter(repo.byKey(c.afterLesson)!, repo)!;
        final planned = c.mix.where((p) => p.$1 != 'comprehension').fold(0, (n, p) => n + p.$2);
        expect(a.itemCount, planned, reason: c.id);
        expect(a.celebration, c.celebration);
      }
      final cp2 = checkpointAfter(repo.byKey('L24')!, repo)!;
      final consonants = {for (final p in cp2.parts) for (final i in p.items) i.target[0]};
      expect(consonants.length, greaterThanOrEqualTo(8), reason: 'CP2 samples many consonants, not one lesson');
    });

    test('never shows a symbol beyond its last lesson', () {
      for (final c in checkpoints) {
        final ledger = ledgerAt(c.afterLesson);
        for (final p in checkpointAfter(repo.byKey(c.afterLesson)!, repo)!.parts) {
          if (p.type == ActivityType.listenChoose || p.type == ActivityType.syllableBuild || p.type == ActivityType.trace) continue;
          for (final i in p.items) {
            expect(ledger, containsAll(i.options.map((o) => o.show.toLowerCase()).toSet()), reason: '${c.id} ${i.target}');
          }
        }
      }
    });
  });

  group('result: never a gate', () {
    const spec = ActivitySpec(lessonKey: 'L08', type: ActivityType.syllableBuild, tier: 2, variant: 'bilan', items: [
      ActivityItem(index: 0, prompt: '', target: 'ta', answer: Choice('a', 'a')),
      ActivityItem(index: 1, prompt: '', target: 'to', answer: Choice('o', 'o')),
    ]);
    const other = ActivitySpec(lessonKey: 'L08', type: ActivityType.missingLetter, tier: 2, variant: 'bilan', items: [
      ActivityItem(index: 0, prompt: '', target: 'tête', answer: Choice('t', 't')),
    ]);
    const a = Assessment('L08:bilan', 'L08', [spec, other]);
    ItemResult r(int i, String t, int wrong) => ItemResult(itemIndex: i, target: t, wrongAttempts: wrong);

    test('all right: passed, nothing to review', () {
      final res = AssessmentResult(a, [
        ActivityResult(spec, [r(0, 'ta', 0), r(1, 'to', 0)]),
        ActivityResult(other, [r(0, 'tête', 0)]),
      ]);
      expect(res.score, 1);
      expect(res.passed, isTrue);
      expect(res.reviewTargets, isEmpty);
    });

    test('below 0.7: the weak targets go to review', () {
      final res = AssessmentResult(a, [
        ActivityResult(spec, [r(0, 'ta', 0), r(1, 'to', 3)]), // 1 + 0.5
        ActivityResult(other, [r(0, 'tête', 1)]), // no partial credit: 0
      ]);
      expect(res.score, closeTo(0.5, 1e-9));
      expect(res.passed, isFalse);
      expect(res.reviewTargets, unorderedEquals(['to', 'tête']));
    });

    test('a skipped part counts 0 and its targets go to review', () {
      final res = AssessmentResult(a, [
        ActivityResult(spec, [r(0, 'ta', 0), r(1, 'to', 0)]),
        ActivityResult.skippedBy(other, SkipReason.user),
      ]);
      expect(res.score, closeTo(2 / 3, 1e-9));
      expect(res.passed, isFalse);
      expect(res.reviewTargets, ['tête']);
    });

    test('passed, but an answer the app gave still goes to review', () {
      final b = Assessment('x', 'L08', [spec, other, other]);
      final res = AssessmentResult(b, [
        ActivityResult(spec, [r(0, 'ta', 0), r(1, 'to', 4)]),
        ActivityResult(other, [r(0, 'tête', 0)]),
        ActivityResult(other, [r(0, 'tête', 0)]),
      ]);
      expect(res.score, 0.75);
      expect(res.passed, isTrue);
      expect(res.reviewTargets, ['to']);
    });
  });
}
