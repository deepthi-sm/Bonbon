import 'package:bonbon/data/content.dart';
import 'package:bonbon/screens/lesson_player.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every lesson loads and builds steps with valid activities', () async {
    final repo = await ContentRepo.load();
    expect(repo.lessons.length, 66); // 56 literacy + 10 digits
    expect(repo.alphabet.length, 26);
    var activities = 0;
    for (final l in repo.lessons) {
      final steps = buildSteps(l, repo);
      expect(steps.last, isA<DoneStep>(), reason: l.key);
      expect(steps.whereType<ContentStep>(), isNotEmpty, reason: l.key);
      for (final s in steps.whereType<ActivityStep>()) {
        activities++;
        expect(s.spec.items, isNotEmpty, reason: s.spec.id);
        for (final it in s.spec.items) {
          if (it.options.isEmpty) continue; // trace: nothing to choose
          expect(it.options.where(it.isCorrect), isNotEmpty, reason: '${s.spec.id}: answer must be offered');
        }
      }
      final id = l.illustrationId;
      if (id != null) expect(repo.assetPaths[id], isNotNull, reason: l.key);
    }
    expect(activities, greaterThan(66));
  });
}
