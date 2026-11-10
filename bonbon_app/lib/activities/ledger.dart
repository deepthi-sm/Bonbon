/// The decodability ledger (01-corpus/decodability.json): for every lesson,
/// the letters and graphemes a learner has met by its end. It is the only
/// legal source of distractors (confusion-matrix.json, rule 1), so a
/// generated item never shows her a symbol she has not been taught.
///
/// Stored as what each lesson adds, in order; a copy of the JSON pack,
/// checked against it by test/ledger_test.dart. Not computable from the
/// lesson targets: « g = j » adds g, « qu = k = c » adds all three.
library;

/// What each literacy lesson adds to the ledger, in lesson order.
const ledgerAdds = <String, List<String>>{
  'L01': ['i'],
  'L02': ['u'],
  'L03': ['o'],
  'L04': ['a'],
  'L05': ['e', 'ê'],
  'L06': ['é', 'è'],
  'L07': ['y'],
  'L08': ['t'],
  'L09': ['p'],
  'L10': ['n'],
  'L11': ['m'],
  'L12': ['r'],
  'L13': ['v'],
  'L14': ['l'],
  'L15': ['d'],
  'L16': ['b'],
  'L17': ['j'],
  'L18': ['f'],
  'L19': ['s'],
  'L20': ['c'],
  'L21': ['g'],
  'L22': ['k'],
  'L23': ['z'],
  'L24': ['h'],
  'L25': ['an', 'am', 'en', 'em'],
  'L26': ['on', 'om'],
  'L27': ['oin'],
  'L28': ['ien', 'ion'],
  'L29': ['eau', 'au', 'os', 'ot'],
  'L30': ['oi', 'oix', 'oit'],
  'L31': ['ain', 'ein', 'in', 'aim'],
  'L32': ['ou', 'ouille'],
  'L33': ['ay', 'oy', 'uy'],
  'L34': ['ail', 'aille'],
  'L35': ['eil', 'eille'],
  'L36': ['ai', 'ei', 'ais', 'ait'],
  'L37': ['et', 'ez', 'ed'],
  'L38': ['euil', 'euille'],
  'L39': ['ill', 'ille'],
  'L40': ['eu', 'œu'],
  'L41': ['eur', 'eure', 'œur'],
  'L42': ['oir', 'oire'],
  'L43': [],
  'L44': ['gu'],
  'L45': ['gn'],
  'L46': ['qu'],
  'L47': [],
  'L48': ['ç'],
  'L49': ['iez', 'ier', 'ied'],
  'L50': ['ch'],
  'L51': ['ph', 'th'],
  'L52': ['ac', 'oc', 'ic'],
  'L53': ['tion', 'sion'],
  'L54': ['bl', 'pl', 'vl', 'fl', 'cl'],
  'L55': ['ar', 'or'],
  'L56': ['br', 'tr', 'cr', 'pr', 'dr', 'gr', 'vr', 'fr'],
};

const _digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

/// Every letter and grapheme met by the end of lesson [lessonKey] ("L08").
/// Digit lessons ("N3") are a closed set of ten, all available from the start.
Set<String> ledgerAt(String lessonKey) {
  if (!ledgerAdds.containsKey(lessonKey)) return lessonKey.startsWith('N') ? {..._digits} : const {};
  final out = <String>{};
  for (final e in ledgerAdds.entries) {
    out.addAll(e.value);
    if (e.key == lessonKey) break;
  }
  return out;
}
