import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import 'contract.dart';
import 'feedback.dart';
import 'generators.dart' show traceGhost, traceTolerance;
import 'glyph_spec.dart';
import 'trace_rubric.dart';
import 'trace_pad.dart';
import 'trace_session.dart';

/// trace on screen: trace the ghosted letter, « Vérifier », a cue matched to
/// what went wrong, at most three attempts, never blocked. The rules live in
/// [TraceSession]; the drawing and measuring in [TracePad].
class TraceActivity extends StatefulWidget {
  final ActivitySpec spec;
  final ValueChanged<ActivityResult> onComplete;
  const TraceActivity({super.key, required this.spec, required this.onComplete});

  @override
  State<TraceActivity> createState() => _TraceActivityState();
}

class _TraceActivityState extends State<TraceActivity> {
  late final TraceSession _s = TraceSession(widget.spec);
  final _pad = GlobalKey<TracePadState>();
  bool _checking = false;

  /// Dev A's stroke data and the rubric; until both load (or if the stroke
  /// data doesn't exist yet), the pad scores coverage as the prototype did.
  Map<String, GlyphSpec> _glyphs = const {};
  TraceRubric? _rubric;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ask());
    Future.wait([loadGlyphSpecs(), loadTraceRubric()]).then((r) {
      if (mounted) {
        setState(() {
          _glyphs = r[0] as Map<String, GlyphSpec>;
          _rubric = r[1] as TraceRubric?;
        });
      }
    });
  }

  void _ask() {
    if (!mounted || _s.finished) return;
    context.app.speech.sayAll(_s.askParts);
  }

  Future<void> _check() async {
    final pad = _pad.currentState;
    if (pad == null || _checking || _s.itemDone) return;
    final app = context.app;
    if (pad.isEmpty) {
      app.speech.sayAll([_s.item.prompt]);
      return;
    }
    _checking = true;
    final r = await pad.score();
    _checking = false;
    if (r == null || !mounted) return;
    final out = _s.check(r);
    if (out == null) return;
    setState(() {});
    await app.speech.sayAll(out.say);
    if (mounted && !out.itemDone) {
      pad.clear();
      setState(_s.clear);
    }
  }

  void _clear() {
    _pad.currentState?.clear();
    setState(_s.clear);
  }

  void _next() {
    setState(_s.next);
    if (_s.finished) {
      widget.onComplete(_s.result);
    } else {
      _ask();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    if (_s.finished) {
      return ListView(padding: const EdgeInsets.all(24), children: [
        const SizedBox(height: 24),
        const Center(child: Icon(Icons.draw_rounded, color: C.teal, size: 96)),
        const SizedBox(height: 12),
        Text(context.tr('Exercice fini', 'Exercise finished'), textAlign: TextAlign.center, style: t.headlineMedium),
        const SizedBox(height: 12),
        for (final r in _s.results)
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(width: 56, child: Text(r.target, textAlign: TextAlign.center, style: t.headlineSmall)),
            _Stars(r.givenByApp ? 0 : (r.quality! * 3).round(), size: 32),
          ]),
      ]);
    }

    final item = _s.item;
    final stars = _s.stars;
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
      const SizedBox(height: 14),
      TracePad(
        key: _pad,
        glyph: item.answer.show,
        cursive: item.answer.cursive,
        ghost: traceGhost(widget.spec.tier),
        dots: widget.spec.tier == 1,
        tolerance: traceTolerance(widget.spec.tier),
        // Cursive tracing is V2 (plan §J.4): stroke data is print only.
        spec: item.answer.cursive ? null : _glyphs[item.answer.show],
        rubric: _rubric,
        mark: _s.modelShown
            ? Mark.model
            : _s.itemDone
                ? Mark.right
                : stars == 1
                    ? Mark.tried
                    : Mark.idle,
        onDraw: () {
          if (_s.stars != null && !_s.itemDone) setState(_s.clear);
        },
      ),
      if (stars != null) ...[
        const SizedBox(height: 10),
        Center(child: _Stars(_s.modelShown ? 0 : stars, size: 44)),
      ],
      const SizedBox(height: 12),
      if (_s.itemDone)
        PressButton(label: context.tr('Continuer', 'Continue'), icon: Icons.arrow_forward_rounded, onTap: _next)
      else
        Row(children: [
          Expanded(
            child: PressButton.ghost(label: context.tr('Effacer', 'Clear'), icon: Icons.delete_outline_rounded, onTap: _clear),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PressButton(label: context.tr('Vérifier', 'Check'), icon: Icons.check_circle_outline_rounded, onTap: _check),
          ),
        ]),
      // No attempt counter on screen: it would read as lives (repair-ladder.json, neverDo).
    ]);
  }
}

class _Stars extends StatelessWidget {
  final int n;
  final double size;
  const _Stars(this.n, {required this.size});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < 3; i++)
          Icon(i < n ? Icons.star_rounded : Icons.star_outline_rounded, color: i < n ? C.gold : C.locked, size: size),
      ]);
}
