import 'dart:convert';
import 'dart:io';

import 'package:bonbon/activities/confusion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the Dart copy matches confusion-matrix.json', () {
    final file = File('../docs/batonga-addon-packs/batonga-addon-packs/02-exercices/confusion-matrix.json');
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    Map<String, List<String>> table(String key) => {
          for (final e in (json[key] as Map<String, dynamic>).entries) e.key: List<String>.from(e.value as List),
        };
    expect(visualConfusion, table('visual'));
    expect(auditoryConfusion, table('auditory'));
  });
}
