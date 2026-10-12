import 'dart:convert';

import 'package:flutter/services.dart';

/// Read-only access to the Batonga content package (schema v1.0.2).
/// The JSON under assets/content is copied verbatim from
/// Batonga-Content-Engine/packages/content and must not be edited by hand.
typedef Json = Map<String, dynamic>;

class TextItem {
  final String id;
  final String text;
  final String speech;
  final List<String> representations;
  const TextItem(this.id, this.text, this.speech, this.representations);

  factory TextItem.fromJson(Json j) => TextItem(
        j['id'] as String,
        j['text'] as String,
        (j['audio']?['fallbackText'] as String?) ?? j['text'] as String,
        ((j['representations'] as List?) ?? const ['print']).cast<String>(),
      );

  bool get hasCursive => representations.contains('cursive');
}

/// A lesson block keeps its raw JSON; renderers read the fields they need.
class Block {
  final String id;
  final String type;
  final Json raw;
  Block(this.raw)
      : id = raw['id'] as String,
        type = raw['type'] as String;

  List<TextItem> items([String key = 'items']) =>
      ((raw[key] as List?) ?? const []).map((e) => TextItem.fromJson(e as Json)).toList();

  String? str(String key) => raw[key] as String?;
}

enum UnitKind { vowels, consonants, graphemes, digits }

class Lesson {
  final String key; // "L08" or "N3" — stable progress key
  final int number;
  final UnitKind unit;
  final List<String> targets;
  final List<Block> blocks;
  final String? sourceTitle;

  Lesson({
    required this.key,
    required this.number,
    required this.unit,
    required this.targets,
    required this.blocks,
    this.sourceTitle,
  });

  bool get isDigit => unit == UnitKind.digits;

  String get shortLabel => isDigit ? '$number' : targets.first;

  String get title => titleIn(false);

  /// Lesson name for the interface; [en] gives the English debug label.
  String titleIn(bool en) {
    if (isDigit) return en ? 'The digit $number' : 'Le chiffre $number';
    if (sourceTitle != null) return sourceTitle!;
    if (unit == UnitKind.graphemes) return '${en ? 'Sounds' : 'Les sons'} ${targets.join(' · ')}';
    return targets.length == 1
        ? '${en ? 'The letter' : 'La lettre'} ${targets.first}'
        : '${en ? 'The letters' : 'Les lettres'} ${targets.join(en ? ' and ' : ' et ')}';
  }

  String get heading => headingIn(false);

  String headingIn(bool en) =>
      isDigit ? (en ? 'Digits' : 'Les chiffres') : '${en ? 'Lesson' : 'Leçon'} ${number.toString().padLeft(2, '0')}';

  /// Spoken announcement of the lesson (French; has a pre-recorded clip).
  String get spokenName => '$heading. $title';

  /// Every word and short phrase in the lesson, in source order.
  List<TextItem> get words => [
        for (final b in blocks)
          if (b.type == 'word_list') ...b.items(),
      ];

  List<TextItem> get syllables => [
        for (final b in blocks)
          if (b.type == 'syllable_drill') ...b.items(),
      ];

  String? get illustrationId =>
      blocks.where((b) => b.type == 'illustration').map((b) => b.str('assetId')).firstOrNull;

  String? get keyword => blocks
      .where((b) => b.type == 'illustration')
      .map((b) => (b.raw['caption'] as Json?)?['text'] as String?)
      .firstOrNull;

  String? get passageTitle =>
      blocks.where((b) => b.type == 'reading_passage').map((b) => b.str('title')).firstOrNull;
}

class Unit {
  final UnitKind kind;
  final String title;
  final String subtitle;
  final List<Lesson> lessons;
  const Unit(this.kind, this.title, this.subtitle, this.lessons);

  String titleIn(bool en) => !en
      ? title
      : switch (kind) {
          UnitKind.vowels => 'Vowels',
          UnitKind.consonants => 'Consonants',
          UnitKind.graphemes => 'Sounds and texts',
          UnitKind.digits => 'Digits',
        };

  String subtitleIn(bool en) => !en
      ? subtitle
      : switch (kind) {
          UnitKind.vowels => 'Lessons 1 to 7',
          UnitKind.consonants => 'Lessons 8 to 24',
          UnitKind.graphemes => 'Lessons 25 to 56',
          UnitKind.digits => '0 to 9',
        };

  /// Spoken announcement (French clip).
  String spokenName(int index) => 'Unité $index. $title.';
}

/// Words of a sentence as tapped individually (punctuation stripped).
List<String> wordsOf(String sentence) => [
      for (final w in sentence.split(RegExp(r'\s+')))
        if (w.replaceAll(RegExp(r'[.,!?;:«»"()…]'), '').isNotEmpty) w.replaceAll(RegExp(r'[.,!?;:«»"()…]'), ''),
    ];

class AlphabetEntry {
  final String lower, upper, category;
  const AlphabetEntry(this.lower, this.upper, this.category);
}

class ContentRepo {
  final List<Lesson> lessons; // literacy then digits, in path order
  final List<Unit> units;
  final Map<String, String> assetPaths; // asset id -> bundle path
  final List<AlphabetEntry> alphabet;

  ContentRepo._(this.lessons, this.units, this.assetPaths, this.alphabet);

  static Future<ContentRepo> load() async {
    // Retries: on a weak connection one of the many parallel requests can
    // drop, and a single missing file must not stop the app from starting.
    Future<dynamic> read(String p) async {
      for (var attempt = 1;; attempt++) {
        try {
          return jsonDecode(await rootBundle.loadString(p, cache: false));
        } catch (_) {
          if (attempt >= 4) rethrow;
          await Future<void>.delayed(Duration(milliseconds: 300 * attempt));
        }
      }
    }

    // Fetch every file at once: on the web each one is a network request, and
    // loading the 56 lessons one after another took ~15 s on a slow connection.
    final files = await Future.wait([
      for (var n = 1; n <= 56; n++) read('assets/content/literacy/lesson-${n.toString().padLeft(2, '0')}.json'),
      read('assets/content/numeracy/units.json'),
      read('assets/content/assets.json'),
      read('assets/content/literacy/reference-materials.json'),
    ]);

    final literacy = <Lesson>[];
    for (var n = 1; n <= 56; n++) {
      final j = files[n - 1] as Json;
      literacy.add(Lesson(
        key: 'L${n.toString().padLeft(2, '0')}',
        number: n,
        unit: n <= 7
            ? UnitKind.vowels
            : n <= 24
                ? UnitKind.consonants
                : UnitKind.graphemes,
        targets: [for (final t in j['targets'] as List) (t as Json)['value'] as String],
        blocks: [for (final b in j['blocks'] as List) Block(b as Json)],
        sourceTitle: j['title'] as String?,
      ));
    }

    final numeracy = files[56] as Json;
    final digits = [
      for (final u in numeracy['units'] as List)
        Lesson(
          key: 'N${(u as Json)['number']}',
          number: u['number'] as int,
          unit: UnitKind.digits,
          targets: [u['numeral'] as String, u['word'] as String],
          blocks: [for (final b in u['blocks'] as List) Block(b as Json)],
        ),
    ];

    final assets = <String, String>{
      for (final a in files[57] as List)
        if ((a as Json)['status'] == 'available')
          a['id'] as String: 'assets/images/${(a['path'] as String).replaceFirst('assets/', '')}',
    };

    final refs = files[58] as List;
    final chart = refs.cast<Json>().firstWhere((r) => r['id'] == 'alphabet-chart');
    final alphabet = [
      for (final e in chart['entries'] as List)
        AlphabetEntry((e as Json)['grapheme'] as String, e['uppercase'] as String,
            e['category'] as String),
    ];

    List<Lesson> of(UnitKind k) => literacy.where((l) => l.unit == k).toList();
    final units = [
      Unit(UnitKind.vowels, 'Les voyelles', 'Leçons 1 à 7', of(UnitKind.vowels)),
      Unit(UnitKind.consonants, 'Les consonnes', 'Leçons 8 à 24', of(UnitKind.consonants)),
      Unit(UnitKind.graphemes, 'Les sons et les textes', 'Leçons 25 à 56', of(UnitKind.graphemes)),
      Unit(UnitKind.digits, 'Les chiffres', 'De 0 à 9', digits),
    ];

    return ContentRepo._([...literacy, ...digits], units, assets, alphabet);
  }

  Lesson? byKey(String key) => lessons.where((l) => l.key == key).firstOrNull;

  Lesson? after(Lesson l) {
    final i = lessons.indexOf(l);
    return i >= 0 && i + 1 < lessons.length ? lessons[i + 1] : null;
  }

  /// Single letters taught up to and including [l] — distractor pool for
  /// recognition activities, so a learner is never shown an untaught letter.
  List<String> lettersTaughtThrough(Lesson l) => [
        for (final x in lessons)
          if (!x.isDigit && x.number <= l.number && x.unit != UnitKind.graphemes) ...x.targets,
      ];
}
