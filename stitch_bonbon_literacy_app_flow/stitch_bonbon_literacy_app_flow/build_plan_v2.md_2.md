# Syllabaire Batonga → Mobile App
## Engineering & Product Plan for a 4-Developer Team

**Source material:** *Syllabaire Alphanumérique pour les Adolescentes et les Jeunes Femmes*, 2ᵉ édition, Fondation Batonga, printed Q2 2025. 104 pages.
**Document status:** v2.0 — written to be committed as `docs/DEVELOPMENT_PLAN.md` and read on day one by all four developers.
**Structure:** **Part One (§A–§R)** digitises the book. **Part Two (§S–§X)** is the four add-on packs that turn the digitisation into the full product — one pack per developer, one directory each, no shared files. §S.6 lists every amendment Part Two makes to Part One.
**Document language:** English. **App UI language:** French.

### How to read this document

Every claim about educational content is tagged:

| Tag | Meaning |
|---|---|
| **[SRC]** | Directly derived from the PDF. Verifiable on a specific page. |
| **[ADAPT]** | A UX/engineering adaptation of something that *is* in the PDF (e.g. a ruled copying line becomes a trace canvas). |
| **[NEW]** | A feature I am recommending that has **no basis in the PDF**. Treat as a product proposal requiring Batonga's approval. |
| **[GAP]** | Something the PDF does *not* contain. Stated explicitly so nobody invents it. |
| **[DERIVED]** | *(Part Two)* Generated mechanically from **[SRC]** material by a stated rule, and re-checkable by re-running that rule. See §S.2. |

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

**React Native + Expo (SDK 54+), TypeScript, expo-router, expo-sqlite, bundled content.**

Specification and justification are in §C.1. Short version: it gives one codebase for Android and iOS, ships all content and audio inside the app binary so the app is fully functional with the radio off, lets you build iOS without owning a Mac (EAS Build), and — critically for a content-heavy app — lets you push corrected lesson text and audio via `expo-updates` without a two-week App Store review. Its file-based router also happens to eliminate the single worst merge-conflict source in a 4-person mobile team (a shared route table).

## A.4 The three honest scope truths

- **Numeracy is thinner than the title promises.** The book is called *alphanumérique* and the preface promises *numératie*, but the delivered numeracy content is **digits 0–9: recognition, French name, and stroke order. Nothing else.** No counting, no arithmetic, no money, no quantity. **[GAP]** **Decided (Part Two, §S.1): digits 0–9 are the whole of the numeracy scope, permanently.** The digit unit is specified completely in `content/corpus/digits.json` and closed. Building an arithmetic module would be a *new product*, not a digitisation.
- **The digital-inclusion promise is unfulfilled by the book.** The preface names reading an SMS and keeping an order book as the goal, but **no lesson in the book teaches either.** **[GAP]** **Decided (Part Two, §S.1): not planned.** Batonga has ruled the SMS / order-book module out of scope for now — not MVP, not V2, not backlog. It remains a Foundation curriculum question, not a developer one. What the app *does* honour from the preface is the book's own economic vocabulary, surfaced as a browsable theme — see §T.8.
- **The book contains no exercises.** Every activity in the book is *read aloud*, *copy*, or *trace*. There are no questions, no answers, no quizzes, no comprehension checks. **[GAP]** Therefore **every interactive activity in the app is an [ADAPT] or [NEW]**, and each one needs a stated pedagogical justification, which §J provides.

---

# B. Book → App Analysis

## B.1 Physical structure of the source

| Pages (PDF) | Section | Content |
|---|---|---|
| 1–2 | Cover / title | Photo of two learners with slates showing `A B C D E F` and `0 1 2 3 4 5 6 7 8 9 10 11` |
| 3 | Préface | Signed *La Fondatrice*. States purpose, audience, and the AGR/digital-inclusion goal |
| 4 | Témoignages | Two quotes: a Batonga business-circle member (Bohicon), and the Bénin Country Director |
| 5 | Alphabet reference | 26 letters, "20 consonnes – 6 voyelles"; full alphabet in **script lower, script upper, cursive lower, cursive upper** |
| 6 | Divider | *ÉTUDE DES VOYELLES ET CONSONNES* |
| 7–53 | **Part I — Lessons 1–24** | 24 letter lessons, each = 1 lesson page + 1 *Écriture* page |
| 54 | Divider | *ÉTUDE DES DIPHTONGUES ET TEXTES* |
| 55–87 | **Part II — Lessons 25–56** | 32 grapheme lessons, 1 page each (Lesson 56 spans 2 pages) |
| 88 | *CHIFFRES* | Table: `0 → zéro` … `9 → neuf` |
| 89–98 | **Part III — Digits** | 10 tracing pages, one per digit 0–9 |
| 99–104 | Back matter | Print date, Angélique Kidjo quote, Batonga contact details + QR code |

## B.2 Part I — the letter lessons (Lessons 1–24)

### The vowel block (Lessons 1–7) **[SRC]**

| # | Letter(s) | Keyword | Illustration |
|---|---|---|---|
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

### The consonant block (Lessons 8–24) **[SRC]**

17 consonants, in this order: **t, p, n, m, r, v, l, d, b, j, f, s, c, g, k, h, z**

| # | Letter | Keyword | # | Letter | Keyword | # | Letter | Keyword |
|---|---|---|---|---|---|---|---|---|
| 08 | t | une tête | 14 | l | un livre | 20 | c | un couteau |
| 09 | p | une pipe | 15 | d | une datte | 21 | g | une guitare |
| 10 | n | un nez | 16 | b | une bassine | 22 | k | un képi |
| 11 | m | une montre | 17 | j | une jupe | 23 | z | un zébu |
| 12 | r | une radio | 18 | f | un feu | 24 | h | une hache |
| 13 | v | un vélo | 19 | s | un sac | | | |

Same anatomy as the vowel lessons, **plus three new blocks**:

- **The syllable tree** — the signature graphic. A consonant on the left, arrows fanning out to each vowel, producing the syllable in **print and cursive**. Usually split into two trees (i/u/o/a and e/é/è/ê) for layout.
- **A syllable strip** — the same syllables as a flat readable line: `ti, tu, to, ta, te, té, tè, tê`
- **A sentence block** — two to four very short sentences built *only from letters already taught*: `papa tape toto.` `toto tape paté.` `mémé a une tomate.` `la pile de lili.`

**Documented variations** (the data model must accommodate these; they are not noise):

- **Lesson 8 (t)** and **Lesson 16 (b)** have an extended tree with a **third column of doubled/derived words**, each then repeated in cursive: `ti → tite`, `tu → tutu`, `to → toto`, `ta → tata`, `bi → bibi`, `bé → bébé`, `bè → bèche`, `bê → bête`. Lesson 8's tree also has only **seven** branches (no `tè`) while its syllable strip below lists **eight** — reproduce both as printed.
- **Lesson 21 (g)** deliberately restricts to `gu, go, ga` only — the soft *g* is withheld until Lesson 43 (`g = j`) and Lesson 44 (`gu`). This is intentional sequencing, not an omission.
- **Lesson 24 (h)** has **no sentence block** — only syllables and a word list of *h*-initial words.
- **Lesson 7 (y)** is placed inside the vowel block and has no tree.

### ⚠️ Content-integrity findings in Part I

| Finding | Detail | Recommended action |
|---|---|---|
| **Lessons 23 and 24 are printed out of order** | PDF p.50 = *Leçon 24* (h / hache); PDF p.52 = *Leçon 23* (z / zébu) | Ship them in **numerical** order (23 = z, 24 = h). Log the discrepancy for Batonga. |
| **q, w, x** — *resolved, not a defect* | The alphabet page claims 20 consonants; only 17 receive lessons. **In French `q` is never written alone — it always carries its `u`, and it is taught exactly where it occurs: Lesson 46, `qu = k = c`.** `w` and `x` are loanword letters and appear on the alphabet wall only. | **No invented lessons.** Finding withdrawn (§S.1, §T.3). Registered as `errata.json` `E-009`, status `documented`. |
| **Écriture-page words drift from the lesson-page words** | e.g. Lesson 10 (n) teaches `note, natte, âne, anani, nono, nini` but the écriture page drills `neuf` and `natte`; Lesson 20 (c) écriture drills `conte` and `calcul`, neither on the lesson page | Preserve both lists verbatim as separate fields (`wordList` vs `writingModels`). Do **not** merge them. |

## B.3 Part II — graphemes and reading texts (Lessons 25–56) **[SRC]**

32 single-page lessons. Anatomy:

1. The grapheme group as a heading in **three renderings**: print lowercase, cursive lowercase, print uppercase — e.g. `an am en em` / *an am en em* / `AN AM EN EM`
2. A syllable list (`dan - pan - man - san - van…`)
3. A word / short-phrase list (`le banc - la jambe - lentement - je danse - le rang`)
4. **The same lists repeated in cursive**
5. **A titled reading text** — this is the new element and the section's whole point

| # | Grapheme(s) | Text title | Text type |
|---|---|---|---|
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
| 37 | et ez ai ed | À l'école | narrative + quote |
| 38 | euil euille | Un visiteur | **dialogue** |
| 39 | ill ille | Une pluie surprise | narrative |
| 40 | eu œu | Les conseils | **advice list** |
| 41 | eur eure œur | Les deux sœurs | narrative |
| 42 | oir oire | Une histoire | **dialogue** |
| 43 | g = j | Le forgeron | narrative |
| 44 | gu | Les mangues | narrative |
| 45 | gn | Un bon repas | narrative |
| 46 | qu = k = c | — | **no text** |
| 47 | s = z | Le magasin | narrative |
| 48 | c = s, ç = s | — | **no text** |
| 49 | iez ier ied | — | **no text** |
| 50 | ch | Le domaine | narrative |
| 51 | ph = f, th = t | Le photographe | narrative |
| 52 | ac oc ic | Les vacances | narrative |
| 53 | tion = sion | Les opérations | narrative |
| 54 | bl pl vl fl cl | — | **no text** |
| 55 | ar or | Les préparatifs | narrative |
| 56 | br tr cr pr dr gr vr fr | L'hôpital | narrative (2 pages) |

**28 texts across three sub-types** — narrative (22), dialogue (4), advice list (2). The sub-type matters for rendering: dialogues use `-` speaker turns and must be laid out as turns, not paragraphs; advice lists are bulleted imperatives.

**Cultural grounding is systematic and must be preserved verbatim.** Places: *Kandi, Cotonou, Nikki, Kérou, Gamia, Nord-Bénin*. Foods: *fonio, igname pilée, akassa, karité, quinquéliba, bouillie, mangue, arachide*. Life: *le marigot, le marché, la case, le pagne, le boubou, la fête de ramadan, le forgeron, le margouillat*. Names: *Baké, Samira, Dossou, Ignace, Bio, Konaté, Kadidia, Orou, Gildas, Gédéon, Victoire, Flore, Rose, Marguerite, Hugues*.

This is not decoration. A learner in Bohicon recognises *un margouillat* on her roof. Replacing it with *un lézard* would break the book. **This vocabulary is protected content — see §O.5.**

**Economic-life vocabulary threads through the texts**, matching the preface's AGR goal: *la vendeuse, le marchand, un acheteur, le magasin, la banque, le client, l'étalage, vendre, acheter, les opérations, l'addition, la soustraction, la multiplication, la division*. Worth surfacing as a filterable vocabulary theme **[ADAPT]**.

### ⚠️ Content-integrity findings in Part II

- **Typographic and grammatical slips** in the source: `La boullie` (should be *bouillie*); `la gardien` (Lesson 21, should be *le gardien*); `un met` (Lesson 37, should be *mets*); `retoune` (Lesson 26, should be *retourne*); Lesson 40's cursive line drops the word after `un` where `un vœu` is expected; `Bl` is capitalised inconsistently in Lesson 54's heading.
- **Lesson 49 appears twice** in the PDF render (p.79 duplicated). Ship once.
- **Recommendation:** build an `errata.json` listing every deviation with page reference. Ship the **source text verbatim by default**; apply corrections only behind a flag, and only after Batonga signs off. A literacy primer's authority depends on it matching the printed book the facilitator is holding.

## B.4 Part III — the digits **[SRC]**

- **One reference page**: `0 → zéro`, `1 → un`, `2 → deux`, `3 → trois`, `4 → quatre`, `5 → cinq`, `6 → six`, `7 → sept`, `8 → huit`, `9 → neuf`
- **Ten tracing pages**, one per digit, each with: a large outlined numeral with **numbered stroke-order arrows** (a richer stroke notation than the letter pages use), then ruled lines with the digit × 8, the word in print × 3, and the word in cursive × 2

**The digits are the most gamification-ready content in the book** — a closed set of 10, each with a name, a shape, and a stroke order, and no reading prerequisite. **[SRC]** confirms only recognition, naming, and writing. Counting objects, comparing quantities, and arithmetic are **[GAP]/[NEW]** — and, per §S.1, **permanently out of scope.** The unit is fully specified in `content/corpus/digits.json` and closed.

## B.5 The pedagogical model, extracted

| Dimension | What the book does |
|---|---|
| **Method** | Synthetic phonics / syllabic. Bottom-up: sound → syllable → word → sentence → text. |
| **Difficulty curve** | Four gears. (1) Vowels in isolation. (2) One consonant at a time × known vowels; sentences appear at Lesson 8 and stay ≤ 6 words until ~Lesson 20. (3) Complex graphemes + paragraph-length texts. (4) Digits, deliberately parked at the end. |
| **How lessons build** | Strictly cumulative. Lesson 9's sentence `papa tape toto` reuses only t, p, o, a from Lessons 1–9. The word `tomate` in Lesson 11 is only legible because t, m, o, a are all taught. **Sequence integrity is a functional requirement, not a preference.** |
| **Repetition** | Extreme and deliberate — 3 rows of the letter, list in print, list again in cursive, models on the écriture page. Repetition *is* the method for adult beginners. |
| **Reading ↔ writing** | Fully parallel. Never "read now, write later." Every letter lesson pairs decoding with stroke-order production, in two scripts. |
| **Vocabulary** | Contextual, Beninese, and increasingly economic. |
| **Comprehension** | Implicit only. Texts are for decoding practice; the book asks no questions about them. **[GAP]** → the question *system* is specified in §U.6; the questions themselves are Batonga's to write. |
| **Assessment** | None. No tests, no self-check, no answer key. **[GAP]** → Bilan, six checkpoints and a placement test are specified in §U.5. |
| **Facilitator role** | Assumed but never documented. The book presumes someone reads aloud and corrects handwriting. **The app must absorb that role.** → the script for that role is §V; the human facilitator gets her own surface in §V.8. |

## B.6 What must remain faithful vs. what may be redesigned

| Must stay faithful **[SRC]** | Safe to redesign **[ADAPT]** |
|---|---|
| Lesson order 1 → 56, then digits | Page layout and pagination |
| Which letter/grapheme belongs to which lesson | How repetition is delivered (tap-drills instead of static rows) |
| Word lists and reading texts, verbatim | Navigation, progress display, encouragement |
| The dual print/cursive presentation of every item | Which script is *default*, with the other one tap-toggled |
| Stroke order and direction | Ruled Seyès lines → responsive trace canvas |
| Keyword + illustration pairings | Illustration re-drawing as SVG (same subject, cleaner vector) |
| Beninese cultural vocabulary | Adding audio, feedback, timing, scoring |
| Digits limited to 0–9 | Adding a digit-recognition game |
---

# C. Complete App Architecture

## C.1 Technology stack — recommendation and specification

You asked for a recommendation for an **offline app that runs on both Android and iOS**. Here it is, with the reasoning, because the team will have to defend it.

### Recommended stack

| Layer | Choice | Why this one |
|---|---|---|
| Framework | **React Native via Expo, SDK 54+** | One codebase, both platforms. Managed workflow means no Xcode/Gradle archaeology for a student team. |
| Language | **TypeScript, `strict: true`** | The contracts in §H are only enforceable if the compiler enforces them. This is what makes 4-way parallel work safe. |
| Navigation | **expo-router** (file-based) | **Merge-conflict elimination.** Routes are files on disk, not entries in a shared array. Four developers adding screens touch four different files. This alone is worth the choice. |
| Local database | **expo-sqlite** + **Drizzle ORM** | Real SQL, real migrations, real relational queries for progress and review scheduling. AsyncStorage would not survive the mastery model. |
| Content storage | **Bundled JSON + assets**, one file per lesson, loaded via `require()` at build time | Zero-network by construction. No first-run download, no "please wait". |
| Audio | **expo-audio** (`expo-av` is deprecated) | Playback, preload, and playlist queueing for sentence-by-sentence reading. |
| Tracing / drawing | **react-native-svg** + **react-native-gesture-handler** + **react-native-reanimated** | Glyph outlines as SVG paths; gesture sampling on the UI thread so the ink never lags on a cheap phone. |
| Ephemeral state | **Zustand** | Small, no boilerplate, no context-provider merge conflicts. |
| Server state (V2) | **TanStack Query** | Only when sync arrives. Not in MVP. |
| i18n | **i18next** + `expo-localization`, namespaced files | French is the only shipped locale in MVP, but strings live outside components from day one. |
| Backend (V2) | **Supabase** (Postgres + Auth + Storage) or a small **Fastify + Postgres** service | See §C.6. Deliberately *not* in MVP. |
| Build & release | **EAS Build + EAS Update** | iOS builds without a Mac. **EAS Update lets you ship a corrected `fonio` spelling or a re-recorded audio clip in hours, not in an App Store review cycle.** For a content-heavy literacy app this is a major operational advantage. |
| Testing | **Jest** + **@testing-library/react-native**; **Maestro** for E2E flows | Maestro's YAML flows are far more tractable than Detox for a student team. |
| CI | **GitHub Actions** | typecheck → lint → test → content-validate → EAS build on `main`. |

### Why not the alternatives

- **Flutter** is a legitimate choice and slightly better at custom canvas rendering (relevant to cursive tracing). Rejected because: (a) Dart is a second new thing for a team already learning a new domain; (b) Expo's OTA content-update story has no clean Flutter equivalent, and this app's main post-launch churn is *content*, not code; (c) the JS/TS ecosystem is more likely to match the team's existing skills. If your team already knows Dart, invert this decision — the rest of this plan (workstreams, contracts, data model, branch strategy) transfers to Flutter essentially unchanged.
- **Native Android (Kotlin/Compose)** would give the best low-end performance and the smallest binary, but it is Android-only, which contradicts your requirement.
- **A PWA** would be the cheapest, but offline audio caching and reliable install on low-end Android is fragile, and app-store presence matters for institutional distribution through Batonga.

### Hard non-functional budgets (agree these in Sprint 0)

| Budget | Target | Owner |
|---|---|---|
| Install size (Android AAB) | **≤ 60 MB** | Dev D |
| Cold start on Android Go, 2 GB RAM | **≤ 3.0 s to interactive** | Dev D |
| Audio tap → first sound | **≤ 150 ms** (preloaded) | Dev D |
| Trace stroke input latency | **≤ 32 ms** (2 frames) | Dev B |
| Lesson screen scroll | **60 fps** on a 2019 entry-level Android | Dev A |
| Minimum OS | **Android 8.0 / iOS 15** | Dev C |
| Network calls in MVP | **Zero required.** All optional. | All |
| Smallest touch target | **56 × 56 dp** | Dev C |

## C.2 Information architecture

```
Batonga Lire  (app)
│
├── FIRST RUN
│   ├── Language & voice check        (spoken welcome, big "écouter" button)
│   ├── Create local profile          (first name OR avatar only — no email, no password)
│   └── Placement offer               (« Commencer au début » | « J'en connais déjà »)
│
├── ACCUEIL  (home / dashboard)
│   ├── « Continuer »  → resumes the exact block the learner left
│   ├── Progress ring + streak
│   ├── Today's review (V2)
│   └── Entry to the Parcours
│
├── PARCOURS  (the learning path — vertical, scrollable, one node per lesson)
│   │
│   ├── UNITÉ 1 — LES VOYELLES              Lessons 01–07     [SRC]
│   ├── UNITÉ 2 — LES CONSONNES             Lessons 08–24     [SRC]
│   ├── UNITÉ 3 — DIPHTONGUES ET TEXTES     Lessons 25–56     [SRC]
│   │     └── sub-grouped into 4 blocks of 8 for pacing        [ADAPT]
│   └── UNITÉ 4 — LES CHIFFRES              Digits 0–9        [SRC]
│
├── LEÇON  (the lesson player — one screen, a sequence of blocks)
│   │
│   ├── 1. Objectif        « Aujourd'hui : la lettre t »        [ADAPT]
│   ├── 2. Découverte      illustration + keyword + audio        [SRC]
│   ├── 3. Les formes      print / cursive / capital + audio     [SRC]
│   ├── 4. Reconnaissance  ACTIVITY: find the letter             [ADAPT]
│   ├── 5. Syllabes        the tree, tappable, each syllable spoken [SRC]
│   ├── 6. Construction    ACTIVITY: build the syllable          [ADAPT]
│   ├── 7. Mots            word list, print ⇄ cursive toggle, audio [SRC]
│   ├── 8. Vocabulaire     ACTIVITY: word ↔ meaning / picture    [ADAPT]
│   ├── 9. Phrases         sentences, tap-to-hear, word-by-word  [SRC]
│   ├── 10. Écriture       stroke animation → guided trace       [SRC]→[ADAPT]
│   ├── 11. Lecture        (Unit 3 only) the full text           [SRC]
│   └── 12. Bilan          3–5 mixed questions, then celebration [ADAPT]
│
├── ENTRAÎNEMENT  (practice — free, no progression, low stakes)
│   ├── Revoir une leçon
│   ├── Le mur des lettres   (alphabet reference, p.5 of the book) [SRC]
│   ├── Les chiffres
│   └── Cahier d'écriture    (free trace canvas)
│
├── MES PROGRÈS
│   ├── Path completion, letters mastered, words heard
│   ├── Streak calendar
│   └── Badges                                                    [NEW]
│
└── RÉGLAGES
    ├── Voice speed (normal / lent)
    ├── Default script (scripte / cursive)
    ├── Text size
    ├── Audio download manager (V2)
    ├── Profile / reset progress
    └── About Batonga
```

**Deliberately absent from MVP:** login, social features, leaderboards, chat, ads, in-app purchase, share sheets. Each would add risk and none serves the learner.

## C.3 Module map

```
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
│   audioService  ·  db (SQLite + Drizzle)  ·  syncService  ·  telemetry          │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │
┌───────────────────────────────────────▼─────────────────────────────────────────┐
│              CONTENT PACK  (Dev A owns schema · Dev D owns delivery)            │
│   lessons/*.json  ·  audio/*.m4a  ·  glyphs/*.svg  ·  illustrations/*.svg       │
└─────────────────────────────────────────────────────────────────────────────────┘
```

Justified modules, and what we are **not** building:

| Module | In MVP? | Owner | Note |
|---|---|---|---|
| Content model + validation | ✅ | A | The spine |
| Lesson rendering engine | ✅ | A | 12 block renderers |
| Activity engine | ✅ | B | 5 activity types in MVP |
| Handwriting / tracing | ✅ (print only) | B | Path-following, **not** ML recognition |
| Audio playback | ✅ | D | Bundled clips |
| Local DB + progress | ✅ | D | SQLite |
| Navigation + shell | ✅ | C | expo-router |
| Design system + a11y | ✅ | C | Low-literacy-first |
| Offline support | ✅ | D | By construction — nothing to "support" |
| Gamification | ✅ light: streak + completion. Badges V2 | D | |
| Assessment | ✅ light: end-of-lesson *Bilan* + unit checkpoint | B | |
| **Authentication** | ❌ | — | No learner needs an account to read. V2, only if facilitator dashboards are funded. |
| **Backend / API** | ❌ MVP | D | Contract designed in MVP, implemented V2 |
| **CMS** | ❌ | — | Content is authored as JSON in the repo. A CMS for 4 devs and one fixed book is over-engineering. |
| **Push notifications** | ❌ MVP | C | Local reminders only in V2; push needs a server |
| **Speech recognition** | ❌ | — | Future. See §Q risk R-07. |

## C.4 Offline strategy

The app is **offline by construction, not by fallback**:

- All 56 lessons, all 10 digit pages, all glyph SVGs, all illustrations, and all audio ship **inside the binary**. Estimated total ≈ 25–35 MB (see §C.5).
- SQLite is the only writeable store. Every user action writes locally and returns immediately. Nothing in the UI ever waits on a network call.
- **Every write also appends a row to `sync_outbox`** from day one, even though nothing drains it in MVP. This is a ~30-line investment that makes V2 sync a feature instead of a rewrite. Dev D owns it.
- Online capabilities, when they arrive, are strictly *additive*: outbox drain, content pack update, optional facilitator reporting. If the network never appears, the learner never notices.

## C.5 Asset budget

| Asset class | Count | Format | Est. size |
|---|---|---|---|
| Illustrations (keywords) | 24 | SVG (line art re-drawn from the book) | ~250 KB |
| Glyph outlines (print + digits, with stroke paths) | 62 | SVG paths in one JSON | ~180 KB |
| Glyph outlines (cursive, V2) | 52 | SVG | ~200 KB |
| Fonts (print, cursive, UI) | 3 families | TTF subset | ~1.5 MB |
| **Audio clips** | **≈ 1 200** | AAC 64 kbps mono | **≈ 15–20 MB** |
| Lesson JSON | 67 files | JSON | ~600 KB |
| **Total content** | | | **≈ 20–25 MB** |

At that size, a "download lesson packs" feature is unnecessary complexity. **Bundle everything.** Revisit only if audio exceeds 35 MB.

## C.6 The online layer (designed now, built in V2)

You said offline-first **with online capabilities**. Concretely, that means three things — none of which the learner depends on:

1. **Progress sync** — the outbox drains to a server when a network appears, so a learner can change phone or a facilitator can see cohort progress. Requires the lightest possible identity: a device-generated `learnerId` UUID plus an optional 6-digit **code de reprise** the learner can write down. **Do not build email/password.** A low-literacy learner cannot type an email address, and asking her to is a dignity failure, not just a UX one.
2. **Content updates** — corrected text or re-recorded audio delivered via EAS Update (code + JSON) or a signed content-pack fetch (audio). Versioned by `contentPackVersion`.
3. **Facilitator reporting** — a web view for Batonga staff showing cohort completion. This is a *separate deliverable* and should not consume mobile-team capacity in the first release.

**Recommended V2 backend:** Supabase. Postgres, row-level security, storage for audio packs, and anonymous auth out of the box — roughly a week of Dev D's time versus a month for a hand-rolled service.

---

# D. Four-Developer Work Allocation

## D.1 The slicing principle

The work is sliced **vertically by capability**, not horizontally by layer. Every developer owns data + logic + UI in their domain, so that:

- nobody is "the backend person" waiting for someone to design a screen,
- nobody is "the UI person" blocked on someone else's API,
- every stream produces something demonstrable on a phone by the end of week 2,
- and every stream is independently testable.

## D.2 Allocation table

| Developer | Branch | Primary responsibility | Major features | Main deliverables |
|---|---|---|---|---|
| **Dev A** | `dev/content-engine` | **Content & Lesson Engine** — the digital representation of the book and the machinery that renders it | Content schema & validator · lesson authoring pipeline · `LessonPlayer` · 12 block renderers · script/cursive typography · illustration & glyph asset pipeline · transcription of all 56 lessons | `@core/content` types · `contentRepository` · `<LessonPlayer/>` · 67 validated lesson JSON files · `validate-content` CLI · errata register |
| **Dev B** | `dev/activities` | **Interactive Activities, Writing & Assessment** — everything the learner *does* | `ActivityHost` · 5 MVP activity types · guided **trace canvas** + stroke scoring · feedback & correction UX · *Bilan* end-of-lesson check · unit checkpoint · activity generation from content | `<ActivityHost/>` · `ActivityResult` contract · `<TraceCanvas/>` + scoring lib · activity generator · assessment rules |
| **Dev C** | `dev/shell-ux` | **App Shell, Navigation & Design System** — everything around the lesson, and how it all looks | Onboarding · local profile · Accueil · Parcours map · Entraînement · Réglages · design tokens & UI primitives · accessibility · French i18n · low-literacy UX patterns | expo-router route tree · `@ui` component library · `theme.ts` · `fr` locale files · a11y checklist + audit · UX pattern guide |
| **Dev D** | `dev/data-audio` | **Data, Progress, Audio & Platform** — the layer everything stands on | SQLite schema + migrations · repositories · progress & mastery engine · streaks · `audioService` + preloading · **audio production pipeline & manifest** · sync outbox + V2 sync client · CI, EAS, perf budgets | `@core/db` + migrations · `progressService` · `audioService` · `audio-manifest.json` + recording kit · `sync_outbox` · CI pipeline · perf report |

## D.3 Balance check

| | Dev A | Dev B | Dev C | Dev D |
|---|---|---|---|---|
| Screens owned | 1 (the player, 12 blocks) | 6 activity surfaces + trace | 9 screens | 3 screens + settings panels |
| Algorithmic difficulty | Medium | **High** (stroke scoring) | Low–Medium | **High** (mastery, sync, perf) |
| Data-entry volume | **High** (56 lessons transcribed) | Low | Medium (strings) | **High** (1 200 audio clips managed) |
| External dependencies | Illustration redraw | — | Font licensing | Voice talent, EAS account |
| Blocks others if late | **Yes** — content schema | No | **Yes** — theme + primitives | **Yes** — DB schema + audio IDs |

Deliberately, the two "blocks others" risks (A's schema, C's primitives, D's schema) are **all resolved in Sprint 0**, before independent work begins. See §R.

---

# E. Detailed Branch Ownership

Branches are named by **domain, not by person**, so that when these four students hand the project on, `dev/content-engine` still means something. Ownership is recorded in `CODEOWNERS`, where names are cheap to change.

## E.1 `dev/content-engine` — Developer A

**Purpose.** Turn a 104-page printed book into validated, typed, renderable data — and render it faithfully.

**Owns (exclusive write access):**
```
src/core/content/          schema, types, repository, loaders
src/features/lesson/       LessonPlayer, block renderers, player state
content/lessons/           L01.json … L56.json, D0.json … D9.json, alphabet.json
content/schema/            JSON Schema definitions
content/errata.json        documented deviations from the printed book
assets/illustrations/      24 keyword SVGs
assets/glyphs/             stroke-path SVGs (shape data; B owns the tracing behaviour)
tools/validate-content.ts  the CLI that CI runs
docs/content-authoring.md
```

**Exposes:**
```ts
// src/core/content/index.ts  — the public surface, frozen after Sprint 0
export type { Lesson, LessonBlock, Unit, VocabularyItem, ReadingText, Grapheme };
export const contentRepository: {
  getUnits(): Unit[];
  getLesson(id: LessonId): Lesson;
  getLessonsByUnit(unitId: UnitId): LessonSummary[];
  getVocabulary(filter?: VocabFilter): VocabularyItem[];
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
```

**Depends on:** `@ui` primitives from C (mockable), `audioService` from D (stub returns a resolved promise), `ActivityHost` from B (stub renders a "Continuer" button).

**Deliverables:** all 67 content files transcribed and validated; 12 working block renderers; the validator wired into CI; a Storybook-style `/dev/blocks` screen showing every block type with fixture data.

**Definition of done:** every lesson in the book renders end-to-end from JSON with zero hardcoded lesson content anywhere in `src/`; `npm run validate-content` passes; a native French speaker has proof-read all 56 lessons against the PDF and signed off in `docs/transcription-signoff.md`.

## E.2 `dev/activities` — Developer B

**Purpose.** Everything the learner does with her fingers, and everything that tells her whether she got it right.

**Owns:**
```
src/features/activity/         ActivityHost, registry, per-type components
src/features/activity/types/   tap-identify, listen-choose, syllable-build,
                               missing-letter, word-match  (+ V2 types)
src/features/writing/          TraceCanvas, stroke sampler, scoring
src/core/scoring/              pure scoring functions (heavily unit-tested)
src/features/assessment/       Bilan, unit checkpoint, result summary
docs/activity-catalogue.md
```

**Exposes:**
```ts
export function ActivityHost(props: {
  spec: ActivitySpec;
  onComplete(result: ActivityResult): void;
  onSkip(reason: 'user' | 'timeout'): void;
});
export function TraceCanvas(props: {
  glyph: GlyphSpec;            // paths + stroke order, from A's assets
  mode: 'demo' | 'guided' | 'free';
  onStrokeComplete(s: StrokeResult): void;
  onComplete(r: TraceResult): void;
});
export function scoreTrace(expected: GlyphSpec, actual: Point[][]): TraceResult; // pure
```

**Depends on:** `ActivitySpec` and `GlyphSpec` types from A (frozen Sprint 0); `@ui` from C; `audioService` from D.

**Deliverables:** 5 MVP activity types, each with fixture-driven tests; the trace canvas working for all 62 print glyphs + digits; `scoreTrace` with ≥ 90 % unit-test coverage; a `/dev/activities` gallery screen.

**Definition of done:** every activity type is playable from a fixture without the rest of the app; scoring is deterministic and covered by tests; feedback is delivered in **audio + colour + icon simultaneously** (never colour alone — see §P); a learner can always advance past a failed attempt.

## E.3 `dev/shell-ux` — Developer C

**Purpose.** Make the app navigable and usable by someone who cannot read the interface — and give the other three a design system so they stop inventing buttons.

**Owns:**
```
app/                       ALL expo-router route files
src/ui/                    Button, Card, Icon, ProgressRing, Sheet, ListRow…
src/ui/theme.ts            colour, spacing, radius, type scale, motion tokens
src/features/onboarding/
src/features/home/         Accueil
src/features/path/         Parcours map
src/features/practice/     Entraînement
src/features/settings/     Réglages
src/features/profile/
src/i18n/                  fr/*.json  (one namespace per feature)
assets/fonts/
docs/ux-principles.md · docs/a11y-checklist.md
```

**Exposes:**
```ts
export { Button, IconButton, Card, ListRow, ProgressRing, Sheet, Toast } from '@ui';
export { theme, useTheme } from '@ui/theme';
export const nav: {
  toLesson(id: LessonId, opts?: { block?: number }): void;
  toPath(unitId?: UnitId): void;
  toHome(): void;
  toPractice(kind: PracticeKind): void;
};
```

**Depends on:** `progressService` from D for the Parcours node states (mockable with a fixture); `contentRepository` from A for the unit/lesson list (mockable).

**Deliverables:** every route file present and navigable with placeholder bodies **by end of Sprint 1** (this is what unblocks everyone); the `@ui` library with all primitives; French strings for all chrome; an accessibility audit against the checklist; the UX principle guide in §K.1.

**Definition of done:** the full navigation graph is walkable on a device with no lesson content loaded; every interactive element is ≥ 56 dp and has a spoken label; the app is usable at 200 % font scale; contrast ≥ 4.5:1 everywhere; screen-reader labels present in French.

## E.4 `dev/data-audio` — Developer D

**Purpose.** The floor the other three stand on: persistence, progress, sound, and shipping.

**Owns:**
```
src/core/db/               schema.ts, client, migrations/, repositories/
src/core/progress/         progressService, masteryEngine, streaks, reviewQueue
src/core/audio/            audioService, preloader, cache, manifest loader
src/core/sync/             outbox, syncClient (V2), conflict rules
src/core/telemetry/        local-only event log (no third-party analytics)
content/audio/             the 1 200 clips + audio-manifest.json
tools/audio-pipeline/      normalise, encode, verify-manifest scripts
.github/workflows/         CI
eas.json · app.config.ts
docs/audio-production.md · docs/data-model.md
```

**Exposes:**
```ts
export const audioService: {
  play(id: AudioId, opts?: { rate?: 'normal' | 'slow' }): Promise<void>;
  playSequence(ids: AudioId[], gapMs?: number): Promise<void>;
  stop(): void;
  preload(ids: AudioId[]): Promise<void>;
  has(id: AudioId): boolean;               // false → caller shows no speaker icon
};
export const progressService: {
  recordActivityResult(r: ActivityResult): Promise<void>;
  recordBlockComplete(lessonId: LessonId, blockIndex: number): Promise<void>;
  completeLesson(lessonId: LessonId, summary: LessonSummary): Promise<LessonOutcome>;
  getLessonState(lessonId: LessonId): Promise<LessonState>;
  getPathState(): Promise<PathState>;      // what C's Parcours renders
  getResumePoint(): Promise<ResumePoint | null>;
  getStreak(): Promise<StreakState>;
};
```

**Depends on:** `ActivityResult` from B and `LessonId`/`AudioId` from A — both frozen in Sprint 0. Nothing else.

**Deliverables:** the schema with migrations; all repositories; the mastery engine with unit tests; `audioService` working against real clips; **the audio manifest and recording kit** (script, naming convention, technical spec) delivered to the voice talent by end of Sprint 2; CI green; a perf report against the §C.1 budgets on a real low-end device.

**Definition of done:** all four budgets in §C.1 measured and met on physical hardware; migrations run forward cleanly from an empty DB and from the previous released version; `audioService.has()` returns correctly for every ID referenced in content (CI-checked cross-reference); the sync outbox records every mutation even though nothing drains it.

## E.5 What no branch may do

| Rule | Reason |
|---|---|
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

```
batonga-lire/
│
├── app/                                    ◆ C  (expo-router — file = route)
│   ├── _layout.tsx                         ◆ C  ⚠ shared: see §O.4
│   ├── index.tsx                              Accueil
│   ├── onboarding/[step].tsx
│   ├── parcours/index.tsx
│   ├── parcours/[unitId].tsx
│   ├── lecon/[lessonId].tsx                   thin wrapper → <LessonPlayer/>
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
│   │   ├── writing/                        ◆ B   TraceCanvas + sampler
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
│   ├── DEVELOPMENT_PLAN.md      ← this file
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
│   ├── pull_request_template.md
│   └── workflows/ci.yml         ◆ D
│
├── app.config.ts   eas.json     ◆ D
├── package.json                 ⚠ Build Steward only
├── tsconfig.json                ⚠ 2 approvals
└── .gitattributes  .gitignore  .env.example
```

**Legend:** ◆ = single owner · ⚠ = shared/protected file, see §O.

### `.github/CODEOWNERS`

```
# Default: any change needs a review from someone
*                               @dev-a @dev-b @dev-c @dev-d

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

# Protected: two approvals required (enforce in branch protection)
/src/core/contracts/            @dev-a @dev-b @dev-c @dev-d
/package.json                   @dev-c @dev-d
/tsconfig.json                  @dev-a @dev-d
/app/_layout.tsx                @dev-c @dev-d
```

---

# G. Data Model

Three tiers, and the tier decides where the data lives and who owns it.

| Tier | Where it lives | Mutable at runtime? | Owner |
|---|---|---|---|
| **Static educational content** | Bundled JSON, loaded read-only | No | **A** (audio manifest: D) |
| **Learner data** | SQLite on device | Yes | **D** |
| **App configuration** | SQLite `settings` + build-time constants | Yes (settings) | **C** (values) / **D** (storage) |

## G.1 Static content entities — owner: Dev A

### `ContentPack`
| Field | Type | Purpose |
|---|---|---|
| `version` | `string` (semver) | Compared against DB `content_version` to trigger migrations |
| `sourceEdition` | `string` | `"Batonga Syllabaire 2e éd., T2 2025"` — provenance, shown in About |
| `locale` | `'fr'` | |
| `units` | `Unit[]` | |

### `Unit`
| Field | Type | Notes |
|---|---|---|
| `id` | `UnitId` | `'voyelles' \| 'consonnes' \| 'graphemes' \| 'chiffres'` |
| `order` | `number` | 1–4 |
| `title` / `subtitle` | `string` | French, learner-facing |
| `lessonIds` | `LessonId[]` | ordered |
| `iconId` | `string` | |
| `sourcePages` | `[number, number]` | Traceability back to the book |

### `Lesson` — the central entity
| Field | Type | Notes |
|---|---|---|
| `id` | `LessonId` | `'L01'…'L56'`, `'D0'…'D9'` |
| `unitId` | `UnitId` | |
| `order` | `number` | **Never reorder. §B.5.** |
| `archetype` | `LessonArchetype` | `'vowel' \| 'consonant' \| 'grapheme' \| 'numeral' \| 'reference'` |
| `title` | `string` | `"Leçon 08 — la lettre t"` |
| `focus` | `Focus` | `{ kind:'letter'\|'grapheme'\|'digit', glyphs: string[] }` |
| `objective` | `string` | **[ADAPT]** — written by the team; the book states none |
| `prerequisiteIds` | `LessonId[]` | Encodes cumulative decoding (§B.5) |
| `blocks` | `LessonBlock[]` | **The lesson is its block sequence.** §I |
| `sourcePages` | `number[]` | |
| `errata` | `ErratumRef[]` | Links to `errata.json` |

### `LessonBlock` — discriminated union, 12 members
| `type` | Payload (abridged) | From |
|---|---|---|
| `keyword-illustration` | `{ illustrationId, wordPrint, wordCursive, audioId }` | [SRC] |
| `letter-forms` | `{ forms: GlyphRef[] }` — print lower/upper, cursive lower/upper, accented | [SRC] |
| `letter-repetition` | `{ glyphId, rows, script }` | [SRC] |
| `syllable-tree` | `{ consonant, branches: {vowel, syllablePrint, syllableCursive, derived?[], audioId}[] }` | [SRC] |
| `syllable-strip` | `{ syllables: SyllableRef[] }` | [SRC] |
| `word-list` | `{ items: VocabularyItemRef[], showCursive: boolean }` | [SRC] |
| `sentence-list` | `{ sentences: SentenceRef[] }` | [SRC] |
| `grapheme-heading` | `{ graphemes: string[], renderings: Script[] }` | [SRC] |
| `reading-text` | `{ textId }` | [SRC] |
| `stroke-diagram` | `{ glyphId, strokes: StrokePath[] }` | [SRC] |
| `writing-practice` | `{ models: WritingModel[], script }` | [SRC] → [ADAPT] |
| `activity` | `{ spec: ActivitySpec }` | [ADAPT] |

### `VocabularyItem`
| Field | Type | Notes |
|---|---|---|
| `id` | `VocabId` | e.g. `'v_fonio'` |
| `print` / `cursive` | `string` | Cursive is normally the same string rendered in the cursive font; the field exists because the book occasionally differs |
| `article` | `string \| null` | `un / une / le / la` — the book teaches words with articles |
| `syllables` | `string[]` | Decoding support **[ADAPT]** |
| `audioId` | `AudioId \| null` | |
| `illustrationId` | `string \| null` | Only 24 words have illustrations |
| `themes` | `string[]` | `['commerce','maison','nourriture','école']` **[ADAPT]** |
| `firstLessonId` | `LessonId` | Where it is introduced |

### `ReadingText`
| Field | Type | Notes |
|---|---|---|
| `id` | `TextId` | |
| `title` | `string` | `"Le marché"` |
| `kind` | `'narrative' \| 'dialogue' \| 'advice-list'` | Drives layout — §B.3 |
| `segments` | `TextSegment[]` | Sentence-level, each with `audioId` and optional `speaker` |
| `lessonId` | `LessonId` | |
| `wordCount` | `number` | For pacing |

### `Glyph`
| Field | Type | Notes |
|---|---|---|
| `id` | `GlyphId` | `'t_print_lower'`, `'8_numeral'` |
| `char` / `script` / `case` | | |
| `outlinePath` | `string` | SVG path for display |
| `strokes` | `StrokePath[]` | Ordered; each has `d`, `startPoint`, `direction`, `checkpoints[]`. **This is what makes tracing possible.** |
| `sourcePage` | `number` | |

### `AudioAsset` — owner: Dev D
| Field | Type | Notes |
|---|---|---|
| `id` | `AudioId` | Deterministic: `letter.t.sound`, `syll.ta`, `word.fonio`, `sent.L09.02`, `text.L27.s04`, `digit.7.name` |
| `file` | `string` | Path under `content/audio/clips/` |
| `durationMs` / `speaker` / `recordedAt` | | |
| `status` | `'recorded' \| 'placeholder' \| 'missing'` | **Lets the app degrade gracefully: no clip → no speaker icon, never a broken button.** |

## G.2 Learner data entities — owner: Dev D

### `Learner`
`id` (UUID, device-generated) · `displayName` · `avatarId` · `createdAt` · `resumeCode` (6 digits, V2) · `preferredScript` · `voiceRate`
**No email. No password. No phone number.** §C.6.

### `LessonState`
`learnerId` + `lessonId` (PK) · `status` (`locked|available|in_progress|completed`) · `lastBlockIndex` · `startedAt` · `completedAt` · `completionCount` · `bestScore`

### `ActivityAttempt`
`id` · `learnerId` · `lessonId` · `activityId` · `activityType` · `isCorrect` · `score` (0–1) · `durationMs` · `hintsUsed` · `attemptNumber` · `createdAt`
Written by D on every `ActivityResult` from B. The raw substrate for mastery.

### `TraceAttempt`
`id` · `learnerId` · `glyphId` · `score` · `strokeScores` (JSON) · `strokeCount` · `durationMs` · `createdAt`
Separate from `ActivityAttempt` because its metrics are different in kind and because handwriting progress deserves its own view.

### `MasteryRecord`
`learnerId` + `targetType` (`letter|syllable|word|grapheme|digit`) + `targetId` (PK) · `strength` (0–1) · `exposures` · `correctCount` · `lastSeenAt` · `nextReviewAt` (V2)
**Why it exists:** the app must be able to say "she can read *ta* but not *tê*". A per-lesson percentage cannot express that, and the review queue in V2 depends on it.

### `Achievement` · `StreakLog` · `Session` · `SyncOutbox`
`Achievement`: `learnerId` + `achievementId` · `unlockedAt` · `seen` — **[NEW]**
`StreakLog`: `learnerId` + `date` (PK) · `minutesActive` · `lessonsCompleted`
`Session`: `id` · `startedAt` · `endedAt` · `lessonsTouched` — for pacing analytics, local only
`SyncOutbox`: `id` · `entity` · `entityId` · `op` · `payload` (JSON) · `createdAt` · `syncedAt` (null until drained) — **written in MVP, drained in V2**

## G.3 Configuration

`AppSettings` (SQLite, single row): `preferredScript`, `voiceRate`, `textScale`, `hapticsEnabled`, `reminderTime`, `contentPackVersion`, `onboardingCompleted`
`FeatureFlags` (build-time constants, D owns): `cursiveTracing`, `syncEnabled`, `comprehensionQuestions`, `badges` — every V2 feature lands behind a flag, off by default, so `dev/*` branches can merge unfinished work into `develop` safely.

## G.4 Relationship diagram

```
ContentPack 1─┬─* Unit 1─* Lesson 1─* LessonBlock
              │                │
              │                ├─* VocabularyItem *─1 AudioAsset
              │                ├─0..1 ReadingText 1─* TextSegment *─1 AudioAsset
              │                └─* Glyph 1─* StrokePath
              │
Learner 1─┬─* LessonState        *─1 Lesson
          ├─* ActivityAttempt    *─1 Lesson
          ├─* TraceAttempt       *─1 Glyph
          ├─* MasteryRecord      → targets letters/syllables/words/digits
          ├─* Achievement
          ├─* StreakLog
          └─* SyncOutbox
```

---

# H. Module Interfaces

These live in `src/core/contracts/`. **They are written and frozen in Sprint 0, before feature code exists.** Everything in §M depends on this being true.

## H.1 The interface rules

1. Contracts are **types and function signatures only** — no implementation, no imports from feature code.
2. A contract change needs a PR with **two approvals from other stream owners** and a note in `docs/adr/`.
3. Every consumer of another stream's module must be able to swap in a **fixture implementation**. Each owner ships `__fixtures__/` alongside the real thing in Sprint 1.
4. Modules communicate through **calls and callbacks**, never by reaching into each other's state.

## H.2 A → B : Lesson Engine hands off to Activity Engine

The single most important interface in the app.

```ts
// contracts/activity.ts   (owner of the file: shared; drafted by B)

export type ActivitySpec = {
  id: string;                       // stable, e.g. 'L08.a1'
  type: ActivityType;               // registry key
  lessonId: LessonId;
  prompt: { text: string; audioId: AudioId | null };
  payload: unknown;                 // narrowed by `type`
  scoring: { passThreshold: number; maxAttempts: number | null };
  allowSkip: boolean;               // MUST be true in MVP — see §J.3
};

export type ActivityResult = {
  activityId: string;
  activityType: ActivityType;
  lessonId: LessonId;
  outcome: 'correct' | 'incorrect' | 'partial' | 'skipped';
  score: number;                    // 0..1
  attempts: number;
  hintsUsed: number;
  durationMs: number;
  targets: MasteryTarget[];         // what this attempt is evidence about
  detail?: Record<string, unknown>; // type-specific; never read by A or D
};

export type MasteryTarget = {
  type: 'letter' | 'syllable' | 'word' | 'grapheme' | 'digit';
  id: string;
  correct: boolean;
};
```

**Behaviour contract**
- A renders `<ActivityHost spec onComplete onSkip/>` and **must not** inspect `payload`.
- B **must** call exactly one of `onComplete` or `onSkip`, exactly once.
- B **must not** call `progressService` itself — the result flows A → D. One writer, one path.
- Every activity is skippable in MVP. A learner who cannot pass an activity must never be trapped.

**Error handling.** Malformed `payload` → B renders a neutral "Continuer" card, logs a telemetry warning, and calls `onSkip('user')`. **A content bug must never crash a lesson.** CI's content validator is what prevents this reaching production.

## H.3 A/B → D : recording progress

```ts
progressService.recordActivityResult(result: ActivityResult): Promise<void>
```
- Idempotent on `activityId + attemptNumber`.
- Writes `ActivityAttempt`, updates `MasteryRecord` for each `target`, appends to `SyncOutbox`.
- **Never throws to the caller.** DB failure is logged and swallowed; a broken disk must not stop a lesson. Returns a resolved promise regardless.

```ts
progressService.completeLesson(id, summary): Promise<LessonOutcome>
// LessonOutcome = { unlockedLessonIds, newAchievements, streak, isFirstCompletion }
```
A calls this once at the end of a lesson; the returned `LessonOutcome` is what the celebration screen renders. **A does not compute unlocking** — D owns progression rules, because they depend on mastery data A cannot see.

## H.4 C → A : launching a lesson

C's route `app/lecon/[lessonId].tsx` is a **thin wrapper only**:
```tsx
export default function LessonRoute() {
  const { lessonId } = useLocalSearchParams<{ lessonId: LessonId }>();
  const resume = useResumePoint(lessonId);              // D
  return (
    <LessonPlayer                                        {/* A */}
      lessonId={lessonId}
      startAtBlock={resume?.blockIndex}
      onBlockComplete={(i) => progressService.recordBlockComplete(lessonId, i)}
      onLessonComplete={(s) => { progressService.completeLesson(lessonId, s); nav.toPath(); }}
    />
  );
}
```
C never imports a block renderer. A never imports a route. This is the seam.

## H.5 D → C : what the Parcours renders

```ts
type PathState = {
  units: Array<{
    unitId: UnitId;
    completedCount: number; totalCount: number;
    nodes: Array<{
      lessonId: LessonId;
      status: 'locked' | 'available' | 'in_progress' | 'completed';
      score: number | null;
      isNext: boolean;                 // exactly one node app-wide
    }>;
  }>;
  resume: ResumePoint | null;
};
```
C renders `PathState` and nothing else. **C contains no progression logic** — no "if lesson 7 done then unlock 8" anywhere in the shell.

## H.6 Everyone → D : audio

```ts
audioService.play(id, { rate }): Promise<void>
audioService.has(id): boolean
```
**The `has()` rule:** any component about to render a speaker icon calls `has()` first. If the clip is not there yet, the icon is not rendered. This is what lets Dev A, B and C build every screen in weeks 1–8 while Dev D is still in the recording studio — **no stream is ever blocked on audio.**

## H.7 B → A : glyph data for tracing

```ts
type GlyphSpec = {
  id: GlyphId; char: string;
  script: 'print' | 'cursive'; case: 'lower' | 'upper' | 'digit';
  viewBox: [number, number, number, number];
  outlinePath: string;
  strokes: Array<{
    order: number; d: string;
    startPoint: [number, number];
    direction: 'down'|'up'|'left'|'right'|'cw'|'ccw';
    checkpoints: Array<[number, number]>;   // ≥ 6, evenly spaced — B scores against these
  }>;
};
```
A produces the data (from the book's arrow diagrams); B consumes it and owns all scoring. **A never writes scoring code; B never edits an SVG.**

## H.8 Event bus (deliberately minimal)

One typed emitter in `contracts/events.ts` for genuinely cross-cutting facts only:
`lesson:completed` · `achievement:unlocked` · `content:updated` · `audio:missing`
Anything else goes through a direct call. An event bus is a merge-conflict magnet and a debugging tax; keep it tiny.

---

# I. Lesson Architecture

## I.1 The decision: data-driven templates, not hardcoded screens

**Recommendation: option B — a reusable, data-driven lesson engine. Emphatically.**

The reasoning is arithmetic before it is architectural:

- The book contains **67 learner-facing lesson units** (24 letter lessons + 32 grapheme lessons + 10 digit pages + 1 alphabet reference) across **~90 pages**.
- Those 67 units use **exactly 5 layout archetypes** and **12 distinct content-block types**.
- The consonant lessons (8–24) are **structurally identical to one another** — 17 instances of one template with different data. The grapheme lessons (25–56) are **32 instances of a second template**. The digit pages are **10 instances of a third**.

Hardcoding would mean **67 screens averaging ~200 lines = ~13 000 lines of near-duplicate JSX**, in which a change to how word lists show cursive requires 56 edits and a typo fix requires finding the right file among 67. It would also make the content un-reviewable: Batonga cannot proof-read TSX.

The data-driven engine instead gives:
- **~12 renderers ≈ 1 200 lines of code, once.** A layout improvement lands everywhere at once.
- **Content reviewable by non-programmers.** A French-speaking reviewer reads JSON, not JSX.
- **CI-verifiable content.** `validate-content` can assert that every `audioId` exists, every `prerequisiteId` is a real earlier lesson, every glyph referenced has stroke data, and no lesson uses a letter not yet taught. **That last check mechanically enforces the book's cumulative decoding rule** (§B.5) — a guarantee that is simply impossible with hardcoded screens.
- **Clean 4-way parallelism.** A builds renderers against fixtures while transcription proceeds independently; B builds activities against fixtures; neither waits.
- **A V2 CMS becomes possible** without rewriting the app.

**The one legitimate objection** is that a few pages have quirks (Lesson 8/16's extended trees, Lesson 21's restricted tree, Lesson 24's missing sentences, Lesson 56's two-page spread). These are handled by *optional fields in the block payloads*, not by escaping to bespoke screens. If a genuine one-off ever appears, the `activity` block type can host a custom component — an escape hatch that has so far proved unnecessary.

## I.2 The five archetypes

### Archetype 1 — `vowel` (Lessons 1–7)
```
objective → keyword-illustration → letter-forms → letter-repetition
→ [activity: tap-identify] → word-list → [activity: listen-choose]
→ stroke-diagram → writing-practice → [activity: trace] → bilan
```

### Archetype 2 — `consonant` (Lessons 8–24)
```
objective → keyword-illustration → letter-forms → letter-repetition
→ [activity: tap-identify]
→ syllable-tree → syllable-strip → [activity: syllable-build]
→ word-list → [activity: missing-letter]
→ sentence-list → [activity: word-match]
→ stroke-diagram → writing-practice → [activity: trace]
→ bilan
```

### Archetype 3 — `grapheme` (Lessons 25–56)
```
objective → grapheme-heading → syllable-strip → [activity: listen-choose]
→ word-list → [activity: missing-letter]
→ reading-text            ← the centrepiece; tap any sentence to hear it
→ [activity: word-match on text vocabulary]
→ bilan
```
Lessons 46, 48, 49, 54 simply omit `reading-text` — the array is shorter. No code branch, no special case.

### Archetype 4 — `numeral` (Digits 0–9)
```
objective → numeral-card (digit + French word + audio)
→ [activity: tap-identify digit] → [activity: listen-choose digit]
→ stroke-diagram → writing-practice → [activity: trace] → bilan
```

### Archetype 5 — `reference` (the alphabet wall, book p.5)
```
grapheme-heading (all 26) → letter-forms grid (4 scripts) — free browsing, no bilan
```

## I.3 A worked example — Lesson 08

Abridged, to show the shape. The full file lives at `content/lessons/L08.json`.

```jsonc
{
  "id": "L08",
  "unitId": "consonnes",
  "order": 8,
  "archetype": "consonant",
  "title": "Leçon 08 — la lettre t",
  "focus": { "kind": "letter", "glyphs": ["t", "T"] },
  "objective": "Reconnaître, entendre et écrire la lettre t, et lire les syllabes en t.",
  "prerequisiteIds": ["L01","L02","L03","L04","L05","L06"],
  "sourcePages": [20, 21],
  "blocks": [
    { "type": "keyword-illustration",
      "illustrationId": "ill_tete", "wordPrint": "une tête",
      "wordCursive": "une tête", "audioId": "word.tete" },

    { "type": "letter-forms",
      "forms": [
        { "glyphId": "t_print_lower",  "audioId": "letter.t.sound" },
        { "glyphId": "t_cursive_lower","audioId": "letter.t.sound" },
        { "glyphId": "T_print_upper",  "audioId": "letter.t.name"  }
      ]},

    { "type": "letter-repetition", "glyphId": "t_print_lower", "rows": 2, "script": "print" },

    { "type": "activity",
      "spec": { "id": "L08.a1", "type": "tap-identify", "lessonId": "L08",
                "prompt": { "text": "Touche la lettre t", "audioId": "prompt.touche.t" },
                "payload": { "target": "t", "distractors": ["i","o","u","a","e"], "gridSize": 6 },
                "scoring": { "passThreshold": 0.8, "maxAttempts": null },
                "allowSkip": true }},

    // NOTE — fidelity detail: the printed tree on p.20 has SEVEN branches
    // (no "tè"), while the syllable strip below it lists EIGHT syllables
    // (including "tè"). We reproduce both exactly as printed rather than
    // "tidying" the tree. `derived` holds the third column of the printed
    // tree; the fourth column is the same word in cursive, so it is a
    // rendering concern, not extra data.
    { "type": "syllable-tree",
      "consonant": "t",
      "branches": [
        { "vowel": "i", "syllablePrint": "ti", "derived": ["tite"], "audioId": "syll.ti" },
        { "vowel": "u", "syllablePrint": "tu", "derived": ["tutu"], "audioId": "syll.tu" },
        { "vowel": "o", "syllablePrint": "to", "derived": ["toto"], "audioId": "syll.to" },
        { "vowel": "a", "syllablePrint": "ta", "derived": ["tata"], "audioId": "syll.ta" },
        { "vowel": "e", "syllablePrint": "te", "derived": ["tate"], "audioId": "syll.te" },
        { "vowel": "é", "syllablePrint": "té", "derived": ["taté"], "audioId": "syll.te_acute" },
        { "vowel": "ê", "syllablePrint": "tê", "derived": ["tête"], "audioId": "syll.te_circ" }
      ]},

    { "type": "syllable-strip",
      "syllables": ["ti","tu","to","ta","te","té","tè","tê"] },

    { "type": "activity",
      "spec": { "id": "L08.a2", "type": "syllable-build", "lessonId": "L08",
                "prompt": { "text": "Écoute et construis la syllabe", "audioId": "prompt.construis" },
                "payload": { "consonants": ["t"], "vowels": ["i","u","o","a","e","é","è","ê"],
                             "rounds": 5 },
                "scoring": { "passThreshold": 0.6, "maxAttempts": null }, "allowSkip": true }},

    { "type": "word-list", "showCursive": true,
      "items": ["v_tete","v_toto","v_tate","v_ote","v_tata","v_tetu"] },

    { "type": "sentence-list",
      "sentences": [
        { "id": "L08.s1", "text": "toto tâte ta tête.",  "audioId": "sent.L08.01" },
        { "id": "L08.s2", "text": "toto as-tu ta tête ?","audioId": "sent.L08.02" },
        { "id": "L08.s3", "text": "tata est têtu.",       "audioId": "sent.L08.03" },
        { "id": "L08.s4", "text": "tata ôte ta tête.",    "audioId": "sent.L08.04" }
      ]},

    { "type": "stroke-diagram", "glyphId": "t_print_lower" },
    { "type": "writing-practice",
      "script": "print",
      "models": [
        { "glyphId": "t_print_lower" }, { "glyphId": "T_print_upper" },
        { "word": "tête" }
      ]},
    { "type": "activity",
      "spec": { "id": "L08.a3", "type": "trace", "lessonId": "L08",
                "prompt": { "text": "Écris la lettre t", "audioId": "prompt.ecris.t" },
                "payload": { "glyphIds": ["t_print_lower","T_print_upper"] },
                "scoring": { "passThreshold": 0.55, "maxAttempts": null }, "allowSkip": true }}
  ]
}
```

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

**Part Two adds rules 9–14** — syllable integrity, distractor decodability, icon presence, audio-ID resolution in both directions, protected terms, and comprehension decodability. See §T.6.
---

# J. Activity Mapping

Reminder from §A.4: **the book contains no exercises.** Its activities are read-aloud, copy, and trace. Every interaction below is therefore an adaptation or an addition, and each is justified against what the page is actually trying to teach.

## J.1 The mapping table

| # | Source element (page) | Learning objective | Digital interaction | Diff. | Feedback | Data required | Dev | Tag |
|---|---|---|---|---|---|---|---|---|
| 1 | Keyword + illustration, e.g. *un épi* (p.7) | Anchor the sound in a known object | Illustration + word; **tap anywhere to hear it**; tap the word to hear it segmented | 1 | Audio only; nothing to get wrong | illustration, word, audio | A | [ADAPT] |
| 2 | Letter in 3–6 renderings (p.7) | Recognise the same letter across scripts and cases | Cards for each rendering; tap = hear the sound; **toggle scripte ⇄ cursive** | 1 | Audio | glyphs, audio | A | [ADAPT] |
| 3 | Three rows of the repeated letter (p.7) | Visual saturation | **Tap-to-identify**: a 6-cell grid of letters, find every *t*. Replaces passive rows with active search | 1 | Correct → green + chime + spoken letter; wrong → grey shake + spoken correct letter, no penalty | target + distractors from taught letters | B | [ADAPT] |
| 4 | Syllable tree (p.20) | **The core mechanic**: consonant + vowel = syllable | Animated tree; tap a vowel → the arrow draws, the syllable appears in both scripts, the audio plays. Then **syllable-build**: hear `ta`, drag `t` + `a` together | 2 | Blend audio on success (`t`…`a`…`ta`); on error, play the two candidate syllables side by side | tree branches, syllable audio | A (display) / B (build) | [SRC] display, [ADAPT] activity |
| 5 | Syllable strip (p.20) | Fluent syllable reading | Tap any syllable to hear; **"Lire tout"** plays the strip in sequence with each syllable highlighted | 2 | Audio | syllables, audio | A | [ADAPT] |
| 6 | Word list, print + cursive (p.20) | Read whole words from known syllables | List with a script toggle; tap a word → hear it; **long-press → hear it syllable by syllable** | 2 | Audio | vocab items, syllabification | A | [ADAPT] |
| 7 | Word list (as practice) | Retrieve the word from its sound | **Listen-and-choose**: hear a word, pick it from 3–4 written options | 2 | Correct → the word is spoken and highlighted; wrong → both words spoken so she hears the contrast | vocab + audio | B | [ADAPT] |
| 8 | Word list (as practice) | Attend to individual letters inside a word | **Missing letter**: `fa_ine` with a keypad of 4 candidates | 3 | The completed word is spoken; wrong letters produce the *wrong* word spoken aloud — the most instructive error feedback available | vocab, target index | B | [ADAPT] |
| 9 | Illustrated keywords (24 across the book) | Word ↔ meaning | **Word-match**: pair 4 words with 4 pictures | 2 | Per-pair audio | the 24 illustrated items only | B | [ADAPT] |
| 10 | Sentences, e.g. *papa tape toto.* (p.22) | Read a connected string | Sentence shown; tap = full reading; **tap a single word = that word**; "mot à mot" mode highlights each word as it is spoken | 3 | Audio | sentences, word-level timing (or per-word clips) | A | [ADAPT] |
| 11 | Sentences (as practice) | Rebuild syntax | **Sentence-build**: hear the sentence, drag its word tiles into order | 4 | Reading of the assembled attempt — she hears her own word order | sentence tokens | B | [ADAPT], **V2** |
| 12 | Stroke-order arrows (p.6, 20) | Learn the motor path | **Animated stroke demo**: the pen traces the glyph at learner-controlled speed, replayable | 2 | None; demonstration | glyph strokes | A | [ADAPT] |
| 13 | Ruled writing lines (p.7, 21) | Produce the letter by hand | **Guided trace**: the glyph is ghosted, a start dot pulses, the finger draws, ink follows, checkpoints light up | 3 | Per-stroke: ✓/retry with a spoken cue ("commence en haut"); per-glyph: a 3-star score | glyph paths + checkpoints | B | [SRC]→[ADAPT] |
| 14 | Écriture-page word models, e.g. *image*, *maman* (p.7, 27) | Write whole words | **Word trace**: same canvas, chained glyphs, wider tolerance | 4 | Per-letter feedback, word-level score | writing models | B | [ADAPT] |
| 15 | Grapheme heading, e.g. *an am en em* (p.55) | Recognise a multi-letter sound unit | Heading in three renderings; tap = hear the sound | 2 | Audio | grapheme, audio | A | [ADAPT] |
| 16 | Grapheme word list (p.55) | Spot the grapheme inside real words | **Grapheme hunt**: the word is displayed, tap the part that makes the sound | 3 | The grapheme lights up and is spoken in isolation, then the whole word | vocab + grapheme span offsets | B | [ADAPT] |
| 17 | Reading text, e.g. *Le marché* (p.57) | **Read continuous prose** | Text laid out sentence by sentence; **tap a sentence = hear it**; "Écouter tout" auto-scrolls with highlighting; a **"J'ai lu"** button per sentence | 4 | Audio + per-sentence completion ticks | text segments + per-sentence audio | A | [ADAPT] |
| 18 | Reading text (dialogue: *Des amis*, *Au réveil*, *Un visiteur*, *Une histoire*) | Read turn-taking speech | Speaker-bubble layout with two voices in the recording | 4 | Audio | text kind = dialogue, speaker tags | A | [ADAPT] |
| 19 | Reading text (advice list: *Des conseils*, *Les conseils*) | Read imperatives | Checklist layout, each line tappable | 3 | Audio | text kind = advice-list | A | [ADAPT] |
| 20 | Reading text | Understand, not just decode | **Comprehension check**: 2 questions per text (« Où va-t-elle ? ») with picture or short-text answers | 5 | Spoken explanation, replay of the relevant sentence | **questions do not exist in the book — must be written and validated by Batonga** | B | **[NEW]** |
| 21 | `CHIFFRES` table (p.88) | Digit ↔ French name | Grid 0–9; tap = hear; **digit-match**: `7` ↔ *sept* | 1 | Audio | digit, word, audio | A/B | [ADAPT] |
| 22 | Digit tracing pages (p.89–98) | Write the digit | Same trace canvas, using the book's numbered stroke order | 2 | Per-stroke | digit glyph strokes | B | [SRC]→[ADAPT] |
| 23 | Alphabet page (p.5) | Reference | **Le mur des lettres**: a browsable 26-letter wall, 4 renderings each, always available, no progression | 1 | Audio | alphabet.json | C shell / A content | [ADAPT] |
| 24 | — | Retention over weeks | **Spaced review**: a daily queue drawn from weak `MasteryRecord` rows | var. | Standard | mastery data | D queue / B rendering | **[NEW]**, V2 |
| 25 | — | Practical literacy the preface promises | **Module « Lire un SMS » / « Mon carnet »** — read a short message, write an order line | 5 | — | **entirely new content; requires Batonga curriculum input** | team | **[NEW]**, V2 |

## J.2 The five MVP activity types

Everything else waits. These five cover every archetype and every unit:

| Type | Key | Used in | Owner |
|---|---|---|---|
| Tap to identify | `tap-identify` | letters, graphemes, digits | B |
| Listen and choose | `listen-choose` | letters, syllables, words, digits | B |
| Build the syllable | `syllable-build` | consonant lessons | B |
| Missing letter | `missing-letter` | words in all units | B |
| Guided trace | `trace` | letters, digits (print only in MVP) | B |

`word-match` is a stretch goal for MVP — it is limited to the 24 illustrated words, so it can only appear in a handful of lessons anyway.

## J.3 Feedback design (applies to every activity)

1. **Never colour alone.** Every judgement is delivered simultaneously as **sound + icon + colour + motion**. A learner may be colour-blind; more relevantly, she may not know that green means yes.
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
- **Path progression with visible unlocking** — mirrors the book's linear, cumulative structure. [ADAPT]
- **Per-lesson completion and a 3-star trace score** — the book's own repetition rows imply "do it until it's good". [ADAPT]
- **A day streak based on attendance, not accuracy.** [NEW, low risk]
- **Unit-completion celebration** — the book's section dividers already mark these boundaries. [ADAPT]

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
|---|---|---|
| **Icon + audio first, text second** | Every button carries an icon and a spoken label. Onboarding is narrated. A user must be able to reach lesson 1 without reading a word. | C |
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
|---|---|
| **Content** | All 56 lessons + alphabet reference + digits 0–9, transcribed and validated. Every word list, sentence, and reading text, verbatim. |
| **Audio** | Human-recorded French for: every letter (name + sound), every syllable in the trees and strips, every word in every list, every sentence, every reading text (whole + per sentence), every digit. ≈ 1 200 clips. |
| **Lesson player** | All 12 block types rendering; script ⇄ cursive toggle; tap-to-hear on every item; resume mid-lesson. |
| **Activities** | The 5 types in §J.2, appearing in every lesson. |
| **Writing** | Guided trace for print lowercase, print uppercase, and digits (62 glyphs). Stroke-order animation for all of them. |
| **Assessment** | End-of-lesson *Bilan* (3–5 mixed items) + one checkpoint at the end of each unit. |
| **Progress** | Path with locked/available/completed states; per-lesson completion; resume point; day streak; a simple Mes Progrès screen. |
| **Shell** | Narrated onboarding, local profile (name + avatar), Accueil, Parcours, Entraînement (alphabet wall, digits, free trace canvas), Réglages. |
| **Platform** | Android + iOS. Fully offline. French UI. ≤ 60 MB. Runs on Android 8 / 2 GB RAM. |
| **Quality** | Content validator in CI; French proof-read sign-off; a11y audit passed; perf budgets met on real hardware. |

## K.3 Explicitly NOT in MVP

Accounts, login, any server call, sync, facilitator **web** dashboard, cursive tracing, notifications, TTS, speech recognition, multiple locales, arithmetic, numbers above 9, social features, in-app content editing, printable worksheets, a tablet-specific layout.

**Amended by Part Two (§S.6):** the exercise bank, comprehension questions, spaced review, specific spoken praise, the placement test, the spoken interface, the on-device facilitator mode and the mastery model **are now in MVP**. Cursive tracing, sync, the facilitator *web* dashboard and OTA content updates remain out.

## K.4 Version 2 — after the first release ships and is used

| Feature | Why it waits |
|---|---|
| **Cursive tracing** (52 more glyphs) | Large authoring effort; print tracing must prove itself first |
| **Comprehension questions** on the 28 texts | **Moved into MVP** (§U.6). The *system* ships; the questions remain Batonga's to author, behind `features.comprehension`. |
| **Spaced review queue** | **Moved into MVP** (§W.9), with conservative default intervals and an explicit recalibration plan. Risk R-17. |
| **Badges & richer celebration** | **Moved into MVP** as the specific-praise bank of §V.5. Still no leaderboards, ever. |
| **Sync + code de reprise** | The outbox already records everything; this drains it |
| **Facilitator web dashboard** | A separate product with a separate audience |
| **Content OTA updates** | Wire `expo-updates` properly with a rollback path |
| **Local reminder notifications** | Only after we learn real usage rhythms |
| **Record-and-compare** | Learner records herself, plays it against the model. Cheap with the audio stack already built, and pedagogically strong |
| **Sentence-build & grapheme-hunt activities** | Activity types 11 and 16 |

## K.5 Future — worth naming, not worth planning yet

Speech-recognition pronunciation scoring · local-language bridge audio (Fon, Bariba, Dendi) for instructions while French remains the content · classroom mode for one shared tablet · adaptive difficulty from mastery data · printable worksheet export for facilitators · numeracy beyond 9, **built as a genuine curriculum project with Batonga rather than a developer's guess** · a second syllabaire in another Batonga country programme, using the same engine with a different content pack.

## K.6 The scope discipline rule

> **If a feature does not help a woman in Bohicon decode a syllable, it is not MVP.**

Print that. When someone proposes dark mode, animated mascots, or a settings screen with fourteen switches in week 6, that sentence is the answer.
---

# L. Development Roadmap

**Assumption:** four students working roughly 15–20 h/week each, in 2-week sprints. **Total: 14 weeks to a releasable MVP.** Adjust the calendar, keep the phase order.

> **Revised by Part Two: 16 weeks.** Phases 0–4 below are unchanged; a new **Phase 4b (weeks 11–12)** carries the comprehension system, the facilitator surface, the review scheduler and the master lexicon. The full revised table is §X.2.

### Phase 0 — Architecture & Setup · Week 1 (all four together, in one room)

| | |
|---|---|
| **Everyone** | Agree the stack. Create the repo, branch protection, CODEOWNERS. **Write and freeze `src/core/contracts/`.** Agree the folder structure in §F verbatim. Write ADR-001 (stack) and ADR-002 (data-driven lessons). Agree the DoD in §P and the workflow in §N. |
| **Individually** | A: JSON Schema for one lesson + transcribe L01 and L08 by hand as reference. B: draft `ActivitySpec`/`ActivityResult`. C: Expo app scaffolded, runs on a device, theme tokens v0. D: SQLite connected, migration 0001, CI pipeline green. |
| **Dependencies** | None. This phase exists to eliminate them. |
| **Output** | A repo that builds on both platforms, with frozen contracts and four owned, empty directories. **No feature code yet.** |

### Phase 1 — Foundation · Weeks 2–3 (parallel)

| Dev | Work | Output |
|---|---|---|
| A | Content loader, repository, validator CLI. **3 block renderers**: keyword-illustration, letter-forms, word-list. Transcribe L01–L07 (the vowel unit). | `/dev/blocks` shows 3 blocks from real JSON |
| B | `ActivityHost` + registry. **`tap-identify`** end to end. Trace canvas spike: capture and render ink at 60 fps. | `/dev/activities` plays one activity |
| C | **All route files created and navigable** (placeholder bodies) — *this is the deliverable that unblocks everyone.* `@ui` primitives: Button, Card, ListRow, ProgressRing. Onboarding flow. | Walk the whole app on a phone |
| D | Full schema + migrations. `progressService` with a fixture. `audioService` reading placeholder clips. **Audio manifest v1 generated from A's L01–L07.** | Progress persists across restart |
| **Integration point** | End of week 3: merge all four into `develop`. **Demo: navigate to lesson 1 and see three real blocks with working audio.** |

### Phase 2 — Core Learning Experience · Weeks 4–6 (parallel)

| Dev | Work |
|---|---|
| A | Remaining 9 block renderers, syllable-tree first. Transcribe L08–L24. Illustration pipeline (24 SVGs). Script ⇄ cursive toggle. |
| B | `listen-choose`, `syllable-build`. **`scoreTrace` implemented and unit-tested** against hand-made fixtures. |
| C | Parcours map against D's `PathState`. Accueil with Continuer. Réglages. Font integration (print + cursive) — **resolve licensing this phase.** |
| D | Mastery engine. Streaks. **Recording session #1 executed** (letters, syllables, digits ≈ 500 clips). Audio ingestion pipeline. Perf baseline on a real low-end device. |
| **Integration** | End of week 6: **any consonant lesson is playable start to finish with real audio.** This is the project's first genuine milestone. |

### Phase 3 — Exercises & Writing · Weeks 7–8 (parallel)

| Dev | Work |
|---|---|
| A | Transcribe L25–L56 (32 grapheme lessons + 28 texts) — **the heaviest transcription block.** `reading-text` renderer with all three sub-types. |
| B | `missing-letter`. **Trace canvas productionised** across all 62 print glyphs. Feedback layer (audio + icon + colour + motion). |
| C | Entraînement section: alphabet wall, digits, free canvas. Mes Progrès layout. **Accessibility audit round 1.** |
| D | **Recording session #2** (words, sentences, texts ≈ 700 clips). Audio preloading strategy. Sync outbox wired to every mutation. |
| **Integration** | End of week 8: all 5 activity types work; tracing works for every print glyph. |

### Phase 4 — Progress & Assessment · Weeks 9–10 (parallel)

| Dev | Work |
|---|---|
| A | Digit lessons D0–D9 + alphabet reference. **Full content validation passing on all 67 files.** French proof-read against the PDF. |
| B | *Bilan* end-of-lesson check. Unit checkpoint. Activity generation tuned per archetype. |
| C | Celebration screens. Empty/error states. Full French string sweep. **A11y audit round 2.** |
| D | Unlocking rules. `LessonOutcome`. Resume point. Streak logic. **All audio ingested and manifest-verified.** |
| **Integration** | End of week 10: **content-complete.** All 67 lessons playable with real audio, activities, tracing and progress. |

### Phase 5 — Integration & Polish · Week 11 (converging)

Feature freeze. Everyone works from `develop`. Cross-stream bugs; visual consistency pass; loading and error states; perf against the §C.1 budgets on physical devices; install-size trim; content errata review with Batonga.

### Phase 6 — Testing · Weeks 12–13

| | |
|---|---|
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

```
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
```

**Not this:**
```
   DEV A ──► DEV B ──► DEV C ──► DEV D      ✗  three developers idle
```

## M.2 How the four dependencies are dissolved

| Natural dependency | How we remove it |
|---|---|
| B needs A's content to test activities | B works from `__fixtures__/activitySpecs.ts` — hand-written specs, no content loader needed |
| C needs D's progress to draw the path | C works from `__fixtures__/pathState.ts` — a static `PathState` with every node status represented |
| A needs D's audio to render speaker icons | `audioService.has()` returns false for unrecorded clips; the icon simply is not drawn. **A ships every screen before a single clip is recorded.** |
| D needs A's audio IDs to build the manifest | IDs are **deterministic from a naming convention** agreed in Phase 0 (`word.fonio`, `syll.ta`, `sent.L09.02`). D generates the manifest by scanning A's JSON — no conversation required |
| A needs B's `ActivityHost` in the player | A renders a stub `<ActivityHost/>` (a "Continuer" card) until B's lands. The `activity` block type exists from day one |
| Everyone needs C's `@ui` | C ships primitives in **week 2**, before anyone needs them. Until then, everyone uses plain RN components and refactors — cheap and bounded |

## M.3 Per-phase parallel view

| Phase | Dev A | Dev B | Dev C | Dev D | Blocked? |
|---|---|---|---|---|---|
| 0 (w1) | Schema + 2 sample lessons | Activity contracts | Scaffold + theme | DB + CI | Together by design |
| 1 (w2–3) | Loader, validator, 3 renderers, L01–07 | ActivityHost, tap-identify, ink spike | **All routes**, `@ui` v1, onboarding | Schema, progress, audio stub | **None** |
| 2 (w4–6) | 9 renderers, L08–24, illustrations | listen-choose, syllable-build, scoreTrace | Parcours, Accueil, fonts | Mastery, streaks, **recording #1** | **None** |
| 3 (w7–8) | L25–56 + texts | missing-letter, trace production | Entraînement, a11y #1 | **Recording #2**, preload, outbox | **None** |
| 4 (w9–10) | Digits, validation, proof-read | Bilan, checkpoints | Celebrations, strings, a11y #2 | Unlocking, audio ingest | **None** |
| 5 (w11) | ← converge on `develop` → | | | | Intentional |
| 6 (w12–13) | Content QA | Test suites | Device matrix | Perf & migrations | Intentional |
| 7 (w14) | ← release together → | | | | Intentional |

**Zero blocking dependencies in weeks 2–10.** That is the design goal of the whole allocation, and it is achievable only because Phase 0 froze the contracts.

## M.4 Weekly rhythm

- **Monday 30 min — sync.** Each dev: what I merged, what I'm on, what I need from whom. Any contract change is raised here, never in a PR.
- **Wednesday — integration day.** Everyone rebases on `develop` and pushes. Failing CI on Wednesday is everyone's problem.
- **Friday 45 min — demo on a real phone.** Not a slide, not a simulator recording. If it does not run on a physical Android, it is not done.

---

# N. Git / GitHub Workflow

Deliberately simple. Four students do not need Git Flow.

## N.1 Branch model

```
main                     protected · always releasable · tagged releases only
 └── develop             protected · integration · CI must be green
      ├── dev/content-engine     Dev A   persistent
      ├── dev/activities         Dev B   persistent
      ├── dev/shell-ux           Dev C   persistent
      └── dev/data-audio         Dev D   persistent
           └── feat/data-audio/streak-logic     short-lived, optional
```

- **Persistent branches** are the four ownership branches. They live for the whole project.
- **Short-lived branches** off your own persistent branch are optional; use one when a change is risky or needs its own review.
- **`hotfix/*`** branches off `main`, merges to `main` **and** `develop`.

## N.2 Setup (day 1, one person, then everyone clones)

```bash
git init && git branch -M main
git commit --allow-empty -m "chore: initial commit"
git push -u origin main
git checkout -b develop && git push -u origin develop

# each developer, once:
git checkout develop && git pull
git checkout -b dev/content-engine        # ← your own branch name
git push -u origin dev/content-engine
```

**Branch protection on `main` and `develop`:** require a PR, require 1 approval (2 for `src/core/contracts/**`), require CI to pass, require the branch to be up to date, no force-push, no deletion.

## N.3 Daily loop

```bash
# every morning, without exception
git checkout develop && git pull origin develop
git checkout dev/content-engine
git rebase develop            # ← rebase your own branch onto develop
# ...work...
git add -p
git commit -m "feat(content): render syllable-tree block"
git push --force-with-lease   # required after a rebase; never plain --force
```

**Pull frequency: every morning, and again after any teammate announces a merge to `develop`.** Rebasing daily turns a week-long agonising conflict into a 30-second one. This is the single highest-value habit in this document.

## N.4 Commit convention

Conventional Commits, with the stream as the scope:

```
feat(content):   add reading-text renderer for dialogue texts
fix(activity):   trace scoring rejected valid uppercase T strokes
chore(db):       add migration 0007_mastery_index
docs(plan):      record ADR-004 on cursive scope
test(scoring):   cover multi-stroke direction checks
refactor(ui):    extract ListRow from Parcours
content(L25):    transcribe grapheme lesson an/am/en/em + Les vacances
```

Scopes: `content` `activity` `writing` `ui` `shell` `db` `progress` `audio` `sync` `ci` `plan`. Plus `content(Lxx)` for transcription commits, which keeps 56 lessons legible in the log.

## N.5 Rebase vs merge — the rule

| Situation | Do this | Why |
|---|---|---|
| Updating **your** branch from `develop` | **`git rebase develop`** | Keeps your branch a clean line of your own work |
| Merging your branch **into** `develop` | **Squash merge via PR** | One commit per feature in `develop`; a legible history for whoever maintains this after you |
| `develop` → `main` at release | **Merge commit** (`--no-ff`) | Preserves the release boundary |
| A branch someone else has pulled | **Never rebase it** | You will rewrite their history |

**The one absolute rule: never rebase `main` or `develop`.**

## N.6 Pull requests

Open a PR **from your persistent branch into `develop` at least once a week**, even if the work is unfinished — put it behind a feature flag (§G.3) and mark it draft. A branch that has not merged in two weeks is a merge disaster forming quietly.

`.github/pull_request_template.md`:
```markdown
## What
One sentence.

## Stream
- [ ] A content  - [ ] B activities  - [ ] C shell  - [ ] D data/audio

## Checklist
- [ ] Rebased on develop today
- [ ] `npm run typecheck && npm run lint && npm test` pass locally
- [ ] `npm run validate-content` passes (if content touched)
- [ ] Tested on a physical Android device
- [ ] No files outside my ownership area (see CODEOWNERS)
- [ ] No hardcoded French strings in components (i18n only)
- [ ] No hardcoded lesson content in components
- [ ] Definition of Done (§P) satisfied

## Touches shared files?
List them and name who approved.

## Screenshot / screen recording
Required for anything visual.
```

## N.7 Code review

- **Reviewer is the owner of whatever the PR touches.** Default reviewer is the dev whose contract you consume.
- **24-hour turnaround.** A PR blocked for three days is a parallelism failure, not a review.
- Review for: contract adherence, ownership boundaries, hardcoded content, hardcoded strings, and whether it runs. Not for style — Prettier settles style, and nobody argues with Prettier.
- **Two approvals** for `src/core/contracts/**`, `package.json`, `tsconfig.json`, `app/_layout.tsx`.

## N.8 Conflict resolution

```bash
git rebase develop
# CONFLICT in src/features/lesson/blockRegistry.ts
git diff --name-only --diff-filter=U     # what actually conflicted
# open it, resolve, keeping BOTH sides for registry/append-only files
git add src/features/lesson/blockRegistry.ts
git rebase --continue
# escape hatch:
git rebase --abort
```

**Rules:**
1. **The file's owner decides.** If you conflict in someone else's file, you are probably in the wrong file — stop and ask.
2. **Append-only files (registries, i18n, migrations): keep both sides.** Never "take mine".
3. **`package-lock.json`: never hand-merge.**
   ```bash
   git checkout --theirs package-lock.json && npm install
   git add package-lock.json
   ```
4. **A conflict you cannot resolve in 10 minutes is a conversation, not a Git problem.** Call the other dev.

## N.9 Urgent fixes

```bash
git checkout main && git pull
git checkout -b hotfix/audio-crash-on-android-8
# fix, PR into main, 1 approval, merge, tag
git checkout develop && git merge main       # ← never forget this line
```

For a content-only fix (a typo, a re-recorded clip), prefer **EAS Update** to the store: `eas update --branch production --message "fix: correct 'bouillie' spelling in L32"` — live in minutes.

## N.10 Not breaking each other

| Practice | Effect |
|---|---|
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
|---|---|---|---|---|
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
| **Contracts** | **shared** | — | `src/core/contracts/**` | ⚠️ **2 approvals + ADR** |
| **Dependencies** | **Build Steward** | — | `package.json`, `package-lock.json` | ⚠️ §O.2 |
| **Root layout** | **C + D** | — | `app/_layout.tsx` | ⚠️ §O.4 |
| **TS config** | **shared** | — | `tsconfig.json` | ⚠️ 2 approvals |

## O.2 Dependencies: the Build Steward

**One person (recommend Dev D) adds dependencies. Nobody else touches `package.json`.**

Process: you open a one-line issue titled `dep: react-native-svg for glyph rendering`; the Steward installs it on `develop`, pushes, and tells the team in chat; everyone rebases. Cost: a few hours of latency. Benefit: `package-lock.json` — the single worst-conflicting file in any JS project — has exactly one writer.

Batch requests into the Monday sync where possible.

## O.3 Registries instead of switch statements

The classic four-way conflict is one `switch` that every developer must extend. Replace it with an **append-only registry**, one alphabetically-sorted line per entry:

```ts
// src/features/lesson/blockRegistry.ts   — owner A, APPEND ONLY, keep alphabetical
import { ActivityBlock }           from './blocks/ActivityBlock';
import { GraphemeHeadingBlock }    from './blocks/GraphemeHeadingBlock';
import { KeywordIllustrationBlock} from './blocks/KeywordIllustrationBlock';
// …

export const blockRegistry: Record<BlockType, BlockRenderer> = {
  'activity':              ActivityBlock,
  'grapheme-heading':      GraphemeHeadingBlock,
  'keyword-illustration':  KeywordIllustrationBlock,
  // …
};
```

Two developers adding entries at different alphabetical positions produce **no conflict at all**. If they land on adjacent lines, Git's 3-way merge usually resolves it; if not, "keep both" is unambiguously correct.

Same pattern for `activityRegistry.ts`.

## O.4 Every shared file, and its rule

| Shared file | Conflict risk | Rule |
|---|---|---|
| `package.json` / `package-lock.json` | **Very high** | Build Steward only (§O.2). On conflict: `git checkout --theirs package-lock.json && npm install` |
| **Routing** | Normally very high — **eliminated here** | expo-router = file-based. One route, one file, one owner. **This is a concrete reason the stack choice matters.** |
| `app/_layout.tsx` | Medium | The one genuinely shared route file: C owns nav/theme/fonts; D owns providers (DB, audio). **Keep it under 60 lines**; each provider on its own line so merges are clean. 2 approvals. |
| `src/ui/theme.ts` | Medium | C writes. **Additive only** — never rename or remove a token. Others request via issue. |
| `src/core/contracts/**` | **Very high impact, low frequency** | Frozen after Phase 0. 2 approvals + an ADR. |
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

```bash
git reflog                             # find the commit before the mess
git reset --hard HEAD@{3}
git merge --abort  /  git rebase --abort
git checkout develop -- path/to/file   # take develop's version of one file
git log --merge -p path/to/file        # see both sides' history for a conflicted file
```
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
|---|---|---|---|---|---|
| **R-01** | **No rights agreement with the Batonga Foundation.** The syllabaire, its illustrations, the cover photograph and the Angélique Kidjo quote are all Batonga's. Building the app without written permission risks the whole project. | Medium | **Fatal** | **Do this in week 1, before writing content code.** Get written permission covering: digitisation of the text, redrawing the illustrations, using the Batonga name and marks, and who owns the app. Also ask for the original source files — a designer's InDesign package would remove weeks of transcription and asset work. | Team lead |
| **R-02** | **Transcription errors.** 56 lessons of accented French, hand-typed by developers. A wrong accent teaches a wrong spelling to someone who cannot yet detect it. | **High** | **High** | The eight validator rules (§I.4); one lesson per file; second-pair-of-eyes rule; screenshot-vs-PDF in every content PR; `protected-terms.json`; a final full read-through by a French speaker in Phase 6. **Treat content bugs as severity-1.** | A |
| **R-03** | **Audio production slips.** ~1 200 clips need a speaker, a quiet room, and editing. This is the longest-lead item and the least like coding. | **High** | **High** | Book the speaker in **week 1**, not week 6. Two sessions (§L Phases 2 and 3). Placeholder-first architecture (`has()`) so **nothing is blocked**. Naming convention fixed in Phase 0 so ingestion is mechanical. Fallback: ship v1 with letters/syllables/digits only and add words/texts by EAS Update. | D |
| **R-04** | **Misrepresenting the pedagogy.** Four developers "improving" a sequence designed by literacy specialists — reordering lessons, simplifying vocabulary, adding difficulty. | Medium | **High** | §B.6 and §J.6 are binding. The validator's cumulative-decoding rule is a mechanical guard. **Any pedagogical change requires Batonga's written approval, recorded as an ADR.** | A |
| **R-05** | **Uneven workload.** Content transcription (A) and audio management (D) are volume-heavy; activities (B) are algorithmically heavy. Someone falls behind and the parallel plan collapses. | **High** | Medium | Track per-stream progress at the Monday sync. **Transcription is explicitly a shareable task** — if A is behind at week 7, B/C/D each take 8 grapheme lessons; the schema is stable by then and the validator catches mistakes. Rebalance early, not in week 12. | Team lead |
| **R-06** | **Scope creep.** Arithmetic, a chatbot, a facilitator dashboard, "just a small AI feature". | **High** | **High** | §K.6's one-sentence test. Everything not in §K.2 goes to a `v2` GitHub milestone **without discussion**. Feature flags let ambitious work merge without shipping. | Team lead |
| **R-07** | **Handwriting complexity swallows the project.** Tracing is the most enticing rabbit hole in the app. | Medium | **High** | §J.4: **path-following, not recognition.** Print only in MVP; cursive is V2. `scoreTrace` is pure and unit-tested. **Time-box the spike to 5 days in Phase 1**; if 60 fps ink is not achieved by then, escalate at the Monday sync. | B |
| **R-08** | **Cursive font licensing.** The book uses a French school cursive face. Redistributing it in an app binary is a different licence from print. | Medium | Medium | Resolve in **Phase 2**, not at release. Options: buy an app-embedding licence; use an open school-cursive face; commission one. **Cursive display is MVP, so this cannot be deferred.** | C |
| **R-09** | **Performance on low-end devices.** SVG glyphs, ~1 200 audio files, long scrolling lessons on an Android Go device with 2 GB RAM. | Medium | **High** | **Buy one cheap Android device in week 1 and test on it weekly.** Budgets in §C.1 measured at every phase boundary. Virtualised lists, lazy audio preloading (current block + next only), SVG over PNG. | D |
| **R-10** | **Merge conflicts and divergence.** Four branches, fourteen weeks. | Medium | Medium | The whole of §N and §O. The two habits that matter most: **rebase daily** and **PR into `develop` weekly**. | All |
| **R-11** | **Accessibility fails the actual audience.** The app is beautiful and unusable by someone who cannot read. | Medium | **High** | §K.1 principles; §P.2 checks on every UI PR; two formal audits (Phases 3 and 4); **and the field test in Phase 6 with real learners, observed, with no developer helping.** Nothing else in this table substitutes for that test. | C |
| **R-12** | **Offline sync design debt.** Building sync in V2 requires retrofitting change tracking. | Low | Medium | `sync_outbox` written from day one (§C.4). Roughly 30 lines now versus a fortnight later. | D |
| **R-13** | **Content volume exhausts the team.** 67 lessons, 24 illustrations, 62 glyphs, 1 200 clips is a lot of *making things*, and it is less fun than coding. | **High** | Medium | Front-load it: transcription starts in Phase 1 and runs continuously. Budget ~45 min per lesson. Make it visible on a board so it is not a silent overrun. Ask Batonga for source files (R-01). | A |
| **R-14** | **Store rejection or distribution friction.** iOS review, or learners who cannot reach the Play Store. | Low | Medium | Ship the Android build to Batonga as a direct APK **and** to Play. Privacy policy is trivially honest: no data collection. Start the Apple developer account in week 1 — enrolment can take days. | D |
| **R-15** | **The team disbands after the project grade.** The four of you graduate; the app has to live. | **High** | **High** | This is why branches are named by domain, why every module has a `docs/*.md`, why decisions are ADRs, and why content is JSON a non-programmer can read. **In Phase 7, write `docs/HANDOVER.md`** — how to add a lesson, how to add an audio clip, how to release. | All |

## Q.1 The three risks to act on this week

1. **R-01** — get the rights conversation started with Batonga today. Everything else is downstream of it.
2. **R-03** — find and book the voice talent now. It is a 6-week lead item on a 14-week schedule.
3. **R-09** — buy a cheap Android phone. You cannot budget performance on a MacBook simulator.

---

# R. Recommended First Sprint

**Sprint 1 = 2 weeks.** Objective:

> **By the end of week 2, all four developers can run the same app on a phone, walk to Lesson 1, and see one real block rendered from real JSON with a working audio button — and each of them can keep building for six weeks without waiting on anyone.**

## R.0 Day 1 — the whole team, together, before any code

Do not skip this. Four hours now saves the project.

| Time | Decide | Output |
|---|---|---|
| 60 min | **Read the book together.** All four, page by page, including all 28 texts. Not the summary — the source. | Shared understanding of what you are building |
| 30 min | Confirm the stack (§C.1). Argue now or not at all. | `docs/adr/001-stack.md` |
| 45 min | **Write `src/core/contracts/` on a whiteboard, then in code.** All five files. This is the most important hour of the project. | Contracts committed to `develop` |
| 30 min | Agree the **audio ID naming convention** (§G.1). Write it down. | `docs/audio-production.md` §1 |
| 30 min | Agree the folder structure in §F **verbatim**, and CODEOWNERS. | Repo scaffold + CODEOWNERS |
| 20 min | Agree §N workflow and §P Definition of Done. | Both pinned in the repo |
| 15 min | Assign the four branches. Nominate the **Build Steward**. | CODEOWNERS committed |
| 20 min | **Assign R-01 (Batonga rights), R-03 (voice talent), R-09 (buy a test phone).** Names and dates. | Three GitHub issues with owners |

## R.1 Developer A — `dev/content-engine`

| # | Task | Done when |
|---|---|---|
| A1 | Write `content/schema/lesson.schema.json` for all 12 block types | It validates the L08 example in §I.3 |
| A2 | **Transcribe `L01.json` (i / un épi) and `L08.json` (t / une tête) by hand**, verbatim from pages 7–8 and 20–21 | Both pass the schema; a second dev has compared them to the PDF |
| A3 | Build `contentRepository` — load, index, query, `getNextLesson` | Unit-tested against L01 and L08 |
| A4 | Build `tools/validate-content.ts` with rules 1–5 of §I.4 | `npm run validate-content` runs in CI |
| A5 | Build 3 block renderers: `keyword-illustration`, `letter-forms`, `word-list` | Visible in `/dev/blocks` with real data |
| A6 | `LessonPlayer` v0: renders a block sequence, next/back, calls `onBlockComplete` | Lesson 1 plays end to end with a stub activity card |
| A7 | Draw or source 2 illustration SVGs (épi, tête) | Rendered in-app, ≤ 15 KB each |
| A8 | Transcribe L02–L07 if time allows | Validator green |

**Hand off by end of sprint:** the frozen `Lesson`/`LessonBlock` types, `L01.json` + `L08.json` as everyone's fixtures, and the audio IDs those two lessons reference (D needs them).

## R.2 Developer B — `dev/activities`

| # | Task | Done when |
|---|---|---|
| B1 | Finalise `ActivitySpec` / `ActivityResult` in contracts with the team | Merged to `develop` on day 1 |
| B2 | `ActivityHost` + `activityRegistry` (append-only pattern, §O.3) | Renders any registered type from a spec |
| B3 | Implement **`tap-identify`** fully: grid, distractors, audio+icon+colour feedback, skip | Playable in `/dev/activities` from a fixture |
| B4 | Write `__fixtures__/activitySpecs.ts` — one spec per planned MVP type | A and D can import it |
| B5 | **Trace canvas spike (time-boxed to 5 days, R-07).** Capture touch points, render ink with Reanimated + SVG, measure latency on the cheap Android | Ink at 60 fps, latency ≤ 32 ms, **or** an escalation at the Monday sync |
| B6 | First cut of `scoreTrace`: start-point + checkpoint coverage only | Pure function, ≥ 5 unit tests, no React import |
| B7 | Feedback layer: sound + icon + colour + motion, from one component | Used by `tap-identify` |

**Hand off:** `ActivityHost` (real, not a stub) and the fixtures file.

## R.3 Developer C — `dev/shell-ux`

| # | Task | Done when |
|---|---|---|
| C1 | Expo + TypeScript + expo-router scaffold; **runs on a physical Android and an iPhone/simulator** | Everyone can `npm i && npx expo start` |
| C2 | **Create every route file in §F with a placeholder body** | The whole app is walkable — *this is the sprint's most important deliverable for the team* |
| C3 | `theme.ts`: colour (Batonga teal + magenta, contrast-checked), spacing, radius, type scale, motion | Committed and documented |
| C4 | `@ui` v1: `Button`, `IconButton`, `Card`, `ListRow`, `ProgressRing`, `Toast` | All ≥ 56 dp, all themed, shown in `/dev/blocks` |
| C5 | i18n set up with namespaced `fr` files | No literal French in any component |
| C6 | Onboarding flow: narrated welcome, name/avatar, start | Walkable; a non-reader could complete it |
| C7 | `docs/ux-principles.md` and `docs/a11y-checklist.md` from §K.1 and §P.2 | Committed |
| C8 | **Resolve the cursive font question (R-08)** — identify candidates and licence terms | A recommendation posted for the team |

**Hand off:** the route tree and `@ui` — both by **end of week 1** if at all possible, because A, B and D all consume them.

## R.4 Developer D — `dev/data-audio`

| # | Task | Done when |
|---|---|---|
| D1 | SQLite + Drizzle; migration `0001` covering all §G.2 tables | Runs on a clean install on both platforms |
| D2 | Repositories for `Learner`, `LessonState`, `ActivityAttempt`, `MasteryRecord` | Unit-tested |
| D3 | `progressService` v1: `recordActivityResult`, `recordBlockComplete`, `getLessonState`, `getResumePoint` | Progress survives a force-quit |
| D4 | `__fixtures__/pathState.ts` — a static `PathState` with every node status | C imports it immediately |
| D5 | `audioService` v1: `play`, `stop`, `preload`, **`has`** | Plays a bundled test clip; `has()` returns false safely for missing IDs |
| D6 | **Write `docs/audio-production.md`**: naming convention, technical spec (mono / 44.1 kHz / −16 LUFS / AAC 64 kbps), the recording script format, session plan | Ready to hand to the voice talent |
| D7 | **Generate `audio-manifest.json` v1 by scanning A's L01 + L08** — every entry `status: "placeholder"` | Manifest generation is a script, not manual |
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
6. **The MVP line** (§K.2 vs §K.3). Write it on the wall. Point at it in week 6.
7. **Who talks to Batonga**, and that pedagogical questions go to them rather than being resolved by developer intuition.

---

# S. Scope Revision — Full Product as MVP

> **Part Two — The four add-on packs.** Part One digitises the book. Part Two builds the product around it: the layer the printed page could assume a human would supply, and the layer a book simply cannot have. Each pack belongs to exactly one developer, lives in its own directory, and adds no shared files. The four-branch, zero-conflict property of Part One is preserved by construction.

## S.1 What Batonga decided, and what it removes

Part One left four questions open for the Foundation. Three now have answers, and each one **shrinks** the surface rather than growing it. Recording them here is more important than recording the additions, because a plan that only grows is a plan nobody finishes.

| # | Question from Part One | Decision | Consequence |
|---|---|---|---|
| 1 | Is `q` an omission to fix? | **No.** In French `q` is never written alone — it always carries its `u`. It *is* taught, at Lesson 46, as `qu = k = c`. | Finding withdrawn. `q` needs no lesson. `w` and `x` remain loanword letters, present on the alphabet wall only. **No invented lessons.** |
| 2 | Numeracy beyond digit recognition? | **No. Digits 0–9 only, and that is the whole of it.** | The digit unit is specified completely (`digits.json`) and closed. No counting, no quantity, no arithmetic, no money — not in MVP, not in V2, not on the backlog. |
| 3 | The SMS / order-book module? | **Not now.** | Removed from V2 planning. The preface's digital-inclusion promise stays a Batonga curriculum question, not a developer one. Section K.4 is amended. |
| 4 | May the sequence be adjusted? | **No. The order is specific to this cohort and is not to be touched.** | §B.6 and §J.6 are upgraded from strong recommendation to hard constraint, and the validator's cumulative-decoding rule is now the mechanism that enforces it. |

**What "full product as MVP" therefore means.** Not more content than the book. Not new curriculum. It means the *book's own content, completely surrounded* — every letter with two recordings, every syllable with a fusion clip, every lesson with exercises the paper never had, every screen operable by someone who cannot read it, and every learner's progress modelled well enough that the app knows which syllable to bring back on Thursday. The scope grew inwards, not outwards.

## S.2 A fifth provenance tag

Part One used four tags. The packs need a fifth, because most of what follows is neither copied from the book nor invented.

| Tag | Meaning |
|---|---|
| **[SRC]** | Directly derived from the PDF. Verifiable on a specific page. |
| **[ADAPT]** | A UX or engineering adaptation of something that *is* in the PDF. |
| **[NEW]** | A recommendation with no basis in the PDF. A product proposal requiring Batonga's approval. |
| **[GAP]** | Something the PDF does not contain. Stated so nobody invents it. |
| **[DERIVED]** | **Generated mechanically from [SRC] material by a stated rule, and re-checkable by running the rule again.** |

[DERIVED] is what makes the corpus honest. The book never prints a list of the 131 syllables it teaches — but it prints seventeen syllable trees, and the list follows from them by multiplication. Nobody invented `mê`; the rule produced it. Every [DERIVED] artefact in these packs ships with the generator that made it, so a reviewer never has to trust the output — they can re-run it.

The rule for using the tag: **if you cannot write down the rule that produced the value, it is [NEW], not [DERIVED].**

## S.3 The four packs

| Pack | Name | Owner | Branch | New directory | What gap it closes |
|---|---|---|---|---|---|
| **1** | Le Corpus | **A** | `dev/content-engine` | `content/corpus/` | The book is a sequence of pages; the app needs an index of the language those pages teach. Sounds, spellings, syllables, decodability. |
| **2** | La Banque d'Exercices | **B** | `dev/activities` | `content/exercices/` | The book contains no exercises, no questions, no answer key, no assessment of any kind. |
| **3** | La Voix de l'Interface | **C** | `dev/shell-ux` | `content/interface/` + `src/i18n/fr/` | The book assumes a literate facilitator on every page and documents her nowhere. The app must become her. |
| **4** | Le Corpus Sonore et le Modèle de Maîtrise | **D** | `dev/data-audio` | `content/audio/script/` | A syllabaire is about sound, and paper has none. And §G declared a `strength` field without saying how it is computed. |

Balance is preserved: two packs are mostly data authoring (1 and 3), two are mostly algorithmic (2 and 4) — the same split as the original allocation, so nobody's workload profile changes character.

## S.4 Ownership map — the no-conflict property, extended

Every path below is new, and every one has exactly one owner. **Not a single shared file is added by Part Two.** This is the whole reason the packs are organised by owner rather than by topic.

```
content/
├── corpus/                              ◆ A   Pack 1
│   ├── lesson-index.json                      the frozen spine
│   ├── phonemes.json                          65 sounds
│   ├── grapheme-phoneme.json                  every spelling → its sound
│   ├── syllabary.json                         131 syllables
│   ├── decodability.json                      what is legible when
│   ├── digits.json                            0–9, closed
│   ├── protected-terms.json                   the Beninese vocabulary guard
│   └── errata.json                            9 registered deviations
│
├── exercices/                           ◆ B   Pack 2
│   ├── generators.json                        5 item generators
│   ├── confusion-matrix.json                  how to be wrong usefully
│   ├── bilan-blueprints.json                  end-of-lesson checks
│   ├── checkpoints.json                       6 unit checkpoints
│   ├── placement-test.json                    « J'en connais déjà »
│   ├── comprehension.json                     the 28 texts' question system
│   ├── trace-rubric.json                      scoreTrace's parameters
│   └── repair-ladder.json                     what happens when she is wrong
│
├── interface/                           ◆ C   Pack 3
│   ├── ui-strings.fr.json                     179 strings × text/icon/voice
│   ├── icon-lexicon.json                      82 icons, closed set
│   ├── onboarding-script.fr.json              the narrated first run
│   ├── encouragement-bank.fr.json             44 spoken lines
│   ├── repair-flows.fr.json                   the moments paper never had
│   ├── register-guide.json                    tone, binding on all four
│   └── facilitator.json                       the animatrice surface
│
└── audio/script/                        ◆ D   Pack 4
    ├── audio-id-grammar.json                  the A↔D seam, as a regex
    ├── recording-script.json / .csv           590 clips, generated
    ├── voice-direction.json                   casting and method
    ├── session-plan.json                      5 sessions, off the critical path
    ├── mastery-model.json                     how `strength` is computed
    ├── progression-rules.json                 unlock, resume, availability
    ├── review-scheduler.json                  the spaced-review queue
    └── telemetry-catalogue.json               local-only event log

tools/
├── gen-corpus.ts                        ◆ A   regenerates Pack 1
├── validate-exercices.ts                ◆ B
├── lint-strings.ts                      ◆ C
└── gen-audio-script.ts                  ◆ D   scans A and C, emits Pack 4
```

Two cross-pack reads exist, and both are one-directional and file-based, which is why neither creates a conflict:

- **B reads `decodability.json`** to know which distractors are legal. B never writes it.
- **D reads `ui-strings.fr.json` and Pack 1** to generate the recording script. D never writes either.

Both are enforced in `CODEOWNERS` and in CI: a PR from `dev/activities` that modifies anything under `content/corpus/` fails before review.

## S.5 What this costs

Honest arithmetic. The packs are mostly *authoring and specification*, and much of what they specify was going to be improvised anyway — but they are not free.

| Pack | Data authoring | Code | Net schedule impact |
|---|---|---|---|
| 1 | Mostly generated; the generator is ~400 lines | Validator grows from 8 rules to 14 | **≈ 0** — replaces guesswork already in the plan |
| 2 | Generators replace ~1 675 hand-written items | Item generation layer, ~600 lines | **−1 week** vs hand-authoring, **+1 week** vs having no exercise bank at all |
| 3 | 179 strings + 82 icons + scripts | None beyond what §E.3 already had | **+1 week** of Dev C's time, largely in Sprint 2 |
| 4 | Recording script generated; +250 clips over the original estimate | Mastery + review, ~500 lines | **+2 weeks** — mastery and review were V2 in Part One |

**Revised total: 16 weeks, not 14.** Phases 0–4 are unchanged; the two added weeks land as a new Phase 4b (weeks 11–12) for mastery, review and the facilitator surface, pushing integration, testing and release out by two. If the calendar cannot move, the honest cut is `review-scheduler` — turn the feature flag off, keep the `MasteryRecord` writes, and ship the queue by EAS Update once the field test has produced real intervals.

## S.6 Amendments to Part One

Read Part One with these applied.

| Section | Amendment |
|---|---|
| §A.4 | The second bullet (digital inclusion / SMS as "the most compelling V2 module") is **withdrawn**. Not planned. |
| §B.2, integrity table | The `q, w, x` row is **superseded**: `q` is taught at L46 inside `qu`. See errata `E-009`. |
| §B.4 | "Counting, comparing quantities and arithmetic are [GAP]/[NEW]" now reads: **out of scope, permanently.** |
| §I.4 | Eight validator rules become **fourteen** (§T.6). |
| §K.2 | MVP gains: exercise bank, comprehension system, placement test, spoken interface, facilitator mode, mastery model, review queue. |
| §K.3 | Comprehension questions, spaced review and badges **move into MVP**. Cursive tracing, sync, facilitator *web* dashboard and OTA remain out. |
| §K.4 | The SMS / order-book row is **deleted**. |
| §L | 14 weeks → **16 weeks**, via a new Phase 4b. |
| §Q | Two risks added: **R-16** (comprehension questions blocked on Batonga) and **R-17** (spaced-review intervals unvalidated). |

---

# T. Pack 1 — Le Corpus  ◆ Dev A

> **The gap.** The book is a sequence of 104 pages. An app is not. To generate an exercise, choose a distractor, decide whether a word is legible yet, or check that a sentence obeys the method, the software needs something the book never prints: **an index of the language the book teaches**. Every letter and every sound it introduces, every syllable its trees produce, and — the load-bearing one — exactly what a learner can decode at each point in the sequence.
>
> None of this is invention. All of it follows from the printed pages by rule, which is why it is tagged **[DERIVED]** and ships with the generator that produced it.

## T.1 What is in the pack

| File | Rows | Tag | What it answers |
|---|---|---|---|
| `lesson-index.json` | 67 lessons, 4 units | [SRC] | What is the order, and what is on each page? |
| `phonemes.json` | 65 | [DERIVED] | Which French sounds does this book actually teach? |
| `grapheme-phoneme.json` | 109 | [DERIVED] | Which spellings map to which sound, and where is each introduced? |
| `syllabary.json` | 131 | [DERIVED] | Every syllable the trees produce, print state, fusion audio. |
| `decodability.json` | 56 | [DERIVED] | At lesson *n*, what can she read? |
| `digits.json` | 10 | [SRC] + [ADAPT] | The closed numeracy unit. |
| `protected-terms.json` | 5 groups | [SRC] | Which words a diff may never quietly change. |
| `errata.json` | 9 | [SRC] | Every known deviation from the printed page. |

Plus two things Dev A authors by hand rather than generates: the **master lexicon** (§T.5) and the **illustration briefs** (§T.7).

## T.2 The spine is frozen, and the file says so

`lesson-index.json` is the only place the order lives. It is written once, from the book, and never sorted, never recomputed, never derived from a folder listing.

```jsonc
{ "id": "L21", "order": 21, "unitId": "consonnes", "archetype": "consonant",
  "focusKind": "letter", "glyphs": ["g"], "phonemes": ["ɡ"],
  "keyword": "guitare", "keywordArticle": "une", "illustrationId": "ill_guitare",
  "hasTree": true, "hasSentences": true, "sourcePages": [46, 47] }
```

Two [SRC] facts are encoded here that a careless implementation loses:

- **Lessons 23 and 24 ship in numerical order** — 23 = z, 24 = h — even though the printed book has them on pages 52 and 50 respectively. Registered as `E-001`, status `applied`. The `sourcePages` field still points at the real page, so a facilitator holding the book can always find it.
- **Lesson 24 (h) has `hasSentences: false`.** It genuinely has no sentence block. That is a fact about the page, not an omission in the data, and encoding it means the renderer needs no special case.

## T.3 Sounds and spellings — the table the book never prints

The book *presents* graphemes. It never *tabulates* the correspondences, so nothing in it tells you that `ai` is taught with two different sounds eleven pages apart. `grapheme-phoneme.json` does.

**The polyvalent rows are the most valuable eleven rows in Pack 1.** These are the spellings the book deliberately teaches twice, with a different sound each time — and they are precisely where an adult decoder stalls, because everything she has learned so far has been one-spelling-one-sound.

| Spelling | First taught | …as | Taught again | …as | Why it matters |
|---|---|---|---|---|---|
| `s` | L19 | /s/ *sac* | L47 | /z/ *magasin* | Between two vowels the sound flips. The book gives this its own lesson. |
| `c` | L20 | /k/ *couteau* | L46, L48 | /k/ = `qu` = `k`; then /s/ + `ç` | Three lessons for one letter. Sequencing, not repetition. |
| `g` | L21 | /ɡ/ *guitare* | L43, L44 | /ʒ/; then `gu` = /ɡ/ | **This is why L21's tree shows only `gu, go, ga`.** The soft *g* is withheld for twenty-two lessons. |
| `ai` | L36 | /ɛ/ | L37 | /e/ | Two adjacent lessons, one letter pair, two sounds. |
| `k`, `qu` | L22, L46 | /k/ | — | — | The convergence the book builds towards: `qu = k = c`. |

**On `q`.** French never writes `q` without its `u`. The letter is therefore taught exactly where it occurs — inside `qu`, at Lesson 46 — and the app invents no lesson for it. `w` and `x` are loanword letters and appear on the alphabet wall only. This closes the "20 consonnes, 17 lessons" finding from §B.2; it is recorded as `E-009` with status `documented`, not as a defect.

## T.4 The syllabary — 131 rows, produced by multiplication

Seventeen consonant trees × eight vowel graphemes, minus the restrictions the book prints. The generator emits the whole set; every row carries the state it had *on the printed page*, so the renderer reproduces the book rather than a tidied version of it.

```jsonc
{ "id": "tè", "text": "tè", "consonant": "t", "vowel": "è", "ipa": "tɛ",
  "lessonId": "L08", "order": 8,
  "inPrintedTree": false,          // p.20's tree has seven branches
  "inPrintedStrip": true,          // …the strip below it lists eight
  "derived": [], "audioId": "syll.te_grave",
  "irregular": false, "note": null, "verifyAgainstSource": false }
```

Three fields earn their place:

- **`inPrintedTree` / `inPrintedStrip`** reproduce Lesson 8's discrepancy exactly rather than resolving it. The tree really does omit `tè` while the strip really does list it, and a learner comparing screen to page must see the same thing on both.
- **`derived`** is the third column of the extended trees at Lessons 8 and 16 — `ti → tite`, `bé → bébé`. An optional array, so seventeen lessons share one renderer.
- **`verifyAgainstSource`** flags the six rows where consonant × vowel is phonologically irregular — `ci`, `ce`, `cé`, `cè`, `cê`, and `si`. The generator cannot know whether the book restricted the tree there the way it restricted `g`. **Dev A must check those six against the PDF before writing L19 and L20**, and the flag is how the task is remembered.

Each syllable also names a **fusion clip**: `blend.ta` is the recording « t … a … ta ». That clip is the audio equivalent of the arrow the book draws, and it is the single most pedagogically important recording in the app — see §W.3.

## T.5 Decodability — the file that makes the method enforceable

§B.5 stated that cumulative decoding is a functional requirement. `decodability.json` is what turns that statement into something a computer can check. For each of the 56 lessons it holds the exact set of letters, graphemes and syllables a learner has met by the end of it.

| After | Letters | Syllables | Graphemes | Distractor pool |
|---|---|---|---|---|
| L01 | 1 | 0 | 0 | 1 |
| L07 | 9 | 0 | 0 | 9 |
| L08 | 10 | 8 | 0 | 10 |
| L12 | 14 | 40 | 0 | 14 |
| L16 | 18 | 72 | 0 | 18 |
| L24 | 26 | 131 | 0 | 26 |
| L36 | 26 | 131 | 33 | 59 |
| L56 | 26 | 131 | 81 | 107 |

Read the L08 row again: at that point in the book a learner has **ten letter forms and eight syllables**. Everything Lesson 8 shows her — `toto tâte ta tête.` — is built from that. This is not a curiosity; it is the constraint that every generated exercise, every distractor and every comprehension question in Pack 2 must satisfy, and `distractorPool` is the only legal source for them.

**The rule, stated once:** *nothing the app shows a learner at lesson n may contain a letter or grapheme absent from the ledger row for lesson n.* Not lesson text, not an exercise option, not a wrong answer, not a question. Validator rule 4 checks it on every pull request.

## T.6 The validator grows from eight rules to fourteen

Rules 1–8 are unchanged from §I.4. The six new ones exist because Part Two adds artefacts that can be silently wrong.

| # | Rule | Why it exists |
|---|---|---|
| 9 | Every syllable referenced by a lesson exists in `syllabary.json` with the same `lessonId`. | Catches a tree branch typed by hand into lesson JSON. |
| 10 | Every distractor in every generated item appears in that lesson's `distractorPool`. | The mechanical form of the cumulative-decoding guarantee, applied to exercises. |
| 11 | Every UI string key has a non-null `i` (icon) unless its `ctx` explains the exception. | A learner who cannot read has only the icon. |
| 12 | Every `audioId` referenced anywhere resolves in `audio-manifest.json`; every manifest entry matches the ID grammar regex. | The A↔D seam, checked in both directions. |
| 13 | No protected term has been altered or removed by the diff. | Stops a well-meaning spellcheck turning *margouillat* into *lézard*. |
| 14 | Every comprehension question passes the decodability check against its own lesson. | A question she cannot read is a decoding test wearing a disguise. |

Rules 10 and 14 are the ones worth arguing for. They mean an exercise cannot be *pedagogically* wrong in the one way that matters most, and the check costs milliseconds in CI.

## T.7 Illustration briefs — 24 drawings, unambiguously specified

The book's line drawings are Batonga's (see R-01). Whether they are licensed or redrawn, twenty-four images must exist and must agree with each other. The brief is short because it is binding.

- **Subject:** exactly the keyword, nothing else in frame. *une bassine* is a basin, not a woman carrying a basin.
- **Register:** adult. The audience is adolescents and young women; a children's illustration style undercuts the dignity framing of the preface as surely as a leaderboard would.
- **Grounding:** Beninese. *un canari* is an earthenware water jar, not a caged bird. *une case*, *un pagne*, *un marigot* have specific referents, and getting them wrong breaks the word–object link the lesson exists to build.
- **Form:** single-weight line art, no fill, no text, no shadow; must read at 96 dp; SVG ≤ 15 KB.
- **Colour:** monochrome, inheriting the theme's ink colour, so the same file works in both themes.

Beyond the 24 keywords, the answer options in Pack 2's comprehension items need pictures too. Those go on the same backlog and follow the same brief; the count is not known until Batonga's questions land.

## T.8 The thematic lexicon — the book's own commerce vocabulary, surfaced

The preface connects literacy to running an income-generating activity, and §B.3 noted that the reading texts carry economic vocabulary throughout: *la vendeuse, le marchand, un acheteur, le magasin, la banque, le client, l'étalage, vendre, acheter, les opérations*.

**This is not a business-literacy module and must not become one.** No new curriculum is authored. What Pack 1 adds is a `themes` tag on `VocabularyItem` — `commerce`, `maison`, `nourriture`, `école`, `village` — so that Entraînement can offer « Les mots du commerce » as a practice set drawn **entirely from words the book already teaches, at lessons she has already completed**. The theme filter reads the decodability ledger like everything else: a word she cannot yet decode does not appear in it.

It is the cheapest possible honouring of the preface's promise, it needs no approval beyond the tagging itself, and it stays true to §J.6: transcribed, not authored.

## T.9 The master lexicon

Every word in the book, once, with the fields the app needs and the page does not carry.

| Field | Source | Note |
|---|---|---|
| `print` / `cursive` | [SRC] | Verbatim. Separate fields because the book occasionally differs. |
| `article` | [SRC] | The book teaches words with their article; strip it and you teach the wrong thing. |
| `syllables` | [DERIVED] | Segmented against `syllabary.json`, so long-press playback is generated, not hand-marked. |
| `graphemeSpans` | [DERIVED] | Character offsets of each grapheme, which is what makes the grapheme-hunt activity possible. |
| `firstLessonId` | [SRC] | Where it appears. |
| `decodableFrom` | [DERIVED] | The **earliest** lesson at which every one of its letters is available. Usually equals `firstLessonId`; **where it does not, the book has printed a word ahead of its own method, and that is worth knowing.** |
| `themes` | [ADAPT] | §T.8. |
| `illustrationId` | [SRC] | Only the 24 keywords have one. |
| `audioId` | [DERIVED] | `word.` + ASCII slug. Never hand-assigned. |

`decodableFrom` is the quiet star of this table. Run it across all 56 word lists and it produces a short report of every place the printed book gets ahead of itself — the single most useful thing this project can hand back to the Foundation, and a genuine contribution rather than a digitisation.

## T.10 Dev A's added tasks

| # | Task | Done when |
|---|---|---|
| A9 | Port `gen_corpus.py` to `tools/gen-corpus.ts`; wire to `npm run gen:corpus` | Regenerating produces a byte-identical tree; CI fails on drift |
| A10 | Verify the six `verifyAgainstSource` syllables against pp. 42–47 | Flags cleared or the tree restricted, with an errata entry either way |
| A11 | Author the master lexicon as the 56 word lists are transcribed | `decodableFrom` computed for every entry |
| A12 | Produce the *decodability exceptions* report for Batonga | One page, every word printed ahead of its method |
| A13 | Add validator rules 9, 10, 12, 13, 14 | `npm run validate-content` covers all fourteen |
| A14 | Tag `themes` on every lexicon entry | « Les mots du commerce » populated from real data |
| A15 | Write the illustration brief and hand it to whoever draws | 24 SVGs specified, each ≤ 15 KB |

---

# U. Pack 2 — La Banque d'Exercices  ◆ Dev B

> **The gap.** The book contains **no exercises**. No questions, no answers, no self-check, no test, no comprehension prompts, no answer key. Its only activities are *read aloud*, *copy*, and *trace*. §J.1 mapped every source element to a digital interaction; what it did not do is say where the actual questions come from. Pack 2 is the answer, and every word of it is **[NEW]**.
>
> That means every item needs a pedagogical justification, and none of it ships without Batonga seeing it.

## U.1 Items are generated, not written

The obvious approach is to hand-author a question bank: 67 lessons × 5 activity types × 5 items ≈ **1 675 questions**. Reject it, for three reasons.

1. **It decays.** Correct one word in Lesson 32 and some unknown number of hand-written items now reference a word that no longer exists. Nothing tells you which.
2. **It cannot be checked.** A hand-typed distractor using a letter from Lesson 40 inside a Lesson 12 exercise looks completely normal in a JSON file. It is a serious pedagogical bug and no reviewer will catch it by reading.
3. **It is four weeks of a student's life** spent typing, in a project that already has 56 lessons to transcribe.

**A generator is correct by construction.** Its inputs are the lesson, the decodability row, and the confusion matrix; it *physically cannot* emit an item using an untaught letter. Its output is reproducible — the seed is `fnv1a(lessonId + ':' + activityType + ':' + itemIndex)`, never `Math.random()` — so an item that confuses a learner in the field can be reproduced exactly on a developer's machine.

The trade is that generated items are less surprising than authored ones. For a syllabaire, where the whole method is systematic repetition, that trade is close to free.

## U.2 The confusion matrix — how to be wrong usefully

This is the pack's centre of gravity, and the part most likely to be skipped by a team in a hurry.

**A distractor chosen at random teaches nothing.** Show a learner `t` among `t, m, ou, 7, é, b` and she picks the `t` by elimination, learning nothing about `t`. Show her `t` among `t, f, l, t, i, t` and she has to actually look. The wrong answers are where the teaching happens.

`confusion-matrix.json` therefore holds two graphs.

**Visual neighbours** — used by `tap-identify` and `missing-letter`, where the learner is looking:

| Target | Neighbours | The discrimination being forced |
|---|---|---|
| `b` | d, p, h | Orientation and ascender — the classic beginner reversal |
| `d` | b, p, q, a | The full rotation family |
| `n` | u, m, h, r | Arch count and direction |
| `é` | è, ê, e | Diacritic only — everything else identical |
| `o` | a, c, e, 0 | Closure, and the digit |
| `6` | 9, 0, b | Rotation, across the letter/digit boundary |

**Auditory neighbours** — used by `listen-choose` and `syllable-build`, where she is listening:

| Contrast | Pairs | Why it is the right drill |
|---|---|---|
| Voicing | p/b, t/d, k/g, f/v, s/z, ch/j | Six French minimal pairs. The mouth does the same thing; only the voice differs. |
| Nasals | an / on / in | Three sounds the book spends Lessons 25, 26 and 31 separating. Drilling them against each other is exactly what those lessons are for. |
| Rounding & height | é/è, eu/e, u/ou, o/au | The vowel confusions that survive longest. |
| Liquids | r/l | Worth drilling, and worth watching in the field test. |

Two rules keep the matrix honest:

- **Every candidate is filtered against the lesson's `distractorPool` before use.** A `b/d` contrast is unavailable at Lesson 12 because `b` arrives at Lesson 16. The matrix proposes; decodability disposes.
- **The auditory sets must be re-checked against the final recordings.** They describe contrasts *in the recorded Beninese French of this app*, not in an abstract standard. If the voice does not distinguish a pair, that pair is removed rather than drilled — drilling a distinction the model audio does not make is teaching a learner she is wrong when she is right.

## U.3 The five generators

Each is a pure function of (lesson, ledger, matrix, seed), with a three-tier difficulty ladder so the same generator serves Lesson 3 and Lesson 53.

| Type | Objective | Tier 1 → Tier 3 | Pass | Mastery evidence |
|---|---|---|---|---|
| `tap-identify` | Reconnaître la forme cible | 6-cell grid, random distractors → 12-cell, visual neighbours, print + cursive mixed | 0.80 | letter |
| `listen-choose` | Associer un son à sa forme | 3 options, random → 4 options, auditory neighbours, word-level targets | 0.75 | letter / syllable / word |
| `syllable-build` | **Fusionner consonne + voyelle** | 4 rounds with model shown → 6 rounds, audio only | 0.60 | syllable |
| `missing-letter` | Attention à une lettre dans un mot | 3 candidates on the focus letter, word shown first → 4 candidates, any position | 0.70 | word + letter |
| `trace` | Produire la lettre à la main | ghost + dots, tolerance × 1.4 → free, tolerance × 0.8 | 0.55 | letter |

Three implementation details carry most of the pedagogy:

- **`syllable-build` plays the fusion clip on success**, not the plain syllable. Hearing « t … a … ta » is the auditory form of the arrow the book draws. Playing only « ta » wastes the moment.
- **`missing-letter` speaks the wrong word she built.** She meant *farine*, she chose `m`, so the app says *« fa-mine »* — then *farine*. Hearing the consequence of her own choice explains the error better than any message could, and it is the single most instructive piece of feedback in the app.
- **`listen-choose` items are dropped at generation time when `audioService.has()` is false.** A silent listening exercise is worse than a missing one. The bank is simply shorter until the clip is recorded, and gets longer by itself afterwards.

## U.4 The repair ladder — there is no failure state

The book assumes a patient human beside the learner. The app must be that, and being that is mostly about what happens when she is wrong.

| Attempt | What the app does | What it says | Hint cost |
|---|---|---|---|
| 1 | Replays the target. Does **not** reveal the answer. | « Écoute encore. » | 0 |
| 2 | Fades two options out; two remain. | « Écoute bien. C'est l'un des deux. » | 0.25 |
| 3 | Lights the correct answer, replays the item empty. | « Regarde : c'est *{réponse}*. Écoute : *{réponse}*. » | 0.5 |
| 4 | Validates it for her and moves on. | « On continue. Tu la reverras. » | 1.0 |

After rung 4 the target enters the review queue at `strength = 0.15`, which is the whole point: the app has not decided she failed, it has decided to bring this one back on Thursday.

**Banned outright:** buzzer, red cross, lives, timer, negative score, any message naming failure, any gating of the next lesson. These are not stylistic preferences. §J.5 rejected leaderboards because the audience is adults excluded from school and public ranking risks shame; the same argument applies with more force to a failure state she meets in private, twenty times a session.

## U.5 Assessment, woven — Bilan, checkpoints, placement

Batonga's instruction was that assessment lives inside each pack rather than as a separate system. In practice that means three surfaces, all built from the same generators.

**Bilan** — 4–5 mixed items at the end of every lesson, drawn at tier 2 with a fresh seed.

| Archetype | Items | Mix |
|---|---|---|
| `vowel` | 4 | 2 tap-identify · 1 listen-choose · 1 trace |
| `consonant` | 5 | 2 listen-choose · 2 syllable-build · 1 missing-letter |
| `grapheme` | 5 | 2 listen-choose · 2 missing-letter · 1 comprehension |
| `numeral` | 4 | 1 tap-identify · 2 listen-choose · 1 trace |

Scoring ≥ 0.7 says « Bien lu ». Below 0.7, the weak targets enter the review queue — **and she advances anyway.** Locking an adult out of Lesson 12 because she scored 0.6 on Lesson 11 is how you lose her, and it contradicts §B.5: repetition is the method, not gatekeeping. Lessons 46, 48, 49 and 54 have no reading text, so their Bilan simply has four items instead of five. The blueprint shortens; no code branches.

**Checkpoints** — six, not four. Unit 3 runs 32 lessons, and a single checkpoint after L56 would be a wall, so it is split into the four eight-lesson blocks the Parcours already groups by.

| ID | After | Items | Focus |
|---|---|---|---|
| CP1 | L07 | 10 | the nine vowel spellings |
| CP2 | L24 | 14 | 17 consonants + 12 sampled syllables |
| CP3a | L32 | 10 | nasals and first digraphs |
| CP3b | L40 | 10 | lessons 33–40 |
| CP3c | L48 | 10 | **the two-sound letters — g, s, c, ç** |
| CP3d | L56 | 12 | clusters and long texts |
| CP4 | D9 | 10 | the ten digits |

CP3c is deliberately weighted toward `listen-choose`: by then the difficulty is no longer recognising a shape, it is knowing which of a letter's two sounds applies.

**Placement test** — the information architecture in §C.2 already offered « J'en connais déjà » at first run, and nothing existed behind it. Now: an adaptive ladder, three rungs, at most 12 items, about four minutes.

| Rung | Probes | Pass → | Fail → |
|---|---|---|---|
| 1 | voyelles i u o a e é | rung 2 | start at L01 |
| 2 | syllabes ta pi mo ne lu ré | rung 3 | start at L08 |
| 3 | graphèmes an ou oi ain ch eu | start at L25 | start at L15 |

Three guardrails, all non-negotiable. It is **fully spoken**. It **never reports a score or a level** — the result is « Tu peux commencer ici » and a lesson title, nothing else. And **a placement result never locks earlier lessons**: everything before the entry point is marked `available`, not `completed`, so the Parcours shows open doors rather than skipped ones. Quitting at any point silently starts her at L01 with no mention of the test.

## U.6 Comprehension — the system, not the questions

The 28 reading texts are the point of Unit 3, and the book asks nothing about them. Comprehension is now in MVP. But **developers cannot write these questions**, and pretending otherwise would be the exact failure §J.6 warns about.

So `comprehension.json` ships the **system** — taxonomy, answer modes, templates, hard rules, workflow — and leaves the content to Batonga.

| Kind | Per text | Asks | Why it is placed where it is |
|---|---|---|---|
| **littérale** | 1, always first | Something written in the text, in so many words | Tests decoding, not inference. A beginner must be able to succeed by re-reading one sentence. |
| **lexicale** | 1 | The meaning of a word, answered with a picture or two choices | The book's Beninese vocabulary is *her* vocabulary. This confirms the word–thing link rather than teaching it. |
| **inférentielle** | 0–1, **not before L36** | Something true but unwritten | Earlier, inference punishes a learner who decoded perfectly. It arrives only once texts are long enough to carry it. |
| **personnelle** | 0–1, **never scored** | A link to her own life | This is what turns decoding into reading. No right answer, spoken response or skip. |

**Hard rules, enforced by `validate-comprehension.ts`:**

- A question may contain **no grapheme its own lesson has not taught** — the same decodability check as the lesson text. This is validator rule 14, and it is what keeps a comprehension question from secretly being a decoding test.
- Every question is **spoken as well as written**.
- Every wrong answer **replays the sentence of the text that holds the answer**, highlighted in place.
- **Maximum three questions per text.** The text is the lesson; the questions are the check.
- Distractors for `phrase-pick` are **other sentences from the same text** — never invented sentences, which would smuggle in untaught spellings.
- No questions about the moral, the author's intent, or the title.

The authoring workflow is five steps and belongs in the schedule, not in someone's head: A exports the 28 texts to `docs/textes-a-questionner.md` → Batonga writes 2–3 questions per text into the fixed shape → B runs the validator → any pictures needed go on A's illustration backlog → nothing ships without a named row in `docs/comprehension-signoff.md`.

**This is a dependency on a third party inside the MVP, which is new.** It is logged as risk **R-16**, and the mitigation is the feature flag: `features.comprehension` ships off, the app is complete without it, and the questions arrive by EAS Update when Batonga signs them off.

## U.7 The trace rubric, extracted from the code

`scoreTrace` stays a pure function (§J.4 — path-following, never recognition). What Pack 2 adds is that its **parameters live in JSON**, so they can be retuned from field-test data without a release.

| Component | Weight | Passes at | Why it is weighted this way |
|---|---|---|---|
| Checkpoint coverage, **in order** | 0.35 | ≥ 80 % | Order is what the book teaches. |
| Direction agreement | 0.25 | ≥ 75 % of segments | **A `t` drawn bottom-up is wrong even though it looks right.** The pages drill stroke direction; a recogniser that accepted it would be pedagogically wrong. |
| Start proximity | 0.20 | ≤ 12 % of glyph height | Every écriture page prints a start dot. |
| Max deviation | 0.15 | ≤ 18 % | Legibility, loosely. |
| Stroke count | 0.05 | exact | Low weight — a learner who joins two strokes has still learned the letter. |

Stars at 0.35 / 0.55 / 0.78. Tolerances vary by glyph class: accented vowels get × 1.2 because the accent is a stroke in its own right and may legitimately be added last; digits get × 1.05 and follow the book's own numbered arrows, which are more precise than the letter pages'.

Six spoken cues carry the correction — « Commence ici, en haut. », « Descends, ne monte pas. », « Doucement, suis le trait. » — delivered as a guiding hand, never a verdict. And the hard rule: **a low score never blocks the lesson.** After three attempts the app replays the animated model once and moves on with « On réessaiera plus tard. »

## U.8 Dev B's added tasks

| # | Task | Done when |
|---|---|---|
| B8 | Item generation layer: `generateItems(lesson, type, count, seed)` | Same seed → identical items, asserted in a test |
| B9 | Load and apply `confusion-matrix.json`, filtered by `decodability.json` | Property test: **no generated item ever uses an out-of-ledger symbol**, across all 67 lessons × 5 types |
| B10 | Repair ladder as one component, used by every activity type | Four rungs verified; no path reaches a dead end |
| B11 | Bilan + the six checkpoints from their blueprints | Playable end to end; a sub-threshold Bilan advances and enqueues review |
| B12 | Placement test with all three guardrails | Abandonable at any point; never shows a score; never locks a lesson |
| B13 | `validate-comprehension.ts` + the export for Batonga | Runs in CI; the 28-text export generated |
| B14 | Move `scoreTrace` parameters into `trace-rubric.json` | Tuning needs no code change |
| B15 | Wire the spoken cues into the trace canvas | Cue fires on the matching failure component, on a physical device |

---

# V. Pack 3 — La Voix de l'Interface  ◆ Dev C

> **The gap.** Every page of the book presumes someone literate is sitting beside the learner — reading the word aloud, saying *now trace it*, noticing she has stopped, telling her that was right. The book never documents that person, because it never had to. **The app has to become her**, and that role is made of language: what it says, when it says it, and what it shows when it says nothing.
>
> §K.1 stated the principle — *at install time the user cannot read the interface.* Pack 3 is the execution: every string, every icon, every spoken line, written out.

## V.1 The dual-string principle

A string in this app is not a string. It is three channels that must all be present.

```ts
type UiString = {
  t: string;              // written label
  a: AudioId;             // spoken clip — NOT optional
  i: IconId | null;       // pictogram — null only with a documented reason
  spoken?: string;        // when the written label must be short but the
                          // spoken one must be a whole sentence
  ctx?: string;           // why this key is the way it is
};
```

`spoken` is the field that matters most and is easiest to leave out. The button says **« Écouter »**; the voice says **« Appuie sur le haut-parleur pour écouter. »** Recording the two-word label produces an app that mutters nouns at someone who needs a sentence.

A key with a null `i` and no `ctx` is a lint failure (validator rule 11), not a style note. For this learner the icon *is* the label.

`ui-strings.fr.json` holds **179 strings across 14 namespaces** — one file per namespace on disk, per §O.4, so four developers never touch the same i18n file.

## V.2 Deliberately empty strings

Six keys ship with an empty `t` and a `ctx` explaining why. They are in the catalogue precisely so nobody later "fixes" them.

| Key | Why it is empty |
|---|---|
| `errors.offline` | The app is offline **by construction** (§C.4). There is no offline state, so there is no offline message. |
| `errors.audio.missing` | When `has()` returns false the speaker icon is **not rendered**. For the learner that button never existed. A greyed-out icon with an explanation would invent a problem she does not have. |
| `activity.attemptsLeft` | There is no attempt limit. Nothing to count down. |
| `progress.noComparison` | No ranking, no cohort average, no comparison with other learners — ever (§J.5). |
| `facilitator.export` | Nothing leaves the phone in MVP. |
| `errors.content.broken` | Renders as a neutral **« Continuer »** card. A malformed payload is a content bug; it must never look like the learner's fault, and must never crash a lesson (§H.2). |

## V.3 The icon lexicon — 82 pictograms, closed

For someone who cannot read, an icon that means two things is a bug of the same severity as a mistranslation. `icon-lexicon.json` is therefore a **closed set**: adding an icon is a design decision made once, by Dev C, and recorded with its meaning.

The rules are short. One icon, one meaning, app-wide. Never colour alone. Every icon has a spoken label reachable by long-press. Minimum 32 dp rendered inside a 56 dp target. **No emoji, ever** — they render differently on every device and read as childish to the audience.

A few entries carry notes that are really design decisions:

- **`speaker`** means exactly one thing: *listen to what is next to this*. It never means "sound is on".
- **`close`** is never used to signal a wrong answer. Nothing signals a wrong answer.
- **`warning`** is for technical problems only — storage full, no audio output — never for the learner's input.
- **`seedling`** replaces every idea of failure. « C'est en train de venir. »
- **`flame`** counts **days she opened the app**, not days she was right (§J.3).
- **`tree`** reuses the arrow graphic of the book's own syllable trees, and **`notebook`** reuses its Seyès ruling. Where the book has already taught a visual convention, the app inherits it rather than inventing one.

Style: single-weight line art, 2 dp stroke, drawn from the same visual world as the book's illustrations — adult, Beninese, uncluttered.

## V.4 The narrated first run

Seven steps, about two minutes, and **nothing in it requires reading or typing.** Audio auto-plays on entering each step and replays on tapping anywhere. Every step has exactly one primary action and a fallback line that fires after eight seconds of no input.

| # | Step | What the voice says | What she does |
|---|---|---|---|
| 1 | Bienvenue | « Bienvenue. Cette application t'apprend à lire et à écrire le français. Tu n'as pas besoin de savoir lire pour t'en servir. Appuie sur le grand bouton vert. » | taps one green button |
| 2 | Le son | « Est-ce que tu m'entends bien ? Si tu ne m'entends pas, monte le son de ton téléphone, sur le côté, vers le haut. » | picks one of two |
| 3 | Ton nom | « Comment veux-tu qu'on t'appelle ? Tu peux écrire ton nom, ou choisir une image. Tu peux aussi passer, ça n'a pas d'importance. » | types, picks an avatar, or skips |
| 4 | **Essayons** | « On essaie ensemble. Touche le rond bleu. » | taps a blue circle |
| 5 | Écoute | « Quand tu vois ce dessin — un haut-parleur — tu peux toujours appuyer pour écouter. Essaie. » | taps the speaker |
| 6 | Par où commencer | « Veux-tu commencer au début, ou veux-tu que je regarde d'abord ce que tu sais déjà ? Si tu n'es pas sûre, commence au début. » | picks one of two |
| 7 | C'est prêt | « C'est prêt. Prends ton temps. Tu peux t'arrêter quand tu veux : l'application se souvient d'où tu t'es arrêtée. » | starts Lesson 1 |

**Steps 4 and 5 are the ones to defend in a scope argument.** They are the only place the app verifies she can operate it — that she can find a target and tap it, and that she understands the speaker icon means *listen* — before any content depends on both. Three seconds each, and they prevent the silent abandonment where a learner never discovers that the app talks.

Step 3 is where a conventional design would ask for an email. There is no email, no password, no phone number (§C.6). Asking a low-literacy learner to type an email address is a dignity failure, not just a UX one.

**Returning learners** get a different line depending on the gap: one to two days, « Te revoilà. » ; three to thirteen, « Contente de te revoir. On reprend doucement. » ; fourteen or more, « Ça fait un moment. On va revoir ensemble avant de continuer. **Rien n'est perdu.** » — and that last one inserts a five-item review session drawn from the weakest mastery rows before the path resumes.

## V.5 The encouragement bank — 44 lines, specific or quiet

« Bravo ! » stops meaning anything the fourth time, and to an adult who left school early it reads as being spoken to like a child. Every line in the bank is either **specific** — it names what she actually did — or **short enough to disappear**.

| Tier | When | Examples |
|---|---|---|
| **micro** | ordinary correct answer, under a second | « C'est ça. » « Oui. » « Voilà. » « Tu l'as. » |
| **specific** | end of a block, naming the fact | « Tu as lu {n} syllabes. » « Tu reconnais {lettre} même en écriture attachée. » « Tu as lu un texte de {n} phrases. » |
| **effort** | after a difficulty overcome | « Tu as réessayé, et tu l'as eu. » « Tu l'avais ratée la première fois. Plus maintenant. » |
| **repair** | after an error, never blame | « Pas encore. Écoute encore. » « C'est celle-là : {réponse}. » |
| **celebration** | lesson or unit only | « Première leçon terminée. C'est le plus difficile qui est fait. » |
| **return / closing** | opening and leaving | « Tu es venue {n} jours de suite. » « Je garde ta place. » |

Rotation is enforced: no line repeats within eight plays, and celebration fires at most three times per session. **Banned outright:** « Bravo !!! », « Super ! », « Génial ! », « Tu es la meilleure », « Tu as gagné », « Faux », « Erreur », « Mauvaise réponse », « Ma chérie », « Petite ». The last three are banned for the same reason leaderboards are: the audience is adults excluded from school, and an infantilising tone undercuts exactly the self-esteem the preface sets out to build.

## V.6 Repair flows — the moments paper never had

Nine flows, each defined by **what the app says**, because she cannot read what it writes.

| Trigger | The app says | And does |
|---|---|---|
| Three failures on one target | « On laisse celle-ci pour aujourd'hui. Tu la reverras. » | validates it, `strength = 0.15`, continues — never a fourth attempt |
| `has(audioId)` is false | *nothing* | does not render the speaker icon at all |
| System volume at zero | « Le son de ton téléphone est coupé. Monte-le sur le côté. » | non-blocking banner |
| Different profile within 2 min | « Est-ce bien toi, {nom} ? » | two faces to tap — the family phone is normal |
| 14+ days away | « Ça fait un moment. Rien n'est perdu. » | 5-item review before resuming |
| Lesson interrupted | « On reprend ici. » | exact block, no recap |
| Locked node tapped | « Termine la leçon d'avant pour ouvrir celle-ci. » | animates the previous node; no dialog |
| Trace score < 0.2, three times | « Regarde encore comment on l'écrit. » | slow-motion model, then moves on — **never says the writing is bad** |
| SQLite write fails | « Ton téléphone est plein. Libère un peu de place. » | lesson continues in memory; the DB failure never reaches the UI (§H.3) |

## V.7 Register — one page, binding on all four developers

Copy is design here. The learner meets this app almost entirely through its voice.

| Question | Decision | Reasoning |
|---|---|---|
| Tutoiement or vouvoiement? | **Tutoiement** | It carries the closeness of an animatrice sitting beside her; vouvoiement reads administrative. **A cultural call, not a stylistic one — confirm with Batonga.** |
| Who is speaking? | An adult Beninese woman, calm, neither professorial nor maternal | The register of the cercle d'affaires facilitator, not a schoolteacher. |
| Sentence length | ≤ 12 words written, ≤ 20 spoken | An instruction that needs re-reading has failed. |
| Imperative or question? | Gentle imperative for instructions, question for choices | « Touche la lettre t » / « Tu veux t'arrêter ? » |
| May we name failure? | **Never** | « Pas encore » says the same thing without the weight. |
| Digits as words or numerals? | Always numerals — `3`, not *trois* | Unit 4 teaches the numeral's shape; the interface should show it. |
| Vocabulary | The book's. *Marigot*, *canari*, *fonio*, *pagne* — never swapped for a "clearer" synonym | `protected-terms.json`. |

And the checklist: one instruction, one action · name the object, not the abstraction (« le haut-parleur », not « le lecteur audio ») · no technical words in spoken instructions — not « application », not « menu », not « paramètres » · no English · no multiple exclamation marks · every written string has an equivalent spoken string, **not an identical one**.

## V.8 The facilitator surface

The book presumes a facilitator on every page. Batonga's cercles d'affaires and leadership clubs actually have one. She gets a small, deliberately unambitious surface — **on the same phone, no account, no network**. This is not the V2 web reporting product of §C.6.3, and conflating the two is how a mobile team loses a month.

**In scope:** several profiles on one phone · where each learner is · what to work on with her today · a group view to read off the screen at the start of a session.
**Out of scope:** accounts, sync, file export, cohort statistics, grading, learner-vs-learner comparison.

Three screens. *Les apprenantes* — one row per profile: name or image, current lesson, last seen, three weakest targets. *À faire ensemble aujourd'hui* — the most common current lesson across the group, the five most widely shared weak targets, and the three exercises that drill them; this is the only thing an animatrice actually asks for. *Voir une leçon* — any lesson read-only with audio, for preparing the session, recording no progress.

Access is Réglages → Mode animatrice, with an optional four-digit PIN **off by default**: a lock she forgets is worse than no lock. Guardrails: nothing leaves the phone, no ranking is ever shown to learners, and she can view a learner's progress but not edit it — except « recommencer », which asks twice.

## V.9 Dev C's added tasks

| # | Task | Done when |
|---|---|---|
| C9 | Import `ui-strings.fr.json` as 14 namespaced i18n files | No French literal in any component; `lint-strings.ts` green |
| C10 | Build the `UiString` type so `a` is required and `i` is required-with-exception | The compiler rejects a string without a clip |
| C11 | Draw or source the 82 icons to the lexicon spec | All present at 32 dp; every one has a spoken label on long-press |
| C12 | Implement the 7-step narrated onboarding, including the tap test and listen test | **A non-reader completes it unaided** — verified with a real person, not a teammate |
| C13 | Encouragement bank with rotation and per-session caps | No line repeats within 8 plays, asserted in a test |
| C14 | The nine repair flows | Each triggerable in a dev build and demonstrated on hardware |
| C15 | Facilitator mode, three screens | Walkable; no data leaves the device |
| C16 | Long-press spoken help on every control | Every interactive element in the app answers |

---

# W. Pack 4 — Le Corpus Sonore et le Modèle de Maîtrise  ◆ Dev D

> **Two gaps, one owner.** A syllabaire teaches sound–symbol correspondence, and paper has no sound: on the page that job belongs to a literate facilitator reading aloud. §A.2 called audio "the app's reason to exist" and §C.5 budgeted about 1 200 clips — but nobody had written down what to record or how. Separately, §G.2 declared a `MasteryRecord` with a `strength` field and never said how strength is computed, which leaves the review queue, the facilitator's *à travailler* list, and the very question of whether a letter is "known" resting on nothing.
>
> Pack 4 closes both. Both belong to Dev D because both are the floor everything else stands on.

## W.1 The ID grammar — the seam between two streams, as a regex

The audio ID is where Dev A's content meets Dev D's studio. If it needs a conversation, the two streams block each other every week. So it is mechanical, and CI enforces the shape:

```
^(letter|syll|blend|word|sent|text|digit|prompt|fb|cue|ui|vo|q)\.[a-z0-9_.-]+$
```

| Namespace | Shape | Example |
|---|---|---|
| `letter` | `letter.{glyph}.{name\|sound}` | `letter.t.name`, `letter.t.sound` |
| `syll` / `blend` | `syll.{c}{vowelkey}` | `syll.te_acute`, `blend.ta` |
| `word` | `word.{ascii-slug}` | `word.fonio` |
| `sent` / `text` | `sent.{lessonId}.{nn}` · `text.{textId}.{whole\|snn}` | `sent.L08.01`, `text.T27.s04` |
| `digit` · `prompt` · `fb` · `cue` · `ui` · `vo` · `q` | see `audio-id-grammar.json` | `fb.micro.03`, `ui.common.listen` |

IDs are lowercase ASCII; diacritics are transliterated, never embedded. **An ID is derived from content, never hand-assigned** — `tools/gen-audio-script.ts` scans `content/` and `src/i18n/` and emits every ID it finds with `status: "missing"`. Nobody types an ID into the manifest.

CI **fails** when content references an ID the manifest does not hold, and **warns** when the manifest holds an ID nothing references. Orphans are cheap; gaps are not.

## W.2 Two clips per letter, always

`letter.t.name` is « té ». `letter.t.sound` is the sound `t`, alone, with no supporting vowel — not « teu ».

Conflating them is the most common error in phonics audio and it teaches the wrong thing outright. **A syllabaire fuses sounds, not names.** A learner who has learned that the letter says « teu » will read `ta` as « teu-a » and the whole method fails at Lesson 8.

This is the hardest part of the recording session and it needs a person trained in literacy work in the room, checking each consonant live. Budget for it. It is a two-hour cost against a mistake that would be discovered in the field test and would require re-recording every consonant.

## W.3 The fusion clips

For every syllable there is a second recording: `blend.ta` is « t … a … ta » — the two sounds separated by a half-second, then the syllable fused.

**This is the audio form of the arrow the book draws.** The syllable tree on page 20 is a picture of fusion; on paper a facilitator performs it aloud. `blend.ta` is that performance, recorded once. It plays on a correct `syllable-build` answer and on long-press anywhere a syllable appears.

Mark the pause with a metronome at 500 ms so every fusion clip is identical. The regularity is not fussiness — it is what makes the pattern learnable.

## W.4 The recording script is generated

`recording-script.json` is produced by scanning Packs 1 and 3. Re-run the generator after any content or string change and the script regenerates. Nobody maintains it by hand, so it cannot drift from what the app actually asks for.

**590 clips are derivable today**, before a single word list has been transcribed:

| Group | Clips |
|---|---|
| Letters — 26 names + 26 sounds, plus q, w, x for the alphabet wall | 55 |
| Syllables (131) + fusion clips (131) | 262 |
| Interface strings | 174 |
| Encouragement bank | 44 |
| Digit names (10) + digit stroke cues (16) | 26 |
| Activity prompts (13) + trace cues (6) | 19 |
| Onboarding and returning-learner voice-over | 10 |

Pending from Dev A's transcription: ≈ 420 words, ≈ 190 sentences, 28 whole texts plus ≈ 250 per-sentence segments, and ≈ 70 comprehension questions once Batonga signs them off. **Total ≈ 1 550** — about 30 % above §C.5's estimate, mostly because of the fusion clips, which were not budgeted and are worth their weight.

The same generator emits `recording-script.csv` with a blank `prise_ok` column: the sheet the studio actually works from, sorted by session.

## W.5 Voice direction

**Casting.** An adult francophone woman from Benin. The learner should recognise a voice that speaks the way the women around her speak; a neutral hexagonal French would teach a register nobody in her market uses, and would put distance between the page and the street. Tone: accompagnatrice, not institutrice — adult to adult. Avoid a storytelling lilt, advertising emphasis, and the habit of speeding up at the end of a phrase.

A **second voice** is needed for the four dialogue texts (Lessons 30, 35, 38, 42). Book it into the same session.

**Technical.** Mono. 48 kHz / 24-bit captured, delivered 44.1 kHz AAC 64 kbps. −16 LUFS integrated, peak ≤ −1 dBTP, noise floor ≤ −60 dBFS. 120 ms of head and 200 ms of tail applied in the edit, not in the take. **The file is named exactly for its ID:** `letter.t.sound.wav`.

**Method.** Three takes of everything, best selected in the edit — never keep a merely acceptable take of a clip that will be heard hundreds of times. Record **by type, not by lesson**: all the letters, then all the syllables, so the register stays even and the performer stays in the gesture. For the bracketed templates (« Touche la lettre {lettre} ») record one take per value; concatenation is audible.

**Quality gate.** Nothing over −1 dBTP. No audible mouth noise on headphones. **Listening check on a phone loudspeaker, never on headphones** (§P.5) — that is how it will actually be heard. And a third listener identifies every consonant sound blind.

## W.6 Five sessions, deliberately off the critical path

| # | Week | Content | Clips | Studio | What it unblocks |
|---|---|---|---|---|---|
| 1 | 4 | letters, syllables, fusions, digits | **327** | 6–8 h | all of Units 1 and 2 become audible |
| 2 | 5 | every UI string, onboarding VO, encouragement, prompts | **241** | 4–5 h | the app becomes usable by a non-reader |
| 3 | 7 | the 56 word lists, trace cues | ≈ 440 | 5–6 h | `listen-choose` and `missing-letter` on real words |
| 4 | 9 | sentences, the 28 texts whole and per-sentence, 4 dialogues | ≈ 470 | 7–9 h | Unit 3 in full |
| 5 | 12 | field-test fixes, Batonga-approved comprehension questions | ≈ 120 | 2–3 h | **always plan this session; there are always retakes** |

Total 24–31 studio hours, plus roughly 1.5× that in editing, plus a 10 % re-record reserve.

**The contingency is the reason this works.** If the schedule slips, ship v1 with sessions 1 and 2 only — letters, syllables, digits, interface. That is exactly the core of a syllabaire, so the app stays pedagogically coherent, and words, sentences and texts arrive later by EAS Update without a store review. And because `audioService.has()` hides the speaker icon for unrecorded clips, **the learner does not see a gap — she sees a simpler app.**

## W.7 The mastery model

`strength ∈ [0, 1]`, one row per (learner, target), updated once per `ActivityResult` per target.

```
gain    = w_type × w_difficulty × (1 − s) × (1 − 0.5 × hintsUsed)
penalty = 0.15 × s                    // on an incorrect target, floored at 0
s'      = clamp(s + gain − penalty)
```

Three deliberate choices:

- **`(1 − s)` makes early exposures worth a lot and late ones worth little**, which is how learning a letter actually feels. Without it, twenty easy repetitions would drive a fragile letter to 1.0.
- **The hint discount** means a target reached only after the answer was shown does not count as knowing it. Rung 3 of the repair ladder halves the gain; rung 4 gives none.
- **Not all correct answers are equal evidence.** Producing a letter by hand is stronger evidence than picking it from a grid of six.

| Activity | Weight | | Activity | Weight |
|---|---|---|---|---|
| `tap-identify` | 0.10 | | `trace` | 0.25 |
| `word-match` | 0.15 | | `review` | 0.28 |
| `listen-choose` | 0.18 | | `bilan` | 0.30 |
| `missing-letter` | 0.20 | | `checkpoint` | 0.40 |
| `syllable-build` | 0.22 | | | |

**Decay:** 2 % per day after three days without exposure, with a floor of 0.2 once a target has ever reached 0.6. The floor matters — decay exists to order the review queue, not to tell a learner she has forgotten a letter she demonstrably learned.

| Band | Range | What it drives |
|---|---|---|
| inconnue | < 0.25 | appears nowhere |
| fragile | < 0.50 | top of the review queue; listed for the animatrice |
| en cours | < 0.75 | normal review |
| **acquise** | ≥ 0.75 | counted in « {n} lettres reconnues » |

**A target is *acquise* at s ≥ 0.75 with at least three exposures across two distinct days.** The second criterion stops one good session from declaring a letter learned.

Aggregation rolls up to lesson and unit mastery — but **never as a percentage shown to the learner.** Mes Progrès counts things done: lessons finished, letters recognised, syllables read, texts read, days attended. Not a success rate.

## W.8 Progression rules — deliberately generous

§H.5 said Dev C renders `PathState` and holds no progression logic. These are the rules behind it.

**Unlock:** lesson *n+1* opens the moment lesson *n* is **finished** — every block seen and the Bilan attempted — **whatever the score. No exceptions.** Gating on a score punishes exactly the learner who most needs to keep going, and it contradicts the book's method: repetition, not gatekeeping. The score feeds the review queue; it never touches the lock.

"Attempted" includes "skipped": `allowSkip` is true everywhere (§H.2).

**Always available:** the alphabet wall, the digits in read-only, the writing notebook, any completed lesson, and the thematic word sets. **Never available:** a lesson whose predecessor is unfinished — except after a placement test, which opens everything before the entry point as `available`, not `completed`.

**Resume** is per block. After fourteen days away, a five-item review session is inserted *before* the resume point. Exactly one node app-wide carries `isNext`: the first `available` lesson in path order.

## W.9 The review queue — shipped, and honest about what it does not know

Part One parked spaced review in V2 for a good reason: the intervals are guesswork without data. It now ships, with that honesty on the record.

**Queue:** at most 12 targets a day, 6 per session. Ordered by fragile-and-oldest first, then targets that failed the last Bilan, then *en cours* items that have come due. Never includes a target introduced in the last 24 hours, a target from an unfinished lesson, or more than four targets from one lesson in a session.

**Intervals (days):** fragile 1 / 2 / 4 · en cours 3 / 7 / 14 · acquise 21 / 45, with ±20 % jitter so everything does not fall due on the same morning.

**These intervals are conservative defaults drawn from common spaced-repetition practice, not from evidence about this cohort.** They must be recalibrated from real `MasteryRecord` data after the field test. That is logged as risk **R-17**, and `features.spacedReview` exists so the whole queue can be switched off if the field test shows it discourages rather than helps.

Presentation stays optional: Accueil → « À revoir aujourd'hui », introduced with « On revoit cinq choses, puis on continue. » It is never forced ahead of a lesson, except after a fourteen-day absence.

## W.10 Telemetry — local only, and for one purpose

A ring-buffered `event_log` table capped at 5 000 rows. No third party, no network, nothing in the sync outbox. No network identifiers, no location, no typed content, and a clear-the-log control in Réglages → À propos.

The purpose is not analytics. It is being able to answer **« pourquoi s'est-elle arrêtée là ? »** during the field test, from the device, with the learner sitting there.

| Event | Why it is worth a row |
|---|---|
| `activity.skip` | **The single most important signal in the app** — where she gives up |
| `block.view` with `dwellMs` | The block where time collapses is the block to redesign |
| `audio.play` with `repeatIndex` | A clip replayed five times is either a hard word or a bad recording |
| `lesson.abandon` | Where and how far in |
| `error.content` | A malformed payload renders a neutral card — without this event, nobody ever finds out |
| `audio.missing` | Catches an ID referenced but never recorded, in production |

Export by cable during the field test, never over the network. A long-press on Réglages → À propos shows a readable on-screen summary for the observer.

## W.11 Dev D's added tasks

| # | Task | Done when |
|---|---|---|
| D11 | `tools/gen-audio-script.ts` scanning Packs 1 and 3 | Regenerates the 590 rows plus the CSV; CI fails on drift |
| D12 | Enforce the ID grammar regex in the manifest generator | Malformed ID fails CI |
| D13 | Book the voice talent and run session 1 in **week 4** | 327 clips ingested and manifest-verified |
| D14 | Fusion clips recorded to the 500 ms metronome | `blend.*` plays on every correct `syllable-build` |
| D15 | Mastery engine to `mastery-model.json` | Unit-tested: gain, penalty, decay, floor, the two-day *acquise* rule |
| D16 | Progression rules — unlock, resume, availability, `isNext` | Property test: **no score anywhere can prevent an unlock** |
| D17 | Review scheduler behind `features.spacedReview` | Queue respects every cap; flag toggles cleanly |
| D18 | `event_log` with the ring buffer and the on-device summary | Field-test observer can read it without a laptop |
| D19 | Re-measure the perf budgets with ~1 550 clips bundled | §C.1 budgets still met on the reference Android Go device |

---

# X. Integrating the Packs

## X.1 Why the packs do not break the four-branch model

The whole value of Part One's allocation is that in weeks 2–10 nobody waits for anybody. Part Two must not spend that. It does not, for four structural reasons.

**1. Every new path has exactly one owner.** Part Two adds four directories and four tools. It adds **zero shared files** — no new contract, no new registry entry, no new route, no change to `theme.ts`, `package.json`, `tsconfig.json` or `app/_layout.tsx`. The list in §S.4 is the whole of it, and `CODEOWNERS` covers all of it.

**2. The two cross-pack reads are one-directional and file-based.**

```
content/corpus/decodability.json ──read──► Pack 2 generators        (B never writes it)
content/corpus/*  +  content/interface/ui-strings.fr.json
                                 ──read──► tools/gen-audio-script   (D never writes them)
```

A file read is not a dependency in the blocking sense: B can develop against a two-lesson fixture of the ledger from day one and swap in the real file the moment A commits it. Nothing about B's code changes when it does.

**3. Pack 4's generator turns A's and C's output into D's input automatically.** This is the same trick §M.2 used for audio IDs, extended. When Dev A commits Lesson 14 and Dev C adds nine strings, Dev D re-runs `gen-audio-script` and the studio sheet is current. No meeting, no hand-off, no spreadsheet.

**4. The contracts are untouched.** Everything in Part Two is data, tooling, or code strictly inside one owner's directory. `src/core/contracts/` — frozen in Phase 0 and the thing whose change would actually be expensive — does not move.

The one genuinely new external dependency is Batonga's comprehension questions (**R-16**), and it is isolated behind a feature flag rather than embedded in the schedule.

## X.2 The revised roadmap — 16 weeks

Phases 0–4 are unchanged from §L. Pack work lands inside them; only Phase 4b is new.

| Phase | Weeks | A — Corpus | B — Exercices | C — Interface | D — Son & Maîtrise |
|---|---|---|---|---|---|
| **0** | 1 | + freeze the [DERIVED] tag and the corpus generator contract | + confusion-matrix approach agreed | + the `UiString` three-channel type | + **ID grammar regex agreed** — this is the seam |
| **1** | 2–3 | Pack 1 generated; L01–L07 | item generation layer; `tap-identify` | routes, `@ui`, **`ui-strings.fr.json` authored** | schema, `progressService`, audio stub, script generator v1 |
| **2** | 4–6 | 9 renderers, L08–L24, illustrations | `listen-choose`, `syllable-build`, `scoreTrace` | Parcours, Accueil, **narrated onboarding**, fonts | **recording sessions 1 and 2**, mastery engine v1 |
| **3** | 7–8 | L25–L56 + the 28 texts | `missing-letter`, trace production, **repair ladder** | Entraînement, **82 icons**, a11y #1 | **session 3**, preload, outbox |
| **4** | 9–10 | digits, full validation, proof-read, **decodability report** | **Bilan + 6 checkpoints + placement test** | celebrations, strings sweep, a11y #2 | **session 4**, unlock rules, resume |
| **4b** | **11–12** | master lexicon complete; **themes tagged** | **comprehension system** + Batonga export | **facilitator mode**, spoken help | **review scheduler**, telemetry, perf re-measure |
| **5** | 13 | ← feature freeze · converge on `develop` → | | | |
| **6** | 14–15 | content QA | test suites | device matrix | perf & migrations |
| — | | **Field test with 5–10 real learners through Batonga** — two half-days, observed, no developer helping | | | |
| **7** | 16 | ← release → | | | |

**Zero blocking dependencies in weeks 2–12.** Same property as Part One, now over twelve weeks instead of nine.

If the two weeks are not available, cut in this order: `review-scheduler` off by flag (keep the `MasteryRecord` writes) → facilitator mode to a post-1.0 point release → comprehension off by flag pending Batonga. **Do not cut the spoken interface or the exercise bank.** Without the first the app is unusable by its audience; without the second it is a PDF viewer.

## X.3 Additions to the Definition of Done

Append to §P.

**P.3 — content**

- [ ] `npm run gen:corpus` produces no diff (the committed corpus matches its generator)
- [ ] No `verifyAgainstSource` flag left unresolved for a lesson being merged
- [ ] `decodableFrom` computed for every new lexicon entry

**P.2 — UI**

- [ ] Every new string has `t`, `a` and `i` — or a `ctx` explaining the exception
- [ ] Every new icon is in `icon-lexicon.json` with a single documented meaning
- [ ] Long-press spoken help answers on every new control

**P.8 — exercises (new)**

- [ ] Generated items are reproducible from their seed, asserted in a test
- [ ] **No item, distractor or question uses a symbol outside its lesson's `distractorPool`**
- [ ] Every activity path reaches rung 4 of the repair ladder and moves on
- [ ] No score anywhere prevents a lesson unlock

**P.5 — audio**

- [ ] The clip's ID matches the grammar regex
- [ ] Consonant sounds verified blind by a third listener
- [ ] Fusion clips use the 500 ms metronome pause

## X.4 Two new risks

| ID | Risk | L | I | Mitigation | Owner |
|---|---|---|---|---|---|
| **R-16** | **Comprehension questions blocked on Batonga.** MVP now contains content only the Foundation can author. If sign-off does not arrive, a shipped feature is empty. | **High** | Medium | The 28-text export is delivered in **week 9**, not week 14. `features.comprehension` ships **off**; the app is complete without it and the questions arrive by EAS Update. Never let this block a release date. | B |
| **R-17** | **Spaced-review intervals are unvalidated.** They are conservative defaults, not evidence about this cohort. Wrong intervals bore or overwhelm. | Medium | Medium | Intervals live in JSON, not code. The field test is instrumented for it. `features.spacedReview` can be switched off entirely. Recalibrate before scaling beyond the pilot cohort. | D |

Two risks from Part One also change weight. **R-03 (audio slips)** grows — 1 550 clips rather than 1 200 — and its mitigation is stronger: five sessions instead of two, the contingency in §W.6, and `has()` hiding what is not yet recorded. **R-13 (content volume exhausts the team)** shrinks: generation replaces roughly 1 675 hand-written exercise items and the entire recording script with code that runs in seconds.

## X.5 What to add to Sprint 1

The packs mostly land later, but four Sprint-1 items decide whether they land cleanly.

| Who | Add to the first two weeks | Why now |
|---|---|---|
| **A** | Commit the corpus generator and its eight output files on **day 2** | B's generators and D's script both read them. It is the cheapest unblock in the project. |
| **B** | Write the property test *"no generated item uses an out-of-ledger symbol"* **before** the first generator | Written first, it is a specification. Written later, it is a cleanup task nobody does. |
| **C** | Commit `ui-strings.fr.json` in **week 1**, even with unrecorded clips | It is D's input for recording session 2 in week 5, and it kills French literals before they spread across four branches. |
| **D** | Agree the ID grammar regex on **day 1** and put it in CI | This is *the* seam. Agreed on day 1 it costs an hour; agreed in week 6 it costs a rename across every content file. |

## X.6 Using the JSON bundle

Everything in Part Two ships as data. The bundle mirrors the repository layout, so integration is a copy:

```bash
cp -r addon/01-corpus/*        content/corpus/
cp -r addon/02-exercices/*     content/exercices/
cp -r addon/03-interface/*     content/interface/
cp -r addon/04-audio-maitrise/* content/audio/script/
```

Then split `ui-strings.fr.json` into `src/i18n/fr/<namespace>.json` — one file per namespace, per §O.4 — and hand `recording-script.csv` to the studio.

Every file carries a `$comment` field stating what it is, what tag it holds, and the reasoning behind the choices inside it. **Read the comment before editing the file.** Several fields look like oversights and are not: the deliberately empty UI strings, Lesson 8's seven-branch tree above its eight-syllable strip, the six syllables flagged `verifyAgainstSource`, and Lesson 24's missing sentence block are all faithful to the printed page.

The four generator scripts are included. They are the authority; the JSON is their output. If the two disagree, the generator is right and someone hand-edited a file they should not have.

## X.7 Where this leaves the project

Part One made the case that the book is a decoding machine and that digitising it faithfully is the whole job. That is still true. Part Two does not add curriculum — Batonga's decisions in §S.1 explicitly closed the two places where a development team would have been tempted to invent one.

What it adds is the apparatus a printed page could leave implicit and software cannot: **the index of what the book teaches**, so the machine can reason about its own content; **the exercises**, because reading a page and being asked nothing is not learning on a phone; **the voice**, because the facilitator the book assumes is not in the room; and **the memory**, because the app has to know which syllable to bring back on Thursday.

The four-branch property survives intact. Four students, four directories, four owners, no shared files, and — in weeks 2 through 12 — nobody waiting on anybody.

> **The scope test still applies, unchanged.** *If a feature does not help a woman in Bohicon decode a syllable, it is not MVP.* Everything in Part Two was written to pass it.

---

# Appendix — Assumptions and Open Questions

## Assumptions I have made (correct me if wrong)

| # | Assumption |
|---|---|
| 1 | The app reproduces **this book only**, in French. Not a general literacy platform. |
| 2 | The team can obtain permission from the Batonga Foundation (R-01). |
| 3 | Learners have personal or shared Android phones; Android is the primary platform, iOS secondary. |
| 4 | A facilitator is often present, as the book assumes — but the app must work without one. |
| 5 | Four developers, ~15–20 h/week each, ~16 weeks (revised from 14 by Part Two). Scale linearly if that is wrong. |
| 6 | The team is more comfortable in JavaScript/TypeScript than Dart or Kotlin. If not, invert the stack decision; everything else in this plan still applies. |
| 7 | A native French speaker can proof-read all content (essential — the accents matter). |
| 8 | A Beninese French speaker can be recorded, ideally a woman, for register and pronunciation the learners recognise. |
| 9 | **[Part Two]** Batonga, or a literacy specialist they nominate, can write 2–3 comprehension questions for each of the 28 texts within the project's timeframe. If not, `features.comprehension` ships off and the app is complete without it (R-16). |
| 10 | **[Part Two]** The spoken interface uses **tutoiement**. This is a cultural judgement, not a stylistic one, and Batonga should confirm it before the interface strings are recorded in week 5 (§V.7). |
| 11 | **[Part Two]** A second voice is available for the four dialogue texts (Lessons 30, 35, 38, 42). |

## Questions the PDF cannot answer — ask Batonga

**Answered (Part Two, §S.1):**

| # | Question | Decision |
|---|---|---|
| ~~3~~ | The letters q, w and x | **Not a defect.** `q` never stands alone in French; it is taught at Lesson 46 inside `qu`. `w` and `x` are reference-only. No invented lessons. |
| ~~6~~ | Numeracy beyond digit recognition | **Digits 0–9 only, permanently.** No counting, no arithmetic, no quantity. |
| ~~7~~ | The digital-inclusion content (SMS, order books) | **Not planned.** Removed from the roadmap. |
| ~~—~~ | May the lesson sequence be adjusted? | **No.** The order is specific to this cohort and is not to be touched. |

**Still open:**

1. **Pacing.** How long is a session in the Batonga programme? One lesson per meeting? Per week? This determines lesson length, and I have sized lessons at 10–15 minutes as a guess.
2. **Is there a facilitator guide?** The book presumes one but does not include one. If it exists, it contains the objectives, the pacing, and the error-correction guidance this plan had to infer — and it would sharpen §V.8 considerably.
4. **The Lesson 23/24 print order** — confirm 23 = z and 24 = h.
5. **The errata** (§B.3, `errata.json`). Ship the typos verbatim, or corrected? My recommendation is verbatim by default, but this is Batonga's call, not ours.
8. **Comprehension questions** for the 28 texts — will Batonga write them, or approve ours? The export is ready in week 9 either way (§U.6).
9. **Source assets.** Do the original illustrations and layout files exist? This would save weeks (R-13).
10. **Are the reading texts original to Batonga**, or drawn from an existing Beninese primer? Relevant to rights (R-01).
11. **[Part Two] Tutoiement or vouvoiement** in the spoken interface? Needed before recording session 2 (week 5).
12. **[Part Two] The six irregular syllables.** Do the printed trees for `c` (Lesson 20) and `s` (Lesson 19) restrict their branches the way Lesson 21's `g` tree does? Dev A must check pages 42–47 against `syllabary.json`'s `verifyAgainstSource` flags before those lessons are written.
13. **[Part Two] The decodability exceptions report** (§T.9). Running `decodableFrom` across all 56 word lists will produce a short list of places the printed book uses a letter before teaching it. Batonga should decide, once, whether those are intentional or worth correcting in a third edition — this is the clearest thing this project can give back to the Foundation.

---

*Plan prepared from the full 104-page source. Part One digitises the book: every content claim is traceable to a specific page, every recommendation not in the book is tagged **[ADAPT]** or **[NEW]**, and every gap is tagged **[GAP]** rather than filled with invention. Part Two builds the product around it: everything generated from the book by a stated rule is tagged **[DERIVED]** and ships with the generator that made it, and everything genuinely new is tagged **[NEW]** and named as requiring Batonga's approval.*
