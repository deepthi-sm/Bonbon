import 'dart:convert';
import 'dart:io';

import 'package:bonbon/activities/glyph_spec.dart';
import 'package:bonbon/activities/stroke_score.dart';
import 'package:bonbon/activities/trace_rubric.dart';
import 'package:bonbon/activities/trace_session.dart';
import 'package:bonbon/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

// Test fixtures only, in the §H.7 shape. Real glyph data is Dev A's to make.
List<Pt> line(Pt a, Pt b, [int n = 7]) => [for (var k = 0; k < n; k++) Pt(a.x + (b.x - a.x) * k / (n - 1), a.y + (b.y - a.y) * k / (n - 1))];
List<Pt> dot(Pt c) => [for (var k = 0; k < 6; k++) Pt(c.x + (k.isEven ? 1 : -1), c.y)];

GlyphStroke stroke(int order, List<Pt> cps, StrokeDirection d) =>
    GlyphStroke(order: order, startPoint: cps.first, direction: d, checkpoints: cps);

/// i: the stem from the top down, then the dot.
final i = GlyphSpec(id: 'print-lower-i', char: 'i', viewBox: [0, 0, 100, 100], strokes: [
  stroke(1, line(const Pt(50, 35), const Pt(50, 90)), StrokeDirection.down),
  stroke(2, dot(const Pt(50, 15)), StrokeDirection.cw),
]);

/// t: the stem down, then the bar left to right.
final t = GlyphSpec(id: 'print-lower-t', char: 't', viewBox: [0, 0, 100, 100], strokes: [
  stroke(1, line(const Pt(45, 10), const Pt(45, 90)), StrokeDirection.down),
  stroke(2, line(const Pt(25, 35), const Pt(65, 35)), StrokeDirection.right),
]);

/// é: a bowl (approximated as a line here), then the accent.
final e = GlyphSpec(id: 'print-lower-e-acute', char: 'é', viewBox: [0, 0, 100, 100], strokes: [
  stroke(1, line(const Pt(25, 60), const Pt(75, 60)), StrokeDirection.right),
  stroke(2, line(const Pt(60, 10), const Pt(45, 25)), StrokeDirection.left),
]);

List<Pt> rev(List<Pt> s) => s.reversed.toList();
List<Pt> shift(List<Pt> s, double dx) => [for (final p in s) Pt(p.x + dx, p.y)];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final rubricJson = File('../docs/batonga-addon-packs/batonga-addon-packs/02-exercices/trace-rubric.json').readAsStringSync();
  final rubric = TraceRubric.fromJson(jsonDecode(rubricJson) as Map<String, dynamic>);
  final stem = line(const Pt(50, 35), const Pt(50, 90), 20);
  final tap = [const Pt(50, 15)];

  group('the rubric (B14: tuning needs no code change)', () {
    test('the bundled copy is trace-rubric.json, and it is read at runtime', () async {
      expect(jsonDecode(File('assets/content/trace-rubric.json').readAsStringSync()), jsonDecode(rubricJson));
      final loaded = await loadTraceRubric();
      expect(loaded, isNotNull);
      expect(loaded!['startProximity'].pass, 0.12);
    });

    test('thresholds, weights, stars and classes come from the JSON', () {
      expect([for (final k in ['startProximity', 'checkpointCoverage', 'directionAgreement', 'maxDeviation', 'strokeCount']) rubric[k].pass],
          [0.12, 0.8, 0.75, 0.18, null]);
      expect(rubric.components.values.fold(0.0, (s, c) => s + c.weight), closeTo(1, 1e-9));
      expect([0.8, 0.6, 0.4, 0.1].map(rubric.starsFor), [3, 2, 1, 1]);
      expect({for (final c in ['t', 'é', 'A', '3', 'i', 'g', 'm']) c: rubric.toleranceFor(c)},
          {'t': 0.95, 'é': 1.2, 'A': 1.1, '3': 1.05, 'i': 1.0, 'g': 0.95, 'm': 1.0});
    });

    test('tuning the JSON changes the scoring', () {
      final j = jsonDecode(rubricJson) as Map<String, dynamic>;
      ((j['scoreComponents'] as List)[0] as Map)['pass'] = '≤ 2 % de la hauteur du glyphe';
      final strict = TraceRubric.fromJson(j);
      final late = [shift(stem, 0).sublist(4), tap]; // starts lower than the start dot
      expect(scoreStrokes(i, late, rubric).passed['startProximity'], isTrue);
      expect(scoreStrokes(i, late, strict).passed['startProximity'], isFalse);
    });

    test('every spoken cue is recorded', () async {
      final speech = await Speech.load();
      for (final c in rubric.cues.entries) {
        expect(speech.has(c.value), isTrue, reason: '${c.key}: « ${c.value} »');
      }
    });
  });

  group('scoring (B6: start point + checkpoints, then direction, deviation, count)', () {
    test('traced as the book teaches: three stars, « C\'est bien tracé. »', () {
      final s = scoreStrokes(i, [stem, tap], rubric);
      expect(s.passed.values, everyElement(isTrue), reason: '$s');
      expect(s.stars, 3);
      expect(s.cueKey, 'good');
    });

    test('a stem drawn upwards looks like an i but is wrong: « Descends, ne monte pas. »', () {
      final s = scoreStrokes(i, [rev(stem), tap], rubric);
      expect(s.passed['directionAgreement'], isFalse);
      expect(s.cueKey, isIn(['startWrong', 'directionWrong']));
      expect(s.stars, lessThan(3));
      // Started at the right place but went up: the direction cue itself.
      final upFromStart = [line(const Pt(50, 35), const Pt(50, 5), 20), tap];
      expect(scoreStrokes(i, upFromStart, rubric).cueKey, isIn(['directionWrong', 'missedCheckpoint']));
    });

    test('the dot forgotten: « Il manque un trait. »', () {
      final s = scoreStrokes(i, [stem], rubric);
      expect(s.cueKey, 'strokeMissing');
      expect(s.passed['strokeCount'], isFalse);
      expect(s.stars, lessThan(3));
      // With the rubric's weights as written, a perfect stem alone still makes
      // 2 stars (0.69 ≥ 0.55) — so it finishes. Flagged for the team to tune.
      expect(s.total, closeTo(0.69, 0.01));
    });

    test('started halfway down: « Commence ici, en haut. »', () {
      expect(scoreStrokes(i, [stem.sublist(10), tap], rubric).cueKey, 'startWrong');
    });

    test('a wild detour, back on track after: « Doucement, suis le trait. »', () {
      final detour = [...stem.sublist(0, 10), const Pt(85, 62), ...stem.sublist(10)];
      final s = scoreStrokes(i, [detour, tap], rubric);
      expect(s.passed['checkpointCoverage'], isTrue);
      expect(s.passed['maxDeviation'], isFalse);
      expect(s.cueKey, 'tooFast');
    });

    test('t\'s bar drawn right to left: no « Descends » cue, the bar does not go down', () {
      final bar = line(const Pt(65, 35), const Pt(25, 35), 20);
      final s = scoreStrokes(t, [line(const Pt(45, 10), const Pt(45, 90), 20), bar], rubric);
      expect(s.passed['directionAgreement'], isFalse);
      expect(s.cueKey, isNot('directionWrong'));
    });

    test('é: the accent may come first or last', () {
      final bowl = line(const Pt(25, 60), const Pt(75, 60), 20), accent = line(const Pt(60, 10), const Pt(45, 25), 8);
      expect(scoreStrokes(e, [bowl, accent], rubric).stars, 3);
      expect(scoreStrokes(e, [accent, bowl], rubric).stars, 3);
    });

    test('tolerance: tier 1 (×1.4) accepts an offset that tier 3 (×0.8) does not', () {
      final off = [shift(stem, 13), shift(tap, 13)];
      expect(scoreStrokes(i, off, rubric, tierTolerance: 1.4).passed['startProximity'], isTrue);
      expect(scoreStrokes(i, off, rubric, tierTolerance: 0.8).passed['startProximity'], isFalse);
    });

    test('checkpoints count only in order: the stem from the bottom reaches one at most', () {
      final r = checkpointRadius(i.strokes.first, 100, 12);
      expect(r, lessThan(12), reason: 'half the spacing: neighbours are never reached at once');
      expect(reachedInOrder(i.strokes.first, rev(stem), r), lessThanOrEqualTo(1));
      expect(reachedInOrder(i.strokes.first, stem, r), i.strokes.first.checkpoints.length);
      expect(checkpointRadius(i.strokes.last, 100, 12), 12, reason: 'a dot: a tap anywhere on it');
    });
  });

  group('into the trace session (B15)', () {
    test('a low attempt says the rubric cue that matches what went wrong', () {
      // Upwards and without the dot: low, and the missing stroke is said first.
      final c = TraceCheck.strokes(scoreStrokes(i, [rev(stem)], rubric), rubric);
      expect(c.stars, lessThan(2));
      expect(c.cue, 'Il manque un trait.');
      final up = TraceCheck.strokes(scoreStrokes(i, [line(const Pt(50, 35), const Pt(50, 5), 20), tap], rubric), rubric);
      expect(up.stars, lessThan(2));
      expect(up.cue, isIn(['Descends, ne monte pas.', 'Passe bien par le point.']));
    });

    test('a good one is praised with « C\'est bien tracé. » and keeps its measured quality', () {
      final s = scoreStrokes(i, [stem, tap], rubric);
      final c = TraceCheck.strokes(s, rubric);
      expect(c.praise, 'C\'est bien tracé.');
      expect(c.quality, closeTo(s.total, 1e-9));
    });
  });

  test('GlyphSpec reads the §H.7 shape; no stroke data is bundled yet, so trace falls back', () async {
    final g = GlyphSpec.fromJson({
      'id': 'print-lower-l', 'char': 'l', 'script': 'print', 'case': 'lower', 'viewBox': [0, 0, 100, 100], 'outlinePath': 'M0 0',
      'strokes': [
        {'order': 1, 'd': 'M50 5 L50 95', 'startPoint': [50, 5], 'direction': 'down',
          'checkpoints': [[50, 5], [50, 23], [50, 41], [50, 59], [50, 77], [50, 95]]},
      ],
    });
    expect(g.strokes.single.direction, StrokeDirection.down);
    expect(g.strokes.single.checkpoints, hasLength(6));
    expect(await loadGlyphSpecs(), isEmpty, reason: '$glyphSpecsAsset is Dev A\'s to add');
  });
}
