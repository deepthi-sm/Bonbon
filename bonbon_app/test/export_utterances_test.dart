// Lists every French sentence the app can speak, with where it first appears,
// so the team can record it.
// Run:  flutter test test/export_utterances_test.dart
// Writes tool/utterances.json, read by tool/audio.py (recording script + manifest).
import 'dart:convert';
import 'dart:io';

import 'package:bonbon/data/content.dart';
import 'package:bonbon/data/phrases.dart';
import 'package:bonbon/screens/lesson_player.dart';
import 'package:bonbon/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('export utterances', () async {
    final repo = await ContentRepo.load();
    final out = <String, Map<String, String>>{}; // normalised -> {text, where}
    var where = 'Interface';

    void add(String? s) {
      if (s == null || s.trim().isEmpty) return;
      out.putIfAbsent(Speech.norm(s), () => {'text': s.trim().replaceAll(RegExp(r'\s+'), ' '), 'where': where});
    }

    void addSentence(String text, String speech) {
      add(speech);
      for (final w in wordsOf(text)) {
        add(w);
      }
    }

    for (final s in P.fixed) {
      add(s);
    }
    for (var total = 1; total <= 4; total++) {
      for (var score = 0; score <= total; score++) {
        add(P.found(score, total));
      }
    }
    for (final (i, u) in repo.units.indexed) {
      add(u.spokenName(i + 1));
    }
    for (final e in repo.alphabet) {
      add(e.lower);
    }

    for (final l in repo.lessons) {
      where = l.isDigit ? 'Chiffre ${l.number}' : 'Leçon ${l.number.toString().padLeft(2, '0')}';
      add(l.spokenName);
      add(l.keyword);
      if (!l.isDigit) {
        for (final t in l.targets) {
          add(t);
        }
      } else {
        add(l.targets[1]);
      }
      for (final b in l.blocks) {
        final raw = b.raw;
        add(raw['audio']?['fallbackText'] as String?);
        final cap = raw['caption'] as Map?;
        if (cap != null) add((cap['audio']?['fallbackText'] ?? cap['text']) as String?);
        add(b.str('title'));
        for (final key in ['items', 'paragraphs']) {
          for (final it in b.items(key)) {
            if (b.type == 'writing_practice') continue; // written, not spoken
            addSentence(it.text, it.speech);
          }
        }
        if (raw['word'] != null) add(TextItem.fromJson(raw['word'] as Json).speech);
        final turns = [
          ...((raw['turns'] as List?) ?? const []),
          for (final seg in (raw['segments'] as List?) ?? const [])
            if ((seg as Map)['type'] == 'dialogue') ...(seg['turns'] as List) else seg,
        ];
        for (final t in turns) {
          final m = t as Map;
          addSentence(m['text'] as String, (m['audio']?['fallbackText'] ?? m['text']) as String);
        }
      }
      for (final s in buildSteps(l, repo).whereType<ActivityStep>()) {
        for (final r in s.activity.rounds) {
          add(r.prompt);
          for (final o in r.options) {
            add(o.speech);
          }
        }
      }
    }

    final list = out.values.toList(); // lesson order: record lesson by lesson
    final chars = list.fold<int>(0, (n, s) => n + s['text']!.length);
    File('tool/utterances.json')
      ..createSync(recursive: true)
      ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(list));
    // ignore: avoid_print
    print('${list.length} utterances, $chars characters -> tool/utterances.json');
    expect(list.length, greaterThan(500));
  });
}
