import 'package:flutter/material.dart';

import '../data/phrases.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'choice_session.dart';
import 'contract.dart';

/// tap-identify, listen-choose and syllable-build on screen, with the repair
/// ladder. Same look as the prototype's ActivityView
/// (lib/screens/activities.dart); the rules live in [ChoiceSession].
///
/// syllable-build adds the consonant tile and an empty slot: she drags a
/// vowel into the slot, or simply taps it.
class ChoiceActivity extends StatefulWidget {
  final ActivitySpec spec;
  final ValueChanged<ActivityResult> onComplete;
  const ChoiceActivity({super.key, required this.spec, required this.onComplete});

  @override
  State<ChoiceActivity> createState() => _ChoiceActivityState();
}

class _ChoiceActivityState extends State<ChoiceActivity> {
  late final ChoiceSession _s = ChoiceSession(widget.spec);
  bool _reported = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ask());
  }

  void _ask() {
    if (!mounted || _s.finished) return;
    context.app.speech.sayAll(_s.askParts);
  }

  Future<void> _tap(int cell) async {
    final out = _s.tap(cell);
    if (out == null) return;
    setState(() {});
    final app = context.app;
    await app.speech.sayAll(out.say);
    if (!mounted || !out.itemDone) return;
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
      _ask();
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
    final cols = build ? n.clamp(2, 4) : n == 4 ? 2 : 3;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
      Row(children: [
        for (var i = 0; i < _s.total; i++)
          Expanded(
            child: Container(
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: i < _s.index ? C.teal : i == _s.index ? C.tealMid : C.border,
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
          Expanded(child: Text(item.prompt, style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w700))),
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
          model: widget.spec.tier == 1 ? item.target : null,
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
        childAspectRatio: build || cols == 3 ? 0.95 : 1.35,
        children: [
          for (var c = 0; c < n; c++)
            if (build && _s.canTap(c))
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

  _CellState _stateOf(int c) {
    if (_s.found.contains(c)) return _CellState.right;
    if (_s.wrongCells.contains(c)) return _CellState.wrong;
    if (_s.faded.contains(c)) return _CellState.faded;
    if (_s.modelShown && _s.item.isCorrect(_s.item.options[c])) return _CellState.model;
    return _CellState.idle;
  }
}

enum _CellState { idle, right, wrong, faded, model }

/// syllable-build: the consonant, a slot for the vowel and, on tier 1, the
/// written syllable as a model underneath.
class _BuildRow extends StatelessWidget {
  final String consonant;
  final String? built; // the vowel, once found
  final String? model;
  final ValueChanged<int> onDrop;
  const _BuildRow({required this.consonant, required this.built, required this.model, required this.onDrop});

  @override
  Widget build(BuildContext context) {
    Widget tile(String? s, {required Color bg, required Color border, double width = 1.5}) => Container(
          width: 96,
          height: 104,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border, width: width),
          ),
          child: s == null ? null : ScriptText(s, cursive: false, size: 52, align: TextAlign.center),
        );
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        tile(consonant, bg: C.tealSoft, border: C.teal, width: 3),
        const SizedBox(width: 12),
        DragTarget<int>(
          onAcceptWithDetails: (d) => onDrop(d.data),
          builder: (context, hovering, _) => built != null
              ? tile(built, bg: C.successSoft, border: C.success, width: 3)
              : tile(null, bg: hovering.isEmpty ? C.canvas : C.goldSoft, border: hovering.isEmpty ? C.border : C.gold, width: 3),
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

class _Cell extends StatelessWidget {
  final Choice o;
  final _CellState state;
  final VoidCallback onTap;
  const _Cell(this.o, {required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Never colour alone (plan §J.3): every state also has an icon or fades.
    final (bg, border, icon) = switch (state) {
      _CellState.right => (C.successSoft, C.success, Icons.check_circle_rounded),
      _CellState.model => (C.goldSoft, C.gold, Icons.touch_app_rounded),
      _CellState.wrong => (C.canvas, C.locked, Icons.hearing_rounded),
      _CellState.faded || _CellState.idle => (C.surface, C.border, null),
    };
    final long = o.show.length > 8;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: state == _CellState.faded ? 0.25 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border, width: state == _CellState.idle || state == _CellState.faded ? 1.5 : 3),
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
                      color: state == _CellState.wrong ? C.inkSoft : C.ink),
                ),
              ),
            ),
            if (icon != null)
              Positioned(
                right: 8,
                top: 8,
                child: Icon(icon, color: state == _CellState.right ? C.success : state == _CellState.model ? C.gold : C.inkSoft, size: 26),
              ),
          ]),
        ),
      ),
    );
  }
}
