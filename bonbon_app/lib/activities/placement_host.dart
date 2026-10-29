import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import 'generators.dart' show HasAudio;
import 'placement.dart';

/// « Commencer au début » or « J'en connais déjà » (onboarding), then the
/// placement ladder and « Tu peux commencer ici. » Every screen is spoken
/// and keeps « Commencer au début » one tap away; choosing it, at any point,
/// gives L01 without a word about the test. Answers show no judgement.
class PlacementHost extends StatefulWidget {
  final ValueChanged<PlacementResult> onPlaced;

  /// Which probes have a recording; the app's own clips when null.
  final HasAudio? hasAudio;
  const PlacementHost({super.key, required this.onPlaced, this.hasAudio});

  @override
  State<PlacementHost> createState() => _PlacementHostState();
}

class _PlacementHostState extends State<PlacementHost> {
  PlacementSession? _s; // null: the offer
  int? _chosen; // the cell just tapped, before the next item

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.app.speech.sayAll([sayPlacementOffer]);
    });
  }

  void _fromStart() {
    final app = context.app;
    final s = _s;
    app.speech.stop();
    // From the offer she hears why it's a good choice; mid-test, nothing.
    if (s == null) app.speech.sayAll([sayFromStart]);
    widget.onPlaced(s == null ? const PlacementResult(placementFromStart, fromStart: true) : s.abandon());
  }

  void _begin() {
    setState(() => _s = PlacementSession(hasAudio: widget.hasAudio ?? context.app.speech.has));
    _ask();
  }

  void _ask() {
    final s = _s;
    if (s == null || s.finished) return;
    context.app.speech.sayAll(s.askParts);
  }

  Future<void> _tap(int cell) async {
    final s = _s!;
    if (_chosen != null || s.finished) return;
    setState(() => _chosen = cell);
    s.answer(s.item.options[cell]);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _chosen = null);
    if (s.finished) {
      final lesson = context.app.repo.byKey(s.result.startAt)!;
      context.app.speech.sayAll([sayPlacedHere, lesson.spokenName]);
    } else {
      _ask();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = _s;
    if (s == null) {
      return ListView(padding: const EdgeInsets.all(24), children: [
        const SizedBox(height: 24),
        Panel(
          color: C.magentaSoft,
          borderColor: const Color(0xFFF3C3D0),
          onTap: () => context.app.speech.sayAll([sayPlacementOffer]),
          child: Row(children: [
            Expanded(child: Text(sayPlacementOffer, style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w700))),
            const SizedBox(width: 10),
            const Icon(Icons.volume_up_rounded, color: C.magenta, size: 40),
          ]),
        ),
        const SizedBox(height: 24),
        PressButton(label: context.tr('Commencer au début', 'Start from the beginning'), icon: Icons.flag_rounded, onTap: _fromStart),
        const SizedBox(height: 12),
        PressButton.ghost(label: context.tr('J\'en connais déjà', 'I already know some'), icon: Icons.hearing_rounded, onTap: _begin),
      ]);
    }

    final top = Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: _fromStart,
        icon: const Icon(Icons.flag_rounded),
        label: Text(context.tr('Commencer au début', 'Start from the beginning')),
      ),
    );

    if (s.finished) {
      final lesson = context.app.repo.byKey(s.result.startAt)!;
      return ListView(padding: const EdgeInsets.all(24), children: [
        top,
        const SizedBox(height: 12),
        const Center(child: Icon(Icons.flag_circle_rounded, color: C.teal, size: 96)),
        const SizedBox(height: 12),
        // Never a score, never a level name: where to start, nothing else.
        Text(sayPlacedHere, textAlign: TextAlign.center, style: t.headlineMedium),
        const SizedBox(height: 6),
        Text('${lesson.heading} · ${lesson.title}', textAlign: TextAlign.center, style: t.titleLarge),
        const SizedBox(height: 24),
        PressButton(label: context.tr('Commencer', 'Start'), icon: Icons.arrow_forward_rounded, onTap: () => widget.onPlaced(s.result)),
      ]);
    }

    final item = s.item;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
      top,
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
      const SizedBox(height: 18),
      GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        children: [
          for (final (c, o) in item.options.indexed)
            GestureDetector(
              onTap: () => _tap(c),
              // A neutral « got it » on the tapped cell: teal, never green or grey.
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _chosen == c ? C.tealSoft : C.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _chosen == c ? C.teal : C.border, width: _chosen == c ? 3 : 1.5),
                ),
                child: ScriptText(o.show, cursive: false, size: 46, align: TextAlign.center),
              ),
            ),
        ],
      ),
    ]);
  }
}
