import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/content.dart';
import '../data/phrases.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// One option in a choice round: what is shown and what is spoken.
class Opt {
  final String show, speech;
  final bool cursive;
  const Opt(this.show, this.speech, {this.cursive = false});
}

class Round {
  final String prompt; // spoken + written instruction
  final Opt answer;
  final List<Opt> options;
  final bool listen; // true: learner hears the answer and picks it
  const Round(this.prompt, this.answer, this.options, {this.listen = true});
}

/// Generated practice. The book has no exercises; every activity here is an
/// [ADAPT] built only from the lesson's own source items (plan §J.2).
class Activity {
  final String title;
  final List<Round> rounds;
  const Activity(this.title, this.rounds);

  /// Hear an item, choose it among 3–4 written options from the same block.
  static Activity? listenChoose(String prompt, List<TextItem> items, math.Random rng) {
    final seen = <String>{};
    final pool = [for (final i in items) if (seen.add(i.text)) i];
    if (pool.length < 3) return null;
    final picks = [...pool]..shuffle(rng);
    final width = pool.length >= 6 ? 4 : 3;
    return Activity(prompt, [
      for (final a in picks.take(math.min(4, pool.length)))
        Round(prompt, Opt(a.text, a.speech),
            ([a, ...(pool.where((x) => x != a).toList()..shuffle(rng)).take(width - 1)]..shuffle(rng))
                .map((x) => Opt(x.text, x.speech))
                .toList()),
    ]);
  }

  /// Recognise the lesson's letter / grapheme / digit among distractors.
  static Activity? recognise(Lesson l, ContentRepo repo, math.Random rng) {
    if (l.isDigit) {
      final d = l.number;
      final others = ([for (var i = 0; i <= 9; i++) if (i != d) i]..shuffle(rng)).take(3);
      final words = {for (final x in repo.units.last.lessons) x.number: x.targets[1]};
      return Activity(P.promptDigit, [
        for (var r = 0; r < 2; r++)
          Round(P.promptDigit, Opt('$d', words[d]!),
              ([d, ...others]..shuffle(rng)).map((n) => Opt('$n', words[n]!)).toList()),
      ]);
    }

    if (l.unit == UnitKind.graphemes) {
      final mine = l.targets.where((t) => !t.contains('=')).toList();
      if (mine.isEmpty) return null;
      final earlier = [
        for (final x in repo.lessons)
          if (x.unit == UnitKind.graphemes && x.number < l.number) ...x.targets.where((t) => !t.contains('=')),
      ];
      final rounds = <Round>[];
      for (final t in mine.take(3)) {
        final pool = {...mine, ...earlier}.where((x) => x != t).toList()..shuffle(rng);
        if (pool.length < 2) continue;
        rounds.add(Round(P.promptSound, Opt(t, t),
            ([t, ...pool.take(2)]..shuffle(rng)).map((x) => Opt(x, x)).toList()));
      }
      return rounds.isEmpty ? null : Activity(P.promptSound, rounds);
    }

    // Letter lessons: find the letter in print, capital, then cursive.
    const fallback = ['a', 'o', 'u', 'e', 'i', 'é', 'y'];
    final taught = repo.lettersTaughtThrough(l).where((x) => !l.targets.contains(x)).toSet().toList();
    final pool = [...taught, ...fallback.where((f) => !taught.contains(f) && !l.targets.contains(f))];
    final rounds = <Round>[];
    for (final t in l.targets) {
      for (final mode in ['print', 'upper', 'cursive']) {
        final ds = (pool.toList()..shuffle(rng)).take(3).toList();
        String f(String s) => mode == 'upper' ? s.toUpperCase() : s;
        final prompt = mode == 'cursive'
            ? P.promptCursive(t)
            : mode == 'upper'
                ? P.promptUpper(t)
                : P.promptLetter(t);
        rounds.add(Round(
          prompt,
          Opt(f(t), t, cursive: mode == 'cursive'),
          ([t, ...ds]..shuffle(rng)).map((x) => Opt(f(x), x, cursive: mode == 'cursive')).toList(),
          listen: false,
        ));
      }
    }
    return Activity('Trouve la lettre', rounds.take(4).toList());
  }
}

class ActivityView extends StatefulWidget {
  final Activity activity;
  final ValueChanged<int> onFinished;
  const ActivityView({super.key, required this.activity, required this.onFinished});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  static const _praise = P.praise;
  static const _repair = P.repair;

  int _r = 0;
  int _score = 0;
  bool _missed = false; // a wrong tap this round — answer no longer counts
  Opt? _right;
  final Set<Opt> _wrong = {};
  bool _finished = false;
  final _rng = math.Random();

  Round get _round => widget.activity.rounds[_r];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ask());
  }

  void _ask() {
    if (!mounted) return;
    final app = context.app;
    final r = _round;
    if (r.listen) {
      app.speech.sayAll([r.prompt, r.answer.speech]);
    } else {
      app.say(r.prompt);
    }
  }

  Future<void> _tap(Opt o) async {
    if (_right != null || _finished) return;
    final app = context.app;
    if (o.show == _round.answer.show) {
      if (!_missed) _score++;
      setState(() => _right = o);
      await app.speech.sayAll([_praise[_rng.nextInt(_praise.length)], o.speech]);
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      if (_r + 1 < widget.activity.rounds.length) {
        setState(() {
          _r++;
          _right = null;
          _missed = false;
          _wrong.clear();
        });
        _ask();
      } else {
        setState(() => _finished = true);
        widget.onFinished(_score);
        app.say(P.found(_score, widget.activity.rounds.length));
      }
    } else {
      setState(() {
        _missed = true;
        _wrong.add(o);
      });
      // Errors teach: say the chosen item, then the target, so she hears the contrast.
      app.speech.sayAll([_repair[_rng.nextInt(_repair.length)], o.speech, P.listenAgain, _round.answer.speech]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final total = widget.activity.rounds.length;
    if (_finished) {
      return ListView(padding: const EdgeInsets.all(24), children: [
        const SizedBox(height: 24),
        const Center(child: Icon(Icons.check_circle_rounded, color: C.success, size: 96)),
        const SizedBox(height: 12),
        Text(context.tr('Exercice fini', 'Exercise finished'), textAlign: TextAlign.center, style: t.headlineMedium),
        const SizedBox(height: 6),
        Text(context.tr('Tu as trouvé $_score sur $total du premier coup.', '$_score of $total right on the first try.'), textAlign: TextAlign.center, style: t.bodyLarge),
        const SizedBox(height: 8),
        Text(context.tr('Appuie sur « Suivant ».', 'Press “Next”.'), textAlign: TextAlign.center, style: t.bodySmall),
      ]);
    }
    final r = _round;
    final cols = r.options.length == 4 ? 2 : r.options.length;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
      Row(children: [
        for (var i = 0; i < total; i++)
          Expanded(
            child: Container(
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: i < _r ? C.teal : i == _r ? C.tealMid : C.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
      ]),
      const SizedBox(height: 18),
      Panel(
        color: C.magentaSoft,
        borderColor: const Color(0xFFF3C3D0),
        onTap: _ask,
        child: Row(children: [
          Expanded(child: Text(context.app.english ? _promptEn(r.prompt) : r.prompt, style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w700))),
          const SizedBox(width: 10),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(color: C.magenta, shape: BoxShape.circle),
            child: const Icon(Icons.replay_rounded, color: Colors.white, size: 32),
          ),
        ]),
      ),
      const SizedBox(height: 8),
      Text(
          r.listen
              ? context.tr('Appuie sur le bouton rose pour réécouter.', 'Press the pink button to hear it again.')
              : context.tr('Appuie sur le bouton rose pour entendre la consigne.', 'Press the pink button to hear the instruction.'),
          style: t.bodySmall),
      const SizedBox(height: 18),
      GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: cols == 3 ? 0.95 : 1.35,
        children: [for (final o in r.options) _OptionCard(o, state: _stateOf(o), onTap: () => _tap(o))],
      ),
    ]);
  }

  _OptState _stateOf(Opt o) {
    if (_right == o) return _OptState.right;
    if (_wrong.contains(o)) return _OptState.wrong;
    return _OptState.idle;
  }
}

/// English gloss of a French prompt, for the debug language toggle only.
String _promptEn(String fr) {
  final m = RegExp(r'^Touche la lettre (\S+)( majuscule| en écriture cursive)?$').firstMatch(fr);
  if (m != null) {
    final kind = m.group(2) == null ? '' : m.group(2)!.contains('majuscule') ? ' (capital)' : ' (cursive)';
    return 'Tap the letter ${m.group(1)}$kind';
  }
  return switch (fr) {
    P.promptSyllable => 'Listen and tap the syllable',
    P.promptWord => 'Listen and tap the word',
    P.promptDigit => 'Listen and tap the digit',
    P.promptSound => 'Listen and tap the sound',
    _ => fr,
  };
}

enum _OptState { idle, right, wrong }

class _OptionCard extends StatelessWidget {
  final Opt o;
  final _OptState state;
  final VoidCallback onTap;
  const _OptionCard(this.o, {required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (bg, border, icon) = switch (state) {
      _OptState.right => (C.successSoft, C.success, Icons.check_circle_rounded),
      _OptState.wrong => (C.canvas, C.locked, Icons.hearing_rounded),
      _OptState.idle => (C.surface, C.border, null),
    };
    final long = o.show.length > 8;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border, width: state == _OptState.idle ? 1.5 : 3),
          boxShadow: const [BoxShadow(color: Color(0x141F2937), offset: Offset(0, 3))],
        ),
        child: Stack(children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: ScriptText(o.show,
                    cursive: o.cursive,
                    size: long ? 26 : 46,
                    align: TextAlign.center,
                    color: state == _OptState.wrong ? C.inkSoft : C.ink),
              ),
            ),
          ),
          if (icon != null)
            Positioned(
              right: 8,
              top: 8,
              child: Icon(icon, color: state == _OptState.right ? C.success : C.inkSoft, size: 26),
            ),
        ]),
      ),
    );
  }
}
