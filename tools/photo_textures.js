#!/usr/bin/env node
/*
 * photo_textures.js - public-domain photos in place of two images we could
 * not clear for distribution (CNNDocs/Third_Party_Textures.md, 2026-10-28):
 *   - Apollo11Crew 512x512 for CNN.rammstein3 (a frame of Rammstein's
 *     "Amerika" video), Moon: "Apollo XI - Prime Crew Portrait (S69-31740)",
 *     NASA Johnson Space Center, Wikimedia Commons, 3840px preview; cut to a
 *     square around the crew;
 *   - LASkyline 4096x2048 for LosAngelesTex.lasky (a photo of unknown source),
 *     Mutiny: "Downtown Los Angeles skyline.jpg" by Serouj, Wikimedia Commons,
 *     released into the public domain; turned to night like the old one --
 *     darkened, the sky above the skyline replaced with stars, a few lit
 *     windows.
 * Each keeps the size of the texture it replaces, so the surfaces keep their
 * mapping. Output: 24-bit BMPs in CNN/Textures/Photos, imported into CNN.u
 * by CNN/Classes/CNNTextures.uc as CNN.Photos.<name>.
 *
 * The photos are JPEGs; convert them to 24-bit PNG first (any editor, or
 * System.Drawing) and name them apollo11_crew.png and la_skyline.png.
 *
 * Usage: node tools/photo_textures.js <folder with the PNGs>
 */
'use strict';
const fs = require('fs');
const path = require('path');
const { readPng } = require('./tex_lookalike.js');

const OUT = path.join(__dirname, '..', 'CNN', 'Textures', 'Photos');

// 24-bit BMP, bottom-up rows padded to 4 bytes; ucc palettizes on import
function bmp(w, h, rgb) {
  const row = (w * 3 + 3) & ~3, b = Buffer.alloc(54 + row * h);
  b.write('BM'); b.writeUInt32LE(b.length, 2); b.writeUInt32LE(54, 10);
  b.writeUInt32LE(40, 14); b.writeInt32LE(w, 18); b.writeInt32LE(h, 22);
  b.writeUInt16LE(1, 26); b.writeUInt16LE(24, 28); b.writeUInt32LE(row * h, 34);
  for (let y = 0; y < h; y++) for (let x = 0; x < w; x++) {
    const s = (y * w + x) * 3, d = 54 + (h - 1 - y) * row + x * 3;
    b[d] = rgb[s + 2]; b[d + 1] = rgb[s + 1]; b[d + 2] = rgb[s];
  }
  return b;
}

// bilinear sample of the source at fractional (x, y)
function sample(src, x, y) {
  const x0 = Math.max(0, Math.min(src.w - 1, Math.floor(x))), y0 = Math.max(0, Math.min(src.h - 1, Math.floor(y)));
  const x1 = Math.min(src.w - 1, x0 + 1), y1 = Math.min(src.h - 1, y0 + 1), fx = x - x0, fy = y - y0;
  const out = [0, 0, 0];
  for (let c = 0; c < 3; c++) {
    const a = src.rgb[(y0 * src.w + x0) * 3 + c], b = src.rgb[(y0 * src.w + x1) * 3 + c];
    const d = src.rgb[(y1 * src.w + x0) * 3 + c], e = src.rgb[(y1 * src.w + x1) * 3 + c];
    out[c] = (a * (1 - fx) + b * fx) * (1 - fy) + (d * (1 - fx) + e * fx) * fy;
  }
  return out;
}

// box-filtered square cut of the source, scaled to size x size
function squareCut(src, ox, oy, side, size) {
  const rgb = Buffer.alloc(size * size * 3), s = side / size;
  for (let y = 0; y < size; y++) for (let x = 0; x < size; x++) {
    const acc = [0, 0, 0];
    let n = 0;
    for (let yy = Math.floor(y * s); yy < Math.floor((y + 1) * s); yy++) for (let xx = Math.floor(x * s); xx < Math.floor((x + 1) * s); xx++) {
      const i = ((oy + yy) * src.w + ox + xx) * 3;
      acc[0] += src.rgb[i]; acc[1] += src.rgb[i + 1]; acc[2] += src.rgb[i + 2]; n++;
    }
    for (let c = 0; c < 3; c++) rgb[(y * size + x) * 3 + c] = Math.round(acc[c] / n);
  }
  return rgb;
}

// repeatable noise in [0, 1)
function hash(x, y, k) {
  let h = (x * 374761393 + y * 668265263 + k * 2147483647) | 0;
  h = Math.imul(h ^ (h >>> 13), 1274126177);
  return ((h ^ (h >>> 16)) >>> 0) / 4294967296;
}

// The day photo as a night skyline: the photo's own sky gives way to a starry
// one above each column's first building; the city is darkened and cooled,
// with a few windows lit. The photo's sky is a smooth haze down to row 370
// (row brightness varies by 2-4), the towers rise from about 320 and the
// city fills the rows below 416.
function nightSkyline(src, w, h) {
  const top = 300, hazeEnd = 370, cityRow = 416;
  const scale = w / src.w, city = h - Math.round((src.h - top) * scale);
  const bright = (x, y) => { const i = (y * src.w + x) * 3; return (src.rgb[i] + src.rgb[i + 1] + src.rgb[i + 2]) / 3; };

  // the haze at each row: the row's median, held below hazeEnd
  const haze = [];
  for (let y = 0; y < src.h; y++) {
    if (y >= hazeEnd) { haze.push(haze[hazeEnd - 1]); continue; }
    const row = [];
    for (let x = 0; x < src.w; x++) row.push(bright(x, y));
    row.sort((a, b) => a - b);
    haze.push(row[row.length >> 1]);
  }

  // first source row of each column that is three rows darker than the haze
  const skyline = [];
  for (let x = 0; x < src.w; x++) {
    let y = top, run = 0;
    for (; y < cityRow; y++) {
      run = bright(x, y) < haze[y] - 14 ? run + 1 : 0;
      if (run === 3) { y -= 2; break; }
    }
    skyline.push(y);
  }

  const rgb = Buffer.alloc(w * h * 3);
  for (let y = 0; y < h; y++) for (let x = 0; x < w; x++) {
    const sx = x / scale, sy = top + (y - city) / scale;
    const edge = sy - skyline[Math.min(src.w - 1, Math.round(sx))];
    // night sky: a dark blue fading upward, stars thinning toward the horizon
    const t = y / h;
    let px = [6 + 10 * t, 9 + 16 * t, 22 + 26 * t];
    const star = hash(x, y, 1);
    if (star > 0.9985 - 0.0015 * (1 - t)) {
      const b = 90 + 165 * hash(x, y, 2) * (1 - t);
      px = [b * 0.9, b * 0.95, b];
    }
    if (sy >= top && edge > -1.5) {
      const p = sample(src, sx, sy), g = (p[0] + p[1] + p[2]) / 3;
      let n = [p[0] * 0.13 + g * 0.05, p[1] * 0.15 + g * 0.05, p[2] * 0.2 + g * 0.06];
      // a lit window here and there, warmer and denser lower down
      if (edge > 4 && hash(x >> 2, y >> 2, 3) > 0.997 - 0.005 * ((y - city) / (h - city))) n = [150 + 60 * hash(x >> 2, y >> 2, 4), 120, 70];
      const a = Math.max(0, Math.min(1, (edge + 1.5) / 3));
      px = px.map((v, c) => v * (1 - a) + n[c] * a);
    }
    for (let c = 0; c < 3; c++) rgb[(y * w + x) * 3 + c] = Math.max(0, Math.min(255, Math.round(px[c])));
  }
  return rgb;
}

function main() {
  const [dir] = process.argv.slice(2);
  if (!dir) { console.error(fs.readFileSync(__filename, 'utf8').split('*/')[0]); process.exit(1); }
  fs.mkdirSync(OUT, { recursive: true });

  const crew = readPng(path.join(dir, 'apollo11_crew.png'));
  if (!crew) throw new Error('apollo11_crew.png: unreadable');
  const side = Math.min(crew.w, crew.h);
  fs.writeFileSync(path.join(OUT, 'Apollo11Crew.bmp'), bmp(512, 512, squareCut(crew, (crew.w - side) >> 1, crew.h - side, side, 512)));
  console.log('Apollo11Crew 512x512');

  const la = readPng(path.join(dir, 'la_skyline.png'));
  if (!la) throw new Error('la_skyline.png: unreadable');
  fs.writeFileSync(path.join(OUT, 'LASkyline.bmp'), bmp(4096, 2048, nightSkyline(la, 4096, 2048)));
  console.log('LASkyline 4096x2048');
}

if (require.main === module) main();
