#!/usr/bin/env node
// tools/audio-pipeline/verify-ids.mjs
//
// Validates the generated recording script against the audio ID grammar.
// Zero dependencies, plain Node — deliberately, so it runs today, before the
// Expo scaffold and package.json exist. Port to TypeScript alongside the rest
// of tools/audio-pipeline/ once the toolchain lands (task D11).
//
// Usage:
//   node tools/audio-pipeline/verify-ids.mjs [scriptDir]
//
// scriptDir defaults to content/audio/script/. Pass a path to run it against
// the add-on pack before the files are copied into the repo, e.g.
//   node tools/audio-pipeline/verify-ids.mjs docs/batonga-addon-packs/04-audio-maitrise
//
// Exit codes:  0 = clean · 1 = grammar or collision failure · 2 = cannot run
//
// See docs/audio-production.md §1 and §2.  BUILD_PLAN_v2 §W.1, task D12.

import { readFileSync } from 'node:fs';
import { join, resolve } from 'node:path';

const dir = resolve(process.argv[2] ?? 'content/audio/script');

const read = (name) => {
  try {
    return JSON.parse(readFileSync(join(dir, name), 'utf8'));
  } catch (err) {
    console.error(`cannot read ${join(dir, name)}: ${err.message}`);
    process.exit(2);
  }
};

const grammar = read('audio-id-grammar.json');
const script = read('recording-script.json');

const re = new RegExp(grammar.regex);
const rows = script.rows ?? [];

if (rows.length === 0) {
  console.error('recording-script.json holds no rows');
  process.exit(2);
}

// ── 1. grammar ────────────────────────────────────────────────────────────
const malformed = rows.filter((r) => !re.test(r.id));

// ── 2. collisions: one ID, two different things to record ─────────────────
// A duplicated ID is only benign when every row carrying it asks for the same
// take. Distinct `text` under one ID means N recordings compete for one
// filename (docs/audio-production.md §5) and the last one written wins.
const byId = new Map();
for (const r of rows) {
  if (!byId.has(r.id)) byId.set(r.id, []);
  byId.get(r.id).push(r);
}
const collisions = [...byId.entries()].filter(
  ([, rs]) => new Set(rs.map((r) => r.text)).size > 1,
);
const benignDupes = [...byId.entries()].filter(
  ([, rs]) => rs.length > 1 && new Set(rs.map((r) => r.text)).size === 1,
);

// ── 3. case-insensitive filename clashes ──────────────────────────────────
// IDs become filenames. macOS volumes are case-insensitive by default, so two
// IDs differing only in case are one file on half the team's machines.
const byLower = new Map();
for (const id of byId.keys()) {
  const k = id.toLowerCase();
  if (!byLower.has(k)) byLower.set(k, new Set());
  byLower.get(k).add(id);
}
const caseClashes = [...byLower.values()].filter((s) => s.size > 1);

// ── report ────────────────────────────────────────────────────────────────
const distinct = byId.size;
const claimed = script.totalDerivableNow;

console.log(`grammar   ${grammar.regex}`);
console.log(`script    ${rows.length} rows · ${distinct} distinct IDs`);
if (typeof claimed === 'number' && claimed !== distinct) {
  console.log(
    `          note: totalDerivableNow claims ${claimed}; ` +
      `${claimed - distinct} of those are duplicate IDs, not clips`,
  );
}

const byNamespace = {};
for (const id of byId.keys()) {
  const ns = id.split('.')[0];
  byNamespace[ns] = (byNamespace[ns] ?? 0) + 1;
}
console.log(
  `          ${Object.entries(byNamespace)
    .sort((a, b) => b[1] - a[1])
    .map(([ns, n]) => `${ns}:${n}`)
    .join(' ')}`,
);

let failed = false;

if (malformed.length) {
  failed = true;
  console.error(`\nFAIL  ${malformed.length} IDs do not match the grammar`);
  const grouped = {};
  for (const r of malformed) {
    const ns = r.id.split('.')[0];
    (grouped[ns] ??= []).push(r.id);
  }
  for (const [ns, ids] of Object.entries(grouped)) {
    console.error(`      ${ns}: ${ids.length}`);
    for (const id of ids) console.error(`        ${id}`);
  }
  console.error(
    '      → docs/audio-production.md §2.1 — team decision, not Dev D\'s alone',
  );
}

if (collisions.length) {
  failed = true;
  console.error(
    `\nFAIL  ${collisions.length} IDs carry more than one distinct recording`,
  );
  for (const [id, rs] of collisions) {
    console.error(`      ${id}`);
    for (const r of rs) console.error(`        « ${r.text} »`);
  }
  console.error(
    '      → each of these overwrites the last as a filename. ' +
      'docs/audio-production.md §2.2',
  );
}

if (caseClashes.length) {
  failed = true;
  console.error(`\nFAIL  IDs differing only in case share a filename on macOS`);
  for (const s of caseClashes) console.error(`      ${[...s].join('  ')}`);
}

if (benignDupes.length) {
  console.warn(
    `\nWARN  ${benignDupes.length} IDs are repeated with identical text ` +
      `(the studio is being asked to record them twice)`,
  );
  for (const [id, rs] of benignDupes) console.warn(`      ${id} ×${rs.length}`);
}

if (!failed) console.log('\nOK    every ID matches the grammar and is unique');

process.exit(failed ? 1 : 0);
