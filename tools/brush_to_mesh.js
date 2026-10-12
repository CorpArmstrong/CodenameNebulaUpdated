#!/usr/bin/env node
/*
 * brush_to_mesh.js - turn a map mover's brush into a Deus Ex vertex mesh.
 *
 * Mover brushes are lit through lightmaps baked in UnrealEd; a brush imported
 * from SketchUp without a lighting rebuild renders black, and lit dynamically
 * it costs ~20 ms a frame. A mesh is lit per vertex by every light at no real
 * cost, so the same geometry as a mesh needs no editor at all.
 *
 *   node tools/brush_to_mesh.js <map.dx> <MoverName> <OutBase> [x,y,z]
 *
 * Writes CNN/Models/<OutBase>_d.3d and _a.3d, Deus Ex 16-bit vertices at 1/64
 * unit (import with MESHMAP SCALE 0.015625), in world axes: the actor showing
 * the mesh keeps Rotation 0. The mesh origin is the middle of the brush plus
 * x,y,z; the result prints it as the actor's offset from the mover's Location.
 * A mesh is lit from the zone its Location is in, so the origin must sit in
 * the lit room, not inside the door frame or in the space behind the door.
 *
 * Texture coordinates follow the brush's TextureU/V; mesh UVs cannot wrap, so
 * each polygon is cut along the texture's tile grid. Faces are turned to point
 * out of the solid (ray parity), and wound the other way round from brushes,
 * as Deus Ex meshes are.
 */
'use strict';
const fs = require('fs');
const path = require('path');
const m = require('./pkg_probe.js');

const [mapPath, moverName, outBase, shiftArg] = process.argv.slice(2);
if (!outBase) { console.error(fs.readFileSync(__filename, 'utf8').split('*/')[0]); process.exit(1); }
const shift = shiftArg ? shiftArg.split(',').map(Number) : [0, 0, 0];

const P = m.load(mapPath);
const mover = P.find(moverName);
const props = Object.fromEntries(m.objProps(P, mover).props.map((p) => [p.name, p.value]));
const model = m.readModel(P, P.find(props.Brush.split('.').pop()));
const polys = m.readPolys(P, model.polys);
const prePivot = props.PrePivot || [0, 0, 0];
const rot = props.Rotation || [0, 0, 0];

// UE1 rotator -> axes (Pitch, Yaw, Roll in 65536ths of a turn).
const ang = (u) => u * Math.PI / 32768;
const [SP, CP] = [Math.sin(ang(rot[0])), Math.cos(ang(rot[0]))];
const [SY, CY] = [Math.sin(ang(rot[1])), Math.cos(ang(rot[1]))];
const [SR, CR] = [Math.sin(ang(rot[2])), Math.cos(ang(rot[2]))];
const AX = [CP * CY, CP * SY, SP];
const AY = [SR * SP * CY - CR * SY, SR * SP * SY + CR * CY, -SR * CP];
const AZ = [-(CR * SP * CY + SR * SY), CY * SR - CR * SP * SY, CR * CP];
const toWorld = (v) => {
  const l = [v[0] - prePivot[0], v[1] - prePivot[1], v[2] - prePivot[2]];
  return [0, 1, 2].map((k) => l[0] * AX[k] + l[1] * AY[k] + l[2] * AZ[k]);
};
const dot = (a, b) => a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
const sub = (a, b) => [a[0] - b[0], a[1] - b[1], a[2] - b[2]];
const lerp = (a, b, t) => a.map((x, k) => x + (b[k] - x) * t);

const TILE = 64; // AF_LiftMetl_A is 64x64; byte UVs span one tile

// Sutherland-Hodgman against one axis-aligned line in UV space.
function clip(poly, axis, value, keepBelow) {
  const out = [];
  for (let i = 0; i < poly.length; i++) {
    const a = poly[i], b = poly[(i + 1) % poly.length];
    const da = keepBelow ? value - a.uv[axis] : a.uv[axis] - value;
    const db = keepBelow ? value - b.uv[axis] : b.uv[axis] - value;
    if (da >= 0) out.push(a);
    if ((da >= 0) !== (db >= 0)) {
      const t = da / (da - db);
      out.push({ p: lerp(a.p, b.p, t), uv: lerp(a.uv, b.uv, t) });
    }
  }
  return out;
}

// The SketchUp brushes mix outward and inward faces (an inward front face is
// why one leaf always looked black: it was culled, showing the dark room
// behind). Orient each face by ray parity: from points on the face, step
// along its normal and count crossings with the other faces -- an odd count
// means the normal points into the solid.
const cross = (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]];
const world = polys.map((poly) => {
  const w = poly.verts.map(toWorld);
  let n = [0, 0, 0];
  for (let i = 1; i + 1 < w.length; i++) n = n.map((x, k) => x + cross(sub(w[i], w[0]), sub(w[i + 1], w[0]))[k]);
  const len = Math.hypot(...n) || 1;
  return { w, n: n.map((x) => x / len) };
});
function rayHits(o, d, skip) {
  let hits = 0;
  world.forEach((f, j) => {
    if (j === skip) return;
    const den = dot(f.n, d);
    if (Math.abs(den) < 1e-6) return;
    const t = dot(f.n, sub(f.w[0], o)) / den;
    if (t <= 1e-3) return;
    const x = o.map((c, k) => c + d[k] * t);
    for (let i = 1; i + 1 < f.w.length; i++) {
      const a = f.w[0], b = f.w[i], c = f.w[i + 1];
      const s1 = dot(cross(sub(b, a), sub(x, a)), f.n), s2 = dot(cross(sub(c, b), sub(x, b)), f.n), s3 = dot(cross(sub(a, c), sub(x, c)), f.n);
      if ((s1 >= 0 && s2 >= 0 && s3 >= 0) || (s1 <= 0 && s2 <= 0 && s3 <= 0)) { hits++; return; }
    }
  });
  return hits;
}
let inwardCount = 0;
world.forEach((f, i) => {
  const c = f.w.reduce((s2, v) => s2.map((x, k) => x + v[k] / f.w.length), [0, 0, 0]);
  const starts = [c, ...f.w.map((v) => lerp(c, v, 0.35))];
  let odd = 0;
  starts.forEach((p, r) => {
    const d = f.n.map((x, k) => x + 0.013 * Math.sin(7 * r + 3 * k + 1));
    const dl = Math.hypot(...d);
    if (rayHits(p.map((x, k) => x + f.n[k] * 0.01), d.map((x) => x / dl), i) % 2) odd++;
  });
  f.inward = odd * 2 > starts.length;
  if (f.inward) inwardCount++;
});

const verts = [], tris = [];
let skipped = 0;
for (const [pi, poly] of polys.entries()) {
  // UVs in texels from the brush-space polygon, positions in world axes.
  let pts = poly.verts.map((v) => ({
    p: toWorld(v),
    uv: [dot(sub(v, poly.base), poly.tu) + poly.panU, dot(sub(v, poly.base), poly.tv) + poly.panV],
  }));
  const us = pts.map((q) => q.uv[0]), vs = pts.map((q) => q.uv[1]);
  for (let tu = Math.floor(Math.min(...us) / TILE); tu * TILE < Math.max(...us); tu++) {
    for (let tv = Math.floor(Math.min(...vs) / TILE); tv * TILE < Math.max(...vs); tv++) {
      let piece = pts;
      piece = clip(piece, 0, tu * TILE, false);
      piece = clip(piece, 0, (tu + 1) * TILE, true);
      piece = clip(piece, 1, tv * TILE, false);
      piece = clip(piece, 1, (tv + 1) * TILE, true);
      if (piece.length < 3) continue;
      // drop slivers left by the grid
      let area = 0;
      for (let i = 1; i + 1 < piece.length; i++) {
        const e1 = sub(piece[i].p, piece[0].p), e2 = sub(piece[i + 1].p, piece[0].p);
        area += Math.hypot(e1[1] * e2[2] - e1[2] * e2[1], e1[2] * e2[0] - e1[0] * e2[2], e1[0] * e2[1] - e1[1] * e2[0]) / 2;
      }
      if (area < 0.05) { skipped++; continue; }
      const first = verts.length;
      for (const q of piece) {
        verts.push(q.p.slice());
        q.byte = [0, 1].map((k) => Math.max(0, Math.min(255, Math.round((q.uv[k] - [tu, tv][k] * TILE) * 256 / TILE))));
      }
      for (let i = 1; i + 1 < piece.length; i++) {
        const t = [first, first + i, first + i + 1];
        const uv = [piece[0].byte, piece[i].byte, piece[i + 1].byte];
        if (!world[pi].inward) { [t[1], t[2]] = [t[2], t[1]]; [uv[1], uv[2]] = [uv[2], uv[1]]; }
        tris.push({ t, uv });
      }
    }
  }
}

if (verts.length > 65535) throw new Error('too many vertices');
const center = [0, 1, 2].map((k) => Math.round((Math.min(...verts.map((v) => v[k])) + Math.max(...verts.map((v) => v[k]))) / 2) + shift[k]);
for (const v of verts) for (let k = 0; k < 3; k++) v[k] -= center[k];
const d = Buffer.alloc(48 + tris.length * 16);
d.writeUInt16LE(tris.length, 0);
d.writeUInt16LE(verts.length, 2);
tris.forEach((tr, i) => {
  const o = 48 + i * 16;
  tr.t.forEach((v, k) => d.writeUInt16LE(v, o + k * 2));
  d[o + 6] = 0; // type: normal one-sided
  d[o + 7] = 0; // color
  tr.uv.forEach((uv, k) => { d[o + 8 + k * 2] = uv[0]; d[o + 9 + k * 2] = uv[1]; });
  d[o + 14] = 0; // texture number
  d[o + 15] = 0; // flags
});
const a = Buffer.alloc(4 + verts.length * 8);
a.writeUInt16LE(1, 0);
a.writeUInt16LE(verts.length * 8, 2);
verts.forEach((v, i) => {
  v.forEach((c, k) => {
    const s = Math.round(c * 64);
    if (s < -32768 || s > 32767) throw new Error('vertex out of 16-bit range: ' + c);
    a.writeInt16LE(s, 4 + i * 8 + k * 2);
  });
});

const dir = path.join(__dirname, '..', 'CNN', 'Models');
fs.writeFileSync(path.join(dir, outBase + '_d.3d'), d);
fs.writeFileSync(path.join(dir, outBase + '_a.3d'), a);
const mn = [0, 1, 2].map((k) => Math.min(...verts.map((v) => v[k]))), mx = [0, 1, 2].map((k) => Math.max(...verts.map((v) => v[k])));
console.log(`${moverName} -> ${outBase}: ${polys.length} brush polys -> ${tris.length} triangles, ${verts.length} vertices` +
  ` (${skipped} slivers dropped, ${inwardCount} inward faces turned out); offset from mover (${center}); bounds ${mn.map((x) => x.toFixed(1))} .. ${mx.map((x) => x.toFixed(1))}`);
