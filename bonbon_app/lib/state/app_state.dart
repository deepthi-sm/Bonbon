import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/content.dart';

/// Learner profile, progress and settings, persisted locally. No account,
/// no network — the plan's offline-first, shared-phone constraint.
class AppState extends ChangeNotifier {
  final ContentRepo repo;
  final SharedPreferences _p;
  final Speech speech;

  AppState(this.repo, this._p, this.speech) {
    speech.slow = slowVoice;
    _recordVisit();
  }

  // ---- profile
  String? get name => _p.getString('name');
  int get avatar => _p.getInt('avatar') ?? 0;
  bool get onboarded => name != null;

  Future<void> setProfile(String name, int avatar) async {
    await _p.setString('name', name.trim().isEmpty ? 'Amie' : name.trim());
    await _p.setInt('avatar', avatar);
    notifyListeners();
  }

  // ---- progress
  Set<String> get completed => (_p.getStringList('completed') ?? const []).toSet();
  bool isDone(Lesson l) => completed.contains(l.key);

  /// Letters unlock one after another in the book's order. Digits are a
  /// separate track, open from the start (0, then 1, then 2…), so numbers can
  /// be learnt alongside the letters instead of only at the end.
  bool isUnlocked(Lesson l) {
    if (unlockAll || isDone(l)) return true;
    final track = repo.lessons.where((x) => x.isDigit == l.isDigit).toList();
    final i = track.indexOf(l);
    return i <= 0 || isDone(track[i - 1]);
  }

  /// Next letter lesson to do; once the letters are finished, the next digit.
  Lesson get current =>
      repo.lessons.firstWhere((l) => !l.isDigit && !isDone(l),
          orElse: () => repo.lessons.firstWhere((l) => !isDone(l), orElse: () => repo.lessons.first));

  /// Next digit to do, or null when all ten are done.
  Lesson? get currentDigit => repo.lessons.where((l) => l.isDigit && !isDone(l)).firstOrNull;

  bool get allDone => completed.length >= repo.lessons.length;

  int get wordsHeard => _p.getInt('heard') ?? 0;
  int get correctAnswers => _p.getInt('correct') ?? 0;

  Future<void> completeLesson(Lesson l, {int correct = 0}) async {
    await _p.setStringList('completed', {...completed, l.key}.toList());
    await _p.setInt('correct', correctAnswers + correct);
    await _p.remove('resume.${l.key}');
    notifyListeners();
  }

  int resumeStep(Lesson l) => _p.getInt('resume.${l.key}') ?? 0;
  void saveStep(Lesson l, int step) => _p.setInt('resume.${l.key}', step);

  // ---- attendance streak (days the app was opened, never accuracy)
  List<String> get visitDays => _p.getStringList('days') ?? const [];

  void _recordVisit() {
    final today = _day(DateTime.now());
    final days = visitDays;
    if (!days.contains(today)) _p.setStringList('days', [...days, today]);
  }

  int get streak {
    final days = visitDays.toSet();
    var d = DateTime.now();
    var n = 0;
    while (days.contains(_day(d))) {
      n++;
      d = d.subtract(const Duration(days: 1));
    }
    return n;
  }

  static String _day(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ---- settings
  bool get slowVoice => _p.getBool('slow') ?? false;
  bool get cursiveDefault => _p.getBool('cursive') ?? false;
  bool get largeText => _p.getBool('large') ?? false;
  bool get unlockAll => _p.getBool('unlockAll') ?? false;
  bool get english => _p.getBool('english') ?? false;

  Future<void> setEnglish(bool v) async {
    await _p.setBool('english', v);
    notifyListeners();
  }

  Future<void> setSlowVoice(bool v) async {
    await _p.setBool('slow', v);
    speech.slow = v;
    notifyListeners();
  }

  Future<void> setCursiveDefault(bool v) async {
    await _p.setBool('cursive', v);
    notifyListeners();
  }

  Future<void> setLargeText(bool v) async {
    await _p.setBool('large', v);
    notifyListeners();
  }

  Future<void> setUnlockAll(bool v) async {
    await _p.setBool('unlockAll', v);
    notifyListeners();
  }

  Future<void> resetAll() async {
    await _p.clear();
    _recordVisit();
    notifyListeners();
  }

  // ---- audio
  Future<void> say(String text, {bool counts = false}) {
    if (counts) _p.setInt('heard', wordsHeard + 1);
    return speech.say(text);
  }
}

/// Spoken French from the team's own recordings, bundled in assets/audio
/// (see tool/audio.py), so it works with no internet. There is deliberately no
/// browser/device text-to-speech fallback: a missing clip stays silent and
/// is reported through [missing] so it can be fixed in the audio pack.
class Speech {
  final Map<String, String> _files;
  // Created on first playback, so start-up (and tests) don't touch the audio system.
  late final AudioPlayer _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  bool slow = false;
  final ValueNotifier<String?> speaking = ValueNotifier(null);
  final ValueNotifier<String?> missing = ValueNotifier(null);
  int _seq = 0; // any new utterance cancels a running sayAll

  Speech._(this._files);

  static Future<Speech> load() async {
    try {
      final raw = jsonDecode(await rootBundle.loadString('assets/audio/manifest.json')) as Map;
      return Speech._({for (final e in raw.entries) norm(e.key as String): e.value as String});
    } catch (_) {
      return Speech._({});
    }
  }

  /// Lookup key shared with the generator: trimmed, single-spaced, lowercase.
  static String norm(String s) => s.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  int get clipCount => _files.length;
  bool has(String text) => _files.containsKey(norm(text));

  Future<void> say(String text) {
    _seq++;
    return _speak(text);
  }

  Future<void> _speak(String text) async {
    final file = _files[norm(text)];
    if (file == null) {
      missing.value = text;
      if (kDebugMode) debugPrint('[audio] missing clip: "$text"');
      return;
    }
    _playerUsed = true;
    await _player.stop();
    final done = Completer<void>();
    late final StreamSubscription<void> sub;
    sub = _player.onPlayerComplete.listen((_) {
      if (!done.isCompleted) done.complete();
    });
    speaking.value = text;
    try {
      await _player.setPlaybackRate(slow ? 0.75 : 1.0);
      await _player.play(AssetSource('audio/$file'));
      await done.future.timeout(const Duration(seconds: 60), onTimeout: () {});
    } catch (e) {
      if (kDebugMode) debugPrint('[audio] playback failed for "$text": $e');
    } finally {
      await sub.cancel();
      if (speaking.value == text) speaking.value = null;
    }
  }

  Future<void> sayAll(List<String> parts, {void Function(int)? onIndex}) async {
    final run = ++_seq;
    for (var i = 0; i < parts.length && run == _seq; i++) {
      onIndex?.call(i);
      await _speak(parts[i]);
      if (run != _seq) break;
      await Future.delayed(const Duration(milliseconds: 250));
    }
    onIndex?.call(-1);
  }

  bool _playerUsed = false;

  Future<void> stop() async {
    _seq++;
    speaking.value = null;
    if (_playerUsed) await _player.stop();
  }
}
