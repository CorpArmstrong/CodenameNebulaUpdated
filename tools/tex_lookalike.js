#!/usr/bin/env node
/*
 * tex_lookalike.js - find the stock Deus Ex texture that looks most like a
 * mod texture, so a map can borrow the stock one instead (tools/pkg_reimport.js).
 *
 * Textures are decoded from the packages themselves (8-bit palettized mip 0,
 * the format of every stock texture) and described by colour (mean, spread),
 * a brightness histogram, how busy and which way the edges run, and a coarse
 * brightness layout -- colour alone pairs a hazard-striped panel with any
 * yellow wall. Size and aspect also count: a stock texture of another size
 * tiles differently on the same surface. --pool surface keeps the candidates
 * to level textures (no UI, skins, detail or font textures).
 *
 * Usage:
 *   node tools/tex_lookalike.js index <out.json> <pkg>...       thumbnails of every texture
 *   node tools/tex_lookalike.js match <stock.json> <mod.json> [--top N] [--only Pkg.Name,...] [--pool surface] > matches.json
 *   node tools/tex_lookalike.js html <matches.json> <out.html>  sheet: mod texture beside its candidates
 *
 * Written for the third-party texture inventory, 2026-10-25 (CNNDocs/Third_Party_Textures.md).
 */
'use strict';
const fs = require('fs');
const path = require('path');
const zlib = require('zlib');
const { load, Reader, readProps } = require('./pkg_probe.js');

const THUMB = 16;

// Texture export -> {w, h, rgb} of mip 0, or null for formats other than P8.
function decode(P, e) {
  const r = new Reader(P.buf, e.off);
  const { props, end } = readProps(P, r);
  const get = (n) => { const p = props.find((x) => x.name === n); return p ? p.value : undefined; };
  if (get('Format')) return null;
  r.p = end;
  if (r.ci() < 1) return null;
  if (P.ver >= 63) r.i32();
  const len = r.ci();
  const data = P.buf.subarray(r.p, r.p + len);
  r.p += len;
  const w = r.i32(), h = r.i32();
  if (w * h !== len) return null;
  const palRef = get('Palette');
  if (!palRef || palRef === 'None') return null;
  const pe = P.exports.find((x, i) => P.objPath(i + 1) === palRef);
  if (!pe) return null;
  const pr = new Reader(P.buf, pe.off);
  pr.p = readProps(P, pr).end;
  const n = pr.ci();
  const pal = P.buf.subarray(pr.p, pr.p + n * 4);
  const rgb = Buffer.alloc(w * h * 3);
  for (let i = 0; i < w * h; i++) { const c = data[i] * 4; rgb[i * 3] = pal[c]; rgb[i * 3 + 1] = pal[c + 1]; rgb[i * 3 + 2] = pal[c + 2]; }
  return { w, h, rgb, masked: !!get('bMasked') };
}

// Feature groups, each scaled to about 0..1 per entry (see distance()).
function features(t) {
  const N = 64;
  const s = thumb(t, N);
  const lum = new Float64Array(N * N);
  const col = [0, 0, 0], col2 = [0, 0, 0];
  for (let i = 0; i < N * N; i++) {
    const r = s[i * 3] / 255, g = s[i * 3 + 1] / 255, b = s[i * 3 + 2] / 255;
    lum[i] = 0.3 * r + 0.59 * g + 0.11 * b;
    [r, g, b].forEach((v, k) => { col[k] += v; col2[k] += v * v; });
  }
  const mean = col.map((v) => v / (N * N));
  const spread = col2.map((v, k) => Math.sqrt(Math.max(0, v / (N * N) - mean[k] * mean[k])));
  const hist = new Array(8).fill(0);
  for (const v of lum) hist[Math.min(7, Math.floor(v * 8))] += 1 / (N * N);
  // edges, wrapping around since textures tile
  const orient = new Array(8).fill(0);
  let edge = 0;
  for (let y = 0; y < N; y++) for (let x = 0; x < N; x++) {
    const gx = lum[y * N + (x + 1) % N] - lum[y * N + (x + N - 1) % N];
    const gy = lum[((y + 1) % N) * N + x] - lum[((y + N - 1) % N) * N + x];
    const m = Math.hypot(gx, gy);
    edge += m;
    let a = Math.atan2(gy, gx); if (a < 0) a += Math.PI;
    orient[Math.min(7, Math.floor(a / Math.PI * 8))] += m;
  }
  const orientN = orient.map((v) => (edge ? v / edge : 0));
  const layout = [];
  for (let y = 0; y < 8; y++) for (let x = 0; x < 8; x++) {
    let v = 0;
    for (let yy = 0; yy < 8; yy++) for (let xx = 0; xx < 8; xx++) v += lum[(y * 8 + yy) * N + x * 8 + xx];
    layout.push(v / 64);
  }
  const lm = layout.reduce((a, v) => a + v, 0) / 64;
  return { mean, spread, hist, edge: Math.min(1, edge / (N * N) * 4), orient: orientN, layout: layout.map((v) => v - lm) };
}

function thumb(t, size = THUMB) {
  const out = new Array(size * size * 3).fill(0);
  for (let y = 0; y < size; y++) for (let x = 0; x < size; x++) {
    const x0 = Math.floor(x * t.w / size), x1 = Math.max(x0 + 1, Math.floor((x + 1) * t.w / size));
    const y0 = Math.floor(y * t.h / size), y1 = Math.max(y0 + 1, Math.floor((y + 1) * t.h / size));
    let r = 0, g = 0, b = 0, n = 0;
    for (let yy = y0; yy < y1; yy++) for (let xx = x0; xx < x1; xx++) {
      const i = (yy * t.w + xx) * 3; r += t.rgb[i]; g += t.rgb[i + 1]; b += t.rgb[i + 2]; n++;
    }
    const o = (y * size + x) * 3; out[o] = r / n | 0; out[o + 1] = g / n | 0; out[o + 2] = b / n | 0;
  }
  return out;
}

function png(w, h, rgb) {
  const raw = Buffer.alloc((w * 3 + 1) * h);
  for (let y = 0; y < h; y++) rgb.copy(raw, y * (w * 3 + 1) + 1, y * w * 3, (y + 1) * w * 3);
  const crc = (b) => { let c = ~0; for (const x of b) { c ^= x; for (let k = 0; k < 8; k++) c = (c >>> 1) ^ (0xedb88320 & -(c & 1)); } return ~c >>> 0; };
  const chunk = (t, d) => {
    const l = Buffer.alloc(4); l.writeUInt32BE(d.length);
    const td = Buffer.concat([Buffer.from(t), d]); const c = Buffer.alloc(4); c.writeUInt32BE(crc(td));
    return Buffer.concat([l, td, c]);
  };
  const ih = Buffer.alloc(13); ih.writeUInt32BE(w, 0); ih.writeUInt32BE(h, 4); ih[8] = 8; ih[9] = 2;
  return Buffer.concat([Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]), chunk('IHDR', ih),
    chunk('IDAT', zlib.deflateSync(raw)), chunk('IEND', Buffer.alloc(0))]);
}

// A preview no larger than 128 px, as a data URI for the html sheet.
function preview(t) {
  const s = Math.min(1, 128 / Math.max(t.w, t.h));
  const w = Math.max(1, Math.round(t.w * s)), h = Math.max(1, Math.round(t.h * s));
  const rgb = Buffer.alloc(w * h * 3);
  for (let y = 0; y < h; y++) for (let x = 0; x < w; x++) {
    const i = (Math.floor(y / s) * t.w + Math.floor(x / s)) * 3; t.rgb.copy(rgb, (y * w + x) * 3, i, i + 3);
  }
  return 'data:image/png;base64,' + png(w, h, rgb).toString('base64');
}

function index(out, pkgs) {
  const all = [];
  for (const file of pkgs) {
    let P;
    try { P = load(file); } catch (err) { console.error(`${file}: ${err.message}`); continue; }
    const pkg = path.basename(file).replace(/\.[^.]+$/, '');
    P.exports.forEach((e, i) => {
      if (P.className(e) !== 'Texture' || !e.size) return;
      let t;
      try { t = decode(P, e); } catch (err) { t = null; }
      if (!t) return;
      all.push({ path: `${pkg}.${P.objPath(i + 1)}`, w: t.w, h: t.h, masked: t.masked, f: features(t), preview: preview(t) });
    });
    console.error(`${pkg}: ${all.length} so far`);
  }
  fs.writeFileSync(out, JSON.stringify(all));
}

// Lower is closer: a weighted sum of the feature groups' RMS differences,
// plus a penalty when the size differs (tiling changes), a larger one when
// the aspect does, and one for masked against solid.
const WEIGHTS = { mean: 30, spread: 15, hist: 15, edge: 10, orient: 20, layout: 10 };

function distance(a, b) {
  let d = 0;
  for (const [k, w] of Object.entries(WEIGHTS)) {
    const x = [].concat(a.f[k]), y = [].concat(b.f[k]);
    let s = 0;
    for (let i = 0; i < x.length; i++) s += (x[i] - y[i]) ** 2;
    d += w * Math.sqrt(s / x.length);
  }
  if (a.w !== b.w || a.h !== b.h) d += 2;
  if (a.w * b.h !== a.h * b.w) d += 4;
  if (a.masked !== b.masked) d += 8;
  return d;
}

// Stock packages that hold no wall, floor or sky textures.
const NOT_SURFACE = /^(DeusExUI|DeusExItems|DeusExCharacters|DeusExDeco|Engine|Render|CoreTexDetail|DXFonts|InfoPortraits|Palettes)\./i;

function match(stockFile, modFile, top, only, pool) {
  let stock = JSON.parse(fs.readFileSync(stockFile));
  if (pool === 'surface') stock = stock.filter((s) => !NOT_SURFACE.test(s.path));
  let mod = JSON.parse(fs.readFileSync(modFile));
  if (only) mod = mod.filter((m) => only.some((o) => m.path.toLowerCase() === o.toLowerCase()));
  const res = mod.map((m) => ({
    path: m.path, w: m.w, h: m.h, preview: m.preview,
    candidates: stock.map((s) => ({ path: s.path, w: s.w, h: s.h, preview: s.preview, d: +distance(m, s).toFixed(1) }))
      .sort((a, b) => a.d - b.d).slice(0, top),
  }));
  process.stdout.write(JSON.stringify(res));
}

function html(matchFile, out) {
  const res = JSON.parse(fs.readFileSync(matchFile));
  const cell = (t, extra = '') => `<td><img src="${t.preview}"><div>${t.path}<br>${t.w}x${t.h}${extra}</div></td>`;
  const rows = res.map((m) => `<tr>${cell(m)}${m.candidates.map((c) => cell(c, ` &middot; d=${c.d}`)).join('')}</tr>`);
  fs.writeFileSync(out, `<!doctype html><meta charset="utf-8"><title>Texture look-alikes</title>
<style>body{background:#222;color:#ddd;font:12px sans-serif}td{vertical-align:top;padding:4px;max-width:150px}
td:first-child{border-right:3px solid #c80}img{image-rendering:pixelated;max-width:128px;max-height:128px}</style>
<table>${rows.join('\n')}</table>`);
}

function main() {
  const [cmd, ...a] = process.argv.slice(2);
  if (cmd === 'index' && a.length >= 2) index(a[0], a.slice(1));
  else if (cmd === 'match' && a.length >= 2) {
    const ti = a.indexOf('--top'), oi = a.indexOf('--only'), pi = a.indexOf('--pool');
    match(a[0], a[1], ti >= 0 ? +a[ti + 1] : 3, oi >= 0 ? a[oi + 1].split(',') : null, pi >= 0 ? a[pi + 1] : null);
  } else if (cmd === 'html' && a.length === 2) html(a[0], a[1]);
  else { console.error(fs.readFileSync(__filename, 'utf8').split('*/')[0]); process.exit(1); }
}

if (require.main === module) main();
module.exports = { decode, features, distance };
