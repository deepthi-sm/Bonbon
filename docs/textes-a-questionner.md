# Textes à questionner

> Généré depuis le contenu de l'application (`bonbon_app/lib/activities/comprehension.dart`).
> Ne pas modifier à la main : `BONBON_EXPORT=1 flutter test test/comprehension_test.dart` le régénère.

26 textes. Pour chacun, écrire 2 ou 3 questions dans `docs/comprehension/questions.json`,
dans la forme donnée en bas de chaque texte. Rien n'est publié sans une signature nommée
(`status: "approved"`, `signedOffBy`) — voir `docs/comprehension-signoff.md`.

## Les règles

- Au plus 3 questions par texte. La première est **littérale** ; une seule **lexicale** ;
  au plus une **inférentielle** (à partir de la leçon 36) et une **personnelle** (jamais notée, `replay-only`).
- Réponses : `image-2` (deux dessins), `image-3` (trois dessins, dès la leçon 30),
  `phrase-pick` (trois phrases COURTES du même texte, dès la leçon 36), `replay-only` (question personnelle).
- La question ne contient aucune graphie que la leçon n'a pas encore enseignée : le validateur le vérifie.
- Chaque question est dite à voix haute (`audioId` = `q.<id>`), et une mauvaise réponse rejoue la phrase
  du texte qui contient la réponse (`onWrong.replaySegment`).
- Pas de question sur la morale, l'intention de l'auteur ou le titre.

## T25 — leçon 25 · Les vacances

Réponses possibles : `image-2`, `replay-only`. Pas de question inférentielle avant la leçon 36.

- `T25.s01` Je passe souvent les vacances avec ma tante Baké à Kandi. Elle habite une grande maison située à l’entrée de la ville en venant de Cotonou.
- `T25.s02` Ma tante a un restaurant où elle vend des différents mets. De temps en temps, je l’aide à servir les clients, je lave aussi les assiettes sales utilisées par les clients. J’aime beaucoup ce travail et je m’empresse pour satisfaire les demandes des clients.
- `T25.s03` C’est toujours une joie pour moi quand je pars en vacances.

```json
{ "textId": "T25", "lessonId": "L25", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T25.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T25.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T25.s01" } },
    { "id": "T25.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T25.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T25.s01" } }
  ] }
```

## T26 — leçon 26 · La fête

Réponses possibles : `image-2`, `replay-only`. Pas de question inférentielle avant la leçon 36.

- `T26.s01` Aujourd’hui, c’est la fête de ramadan.
- `T26.s02` Tout le monde s’est réveillé tôt le matin pour aller à la prière. J’ai porté un beau pantalon et un long boubou. Mon oncle et ses enfants ont porté aussi de beaux vêtements. Nous avons prié à la place “Idi” en compagnie des musulmans venus de tout le quartier. À la fin de la prière chaque famille retoune à la maison pour continuer la fête.

```json
{ "textId": "T26", "lessonId": "L26", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T26.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T26.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T26.s01" } },
    { "id": "T26.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T26.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T26.s01" } }
  ] }
```

## T27 — leçon 27 · Le marché

Réponses possibles : `image-2`, `replay-only`. Pas de question inférentielle avant la leçon 36.

- `T27.s01` Le marché de Nikki n’est pas loin de la maison de ma tante. Je m’y rends souvent pour acheter les condiments dont nous avons besoin pour faire la cuisine. Un jour, en allant au marché, j’ai vu de loin un enfant qui jouait au balafon dans un coin de la rue. Au marché chaque vendeuse prend soin de son étalage pour attirer les clients. À mon retour, je fais le point pour m’assurer de n’avoir rien oublié.

```json
{ "textId": "T27", "lessonId": "L27", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T27.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T27.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T27.s01" } },
    { "id": "T27.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T27.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T27.s01" } }
  ] }
```

## T28 — leçon 28 · La ferme

Réponses possibles : `image-2`, `replay-only`. Pas de question inférentielle avant la leçon 36.

- `T28.s01` La ferme de mon oncle est très loin de la ville. Elle est dans un village où la population est jeune. Sur sa ferme, mon oncle a des plantations d’ignames et élève aussi des animaux. Le gardien de la ferme est un jeune qui a suivi une formation d’agent de sécurité. Mon oncle a un ancien fusil pour éloigner les animaux sauvages qui tentent de dévorer les bêtes de la ferme.

```json
{ "textId": "T28", "lessonId": "L28", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T28.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T28.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T28.s01" } },
    { "id": "T28.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T28.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T28.s01" } }
  ] }
```

## T29 — leçon 29 · Mon village

Réponses possibles : `image-2`, `replay-only`. Pas de question inférentielle avant la leçon 36.

- `T29.s01` Mon beau village est entouré de collines et d’arbres. Un beau lieu de repos est situé à côté d’une forêt non loin d’un marigot. Très tôt le matin, des jeunes filles et femmes viennent au marigot pour puiser de l’eau et ramasser du bois. Elles font des petits fagots qu’ elles portent sur la tête.

```json
{ "textId": "T29", "lessonId": "L29", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T29.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T29.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T29.s01" } },
    { "id": "T29.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T29.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T29.s01" } }
  ] }
```

## T30 — leçon 30 · Des amis

Réponses possibles : `image-2`, `image-3`, `replay-only`. Pas de question inférentielle avant la leçon 36.

- `T30.s01` Antoine voit son ami Benoît.
- `T30.s02` Bonsoir Benoît, où vas tu de ce pas ?
- `T30.s03` Je vais acheter des noix de coco dans la maison sans toit que tu vois là-bas.
- `T30.s04` Laisse-moi donc t’accompagner.

```json
{ "textId": "T30", "lessonId": "L30", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T30.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T30.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T30.s01" } },
    { "id": "T30.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T30.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T30.s01" } }
  ] }
```

## T31 — leçon 31 · Mon papa

Réponses possibles : `image-2`, `image-3`, `replay-only`. Pas de question inférentielle avant la leçon 36.

- `T31.s01` Mon papa est médecin. Chaque matin il part à la clinique soigner des malades. Sur la route Il achète du pain chez Samira la commerçante de notre quartier. Papa a aussi des poussins à la maison.

```json
{ "textId": "T31", "lessonId": "L31", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T31.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T31.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T31.s01" } },
    { "id": "T31.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T31.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T31.s01" } }
  ] }
```

## T32 — leçon 32 · La bouillie

Réponses possibles : `image-2`, `image-3`, `replay-only`. Pas de question inférentielle avant la leçon 36.

- `T32.s01` Aujourd’hui, il y a du brouillard, et il fait froid. Dossou boit de la bouillie bien chaude. Sur la toiture rouillée de sa chambre se trouve un margouillat qui regarde les mouches qui volent autour du bol de bouillie que Dossou a déposé sur la table.

```json
{ "textId": "T32", "lessonId": "L32", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T32.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T32.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T32.s01" } },
    { "id": "T32.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T32.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T32.s01" } }
  ] }
```

## T33 — leçon 33 · Chaque Samedi

Réponses possibles : `image-2`, `image-3`, `replay-only`. Pas de question inférentielle avant la leçon 36.

- `T33.s01` Le matin, à mon réveil je me débarbouille à la douche avant de balayer ma chambre, et essuyer mes meubles ensuite je nettoie les rayons de mon nouveau vélo. Après le nettoyage je fais mes exercices d’école.

```json
{ "textId": "T33", "lessonId": "L33", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T33.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T33.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T33.s01" } },
    { "id": "T33.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T33.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T33.s01" } }
  ] }
```

## T35 — leçon 35 · Au réveil

Réponses possibles : `image-2`, `image-3`, `replay-only`. Pas de question inférentielle avant la leçon 36.

- `T35.s01` Le réveil de Samira sonne. Le soleil s’est levé Samira n’a plus sommeil mais elle est toujours dans son lit. Elle est en éveil.
- `T35.s02` Réveille - toi Samira ! Tu dois aller à l’école !
- `T35.s03` Je suis en éveil maman ! Seulement, j’ai mal à l’oreille.

```json
{ "textId": "T35", "lessonId": "L35", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T35.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T35.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T35.s01" } },
    { "id": "T35.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T35.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T35.s01" } }
  ] }
```

## T36 — leçon 36 · En classe

Réponses possibles : `image-2`, `image-3`, `phrase-pick`, `replay-only`. Question inférentielle possible.

- `T36.s01` Baké prend son sac, son balai et un peigne pour aller à l’école. L’instituteur utilise de la craie rouge au tableau. Parfait le voisin de Baké aime utiliser le bâton de craie jaune comme relais quand il n’a plus de craie blanche. Baké et son voisin aiment le bon lait de vache vendu par les vendeuses toute la semaine.

```json
{ "textId": "T36", "lessonId": "L36", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T36.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T36.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T36.s01" } },
    { "id": "T36.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T36.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T36.s01" } }
  ] }
```

## T37 — leçon 37 · À l’école

Réponses possibles : `image-2`, `image-3`, `phrase-pick`, `replay-only`. Question inférentielle possible.

- `T37.s01` Chaque élève a apporté son balai. Les enfants sont contents de rendre l’école propre. Les tout petits ramassent les papiers et vont les jeter au pied d’un cocotier. Il y a beaucoup de poussière. Monsieur Orou, le directeur, arrive et dit, en se pinçant le nez :
- `T37.s02` Attention, balayez doucement.

```json
{ "textId": "T37", "lessonId": "L37", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T37.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T37.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T37.s01" } },
    { "id": "T37.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T37.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T37.s01" } }
  ] }
```

## T38 — leçon 38 · Un visiteur

Réponses possibles : `image-2`, `image-3`, `phrase-pick`, `replay-only`. Question inférentielle possible.

- `T38.s01` Papa est dans un fauteuil sous le feuillage du grand manguier au milieu de la maison. Béré, va voir qui frappe à la porte, me dit papa. Sur le seuil de la maison, je salue le visiteur.
- `T38.s02` Veuillez bien remettre ces feuilles à ton père.
- `T38.s03` Avec ces feuilles, on prépare une bonne tisane. Ce sont des feuilles médicinales qui servent à se soigner.
- `T38.s04` Merci monsieur.

```json
{ "textId": "T38", "lessonId": "L38", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T38.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T38.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T38.s01" } },
    { "id": "T38.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T38.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T38.s01" } }
  ] }
```

## T39 — leçon 39 · Une pluie surprise

Réponses possibles : `image-2`, `image-3`, `phrase-pick`, `replay-only`. Question inférentielle possible.

- `T39.s01` Alors que le soleil brille encore dans le ciel, la pluie arrive brusquement et surprend les filles au marché. De grosses gouttes d’eau tombent sur les feuillages des arbres. Les papillons s’envolent dans le ciel. Nos vêtements sont mouillés. La famille de Sidi court se mettre à l’abri.

```json
{ "textId": "T39", "lessonId": "L39", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T39.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T39.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T39.s01" } },
    { "id": "T39.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T39.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T39.s01" } }
  ] }
```

## T41 — leçon 41 · Les deux sœurs

Réponses possibles : `image-2`, `image-3`, `phrase-pick`, `replay-only`. Question inférentielle possible.

- `T41.s01` C’est le soir. Les deux sœurs Flore et Rose jouent au jeu de cache - cache dans la haie de fleurs. Flore voulant se cacher, voit un bâton ayant la forme d’un serpent. Apeurée, elle crie très fort. Sa maman entend son cri de peur. Elle surgit de la demeure. Le cœur de Flore bat sans arrêt. Sa sœur Rose la serre dans ses bras. Maman la console et lui promet du pain avec du beurre.

```json
{ "textId": "T41", "lessonId": "L41", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T41.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T41.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T41.s01" } },
    { "id": "T41.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T41.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T41.s01" } }
  ] }
```

## T42 — leçon 42 · Une histoire

Réponses possibles : `image-2`, `image-3`, `phrase-pick`, `replay-only`. Question inférentielle possible.

- `T42.s01` Le Samedi soir, Victoire va voir sa mère.
- `T42.s02` Bonsoir maman, je veux m’asseoir sur vos genoux pour écouter une belle histoire. Êtes-vous d’accord maman ?
- `T42.s03` Oui mais donne-moi à boire d’abord. Ensuite, allume-moi la lampe à pétrole car il fait déjà noir.
- `T42.s04` Victoire fait tout ce que sa mère lui demande parce qu’elle veut écouter sa belle histoire.

```json
{ "textId": "T42", "lessonId": "L42", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T42.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T42.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T42.s01" } },
    { "id": "T42.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T42.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T42.s01" } }
  ] }
```

## T43 — leçon 43 · Le forgeron

Réponses possibles : `image-2`, `image-3`, `phrase-pick`, `replay-only`. Question inférentielle possible.

- `T43.s01` Au village, on entend le forgeron qui tape sur son enclume. Le bruit se fait entendre dans le garage du père de Gildas. Le forgeron Gédéon fabrique dans sa forge des instruments pour les vendre aux étrangers en voyage pendant leur passage dans notre village.

```json
{ "textId": "T43", "lessonId": "L43", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T43.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T43.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T43.s01" } },
    { "id": "T43.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T43.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T43.s01" } }
  ] }
```

## T44 — leçon 44 · Les mangues

Réponses possibles : `image-2`, `image-3`, `phrase-pick`, `replay-only`. Question inférentielle possible.

- `T44.s01` Auguste est allé marauder. Il ramène beaucoup de mangues qu’il distribue à Hugues, Rodrigue, Agathe et Marguerite. Les mangues sont si juteuses que Hugues se blesse la langue en les mangeant. Les mangues ont si bon goût que Marguerite les déguste avec plaisir.

```json
{ "textId": "T44", "lessonId": "L44", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T44.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T44.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T44.s01" } },
    { "id": "T44.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T44.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T44.s01" } }
  ] }
```

## T45 — leçon 45 · Un bon repas

Réponses possibles : `image-2`, `image-3`, `phrase-pick`, `replay-only`. Question inférentielle possible.

- `T45.s01` Ignace, l’ami de Bio est allé en vacances à Gamia, un village du Nord-Bénin. Sous un arbre où des araignées avaient tissé leur toile, un repas fait d’ignames pilées, d’une sauce d’oignons accompagnée de viandes séchées, est offert au jeune Ignace qui a mangé avec appétit. Avec quelques poignées, le repas est terminé.

```json
{ "textId": "T45", "lessonId": "L45", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T45.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T45.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T45.s01" } },
    { "id": "T45.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T45.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T45.s01" } }
  ] }
```

## T47 — leçon 47 · Le magasin

Réponses possibles : `image-2`, `image-3`, `phrase-pick`, `replay-only`. Question inférentielle possible.

- `T47.s01` Le plus grand magasin de notre ville a été créé par Maryse. Il se trouve à l’entrée de la ville, très loin de notre maison. On y trouve beaucoup de choses comme des chaises, des vases, des petites cases en bois, des blouses blanches, et beaucoup d’autres objets. Chaque fois que je le visite, il y a toujours des surprises.

```json
{ "textId": "T47", "lessonId": "L47", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T47.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T47.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T47.s01" } },
    { "id": "T47.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T47.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T47.s01" } }
  ] }
```

## T50 — leçon 50 · Le domaine

Réponses possibles : `image-2`, `image-3`, `phrase-pick`, `replay-only`. Question inférentielle possible.

- `T50.s01` À kérou, nous avons un voisin qui a un domaine avec beaucoup d’animaux. Chaque fois que je monte sur une chaise pour les regarder je vois des vaches, des chevaux, des chiens et des chats. Quand je saute de ma chaise pour descendre je fais tomber mon chapeau.

```json
{ "textId": "T50", "lessonId": "L50", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T50.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T50.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T50.s01" } },
    { "id": "T50.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T50.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T50.s01" } }
  ] }
```

## T51 — leçon 51 · Le photographe

Réponses possibles : `image-2`, `image-3`, `phrase-pick`, `replay-only`. Question inférentielle possible.

- `T51.s01` L’oncle Mathieu a une belle voiture avec des phares ronds. Il vient d’appeler sa nièce au téléphone. Ensemble ils iront acheter du pain et un médicament à la pharmacie. Au retour ils iront prendre une photo chez Moustapha l’un des photographes du village

```json
{ "textId": "T51", "lessonId": "L51", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T51.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T51.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T51.s01" } },
    { "id": "T51.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T51.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T51.s01" } }
  ] }
```

## T52 — leçon 52 · Les vacances

Réponses possibles : `image-2`, `image-3`, `phrase-pick`, `replay-only`. Question inférentielle possible.

- `T52.s01` Pendant les vacances papa nous accompagne avec sa charette en campagne faire du pique-nique et aussi des parties de chasse. Chacun de nous profite pour se reposer loin de la chaleur de la ville et des accidents. Sur le chemin de retour nous chantons tout en traversant les grands champs étendus à perte de vue.

```json
{ "textId": "T52", "lessonId": "L52", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T52.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T52.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T52.s01" } },
    { "id": "T52.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T52.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T52.s01" } }
  ] }
```

## T53 — leçon 53 · Les opérations

Réponses possibles : `image-2`, `image-3`, `phrase-pick`, `replay-only`. Question inférentielle possible.

- `T53.s01` À l’école nous apprenons à faire des calculs d’addition, de soustraction, de multiplication et de division. Pendant la récréation, le directeur de l’école va à la banque faire des opérations, il fait attention aux voitures et aux motos en traversant la route.

```json
{ "textId": "T53", "lessonId": "L53", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T53.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T53.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T53.s01" } },
    { "id": "T53.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T53.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T53.s01" } }
  ] }
```

## T55 — leçon 55 · Les préparatifs

Réponses possibles : `image-2`, `image-3`, `phrase-pick`, `replay-only`. Question inférentielle possible.

- `T55.s01` Avant la nouvelle année, maman dégage toutes les ordures de la maison. Mon frère est chargé d’orner le salon et le rendre beau. Papa aussi ne se repose pas, il arrache les mauvaises herbes autour de la maison. Pour aller retirer de l’argent à la banque, papa prend l’autocar.

```json
{ "textId": "T55", "lessonId": "L55", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T55.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T55.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T55.s01" } },
    { "id": "T55.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T55.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T55.s01" } }
  ] }
```

## T56 — leçon 56 · L’hôpital

Réponses possibles : `image-2`, `image-3`, `phrase-pick`, `replay-only`. Question inférentielle possible.

- `T56.s01` L’hôpital du village est près du grand fromager. Un autre grand arbre donne de l’ombre dans la cour. Notre hôpital compte un grand bâtiment administratif près du grand portail, trois salles de soins sont construites et trois autres attendent d’être en matériaux définitifs, une décision prise par le directeur du personnel soignant après la réunion du dernier vendredi du mois passé. Mes amis Brigitte, Crépin, Grégoire et moi préparons un test pour y travailler.

```json
{ "textId": "T56", "lessonId": "L56", "status": "draft", "signedOffBy": null,
  "questions": [
    { "id": "T56.q1", "kind": "littérale", "mode": "image-2", "prompt": "", "audioId": "q.T56.q1",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T56.s01" } },
    { "id": "T56.q2", "kind": "lexicale", "mode": "image-2", "prompt": "", "audioId": "q.T56.q2",
      "options": [{ "illustrationId": "", "correct": true }, { "illustrationId": "", "correct": false }],
      "onWrong": { "replaySegment": "T56.s01" } }
  ] }
```

