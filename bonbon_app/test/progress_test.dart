import 'package:bonbon/data/content.dart';
import 'package:bonbon/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppState> fresh() async {
    SharedPreferences.setMockInitialValues({});
    return AppState(await ContentRepo.load(), await SharedPreferences.getInstance(), await Speech.load());
  }

  Lesson l(AppState a, String key) => a.repo.byKey(key)!;

  test('digits are open from the start, alongside lesson 1', () async {
    final a = await fresh();
    expect(a.isUnlocked(l(a, 'L01')), isTrue);
    expect(a.isUnlocked(l(a, 'L02')), isFalse);
    expect(a.isUnlocked(l(a, 'N0')), isTrue);
    expect(a.isUnlocked(l(a, 'N1')), isFalse);
    expect(a.current.key, 'L01');
    expect(a.currentDigit?.key, 'N0');
  });

  test('digits unlock in order, independently of the letters', () async {
    final a = await fresh();
    await a.completeLesson(l(a, 'N0'));
    expect(a.isUnlocked(l(a, 'N1')), isTrue);
    expect(a.isUnlocked(l(a, 'N2')), isFalse);
    expect(a.isUnlocked(l(a, 'L02')), isFalse, reason: 'letters still follow the book');
    expect(a.current.key, 'L01');
    expect(a.currentDigit?.key, 'N1');
  });

  test('when everything is done, every lesson stays open for revision', () async {
    final a = await fresh();
    for (final x in a.repo.lessons) {
      await a.completeLesson(x);
    }
    expect(a.allDone, isTrue);
    expect(a.repo.lessons.every(a.isUnlocked), isTrue);
    expect(a.current.key, 'L01', reason: 'revision starts from the beginning');
    expect(a.currentDigit, isNull);
  });
}
