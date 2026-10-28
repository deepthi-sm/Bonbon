import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import 'choice_activity.dart';
import 'contract.dart';

typedef ActivityBuilder = Widget Function(
  ActivitySpec spec,
  ValueChanged<ActivityResult> onComplete,
  ValueChanged<SkipReason> onSkip,
);

/// One builder per activity type (plan §O.3: a registry instead of a switch).
/// Append-only, in alphabetical order, one line per type, so two branches
/// adding types never conflict on the same line.
final Map<ActivityType, ActivityBuilder> activityRegistry = {
  ActivityType.listenChoose: (spec, done, skip) => ChoiceActivity(key: ValueKey(spec.id), spec: spec, onComplete: done),
  // ActivityType.missingLetter: not built yet
  // ActivityType.syllableBuild: not built yet
  ActivityType.tapIdentify: (spec, done, skip) => ChoiceActivity(key: ValueKey(spec.id), spec: spec, onComplete: done),
  // ActivityType.trace: not built yet
};

/// Shows any registered activity from its spec (plan §E.2, task B2). The
/// lesson player only needs this widget; it never knows the activity types.
///
/// A type with no builder yet shows a "Continuer" card that skips, so a
/// lesson is never stuck on an activity that isn't built.
class ActivityHost extends StatelessWidget {
  final ActivitySpec spec;
  final ValueChanged<ActivityResult> onComplete;
  final ValueChanged<SkipReason> onSkip;

  const ActivityHost({super.key, required this.spec, required this.onComplete, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final builder = activityRegistry[spec.type];
    if (builder != null) return builder(spec, onComplete, onSkip);
    return ListView(padding: const EdgeInsets.all(24), children: [
      const SizedBox(height: 24),
      const Center(child: Icon(Icons.construction_rounded, color: C.inkSoft, size: 72)),
      const SizedBox(height: 12),
      Text(
        context.tr('Exercice bientôt prêt', 'Exercise coming soon'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 4),
      Text(spec.type.key, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 20),
      PressButton(
        label: context.tr('Continuer', 'Continue'),
        icon: Icons.arrow_forward_rounded,
        onTap: () => onSkip(SkipReason.user),
      ),
    ]);
  }
}
