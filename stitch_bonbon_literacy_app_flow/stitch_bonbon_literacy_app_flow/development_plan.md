# Syllabaire Batonga → Mobile App

## Engineering & Product Plan for a 4-Developer Team

**Source material:** *Syllabaire Alphanumérique pour les Adolescentes et les Jeunes Femmes*, 2ᵉ édition, Fondation Batonga, printed Q2 2025\. 104 pages. **Document status:** v1.0 — written to be committed as `docs/DEVELOPMENT_PLAN.md` and read on day one by all four developers. **Document language:** English. **App UI language:** French.

### How to read this document

Every claim about educational content is tagged:

| Tag | Meaning |
| :---- | :---- |
| **\[SRC\]** | Directly derived from the PDF. Verifiable on a specific page. |
| **\[ADAPT\]** | A UX/engineering adaptation of something that *is* in the PDF (e.g. a ruled copying line becomes a trace canvas). |
| **\[NEW\]** | A feature I am recommending that has **no basis in the PDF**. Treat as a product proposal requiring Batonga's approval. |
| **\[GAP\]** | Something the PDF does *not* contain. Stated explicitly so nobody invents it. |

---

# A. Executive Summary

## A.1 What the book actually is

The *Syllabaire Alphanumérique* is a **synthetic-phonics primer** (*méthode syllabique*) in French, produced by the Batonga Foundation for adolescent girls and young women in Benin who were excluded from formal schooling. It is not a textbook about French; it is a **decoding machine**. Its entire design rests on one generative idea, stated visually on almost every page from Lesson 8 onward:

> **consonant × vowel → syllable → word → sentence → text**

The book teaches the vowel inventory first (7 lessons), then introduces one consonant at a time and multiplies it against the vowels already known (17 lessons), then teaches complex graphemes and moves the learner into connected reading passages (32 lessons), then teaches the digits 0–9 (11 pages). Reading and handwriting are taught *simultaneously and in two scripts* — every word appears twice on the page, once in print (*écriture scripte*) and once in cursive (*écriture cursive*).

The preface states the purpose plainly: literacy and numeracy as *"un passeport vers la dignité, l'indépendance et l'autonomie économique"* — explicitly connected to running an income-generating activity (AGR), reading an SMS, filling in an order book, and participating in the digital world. The target readers are named: women in Batonga business circles (*cercles d'affaires*) and out-of-school adolescents in leadership clubs.

## A.2 What the app must fundamentally accomplish

The app must **reproduce the book's decoding sequence with fidelity, and add the one thing paper cannot give: sound and immediate feedback.**

Three non-negotiables follow from the source and the audience:

1. **The progression is the product.** A learner must be able to walk lesson 1 → lesson 56 → digits and arrive at the same competence the book targets. We do not reorder, we do not "modernise" the sequence, we do not swap the Beninese vocabulary (*fonio, akassa, igname, marigot, quinquéliba, canari, kapokier*) for generic French.  
2. **Audio is the app's reason to exist.** A syllabaire teaches sound–symbol correspondence. On paper, that requires a literate facilitator to read aloud. In the app, the phone *is* the facilitator. Every letter, syllable, word, sentence and text must be tappable-to-hear. This is the single highest-value transformation.  
3. **It must work with no network, on a cheap Android phone, for someone who cannot read the interface.** The learner is by definition low-literacy at install time. The UI cannot be explained in words — it must be explained in icons, illustrations, and spoken French.

## A.3 Recommended technology (you asked for a recommendation)

**React Native \+ Expo (SDK 54+), TypeScript, expo-router, expo-sqlite, bundled content.**

Specification and justification are in §C.1. Short version: it gives one codebase for Android and iOS, ships all content and audio inside the app binary so the app is fully functional with the radio off, lets you build iOS without owning a Mac (EAS Build), and — critically for a content-heavy app — lets you push corrected lesson text and audio via `expo-updates` without a two-week App Store review. Its file-based router also happens to eliminate the single worst merge-conflict source in a 4-person mobile team (a shared route table).

## A.4 The three honest scope truths

- **Numeracy is thinner than the title promises.** The book is called *alphanumérique* and the preface promises *numératie*, but the delivered numeracy content is **digits 0–9: recognition, French name, and stroke order. Nothing else.** No counting, no arithmetic, no money, no quantity. **\[GAP\]** Building an arithmetic module is a *new product*, not a digitisation. Do not let it into MVP.  
- **The digital-inclusion promise is unfulfilled by the book.** The preface names reading an SMS and keeping an order book as the goal, but **no lesson in the book teaches either.** **\[GAP\]** This is the most compelling V2 module and the clearest place for the team to add original value — but it must be built *with* Batonga, not invented by four developers.  
- **The book contains no exercises.** Every activity in the book is *read aloud*, *copy*, or *trace*. There are no questions, no answers, no quizzes, no comprehension checks. **\[GAP\]** Therefore **every interactive activity in the app is an \[ADAPT\] or \[NEW\]**, and each one needs a stated pedagogical justification, which §J provides.

---

# B. Book → App Analysis

## B.1 Physical structure of the source

| Pages (PDF) | Section | Content |
| :---- | :---- | :---- |
| 1–2 | Cover / title | Photo of two learners with slates showing `A B C D E F` and `0 1 2 3 4 5 6 7 8 9 10 11` |
| 3 | Préface | Signed *La Fondatrice*. States purpose, audience, and the AGR/digital-inclusion goal |
| 4 | Témoignages | Two quotes: a Batonga business-circle member (Bohicon), and the Bénin Country Director |
| 5 | Alphabet reference | 26 letters, "20 consonnes – 6 voyelles"; full alphabet in **script lower, script upper, cursive lower, cursive upper** |
| 6 | Divider | *ÉTUDE DES VOYELLES ET CONSONNES* |
| 7–53 | **Part I — Lessons 1–24** | 24 letter lessons, each \= 1 lesson page \+ 1 *Écriture* page |
| 54 | Divider | *ÉTUDE DES DIPHTONGUES ET TEXTES* |
| 55–87 | **Part II — Lessons 25–56** | 32 grapheme lessons, 1 page each (Lesson 56 spans 2 pages) |
| 88 | *CHIFFRES* | Table: `0 → zéro` … `9 → neuf` |
| 89–98 | **Part III — Digits** | 10 tracing pages, one per digit 0–9 |
| 99–104 | Back matter | Print date, Angélique Kidjo quote, Batonga contact details \+ QR code |

## B.2 Part I — the letter lessons (Lessons 1–24)

### The vowel block (Lessons 1–7) **\[SRC\]**

| \# | Letter(s) | Keyword | Illustration |
| :---- | :---- | :---- | :---- |
| 01 | i / I | un épi | maize ear |
| 02 | u / U | une lune | crescent moon |
| 03 | o / O | un pot | pot |
| 04 | a / A | un ananas | pineapple |
| 05 | e ê / E Ê | une fenêtre | window |
| 06 | é è / É È | une élève | girl writing |
| 07 | y / Y | mes yeux | pair of eyes |

Fixed page anatomy, identical across all seven:

1. Line illustration of the keyword  
2. Keyword written in **print**, then again in **cursive**  
3. The letter in three renderings: **print lowercase, cursive lowercase, print uppercase** (Lessons 5 and 6 show six, because they carry two accented variants each)  
4. Three rows of the letter repeated (print, then cursive) — pure visual saturation  
5. A word list in print containing the letter (`fil, image, canari, farine, rivière, fini, mil`)  
6. **The same word list repeated in cursive**  
7. `Écriture` heading with **stroke-order diagrams**: arrows and a start-dot for each rendering  
8. Ruled writing lines (Seyès-style, with a pink margin) with a model letter at the left  
9. **A full second page** of ruled lines with model letters *and* model words, alternating print and cursive

**Why vowels come first and alone:** they carry no syllable tree, because there is nothing yet to combine them with. The book front-loads the entire vowel inventory (8 vowel sounds: i, u, o, a, e, é, è, ê — plus y) precisely so that from Lesson 8 onward *every* consonant can immediately be multiplied against the full set. This is the load-bearing pedagogical decision in the book, and the app's data model must express it (§I).

### The consonant block (Lessons 8–24) **\[SRC\]**

17 consonants, in this order: **t, p, n, m, r, v, l, d, b, j, f, s, c, g, k, h, z**

| \# | Letter | Keyword | \# | Letter | Keyword | \# | Letter | Keyword |
| :---- | :---- | :---- | :---- | :---- | :---- | :---- | :---- | :---- |
| 08 | t | une tête | 14 | l | un livre | 20 | c | un couteau |
| 09 | p | une pipe | 15 | d | une datte | 21 | g | une guitare |
| 10 | n | un nez | 16 | b | une bassine | 22 | k | un képi |
| 11 | m | une montre | 17 | j | une jupe | 23 | z | un zébu |
| 12 | r | une radio | 18 | f | un feu | 24 | h | une hache |
| 13 | v | un vélo | 19 | s | un sac |  |  |  |

Same anatomy as the vowel lessons, **plus three new blocks**:

- **The syllable tree** — the signature graphic. A consonant on the left, arrows fanning out to each vowel, producing the syllable in **print and cursive**. Usually split into two trees (i/u/o/a and e/é/è/ê) for layout.  
- **A syllable strip** — the same syllables as a flat readable line: `ti, tu, to, ta, te, té, tè, tê`  
- **A sentence block** — two to four very short sentences built *only from letters already taught*: `papa tape toto.` `toto tape paté.` `mémé a une tomate.` `la pile de lili.`

**Documented variations** (the data model must accommodate these; they are not noise):

- **Lesson 8 (t)** and **Lesson 16 (b)** have an extended tree with a **third column of doubled/derived words**, each then repeated in cursive: `ti → tite`, `tu → tutu`, `to → toto`, `ta → tata`, `bi → bibi`, `bé → bébé`, `bè → bèche`, `bê → bête`. Lesson 8's tree also has only **seven** branches (no `tè`) while its syllable strip below lists **eight** — reproduce both as printed.  
- **Lesson 21 (g)** deliberately restricts to `gu, go, ga` only — the soft *g* is withheld until Lesson 43 (`g = j`) and Lesson 44 (`gu`). This is intentional sequencing, not an omission.  
- **Lesson 24 (h)** has **no sentence block** — only syllables and a word list of *h*\-initial words.  
- **Lesson 7 (y)** is placed inside the vowel block and has no tree.

### ⚠️ Content-integrity findings in Part I

| Finding | Detail | Recommended action |
| :---- | :---- | :---- |
| **Lessons 23 and 24 are printed out of order** | PDF p.50 \= *Leçon 24* (h / hache); PDF p.52 \= *Leçon 23* (z / zébu) | Ship them in **numerical** order (23 \= z, 24 \= h). Log the discrepancy for Batonga. |
| **q, w, x are never taught** | The alphabet page claims 20 consonants; only 17 receive lessons. `q` appears only inside `qu` at Lesson 46; `w` and `x` never appear as lesson subjects | **\[GAP\]** Do not invent lessons. The alphabet reference screen shows all 26; the learning path teaches 17 \+ graphemes. Flag to Batonga. |
| **Écriture-page words drift from the lesson-page words** | e.g. Lesson 10 (n) teaches `note, natte, âne, anani, nono, nini` but the écriture page drills `neuf` and `natte`; Lesson 20 (c) écriture drills `conte` and `calcul`, neither on the lesson page | Preserve both lists verbatim as separate fields (`wordList` vs `writingModels`). Do **not** merge them. |

## B.3 Part II — graphemes and reading texts (Lessons 25–56) **\[SRC\]**

32 single-page lessons. Anatomy:

1. The grapheme group as a heading in **three renderings**: print lowercase, cursive lowercase, print uppercase — e.g. `an am en em` / *an am en em* / `AN AM EN EM`  
2. A syllable list (`dan - pan - man - san - van…`)  
3. A word / short-phrase list (`le banc - la jambe - lentement - je danse - le rang`)  
4. **The same lists repeated in cursive**  
5. **A titled reading text** — this is the new element and the section's whole point

| \# | Grapheme(s) | Text title | Text type |
| :---- | :---- | :---- | :---- |
| 25 | an am en em | Les vacances | narrative |
| 26 | on om | La fête | narrative |
| 27 | oin | Le marché | narrative |
| 28 | ien ion | La ferme | narrative |
| 29 | eau au os ot | Mon village | narrative |
| 30 | oi oix oit | Des amis | **dialogue** |
| 31 | ain ein in aim | Mon papa | narrative |
| 32 | ou ouille | La boullie *(sic)* | narrative |
| 33 | ay oy uy | Chaque Samedi | narrative |
| 34 | ail aille | Des conseils | **advice list** |
| 35 | eil eille | Au réveil | **dialogue** |
| 36 | ai ei ais ait | En classe | narrative |
| 37 | et ez ai ed | À l'école | narrative \+ quote |
| 38 | euil euille | Un visiteur | **dialogue** |
| 39 | ill ille | Une pluie surprise | narrative |
| 40 | eu œu | Les conseils | **advice list** |
| 41 | eur eure œur | Les deux sœurs | narrative |
| 42 | oir oire | Une histoire | **dialogue** |
| 43 | g \= j | Le forgeron | narrative |
| 44 | gu | Les mangues | narrative |
| 45 | gn | Un bon repas | narrative |
| 46 | qu \= k \= c | — | **no text** |
| 47 | s \= z | Le magasin | narrative |
| 48 | c \= s, ç \= s | — | **no text** |
| 49 | iez ier ied | — | **no text** |
| 50 | ch | Le domaine | narrative |
| 51 | ph \= f, th \= t | Le photographe | narrative |
| 52 | ac oc ic | Les vacances | narrative |
| 53 | tion \= sion | Les opérations | narrative |
| 54 | bl pl vl fl cl | — | **no text** |
| 55 | ar or | Les préparatifs | narrative |
| 56 | br tr cr pr dr gr vr fr | L'hôpital | narrative (2 pages) |

**28 texts across three sub-types** — narrative (22), dialogue (4), advice list (2). The sub-type matters for rendering: dialogues use `-` speaker turns and must be laid out as turns, not paragraphs; advice lists are bulleted imperatives.

**Cultural grounding is systematic and must be preserved verbatim.** Places: *Kandi, Cotonou, Nikki, Kérou, Gamia, Nord-Bénin*. Foods: *fonio, igname pilée, akassa, karité, quinquéliba, bouillie, mangue, arachide*. Life: *le marigot, le marché, la case, le pagne, le boubou, la fête de ramadan, le forgeron, le margouillat*. Names: *Baké, Samira, Dossou, Ignace, Bio, Konaté, Kadidia, Orou, Gildas, Gédéon, Victoire, Flore, Rose, Marguerite, Hugues*.

This is not decoration. A learner in Bohicon recognises *un margouillat* on her roof. Replacing it with *un lézard* would break the book. **This vocabulary is protected content — see §O.5.**

**Economic-life vocabulary threads through the texts**, matching the preface's AGR goal: *la vendeuse, le marchand, un acheteur, le magasin, la banque, le client, l'étalage, vendre, acheter, les opérations, l'addition, la soustraction, la multiplication, la division*. Worth surfacing as a filterable vocabulary theme **\[ADAPT\]**.

### ⚠️ Content-integrity findings in Part II

- **Typographic and grammatical slips** in the source: `La boullie` (should be *bouillie*); `la gardien` (Lesson 21, should be *le gardien*); `un met` (Lesson 37, should be *mets*); `retoune` (Lesson 26, should be *retourne*); Lesson 40's cursive line drops the word after `un` where `un vœu` is expected; `Bl` is capitalised inconsistently in Lesson 54's heading.  
- **Lesson 49 appears twice** in the PDF render (p.79 duplicated). Ship once.  
- **Recommendation:** build an `errata.json` listing every deviation with page reference. Ship the **source text verbatim by default**; apply corrections only behind a flag, and only after Batonga signs off. A literacy primer's authority depends on it matching the printed book the facilitator is holding.

## B.4 Part III — the digits **\[SRC\]**

- **One reference page**: `0 → zéro`, `1 → un`, `2 → deux`, `3 → trois`, `4 → quatre`, `5 → cinq`, `6 → six`, `7 → sept`, `8 → huit`, `9 → neuf`  
- **Ten tracing pages**, one per digit, each with: a large outlined numeral with **numbered stroke-order arrows** (a richer stroke notation than the letter pages use), then ruled lines with the digit × 8, the word in print × 3, and the word in cursive × 2

**The digits are the most gamification-ready content in the book** — a closed set of 10, each with a name, a shape, and a stroke order, and no reading prerequisite. **\[SRC\]** confirms only recognition, naming, and writing. Counting objects, comparing quantities, and arithmetic are **\[GAP\]/\[NEW\]**.

## B.5 The pedagogical model, extracted

| Dimension | What the book does |
| :---- | :---- |
| **Method** | Synthetic phonics / syllabic. Bottom-up: sound → syllable → word → sentence → text. |
| **Difficulty curve** | Four gears. (1) Vowels in isolation. (2) One consonant at a time × known vowels; sentences appear at Lesson 8 and stay ≤ 6 words until \~Lesson 20\. (3) Complex graphemes \+ paragraph-length texts. (4) Digits, deliberately parked at the end. |
| **How lessons build** | Strictly cumulative. Lesson 9's sentence `papa tape toto` reuses only t, p, o, a from Lessons 1–9. The word `tomate` in Lesson 11 is only legible because t, m, o, a are all taught. **Sequence integrity is a functional requirement, not a preference.** |
| **Repetition** | Extreme and deliberate — 3 rows of the letter, list in print, list again in cursive, models on the écriture page. Repetition *is* the method for adult beginners. |
| **Reading ↔ writing** | Fully parallel. Never "read now, write later." Every letter lesson pairs decoding with stroke-order production, in two scripts. |
| **Vocabulary** | Contextual, Beninese, and increasingly economic. |
| **Comprehension** | Implicit only. Texts are for decoding practice; the book asks no questions about them. **\[GAP\]** |
| **Assessment** | None. No tests, no self-check, no answer key. **\[GAP\]** |
| **Facilitator role** | Assumed but never documented. The book presumes someone reads aloud and corrects handwriting. **The app must absorb that role.** |

## B.6 What must remain faithful vs. what may be redesigned

| Must stay faithful \[SRC\] | Safe to redesign \[ADAPT\] |
| :---- | :---- |
| Lesson order 1 → 56, then digits | Page layout and pagination |
| Which letter/grapheme belongs to which lesson | How repetition is delivered (tap-drills instead of static rows) |
| Word lists and reading texts, verbatim | Navigation, progress display, encouragement |
| The dual print/cursive presentation of every item | Which script is *default*, with the other one tap-toggled |
| Stroke order and direction | Ruled Seyès lines → responsive trace canvas |
| Keyword \+ illustration pairings | Illustration re-drawing as SVG (same subject, cleaner vector) |
| Beninese cultural vocabulary | Adding audio, feedback, timing, scoring |
| Digits limited to 0–9 | Adding a digit-recognition game |

---

# C. Complete App Architecture

## C.1 Technology stack — recommendation and specification

You asked for a recommendation for an **offline app that runs on both Android and iOS**. Here it is, with the reasoning, because the team will have to defend it.

### Recommended stack

| Layer | Choice | Why this one |
| :---- | :---- | :---- |
| Framework | **React Native via Expo, SDK 54+** | One codebase, both platforms. Managed workflow means no Xcode/Gradle archaeology for a student team. |
| Language | **TypeScript, `strict: true`** | The contracts in §H are only enforceable if the compiler enforces them. This is what makes 4-way parallel work safe. |
| Navigation | **expo-router** (file-based) | **Merge-conflict elimination.** Routes are files on disk, not entries in a shared array. Four developers adding screens touch four different files. This alone is worth the choice. |
| Local database | **expo-sqlite** \+ **Drizzle ORM** | Real SQL, real migrations, real relational queries for progress and review scheduling. AsyncStorage would not survive the mastery model. |
| Content storage | **Bundled JSON \+ assets**, one file per lesson, loaded via `require()` at build time | Zero-network by construction. No first-run download, no "please wait". |
| Audio | **expo-audio** (`expo-av` is deprecated) | Playback, preload, and playlist queueing for sentence-by-sentence reading. |
| Tracing / drawing | **react-native-svg** \+ **react-native-gesture-handler** \+ **react-native-reanimated** | Glyph outlines as SVG paths; gesture sampling on the UI thread so the ink never lags on a cheap phone. |
| Ephemeral state | **Zustand** | Small, no boilerplate, no context-provider merge conflicts. |
| Server state (V2) | **TanStack Query** | Only when sync arrives. Not in MVP. |
| i18n | **i18next** \+ `expo-localization`, namespaced files | French is the only shipped locale in MVP, but strings live outside components from day one. |
| Backend (V2) | **Supabase** (Postgres \+ Auth \+ Storage) or a small **Fastify \+ Postgres** service | See §C.6. Deliberately *not* in MVP. |
| Build & release | **EAS Build \+ EAS Update** | iOS builds without a Mac. **EAS Update lets you ship a corrected `fonio` spelling or a re-recorded audio clip in hours, not in an App Store review cycle.** For a content-heavy literacy app this is a major operational advantage. |
| Testing | **Jest** \+ **@testing-library/react-native**; **Maestro** for E2E flows | Maestro's YAML flows are far more tractable than Detox for a student team. |
| CI | **GitHub Actions** | typecheck → lint → test → content-validate → EAS build on `main`. |

### Why not the alternatives

- **Flutter** is a legitimate choice and slightly better at custom canvas rendering (relevant to cursive tracing). Rejected because: (a) Dart is a second new thing for a team already learning a new domain; (b) Expo's OTA content-update story has no clean Flutter equivalent, and this app's main post-launch churn is *content*, not code; (c) the JS/TS ecosystem is more likely to match the team's existing skills. If your team already knows Dart, invert this decision — the rest of this plan (workstreams, contracts, data model, branch strategy) transfers to Flutter essentially unchanged.  
- **Native Android (Kotlin/Compose)** would give the best low-end performance and the smallest binary, but it is Android-only, which contradicts your requirement.  
- **A PWA** would be the cheapest, but offline audio caching and reliable install on low-end Android is fragile, and app-store presence matters for institutional distribution through Batonga.

### Hard non-functional budgets (agree these in Sprint 0\)

| Budget | Target | Owner |
| :---- | :---- | :---- |
| Install size (Android AAB) | **≤ 60 MB** | Dev D |
| Cold start on Android Go, 2 GB RAM | **≤ 3.0 s to interactive** | Dev D |
| Audio tap → first sound | **≤ 150 ms** (preloaded) | Dev D |
| Trace stroke input latency | **≤ 32 ms** (2 frames) | Dev B |
| Lesson screen scroll | **60 fps** on a 2019 entry-level Android | Dev A |
| Minimum OS | **Android 8.0 / iOS 15** | Dev C |
| Network calls in MVP | **Zero required.** All optional. | All |
| Smallest touch target | **56 × 56 dp** | Dev C |

## C.2 Information architecture

Batonga Lire  (app)

│

├── FIRST RUN

│   ├── Language & voice check        (spoken welcome, big "écouter" button)

│   ├── Create local profile          (first name OR avatar only — no email, no password)

│   └── Placement offer               (« Commencer au début » | « J'en connais déjà »)

│

├── ACCUEIL  (home / dashboard)

│   ├── « Continuer »  → resumes the exact block the learner left

│   ├── Progress ring \+ streak

│   ├── Today's review (V2)

│   └── Entry to the Parcours

│

├── PARCOURS  (the learning path — vertical, scrollable, one node per lesson)

│   │

│   ├── UNITÉ 1 — LES VOYELLES              Lessons 01–07     \[SRC\]

│   ├── UNITÉ 2 — LES CONSONNES             Lessons 08–24     \[SRC\]

│   ├── UNITÉ 3 — DIPHTONGUES ET TEXTES     Lessons 25–56     \[SRC\]

│   │     └── sub-grouped into 4 blocks of 8 for pacing        \[ADAPT\]

│   └── UNITÉ 4 — LES CHIFFRES              Digits 0–9        \[SRC\]

│

├── LEÇON  (the lesson player — one screen, a sequence of blocks)

│   │

│   ├── 1\. Objectif        « Aujourd'hui : la lettre t »        \[ADAPT\]

│   ├── 2\. Découverte      illustration \+ keyword \+ audio        \[SRC\]

│   ├── 3\. Les formes      print / cursive / capital \+ audio     \[SRC\]

│   ├── 4\. Reconnaissance  ACTIVITY: find the letter             \[ADAPT\]

│   ├── 5\. Syllabes        the tree, tappable, each syllable spoken \[SRC\]

│   ├── 6\. Construction    ACTIVITY: build the syllable          \[ADAPT\]

│   ├── 7\. Mots            word list, print ⇄ cursive toggle, audio \[SRC\]

│   ├── 8\. Vocabulaire     ACTIVITY: word ↔ meaning / picture    \[ADAPT\]

│   ├── 9\. Phrases         sentences, tap-to-hear, word-by-word  \[SRC\]

│   ├── 10\. Écriture       stroke animation → guided trace       \[SRC\]→\[ADAPT\]

│   ├── 11\. Lecture        (Unit 3 only) the full text           \[SRC\]

│   └── 12\. Bilan          3–5 mixed questions, then celebration \[ADAPT\]

│

├── ENTRAÎNEMENT  (practice — free, no progression, low stakes)

│   ├── Revoir une leçon

│   ├── Le mur des lettres   (alphabet reference, p.5 of the book) \[SRC\]

│   ├── Les chiffres

│   └── Cahier d'écriture    (free trace canvas)

│

├── MES PROGRÈS

│   ├── Path completion, letters mastered, words heard

│   ├── Streak calendar

│   └── Badges                                                    \[NEW\]

│

└── RÉGLAGES

    ├── Voice speed (normal / lent)

    ├── Default script (scripte / cursive)

    ├── Text size

    ├── Audio download manager (V2)

    ├── Profile / reset progress

    └── About Batonga

**Deliberately absent from MVP:** login, social features, leaderboards, chat, ads, in-app purchase, share sheets. Each would add risk and none serves the learner.

## C.3 Module map

                        ┌──────────────────────────────┐

                        │      APP SHELL  (Dev C)      │

                        │  router · theme · a11y · i18n│

                        └───────────────┬──────────────┘

                                        │ renders

        ┌───────────────────────────────┼───────────────────────────────┐

        │                               │                               │

┌───────▼────────┐            ┌─────────▼─────────┐          ┌──────────▼─────────┐

│ LESSON ENGINE  │            │  ACTIVITY ENGINE  │          │  PROGRESS ENGINE   │

│    (Dev A)     │            │      (Dev B)      │          │      (Dev D)       │

│                │            │                   │          │                    │

│ LessonPlayer   │  lessonId  │ ActivityHost      │  result  │ progressService    │

│ BlockRegistry  ├───────────►│ ActivityRegistry  ├─────────►│ masteryEngine      │

│ 12 renderers   │            │ TraceCanvas       │          │ streaks · badges   │

│ contentRepo    │            │ FeedbackLayer     │          │ reviewQueue        │

└───────┬────────┘            └─────────┬─────────┘          └──────────┬─────────┘

        │                               │                               │

        │ reads                         │ plays                         │ persists

        │                               │                               │

┌───────▼───────────────────────────────▼───────────────────────────────▼─────────┐

│                          PLATFORM SERVICES  (Dev D)                             │

│   audioService  ·  db (SQLite \+ Drizzle)  ·  syncService  ·  telemetry          │

└─────────────────────────────────────────────────────────────────────────────────┘

                                        │

┌───────────────────────────────────────▼─────────────────────────────────────────┐

│              CONTENT PACK  (Dev A owns schema · Dev D owns delivery)            │

│   lessons/\*.json  ·  audio/\*.m4a  ·  glyphs/\*.svg  ·  illustrations/\*.svg       │

└─────────────────────────────────────────────────────────────────────────────────┘

Justified modules, and what we are **not** building:

| Module | In MVP? | Owner | Note |
| :---- | :---- | :---- | :---- |
| Content model \+ validation | ✅ | A | The spine |
| Lesson rendering engine | ✅ | A | 12 block renderers |
| Activity engine | ✅ | B | 5 activity types in MVP |
| Handwriting / tracing | ✅ (print only) | B | Path-following, **not** ML recognition |
| Audio playback | ✅ | D | Bundled clips |
| Local DB \+ progress | ✅ | D | SQLite |
| Navigation \+ shell | ✅ | C | expo-router |
| Design system \+ a11y | ✅ | C | Low-literacy-first |
| Offline support | ✅ | D | By construction — nothing to "support" |
| Gamification | ✅ light: streak \+ completion. Badges V2 | D |  |
| Assessment | ✅ light: end-of-lesson *Bilan* \+ unit checkpoint | B |  |
| **Authentication** | ❌ | — | No learner needs an account to read. V2, only if facilitator dashboards are funded. |
| **Backend / API** | ❌ MVP | D | Contract designed in MVP, implemented V2 |
| **CMS** | ❌ | — | Content is authored as JSON in the repo. A CMS for 4 devs and one fixed book is over-engineering. |
| **Push notifications** | ❌ MVP | C | Local reminders only in V2; push needs a server |
| **Speech recognition** | ❌ | — | Future. See §Q risk R-07. |

## C.4 Offline strategy

The app is **offline by construction, not by fallback**:

- All 56 lessons, all 10 digit pages, all glyph SVGs, all illustrations, and all audio ship **inside the binary**. Estimated total ≈ 25–35 MB (see §C.5).  
- SQLite is the only writeable store. Every user action writes locally and returns immediately. Nothing in the UI ever waits on a network call.  
- **Every write also appends a row to `sync_outbox`** from day one, even though nothing drains it in MVP. This is a \~30-line investment that makes V2 sync a feature instead of a rewrite. Dev D owns it.  
- Online capabilities, when they arrive, are strictly *additive*: outbox drain, content pack update, optional facilitator reporting. If the network never appears, the learner never notices.

## C.5 Asset budget

| Asset class | Count | Format | Est. size |
| :---- | :---- | :---- | :---- |
| Illustrations (keywords) | 24 | SVG (line art re-drawn from the book) | \~250 KB |
| Glyph outlines (print \+ digits, with stroke paths) | 62 | SVG paths in one JSON | \~180 KB |
| Glyph outlines (cursive, V2) | 52 | SVG | \~200 KB |
| Fonts (print, cursive, UI) | 3 families | TTF subset | \~1.5 MB |
| **Audio clips** | **≈ 1 200** | AAC 64 kbps mono | **≈ 15–20 MB** |
| Lesson JSON | 67 files | JSON | \~600 KB |
| **Total content** |  |  | **≈ 20–25 MB** |

At that size, a "download lesson packs" feature is unnecessary complexity. **Bundle everything.** Revisit only if audio exceeds 35 MB.

## C.6 The online layer (designed now, built in V2)

You said offline-first **with online capabilities**. Concretely, that means three things — none of which the learner depends on:

1. **Progress sync** — the outbox drains to a server when a network appears, so a learner can change phone or a facilitator can see cohort progress. Requires the lightest possible identity: a device-generated `learnerId` UUID plus an optional 6-digit **code de reprise** the learner can write down. **Do not build email/password.** A low-literacy learner cannot type an email address, and asking her to is a dignity failure, not just a UX one.  
2. **Content updates** — corrected text or re-recorded audio delivered via EAS Update (code \+ JSON) or a signed content-pack fetch (audio). Versioned by `contentPackVersion`.  
3. **Facilitator reporting** — a web view for Batonga staff showing cohort completion. This is a *separate deliverable* and should not consume mobile-team capacity in the first release.

**Recommended V2 backend:** Supabase. Postgres, row-level security, storage for audio packs, and anonymous auth out of the box — roughly a week of Dev D's time versus a month for a hand-rolled service.

---

# D. Four-Developer Work Allocation

## D.1 The slicing principle

The work is sliced **vertically by capability**, not horizontally by layer. Every developer owns data \+ logic \+ UI in their domain, so that:

- nobody is "the backend person" waiting for someone to design a screen,  
- nobody is "the UI person" blocked on someone else's API,  
- every stream produces something demonstrable on a phone by the end of week 2,  
- and every stream is independently testable.

## D.2 Allocation table

| Developer | Branch | Primary responsibility | Major features | Main deliverables |
| :---- | :---- | :---- | :---- | :---- |
| **Dev A** | `dev/content-engine` | **Content & Lesson Engine** — the digital representation of the book and the machinery that renders it | Content schema & validator · lesson authoring pipeline · `LessonPlayer` · 12 block renderers · script/cursive typography · illustration & glyph asset pipeline · transcription of all 56 lessons | `@core/content` types · `contentRepository` · `<LessonPlayer/>` · 67 validated lesson JSON files · `validate-content` CLI · errata register |
| **Dev B** | `dev/activities` | **Interactive Activities, Writing & Assessment** — everything the learner *does* | `ActivityHost` · 5 MVP activity types · guided **trace canvas** \+ stroke scoring · feedback & correction UX · *Bilan* end-of-lesson check · unit checkpoint · activity generation from content | `<ActivityHost/>` · `ActivityResult` contract · `<TraceCanvas/>` \+ scoring lib · activity generator · assessment rules |
| **Dev C** | `dev/shell-ux` | **App Shell, Navigation & Design System** — everything around the lesson, and how it all looks | Onboarding · local profile · Accueil · Parcours map · Entraînement · Réglages · design tokens & UI primitives · accessibility · French i18n · low-literacy UX patterns | expo-router route tree · `@ui` component library · `theme.ts` · `fr` locale files · a11y checklist \+ audit · UX pattern guide |
| **Dev D** | `dev/data-audio` | **Data, Progress, Audio & Platform** — the layer everything stands on | SQLite schema \+ migrations · repositories · progress & mastery engine · streaks · `audioService` \+ preloading · **audio production pipeline & manifest** · sync outbox \+ V2 sync client · CI, EAS, perf budgets | `@core/db` \+ migrations · `progressService` · `audioService` · `audio-manifest.json` \+ recording kit · `sync_outbox` · CI pipeline · perf report |

## D.3 Balance check

|  | Dev A | Dev B | Dev C | Dev D |
| :---- | :---- | :---- | :---- | :---- |
| Screens owned | 1 (the player, 12 blocks) | 6 activity surfaces \+ trace | 9 screens | 3 screens \+ settings panels |
| Algorithmic difficulty | Medium | **High** (stroke scoring) | Low–Medium | **High** (mastery, sync, perf) |
| Data-entry volume | **High** (56 lessons transcribed) | Low | Medium (strings) | **High** (1 200 audio clips managed) |
| External dependencies | Illustration redraw | — | Font licensing | Voice talent, EAS account |
| Blocks others if late | **Yes** — content schema | No | **Yes** — theme \+ primitives | **Yes** — DB schema \+ audio IDs |

Deliberately, the two "blocks others" risks (A's schema, C's primitives, D's schema) are **all resolved in Sprint 0**, before independent work begins. See §R.

---

# E. Detailed Branch Ownership

Branches are named by **domain, not by person**, so that when these four students hand the project on, `dev/content-engine` still means something. Ownership is recorded in `CODEOWNERS`, where names are cheap to change.

## E.1 `dev/content-engine` — Developer A

**Purpose.** Turn a 104-page printed book into validated, typed, renderable data — and render it faithfully.

**Owns (exclusive write access):**

src/core/content/          schema, types, repository, loaders

src/features/lesson/       LessonPlayer, block renderers, player state

content/lessons/           L01.json … L56.json, D0.json … D9.json, alphabet.json

content/schema/            JSON Schema definitions

content/errata.json        documented deviations from the printed book

assets/illustrations/      24 keyword SVGs

assets/glyphs/             stroke-path SVGs (shape data; B owns the tracing behaviour)

tools/validate-content.ts  the CLI that CI runs

docs/content-authoring.md

**Exposes:**

// src/core/content/index.ts  — the public surface, frozen after Sprint 0

export type { Lesson, LessonBlock, Unit, VocabularyItem, ReadingText, Grapheme };

export const contentRepository: {

  getUnits(): Unit\[\];

  getLesson(id: LessonId): Lesson;

  getLessonsByUnit(unitId: UnitId): LessonSummary\[\];

  getVocabulary(filter?: VocabFilter): VocabularyItem\[\];

  getNextLesson(after: LessonId): LessonId | null;

};

// src/features/lesson/LessonPlayer.tsx

export function LessonPlayer(props: {

  lessonId: LessonId;

  startAtBlock?: number;

  onBlockComplete(blockIndex: number): void;

  onLessonComplete(summary: LessonSummary): void;

  onRequestActivity(spec: ActivitySpec): void;   // hands control to Dev B

});

**Depends on:** `@ui` primitives from C (mockable), `audioService` from D (stub returns a resolved promise), `ActivityHost` from B (stub renders a "Continuer" button).

**Deliverables:** all 67 content files transcribed and validated; 12 working block renderers; the validator wired into CI; a Storybook-style `/dev/blocks` screen showing every block type with fixture data.

**Definition of done:** every lesson in the book renders end-to-end from JSON with zero hardcoded lesson content anywhere in `src/`; `npm run validate-content` passes; a native French speaker has proof-read all 56 lessons against the PDF and signed off in `docs/transcription-signoff.md`.

## E.2 `dev/activities` — Developer B

**Purpose.** Everything the learner does with her fingers, and everything that tells her whether she got it right.

**Owns:**

src/features/activity/         ActivityHost, registry, per-type components

src/features/activity/types/   tap-identify, listen-choose, syllable-build,

                               missing-letter, word-match  (+ V2 types)

src/features/writing/          TraceCanvas, stroke sampler, scoring

src/core/scoring/              pure scoring functions (heavily unit-tested)

src/features/assessment/       Bilan, unit checkpoint, result summary

docs/activity-catalogue.md

**Exposes:**

export function ActivityHost(props: {

  spec: ActivitySpec;

  onComplete(result: ActivityResult): void;

  onSkip(reason: 'user' | 'timeout'): void;

});

export function TraceCanvas(props: {

  glyph: GlyphSpec;            // paths \+ stroke order, from A's assets

  mode: 'demo' | 'guided' | 'free';

  onStrokeComplete(s: StrokeResult): void;

  onComplete(r: TraceResult): void;

});

export function scoreTrace(expected: GlyphSpec, actual: Point\[\]\[\]): TraceResult; // pure

**Depends on:** `ActivitySpec` and `GlyphSpec` types from A (frozen Sprint 0); `@ui` from C; `audioService` from D.

**Deliverables:** 5 MVP activity types, each with fixture-driven tests; the trace canvas working for all 62 print glyphs \+ digits; `scoreTrace` with ≥ 90 % unit-test coverage; a `/dev/activities` gallery screen.

**Definition of done:** every activity type is playable from a fixture without the rest of the app; scoring is deterministic and covered by tests; feedback is delivered in **audio \+ colour \+ icon simultaneously** (never colour alone — see §P); a learner can always advance past a failed attempt.

## E.3 `dev/shell-ux` — Developer C

**Purpose.** Make the app navigable and usable by someone who cannot read the interface — and give the other three a design system so they stop inventing buttons.

**Owns:**

app/                       ALL expo-router route files

src/ui/                    Button, Card, Icon, ProgressRing, Sheet, ListRow…

src/ui/theme.ts            colour, spacing, radius, type scale, motion tokens

src/features/onboarding/

src/features/home/         Accueil

src/features/path/         Parcours map

src/features/practice/     Entraînement

src/features/settings/     Réglages

src/features/profile/

src/i18n/                  fr/\*.json  (one namespace per feature)

assets/fonts/

docs/ux-principles.md · docs/a11y-checklist.md

**Exposes:**

export { Button, IconButton, Card, ListRow, ProgressRing, Sheet, Toast } from '@ui';

export { theme, useTheme } from '@ui/theme';

export const nav: {

  toLesson(id: LessonId, opts?: { block?: number }): void;

  toPath(unitId?: UnitId): void;

  toHome(): void;

  toPractice(kind: PracticeKind): void;

};

**Depends on:** `progressService` from D for the Parcours node states (mockable with a fixture); `contentRepository` from A for the unit/lesson list (mockable).

**Deliverables:** every route file present and navigable with placeholder bodies **by end of Sprint 1** (this is what unblocks everyone); the `@ui` library with all primitives; French strings for all chrome; an accessibility audit against the checklist; the UX principle guide in §K.1.

**Definition of done:** the full navigation graph is walkable on a device with no lesson content loaded; every interactive element is ≥ 56 dp and has a spoken label; the app is usable at 200 % font scale; contrast ≥ 4.5:1 everywhere; screen-reader labels present in French.

## E.4 `dev/data-audio` — Developer D

**Purpose.** The floor the other three stand on: persistence, progress, sound, and shipping.

**Owns:**

src/core/db/               schema.ts, client, migrations/, repositories/

src/core/progress/         progressService, masteryEngine, streaks, reviewQueue

src/core/audio/            audioService, preloader, cache, manifest loader

src/core/sync/             outbox, syncClient (V2), conflict rules

src/core/telemetry/        local-only event log (no third-party analytics)

content/audio/             the 1 200 clips \+ audio-manifest.json

tools/audio-pipeline/      normalise, encode, verify-manifest scripts

.github/workflows/         CI

eas.json · app.config.ts

docs/audio-production.md · docs/data-model.md

**Exposes:**

export const audioService: {

  play(id: AudioId, opts?: { rate?: 'normal' | 'slow' }): Promise\<void\>;

  playSequence(ids: AudioId\[\], gapMs?: number): Promise\<void\>;

  stop(): void;

  preload(ids: AudioId\[\]): Promise\<void\>;

  has(id: AudioId): boolean;               // false → caller shows no speaker icon

};

export const progressService: {

  recordActivityResult(r: ActivityResult): Promise\<void\>;

  recordBlockComplete(lessonId: LessonId, blockIndex: number): Promise\<void\>;

  completeLesson(lessonId: LessonId, summary: LessonSummary): Promise\<LessonOutcome\>;

  getLessonState(lessonId: LessonId): Promise\<LessonState\>;

  getPathState(): Promise\<PathState\>;      // what C's Parcours renders

  getResumePoint(): Promise\<ResumePoint | null\>;

  getStreak(): Promise\<StreakState\>;

};

**Depends on:** `ActivityResult` from B and `LessonId`/`AudioId` from A — both frozen in Sprint 0\. Nothing else.

**Deliverables:** the schema with migrations; all repositories; the mastery engine with unit tests; `audioService` working against real clips; **the audio manifest and recording kit** (script, naming convention, technical spec) delivered to the voice talent by end of Sprint 2; CI green; a perf report against the §C.1 budgets on a real low-end device.

**Definition of done:** all four budgets in §C.1 measured and met on physical hardware; migrations run forward cleanly from an empty DB and from the previous released version; `audioService.has()` returns correctly for every ID referenced in content (CI-checked cross-reference); the sync outbox records every mutation even though nothing drains it.

## E.5 What no branch may do

| Rule | Reason |
| :---- | :---- |
| No branch other than `dev/shell-ux` may add a file under `app/` | Route ownership |
| No branch may edit `src/ui/theme.ts` | Design tokens are additive-only, by C, on request |
| No branch other than `dev/data-audio` may write SQL or add a migration | Schema integrity |
| No branch may hardcode a lesson's text, word list, or sentence in a component | The entire architecture depends on this |
| No branch may add a dependency to `package.json` without the Build Steward (§O.2) | Lockfile conflicts |
| No branch may edit `src/core/contracts/**` without a PR approved by **two** other devs | These are the interfaces |
| No branch may commit `.env` | Secrets |
| No branch may edit another's `content/` or `assets/` files | Content ownership |

---

# F. Repository Structure

Single repository. Not a monorepo — four students do not need Turborepo, and workspace tooling would cost more than it saves.

batonga-lire/

│

├── app/                                    ◆ C  (expo-router — file \= route)

│   ├── \_layout.tsx                         ◆ C  ⚠ shared: see §O.4

│   ├── index.tsx                              Accueil

│   ├── onboarding/\[step\].tsx

│   ├── parcours/index.tsx

│   ├── parcours/\[unitId\].tsx

│   ├── lecon/\[lessonId\].tsx                   thin wrapper → \<LessonPlayer/\>

│   ├── entrainement/index.tsx

│   ├── entrainement/alphabet.tsx

│   ├── entrainement/chiffres.tsx

│   ├── entrainement/cahier.tsx

│   ├── progres/index.tsx

│   ├── reglages/index.tsx

│   └── dev/                                   internal galleries (dev builds only)

│       ├── blocks.tsx                      ◆ A

│       ├── activities.tsx                  ◆ B

│       └── audio.tsx                       ◆ D

│

├── src/

│   ├── core/

│   │   ├── contracts/                      ◆ SHARED — 2 approvals to change

│   │   │   ├── ids.ts                         LessonId, AudioId, GlyphId, UnitId…

│   │   │   ├── content.ts                     Lesson, LessonBlock, Unit…

│   │   │   ├── activity.ts                    ActivitySpec, ActivityResult

│   │   │   ├── progress.ts                    LessonState, PathState, Mastery

│   │   │   └── events.ts                      cross-module event names

│   │   │

│   │   ├── content/                        ◆ A   repository, loaders, selectors

│   │   ├── scoring/                        ◆ B   pure trace/answer scoring

│   │   ├── db/                             ◆ D   schema, client, migrations/

│   │   ├── progress/                       ◆ D   progressService, mastery, streaks

│   │   ├── audio/                          ◆ D   audioService, preloader

│   │   ├── sync/                           ◆ D   outbox, syncClient (V2)

│   │   └── telemetry/                      ◆ D

│   │

│   ├── features/

│   │   ├── lesson/                         ◆ A

│   │   │   ├── LessonPlayer.tsx

│   │   │   ├── blockRegistry.ts            ⚠ append-only, alphabetical

│   │   │   └── blocks/                        one file per block type

│   │   ├── activity/                       ◆ B

│   │   │   ├── ActivityHost.tsx

│   │   │   ├── activityRegistry.ts         ⚠ append-only, alphabetical

│   │   │   └── types/                         one file per activity type

│   │   ├── writing/                        ◆ B   TraceCanvas \+ sampler

│   │   ├── assessment/                     ◆ B

│   │   ├── onboarding/  home/  path/       ◆ C

│   │   ├── practice/  settings/  profile/  ◆ C

│   │   └── progressview/                   ◆ D   the Mes Progrès screen body

│   │

│   ├── ui/                                 ◆ C   design system

│   │   ├── theme.ts                        ⚠ additive only, C writes

│   │   ├── Button.tsx  Card.tsx  Icon.tsx  ProgressRing.tsx  …

│   │   └── icons/

│   │

│   ├── i18n/                               ◆ C

│   │   ├── index.ts

│   │   └── fr/  common.json · lesson.json · activity.json · settings.json

│   │            (one namespace per feature — never one giant fr.json)

│   │

│   └── utils/                              ◆ shared, small, pure, no cross-imports

│

├── content/                                ◆ A owns lessons; D owns audio

│   ├── schema/            lesson.schema.json  ◆ A

│   ├── lessons/           L01.json … L56.json  ◆ A   one file per lesson

│   ├── digits/            D0.json … D9.json    ◆ A

│   ├── alphabet.json                            ◆ A

│   ├── errata.json                              ◆ A

│   ├── manifest.json                            ⚠ GENERATED — never hand-edit

│   └── audio/

│       ├── audio-manifest.json                  ◆ D

│       └── clips/                               ◆ D  (git-lfs)

│

├── assets/

│   ├── illustrations/     24 SVGs               ◆ A

│   ├── glyphs/            stroke paths          ◆ A (shape) / B (behaviour)

│   └── fonts/                                   ◆ C

│

├── tools/

│   ├── validate-content.ts                      ◆ A

│   ├── generate-manifest.ts                     ◆ A

│   └── audio-pipeline/                          ◆ D

│

├── docs/

│   ├── DEVELOPMENT\_PLAN.md      ← this file

│   ├── content-authoring.md     ◆ A

│   ├── activity-catalogue.md    ◆ B

│   ├── ux-principles.md         ◆ C

│   ├── a11y-checklist.md        ◆ C

│   ├── data-model.md            ◆ D

│   ├── audio-production.md      ◆ D

│   └── adr/                     ◆ shared — architecture decision records

│

├── .github/

│   ├── CODEOWNERS               ⚠ shared

│   ├── pull\_request\_template.md

│   └── workflows/ci.yml         ◆ D

│

├── app.config.ts   eas.json     ◆ D

├── package.json                 ⚠ Build Steward only

├── tsconfig.json                ⚠ 2 approvals

└── .gitattributes  .gitignore  .env.example

**Legend:** ◆ \= single owner · ⚠ \= shared/protected file, see §O.

### `.github/CODEOWNERS`

\# Default: any change needs a review from someone

\*                               @dev-a @dev-b @dev-c @dev-d

/app/                           @dev-c

/src/ui/                        @dev-c

/src/i18n/                      @dev-c

/src/features/onboarding/       @dev-c

/src/features/home/             @dev-c

/src/features/path/             @dev-c

/src/features/practice/         @dev-c

/src/features/settings/         @dev-c

/src/core/content/              @dev-a

/src/features/lesson/           @dev-a

/content/lessons/               @dev-a

/content/digits/                @dev-a

/content/schema/                @dev-a

/assets/illustrations/          @dev-a

/tools/validate-content.ts      @dev-a

/src/features/activity/         @dev-b

/src/features/writing/          @dev-b

/src/features/assessment/       @dev-b

/src/core/scoring/              @dev-b

/src/core/db/                   @dev-d

/src/core/progress/             @dev-d

/src/core/audio/                @dev-d

/src/core/sync/                 @dev-d

/content/audio/                 @dev-d

/tools/audio-pipeline/          @dev-d

/.github/workflows/             @dev-d

/eas.json                       @dev-d

/app.config.ts                  @dev-d

\# Protected: two approvals required (enforce in branch protection)

/src/core/contracts/            @dev-a @dev-b @dev-c @dev-d

/package.json                   @dev-c @dev-d

/tsconfig.json                  @dev-a @dev-d

/app/\_layout.tsx                @dev-c @dev-d

---

# G. Data Model

Three tiers, and the tier decides where the data lives and who owns it.

| Tier | Where it lives | Mutable at runtime? | Owner |
| :---- | :---- | :---- | :---- |
| **Static educational content** | Bundled JSON, loaded read-only | No | **A** (audio manifest: D) |
| **Learner data** | SQLite on device | Yes | **D** |
| **App configuration** | SQLite `settings` \+ build-time constants | Yes (settings) | **C** (values) / **D** (storage) |

## G.1 Static content entities — owner: Dev A

### `ContentPack`

| Field | Type | Purpose |
| :---- | :---- | :---- |
| `version` | `string` (semver) | Compared against DB `content_version` to trigger migrations |
| `sourceEdition` | `string` | `"Batonga Syllabaire 2e éd., T2 2025"` — provenance, shown in About |
| `locale` | `'fr'` |  |
| `units` | `Unit[]` |  |

### `Unit`

| Field | Type | Notes |
| :---- | :---- | :---- |
| `id` | `UnitId` | `'voyelles' | 'consonnes' | 'graphemes' | 'chiffres'` |
| `order` | `number` | 1–4 |
| `title` / `subtitle` | `string` | French, learner-facing |
| `lessonIds` | `LessonId[]` | ordered |
| `iconId` | `string` |  |
| `sourcePages` | `[number, number]` | Traceability back to the book |

### `Lesson` — the central entity

| Field | Type | Notes |
| :---- | :---- | :---- |
| `id` | `LessonId` | `'L01'…'L56'`, `'D0'…'D9'` |
| `unitId` | `UnitId` |  |
| `order` | `number` | **Never reorder. §B.5.** |
| `archetype` | `LessonArchetype` | `'vowel' | 'consonant' | 'grapheme' | 'numeral' | 'reference'` |
| `title` | `string` | `"Leçon 08 — la lettre t"` |
| `focus` | `Focus` | `{ kind:'letter'|'grapheme'|'digit', glyphs: string[] }` |
| `objective` | `string` | **\[ADAPT\]** — written by the team; the book states none |
| `prerequisiteIds` | `LessonId[]` | Encodes cumulative decoding (§B.5) |
| `blocks` | `LessonBlock[]` | **The lesson is its block sequence.** §I |
| `sourcePages` | `number[]` |  |
| `errata` | `ErratumRef[]` | Links to `errata.json` |

### `LessonBlock` — discriminated union, 12 members

| `type` | Payload (abridged) | From |
| :---- | :---- | :---- |
| `keyword-illustration` | `{ illustrationId, wordPrint, wordCursive, audioId }` | \[SRC\] |
| `letter-forms` | `{ forms: GlyphRef[] }` — print lower/upper, cursive lower/upper, accented | \[SRC\] |
| `letter-repetition` | `{ glyphId, rows, script }` | \[SRC\] |
| `syllable-tree` | `{ consonant, branches: {vowel, syllablePrint, syllableCursive, derived?[], audioId}[] }` | \[SRC\] |
| `syllable-strip` | `{ syllables: SyllableRef[] }` | \[SRC\] |
| `word-list` | `{ items: VocabularyItemRef[], showCursive: boolean }` | \[SRC\] |
| `sentence-list` | `{ sentences: SentenceRef[] }` | \[SRC\] |
| `grapheme-heading` | `{ graphemes: string[], renderings: Script[] }` | \[SRC\] |
| `reading-text` | `{ textId }` | \[SRC\] |
| `stroke-diagram` | `{ glyphId, strokes: StrokePath[] }` | \[SRC\] |
| `writing-practice` | `{ models: WritingModel[], script }` | \[SRC\] → \[ADAPT\] |
| `activity` | `{ spec: ActivitySpec }` | \[ADAPT\] |

### `VocabularyItem`

| Field | Type | Notes |
| :---- | :---- | :---- |
| `id` | `VocabId` | e.g. `'v_fonio'` |
| `print` / `cursive` | `string` | Cursive is normally the same string rendered in the cursive font; the field exists because the book occasionally differs |
| `article` | `string | null` | `un / une / le / la` — the book teaches words with articles |
| `syllables` | `string[]` | Decoding support **\[ADAPT\]** |
| `audioId` | `AudioId | null` |  |
| `illustrationId` | `string | null` | Only 24 words have illustrations |
| `themes` | `string[]` | `['commerce','maison','nourriture','école']` **\[ADAPT\]** |
| `firstLessonId` | `LessonId` | Where it is introduced |

### `ReadingText`

| Field | Type | Notes |
| :---- | :---- | :---- |
| `id` | `TextId` |  |
| `title` | `string` | `"Le marché"` |
| `kind` | `'narrative' | 'dialogue' | 'advice-list'` | Drives layout — §B.3 |
| `segments` | `TextSegment[]` | Sentence-level, each with `audioId` and optional `speaker` |
| `lessonId` | `LessonId` |  |
| `wordCount` | `number` | For pacing |

### `Glyph`

| Field | Type | Notes |
| :---- | :---- | :---- |
| `id` | `GlyphId` | `'t_print_lower'`, `'8_numeral'` |
| `char` / `script` / `case` |  |  |
| `outlinePath` | `string` | SVG path for display |
| `strokes` | `StrokePath[]` | Ordered; each has `d`, `startPoint`, `direction`, `checkpoints[]`. **This is what makes tracing possible.** |
| `sourcePage` | `number` |  |

### `AudioAsset` — owner: Dev D

| Field | Type | Notes |
| :---- | :---- | :---- |
| `id` | `AudioId` | Deterministic: `letter.t.sound`, `syll.ta`, `word.fonio`, `sent.L09.02`, `text.L27.s04`, `digit.7.name` |
| `file` | `string` | Path under `content/audio/clips/` |
| `durationMs` / `speaker` / `recordedAt` |  |  |
| `status` | `'recorded' | 'placeholder' | 'missing'` | **Lets the app degrade gracefully: no clip → no speaker icon, never a broken button.** |

## G.2 Learner data entities — owner: Dev D

### `Learner`

`id` (UUID, device-generated) · `displayName` · `avatarId` · `createdAt` · `resumeCode` (6 digits, V2) · `preferredScript` · `voiceRate` **No email. No password. No phone number.** §C.6.

### `LessonState`

`learnerId` \+ `lessonId` (PK) · `status` (`locked|available|in_progress|completed`) · `lastBlockIndex` · `startedAt` · `completedAt` · `completionCount` · `bestScore`

### `ActivityAttempt`

`id` · `learnerId` · `lessonId` · `activityId` · `activityType` · `isCorrect` · `score` (0–1) · `durationMs` · `hintsUsed` · `attemptNumber` · `createdAt` Written by D on every `ActivityResult` from B. The raw substrate for mastery.

### `TraceAttempt`

`id` · `learnerId` · `glyphId` · `score` · `strokeScores` (JSON) · `strokeCount` · `durationMs` · `createdAt` Separate from `ActivityAttempt` because its metrics are different in kind and because handwriting progress deserves its own view.

### `MasteryRecord`

`learnerId` \+ `targetType` (`letter|syllable|word|grapheme|digit`) \+ `targetId` (PK) · `strength` (0–1) · `exposures` · `correctCount` · `lastSeenAt` · `nextReviewAt` (V2) **Why it exists:** the app must be able to say "she can read *ta* but not *tê*". A per-lesson percentage cannot express that, and the review queue in V2 depends on it.

### `Achievement` · `StreakLog` · `Session` · `SyncOutbox`

`Achievement`: `learnerId` \+ `achievementId` · `unlockedAt` · `seen` — **\[NEW\]** `StreakLog`: `learnerId` \+ `date` (PK) · `minutesActive` · `lessonsCompleted` `Session`: `id` · `startedAt` · `endedAt` · `lessonsTouched` — for pacing analytics, local only `SyncOutbox`: `id` · `entity` · `entityId` · `op` · `payload` (JSON) · `createdAt` · `syncedAt` (null until drained) — **written in MVP, drained in V2**

## G.3 Configuration

`AppSettings` (SQLite, single row): `preferredScript`, `voiceRate`, `textScale`, `hapticsEnabled`, `reminderTime`, `contentPackVersion`, `onboardingCompleted` `FeatureFlags` (build-time constants, D owns): `cursiveTracing`, `syncEnabled`, `comprehensionQuestions`, `badges` — every V2 feature lands behind a flag, off by default, so `dev/*` branches can merge unfinished work into `develop` safely.

## G.4 Relationship diagram

ContentPack 1─┬─\* Unit 1─\* Lesson 1─\* LessonBlock

              │                │

              │                ├─\* VocabularyItem \*─1 AudioAsset

              │                ├─0..1 ReadingText 1─\* TextSegment \*─1 AudioAsset

              │                └─\* Glyph 1─\* StrokePath

              │

Learner 1─┬─\* LessonState        \*─1 Lesson

          ├─\* ActivityAttempt    \*─1 Lesson

          ├─\* TraceAttempt       \*─1 Glyph

          ├─\* MasteryRecord      → targets letters/syllables/words/digits

          ├─\* Achievement

          ├─\* StreakLog

          └─\* SyncOutbox

---

# H. Module Interfaces

These live in `src/core/contracts/`. **They are written and frozen in Sprint 0, before feature code exists.** Everything in §M depends on this being true.

## H.1 The interface rules

1. Contracts are **types and function signatures only** — no implementation, no imports from feature code.  
2. A contract change needs a PR with **two approvals from other stream owners** and a note in `docs/adr/`.  
3. Every consumer of another stream's module must be able to swap in a **fixture implementation**. Each owner ships `__fixtures__/` alongside the real thing in Sprint 1\.  
4. Modules communicate through **calls and callbacks**, never by reaching into each other's state.

## H.2 A → B : Lesson Engine hands off to Activity Engine

The single most important interface in the app.

// contracts/activity.ts   (owner of the file: shared; drafted by B)

export type ActivitySpec \= {

  id: string;                       // stable, e.g. 'L08.a1'

  type: ActivityType;               // registry key

  lessonId: LessonId;

  prompt: { text: string; audioId: AudioId | null };

  payload: unknown;                 // narrowed by \`type\`

  scoring: { passThreshold: number; maxAttempts: number | null };

  allowSkip: boolean;               // MUST be true in MVP — see §J.3

};

export type ActivityResult \= {

  activityId: string;

  activityType: ActivityType;

  lessonId: LessonId;

  outcome: 'correct' | 'incorrect' | 'partial' | 'skipped';

  score: number;                    // 0..1

  attempts: number;

  hintsUsed: number;

  durationMs: number;

  targets: MasteryTarget\[\];         // what this attempt is evidence about

  detail?: Record\<string, unknown\>; // type-specific; never read by A or D

};

export type MasteryTarget \= {

  type: 'letter' | 'syllable' | 'word' | 'grapheme' | 'digit';

  id: string;

  correct: boolean;

};

**Behaviour contract**

- A renders `<ActivityHost spec onComplete onSkip/>` and **must not** inspect `payload`.  
- B **must** call exactly one of `onComplete` or `onSkip`, exactly once.  
- B **must not** call `progressService` itself — the result flows A → D. One writer, one path.  
- Every activity is skippable in MVP. A learner who cannot pass an activity must never be trapped.

**Error handling.** Malformed `payload` → B renders a neutral "Continuer" card, logs a telemetry warning, and calls `onSkip('user')`. **A content bug must never crash a lesson.** CI's content validator is what prevents this reaching production.

## H.3 A/B → D : recording progress

progressService.recordActivityResult(result: ActivityResult): Promise\<void\>

- Idempotent on `activityId + attemptNumber`.  
- Writes `ActivityAttempt`, updates `MasteryRecord` for each `target`, appends to `SyncOutbox`.  
- **Never throws to the caller.** DB failure is logged and swallowed; a broken disk must not stop a lesson. Returns a resolved promise regardless.

progressService.completeLesson(id, summary): Promise\<LessonOutcome\>

// LessonOutcome \= { unlockedLessonIds, newAchievements, streak, isFirstCompletion }

A calls this once at the end of a lesson; the returned `LessonOutcome` is what the celebration screen renders. **A does not compute unlocking** — D owns progression rules, because they depend on mastery data A cannot see.

## H.4 C → A : launching a lesson

C's route `app/lecon/[lessonId].tsx` is a **thin wrapper only**:

export default function LessonRoute() {

  const { lessonId } \= useLocalSearchParams\<{ lessonId: LessonId }\>();

  const resume \= useResumePoint(lessonId);              // D

  return (

    \<LessonPlayer                                        {/\* A \*/}

      lessonId={lessonId}

      startAtBlock={resume?.blockIndex}

      onBlockComplete={(i) \=\> progressService.recordBlockComplete(lessonId, i)}

      onLessonComplete={(s) \=\> { progressService.completeLesson(lessonId, s); nav.toPath(); }}

    /\>

  );

}

C never imports a block renderer. A never imports a route. This is the seam.

## H.5 D → C : what the Parcours renders

type PathState \= {

  units: Array\<{

    unitId: UnitId;

    completedCount: number; totalCount: number;

    nodes: Array\<{

      lessonId: LessonId;

      status: 'locked' | 'available' | 'in\_progress' | 'completed';

      score: number | null;

      isNext: boolean;                 // exactly one node app-wide

    }\>;

  }\>;

  resume: ResumePoint | null;

};

C renders `PathState` and nothing else. **C contains no progression logic** — no "if lesson 7 done then unlock 8" anywhere in the shell.

## H.6 Everyone → D : audio

audioService.play(id, { rate }): Promise\<void\>

audioService.has(id): boolean

**The `has()` rule:** any component about to render a speaker icon calls `has()` first. If the clip is not there yet, the icon is not rendered. This is what lets Dev A, B and C build every screen in weeks 1–8 while Dev D is still in the recording studio — **no stream is ever blocked on audio.**

## H.7 B → A : glyph data for tracing

type GlyphSpec \= {

  id: GlyphId; char: string;

  script: 'print' | 'cursive'; case: 'lower' | 'upper' | 'digit';

  viewBox: \[number, number, number, number\];

  outlinePath: string;

  strokes: Array\<{

    order: number; d: string;

    startPoint: \[number, number\];

    direction: 'down'|'up'|'left'|'right'|'cw'|'ccw';

    checkpoints: Array\<\[number, number\]\>;   // ≥ 6, evenly spaced — B scores against these

  }\>;

};

A produces the data (from the book's arrow diagrams); B consumes it and owns all scoring. **A never writes scoring code; B never edits an SVG.**

## H.8 Event bus (deliberately minimal)

One typed emitter in `contracts/events.ts` for genuinely cross-cutting facts only: `lesson:completed` · `achievement:unlocked` · `content:updated` · `audio:missing` Anything else goes through a direct call. An event bus is a merge-conflict magnet and a debugging tax; keep it tiny.

---

# I. Lesson Architecture

## I.1 The decision: data-driven templates, not hardcoded screens

**Recommendation: option B — a reusable, data-driven lesson engine. Emphatically.**

The reasoning is arithmetic before it is architectural:

- The book contains **67 learner-facing lesson units** (24 letter lessons \+ 32 grapheme lessons \+ 10 digit pages \+ 1 alphabet reference) across **\~90 pages**.  
- Those 67 units use **exactly 5 layout archetypes** and **12 distinct content-block types**.  
- The consonant lessons (8–24) are **structurally identical to one another** — 17 instances of one template with different data. The grapheme lessons (25–56) are **32 instances of a second template**. The digit pages are **10 instances of a third**.

Hardcoding would mean **67 screens averaging \~200 lines \= \~13 000 lines of near-duplicate JSX**, in which a change to how word lists show cursive requires 56 edits and a typo fix requires finding the right file among 67\. It would also make the content un-reviewable: Batonga cannot proof-read TSX.

The data-driven engine instead gives:

- **\~12 renderers ≈ 1 200 lines of code, once.** A layout improvement lands everywhere at once.  
- **Content reviewable by non-programmers.** A French-speaking reviewer reads JSON, not JSX.  
- **CI-verifiable content.** `validate-content` can assert that every `audioId` exists, every `prerequisiteId` is a real earlier lesson, every glyph referenced has stroke data, and no lesson uses a letter not yet taught. **That last check mechanically enforces the book's cumulative decoding rule** (§B.5) — a guarantee that is simply impossible with hardcoded screens.  
- **Clean 4-way parallelism.** A builds renderers against fixtures while transcription proceeds independently; B builds activities against fixtures; neither waits.  
- **A V2 CMS becomes possible** without rewriting the app.

**The one legitimate objection** is that a few pages have quirks (Lesson 8/16's extended trees, Lesson 21's restricted tree, Lesson 24's missing sentences, Lesson 56's two-page spread). These are handled by *optional fields in the block payloads*, not by escaping to bespoke screens. If a genuine one-off ever appears, the `activity` block type can host a custom component — an escape hatch that has so far proved unnecessary.

## I.2 The five archetypes

### Archetype 1 — `vowel` (Lessons 1–7)

objective → keyword-illustration → letter-forms → letter-repetition

→ \[activity: tap-identify\] → word-list → \[activity: listen-choose\]

→ stroke-diagram → writing-practice → \[activity: trace\] → bilan

### Archetype 2 — `consonant` (Lessons 8–24)

objective → keyword-illustration → letter-forms → letter-repetition

→ \[activity: tap-identify\]

→ syllable-tree → syllable-strip → \[activity: syllable-build\]

→ word-list → \[activity: missing-letter\]

→ sentence-list → \[activity: word-match\]

→ stroke-diagram → writing-practice → \[activity: trace\]

→ bilan

### Archetype 3 — `grapheme` (Lessons 25–56)

objective → grapheme-heading → syllable-strip → \[activity: listen-choose\]

→ word-list → \[activity: missing-letter\]

→ reading-text            ← the centrepiece; tap any sentence to hear it

→ \[activity: word-match on text vocabulary\]

→ bilan

Lessons 46, 48, 49, 54 simply omit `reading-text` — the array is shorter. No code branch, no special case.

### Archetype 4 — `numeral` (Digits 0–9)

objective → numeral-card (digit \+ French word \+ audio)

→ \[activity: tap-identify digit\] → \[activity: listen-choose digit\]

→ stroke-diagram → writing-practice → \[activity: trace\] → bilan

### Archetype 5 — `reference` (the alphabet wall, book p.5)

grapheme-heading (all 26\) → letter-forms grid (4 scripts) — free browsing, no bilan

## I.3 A worked example — Lesson 08

Abridged, to show the shape. The full file lives at `content/lessons/L08.json`.

{

  "id": "L08",

  "unitId": "consonnes",

  "order": 8,

  "archetype": "consonant",

  "title": "Leçon 08 — la lettre t",

  "focus": { "kind": "letter", "glyphs": \["t", "T"\] },

  "objective": "Reconnaître, entendre et écrire la lettre t, et lire les syllabes en t.",

  "prerequisiteIds": \["L01","L02","L03","L04","L05","L06"\],

  "sourcePages": \[20, 21\],

  "blocks": \[

    { "type": "keyword-illustration",

      "illustrationId": "ill\_tete", "wordPrint": "une tête",

      "wordCursive": "une tête", "audioId": "word.tete" },

    { "type": "letter-forms",

      "forms": \[

        { "glyphId": "t\_print\_lower",  "audioId": "letter.t.sound" },

        { "glyphId": "t\_cursive\_lower","audioId": "letter.t.sound" },

        { "glyphId": "T\_print\_upper",  "audioId": "letter.t.name"  }

      \]},

    { "type": "letter-repetition", "glyphId": "t\_print\_lower", "rows": 2, "script": "print" },

    { "type": "activity",

      "spec": { "id": "L08.a1", "type": "tap-identify", "lessonId": "L08",

                "prompt": { "text": "Touche la lettre t", "audioId": "prompt.touche.t" },

                "payload": { "target": "t", "distractors": \["i","o","u","a","e"\], "gridSize": 6 },

                "scoring": { "passThreshold": 0.8, "maxAttempts": null },

                "allowSkip": true }},

    // NOTE — fidelity detail: the printed tree on p.20 has SEVEN branches

    // (no "tè"), while the syllable strip below it lists EIGHT syllables

    // (including "tè"). We reproduce both exactly as printed rather than

    // "tidying" the tree. \`derived\` holds the third column of the printed

    // tree; the fourth column is the same word in cursive, so it is a

    // rendering concern, not extra data.

    { "type": "syllable-tree",

      "consonant": "t",

      "branches": \[

        { "vowel": "i", "syllablePrint": "ti", "derived": \["tite"\], "audioId": "syll.ti" },

        { "vowel": "u", "syllablePrint": "tu", "derived": \["tutu"\], "audioId": "syll.tu" },

        { "vowel": "o", "syllablePrint": "to", "derived": \["toto"\], "audioId": "syll.to" },

        { "vowel": "a", "syllablePrint": "ta", "derived": \["tata"\], "audioId": "syll.ta" },

        { "vowel": "e", "syllablePrint": "te", "derived": \["tate"\], "audioId": "syll.te" },

        { "vowel": "é", "syllablePrint": "té", "derived": \["taté"\], "audioId": "syll.te\_acute" },

        { "vowel": "ê", "syllablePrint": "tê", "derived": \["tête"\], "audioId": "syll.te\_circ" }

      \]},

    { "type": "syllable-strip",

      "syllables": \["ti","tu","to","ta","te","té","tè","tê"\] },

    { "type": "activity",

      "spec": { "id": "L08.a2", "type": "syllable-build", "lessonId": "L08",

                "prompt": { "text": "Écoute et construis la syllabe", "audioId": "prompt.construis" },

                "payload": { "consonants": \["t"\], "vowels": \["i","u","o","a","e","é","è","ê"\],

                             "rounds": 5 },

                "scoring": { "passThreshold": 0.6, "maxAttempts": null }, "allowSkip": true }},

    { "type": "word-list", "showCursive": true,

      "items": \["v\_tete","v\_toto","v\_tate","v\_ote","v\_tata","v\_tetu"\] },

    { "type": "sentence-list",

      "sentences": \[

        { "id": "L08.s1", "text": "toto tâte ta tête.",  "audioId": "sent.L08.01" },

        { "id": "L08.s2", "text": "toto as-tu ta tête ?","audioId": "sent.L08.02" },

        { "id": "L08.s3", "text": "tata est têtu.",       "audioId": "sent.L08.03" },

        { "id": "L08.s4", "text": "tata ôte ta tête.",    "audioId": "sent.L08.04" }

      \]},

    { "type": "stroke-diagram", "glyphId": "t\_print\_lower" },

    { "type": "writing-practice",

      "script": "print",

      "models": \[

        { "glyphId": "t\_print\_lower" }, { "glyphId": "T\_print\_upper" },

        { "word": "tête" }

      \]},

    { "type": "activity",

      "spec": { "id": "L08.a3", "type": "trace", "lessonId": "L08",

                "prompt": { "text": "Écris la lettre t", "audioId": "prompt.ecris.t" },

                "payload": { "glyphIds": \["t\_print\_lower","T\_print\_upper"\] },

                "scoring": { "passThreshold": 0.55, "maxAttempts": null }, "allowSkip": true }}

  \]

}

Note what this buys: the *derived* syllables of Lesson 8 (`tite`, `tili`) are an optional array, and Lesson 21's restricted `g` tree is just three branches instead of eight. **No template forks.**

## I.4 Faithfulness rules enforced by the validator

`npm run validate-content` fails the build if any of these break:

1. Every `audioId` referenced exists in `audio-manifest.json` (as recorded **or** placeholder).  
2. Every `glyphId` exists and carries ≥ 1 stroke path.  
3. Every `VocabularyItem` referenced is defined.  
4. **No lesson uses a letter or grapheme not introduced in that lesson or an earlier one** — the cumulative-decoding guarantee.  
5. `order` values are unique and contiguous within a unit.  
6. Every `prerequisiteId` points to a lesson with a lower `order`.  
7. Every lesson declares `sourcePages`.  
8. Every deviation from the printed text is registered in `errata.json` with a page number.

---

# J. Activity Mapping

Reminder from §A.4: **the book contains no exercises.** Its activities are read-aloud, copy, and trace. Every interaction below is therefore an adaptation or an addition, and each is justified against what the page is actually trying to teach.

## J.1 The mapping table

| \# | Source element (page) | Learning objective | Digital interaction | Diff. | Feedback | Data required | Dev | Tag |
| :---- | :---- | :---- | :---- | :---- | :---- | :---- | :---- | :---- |
| 1 | Keyword \+ illustration, e.g. *un épi* (p.7) | Anchor the sound in a known object | Illustration \+ word; **tap anywhere to hear it**; tap the word to hear it segmented | 1 | Audio only; nothing to get wrong | illustration, word, audio | A | \[ADAPT\] |
| 2 | Letter in 3–6 renderings (p.7) | Recognise the same letter across scripts and cases | Cards for each rendering; tap \= hear the sound; **toggle scripte ⇄ cursive** | 1 | Audio | glyphs, audio | A | \[ADAPT\] |
| 3 | Three rows of the repeated letter (p.7) | Visual saturation | **Tap-to-identify**: a 6-cell grid of letters, find every *t*. Replaces passive rows with active search | 1 | Correct → green \+ chime \+ spoken letter; wrong → grey shake \+ spoken correct letter, no penalty | target \+ distractors from taught letters | B | \[ADAPT\] |
| 4 | Syllable tree (p.20) | **The core mechanic**: consonant \+ vowel \= syllable | Animated tree; tap a vowel → the arrow draws, the syllable appears in both scripts, the audio plays. Then **syllable-build**: hear `ta`, drag `t` \+ `a` together | 2 | Blend audio on success (`t`…`a`…`ta`); on error, play the two candidate syllables side by side | tree branches, syllable audio | A (display) / B (build) | \[SRC\] display, \[ADAPT\] activity |
| 5 | Syllable strip (p.20) | Fluent syllable reading | Tap any syllable to hear; **"Lire tout"** plays the strip in sequence with each syllable highlighted | 2 | Audio | syllables, audio | A | \[ADAPT\] |
| 6 | Word list, print \+ cursive (p.20) | Read whole words from known syllables | List with a script toggle; tap a word → hear it; **long-press → hear it syllable by syllable** | 2 | Audio | vocab items, syllabification | A | \[ADAPT\] |
| 7 | Word list (as practice) | Retrieve the word from its sound | **Listen-and-choose**: hear a word, pick it from 3–4 written options | 2 | Correct → the word is spoken and highlighted; wrong → both words spoken so she hears the contrast | vocab \+ audio | B | \[ADAPT\] |
| 8 | Word list (as practice) | Attend to individual letters inside a word | **Missing letter**: `fa_ine` with a keypad of 4 candidates | 3 | The completed word is spoken; wrong letters produce the *wrong* word spoken aloud — the most instructive error feedback available | vocab, target index | B | \[ADAPT\] |
| 9 | Illustrated keywords (24 across the book) | Word ↔ meaning | **Word-match**: pair 4 words with 4 pictures | 2 | Per-pair audio | the 24 illustrated items only | B | \[ADAPT\] |
| 10 | Sentences, e.g. *papa tape toto.* (p.22) | Read a connected string | Sentence shown; tap \= full reading; **tap a single word \= that word**; "mot à mot" mode highlights each word as it is spoken | 3 | Audio | sentences, word-level timing (or per-word clips) | A | \[ADAPT\] |
| 11 | Sentences (as practice) | Rebuild syntax | **Sentence-build**: hear the sentence, drag its word tiles into order | 4 | Reading of the assembled attempt — she hears her own word order | sentence tokens | B | \[ADAPT\], **V2** |
| 12 | Stroke-order arrows (p.6, 20\) | Learn the motor path | **Animated stroke demo**: the pen traces the glyph at learner-controlled speed, replayable | 2 | None; demonstration | glyph strokes | A | \[ADAPT\] |
| 13 | Ruled writing lines (p.7, 21\) | Produce the letter by hand | **Guided trace**: the glyph is ghosted, a start dot pulses, the finger draws, ink follows, checkpoints light up | 3 | Per-stroke: ✓/retry with a spoken cue ("commence en haut"); per-glyph: a 3-star score | glyph paths \+ checkpoints | B | \[SRC\]→\[ADAPT\] |
| 14 | Écriture-page word models, e.g. *image*, *maman* (p.7, 27\) | Write whole words | **Word trace**: same canvas, chained glyphs, wider tolerance | 4 | Per-letter feedback, word-level score | writing models | B | \[ADAPT\] |
| 15 | Grapheme heading, e.g. *an am en em* (p.55) | Recognise a multi-letter sound unit | Heading in three renderings; tap \= hear the sound | 2 | Audio | grapheme, audio | A | \[ADAPT\] |
| 16 | Grapheme word list (p.55) | Spot the grapheme inside real words | **Grapheme hunt**: the word is displayed, tap the part that makes the sound | 3 | The grapheme lights up and is spoken in isolation, then the whole word | vocab \+ grapheme span offsets | B | \[ADAPT\] |
| 17 | Reading text, e.g. *Le marché* (p.57) | **Read continuous prose** | Text laid out sentence by sentence; **tap a sentence \= hear it**; "Écouter tout" auto-scrolls with highlighting; a **"J'ai lu"** button per sentence | 4 | Audio \+ per-sentence completion ticks | text segments \+ per-sentence audio | A | \[ADAPT\] |
| 18 | Reading text (dialogue: *Des amis*, *Au réveil*, *Un visiteur*, *Une histoire*) | Read turn-taking speech | Speaker-bubble layout with two voices in the recording | 4 | Audio | text kind \= dialogue, speaker tags | A | \[ADAPT\] |
| 19 | Reading text (advice list: *Des conseils*, *Les conseils*) | Read imperatives | Checklist layout, each line tappable | 3 | Audio | text kind \= advice-list | A | \[ADAPT\] |
| 20 | Reading text | Understand, not just decode | **Comprehension check**: 2 questions per text (« Où va-t-elle ? ») with picture or short-text answers | 5 | Spoken explanation, replay of the relevant sentence | **questions do not exist in the book — must be written and validated by Batonga** | B | **\[NEW\]** |
| 21 | `CHIFFRES` table (p.88) | Digit ↔ French name | Grid 0–9; tap \= hear; **digit-match**: `7` ↔ *sept* | 1 | Audio | digit, word, audio | A/B | \[ADAPT\] |
| 22 | Digit tracing pages (p.89–98) | Write the digit | Same trace canvas, using the book's numbered stroke order | 2 | Per-stroke | digit glyph strokes | B | \[SRC\]→\[ADAPT\] |
| 23 | Alphabet page (p.5) | Reference | **Le mur des lettres**: a browsable 26-letter wall, 4 renderings each, always available, no progression | 1 | Audio | alphabet.json | C shell / A content | \[ADAPT\] |
| 24 | — | Retention over weeks | **Spaced review**: a daily queue drawn from weak `MasteryRecord` rows | var. | Standard | mastery data | D queue / B rendering | **\[NEW\]**, V2 |
| 25 | — | Practical literacy the preface promises | **Module « Lire un SMS » / « Mon carnet »** — read a short message, write an order line | 5 | — | **entirely new content; requires Batonga curriculum input** | team | **\[NEW\]**, V2 |

## J.2 The five MVP activity types

Everything else waits. These five cover every archetype and every unit:

| Type | Key | Used in | Owner |
| :---- | :---- | :---- | :---- |
| Tap to identify | `tap-identify` | letters, graphemes, digits | B |
| Listen and choose | `listen-choose` | letters, syllables, words, digits | B |
| Build the syllable | `syllable-build` | consonant lessons | B |
| Missing letter | `missing-letter` | words in all units | B |
| Guided trace | `trace` | letters, digits (print only in MVP) | B |

`word-match` is a stretch goal for MVP — it is limited to the 24 illustrated words, so it can only appear in a handful of lessons anyway.

## J.3 Feedback design (applies to every activity)

1. **Never colour alone.** Every judgement is delivered simultaneously as **sound \+ icon \+ colour \+ motion**. A learner may be colour-blind; more relevantly, she may not know that green means yes.  
2. **Errors teach.** A wrong answer plays the *correct* item, then optionally the chosen one, so the learner hears the contrast. No buzzer, no red X, no life lost.  
3. **No timers, no penalties, no streak-breaking on failure.** Adult beginners returning to learning after exclusion do not need time pressure. The streak counts *days she opened the app*, not days she got things right.  
4. **Always a way forward.** `allowSkip: true` on every MVP activity. Being stuck is the most common reason an adult learner abandons an app.  
5. **Praise is specific and spoken.** "Tu as lu six mots" beats a confetti burst — though a small one is fine too.

## J.4 On handwriting recognition — an explicit recommendation

**Do not build handwriting recognition.** No ML model, no on-device classifier, no cloud OCR.

Build **stroke-path following** instead: the expected glyph carries an ordered set of stroke paths with checkpoints (§H.7); the canvas samples the finger; `scoreTrace` checks start-point proximity, ordered checkpoint coverage, direction agreement, and maximum deviation from the path.

Why this is the right call:

- It is a **pure, testable function** (`scoreTrace`) that a student developer can get right in two weeks, versus an ML pipeline that could consume the entire project.  
- It matches what the book actually teaches. The pages drill **stroke order and direction**, not letter shape in the abstract. A recogniser that accepts a *t* drawn bottom-up would be pedagogically wrong even though it is "correct".  
- It works offline with no model, no download, no inference cost on a 2 GB phone.  
- Feedback is *actionable*: "start at the top" is useful; "82 % confidence this is a t" is not.

**Cursive tracing is V2.** Cursive glyphs are multi-stroke, connected, and roughly four times the authoring and tolerance-tuning work of print. Cursive **display** remains in MVP throughout — the book's dual-script presentation is preserved visually from day one. This is the single biggest honest scope cut in this plan, and it is the right one.

## J.5 Gamification — what is justified, and what is not

**Justified by the audience and the source:**

- **Path progression with visible unlocking** — mirrors the book's linear, cumulative structure. \[ADAPT\]  
- **Per-lesson completion and a 3-star trace score** — the book's own repetition rows imply "do it until it's good". \[ADAPT\]  
- **A day streak based on attendance, not accuracy.** \[NEW, low risk\]  
- **Unit-completion celebration** — the book's section dividers already mark these boundaries. \[ADAPT\]

**Not justified — do not build:**

- Leaderboards or any learner-vs-learner comparison. The audience is adults who were excluded from school; public ranking risks shame, which is the exact opposite of the book's stated purpose of *renforcer leur estime de soi*.  
- Lives / hearts / energy that block practice. Never gate literacy behind a timer.  
- Streak-loss anxiety mechanics.  
- Any currency, shop, or purchase.

## J.6 What must not be redesigned

Restating §B.6 as an engineering rule for the four of you: **the word lists, the sentences, the 28 texts, the lesson order, the keyword pairings, and the Beninese vocabulary are transcribed, not authored.** If something in the book seems wrong, it goes in `errata.json` and to Batonga — it does not get quietly fixed in a JSON file. The app's credibility with facilitators depends on the screen matching the printed page in their hands.

---

# K. MVP Scope

## K.1 Designing for this learner

Everything below follows from one fact: **at install time, the user cannot read the interface.** That is not an accessibility edge case — it is the core use case.

| Principle | What it means concretely | Owner |
| :---- | :---- | :---- |
| **Icon \+ audio first, text second** | Every button carries an icon and a spoken label. Onboarding is narrated. A user must be able to reach lesson 1 without reading a word. | C |
| **One decision per screen** | No screen offers more than 3 choices. The home screen's primary action is a single large « Continuer ». | C |
| **Big targets, generous spacing** | ≥ 56 dp, ≥ 16 dp apart. Assume a cracked screen, a thumb, and possibly a child on the hip. | C |
| **Linear by default, browsable by choice** | The path is a single scrolling line, not a graph. Free browsing exists but is never the default route. | C |
| **The learner is never wrong, only not-yet** | No red, no ✗, no score below which she "fails". Retry is always the offered action. | B |
| **Nothing waits on a network** | No spinners on content. Ever. | D |
| **Legibility over beauty** | Large type, high contrast (≥ 4.5:1), generous line height. Batonga's teal/magenta palette is kept for identity but never used as the sole carrier of meaning. | C |
| **Respect the adult** | Adult illustrations and adult voice. **Not a children's app** — the audience is adolescents and young women, and infantilising visuals would undercut the dignity framing in the preface. The book's own illustrations model this well. | C |
| **Resumable in 3 seconds** | She may have 4 minutes between chores. Cold start → tap Continuer → exact block she left. | D |
| **Works on the family phone** | A shared device is normal. Profile switching is trivial and unlocked (no password). | C |
| **Data-frugal** | Zero background data. If online features arrive, they are explicit, opt-in, and Wi-Fi-preferred. | D |

## K.2 MVP — required to reproduce the core educational experience

| Area | In MVP |
| :---- | :---- |
| **Content** | All 56 lessons \+ alphabet reference \+ digits 0–9, transcribed and validated. Every word list, sentence, and reading text, verbatim. |
| **Audio** | Human-recorded French for: every letter (name \+ sound), every syllable in the trees and strips, every word in every list, every sentence, every reading text (whole \+ per sentence), every digit. ≈ 1 200 clips. |
| **Lesson player** | All 12 block types rendering; script ⇄ cursive toggle; tap-to-hear on every item; resume mid-lesson. |
| **Activities** | The 5 types in §J.2, appearing in every lesson. |
| **Writing** | Guided trace for print lowercase, print uppercase, and digits (62 glyphs). Stroke-order animation for all of them. |
| **Assessment** | End-of-lesson *Bilan* (3–5 mixed items) \+ one checkpoint at the end of each unit. |
| **Progress** | Path with locked/available/completed states; per-lesson completion; resume point; day streak; a simple Mes Progrès screen. |
| **Shell** | Narrated onboarding, local profile (name \+ avatar), Accueil, Parcours, Entraînement (alphabet wall, digits, free trace canvas), Réglages. |
| **Platform** | Android \+ iOS. Fully offline. French UI. ≤ 60 MB. Runs on Android 8 / 2 GB RAM. |
| **Quality** | Content validator in CI; French proof-read sign-off; a11y audit passed; perf budgets met on real hardware. |

## K.3 Explicitly NOT in MVP

Accounts, login, any server call, sync, facilitator dashboard, cursive tracing, comprehension questions, spaced review, badges, notifications, TTS, speech recognition, multiple locales, arithmetic, numbers above 9, social features, in-app content editing, printable worksheets, a tablet-specific layout.

## K.4 Version 2 — after the first release ships and is used

| Feature | Why it waits |
| :---- | :---- |
| **Cursive tracing** (52 more glyphs) | Large authoring effort; print tracing must prove itself first |
| **Comprehension questions** on the 28 texts | **\[NEW\] content requiring Batonga's pedagogical sign-off** — cannot be written by developers alone |
| **Spaced review queue** | Needs weeks of real `MasteryRecord` data before the scheduling is anything but guesswork |
| **Badges & richer celebration** | Nice; not load-bearing |
| **Sync \+ code de reprise** | The outbox already records everything; this drains it |
| **Facilitator web dashboard** | A separate product with a separate audience |
| **Content OTA updates** | Wire `expo-updates` properly with a rollback path |
| **Local reminder notifications** | Only after we learn real usage rhythms |
| **Module « Lire un SMS » / « Mon carnet de commandes »** | **The preface's unfulfilled promise (§A.4).** The highest-value new content in the whole roadmap — and the one that most needs Batonga to co-author it |
| **Record-and-compare** | Learner records herself, plays it against the model. Cheap with the audio stack already built, and pedagogically strong |
| **Sentence-build & grapheme-hunt activities** | Activity types 11 and 16 |

## K.5 Future — worth naming, not worth planning yet

Speech-recognition pronunciation scoring · local-language bridge audio (Fon, Bariba, Dendi) for instructions while French remains the content · classroom mode for one shared tablet · adaptive difficulty from mastery data · printable worksheet export for facilitators · numeracy beyond 9, **built as a genuine curriculum project with Batonga rather than a developer's guess** · a second syllabaire in another Batonga country programme, using the same engine with a different content pack.

## K.6 The scope discipline rule

> **If a feature does not help a woman in Bohicon decode a syllable, it is not MVP.**

## Print that. When someone proposes dark mode, animated mascots, or a settings screen with fourteen switches in week 6, that sentence is the answer.

# L. Development Roadmap

**Assumption:** four students working roughly 15–20 h/week each, in 2-week sprints. **Total: 14 weeks to a releasable MVP.** Adjust the calendar, keep the phase order.

### Phase 0 — Architecture & Setup · Week 1 (all four together, in one room)

|  |  |
| :---- | :---- |
| **Everyone** | Agree the stack. Create the repo, branch protection, CODEOWNERS. **Write and freeze `src/core/contracts/`.** Agree the folder structure in §F verbatim. Write ADR-001 (stack) and ADR-002 (data-driven lessons). Agree the DoD in §P and the workflow in §N. |
| **Individually** | A: JSON Schema for one lesson \+ transcribe L01 and L08 by hand as reference. B: draft `ActivitySpec`/`ActivityResult`. C: Expo app scaffolded, runs on a device, theme tokens v0. D: SQLite connected, migration 0001, CI pipeline green. |
| **Dependencies** | None. This phase exists to eliminate them. |
| **Output** | A repo that builds on both platforms, with frozen contracts and four owned, empty directories. **No feature code yet.** |

### Phase 1 — Foundation · Weeks 2–3 (parallel)

| Dev | Work | Output |
| :---- | :---- | :---- |
| A | Content loader, repository, validator CLI. **3 block renderers**: keyword-illustration, letter-forms, word-list. Transcribe L01–L07 (the vowel unit). | `/dev/blocks` shows 3 blocks from real JSON |
| B | `ActivityHost` \+ registry. **`tap-identify`** end to end. Trace canvas spike: capture and render ink at 60 fps. | `/dev/activities` plays one activity |
| C | **All route files created and navigable** (placeholder bodies) — *this is the deliverable that unblocks everyone.* `@ui` primitives: Button, Card, ListRow, ProgressRing. Onboarding flow. | Walk the whole app on a phone |
| D | Full schema \+ migrations. `progressService` with a fixture. `audioService` reading placeholder clips. **Audio manifest v1 generated from A's L01–L07.** | Progress persists across restart |
| **Integration point** | End of week 3: merge all four into `develop`. **Demo: navigate to lesson 1 and see three real blocks with working audio.** |  |

### Phase 2 — Core Learning Experience · Weeks 4–6 (parallel)

| Dev | Work |
| :---- | :---- |
| A | Remaining 9 block renderers, syllable-tree first. Transcribe L08–L24. Illustration pipeline (24 SVGs). Script ⇄ cursive toggle. |
| B | `listen-choose`, `syllable-build`. **`scoreTrace` implemented and unit-tested** against hand-made fixtures. |
| C | Parcours map against D's `PathState`. Accueil with Continuer. Réglages. Font integration (print \+ cursive) — **resolve licensing this phase.** |
| D | Mastery engine. Streaks. **Recording session \#1 executed** (letters, syllables, digits ≈ 500 clips). Audio ingestion pipeline. Perf baseline on a real low-end device. |
| **Integration** | End of week 6: **any consonant lesson is playable start to finish with real audio.** This is the project's first genuine milestone. |

### Phase 3 — Exercises & Writing · Weeks 7–8 (parallel)

| Dev | Work |
| :---- | :---- |
| A | Transcribe L25–L56 (32 grapheme lessons \+ 28 texts) — **the heaviest transcription block.** `reading-text` renderer with all three sub-types. |
| B | `missing-letter`. **Trace canvas productionised** across all 62 print glyphs. Feedback layer (audio \+ icon \+ colour \+ motion). |
| C | Entraînement section: alphabet wall, digits, free canvas. Mes Progrès layout. **Accessibility audit round 1\.** |
| D | **Recording session \#2** (words, sentences, texts ≈ 700 clips). Audio preloading strategy. Sync outbox wired to every mutation. |
| **Integration** | End of week 8: all 5 activity types work; tracing works for every print glyph. |

### Phase 4 — Progress & Assessment · Weeks 9–10 (parallel)

| Dev | Work |
| :---- | :---- |
| A | Digit lessons D0–D9 \+ alphabet reference. **Full content validation passing on all 67 files.** French proof-read against the PDF. |
| B | *Bilan* end-of-lesson check. Unit checkpoint. Activity generation tuned per archetype. |
| C | Celebration screens. Empty/error states. Full French string sweep. **A11y audit round 2\.** |
| D | Unlocking rules. `LessonOutcome`. Resume point. Streak logic. **All audio ingested and manifest-verified.** |
| **Integration** | End of week 10: **content-complete.** All 67 lessons playable with real audio, activities, tracing and progress. |

### Phase 5 — Integration & Polish · Week 11 (converging)

Feature freeze. Everyone works from `develop`. Cross-stream bugs; visual consistency pass; loading and error states; perf against the §C.1 budgets on physical devices; install-size trim; content errata review with Batonga.

### Phase 6 — Testing · Weeks 12–13

|  |  |
| :---- | :---- |
| **All** | Fix what testing finds; no new features. |
| A | Every lesson opened and compared page-by-page against the PDF. |
| B | Scoring test suite ≥ 90 %; Maestro E2E for the five core flows. |
| C | Device matrix (≥ 4 Android including one Android Go, ≥ 2 iOS); a11y sign-off. |
| D | Migration test from a v0 DB; cold-start and memory profiling; crash reporting. |
| **Critical** | **Field test with 5–10 real learners through Batonga.** Two half-days, observed, no developer helping. This will teach you more than the previous twelve weeks. |

### Phase 7 — Release · Week 14

Store listings (FR), privacy policy (say plainly: no data leaves the device), screenshots, Play Store internal-test track → closed test with a Batonga cohort → production. Tag `v1.0.0`, write release notes, hand over `docs/`. Set up EAS Update channels for content fixes.

---

# M. Parallel Work Plan

## M.1 The dependency graph we are building

                 ┌──────────────────────────────────────────┐

   WEEK 1        │  PHASE 0 — all four, same room           │

                 │  contracts frozen · folders created      │

                 └───────────────────┬──────────────────────┘

                                     │

        ┌──────────────┬─────────────┼─────────────┬──────────────┐

        │              │             │             │              │

   ┌────▼────┐   ┌─────▼────┐   ┌────▼────┐   ┌────▼────┐         │

   │  DEV A  │   │  DEV B   │   │  DEV C  │   │  DEV D  │         │

   │ content │   │activities│   │  shell  │   │data+audio│        │

   └────┬────┘   └─────┬────┘   └────┬────┘   └────┬────┘         │

        │              │             │             │              │

        └──────────────┴──────┬──────┴─────────────┘              │

                              │                                   │

                    ┌─────────▼──────────┐                        │

                    │  develop (weekly)  │◄───────────────────────┘

                    └─────────┬──────────┘

                              │

                        ┌─────▼─────┐

                        │   main    │

                        └───────────┘

**Not this:**

   DEV A ──► DEV B ──► DEV C ──► DEV D      ✗  three developers idle

## M.2 How the four dependencies are dissolved

| Natural dependency | How we remove it |
| :---- | :---- |
| B needs A's content to test activities | B works from `__fixtures__/activitySpecs.ts` — hand-written specs, no content loader needed |
| C needs D's progress to draw the path | C works from `__fixtures__/pathState.ts` — a static `PathState` with every node status represented |
| A needs D's audio to render speaker icons | `audioService.has()` returns false for unrecorded clips; the icon simply is not drawn. **A ships every screen before a single clip is recorded.** |
| D needs A's audio IDs to build the manifest | IDs are **deterministic from a naming convention** agreed in Phase 0 (`word.fonio`, `syll.ta`, `sent.L09.02`). D generates the manifest by scanning A's JSON — no conversation required |
| A needs B's `ActivityHost` in the player | A renders a stub `<ActivityHost/>` (a "Continuer" card) until B's lands. The `activity` block type exists from day one |
| Everyone needs C's `@ui` | C ships primitives in **week 2**, before anyone needs them. Until then, everyone uses plain RN components and refactors — cheap and bounded |

## M.3 Per-phase parallel view

| Phase | Dev A | Dev B | Dev C | Dev D | Blocked? |
| :---- | :---- | :---- | :---- | :---- | :---- |
| 0 (w1) | Schema \+ 2 sample lessons | Activity contracts | Scaffold \+ theme | DB \+ CI | Together by design |
| 1 (w2–3) | Loader, validator, 3 renderers, L01–07 | ActivityHost, tap-identify, ink spike | **All routes**, `@ui` v1, onboarding | Schema, progress, audio stub | **None** |
| 2 (w4–6) | 9 renderers, L08–24, illustrations | listen-choose, syllable-build, scoreTrace | Parcours, Accueil, fonts | Mastery, streaks, **recording \#1** | **None** |
| 3 (w7–8) | L25–56 \+ texts | missing-letter, trace production | Entraînement, a11y \#1 | **Recording \#2**, preload, outbox | **None** |
| 4 (w9–10) | Digits, validation, proof-read | Bilan, checkpoints | Celebrations, strings, a11y \#2 | Unlocking, audio ingest | **None** |
| 5 (w11) | ← converge on `develop` → |  |  |  | Intentional |
| 6 (w12–13) | Content QA | Test suites | Device matrix | Perf & migrations | Intentional |
| 7 (w14) | ← release together → |  |  |  | Intentional |

**Zero blocking dependencies in weeks 2–10.** That is the design goal of the whole allocation, and it is achievable only because Phase 0 froze the contracts.

## M.4 Weekly rhythm

- **Monday 30 min — sync.** Each dev: what I merged, what I'm on, what I need from whom. Any contract change is raised here, never in a PR.  
- **Wednesday — integration day.** Everyone rebases on `develop` and pushes. Failing CI on Wednesday is everyone's problem.  
- **Friday 45 min — demo on a real phone.** Not a slide, not a simulator recording. If it does not run on a physical Android, it is not done.

---

# N. Git / GitHub Workflow

Deliberately simple. Four students do not need Git Flow.

## N.1 Branch model

main                     protected · always releasable · tagged releases only

 └── develop             protected · integration · CI must be green

      ├── dev/content-engine     Dev A   persistent

      ├── dev/activities         Dev B   persistent

      ├── dev/shell-ux           Dev C   persistent

      └── dev/data-audio         Dev D   persistent

           └── feat/data-audio/streak-logic     short-lived, optional

- **Persistent branches** are the four ownership branches. They live for the whole project.  
- **Short-lived branches** off your own persistent branch are optional; use one when a change is risky or needs its own review.  
- **`hotfix/*`** branches off `main`, merges to `main` **and** `develop`.

## N.2 Setup (day 1, one person, then everyone clones)

git init && git branch \-M main

git commit \--allow-empty \-m "chore: initial commit"

git push \-u origin main

git checkout \-b develop && git push \-u origin develop

\# each developer, once:

git checkout develop && git pull

git checkout \-b dev/content-engine        \# ← your own branch name

git push \-u origin dev/content-engine

**Branch protection on `main` and `develop`:** require a PR, require 1 approval (2 for `src/core/contracts/**`), require CI to pass, require the branch to be up to date, no force-push, no deletion.

## N.3 Daily loop

\# every morning, without exception

git checkout develop && git pull origin develop

git checkout dev/content-engine

git rebase develop            \# ← rebase your own branch onto develop

\# ...work...

git add \-p

git commit \-m "feat(content): render syllable-tree block"

git push \--force-with-lease   \# required after a rebase; never plain \--force

**Pull frequency: every morning, and again after any teammate announces a merge to `develop`.** Rebasing daily turns a week-long agonising conflict into a 30-second one. This is the single highest-value habit in this document.

## N.4 Commit convention

Conventional Commits, with the stream as the scope:

feat(content):   add reading-text renderer for dialogue texts

fix(activity):   trace scoring rejected valid uppercase T strokes

chore(db):       add migration 0007\_mastery\_index

docs(plan):      record ADR-004 on cursive scope

test(scoring):   cover multi-stroke direction checks

refactor(ui):    extract ListRow from Parcours

content(L25):    transcribe grapheme lesson an/am/en/em \+ Les vacances

Scopes: `content` `activity` `writing` `ui` `shell` `db` `progress` `audio` `sync` `ci` `plan`. Plus `content(Lxx)` for transcription commits, which keeps 56 lessons legible in the log.

## N.5 Rebase vs merge — the rule

| Situation | Do this | Why |
| :---- | :---- | :---- |
| Updating **your** branch from `develop` | **`git rebase develop`** | Keeps your branch a clean line of your own work |
| Merging your branch **into** `develop` | **Squash merge via PR** | One commit per feature in `develop`; a legible history for whoever maintains this after you |
| `develop` → `main` at release | **Merge commit** (`--no-ff`) | Preserves the release boundary |
| A branch someone else has pulled | **Never rebase it** | You will rewrite their history |

**The one absolute rule: never rebase `main` or `develop`.**

## N.6 Pull requests

Open a PR **from your persistent branch into `develop` at least once a week**, even if the work is unfinished — put it behind a feature flag (§G.3) and mark it draft. A branch that has not merged in two weeks is a merge disaster forming quietly.

`.github/pull_request_template.md`:

\#\# What

One sentence.

\#\# Stream

\- \[ \] A content  \- \[ \] B activities  \- \[ \] C shell  \- \[ \] D data/audio

\#\# Checklist

\- \[ \] Rebased on develop today

\- \[ \] \`npm run typecheck && npm run lint && npm test\` pass locally

\- \[ \] \`npm run validate-content\` passes (if content touched)

\- \[ \] Tested on a physical Android device

\- \[ \] No files outside my ownership area (see CODEOWNERS)

\- \[ \] No hardcoded French strings in components (i18n only)

\- \[ \] No hardcoded lesson content in components

\- \[ \] Definition of Done (§P) satisfied

\#\# Touches shared files?

List them and name who approved.

\#\# Screenshot / screen recording

Required for anything visual.

## N.7 Code review

- **Reviewer is the owner of whatever the PR touches.** Default reviewer is the dev whose contract you consume.  
- **24-hour turnaround.** A PR blocked for three days is a parallelism failure, not a review.  
- Review for: contract adherence, ownership boundaries, hardcoded content, hardcoded strings, and whether it runs. Not for style — Prettier settles style, and nobody argues with Prettier.  
- **Two approvals** for `src/core/contracts/**`, `package.json`, `tsconfig.json`, `app/_layout.tsx`.

## N.8 Conflict resolution

git rebase develop

\# CONFLICT in src/features/lesson/blockRegistry.ts

git diff \--name-only \--diff-filter=U     \# what actually conflicted

\# open it, resolve, keeping BOTH sides for registry/append-only files

git add src/features/lesson/blockRegistry.ts

git rebase \--continue

\# escape hatch:

git rebase \--abort

**Rules:**

1. **The file's owner decides.** If you conflict in someone else's file, you are probably in the wrong file — stop and ask.  
2. **Append-only files (registries, i18n, migrations): keep both sides.** Never "take mine".  
3. **`package-lock.json`: never hand-merge.**  
     
   git checkout \--theirs package-lock.json && npm install  
     
   git add package-lock.json  
     
4. **A conflict you cannot resolve in 10 minutes is a conversation, not a Git problem.** Call the other dev.

## N.9 Urgent fixes

git checkout main && git pull

git checkout \-b hotfix/audio-crash-on-android-8

\# fix, PR into main, 1 approval, merge, tag

git checkout develop && git merge main       \# ← never forget this line

For a content-only fix (a typo, a re-recorded clip), prefer **EAS Update** to the store: `eas update --branch production --message "fix: correct 'bouillie' spelling in L32"` — live in minutes.

## N.10 Not breaking each other

| Practice | Effect |
| :---- | :---- |
| CI on every PR **and** on every push to `dev/*` | You find out you broke `develop` in 4 minutes, not on Friday |
| Feature flags default-off | Unfinished work merges safely |
| `__fixtures__/` shipped alongside every module | Nobody consumes an unfinished implementation |
| Contracts frozen in Phase 0 | The only truly expensive break is prevented by process |
| Wednesday integration day | Drift never exceeds one week |
| Friday demo on hardware | "Works on my machine" dies weekly |

---

# O. Merge Conflict Prevention Strategy

Two conflict classes exist. **Content conflicts** (two people edited the same logic) are rare here because ownership is exclusive. **Structural conflicts** (two people appended to the same list) are the real threat. Everything below targets the second.

## O.1 The ownership table

| Area | Owner | Branch | Files / folders | Others may modify? |
| :---- | :---- | :---- | :---- | :---- |
| Content schema & data | **A** | `dev/content-engine` | `content/**`, `src/core/content/**` | ❌ never |
| Lesson player & blocks | **A** | `dev/content-engine` | `src/features/lesson/**` | ❌ (registry: append only, §O.3) |
| Illustrations & glyph shapes | **A** | `dev/content-engine` | `assets/illustrations/**`, `assets/glyphs/**` | ❌ |
| Content tooling | **A** | `dev/content-engine` | `tools/validate-content.ts` | ❌ |
| Activities & registry | **B** | `dev/activities` | `src/features/activity/**` | ❌ (registry: append only) |
| Writing & tracing | **B** | `dev/activities` | `src/features/writing/**` | ❌ |
| Scoring | **B** | `dev/activities` | `src/core/scoring/**` | ❌ |
| Assessment | **B** | `dev/activities` | `src/features/assessment/**` | ❌ |
| Routes | **C** | `dev/shell-ux` | `app/**` | ❌ **absolutely not** |
| Design system & theme | **C** | `dev/shell-ux` | `src/ui/**` | ❌ (request additions) |
| Shell features | **C** | `dev/shell-ux` | `onboarding/ home/ path/ practice/ settings/ profile/` | ❌ |
| i18n | **C** | `dev/shell-ux` | `src/i18n/**` | ⚠️ own namespace file only |
| Fonts | **C** | `dev/shell-ux` | `assets/fonts/**` | ❌ |
| Database & migrations | **D** | `dev/data-audio` | `src/core/db/**` | ❌ **absolutely not** |
| Progress & mastery | **D** | `dev/data-audio` | `src/core/progress/**` | ❌ |
| Audio | **D** | `dev/data-audio` | `src/core/audio/**`, `content/audio/**` | ❌ |
| Sync & telemetry | **D** | `dev/data-audio` | `src/core/sync/**`, `src/core/telemetry/**` | ❌ |
| Build, CI, EAS | **D** | `dev/data-audio` | `.github/workflows/**`, `eas.json`, `app.config.ts` | ❌ |
| **Contracts** | **shared** | — | `src/core/contracts/**` | ⚠️ **2 approvals \+ ADR** |
| **Dependencies** | **Build Steward** | — | `package.json`, `package-lock.json` | ⚠️ §O.2 |
| **Root layout** | **C \+ D** | — | `app/_layout.tsx` | ⚠️ §O.4 |
| **TS config** | **shared** | — | `tsconfig.json` | ⚠️ 2 approvals |

## O.2 Dependencies: the Build Steward

**One person (recommend Dev D) adds dependencies. Nobody else touches `package.json`.**

Process: you open a one-line issue titled `dep: react-native-svg for glyph rendering`; the Steward installs it on `develop`, pushes, and tells the team in chat; everyone rebases. Cost: a few hours of latency. Benefit: `package-lock.json` — the single worst-conflicting file in any JS project — has exactly one writer.

Batch requests into the Monday sync where possible.

## O.3 Registries instead of switch statements

The classic four-way conflict is one `switch` that every developer must extend. Replace it with an **append-only registry**, one alphabetically-sorted line per entry:

// src/features/lesson/blockRegistry.ts   — owner A, APPEND ONLY, keep alphabetical

import { ActivityBlock }           from './blocks/ActivityBlock';

import { GraphemeHeadingBlock }    from './blocks/GraphemeHeadingBlock';

import { KeywordIllustrationBlock} from './blocks/KeywordIllustrationBlock';

// …

export const blockRegistry: Record\<BlockType, BlockRenderer\> \= {

  'activity':              ActivityBlock,

  'grapheme-heading':      GraphemeHeadingBlock,

  'keyword-illustration':  KeywordIllustrationBlock,

  // …

};

Two developers adding entries at different alphabetical positions produce **no conflict at all**. If they land on adjacent lines, Git's 3-way merge usually resolves it; if not, "keep both" is unambiguously correct.

Same pattern for `activityRegistry.ts`.

## O.4 Every shared file, and its rule

| Shared file | Conflict risk | Rule |
| :---- | :---- | :---- |
| `package.json` / `package-lock.json` | **Very high** | Build Steward only (§O.2). On conflict: `git checkout --theirs package-lock.json && npm install` |
| **Routing** | Normally very high — **eliminated here** | expo-router \= file-based. One route, one file, one owner. **This is a concrete reason the stack choice matters.** |
| `app/_layout.tsx` | Medium | The one genuinely shared route file: C owns nav/theme/fonts; D owns providers (DB, audio). **Keep it under 60 lines**; each provider on its own line so merges are clean. 2 approvals. |
| `src/ui/theme.ts` | Medium | C writes. **Additive only** — never rename or remove a token. Others request via issue. |
| `src/core/contracts/**` | **Very high impact, low frequency** | Frozen after Phase 0\. 2 approvals \+ an ADR. |
| **Database schema** | High | D only. **One migration per file**, named `NNNN_<owner>_<slug>.sql` (`0007_d_mastery_index.sql`). The owner initial prevents two devs claiming `0007`. Never edit a merged migration. |
| **i18n** | Medium | **One namespace file per feature** (`fr/lesson.json`, `fr/activity.json`), never one `fr.json`. Keys sorted alphabetically. |
| **Content JSON** | Low | **One file per lesson.** Never a `lessons.json` array. `manifest.json` is generated by `npm run generate-manifest` and gitignored from hand-editing — `.gitattributes: content/manifest.json linguist-generated=true` |
| `.env` | High if committed | Never committed. `.env.example` is the shared, documented one. |
| `tsconfig.json` | Low frequency, high impact | 2 approvals. Path aliases agreed in Phase 0 and then left alone. |
| `app.config.ts` / `eas.json` | Medium | D only. |
| **Barrel files** (`index.ts` re-exports) | **High** | **Banned.** Import from the real path. Barrels are conflict magnets and hurt bundle size. Enforce with an ESLint rule. |
| `.github/CODEOWNERS` | Low | Changes only at the Monday sync. |

## O.5 Content-specific protection

Educational content has a failure mode code does not: **a silent, plausible-looking corruption**. A wrong accent in `fonio` will not fail a test.

1. **One lesson, one file.** 56 files, 56 independent edit surfaces.  
2. **CI runs `validate-content` on every PR** — §I.4's eight rules.  
3. **Every content PR requires a screenshot of the rendered lesson** beside the PDF page.  
4. **Protected vocabulary list.** `content/protected-terms.json` lists the Beninese cultural terms (§B.3). CI warns loudly if one is removed or altered by a diff. This is what stops a well-meaning "spellcheck" turning *margouillat* into *moustique*.  
5. **Second-pair-of-eyes rule:** no lesson merges until a second team member has compared it to the PDF page. Track in `docs/transcription-signoff.md`.

## O.6 If it goes wrong anyway

git reflog                             \# find the commit before the mess

git reset \--hard HEAD@{3}

git merge \--abort  /  git rebase \--abort

git checkout develop \-- path/to/file   \# take develop's version of one file

git log \--merge \-p path/to/file        \# see both sides' history for a conflicted file

And: **stop and call the file's owner.** Ten minutes on a call beats an afternoon of guessing what a teammate intended.

---

# P. Definition of Done

A feature is done when **every** box is ticked. Copy this into the PR template.

## P.1 Universal (every PR)

- [ ] Implemented and working on a **physical Android device** (not just the simulator)  
- [ ] `npm run typecheck` clean — **no `any`, no `@ts-ignore`** without a comment explaining why  
- [ ] `npm run lint` clean  
- [ ] `npm test` passes; new logic has tests  
- [ ] No console errors or warnings in the flow you touched  
- [ ] Rebased on `develop` the day it merges  
- [ ] Files touched are within your ownership area, or the owner approved  
- [ ] Reviewed and approved by the relevant owner

## P.2 Anything with a UI

- [ ] Renders correctly at **320 dp and 428 dp** widths  
- [ ] Renders correctly at **200 % system font scale** (nothing clipped, nothing overlapping)  
- [ ] All touch targets **≥ 56 × 56 dp**  
- [ ] Text contrast **≥ 4.5:1**  
- [ ] **No meaning conveyed by colour alone** (§J.3)  
- [ ] Every interactive element has a French screen-reader label  
- [ ] Every action a low-literacy user must understand has an **icon and audio**, not text alone  
- [ ] Loading, empty and error states exist  
- [ ] Uses `@ui` primitives and `theme` tokens — **no hardcoded hex, no magic spacing numbers**  
- [ ] All strings via i18n — **no French literals in components**

## P.3 Anything touching content

- [ ] `npm run validate-content` passes  
- [ ] Text matches the PDF **character for character**, including accents and punctuation  
- [ ] Any deviation is registered in `errata.json` with a page number  
- [ ] `sourcePages` recorded  
- [ ] Every referenced `audioId` exists in the manifest (as recorded or placeholder)  
- [ ] **Second-pair-of-eyes check done** and logged in `docs/transcription-signoff.md`  
- [ ] Screenshot of the rendered lesson attached to the PR beside the PDF page

## P.4 Anything touching data

- [ ] Migration is a new numbered file; **no merged migration edited**  
- [ ] Migration tested forward from an empty DB **and** from the previous released schema  
- [ ] Repository functions have tests  
- [ ] Mutation appends to `sync_outbox`  
- [ ] **Failure is swallowed and logged, never thrown to the UI** (§H.3)

## P.5 Anything touching audio

- [ ] Clip is mono, normalised to −16 LUFS, encoded AAC 64 kbps  
- [ ] Manifest entry with correct `status`  
- [ ] `audioService.has()` returns true  
- [ ] Playback tested on a physical device **with the phone speaker, not headphones** — this is how it will actually be used

## P.6 Performance (checked at each phase boundary, not every PR)

- [ ] Cold start ≤ 3.0 s on the reference low-end device  
- [ ] Lesson scroll holds 60 fps  
- [ ] Audio tap → sound ≤ 150 ms  
- [ ] Trace ink latency ≤ 32 ms  
- [ ] Install size ≤ 60 MB

## P.7 Feature-complete (before a phase closes)

- [ ] Documented in the relevant `docs/*.md`  
- [ ] Demoed on hardware at a Friday demo  
- [ ] Any new decision recorded as an ADR  
- [ ] Works with **airplane mode on** — this is the acceptance test that matters most

---

# Q. Risks and Mitigation

Ordered by expected damage, not by likelihood.

| ID | Risk | Likelihood | Impact | Mitigation | Owner |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **R-01** | **No rights agreement with the Batonga Foundation.** The syllabaire, its illustrations, the cover photograph and the Angélique Kidjo quote are all Batonga's. Building the app without written permission risks the whole project. | Medium | **Fatal** | **Do this in week 1, before writing content code.** Get written permission covering: digitisation of the text, redrawing the illustrations, using the Batonga name and marks, and who owns the app. Also ask for the original source files — a designer's InDesign package would remove weeks of transcription and asset work. | Team lead |
| **R-02** | **Transcription errors.** 56 lessons of accented French, hand-typed by developers. A wrong accent teaches a wrong spelling to someone who cannot yet detect it. | **High** | **High** | The eight validator rules (§I.4); one lesson per file; second-pair-of-eyes rule; screenshot-vs-PDF in every content PR; `protected-terms.json`; a final full read-through by a French speaker in Phase 6\. **Treat content bugs as severity-1.** | A |
| **R-03** | **Audio production slips.** \~1 200 clips need a speaker, a quiet room, and editing. This is the longest-lead item and the least like coding. | **High** | **High** | Book the speaker in **week 1**, not week 6\. Two sessions (§L Phases 2 and 3). Placeholder-first architecture (`has()`) so **nothing is blocked**. Naming convention fixed in Phase 0 so ingestion is mechanical. Fallback: ship v1 with letters/syllables/digits only and add words/texts by EAS Update. | D |
| **R-04** | **Misrepresenting the pedagogy.** Four developers "improving" a sequence designed by literacy specialists — reordering lessons, simplifying vocabulary, adding difficulty. | Medium | **High** | §B.6 and §J.6 are binding. The validator's cumulative-decoding rule is a mechanical guard. **Any pedagogical change requires Batonga's written approval, recorded as an ADR.** | A |
| **R-05** | **Uneven workload.** Content transcription (A) and audio management (D) are volume-heavy; activities (B) are algorithmically heavy. Someone falls behind and the parallel plan collapses. | **High** | Medium | Track per-stream progress at the Monday sync. **Transcription is explicitly a shareable task** — if A is behind at week 7, B/C/D each take 8 grapheme lessons; the schema is stable by then and the validator catches mistakes. Rebalance early, not in week 12\. | Team lead |
| **R-06** | **Scope creep.** Arithmetic, a chatbot, a facilitator dashboard, "just a small AI feature". | **High** | **High** | §K.6's one-sentence test. Everything not in §K.2 goes to a `v2` GitHub milestone **without discussion**. Feature flags let ambitious work merge without shipping. | Team lead |
| **R-07** | **Handwriting complexity swallows the project.** Tracing is the most enticing rabbit hole in the app. | Medium | **High** | §J.4: **path-following, not recognition.** Print only in MVP; cursive is V2. `scoreTrace` is pure and unit-tested. **Time-box the spike to 5 days in Phase 1**; if 60 fps ink is not achieved by then, escalate at the Monday sync. | B |
| **R-08** | **Cursive font licensing.** The book uses a French school cursive face. Redistributing it in an app binary is a different licence from print. | Medium | Medium | Resolve in **Phase 2**, not at release. Options: buy an app-embedding licence; use an open school-cursive face; commission one. **Cursive display is MVP, so this cannot be deferred.** | C |
| **R-09** | **Performance on low-end devices.** SVG glyphs, \~1 200 audio files, long scrolling lessons on an Android Go device with 2 GB RAM. | Medium | **High** | **Buy one cheap Android device in week 1 and test on it weekly.** Budgets in §C.1 measured at every phase boundary. Virtualised lists, lazy audio preloading (current block \+ next only), SVG over PNG. | D |
| **R-10** | **Merge conflicts and divergence.** Four branches, fourteen weeks. | Medium | Medium | The whole of §N and §O. The two habits that matter most: **rebase daily** and **PR into `develop` weekly**. | All |
| **R-11** | **Accessibility fails the actual audience.** The app is beautiful and unusable by someone who cannot read. | Medium | **High** | §K.1 principles; §P.2 checks on every UI PR; two formal audits (Phases 3 and 4); **and the field test in Phase 6 with real learners, observed, with no developer helping.** Nothing else in this table substitutes for that test. | C |
| **R-12** | **Offline sync design debt.** Building sync in V2 requires retrofitting change tracking. | Low | Medium | `sync_outbox` written from day one (§C.4). Roughly 30 lines now versus a fortnight later. | D |
| **R-13** | **Content volume exhausts the team.** 67 lessons, 24 illustrations, 62 glyphs, 1 200 clips is a lot of *making things*, and it is less fun than coding. | **High** | Medium | Front-load it: transcription starts in Phase 1 and runs continuously. Budget \~45 min per lesson. Make it visible on a board so it is not a silent overrun. Ask Batonga for source files (R-01). | A |
| **R-14** | **Store rejection or distribution friction.** iOS review, or learners who cannot reach the Play Store. | Low | Medium | Ship the Android build to Batonga as a direct APK **and** to Play. Privacy policy is trivially honest: no data collection. Start the Apple developer account in week 1 — enrolment can take days. | D |
| **R-15** | **The team disbands after the project grade.** The four of you graduate; the app has to live. | **High** | **High** | This is why branches are named by domain, why every module has a `docs/*.md`, why decisions are ADRs, and why content is JSON a non-programmer can read. **In Phase 7, write `docs/HANDOVER.md`** — how to add a lesson, how to add an audio clip, how to release. | All |

## Q.1 The three risks to act on this week

1. **R-01** — get the rights conversation started with Batonga today. Everything else is downstream of it.  
2. **R-03** — find and book the voice talent now. It is a 6-week lead item on a 14-week schedule.  
3. **R-09** — buy a cheap Android phone. You cannot budget performance on a MacBook simulator.

---

# R. Recommended First Sprint

**Sprint 1 \= 2 weeks.** Objective:

> **By the end of week 2, all four developers can run the same app on a phone, walk to Lesson 1, and see one real block rendered from real JSON with a working audio button — and each of them can keep building for six weeks without waiting on anyone.**

## R.0 Day 1 — the whole team, together, before any code

Do not skip this. Four hours now saves the project.

| Time | Decide | Output |
| :---- | :---- | :---- |
| 60 min | **Read the book together.** All four, page by page, including all 28 texts. Not the summary — the source. | Shared understanding of what you are building |
| 30 min | Confirm the stack (§C.1). Argue now or not at all. | `docs/adr/001-stack.md` |
| 45 min | **Write `src/core/contracts/` on a whiteboard, then in code.** All five files. This is the most important hour of the project. | Contracts committed to `develop` |
| 30 min | Agree the **audio ID naming convention** (§G.1). Write it down. | `docs/audio-production.md` §1 |
| 30 min | Agree the folder structure in §F **verbatim**, and CODEOWNERS. | Repo scaffold \+ CODEOWNERS |
| 20 min | Agree §N workflow and §P Definition of Done. | Both pinned in the repo |
| 15 min | Assign the four branches. Nominate the **Build Steward**. | CODEOWNERS committed |
| 20 min | **Assign R-01 (Batonga rights), R-03 (voice talent), R-09 (buy a test phone).** Names and dates. | Three GitHub issues with owners |

## R.1 Developer A — `dev/content-engine`

| \# | Task | Done when |
| :---- | :---- | :---- |
| A1 | Write `content/schema/lesson.schema.json` for all 12 block types | It validates the L08 example in §I.3 |
| A2 | **Transcribe `L01.json` (i / un épi) and `L08.json` (t / une tête) by hand**, verbatim from pages 7–8 and 20–21 | Both pass the schema; a second dev has compared them to the PDF |
| A3 | Build `contentRepository` — load, index, query, `getNextLesson` | Unit-tested against L01 and L08 |
| A4 | Build `tools/validate-content.ts` with rules 1–5 of §I.4 | `npm run validate-content` runs in CI |
| A5 | Build 3 block renderers: `keyword-illustration`, `letter-forms`, `word-list` | Visible in `/dev/blocks` with real data |
| A6 | `LessonPlayer` v0: renders a block sequence, next/back, calls `onBlockComplete` | Lesson 1 plays end to end with a stub activity card |
| A7 | Draw or source 2 illustration SVGs (épi, tête) | Rendered in-app, ≤ 15 KB each |
| A8 | Transcribe L02–L07 if time allows | Validator green |

**Hand off by end of sprint:** the frozen `Lesson`/`LessonBlock` types, `L01.json` \+ `L08.json` as everyone's fixtures, and the audio IDs those two lessons reference (D needs them).

## R.2 Developer B — `dev/activities`

| \# | Task | Done when |
| :---- | :---- | :---- |
| B1 | Finalise `ActivitySpec` / `ActivityResult` in contracts with the team | Merged to `develop` on day 1 |
| B2 | `ActivityHost` \+ `activityRegistry` (append-only pattern, §O.3) | Renders any registered type from a spec |
| B3 | Implement **`tap-identify`** fully: grid, distractors, audio+icon+colour feedback, skip | Playable in `/dev/activities` from a fixture |
| B4 | Write `__fixtures__/activitySpecs.ts` — one spec per planned MVP type | A and D can import it |
| B5 | **Trace canvas spike (time-boxed to 5 days, R-07).** Capture touch points, render ink with Reanimated \+ SVG, measure latency on the cheap Android | Ink at 60 fps, latency ≤ 32 ms, **or** an escalation at the Monday sync |
| B6 | First cut of `scoreTrace`: start-point \+ checkpoint coverage only | Pure function, ≥ 5 unit tests, no React import |
| B7 | Feedback layer: sound \+ icon \+ colour \+ motion, from one component | Used by `tap-identify` |

**Hand off:** `ActivityHost` (real, not a stub) and the fixtures file.

## R.3 Developer C — `dev/shell-ux`

| \# | Task | Done when |
| :---- | :---- | :---- |
| C1 | Expo \+ TypeScript \+ expo-router scaffold; **runs on a physical Android and an iPhone/simulator** | Everyone can `npm i && npx expo start` |
| C2 | **Create every route file in §F with a placeholder body** | The whole app is walkable — *this is the sprint's most important deliverable for the team* |
| C3 | `theme.ts`: colour (Batonga teal \+ magenta, contrast-checked), spacing, radius, type scale, motion | Committed and documented |
| C4 | `@ui` v1: `Button`, `IconButton`, `Card`, `ListRow`, `ProgressRing`, `Toast` | All ≥ 56 dp, all themed, shown in `/dev/blocks` |
| C5 | i18n set up with namespaced `fr` files | No literal French in any component |
| C6 | Onboarding flow: narrated welcome, name/avatar, start | Walkable; a non-reader could complete it |
| C7 | `docs/ux-principles.md` and `docs/a11y-checklist.md` from §K.1 and §P.2 | Committed |
| C8 | **Resolve the cursive font question (R-08)** — identify candidates and licence terms | A recommendation posted for the team |

**Hand off:** the route tree and `@ui` — both by **end of week 1** if at all possible, because A, B and D all consume them.

## R.4 Developer D — `dev/data-audio`

| \# | Task | Done when |
| :---- | :---- | :---- |
| D1 | SQLite \+ Drizzle; migration `0001` covering all §G.2 tables | Runs on a clean install on both platforms |
| D2 | Repositories for `Learner`, `LessonState`, `ActivityAttempt`, `MasteryRecord` | Unit-tested |
| D3 | `progressService` v1: `recordActivityResult`, `recordBlockComplete`, `getLessonState`, `getResumePoint` | Progress survives a force-quit |
| D4 | `__fixtures__/pathState.ts` — a static `PathState` with every node status | C imports it immediately |
| D5 | `audioService` v1: `play`, `stop`, `preload`, **`has`** | Plays a bundled test clip; `has()` returns false safely for missing IDs |
| D6 | **Write `docs/audio-production.md`**: naming convention, technical spec (mono / 44.1 kHz / −16 LUFS / AAC 64 kbps), the recording script format, session plan | Ready to hand to the voice talent |
| D7 | **Generate `audio-manifest.json` v1 by scanning A's L01 \+ L08** — every entry `status: "placeholder"` | Manifest generation is a script, not manual |
| D8 | CI: typecheck → lint → test → validate-content, on PR and on push to `dev/*` | Green on `develop` |
| D9 | Set up EAS; produce one internal Android build the team can install | APK in the team chat |
| D10 | Record a **perf baseline** on the cheap Android from C1's build | Numbers posted against §C.1 |

**Hand off:** `progressService`, `audioService`, the `PathState` fixture, and green CI.

## R.5 Sprint 1 exit criteria

Do not start Sprint 2 until all of these are true:

- [ ] `develop` builds and runs on **both** platforms, from a clean clone  
- [ ] **`src/core/contracts/` is written, merged, and declared frozen**  
- [ ] Every route file exists; the app is fully walkable with placeholders  
- [ ] `L01.json` and `L08.json` are transcribed, validated, and PDF-verified by a second person  
- [ ] Lesson 1 plays three real block types from JSON  
- [ ] One activity (`tap-identify`) is playable  
- [ ] Progress persists across a force-quit  
- [ ] `audioService.has()` correctly returns false for unrecorded clips, and no speaker icon renders for them  
- [ ] CI is green and runs on every PR  
- [ ] All four have merged at least one PR into `develop`  
- [ ] The three week-1 actions (§Q.1) have owners, and the Batonga rights conversation has started  
- [ ] The cheap Android test device is in someone's hand

## R.6 What the team must agree together before writing much code

In descending order of cost-if-wrong:

1. **The contracts in §H.** Everything parallel depends on them. Change them in week 1; changing them in week 8 costs days across four branches.  
2. **That lessons are data, not screens** (§I.1). Half the team quietly hardcoding a screen "just for this one lesson" is the failure mode that ends the architecture.  
3. **The audio ID naming convention.** It is the seam between the content stream and the audio stream, and it must be mechanical.  
4. **Ownership boundaries** (§O.1). Agree that "I'll just quickly fix it in your file" is not a thing you do here.  
5. **The Definition of Done** (§P). Agreed up front it is a standard; introduced in week 10 it is an insult.  
6. **The MVP line** (§K.2 vs §K.3). Write it on the wall. Point at it in week 6\.  
7. **Who talks to Batonga**, and that pedagogical questions go to them rather than being resolved by developer intuition.

---

# Appendix — Assumptions and Open Questions

## Assumptions I have made (correct me if wrong)

| \# | Assumption |
| :---- | :---- |
| 1 | The app reproduces **this book only**, in French. Not a general literacy platform. |
| 2 | The team can obtain permission from the Batonga Foundation (R-01). |
| 3 | Learners have personal or shared Android phones; Android is the primary platform, iOS secondary. |
| 4 | A facilitator is often present, as the book assumes — but the app must work without one. |
| 5 | Four developers, \~15–20 h/week each, \~14 weeks. Scale linearly if that is wrong. |
| 6 | The team is more comfortable in JavaScript/TypeScript than Dart or Kotlin. If not, invert the stack decision; everything else in this plan still applies. |
| 7 | A native French speaker can proof-read all content (essential — the accents matter). |
| 8 | A Beninese French speaker can be recorded, ideally a woman, for register and pronunciation the learners recognise. |

## Questions the PDF cannot answer — ask Batonga

1. **Pacing.** How long is a session in the Batonga programme? One lesson per meeting? Per week? This determines lesson length, and I have sized lessons at 10–15 minutes as a guess.  
2. **Is there a facilitator guide?** The book presumes one but does not include one. If it exists, it contains the objectives, the pacing, and the error-correction guidance this plan had to infer.  
3. **The letters q, w and x** (§B.2). Deliberate omission, or an oversight to fix in the app?  
4. **The Lesson 23/24 print order** — confirm 23 \= z and 24 \= h.  
5. **The errata** (§B.3). Ship the typos verbatim, or corrected? My recommendation is verbatim by default, but this is Batonga's call, not ours.  
6. **Numeracy.** The title says *alphanumérique* and the preface promises *numératie*, but the content stops at digit recognition. Is a numeracy volume planned? Anything we build beyond digits 0–9 is invention.  
7. **The digital-inclusion content** (SMS, order books) named in the preface but absent from the book. Is it planned? This is the strongest V2 module, and it needs Batonga's curriculum, not ours.  
8. **Comprehension questions** for the 28 texts — will Batonga write them, or approve ours?  
9. **Source assets.** Do the original illustrations and layout files exist? This would save weeks (R-13).  
10. **Are the reading texts original to Batonga**, or drawn from an existing Beninese primer? Relevant to rights (R-01).

---

*Plan prepared from the full 104-page source. Every content claim above is traceable to a specific page; every recommendation not in the book is tagged **\[ADAPT\]** or **\[NEW\]**; every gap is tagged **\[GAP\]** rather than filled with invention.*  
