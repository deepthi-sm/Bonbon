// Every activity screen, opened and played through as she would: tapping,
// dragging, tracing, skipping. The rules have their own tests; these make
// sure the screens built on them open, respond and always let her go on.
//
// The voice is loaded without recordings, so nothing plays: a clip that
// isn't there is skipped, exactly as in the app while recordings are made.
import 'package:bonbon/activities/activity_host.dart';
import 'package:bonbon/activities/assessment.dart';
import 'package:bonbon/activities/assessment_host.dart';
import 'package:bonbon/activities/contract.dart';
import 'package:bonbon/activities/fixtures.dart';
import 'package:bonbon/activities/gallery_main.dart';
import 'package:bonbon/activities/placement.dart';
import 'package:bonbon/activities/placement_host.dart';
import 'package:bonbon/data/content.dart';
import 'package:bonbon/state/app_state.dart';
import 'package:bonbon/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

late AppState state;

/// A phone-sized screen (400 × 860), as she would hold it.
void phone(WidgetTester t) {
  t.view.devicePixelRatio = 2;
  t.view.physicalSize = const Size(800, 1720);
  addTearDown(t.view.reset);
}

Widget host(Widget child) => AppScope(state: state, child: MaterialApp(home: Scaffold(body: child)));

/// Lets the screen's own short pauses (between items, between parts) run.
Future<void> wait(WidgetTester t, [int ms = 1500]) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

/// Taps every tile showing [item]'s answer (tap-identify has two or three).
Future<void> answer(WidgetTester t, ActivityItem item) async {
  final tiles = find.text(item.answer.show);
  final n = tiles.evaluate().length;
  for (var k = 0; k < n; k++) {
    await t.tap(tiles.at(k), warnIfMissed: false);
    await t.pump(const Duration(milliseconds: 50));
  }
  await wait(t);
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final repo = await ContentRepo.load();
    // From here on no asset loads: the voice starts with no clips (silent),
    // and trace finds no stroke data, so it scores as the prototype does.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (_) async => null);
    state = AppState(repo, await SharedPreferences.getInstance(), await Speech.load());
  });

  group('each activity type plays through with right answers', () {
    for (final spec in [tapIdentifyL08, listenChooseL08, syllableBuildL08, missingLetterL11]) {
      testWidgets(spec.type.key, (t) async {
    phone(t);
        ActivityResult? done;
        await t.pumpWidget(host(ActivityHost(spec: spec, onComplete: (r) => done = r, onSkip: (_) {})));
        await wait(t);
        for (final item in spec.items) {
          await answer(t, item);
        }
        expect(done, isNotNull, reason: 'onComplete');
        expect(done!.score, 1);
        expect(find.text('Exercice fini'), findsOneWidget);
      });
    }
  });

  testWidgets('wrong answers climb the repair ladder and still end the item', (t) async {
    phone(t);
    ActivityResult? done;
    await t.pumpWidget(host(ActivityHost(spec: listenChooseL08, onComplete: (r) => done = r, onSkip: (_) {})));
    await wait(t);
    final first = listenChooseL08.items.first;
    for (var k = 0; k < 4; k++) {
      for (final o in first.options.where((o) => !first.isCorrect(o))) {
        await t.tap(find.text(o.show), warnIfMissed: false);
        await wait(t, 300);
      }
    }
    await answer(t, first); // may already be over: rung 4 answers for her
    await answer(t, listenChooseL08.items.last);
    expect(done, isNotNull);
    expect(done!.items.first.wrongAttempts, greaterThanOrEqualTo(2));
    expect(t.takeException(), isNull);
  });

  testWidgets('syllable-build: dragging the vowel onto the slot works too', (t) async {
    phone(t);
    ActivityResult? done;
    await t.pumpWidget(host(ActivityHost(spec: syllableBuildL08, onComplete: (r) => done = r, onSkip: (_) {})));
    await wait(t);
    final from = t.getCenter(find.text('a'));
    final to = t.getCenter(find.byType(DragTarget<int>));
    final g = await t.startGesture(from);
    for (var k = 1; k <= 10; k++) {
      await g.moveTo(Offset.lerp(from, to, k / 10)!);
      await t.pump(const Duration(milliseconds: 16));
    }
    await g.up();
    await wait(t);
    expect(done?.score, 1);
  });

  testWidgets('« Passer » is on every activity and hands back a skip', (t) async {
    phone(t);
    for (final spec in [tapIdentifyL08, listenChooseL08, syllableBuildL08, missingLetterL11, traceL01]) {
      SkipReason? why;
      await t.pumpWidget(host(ActivityHost(key: ValueKey(spec.id), spec: spec, onComplete: (_) {}, onSkip: (r) => why = r)));
      await wait(t, 300);
      await t.tap(find.text('Passer'));
      await t.pump();
      expect(why, SkipReason.user, reason: spec.id);
    }
    await wait(t, 500);
  });

  testWidgets('trace: checking an empty pad is fine; a stroke gets stars', (t) async {
    phone(t);
    await t.pumpWidget(host(ActivityHost(spec: traceL01, onComplete: (_) {}, onSkip: (_) {})));
    await wait(t, 300);
    await t.tap(find.text('Vérifier'));
    await wait(t, 300);
    expect(find.byIcon(Icons.star_rounded), findsNothing, reason: 'nothing drawn: no stars');

    final pad = t.getRect(find.byType(CustomPaint).last);
    final g = await t.startGesture(pad.center.translate(0, -60));
    for (var k = 1; k <= 12; k++) {
      await g.moveTo(pad.center.translate(0, -60 + k * 10.0));
      await t.pump(const Duration(milliseconds: 16));
    }
    await g.up();
    await t.tap(find.text('Vérifier'));
    // The ink is measured on an image of the model: let that real work finish.
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 500)));
    await wait(t, 300);
    expect(find.byIcon(Icons.star_rounded).evaluate().length + find.byIcon(Icons.star_outline_rounded).evaluate().length, 3);
    expect(t.takeException(), isNull);
  });

  testWidgets('a Bilan plays end to end and ends on « Bien lu ! »', (t) async {
    phone(t);
    final b = bilanFor(state.repo.byKey('L08')!, state.repo)!;
    AssessmentResult? result;
    var continued = false;
    await t.pumpWidget(host(AssessmentHost(assessment: b, onDone: (r) => result = r, onContinue: () => continued = true)));
    expect(find.textContaining('pas un examen'), findsOneWidget);
    await t.tap(find.text('Commencer'));
    await wait(t, 500);
    for (final part in b.parts) {
      for (final item in part.items) {
        await answer(t, item);
      }
      await wait(t);
    }
    expect(result?.passed, isTrue);
    expect(find.text('Bien lu !'), findsOneWidget);
    await t.tap(find.text('Continuer'));
    expect(continued, isTrue);
  });

  testWidgets('a checkpoint skipped part by part: never blocked, review offered', (t) async {
    phone(t);
    final cp = checkpointAfter(state.repo.byKey('L07')!, state.repo)!;
    AssessmentResult? result;
    var continued = false;
    await t.pumpWidget(host(AssessmentHost(assessment: cp, onDone: (r) => result = r, onContinue: () => continued = true, onReview: () {})));
    await t.tap(find.text('Commencer'));
    await wait(t, 500);
    for (var k = 0; k < cp.parts.length; k++) {
      await t.tap(find.text('Passer'));
      await wait(t);
    }
    expect(result?.passed, isFalse);
    expect(find.text('On continue.'), findsOneWidget);
    expect(find.text('Revoir maintenant'), findsOneWidget);
    await t.tap(find.text('Continuer'));
    expect(continued, isTrue, reason: 'a low score never locks anything');
  });

  group('placement', () {
    testWidgets('right all the way: « Tu peux commencer ici » and lesson 25, no score shown', (t) async {
    phone(t);
      PlacementResult? placed;
      await t.pumpWidget(host(PlacementHost(onPlaced: (r) => placed = r, hasAudio: (_) => true)));
      await t.tap(find.text('J\'en connais déjà'));
      await wait(t, 300);
      for (final r in placementRungs) {
        for (final item in placementItems(r, hasAudio: (_) => true).take(placementNeeded(placementItemsPerRung))) {
          await t.tap(find.text(item.answer.show));
          await wait(t, 600);
        }
      }
      expect(find.text(sayPlacedHere), findsOneWidget);
      expect(find.textContaining('Leçon 25'), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);
      expect(find.textContaining('/'), findsNothing);
      await t.tap(find.text('Commencer'));
      expect(placed?.startAt, 'L25');
      await wait(t, 500);
    });

    testWidgets('« Commencer au début », on the offer or mid-test, gives L01', (t) async {
    phone(t);
      PlacementResult? placed;
      await t.pumpWidget(host(PlacementHost(onPlaced: (r) => placed = r, hasAudio: (_) => true)));
      await t.tap(find.text('Commencer au début'));
      expect(placed?.startAt, 'L01');
      expect(placed?.fromStart, isTrue);

      placed = null;
      await t.pumpWidget(host(PlacementHost(key: const ValueKey(2), onPlaced: (r) => placed = r, hasAudio: (_) => true)));
      await t.tap(find.text('J\'en connais déjà'));
      await wait(t, 300);
      await t.tap(find.text(placementItems(placementRungs.first, hasAudio: (_) => true).first.answer.show));
      await wait(t, 600);
      await t.tap(find.text('Commencer au début'));
      expect(placed?.startAt, 'L01');
      expect(placed?.fromStart, isTrue);
      await wait(t, 500);
    });
  });

  testWidgets('the gallery opens, switches tier, and opens an activity', (t) async {
    phone(t);
    await t.pumpWidget(host(const ActivityGallery()));
    await wait(t, 300);
    expect(find.text('Test de placement'), findsOneWidget);
    await t.tap(find.text('Tier 2'));
    await wait(t, 300);
    await t.scrollUntilVisible(find.textContaining('L08:syllable-build'), 200);
    await t.tap(find.textContaining('L08:syllable-build'));
    await wait(t, 600);
    expect(find.byType(ActivityHost), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
