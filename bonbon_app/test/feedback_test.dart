import 'package:bonbon/activities/feedback.dart';
import 'package:bonbon/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Mark m, {bool still = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: still),
        child: Center(child: SizedBox(width: 120, height: 120, child: Marked(mark: m, child: const Text('t')))),
      ),
    );

void main() {
  test('never colour alone: every judgement has an icon', () {
    for (final m in [Mark.right, Mark.tried, Mark.model]) {
      expect(MarkStyle.of(m).icon, isNotNull, reason: m.name);
    }
  });

  test('no red anywhere: a wrong attempt is grey, not an error colour', () {
    for (final m in Mark.values) {
      final s = MarkStyle.of(m);
      for (final c in [s.fill, s.border, s.iconColor, s.ink]) {
        expect(c, isNot(anyOf(C.magenta, C.magentaDark, Colors.red)), reason: m.name);
      }
    }
  });

  testWidgets('each mark shows its icon', (t) async {
    final icons = {Mark.right: Icons.check_circle_rounded, Mark.tried: Icons.hearing_rounded, Mark.model: Icons.touch_app_rounded};
    for (final e in icons.entries) {
      await t.pumpWidget(host(e.key));
      await t.pump(const Duration(milliseconds: 100));
      expect(find.byIcon(e.value), findsOneWidget, reason: e.key.name);
    }
    await t.pumpWidget(host(Mark.idle));
    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('a faded option is see-through, with no icon', (t) async {
    await t.pumpWidget(host(Mark.faded));
    await t.pumpAndSettle();
    expect(t.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity, 0.25);
    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('right pops, then settles back to its size', (t) async {
    await t.pumpWidget(host(Mark.idle));
    await t.pumpWidget(host(Mark.right));
    await t.pump(const Duration(milliseconds: 210));
    final mid = t.getSize(find.byType(AnimatedContainer)).width * _scale(t);
    expect(mid, greaterThan(120), reason: 'halfway through the pop it is bigger');
    await t.pumpAndSettle();
    expect(_scale(t), 1);
  });

  testWidgets('with reduced motion nothing moves', (t) async {
    await t.pumpWidget(host(Mark.model, still: true));
    await t.pumpAndSettle(); // would never settle if the pulse were running
    expect(_scale(t), 1);
    expect(find.byIcon(Icons.touch_app_rounded), findsOneWidget, reason: 'the icon still says it');
  });
}

double _scale(WidgetTester t) {
  final scales = find.descendant(of: find.byType(Marked), matching: find.byType(Transform)).evaluate();
  if (scales.isEmpty) return 1;
  final m = (scales.last.widget as Transform).transform;
  return m.getMaxScaleOnAxis();
}
