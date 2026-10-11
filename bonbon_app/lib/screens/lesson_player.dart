import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/content.dart';
import '../data/phrases.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'activities.dart';
import 'atelier.dart';

/// One screen of a lesson: either source content (one or more blocks of the
/// same kind) or a generated activity.
sealed class Step {
  String title(bool en);
  IconData get icon;
}

class ContentStep extends Step {
  final String kind;
  final List<Block> blocks;
  ContentStep(this.kind, this.blocks);

  @override
  String title(bool en) => switch (kind) {
        'grapheme' => en ? 'Letter shapes' : 'Les formes',
        'illustration' => en ? 'Keyword' : 'Découverte',
        'syllable_drill' => en ? 'Syllables' : 'Syllabes',
        'word_list' => en ? 'Words' : 'Mots',
        'sentence_list' => en ? 'Sentences' : 'Phrases',
        'writing' => en ? 'Writing' : 'Écriture',
        'numeral_display' => en ? 'The digit' : 'Le chiffre',
        _ => en ? 'Reading' : 'Lecture',
      };

  @override
  IconData get icon => switch (kind) {
        'grapheme' => Icons.text_fields_rounded,
        'illustration' => Icons.image_outlined,
        'syllable_drill' => Icons.join_inner_rounded,
        'word_list' => Icons.format_list_bulleted_rounded,
        'sentence_list' => Icons.short_text_rounded,
        'writing' => Icons.draw_rounded,
        'numeral_display' => Icons.pin_rounded,
        _ => Icons.menu_book_rounded,
      };
}

class ActivityStep extends Step {
  final Activity activity;
  ActivityStep(this.activity);
  @override
  String title(bool en) => en ? 'Exercise' : 'Exercice';
  @override
  IconData get icon => Icons.extension_rounded;
}

class BilanStep extends Step {
  @override
  String title(bool en) => en ? 'Review' : 'Bilan';
  @override
  IconData get icon => Icons.emoji_events_rounded;
}

List<Step> buildSteps(Lesson lesson, ContentRepo repo) {
  final rng = math.Random(lesson.key.hashCode);
  final steps = <Step>[];
  String group(String type) =>
      type == 'handwriting_demo' || type == 'writing_practice' ? 'writing' : type;

  for (final b in lesson.blocks) {
    final g = group(b.type);
    final last = steps.isNotEmpty ? steps.last : null;
    if (last is ContentStep && last.kind == g) {
      last.blocks.add(b);
    } else {
      steps.add(ContentStep(g, [b]));
    }
  }

  // Insert activities after the content they practise (book §J.2 mapping).
  final out = <Step>[];
  for (final s in steps) {
    out.add(s);
    if (s is! ContentStep) continue;
    final a = switch (s.kind) {
      'grapheme' => Activity.recognise(lesson, repo, rng),
      'numeral_display' => Activity.recognise(lesson, repo, rng),
      'syllable_drill' => Activity.listenChoose(
          P.promptSyllable, [for (final b in s.blocks) ...b.items()], rng),
      'word_list' => Activity.listenChoose(
          P.promptWord, [for (final b in s.blocks) ...b.items()], rng),
      _ => null,
    };
    if (a != null) out.add(ActivityStep(a));
  }
  out.add(BilanStep());
  return out;
}

class LessonPlayer extends StatefulWidget {
  final Lesson lesson;
  const LessonPlayer({super.key, required this.lesson});

  @override
  State<LessonPlayer> createState() => _LessonPlayerState();
}

class _LessonPlayerState extends State<LessonPlayer> {
  late final List<Step> _steps;
  int _i = 0;
  int _correct = 0;
  bool _activityDone = false;
  late bool _cursive;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    final app = context.app;
    _steps = buildSteps(widget.lesson, app.repo);
    _i = app.resumeStep(widget.lesson).clamp(0, _steps.length - 1);
    _cursive = app.cursiveDefault;
  }

  bool _initialised = false;

  void _go(int i) {
    context.app.speech.stop();
    setState(() {
      _i = i.clamp(0, _steps.length - 1);
      _activityDone = false;
    });
    context.app.saveStep(widget.lesson, _i);
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_i];
    final l = widget.lesson;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
            child: Row(children: [
              IconButton(
                tooltip: context.tr('Fermer', 'Close'),
                onPressed: () {
                  context.app.speech.stop();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close_rounded, size: 30),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (_i + 1) / _steps.length,
                    minHeight: 12,
                    backgroundColor: C.border,
                    color: C.magenta,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('${_i + 1}/${_steps.length}', style: const TextStyle(fontWeight: FontWeight.w700, color: C.inkSoft)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: C.tealSoft, shape: BoxShape.circle),
                child: Icon(step.icon, color: C.teal, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${l.headingIn(context.app.english)} · ${l.titleIn(context.app.english)}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: C.inkSoft, fontWeight: FontWeight.w600)),
                  Text(step.title(context.app.english), style: Theme.of(context).textTheme.headlineSmall),
                ]),
              ),
            ]),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: KeyedSubtree(key: ValueKey(_i), child: _body(step)),
            ),
          ),
          _bottomBar(step),
        ]),
      ),
    );
  }

  Widget _body(Step step) => switch (step) {
        ContentStep s => ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              if (_usesScript(s)) ...[
                ScriptToggle(cursive: _cursive, onChanged: (v) => setState(() => _cursive = v)),
                const SizedBox(height: 16),
              ],
              for (final b in s.blocks) ...[
                BlockView(block: b, lesson: widget.lesson, cursive: _cursive),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ActivityStep a => ActivityView(
            activity: a.activity,
            onFinished: (score) => setState(() {
              _correct += score;
              _activityDone = true;
            }),
          ),
        BilanStep _ => _Bilan(lesson: widget.lesson, correct: _correct),
      };

  bool _usesScript(ContentStep s) =>
      const {'word_list', 'sentence_list', 'reading_passage', 'syllable_drill', 'illustration'}.contains(s.kind);

  Widget _bottomBar(Step step) {
    final last = _i == _steps.length - 1;
    final isActivity = step is ActivityStep;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: C.surface,
        border: Border(top: BorderSide(color: C.border, width: 1.5)),
      ),
      child: Row(children: [
        if (_i > 0) ...[
          SizedBox(
            width: 64,
            child: PressButton.ghost(label: '', icon: Icons.arrow_back_rounded, onTap: () => _go(_i - 1)),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: last
              ? PressButton.magenta(
                  label: context.tr('Terminer la leçon', 'Finish lesson'),
                  icon: Icons.check_rounded,
                  onTap: () async {
                    final app = context.app;
                    await app.completeLesson(widget.lesson, correct: _correct);
                    if (!mounted) return;
                    app.say(P.lessonDone);
                    Navigator.of(context).pop();
                  },
                )
              : isActivity && !_activityDone
                  ? PressButton.ghost(label: context.tr('Passer', 'Skip'), icon: Icons.skip_next_rounded, onTap: () => _go(_i + 1))
                  : PressButton(label: context.tr('Suivant', 'Next'), icon: Icons.arrow_forward_rounded, onTap: () => _go(_i + 1)),
        ),
      ]),
    );
  }
}

class _Bilan extends StatelessWidget {
  final Lesson lesson;
  final int correct;
  const _Bilan({required this.lesson, required this.correct});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final words = lesson.words.length;
    final line = lesson.isDigit
        ? context.tr('Tu connais le chiffre ${lesson.number} : ${lesson.targets[1]}.',
            'You know the digit ${lesson.number}: ${lesson.targets[1]}.')
        : words > 0
            ? context.tr('Tu as lu $words mots.', 'You read $words words.')
            : context.tr('Tu as reconnu ${lesson.targets.join(', ')}.', 'You recognised ${lesson.targets.join(', ')}.');
    return ListView(padding: const EdgeInsets.all(24), children: [
      const SizedBox(height: 12),
      Center(
        child: Container(
          width: 140,
          height: 140,
          decoration: const BoxDecoration(color: C.goldSoft, shape: BoxShape.circle),
          child: const Icon(Icons.emoji_events_rounded, color: C.gold, size: 84),
        ),
      ),
      const SizedBox(height: 20),
      Text(context.tr('Leçon terminée', 'Lesson complete'), textAlign: TextAlign.center, style: t.headlineLarge?.copyWith(color: C.tealDark)),
      const SizedBox(height: 8),
      Text(line, textAlign: TextAlign.center, style: t.bodyLarge),
      if (correct > 0) ...[
        const SizedBox(height: 4),
        Text(
            context.tr('$correct bonne${correct > 1 ? 's' : ''} réponse${correct > 1 ? 's' : ''} aux exercices.',
                '$correct correct answer${correct > 1 ? 's' : ''} in the exercises.'),
            textAlign: TextAlign.center, style: t.bodySmall),
      ],
      const SizedBox(height: 20),
      const Center(child: SpeakButton(P.lessonDone, size: 64)),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Block renderers — one per content-schema block type.

class BlockView extends StatelessWidget {
  final Block block;
  final Lesson lesson;
  final bool cursive;
  const BlockView({super.key, required this.block, required this.lesson, required this.cursive});

  @override
  Widget build(BuildContext context) {
    final b = block;
    return switch (b.type) {
      'grapheme' => _GraphemeCard(b),
      'illustration' => _IllustrationCard(b, cursive: cursive),
      'syllable_drill' => _ItemGrid(items: b.items(), cursive: cursive),
      'word_list' => _WordList(items: b.items(), cursive: cursive),
      'sentence_list' => _Sentences(items: b.items(), cursive: cursive),
      'instruction_list' => _Sentences(items: b.items(), cursive: cursive),
      'reading_passage' => _Passage(b, cursive: cursive),
      'section_text' => _Section(b, cursive: cursive),
      'dialogue' => _Passage(b, cursive: cursive),
      'handwriting_demo' => _HandwritingDemo(b),
      'writing_practice' => _WritingPractice(b),
      'numeral_display' => _Numeral(b),
      _ => const SizedBox.shrink(),
    };
  }
}

class _GraphemeCard extends StatelessWidget {
  final Block b;
  const _GraphemeCard(this.b);

  @override
  Widget build(BuildContext context) {
    final g = b.str('grapheme')!;
    final up = b.str('uppercase');
    final speech = (b.raw['audio']?['fallbackText'] as String?) ?? g;
    Widget form(String label, Widget glyph) => Expanded(
          child: Column(children: [
            Container(
              height: 104,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: C.canvas, borderRadius: BorderRadius.circular(18)),
              child: FittedBox(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: glyph)),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: C.inkSoft)),
          ]),
        );
    return Panel(
      onTap: () => context.app.say(speech),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: Text(g, style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: C.teal)),
          ),
          SpeakButton(speech, size: 56),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          form('scripte', Text(g, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w700))),
          const SizedBox(width: 10),
          form('cursive', Text(g, style: cursive(52))),
          if (up != null) ...[
            const SizedBox(width: 10),
            form('majuscule', Text(up, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w700))),
          ],
        ]),
      ]),
    );
  }
}

class _IllustrationCard extends StatelessWidget {
  final Block b;
  final bool cursive;
  const _IllustrationCard(this.b, {required this.cursive});

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final path = app.repo.assetPaths[b.str('assetId')];
    final cap = b.raw['caption'] == null ? null : TextItem.fromJson(b.raw['caption'] as Json);
    return Panel(
      onTap: cap == null ? null : () => app.say(cap.speech, counts: true),
      child: Column(children: [
        if (path != null)
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(color: C.canvas, borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.all(16),
            child: Image.asset(path, fit: BoxFit.contain),
          ),
        if (cap != null) ...[
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: ScriptText(cap.text, cursive: cursive, size: 32)),
            SpeakButton(cap.speech, size: 56, counts: true),
          ]),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(context.tr('Le mot-clé de la leçon', 'The lesson keyword'),
                style: const TextStyle(color: C.inkSoft, fontSize: 15)),
          ),
        ],
      ]),
    );
  }
}

/// "Tout écouter": plays a list in order, highlighting each item.
class _ListenAll extends StatelessWidget {
  final List<String> parts;
  final ValueChanged<int> onIndex;
  const _ListenAll({required this.parts, required this.onIndex});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: PressButton.magenta(
          label: context.tr('Tout écouter', 'Play all'),
          icon: Icons.playlist_play_rounded,
          expand: false,
          onTap: () => context.app.speech.sayAll(parts, onIndex: onIndex),
        ),
      );
}

class _ItemGrid extends StatefulWidget {
  final List<TextItem> items;
  final bool cursive;
  const _ItemGrid({required this.items, required this.cursive});

  @override
  State<_ItemGrid> createState() => _ItemGridState();
}

class _ItemGridState extends State<_ItemGrid> {
  int _hl = -1;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _ListenAll(
          parts: [for (final i in widget.items) i.speech],
          onIndex: (i) => mounted ? setState(() => _hl = i) : null),
      const SizedBox(height: 14),
      Wrap(spacing: 10, runSpacing: 10, children: [
        for (final (n, it) in widget.items.indexed)
          GestureDetector(
            onTap: () {
              setState(() => _hl = n);
              app.say(it.speech, counts: true);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              constraints: const BoxConstraints(minWidth: 84, minHeight: 72),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _hl == n ? C.tealSoft : C.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _hl == n ? C.teal : C.border, width: _hl == n ? 2.5 : 1.5),
              ),
              child: ScriptText(it.text, cursive: widget.cursive, size: 30, color: _hl == n ? C.tealDark : C.ink),
            ),
          ),
      ]),
    ]);
  }
}

class _WordList extends StatefulWidget {
  final List<TextItem> items;
  final bool cursive;
  const _WordList({required this.items, required this.cursive});

  @override
  State<_WordList> createState() => _WordListState();
}

class _WordListState extends State<_WordList> {
  int _hl = -1;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _ListenAll(
          parts: [for (final i in widget.items) i.speech],
          onIndex: (i) => mounted ? setState(() => _hl = i) : null),
      const SizedBox(height: 14),
      for (final (n, it) in widget.items.indexed) ...[
        Panel(
          padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
          color: _hl == n ? C.tealSoft : C.surface,
          borderColor: _hl == n ? C.teal : C.border,
          onTap: () {
            setState(() => _hl = n);
            app.say(it.speech, counts: true);
          },
          child: Row(children: [
            Expanded(child: ScriptText(it.text, cursive: widget.cursive, size: 26)),
            SpeakButton(it.speech, size: 48, filled: false, counts: true),
          ]),
        ),
        const SizedBox(height: 10),
      ],
    ]);
  }
}

class _Sentences extends StatefulWidget {
  final List<TextItem> items;
  final bool cursive;
  const _Sentences({required this.items, required this.cursive});

  @override
  State<_Sentences> createState() => _SentencesState();
}

class _SentencesState extends State<_Sentences> {
  int _hl = -1;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _ListenAll(
          parts: [for (final i in widget.items) i.speech],
          onIndex: (i) => mounted ? setState(() => _hl = i) : null),
      const SizedBox(height: 6),
      Text(context.tr('Touche une phrase pour l\'entendre, ou un mot.', 'Tap a sentence to hear it, or a single word.'),
          style: const TextStyle(color: C.inkSoft, fontSize: 15)),
      const SizedBox(height: 12),
      for (final (n, it) in widget.items.indexed) ...[
        _SentenceCard(
          text: it.text,
          speech: it.speech,
          cursive: widget.cursive,
          highlighted: _hl == n,
          onTap: () => setState(() => _hl = n),
        ),
        const SizedBox(height: 10),
      ],
    ]);
  }
}

/// A sentence whose individual words can be tapped; the speaker reads it all.
class _SentenceCard extends StatelessWidget {
  final String text, speech;
  final bool cursive, highlighted;
  final VoidCallback onTap;
  const _SentenceCard({
    required this.text,
    required this.speech,
    required this.cursive,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final words = text.split(RegExp(r'\s+'));
    return Panel(
      padding: const EdgeInsets.fromLTRB(18, 12, 10, 12),
      color: highlighted ? C.goldSoft : C.surface,
      borderColor: highlighted ? C.gold : C.border,
      onTap: () {
        onTap();
        app.say(speech, counts: true);
      },
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 6, runSpacing: 2, children: [
              for (final w in words)
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    final clean = wordsOf(w);
                    if (clean.isNotEmpty) app.say(clean.first, counts: true);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    child: ScriptText(w, cursive: cursive, size: 22, weight: FontWeight.w600),
                  ),
                ),
            ]),
          ]),
        ),
        SpeakButton(speech, size: 44, filled: false),
      ]),
    );
  }
}

class _Passage extends StatefulWidget {
  final Block b;
  final bool cursive;
  const _Passage(this.b, {required this.cursive});

  @override
  State<_Passage> createState() => _PassageState();
}

class _PassageState extends State<_Passage> {
  int _hl = -1;

  /// Flattened (text, speech, isDialogueTurn) lines in source order.
  List<(String, String, bool)> get _lines {
    final raw = widget.b.raw;
    final out = <(String, String, bool)>[];
    void turn(Json t) =>
        out.add((t['text'] as String, (t['audio']?['fallbackText'] as String?) ?? t['text'] as String, true));
    if (raw['type'] == 'dialogue') {
      for (final t in raw['turns'] as List) {
        turn(t as Json);
      }
      return out;
    }
    for (final s in raw['segments'] as List) {
      final seg = s as Json;
      if (seg['type'] == 'dialogue') {
        for (final t in seg['turns'] as List) {
          turn(t as Json);
        }
      } else {
        out.add((seg['text'] as String, (seg['audio']?['fallbackText'] as String?) ?? seg['text'] as String, false));
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final lines = _lines;
    final title = widget.b.str('title');
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (title != null) ...[
        Row(children: [
          Expanded(child: ScriptText(title, cursive: widget.cursive, size: 30, color: C.tealDark, weight: FontWeight.w800)),
          SpeakButton(title, size: 48),
        ]),
        const SizedBox(height: 12),
      ],
      _ListenAll(parts: [for (final l in lines) l.$2], onIndex: (i) => mounted ? setState(() => _hl = i) : null),
      const SizedBox(height: 12),
      for (final (n, l) in lines.indexed) ...[
        Padding(
          padding: EdgeInsets.only(left: l.$3 ? 16 : 0),
          child: _SentenceCard(
            text: l.$1,
            speech: l.$2,
            cursive: widget.cursive,
            highlighted: _hl == n,
            onTap: () => setState(() => _hl = n),
          ),
        ),
        const SizedBox(height: 10),
      ],
    ]);
  }
}

class _Section extends StatelessWidget {
  final Block b;
  final bool cursive;
  const _Section(this.b, {required this.cursive});

  @override
  Widget build(BuildContext context) {
    final heading = b.str('heading');
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (heading != null) ...[
        Text(heading, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: C.tealDark)),
        const SizedBox(height: 10),
      ],
      _Sentences(items: b.items('paragraphs'), cursive: cursive),
    ]);
  }
}

class _HandwritingDemo extends StatelessWidget {
  final Block b;
  const _HandwritingDemo(this.b);

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final glyphs = ((b.raw['glyphAssetIds'] as List?) ?? const []).cast<String>();
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(context.tr('Le modèle du livre', 'The book\'s model'),
            style: const TextStyle(fontWeight: FontWeight.w800, color: C.teal, fontSize: 16)),
        const SizedBox(height: 12),
        if (glyphs.isNotEmpty)
          Wrap(spacing: 12, runSpacing: 12, children: [
            for (final g in glyphs)
              if (app.repo.assetPaths[g] != null)
                Container(
                  height: 110,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: C.canvas, borderRadius: BorderRadius.circular(16)),
                  child: Image.asset(app.repo.assetPaths[g]!, fit: BoxFit.contain),
                ),
          ])
        else
          Wrap(spacing: 16, children: [
            for (final e in b.items('examples')) Text(e.text, style: cursive(40)),
          ]),
      ]),
    );
  }
}

class _WritingPractice extends StatefulWidget {
  final Block b;
  const _WritingPractice(this.b);

  @override
  State<_WritingPractice> createState() => _WritingPracticeState();
}

class _WritingPracticeState extends State<_WritingPractice> {
  int _sel = 0;

  @override
  Widget build(BuildContext context) {
    final items = widget.b.items();
    final it = items[_sel.clamp(0, items.length - 1)];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(context.tr('Choisis un modèle, puis trace-le avec ton doigt.', 'Pick a model, then trace it with your finger.'),
          style: const TextStyle(color: C.inkSoft, fontSize: 15)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final (n, x) in items.indexed)
          ChoiceChip(
            label: Text(x.text, style: x.representations.contains('cursive') && !x.representations.contains('print')
                ? cursive(16, color: n == _sel ? Colors.white : C.ink)
                : TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: n == _sel ? Colors.white : C.ink)),
            selected: n == _sel,
            showCheckmark: false,
            selectedColor: C.teal,
            backgroundColor: C.surface,
            side: const BorderSide(color: C.border, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            onSelected: (_) => setState(() => _sel = n),
          ),
      ]),
      const SizedBox(height: 12),
      TraceCanvas(
        key: ValueKey(it.id),
        model: it.text,
        cursiveModel: it.representations.contains('cursive') && !it.representations.contains('print'),
      ),
    ]);
  }
}

class _Numeral extends StatelessWidget {
  final Block b;
  const _Numeral(this.b);

  @override
  Widget build(BuildContext context) {
    final word = b.raw['word'] == null ? null : TextItem.fromJson(b.raw['word'] as Json);
    final speech = word?.speech ?? b.str('display')!;
    return Panel(
      onTap: () => context.app.say(speech, counts: true),
      child: Column(children: [
        Text(b.str('display')!, style: const TextStyle(fontSize: 140, fontWeight: FontWeight.w800, color: C.goldDeep, height: 1.1)),
        if (word != null) ...[
          Text(word.text, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700)),
          Text(word.text, style: cursive(30, color: C.inkSoft)),
        ],
        const SizedBox(height: 12),
        SpeakButton(speech, size: 60, counts: true),
      ]),
    );
  }
}
