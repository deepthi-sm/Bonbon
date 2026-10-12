import 'dart:math' as math;

import 'package:bonbon/screens/trace_score.dart';
import 'package:flutter_test/flutter_test.dart';

// A model on a 150x65 grid (the canvas at half resolution): a tall stroke
// like an "l", a ring like an "o", and a dot. Strokes are ~7 cells thick,
// like the bold ghost letters.
const w = 150, h = 65;
const pen = 3.0; // 12 px pen at half resolution

List<bool> model() {
  final ink = List<bool>.filled(w * h, false);
  void set(int x, int y) {
    if (x >= 0 && x < w && y >= 0 && y < h) ink[y * w + x] = true;
  }

  for (var y = 8; y <= 56; y++) {
    for (var x = 20; x <= 26; x++) {
      set(x, y);
    }
  }
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final r = math.sqrt(math.pow(x - 70, 2) + math.pow(y - 36, 2));
      if (r >= 12 && r <= 19) set(x, y);
    }
  }
  for (var y = 10; y <= 15; y++) {
    for (var x = 110; x <= 115; x++) {
      set(x, y);
    }
  }
  return ink;
}

/// Cells along straight segments between points, like the finger's path.
Set<int> path(List<List<(double, double)>> strokes, {double dx = 0, double dy = 0}) {
  final out = <int>{};
  for (final s in strokes) {
    for (var i = 0; i < s.length; i++) {
      final a = s[i], b = i + 1 < s.length ? s[i + 1] : s[i];
      final n = math.max(1, (math.sqrt(math.pow(b.$1 - a.$1, 2) + math.pow(b.$2 - a.$2, 2))).ceil());
      for (var k = 0; k <= n; k++) {
        final x = (a.$1 + (b.$1 - a.$1) * k / n + dx).round();
        final y = (a.$2 + (b.$2 - a.$2) * k / n + dy).round();
        if (x >= 0 && x < w && y >= 0 && y < h) out.add(y * w + x);
      }
    }
  }
  return out;
}

List<(double, double)> ring({double from = 0, double to = 2 * math.pi}) => [
      for (var t = from; t <= to + 1e-9; t += 0.1) (70 + 15.5 * math.cos(t), 36 + 15.5 * math.sin(t)),
    ];

const bar = [(23.0, 8.0), (23.0, 56.0)];
const dot = [(112.0, 12.0), (113.0, 13.0)];

TraceResult score(Set<int> p) => scoreTrace(ink: model(), w: w, h: h, path: p, penRadius: pen);

void main() {
  test('careful trace of every shape gets 3 stars', () {
    final r = score(path([bar, ring(), dot]));
    expect(r.stars, 3, reason: '$r');
  });

  test('traced from the other direction still gets 3 stars', () {
    final r = score(path([bar.reversed.toList(), ring().reversed.toList(), dot]));
    expect(r.stars, 3, reason: '$r');
  });

  test('small wobble (2 cells = 4 px) still gets 3 stars', () {
    final r = score(path([bar, ring(), dot], dx: 2, dy: -1));
    expect(r.stars, 3, reason: '$r');
  });

  test('half traced gets 2 stars', () {
    final r = score(path([bar, ring(to: math.pi * 0.6)]));
    expect(r.stars, 2, reason: '$r');
  });

  test('forgetting the dot keeps it from 3 stars', () {
    final r = score(path([bar, ring()]));
    expect(r.stars, 2, reason: '$r');
  });

  test('the whole trace shifted off the model gets 1 star', () {
    final r = score(path([bar, ring(), dot], dx: 12, dy: 10));
    expect(r.stars, 1, reason: '$r');
  });

  test('writing something else over the model gets 1 star', () {
    // A different word: big loops and tall strokes crossing the model.
    final other = [
      [(5.0, 50.0), (15.0, 10.0), (40.0, 5.0), (45.0, 30.0), (30.0, 60.0)],
      [(50.0, 5.0), (55.0, 60.0)],
      [(85.0, 60.0), (95.0, 20.0), (105.0, 60.0), (120.0, 25.0), (140.0, 55.0)],
    ];
    final r = score(path(other));
    expect(r.stars, 1, reason: '$r');
  });

  test('scribbling over the whole area gets 1 star even though it covers the model', () {
    final hatch = [for (var y = 2.0; y < h; y += 4) [(0.0, y), (149.0, y)]];
    final r = score(path(hatch));
    expect(r.coverage, greaterThan(0.9));
    expect(r.stars, 1, reason: '$r');
  });

  test('a single tap gets 1 star', () {
    final r = score(path([[(23.0, 30.0)]]));
    expect(r.stars, 1, reason: '$r');
  });
}
