import 'package:flutter/material.dart';

import '../data/content.dart';
import '../data/phrases.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'accueil.dart';

/// The lessons, laid out like the syllabaire's table of contents: one unit
/// at a time, each lesson a "page" card with its letter and keyword picture.
/// Order and unlocking still follow the book, one lesson after the other.
class Parcours extends StatefulWidget {
  const Parcours({super.key});

  @override
  State<Parcours> createState() => _ParcoursState();
}

class _ParcoursState extends State<Parcours> {
  int? _unit; // null until first build: open on the unit holding the current lesson

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final units = app.repo.units;
    final current = app.current;
    final ui = _unit ?? units.indexWhere((u) => u.lessons.contains(current)).clamp(0, units.length - 1);
    final unit = units[ui];
    final en = app.english;

    // Unit 3 has 32 lessons: shown in blocks of 8 so it reads as chapters (plan §C.2).
    final blocks = <(String?, List<Lesson>)>[];
    if (unit.kind == UnitKind.graphemes) {
      for (var i = 0; i < unit.lessons.length; i += 8) {
        final part = unit.lessons.sublist(i, (i + 8).clamp(0, unit.lessons.length));
        blocks.add((
          '${context.tr('Partie', 'Part')} ${i ~/ 8 + 1} · ${context.tr('leçons', 'lessons')} ${part.first.number}–${part.last.number}',
          part,
        ));
      }
    } else {
      blocks.add((null, unit.lessons));
    }

    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: TopBar(page: context.tr('Leçons', 'Lessons'), spoken: P.path)),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 64,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            scrollDirection: Axis.horizontal,
            itemCount: units.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final on = i == ui;
              final c = unitColor(units[i].kind);
              return InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => setState(() => _unit = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: on ? c : C.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: on ? c : C.border, width: 1.5),
                  ),
                  child: Text('${i + 1} · ${units[i].titleIn(en)}',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: on ? Colors.white : C.ink)),
                ),
              );
            },
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: _UnitHeader(index: ui + 1, unit: unit),
        ),
      ),
      for (final (label, lessons) in blocks) ...[
        if (label != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 20, 2),
              child: Text(label.toUpperCase(),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: C.inkSoft)),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.92,
            ),
            itemCount: lessons.length,
            itemBuilder: (context, i) => _LessonPage(lesson: lessons[i], isCurrent: lessons[i] == current),
          ),
        ),
      ],
      const SliverToBoxAdapter(child: SizedBox(height: 32)),
    ]);
  }
}

class _UnitHeader extends StatelessWidget {
  final int index;
  final Unit unit;
  const _UnitHeader({required this.index, required this.unit});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final en = app.english;
    final done = unit.lessons.where(app.isDone).length;
    final c = unitColor(unit.kind);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Color.alphaBlend(c.withValues(alpha: 0.08), C.surface),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${context.tr('UNITÉ', 'UNIT')} $index · ${unit.subtitleIn(en).toUpperCase()}',
                  style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.6)),
              const SizedBox(height: 2),
              Text(unit.titleIn(en), style: Theme.of(context).textTheme.headlineMedium),
            ]),
          ),
          SpeakButton(unit.spokenName(index), size: 48, filled: false),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: done / unit.lessons.length,
                minHeight: 8,
                backgroundColor: C.border,
                color: c,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('$done/${unit.lessons.length}', style: const TextStyle(fontWeight: FontWeight.w800, color: C.inkSoft)),
        ]),
      ]),
    );
  }
}

/// A lesson as a page of the book: number, the letter or sound in print and
/// cursive, the keyword picture (or the reading text's title), and status.
class _LessonPage extends StatelessWidget {
  final Lesson lesson;
  final bool isCurrent;
  const _LessonPage({required this.lesson, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final done = app.isDone(lesson);
    final open = app.isUnlocked(lesson);
    final c = unitColor(lesson.unit);
    final img = lesson.illustrationId == null ? null : app.repo.assetPaths[lesson.illustrationId];
    final glyph = lesson.isDigit ? lesson.shortLabel : lesson.targets.first.split(' ').first;
    final others = lesson.isDigit ? const <String>[] : lesson.targets.skip(1).toList();
    final caption = lesson.isDigit ? lesson.targets[1] : lesson.keyword ?? lesson.passageTitle;

    final (statusText, statusIcon, statusColor) = done
        ? (context.tr('Terminée', 'Done'), Icons.check_circle_rounded, C.success)
        : isCurrent
            ? (context.tr('À faire', 'Up next'), Icons.play_circle_fill_rounded, C.magenta)
            : open
                ? (context.tr('Ouverte', 'Open'), Icons.radio_button_unchecked_rounded, C.inkSoft)
                : (context.tr('Fermée', 'Locked'), Icons.lock_rounded, C.inkSoft);

    return Opacity(
      opacity: open ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => open ? openLesson(context, lesson) : app.say(P.lockedLesson),
          child: Container(
            decoration: BoxDecoration(
              color: C.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: isCurrent ? C.magenta : C.border, width: isCurrent ? 2.5 : 1.5),
              boxShadow: const [BoxShadow(color: Color(0x0F1F2937), offset: Offset(0, 2), blurRadius: 4)],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // Page header: coloured band with the number, like the book's lesson tabs.
              Container(
                color: c,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(children: [
                  Text(
                    lesson.isDigit ? context.tr('CHIFFRE', 'DIGIT') : '${context.tr('LEÇON', 'LESSON')} ${lesson.number}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.6),
                  ),
                  const Spacer(),
                  if (!open) const Icon(Icons.lock_rounded, color: Colors.white, size: 16),
                ]),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(glyph,
                              style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: c, height: 1.05)),
                        ),
                        if (!lesson.isDigit)
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(glyph, style: cursive(24, color: C.inkSoft)),
                          ),
                        if (others.isNotEmpty)
                          Text(others.join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w800, color: c, fontSize: 15)),
                      ]),
                    ),
                    if (img != null)
                      SizedBox(width: 64, height: 72, child: Image.asset(img, fit: BoxFit.contain)),
                  ]),
                ),
              ),
              if (caption != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('« $caption »',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: C.inkSoft)),
                ),
              Container(
                margin: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isCurrent ? C.magentaSoft : C.canvas,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(children: [
                  Icon(statusIcon, size: 18, color: statusColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(statusText,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: statusColor)),
                  ),
                  if (open && !done && app.resumeStep(lesson) > 0)
                    Text(context.tr('en cours', 'started'),
                        style: const TextStyle(fontSize: 12, color: C.inkSoft, fontWeight: FontWeight.w600)),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
