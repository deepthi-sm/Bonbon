import 'dart:convert';
import 'dart:io';

import 'package:bonbon/activities/contract.dart';
import 'package:bonbon/activities/placement.dart';
import 'package:bonbon/data/content.dart';
import 'package:bonbon/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers every item of [s] right while [right] says so, until it ends.
PlacementResult run(PlacementSession s, bool Function(int rung) right) {
  while (!s.finished) {
    final i = s.item;
    final pick = right(s.rung.rung) ? i.answer : i.options.firstWhere((o) => !i.isCorrect(o));
    s.answer(pick);
  }
  return s.result;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('rungs match placement-test.json', () {
    final j = jsonDecode(File('../docs/batonga-addon-packs/batonga-addon-packs/02-exercices/placement-test.json').readAsStringSync())
        as Map<String, dynamic>;
    final rungs = j['rungs'] as List;
    expect(placementRungs, hasLength(rungs.length));
    for (final (k, raw) in rungs.indexed) {
      final r = raw as Map<String, dynamic>, mine = placementRungs[k];
      expect(mine.probes, (r['probes'] as String).split(' ').skip(1).toList(), reason: 'rung ${k + 1}');
      expect(placementItemsPerRung, r['items']);
      expect(r['advanceIf'], '≥ 3/4');
      expect(mine.failStart, (r['onFail'] as Map)['startAt']);
      expect(mine.passStart, (r['onPass'] as Map?)?['startAt']);
    }
  });

  test('every probe answer is right: L25, in 12 items at most', () {
    final s = PlacementSession();
    expect(run(s, (_) => true).startAt, 'L25');
    expect(s.asked, lessThanOrEqualTo(12));
  });

  test('each rung sends a miss to its own start', () {
    expect(run(PlacementSession(), (_) => false).startAt, 'L01');
    expect(run(PlacementSession(), (r) => r < 2).startAt, 'L08');
    expect(run(PlacementSession(), (r) => r < 3).startAt, 'L15');
  });

  test('adaptive: a rung stops as soon as its outcome is known', () {
    final miss = PlacementSession();
    run(miss, (_) => false);
    expect(miss.asked, 2, reason: 'two misses out of four can no longer reach 3/4');
    final hit = PlacementSession();
    run(hit, (_) => true);
    expect(hit.asked, 9, reason: 'three right per rung is enough');
  });

  test('quitting at any point starts at L01, marked as from the start', () {
    final s = PlacementSession();
    s.answer(s.item.answer);
    final r = s.abandon();
    expect(r.startAt, 'L01');
    expect(r.fromStart, isTrue);
  });

  test('never a score or a level: the result holds the start and nothing else', () {
    final r = run(PlacementSession(), (r) => r < 3);
    expect(r.toJson().keys, ['startAt']);
  });

  test('never locks: lessons before the start are opened, digits are not involved', () async {
    final repo = await ContentRepo.load();
    expect(openBefore('L01', repo), isEmpty);
    final open = openBefore('L25', repo);
    expect(open.first, 'L01');
    expect(open.last, 'L24');
    expect(open, hasLength(24));
  });

  test('every item is spoken: prompt and probe have recordings, « é » alone is left out', () async {
    final speech = await Speech.load();
    for (final r in placementRungs) {
      final items = placementItems(r, hasAudio: speech.has);
      expect(items, hasLength(placementItemsPerRung), reason: 'rung ${r.rung}');
      for (final i in items) {
        expect(speech.has(i.prompt), isTrue, reason: i.prompt);
        expect(speech.has(i.heard), isTrue, reason: i.heard);
        expect(r.probes, containsAll(i.options.map((o) => o.show)));
        expect(i.options.where(i.isCorrect), hasLength(1));
      }
    }
    expect(placementItems(placementRungs.first, hasAudio: speech.has).map((i) => i.target), isNot(contains('é')));
    for (final s in [sayPlacementOffer, sayFromStart, sayPlacedHere]) {
      expect(speech.has(s), isTrue, reason: s);
    }
    final repo = await ContentRepo.load();
    for (final key in {for (final r in placementRungs) ...[r.failStart, ?r.passStart]}) {
      final name = repo.byKey(key)!.spokenName;
      expect(speech.has(name), isTrue, reason: '« $name » is spoken with the result');
    }
  });

  test('the same ladder every time', () {
    String dump(List<ActivityItem> items) => items.map((i) => '${i.target}:${i.options.map((o) => o.show)}').join(' ');
    for (final r in placementRungs) {
      expect(dump(placementItems(r)), dump(placementItems(r)));
    }
  });
}
