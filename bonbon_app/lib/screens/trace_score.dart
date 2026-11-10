/// Scores a finger trace against the model glyph. Pure Dart so it can be
/// tested without a screen.
///
/// Two measures, both strict:
///  * precision — how much of the drawn path lies on the model's ink
///    (within the pen's half-width). Writing something else, scribbling, or
///    drifting off the letter lowers it.
///  * coverage — how much of the model is traced. Measured per separate
///    shape (each letter, the dot of an i), so skipping a letter cannot be
///    made up for elsewhere.
///
/// Direction and stroke order are not judged: the learner may trace from any
/// side.
library;

import 'dart:collection';
import 'dart:math' as math;

class TraceResult {
  final int stars; // 1..3; 1 means "try again"
  final double precision;
  final double coverage; // overall
  final double worstShape; // coverage of the least-traced shape
  const TraceResult(this.stars, this.precision, this.coverage, this.worstShape);

  @override
  String toString() =>
      'TraceResult($stars★, precision ${precision.toStringAsFixed(2)}, coverage ${coverage.toStringAsFixed(2)}, '
      'worst shape ${worstShape.toStringAsFixed(2)})';
}

/// [ink] is the model on a [w]×[h] grid (true = model ink). [path] holds the
/// cells the finger's centre-line passed through, in the same grid.
/// [penRadius] is the drawn pen's half-width in cells.
TraceResult scoreTrace({
  required List<bool> ink,
  required int w,
  required int h,
  required Set<int> path,
  required double penRadius,
}) {
  if (path.isEmpty || !ink.contains(true)) return const TraceResult(1, 0, 0, 0);

  // Distance (in cells, chessboard metric) from every cell to the nearest model ink.
  final toInk = _distances(w, h, [for (var i = 0; i < ink.length; i++) if (ink[i]) i]);
  // Distance from every cell to the nearest point of the finger's path.
  final toPath = _distances(w, h, path);
  // Half the thickness of the model's strokes, so tracing a stroke's middle
  // counts as covering its full width.
  final toBlank = _distances(w, h, [for (var i = 0; i < ink.length; i++) if (!ink[i]) i]);
  var halfStroke = 0;
  for (var i = 0; i < ink.length; i++) {
    if (ink[i]) halfStroke = math.max(halfStroke, toBlank[i]);
  }

  // Precision: the path's centre-line must sit on the model, or within the
  // pen's own half-width of its edge.
  final onTol = penRadius.ceil();
  final on = path.where((c) => toInk[c] <= onTol).length;
  final precision = on / path.length;

  // Coverage: a model cell counts once the pen passed close enough to it.
  final coverTol = halfStroke + penRadius.ceil() + 1;
  var covered = 0, total = 0;
  var worst = 1.0;
  for (final shape in _shapes(ink, w, h)) {
    final hit = shape.where((c) => toPath[c] <= coverTol).length;
    covered += hit;
    total += shape.length;
    // Tiny specks (anti-aliasing debris) don't count as a shape to trace.
    if (shape.length >= 6) worst = math.min(worst, hit / shape.length);
  }
  final coverage = total == 0 ? 0.0 : covered / total;

  final stars = precision >= 0.9 && coverage >= 0.9 && worst >= 0.8
      ? 3
      : precision >= 0.75 && coverage >= 0.5
          ? 2
          : 1;
  return TraceResult(stars, precision, coverage, worst);
}

/// Multi-source BFS: distance (8-neighbour steps) from each cell to the
/// nearest source. Cells unreachable keep a large value.
List<int> _distances(int w, int h, Iterable<int> sources) {
  const far = 1 << 20;
  final d = List<int>.filled(w * h, far);
  final q = Queue<int>();
  for (final s in sources) {
    if (d[s] != 0) {
      d[s] = 0;
      q.add(s);
    }
  }
  while (q.isNotEmpty) {
    final c = q.removeFirst();
    final x = c % w, y = c ~/ w, nd = d[c] + 1;
    for (var dy = -1; dy <= 1; dy++) {
      final ny = y + dy;
      if (ny < 0 || ny >= h) continue;
      for (var dx = -1; dx <= 1; dx++) {
        final nx = x + dx;
        if (nx < 0 || nx >= w) continue;
        final n = ny * w + nx;
        if (nd < d[n]) {
          d[n] = nd;
          q.add(n);
        }
      }
    }
  }
  return d;
}

/// Connected groups of model ink (each letter, an accent, the dot of an i).
List<List<int>> _shapes(List<bool> ink, int w, int h) {
  final seen = List<bool>.filled(ink.length, false);
  final out = <List<int>>[];
  for (var i = 0; i < ink.length; i++) {
    if (!ink[i] || seen[i]) continue;
    final shape = <int>[];
    final stack = [i];
    seen[i] = true;
    while (stack.isNotEmpty) {
      final c = stack.removeLast();
      shape.add(c);
      final x = c % w, y = c ~/ w;
      for (var dy = -1; dy <= 1; dy++) {
        for (var dx = -1; dx <= 1; dx++) {
          final nx = x + dx, ny = y + dy;
          if (nx < 0 || nx >= w || ny < 0 || ny >= h) continue;
          final n = ny * w + nx;
          if (ink[n] && !seen[n]) {
            seen[n] = true;
            stack.add(n);
          }
        }
      }
    }
    out.add(shape);
  }
  return out;
}
