import 'package:flutter/material.dart';

import '../data/phrases.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'choice_session.dart';
import 'activity_top_bar.dart';
import 'contract.dart';
import 'feedback.dart';

/// tap-identify, listen-choose, syllable-build and missing-letter on screen,
/// with the repair ladder. Same look as the prototype's ActivityView
/// (lib/screens/activities.dart); the rules live in [ChoiceSession].
///
/// syllable-build adds the consonant tile and an empty slot, missing-letter
/// the word with a blank: she drags a tile into it, or simply taps it. A
/// wrong tile shows in the slot while the word it built is spoken.
class ChoiceActivity extends StatefulWidget {
  final ActivitySpec spec;
  final ValueChanged<ActivityResult> onComplete;
  final ValueChanged<SkipReason>? onSkip;
  const ChoiceActivity({super.key, required this.spec, required this.onComplete, this.onSkip});

  @override
  State<ChoiceActivity> createState() => _ChoiceActivityState();
}

class _ChoiceActivityState extends State<ChoiceActivity> {
  late final ChoiceSession _s = ChoiceSession(widget.spec);
  bool _reported = false;

  /// missing-letter tier 1 (wordVisibleFirst): the whole word, before the blank.
  bool _whole = false;

  /// The wrong tile shown in the slot while what it built is spoken.
  String? _tried;

  bool get _missing => widget.spec.type == ActivityType.missingLetter;

  /// « Passer », when the spec allows it: stop speaking and hand back.
  VoidCallback? get _skip => widget.onSkip == null || !widget.spec.allowSkip || _reported
      ? null
      : () {
          _reported = true;
          context.app.speech.stop();
          widget.onSkip!(SkipReason.user);
        };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ask(intro: true));
  }

  Future<void> _ask({bool intro = false}) async {
    if (!mounted || _s.finished) return;
    final speech = context.app.speech;
    if (intro && _missing && widget.spec.tier == 1) {
      final at = _s.index;
      setState(() => _whole = true);
      await speech.sayAll([_s.item.heard]);
      if (!mounted || _s.index != at) return;
      setState(() => _whole = false);
    }
    await speech.sayAll(_s.askParts);
  }

  Future<void> _tap(int cell) async {
    final tried = _s.item.options[cell].show;
    final out = _s.tap(cell);
    if (out == null) return;
    setState(() {
      _whole = false;
      _tried = out.correct ? null : tried;
    });
    final app = context.app;
    await app.speech.sayAll(out.say);
    if (!mounted) return;
    if (_tried == tried) setState(() => _tried = null);
    if (!out.itemDone) return;
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(_s.next);
    if (_s.finished) {
      if (!_reported) {
        _reported = true;
        widget.onComplete(_s.result);
      }
      app.say(P.found(_s.result.firstTryCount, _s.total));
    } else {
      _ask(intro: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    if (_s.finished) {
      final first = _s.result.firstTryCount;
      return ListView(padding: const EdgeInsets.all(24), children: [
        const SizedBox(height: 24),
        const Center(child: Icon(Icons.check_circle_rounded, color: C.success, size: 96)),
        const SizedBox(height: 12),
        Text(context.tr('Exercice fini', 'Exercise finished'), textAlign: TextAlign.center, style: t.headlineMedium),
        const SizedBox(height: 6),
        Text(context.tr('Tu as trouvé $first sur ${_s.total} du premier coup.', '$first of ${_s.total} right on the first try.'),
            textAlign: TextAlign.center, style: t.bodyLarge),
      ]);
    }

    final item = _s.item;
    final n = item.options.length;
    final build = widget.spec.type == ActivityType.syllableBuild;
    final fill = build || _missing; // tiles go into a slot
    final cols = fill ? n.clamp(2, 4) : n == 4 ? 2 : 3;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
      ActivityTopBar(total: _s.total, index: _s.index, onSkip: _skip),
      const SizedBox(height: 18),
      Panel(
        color: C.magentaSoft,
        borderColor: const Color(0xFFF3C3D0),
        onTap: _ask,
        child: Row(children: [
          Expanded(
            // syllable-build tier 3 is audio only: the instruction is heard, not read.
            child: build && widget.spec.tier == 3
                ? const Align(alignment: Alignment.centerLeft, child: Icon(Icons.hearing_rounded, color: C.magenta, size: 40))
                : Text(item.prompt, style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
          ),
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
          item.listen
              ? context.tr('Appuie sur le bouton rose pour réécouter.', 'Press the pink button to hear it again.')
              : context.tr('Appuie sur le bouton rose pour entendre la consigne.', 'Press the pink button to hear the instruction.'),
          style: t.bodySmall),
      if (build) ...[
        const SizedBox(height: 18),
        _BuildRow(
          consonant: item.fixed!,
          built: _s.found.isEmpty ? null : item.answer.show,
          tried: _tried,
          model: widget.spec.tier == 1 ? item.target : null,
          onDrop: _tap,
        ),
      ],
      if (_missing) ...[
        const SizedBox(height: 18),
        _WordRow(
          word: item.target,
          blankAt: item.blankAt!,
          blankLength: item.blankLength,
          filled: _whole || _s.found.isNotEmpty ? item.answer.show : null,
          right: _s.found.isNotEmpty,
          tried: _tried,
          onDrop: _tap,
        ),
      ],
      const SizedBox(height: 18),
      GridView.count(
        crossAxisCount: cols,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: fill || cols == 3 ? 0.95 : 1.35,
        children: [
          for (var c = 0; c < n; c++)
            if (fill && _s.canTap(c))
              _draggable(c, _Cell(item.options[c], state: _stateOf(c), onTap: () => _tap(c)))
            else
              _Cell(item.options[c], state: _stateOf(c), onTap: () => _tap(c)),
        ],
      ),
    ]);
  }

  /// A vowel tile she can drag onto the slot; the dragged copy is the tile itself.
  Widget _draggable(int c, Widget cell) => LayoutBuilder(
        builder: (context, box) => Draggable<int>(
          data: c,
          feedback: Material(
            color: Colors.transparent,
            child: SizedBox(width: box.maxWidth, height: box.maxHeight, child: cell),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: cell),
          child: cell,
        ),
      );

  Mark _stateOf(int c) {
    if (_s.found.contains(c)) return Mark.right;
    if (_s.wrongCells.contains(c)) return Mark.tried;
    if (_s.faded.contains(c)) return Mark.faded;
    if (_s.modelShown && _s.item.isCorrect(_s.item.options[c])) return Mark.model;
    return Mark.idle;
  }
}

/// syllable-build: the consonant, a slot for the vowel and, on tier 1, the
/// written syllable as a model underneath.
class _BuildRow extends StatelessWidget {
  final String consonant;
  final String? built; // the vowel, once found
  final String? tried; // a wrong vowel, while what it built is spoken
  final String? model;
  final ValueChanged<int> onDrop;
  const _BuildRow({required this.consonant, required this.built, required this.tried, required this.model, required this.onDrop});

  @override
  Widget build(BuildContext context) {
    const size = BoxConstraints.tightFor(width: 96, height: 104);
    Widget letter(String s, {Color color = C.ink}) => ScriptText(s, cursive: false, size: 52, align: TextAlign.center, color: color);
    final mark = built != null ? Mark.right : tried != null ? Mark.tried : Mark.idle;
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          constraints: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: C.tealSoft,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: C.teal, width: 3),
          ),
          child: letter(consonant),
        ),
        const SizedBox(width: 12),
        DragTarget<int>(
          onAcceptWithDetails: (d) => onDrop(d.data),
          builder: (context, hovering, _) => Marked(
            mark: mark,
            constraints: size,
            showIcon: false,
            fill: hovering.isEmpty ? C.canvas : C.goldSoft,
            border: hovering.isEmpty ? C.border : C.gold,
            child: built != null
                ? letter(built!)
                : tried != null
                    ? letter(tried!, color: MarkStyle.of(Mark.tried).ink)
                    : const SizedBox.shrink(),
          ),
        ),
      ]),
      if (model != null) ...[
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.visibility_rounded, color: C.inkSoft, size: 22),
          const SizedBox(width: 8),
          ScriptText(model!, cursive: false, size: 30, color: C.inkSoft),
        ]),
      ],
    ]);
  }
}

/// missing-letter: the word with one letter replaced by a slot. The slot
/// shows the answer while the whole word is presented and once found, and
/// a wrong letter while the word it built is spoken.
class _WordRow extends StatelessWidget {
  final String word;
  final int blankAt, blankLength;
  final String? filled;
  final bool right;
  final String? tried;
  final ValueChanged<int> onDrop;
  const _WordRow({
    required this.word,
    required this.blankAt,
    required this.blankLength,
    required this.filled,
    required this.right,
    required this.tried,
    required this.onDrop,
  });

  @override
  Widget build(BuildContext context) {
    const size = 50.0;
    Widget text(String s, {Color color = C.ink}) => ScriptText(s, cursive: false, size: size, color: color);
    final letter = filled ?? tried;
    return Panel(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (blankAt > 0) text(word.substring(0, blankAt)),
          DragTarget<int>(
            onAcceptWithDetails: (d) => onDrop(d.data),
            builder: (context, hovering, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Marked(
                mark: right ? Mark.right : filled == null && tried != null ? Mark.tried : Mark.idle,
                radius: 12,
                showIcon: false,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 68),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                // While the whole word is shown, the slot is just a letter of it.
                fill: filled != null ? Colors.transparent : hovering.isEmpty ? C.canvas : C.goldSoft,
                border: filled != null ? Colors.transparent : C.gold,
                child: letter == null
                    ? const SizedBox(width: 40)
                    : text(letter, color: filled == null ? MarkStyle.of(Mark.tried).ink : C.ink),
              ),
            ),
          ),
          if (blankAt + blankLength < word.length) text(word.substring(blankAt + blankLength)),
        ]),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final Choice o;
  final Mark state;
  final VoidCallback onTap;
  const _Cell(this.o, {required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final long = o.show.length > 8;
    return GestureDetector(
      onTap: onTap,
      child: Marked(
        mark: state,
        shadow: true,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ScriptText(o.show,
                cursive: o.cursive, size: long ? 26 : 46, align: TextAlign.center, color: MarkStyle.of(state).ink),
          ),
        ),
      ),
    );
  }
}
