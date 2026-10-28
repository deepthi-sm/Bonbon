/// Reproducible randomness for generated items (plan §U.1, task B8):
/// seed = fnv1a(lessonId + ':' + activityType + ':' + itemIndex). The same
/// seed gives the same item on every device, so an item that confuses a
/// learner in the field can be rebuilt exactly on a developer's machine.
///
/// Only 32-bit shifts, xor and small multiplications are used, so the numbers
/// are identical in the Dart VM and in the web build (JavaScript doubles).
library;

import 'dart:convert';

const _mask = 0xFFFFFFFF;

/// 32-bit FNV-1a over the UTF-8 bytes of [s].
int fnv1a(String s) {
  var h = 0x811c9dc5;
  for (final b in utf8.encode(s)) {
    h ^= b;
    // h * 16777619 == h * (2^24 + 403), split so it never exceeds 2^53.
    h = (((h << 24) & _mask) + h * 403) & _mask;
  }
  return h;
}

int itemSeed(String lessonKey, String activityType, int itemIndex) =>
    fnv1a('$lessonKey:$activityType:$itemIndex');

/// Small deterministic generator (xorshift32). Use this, never math.Random(),
/// whose sequence is not guaranteed to match across platforms.
class SeededRng {
  int _x;
  SeededRng(int seed) : _x = (seed & _mask) == 0 ? 0x9e3779b9 : seed & _mask;

  int _next() {
    var x = _x;
    x ^= (x << 13) & _mask;
    x ^= x >> 17;
    x ^= (x << 5) & _mask;
    return _x = x & _mask;
  }

  /// 0 <= result < [max].
  int nextInt(int max) {
    if (max <= 0) throw ArgumentError.value(max, 'max', 'must be positive');
    return _next() % max;
  }

  /// Fisher–Yates, in place.
  void shuffle<T>(List<T> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final t = list[i];
      list[i] = list[j];
      list[j] = t;
    }
  }

  /// A shuffled copy of [items].
  List<T> shuffled<T>(Iterable<T> items) {
    final list = items.toList();
    shuffle(list);
    return list;
  }

  T pick<T>(List<T> list) => list[nextInt(list.length)];
}
