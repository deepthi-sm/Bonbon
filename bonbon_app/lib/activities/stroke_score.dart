/// Stroke-path scoring (plan §J.4, tasks B6, B14, B15): how a trace follows
/// the glyph's strokes — where it starts, which checkpoints it reaches in
/// order, which way it goes, how far it strays, how many strokes. Path
/// following, never recognition: « Un t tracé de bas en haut est faux même
/// s'il ressemble à un t. » Every number comes from the [TraceRubric].
///
/// All distances are in glyph units: thresholds are shares of the glyph's
/// height, widened by its class and the activity's tier. Pure logic.
library;

import 'dart:math' as math;

import 'glyph_spec.dart';
import 'trace_rubric.dart';

/// One scored attempt.
class StrokeScore {
  /// Each rubric component, 0..1, and whether it met its pass threshold.
  final Map<String, double> parts;
  final Map<String, bool> passed;
  final double total; // weighted, 0..1
  final int stars;

  /// What to say: the rubric's cue for the first component that failed, or « good ».
  final String cueKey;
  const StrokeScore(this.parts, this.passed, this.total, this.stars, this.cueKey);

  @override
  String toString() => 'StrokeScore(${total.toStringAsFixed(2)}, $stars★, $cueKey, '
      '${parts.map((k, v) => MapEntry(k, v.toStringAsFixed(2)))})';
}

double _dist(Pt a, Pt b) => a.distanceTo(b);

/// Distance from [p] to segment [a]–[b].
double _toSegment(Pt p, Pt a, Pt b) {
  final ab = b - a, ap = p - a;
  final len2 = ab.x * ab.x + ab.y * ab.y;
  if (len2 == 0) return _dist(p, a);
  final t = ((ap.x * ab.x + ap.y * ab.y) / len2).clamp(0.0, 1.0);
  return _dist(p, Pt(a.x + ab.x * t, a.y + ab.y * t));
}

/// The nearest segment of [line] to [p]: its index and distance.
(int, double) _nearest(Pt p, List<Pt> line) {
  if (line.length == 1) return (0, _dist(p, line.first));
  var best = (0, double.infinity);
  for (var k = 0; k + 1 < line.length; k++) {
    final d = _toSegment(p, line[k], line[k + 1]);
    if (d < best.$2) best = (k, d);
  }
  return best;
}

/// [stroke] resampled every [step], so a fast finger can't jump a checkpoint.
List<Pt> densify(List<Pt> stroke, double step) {
  if (stroke.length < 2) return stroke;
  final out = <Pt>[stroke.first];
  for (var k = 1; k < stroke.length; k++) {
    final a = stroke[k - 1], b = stroke[k];
    final n = (_dist(a, b) / step).ceil().clamp(1, 1000);
    for (var i = 1; i <= n; i++) {
      out.add(Pt(a.x + (b.x - a.x) * i / n, a.y + (b.y - a.y) * i / n));
    }
  }
  return out;
}

/// Checkpoints of [expected] reached in order by [drawn], within [radius].
int reachedInOrder(GlyphStroke expected, List<Pt> drawn, double radius) {
  var i = 0;
  for (final p in drawn) {
    while (i < expected.checkpoints.length && _dist(p, expected.checkpoints[i]) <= radius) {
      i++;
    }
  }
  return i;
}

/// How close counts as reaching one of [s]'s checkpoints: half their
/// spacing, so two neighbours are never reached at once (and order means
/// something), and never more than [startMax]. A dot keeps [startMax]: a tap
/// anywhere on it is enough. The rubric gives no radius of its own.
double checkpointRadius(GlyphStroke s, double h, double startMax) {
  final c = s.checkpoints;
  if (c.length < 2 || _isDot(s.polyline, h)) return startMax;
  var spacing = 0.0;
  for (var k = 1; k < c.length; k++) {
    spacing += _dist(c[k - 1], c[k]);
  }
  return math.min(startMax, spacing / (c.length - 1) / 2);
}

/// A stroke this small is a dot (the dot of i, an accent tap): only where
/// it lands counts.
bool _isDot(List<Pt> line, double h) {
  final xs = line.map((p) => p.x), ys = line.map((p) => p.y);
  return math.max(xs.reduce(math.max) - xs.reduce(math.min), ys.reduce(math.max) - ys.reduce(math.min)) < 0.1 * h;
}

/// Scores [drawn] (strokes in glyph coordinates, in the order she drew them)
/// against [spec]. [tierTolerance] is the activity's (generators.json: 1.4,
/// 1.0, 0.8); the glyph's class multiplies it (trace-rubric.json).
StrokeScore scoreStrokes(GlyphSpec spec, List<List<Pt>> drawn, TraceRubric rubric, {double tierTolerance = 1}) {
  final h = spec.height;
  final tol = rubric.toleranceFor(spec.char) * tierTolerance;
  final startMax = rubric['startProximity'].pass! * h * tol;
  final devMax = rubric['maxDeviation'].pass! * h * tol;
  final strokes = [for (final s in drawn) if (s.isNotEmpty) densify(s, 0.02 * h)];

  // « L'accent compte comme un trait ; il peut être tracé en dernier » — and,
  // as children often do, first: try the accent at either end, keep the best.
  final orders = <List<GlyphStroke>>[spec.strokes];
  if (rubric.classFor(spec.char)?.name == 'vowel-accented' && spec.strokes.length > 1) {
    orders.add([spec.strokes.last, ...spec.strokes.take(spec.strokes.length - 1)]);
  }
  StrokeScore? best;
  for (final expected in orders) {
    final s = _score(spec, expected, strokes, rubric, startMax, devMax);
    if (best == null || s.total > best.total) best = s;
  }
  return best!;
}

double _ramp(double d, double max) => d <= max ? 1 : math.max(0, 1 - (d - max) / max);

StrokeScore _score(GlyphSpec spec, List<GlyphStroke> expected, List<List<Pt>> drawn, TraceRubric rubric, double startMax, double devMax) {
  final h = spec.height;
  final pairs = math.min(expected.length, drawn.length);

  // startProximity: the first point of each stroke, against its start.
  var start = 0.0;
  var startOk = pairs == expected.length;
  for (var k = 0; k < pairs; k++) {
    final d = _dist(drawn[k].first, expected[k].startPoint);
    start += _ramp(d, startMax);
    if (d > startMax) startOk = false;
  }
  start /= expected.length;

  // checkpointCoverage: checkpoints reached IN ORDER, over all strokes.
  final total = expected.fold(0, (n, s) => n + s.checkpoints.length);
  var reached = 0;
  for (var k = 0; k < pairs; k++) {
    reached += reachedInOrder(expected[k], drawn[k], checkpointRadius(expected[k], h, startMax));
  }
  final cover = total == 0 ? 1.0 : reached / total;

  // directionAgreement: each drawn segment against the expected segment it
  // runs along; dots have no direction.
  var along = 0.0, agree = 0.0;
  StrokeDirection? wrongWay;
  for (var k = 0; k < pairs; k++) {
    final line = expected[k].polyline;
    if (_isDot(line, h)) continue;
    var strokeAgree = 0.0, strokeAlong = 0.0;
    for (var i = 1; i < drawn[k].length; i++) {
      final a = drawn[k][i - 1], b = drawn[k][i];
      final (seg, _) = _nearest(Pt((a.x + b.x) / 2, (a.y + b.y) / 2), line);
      final e = line[seg + 1] - line[seg], v = b - a;
      final len = _dist(a, b);
      strokeAlong += len;
      if (e.x * v.x + e.y * v.y > 0) strokeAgree += len;
    }
    along += strokeAlong;
    agree += strokeAgree;
    if (strokeAlong > 0 && strokeAgree / strokeAlong < rubric['directionAgreement'].pass!) wrongWay ??= expected[k].direction;
  }
  final direction = along == 0 ? 1.0 : agree / along;

  // maxDeviation: the farthest drawn point from its expected stroke.
  var dev = 0.0;
  for (var k = 0; k < pairs; k++) {
    for (final p in drawn[k]) {
      dev = math.max(dev, _nearest(p, expected[k].polyline).$2);
    }
  }
  for (final extra in drawn.skip(pairs)) {
    for (final p in extra) {
      dev = math.max(dev, expected.map((e) => _nearest(p, e.polyline).$2).reduce(math.min));
    }
  }
  final deviation = _ramp(dev, devMax);

  final count = drawn.length == expected.length ? 1.0 : 0.0;

  final parts = {
    'startProximity': start,
    'checkpointCoverage': cover,
    'directionAgreement': direction,
    'maxDeviation': deviation,
    'strokeCount': count,
  };
  final passed = {
    'startProximity': startOk,
    'checkpointCoverage': cover >= rubric['checkpointCoverage'].pass!,
    'directionAgreement': direction >= rubric['directionAgreement'].pass!,
    'maxDeviation': dev <= devMax,
    'strokeCount': count == 1,
  };
  final score = parts.entries.fold(0.0, (t, e) => t + rubric[e.key].weight * e.value);

  // B15: one cue, for the first thing that went wrong, in the order she can act on it.
  final cue = drawn.length < expected.length
      ? 'strokeMissing'
      : !passed['startProximity']!
          ? 'startWrong'
          // « Descends, ne monte pas » is only true of a stroke that goes down.
          : !passed['directionAgreement']! && wrongWay == StrokeDirection.down
              ? 'directionWrong'
              : !passed['checkpointCoverage']! || !passed['directionAgreement']!
                  ? 'missedCheckpoint'
                  : !passed['maxDeviation']!
                      ? 'tooFast'
                      : 'good';
  return StrokeScore(parts, passed, score, rubric.starsFor(score), cue);
}
