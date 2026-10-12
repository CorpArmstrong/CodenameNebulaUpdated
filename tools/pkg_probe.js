#!/usr/bin/env node
/*
 * pkg_probe.js - read Unreal Engine 1 packages (.dx/.u/.u3d) without UnrealEd.
 *
 * `ucc batchexport` cannot export a Level to T3D, and the only map T3Ds in the
 * repo are years stale, so questions like "which movers use this sound" or
 * "how many polygons is that door brush" had no answer from git. This reads
 * the package tables, an object's tagged properties, and UPolys brush data.
 *
 * Usage:
 *   node tools/pkg_probe.js <pkg> names [filter]
 *   node tools/pkg_probe.js <pkg> exports [classFilter]
 *   node tools/pkg_probe.js <pkg> props <ObjectName>
 *   node tools/pkg_probe.js <pkg> movers              every Mover: class, brush poly count, sounds
 *   node tools/pkg_probe.js <pkg> polys <PolysName> [verbose]
 *   node tools/pkg_probe.js <pkg> model <ModelName>     BSP counts, surface textures/flags, lightmaps
 */
'use strict';
const fs = require('fs');

class Reader {
  constructor(buf, pos = 0) { this.b = buf; this.p = pos; }
  u8() { return this.b[this.p++]; }
  i16() { const v = this.b.readInt16LE(this.p); this.p += 2; return v; }
  u16() { const v = this.b.readUInt16LE(this.p); this.p += 2; return v; }
  i32() { const v = this.b.readInt32LE(this.p); this.p += 4; return v; }
  u32() { const v = this.b.readUInt32LE(this.p); this.p += 4; return v; }
  f32() { const v = this.b.readFloatLE(this.p); this.p += 4; return v; }
  vec() { return [this.f32(), this.f32(), this.f32()]; }
  // FCompactIndex: sign + 6 bits, then 7 bits per continuation byte.
  ci() {
    const b0 = this.u8(); let v = b0 & 0x3f;
    if (b0 & 0x40) {
      let shift = 6, b;
      do { b = this.u8(); v |= (b & 0x7f) << shift; shift += 7; } while ((b & 0x80) && shift < 32);
    }
    return (b0 & 0x80) ? -v : v;
  }
  str() {
    const n = this.ci(); const s = this.b.toString('latin1', this.p, this.p + Math.max(0, n - 1));
    this.p += n; return s;
  }
}

function load(path) {
  const buf = fs.readFileSync(path);
  const r = new Reader(buf);
  if (r.u32() !== 0x9e2a83c1) throw new Error('not an Unreal package');
  const ver = r.u16(); r.u16(); r.u32();
  const nameCount = r.u32(), nameOff = r.u32(), expCount = r.u32(), expOff = r.u32(),
        impCount = r.u32(), impOff = r.u32();
  const names = [];
  r.p = nameOff;
  for (let i = 0; i < nameCount; i++) { names.push(r.str()); r.u32(); }
  const imports = [];
  r.p = impOff;
  for (let i = 0; i < impCount; i++)
    imports.push({ classPkg: names[r.ci()], className: names[r.ci()], pkg: r.i32(), name: names[r.ci()] });
  const exports = [];
  r.p = expOff;
  for (let i = 0; i < expCount; i++) {
    const e = { cls: r.ci(), sup: r.ci(), pkg: r.i32(), name: names[r.ci()], flags: r.u32(), size: r.ci() };
    e.off = e.size > 0 ? r.ci() : 0;
    exports.push(e);
  }
  const P = { buf, ver, names, imports, exports };
  P.objName = (ref) => {
    if (ref === 0) return 'None';
    if (ref < 0) { const im = imports[-ref - 1]; return im.name; }
    return exports[ref - 1].name;
  };
  P.objPath = (ref) => {
    if (ref === 0) return 'None';
    const parts = [];
    let cur = ref;
    while (cur !== 0) {
      if (cur < 0) { const im = imports[-cur - 1]; parts.unshift(im.name); cur = im.pkg; }
      else { const ex = exports[cur - 1]; parts.unshift(ex.name); cur = ex.pkg; }
    }
    return parts.join('.');
  };
  P.className = (e) => e.cls === 0 ? 'Class' : P.objName(e.cls);
  P.find = (name) => exports.find((e) => e.name.toLowerCase() === name.toLowerCase());
  return P;
}

// Tagged property stream. Returns {props, end}.
function readProps(P, r) {
  const props = [];
  for (;;) {
    const name = P.names[r.ci()];
    if (name === 'None') break;
    const info = r.u8();
    const type = info & 0x0f, sizeCode = (info >> 4) & 7, isArr = (info & 0x80) !== 0;
    let structName = null;
    if (type === 10) structName = P.names[r.ci()];
    let size;
    switch (sizeCode) {
      case 0: size = 1; break; case 1: size = 2; break; case 2: size = 4; break;
      case 3: size = 12; break; case 4: size = 16; break;
      case 5: size = r.u8(); break; case 6: size = r.u16(); break; case 7: size = r.u32(); break;
    }
    let idx = 0;
    if (isArr && type !== 3) {
      const b = r.u8();
      if ((b & 0x80) === 0) idx = b;
      else if ((b & 0xc0) === 0x80) idx = ((b & 0x7f) << 8) | r.u8();
      else idx = ((b & 0x3f) << 24) | (r.u8() << 16) | (r.u8() << 8) | r.u8();
    }
    const start = r.p;
    let value;
    switch (type) {
      case 1: value = r.u8(); break;
      case 2: value = r.i32(); break;
      case 3: value = isArr; break; // bool lives in the array bit
      case 4: value = r.f32(); break;
      case 5: { const sub = new Reader(r.b, r.p); value = P.objPath(sub.ci()); break; }
      case 6: { const sub = new Reader(r.b, r.p); value = P.names[sub.ci()]; break; }
      case 10:
        if (structName === 'Vector') { const s = new Reader(r.b, r.p); value = s.vec().map((x) => +x.toFixed(2)); }
        else if (structName === 'Rotator') { const s = new Reader(r.b, r.p); value = [s.i32(), s.i32(), s.i32()]; }
        else if (structName === 'Scale') { const s = new Reader(r.b, r.p); value = { scale: s.vec(), sheer: s.f32(), axis: s.u8() }; }
        else value = `<${structName} ${size}b>`;
        break;
      case 13: { const sub = new Reader(r.b, r.p); value = sub.str(); break; }
      default: value = `<type${type} ${size}b>`;
    }
    if (type !== 3) r.p = start + size;
    props.push({ name: idx ? `${name}[${idx}]` : name, value, type });
  }
  return { props, end: r.p };
}

function objProps(P, e) {
  const r = new Reader(P.buf, e.off);
  // Actors and other non-class objects with RF_HasStack carry a state frame first.
  // FStateFrame: Node, StateNode, QWORD ProbeMask, INT LatentAction, Offset if Node.
  if (e.flags & 0x02000000) { const node = r.ci(); r.ci(); r.p += 8; r.i32(); if (node) r.ci(); }
  return readProps(P, r);
}

function readPolys(P, e) {
  const { end } = objProps(P, e);
  const r = new Reader(P.buf, end);
  const num = r.i32(); r.i32();
  const polys = [];
  for (let i = 0; i < num; i++) {
    const nv = r.ci();
    const base = r.vec(), normal = r.vec(), tu = r.vec(), tv = r.vec();
    const verts = [];
    for (let k = 0; k < nv; k++) verts.push(r.vec());
    const flags = r.u32();
    const actor = r.ci(), tex = r.ci(), item = r.ci(), link = r.ci(), brushPoly = r.ci();
    const panU = r.i16(), panV = r.i16();
    polys.push({ nv, base, normal, tu, tv, verts, flags, tex: P.objPath(tex), item: P.names[item], link, brushPoly, panU, panV });
  }
  return polys;
}

// UModel (a brush or the level BSP), serialized as in UT v68 UModel::Serialize:
// UPrimitive bounds, then Vectors, Points, Nodes, Surfs, Verts, NumSharedSides,
// NumZones + zones, Polys. Returns the parsed BSP counts and the Polys export.
function readModel(P, e) {
  const { end } = objProps(P, e);
  const r = new Reader(P.buf, end);
  r.p += 25 + 16; // FBox + FSphere
  const nVectors = r.ci(); r.p += nVectors * 12;
  const nPoints = r.ci(); r.p += nPoints * 12;
  const nNodes = r.ci();
  for (let i = 0; i < nNodes; i++) {
    r.p += 16 + 8 + 1; for (let k = 0; k < 7; k++) r.ci(); r.p += 2 + 1 + 8;
  }
  const nSurfs = r.ci();
  const surfTex = {}, surfFlags = {}, surfs = [];
  for (let i = 0; i < nSurfs; i++) {
    const t = P.objPath(r.ci()); surfTex[t] = (surfTex[t] || 0) + 1;
    const flags = r.u32(); const fs = flagStr(flags); surfFlags[fs] = (surfFlags[fs] || 0) + 1;
    const idx = []; for (let k = 0; k < 6; k++) idx.push(r.ci());
    const panU = r.i16(), panV = r.i16(); r.ci();
    surfs.push({ tex: t, flags, pBase: idx[0], vNormal: idx[1], iLightMap: idx[4], iBrushPoly: idx[5], panU, panV });
  }
  const nVerts = r.ci(); for (let i = 0; i < nVerts; i++) { r.ci(); r.ci(); }
  r.i32();
  const nZones = r.i32();
  for (let i = 0; i < nZones; i++) { r.ci(); r.p += 16 + 4; }
  const polysRef = r.ci();
  const pe = polysRef > 0 ? P.exports[polysRef - 1] : null;
  const nLightMaps = r.ci();
  return { nNodes, nSurfs, nVerts, nPoints, nLightMaps, surfTex, surfFlags, surfs, polys: pe && P.className(pe) === 'Polys' ? pe : null };
}

const FLAGS = { 1: 'Invisible', 2: 'Masked', 4: 'Translucent', 8: 'NotSolid', 0x10: 'Environment',
  0x20: 'Semisolid', 0x40: 'Modulated', 0x80: 'FakeBackdrop', 0x100: 'TwoSided', 0x200: 'AutoUPan',
  0x400: 'AutoVPan', 0x800: 'NoSmooth', 0x1000: 'BigWavy', 0x2000: 'SmallWavy', 0x4000: 'Flat',
  0x8000: 'LowShadowDetail', 0x10000: 'NoMerge', 0x20000: 'CloudWavy', 0x40000: 'DirtyShadows',
  0x80000: 'BrightCorners', 0x100000: 'SpecialLit', 0x200000: 'Gouraud', 0x400000: 'Unlit',
  0x800000: 'HighShadowDetail', 0x1000000: 'Portal', 0x2000000: 'Mirror' };
const flagStr = (f) => Object.entries(FLAGS).filter(([k]) => f & +k).map(([, v]) => v).join('|') || '-';

function polyStats(polys) {
  const tex = {}, flags = {}, verts = {};
  let tris = 0;
  for (const p of polys) {
    tex[p.tex] = (tex[p.tex] || 0) + 1;
    flags[flagStr(p.flags)] = (flags[flagStr(p.flags)] || 0) + 1;
    verts[p.nv] = (verts[p.nv] || 0) + 1;
    tris += p.nv - 2;
  }
  return { count: polys.length, tris, tex, flags, verts };
}

function main() {
  const [path, cmd, arg, arg2] = process.argv.slice(2);
  if (!path || !cmd) { console.error(fs.readFileSync(__filename, 'utf8').split('*/')[0]); process.exit(1); }
  const P = load(path);
  if (cmd === 'names') {
    P.names.forEach((n, i) => { if (!arg || n.toLowerCase().includes(arg.toLowerCase())) console.log(i, n); });
  } else if (cmd === 'exports') {
    P.exports.forEach((e, i) => {
      const c = P.className(e);
      if (!arg || c.toLowerCase().includes(arg.toLowerCase())) console.log(i + 1, c, P.objPath(i + 1), e.size);
    });
  } else if (cmd === 'props') {
    const e = P.find(arg);
    if (!e) throw new Error('no export ' + arg);
    for (const p of objProps(P, e).props) console.log(p.name, '=', JSON.stringify(p.value));
  } else if (cmd === 'polys') {
    const e = P.find(arg);
    const polys = readPolys(P, e);
    console.log(JSON.stringify(polyStats(polys), null, 1));
    if (arg2) polys.forEach((p, i) => console.log(i, p.nv, 'N', p.normal.map((x) => x.toFixed(3)).join(','), flagStr(p.flags), p.tex));
  } else if (cmd === 'model') {
    const md = readModel(P, P.find(arg));
    const { surfs, ...rest } = md;
    console.log(JSON.stringify({ ...rest, polys: md.polys && md.polys.name }, null, 1));
    console.log('surfs without lightmap:', surfs.filter((x) => x.iLightMap < 0).length, 'of', surfs.length);
  } else if (cmd === 'movers') {
    P.exports.forEach((e, i) => {
      const c = P.className(e);
      if (!/Mover|Door/i.test(c) || e.size === 0 || P.objName(e.pkg) === 'None' && false) return;
      let props;
      try { props = objProps(P, e).props; } catch (err) { console.log(e.name, c, 'PARSE ERROR', err.message); return; }
      const get = (n) => { const p = props.find((x) => x.name === n); return p ? p.value : undefined; };
      const brush = get('Brush');
      let pc = '?';
      if (brush && brush !== 'None') {
        const me = P.find(brush.split('.').pop());
        let m = null; try { m = me && readModel(P, me); } catch (err) { pc = 'model?'; }
        if (m) pc = `${m.nNodes} nodes/${m.nSurfs} surfs` + (m.polys ? `, ${polyStats(readPolys(P, m.polys)).count} polys (${m.polys.name})` : ', polys?');
      }
      const sounds = props.filter((p) => /Sound/.test(p.name) && typeof p.value === 'string')
        .map((p) => `${p.name}=${p.value.split('.').pop()}`).join(' ');
      console.log(`${e.name} [${c}] tag=${get('Tag') || ''} loc=${JSON.stringify(get('Location'))} brush=${pc} ${sounds}`);
    });
  } else throw new Error('unknown command ' + cmd);
}

if (require.main === module) main();
module.exports = { load, readModel, Reader, readProps, objProps, readPolys, polyStats, flagStr };
