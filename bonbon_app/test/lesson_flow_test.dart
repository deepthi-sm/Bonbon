// Whole lessons played through the lesson player, as she would: content
// screens, every generated activity, the Bilan, the unit checkpoint, then
// « Terminer la leçon ». Also the saving rules for results, mastery and the
// review list.
//
// The voice is loaded without recordings, so nothing plays (a missing clip
// is skipped, as in the app).
import 'dart:convert';
import 'dart:io';

import 'package:bonbon/activities/activity_host.dart';
import 'package:bonbon/activities/assessment_host.dart';
import 'package:bonbon/activities/contract.dart';
import 'package:bonbon/data/content.dart';
import 'package:bonbon/screens/lesson_player.dart';
import 'package:bonbon/state/app_state.dart';
import 'package:bonbon/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

late ContentRepo repo;
late SharedPreferences prefs;
late Speech speech;

void phone(WidgetTester t) {
  t.view.devicePixelRatio = 2;
  t.view.physicalSize = const Size(800, 1720);
  addTearDown(t.view.reset);
}

Future<void> wait(WidgetTester t, [int ms = 1500]) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> tapText(WidgetTester t, String text) async {
  await t.tap(find.text(text).last, warnIfMissed: false);
  await wait(t, 600);
}

/// Plays the activity on screen: right answers for the choice types,
/// « Passer » for trace (or whenever an answer can't be found).
Future<void> playActivity(WidgetTester t) async {
  final spec = t.widget<ActivityHost>(find.byType(ActivityHost)).spec;
  if (spec.type != ActivityType.trace) {
    for (final item in spec.items) {
      final tiles = find.text(item.answer.show);
      final n = tiles.evaluate().length;
      for (var k = 0; k < n; k++) {
        await t.tap(tiles.at(k), warnIfMissed: false);
        await t.pump(const Duration(milliseconds: 50));
      }
      await wait(t);
    }
  }
  if (find.text('Exercice fini').evaluate().isEmpty && find.text('Passer').evaluate().isNotEmpty) {
    await tapText(t, 'Passer');
  }
}

/// Opens [l] from a home screen and plays it to the end. Returns the step
/// kinds seen, in order.
Future<List<String>> playLesson(WidgetTester t, AppState app, Lesson l) async {
  await t.pumpWidget(AppScope(state: app, child: const MaterialApp(home: Scaffold(body: Text('home')))));
  t.state<NavigatorState>(find.byType(Navigator)).push(MaterialPageRoute(builder: (_) => LessonPlayer(lesson: l)));
  await wait(t);
  final seen = <String>[];
  for (var guard = 0; guard < 80; guard++) {
    if (find.text('home').evaluate().isNotEmpty && find.byType(LessonPlayer).evaluate().isEmpty) break;
    if (find.byType(AssessmentHost).evaluate().isNotEmpty) {
      seen.add('assessment');
      final a = t.widget<AssessmentHost>(find.byType(AssessmentHost)).assessment;
      await tapText(t, 'Commencer');
      for (var p = 0; p < a.parts.length; p++) {
        await playActivity(t);
        await wait(t);
      }
      expect(find.text('Continuer'), findsOneWidget, reason: '${a.id}: always a way on');
      await tapText(t, 'Continuer');
    } else if (find.byType(ActivityHost).evaluate().isNotEmpty) {
      seen.add('activity');
      await playActivity(t);
      if (find.text('Suivant').evaluate().isNotEmpty) await tapText(t, 'Suivant');
    } else if (find.text('Terminer la leçon').evaluate().isNotEmpty) {
      seen.add('done');
      await tapText(t, 'Terminer la leçon');
      await wait(t);
    } else {
      seen.add('content');
      await tapText(t, 'Suivant');
    }
  }
  return seen;
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    repo = await ContentRepo.load();
    // Real assets (pictures, fonts) from the folder `flutter test` builds,
    // except the voice (silent) and stroke data (trace scores by coverage).
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (msg) async {
      final key = Uri.decodeFull(utf8.decode(msg!.buffer.asUint8List(msg.offsetInBytes, msg.lengthInBytes)));
      if (key.startsWith('assets/audio/') || key.endsWith('glyph-specs.json')) return null;
      final f = File('build/unit_test_assets/$key');
      return f.existsSync() ? ByteData.sublistView(f.readAsBytesSync()) : null;
    });
    prefs = await SharedPreferences.getInstance();
    speech = await Speech.load();
  });

  setUp(() async => prefs.clear());

  AppState fresh() => AppState(repo, prefs, speech);

  group('a whole lesson plays to the end and is saved', () {
    for (final (key, checkpoint) in [('L07', true), ('L08', false), ('L25', false), ('N3', false)]) {
      testWidgets(key, (t) async {
        phone(t);
        final app = fresh();
        final l = repo.byKey(key)!;
        final seen = await playLesson(t, app, l);

        expect(app.isDone(l), isTrue, reason: 'lesson saved as finished');
        expect(seen.last, 'done');
        expect(seen.where((s) => s == 'activity'), isNotEmpty, reason: 'new activities in the lesson');
        expect(seen.where((s) => s == 'assessment').length, checkpoint ? 2 : 1, reason: 'Bilan (+ checkpoint)');

        final log = app.activityLog;
        expect(log.where((e) => e['activity'] != null), isNotEmpty, reason: 'activity results saved');
        expect(log.where((e) => e['assessment'] == '$key:bilan'), hasLength(1), reason: 'Bilan saved');
        if (checkpoint) expect(log.where((e) => e['assessment'] == 'CP1'), hasLength(1), reason: 'checkpoint saved');
        expect(app.mastery, isNotEmpty, reason: 'mastery recorded');
        expect(log.where((e) => e['activity'] != null && e['skipped'] == null && (e['score'] as num) > 0), isNotEmpty,
            reason: 'at least one activity answered, not only skipped');
        // ignore: avoid_print
        print('$key: ${seen.join(' > ')}');
      });
    }
  });

  group('saving', () {
    const spec = ActivitySpec(
      lessonKey: 'L08',
      type: ActivityType.listenChoose,
      items: [
        ActivityItem(index: 0, prompt: 'p', target: 'ta', answer: Choice('ta', 'ta')),
        ActivityItem(index: 1, prompt: 'p', target: 'to', answer: Choice('to', 'to')),
      ],
    );

    test('an answer the app gave goes to review at low strength; a later first-try answer clears it', () async {
      final app = fresh();
      await app.recordActivity(const ActivityResult(spec, [
        ItemResult(itemIndex: 0, target: 'ta', wrongAttempts: 0),
        ItemResult(itemIndex: 1, target: 'to', wrongAttempts: 4),
      ]));
      expect(app.mastery['ta'], 1);
      expect(app.mastery['to'], AppState.givenStrength);
      expect(app.reviewList, ['to']);

      await app.recordActivity(const ActivityResult(spec, [ItemResult(itemIndex: 1, target: 'to', wrongAttempts: 0)]));
      expect(app.reviewList, isEmpty);
      expect(app.mastery['to'], closeTo(0.15 * 0.6 + 0.4, 0.001));
      expect(app.activityLog, hasLength(2));
    });

    test('a skipped activity is logged but changes no mastery', () async {
      final app = fresh();
      await app.recordActivity(ActivityResult.skippedBy(spec, SkipReason.user));
      expect(app.activityLog.single['skipped'], 'user');
      expect(app.mastery, isEmpty);
    });

    test('the log keeps only the most recent results', () async {
      final app = fresh();
      for (var i = 0; i < AppState.activityLogMax + 5; i++) {
        await app.recordActivity(ActivityResult.skippedBy(spec, SkipReason.user));
      }
      expect(app.activityLog, hasLength(AppState.activityLogMax));
    });

    test('« Tout effacer » clears results too', () async {
      final app = fresh();
      await app.recordActivity(const ActivityResult(spec, [ItemResult(itemIndex: 1, target: 'to', wrongAttempts: 4)]));
      await app.resetAll();
      expect(app.activityLog, isEmpty);
      expect(app.mastery, isEmpty);
      expect(app.reviewList, isEmpty);
    });
  });
}
