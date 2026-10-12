# Data Model — Batonga *Lire*

**Owner:** Dev D (`dev/data-audio`) · **Status:** Sprint 1 design draft — schema not yet written
**Governs:** `src/core/db/**`, `src/core/progress/**`, `src/core/sync/**`, `src/core/telemetry/**`
**Plan references:** BUILD_PLAN_v2 §C.4, §G, §H.3, §H.5, §O.4, §P.4, §W.7–W.10.

This is the §G.2 schema worked out to the level D1 can be written from mechanically. It exists
because D1 is blocked on the Expo scaffold and the design is not — everything below can be
argued and corrected now, so that when `package.json` lands the migration is transcription
rather than invention.

> **⚠ Sections marked PROVISIONAL depend on `src/core/contracts/**`, which is not written or
> frozen. Every one of them is flagged in §9 as needing reconciliation at the Sprint-0 contracts
> session. Nothing here is a decision I have taken on the team's behalf.**

---

## 1. The three tiers

| Tier | Store | Mutable at runtime | Owner |
|---|---|---|---|
| Static educational content | Bundled JSON, read-only | No | **A** (audio manifest: D) |
| **Learner data** | **SQLite on device** | **Yes** | **D — this document** |
| App configuration | SQLite `app_settings` + build constants | Settings yes | C (values) / D (storage) |

**SQLite is the only writeable store.** Every user action writes locally and returns
immediately; nothing in the UI ever waits on a network call (§C.4). There is no remote database
in MVP, and `sync_outbox` is written but never drained.

---

## 2. Conventions

| | |
|---|---|
| Engine | `expo-sqlite` + Drizzle ORM |
| Timestamps | `INTEGER` — Unix epoch **milliseconds**, UTC. Never TEXT: TEXT dates don't index or compare cheaply, and this is a phone. |
| Dates (day granularity) | `TEXT` `YYYY-MM-DD` in **device-local** time — see §5.3 |
| Booleans | `INTEGER` 0/1. SQLite has no boolean. |
| IDs | `TEXT`. Learner is a device-generated UUIDv4. Domain IDs (`L08`, `letter.t.sound`) are the content IDs verbatim. |
| Scores / strength | `REAL` in `[0,1]` |
| JSON columns | `TEXT`, application-parsed. Used only where the shape is genuinely open (`stroke_scores`, outbox `payload`, telemetry `props`). |
| Foreign keys | Declared, `PRAGMA foreign_keys = ON` at open |
| Naming | `snake_case` tables and columns; Drizzle maps to camelCase in TS |

**No SQL outside `src/core/db/`.** §E.5: no branch other than `dev/data-audio` may write SQL or
add a migration. Consumers reach data through `progressService` and the repositories, never
through a query.

---

## 3. Tables

### 3.1 `learner`

```sql
CREATE TABLE learner (
  id                TEXT PRIMARY KEY,          -- UUIDv4, device-generated
  display_name      TEXT NOT NULL,
  avatar_id         TEXT,
  preferred_script  TEXT NOT NULL DEFAULT 'print',   -- 'print' | 'cursive'
  voice_rate        TEXT NOT NULL DEFAULT 'normal',  -- 'normal' | 'slow'
  resume_code       TEXT,                      -- 6 digits, V2 — null in MVP
  created_at        INTEGER NOT NULL
);
```

**No email. No password. No phone number** (§C.6). A low-literacy learner cannot type an email
address, and asking her to is a dignity failure, not just a UX one.

MVP has exactly one row. The table is keyed anyway because V2 facilitator mode puts several
learners on a shared phone, and retrofitting a `learner_id` onto six tables later is the
expensive version of this decision.

`display_name` is the app's **only** piece of personal data. See §7.2.

### 3.2 `lesson_state`

```sql
CREATE TABLE lesson_state (
  learner_id        TEXT NOT NULL REFERENCES learner(id),
  lesson_id         TEXT NOT NULL,             -- 'L01'…'L56', 'D0'…'D9'
  status            TEXT NOT NULL,             -- locked|available|in_progress|completed
  last_block_index  INTEGER NOT NULL DEFAULT 0,
  blocks_seen       TEXT NOT NULL DEFAULT '[]',-- JSON int[] — see below
  block_count       INTEGER,                   -- PROVISIONAL — see §9.4
  bilan_attempted   INTEGER NOT NULL DEFAULT 0,
  started_at        INTEGER,
  completed_at      INTEGER,
  completion_count  INTEGER NOT NULL DEFAULT 0,
  best_score        REAL,
  PRIMARY KEY (learner_id, lesson_id)
);
```

**`blocks_seen` and `bilan_attempted` are additions to §G.2**, and they are not optional.
§W.8 defines completion as *every block seen and the Bilan attempted, whatever the score*.
`last_block_index` alone cannot express that: a learner who jumps back to block 2 and quits has
`last_block_index = 2` but has seen blocks 0–9. Storing the set is the only honest
implementation of the rule.

`status` is **derived, not authoritative** — recomputed from `blocks_seen`, `bilan_attempted`
and the previous lesson's state. It is stored so the Parcours query is one read instead of a
graph walk, and it is rebuilt on migration.

### 3.3 `activity_attempt`

```sql
CREATE TABLE activity_attempt (
  id             TEXT PRIMARY KEY,
  learner_id     TEXT NOT NULL REFERENCES learner(id),
  lesson_id      TEXT NOT NULL,
  activity_id    TEXT NOT NULL,          -- 'L08.a1'
  activity_type  TEXT NOT NULL,
  attempt_number INTEGER NOT NULL,       -- PROVISIONAL — see §9.1
  outcome        TEXT NOT NULL,          -- correct|incorrect|partial|skipped
  is_correct     INTEGER NOT NULL,
  score          REAL NOT NULL,
  duration_ms    INTEGER NOT NULL,
  hints_used     REAL NOT NULL,          -- PROVISIONAL — count or cost? §9.2
  difficulty_tier INTEGER,               -- PROVISIONAL — no channel exists. §9.3
  created_at     INTEGER NOT NULL,
  UNIQUE (learner_id, activity_id, attempt_number)
);
CREATE INDEX ix_attempt_lesson ON activity_attempt (learner_id, lesson_id);
```

The `UNIQUE` constraint **is** the idempotency guarantee §H.3 demands. `INSERT … ON CONFLICT DO
NOTHING`, then skip the mastery update on conflict — a re-delivered result must not move
strength twice.

### 3.4 `attempt_target` — **addition to §G.2**

```sql
CREATE TABLE attempt_target (
  attempt_id   TEXT NOT NULL REFERENCES activity_attempt(id) ON DELETE CASCADE,
  target_type  TEXT NOT NULL,           -- letter|syllable|word|grapheme|digit
  target_id    TEXT NOT NULL,
  correct      INTEGER NOT NULL,
  PRIMARY KEY (attempt_id, target_type, target_id)
);
```

§G.2 stores attempts at activity level only, but mastery is computed from
`ActivityResult.targets` — so as written, **the evidence is consumed and thrown away**.

That is a bad trade for two reasons. Mastery will have a bug (the formula has three open
questions in §9 alone), and without the target-level rows there is no way to recompute
strength from history — only to reset it, which destroys real learner progress. And §W.9 says
the review intervals *must be recalibrated from real `MasteryRecord` data after the field test*
(R-17); that recalibration needs the evidence, not just the current strength.

Cost: roughly 2–4 rows per attempt, a few thousand over a learner's whole path. Nothing.

### 3.5 `trace_attempt`

```sql
CREATE TABLE trace_attempt (
  id            TEXT PRIMARY KEY,
  learner_id    TEXT NOT NULL REFERENCES learner(id),
  glyph_id      TEXT NOT NULL,
  score         REAL NOT NULL,
  stroke_scores TEXT NOT NULL,          -- JSON number[]
  stroke_count  INTEGER NOT NULL,
  duration_ms   INTEGER NOT NULL,
  created_at    INTEGER NOT NULL
);
CREATE INDEX ix_trace_glyph ON trace_attempt (learner_id, glyph_id, created_at);
```

Separate from `activity_attempt` because its metrics differ in kind, and because handwriting
progress deserves its own view. A trace also emits an `ActivityResult`, so it appears in both
tables — that is intended, not duplication: one row is the activity, the other is the
handwriting.

### 3.6 `mastery_record`

```sql
CREATE TABLE mastery_record (
  learner_id       TEXT NOT NULL REFERENCES learner(id),
  target_type      TEXT NOT NULL,
  target_id        TEXT NOT NULL,
  strength         REAL NOT NULL DEFAULT 0,
  strength_peak    REAL NOT NULL DEFAULT 0,   -- addition — see below
  exposures        INTEGER NOT NULL DEFAULT 0,
  correct_count    INTEGER NOT NULL DEFAULT 0,
  distinct_days    INTEGER NOT NULL DEFAULT 0,-- addition — see below
  first_seen_at    INTEGER,
  last_seen_at     INTEGER,
  last_seen_day    TEXT,                      -- 'YYYY-MM-DD' local
  next_review_at   INTEGER,
  introduced_at    INTEGER,                   -- addition — see below
  PRIMARY KEY (learner_id, target_type, target_id)
);
CREATE INDEX ix_mastery_review ON mastery_record (learner_id, strength, next_review_at);
```

**Three additions, each forced by a rule §G.2's columns cannot express:**

| Column | The rule it serves | Why the §G.2 columns can't |
|---|---|---|
| `distinct_days` + `last_seen_day` | *acquise* = `s ≥ 0.75` with **≥3 exposures across 2 distinct days** (§W.7) | `exposures` counts events, `last_seen_at` is one instant. Neither counts days. Incremented only when `today ≠ last_seen_day`. |
| `strength_peak` | decay floor of 0.2 **once s has ever reached 0.6** (§W.7) | "has ever reached" is a high-water mark. Current `strength` has already decayed past it by the time the floor matters. |
| `introduced_at` | the queue never includes a target introduced **in the last 24 h** (§W.9) | `first_seen_at` is the first *attempt*; a target is introduced by a lesson block before it is ever attempted. |

Without the first two, the two rules simply cannot be implemented — they are not
optimisations.

### 3.7 `achievement` · `streak_log` · `session`

```sql
CREATE TABLE achievement (
  learner_id     TEXT NOT NULL REFERENCES learner(id),
  achievement_id TEXT NOT NULL,
  unlocked_at    INTEGER NOT NULL,
  seen           INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (learner_id, achievement_id)
);

CREATE TABLE streak_log (
  learner_id       TEXT NOT NULL REFERENCES learner(id),
  day              TEXT NOT NULL,            -- 'YYYY-MM-DD' local
  minutes_active   INTEGER NOT NULL DEFAULT 0,
  lessons_completed INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (learner_id, day)
);

CREATE TABLE learner_session (
  id              TEXT PRIMARY KEY,
  learner_id      TEXT NOT NULL REFERENCES learner(id),
  started_at      INTEGER NOT NULL,
  ended_at        INTEGER,
  lessons_touched INTEGER NOT NULL DEFAULT 0
);
```

`session` is renamed **`learner_session`** — `session` collides with too much (expo-sqlite
internals, any future auth library, and the word's everyday use in this codebase for a
*recording* session).

### 3.8 `sync_outbox`

```sql
CREATE TABLE sync_outbox (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  entity     TEXT NOT NULL,
  entity_id  TEXT NOT NULL,
  op         TEXT NOT NULL,             -- insert|update|delete
  payload    TEXT NOT NULL,             -- JSON
  created_at INTEGER NOT NULL,
  synced_at  INTEGER                    -- null until drained; nothing drains it in MVP
);
CREATE INDEX ix_outbox_pending ON sync_outbox (synced_at) WHERE synced_at IS NULL;
```

Written from day one, drained in V2. About thirty lines of investment that makes V2 sync a
feature instead of a rewrite (§C.4).

### 3.9 `event_log` — local-only telemetry

```sql
CREATE TABLE event_log (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  event      TEXT NOT NULL,
  props      TEXT NOT NULL DEFAULT '{}', -- JSON
  created_at INTEGER NOT NULL
);
CREATE INDEX ix_event_created ON event_log (created_at);

CREATE TRIGGER event_log_ring AFTER INSERT ON event_log
WHEN (SELECT COUNT(*) FROM event_log) > 5000
BEGIN
  DELETE FROM event_log WHERE id <= NEW.id - 5000;
END;
```

The ring buffer is a **trigger, not application code**, so it cannot be forgotten at a call
site. Capped at 5 000 rows (§W.10).

**No network identifiers, no location, no typed content.** Nothing here enters `sync_outbox`
(§7.1). Réglages → À propos clears the log; a long-press there shows a readable on-screen
summary for a field-test observer, who will not have a laptop.

The purpose is not analytics. It is being able to answer **« pourquoi s'est-elle arrêtée là ? »**
from the device, with the learner sitting there. The single most important row in it is
`activity.skip` — where she gives up.

### 3.10 `app_settings`

```sql
CREATE TABLE app_settings (
  id                   INTEGER PRIMARY KEY CHECK (id = 1),
  preferred_script     TEXT NOT NULL DEFAULT 'print',
  voice_rate           TEXT NOT NULL DEFAULT 'normal',
  text_scale           REAL NOT NULL DEFAULT 1.0,
  haptics_enabled      INTEGER NOT NULL DEFAULT 1,
  reminder_time        TEXT,
  content_pack_version TEXT,
  onboarding_completed INTEGER NOT NULL DEFAULT 0
);
```

`CHECK (id = 1)` enforces the single row in the schema rather than by convention. C owns the
values, D owns the storage (§G.3). Feature flags are **build-time constants**, not rows — a
flag in the database is a flag someone can leave in the wrong state on a test device.

---

## 4. Migrations

**One migration per file**, named `NNNN_<owner>_<slug>.sql` (§O.4). The owner initial is what
stops two developers both claiming `0007`. **A merged migration is never edited.**

**⚠ This collides with drizzle-kit**, which generates `0000_<random_words>.sql` and indexes
files in `meta/_journal.json` — renaming a file by hand breaks the journal silently.

Proposed resolution, to confirm when D1 is written: use drizzle-kit's `--name` flag
(`drizzle-kit generate --name=d_initial_schema` → `0000_d_initial_schema.sql`), accept
drizzle's 0-based numbering as the `NNNN`, and add a CI check that every migration filename
matches `^\d{4}_[abcd]_[a-z0-9_]+\.sql$`. If the flag does not behave as expected we hand-write
migrations and drop drizzle-kit's generator, keeping the ORM.

**§P.4 requires every migration to be tested forward from an empty DB *and* from the previous
released schema.** Both run in CI, against fixture databases committed under
`src/core/db/__fixtures__/`.

---

## 5. Derived state

### 5.1 Decay is computed at read, never written

Strength decays 2 % per day after three days without exposure (§W.7), but rows are only written
when an `ActivityResult` arrives. A nightly sweep would mean a background task, a wake-lock
argument, and a phone that is off for a week getting it wrong anyway.

So decay is a **pure function applied at read**:

```
effective(s, peak, lastSeenAt, now)
  days   = floor((now − lastSeenAt) / 86_400_000)
  if days ≤ 3 → s
  decayed = s × 0.98 ^ (days − 3)
  floor   = peak ≥ 0.6 ? 0.2 : 0
  → max(decayed, floor)
```

**Consequence worth writing down once so nobody debugs it twice:** the `strength` column is the
strength *as of `last_seen_at`*, not the strength the app displays. Every read path goes through
`effective()`. The stored value is only ever updated by an attempt.

### 5.2 Mastery update — PROVISIONAL

```
gain    = w_type × w_difficulty × (1 − s) × hintFactor
penalty = 0.15 × s          on an incorrect target, floored at 0
s'      = clamp(s + gain − penalty, 0, 1)
```

`w_type` from `mastery-model.json.evidenceWeights`, `w_difficulty` from `difficultyWeights`.
Weights live in JSON, never in code, so they can be retuned after the field test without a
release.

**`hintFactor` is the open question.** §W.7 writes `(1 − 0.5 × hintsUsed)`; its own prose says
"rung 3 halves the gain, rung 4 gives none"; `repair-ladder.json` defines `hintCost` as
0 / 0.25 / 0.5 / 1.0. Only `hintFactor = (1 − hintCost)` satisfies the prose. Taken literally
with `hintsUsed` as a count, two hints give zero gain and **three give negative gain** — a
correct answer that lowers strength. Whatever we settle on, `hintFactor` is clamped to `[0,1]`
at the boundary; a formula that can go negative is a bug waiting for a learner to find it.

### 5.3 Days are device-local

`streak_log.day`, `mastery_record.last_seen_day` and the *acquise* two-day rule use the
**device's local calendar day**, not UTC. Bohicon is UTC+1; a UTC day boundary would break a
streak at 1 a.m. for a learner who studied at midnight. Timestamps stay UTC epoch ms; only the
day strings are local. Travel across a timezone can produce a duplicate or missing day — this
is acceptable and is not worth a timezone library in a 60 MB budget.

### 5.4 Progression — `progression-rules.json`

- **Unlock:** lesson *n+1* opens the moment lesson *n* is finished — every block seen, Bilan
  attempted — **whatever the score. No exceptions.** The score feeds review; it never touches
  the lock. Gating on score punishes exactly the learner who most needs to keep going.
- "Attempted" includes "skipped". `allowSkip` is true everywhere.
- **Resume** is per block. After fourteen days away, a five-item review session is inserted
  *before* the resume point.
- **Exactly one node app-wide carries `isNext`:** the first `available` lesson in path order.
  Asserted in a unit test, because "exactly one" is the kind of invariant that quietly becomes
  two.
- **Property test (D16):** *no score anywhere can prevent an unlock.* Generated over random
  score/attempt histories.

C renders `PathState` and holds no progression logic (§H.5). None of the above appears in the
shell.

---

## 6. Repositories and the service boundary

```
src/core/db/
├── client.ts          open, PRAGMAs, migration runner
├── schema.ts          Drizzle table definitions
├── migrations/        NNNN_d_*.sql
├── repositories/      learnerRepo, lessonStateRepo, attemptRepo, masteryRepo,
│                      streakRepo, outboxRepo, eventRepo, settingsRepo
└── __fixtures__/      seeded DBs for migration tests
```

Repositories are **thin**: CRUD, typed, no business rules. Every rule — mastery, unlocking,
streaks, the review queue — lives in `src/core/progress/`. The split exists so the mastery
engine is a set of pure functions over plain data, unit-testable with no database at all
(§W.11 D15 requires exactly that).

`progressService` is the only thing A, B and C ever import.

### 6.1 Failure is swallowed, never thrown

§H.3 is explicit and §P.4 makes it a merge gate: `recordActivityResult` **never throws to the
caller**. A DB failure is logged to `event_log` and swallowed; the promise resolves regardless.

**A broken disk must not stop a lesson.** The learner is mid-way through Lesson 12 with a
facilitator beside her; a write failure that surfaces as a crash costs her the session, and
losing one attempt row costs her nothing she will notice.

This applies to every mutating method on `progressService`. Read methods may reject — a caller
that cannot get `PathState` has to render something, and that is C's decision to make.

---

## 7. `sync_outbox` rules

### 7.1 What is written — and the one exemption

Every mutation to `learner`, `lesson_state`, `activity_attempt`, `trace_attempt`,
`mastery_record`, `achievement` and `streak_log` appends an outbox row (§P.4).

**`event_log` does not**, and neither does `app_settings`.

This is a **direct contradiction inside the plan** and it must be resolved on the record, not
by whichever of the two I happened to read last: §P.4's Definition of Done says *every*
mutation appends to the outbox; §W.10 says « rien n'est transmis : le sync_outbox ne contient
PAS d'événements ». Telemetry writes are mutations.

I have implemented §W.10 and treated §P.4 as needing an explicit exemption clause, because the
alternative queues 5 000 rows of behavioural data per field-test device for a future drain to a
server — which is precisely what §W.10's privacy paragraph exists to prevent. **Ratify or
overrule this at the sync; do not leave it implicit.**

### 7.2 Personal data

`learner.display_name` is the only personal data in the app, and the `learner` outbox row is
the only place it would leave the device when V2 drains to Supabase. Two questions the team
should answer **now** rather than in V2, when a schema is already deployed:

1. Does the outbox payload carry `display_name` at all, or only the UUID?
2. If it does, is that disclosed anywhere a facilitator or learner could understand?

A name is not much. It is also a real person's name attached to a record of what she could not
read, and that deserves a decision rather than a default.

---

## 8. Performance

The §C.1 budgets I am accountable for that this schema touches:

| Budget | Target | What in here affects it |
|---|---|---|
| Cold start → interactive | ≤ 3.0 s | Migration check on open; `getPathState()` must be **one indexed query**, not 66 |
| Audio tap → first sound | ≤ 150 ms | Not schema, but the preloader competes with DB work on the same thread |
| Install size | ≤ 60 MB | Empty schema is negligible; the audio is the budget |

`getPathState()` is on the cold-start path and is the query to watch: it must read
`lesson_state` once, ordered, and let the service assemble the units in memory. A per-lesson
query is 66 round-trips and will show up on an Android Go device.

`event_log` writes are fire-and-forget on a queue, never awaited by a UI interaction.

---

## 9. PROVISIONAL — needs the Sprint-0 contracts session

Every item here is a placeholder I have had to invent because `src/core/contracts/**` does not
exist yet. **None is a decision I have taken on the team's behalf.** Each needs 2 approvals and
an ADR per §H.1.

| # | Item | The problem | What I have assumed |
|---|---|---|---|
| **9.1** | `attempt_number` | §H.3 requires idempotency on `activityId + attemptNumber`, but `ActivityResult` (§H.2) carries `attempts` — a count, not an index. There is no key. | Treated `attempts` as a 1-based index and made it the uniqueness key. **Wrong if B sends one result per activity rather than per attempt.** |
| **9.2** | `hints_used` | Count (§G.2, §H.2) or cost (`repair-ladder.json`)? The formula, the prose and the data file disagree three ways (§5.2). | Stored as `REAL` so either fits. `hintFactor` clamped to `[0,1]`. |
| **9.3** | `difficulty_tier` | `mastery-model.json` weights tier1/2/3, but the tier lives in B's `generators.json` and **no contract field carries it**. `w_difficulty` has no input. | Column exists, nullable, defaults to tier 2 (weight 1.0). Needs a field on `ActivityResult` or `MasteryTarget`. |
| **9.4** | `block_count` | Completion is "every block seen", so I need the lesson's block count — but §E.4 says I depend on `ActivityResult` and the ID types, "nothing else". | Cached on `lesson_state`, written by whoever calls `completeLesson`. Either I get a read dependency on `@core/content`, or A puts it in `LessonSummary`. **This decision defines `LessonSummary`.** |
| **9.5** | `outcome: skipped \| partial` | `MasteryTarget.correct` is a boolean. If B emits targets with `correct:false` on a skip, the 0.15 penalty fires on a learner who skipped — contradicting "there is no failure state". | Skipped results write the attempt row and **no** mastery update. Needs B's confirmation. |
| **9.6** | Rung 4's `strength = 0.15` | `repair-ladder.json` sets strength to 0.15 on give-and-go. As a hard set, an *acquise* target drops 0.80 → 0.15, contradicting the decay floor's whole rationale. | Implemented as **floor-if-lower**, never as a reduction. |
| **9.7** | `LessonSummary`, `ResumePoint`, `StreakState` | Named in my public signature (§E.4, §H.3, §H.5) and **defined nowhere in the plan**. | Drafted locally; must move into `contracts/progress.ts` and be frozen before D3. |

---

## 10. Open questions

| # | Question | Owner | Needed by |
|---|---|---|---|
| 1 | All seven items in §9 | contracts session, 2 approvals + ADR | before D3 |
| 2 | §P.4 vs §W.10 — is telemetry exempt from the outbox? (§7.1) | team | before D1 |
| 3 | Does the outbox carry `display_name`? (§7.2) | team | before D1 |
| 4 | Drizzle `--name` vs the §O.4 migration convention (§4) | Dev D, confirm at D1 | at D1 |
| 5 | Confirm `expo-sqlite` + `drizzle-orm` + `drizzle-kit` through the Build Steward | Build Steward | blocks D1 |

---

*Sources: BUILD_PLAN_v2 §G, §H, §O.4, §P.4, §W.7–W.10, and `content/audio/script/mastery-model.json`,
`progression-rules.json`, `review-scheduler.json`, `telemetry-catalogue.json`. Where this document and
those files disagree, the files are right and this document has drifted — open an issue.*
