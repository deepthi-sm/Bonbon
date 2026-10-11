/// Every fixed French sentence the app speaks. Audio is pre-recorded per
/// sentence (recorded by the team, see tool/audio.py), so spoken text must come from here or from
/// the content package — never built at runtime from a name or a number.
class P {
  static const welcome = 'Bienvenue à Bonbon ! Apprenons à lire et à écrire ensemble, pas à pas.';
  static const profile = 'Choisis ton image. Tu peux aussi écrire ton prénom.';
  static const greeting = 'Bonjour ! Heureuse de te revoir.';

  static const home = 'Accueil';
  static const path = 'Les leçons. Touche une leçon.';
  static const atelier = 'L\'atelier. Choisis une activité libre.';
  static const progress = 'Mes progrès';
  static const settings = 'Réglages';

  static const lockedLesson = 'Termine d\'abord la leçon d\'avant.';
  static const lessonDone = 'Leçon terminée.';

  static const listenAgain = 'Écoute :';
  static const praise = ['C\'est ça.', 'Oui.', 'Exact.', 'Bien.', 'Voilà.', 'C\'est bon.', 'Tu l\'as.'];
  static const repair = ['Pas encore. Écoute encore.', 'Presque.', 'On réessaie.'];

  static const promptSyllable = 'Écoute et touche la syllabe';
  static const promptWord = 'Écoute et touche le mot';
  static const promptDigit = 'Écoute et touche le chiffre';
  static const promptSound = 'Écoute et touche le son';
  static String promptLetter(String t) => 'Touche la lettre $t';
  static String promptUpper(String t) => 'Touche la lettre $t majuscule';
  static String promptCursive(String t) => 'Touche la lettre $t en écriture cursive';
  static String found(int score, int total) => 'Tu as trouvé $score sur $total.';

  static const alphabet = 'Le mur des lettres. Les 26 lettres, à écouter et à tracer.';
  static const digits = 'Les chiffres. De 0 à 9 : écoute et écris.';
  static const notebook = 'Cahier d\'écriture. Trace une lettre avec ton doigt.';
  static const traceEmpty = 'Trace la lettre avec ton doigt, sur le modèle gris.';
  static const trace = [
    'Pas encore. Commence en haut et suis le modèle.',
    'Presque. Passe sur toute la lettre.',
    'Bien. Suis bien le modèle gris.',
    'Très bien tracé.',
  ];

  static const slowVoice = 'Voix lente. La voix parle plus doucement.';
  static const slowOn = 'Je parle lentement.';
  static const slowOff = 'Je parle normalement.';
  static const cursiveDefault = 'Écriture cursive par défaut.';
  static const largeText = 'Grand texte.';
  static const unlockAll = 'Ouvrir toutes les leçons.';

  static const fixed = [
    welcome, profile, greeting, home, path, atelier, progress, settings, lockedLesson,
    lessonDone, listenAgain, ...praise, ...repair, promptSyllable, promptWord, promptDigit,
    promptSound, alphabet, digits, notebook, traceEmpty, ...trace, slowVoice, slowOn, slowOff,
    cursiveDefault, largeText, unlockAll,
  ];
}
