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
      expect(steps.last, isA<BilanStep>(), reason: l.key);
      expect(steps.whereType<ContentStep>(), isNotEmpty, reason: l.key);
      for (final s in steps.whereType<ActivityStep>()) {
        activities++;
        for (final r in s.activity.rounds) {
          expect(r.options.where((o) => o.show == r.answer.show).length, 1,
              reason: '${l.key}: answer must appear exactly once');
          expect(r.options.map((o) => o.show).toSet().length, r.options.length,
              reason: '${l.key}: duplicate options');
        }
      }
      final id = l.illustrationId;
      if (id != null) expect(repo.assetPaths[id], isNotNull, reason: l.key);
    }
    expect(activities, greaterThan(66));
  });
}
