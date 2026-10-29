import 'dart:convert';
import 'dart:io';

import 'package:bonbon/activities/ledger.dart';
import 'package:bonbon/data/content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final json = jsonDecode(File('../docs/batonga-addon-packs/batonga-addon-packs/01-corpus/decodability.json').readAsStringSync())
      as Map<String, dynamic>;
  final ledger = [for (final e in json['ledger'] as List) e as Map<String, dynamic>];

  test('the Dart copy matches decodability.json, lesson by lesson', () {
    expect(ledgerAdds.keys, [for (final e in ledger) e['lessonId']]);
    for (final e in ledger) {
      expect(ledgerAt(e['lessonId'] as String), Set<String>.from(e['distractorPool'] as List), reason: e['lessonId'] as String);
    }
  });

  test('its letters are the app\'s own letters taught so far', () async {
    final repo = await ContentRepo.load();
    for (final l in repo.lessons.where((l) => !l.isDigit)) {
      expect(ledgerAt(l.key).where((x) => x.length == 1).toSet(), containsAll(repo.lettersTaughtThrough(l)), reason: l.key);
    }
  });

  test('digits are a closed set of ten, open from the start', () {
    expect(ledgerAt('N0'), {for (var n = 0; n <= 9; n++) '$n'});
  });
}
