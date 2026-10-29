/// Comprehension: the system, not the questions (comprehension.json, plan
/// §U.6, task B13). The reading texts carry no questions; Batonga writes 2–3
/// per text into a fixed shape ([QuestionSet]), and [validateComprehension]
/// enforces the hard rules before anything ships. [exportForBatonga] writes
/// the texts out for them (docs/textes-a-questionner.md). Pure Dart.
library;

import '../data/content.dart';
import 'generators.dart' show HasAudio, graphemeSpots;
import 'ledger.dart';

/// One reading text of the book, with ids from the audio-ID grammar
/// (plan §W.2): « T27 », and « T27.s01 »… for its segments, in order.
class ReadingText {
  final String textId, lessonKey, title;
  final List<(String id, String text)> segments;
  const ReadingText(this.textId, this.lessonKey, this.title, this.segments);

  String get whole => segments.map((s) => s.$2).join(' ');
}

String _two(int n) => n.toString().padLeft(2, '0');

/// Every reading passage of the content, one per lesson that has one. A
/// dialogue's turns are segments of their own, as the reader plays them.
List<ReadingText> readingTexts(ContentRepo repo) => [
      for (final l in repo.lessons)
        for (final b in l.blocks.where((b) => b.type == 'reading_passage'))
          ReadingText('T${l.number}', l.key, b.str('title') ?? '', [
            for (final (k, text) in [
              for (final s in (b.raw['segments'] as List).cast<Map>())
                if (s['type'] == 'dialogue')
                  for (final t in (s['turns'] as List).cast<Map>()) (t['text'] as String).trim()
                else
                  (s['text'] as String).trim(),
            ].indexed)
              ('T${l.number}.s${_two(k + 1)}', text),
          ]),
    ];

// ---------------------------------------------------------------------------
// The question shape (comprehension.json, workedExample)

const questionKinds = ['littérale', 'lexicale', 'inférentielle', 'personnelle'];
const answerModes = ['image-2', 'image-3', 'phrase-pick', 'replay-only'];

class QuestionOption {
  final String? illustrationId, text;
  final bool correct;
  const QuestionOption({this.illustrationId, this.text, this.correct = false});

  factory QuestionOption.fromJson(Map<String, dynamic> j) =>
      QuestionOption(illustrationId: j['illustrationId'] as String?, text: j['text'] as String?, correct: j['correct'] == true);
}

class Question {
  final String id, kind, mode, prompt;
  final String? audioId, replaySegment;
  final List<QuestionOption> options;
  final bool scored;
  const Question({
    required this.id,
    required this.kind,
    required this.mode,
    required this.prompt,
    this.audioId,
    this.replaySegment,
    this.options = const [],
    this.scored = true,
  });

  factory Question.fromJson(Map<String, dynamic> j) => Question(
        id: j['id'] as String? ?? '',
        kind: j['kind'] as String? ?? '',
        mode: j['mode'] as String? ?? '',
        prompt: j['prompt'] as String? ?? '',
        audioId: j['audioId'] as String?,
        replaySegment: (j['onWrong'] as Map?)?['replaySegment'] as String?,
        options: [for (final o in (j['options'] as List?) ?? const []) QuestionOption.fromJson(o as Map<String, dynamic>)],
        scored: j['scored'] != false,
      );
}

/// Batonga's questions for one text. Only `approved` with a named
/// [signedOffBy] may ship (docs/comprehension-signoff.md).
class QuestionSet {
  final String textId, lessonKey, status;
  final String? signedOffBy;
  final List<Question> questions;
  const QuestionSet(this.textId, this.lessonKey, this.status, this.questions, {this.signedOffBy});

  factory QuestionSet.fromJson(Map<String, dynamic> j) => QuestionSet(
        j['textId'] as String? ?? '',
        j['lessonId'] as String? ?? '',
        j['status'] as String? ?? 'draft',
        [for (final q in (j['questions'] as List?) ?? const []) Question.fromJson(q as Map<String, dynamic>)],
        signedOffBy: j['signedOffBy'] as String?,
      );

  bool get approved => status == 'approved' && (signedOffBy?.trim().isNotEmpty ?? false);
}

// ---------------------------------------------------------------------------
// The validator

enum Severity {
  /// Breaks a hard rule: the question cannot ship as written.
  error,

  /// Not wrong, not done: no recording yet, no sign-off yet, a picture to draw.
  pending,
}

class Finding {
  final Severity severity;
  final String textId;
  final String? questionId;
  final String rule, message;
  const Finding(this.severity, this.textId, this.questionId, this.rule, this.message);

  @override
  String toString() => '${severity.name} ${questionId ?? textId} [$rule] $message';
}

int _lessonNumber(String key) => int.tryParse(key.substring(1)) ?? 0;

/// Words she can read by the end of lesson [lessonKey]: every word the book
/// itself has shown her up to then.
Set<String> _bookWords(ContentRepo repo, String lessonKey) {
  final out = <String>{};
  void walk(Object? x) {
    if (x is Map) {
      for (final e in x.entries) {
        if (e.key == 'text' && e.value is String) out.addAll(wordsIn(e.value as String));
        walk(e.value);
      }
    } else if (x is List) {
      x.forEach(walk);
    }
  }

  for (final l in repo.lessons.where((l) => !l.isDigit)) {
    if (_lessonNumber(l.key) > _lessonNumber(lessonKey)) break;
    for (final b in l.blocks) {
      walk(b.raw);
    }
  }
  return out;
}

/// Lowercase words of [s]: letters only, split at spaces, apostrophes and
/// punctuation (« l'ail » is « l » and « ail »).
List<String> wordsIn(String s) =>
    RegExp(r"[a-zàâäçéèêëîïôöùûüÿœæ]+").allMatches(s.toLowerCase()).map((m) => m.group(0)!).toList();

/// Graphemes of [word] (longest match, as missing-letter blanks them) that
/// are not in the ledger at [lessonKey].
List<String> untaughtGraphemes(String word, String lessonKey) {
  final ledger = ledgerAt(lessonKey);
  final all = ledgerAt('L56').where((g) => g.length > 1).toList()..sort((a, b) => b.length.compareTo(a.length));
  final taken = List.filled(word.length, false);
  final out = <String>[];
  for (final g in all) {
    for (final k in graphemeSpots(word, g)) {
      if (taken.sublist(k, k + g.length).any((t) => t)) continue;
      taken.fillRange(k, k + g.length, true);
      if (!ledger.contains(g)) out.add(g);
    }
  }
  for (var k = 0; k < word.length; k++) {
    if (!taken[k] && !ledger.contains(word[k])) out.add(word[k]);
  }
  return out;
}

/// The lesson that first teaches [g], for messages.
String? taughtIn(String g) => ledgerAdds.entries.where((e) => e.value.contains(g)).firstOrNull?.key;

/// Every hard rule of comprehension.json over [sets]. [hasAudio], when
/// given, reports prompts with no recording yet (pending).
List<Finding> validateComprehension(List<QuestionSet> sets, ContentRepo repo, {HasAudio? hasAudio}) {
  final texts = {for (final t in readingTexts(repo)) t.textId: t};
  final out = <Finding>[];
  final seenText = <String>{};

  for (final set in sets) {
    void add(Severity s, String? q, String rule, String msg) => out.add(Finding(s, set.textId, q, rule, msg));
    final text = texts[set.textId];
    if (text == null) {
      add(Severity.error, null, 'text', 'no reading text « ${set.textId} » (texts: ${texts.keys.join(' ')})');
      continue;
    }
    if (!seenText.add(set.textId)) add(Severity.error, null, 'text', 'two question sets for the same text');
    if (set.lessonKey != text.lessonKey) add(Severity.error, null, 'text', 'lessonId ${set.lessonKey}, but the text is in ${text.lessonKey}');
    final lesson = _lessonNumber(text.lessonKey);
    final qs = set.questions;

    // « Max 3 questions per text. »
    if (qs.isEmpty) add(Severity.error, null, 'count', 'no questions');
    if (qs.length > 3) add(Severity.error, null, 'count', '${qs.length} questions; at most 3 per text');

    // Taxonomy: littérale once and first, lexicale once, the others at most once.
    int count(String kind) => qs.where((q) => q.kind == kind).length;
    if (qs.isNotEmpty && qs.first.kind != 'littérale') add(Severity.error, qs.first.id, 'kind', 'the first question must be littérale');
    if (count('littérale') != 1) add(Severity.error, null, 'kind', '${count('littérale')} littérale; exactly 1 per text');
    if (count('lexicale') > 1) add(Severity.error, null, 'kind', '${count('lexicale')} lexicale; 1 per text');
    if (count('inférentielle') > 1) add(Severity.error, null, 'kind', 'at most 1 inférentielle');
    if (count('personnelle') > 1) add(Severity.error, null, 'kind', 'at most 1 personnelle');

    final words = _bookWords(repo, text.lessonKey);
    final ids = <String>{};
    for (final (n, q) in qs.indexed) {
      void bad(String rule, String msg) => add(Severity.error, q.id, rule, msg);
      if (!ids.add(q.id)) bad('id', 'duplicate id');
      if (q.id != '${set.textId}.q${n + 1}') bad('id', 'expected id « ${set.textId}.q${n + 1} »');
      if (!questionKinds.contains(q.kind)) bad('kind', 'unknown kind « ${q.kind} »');
      if (q.kind == 'inférentielle' && lesson < 36) bad('kind', 'inférentielle only from lesson 36');

      // Answer modes and their options.
      if (!answerModes.contains(q.mode)) bad('mode', 'unknown mode « ${q.mode} »');
      if (q.mode == 'image-3' && lesson < 30) bad('mode', 'image-3 only from lesson 30');
      if (q.mode == 'phrase-pick' && lesson < 36) bad('mode', 'phrase-pick only from lesson 36');
      if (q.kind == 'personnelle') {
        if (q.mode != 'replay-only') bad('mode', 'personnelle is replay-only');
        if (q.scored) bad('scored', 'personnelle is never scored (« scored »: false)');
      } else if (q.mode == 'replay-only') {
        bad('mode', 'replay-only is for personnelle questions only');
      }
      final want = {'image-2': 2, 'image-3': 3, 'phrase-pick': 3, 'replay-only': 0}[q.mode];
      if (want != null && q.options.length != want) bad('options', '${q.mode} needs $want options, has ${q.options.length}');
      if (q.mode != 'replay-only' && q.options.where((o) => o.correct).length != 1) bad('options', 'exactly one correct option');
      if (q.mode.startsWith('image') && q.options.any((o) => (o.illustrationId ?? '').isEmpty)) {
        bad('options', '${q.mode}: every option is a picture (illustrationId)');
      }
      if (q.mode == 'phrase-pick') {
        for (final o in q.options) {
          // « Les distracteurs sont d'autres phrases du MÊME texte — jamais inventées. »
          if (o.text == null || !text.whole.contains(o.text!.trim())) bad('options', 'phrase-pick option « ${o.text} » is not a sentence of ${set.textId}');
        }
      }

      // « Every wrong answer replays the sentence of the text that holds the answer. »
      if (q.scored && q.mode != 'replay-only') {
        if (q.replaySegment == null) {
          bad('onWrong', 'a scored question needs onWrong.replaySegment');
        } else if (!text.segments.any((s) => s.$1 == q.replaySegment)) {
          bad('onWrong', 'replaySegment « ${q.replaySegment} » is not a segment of ${set.textId}');
        }
      }

      // « Every question is spoken as well as written. »
      if (q.prompt.trim().isEmpty) bad('spoken', 'empty prompt');
      if (q.audioId != 'q.${q.id}') bad('spoken', 'audioId must be « q.${q.id} »');
      if (hasAudio != null && q.prompt.trim().isNotEmpty && !hasAudio(q.prompt)) {
        add(Severity.pending, q.id, 'spoken', 'prompt not recorded yet');
      }

      // « No question about the moral, the author's intent, or the title. »
      final p = q.prompt.toLowerCase();
      if (RegExp(r'\b(morale|auteur|titre)\b').hasMatch(p) || (text.title.isNotEmpty && p.contains(text.title.toLowerCase()))) {
        bad('subject', 'no question about the moral, the author or the title');
      }

      // « A question may contain no grapheme not taught by its own lesson. »
      for (final w in wordsIn(q.prompt)) {
        if (words.contains(w)) continue; // the book has shown her this word
        final missing = untaughtGraphemes(w, text.lessonKey);
        if (missing.isNotEmpty) {
          bad('decodable', '« $w » uses ${missing.map((g) => '« $g »${taughtIn(g) == null ? '' : ' (${taughtIn(g)})'}').join(', ')}, not taught by ${text.lessonKey}');
        }
      }

      // Workflow step 4: pictures go on Dev A's illustration backlog.
      for (final o in q.options) {
        final id = o.illustrationId;
        if (id != null && id.isNotEmpty && !repo.assetPaths.containsKey(id)) add(Severity.pending, q.id, 'illustration', '« $id » to draw');
      }
    }

    // Workflow step 5: nothing ships without a named sign-off.
    if (!set.approved) add(Severity.pending, null, 'signoff', 'status « ${set.status} »: awaiting a named sign-off');
  }
  return out;
}

/// The sets that may ship: approved, signed off, no error.
List<QuestionSet> shippable(List<QuestionSet> sets, List<Finding> findings) => [
      for (final s in sets)
        if (s.approved && !findings.any((f) => f.textId == s.textId && f.severity == Severity.error)) s,
    ];

// ---------------------------------------------------------------------------
// The export for Batonga (workflow step 1)

/// docs/textes-a-questionner.md: one section per text, with its segment
/// ids, what the lesson allows, and the shape to fill in. In French: it is
/// for Batonga.
String exportForBatonga(ContentRepo repo) {
  final texts = readingTexts(repo);
  final b = StringBuffer()
    ..writeln('# Textes à questionner')
    ..writeln()
    ..writeln('> Généré depuis le contenu de l\'application (`bonbon_app/lib/activities/comprehension.dart`).')
    ..writeln('> Ne pas modifier à la main : `BONBON_EXPORT=1 flutter test test/comprehension_test.dart` le régénère.')
    ..writeln()
    ..writeln('${texts.length} textes. Pour chacun, écrire 2 ou 3 questions dans `docs/comprehension/questions.json`,')
    ..writeln('dans la forme donnée en bas de chaque texte. Rien n\'est publié sans une signature nommée')
    ..writeln('(`status: "approved"`, `signedOffBy`) — voir `docs/comprehension-signoff.md`.')
    ..writeln()
    ..writeln('## Les règles')
    ..writeln()
    ..writeln('- Au plus 3 questions par texte. La première est **littérale** ; une seule **lexicale** ;')
    ..writeln('  au plus une **inférentielle** (à partir de la leçon 36) et une **personnelle** (jamais notée, `replay-only`).')
    ..writeln('- Réponses : `image-2` (deux dessins), `image-3` (trois dessins, dès la leçon 30),')
    ..writeln('  `phrase-pick` (trois phrases COURTES du même texte, dès la leçon 36), `replay-only` (question personnelle).')
    ..writeln('- La question ne contient aucune graphie que la leçon n\'a pas encore enseignée : le validateur le vérifie.')
    ..writeln('- Chaque question est dite à voix haute (`audioId` = `q.<id>`), et une mauvaise réponse rejoue la phrase')
    ..writeln('  du texte qui contient la réponse (`onWrong.replaySegment`).')
    ..writeln('- Pas de question sur la morale, l\'intention de l\'auteur ou le titre.')
    ..writeln();
  for (final t in texts) {
    final n = _lessonNumber(t.lessonKey);
    final modes = ['image-2', if (n >= 30) 'image-3', if (n >= 36) 'phrase-pick', 'replay-only'];
    b
      ..writeln('## ${t.textId} — leçon $n · ${t.title}')
      ..writeln()
      ..writeln('Réponses possibles : ${modes.map((m) => '`$m`').join(', ')}.'
          '${n >= 36 ? ' Question inférentielle possible.' : ' Pas de question inférentielle avant la leçon 36.'}')
      ..writeln();
    for (final (id, text) in t.segments) {
      b.writeln('- `$id` $text');
    }
    b
      ..writeln()
      ..writeln('```json')
      ..writeln('{ "textId": "${t.textId}", "lessonId": "${t.lessonKey}", "status": "draft", "signedOffBy": null,')
      ..writeln('  "questions": [')
      ..writeln('    { "id": "${t.textId}.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.${t.textId}.q1",')
      ..writeln('      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],')
      ..writeln('      "onWrong": { "replaySegment": "${t.segments.first.$1}" } },')
      ..writeln('    { "id": "${t.textId}.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.${t.textId}.q2",')
      ..writeln('      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],')
      ..writeln('      "onWrong": { "replaySegment": "${t.segments.first.$1}" } }')
      ..writeln('  ] }')
      ..writeln('```')
      ..writeln();
  }
  return b.toString();
}
