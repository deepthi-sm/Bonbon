/// scoreTrace's parameters, read at runtime from trace-rubric.json (task
/// B14): weights, pass thresholds, star bands, tolerance per glyph class,
/// spoken cues. Tuning from field-test data is an edit to
/// assets/content/trace-rubric.json, not a code change.
library;

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

const traceRubricAsset = 'assets/content/trace-rubric.json';

class RubricComponent {
  final String key;
  final double weight;

  /// The pass threshold as a fraction (« ≤ 12 % » → 0.12); null when « exact ».
  final double? pass;
  const RubricComponent(this.key, this.weight, this.pass);
}

class GlyphClass {
  final String name;
  final double tolerance;

  /// The lowercase letters the class lists in its note (« b d f h k l t »).
  final Set<String> letters;
  const GlyphClass(this.name, this.tolerance, this.letters);
}

class TraceRubric {
  final Map<String, RubricComponent> components;

  /// Star bands, highest first: (stars, minimum score).
  final List<(int, double)> stars;
  final Map<String, GlyphClass> classes;
  final Map<String, String> cues;
  const TraceRubric(this.components, this.stars, this.classes, this.cues);

  RubricComponent operator [](String key) => components[key]!;

  /// « ≤ 12 % de la hauteur » → 0.12, « ≥ 80 % des jalons » → 0.8, « exact » → null.
  static double? _fraction(String pass) {
    final m = RegExp(r'(\d+(?:[.,]\d+)?)\s*%').firstMatch(pass);
    return m == null ? null : double.parse(m.group(1)!.replaceAll(',', '.')) / 100;
  }

  factory TraceRubric.fromJson(Map<String, dynamic> j) {
    final classes = <String, GlyphClass>{};
    for (final e in (j['tolerancesByClass'] as Map<String, dynamic>).entries) {
      final c = e.value as Map<String, dynamic>;
      final note = (c['note'] as String? ?? '').split('—').first;
      classes[e.key] = GlyphClass(
        e.key,
        (c['toleranceMultiplier'] as num).toDouble(),
        {for (final w in note.split(RegExp(r'\s+'))) if (w.length == 1) w},
      );
    }
    final stars = [
      for (final s in (j['stars'] as List).cast<Map<String, dynamic>>()) (s['stars'] as int, (s['min'] as num).toDouble()),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    return TraceRubric(
      {
        for (final c in (j['scoreComponents'] as List).cast<Map<String, dynamic>>())
          c['key'] as String: RubricComponent(c['key'] as String, (c['weight'] as num).toDouble(), _fraction(c['pass'] as String)),
      },
      stars,
      classes,
      Map<String, String>.from(j['spokenCues'] as Map),
    );
  }

  /// The tolerance multiplier for [char] (trace-rubric.json, tolerancesByClass).
  double toleranceFor(String char) => classFor(char)?.tolerance ?? 1.0;

  GlyphClass? classFor(String char) {
    if (RegExp(r'^[0-9]$').hasMatch(char)) return classes['digit'];
    if (char != char.toLowerCase()) return classes['uppercase'];
    return classes.values.where((c) => c.letters.contains(char)).firstOrNull;
  }

  /// Stars for a total [score]: the highest band reached; never fewer than 1
  /// (« 1 » means « try again », there is no zero).
  int starsFor(double score) => stars.where((s) => score >= s.$2).firstOrNull?.$1 ?? 1;
}

/// The rubric bundled with the app, or null if it can't be read (trace then
/// keeps the prototype's scoring).
Future<TraceRubric?> loadTraceRubric() async {
  try {
    return TraceRubric.fromJson(jsonDecode(await rootBundle.loadString(traceRubricAsset)) as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}
