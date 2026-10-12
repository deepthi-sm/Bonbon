import 'package:flutter/material.dart';

import '../data/content.dart';
import '../data/phrases.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'atelier.dart';
import 'lesson_player.dart';
import 'shell.dart';

Color unitColor(UnitKind k) => switch (k) {
      UnitKind.vowels => C.teal,
      UnitKind.consonants => C.magenta,
      UnitKind.graphemes => const Color(0xFF0369A1),
      UnitKind.digits => C.goldDeep,
    };

void openLesson(BuildContext context, Lesson l) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => LessonPlayer(lesson: l)));

class LessonTile extends StatelessWidget {
  final Lesson lesson;
  final double size;
  const LessonTile(this.lesson, {super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    final c = unitColor(lesson.unit);
    final label = lesson.unit == UnitKind.graphemes
        ? lesson.targets.first.split(' ').first
        : lesson.isDigit
            ? lesson.shortLabel
            : '${lesson.targets.first.toUpperCase()}${lesson.targets.first}';
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(size * 0.26),
        border: Border(bottom: BorderSide(color: Color.lerp(c, Colors.black, 0.3)!, width: 4)),
      ),
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(label,
              style: TextStyle(color: Colors.white, fontSize: size * 0.42, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

class Accueil extends StatelessWidget {
  const Accueil({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final t = Theme.of(context).textTheme;
    final current = app.current;
    final allDone = app.allDone;
    final started = app.resumeStep(current) > 0;
    final digit = app.currentDigit;
    final known = [
      for (final l in app.repo.lessons)
        if (app.isDone(l) && l.keyword != null && l.illustrationId != null) l,
    ];

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        TopBar(page: context.tr('Accueil', 'Home'), spoken: P.home),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 8),
            Panel(
              color: C.surface,
              child: Row(children: [
                Avatar(app.avatar, size: 64),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${context.tr('Bonjour', 'Hello')}, ${app.name} !',
                        overflow: TextOverflow.ellipsis,
                        style: t.headlineSmall?.copyWith(color: C.tealDark)),
                    Text(context.tr('Heureuse de te revoir !', 'Good to see you again!'), style: t.bodySmall),
                  ]),
                ),
                const SpeakButton(P.greeting, size: 52),
              ]),
            ),
            const SizedBox(height: 18),
            if (allDone)
              const CompletionCard()
            else ...[
              _ContinueCard(lesson: current, started: started, allDone: false),
              // Digits are their own track, so offer the next one alongside the letters.
              if (digit != null && digit != current) ...[
                const SizedBox(height: 12),
                _NextDigit(lesson: digit),
              ],
            ],
            const SizedBox(height: 26),
            SectionTitle(context.tr('Activités rapides', 'Quick activities'), icon: Icons.bolt_rounded),
            const SizedBox(height: 12),
            Row(children: [
              _Quick('Alphabet', 'Aa', C.goldSoft, C.goldDeep,
                  () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AlphabetWall()))),
              const SizedBox(width: 12),
              _Quick(context.tr('Chiffres', 'Digits'), '123', C.tealSoft, C.teal,
                  () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DigitWall()))),
              const SizedBox(width: 12),
              _Quick(context.tr('Tracer', 'Trace'), '✎', C.magentaSoft, C.magenta,
                  () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FreeTrace()))),
            ]),
            const SizedBox(height: 22),
            Panel(
              color: C.tealSoft,
              borderColor: C.tealMid,
              child: Row(children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.eco_rounded, color: C.teal, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(context.tr('${app.streak} jour${app.streak > 1 ? 's' : ''} de suite', '${app.streak}-day streak'),
                        style: const TextStyle(fontWeight: FontWeight.w800, color: C.teal, fontSize: 14)),
                    Text(
                      app.completed.isEmpty
                          ? context.tr('Ta première leçon t\'attend.', 'Your first lesson is waiting.')
                          : context.tr('Tu as terminé ${app.completed.length} leçon${app.completed.length > 1 ? 's' : ''}.',
                              '${app.completed.length} lesson${app.completed.length > 1 ? 's' : ''} completed.'),
                      style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ]),
                ),
              ]),
            ),
            if (known.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(context.tr('Les mots que tu connais', 'Words you know'), style: t.headlineSmall),
              const SizedBox(height: 12),
              SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: known.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final l = known[i];
                    return Panel(
                      padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
                      onTap: () => app.say(l.keyword!),
                      child: Row(children: [
                        Image.asset(app.repo.assetPaths[l.illustrationId]!, width: 44, height: 44),
                        const SizedBox(width: 8),
                        Text(l.keyword!, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 6),
                        const Icon(Icons.volume_up_rounded, color: C.magenta, size: 20),
                      ]),
                    );
                  },
                ),
              ),
            ],
          ]),
        ),
      ],
    );
  }
}

/// Shown when every lesson is done: a trophy, then two ways to revise.
class CompletionCard extends StatelessWidget {
  /// False on the lessons screen, where the lessons are already there to pick.
  final bool showPick;
  const CompletionCard({super.key, this.showPick = true});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.goldSoft,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: C.gold.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.emoji_events_rounded, color: C.gold, size: 50),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(context.tr('Syllabaire terminé !', 'Syllabaire complete!'),
                  style: t.headlineSmall?.copyWith(color: C.goldDeep)),
              Text(
                  context.tr('Les 56 leçons et les 10 chiffres. Tu peux tout revoir.',
                      'All 56 lessons and 10 digits. You can revise anything.'),
                  style: t.bodySmall),
            ]),
          ),
          const SpeakButton(P.allDone, size: 48, filled: false),
        ]),
        const SizedBox(height: 16),
        PressButton.magenta(
          label: context.tr('Recommencer depuis le début', 'Start again from lesson 1'),
          icon: Icons.replay_rounded,
          onTap: () => openLesson(context, app.repo.lessons.first),
        ),
        if (showPick) ...[
          const SizedBox(height: 10),
          PressButton.ghost(
            label: context.tr('Choisir une leçon à revoir', 'Pick a lesson to revise'),
            icon: Icons.grid_view_rounded,
            onTap: () => Shell.goTo(context, 1),
          ),
        ] else ...[
          const SizedBox(height: 10),
          Text(context.tr('Ou touche une leçon ci-dessous pour la revoir.', 'Or tap any lesson below to revise it.'),
              textAlign: TextAlign.center, style: t.bodySmall),
        ],
      ]),
    );
  }
}

class _NextDigit extends StatelessWidget {
  final Lesson lesson;
  const _NextDigit({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final en = context.app.english;
    return Panel(
      padding: const EdgeInsets.all(12),
      onTap: () => openLesson(context, lesson),
      child: Row(children: [
        LessonTile(lesson, size: 56),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(context.tr('CHIFFRES', 'DIGITS'),
                style: const TextStyle(color: C.goldDeep, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.6)),
            Text(lesson.titleIn(en), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
        ),
        SpeakButton(lesson.spokenName, size: 40, filled: false),
        const SizedBox(width: 8),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(color: C.goldDeep, shape: BoxShape.circle),
          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
        ),
      ]),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final Lesson lesson;
  final bool started;
  final bool allDone;
  const _ContinueCard({required this.lesson, required this.started, required this.allDone});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final en = context.app.english;
    final label = allDone
        ? context.tr('Tout est terminé', 'All done')
        : started
            ? context.tr('Continuer la leçon', 'Continue lesson')
            : context.tr('Prochaine leçon', 'Next lesson');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFFCDEBE8), Color(0xFFE9F5F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(999)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.menu_book_rounded, color: C.teal, size: 20),
              const SizedBox(width: 8),
              Text(label.toUpperCase(),
                  style: const TextStyle(color: C.teal, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.6)),
            ]),
          ),
          const Spacer(),
          SpeakButton(lesson.spokenName, size: 44, filled: false),
        ]),
        const SizedBox(height: 14),
        Panel(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            LessonTile(lesson, size: 88),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(lesson.headingIn(en), style: const TextStyle(color: C.teal, fontWeight: FontWeight.w700, fontSize: 15)),
                Text(lesson.titleIn(en), style: t.headlineSmall),
                if (lesson.keyword != null)
                  Text('« ${lesson.keyword} »',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontStyle: FontStyle.italic, color: C.inkSoft, fontSize: 16)),
                if (lesson.passageTitle != null)
                  Text('${context.tr('Texte', 'Text')} : ${lesson.passageTitle}',
                      overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.inkSoft, fontSize: 15)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        PressButton.magenta(
          label: allDone
              ? context.tr('Revoir', 'Review')
              : started
                  ? context.tr('Reprendre', 'Resume')
                  : context.tr('Commencer', 'Start'),
          icon: Icons.play_arrow_rounded,
          onTap: () => openLesson(context, lesson),
        ),
      ]),
    );
  }
}

class _Quick extends StatelessWidget {
  final String label, glyph;
  final Color bg, fg;
  final VoidCallback onTap;
  const _Quick(this.label, this.glyph, this.bg, this.fg, this.onTap);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Panel(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          onTap: onTap,
          child: Column(children: [
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Text(glyph, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: fg)),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ]),
        ),
      );
}
