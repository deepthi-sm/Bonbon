import 'package:flutter/material.dart';

import '../data/content.dart';
import '../data/phrases.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'accueil.dart';

class Progres extends StatelessWidget {
  const Progres({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final t = Theme.of(context).textTheme;
    final total = app.repo.lessons.length;
    final done = app.completed.length;
    final letters = [
      for (final l in app.repo.lessons)
        if (app.isDone(l) && (l.unit == UnitKind.vowels || l.unit == UnitKind.consonants)) ...l.targets,
    ];
    final days = app.visitDays.toSet();
    final now = DateTime.now();
    final week = [for (var i = 6; i >= 0; i--) now.subtract(Duration(days: i))];
    String key(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final dayNames = app.english ? const ['M', 'T', 'W', 'T', 'F', 'S', 'S'] : const ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      TopBar(page: context.tr('Mes progrès', 'My progress'), spoken: P.progress),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 8),
          Panel(
            child: Row(children: [
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(fit: StackFit.expand, children: [
                  CircularProgressIndicator(
                    value: done / total,
                    strokeWidth: 12,
                    backgroundColor: C.border,
                    color: C.teal,
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Text('${(done * 100 / total).round()}%',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: C.tealDark)),
                  ),
                ]),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('$done / $total', style: t.headlineMedium),
                  Text(context.tr('leçons terminées', 'lessons completed'), style: t.bodySmall),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          Row(children: [
            _Stat(Icons.local_fire_department_rounded, '${app.streak}', context.tr('jours de suite', 'day streak'), C.magenta),
            const SizedBox(width: 12),
            _Stat(Icons.hearing_rounded, '${app.wordsHeard}', context.tr('écoutes', 'listens'), C.teal),
            const SizedBox(width: 12),
            _Stat(Icons.check_circle_rounded, '${app.correctAnswers}', context.tr('bonnes réponses', 'correct answers'), C.goldDeep),
          ]),
          const SizedBox(height: 20),
          Text(context.tr('Cette semaine', 'This week'), style: t.headlineSmall),
          const SizedBox(height: 10),
          Panel(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              for (final d in week)
                Column(children: [
                  Text(dayNames[d.weekday - 1], style: const TextStyle(fontWeight: FontWeight.w700, color: C.inkSoft)),
                  const SizedBox(height: 6),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: days.contains(key(d)) ? C.teal : C.canvas,
                      border: Border.all(color: days.contains(key(d)) ? C.teal : C.border, width: 1.5),
                    ),
                    child: days.contains(key(d)) ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                  ),
                ]),
            ]),
          ),
          const SizedBox(height: 20),
          Text(context.tr('Les lettres que tu connais', 'Letters you know'), style: t.headlineSmall),
          const SizedBox(height: 10),
          if (letters.isEmpty)
            Text(context.tr('Termine la leçon 1 pour gagner ta première lettre.', 'Finish lesson 1 to earn your first letter.'), style: t.bodySmall)
          else
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final l in letters)
                GestureDetector(
                  onTap: () => app.say(l),
                  child: Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: C.tealSoft, borderRadius: BorderRadius.circular(16)),
                    child: Text(l, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: C.tealDark)),
                  ),
                ),
            ]),
          const SizedBox(height: 20),
          Text(context.tr('Par unité', 'By unit'), style: t.headlineSmall),
          const SizedBox(height: 10),
          for (final u in app.repo.units) ...[
            Panel(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Container(width: 14, height: 44, decoration: BoxDecoration(color: unitColor(u.kind), borderRadius: BorderRadius.circular(9))),
                const SizedBox(width: 12),
                Expanded(child: Text(u.titleIn(app.english), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
                Text('${u.lessons.where(app.isDone).length}/${u.lessons.length}',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: C.inkSoft)),
              ]),
            ),
            const SizedBox(height: 10),
          ],
        ]),
      ),
    ]);
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _Stat(this.icon, this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Panel(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(children: [
            Icon(icon, color: color, size: 30),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: C.inkSoft)),
          ]),
        ),
      );
}
