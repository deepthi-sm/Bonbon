#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Pack 2 generator — La Banque d'Exercices.
The book contains no exercises at all. Everything here is NEW, generated from
Pack 1's decodability ledger so that no item can ever use a letter, grapheme or
syllable the learner has not met.
"""
import json, pathlib

BASE = pathlib.Path(__file__).parent
OUT = BASE / '02-exercices'; OUT.mkdir(exist_ok=True)
CORPUS = BASE / '01-corpus'

def w(name, obj):
    (OUT / name).write_text(json.dumps(obj, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'{name:34s} {len(json.dumps(obj, ensure_ascii=False)):>8,d} bytes')

ledger = {r["lessonId"]: r for r in json.load(open(CORPUS/'decodability.json'))["ledger"]}
lessons = json.load(open(CORPUS/'lesson-index.json'))["lessons"]
syll = json.load(open(CORPUS/'syllabary.json'))["syllables"]

# ─────────────────────────────────────────────────────────────────────────
# 1. THE CONFUSION MATRIX  — the pedagogical heart of the pack
# ─────────────────────────────────────────────────────────────────────────
# A distractor that is obviously wrong teaches nothing. A distractor that is
# MINIMALLY different forces the discrimination the lesson is actually about.
VISUAL = {
  "b": ["d","p","h"], "d": ["b","p","q","a"], "p": ["q","b","d"], "q": ["p","g","d"],
  "n": ["u","m","h","r"], "u": ["n","v","y"], "m": ["n","w"], "h": ["n","b","k"],
  "i": ["l","j","í"], "l": ["i","t","f","1"], "j": ["i","g"], "t": ["f","l","+"],
  "f": ["t","l"], "o": ["a","c","e","0"], "a": ["o","e","d"], "c": ["e","o","s"],
  "e": ["c","a","o"], "s": ["z","c","5"], "z": ["s","2"], "v": ["y","u","w"],
  "y": ["v","u","g"], "g": ["q","y","j"], "r": ["n","v"], "k": ["h","x"],
  "é": ["è","ê","e"], "è": ["é","ê","e"], "ê": ["é","è","e"], "e": ["é","è","c"],
  "0": ["o","O","6","9"], "1": ["l","i","7"], "2": ["z","5"], "3": ["8","5"],
  "4": ["9","7"], "5": ["s","2","3"], "6": ["9","0","b"], "7": ["1","4"],
  "8": ["3","0","6"], "9": ["6","4","g"],
}
AUDITORY = {
  # voicing pairs — the classic French minimal contrast
  "p": ["b"], "b": ["p"], "t": ["d"], "d": ["t"], "k": ["g"], "g": ["k"],
  "c": ["g"], "f": ["v"], "v": ["f"], "s": ["z"], "z": ["s"], "j": ["ch"],
  # nasals
  "an": ["on","in","en"], "am": ["om","aim"], "on": ["an","in"], "om": ["on","am"],
  "in": ["an","on","ain"], "ain": ["in","ein","an"], "ein": ["ain","in"], "aim": ["ain","am"],
  "en": ["an","in"], "em": ["am","om"],
  # vowel height / rounding
  "é": ["è","e"], "è": ["é","ê"], "ê": ["è","é"], "e": ["é","eu"],
  "u": ["ou","i"], "ou": ["u","o"], "o": ["ou","au"], "eu": ["e","œu","ou"],
  "œu": ["eu","eur"], "i": ["u","y"],
  # liquids and glides
  "r": ["l"], "l": ["r"], "y": ["i","ill"], "ill": ["ill","y","ail"],
  # complex graphemes taught as equivalences
  "oi": ["oin","ou"], "oin": ["oi","on"], "ien": ["ion","in"], "ion": ["ien","on"],
  "ail": ["eil","aille"], "eil": ["ail","euil"], "euil": ["eil","eu"],
  "ch": ["j","s"], "gn": ["n","ni"], "qu": ["k","c","g"], "ph": ["f","p"],
  "th": ["t","h"], "tion": ["sion","tio"], "ç": ["c","s"],
}
w("confusion-matrix.json", {
  "$comment": "NEW. The rule for choosing a wrong answer. A distractor drawn at random "
              "teaches nothing; a distractor that differs from the target on exactly one "
              "dimension makes the error diagnostic — the app then knows WHICH "
              "discrimination failed and can drill it. `visual` drives tap-identify and "
              "missing-letter; `auditory` drives listen-choose and syllable-build. "
              "Every candidate is filtered against the lesson's decodability set before "
              "it can be used, so a distractor is never a letter she has not met.",
  "rules": [
    "A distractor MUST appear in decodability.json for the item's lesson.",
    "Prefer a confusion-matrix neighbour; fall back to a random decodable item only when the matrix is exhausted.",
    "Never use more than one grapheme-length distractor per item in Unit 1 or 2.",
    "The correct answer's position is drawn from the seeded RNG, never fixed.",
    "Two consecutive items in the same activity may not share a distractor set.",
  ],
  "visual": VISUAL, "auditory": AUDITORY,
  "voicingPairs": [["p","b"],["t","d"],["k","g"],["f","v"],["s","z"],["ch","j"]],
  "nasalTriad": ["an","on","in"],
  "validation": "The auditory sets must be re-checked against the FINAL recordings. "
                "They describe contrasts in the recorded Beninese French of this app, "
                "not in an abstract standard; if the voice does not distinguish a pair, "
                "that pair must be removed rather than drilled.",
})

# ─────────────────────────────────────────────────────────────────────────
# 2. ITEM GENERATORS — one per MVP activity type
# ─────────────────────────────────────────────────────────────────────────
GENERATORS = [
 {"type":"tap-identify","owner":"B","usedIn":["vowel","consonant","grapheme","numeral"],
  "objective":"Reconnaître la forme cible parmi des formes proches.",
  "input":["target glyph","decodability.lettersAvailable","confusion.visual"],
  "rule":"Build a grid of `gridSize` cells. Place `targetCount` instances of the target. "
         "Fill the rest from confusion.visual[target] ∩ decodable, then from decodable at random. "
         "Shuffle with seed = hash(lessonId + itemIndex).",
  "params":{"gridSize":[6,9,12],"targetCount":[2,3],"scriptMix":["print","print+cursive"]},
  "difficultyLadder":[
    {"tier":1,"gridSize":6,"targetCount":2,"distractorSource":"random-decodable"},
    {"tier":2,"gridSize":9,"targetCount":3,"distractorSource":"visual-confusion"},
    {"tier":3,"gridSize":12,"targetCount":3,"distractorSource":"visual-confusion","scriptMix":"print+cursive"}],
  "scoring":{"passThreshold":0.8,"partialCredit":True,"maxAttempts":None},
  "masteryTargets":[{"type":"letter","from":"target"}]},

 {"type":"listen-choose","owner":"B","usedIn":["vowel","consonant","grapheme","numeral"],
  "objective":"Associer un son entendu à sa forme écrite.",
  "input":["audioId of target","confusion.auditory","decodability"],
  "rule":"Play the target clip. Show 3–4 written options: the target plus "
         "confusion.auditory[target] ∩ decodable. If audioService.has(target) is false the "
         "item is SKIPPED at generation time and the bank is short by one — never render a "
         "silent listen item.",
  "params":{"optionCount":[3,4],"replayLimit":None},
  "difficultyLadder":[
    {"tier":1,"optionCount":3,"distractorSource":"random-decodable"},
    {"tier":2,"optionCount":4,"distractorSource":"auditory-confusion"},
    {"tier":3,"optionCount":4,"distractorSource":"auditory-confusion","targetUnit":"word"}],
  "scoring":{"passThreshold":0.75,"partialCredit":False,"maxAttempts":None},
  "masteryTargets":[{"type":"letter|syllable|word","from":"target"}]},

 {"type":"syllable-build","owner":"B","usedIn":["consonant"],
  "objective":"Fusionner consonne + voyelle — le mécanisme central du syllabaire.",
  "input":["syllabary rows for this lesson","decodability"],
  "rule":"Play the target syllable. Present the lesson's consonant plus 4–6 vowel tiles "
         "drawn from the vowels already taught. The learner drags a vowel onto the "
         "consonant. On success play the BLEND clip (c … v … cv), not just the syllable.",
  "params":{"rounds":[4,5,6],"vowelTileCount":[4,6,8]},
  "difficultyLadder":[
    {"tier":1,"rounds":4,"vowelTileCount":4,"showModel":True},
    {"tier":2,"rounds":5,"vowelTileCount":6,"showModel":False},
    {"tier":3,"rounds":6,"vowelTileCount":8,"showModel":False,"audioOnly":True}],
  "scoring":{"passThreshold":0.6,"partialCredit":True,"maxAttempts":None},
  "masteryTargets":[{"type":"syllable","from":"target"}]},

 {"type":"missing-letter","owner":"B","usedIn":["vowel","consonant","grapheme"],
  "objective":"Porter attention à une lettre précise à l'intérieur d'un mot connu.",
  "input":["word from this lesson's word list","confusion.visual + confusion.auditory"],
  "rule":"Blank ONE position in a word already read in this lesson. Offer 4 candidates: the "
         "correct letter plus visual and auditory neighbours ∩ decodable. On a wrong choice, "
         "SPEAK THE WRONG WORD SHE BUILT before speaking the right one — hearing « fa-mine » "
         "when she meant « farine » is the most instructive feedback in the whole app.",
  "params":{"candidateCount":[3,4],"blankPosition":["focus-letter","any"]},
  "difficultyLadder":[
    {"tier":1,"candidateCount":3,"blankPosition":"focus-letter","wordVisibleFirst":True},
    {"tier":2,"candidateCount":4,"blankPosition":"focus-letter","wordVisibleFirst":False},
    {"tier":3,"candidateCount":4,"blankPosition":"any","wordVisibleFirst":False}],
  "scoring":{"passThreshold":0.7,"partialCredit":False,"maxAttempts":None},
  "masteryTargets":[{"type":"word","from":"word"},{"type":"letter","from":"blank"}]},

 {"type":"trace","owner":"B","usedIn":["vowel","consonant","numeral"],
  "objective":"Produire la lettre à la main, dans le bon ordre de tracé.",
  "input":["GlyphSpec from assets/glyphs","trace-rubric.json"],
  "rule":"Ghost the glyph, pulse the start dot, sample the finger, light checkpoints in "
         "order. Score per stroke, then per glyph. Never block progress on a low score.",
  "params":{"glyphCount":[1,2,3],"guideLevel":["ghost+dots","ghost","free"]},
  "difficultyLadder":[
    {"tier":1,"guideLevel":"ghost+dots","toleranceMultiplier":1.4},
    {"tier":2,"guideLevel":"ghost","toleranceMultiplier":1.0},
    {"tier":3,"guideLevel":"free","toleranceMultiplier":0.8}],
  "scoring":{"passThreshold":0.55,"partialCredit":True,"maxAttempts":None},
  "masteryTargets":[{"type":"letter","from":"glyph"}]},
]
w("generators.json", {
  "$comment": "NEW. Items are GENERATED, not hand-written. 67 lessons × 5 types × 5 items "
              "would be 1 675 hand-maintained questions that drift out of sync with the "
              "corpus the first time a word list is corrected. A generator seeded on "
              "(lessonId, itemIndex) is reproducible, CI-testable, and correct by "
              "construction: it physically cannot emit an item using an untaught letter.",
  "seedRule":"seed = fnv1a(lessonId + ':' + activityType + ':' + itemIndex) — same seed, "
             "same item, every device, every run. Never Math.random().",
  "generators": GENERATORS,
})

# ─────────────────────────────────────────────────────────────────────────
# 3. BILAN + CHECKPOINTS + PLACEMENT   (assessment woven through)
# ─────────────────────────────────────────────────────────────────────────
BILAN = {
 "vowel":     {"itemCount":4,"mix":[["tap-identify",2],["listen-choose",1],["trace",1]]},
 "consonant": {"itemCount":5,"mix":[["listen-choose",2],["syllable-build",2],["missing-letter",1]]},
 "grapheme":  {"itemCount":5,"mix":[["listen-choose",2],["missing-letter",2],["comprehension",1]]},
 "numeral":   {"itemCount":4,"mix":[["tap-identify",1],["listen-choose",2],["trace",1]]},
}
w("bilan-blueprints.json", {
  "$comment": "NEW. The end-of-lesson check. Deliberately short, deliberately mixed, and "
              "deliberately NOT a gate: a Bilan below threshold schedules review, it never "
              "locks the next lesson. Locking an adult out of lesson 12 because she scored "
              "0.6 on lesson 11 is how you lose her.",
  "rules":[
    "Items are drawn at tier 2 from the same generators, with a fresh seed.",
    "Every Bilan item must target something introduced in THIS lesson.",
    "Score ≥ 0.7 → « Bien lu ». Score < 0.7 → the weak targets enter the review queue.",
    "Never below 0.7 → still advance. Repetition is the method (§B.5), not gating.",
    "The comprehension item in the grapheme Bilan is omitted when the lesson has no text "
    "(L46, L48, L49, L54) — the blueprint shortens, no special case in code.",
  ],
  "byArchetype": BILAN,
})

CHECKPOINTS = [
 {"id":"CP1","afterUnit":"voyelles","afterLesson":"L07","itemCount":10,
  "coverage":"les 9 graphies de voyelles","mix":[["tap-identify",3],["listen-choose",4],["trace",3]],
  "passRule":"≥ 0.7 → célébration d'unité. < 0.7 → révision proposée, jamais imposée.",
  "celebration":"Unité 1 terminée : tu connais toutes les voyelles."},
 {"id":"CP2","afterUnit":"consonnes","afterLesson":"L24","itemCount":14,
  "coverage":"17 consonnes + un échantillon de 12 syllabes des 131",
  "mix":[["listen-choose",5],["syllable-build",5],["missing-letter",3],["trace",1]],
  "passRule":"≥ 0.7 → célébration. Les cibles faibles alimentent la file de révision.",
  "celebration":"Unité 2 terminée : tu peux lire des syllabes et des phrases courtes."},
 {"id":"CP3a","afterUnit":"graphemes","afterLesson":"L32","itemCount":10,
  "coverage":"leçons 25–32 : les nasales et les premiers digrammes",
  "mix":[["listen-choose",5],["missing-letter",4],["comprehension",1]],
  "passRule":"≥ 0.7","celebration":"Bloc 1 des diphtongues terminé."},
 {"id":"CP3b","afterUnit":"graphemes","afterLesson":"L40","itemCount":10,
  "coverage":"leçons 33–40","mix":[["listen-choose",5],["missing-letter",4],["comprehension",1]],
  "passRule":"≥ 0.7","celebration":"Bloc 2 terminé."},
 {"id":"CP3c","afterUnit":"graphemes","afterLesson":"L48","itemCount":10,
  "coverage":"leçons 41–48 : les lettres à deux sons (g, s, c, ç)",
  "mix":[["listen-choose",6],["missing-letter",3],["comprehension",1]],
  "passRule":"≥ 0.7","celebration":"Bloc 3 terminé : tu sais qu'une lettre peut avoir deux sons."},
 {"id":"CP3d","afterUnit":"graphemes","afterLesson":"L56","itemCount":12,
  "coverage":"leçons 49–56 : groupes consonantiques et textes longs",
  "mix":[["listen-choose",4],["missing-letter",4],["comprehension",4]],
  "passRule":"≥ 0.7","celebration":"Unité 3 terminée : tu lis des textes."},
 {"id":"CP4","afterUnit":"chiffres","afterLesson":"D9","itemCount":10,
  "coverage":"les 10 chiffres, forme et nom",
  "mix":[["tap-identify",3],["listen-choose",4],["trace",3]],
  "passRule":"≥ 0.7","celebration":"Tu connais les chiffres de zéro à neuf."},
]
w("checkpoints.json", {
  "$comment": "NEW. Six checkpoints, not four: Unit 3 is 32 lessons long and a single "
              "checkpoint after L56 would be a wall. The four sub-blocks match the pacing "
              "grouping already in the Parcours (§C.2).",
  "checkpoints": CHECKPOINTS,
})

w("placement-test.json", {
  "$comment": "NEW. The information architecture already offers « J'en connais déjà » at "
              "first run (§C.2) but nothing behind it existed. This is that. It must be "
              "fully spoken, skippable at any point, and it must never tell a learner she "
              "failed — it only chooses a starting point, and « Commencer au début » stays "
              "one tap away on every screen of it.",
  "design":{
    "form":"adaptive ladder, 3 rungs, max 12 items, ~4 minutes",
    "entryPoint":"onboarding step 5",
    "abandonPolicy":"quitting at any point starts her at L01 with no message about the test",
    "resultMessage":"« Tu peux commencer ici. » + the lesson title. Never a score, never a level name.",
  },
  "rungs":[
    {"rung":1,"probes":"voyelles i u o a e é","items":4,"type":"listen-choose",
     "advanceIf":"≥ 3/4","onFail":{"startAt":"L01"}},
    {"rung":2,"probes":"syllabes ta pi mo ne lu ré","items":4,"type":"listen-choose",
     "advanceIf":"≥ 3/4","onFail":{"startAt":"L08","note":"connaît les voyelles, pas la fusion"}},
    {"rung":3,"probes":"graphèmes an ou oi ain ch eu","items":4,"type":"listen-choose",
     "advanceIf":"≥ 3/4","onFail":{"startAt":"L15","note":"fusionne, consonnes incomplètes"},
     "onPass":{"startAt":"L25","note":"prête pour les diphtongues"}},
  ],
  "guardrail":"A placement result NEVER locks earlier lessons. Everything before the entry "
              "point is marked `available`, not `completed` — she can go back, and the "
              "Parcours shows the earlier lessons as open, not as skipped.",
})

# ─────────────────────────────────────────────────────────────────────────
# 4. COMPREHENSION — the layer the book has none of
# ─────────────────────────────────────────────────────────────────────────
w("comprehension.json", {
  "$comment": "NEW and NOT developer-authorable alone. The 28 reading texts carry no "
              "questions, no answer key, no comprehension guidance. This file is the "
              "SYSTEM — taxonomy, answer modes, French templates, authoring workflow — "
              "so that Batonga (or a literacy specialist) can fill 2–3 questions per text "
              "into a fixed shape instead of starting from a blank page. The templates are "
              "worked examples of form, not approved content: every instantiated question "
              "needs Batonga's sign-off before it ships.",
  "taxonomy":[
    {"kind":"littérale","share":"1 par texte, toujours en premier",
     "asks":"Une information écrite en toutes lettres dans le texte.",
     "why":"Vérifie le décodage, pas l'inférence. Une lectrice débutante doit pouvoir "
           "réussir celle-ci en relisant une phrase.",
     "templates":["Qui {verbe} ?","Où va {personnage} ?","Quand {événement} ?",
                  "Qu'est-ce que {personnage} {verbe} ?","Combien de {nom} ?"]},
    {"kind":"lexicale","share":"1 par texte",
     "asks":"Le sens d'un mot du texte, appuyé par une image ou deux choix.",
     "why":"Le vocabulaire béninois du livre (fonio, marigot, canari) est le vocabulaire "
           "de la lectrice : la question doit confirmer le lien mot ↔ chose, pas l'enseigner.",
     "templates":["Dans le texte, « {mot} » veut dire…","Montre {mot}.",
                  "Quel dessin montre « {mot} » ?"]},
    {"kind":"inférentielle","share":"0–1, seulement à partir de la leçon 36",
     "asks":"Quelque chose de vrai dans le texte mais non écrit.",
     "why":"Trop tôt, l'inférence punit une lectrice qui a pourtant bien décodé. "
           "Elle n'apparaît qu'une fois les textes assez longs pour la porter.",
     "templates":["Pourquoi {personnage} {verbe} ?","Comment se sent {personnage} ?",
                  "Que va faire {personnage} après ?"]},
    {"kind":"personnelle","share":"0–1, jamais notée",
     "asks":"Un lien avec sa propre vie. Aucune bonne réponse.",
     "why":"C'est ce qui transforme un exercice de décodage en lecture. Non notée, "
           "sans mauvaise réponse, réponse orale ou par image.",
     "templates":["Et toi, {question} ?","As-tu déjà {verbe} ?","Chez toi, {question} ?"]},
  ],
  "answerModes":[
    {"mode":"image-2","use":"unités 1–2 et tout texte court","desc":"Deux dessins, un seul correct."},
    {"mode":"image-3","use":"à partir de la leçon 30","desc":"Trois dessins."},
    {"mode":"phrase-pick","use":"à partir de la leçon 36",
     "desc":"Trois phrases COURTES tirées du texte ; la lectrice touche la bonne. "
            "Les distracteurs sont d'autres phrases du MÊME texte — jamais des phrases inventées, "
            "qui contiendraient des graphies non enseignées."},
    {"mode":"replay-only","use":"question personnelle","desc":"Pas de réponse à saisir ; "
            "la question est posée à voix haute et la lectrice répond à l'oral ou passe."},
  ],
  "hardRules":[
    "A question may contain no grapheme not taught by its own lesson. Run it through the "
    "same decodability check as the lesson text — comprehension.spec.ts enforces this.",
    "Every question is spoken as well as written. A comprehension question a learner cannot "
    "read is a decoding test wearing a disguise.",
    "Every wrong answer replays the sentence of the text that holds the answer, highlighted.",
    "Max 3 questions per text. The text is the lesson; the questions are the check.",
    "No question about the moral, the author's intent, or the title.",
  ],
  "workedExample":{
    "textId":"T27","title":"Le marché","lessonId":"L27","status":"EXAMPLE — awaiting Batonga",
    "questions":[
      {"id":"T27.q1","kind":"littérale","mode":"image-2",
       "prompt":"Où va-t-elle ?","audioId":"q.T27.q1",
       "options":[{"illustrationId":"ill_marche","correct":True},
                  {"illustrationId":"ill_marigot","correct":False}],
       "onWrong":{"replaySegment":"T27.s01"}},
      {"id":"T27.q2","kind":"lexicale","mode":"image-3",
       "prompt":"Montre le canari.","audioId":"q.T27.q2",
       "options":[{"illustrationId":"ill_canari","correct":True},
                  {"illustrationId":"ill_bassine","correct":False},
                  {"illustrationId":"ill_pot","correct":False}]},
      {"id":"T27.q3","kind":"personnelle","mode":"replay-only",
       "prompt":"Et toi, que achètes-tu au marché ?","audioId":"q.T27.q3","scored":False},
    ]},
  "authoringWorkflow":[
    "1. Dev A exports the 28 texts to docs/textes-a-questionner.md, one page per text.",
    "2. Batonga (or the literacy lead) writes 2–3 questions per text into the fixed shape.",
    "3. Dev B runs tools/validate-comprehension.ts: decodability, spoken-prompt presence, answer-mode legality.",
    "4. Illustrations needed by image-mode answers go on Dev A's illustration backlog.",
    "5. Nothing ships without a named sign-off row in docs/comprehension-signoff.md.",
  ],
})

# ─────────────────────────────────────────────────────────────────────────
# 5. TRACE RUBRIC + REPAIR LADDER
# ─────────────────────────────────────────────────────────────────────────
w("trace-rubric.json", {
  "$comment": "NEW. scoreTrace is a pure function; this file is its parameter set, kept out "
              "of code so it can be tuned from field-test data without a release. "
              "Path-following, never recognition (§J.4).",
  "scoreComponents":[
    {"key":"startProximity","weight":0.20,"desc":"Distance du premier point au point de départ imposé.",
     "pass":"≤ 12 % de la hauteur du glyphe"},
    {"key":"checkpointCoverage","weight":0.35,"desc":"Part des jalons atteints DANS L'ORDRE.",
     "pass":"≥ 80 % des jalons, ordre respecté"},
    {"key":"directionAgreement","weight":0.25,"desc":"Le sens du tracé correspond au sens imposé.",
     "pass":"≥ 75 % des segments dans le bon sens",
     "why":"C'est ce que le livre enseigne réellement : l'ordre et le sens, pas la forme. "
           "Un « t » tracé de bas en haut est faux même s'il ressemble à un t."},
    {"key":"maxDeviation","weight":0.15,"desc":"Écart maximal au trait modèle.",
     "pass":"≤ 18 % de la hauteur"},
    {"key":"strokeCount","weight":0.05,"desc":"Nombre de traits attendu.","pass":"exact"},
  ],
  "stars":[{"stars":1,"min":0.35},{"stars":2,"min":0.55},{"stars":3,"min":0.78}],
  "tolerancesByClass":{
    "vowel-simple":{"note":"i o u a — formes rondes ou droites","toleranceMultiplier":1.0},
    "vowel-accented":{"note":"é è ê — l'accent est un trait à part entière","toleranceMultiplier":1.2,
                      "special":"L'accent compte comme un trait ; il peut être tracé en dernier."},
    "ascender":{"note":"b d f h k l t","toleranceMultiplier":0.95},
    "descender":{"note":"g j p q y","toleranceMultiplier":0.95},
    "uppercase":{"note":"formes majuscules imprimées","toleranceMultiplier":1.1},
    "digit":{"note":"0–9","toleranceMultiplier":1.05,
             "special":"Le livre numérote les traits des chiffres plus précisément que ceux "
                       "des lettres (pp. 89–98) : suivre cette numérotation."},
  },
  "spokenCues":{
    "startWrong":"Commence ici, en haut.",
    "directionWrong":"Descends, ne monte pas.",
    "missedCheckpoint":"Passe bien par le point.",
    "tooFast":"Doucement, suis le trait.",
    "strokeMissing":"Il manque un trait.",
    "good":"C'est bien tracé.",
  },
  "hardRule":"A low trace score NEVER blocks the lesson. After three attempts the app plays "
             "the animated model once more and moves on with « On réessaiera plus tard. »",
})

w("repair-ladder.json", {
  "$comment": "NEW. What happens when she gets it wrong — the single most important UX "
              "surface in a literacy app, and the one the book (which assumes a patient "
              "human beside her) never had to specify. Four rungs, then always forward.",
  "principle":"Une lectrice bloquée abandonne l'application. Il n'existe aucun état d'échec.",
  "ladder":[
    {"attempt":1,"action":"replay-target","spoken":"Écoute encore.",
     "visual":"la bonne réponse n'est PAS montrée","hintCost":0},
    {"attempt":2,"action":"narrow","spoken":"Écoute bien. C'est l'un des deux.",
     "visual":"deux options sont estompées, il en reste deux","hintCost":0.25},
    {"attempt":3,"action":"model","spoken":"Regarde : c'est {réponse}. Écoute : {réponse}.",
     "visual":"la bonne réponse s'illumine, puis l'item est rejoué à vide","hintCost":0.5},
    {"attempt":4,"action":"give-and-go","spoken":"On continue. Tu la reverras.",
     "visual":"la bonne réponse est validée pour elle","hintCost":1.0,
     "sideEffect":"la cible entre dans la file de révision avec strength = 0.15"},
  ],
  "neverDo":["buzzer sonore","croix rouge","vie perdue","chronomètre","score négatif",
             "message qui nomme l'échec","blocage de la leçon suivante"],
  "wrongAnswerFeedback":{
    "rule":"On joue TOUJOURS la bonne réponse. On joue le choix erroné seulement quand "
           "l'entendre est instructif — c'est le cas de missing-letter, où entendre le mot "
           "qu'elle a construit explique l'erreur mieux que n'importe quel message.",
    "byType":{
      "tap-identify":"jouer la lettre correcte","listen-choose":"jouer la cible, puis le choix",
      "syllable-build":"jouer la syllabe construite, puis la cible",
      "missing-letter":"jouer le mot construit, puis le mot correct",
      "trace":"rejouer l'animation du tracé"},
  },
})
print("\nPack 2 written to", OUT)
