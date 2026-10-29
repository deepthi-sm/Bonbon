import 'dart:convert';
import 'dart:io';

import 'package:bonbon/activities/comprehension.dart';
import 'package:bonbon/data/content.dart';
import 'package:flutter_test/flutter_test.dart';

/// Batonga's questions (workflow step 2). Every set here must pass.
const questionsFile = '../docs/comprehension/questions.json';

/// The export for Batonga (workflow step 1), regenerated with BONBON_EXPORT=1.
const exportFile = '../docs/textes-a-questionner.md';

String norm(String s) => s.replaceAll('\r\n', '\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ContentRepo repo;
  setUpAll(() async => repo = await ContentRepo.load());

  Set<String> rules(List<Finding> fs, [Severity s = Severity.error]) => {for (final f in fs) if (f.severity == s) '${f.questionId ?? f.textId} ${f.rule}'};

  /// A set that follows every rule, for T30 (« le choix » … lesson 30).
  QuestionSet good() {
    final t = readingTexts(repo).firstWhere((t) => t.textId == 'T30');
    return QuestionSet.fromJson({
      'textId': 'T30',
      'lessonId': 'L30',
      'status': 'approved',
      'signedOffBy': 'Batonga — test',
      'questions': [
        {
          'id': 'T30.q1', 'kind': 'littérale', 'mode': 'image-2', 'prompt': 'Où va Benoît ?', 'audioId': 'q.T30.q1',
          'options': [{'illustrationId': 'a', 'correct': true}, {'illustrationId': 'b'}],
          'onWrong': {'replaySegment': t.segments.first.$1},
        },
        {
          'id': 'T30.q2', 'kind': 'lexicale', 'mode': 'image-3', 'prompt': 'Montre la noix de coco.', 'audioId': 'q.T30.q2',
          'options': [{'illustrationId': 'a', 'correct': true}, {'illustrationId': 'b'}, {'illustrationId': 'c'}],
          'onWrong': {'replaySegment': t.segments.last.$1},
        },
        {'id': 'T30.q3', 'kind': 'personnelle', 'mode': 'replay-only', 'prompt': 'Et toi, as-tu des noix ?', 'audioId': 'q.T30.q3', 'scored': false},
      ],
    });
  }

  QuestionSet edit(void Function(Map<String, dynamic> j) change) {
    final g = good();
    final j = {
      'textId': g.textId,
      'lessonId': g.lessonKey,
      'status': g.status,
      'signedOffBy': g.signedOffBy,
      'questions': [
        for (final q in g.questions)
          {
            'id': q.id, 'kind': q.kind, 'mode': q.mode, 'prompt': q.prompt, 'audioId': q.audioId, 'scored': q.scored,
            'options': [for (final o in q.options) {'illustrationId': o.illustrationId, 'text': o.text, 'correct': o.correct}],
            if (q.replaySegment != null) 'onWrong': {'replaySegment': q.replaySegment},
          },
      ],
    };
    change(j);
    return QuestionSet.fromJson(j);
  }

  Map<String, dynamic> q(Map<String, dynamic> j, int n) => (j['questions'] as List)[n] as Map<String, dynamic>;

  test('the reading texts: ids from the audio grammar, a dialogue turn per segment', () {
    final texts = readingTexts(repo);
    expect(texts, hasLength(26), reason: 'the plan says 28; the content has 26 (L34 and L40 have none)');
    expect(texts.map((t) => t.textId).toSet(), hasLength(texts.length));
    expect(texts.first.segments.first.$1, 'T25.s01');
    expect(texts.firstWhere((t) => t.textId == 'T30').segments, hasLength(4), reason: 'narration + 2 turns + narration');
  });

  test('a set that follows every rule has no error', () {
    expect(rules(validateComprehension([good()], repo)), isEmpty);
  });

  test('each hard rule is enforced', () {
    final cases = <String, QuestionSet>{
      'T30 count': edit((j) => (j['questions'] as List).add(q(j, 0))),
      // lexicale first: reported on that question, which keeps its id T30.q2
      'T30.q2 kind': edit((j) => (j['questions'] as List).insert(0, (j['questions'] as List).removeAt(1))),
      'T30.q1 mode': edit((j) => q(j, 0)['mode'] = 'phrase-pick'), // before lesson 36
      'T30.q1 options': edit((j) => (q(j, 0)['options'] as List).removeLast()),
      'T30.q1 onWrong': edit((j) => q(j, 0).remove('onWrong')),
      'T30.q1 spoken': edit((j) => q(j, 0)['audioId'] = null),
      'T30.q1 subject': edit((j) => q(j, 0)['prompt'] = 'Quel est le titre ?'),
      'T30.q1 decodable': edit((j) => q(j, 0)['prompt'] = 'Où est la chèvre ?'), // ch is L50
      'T30.q3 scored': edit((j) => q(j, 2)['scored'] = true),
    };
    for (final e in cases.entries) {
      expect(rules(validateComprehension([e.value], repo)), contains(e.key), reason: e.key);
    }
  });

  test('a word the book has already shown her is fine even if its graphemes come later', () {
    // « une » has no grapheme beyond the letters, « Benoît » is in T30's own text.
    expect(rules(validateComprehension([edit((j) => q(j, 0)['prompt'] = 'Où va Benoît avec une noix ?')], repo)), isEmpty);
  });

  test('pending, not errors: no recording, no sign-off, pictures to draw', () {
    final draft = edit((j) => j['status'] = 'draft');
    final fs = validateComprehension([draft], repo, hasAudio: (_) => false);
    expect(rules(fs), isEmpty);
    expect(rules(fs, Severity.pending), containsAll(['T30 signoff', 'T30.q1 spoken', 'T30.q1 illustration']));
    expect(shippable([draft], fs), isEmpty, reason: 'nothing ships without a named sign-off');
    expect(shippable([good()], validateComprehension([good()], repo)), hasLength(1));
  });

  test('the plan\'s own worked example (T27) breaks five rules — the validator is needed', () {
    final j = jsonDecode(File('../docs/batonga-addon-packs/batonga-addon-packs/02-exercices/comprehension.json').readAsStringSync());
    final fs = validateComprehension([QuestionSet.fromJson(j['workedExample'] as Map<String, dynamic>)], repo);
    expect(rules(fs), {'T27.q2 mode', 'T27.q2 onWrong', 'T27.q3 decodable'});
    expect(fs.where((f) => f.rule == 'decodable').map((f) => f.message), everyElement(contains('not taught by L27')));
  });

  test('Batonga\'s questions file passes (CI gate)', () {
    final sets = [
      for (final s in jsonDecode(File(questionsFile).readAsStringSync()) as List) QuestionSet.fromJson(s as Map<String, dynamic>),
    ];
    final errors = validateComprehension(sets, repo).where((f) => f.severity == Severity.error).toList();
    expect(errors, isEmpty, reason: errors.join('\n'));
  });

  test('the export for Batonga is up to date', () {
    final fresh = exportForBatonga(repo);
    final file = File(exportFile);
    if (Platform.environment['BONBON_EXPORT'] == '1') file.writeAsStringSync(fresh);
    expect(norm(file.readAsStringSync()), norm(fresh), reason: 'run BONBON_EXPORT=1 flutter test test/comprehension_test.dart');
    for (final t in readingTexts(repo)) {
      expect(fresh, contains('## ${t.textId} '));
    }
  });
}
