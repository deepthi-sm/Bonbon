import 'package:flutter/material.dart';

import '../data/phrases.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'activity_host.dart';
import 'assessment.dart';
import 'contract.dart';
import 'repair_ladder.dart';

/// Plays a Bilan or a checkpoint: a short intro, each part through
/// [ActivityHost], then the outcome. Never a gate: « Continuer » is always
/// there, whatever the score. [onDone] gets the result once the last part
/// ends; [onContinue] is the way out; [onReview], when given, offers
/// « Revoir maintenant » below the threshold — offered, never imposed.
class AssessmentHost extends StatefulWidget {
  final Assessment assessment;
  final ValueChanged<AssessmentResult> onDone;
  final VoidCallback onContinue;
  final VoidCallback? onReview;
  const AssessmentHost({
    super.key,
    required this.assessment,
    required this.onDone,
    required this.onContinue,
    this.onReview,
  });

  @override
  State<AssessmentHost> createState() => _AssessmentHostState();
}

class _AssessmentHostState extends State<AssessmentHost> {
  int _part = -1; // -1: the intro
  final List<ActivityResult> _results = [];
  AssessmentResult? _result;

  Assessment get _a => widget.assessment;

  void _start() => setState(() => _part = 0);

  Future<void> _record(ActivityResult r) async {
    _results.add(r);
    // Let her see the part's own ending before the next one starts.
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    if (_part + 1 < _a.parts.length) {
      setState(() => _part++);
      return;
    }
    final result = AssessmentResult(_a, _results);
    setState(() => _result = result);
    widget.onDone(result);
    final app = context.app;
    final found = P.found(result.parts.fold(0, (n, p) => n + p.firstTryCount), _a.itemCount);
    app.speech.sayAll([
      if (result.passed && _a.spoken != null) _a.spoken!,
      if (result.passed && _a.spoken == null && app.speech.has(found)) found,
      if (!result.passed) RepairLadder.sayMoveOn, // « On continue. Tu la reverras. »
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    if (r != null) return _Outcome(result: r, onContinue: widget.onContinue, onReview: widget.onReview);
    if (_part < 0) return _Intro(assessment: _a, onStart: _start);
    final spec = _a.parts[_part];
    return ActivityHost(
      key: ValueKey('${_a.id}/$_part'),
      spec: spec,
      onComplete: _record,
      onSkip: (why) => _record(ActivityResult.skippedBy(spec, why)),
    );
  }
}

class _Intro extends StatelessWidget {
  final Assessment assessment;
  final VoidCallback onStart;
  const _Intro({required this.assessment, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final n = assessment.itemCount;
    return ListView(padding: const EdgeInsets.all(24), children: [
      const SizedBox(height: 24),
      const Center(child: Icon(Icons.emoji_events_rounded, color: C.gold, size: 96)),
      const SizedBox(height: 12),
      Text(
        assessment.isCheckpoint ? context.tr('Point d\'étape', 'Checkpoint') : context.tr('Bilan', 'Review'),
        textAlign: TextAlign.center,
        style: t.headlineMedium,
      ),
      const SizedBox(height: 8),
      Text(
        context.tr('$n petites questions. Ce n\'est pas un examen : tu continues quoi qu\'il arrive.',
            '$n short questions. It isn\'t a test: you carry on whatever happens.'),
        textAlign: TextAlign.center,
        style: t.bodyLarge,
      ),
      const SizedBox(height: 24),
      PressButton(label: context.tr('Commencer', 'Start'), icon: Icons.play_arrow_rounded, onTap: onStart),
    ]);
  }
}

class _Outcome extends StatelessWidget {
  final AssessmentResult result;
  final VoidCallback onContinue;
  final VoidCallback? onReview;
  const _Outcome({required this.result, required this.onContinue, required this.onReview});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final a = result.assessment;
    final review = result.reviewTargets;
    return ListView(padding: const EdgeInsets.all(24), children: [
      const SizedBox(height: 24),
      Center(
        child: Icon(result.passed ? Icons.emoji_events_rounded : Icons.replay_circle_filled_rounded,
            color: result.passed ? C.gold : C.teal, size: 96),
      ),
      const SizedBox(height: 12),
      Text(
        result.passed ? a.celebration ?? context.tr('Bien lu !', 'Well read!') : context.tr('On continue.', 'Let\'s carry on.'),
        textAlign: TextAlign.center,
        style: t.headlineSmall,
      ),
      if (review.isNotEmpty) ...[
        const SizedBox(height: 14),
        Text(context.tr('Tu les reverras bientôt :', 'You\'ll see these again soon:'), textAlign: TextAlign.center, style: t.bodyLarge),
        const SizedBox(height: 8),
        Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
          for (final x in review)
            Chip(label: Text(x, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)), backgroundColor: C.tealSoft),
        ]),
      ],
      const SizedBox(height: 24),
      if (!result.passed && onReview != null) ...[
        PressButton.ghost(label: context.tr('Revoir maintenant', 'Review now'), icon: Icons.replay_rounded, onTap: onReview),
        const SizedBox(height: 12),
      ],
      PressButton(label: context.tr('Continuer', 'Continue'), icon: Icons.arrow_forward_rounded, onTap: onContinue),
    ]);
  }
}
