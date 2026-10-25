#!/usr/bin/env node
/*
 * bsp_retexture.js - give a map's untextured BSP surfaces a texture.
 *
 * A level surface whose Texture is None is drawn with the engine's
 * DefaultTexture (the green bubbles). Some CNN maps have had a few since they
 * were built. This picks a texture for each visible one and writes it into
 * the level model (what the game draws) and into the brush that made the
 * surface (what UnrealEd rebuilds from), so a later rebuild keeps it:
 *   1. the texture most used on the brush's other faces;
 *   2. otherwise that of the nearest textured level surface facing the same way.
 * A texture reference is a compact index, longer than the 1-byte None, so the
 * changed models are written again at the end of the file and the export
 * table after them (exports are found through that table, never by position).
 *
 * Usage:
 *   node tools/bsp_retexture.js <map.dx>                       list what it would do
 *   node tools/bsp_retexture.js <map.dx> [surf=Pkg.Tex ...] --write
 * surf=Pkg.Tex overrides the pick for one surface (Pkg.Tex must be imported).
 *
 * Written 2026-10-25 for the DefaultTexture patches on L1 and the endings.
 */
'use strict';
const fs = require('fs');
const { load, Reader, objProps, readModel, flagStr } = require('./pkg_probe.js');

function ciBytes(v) {
  let a = Math.abs(v);
  const out = [(v < 0 ? 0x80 : 0) | (a & 0x3f) | (a >= 0x40 ? 0x40 : 0)];
  a >>>= 6;
  while (a) { out.push((a & 0x7f) | (a >= 0x80 ? 0x80 : 0)); a >>>= 7; }
  return Buffer.from(out);
}

// A Model export parsed far enough to know where each surface's texture
// reference sits, plus its centre and normal (from the BSP nodes).
function parseModel(P, e) {
  const r = new Reader(P.buf, objProps(P, e).end);
  r.p += 41;
  const V = []; for (let i = r.ci(); i > 0; i--) V.push(r.vec());
  const Pt = []; for (let i = r.ci(); i > 0; i--) Pt.push(r.vec());
  const nodes = [];
  for (let i = r.ci(); i > 0; i--) {
    r.p += 25; const vp = r.ci(), surf = r.ci(); for (let k = 0; k < 5; k++) r.ci(); r.p += 2;
    const nv = r.u8(); r.p += 8; nodes.push({ vp, surf, nv });
  }
  const surfs = [];
  for (let i = r.ci(); i > 0; i--) {
    const texAt = r.p, tex = r.ci(), texLen = r.p - texAt;
    const flags = r.u32(); const idx = []; for (let k = 0; k < 6; k++) idx.push(r.ci());
    r.i16(); r.i16();
    surfs.push({ texAt, texLen, tex, flags, normal: V[idx[1]], brushPoly: idx[5], actor: r.ci(), pts: [] });
  }
  const verts = []; for (let i = r.ci(); i > 0; i--) { verts.push(r.ci()); r.ci(); }
  for (const nd of nodes) for (let k = 0; k < nd.nv; k++) surfs[nd.surf].pts.push(Pt[verts[nd.vp + k]]);
  for (const s of surfs) s.centre = s.pts.length ? [0, 1, 2].map((k) => s.pts.reduce((a, p) => a + p[k], 0) / s.pts.length) : null;
  return surfs;
}

// The Polys export: where each poly's texture reference sits.
function parsePolys(P, e) {
  const r = new Reader(P.buf, objProps(P, e).end);
  const num = r.i32(); r.i32();
  const polys = [];
  for (let i = 0; i < num; i++) {
    const nv = r.ci(); r.p += 48 + nv * 12; r.u32(); r.ci();
    const texAt = r.p, tex = r.ci();
    polys.push({ texAt, texLen: r.p - texAt, tex });
    r.ci(); r.ci(); r.ci(); r.p += 4;
  }
  return polys;
}

// export data with some compact indices swapped: [{at, len, value}]
function rewrite(P, e, edits) {
  const parts = []; let pos = e.off;
  for (const ed of edits.sort((a, b) => a.at - b.at)) {
    parts.push(P.buf.subarray(pos, ed.at), ciBytes(ed.value)); pos = ed.at + ed.len;
  }
  parts.push(P.buf.subarray(pos, e.off + e.size));
  return Buffer.concat(parts);
}

function main() {
  const args = process.argv.slice(2);
  const write = args.includes('--write');
  const [path, ...overrides] = args.filter((a) => a !== '--write');
  if (!path) { console.error(fs.readFileSync(__filename, 'utf8').split('*/')[0]); process.exit(1); }
  const P = load(path);
  const exIndex = (e) => P.exports.indexOf(e) + 1;
  const importRef = (p) => {
    const i = P.imports.findIndex((im, k) => P.objPath(-(k + 1)).toLowerCase() === p.toLowerCase());
    if (i < 0) throw new Error(`${p} is not imported by this map`);
    return -(i + 1);
  };
  const forced = Object.fromEntries(overrides.map((o) => o.split('=')).map(([s, t]) => [+s, importRef(t)]));

  // the level model is the one with the most surfaces
  let level = null, levelSurfs = null;
  for (const e of P.exports) {
    if (P.className(e) !== 'Model' || !e.size) continue;
    let s; try { s = parseModel(P, e); } catch (err) { continue; }
    if (!levelSurfs || s.length > levelSurfs.length) { level = e; levelSurfs = s; }
  }
  const brushPolys = new Map();   // brush actor -> {export, polys}
  const polysOf = (actorRef) => {
    if (brushPolys.has(actorRef)) return brushPolys.get(actorRef);
    let v = null;
    if (actorRef > 0) {
      const brush = objProps(P, P.exports[actorRef - 1]).props.find((p) => p.name === 'Brush');
      const model = brush && P.find(brush.value.split('.').pop());
      const pe = model && readModel(P, model).polys;
      if (pe) v = { export: pe, polys: parsePolys(P, pe) };
    }
    brushPolys.set(actorRef, v);
    return v;
  };

  const picks = [];
  levelSurfs.forEach((s, i) => {
    if (s.tex !== 0 || (s.flags & 1) || !s.centre) return;
    let tex = forced[i], why = 'given';
    const bp = polysOf(s.actor);
    if (!tex && bp) {
      const count = {};
      bp.polys.forEach((p) => { if (p.tex) count[p.tex] = (count[p.tex] || 0) + 1; });
      const best = Object.entries(count).sort((a, b) => b[1] - a[1])[0];
      if (best) { tex = +best[0]; why = 'brush'; }
    }
    if (!tex) {
      let bestD = Infinity;
      levelSurfs.forEach((o) => {
        if (!o.tex || !o.centre || (o.flags & 1)) return;
        const dot = o.normal[0] * s.normal[0] + o.normal[1] * s.normal[1] + o.normal[2] * s.normal[2];
        if (dot < 0.9) return;
        const d = Math.hypot(...[0, 1, 2].map((k) => o.centre[k] - s.centre[k]));
        if (d < bestD) { bestD = d; tex = o.tex; }
      });
      why = `neighbour ${Math.round(bestD)} away`;
    }
    picks.push({ i, s, tex, why, bp });
  });
  // a brush with no texture on any face gets one texture for all of them:
  // the one most of its faces' neighbours voted for
  const byBrush = new Map();
  for (const p of picks) if (p.why.startsWith('neighbour')) {
    if (!byBrush.has(p.s.actor)) byBrush.set(p.s.actor, []);
    byBrush.get(p.s.actor).push(p);
  }
  for (const list of byBrush.values()) {
    if (list.length < 2) continue;
    const votes = {};
    list.forEach((p) => { votes[p.tex] = (votes[p.tex] || 0) + 1; });
    const tex = +Object.entries(votes).sort((a, b) => b[1] - a[1])[0][0];
    list.forEach((p) => { p.tex = tex; p.why = 'brush neighbours'; });
  }
  for (const p of picks) {
    console.log(`surf ${p.i} at ${p.s.centre.map(Math.round).join(',')} ${flagStr(p.s.flags)} [${P.objName(p.s.actor)}] -> ${P.objPath(p.tex)} (${p.why})`);
  }
  if (!picks.length) { console.log('no untextured visible surfaces'); return; }
  if (!write) { console.log('dry run; add --write to apply'); return; }

  // new data for the level model and every brush Polys touched
  const blobs = new Map([[level, rewrite(P, level, picks.map((p) => ({ at: p.s.texAt, len: p.s.texLen, value: p.tex })))]]);
  const polyEdits = new Map();
  for (const p of picks) {
    if (!p.bp) continue;
    const poly = p.bp.polys[p.s.brushPoly];
    if (!poly || poly.tex) continue;
    if (!polyEdits.has(p.bp.export)) polyEdits.set(p.bp.export, []);
    const list = polyEdits.get(p.bp.export);
    if (!list.some((x) => x.at === poly.texAt)) list.push({ at: poly.texAt, len: poly.texLen, value: p.tex });
  }
  for (const [e, edits] of polyEdits) blobs.set(e, rewrite(P, e, edits));

  // blobs appended, then the export table with their new sizes and offsets
  const parts = [P.buf]; let at = P.buf.length;
  const place = new Map();
  for (const [e, b] of blobs) { place.set(e, { off: at, size: b.length }); parts.push(b); at += b.length; }
  const r = new Reader(P.buf, P.buf.readUInt32LE(24));
  const table = [];
  for (const e of P.exports) {
    const start = r.p; r.ci(); r.ci(); r.i32(); r.ci(); r.u32();
    const head = P.buf.subarray(start, r.p);
    const size = r.ci(); if (size > 0) r.ci();
    const pl = place.get(e) || { off: e.off, size };
    table.push(head, ciBytes(pl.size), pl.size > 0 ? ciBytes(pl.off) : Buffer.alloc(0));
  }
  const tableBuf = Buffer.concat(table);
  const out = Buffer.concat([...parts, tableBuf]);
  out.writeUInt32LE(at, 24);

  // read it back: every pick textured, nothing else moved
  const tmp = require('os').tmpdir() + `/bsp_retexture_${process.pid}.tmp`;
  fs.writeFileSync(tmp, out);
  try {
    const Q = load(tmp);
    const qs = parseModel(Q, Q.exports[exIndex(level) - 1]);
    for (const p of picks) if (qs[p.i].tex !== p.tex) throw new Error(`surf ${p.i} reads back wrong`);
    if (qs.length !== levelSurfs.length || Q.exports.length !== P.exports.length) throw new Error('model read back wrong');
  } finally { fs.unlinkSync(tmp); }
  fs.writeFileSync(path, out);
  console.log(`wrote ${path}: ${picks.length} surfaces, ${polyEdits.size} brushes (+${out.length - P.buf.length} bytes)`);
}

if (require.main === module) main();
