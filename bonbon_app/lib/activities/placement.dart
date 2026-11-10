/// The placement test behind « J'en connais déjà » (placement-test.json,
/// plan §U.5, task B12): an adaptive ladder of three listening rungs, at
/// most 12 items, that only chooses a starting lesson. Pure Dart.
///
/// The three guardrails: it is fully spoken; it never reports a score or a
/// level — only « Tu peux commencer ici » and a lesson; and it never locks a
/// lesson (lessons before the entry point are opened, not completed:
/// [openBefore]). Quitting at any point starts her at L01, with no word
/// about the test.
library;

import '../data/content.dart';
import '../data/phrases.dart';
import 'contract.dart';
import 'generators.dart';
import 'seed.dart';

class PlacementRung {
  final int rung;
  final List<String> probes;
  final String prompt; // recorded
  final String failStart;
  final String? passStart; // null: go on to the next rung
  const PlacementRung(this.rung, this.probes, this.prompt, this.failStart, [this.passStart]);
}

/// placement-test.json, rungs.
const placementRungs = [
  PlacementRung(1, ['i', 'u', 'o', 'a', 'e', 'é'], 'Écoute, puis touche la bonne lettre.', 'L01'),
  PlacementRung(2, ['ta', 'pi', 'mo', 'ne', 'lu', 'ré'], P.promptSyllable, 'L08'),
  PlacementRung(3, ['an', 'ou', 'oi', 'ain', 'ch', 'eu'], P.promptSound, 'L15', 'L25'),
];

const placementItemsPerRung = 4;

/// « advanceIf ≥ 3/4 », kept as a share when a rung is shorter (a probe
/// with no recording is dropped: « é » alone is not recorded).
int placementNeeded(int items) => (items * 3 / 4).ceil();

/// Where she starts when she says « Commencer au début » or quits the test.
const placementFromStart = 'L01';

/// Recorded lines from the team's onboarding script.
const sayPlacementOffer =
    'Veux-tu commencer au début, ou veux-tu que je regarde d\'abord ce que tu sais déjà ? Si tu n\'es pas sûre, commence au début.';
const sayFromStart = 'Commencer au début. C\'est le meilleur choix si tu n\'es pas sûre.';
const sayPlacedHere = 'Tu peux commencer ici.';

/// The items of [r]: 4 probes she hears, each written among 3 probes of the
/// same rung, reproducibly. With [hasAudio], a probe with no clip is left out.
List<ActivityItem> placementItems(PlacementRung r, {HasAudio? hasAudio}) {
  final heard = [for (final p in r.probes) if (hasAudio == null || hasAudio(p)) p];
  final targets = SeededRng(fnv1a('placement:${r.rung}:order')).shuffled(heard).take(placementItemsPerRung).toList();
  final items = <ActivityItem>[];
  Set<String> previous = {};
  for (final (i, t) in targets.indexed) {
    final rng = SeededRng(itemSeed('placement', 'rung${r.rung}', i));
    final others = pickDistractors(rankDistractors(t, r.probes, rng, near: false, isNear: (_) => false), 2, previous);
    previous = others.toSet();
    items.add(ActivityItem(
      index: i,
      prompt: r.prompt,
      target: t,
      answer: Choice(t, t),
      options: rng.shuffled([t, ...others].map((x) => Choice(x, x))),
    ));
  }
  return items;
}

/// Where she starts. Deliberately nothing else: no score, no level.
class PlacementResult {
  final String startAt;

  /// She chose « Commencer au début » or left the test.
  final bool fromStart;
  const PlacementResult(this.startAt, {this.fromStart = false});

  Map<String, Object?> toJson() => {'startAt': startAt, if (fromStart) 'fromStart': true};
}

/// The ladder, one item at a time. Answers are recorded silently: nothing
/// she sees or hears says right or wrong.
class PlacementSession {
  final HasAudio? hasAudio;
  PlacementSession({this.hasAudio}) {
    _enter(0);
  }

  int _rung = 0;
  List<ActivityItem> _items = const [];
  int _asked = 0, _right = 0, _total = 0;
  String? _startAt;

  PlacementRung get rung => placementRungs[_rung];
  ActivityItem get item => _items[_asked];
  bool get finished => _startAt != null;
  PlacementResult get result => PlacementResult(_startAt ?? placementFromStart);

  /// Items asked so far, over every rung (at most 12).
  int get asked => _total;

  List<String> get askParts => [item.prompt, item.heard];

  void _enter(int rung) {
    _rung = rung;
    _items = placementItems(placementRungs[rung], hasAudio: hasAudio);
    _asked = 0;
    _right = 0;
    // Nothing recorded to ask: start where this rung would send a miss.
    if (_items.isEmpty) _startAt = placementRungs[rung].failStart;
  }

  /// Records her choice and moves on: to the next item, the next rung, or a
  /// start. A rung stops as soon as its outcome is decided.
  void answer(Choice c) {
    if (finished) return;
    if (c.show == item.answer.show) _right++;
    _asked++;
    _total++;
    final need = placementNeeded(_items.length);
    if (_right >= need) {
      if (rung.passStart != null) {
        _startAt = rung.passStart;
      } else {
        _enter(_rung + 1);
      }
    } else if (_asked - _right > _items.length - need) {
      _startAt = rung.failStart;
    }
  }

  /// She left: L01, and no word about the test.
  PlacementResult abandon() => _startAt == null ? const PlacementResult(placementFromStart, fromStart: true) : result;
}

/// The guardrail for whoever stores progress (Dev D): every literacy lesson
/// before [startAt] is to be opened — `available`, never `completed` — so
/// she can go back and the path shows open doors, not skipped ones.
List<String> openBefore(String startAt, ContentRepo repo) {
  final literacy = [for (final l in repo.lessons) if (!l.isDigit) l.key];
  final i = literacy.indexOf(startAt);
  return i <= 0 ? const [] : literacy.sublist(0, i);
}
