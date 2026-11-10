/// The stroke data a tracing glyph carries (plan §H.7, « B → A »): Dev A
/// produces it from the book's arrow diagrams, Dev B scores against it. A
/// never writes scoring code; B never edits the shapes.
///
/// Expected at assets/images/glyphs/glyph-specs.json (a folder the app
/// already bundles): `[GlyphSpec, …]`. Until it exists, trace falls back to
/// the prototype's coverage scoring (trace_score.dart).
library;

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart' show rootBundle;

typedef Pt = math.Point<double>;

enum StrokeDirection { down, up, left, right, cw, ccw }

class GlyphStroke {
  final int order;

  /// The SVG path, for whoever draws it; scoring uses [checkpoints].
  final String d;
  final Pt startPoint;
  final StrokeDirection direction;

  /// ≥ 6, evenly spaced along the stroke, in drawing order (§H.7).
  final List<Pt> checkpoints;

  const GlyphStroke({required this.order, this.d = '', required this.startPoint, required this.direction, required this.checkpoints});

  /// The stroke as a polyline: its start, then its checkpoints.
  List<Pt> get polyline => [if (checkpoints.isEmpty || checkpoints.first != startPoint) startPoint, ...checkpoints];

  factory GlyphStroke.fromJson(Map<String, dynamic> j) => GlyphStroke(
        order: j['order'] as int,
        d: j['d'] as String? ?? '',
        startPoint: _pt(j['startPoint']),
        direction: StrokeDirection.values.byName(j['direction'] as String),
        checkpoints: [for (final c in j['checkpoints'] as List) _pt(c)],
      );
}

Pt _pt(Object? xy) {
  final l = xy as List;
  return Pt((l[0] as num).toDouble(), (l[1] as num).toDouble());
}

class GlyphSpec {
  final String id, char;
  final String script; // print | cursive
  final String glyphCase; // lower | upper | digit
  final List<double> viewBox; // x, y, w, h
  final List<GlyphStroke> strokes; // sorted by order

  GlyphSpec({
    required this.id,
    required this.char,
    this.script = 'print',
    this.glyphCase = 'lower',
    required this.viewBox,
    required List<GlyphStroke> strokes,
  }) : strokes = [...strokes]..sort((a, b) => a.order.compareTo(b.order));

  double get height => viewBox[3];

  factory GlyphSpec.fromJson(Map<String, dynamic> j) => GlyphSpec(
        id: j['id'] as String,
        char: j['char'] as String,
        script: j['script'] as String? ?? 'print',
        glyphCase: j['case'] as String? ?? 'lower',
        viewBox: [for (final v in j['viewBox'] as List) (v as num).toDouble()],
        strokes: [for (final s in j['strokes'] as List) GlyphStroke.fromJson(s as Map<String, dynamic>)],
      );
}

const glyphSpecsAsset = 'assets/images/glyphs/glyph-specs.json';

/// The print glyphs Dev A has provided, by character; empty until the file exists.
Future<Map<String, GlyphSpec>> loadGlyphSpecs() async {
  try {
    final raw = jsonDecode(await rootBundle.loadString(glyphSpecsAsset)) as List;
    return {
      for (final g in raw.cast<Map<String, dynamic>>().map(GlyphSpec.fromJson))
        if (g.script == 'print') g.char: g,
    };
  } catch (_) {
    return const {};
  }
}
