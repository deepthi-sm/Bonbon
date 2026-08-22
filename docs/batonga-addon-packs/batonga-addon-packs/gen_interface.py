#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Pack 3 generator — La Voix de l'Interface.
The book assumes a literate facilitator sits beside the learner. The app has to
absorb that role. This pack is the script for it: every string the app can say,
every icon it can show, and the flows for the moments the book never had to
specify.
"""
import json, pathlib, re

OUT = pathlib.Path(__file__).parent / '03-interface'; OUT.mkdir(exist_ok=True)
def w(name, obj):
    (OUT / name).write_text(json.dumps(obj, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'{name:34s} {len(json.dumps(obj, ensure_ascii=False)):>8,d} bytes')

def S(key, text, icon=None, ctx=None, spoken=None):
    """One string, three channels. `spoken` differs from `text` when the written
    label must be short but the spoken one must be a whole sentence."""
    e = {"t": text, "a": f"ui.{key}", "i": icon}
    if spoken: e["spoken"] = spoken
    if ctx: e["ctx"] = ctx
    return key, e

NS = {}
def ns(name, *pairs):
    NS[name] = dict(pairs)

# ── common ────────────────────────────────────────────────────────────────
ns("common",
  S("continue",   "Continuer",        "arrow-right", spoken="Appuie pour continuer."),
  S("start",      "Commencer",        "play"),
  S("back",       "Retour",           "arrow-left"),
  S("close",      "Fermer",           "close"),
  S("yes",        "Oui",              "check"),
  S("no",         "Non",              "close"),
  S("listen",     "Écouter",          "speaker", spoken="Appuie sur le haut-parleur pour écouter."),
  S("listenAll",  "Tout écouter",     "speaker-list"),
  S("again",      "Encore",           "replay",  spoken="Appuie pour réécouter."),
  S("slower",     "Plus lentement",   "turtle"),
  S("next",       "Suivant",          "arrow-right"),
  S("previous",   "Précédent",        "arrow-left"),
  S("skip",       "Passer",           "skip", ctx="ALWAYS visible on every activity. §J.3 rule 4."),
  S("done",       "Terminé",          "check-circle"),
  S("retry",      "Réessayer",        "replay"),
  S("help",       "Aide",             "hand", spoken="Appuie longuement sur un bouton pour savoir à quoi il sert."),
  S("script.print",  "Écriture normale", "letter-print"),
  S("script.cursive","Écriture attachée","letter-cursive"),
  S("loading",    "Un instant…",      "hourglass"),
)

# ── onboarding ────────────────────────────────────────────────────────────
ns("onboarding",
  S("welcome.title",  "Bienvenue",  "hand-wave",
    spoken="Bienvenue. Cette application t'apprend à lire et à écrire le français. "
           "Tu n'as pas besoin de savoir lire pour t'en servir. Appuie sur le grand bouton vert."),
  S("welcome.cta",    "Commencer",  "play"),
  S("sound.title",    "Le son",     "speaker",
    spoken="Est-ce que tu m'entends bien ? Si tu n'entends rien, monte le son de ton téléphone."),
  S("sound.yes",      "Je t'entends","check"),
  S("sound.no",       "Je n'entends rien","ear-off"),
  S("sound.help",     "Monte le son","volume-up",
    spoken="Appuie sur le bouton du son, sur le côté de ton téléphone, vers le haut. Puis réessaie."),
  S("name.title",     "Ton nom",    "person",
    spoken="Comment veux-tu qu'on t'appelle ? Tu peux écrire ton nom, ou choisir une image. "
           "Tu peux aussi passer."),
  S("name.placeholder","Ton nom",   None),
  S("name.orAvatar",  "Ou choisis une image","image"),
  S("name.skip",      "Passer",     "skip"),
  S("tapTest.title",  "Essayons",   "target",
    spoken="On va essayer ensemble. Touche le rond bleu."),
  S("tapTest.ok",     "C'est ça.",  "check-circle", spoken="C'est ça. Tu sais te servir de l'application."),
  S("tapTest.retry",  "Touche le rond bleu.","target"),
  S("listenTest.title","Écoute",    "speaker",
    spoken="Maintenant, touche le haut-parleur pour entendre une lettre."),
  S("placement.title","Par où commencer ?","signpost",
    spoken="Veux-tu commencer au début, ou veux-tu que je regarde ce que tu sais déjà ?"),
  S("placement.fromStart","Commencer au début","book-open",
    spoken="Commencer au début. C'est le meilleur choix si tu n'es pas sûre."),
  S("placement.test", "Je connais déjà des lettres","fast-forward",
    spoken="Je vais te poser quelques questions courtes. Ce n'est pas un examen. "
           "Tu peux t'arrêter quand tu veux."),
  S("placement.result","Tu peux commencer ici.","flag",
    ctx="Followed by the lesson title. NEVER a score, NEVER a level name."),
  S("done.title",     "C'est prêt",  "check-circle",
    spoken="C'est prêt. Prends ton temps. Tu peux revenir quand tu veux : "
           "l'application se souvient d'où tu t'es arrêtée."),
)

# ── home / accueil ────────────────────────────────────────────────────────
ns("home",
  S("resume",         "Continuer",   "play-circle",
    spoken="Reprends là où tu t'es arrêtée.", ctx="The single primary action. §K.1."),
  S("resume.detail",  "Leçon {n} — {titre}", None),
  S("startFirst",     "Commencer la leçon 1","play-circle"),
  S("path",           "Mon parcours","path"),
  S("practice",       "M'entraîner","dumbbell"),
  S("progress",       "Mes progrès","chart"),
  S("settings",       "Réglages",   "gear"),
  S("review.today",   "À revoir aujourd'hui","refresh"),
  S("review.count",   "{n} à revoir", None),
  S("streak.days",    "{n} jours de suite","flame",
    ctx="Counts DAYS SHE OPENED THE APP, never accuracy. §J.3 rule 3."),
  S("streak.today",   "Tu es venue aujourd'hui.","flame"),
  S("greeting.morning","Bonjour {nom}","sun"),
  S("greeting.evening","Bonsoir {nom}","moon"),
)

# ── parcours ──────────────────────────────────────────────────────────────
ns("path",
  S("title",          "Mon parcours","path"),
  S("unit.voyelles",  "Les voyelles","letter-a"),
  S("unit.consonnes", "Les consonnes","letter-t"),
  S("unit.graphemes", "Les sons et les textes","book-open"),
  S("unit.chiffres",  "Les chiffres","digits"),
  S("unit.progress",  "{fait} sur {total}", None),
  S("node.locked",    "Pas encore ouverte","lock",
    spoken="Termine la leçon d'avant pour ouvrir celle-ci."),
  S("node.available", "À faire",     "circle"),
  S("node.current",   "À toi",       "play-circle"),
  S("node.completed", "Terminée",    "check-circle"),
  S("node.review",    "À revoir",    "refresh"),
)

# ── lesson player ─────────────────────────────────────────────────────────
ns("lesson",
  S("objective",      "Aujourd'hui","target",
    ctx="Followed by the lesson objective string from the content pack."),
  S("block.keyword",  "Le mot",     "image"),
  S("block.forms",    "Les formes de la lettre","letters"),
  S("block.repetition","Regarde bien","eye"),
  S("block.tree",     "Les syllabes","tree"),
  S("block.strip",    "Lis les syllabes","list"),
  S("block.words",    "Les mots",   "word"),
  S("block.sentences","Les phrases","sentence"),
  S("block.text",     "Le texte",   "book-open"),
  S("block.strokes",  "Comment on l'écrit","pen"),
  S("block.writing",  "À toi d'écrire","hand-pen"),
  S("block.bilan",    "Ce que tu as appris","check-list"),
  S("tapToHear",      "Touche pour écouter","speaker"),
  S("longPressSyllables","Appuie longtemps pour entendre syllabe par syllabe","speaker-slow"),
  S("wordByWord",     "Mot à mot",  "words-sequence"),
  S("iReadIt",        "J'ai lu",    "check", ctx="Per sentence in a reading text."),
  S("progress",       "{i} sur {n}", None),
  S("leave.title",    "Tu veux t'arrêter ?","pause",
    spoken="Tu veux t'arrêter ? Je garde ta place."),
  S("leave.confirm",  "Oui, je m'arrête","check"),
  S("leave.cancel",   "Je continue","play"),
  S("resumed",        "On reprend ici.","bookmark"),
)

# ── activity ──────────────────────────────────────────────────────────────
ns("activity",
  S("tapIdentify.prompt",  "Touche {cible}","target"),
  S("listenChoose.prompt", "Écoute, puis touche le bon","ear"),
  S("syllableBuild.prompt","Écoute et construis la syllabe","puzzle"),
  S("missingLetter.prompt","Quelle lettre manque ?","question"),
  S("trace.prompt",        "Écris {cible}","pen"),
  S("wordMatch.prompt",    "Relie le mot à l'image","link"),
  S("comprehension.prompt","Réponds à la question","question"),
  S("correct",             "C'est ça","check-circle", spoken="C'est ça."),
  S("almost",              "Presque","half-circle", spoken="Presque. Écoute encore."),
  S("notYet",              "Pas encore","circle", spoken="Pas encore. On réessaie."),
  S("hint.listenAgain",    "Écoute encore","replay"),
  S("hint.narrow",         "C'est l'un des deux","filter"),
  S("hint.show",           "Regarde","eye"),
  S("moveOn",              "On continue. Tu la reverras.","arrow-right"),
  S("skipConfirm",         "Passer cet exercice ?","skip"),
  S("attemptsLeft",        "", None, ctx="INTENTIONALLY EMPTY — we never show attempts left. "
                                        "There is no attempt limit in MVP."),
)

# ── assessment ────────────────────────────────────────────────────────────
ns("assessment",
  S("bilan.title",    "Ce que tu as appris","check-list",
    spoken="Quelques questions pour voir ce que tu retiens. Ce n'est pas un examen."),
  S("bilan.good",     "Bien lu","star", spoken="Bien lu. Tu as reconnu {n} choses sur {total}."),
  S("bilan.partial",  "C'est en train de venir","seedling",
    spoken="C'est en train de venir. On reverra {cible} bientôt."),
  S("checkpoint.title","Fin de l'unité","flag",
    spoken="Tu arrives au bout de cette partie. On va revoir ensemble."),
  S("checkpoint.pass","Unité terminée","trophy"),
  S("result.count",   "{bon} sur {total}", None),
  S("review.added",   "On reverra : {liste}","refresh"),
)

# ── writing ───────────────────────────────────────────────────────────────
ns("writing",
  S("watchFirst",     "Regarde d'abord","eye", spoken="Regarde comment on l'écrit."),
  S("replayModel",    "Revoir le modèle","replay"),
  S("nowYou",         "À toi",      "hand-pen", spoken="À toi. Commence au point."),
  S("startHere",      "Commence ici","dot"),
  S("stars",          "{n} étoiles sur 3","star"),
  S("clear",          "Effacer",    "eraser"),
  S("cue.start",      "Commence ici, en haut.", "dot"),
  S("cue.direction",  "Descends, ne monte pas.","arrow-down"),
  S("cue.checkpoint", "Passe bien par le point.","dot"),
  S("cue.slow",       "Doucement, suis le trait.","turtle"),
  S("cue.missing",    "Il manque un trait.","pen"),
  S("cue.good",       "C'est bien tracé.","check-circle"),
)

# ── practice / entraînement ───────────────────────────────────────────────
ns("practice",
  S("title",          "M'entraîner","dumbbell"),
  S("reviewLesson",   "Revoir une leçon","replay"),
  S("letterWall",     "Le mur des lettres","letters",
    spoken="Toutes les lettres, à regarder et à écouter quand tu veux."),
  S("digits",         "Les chiffres","digits"),
  S("notebook",       "Cahier d'écriture","notebook",
    spoken="Une page blanche pour t'entraîner à écrire."),
  S("themes",         "Les mots par thème","tags",
    ctx="Surfaces the thematic lexicon from Pack 1 — including « les mots du commerce », "
        "which are the book's OWN words, not a new curriculum."),
  S("theme.commerce", "Les mots du commerce","shop"),
  S("theme.maison",   "À la maison","house"),
  S("theme.nourriture","La nourriture","bowl"),
  S("theme.ecole",    "À l'école","school"),
  S("theme.village",  "Au village","village"),
  S("freeBrowse",     "Tu peux tout regarder, rien n'est bloqué ici.","unlock"),
)

# ── progress ──────────────────────────────────────────────────────────────
ns("progress",
  S("title",          "Mes progrès","chart"),
  S("lessonsDone",    "{n} leçons terminées","check-circle"),
  S("lettersKnown",   "{n} lettres reconnues","letters"),
  S("syllablesKnown", "{n} syllabes lues","puzzle"),
  S("wordsHeard",     "{n} mots écoutés","ear"),
  S("textsRead",      "{n} textes lus","book-open"),
  S("daysActive",     "{n} jours","calendar"),
  S("empty",          "Tu commences tout juste. Reviens après ta première leçon.","seedling"),
  S("noComparison",   "", None, ctx="INTENTIONALLY EMPTY — no ranking, no comparison with "
                                    "other learners, ever. §J.5."),
)

# ── settings ──────────────────────────────────────────────────────────────
ns("settings",
  S("title",          "Réglages",   "gear"),
  S("voice.speed",    "Vitesse de la voix","speaker"),
  S("voice.normal",   "Normale",    "speaker"),
  S("voice.slow",     "Lente",      "turtle"),
  S("script.default", "Écriture affichée","letters"),
  S("textSize",       "Taille du texte","text-size"),
  S("haptics",        "Vibrations", "vibrate"),
  S("profile",        "Mon profil", "person"),
  S("profile.switch", "Changer de personne","people",
    spoken="Si quelqu'un d'autre utilise ce téléphone, choisis son nom ici.",
    ctx="A shared family phone is normal. §K.1."),
  S("profile.reset",  "Tout recommencer","refresh",
    spoken="Attention : tu perdras tes progrès. Es-tu sûre ?"),
  S("about",          "À propos",   "info"),
  S("about.source",   "D'après le Syllabaire Alphanumérique de la Fondation Batonga, 2ᵉ édition.",
    "book-open"),
  S("privacy",        "Tes données restent sur ce téléphone.","shield",
    spoken="Rien de ce que tu fais ici ne quitte ton téléphone."),
  S("facilitator",    "Mode animatrice","people"),
)

# ── celebration ───────────────────────────────────────────────────────────
ns("celebration",
  S("lesson.done",    "Leçon terminée","check-circle"),
  S("lesson.first",   "Ta première leçon est terminée.","star"),
  S("unit.done",      "Unité terminée","trophy"),
  S("specific.letters","Tu as reconnu la lettre {lettre}.","letters"),
  S("specific.syllables","Tu as lu {n} syllabes.","puzzle"),
  S("specific.words", "Tu as lu {n} mots.","word"),
  S("specific.text",  "Tu as lu un texte en entier.","book-open"),
  S("keepGoing",      "On continue ?","arrow-right"),
  S("comeBack",       "Reviens quand tu veux.","door"),
)

# ── errors / empty / repair ───────────────────────────────────────────────
ns("errors",
  S("audio.missing",  "", None,
    ctx="INTENTIONALLY EMPTY. When audioService.has() is false the speaker icon is NOT "
        "RENDERED. There is no error message, because there is no error for the learner. §H.6."),
  S("audio.failed",   "Le son ne marche pas. Vérifie le volume.","volume-up"),
  S("content.broken", "Continuer",  "arrow-right",
    ctx="A malformed activity payload renders a neutral Continuer card. A content bug must "
        "never look like the learner's fault, and must never crash a lesson. §H.2."),
  S("storage.full",   "Ton téléphone est plein. Libère un peu de place.","warning"),
  S("generic",        "Quelque chose n'a pas marché. Réessaie.","warning"),
  S("offline",        "", None,
    ctx="INTENTIONALLY EMPTY. The app is offline by construction. There is no offline "
        "state and therefore no offline message. §C.4."),
)

# ── facilitator ───────────────────────────────────────────────────────────
ns("facilitator",
  S("title",          "Mode animatrice","people"),
  S("subtitle",       "Pour la personne qui accompagne le groupe.", None),
  S("enter",          "Entrer",     "arrow-right",
    ctx="No password. A 4-digit PIN is optional and off by default — a lock the animatrice "
        "forgets is worse than no lock."),
  S("learners",       "Les apprenantes","people"),
  S("learner.at",     "En est à : {leçon}", None),
  S("learner.lastSeen","Vue le {date}", None),
  S("learner.weak",   "À travailler : {liste}", None),
  S("addLearner",     "Ajouter une apprenante","person-plus"),
  S("groupSummary",   "{n} apprenantes · {m} leçons terminées cette semaine", None),
  S("suggest",        "À faire ensemble aujourd'hui","clipboard"),
  S("export",         "", None, ctx="INTENTIONALLY EMPTY in MVP — no export, no upload, "
                                    "no report leaves the phone."),
)

w("ui-strings.fr.json", {
  "$comment": "NEW. The complete French interface, in three channels at once. EVERY key "
              "carries `t` (written), `a` (spoken clip id) and `i` (icon id). A key with a "
              "null icon or a missing clip is a lint failure, not a style choice: the "
              "learner cannot read `t`, so `a` and `i` are not decoration, they are the "
              "interface. Keys with an empty string and a `ctx` note are deliberately empty "
              "— read the note before filling one in.",
  "principle":"text + icon + voice, always all three",
  "register":{"address":"tutoiement","tone":"adulte, chaleureux, jamais enfantin",
              "maxWords":12,"noJargon":True},
  "lint":["every key has i != null unless ctx explains why",
          "every key has a matching row in the audio recording script",
          "no key longer than 12 words in `t`",
          "no key contains a digit above 9 spelled as a numeral in Unit 1–3 text",
          "placeholders are named ({nom}), never positional ({0})"],
  "namespaceCount": len(NS),
  "stringCount": sum(len(v) for v in NS.values()),
  "namespaces": NS,
})

# ── icon lexicon ──────────────────────────────────────────────────────────
ICONS = [
 ("speaker","haut-parleur","écouter ce qui est à côté","le seul sens autorisé : ÉCOUTER. Jamais « son activé »."),
 ("speaker-slow","haut-parleur + tortue","écouter lentement, syllabe par syllabe",None),
 ("speaker-list","haut-parleur + lignes","tout écouter à la suite",None),
 ("replay","flèche circulaire","recommencer, réécouter",None),
 ("play","triangle","démarrer",None),
 ("play-circle","triangle dans un rond","action principale de l'écran","un seul par écran"),
 ("pause","deux barres","mettre en pause",None),
 ("arrow-right","flèche droite","avancer",None),
 ("arrow-left","flèche gauche","reculer",None),
 ("arrow-down","flèche bas","sens du tracé, vers le bas",None),
 ("check","coche","validé",None),
 ("check-circle","coche dans un rond","terminé, réussi",None),
 ("circle","rond vide","à faire","jamais rouge"),
 ("half-circle","demi-rond","presque",None),
 ("close","croix","fermer","JAMAIS pour signaler une erreur"),
 ("lock","cadenas","pas encore ouvert",None),
 ("unlock","cadenas ouvert","libre d'accès",None),
 ("star","étoile","réussite, qualité du tracé",None),
 ("trophy","coupe","fin d'unité",None),
 ("flame","flamme","jours de suite","compte les jours de présence, pas les réussites"),
 ("flag","drapeau","point de départ, jalon",None),
 ("target","cible","touche ceci",None),
 ("dot","point","point de départ du tracé",None),
 ("pen","stylo","écriture, modèle de tracé",None),
 ("hand-pen","main qui écrit","à toi d'écrire",None),
 ("eraser","gomme","effacer",None),
 ("eye","œil","regarde",None),
 ("ear","oreille","écoute puis choisis",None),
 ("ear-off","oreille barrée","je n'entends rien",None),
 ("letters","plusieurs lettres","alphabet, formes",None),
 ("letter-print","a droit","écriture scripte",None),
 ("letter-cursive","a attaché","écriture cursive",None),
 ("puzzle","deux pièces","construire une syllabe",None),
 ("tree","arbre de flèches","l'arbre des syllabes","reprend le graphisme du livre"),
 ("word","un mot encadré","mot",None),
 ("sentence","une ligne de mots","phrase",None),
 ("book-open","livre ouvert","texte, lecture",None),
 ("path","chemin","le parcours",None),
 ("digits","1 2 3","les chiffres",None),
 ("chart","barres","mes progrès",None),
 ("calendar","calendrier","jours",None),
 ("person","silhouette","mon profil",None),
 ("people","deux silhouettes","autres personnes, animatrice",None),
 ("person-plus","silhouette +","ajouter",None),
 ("gear","roue dentée","réglages",None),
 ("info","i dans un rond","à propos",None),
 ("shield","bouclier","tes données restent ici",None),
 ("warning","triangle","problème technique","jamais pour une réponse fausse"),
 ("skip","double flèche","passer",None),
 ("refresh","flèches circulaires","à revoir",None),
 ("turtle","tortue","plus lentement",None),
 ("volume-up","haut-parleur +","monter le son du téléphone",None),
 ("hand","main ouverte","aide",None),
 ("hand-wave","main qui salue","bienvenue",None),
 ("seedling","jeune pousse","ça vient","remplace toute idée d'échec"),
 ("shop","étal","les mots du commerce",None),
 ("house","maison","à la maison",None),
 ("bowl","calebasse","la nourriture",None),
 ("school","école","à l'école",None),
 ("village","cases","au village",None),
 ("tags","étiquettes","thèmes",None),
 ("image","cadre photo","dessin",None),
 ("notebook","cahier ligné","cahier d'écriture","reprend la réglure Seyès du livre"),
 ("clipboard","porte-bloc","à faire ensemble",None),
 ("signpost","panneau","par où commencer",None),
 ("bookmark","marque-page","on reprend ici",None),
 ("door","porte","reviens quand tu veux",None),
 ("sun","soleil","bonjour",None),
 ("moon","lune","bonsoir",None),
 ("hourglass","sablier","un instant",None),
 ("filter","entonnoir","il en reste deux",None),
 ("link","chaînon","relier",None),
 ("question","point d'interrogation","question",None),
 ("check-list","liste cochée","bilan",None),
 ("dumbbell","haltère","m'entraîner",None),
 ("text-size","Aa","taille du texte",None),
 ("vibrate","téléphone qui vibre","vibrations",None),
 ("fast-forward","double triangle","je connais déjà",None),
 ("words-sequence","mots surlignés l'un après l'autre","mot à mot",None),
 ("letter-a","un a","unité des voyelles",None),
 ("letter-t","un t","unité des consonnes",None),
 ("list","lignes","bande de syllabes",None),
]
w("icon-lexicon.json", {
  "$comment": "NEW. For a learner who cannot read, the icon IS the label — so an icon that "
              "means two things is a bug of the same severity as a mistranslation. This is a "
              "CLOSED set: adding an icon is a design decision made once, by Dev C, and "
              "recorded here. Style: single-weight line art, 2 dp stroke, no colour carrying "
              "meaning, drawn from the same visual world as the book's own illustrations "
              "(adult, Beninese, uncluttered) — never a children's icon set.",
  "rules":["one icon, one meaning, app-wide",
           "an icon never carries meaning by colour alone (§J.3)",
           "every icon has a spoken label reachable by long-press",
           "minimum rendered size 32 dp inside a 56 dp target",
           "no emoji, ever — they render differently per device and read as childish"],
  "count": len(ICONS),
  "icons":[{"id":i,"drawing":d,"means":m,"note":n} for i,d,m,n in ICONS],
})

# ── narrated onboarding script ────────────────────────────────────────────
w("onboarding-script.fr.json", {
  "$comment": "NEW. The book presumes a facilitator who says « ouvre à la page 20 ». Nobody "
              "says that here, so the app must. This is the full voice-over script for first "
              "run, written to be operable by someone who reads nothing at all. Total runtime "
              "≈ 2 minutes. Every step is skippable; no step needs the keyboard.",
  "designRules":[
    "Nothing in onboarding requires reading.",
    "Nothing in onboarding requires typing (the name step is optional and offers avatars).",
    "The learner performs a real tap before Lesson 1 — we verify she can operate the app.",
    "Audio auto-plays on entering each step, and replays on tapping the screen anywhere.",
    "Total ≤ 6 steps. Every step has exactly one primary action.",
  ],
  "steps":[
    {"n":1,"id":"welcome","auto":"vo.onb.01",
     "vo":"Bienvenue. Cette application t'apprend à lire et à écrire le français. "
          "Tu n'as pas besoin de savoir lire pour t'en servir. Appuie sur le grand bouton vert.",
     "screen":"Logo Batonga, un seul grand bouton vert au centre.",
     "action":"tap primary","fallbackAfterMs":8000,
     "fallbackVo":"Appuie sur le grand bouton vert, au milieu de l'écran."},
    {"n":2,"id":"sound","auto":"vo.onb.02",
     "vo":"Est-ce que tu m'entends bien ? Si tu ne m'entends pas, monte le son de ton téléphone, "
          "sur le côté, vers le haut.",
     "screen":"Deux boutons : « Je t'entends » et « Je n'entends rien ».",
     "action":"choose 1 of 2",
     "branch":{"no":"Play vo.onb.02b: « Monte le son sur le côté du téléphone, vers le haut. "
                     "Puis appuie encore. » — loops, never blocks."}},
    {"n":3,"id":"name","auto":"vo.onb.03",
     "vo":"Comment veux-tu qu'on t'appelle ? Tu peux écrire ton nom, ou choisir une image. "
          "Tu peux aussi passer, ça n'a pas d'importance.",
     "screen":"Champ de texte optionnel + grille de 12 images + bouton « Passer ».",
     "action":"type OR pick OR skip",
     "note":"Aucun email. Aucun mot de passe. Aucun numéro. §C.6."},
    {"n":4,"id":"tap-test","auto":"vo.onb.04",
     "vo":"On essaie ensemble. Touche le rond bleu.",
     "screen":"Un grand rond bleu, un carré gris à côté.",
     "action":"tap the blue circle","onWrong":"vo.onb.04b: « Le rond bleu, celui qui est rond. »",
     "onRight":"vo.onb.04c: « C'est ça. Tu sais te servir de l'application. »",
     "why":"This is the only place we verify she can operate the interface before the "
           "content starts. Three seconds now prevents a silent abandonment in lesson 1."},
    {"n":5,"id":"listen-test","auto":"vo.onb.05",
     "vo":"Quand tu vois ce dessin — un haut-parleur — tu peux toujours appuyer pour écouter. "
          "Essaie.",
     "screen":"Une grande icône haut-parleur au centre.",
     "action":"tap the speaker","onRight":"plays letter.a.sound, then vo.onb.05b: "
              "« Voilà. Le haut-parleur, c'est pour écouter. »"},
    {"n":6,"id":"placement","auto":"vo.onb.06",
     "vo":"Veux-tu commencer au début, ou veux-tu que je regarde d'abord ce que tu sais déjà ? "
          "Si tu n'es pas sûre, commence au début.",
     "screen":"Deux boutons ; « Commencer au début » est visuellement dominant.",
     "action":"choose 1 of 2","default":"Commencer au début"},
    {"n":7,"id":"ready","auto":"vo.onb.07",
     "vo":"C'est prêt. Prends ton temps. Tu peux t'arrêter quand tu veux : "
          "l'application se souvient d'où tu t'es arrêtée.",
     "screen":"Bouton « Commencer la leçon 1 ».","action":"tap primary"},
  ],
  "returningLearner":[
    {"gap":"1–2 days","vo":"Te revoilà. On reprend à la leçon {n} ?"},
    {"gap":"3–13 days","vo":"Contente de te revoir. On reprend doucement : "
                            "je te remets d'abord ce que tu as vu la dernière fois."},
    {"gap":"14+ days","vo":"Ça fait un moment. On va revoir ensemble avant de continuer. "
                           "Rien n'est perdu.",
     "sideEffect":"insert a 5-item review session drawn from the weakest mastery rows "
                  "before resuming the path"},
  ],
})

# ── encouragement bank ────────────────────────────────────────────────────
w("encouragement-bank.fr.json", {
  "$comment": "NEW. 44 spoken lines. Generic praise (« Bravo ! ») stops meaning anything by "
              "the fourth time and reads as childish to an adult. Every line here is either "
              "SPECIFIC (names what she actually did) or QUIET. Rotation is enforced: no line "
              "repeats within 8 plays, and the celebratory tier only fires on genuine "
              "milestones, never on a routine correct answer.",
  "register":"adulte, chaleureux, sobre. Jamais de diminutif, jamais de voix d'enfant, "
             "jamais de superlatif répété.",
  "rotation":{"noRepeatWithin":8,"perSessionCap":{"celebration":3}},
  "tiers":{
    "micro":{"when":"bonne réponse ordinaire","runtime":"< 1 s","lines":[
      "C'est ça.","Oui.","Exact.","Bien.","Voilà.","C'est bon.","Tu l'as."]},
    "specific":{"when":"fin de bloc — nomme ce qu'elle vient de faire","lines":[
      "Tu as reconnu la lettre {lettre}.","Tu as lu {n} syllabes.","Tu as lu {n} mots.",
      "Tu as lu la phrase en entier.","Tu as écouté tout le texte.",
      "Tu as trouvé les {n} lettres.","Tu as construit {n} syllabes.",
      "Tu as écrit {lettre} trois fois.","Tu reconnais {lettre} même en écriture attachée.",
      "Tu as lu un texte de {n} phrases."]},
    "effort":{"when":"après une difficulté surmontée","lines":[
      "Tu as réessayé, et tu l'as eu.","Celle-là était difficile.",
      "Tu ne t'es pas arrêtée.","Tu as pris ton temps, c'est bien.",
      "Tu l'avais ratée la première fois. Plus maintenant."]},
    "repair":{"when":"après une erreur — jamais de blâme","lines":[
      "Pas encore. Écoute encore.","On réessaie.","Presque.",
      "C'est celle-là : {réponse}.","On continue, tu la reverras.",
      "Ce n'est pas grave. Écoute."]},
    "celebration":{"when":"fin de leçon ou d'unité seulement","lines":[
      "Leçon terminée.","Tu as terminé la leçon {n}.",
      "Première leçon terminée. C'est le plus difficile qui est fait.",
      "Unité terminée. Tu connais maintenant toutes les voyelles.",
      "Unité terminée. Tu peux lire des syllabes et des phrases courtes.",
      "Tu as lu ton premier texte en entier.",
      "Tu connais les chiffres de zéro à neuf."]},
    "return":{"when":"ouverture de l'application","lines":[
      "Te revoilà.","Bonjour {nom}.","Contente de te revoir.",
      "Tu es venue {n} jours de suite.","On reprend où tu t'es arrêtée."]},
    "closing":{"when":"sortie de l'application","lines":[
      "À bientôt.","Reviens quand tu veux.","Je garde ta place.",
      "Tu as travaillé {n} minutes aujourd'hui."]},
  },
  "banned":["Bravo !!!","Super !","Génial !","Tu es la meilleure","Waouh",
            "Tu as gagné","Tu as perdu","Faux","Erreur","Mauvaise réponse",
            "Essaie encore ma belle","Ma chérie","Petite"],
  "why":"Les trois derniers sont bannis pour la même raison que les leaderboards (§J.5) : "
        "le public est composé d'adultes exclues de l'école. Un ton infantilisant sape "
        "exactement l'estime de soi que la préface du livre cherche à renforcer.",
})

# ── repair flows ──────────────────────────────────────────────────────────
w("repair-flows.fr.json", {
  "$comment": "NEW. The moments a paper book never has to handle. Each flow is defined by "
              "what the app SAYS, because the learner cannot read what it writes.",
  "flows":[
    {"id":"stuck-3-times","trigger":"3 échecs consécutifs sur la même cible",
     "vo":"On laisse celle-ci pour aujourd'hui. Tu la reverras.",
     "action":"valider pour elle, marquer strength = 0.15, continuer",
     "never":"ne jamais bloquer, ne jamais répéter une quatrième fois"},
    {"id":"no-audio-yet","trigger":"audioService.has(id) === false",
     "vo":None,"action":"ne pas afficher l'icône haut-parleur",
     "never":"aucun message, aucune icône grisée, aucune explication — "
             "pour l'apprenante, ce bouton n'a jamais existé"},
    {"id":"volume-zero","trigger":"volume système à 0 au lancement d'une leçon",
     "vo":"Le son de ton téléphone est coupé. Monte-le sur le côté.",
     "action":"bandeau persistant avec icône volume, non bloquant"},
    {"id":"wrong-profile","trigger":"profil actif ≠ dernier profil actif il y a < 2 min",
     "vo":"Est-ce bien toi, {nom} ?","action":"deux visages/noms à toucher",
     "why":"Le téléphone familial est la norme (§K.1)."},
    {"id":"long-absence","trigger":"≥ 14 jours sans ouverture",
     "vo":"Ça fait un moment. On va revoir ensemble avant de continuer. Rien n'est perdu.",
     "action":"session de révision de 5 items avant de reprendre le parcours"},
    {"id":"interrupted-lesson","trigger":"leçon quittée en cours",
     "vo":"On reprend ici.","action":"reprise exacte au bloc quitté, sans résumé"},
    {"id":"locked-node-tapped","trigger":"nœud verrouillé touché dans le parcours",
     "vo":"Termine la leçon d'avant pour ouvrir celle-ci.",
     "action":"animer le nœud précédent, ne pas ouvrir de dialogue"},
    {"id":"trace-illegible","trigger":"score de tracé < 0.2 trois fois",
     "vo":"Regarde encore comment on l'écrit.",
     "action":"rejouer l'animation au ralenti, puis passer",
     "never":"ne jamais dire que le tracé est mauvais"},
    {"id":"storage-full","trigger":"écriture SQLite échouée",
     "vo":"Ton téléphone est plein. Libère un peu de place.",
     "action":"la leçon continue en mémoire ; la progression est réécrite au prochain "
              "lancement réussi (l'échec DB ne remonte jamais à l'UI — §H.3)"},
  ],
})

# ── register / tone guide ─────────────────────────────────────────────────
w("register-guide.json", {
  "$comment": "NEW. One page, binding on all four developers. Copy is design here, not "
              "decoration: the learner meets the app almost entirely through its voice.",
  "decisions":[
    {"q":"Tutoiement ou vouvoiement ?","a":"Tutoiement.",
     "why":"Le livre s'adresse aux apprenantes directement et le tutoiement porte la "
           "proximité d'une animatrice assise à côté. Le vouvoiement crée une distance "
           "administrative. À revalider auprès de Batonga : c'est un choix culturel, pas "
           "seulement stylistique."},
    {"q":"Qui parle ?","a":"Une femme adulte, béninoise, calme, ni professorale ni maternante.",
     "why":"Le registre de l'accompagnatrice du cercle d'affaires, pas celui d'une institutrice."},
    {"q":"Longueur des phrases ?","a":"12 mots maximum à l'écrit, 20 à l'oral.",
     "why":"Une consigne qu'il faut relire est une consigne ratée."},
    {"q":"Impératif ou question ?","a":"Impératif doux pour les consignes (« Touche la lettre t »), "
                                       "question pour les choix (« Tu veux t'arrêter ? »)."},
    {"q":"Peut-on nommer l'échec ?","a":"Jamais.",
     "why":"« Pas encore » et « on réessaie » disent la même chose sans la charge."},
    {"q":"Chiffres en lettres ou en chiffres ?","a":"En chiffres, toujours (3, pas trois).",
     "why":"L'unité 4 enseigne précisément la forme du chiffre ; l'interface doit la montrer."},
    {"q":"Vocabulaire",
     "a":"Celui du livre. Marigot, canari, fonio, pagne — jamais remplacés par un synonyme "
         "« plus clair ». Voir protected-terms.json."},
  ],
  "checklist":["Une consigne = une action.",
               "Nommer l'objet, pas l'abstraction (« le haut-parleur », pas « le lecteur audio »).",
               "Aucun terme technique : ni « application », ni « menu », ni « paramètres » "
               "dans les consignes parlées.",
               "Aucun mot anglais.",
               "Aucun point d'exclamation multiple.",
               "Toute chaîne écrite a une chaîne parlée équivalente, pas identique : "
               "l'écrit peut être court, l'oral doit être une phrase."],
})

# ── facilitator surface ───────────────────────────────────────────────────
w("facilitator.json", {
  "$comment": "NEW. The book assumes a facilitator on every page and documents her nowhere. "
              "Batonga's cercles d'affaires and leadership clubs have one. This is a small, "
              "deliberately unambitious surface for her — on the same phone, no account, no "
              "network, no dashboard. It is NOT the V2 web reporting product (§C.6.3).",
  "scope":{"in":["plusieurs profils sur un même téléphone",
                 "où en est chaque apprenante",
                 "ce qu'il faut retravailler avec elle aujourd'hui",
                 "une page imprimable-à-l'écran pour la séance de groupe"],
           "out":["comptes","synchronisation","export de fichier","statistiques de cohorte",
                  "notation","comparaison entre apprenantes"]},
  "access":{"entry":"Réglages → Mode animatrice","lock":"PIN 4 chiffres, désactivé par défaut",
            "why":"Un verrou que l'animatrice oublie est pire que pas de verrou."},
  "screens":[
    {"id":"learners","title":"Les apprenantes",
     "shows":"une ligne par profil : nom/image, leçon en cours, dernière venue, "
             "3 cibles faibles",
     "sourceOf":"progressService.getPathState() par profil + les 3 MasteryRecord "
                "les plus faibles"},
    {"id":"today","title":"À faire ensemble aujourd'hui",
     "shows":"pour le groupe : la leçon la plus fréquente en cours, les 5 cibles faibles "
             "les plus partagées, et les 3 exercices qui les travaillent",
     "why":"C'est la seule chose que l'animatrice demande vraiment : par quoi je commence "
           "la séance."},
    {"id":"lesson-preview","title":"Voir une leçon",
     "shows":"n'importe quelle leçon en lecture seule, avec l'audio — pour préparer la séance",
     "note":"Aucune progression n'est enregistrée en mode animatrice."},
  ],
  "guardrails":["Aucune donnée ne quitte le téléphone.",
                "Aucun classement, aucune moyenne de groupe affichée aux apprenantes.",
                "L'animatrice ne peut pas modifier la progression d'une apprenante, "
                "seulement la consulter — sauf « recommencer », qui demande confirmation."],
})
print("\nPack 3 written to", OUT)
