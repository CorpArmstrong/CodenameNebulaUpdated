#!/usr/bin/env node
/*
 * bsp_audit.js - look for BSP holes in a built map (.dx), with no editor.
 *
 * A hole is a place where the collision says "solid" but nothing is drawn, so
 * the player looks through the wall. This walks the level's real BSP tree, not
 * a re-run of the CSG: rays go out from where actors stand, and at the point a
 * ray enters solid it asks which polygon the wall has there.
 *
 *   NO_POLY    no polygon on that plane covers the point: a hole in the wall
 *   BACKFACE   the polygon faces away from the viewer and is not two-sided
 *   INVISIBLE  the polygon there is flagged Invisible but is a real solid
 *   BLOCKER    Invisible + Semisolid: a designer's collision shell, common in
 *              the stock maps too. Counted, listed only with --all
 *
 * Findings are grouped by the plane of the wall, most rays first; one hole in a
 * wall is hit from many angles and lands in one group. The stock maps score too
 * (UNATCOIsland 14 NO_POLY rays, Airfield 641, at --rays 150), so compare with
 * them, and look at a finding in the game before acting: like map_probe.js this
 * generates hypotheses. It sees holes in the tree, not faults in rendering order
 * or zone visibility, and only from where actors stand.
 *
 * Looked at by eye, 2026-11-04. INVISIBLE is real: a wall flagged Invisible draws as a
 * black void (the room behind it does not show), and it was reported as such. NO_POLY is
 * unproven: on stock Airfield most of it is a sea floor under fog, nothing to see there.
 *
 * Usage:
 *   node tools/bsp_audit.js <map.dx> [--rays 300] [--range 4000] [--top 25] [--all]
 *   node tools/bsp_audit.js <map.dx> at <x> <y> <z>        solid or open, zone
 *   node tools/bsp_audit.js <map.dx> ray <x y z> <x y z>   first wall on a line
 *   node tools/bsp_audit.js <map.dx> stats                 tree and flag counts
 */
'use strict';
const { load, Reader, objProps } = require('./pkg_probe');

const PF_INVISIBLE = 0x1, PF_MASKED = 0x2, PF_TRANSLUCENT = 0x4, PF_NOTSOLID = 0x8, PF_SEMISOLID = 0x20, PF_FAKEBACKDROP = 0x80,
  PF_TWOSIDED = 0x100, PF_PORTAL = 0x4000000;
const NF_NOTCSG = 0x01, NF_ISNEW = 0x20;
const SEE_THROUGH = PF_MASKED | PF_TRANSLUCENT | PF_PORTAL | PF_FAKEBACKDROP;

// The level BSP is the largest Model in the package. Layout as in UModel::Serialize, see pkg_probe.readModel.
function readBsp(P) {
  let best = null;
  P.exports.forEach((e) => { if (P.className(e) === 'Model' && (!best || e.size > best.size)) best = e; });
  if (!best) throw new Error('no Model in ' + P.path);
  const { end } = objProps(P, best);
  const r = new Reader(P.buf, end);
  r.p += 25 + 16; // FBox + FSphere
  const vecs = (n) => { const a = []; for (let i = 0; i < n; i++) a.push(r.vec()); return a; };
  const vectors = vecs(r.ci());
  const points = vecs(r.ci());
  const nodes = [];
  const nNodes = r.ci();
  for (let i = 0; i < nNodes; i++) {
    const plane = [r.f32(), r.f32(), r.f32(), r.f32()];
    r.p += 8;
    const flags = r.u8();
    const iVertPool = r.ci(), iSurf = r.ci(), back = r.ci(), front = r.ci(), iPlane = r.ci();
    r.ci(); r.ci();
    const zone0 = r.u8(), zone1 = r.u8(), numVerts = r.u8();
    r.p += 8;
    nodes.push({ i, plane, flags, iVertPool, iSurf, back, front, iPlane, zone: [zone0, zone1], numVerts });
  }
  const surfs = [];
  const nSurfs = r.ci();
  for (let i = 0; i < nSurfs; i++) {
    const tex = r.ci(), flags = r.u32();
    const idx = []; for (let k = 0; k < 6; k++) idx.push(r.ci());
    r.p += 4; r.ci();
    surfs.push({ tex, flags, iBrushPoly: idx[5] });
  }
  const verts = [];
  const nVerts = r.ci();
  for (let i = 0; i < nVerts; i++) { verts.push(r.ci()); r.ci(); }
  return { name: best.name, vectors, points, nodes, surfs, verts, texName: (t) => (t ? P.objPath(t) : 'None') };
}

const dot = (pl, p) => pl[0] * p[0] + pl[1] * p[1] + pl[2] * p[2] - pl[3];
const isCsg = (n) => n.numVerts > 0 && !(n.flags & (NF_ISNEW | NF_NOTCSG));
const childOutside = (front, outside, n) => (front ? outside || isCsg(n) : outside && !isCsg(n));

// World starts solid in a level (RootOutside false).
function pointClass(bsp, p) {
  const { nodes } = bsp;
  let i = 0, outside = false, zone = 0;
  while (i >= 0 && nodes.length) {
    const n = nodes[i], f = dot(n.plane, p) >= 0;
    outside = childOutside(f, outside, n);
    zone = n.zone[f ? 1 : 0];
    i = f ? n.front : n.back;
  }
  return { open: outside, zone };
}

// First entry into solid along a..b, with the node whose plane it crossed.
function firstSolid(bsp, a, b) {
  const { nodes } = bsp;
  const walk = (i, outside, p, q, tp, tq, via) => {
    if (i < 0) return outside ? null : { t: tp, via };
    const n = nodes[i], dp = dot(n.plane, p), dq = dot(n.plane, q);
    if (dp >= -0.01 && dq >= -0.01) return walk(n.front, childOutside(true, outside, n), p, q, tp, tq, via);
    if (dp <= 0.01 && dq <= 0.01) return walk(n.back, childOutside(false, outside, n), p, q, tp, tq, via);
    const s = dp / (dp - dq), m = [p[0] + (q[0] - p[0]) * s, p[1] + (q[1] - p[1]) * s, p[2] + (q[2] - p[2]) * s];
    const tm = tp + (tq - tp) * s, front = dp >= 0;
    return walk(front ? n.front : n.back, childOutside(front, outside, n), p, m, tp, tm, via)
      || walk(front ? n.back : n.front, childOutside(!front, outside, n), m, q, tm, tq, n);
  };
  const r = walk(0, false, a, b, 0, 1, null);
  if (!r) return null;
  return { ...r, at: [a[0] + (b[0] - a[0]) * r.t, a[1] + (b[1] - a[1]) * r.t, a[2] + (b[2] - a[2]) * r.t] };
}

const planeKey = (pl) => {
  const s = pl[0] < -1e-3 || (Math.abs(pl[0]) <= 1e-3 && (pl[1] < -1e-3 || (Math.abs(pl[1]) <= 1e-3 && pl[2] < 0))) ? -1 : 1;
  return [pl[0] * s, pl[1] * s, pl[2] * s].map((v) => v.toFixed(3)).join() + '|' + Math.round(pl[3] * s);
};

function indexPlanes(bsp) {
  const m = new Map();
  for (const n of bsp.nodes) {
    if (!n.numVerts) continue;
    for (const k of [planeKey(n.plane), planeKey([n.plane[0], n.plane[1], n.plane[2], n.plane[3] + 1]), planeKey([n.plane[0], n.plane[1], n.plane[2], n.plane[3] - 1])]) {
      if (!m.has(k)) m.set(k, []);
      m.get(k).push(n);
    }
  }
  bsp.planes = m;
}

// Convex fragment, tested edge by edge in its own plane, grown by a small margin for T-junctions.
function nodeCovers(bsp, n, p, margin) {
  const v = [];
  for (let k = 0; k < n.numVerts; k++) v.push(bsp.points[bsp.verts[n.iVertPool + k]]);
  const N = n.plane;
  let sign = 0;
  for (let k = 0; k < v.length; k++) {
    const a = v[k], b = v[(k + 1) % v.length];
    const e = [b[0] - a[0], b[1] - a[1], b[2] - a[2]], len = Math.hypot(e[0], e[1], e[2]);
    if (len < 1e-3) continue;
    const c = [N[1] * e[2] - N[2] * e[1], N[2] * e[0] - N[0] * e[2], N[0] * e[1] - N[1] * e[0]];
    const d = (c[0] * (p[0] - a[0]) + c[1] * (p[1] - a[1]) + c[2] * (p[2] - a[2])) / len;
    if (!sign && Math.abs(d) > margin) sign = Math.sign(d);
    if (sign && d * sign < -margin) return false;
  }
  return true;
}

function classifyHit(bsp, hit, dir) {
  const candidates = (hit.via && bsp.planes.get(planeKey(hit.via.plane))) || [];
  const covering = candidates.filter((n) => nodeCovers(bsp, n, hit.at, 1.5));
  if (!covering.length) return { kind: 'NO_POLY', node: hit.via };
  const opaque = covering.filter((n) => !(bsp.surfs[n.iSurf].flags & (PF_INVISIBLE | PF_NOTSOLID)));
  if (!opaque.length) {
    const n = covering[0], f = bsp.surfs[n.iSurf].flags;
    if (!(f & PF_INVISIBLE) || (f & SEE_THROUGH)) return { kind: 'OK', node: n };
    return { kind: f & PF_SEMISOLID ? 'BLOCKER' : 'INVISIBLE', node: n };
  }
  const facing = opaque.filter((n) => {
    const d = n.plane[0] * dir[0] + n.plane[1] * dir[1] + n.plane[2] * dir[2];
    return d < 0 || (bsp.surfs[n.iSurf].flags & PF_TWOSIDED);
  });
  return { kind: facing.length ? 'OK' : 'BACKFACE', node: opaque[0] };
}

// Actors placed in the level: the places someone stands or looks from.
function seeds(P, bsp) {
  const skip = /^(Model|Polys|Level|LevelSummary|Texture|Palette|Sound|Music|TextBuffer|Brush|Mover|DeusExMover|BreakableGlass|LevelInfo|Class|Function|Package|Conversation)$/;
  const out = [];
  P.exports.forEach((e) => {
    const c = P.className(e);
    if (!e.size || skip.test(c)) return;
    let loc;
    try { const p = objProps(P, e).props.find((x) => x.name === 'Location'); loc = p && p.value; } catch (err) { return; }
    if (!Array.isArray(loc)) return;
    if (pointClass(bsp, loc).open) out.push({ name: e.name, cls: c, loc });
  });
  return out;
}

function sphere(n) {
  const a = [], g = Math.PI * (3 - Math.sqrt(5));
  for (let i = 0; i < n; i++) {
    const z = 1 - (2 * i + 1) / n, r = Math.sqrt(1 - z * z), t = g * i;
    a.push([r * Math.cos(t), r * Math.sin(t), z]);
  }
  return a;
}

function audit(bsp, from, rays, range) {
  const dirs = sphere(rays), found = new Map();
  let cast = 0, hits = 0;
  for (const s of from) {
    for (const d of dirs) {
      cast++;
      const hit = firstSolid(bsp, s.loc, [s.loc[0] + d[0] * range, s.loc[1] + d[1] * range, s.loc[2] + d[2] * range]);
      if (!hit) continue;
      hits++;
      const c = classifyHit(bsp, hit, d);
      if (c.kind === 'OK') continue;
      const k = c.kind + ':' + (hit.via ? planeKey(hit.via.plane) : '?');
      if (!found.has(k)) found.set(k, { kind: c.kind, at: hit.at, from: s, n: 0, min: hit.at.slice(), max: hit.at.slice(), surf: c.node && bsp.surfs[c.node.iSurf] });
      const f = found.get(k);
      f.n++;
      hit.at.forEach((v, i) => { f.min[i] = Math.min(f.min[i], v); f.max[i] = Math.max(f.max[i], v); });
    }
  }
  return { cast, hits, findings: [...found.values()].sort((a, b) => b.n - a.n) };
}

const fmt = (p) => p.map((v) => Math.round(v)).join(' ');

function main() {
  const argv = process.argv.slice(2);
  const path = argv.shift();
  if (!path) { console.error(require('fs').readFileSync(__filename, 'utf8').split('*/')[0]); process.exit(1); }
  const P = load(path);
  P.path = path;
  const bsp = readBsp(P);
  indexPlanes(bsp);
  const opt = (name, def) => { const i = argv.indexOf('--' + name); return i >= 0 ? +argv[i + 1] : def; };
  if (argv[0] === 'at') {
    const p = argv.slice(1, 4).map(Number), c = pointClass(bsp, p);
    console.log(`(${fmt(p)}) ${c.open ? 'open' : 'SOLID'} zone=${c.zone}`);
  } else if (argv[0] === 'ray') {
    const a = argv.slice(1, 4).map(Number), b = argv.slice(4, 7).map(Number);
    const hit = firstSolid(bsp, a, b);
    if (!hit) { console.log('nothing solid on the line'); return; }
    const len = Math.hypot(b[0] - a[0], b[1] - a[1], b[2] - a[2]), d = [(b[0] - a[0]) / len, (b[1] - a[1]) / len, (b[2] - a[2]) / len];
    const c = classifyHit(bsp, hit, d), s = c.node && bsp.surfs[c.node.iSurf];
    console.log(`solid at (${fmt(hit.at)}) ${c.kind}` + (s ? ` tex=${bsp.texName(s.tex)} flags=0x${s.flags.toString(16)}` : ''));
  } else if (argv[0] === 'stats') {
    const flags = {};
    bsp.surfs.forEach((s) => { const k = '0x' + s.flags.toString(16); flags[k] = (flags[k] || 0) + 1; });
    console.log(`${bsp.name}: nodes=${bsp.nodes.length} surfs=${bsp.surfs.length} points=${bsp.points.length} verts=${bsp.verts.length}`);
    console.log(`nodes with no polygon: ${bsp.nodes.filter((n) => !n.numVerts).length}`);
    console.log(flags);
  } else {
    const from = seeds(P, bsp);
    const r = audit(bsp, from, opt('rays', 300), opt('range', 4000));
    console.log(`${path}: ${bsp.nodes.length} nodes, ${from.length} viewpoints, ${r.cast} rays, ${r.hits} hit a wall`);
    const by = {};
    r.findings.forEach((f) => { by[f.kind] = (by[f.kind] || 0) + f.n; });
    console.log('rays by finding:', by, `walls: ${r.findings.length}`);
    const shown = r.findings.filter((f) => argv.includes('--all') || f.kind !== 'BLOCKER');
    for (const f of shown.slice(0, opt('top', 25))) {
      console.log(`${f.kind.padEnd(9)} x${String(f.n).padEnd(5)} (${fmt(f.min)}) .. (${fmt(f.max)}) seen from ${f.from.name} (${fmt(f.from.loc)})` + (f.surf ? ` tex=${bsp.texName(f.surf.tex)} flags=0x${f.surf.flags.toString(16)}` : ''));
    }
  }
}

if (require.main === module) main();
module.exports = { readBsp, indexPlanes, pointClass, firstSolid, classifyHit, audit, seeds };
