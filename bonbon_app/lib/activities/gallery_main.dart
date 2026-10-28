/// Dev B's activity gallery (plan §R.2, `/dev/activities`): every activity
/// type playable on its own, from the fixtures or generated for any lesson.
/// A separate entry point, so the app's own main.dart is untouched:
///
///   flutter run -t lib/activities/gallery_main.dart -d chrome
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/content.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'activity_host.dart';
import 'contract.dart';
import 'fixtures.dart';
import 'generators.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState(await ContentRepo.load(), await SharedPreferences.getInstance(), await Speech.load());
  runApp(AppScope(state: state, child: const _GalleryApp()));
}

class _GalleryApp extends StatelessWidget {
  const _GalleryApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Bonbon · activités',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        builder: (context, child) => ColoredBox(
          color: const Color(0xFFEDE7DD),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: MissingAudioBanner(child: child!),
            ),
          ),
        ),
        home: const ActivityGallery(),
      );
}

class ActivityGallery extends StatefulWidget {
  const ActivityGallery({super.key});

  @override
  State<ActivityGallery> createState() => _ActivityGalleryState();
}

class _ActivityGalleryState extends State<ActivityGallery> {
  String _lesson = 'L08';

  @override
  Widget build(BuildContext context) {
    final repo = context.app.repo;
    final lesson = repo.byKey(_lesson)!;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Activités (dev)')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Fixtures', style: t.titleLarge),
        for (final s in allFixtures) _SpecTile(s),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: Text('Générées pour', style: t.titleLarge)),
          DropdownButton<String>(
            value: _lesson,
            items: [for (final l in repo.lessons) DropdownMenuItem(value: l.key, child: Text(l.key))],
            onChanged: (v) => setState(() => _lesson = v!),
          ),
        ]),
        Text(lesson.title, style: t.bodySmall),
        for (final s in specsFor(lesson, repo)) _SpecTile(s),
      ]),
    );
  }
}

class _SpecTile extends StatelessWidget {
  final ActivitySpec spec;
  const _SpecTile(this.spec);

  @override
  Widget build(BuildContext context) {
    final built = activityRegistry.containsKey(spec.type);
    return ListTile(
      title: Text(spec.id),
      subtitle: Text('${spec.items.length} items · tier ${spec.tier}${built ? '' : ' · pas encore construit'}'),
      trailing: const Icon(Icons.play_arrow_rounded),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _Play(spec))),
    );
  }
}

class _Play extends StatefulWidget {
  final ActivitySpec spec;
  const _Play(this.spec);

  @override
  State<_Play> createState() => _PlayState();
}

class _PlayState extends State<_Play> {
  ActivityResult? _result;

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return Scaffold(
      appBar: AppBar(title: Text(widget.spec.id)),
      body: Column(children: [
        Expanded(
          child: ActivityHost(
            spec: widget.spec,
            onComplete: (res) => setState(() => _result = res),
            onSkip: (why) => setState(() => _result = ActivityResult.skippedBy(widget.spec, why)),
          ),
        ),
        if (r != null)
          Container(
            width: double.infinity,
            color: C.surface,
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              'score ${r.score.toStringAsFixed(2)} · ${r.passed ? 'passed' : 'not passed'} · '
              'review ${r.reviewTargets}\n${const JsonEncoder.withIndent('  ').convert(r.toJson())}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
      ]),
    );
  }
}
