#!/usr/bin/env node
/*
 * pkg_deadbytes.js - zero what a package carries but nothing reads.
 *
 * Two kinds of dead weight end up in CNN's shipped packages:
 *  - maps edited in place by pkg_reimport.js / bsp_retexture.js: a table or a
 *    model that grew was written again at the end of the file and the old
 *    copy stays behind, no longer covered by any export or table (3-4.5 MB
 *    on L1, Hijacking, Transcend, Mutiny);
 *  - third-party packages of which the mod uses a few objects
 *    (DXRVNewVehicles.u: one tank of 15 vehicles, 46 of 47 MB unused).
 *
 * Nothing is moved: objects carry absolute file offsets of their own (lazy
 * arrays: texture mips, mesh and lightmap data), so every byte that stays
 * keeps its position. Dead bytes are set to zero instead, which the
 * installer's LZMA stores for next to nothing; the file keeps its size.
 *
 * A dropped export gets SerialSize 0 in the export table, so if anything
 * ever loads it the engine stops with "Serial size mismatch" rather than
 * reading zeros. Only drop what the game provably never loads
 * (tools/cnn_objdump.ps1) and check the result in the game again.
 *
 * Usage:
 *   node tools/pkg_deadbytes.js <pkg>                       report gaps and exports
 *   node tools/pkg_deadbytes.js <pkg> --gaps --out <file>   zero bytes no export or table covers
 *   node tools/pkg_deadbytes.js <pkg> --keep <Class>:<Obj,Obj,...> [--gaps] --out <file>
 *       drop every export of that class except the named ones (Group.Name or Name)
 */
'use strict';
const fs = require('fs');
const { load, Reader } = require('./pkg_probe.js');

function ciBytes(v) {
  let a = Math.abs(v);
  const out = [(v < 0 ? 0x80 : 0) | (a & 0x3f)];
  a >>>= 6;
  while (a) { out[out.length - 1] |= out.length === 1 ? 0x40 : 0x80; out.push(a & 0x7f); a >>>= 7; }
  return out;
}

// Byte ranges the package itself reads: header, name/import/export tables,
// and each export's serial data.
function layout(P) {
  const b = P.buf;
  const nameCount = b.readUInt32LE(12), nameOff = b.readUInt32LE(16);
  const expCount = b.readUInt32LE(20), expOff = b.readUInt32LE(24);
  const impCount = b.readUInt32LE(28), impOff = b.readUInt32LE(32);
  if (P.ver < 68) throw new Error('only package version 68 and later (generations header)');
  const gens = b.readInt32LE(52);
  const ranges = [{ what: 'header', from: 0, to: 56 + gens * 8 }];

  let r = new Reader(b, nameOff);
  for (let i = 0; i < nameCount; i++) { r.str(); r.u32(); }
  ranges.push({ what: 'names', from: nameOff, to: r.p });
  r = new Reader(b, impOff);
  for (let i = 0; i < impCount; i++) { r.ci(); r.ci(); r.i32(); r.ci(); }
  ranges.push({ what: 'imports', from: impOff, to: r.p });
  r = new Reader(b, expOff);
  const fields = [];
  for (let i = 0; i < expCount; i++) {
    const start = r.p;
    r.ci(); r.ci(); r.i32(); r.ci(); r.u32();
    const sizeAt = r.p; const size = r.ci(); if (size > 0) r.ci();
    fields.push({ start, sizeAt, end: r.p });
  }
  ranges.push({ what: 'exports', from: expOff, to: r.p });
  P.exports.forEach((e, i) => { if (e.size > 0) ranges.push({ what: 'export ' + (i + 1), from: e.off, to: e.off + e.size }); });
  return { ranges, fields, expOff };
}

function gaps(len, ranges) {
  const sorted = ranges.slice().sort((a, b) => a.from - b.from);
  const out = [];
  let at = 0;
  for (const rg of sorted) {
    if (rg.from > at) out.push({ from: at, to: rg.from });
    at = Math.max(at, rg.to);
  }
  if (len > at) out.push({ from: at, to: len });
  return out;
}

const mb = (n) => (n / 1048576).toFixed(2) + ' MB';

function main() {
  const args = process.argv.slice(2);
  const path = args[0];
  if (!path) { console.error(fs.readFileSync(__filename, 'utf8').split('*/')[0]); process.exit(1); }
  const opt = (k) => { const i = args.indexOf(k); return i >= 0 ? args[i + 1] : null; };
  const out = opt('--out'), keep = opt('--keep'), zeroGaps = args.includes('--gaps');

  const P = load(path);
  const buf = Buffer.from(P.buf);
  const { ranges, fields, expOff } = layout(P);

  // exports to drop
  const drop = new Set();
  if (keep) {
    const [cls, list] = keep.split(':');
    const names = new Set((list || '').split(',').filter(Boolean).map((s) => s.toLowerCase()));
    P.exports.forEach((e, i) => {
      if (P.className(e) !== cls || e.size === 0) return;
      // an export's path starts below the package: Group.Name
      if (!names.has(P.objPath(i + 1).toLowerCase()) && !names.has(e.name.toLowerCase())) drop.add(i);
    });
    const found = P.exports.filter((e, i) => P.className(e) === cls && e.size > 0 && !drop.has(i)).map((e) => e.name);
    for (const n of names) if (!found.some((f) => f.toLowerCase() === n.split('.').pop().toLowerCase())) throw new Error('kept object not found: ' + n);
  }

  let dropped = 0;
  for (const i of drop) { const e = P.exports[i]; buf.fill(0, e.off, e.off + e.size); dropped += e.size; }

  const live = ranges.filter((rg) => !(rg.what.startsWith('export ') && drop.has(+rg.what.slice(7) - 1)));
  const dead = gaps(buf.length, live);
  const gapBytes = dead.reduce((s, g) => s + g.to - g.from, 0) - dropped;

  console.log(`${path}: ${mb(buf.length)}, ${P.exports.length} exports`);
  console.log(`  not covered by any export or table: ${mb(gapBytes)} in ${dead.length} ranges`);
  if (keep) console.log(`  dropped ${drop.size} exports, ${mb(dropped)}`);
  if (!out) {
    for (const g of dead.slice(0, 20)) console.log(`    ${g.from}..${g.to} (${g.to - g.from})`);
    return;
  }

  if (zeroGaps) for (const g of dead) buf.fill(0, g.from, g.to);

  // the export table again, dropped entries with SerialSize 0 and no offset;
  // it only gets shorter, so it is written in place and the rest zeroed
  if (drop.size) {
    const parts = [];
    fields.forEach((f, i) => {
      if (drop.has(i)) parts.push(P.buf.subarray(f.start, f.sizeAt), Buffer.from(ciBytes(0)));
      else parts.push(P.buf.subarray(f.start, f.end));
    });
    const table = Buffer.concat(parts);
    const oldEnd = fields[fields.length - 1].end;
    buf.fill(0, expOff, oldEnd);
    table.copy(buf, expOff);
  }
  fs.writeFileSync(out, buf);

  const check = load(out);
  if (check.exports.length !== P.exports.length || check.names.length !== P.names.length) throw new Error('re-read failed');
  check.exports.forEach((e, i) => {
    const o = P.exports[i];
    if (e.name !== o.name || (!drop.has(i) && (e.size !== o.size || e.off !== o.off))) throw new Error('export changed: ' + o.name);
  });
  console.log(`  wrote ${out}`);
}

if (require.main === module) main();
