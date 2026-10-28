/// One hand-made spec per MVP activity type (plan §R.2 task B4), built only
/// from letters already taught at that lesson. Used by tests and by the
/// activity gallery; Dev A and Dev D can import it to try the contract
/// without the generators.
///
/// Real lessons get their items from the generators (task B8), not from here.
library;

import 'contract.dart';

/// L08 (t): find the two t among taught letters — tier 1, 6-cell grid.
const tapIdentifyL08 = ActivitySpec(lessonKey: 'L08', type: ActivityType.tapIdentify, items: [
  ActivityItem(
    index: 0,
    prompt: 'Touche la lettre t',
    target: 't',
    answer: Choice('t', 't'),
    listen: false,
    options: [
      Choice('i', 'i'), Choice('t', 't'), Choice('o', 'o'),
      Choice('a', 'a'), Choice('u', 'u'), Choice('t', 't'),
    ],
  ),
]);

/// L08 (t): hear a syllable, pick it from three — tier 1.
const listenChooseL08 = ActivitySpec(lessonKey: 'L08', type: ActivityType.listenChoose, items: [
  ActivityItem(
    index: 0,
    prompt: 'Écoute et touche la syllabe',
    target: 'ta',
    answer: Choice('ta', 'ta'),
    options: [Choice('to', 'to'), Choice('ta', 'ta'), Choice('ti', 'ti')],
  ),
  ActivityItem(
    index: 1,
    prompt: 'Écoute et touche la syllabe',
    target: 'tu',
    answer: Choice('tu', 'tu'),
    options: [Choice('tu', 'tu'), Choice('té', 'té'), Choice('to', 'to')],
  ),
]);

/// L08 (t): hear « ta », join t with the right vowel — tier 1, 4 vowel tiles.
const syllableBuildL08 = ActivitySpec(lessonKey: 'L08', type: ActivityType.syllableBuild, items: [
  ActivityItem(
    index: 0,
    prompt: 'Écoute et touche la syllabe',
    target: 'ta',
    word: 'ta',
    fixed: 't',
    blend: 't … a … ta',
    answer: Choice('a', 'a'),
    options: [Choice('i', 'i'), Choice('u', 'u'), Choice('o', 'o'), Choice('a', 'a')],
  ),
]);

/// L11 (m): tomate with the m missing — tier 1, 3 candidates on the focus letter.
/// n (L10) and u (L02) are already taught, and are m's visual neighbours.
const missingLetterL11 = ActivitySpec(lessonKey: 'L11', type: ActivityType.missingLetter, items: [
  ActivityItem(
    index: 0,
    prompt: 'Quelle lettre manque ?',
    target: 'tomate',
    word: 'tomate',
    blankAt: 2,
    answer: Choice('m', 'm'),
    options: [Choice('n', 'n'), Choice('m', 'm'), Choice('u', 'u')],
  ),
]);

/// L01 (i): trace the letter i — tier 1 (ghost + dots).
const traceL01 = ActivitySpec(lessonKey: 'L01', type: ActivityType.trace, items: [
  ActivityItem(index: 0, prompt: 'Trace la lettre avec ton doigt, sur le modèle gris.', target: 'i', answer: Choice('i', 'i')),
]);

const allFixtures = [tapIdentifyL08, listenChooseL08, syllableBuildL08, missingLetterL11, traceL01];
